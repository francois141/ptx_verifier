//! Read an NKI kernel, specialized to one call's parameter shapes, as HBM tensors,
//! on-chip tiles and the instructions over them. The kernel's Python runs here, as
//! NKI's tracer runs it: integers, lists, objects, `assert`s, `if`s, loops and calls.

use std::collections::{BTreeMap, BTreeSet};
use std::fmt;
use std::num::NonZeroU64;

use super::ast::{
    Address, Bounds, Buffer, Dtype, HbmDecl, Instruction, Kernel, Operand, Param, Partitions,
    RegionProblem, Scalar, Statement, Subscript, TensorName, TileDecl, TileShape, kept_extents,
    resolve_region,
};
use super::error::{ParseError, ShapeProblem, bail};
use super::lex::CmpOp;
use super::python::{
    self, BinOp, Call, ClassSource, Dotted, Expr, Function, FunctionSource, Item, LogicalOp, Stmt,
    Target, UnaryOp,
};

const NKI_LANGUAGE: &str = "nki.language";
const NKI_ISA: &str = "nki.isa";
/// The `nki.language` buffer of a device-memory tensor the kernel allocates.
const SHARED_HBM: &str = "shared_hbm";

/// The values a kernel reads from `nl.tile_size`. `Default` is the hardware's limits, as
/// NKI defines them; smaller ones run a tiled kernel's loops on small inputs, the kernel
/// tiled exactly as at full size but with smaller tiles.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TileSizes {
    /// `nl.tile_size.pmax`: a tile's partitions.
    pub pmax: u64,
    /// `nl.tile_size.gemm_stationary_fmax`: a matmul's stationary free size.
    pub gemm_stationary_fmax: u64,
    /// `nl.tile_size.gemm_moving_fmax`: a matmul's moving free size.
    pub gemm_moving_fmax: u64,
    /// `nl.tile_size.sbuf_fmax_bytes`: a tile's largest SBUF free size in bytes, which
    /// bounds where `address=` may place an SBUF tile.
    pub sbuf_fmax_bytes: u64,
}

impl Default for TileSizes {
    fn default() -> Self {
        Self::HARDWARE
    }
}

impl TileSizes {
    /// The hardware's limits, as NKI defines them.
    pub const HARDWARE: Self = Self {
        pmax: Partitions::MAX as u64,
        gemm_stationary_fmax: 128,
        gemm_moving_fmax: 512,
        // A tile's largest SBUF free size in bytes, a whole partition: Trn2's 24 MiB
        // over 128 partitions. The docs state no value; v10 reads it to bound its allocator.
        sbuf_fmax_bytes: 192 * 1024,
    };

    /// The value of `nl.tile_size.<member>`, if NKI defines that member here.
    fn member(self, member: &str) -> Option<u64> {
        match member {
            "pmax" => Some(self.pmax),
            "gemm_stationary_fmax" => Some(self.gemm_stationary_fmax),
            "gemm_moving_fmax" => Some(self.gemm_moving_fmax),
            "sbuf_fmax_bytes" => Some(self.sbuf_fmax_bytes),
            _ => None,
        }
    }
}
/// A PSUM partition's bytes: eight 2 KiB banks, as v10's allocator assumes.
const PSUM_PARTITION_BYTES: u64 = 16 * 1024;

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
    parse_kernel_for_call(source, modules, name, &KernelCall::new(shapes))
}

/// What `@nki.jit` specializes a kernel to: each tensor parameter's shape, the dtypes
/// of any the kernel compares or sizes a dtype of, its other parameters' values, and
/// the `nl.tile_size` it reads.
#[derive(Debug, Clone, Copy)]
pub struct KernelCall<'a> {
    pub shapes: &'a [(&'a str, &'a [u64])],
    /// `nki.language` dtype names, e.g. `("q", "bfloat16")`.
    pub dtypes: &'a [(&'a str, &'a str)],
    /// The parameters that are not tensors, e.g. `("pool_size", Constant::Int(2))`;
    /// one the call gives no value or shape takes its default.
    pub constants: &'a [(&'a str, Constant<'a>)],
    pub tile_sizes: TileSizes,
}

/// A kernel argument that is not a tensor, a Python value the kernel computes with.
#[derive(Debug, Clone, Copy)]
pub enum Constant<'a> {
    Int(i64),
    /// A tuple of integers, e.g. `(3, 4)`.
    Ints(&'a [i64]),
    Bool(bool),
}

impl Constant<'_> {
    fn value(self) -> Value {
        match self {
            Self::Int(value) => Value::Int(value),
            Self::Ints(values) => Value::Tuple(values.iter().copied().map(Value::Int).collect()),
            Self::Bool(value) => Value::Bool(value),
        }
    }
}

impl<'a> KernelCall<'a> {
    /// A call with `shapes`, no dtypes and the hardware's tile sizes.
    pub fn new(shapes: &'a [(&'a str, &'a [u64])]) -> Self {
        Self {
            shapes,
            dtypes: &[],
            constants: &[],
            tile_sizes: TileSizes::default(),
        }
    }
}

/// `parse_kernel_with_modules` for `call`.
pub fn parse_kernel_for_call(
    source: &str,
    modules: &[(&str, &str)],
    name: &str,
    call: &KernelCall,
) -> Result<Kernel, ParseError> {
    let mut program = Program {
        modules: BTreeMap::new(),
        tile_sizes: call.tile_sizes,
    };
    program.modules.insert(MAIN.into(), Module::parse(source)?);
    for (module, source) in modules {
        program
            .modules
            .insert((*module).into(), Module::parse(source)?);
    }
    kernel(&program, name, call)
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
    tile_sizes: TileSizes,
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
    Class(ClassSource),
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
                Item::Class(class) => {
                    bind(class.name.clone(), Global::Class(class.clone()), class.line)?
                }
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
    /// The attributes of each object `Value::Object` refers to, shared like lists.
    objects: Vec<Object>,
    /// Each class instantiated so far, by module and name.
    classes: BTreeMap<ClassName, ClassDef>,
    /// The statements emitted so far, in order.
    body: Vec<Statement>,
    /// How many times each helper function has been called, which names its tiles.
    calls: BTreeMap<String, u64>,
    depth: usize,
}

