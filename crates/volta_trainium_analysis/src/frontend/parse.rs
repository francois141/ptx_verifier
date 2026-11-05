//! Read an NKI kernel file, specialized to one call's parameter shapes, as HBM
//! tensors, on-chip tiles and the instructions over them. Integer arithmetic and
//! `assert`s are evaluated here; imports come first and nothing is rebound.

use std::collections::BTreeMap;
use std::fmt;
use std::num::NonZeroU64;

use super::ast::{
    Bounds, Buffer, Dtype, HbmDecl, Instruction, Kernel, Operand, Param, Partitions, Scalar,
    Statement, TensorName, TileDecl, TileShape,
};
use super::error::{ParseError, ShapeProblem, bail};
use super::lex::CmpOp;
use super::python::{self, BinOp, Call, Dotted, Expr, Function, Item, Stmt, Target};

const NKI: &str = "nki";
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

/// Parse `source` and return its `@nki.jit` kernel `name` for a call whose
/// arguments have `shapes`, as `@nki.jit` specializes a kernel to each call.
pub fn parse_kernel(
    source: &str,
    name: &str,
    shapes: &[(&str, &[u64])],
) -> Result<Kernel, ParseError> {
    let items = python::parse(source)?;
    let (imports, functions) = split_module(items)?;
    kernel(find(functions, name)?, &imports, shapes)
}

