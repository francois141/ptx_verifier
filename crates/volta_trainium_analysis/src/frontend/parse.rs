//! Read an NKI kernel, specialized to one call's parameter shapes, as HBM tensors,
//! on-chip tiles and the instructions over them. The kernel's Python runs here, as
//! NKI's tracer runs it: integers, lists, `assert`s, loops and helper calls.

use std::collections::{BTreeMap, BTreeSet};
use std::fmt;
use std::num::NonZeroU64;

use super::ast::{
    Bounds, Buffer, Dtype, HbmDecl, Instruction, Kernel, Operand, Param, Partitions, RegionProblem,
    Scalar, Statement, Subscript, TensorName, TileDecl, TileShape, kept_extents, resolve_region,
};
use super::error::{ParseError, ShapeProblem, bail};
use super::lex::CmpOp;
use super::python::{
    self, BinOp, Call, Dotted, Expr, Function, FunctionSource, Item, Stmt, Target,
};

const NKI_LANGUAGE: &str = "nki.language";
const NKI_ISA: &str = "nki.isa";
/// The `nki.language` buffer of a device-memory tensor the kernel allocates.
const SHARED_HBM: &str = "shared_hbm";
/// `nl.tile_size`'s members, the hardware's tile limits.
const TILE_SIZES: [(&str, u64); 3] = [
    ("pmax", Partitions::MAX as u64),
    ("gemm_stationary_fmax", 128),
    ("gemm_moving_fmax", 512),
];
/// The name the kernel's own module goes by.
const MAIN: &str = "__main__";
/// How deeply helper calls may nest, which bounds recursion.
const MAX_CALL_DEPTH: usize = 32;

/// Parse `source` and return its `@nki.jit` kernel `name` for a call whose
/// arguments have `shapes`, as `@nki.jit` specializes a kernel to each call.
pub fn parse_kernel(
    source: &str,
    name: &str,
    shapes: &[(&str, &[u64])],
) -> Result<Kernel, ParseError> {
    parse_kernel_with_modules(source, &[], name, shapes)
}

/// `parse_kernel` for a kernel whose file imports from `modules`, the other
/// modules' sources by module name, e.g. `("attention_kernel_utils", source)`.
pub fn parse_kernel_with_modules(
    source: &str,
    modules: &[(&str, &str)],
    name: &str,
    shapes: &[(&str, &[u64])],
) -> Result<Kernel, ParseError> {
    let mut program = Program {
        modules: BTreeMap::new(),
    };
    program.modules.insert(MAIN.into(), Module::parse(source)?);
    for (module, source) in modules {
        program
            .modules
            .insert((*module).into(), Module::parse(source)?);
    }
    kernel(&program, name, shapes)
}

/// The shapes kernel `name`'s top-level `assert param.shape == (extent, ...)`
/// statements state, the first for each parameter, for running it without a call.
pub fn asserted_shapes(source: &str, name: &str) -> Result<Vec<(String, Vec<u64>)>, ParseError> {
    let function = Module::parse(source)?.function(name)?.parse()?;
    let params: Vec<&str> = function.params.iter().map(|p| p.name.as_str()).collect();

    let mut shapes: Vec<(String, Vec<u64>)> = Vec::new();
    for stmt in &function.body {
        let Some((param, extents)) = literal_shape(stmt) else {
            continue;
        };
        if params.contains(&param.as_str()) && !shapes.iter().any(|(given, _)| *given == param) {
            shapes.push((param, extents));
        }
    }
    Ok(shapes)
}

/// The name and extents of `assert name.shape == (extent, ...)` with integer literal extents.
fn literal_shape(stmt: &Stmt) -> Option<(String, Vec<u64>)> {
    let Stmt::Assert {
        test: Expr::Compare { first, rest },
        ..
    } = stmt
    else {
        return None;
    };
    let (Expr::Name(name), [(CmpOp::Eq, Expr::Tuple(extents))]) = (&**first, &rest[..]) else {
        return None;
    };
    if name.attributes != ["shape"] {
        return None;
    }

    let extents = extents
        .iter()
        .map(|extent| match extent {
            Expr::Int(extent) => Some(*extent),
            _ => None,
        })
        .collect::<Option<_>>()?;
    Some((name.head.clone(), extents))
}

// =============================================================================
// Modules
// =============================================================================

/// Every module a kernel may reach, by module name; the kernel's own is `MAIN`.
struct Program {
    modules: BTreeMap<String, Module>,
}

/// A module's global names. Functions are parsed only when called.
struct Module {
    globals: BTreeMap<String, Global>,
}

enum Global {
    /// `import a.b as c` binds `c` to the module `a.b`, `import a.b` binds `a` to `a`.
    Module(String),
    /// `from module import name`.
    Imported {
        module: String,
        name: String,
    },
    Function(FunctionSource),
    Class,
}

impl Module {
    /// A module's items as its globals; no global name is bound twice.
    fn parse(source: &str) -> Result<Self, ParseError> {
        let mut globals = BTreeMap::new();
        let mut bind = |name: String, global: Global, line: usize| {
            if globals.insert(name.clone(), global).is_some() {
                bail!(line, "`{name}` is defined twice");
            }
            Ok(())
        };

        for item in python::parse(source)? {
            match item {
                Item::Import { line, path, alias } => {
                    let (name, module) = match alias {
                        Some(alias) => (alias, path.to_string()),
                        None => (path.head.clone(), path.head),
                    };
                    bind(name, Global::Module(module), line)?;
                }
                Item::FromImport {
                    line,
                    module,
                    names,
                } => {
                    for (name, alias) in names {
                        let global = Global::Imported {
                            module: module.to_string(),
                            name: name.clone(),
                        };
                        bind(alias.unwrap_or(name), global, line)?;
                    }
                }
                Item::Function(function) => bind(
                    function.name.clone(),
                    Global::Function(function.clone()),
                    function.line,
                )?,
                Item::Class { line, name } => bind(name, Global::Class, line)?,
            }
        }
        Ok(Self { globals })
    }

    fn function(&self, name: &str) -> Result<&FunctionSource, ParseError> {
        match self.globals.get(name) {
            Some(Global::Function(function)) => Ok(function),
            _ => Err(ParseError::KernelNotFound(name.into())),
        }
    }
}

// =============================================================================
// Kernels and calls
// =============================================================================

/// What running a kernel's Python accumulates, across every call it makes.
struct Trace<'p> {
    program: &'p Program,
    /// Every tensor declared so far.
    tensors: BTreeMap<TensorName, Declared>,
    /// The items of each list `Value::List` refers to: lists are shared, as in Python.
    lists: Vec<Vec<Value>>,
    /// The statements emitted so far, in order.
    body: Vec<Statement>,
    /// How many times each helper function has been called, which names its tiles.
    calls: BTreeMap<String, u64>,
    depth: usize,
}

/// A declared tensor's extents and whether it is in device memory.
struct Declared {
    extents: Vec<u64>,
    place: Place,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Place {
    /// Device memory (HBM): a parameter or an `nl.shared_hbm` tensor.
    Hbm,
    /// An SBUF or PSUM tile.
    OnChip,
}

/// One function call's names.
struct Frame<'p> {
    module: &'p str,
    locals: BTreeMap<String, Value>,
    /// The names the function assigns anywhere, which are local throughout it.
    assigned: BTreeSet<String>,
    /// Prepended to the tensors the call declares: `softmax_isa[0].` in `softmax_isa`'s first call.
    prefix: String,
    /// The index of each enclosing unrolled iteration, outermost first.
    iterations: Vec<u64>,
}