/// A declared tensor's extents, whether it is in device memory, and its dtype's
/// `nki.language` name, unknown for a parameter whose dtype the call does not give.
struct Declared {
    extents: Vec<u64>,
    place: Place,
    dtype: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Place {
    /// Device memory (HBM): a parameter or an `nl.shared_hbm` tensor.
    Hbm,
    /// An SBUF or PSUM tile.
    OnChip,
}

/// A class, by the module that defines it and its name there.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
struct ClassName {
    module: String,
    name: String,
}

/// A class's attributes, evaluated when it is first instantiated, and its methods.
struct ClassDef {
    attributes: BTreeMap<String, Value>,
    methods: BTreeMap<String, FunctionSource>,
}

/// An instance: its class and the attributes assigned to it.
struct Object {
    class: ClassName,
    attributes: BTreeMap<String, Value>,
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
    /// What the caller binds the call's value to, qualified in the caller: a tensor
    /// that `return nl.ndarray(...)` declares takes this name.
    returned_name: Option<String>,
}

/// Whether a statement ends its function, and the value it returns if so.
enum Flow {
    Next,
    Return(Value),
}

/// A `@nki.jit` function, its parameters the HBM tensors it receives with the
/// call's shapes, and the tensor it returns, if it returns one.
fn kernel(program: &Program, name: &str, call: &KernelCall) -> Result<Kernel, ParseError> {
    let function = program.modules[MAIN].function(name)?.parse()?;
    let line = function.line;
    let mut trace = Trace {
        program,
        tensors: BTreeMap::new(),
        lists: Vec::new(),
        objects: Vec::new(),
        classes: BTreeMap::new(),
        body: Vec::new(),
        calls: BTreeMap::new(),
        depth: 0,
    };
    let mut frame = Frame::new(MAIN, &function, String::new(), None);

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

    let is_param = |given: &str| function.params.iter().any(|param| param.name == given);
    for (index, (given, _)) in call.shapes.iter().enumerate() {
        let problem = if !is_param(given) {
            ShapeProblem::NotAParam
        } else if call.shapes[..index]
            .iter()
            .any(|(earlier, _)| earlier == given)
        {
            ShapeProblem::Repeated
        } else {
            continue;
        };
        return Err(ParseError::ParamShape {
            param: (*given).into(),
            problem,
        });
    }
    for (index, (given, _)) in call.constants.iter().enumerate() {
        if !is_param(given) {
            bail!(
                line,
                "a value is given for `{given}`, which is not a parameter"
            );
        }
        if call.shapes.iter().any(|(shaped, _)| shaped == given) {
            bail!(line, "`{given}` is given both a shape and a value");
        }
        if call.constants[..index]
            .iter()
            .any(|(earlier, _)| earlier == given)
        {
            bail!(line, "the value of `{given}` is given twice");
        }
    }
    for (index, (given, _)) in call.dtypes.iter().enumerate() {
        if !is_param(given) {
            bail!(
                line,
                "a dtype is given for `{given}`, which is not a parameter"
            );
        }
        if call.dtypes[..index]
            .iter()
            .any(|(earlier, _)| earlier == given)
        {
            bail!(line, "the dtype of `{given}` is given twice");
        }
    }

    let mut params = Vec::new();
    for param in &function.params {
        let shaped = call.shapes.iter().any(|(given, _)| *given == param.name);
        let constant = call
            .constants
            .iter()
            .find(|(given, _)| *given == param.name);
        let value = match (constant, &param.default) {
            _ if shaped => None,
            (Some((_, constant)), _) => Some(constant.value()),
            (None, Some(default)) => {
                Some(trace.evaluate(&Frame::module_level(MAIN), default.clone(), line)?)
            }
            (None, None) => None,
        };
        if let Some(value) = value {
            frame.locals.insert(param.name.clone(), value);
            continue;
        }
        let shape = param_shape(&param.name, call.shapes)?;
        let extents = shape.iter().map(|extent| extent.get()).collect();
        let dtype = call
            .dtypes
            .iter()
            .find(|(given, _)| *given == param.name)
            .map(|(_, dtype)| (*dtype).to_string());
        let tensor = trace.declare(frame.qualify(&param.name), extents, Place::Hbm, dtype);
        frame
            .locals
            .insert(param.name.clone(), Value::Tensor(tensor.clone()));
        params.push(Param {
            name: tensor,
            shape,
        });
    }

    let returned = match run(&function.body, &mut trace, &mut frame)? {
        Value::None => None,
        Value::Tensor(tensor) => Some(tensor),
        other => bail!(line, "a kernel can only return a tensor, not `{other}`"),
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

/// Run a function body and return what its `return` gives, `None` if it runs off its end.
fn run(body: &[Stmt], trace: &mut Trace, frame: &mut Frame) -> Result<Value, ParseError> {
    match block(body, trace, frame)? {
        Flow::Return(value) => Ok(value),
        Flow::Next => Ok(Value::None),
    }
}

/// Run `body` until a statement returns.
fn block(body: &[Stmt], trace: &mut Trace, frame: &mut Frame) -> Result<Flow, ParseError> {
    for stmt in body {
        if let Flow::Return(value) = statement(stmt.clone(), trace, frame)? {
            return Ok(Flow::Return(value));
        }
    }
    Ok(Flow::Next)
}

/// `return value`'s value; `value` may be a call, as an assignment's may, and a tensor
/// it declares takes the name the frame's caller binds it to.
fn returned_value(
    value: Expr,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Value, ParseError> {
    let Expr::Call(call) = value else {
        return trace.evaluate(frame, value, line);
    };
    let callee = frame.resolve(trace, &call.callee, line)?;
    if is_tensor_call(&callee) {
        let name = frame
            .returned_name
            .clone()
            .unwrap_or_else(|| frame.qualify("return"));
        let tensor = tensor_call(name, &callee, call, trace, frame, line)?;
        return Ok(Value::Tensor(tensor.expect("a tensor call")));
    }
    let returned_name = frame.returned_name.clone();
    trace.call(callee, call, frame, line, returned_name)
}

/// A Python function: a module's, or a class's method bound to an object.
struct Callable {
    module: String,
    /// Its name in errors and tile names: `softmax_isa`, or `Allocator.allocate` for a method.
    name: String,
    source: FunctionSource,
    receiver: Option<usize>,
}

/// Call `callable` with `call`'s arguments, evaluated in the caller's `frame`: its body
/// runs in a frame of its own, its tiles named after the call.
fn inline(
    callable: Callable,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
    returned_name: Option<String>,
) -> Result<Value, ParseError> {
    let program = trace.program;
    let Callable {
        module,
        name,
        source,
        receiver,
    } = callable;
    let in_call = |error| ParseError::InCall {
        function: name.clone(),
        module: module.clone(),
        error: Box::new(error),
    };

    let function = source.parse().map_err(in_call)?;
    if !function.decorators.is_empty() {
        bail!(line, "`{name}` is decorated, so it cannot be called inline");
    }
    if trace.depth == MAX_CALL_DEPTH {
        bail!(line, "calls nest more than {MAX_CALL_DEPTH} deep");
    }

    let mut args: Vec<Value> = receiver.into_iter().map(Value::Object).collect();
    for arg in call.args {
        args.push(trace.evaluate(frame, arg, line)?);
    }
    let mut kwargs = Vec::new();
    for (keyword, arg) in call.kwargs {
        kwargs.push((keyword, trace.evaluate(frame, arg, line)?));
    }

    let count = trace.calls.entry(name.clone()).or_default();
    let prefix = format!("{name}[{count}].");
    *count += 1;
    let module = program
        .modules
        .get_key_value(&module)
        .expect("a loaded module")
        .0;
    let mut callee = Frame::new(module, &function, prefix, returned_name);
    bind_arguments(&function, args, kwargs, trace, &mut callee, line)?;

    trace.depth += 1;
    let returned = run(&function.body, trace, &mut callee).map_err(in_call);
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
                let module = Frame::module_level(callee.module);
                trace.evaluate(&module, default.clone(), line)?
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
    None,
    Int(i64),
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
    /// `t.ap`, tensor `t`'s access-pattern method.
    AccessPatternOf(TensorName),
    /// `t.ap(pattern, offset=offset)`: a strided view of `t`, each pair `[step, count]`.
    Pattern {
        tensor: TensorName,
        pattern: Vec<[u64; 2]>,
        offset: u64,
    },
    /// A function of a module, called by running its body.
    Function {
        module: String,
        name: String,
    },
    Class(ClassName),
    /// An instance: an index into `Trace::objects`.
    Object(usize),
    /// Method `name` of an object's class, bound to the object.
    Method {
        object: usize,
        name: String,
    },
    Builtin(Builtin),
}

/// The Python built-in functions the subset runs.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Builtin {
    List,
    Tuple,
    Len,
    /// `range([start,] stop)`, only as a `for` loop's iterable.
    Range,
}

impl Builtin {
    const ALL: [Self; 4] = [Self::List, Self::Tuple, Self::Len, Self::Range];

    fn name(self) -> &'static str {
        match self {
            Self::List => "list",
            Self::Tuple => "tuple",
            Self::Len => "len",
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

    /// The integer `n`, which must fit Python's integers as the subset has them.
    fn int(n: u64, line: usize) -> Result<Self, ParseError> {
        match i64::try_from(n) {
            Ok(n) => Ok(Self::Int(n)),
            Err(_) => bail!(line, "the integer {n} is too large"),
        }
    }

    /// Its truth value, as Python's `if` takes it.
    fn truth(&self, line: usize) -> Result<bool, ParseError> {
        match self {
            Self::None => Ok(false),
            Self::Bool(value) => Ok(*value),
            Self::Int(value) => Ok(*value != 0),
            other => bail!(line, "the truth of `{other}` is not supported"),
        }
    }
}

impl fmt::Display for Value {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::None => f.write_str("None"),
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
            Self::AccessPatternOf(tensor) => write!(f, "method `{tensor}.ap`"),
            Self::Pattern {
                tensor,
                pattern,
                offset,
            } => {
                let operand = Operand::Pattern {
                    tensor: tensor.clone(),
                    pattern: pattern.clone(),
                    offset: *offset,
                };
                write!(f, "{operand}")
            }
            Self::Function { name, .. } => write!(f, "function `{name}`"),
            Self::Class(class) => write!(f, "class `{}`", class.name),
            Self::Object(_) => f.write_str("an object"),
            Self::Method { name, .. } => write!(f, "method `{name}`"),
            Self::Builtin(builtin) => write!(f, "built-in `{}`", builtin.name()),
        }
    }
}

impl<'p> Frame<'p> {
    fn new(
        module: &'p str,
        function: &Function,
        prefix: String,
        returned_name: Option<String>,
    ) -> Self {
        let mut assigned = BTreeSet::new();
        assigned_names(&function.body, &mut assigned);
        Self {
            module,
            locals: BTreeMap::new(),
            assigned,
            prefix,
            iterations: Vec::new(),
            returned_name,
        }
    }

    /// A frame of `module`'s globals only, where defaults and class bodies evaluate.
    fn module_level(module: &'p str) -> Self {
        Self {
            module,
            locals: BTreeMap::new(),
            assigned: BTreeSet::new(),
            prefix: String::new(),
            iterations: Vec::new(),
            returned_name: None,
        }
    }

    /// Tensor `name` of this frame, named after its call and iterations: `softmax_isa[0].x.1`.
    fn qualify(&self, name: &str) -> String {
        let mut qualified = format!("{}{name}", self.prefix);
        for index in &self.iterations {
            qualified.push('.');
            qualified.push_str(&index.to_string());
        }
        qualified
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

        name.attributes.iter().try_fold(value, |value, attribute| {
            trace.attribute(value, attribute, line)
        })
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
        Global::Class(_) => Value::Class(ClassName {
            module: module.into(),
            name: name.into(),
        }),
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
                tile_size(program.tile_sizes, format!("{from}.{name}"), line)?
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

/// Every name `body` assigns: assignment targets and loop variables, in nested blocks
/// too. Assigning an attribute assigns no name.
fn assigned_names(body: &[Stmt], names: &mut BTreeSet<String>) {
    for stmt in body {
        match stmt {
            Stmt::Assign { target, .. } => match target {
                Target::Name(name) | Target::Item { name, .. } => {
                    names.insert(name.clone());
                }
                Target::Unpack(targets) => names.extend(targets.iter().cloned()),
                Target::Attribute { .. } => {}
            },
            Stmt::For { var, body, .. } => {
                names.insert(var.clone());
                assigned_names(body, names);
            }
            Stmt::If { body, orelse, .. } => {
                assigned_names(body, names);
                assigned_names(orelse, names);
            }
            Stmt::With { body, .. } => assigned_names(body, names),
            Stmt::Expr { .. } | Stmt::Assert { .. } | Stmt::Return { .. } => {}
        }
    }
}

impl Trace<'_> {
    /// Declare tensor `qualified`, a frame's qualified name; a name declared again, as
    /// `x = nl.exp(x)` does, takes a version suffix Python cannot write, `x~1`, so every
    /// tensor has a name of its own.
    fn declare(
        &mut self,
        qualified: String,
        extents: Vec<u64>,
        place: Place,
        dtype: Option<String>,
    ) -> TensorName {
        let mut tensor = TensorName(qualified.clone());
        let mut version = 0;
        while self.tensors.contains_key(&tensor) {
            version += 1;
            tensor = TensorName(format!("{qualified}~{version}"));
        }
        self.tensors.insert(
            tensor.clone(),
            Declared {
                extents,
                place,
                dtype,
            },
        );
        tensor
    }

    /// The `nki.language` name of `dtype`, if it is known.
    fn dtype_name(&self, dtype: &Dtype) -> Option<String> {
        match dtype {
            Dtype::Named(name) => Some(name.clone()),
            Dtype::Of(tensor) => self.tensors[tensor].dtype.clone(),
        }
    }

    /// `value.attribute`: a module's member, a tensor's `dtype` or `shape`, or an object's
    /// attribute, else its class's, else its class's method.
    fn attribute(&self, value: Value, attribute: &str, line: usize) -> Result<Value, ParseError> {
        match value {
            Value::Member(member) => tile_size(
                self.program.tile_sizes,
                format!("{member}.{attribute}"),
                line,
            ),
            Value::Tensor(tensor) if attribute == "dtype" => Ok(Value::DtypeOf(tensor)),
            Value::Tensor(tensor) if attribute == "ap" => Ok(Value::AccessPatternOf(tensor)),
            Value::Tensor(tensor) if attribute == "shape" => {
                let extents = &self.tensors[&tensor].extents;
                let extents = extents.iter().map(|&e| Value::int(e, line));
                Ok(Value::Tuple(extents.collect::<Result<_, _>>()?))
            }
            Value::Tensor(tensor) => {
                bail!(line, "unsupported tensor attribute `{tensor}.{attribute}`")
            }
            Value::Object(object) => {
                let Object { class, attributes } = &self.objects[object];
                let def = &self.classes[class];
                if let Some(value) = attributes.get(attribute) {
                    Ok(value.clone())
                } else if let Some(value) = def.attributes.get(attribute) {
                    Ok(value.clone())
                } else if def.methods.contains_key(attribute) {
                    Ok(Value::Method {
                        object,
                        name: attribute.into(),
                    })
                } else {
                    bail!(
                        line,
                        "`{}` object has no attribute `{attribute}`",
                        class.name
                    )
                }
            }
            other => bail!(line, "unsupported attribute `{attribute}` of `{other}`"),
        }
    }

    fn evaluate(&mut self, frame: &Frame, expr: Expr, line: usize) -> Result<Value, ParseError> {
        match expr {
            Expr::None => Ok(Value::None),
            Expr::Int(value) => Value::int(value, line),
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
                if op == BinOp::Div {
                    return true_division(&lhs, &rhs, line);
                }
                let (Value::Int(lhs), Value::Int(rhs)) = (lhs, rhs) else {
                    bail!(line, "`{}` needs integer operands", op.text());
                };
                Ok(Value::Int(arithmetic(op, lhs, rhs, line)?))
            }
            Expr::Unary { op, operand } => {
                let operand = self.evaluate(frame, *operand, line)?;
                match (op, operand) {
                    (UnaryOp::Not, operand) => Ok(Value::Bool(!operand.truth(line)?)),
                    (UnaryOp::Neg, Value::Int(value)) => match value.checked_neg() {
                        Some(value) => Ok(Value::Int(value)),
                        None => bail!(line, "integer arithmetic overflows"),
                    },
                    (UnaryOp::Neg, Value::Float(value)) => Ok(Value::Float(
                        Scalar::new(-value.get()).expect("a negated finite float is finite"),
                    )),
                    (UnaryOp::Invert, Value::Int(value)) => Ok(Value::Int(!value)),
                    (_, operand) => bail!(line, "unsupported operand `{operand}`"),
                }
            }
            Expr::Logical { op, lhs, rhs } => {
                let lhs = self.evaluate(frame, *lhs, line)?;
                let decided = match op {
                    LogicalOp::And => !lhs.truth(line)?,
                    LogicalOp::Or => lhs.truth(line)?,
                };
                if decided {
                    return Ok(lhs);
                }
                self.evaluate(frame, *rhs, line)
            }
            Expr::Subscript { base, indices } => {
                let base = self.evaluate(frame, *base, line)?;
                self.subscript(frame, base, indices, line)
            }
            Expr::Slice { .. } => bail!(line, "a slice is only valid inside `[]`"),
            Expr::Call(call) => {
                let callee = frame.resolve(self, &call.callee, line)?;
                self.call(callee, call, frame, line, None)
            }
            Expr::Compare { first, rest } => Ok(Value::Bool(
                self.failed_comparison(frame, *first, rest, line)?.is_none(),
            )),
        }
    }

    /// Call `callee`: a module's function or an object's method, run inline, a class,
    /// instantiated, or a built-in; what the caller binds the result to is `returned_name`.
    fn call(
        &mut self,
        callee: Value,
        call: Call,
        frame: &Frame,
        line: usize,
        returned_name: Option<String>,
    ) -> Result<Value, ParseError> {
        let callable = match callee {
            Value::Function { module, name } => Callable {
                source: self.program.modules[&module].function(&name)?.clone(),
                module,
                name,
                receiver: None,
            },
            Value::Method { object, name } => {
                let class = self.objects[object].class.clone();
                Callable {
                    source: self.classes[&class].methods[&name].clone(),
                    name: format!("{}.{name}", class.name),
                    module: class.module,
                    receiver: Some(object),
                }
            }
            Value::Class(class) => return self.instantiate(class, call, frame, line),
            Value::Builtin(builtin) => return self.builtin(frame, builtin, call, line),
            Value::AccessPatternOf(tensor) => {
                return self.access_pattern(tensor, &call, frame, line);
            }
            _ => bail!(
                line,
                "`{}` can only be called as a statement or an assignment's value",
                call.callee
            ),
        };
        inline(callable, call, self, frame, line, returned_name)
    }

    /// `tensor.ap(pattern, offset=0)`: `pattern` a list or tuple of `[step, count]` pairs
    /// of integers, `offset` an element offset. The `ap` parameters for dynamic or
    /// reinterpreted views (`scalar_offset`, `dtype`, ...) are unsupported.
    fn access_pattern(
        &mut self,
        tensor: TensorName,
        call: &Call,
        frame: &Frame,
        line: usize,
    ) -> Result<Value, ParseError> {
        let callee = format!("{tensor}.ap");
        let [pattern, offset] = arguments(call, ["pattern", "offset"], 1, self, frame, line)?;
        let integer = |value: &Value, what| match value {
            Value::Int(value) => non_negative(*value, what, line),
            other => bail!(line, "`{callee}` needs an integer {what}, not `{other}`"),
        };
        let offset = match &offset {
            None | Some(Value::None) => 0,
            Some(offset) => integer(offset, "offset")?,
        };
        let pairs = self.items(&pattern.expect("required"), &callee, line)?;
        let mut steps = Vec::new();
        for pair in pairs {
            let Ok([step, count]) = <[Value; 2]>::try_from(self.items(&pair, &callee, line)?)
            else {
                bail!(line, "`{callee}` takes `[step, count]` pairs");
            };
            steps.push([integer(&step, "step")?, integer(&count, "count")?]);
        }
        Ok(Value::Pattern {
            tensor,
            pattern: steps,
            offset,
        })
    }

    /// The items of a tuple or list `value`, an argument of `callee`.
    fn items(&self, value: &Value, callee: &str, line: usize) -> Result<Vec<Value>, ParseError> {
        match value {
            Value::Tuple(items) => Ok(items.clone()),
            Value::List(list) => Ok(self.lists[*list].clone()),
            other => bail!(line, "`{callee}` needs a tuple or a list, not `{other}`"),
        }
    }

    /// `Class(args)`: a new object, initialized by the class's `__init__` if it has one.
    /// A class must derive from `nl.NKIObject` alone, or from nothing.
    fn instantiate(
        &mut self,
        class: ClassName,
        call: Call,
        frame: &Frame,
        line: usize,
    ) -> Result<Value, ParseError> {
        if !self.classes.contains_key(&class) {
            let def = self.class_def(&class, line)?;
            self.classes.insert(class.clone(), def);
        }
        self.objects.push(Object {
            class: class.clone(),
            attributes: BTreeMap::new(),
        });
        let object = self.objects.len() - 1;

        if self.classes[&class].methods.contains_key("__init__") {
            let init = Value::Method {
                object,
                name: "__init__".into(),
            };
            self.call(init, call, frame, line, None)?;
        } else if !call.args.is_empty() || !call.kwargs.is_empty() {
            bail!(line, "`{}` takes no arguments", class.name);
        }
        Ok(Value::Object(object))
    }

    /// Class `class`'s body: its attributes, evaluated in its module, and its methods.
    fn class_def(&mut self, class: &ClassName, line: usize) -> Result<ClassDef, ParseError> {
        let program = self.program;
        let (module, Global::Class(source)) = program
            .modules
            .get_key_value(&class.module)
            .map(|(module, globals)| (module, &globals.globals[&class.name]))
            .expect("a class of a loaded module")
        else {
            unreachable!("`Value::Class` names a class");
        };
        let parsed = source.parse()?;
        let scope = Frame::module_level(module);

        for base in &parsed.bases {
            if scope.resolve(self, base, line)?.member_of(NKI_LANGUAGE) != Some("NKIObject") {
                bail!(
                    line,
                    "class `{}` may only derive from `nl.NKIObject`, not `{base}`",
                    class.name
                );
            }
        }
        let mut attributes = BTreeMap::new();
        for (line, name, value) in parsed.attributes {
            let value = self.evaluate(&scope, value, line)?;
            attributes.insert(name, value);
        }
        let mut methods = BTreeMap::new();
        for method in parsed.methods {
            if methods
                .insert(method.name.clone(), method.clone())
                .is_some()
            {
                bail!(method.line, "method `{}` is defined twice", method.name);
            }
        }
        Ok(ClassDef {
            attributes,
            methods,
        })
    }

    /// `base[indices]`: a tensor's region, an integer or a slice per leading
    /// dimension, or a tuple's or list's item or slice.
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
        let items = match &base {
            Value::Tuple(items) => items.clone(),
            Value::List(list) => self.lists[*list].clone(),
            _ => bail!(line, "`{base}` cannot be indexed"),
        };

        if let Expr::Slice { start, stop } = index {
            let start = self.bound(frame, start.clone(), line)?.unwrap_or(0);
            let stop = self.bound(frame, stop.clone(), line)?;
            let len = items.len() as u64;
            let stop = stop.unwrap_or(len).min(len);
            let start = start.min(stop);
            let items = items[start as usize..stop as usize].to_vec();
            return Ok(match base {
                Value::List(_) => self.new_list(items),
                _ => Value::Tuple(items),
            });
        }

        let Value::Int(index) = self.evaluate(frame, index.clone(), line)? else {
            bail!(line, "an index must be an integer");
        };
        let item = usize::try_from(index)
            .ok()
            .and_then(|index| items.get(index));
        let Some(item) = item else {
            bail!(line, "index {index} is out of range");
        };
        Ok(item.clone())
    }

    /// `list(items)`, `tuple(items)` or `len(items)` of a tuple or list.
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
            Builtin::Len => Value::int(items.len() as u64, line)?,
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
            if !self.holds(op, &lhs, &rhs, line)? {
                return Ok(Some((lhs, op, rhs)));
            }
            lhs = rhs;
        }
        Ok(None)
    }

    /// Whether `lhs op rhs` holds: integers compare by any operator, other values by
    /// `==` and `!=` only.
    fn holds(&self, op: CmpOp, lhs: &Value, rhs: &Value, line: usize) -> Result<bool, ParseError> {
        let ordered = |lhs: &i64, rhs: &i64| match op {
            CmpOp::Eq => lhs == rhs,
            CmpOp::Ne => lhs != rhs,
            CmpOp::Lt => lhs < rhs,
            CmpOp::Le => lhs <= rhs,
            CmpOp::Gt => lhs > rhs,
            CmpOp::Ge => lhs >= rhs,
        };
        match (lhs, rhs, op) {
            (Value::Int(lhs), Value::Int(rhs), _) => Ok(ordered(lhs, rhs)),
            (_, _, CmpOp::Eq) => self.equal(lhs, rhs, line),
            (_, _, CmpOp::Ne) => Ok(!self.equal(lhs, rhs, line)?),
            _ => bail!(
                line,
                "cannot compare `{lhs}` {} `{rhs}`: only integers are ordered",
                op.text()
            ),
        }
    }

    /// Whether `lhs == rhs`, as Python has it for the values compared: integers, bools,
    /// floats, `None`, tuples, objects by identity, and dtypes, a tensor's by its name.
    fn equal(&self, lhs: &Value, rhs: &Value, line: usize) -> Result<bool, ParseError> {
        let [lhs, rhs] = [lhs, rhs].map(|value| self.dtype_member(value, line));
        let (lhs, rhs) = (lhs?, rhs?);
        match (&lhs, &rhs) {
            (Value::None, _) | (_, Value::None) => Ok(lhs == rhs),
            (Value::Int(a), Value::Int(b)) => Ok(a == b),
            (Value::Bool(a), Value::Bool(b)) => Ok(a == b),
            (Value::Float(a), Value::Float(b)) => Ok(a == b),
            (Value::Member(a), Value::Member(b)) => Ok(a == b),
            (Value::Object(a), Value::Object(b)) => Ok(a == b),
            (Value::Tuple(a), Value::Tuple(b)) => {
                if a.len() != b.len() {
                    return Ok(false);
                }
                for (a, b) in a.iter().zip(b) {
                    if !self.equal(a, b, line)? {
                        return Ok(false);
                    }
                }
                Ok(true)
            }
            _ => bail!(line, "cannot compare `{lhs}` with `{rhs}`"),
        }
    }

    /// `value`, a tensor's dtype as its `nki.language` member: `q.dtype` as `nl.bfloat16`.
    fn dtype_member(&self, value: &Value, line: usize) -> Result<Value, ParseError> {
        let Value::DtypeOf(tensor) = value else {
            return Ok(value.clone());
        };
        match &self.tensors[tensor].dtype {
            Some(dtype) => Ok(Value::Member(format!("{NKI_LANGUAGE}.{dtype}"))),
            None => bail!(
                line,
                "the dtype of `{tensor}` is compared, so the call must give it"
            ),
        }
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
        if let Expr::Call(call) = &index {
            let callee = frame.resolve(self, &call.callee, line)?;
            if callee.member_of(NKI_LANGUAGE) == Some("ds") {
                return self.dynamic_slice(frame, call, line);
            }
        }
        match self.evaluate(frame, index, line)? {
            Value::Int(index) => Ok(Subscript::Index(non_negative(index, "an index", line)?)),
            other => bail!(
                line,
                "a tensor index must be an integer or a slice, not `{other}`"
            ),
        }
    }

    /// `nl.ds(start, size)`: the slice `start:start + size`.
    fn dynamic_slice(
        &mut self,
        frame: &Frame,
        call: &Call,
        line: usize,
    ) -> Result<Subscript, ParseError> {
        let [start, size] = call.args.as_slice() else {
            bail!(line, "`nl.ds` takes a start and a size, by position");
        };
        if !call.kwargs.is_empty() {
            bail!(line, "`nl.ds` takes a start and a size, by position");
        }
        let mut int = |expr: &Expr, what| match self.evaluate(frame, expr.clone(), line)? {
            Value::Int(value) => non_negative(value, what, line),
            other => bail!(line, "`nl.ds` needs an integer {what}, not `{other}`"),
        };
        let start = int(start, "start")?;
        let size = int(size, "size")?;
        if size == 0 {
            bail!(line, "`nl.ds` needs a positive size");
        }
        Ok(Subscript::Slice(Bounds {
            start: Some(start),
            stop: Some(start + size),
        }))
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
        Ok(Some(non_negative(value, "a slice bound", line)?))
    }
}