/// The shapes kernel `name`'s top-level `assert param.shape == (extent, ...)`
/// statements state, the first for each parameter, for running it without a call.
pub fn asserted_shapes(source: &str, name: &str) -> Result<Vec<(String, Vec<u64>)>, ParseError> {
    let (_, functions) = split_module(python::parse(source)?)?;
    let function = find(functions, name)?;

    let mut shapes: Vec<(String, Vec<u64>)> = Vec::new();
    for stmt in &function.body {
        let Some((param, extents)) = literal_shape(stmt) else {
            continue;
        };
        if function.params.contains(&param) && !shapes.iter().any(|(given, _)| *given == param) {
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

fn find(functions: Vec<Function>, name: &str) -> Result<Function, ParseError> {
    functions
        .into_iter()
        .find(|function| function.name == name)
        .ok_or_else(|| ParseError::KernelNotFound(name.into()))
}

/// The module each imported name is bound to.
type Imports = BTreeMap<String, String>;

/// A module's imports and functions: every import precedes the functions, and
/// no global name is bound twice.
fn split_module(items: Vec<Item>) -> Result<(Imports, Vec<Function>), ParseError> {
    let mut imports = Imports::new();
    let mut functions: Vec<Function> = Vec::new();

    for item in items {
        match item {
            Item::Import { line, path, alias } => {
                if !functions.is_empty() {
                    bail!(line, "imports must precede the kernels");
                }

                // `import a.b` binds `a` to `a`; `import a.b as c` binds `c` to `a.b`.
                let (name, module) = match alias {
                    Some(alias) => (alias, path.to_string()),
                    None => (path.head.clone(), path.head),
                };
                if imports.get(&name).is_some_and(|bound| *bound != module) {
                    bail!(line, "`{name}` is imported twice");
                }
                imports.insert(name, module);
            }

            Item::Function(function) => {
                let name = &function.name;
                if imports.contains_key(name) || functions.iter().any(|f| f.name == *name) {
                    bail!(function.line, "`{name}` is defined twice");
                }
                functions.push(function);
            }
        }
    }

    Ok((imports, functions))
}

/// A `@nki.jit` function, its parameters the HBM tensors it receives with the
/// call's shapes, and the tensor its last statement returns, if that is a `return`.
fn kernel(
    function: Function,
    imports: &Imports,
    shapes: &[(&str, &[u64])],
) -> Result<Kernel, ParseError> {
    let line = function.line;
    let mut scope = Scope {
        imports,
        names: BTreeMap::new(),
        iterations: Vec::new(),
    };

    let decorator = scope.resolve(&function.decorator, line)?;
    if decorator.member_of(NKI) != Some("jit") {
        bail!(line, "unsupported decorator `@{}`", function.decorator);
    }

    for (index, (given, _)) in shapes.iter().enumerate() {
        let problem = if !function.params.iter().any(|param| param == given) {
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
    for param in function.params {
        let shape = param_shape(&param, shapes)?;
        let extents = shape.iter().map(|extent| extent.get()).collect();
        let name = scope.bind_tensor(param, extents, line)?;
        params.push(Param { name, shape });
    }

    let mut statements = function.body;
    let returned = match statements.pop() {
        Some(Stmt::Return { line, value }) => Some((value, line)),
        last => {
            statements.extend(last);
            None
        }
    };

    let mut body = Vec::new();
    for stmt in statements {
        statement(stmt, &mut scope, &mut body)?;
    }

    let returned = returned
        .map(|(value, line)| returned_tensor(value, &scope, line))
        .transpose()?;

    Ok(Kernel {
        name: function.name,
        params,
        body,
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

/// The tensor `return value` names.
fn returned_tensor(value: Expr, scope: &Scope, line: usize) -> Result<TensorName, ParseError> {
    let Value::Tensor(tensor) = scope.evaluate(value, line)? else {
        bail!(line, "a kernel can only return a tensor");
    };
    Ok(tensor)
}

/// What an expression denotes. A tensor's `shape` is a tuple of its extents.
#[derive(PartialEq)]
enum Value {
    Int(u64),
    Float(Scalar),
    Tuple(Vec<Value>),
    Tensor(TensorName),
    /// `t.dtype`: the element type of tensor `t`.
    DtypeOf(TensorName),
    /// An imported module's member, fully qualified: `nl.add` is `nki.language.add`.
    Member(String),
    /// A rectangular region of a tensor, from a subscript.
    Region {
        tensor: TensorName,
        dims: Vec<Bounds>,
    },
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
            Self::Tuple(items) => {
                let items: Vec<String> = items.iter().map(Value::to_string).collect();
                write!(f, "({})", items.join(", "))
            }
            Self::Tensor(tensor) => write!(f, "{tensor}"),
            Self::DtypeOf(tensor) => write!(f, "{tensor}.dtype"),
            Self::Member(member) => f.write_str(member),
            Self::Region { tensor, dims } => {
                let dims: Vec<String> = dims.iter().map(Bounds::to_string).collect();
                write!(f, "{tensor}[{}]", dims.join(", "))
            }
        }
    }
}

/// What a name in the kernel body is bound to.
enum Binding {
    /// A tensor, with its extents.
    Tensor(Vec<u64>),
    /// A compile-time integer: a shape's extent, arithmetic on one, or a loop index.
    Int(u64),
}

/// The names a kernel body sees: the imports, and the tensors and integers bound so far.
struct Scope<'a> {
    imports: &'a Imports,
    /// Keyed by qualified name, so each unrolled iteration binds its own.
    names: BTreeMap<String, Binding>,
    /// The index of each enclosing unrolled iteration, outermost first.
    iterations: Vec<u64>,
}

impl Scope<'_> {
    /// Bind `name`, qualified; it may neither shadow an import nor rebind a name.
    fn bind(&mut self, name: String, binding: Binding, line: usize) -> Result<String, ParseError> {
        if self.imports.contains_key(&name) {
            bail!(line, "`{name}` shadows an import");
        }

        let qualified = self.qualified(&name);
        if self.names.contains_key(&qualified) {
            bail!(line, "`{qualified}` is already defined");
        }
        self.names.insert(qualified.clone(), binding);
        Ok(qualified)
    }

    fn bind_tensor(
        &mut self,
        name: String,
        extents: Vec<u64>,
        line: usize,
    ) -> Result<TensorName, ParseError> {
        self.bind(name, Binding::Tensor(extents), line)
            .map(TensorName)
    }

    /// Bind `name` to `value`, which must be an integer.
    fn bind_int(&mut self, name: String, value: Value, line: usize) -> Result<(), ParseError> {
        let Value::Int(value) = value else {
            bail!(
                line,
                "`{name}` must be bound to an integer or an `nl.ndarray` tensor, not `{value}`"
            );
        };
        self.bind(name, Binding::Int(value), line)?;
        Ok(())
    }

    fn evaluate(&self, expr: Expr, line: usize) -> Result<Value, ParseError> {
        match expr {
            Expr::Int(value) => Ok(Value::Int(value)),
            Expr::Float(value) => Ok(Value::Float(value)),
            Expr::Name(name) => self.resolve(&name, line),
            Expr::Tuple(items) => {
                let mut values = Vec::new();
                for item in items {
                    values.push(self.evaluate(item, line)?);
                }
                Ok(Value::Tuple(values))
            }
            Expr::Binary { op, lhs, rhs } => {
                let lhs = self.evaluate(*lhs, line)?;
                let rhs = self.evaluate(*rhs, line)?;
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
                let Value::Tensor(tensor) = self.evaluate(*base, line)? else {
                    bail!(line, "only a tensor can be indexed");
                };
                let mut dims = Vec::new();
                for index in indices {
                    dims.push(self.bounds(index, line)?);
                }
                Ok(Value::Region { tensor, dims })
            }
            Expr::Slice { .. } => bail!(line, "a slice is only valid inside `[]`"),
            Expr::Call(call) => bail!(
                line,
                "`{}` can only be called as a statement, or bound if it is `nl.ndarray`",
                call.callee
            ),
            Expr::Compare { .. } => bail!(line, "a comparison is only valid in an `assert`"),
        }
    }

    /// The first comparison of the chain `first op second ...` that is false, if any.
    fn failed_comparison(
        &self,
        first: Expr,
        rest: Vec<(CmpOp, Expr)>,
        line: usize,
    ) -> Result<Option<(Value, CmpOp, Value)>, ParseError> {
        let mut lhs = self.evaluate(first, line)?;
        for (op, rhs) in rest {
            let rhs = self.evaluate(rhs, line)?;
            if !holds(op, &lhs, &rhs, line)? {
                return Ok(Some((lhs, op, rhs)));
            }
            lhs = rhs;
        }
        Ok(None)
    }

    /// One subscript index as slice bounds. An integer index would drop its
    /// dimension, so only a slice is accepted.
    fn bounds(&self, index: Expr, line: usize) -> Result<Bounds, ParseError> {
        let Expr::Slice { start, stop } = index else {
            bail!(line, "a tensor index must be a slice");
        };
        Ok(Bounds {
            start: self.bound(start, line)?,
            stop: self.bound(stop, line)?,
        })
    }

    /// A slice bound, absent when the subscript omits it.
    fn bound(&self, bound: Option<Box<Expr>>, line: usize) -> Result<Option<u64>, ParseError> {
        let Some(expr) = bound else {
            return Ok(None);
        };
        let Value::Int(value) = self.evaluate(*expr, line)? else {
            bail!(line, "a slice bound must be an integer");
        };
        Ok(Some(value))
    }

    fn resolve(&self, name: &Dotted, line: usize) -> Result<Value, ParseError> {
        if let Some(module) = self.imports.get(&name.head) {
            let mut member = module.clone();
            for attribute in &name.attributes {
                member.push('.');
                member.push_str(attribute);
            }
            return tile_size(member, line);
        }

        let Some((qualified, binding)) = self.lookup(&name.head) else {
            bail!(line, "unknown name `{}`", name.head);
        };

        match (binding, name.attributes.as_slice()) {
            (Binding::Int(value), []) => Ok(Value::Int(*value)),
            (Binding::Int(_), _) => bail!(line, "unsupported attribute on `{}`", name.head),
            (Binding::Tensor(_), []) => Ok(Value::Tensor(TensorName(qualified))),
            (Binding::Tensor(_), [attribute]) if attribute == "dtype" => {
                Ok(Value::DtypeOf(TensorName(qualified)))
            }
            (Binding::Tensor(extents), [attribute]) if attribute == "shape" => Ok(Value::Tuple(
                extents.iter().map(|&extent| Value::Int(extent)).collect(),
            )),
            (Binding::Tensor(_), _) => bail!(line, "unsupported tensor attribute `{name}`"),
        }
    }

    /// `name` with the enclosing iteration indices appended, so each unrolled
    /// iteration declares its own tiles: `x` becomes `x.0` in iteration 0.
    fn qualified(&self, name: &str) -> String {
        let mut qualified = name.to_string();
        for index in &self.iterations {
            qualified.push('.');
            qualified.push_str(&index.to_string());
        }
        qualified
    }

    /// What `name` refers to, with its qualified name: the innermost enclosing
    /// iteration's binding, else an outer one's.
    fn lookup(&self, name: &str) -> Option<(String, &Binding)> {
        for depth in (0..=self.iterations.len()).rev() {
            let mut candidate = name.to_string();
            for index in &self.iterations[..depth] {
                candidate.push('.');
                candidate.push_str(&index.to_string());
            }
            if let Some(binding) = self.names.get(&candidate) {
                return Some((candidate, binding));
            }
        }
        None
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

fn statement(stmt: Stmt, scope: &mut Scope, out: &mut Vec<Statement>) -> Result<(), ParseError> {
    match stmt {
        Stmt::Assign {
            line,
            target,
            value,
        } => assignment(target, value, scope, out, line),
        Stmt::Expr { line, value } => {
            out.push(effect(value, scope, line)?);
            Ok(())
        }
        Stmt::Assert { line, test } => assertion(test, scope, line),
        Stmt::For {
            line,
            var,
            iterable,
            body,
        } => unroll(var, iterable, body, scope, out, line),
        Stmt::Return { line, .. } => bail!(line, "`return` must be the kernel's last statement"),
    }
}

/// `for var in nl.affine_range(count):` as its body once per index, each
/// iteration binding its own index and tiles. The index is unbound after its
/// iteration, so later loops can reuse the name.
fn unroll(
    var: String,
    iterable: Expr,
    body: Vec<Stmt>,
    scope: &mut Scope,
    out: &mut Vec<Statement>,
    line: usize,
) -> Result<(), ParseError> {
    let count = affine_range(iterable, scope, line)?;

    for index in 0..count {
        scope.iterations.push(index);
        let bound = scope.bind(var.clone(), Binding::Int(index), line)?;
        for stmt in body.clone() {
            statement(stmt, scope, out)?;
        }
        scope.names.remove(&bound);
        scope.iterations.pop();
    }
    Ok(())
}

/// The trip count of `nl.affine_range(count)`: only a concrete count unrolls.
fn affine_range(iterable: Expr, scope: &Scope, line: usize) -> Result<u64, ParseError> {
    let Expr::Call(call) = iterable else {
        bail!(line, "a loop must iterate over `nl.affine_range(count)`");
    };
    let callee = scope.resolve(&call.callee, line)?;
    if callee.member_of(NKI_LANGUAGE) != Some("affine_range") {
        bail!(line, "unsupported loop iterable `{}`", call.callee);
    }
    if !call.kwargs.is_empty() {
        bail!(line, "`affine_range` takes no keyword arguments");
    }
    let [count] = &call.args[..] else {
        bail!(line, "`affine_range` takes one argument");
    };
    let Value::Int(count) = scope.evaluate(count.clone(), line)? else {
        bail!(line, "`affine_range`'s count must be an integer");
    };
    Ok(count)
}

/// `x = nl.ndarray(...)` declares the tile or HBM tensor `x`; any other value
/// binds integers, `a, b = t.shape` one per extent.
fn assignment(
    target: Target,
    value: Expr,
    scope: &mut Scope,
    out: &mut Vec<Statement>,
    line: usize,
) -> Result<(), ParseError> {
    let value = match value {
        Expr::Call(call) => {
            let callee = scope.resolve(&call.callee, line)?;
            if callee.member_of(NKI_LANGUAGE) != Some("ndarray") {
                bail!(
                    line,
                    "only `nl.ndarray` declares tensors, not `{}`",
                    call.callee
                );
            }
            let Target::Name(name) = target else {
                bail!(line, "`nl.ndarray` declares one tensor");
            };
            out.push(declaration(name, call, scope, line)?);
            return Ok(());
        }
        value => scope.evaluate(value, line)?,
    };

    match target {
        Target::Name(name) => scope.bind_int(name, value, line),
        Target::Unpack(names) => {
            let Value::Tuple(items) = value else {
                bail!(line, "only a tuple can be unpacked, not `{value}`");
            };
            if items.len() != names.len() {
                bail!(
                    line,
                    "cannot unpack {} values into {} names",
                    items.len(),
                    names.len()
                );
            }
            for (name, item) in names.into_iter().zip(items) {
                scope.bind_int(name, item, line)?;
            }
            Ok(())
        }
    }
}

/// An expression statement: `nisa.<opcode>(...)`, an instruction.
fn effect(value: Expr, scope: &Scope, line: usize) -> Result<Statement, ParseError> {
    let Expr::Call(call) = value else {
        bail!(
            line,
            "a statement must be an `nki.isa` call, an assignment or an `assert`"
        );
    };
    let callee = scope.resolve(&call.callee, line)?;

    if callee.member_of(NKI_LANGUAGE) == Some("ndarray") {
        bail!(
            line,
            "the tile of `{}` must be bound to a name",
            call.callee
        );
    }
    let Some(opcode) = callee.member_of(NKI_ISA) else {
        bail!(line, "unsupported call `{}`", call.callee);
    };
    let instruction = instruction(opcode.to_owned(), call, scope, line)?;
    Ok(Statement::Instruction(instruction))
}

/// `assert a op b ...`, checked against the call's shapes: it leaves no statement.
fn assertion(test: Expr, scope: &Scope, line: usize) -> Result<(), ParseError> {
    let Expr::Compare { first, rest } = test else {
        bail!(line, "an `assert` must be a comparison");
    };
    if let Some((lhs, op, rhs)) = scope.failed_comparison(*first, rest, line)? {
        bail!(
            line,
            "assertion fails for this call: `{lhs} {} {rhs}` is false",
            op.text()
        );
    }
    Ok(())
}

/// `target = nl.ndarray(shape, dtype, buffer=...)`: an HBM tensor of any rank in
/// `nl.shared_hbm`, else an on-chip tile.
fn declaration(
    target: String,
    call: Call,
    scope: &mut Scope,
    line: usize,
) -> Result<Statement, ParseError> {
    let [shape, dtype, buffer] = ndarray_arguments(call, scope, line)?;
    let dtype = read_dtype(dtype, line)?;

    // As in Python, the arguments are evaluated before the target is bound.
    if buffer.member_of(NKI_LANGUAGE) == Some(SHARED_HBM) {
        let shape = read_extents(shape, line)?;
        let extents = shape.iter().map(|extent| extent.get()).collect();
        let name = scope.bind_tensor(target, extents, line)?;
        return Ok(Statement::DeclareHbm(HbmDecl { name, shape, dtype }));
    }

    let shape = read_shape(shape, line)?;
    let buffer = read_buffer(buffer, line)?;
    let extents = vec![u64::from(shape.partitions.get()), shape.free.get()];
    let name = scope.bind_tensor(target, extents, line)?;
    Ok(Statement::Declare(TileDecl {
        name,
        shape,
        dtype,
        buffer,
    }))
}

/// `nl.ndarray`'s shape, dtype and buffer, each given by position or by keyword.
fn ndarray_arguments(call: Call, scope: &Scope, line: usize) -> Result<[Value; 3], ParseError> {
    const PARAMS: [&str; 3] = ["shape", "dtype", "buffer"];

    if call.args.len() > PARAMS.len() {
        bail!(line, "`{}` takes at most 3 arguments", call.callee);
    }
    let mut given: [Option<Expr>; 3] = [None, None, None];
    for (slot, expr) in given.iter_mut().zip(call.args) {
        *slot = Some(expr);
    }

    for (keyword, expr) in call.kwargs {
        let Some(index) = PARAMS.iter().position(|param| *param == keyword) else {
            bail!(line, "`{}` has no argument `{keyword}`", call.callee);
        };
        if given[index].replace(expr).is_some() {
            bail!(
                line,
                "argument `{keyword}` of `{}` given twice",
                call.callee
            );
        }
    }

    let [Some(shape), Some(dtype), Some(buffer)] = given else {
        bail!(
            line,
            "`{}` needs a shape, a dtype and a buffer",
            call.callee
        );
    };
    Ok([
        scope.evaluate(shape, line)?,
        scope.evaluate(dtype, line)?,
        scope.evaluate(buffer, line)?,
    ])
}

/// `nisa.<opcode>(keyword=operand, ...)`: every operand by keyword, so its role is explicit.
fn instruction(
    opcode: String,
    call: Call,
    scope: &Scope,
    line: usize,
) -> Result<Instruction, ParseError> {
    if !call.args.is_empty() {
        bail!(line, "`{}` takes its operands by keyword", call.callee);
    }

    let mut operands = BTreeMap::new();
    for (keyword, expr) in call.kwargs {
        let operand = read_operand(&keyword, scope.evaluate(expr, line)?, line)?;
        operands.insert(keyword, operand);
    }

    Ok(Instruction { opcode, operands })
}

/// A tile's `(partitions, free)` extents, e.g. `(128, 512)`.
fn read_shape(value: Value, line: usize) -> Result<TileShape, ParseError> {
    let Value::Tuple(extents) = value else {
        bail!(line, "a tile's shape must be a tuple");
    };
    let [Value::Int(partitions), Value::Int(free)] = extents[..] else {
        bail!(
            line,
            "a tile's shape must be two integers `(partitions, free)`"
        );
    };

    let Some(partitions) = Partitions::new(partitions) else {
        bail!(
            line,
            "a tile spans 1 to {} partitions, not {partitions}",
            Partitions::MAX
        );
    };
    let Some(free) = NonZeroU64::new(free) else {
        bail!(line, "a tile's free size must be positive");
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

/// A tensor, a region of one, a scalar, or a module member, e.g. `x`, `x[0:4, :]`,
/// `0.125` or `nl.add`.
fn read_operand(keyword: &str, value: Value, line: usize) -> Result<Operand, ParseError> {
    match value {
        Value::Tensor(tensor) => Ok(Operand::Tensor(tensor)),
        Value::Member(member) => Ok(Operand::Member(member)),
        Value::Float(value) => Ok(Operand::Scalar(value)),
        Value::Region { tensor, dims } => Ok(Operand::Region { tensor, dims }),
        _ => bail!(
            line,
            "operand `{keyword}` must be a tensor, a region, a scalar, or a module member"
        ),
    }
}