/// A `@nki.jit` function, its parameters the HBM tensors it receives with the
/// call's shapes, and the tensor its last statement returns, if that is a `return`.
fn kernel(program: &Program, name: &str, shapes: &[(&str, &[u64])]) -> Result<Kernel, ParseError> {
    let function = program.modules[MAIN].function(name)?.parse()?;
    let line = function.line;
    let mut trace = Trace {
        program,
        tensors: BTreeMap::new(),
        lists: Vec::new(),
        body: Vec::new(),
        calls: BTreeMap::new(),
        depth: 0,
    };
    let mut frame = Frame::new(MAIN, &function, String::new());

    let decorators: Vec<String> = function.decorators.iter().map(Dotted::to_string).collect();
    let is_jit = match &function.decorators[..] {
        [decorator] => frame.resolve(&trace, decorator, line)?.member_of("nki") == Some("jit"),
        _ => false,
    };
    if !is_jit {
        bail!(
            line,
            "a kernel must be decorated `@nki.jit` only, not {decorators:?}"
        );
    }

    for (index, (given, _)) in shapes.iter().enumerate() {
        let problem = if !function.params.iter().any(|param| param.name == *given) {
            ShapeProblem::NotAParam
        } else if shapes[..index].iter().any(|(earlier, _)| earlier == given) {
            ShapeProblem::Repeated
        } else {
            continue;
        };
        return Err(ParseError::ParamShape {
            param: (*given).into(),
            problem,
        });
    }

    let mut params = Vec::new();
    for param in &function.params {
        if param.default.is_some() {
            bail!(
                line,
                "kernel parameter `{}` cannot have a default",
                param.name
            );
        }
        let shape = param_shape(&param.name, shapes)?;
        let extents = shape.iter().map(|extent| extent.get()).collect();
        let tensor = trace.declare(&frame, &param.name, extents, Place::Hbm);
        frame
            .locals
            .insert(param.name.clone(), Value::Tensor(tensor.clone()));
        params.push(Param {
            name: tensor,
            shape,
        });
    }

    let returned = match run(function.body, &mut trace, &mut frame)? {
        None => None,
        Some(Value::Tensor(tensor)) => Some(tensor),
        Some(other) => bail!(line, "a kernel can only return a tensor, not `{other}`"),
    };

    Ok(Kernel {
        name: function.name,
        params,
        body: trace.body,
        returned,
    })
}

/// The shape `shapes` gives parameter `param`: one or more positive extents.
fn param_shape(param: &str, shapes: &[(&str, &[u64])]) -> Result<Vec<NonZeroU64>, ParseError> {
    let problem = |problem| ParseError::ParamShape {
        param: param.into(),
        problem,
    };

    let Some((_, extents)) = shapes.iter().find(|(given, _)| *given == param) else {
        return Err(problem(ShapeProblem::Missing));
    };
    let shape: Option<Vec<NonZeroU64>> = extents.iter().map(|&e| NonZeroU64::new(e)).collect();
    match shape {
        Some(shape) if !shape.is_empty() => Ok(shape),
        _ => Err(problem(ShapeProblem::Empty)),
    }
}

/// Run a function body; a `return` may only be its last statement, whose value it gives.
fn run(
    mut body: Vec<Stmt>,
    trace: &mut Trace,
    frame: &mut Frame,
) -> Result<Option<Value>, ParseError> {
    let returned = match body.pop() {
        Some(Stmt::Return { line, value }) => Some((value, line)),
        last => {
            body.extend(last);
            None
        }
    };

    for stmt in body {
        statement(stmt, trace, frame)?;
    }
    returned
        .map(|(value, line)| returned_value(value, trace, frame, line))
        .transpose()
}

/// `return value`'s value; `value` may be a helper call, as an assignment's may.
fn returned_value(
    value: Expr,
    trace: &mut Trace,
    frame: &mut Frame,
    line: usize,
) -> Result<Value, ParseError> {
    let Expr::Call(call) = &value else {
        return trace.evaluate(frame, value, line);
    };
    let Value::Function { module, name } = frame.resolve(trace, &call.callee, line)? else {
        return trace.evaluate(frame, value, line);
    };
    let Some(returned) = inline(&module, &name, call.clone(), trace, frame, line)? else {
        bail!(line, "`{name}` returns nothing to return");
    };
    Ok(returned)
}

/// Call helper `name` of `module` with `call`'s arguments, evaluated in the caller's
/// `frame`: its body runs in a frame of its own, its tiles named after the call.
fn inline(
    module: &str,
    name: &str,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Option<Value>, ParseError> {
    let program = trace.program;
    let in_call = |error| ParseError::InCall {
        function: name.into(),
        module: module.into(),
        error: Box::new(error),
    };

    let function = program.modules[module]
        .function(name)?
        .parse()
        .map_err(in_call)?;
    if !function.decorators.is_empty() {
        bail!(line, "`{name}` is decorated, so it cannot be called inline");
    }
    if trace.depth == MAX_CALL_DEPTH {
        bail!(line, "calls nest more than {MAX_CALL_DEPTH} deep");
    }

    let mut args = Vec::new();
    for arg in call.args {
        args.push(trace.evaluate(frame, arg, line)?);
    }
    let mut kwargs = Vec::new();
    for (keyword, arg) in call.kwargs {
        kwargs.push((keyword, trace.evaluate(frame, arg, line)?));
    }

    let count = trace.calls.entry(name.to_string()).or_default();
    let prefix = format!("{name}[{count}].");
    *count += 1;
    let module = program
        .modules
        .get_key_value(module)
        .expect("a loaded module")
        .0;
    let mut callee = Frame::new(module, &function, prefix);
    bind_arguments(&function, args, kwargs, trace, &mut callee, line)?;

    trace.depth += 1;
    let returned = run(function.body, trace, &mut callee).map_err(in_call);
    trace.depth -= 1;
    returned
}

/// Bind each of `function`'s parameters to its argument, by position or keyword, else to
/// its default, evaluated in the callee's module.
fn bind_arguments(
    function: &Function,
    args: Vec<Value>,
    kwargs: Vec<(String, Value)>,
    trace: &mut Trace,
    callee: &mut Frame,
    line: usize,
) -> Result<(), ParseError> {
    let name = &function.name;
    if args.len() > function.params.len() {
        bail!(
            line,
            "`{name}` takes at most {} arguments",
            function.params.len()
        );
    }

    let mut given: Vec<Option<Value>> = function.params.iter().map(|_| None).collect();
    for (slot, arg) in given.iter_mut().zip(args) {
        *slot = Some(arg);
    }
    for (keyword, arg) in kwargs {
        let Some(index) = function.params.iter().position(|p| p.name == keyword) else {
            bail!(line, "`{name}` has no parameter `{keyword}`");
        };
        if given[index].replace(arg).is_some() {
            bail!(line, "argument `{keyword}` of `{name}` given twice");
        }
    }

    for (param, value) in function.params.iter().zip(given) {
        let value = match (value, &param.default) {
            (Some(value), _) => value,
            (None, Some(default)) => {
                let empty = Frame::new(callee.module, function, String::new());
                trace.evaluate(&empty, default.clone(), line)?
            }
            (None, None) => bail!(line, "`{name}` needs an argument for `{}`", param.name),
        };
        callee.locals.insert(param.name.clone(), value);
    }
    Ok(())
}

// =============================================================================
// Values
// =============================================================================

/// What an expression denotes. A tensor's `shape` is a tuple of its extents.
#[derive(Clone, PartialEq)]
enum Value {
    Int(u64),
    Float(Scalar),
    Bool(bool),
    Tuple(Vec<Value>),
    /// A list: an index into `Trace::lists`, so every name bound to it sees a change.
    List(usize),
    Tensor(TensorName),
    /// `t.dtype`: the element type of tensor `t`.
    DtypeOf(TensorName),
    /// An imported module's member, fully qualified: `nl.add` is `nki.language.add`.
    Member(String),
    /// A rectangular region of a tensor, from a subscript.
    Region {
        tensor: TensorName,
        dims: Vec<Subscript>,
    },
    /// A function of a module, called by running its body.
    Function {
        module: String,
        name: String,
    },
    Builtin(Builtin),
}

/// The Python built-in functions the subset runs.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Builtin {
    List,
    Tuple,
    /// `range(count)`, only as a `for` loop's iterable.
    Range,
}