/// `lhs / rhs`, Python's true division of integers or floats: the f64 quotient, which
/// for integers is Python's correctly rounded one while they convert exactly.
fn true_division(lhs: &Value, rhs: &Value, line: usize) -> Result<Value, ParseError> {
    const EXACT: u64 = 1 << f64::MANTISSA_DIGITS;
    let number = |value: &Value| match value {
        Value::Int(value) if value.unsigned_abs() <= EXACT => Ok(*value as f64),
        Value::Int(value) => bail!(line, "`/` of {value}, which no float holds exactly"),
        Value::Float(value) => Ok(value.get()),
        other => bail!(line, "`/` needs numbers, not `{other}`"),
    };
    let (lhs, rhs) = (number(lhs)?, number(rhs)?);
    if rhs == 0.0 {
        bail!(line, "division by zero");
    }
    match Scalar::new(lhs / rhs) {
        Some(quotient) => Ok(Value::Float(quotient)),
        None => bail!(line, "`/` overflows a float"),
    }
}

/// `lhs op rhs` over Python's integers: `//` rounds down and `%` takes the divisor's sign.
fn arithmetic(op: BinOp, lhs: i64, rhs: i64, line: usize) -> Result<i64, ParseError> {
    if matches!(op, BinOp::FloorDiv | BinOp::Mod) && rhs == 0 {
        bail!(line, "integer division by zero");
    }
    let floor_div = || {
        let quotient = lhs.checked_div(rhs)?;
        let inexact = lhs.checked_rem(rhs)? != 0;
        Some(if inexact && (lhs < 0) != (rhs < 0) {
            quotient - 1
        } else {
            quotient
        })
    };
    let value = match op {
        BinOp::Add => lhs.checked_add(rhs),
        BinOp::Sub => lhs.checked_sub(rhs),
        BinOp::Mul => lhs.checked_mul(rhs),
        BinOp::Div => unreachable!("`/` is true division"),
        BinOp::FloorDiv => floor_div(),
        BinOp::Mod => floor_div()
            .and_then(|quotient| quotient.checked_mul(rhs))
            .and_then(|product| lhs.checked_sub(product)),
        BinOp::BitAnd => Some(lhs & rhs),
    };
    let Some(value) = value else {
        bail!(line, "integer arithmetic overflows");
    };
    Ok(value)
}

