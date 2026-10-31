//! Read an NKI kernel file as HBM tensors, on-chip tiles and the instructions
//! over them. Every name resolves to an imported module's member or a tensor;
//! imports come first and nothing is rebound, so names resolve as at run time.

use std::collections::{BTreeMap, BTreeSet};
use std::num::NonZeroU64;

use super::ast::{
    Buffer, Dtype, Instruction, Kernel, Operand, Partitions, Statement, TensorName, TileDecl,
    TileShape,
};
use super::error::{ParseError, bail};
use super::python::{self, Call, Dotted, Expr, Function, Item, Stmt};

const NKI: &str = "nki";
const NKI_LANGUAGE: &str = "nki.language";
const NKI_ISA: &str = "nki.isa";

/// Parse `source` and return its `@nki.jit` kernel `name`.
pub fn parse_kernel(source: &str, name: &str) -> Result<Kernel, ParseError> {
    let items = python::parse(source)?;
    let (imports, functions) = split_module(items)?;

    let Some(function) = functions.into_iter().find(|function| function.name == name) else {
        return Err(ParseError::KernelNotFound(name.into()));
    };
    kernel(function, &imports)
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

/// A `@nki.jit` function, its parameters the HBM tensors it receives.
fn kernel(function: Function, imports: &Imports) -> Result<Kernel, ParseError> {
    let line = function.line;
    let mut scope = Scope {
        imports,
        tensors: BTreeSet::new(),
    };

    let decorator = scope.resolve(&function.decorator, line)?;
    if decorator.member_of(NKI) != Some("jit") {
        bail!(line, "unsupported decorator `@{}`", function.decorator);
    }

    let mut params = Vec::new();
    for param in function.params {
        params.push(scope.bind(param, line)?);
    }

    let mut body = Vec::new();
    for stmt in function.body {
        body.push(statement(stmt, &mut scope)?);
    }

    Ok(Kernel {
        name: function.name,
        params,
        body,
    })
}

/// What an expression denotes.
enum Value {
    Int(u64),
    Tuple(Vec<Value>),
    Tensor(TensorName),
    /// `t.dtype`: the element type of tensor `t`.
    DtypeOf(TensorName),
    /// `t.shape`: the extents of tensor `t`.
    ShapeOf(TensorName),
    /// An imported module's member, fully qualified: `nl.add` is `nki.language.add`.
    Member(String),
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

/// The names a kernel body sees: the imports, and the tensors bound so far.
struct Scope<'a> {
    imports: &'a Imports,
    tensors: BTreeSet<TensorName>,
}

impl Scope<'_> {
    /// Bind `name` to a new tensor; it may neither shadow an import nor rebind a name.
    fn bind(&mut self, name: String, line: usize) -> Result<TensorName, ParseError> {
        if self.imports.contains_key(&name) {
            bail!(line, "`{name}` shadows an import");
        }

        let tensor = TensorName(name);
        if !self.tensors.insert(tensor.clone()) {
            bail!(line, "tensor `{tensor}` is already defined");
        }
        Ok(tensor)
    }

    fn evaluate(&self, expr: Expr, line: usize) -> Result<Value, ParseError> {
        match expr {
            Expr::Int(value) => Ok(Value::Int(value)),
            Expr::Name(name) => self.resolve(&name, line),
            Expr::Tuple(items) => {
                let mut values = Vec::new();
                for item in items {
                    values.push(self.evaluate(item, line)?);
                }
                Ok(Value::Tuple(values))
            }
        }
    }

    fn resolve(&self, name: &Dotted, line: usize) -> Result<Value, ParseError> {
        if let Some(module) = self.imports.get(&name.head) {
            let mut member = module.clone();
            for attribute in &name.attributes {
                member.push('.');
                member.push_str(attribute);
            }
            return Ok(Value::Member(member));
        }

        let tensor = TensorName(name.head.clone());
        if !self.tensors.contains(&tensor) {
            bail!(line, "unknown name `{tensor}`");
        }

        match name.attributes.as_slice() {
            [] => Ok(Value::Tensor(tensor)),
            [attribute] if attribute == "dtype" => Ok(Value::DtypeOf(tensor)),
            [attribute] if attribute == "shape" => Ok(Value::ShapeOf(tensor)),
            _ => bail!(line, "unsupported tensor attribute `{name}`"),
        }
    }
}

fn statement(stmt: Stmt, scope: &mut Scope) -> Result<Statement, ParseError> {
    match stmt {
        Stmt::Call { line, target, call } => call_statement(target, call, scope, line),
        Stmt::AssertEq { line, left, right } => shape_assertion(left, right, scope, line),
    }
}

/// `x = nl.ndarray(...)` declares the tile `x`; `nisa.<opcode>(...)` is an instruction.
fn call_statement(
    target: Option<String>,
    call: Call,
    scope: &mut Scope,
    line: usize,
) -> Result<Statement, ParseError> {
    let callee = scope.resolve(&call.callee, line)?;

    if callee.member_of(NKI_LANGUAGE) == Some("ndarray") {
        let Some(target) = target else {
            bail!(
                line,
                "the tile of `{}` must be bound to a name",
                call.callee
            );
        };
        let tile = declaration(target, call, scope, line)?;
        return Ok(Statement::Declare(tile));
    }

    if let Some(opcode) = callee.member_of(NKI_ISA) {
        if let Some(target) = target {
            bail!(
                line,
                "`{target}` is bound to an instruction; only `nl.ndarray` declares tiles"
            );
        }
        let instruction = instruction(opcode.to_owned(), call, scope, line)?;
        return Ok(Statement::Instruction(instruction));
    }

    bail!(line, "unsupported call `{}`", call.callee);
}

/// `assert t.shape == (extent, ...)`.
fn shape_assertion(
    left: Expr,
    right: Expr,
    scope: &Scope,
    line: usize,
) -> Result<Statement, ParseError> {
    let left = scope.evaluate(left, line)?;
    let right = scope.evaluate(right, line)?;
    let (Value::ShapeOf(tensor), Value::Tuple(extents)) = (left, right) else {
        bail!(
            line,
            "only `tensor.shape == (extent, ...)` assertions are supported"
        );
    };

    let mut shape = Vec::new();
    for extent in extents {
        let Value::Int(extent) = extent else {
            bail!(line, "a shape's extents must be integers");
        };
        shape.push(extent);
    }

    Ok(Statement::AssertShape { tensor, shape })
}

/// `target = nl.ndarray(shape, dtype, buffer=...)`.
fn declaration(
    target: String,
    call: Call,
    scope: &mut Scope,
    line: usize,
) -> Result<TileDecl, ParseError> {
    let [shape, dtype, buffer] = ndarray_arguments(call, scope, line)?;

    let shape = read_shape(shape, line)?;
    let dtype = read_dtype(dtype, line)?;
    let buffer = read_buffer(buffer, line)?;

    // As in Python, the arguments are evaluated before the target is bound.
    let name = scope.bind(target, line)?;

    Ok(TileDecl {
        name,
        shape,
        dtype,
        buffer,
    })
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
            "a tile's buffer must be `nl.sbuf` or `nl.psum`; HBM tensors are parameters"
        );
    };
    Ok(buffer)
}

/// A tensor or a module member, e.g. `x` or `nl.add`.
fn read_operand(keyword: &str, value: Value, line: usize) -> Result<Operand, ParseError> {
    match value {
        Value::Tensor(tensor) => Ok(Operand::Tensor(tensor)),
        Value::Member(member) => Ok(Operand::Member(member)),
        _ => bail!(
            line,
            "operand `{keyword}` must be a tensor or a module member"
        ),
    }
}