impl Builtin {
    const ALL: [Self; 3] = [Self::List, Self::Tuple, Self::Range];

    fn name(self) -> &'static str {
        match self {
            Self::List => "list",
            Self::Tuple => "tuple",
            Self::Range => "range",
        }
    }
}

impl Value {
    /// Its name in `module` if it is a direct member: `dma_copy` for `nki.isa.dma_copy`.
    fn member_of(&self, module: &str) -> Option<&str> {
        let Self::Member(member) = self else {
            return None;
        };
        let name = member.strip_prefix(module)?.strip_prefix('.')?;
        (!name.contains('.')).then_some(name)
    }
}

impl fmt::Display for Value {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Int(value) => write!(f, "{value}"),
            Self::Float(value) => write!(f, "{value}"),
            Self::Bool(value) => f.write_str(if *value { "True" } else { "False" }),
            Self::Tuple(items) => {
                let items: Vec<String> = items.iter().map(Value::to_string).collect();
                write!(f, "({})", items.join(", "))
            }
            Self::List(_) => f.write_str("a list"),
            Self::Tensor(tensor) => write!(f, "{tensor}"),
            Self::DtypeOf(tensor) => write!(f, "{tensor}.dtype"),
            Self::Member(member) => f.write_str(member),
            Self::Region { tensor, dims } => {
                let dims: Vec<String> = dims.iter().map(Subscript::to_string).collect();
                write!(f, "{tensor}[{}]", dims.join(", "))
            }
            Self::Function { name, .. } => write!(f, "function `{name}`"),
            Self::Builtin(builtin) => write!(f, "built-in `{}`", builtin.name()),
        }
    }
}

impl<'p> Frame<'p> {
    fn new(module: &'p str, function: &Function, prefix: String) -> Self {
        let mut assigned = BTreeSet::new();
        assigned_names(&function.body, &mut assigned);
        Self {
            module,
            locals: BTreeMap::new(),
            assigned,
            prefix,
            iterations: Vec::new(),
        }
    }

    /// `name` and its attributes: a local, else a global of the frame's module, else a
    /// built-in. A name the function assigns is local throughout it, as in Python.
    fn resolve(&self, trace: &Trace, name: &Dotted, line: usize) -> Result<Value, ParseError> {
        let head = &name.head;
        let value = if let Some(value) = self.locals.get(head) {
            value.clone()
        } else if self.assigned.contains(head) {
            bail!(line, "`{head}` is read before it is assigned");
        } else if let Some(value) = global(trace.program, self.module, head, line, 0)? {
            value
        } else if let Some(builtin) = Builtin::ALL.into_iter().find(|b| b.name() == head) {
            Value::Builtin(builtin)
        } else {
            bail!(line, "unknown name `{head}`");
        };

        match (value, name.attributes.as_slice()) {
            (value, []) => Ok(value),
            (Value::Member(mut member), attributes) => {
                for attribute in attributes {
                    member.push('.');
                    member.push_str(attribute);
                }
                tile_size(member, line)
            }
            (Value::Tensor(tensor), [attribute]) if attribute == "dtype" => {
                Ok(Value::DtypeOf(tensor))
            }
            (Value::Tensor(tensor), [attribute]) if attribute == "shape" => Ok(Value::Tuple(
                trace.tensors[&tensor]
                    .extents
                    .iter()
                    .map(|&e| Value::Int(e))
                    .collect(),
            )),
            (Value::Tensor(_), _) => bail!(line, "unsupported tensor attribute `{name}`"),
            (_, _) => bail!(line, "unsupported attribute on `{head}`"),
        }
    }
}

/// Global `name` of `module`, if it has one; `follows` counts the `from ... import`s
/// followed to reach it, which bounds an import cycle.
fn global(
    program: &Program,
    module: &str,
    name: &str,
    line: usize,
    follows: usize,
) -> Result<Option<Value>, ParseError> {
    let Some(global) = program.modules[module].globals.get(name) else {
        return Ok(None);
    };
    let value = match global {
        Global::Module(path) => Value::Member(path.clone()),
        Global::Function(_) => Value::Function {
            module: module.into(),
            name: name.into(),
        },
        Global::Class => bail!(line, "`{name}` is a class, and classes are not supported"),
        Global::Imported { module: from, name } => {
            if follows == program.modules.len() {
                bail!(line, "`{name}` is imported in a cycle");
            }
            if program.modules.contains_key(from) {
                let Some(value) = self::global(program, from, name, line, follows + 1)? else {
                    bail!(line, "module `{from}` has no `{name}`");
                };
                value
            } else if from == "nki" || from.starts_with("nki.") {
                tile_size(format!("{from}.{name}"), line)?
            } else {
                bail!(
                    line,
                    "`{name}` is imported from `{from}`, a module that was not given"
                )
            }
        }
    };
    Ok(Some(value))
}

/// Every name `body` assigns: assignment targets and loop variables, nested loops included.
fn assigned_names(body: &[Stmt], names: &mut BTreeSet<String>) {
    for stmt in body {
        match stmt {
            Stmt::Assign { target, .. } => match target {
                Target::Name(name) | Target::Item { name, .. } => {
                    names.insert(name.clone());
                }
                Target::Unpack(targets) => names.extend(targets.iter().cloned()),
            },
            Stmt::For { var, body, .. } => {
                names.insert(var.clone());
                assigned_names(body, names);
            }
            Stmt::Expr { .. } | Stmt::Assert { .. } | Stmt::Return { .. } => {}
        }
    }
}