/// `value`, which must not be negative, as what it is used as: `what`.
fn non_negative(value: i64, what: &str, line: usize) -> Result<u64, ParseError> {
    match u64::try_from(value) {
        Ok(value) => Ok(value),
        Err(_) => bail!(line, "{what} must not be negative, not {value}"),
    }
}

/// An `nl.tile_size` limit as its integer; any other member as itself.
fn tile_size(tile_sizes: TileSizes, member: String, line: usize) -> Result<Value, ParseError> {
    let Some(limit) = member
        .strip_prefix(NKI_LANGUAGE)
        .and_then(|rest| rest.strip_prefix(".tile_size."))
    else {
        return Ok(Value::Member(member));
    };
    let Some(value) = tile_sizes.member(limit) else {
        bail!(line, "unsupported tile size `nl.tile_size.{limit}`");
    };
    Value::int(value, line)
}

// =============================================================================
// Statements
// =============================================================================

fn statement(stmt: Stmt, trace: &mut Trace, frame: &mut Frame) -> Result<Flow, ParseError> {
    match stmt {
        Stmt::Assign {
            line,
            target,
            value,
        } => assignment(target, value, trace, frame, line)?,
        Stmt::Expr { line, value } => effect(value, trace, frame, line)?,
        Stmt::Assert { line, test } => assertion(test, trace, frame, line)?,
        Stmt::For {
            line,
            var,
            iterable,
            body,
        } => return unroll(var, iterable, &body, trace, frame, line),
        Stmt::If {
            line,
            test,
            body,
            orelse,
        } => {
            let taken = if trace.evaluate(frame, test, line)?.truth(line)? {
                body
            } else {
                orelse
            };
            return block(&taken, trace, frame);
        }
        Stmt::With {
            line,
            context,
            body,
        } => {
            no_reorder(context, trace, frame, line)?;
            return block(&body, trace, frame);
        }
        Stmt::Return { line, value } => {
            let value = match value {
                Some(value) => returned_value(value, trace, frame, line)?,
                None => Value::None,
            };
            return Ok(Flow::Return(value));
        }
    }
    Ok(Flow::Next)
}