impl Trace<'_> {
    /// Declare tensor `name` of `frame`, named after the frame's call and iterations
    /// (`softmax_isa[0].x.1`); a name declared again, as `x = nl.exp(x)` does, takes a
    /// version suffix Python cannot write, `x~1`, so every tensor has a name of its own.
    fn declare(
        &mut self,
        frame: &Frame,
        name: &str,
        extents: Vec<u64>,
        place: Place,
    ) -> TensorName {
        let mut qualified = format!("{}{name}", frame.prefix);
        for index in &frame.iterations {
            qualified.push('.');
            qualified.push_str(&index.to_string());
        }

        let mut tensor = TensorName(qualified.clone());
        let mut version = 0;
        while self.tensors.contains_key(&tensor) {
            version += 1;
            tensor = TensorName(format!("{qualified}~{version}"));
        }
        self.tensors
            .insert(tensor.clone(), Declared { extents, place });
        tensor
    }

    fn evaluate(&mut self, frame: &Frame, expr: Expr, line: usize) -> Result<Value, ParseError> {
        match expr {
            Expr::Int(value) => Ok(Value::Int(value)),
            Expr::Float(value) => Ok(Value::Float(value)),
            Expr::Bool(value) => Ok(Value::Bool(value)),
            Expr::Name(name) => frame.resolve(self, &name, line),
            Expr::Tuple(items) => Ok(Value::Tuple(self.evaluate_all(frame, items, line)?)),
            Expr::List(items) => {
                let items = self.evaluate_all(frame, items, line)?;
                Ok(self.new_list(items))
            }
            Expr::Binary { op, lhs, rhs } => {
                let lhs = self.evaluate(frame, *lhs, line)?;
                let rhs = self.evaluate(frame, *rhs, line)?;
                let (Value::Int(lhs), Value::Int(rhs)) = (lhs, rhs) else {
                    bail!(line, "arithmetic needs integer operands");
                };
                let value = match op {
                    BinOp::Mul => lhs.checked_mul(rhs),
                    BinOp::FloorDiv if rhs == 0 => bail!(line, "integer division by zero"),
                    BinOp::FloorDiv => Some(lhs / rhs),
                    BinOp::Add => lhs.checked_add(rhs),
                };
                let Some(value) = value else {
                    bail!(line, "integer arithmetic overflows");
                };
                Ok(Value::Int(value))
            }
            Expr::Subscript { base, indices } => {
                let base = self.evaluate(frame, *base, line)?;
                self.subscript(frame, base, indices, line)
            }
            Expr::Slice { .. } => bail!(line, "a slice is only valid inside `[]`"),
            Expr::Call(call) => {
                let callee = frame.resolve(self, &call.callee, line)?;
                let Value::Builtin(builtin) = callee else {
                    bail!(
                        line,
                        "`{}` can only be called as a statement or an assignment's value",
                        call.callee
                    );
                };
                self.builtin(frame, builtin, call, line)
            }
            Expr::Compare { .. } => bail!(line, "a comparison is only valid in an `assert`"),
        }
    }

    /// `base[indices]`: a tensor's region, an integer or a slice per leading
    /// dimension, or a tuple's or list's item.
    fn subscript(
        &mut self,
        frame: &Frame,
        base: Value,
        indices: Vec<Expr>,
        line: usize,
    ) -> Result<Value, ParseError> {
        if let Value::Tensor(tensor) = base {
            let mut dims = Vec::new();
            for index in indices {
                dims.push(self.subscript_index(frame, index, line)?);
            }
            return Ok(Value::Region { tensor, dims });
        }

        let [index] = &indices[..] else {
            bail!(line, "a tuple or list takes one index");
        };
        let Value::Int(index) = self.evaluate(frame, index.clone(), line)? else {
            bail!(line, "an index must be an integer");
        };
        let items = match &base {
            Value::Tuple(items) => items,
            Value::List(list) => &self.lists[*list],
            _ => bail!(line, "`{base}` cannot be indexed"),
        };
        let item = usize::try_from(index)
            .ok()
            .and_then(|index| items.get(index));
        let Some(item) = item else {
            bail!(line, "index {index} is out of range");
        };
        Ok(item.clone())
    }

    /// `list(items)` or `tuple(items)` of a tuple or list.
    fn builtin(
        &mut self,
        frame: &Frame,
        builtin: Builtin,
        call: Call,
        line: usize,
    ) -> Result<Value, ParseError> {
        let name = builtin.name();
        if builtin == Builtin::Range {
            bail!(line, "`range` is only supported as a `for` loop's iterable");
        }
        if !call.kwargs.is_empty() {
            bail!(line, "`{name}` takes no keyword arguments");
        }
        let [arg] = &call.args[..] else {
            bail!(line, "`{name}` takes one argument");
        };
        let items = match self.evaluate(frame, arg.clone(), line)? {
            Value::Tuple(items) => items,
            Value::List(list) => self.lists[list].clone(),
            other => bail!(line, "`{name}` needs a tuple or a list, not `{other}`"),
        };
        Ok(match builtin {
            Builtin::List => self.new_list(items),
            Builtin::Tuple => Value::Tuple(items),
            Builtin::Range => unreachable!("rejected above"),
        })
    }

    fn evaluate_all(
        &mut self,
        frame: &Frame,
        exprs: Vec<Expr>,
        line: usize,
    ) -> Result<Vec<Value>, ParseError> {
        exprs
            .into_iter()
            .map(|expr| self.evaluate(frame, expr, line))
            .collect()
    }

    fn new_list(&mut self, items: Vec<Value>) -> Value {
        self.lists.push(items);
        Value::List(self.lists.len() - 1)
    }

    /// The first comparison of the chain `first op second ...` that is false, if any.
    fn failed_comparison(
        &mut self,
        frame: &Frame,
        first: Expr,
        rest: Vec<(CmpOp, Expr)>,
        line: usize,
    ) -> Result<Option<(Value, CmpOp, Value)>, ParseError> {
        let mut lhs = self.evaluate(frame, first, line)?;
        for (op, rhs) in rest {
            let rhs = self.evaluate(frame, rhs, line)?;
            if !holds(op, &lhs, &rhs, line)? {
                return Ok(Some((lhs, op, rhs)));
            }
            lhs = rhs;
        }
        Ok(None)
    }

    /// One index of a tensor's subscript: a slice, or an integer.
    fn subscript_index(
        &mut self,
        frame: &Frame,
        index: Expr,
        line: usize,
    ) -> Result<Subscript, ParseError> {
        if let Expr::Slice { start, stop } = index {
            return Ok(Subscript::Slice(Bounds {
                start: self.bound(frame, start, line)?,
                stop: self.bound(frame, stop, line)?,
            }));
        }
        match self.evaluate(frame, index, line)? {
            Value::Int(index) => Ok(Subscript::Index(index)),
            other => bail!(
                line,
                "a tensor index must be an integer or a slice, not `{other}`"
            ),
        }
    }

    /// A slice bound, absent when the subscript omits it.
    fn bound(
        &mut self,
        frame: &Frame,
        bound: Option<Box<Expr>>,
        line: usize,
    ) -> Result<Option<u64>, ParseError> {
        let Some(expr) = bound else {
            return Ok(None);
        };
        let Value::Int(value) = self.evaluate(frame, *expr, line)? else {
            bail!(line, "a slice bound must be an integer");
        };
        Ok(Some(value))
    }
}

/// An `nl.tile_size` limit as its integer; any other member as itself.
fn tile_size(member: String, line: usize) -> Result<Value, ParseError> {
    let Some(limit) = member
        .strip_prefix(NKI_LANGUAGE)
        .and_then(|rest| rest.strip_prefix(".tile_size."))
    else {
        return Ok(Value::Member(member));
    };
    let Some(&(_, value)) = TILE_SIZES.iter().find(|(name, _)| *name == limit) else {
        bail!(line, "unsupported tile size `nl.tile_size.{limit}`");
    };
    Ok(Value::Int(value))
}