/// `with nl.no_reorder():`, the only context the subset enters: its body runs in program
/// order, as every instruction does here.
fn no_reorder(context: Expr, trace: &Trace, frame: &Frame, line: usize) -> Result<(), ParseError> {
    let Expr::Call(call) = context else {
        bail!(line, "`with` supports `nl.no_reorder()` only");
    };
    let callee = frame.resolve(trace, &call.callee, line)?;
    if callee.member_of(NKI_LANGUAGE) != Some("no_reorder")
        || !call.args.is_empty()
        || !call.kwargs.is_empty()
    {
        bail!(line, "`with` supports `nl.no_reorder()` only");
    }
    Ok(())
}

/// `for var in iterable:` as its body once per item, binding `var` to it; each
/// iteration's tiles take its index as a suffix (`x.0`), so each declares its own.
fn unroll(
    var: String,
    iterable: Expr,
    body: &[Stmt],
    trace: &mut Trace,
    frame: &mut Frame,
    line: usize,
) -> Result<Flow, ParseError> {
    let items = iterable_items(iterable, trace, frame, line)?;

    let mut index = 0;
    // A list is iterated live, as in Python: the body may change it.
    while let Some(item) = items.get(trace, index) {
        frame.iterations.push(index as u64);
        frame.locals.insert(var.clone(), item);
        let flow = block(body, trace, frame);
        frame.iterations.pop();
        if let Flow::Return(value) = flow? {
            return Ok(Flow::Return(value));
        }
        index += 1;
    }
    Ok(Flow::Next)
}