/// Whether `lhs op rhs` holds: integers compare by any operator, tuples such as
/// shapes by `==` and `!=`.
fn holds(op: CmpOp, lhs: &Value, rhs: &Value, line: usize) -> Result<bool, ParseError> {
    match (lhs, rhs, op) {
        (Value::Int(lhs), Value::Int(rhs), _) => Ok(match op {
            CmpOp::Eq => lhs == rhs,
            CmpOp::Ne => lhs != rhs,
            CmpOp::Lt => lhs < rhs,
            CmpOp::Le => lhs <= rhs,
            CmpOp::Gt => lhs > rhs,
            CmpOp::Ge => lhs >= rhs,
        }),
        (Value::Tuple(_), Value::Tuple(_), CmpOp::Eq) => Ok(lhs == rhs),
        (Value::Tuple(_), Value::Tuple(_), CmpOp::Ne) => Ok(lhs != rhs),
        _ => bail!(
            line,
            "cannot compare `{lhs}` {} `{rhs}`: `assert` compares integers, or tuples by `==` and `!=`",
            op.text()
        ),
    }
}

// =============================================================================
// Statements
// =============================================================================

fn statement(stmt: Stmt, trace: &mut Trace, frame: &mut Frame) -> Result<(), ParseError> {
    match stmt {
        Stmt::Assign {
            line,
            target,
            value,
        } => assignment(target, value, trace, frame, line),
        Stmt::Expr { line, value } => effect(value, trace, frame, line),
        Stmt::Assert { line, test } => assertion(test, trace, frame, line),
        Stmt::For {
            line,
            var,
            iterable,
            body,
        } => unroll(var, iterable, body, trace, frame, line),
        Stmt::Return { line, .. } => bail!(line, "`return` must be a function's last statement"),
    }
}

/// `for var in iterable:` as its body once per item, binding `var` to it; each
/// iteration's tiles take its index as a suffix (`x.0`), so each declares its own.
fn unroll(
    var: String,
    iterable: Expr,
    body: Vec<Stmt>,
    trace: &mut Trace,
    frame: &mut Frame,
    line: usize,
) -> Result<(), ParseError> {
    let items = iterable_items(iterable, trace, frame, line)?;

    let mut index = 0;
    // A list is iterated live, as in Python: the body may change it.
    while let Some(item) = items.get(trace, index) {
        frame.iterations.push(index as u64);
        frame.locals.insert(var.clone(), item);
        for stmt in body.clone() {
            statement(stmt, trace, frame)?;
        }
        frame.iterations.pop();
        index += 1;
    }
    Ok(())
}

/// What a `for` iterates over: `nl.affine_range(count)`'s or `range(count)`'s indices, or a
/// tuple's or list's items.
enum Iterable {
    Range(u64),
    Tuple(Vec<Value>),
    List(usize),
}

impl Iterable {
    fn get(&self, trace: &Trace, index: usize) -> Option<Value> {
        match self {
            Self::Range(count) => {
                let index = u64::try_from(index).ok()?;
                (index < *count).then_some(Value::Int(index))
            }
            Self::Tuple(items) => items.get(index).cloned(),
            Self::List(list) => trace.lists[*list].get(index).cloned(),
        }
    }
}

fn iterable_items(
    iterable: Expr,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Iterable, ParseError> {
    if let Expr::Call(call) = &iterable {
        let callee = frame.resolve(trace, &call.callee, line)?;
        if callee.member_of(NKI_LANGUAGE) == Some("affine_range")
            || callee == Value::Builtin(Builtin::Range)
        {
            return trip_count(call.clone(), trace, frame, line).map(Iterable::Range);
        }
    }
    match trace.evaluate(frame, iterable, line)? {
        Value::Tuple(items) => Ok(Iterable::Tuple(items)),
        Value::List(list) => Ok(Iterable::List(list)),
        other => bail!(
            line,
            "a loop must iterate over `nl.affine_range(count)`, `range(count)`, a tuple or a list, \
             not `{other}`"
        ),
    }
}

/// The trip count of `nl.affine_range(count)` or `range(count)`: only a concrete count
/// unrolls.
fn trip_count(
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<u64, ParseError> {
    if !call.kwargs.is_empty() {
        bail!(line, "`{}` takes no keyword arguments", call.callee);
    }
    let [count] = &call.args[..] else {
        bail!(line, "`{}` takes one argument", call.callee);
    };
    let Value::Int(count) = trace.evaluate(frame, count.clone(), line)? else {
        bail!(line, "`{}`'s count must be an integer", call.callee);
    };
    Ok(count)
}

/// `x = nl.ndarray(...)` declares the tile or HBM tensor `x`, and `x = helper(...)`
/// binds what the helper returns; any other value is bound as is.
fn assignment(
    target: Target,
    value: Expr,
    trace: &mut Trace,
    frame: &mut Frame,
    line: usize,
) -> Result<(), ParseError> {
    let value = match value {
        Expr::Call(call) => match frame.resolve(trace, &call.callee, line)? {
            callee if is_tensor_call(&callee) => {
                let Target::Name(name) = target else {
                    bail!(line, "`{}` declares one tensor", call.callee);
                };
                // As in Python, the arguments are evaluated before the target is bound.
                let tensor = tensor_call(&name, &callee, call, trace, frame, line)?;
                let tensor = tensor.expect("a tensor call");
                frame.locals.insert(name, Value::Tensor(tensor));
                return Ok(());
            }
            Value::Function { module, name } => {
                let Some(value) = inline(&module, &name, call, trace, frame, line)? else {
                    bail!(line, "`{name}` returns nothing to assign");
                };
                value
            }
            Value::Builtin(_) => trace.evaluate(frame, Expr::Call(call), line)?,
            _ => bail!(
                line,
                "only `nl.ndarray`, `nl.zeros`, the `nki.language` functions returning a tile \
                 and helper functions can be assigned from a call, not `{}`",
                call.callee
            ),
        },
        value => trace.evaluate(frame, value, line)?,
    };

    match target {
        Target::Name(name) => {
            frame.locals.insert(name, value);
            Ok(())
        }
        Target::Unpack(names) => {
            let items = match value {
                Value::Tuple(items) => items,
                Value::List(list) => trace.lists[list].clone(),
                other => bail!(
                    line,
                    "only a tuple or a list can be unpacked, not `{other}`"
                ),
            };
            if items.len() != names.len() {
                bail!(
                    line,
                    "cannot unpack {} values into {} names",
                    items.len(),
                    names.len()
                );
            }
            frame.locals.extend(names.into_iter().zip(items));
            Ok(())
        }
        Target::Item { name, index } => {
            let list = match frame.resolve(
                trace,
                &Dotted {
                    head: name.clone(),
                    attributes: Vec::new(),
                },
                line,
            )? {
                Value::List(list) => list,
                Value::Tuple(_) => bail!(line, "`{name}` is a tuple, which cannot be changed"),
                other => bail!(line, "only a list's item can be assigned, not `{other}`'s"),
            };
            let Value::Int(index) = trace.evaluate(frame, index, line)? else {
                bail!(line, "an index must be an integer");
            };
            let slot = usize::try_from(index)
                .ok()
                .and_then(|index| trace.lists[list].get_mut(index));
            let Some(slot) = slot else {
                bail!(line, "index {index} is out of range");
            };
            *slot = value;
            Ok(())
        }
    }
}

/// An expression statement: `nisa.<opcode>(...)`, an instruction, or a helper call.
fn effect(value: Expr, trace: &mut Trace, frame: &Frame, line: usize) -> Result<(), ParseError> {
    let Expr::Call(call) = value else {
        bail!(
            line,
            "a statement must be a call, an assignment, an `assert` or a `for`"
        );
    };

    if call.callee.attributes == ["append"] {
        let list = Dotted {
            head: call.callee.head.clone(),
            attributes: Vec::new(),
        };
        if let Value::List(list) = frame.resolve(trace, &list, line)? {
            return append(list, call, trace, frame, line);
        }
    }

    match frame.resolve(trace, &call.callee, line)? {
        Value::Function { module, name } => {
            inline(&module, &name, call, trace, frame, line)?;
            Ok(())
        }
        callee if callee.member_of(NKI_LANGUAGE) == Some("store") => {
            store(&call, trace, frame, line)
        }
        callee if is_tensor_call(&callee) => {
            bail!(
                line,
                "the tile of `{}` must be bound to a name",
                call.callee
            )
        }
        callee => {
            let Some(opcode) = callee.member_of(NKI_ISA) else {
                bail!(line, "unsupported call `{}`", call.callee);
            };
            let instruction = instruction(opcode.to_owned(), call, trace, frame, line)?;
            trace.body.push(Statement::Instruction(instruction));
            Ok(())
        }
    }
}

/// `items.append(value)`; a tensor `value` declares a tile named after its list item,
/// `qk_tiles[0]`.
fn append(
    list: usize,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<(), ParseError> {
    let name = &call.callee.head;
    if !call.kwargs.is_empty() || call.args.len() != 1 {
        bail!(line, "`{name}.append` takes one argument");
    }
    let arg = call.args.into_iter().next().expect("one argument");

    let value = match arg {
        Expr::Call(inner) => {
            let callee = frame.resolve(trace, &inner.callee, line)?;
            let item = format!("{name}[{}]", trace.lists[list].len());
            match tensor_call(&item, &callee, inner.clone(), trace, frame, line)? {
                Some(tensor) => Value::Tensor(tensor),
                None => trace.evaluate(frame, Expr::Call(inner), line)?,
            }
        }
        arg => trace.evaluate(frame, arg, line)?,
    };
    trace.lists[list].push(value);
    Ok(())
}

/// `assert a op b ...`, checked against the call's shapes: it leaves no statement.
fn assertion(test: Expr, trace: &mut Trace, frame: &Frame, line: usize) -> Result<(), ParseError> {
    let Expr::Compare { first, rest } = test else {
        bail!(line, "an `assert` must be a comparison");
    };
    if let Some((lhs, op, rhs)) = trace.failed_comparison(frame, *first, rest, line)? {
        bail!(
            line,
            "assertion fails for this call: `{lhs} {} {rhs}` is false",
            op.text()
        );
    }
    Ok(())
}

/// The calls that declare a new tensor: `nl.ndarray`, `nl.zeros` and the
/// `nki.language` functions returning a tile. `target` names the tensor; the caller
/// binds it, to a variable or a list's item. `None` if `callee` is none of them.
fn tensor_call(
    target: &str,
    callee: &Value,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Option<TensorName>, ParseError> {
    let tensor = match callee.member_of(NKI_LANGUAGE) {
        Some("ndarray") => declaration(target, &call, trace, frame, line)?,
        Some("zeros") => zeros(target, &call, trace, frame, line)?,
        _ => match TileFunction::of(callee) {
            Some(function) => tile_call(target, function, call, trace, frame, line)?,
            None => return Ok(None),
        },
    };
    Ok(Some(tensor))
}

fn is_tensor_call(callee: &Value) -> bool {
    matches!(callee.member_of(NKI_LANGUAGE), Some("ndarray" | "zeros"))
        || TileFunction::of(callee).is_some()
}

/// `target = nl.ndarray(shape, dtype, buffer=...)`: an HBM tensor of any rank in
/// `nl.shared_hbm`, else an on-chip tile.
fn declaration(
    target: &str,
    call: &Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<TensorName, ParseError> {
    let [shape, dtype, buffer] = ndarray_arguments(call, trace, frame, line)?;
    let dtype = read_dtype(dtype, line)?;

    if buffer.member_of(NKI_LANGUAGE) == Some(SHARED_HBM) {
        let shape = read_extents(shape, line)?;
        let extents = shape.iter().map(|extent| extent.get()).collect();
        let name = trace.declare(frame, target, extents, Place::Hbm);
        trace.body.push(Statement::DeclareHbm(HbmDecl {
            name: name.clone(),
            shape,
            dtype,
        }));
        return Ok(name);
    }

    let shape = read_shape(shape, line)?;
    let buffer = read_buffer(buffer, line)?;
    Ok(declare_tile(target, shape, dtype, buffer, trace, frame))
}

/// `target = nl.zeros(shape, dtype, buffer=...)`: an on-chip tile, every element set
/// to zero by a `memset`.
fn zeros(
    target: &str,
    call: &Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<TensorName, ParseError> {
    let [shape, dtype, buffer] = ndarray_arguments(call, trace, frame, line)?;
    if buffer.member_of(NKI_LANGUAGE) == Some(SHARED_HBM) {
        bail!(
            line,
            "`{}` allocates an on-chip tile only: `nl.sbuf` or `nl.psum`",
            call.callee
        );
    }
    let tile = declare_tile(
        target,
        read_shape(shape, line)?,
        read_dtype(dtype, line)?,
        read_buffer(buffer, line)?,
        trace,
        frame,
    );
    let zero = Scalar::new(0.0).expect("zero is finite");
    let operands = [
        ("dst", Operand::Tensor(tile.clone())),
        ("value", Operand::Scalar(zero)),
    ];
    trace.body.push(Statement::Instruction(Instruction {
        opcode: "memset".into(),
        operands: operands
            .map(|(keyword, operand)| (keyword.to_string(), operand))
            .into(),
    }));
    Ok(tile)
}

/// Declare the on-chip tile `target` and emit its declaration.
fn declare_tile(
    target: &str,
    shape: TileShape,
    dtype: Dtype,
    buffer: Buffer,
    trace: &mut Trace,
    frame: &Frame,
) -> TensorName {
    let name = trace.declare(frame, target, shape.extents(), Place::OnChip);
    trace.body.push(Statement::Declare(TileDecl {
        name: name.clone(),
        shape,
        dtype,
        buffer,
    }));
    name
}

/// `nl.ndarray`'s shape, dtype and buffer, each given by position or by keyword.
fn ndarray_arguments(
    call: &Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<[Value; 3], ParseError> {
    let [shape, dtype, buffer] =
        arguments(call, ["shape", "dtype", "buffer"], 3, trace, frame, line)?;
    Ok([
        shape.expect("required"),
        dtype.expect("required"),
        buffer.expect("required"),
    ])
}

/// The values of `call`'s arguments for `params`, each by position or by keyword; the
/// first `required` must be given.
fn arguments<const N: usize>(
    call: &Call,
    params: [&str; N],
    required: usize,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<[Option<Value>; N], ParseError> {
    let callee = &call.callee;
    if call.args.len() > N {
        bail!(line, "`{callee}` takes at most {N} arguments");
    }
    let mut given: [Option<Expr>; N] = std::array::from_fn(|_| None);
    for (slot, expr) in given.iter_mut().zip(&call.args) {
        *slot = Some(expr.clone());
    }

    for (keyword, expr) in &call.kwargs {
        let Some(index) = params.iter().position(|param| param == keyword) else {
            bail!(line, "`{callee}` has no argument `{keyword}`");
        };
        if given[index].replace(expr.clone()).is_some() {
            bail!(line, "argument `{keyword}` of `{callee}` given twice");
        }
    }

    let mut values: [Option<Value>; N] = std::array::from_fn(|_| None);
    for (index, (expr, value)) in given.into_iter().zip(&mut values).enumerate() {
        match expr {
            Some(expr) => *value = Some(trace.evaluate(frame, expr, line)?),
            None if index < required => {
                bail!(line, "`{callee}` needs argument `{}`", params[index])
            }
            None => {}
        }
    }
    Ok(values)
}

// =============================================================================
// nki.language functions that return a tile
// =============================================================================

/// The `nki.language` functions that return a new tile. Each is one instruction
/// writing a tile it declares, as NKI lowers it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum TileFunction {
    Load,
    Matmul,
    Max,
    Sum,
    Exp,
    Reciprocal,
    Transpose,
}

impl TileFunction {
    const ALL: [Self; 7] = [
        Self::Load,
        Self::Matmul,
        Self::Max,
        Self::Sum,
        Self::Exp,
        Self::Reciprocal,
        Self::Transpose,
    ];

    /// Its `nki.language` member: `nl.load` is `load`.
    fn name(self) -> &'static str {
        match self {
            Self::Load => "load",
            Self::Matmul => "matmul",
            Self::Max => "max",
            Self::Sum => "sum",
            Self::Exp => "exp",
            Self::Reciprocal => "reciprocal",
            Self::Transpose => "transpose",
        }
    }

    fn of(callee: &Value) -> Option<Self> {
        let name = callee.member_of(NKI_LANGUAGE)?;
        Self::ALL
            .into_iter()
            .find(|function| function.name() == name)
    }
}

/// `target = nl.<function>(...)`: the tile `target`, declared in the memory the
/// instruction writes (PSUM for `matmul` and `transpose`, else SBUF), and that instruction.
fn tile_call(
    target: &str,
    function: TileFunction,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<TensorName, ParseError> {
    let callee = call.callee.to_string();
    let member = |name: &str| Operand::Member(format!("{NKI_LANGUAGE}.{name}"));
    let tile_extents = |trace: &Trace, tensor: &TensorName| -> Result<[u64; 2], ParseError> {
        match trace.tensors[tensor].extents[..] {
            [partitions, free] => Ok([partitions, free]),
            _ => bail!(
                line,
                "`{callee}` takes a two-dimensional tile, not `{tensor}`"
            ),
        }
    };

    let (extents, buffer, dtype, opcode, mut operands) = match function {
        TileFunction::Load => {
            let [src] = arguments(&call, ["src"], 1, trace, frame, line)?;
            let src = src.expect("required");
            let (tensor, extents) = region_extents(trace, &src, &callee, line)?;
            in_hbm(trace, &tensor, "src", &callee, line)?;
            let operands = vec![("src", read_operand("src", src, line)?)];
            (
                extents,
                Buffer::Sbuf,
                Dtype::Of(tensor),
                "dma_copy",
                operands,
            )
        }
        TileFunction::Matmul => {
            let [x, y, transpose_x] =
                arguments(&call, ["x", "y", "transpose_x"], 2, trace, frame, line)?;
            if transpose_x != Some(Value::Bool(true)) {
                bail!(
                    line,
                    "`{callee}` is supported with `transpose_x=True` only, which computes \
                     `x.T @ y` as `nc_matmul` does"
                );
            }
            let [x, y] = [tile(x, "x", &callee, line)?, tile(y, "y", &callee, line)?];
            let [[_, rows], [_, columns]] = [tile_extents(trace, &x)?, tile_extents(trace, &y)?];
            let operands = vec![
                ("stationary", Operand::Tensor(x)),
                ("moving", Operand::Tensor(y)),
            ];
            let dtype = Dtype::Named("float32".into());
            (
                vec![rows, columns],
                Buffer::Psum,
                dtype,
                "nc_matmul",
                operands,
            )
        }
        TileFunction::Max | TileFunction::Sum => {
            let [x, axis, keepdims] =
                arguments(&call, ["x", "axis", "keepdims"], 2, trace, frame, line)?;
            if keepdims != Some(Value::Bool(true)) {
                bail!(line, "`{callee}` is supported with `keepdims=True` only");
            }
            let x = tile(x, "x", &callee, line)?;
            let [partitions, _] = tile_extents(trace, &x)?;
            let op = match function {
                TileFunction::Max => "maximum",
                _ => "add",
            };
            let axis = read_operand("axis", axis.expect("required"), line)?;
            let operands = vec![
                ("data", Operand::Tensor(x.clone())),
                ("op", member(op)),
                ("axis", axis),
            ];
            (
                vec![partitions, 1],
                Buffer::Sbuf,
                Dtype::Of(x),
                "tensor_reduce",
                operands,
            )
        }
        TileFunction::Exp | TileFunction::Reciprocal | TileFunction::Transpose => {
            let [x] = arguments(&call, ["x"], 1, trace, frame, line)?;
            let x = tile(x, "x", &callee, line)?;
            let [partitions, free] = tile_extents(trace, &x)?;
            let data = ("data", Operand::Tensor(x.clone()));
            match function {
                TileFunction::Exp => {
                    let operands = vec![data, ("op", member("exp"))];
                    (
                        vec![partitions, free],
                        Buffer::Sbuf,
                        Dtype::Of(x),
                        "activation",
                        operands,
                    )
                }
                TileFunction::Reciprocal => {
                    let operands = vec![data];
                    (
                        vec![partitions, free],
                        Buffer::Sbuf,
                        Dtype::Of(x),
                        "reciprocal",
                        operands,
                    )
                }
                _ => {
                    let operands = vec![data];
                    (
                        vec![free, partitions],
                        Buffer::Psum,
                        Dtype::Of(x),
                        "nc_transpose",
                        operands,
                    )
                }
            }
        }
    };

    let shape = Value::Tuple(extents.iter().map(|&extent| Value::Int(extent)).collect());
    let shape = read_shape(shape, line)?;
    let name = declare_tile(target, shape, dtype, buffer, trace, frame);
    operands.push(("dst", Operand::Tensor(name.clone())));
    let operands = operands
        .into_iter()
        .map(|(keyword, operand)| (keyword.to_string(), operand))
        .collect();
    trace.body.push(Statement::Instruction(Instruction {
        opcode: opcode.into(),
        operands,
    }));
    Ok(name)
}

/// `nl.store(dst, value)`: `value` copied into `dst`, an HBM tensor or a region of one.
fn store(call: &Call, trace: &mut Trace, frame: &Frame, line: usize) -> Result<(), ParseError> {
    let [dst, value] = arguments(call, ["dst", "value"], 2, trace, frame, line)?;
    let callee = call.callee.to_string();
    if let Some(dst) = &dst {
        let (tensor, _) = region_extents(trace, dst, &callee, line)?;
        in_hbm(trace, &tensor, "dst", &callee, line)?;
    }
    let operands = [("dst", dst), ("src", value)]
        .into_iter()
        .map(|(keyword, value)| {
            let operand = read_operand(keyword, value.expect("required"), line)?;
            Ok((keyword.to_string(), operand))
        })
        .collect::<Result<_, ParseError>>()?;
    trace.body.push(Statement::Instruction(Instruction {
        opcode: "dma_copy".into(),
        operands,
    }));
    Ok(())
}

/// `nl.load` reads and `nl.store` writes device memory only.
fn in_hbm(
    trace: &Trace,
    tensor: &TensorName,
    keyword: &str,
    callee: &str,
    line: usize,
) -> Result<(), ParseError> {
    if trace.tensors[tensor].place != Place::Hbm {
        bail!(
            line,
            "`{keyword}` of `{callee}` must be in HBM, not the tile `{tensor}`"
        );
    }
    Ok(())
}

/// Argument `keyword` of `callee`, which must be a tile.
fn tile(
    value: Option<Value>,
    keyword: &str,
    callee: &str,
    line: usize,
) -> Result<TensorName, ParseError> {
    match value {
        Some(Value::Tensor(tensor)) => Ok(tensor),
        Some(other) => bail!(
            line,
            "`{keyword}` of `{callee}` must be a tile, not `{other}`"
        ),
        None => bail!(line, "`{callee}` needs argument `{keyword}`"),
    }
}

/// The tensor a tensor or region `value` reads, and the region's shape: its
/// extents, less the dimensions an integer index drops.
fn region_extents(
    trace: &Trace,
    value: &Value,
    callee: &str,
    line: usize,
) -> Result<(TensorName, Vec<u64>), ParseError> {
    let (tensor, dims) = match value {
        Value::Tensor(tensor) => (tensor, &[][..]),
        Value::Region { tensor, dims } => (tensor, &dims[..]),
        other => bail!(line, "`{callee}` reads a tensor or a region, not `{other}`"),
    };
    let shape = &trace.tensors[tensor].extents;
    match resolve_region(dims, shape) {
        Ok(selected) => Ok((tensor.clone(), kept_extents(&selected))),
        Err(RegionProblem::TooManyIndices) => bail!(
            line,
            "`{tensor}` has {} dimensions, fewer than its subscript's {}",
            shape.len(),
            dims.len()
        ),
        Err(RegionProblem::OutOfBounds { dimension }) => bail!(
            line,
            "`{tensor}`'s index in dimension {dimension} is empty or outside its extent {}",
            shape[dimension]
        ),
    }
}

/// `nisa.<opcode>(keyword=operand, ...)`: every operand by keyword, so its role is explicit.
fn instruction(
    opcode: String,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Instruction, ParseError> {
    if !call.args.is_empty() {
        bail!(line, "`{}` takes its operands by keyword", call.callee);
    }

    let mut operands = BTreeMap::new();
    for (keyword, expr) in call.kwargs {
        let value = trace.evaluate(frame, expr, line)?;
        let operand = read_operand(&keyword, value, line)?;
        operands.insert(keyword, operand);
    }

    Ok(Instruction { opcode, operands })
}

// =============================================================================
// Reading values as kernel parts
// =============================================================================

/// A tile's `(partitions, free, ...)` extents, e.g. `(128, 512)` or `(128, 4, 128)`.
fn read_shape(value: Value, line: usize) -> Result<TileShape, ParseError> {
    let Value::Tuple(extents) = value else {
        bail!(line, "a tile's shape must be a tuple");
    };
    let mut ints = Vec::new();
    for extent in &extents {
        let Value::Int(extent) = *extent else {
            bail!(line, "a tile's extents must be integers");
        };
        ints.push(extent);
    }
    let [partitions, ref free @ ..] = ints[..] else {
        bail!(line, "a tile's shape must be `(partitions, free, ...)`");
    };
    if free.is_empty() {
        bail!(
            line,
            "a tile's shape needs a free dimension: `(partitions, free, ...)`"
        );
    }

    let Some(partitions) = Partitions::new(partitions) else {
        bail!(
            line,
            "a tile spans 1 to {} partitions, not {partitions}",
            Partitions::MAX
        );
    };
    let Some(free) = free.iter().map(|&extent| NonZeroU64::new(extent)).collect() else {
        bail!(line, "a tile's free extents must be positive");
    };

    Ok(TileShape { partitions, free })
}

/// An HBM tensor's extents, e.g. `(128, 512)`: one or more positive integers.
fn read_extents(value: Value, line: usize) -> Result<Vec<NonZeroU64>, ParseError> {
    let Value::Tuple(extents) = value else {
        bail!(line, "a tensor's shape must be a tuple");
    };
    if extents.is_empty() {
        bail!(line, "a tensor's shape must have at least one extent");
    }

    let mut shape = Vec::new();
    for extent in extents {
        let Value::Int(extent) = extent else {
            bail!(line, "a tensor's extents must be integers");
        };
        let Some(extent) = NonZeroU64::new(extent) else {
            bail!(line, "a tensor's extents must be positive");
        };
        shape.push(extent);
    }
    Ok(shape)
}

/// A tensor's `dtype` or a `nki.language` type, e.g. `a.dtype` or `nl.float32`.
fn read_dtype(value: Value, line: usize) -> Result<Dtype, ParseError> {
    if let Some(dtype) = value.member_of(NKI_LANGUAGE) {
        return Ok(Dtype::Named(dtype.into()));
    }
    let Value::DtypeOf(tensor) = value else {
        bail!(
            line,
            "the dtype must be a tensor's `dtype` or a `{NKI_LANGUAGE}` type"
        );
    };
    Ok(Dtype::Of(tensor))
}

/// An on-chip `nki.language` memory: `nl.sbuf` or `nl.psum`.
fn read_buffer(value: Value, line: usize) -> Result<Buffer, ParseError> {
    let memory = value.member_of(NKI_LANGUAGE);
    let Some(buffer) = Buffer::ALL
        .into_iter()
        .find(|buffer| Some(buffer.name()) == memory)
    else {
        bail!(
            line,
            "a tensor's buffer must be `nl.sbuf`, `nl.psum` or `nl.{SHARED_HBM}`"
        );
    };
    Ok(buffer)
}

/// A tensor, a region of one, a scalar, a module member, an integer or a tuple of
/// them, e.g. `x`, `x[0:4, :]`, `0.125`, `nl.add`, `1` or `(1,)`.
fn read_operand(keyword: &str, value: Value, line: usize) -> Result<Operand, ParseError> {
    match value {
        Value::Tensor(tensor) => Ok(Operand::Tensor(tensor)),
        Value::Member(member) => Ok(Operand::Member(member)),
        Value::Float(value) => Ok(Operand::Scalar(value)),
        Value::Int(value) => Ok(Operand::Int(value)),
        Value::Region { tensor, dims } => Ok(Operand::Region { tensor, dims }),
        Value::Tuple(items) => {
            let mut values = Vec::new();
            for item in items {
                let Value::Int(value) = item else {
                    bail!(line, "operand `{keyword}`'s tuple must hold integers only");
                };
                values.push(value);
            }
            Ok(Operand::Ints(values))
        }
        other => bail!(
            line,
            "operand `{keyword}` must be a tensor, a region, a scalar, a module member, \
             or integers, not `{other}`"
        ),
    }
}