/// The `nki.language` loop iterators. Each unrolls in order: `affine_range` declares
/// its iterations independent, and `sequential_range` and `static_range` do not, but
/// each runs the same iterations in program order.
const LOOP_RANGES: [&str; 3] = ["affine_range", "sequential_range", "static_range"];

/// What a `for` iterates over: an `nl` loop iterator's or `range([start,] stop)`'s
/// integers, or a tuple's or list's items.
enum Iterable {
    Range { start: i64, stop: i64 },
    Tuple(Vec<Value>),
    List(usize),
}

impl Iterable {
    fn get(&self, trace: &Trace, index: usize) -> Option<Value> {
        match self {
            Self::Range { start, stop } => {
                let value = start.checked_add(i64::try_from(index).ok()?)?;
                (value < *stop).then_some(Value::Int(value))
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
        let loop_range = callee
            .member_of(NKI_LANGUAGE)
            .is_some_and(|member| LOOP_RANGES.contains(&member));
        if loop_range || callee == Value::Builtin(Builtin::Range) {
            return range(call.clone(), &callee, trace, frame, line);
        }
    }
    match trace.evaluate(frame, iterable, line)? {
        Value::Tuple(items) => Ok(Iterable::Tuple(items)),
        Value::List(list) => Ok(Iterable::List(list)),
        other => bail!(
            line,
            "a loop must iterate over `nl.affine_range`, `nl.sequential_range` or \
             `nl.static_range` of a count, `range([start,] stop)`, a tuple or a list, not \
             `{other}`"
        ),
    }
}

/// The integers of an `nl` loop iterator's `(count)` or `range([start,] stop)`: only
/// concrete bounds unroll.
fn range(
    call: Call,
    callee: &Value,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Iterable, ParseError> {
    let name = &call.callee;
    if !call.kwargs.is_empty() {
        bail!(line, "`{name}` takes no keyword arguments");
    }
    let mut bounds = Vec::new();
    for bound in call.args {
        let Value::Int(bound) = trace.evaluate(frame, bound, line)? else {
            bail!(line, "`{name}`'s bounds must be integers");
        };
        bounds.push(bound);
    }
    match bounds[..] {
        [stop] => Ok(Iterable::Range { start: 0, stop }),
        [start, stop] if *callee == Value::Builtin(Builtin::Range) => {
            Ok(Iterable::Range { start, stop })
        }
        _ if *callee == Value::Builtin(Builtin::Range) => {
            bail!(line, "`{name}` takes one or two arguments")
        }
        _ => bail!(line, "`{name}` takes one argument"),
    }
}

/// `x = nl.ndarray(...)` declares the tile or HBM tensor `x`, and `x = f(...)` binds
/// what the call returns; any other value is bound as is.
fn assignment(
    target: Target,
    value: Expr,
    trace: &mut Trace,
    frame: &mut Frame,
    line: usize,
) -> Result<(), ParseError> {
    let bound = match &target {
        Target::Name(name)
        | Target::Attribute {
            attribute: name, ..
        } => Some(frame.qualify(name)),
        Target::Unpack(_) | Target::Item { .. } => None,
    };
    let value = match value {
        Expr::Call(call) => match frame.resolve(trace, &call.callee, line)? {
            callee if is_tensor_call(&callee) => {
                let Some(name) = bound else {
                    bail!(line, "`{}` declares one tensor", call.callee);
                };
                // As in Python, the arguments are evaluated before the target is bound.
                let tensor = tensor_call(name, &callee, call, trace, frame, line)?;
                Value::Tensor(tensor.expect("a tensor call"))
            }
            callee @ (Value::Function { .. }
            | Value::Method { .. }
            | Value::Class(_)
            | Value::Builtin(_)
            | Value::AccessPatternOf(_)) => trace.call(callee, call, frame, line, bound)?,
            _ => bail!(
                line,
                "only `nl.ndarray`, `nl.zeros`, the `nki.language` functions returning a tile, \
                 functions, methods and classes can be assigned from a call, not `{}`",
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
        Target::Attribute { object, attribute } => {
            let Value::Object(object) = frame.resolve(trace, &object, line)? else {
                bail!(
                    line,
                    "only an object's attributes can be assigned, not `{object}`'s"
                );
            };
            trace.objects[object].attributes.insert(attribute, value);
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

/// An expression statement: `nisa.<opcode>(...)`, an instruction, or a call of a
/// function, method or class.
fn effect(value: Expr, trace: &mut Trace, frame: &Frame, line: usize) -> Result<(), ParseError> {
    let Expr::Call(call) = value else {
        bail!(
            line,
            "a statement must be a call, an assignment, an `assert`, an `if`, a `with` or a `for`"
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
        callee @ (Value::Function { .. } | Value::Method { .. } | Value::Class(_)) => {
            trace.call(callee, call, frame, line, None)?;
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
            let item = frame.qualify(&format!("{name}[{}]", trace.lists[list].len()));
            match tensor_call(item, &callee, inner.clone(), trace, frame, line)? {
                Some(tensor) => Value::Tensor(tensor),
                None => trace.evaluate(frame, Expr::Call(inner), line)?,
            }
        }
        arg => trace.evaluate(frame, arg, line)?,
    };
    trace.lists[list].push(value);
    Ok(())
}

/// `assert test`, checked against the call: it leaves no statement.
fn assertion(test: Expr, trace: &mut Trace, frame: &Frame, line: usize) -> Result<(), ParseError> {
    if let Expr::Compare { first, rest } = test {
        if let Some((lhs, op, rhs)) = trace.failed_comparison(frame, *first, rest, line)? {
            bail!(
                line,
                "assertion fails for this call: `{lhs} {} {rhs}` is false",
                op.text()
            );
        }
        return Ok(());
    }
    if !trace.evaluate(frame, test, line)?.truth(line)? {
        bail!(line, "assertion fails for this call");
    }
    Ok(())
}

/// The calls that declare a new tensor: `nl.ndarray`, `nl.zeros` and the
/// `nki.language` functions returning a tile. `target`, qualified in its frame, names the
/// tensor; the caller binds it. `None` if `callee` is none of them.
fn tensor_call(
    target: String,
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
    target: String,
    call: &Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<TensorName, ParseError> {
    let [shape, dtype, buffer, name, address] = arguments(
        call,
        ["shape", "dtype", "buffer", "name", "address"],
        3,
        trace,
        frame,
        line,
    )?;
    let [shape, dtype, buffer] = [shape, dtype, buffer].map(|value| value.expect("required"));
    let dtype = read_dtype(dtype, line)?;
    if name.is_some() {
        bail!(line, "`{}`'s `name` is not supported", call.callee);
    }
    let address = address.filter(|address| !matches!(address, Value::None));

    if buffer.member_of(NKI_LANGUAGE) == Some(SHARED_HBM) {
        if address.is_some() {
            bail!(
                line,
                "`address=` places on-chip tiles only, not an HBM tensor"
            );
        }
        let shape = read_extents(shape, line)?;
        let extents = shape.iter().map(|extent| extent.get()).collect();
        let name = trace.declare(target, extents, Place::Hbm, trace.dtype_name(&dtype));
        trace.body.push(Statement::DeclareHbm(HbmDecl {
            name: name.clone(),
            shape,
            dtype,
        }));
        return Ok(name);
    }

    let shape = read_shape(shape, line)?;
    let buffer = read_buffer(buffer, line)?;
    let address = address
        .map(|address| read_address(address, &shape, &dtype, buffer, trace, line))
        .transpose()?;
    Ok(declare_tile(target, shape, dtype, buffer, address, trace))
}

/// `target = nl.zeros(shape, dtype, buffer=...)`: an on-chip tile, every element set
/// to zero by a `memset`.
fn zeros(
    target: String,
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
        None,
        trace,
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
    target: String,
    shape: TileShape,
    dtype: Dtype,
    buffer: Buffer,
    address: Option<Address>,
    trace: &mut Trace,
) -> TensorName {
    let dtype_name = trace.dtype_name(&dtype);
    let name = trace.declare(target, shape.extents(), Place::OnChip, dtype_name);
    trace.body.push(Statement::Declare(TileDecl {
        name: name.clone(),
        shape,
        dtype,
        buffer,
        address,
    }));
    name
}

/// A tile's `address=(partition, offset)`, its offset in bytes. Its dtype must be
/// known, to size its elements, and the tile must fit in its buffer from there.
fn read_address(
    value: Value,
    shape: &TileShape,
    dtype: &Dtype,
    buffer: Buffer,
    trace: &Trace,
    line: usize,
) -> Result<Address, ParseError> {
    let Value::Tuple(items) = &value else {
        bail!(
            line,
            "`address=` must be a `(partition, offset)` tuple, not `{value}`"
        );
    };
    let [Value::Int(partition), Value::Int(offset)] = items[..] else {
        bail!(
            line,
            "`address=` must be a `(partition, offset)` tuple, not `{value}`"
        );
    };
    let partition = non_negative(partition, "a partition offset", line)?;
    let offset = non_negative(offset, "a byte offset", line)?;

    let element_bytes = match trace.dtype_name(dtype).as_deref() {
        Some("float32") => 4,
        Some("bfloat16" | "float16") => 2,
        Some(other) => bail!(
            line,
            "a tile placed by `address=` of dtype `{other}` is not supported"
        ),
        None => bail!(
            line,
            "the dtype `{dtype}` of a tile placed by `address=` sizes its elements, so the \
             call must give it"
        ),
    };

    let free: u64 = shape.free.iter().map(|extent| extent.get()).product();
    let capacity = match buffer {
        Buffer::Sbuf => trace.program.tile_sizes.sbuf_fmax_bytes,
        Buffer::Psum => PSUM_PARTITION_BYTES,
    };
    let partitions = u64::from(shape.partitions.get());
    let end = free
        .checked_mul(element_bytes)
        .and_then(|bytes| bytes.checked_add(offset));
    if partition + partitions > u64::from(Partitions::MAX) || end.is_none_or(|end| end > capacity) {
        bail!(
            line,
            "a tile of {partitions} partitions of {free} {element_bytes}-byte elements at \
             `({partition}, {offset})` does not fit in `nl.{}`: {} partitions of {capacity} bytes",
            buffer.name(),
            Partitions::MAX
        );
    }
    Ok(Address {
        partition,
        offset,
        element_bytes,
    })
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
    target: String,
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
            let x = x.expect("required");
            let (tensor, extents) = region_extents(trace, &x, &callee, line)?;
            let axis = axis.expect("required");
            let axes = match &axis {
                Value::Int(axis) => vec![non_negative(*axis, "an axis", line)?],
                axes => {
                    let items = trace.items(axes, &callee, line)?;
                    let axis = |item: &Value| match item {
                        Value::Int(axis) => non_negative(*axis, "an axis", line),
                        other => bail!(line, "`{callee}` needs integer axes, not `{other}`"),
                    };
                    items.iter().map(axis).collect::<Result<_, _>>()?
                }
            };
            let keepdims = match keepdims {
                None | Some(Value::Bool(false)) => false,
                Some(Value::Bool(true)) => true,
                Some(other) => bail!(
                    line,
                    "`keepdims` of `{callee}` must be a bool, not `{other}`"
                ),
            };
            let rank = extents.len() as u64;
            let first = rank.saturating_sub(axes.len() as u64);
            if first == 0 || !axes.iter().copied().eq(first..rank) {
                bail!(
                    line,
                    "`{callee}` reduces a tile's trailing free axes, not {axes:?} of its {rank}"
                );
            }
            let mut reduced = extents[..first as usize].to_vec();
            if keepdims {
                reduced.extend(std::iter::repeat_n(1, axes.len()));
            }
            let op = match function {
                TileFunction::Max => "maximum",
                _ => "add",
            };
            let axis = match axis {
                Value::Int(_) => read_operand("axis", axis, line)?,
                _ => Operand::Ints(axes),
            };
            let operands = vec![
                ("data", read_operand("x", x, line)?),
                ("op", member(op)),
                ("axis", axis),
            ];
            (
                reduced,
                Buffer::Sbuf,
                Dtype::Of(tensor),
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

    let shape = tile_shape(&extents, line)?;
    let name = declare_tile(target, shape, dtype, buffer, None, trace);
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
        Value::Pattern {
            tensor, pattern, ..
        } => {
            let counts = pattern.iter().map(|&[_, count]| count).collect();
            return Ok((tensor.clone(), counts));
        }
        other => bail!(
            line,
            "`{callee}` reads a tensor, a region or a view, not `{other}`"
        ),
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

/// The leading parameters of the `nki.isa` instructions a kernel may give by position,
/// in the order their docs declare them.
const POSITIONAL: [(&str, &[&str]); 4] = [
    ("dma_copy", &["dst", "src"]),
    ("tensor_copy", &["dst", "src"]),
    ("nc_matmul", &["dst", "stationary", "moving"]),
    ("nc_transpose", &["dst", "data"]),
];

/// `nisa.<opcode>(operand, ..., keyword=operand, ...)`: positional operands only where
/// `POSITIONAL` names them, so each operand's role is explicit.
fn instruction(
    opcode: String,
    call: Call,
    trace: &mut Trace,
    frame: &Frame,
    line: usize,
) -> Result<Instruction, ParseError> {
    let params = POSITIONAL
        .iter()
        .find(|(name, _)| *name == opcode)
        .map_or(&[][..], |(_, params)| *params);
    if call.args.len() > params.len() {
        bail!(
            line,
            "`{}` takes at most {} operands by position, the rest by keyword",
            call.callee,
            params.len()
        );
    }
    let callee = call.callee.to_string();
    let positional = params.iter().map(|param| param.to_string()).zip(call.args);
    let mut operands = BTreeMap::new();
    for (keyword, expr) in positional.chain(call.kwargs) {
        if operands.contains_key(&keyword) {
            bail!(line, "operand `{keyword}` of `{callee}` is given twice");
        }
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
        let Ok(extent) = u64::try_from(extent) else {
            bail!(line, "a tile's free extents must be positive");
        };
        ints.push(extent);
    }
    tile_shape(&ints, line)
}

/// A tile's shape from its extents, the partitions first.
fn tile_shape(extents: &[u64], line: usize) -> Result<TileShape, ParseError> {
    let [partitions, ref free @ ..] = extents[..] else {
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
        let Some(extent) = u64::try_from(extent).ok().and_then(NonZeroU64::new) else {
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
/// them, a bool or `None`, e.g. `x`, `x[0:4, :]`, `0.125`, `nl.add`, `1`, `(1,)` or `True`.
fn read_operand(keyword: &str, value: Value, line: usize) -> Result<Operand, ParseError> {
    match value {
        Value::Tensor(tensor) => Ok(Operand::Tensor(tensor)),
        Value::Member(member) => Ok(Operand::Member(member)),
        Value::Float(value) => Ok(Operand::Scalar(value)),
        Value::Int(value) => Ok(Operand::Int(non_negative(
            value,
            "an integer operand",
            line,
        )?)),
        Value::Bool(value) => Ok(Operand::Bool(value)),
        Value::None => Ok(Operand::None),
        Value::Region { tensor, dims } => Ok(Operand::Region { tensor, dims }),
        Value::Pattern {
            tensor,
            pattern,
            offset,
        } => Ok(Operand::Pattern {
            tensor,
            pattern,
            offset,
        }),
        Value::Tuple(items) => {
            let mut values = Vec::new();
            for item in items {
                let Value::Int(value) = item else {
                    bail!(line, "operand `{keyword}`'s tuple must hold integers only");
                };
                values.push(non_negative(value, "an integer operand", line)?);
            }
            Ok(Operand::Ints(values))
        }
        other => bail!(
            line,
            "operand `{keyword}` must be a tensor, a region, a scalar, a module member, \
             integers or a bool, not `{other}`"
        ),
    }
}
