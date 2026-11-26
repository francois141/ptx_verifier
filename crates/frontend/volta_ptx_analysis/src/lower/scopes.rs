//! Block-scoped register declarations (PTX ISA 11.2: a `.reg` declared in a `{}` block is
//! visible only in it, shadowing an outer one). Lowering keeps one flat register table, so a
//! nested `.reg` whose name another declaration of the function already uses is renamed,
//! with every use inside its block, before declarations are collected.

use std::collections::{HashMap, HashSet};

use crate::frontend::ascii::AsciiString;
use crate::frontend::ast::{
    Address, AddressBase, Expr, FunctionBody, Instruction, InstructionOp, Operand,
    ParsedInstruction, StateSpace, Statement, VarDecl,
};

/// `body` with each shadowing nested register renamed `name#k`; `#` cannot appear in a PTX
/// identifier, so a new name never collides with a declared one.
pub(super) fn unshadow_registers(body: &FunctionBody, module_vars: &[VarDecl]) -> FunctionBody {
    let mut taken: HashSet<String> = module_vars.iter().flat_map(declared_names).collect();
    for stmt in &body.statements {
        if let Statement::Variable(var) = stmt {
            taken.extend(declared_names(var));
        }
    }
    let mut renamer = Renamer {
        taken,
        scopes: vec![HashMap::new()],
        next: 0,
    };
    FunctionBody {
        statements: body
            .statements
            .iter()
            .map(|s| renamer.statement(s, 0))
            .collect(),
    }
}

/// The register names `var` declares (`%r<4>` declares `%r0` to `%r3`).
fn declared_names(var: &VarDecl) -> Vec<String> {
    if var.space != StateSpace::Reg {
        return Vec::new();
    }
    let name = var.name.to_string();
    match var.param_count {
        None => vec![name],
        Some(count) => (0..count).map(|i| format!("{name}{i}")).collect(),
    }
}

struct Renamer {
    /// Every name a declaration of the function claims so far.
    taken: HashSet<String>,
    /// Renames in force, innermost block last.
    scopes: Vec<HashMap<String, String>>,
    next: u32,
}

impl Renamer {
    fn statement(&mut self, stmt: &Statement, depth: u32) -> Statement {
        match stmt {
            Statement::Block(stmts) => {
                self.scopes.push(HashMap::new());
                let inner = stmts.iter().map(|s| self.statement(s, depth + 1)).collect();
                self.scopes.pop();
                Statement::Block(inner)
            }
            Statement::Variable(var) if depth > 0 && var.space == StateSpace::Reg => {
                Statement::Variable(self.declare(var))
            }
            Statement::Instruction(instr) => Statement::Instruction(self.instruction(instr)),
            other => other.clone(),
        }
    }

    /// A nested declaration, renamed when any of its names is already claimed.
    fn declare(&mut self, var: &VarDecl) -> VarDecl {
        let names = declared_names(var);
        if !names.iter().any(|n| self.taken.contains(n)) {
            self.taken.extend(names);
            return var.clone();
        }
        self.next += 1;
        let base = format!("{}#{}", var.name, self.next);
        let scope = self.scopes.last_mut().expect("a block scope");
        match var.param_count {
            None => {
                scope.insert(var.name.to_string(), base.clone());
            }
            Some(count) => {
                for i in 0..count {
                    scope.insert(format!("{}{i}", var.name), format!("{base}#{i}"));
                }
            }
        }
        let mut renamed = var.clone();
        renamed.name = ascii_name(&match var.param_count {
            None => base,
            Some(_) => format!("{base}#"),
        });
        self.taken.extend(declared_names(&renamed));
        renamed
    }

    fn resolve(&self, name: &AsciiString) -> AsciiString {
        let key = name.to_string();
        for scope in self.scopes.iter().rev() {
            if let Some(renamed) = scope.get(&key) {
                return ascii_name(renamed);
            }
        }
        name.clone()
    }

    fn instruction(&self, instr: &Instruction) -> Instruction {
        if self.scopes.iter().all(HashMap::is_empty) {
            return instr.clone();
        }
        let mut out = instr.clone();
        if let Some(guard) = &mut out.predicate {
            guard.reg = self.resolve(&guard.reg);
        }
        match &mut out.op {
            InstructionOp::Unparsed { operands, .. } => {
                operands.iter_mut().for_each(|op| self.operand(op));
            }
            InstructionOp::Parsed(ParsedInstruction::Call(call)) => {
                call.return_operands
                    .iter_mut()
                    .for_each(|op| self.operand(op));
                call.arguments.iter_mut().for_each(|op| self.operand(op));
            }
            InstructionOp::Parsed(_) => {}
        }
        out
    }

    fn operand(&self, op: &mut Operand) {
        match op {
            Operand::Ident(name) | Operand::Symbol(name) | Operand::VectorElement(name, _) => {
                *name = self.resolve(name);
            }
            Operand::PredicateOperand { name, .. } => *name = self.resolve(name),
            Operand::PredicatePair(a, b) => {
                *a = self.resolve(a);
                *b = self.resolve(b);
            }
            Operand::Expr(expr) => self.expr(expr),
            Operand::Address(address) => self.address(address),
            Operand::TensorCoordAddress { descriptor, coords } => {
                self.address(descriptor);
                coords.iter_mut().for_each(|c| self.operand(c));
            }
            Operand::Vector(ops) => ops.iter_mut().for_each(|o| self.operand(o)),
            Operand::ImmInt(_)
            | Operand::ImmUInt(_)
            | Operand::ImmFloat(_)
            | Operand::Underscore => {}
        }
    }

    fn address(&self, address: &mut Address) {
        match &mut address.base {
            AddressBase::Register(name) | AddressBase::Symbol(name) => *name = self.resolve(name),
            AddressBase::Immediate(_) => {}
        }
        if let Some(offset) = &mut address.offset {
            self.expr(offset);
        }
    }

    fn expr(&self, expr: &mut Expr) {
        match expr {
            Expr::Ident(name) => *name = self.resolve(name),
            Expr::Unary(_, e) => self.expr(e),
            Expr::Binary(a, _, b) => {
                self.expr(a);
                self.expr(b);
            }
            Expr::Ternary(c, a, b) => {
                self.expr(c);
                self.expr(a);
                self.expr(b);
            }
            Expr::IntLitS(_) | Expr::IntLitU(_) => {}
        }
    }
}

fn ascii_name(name: &str) -> AsciiString {
    use crate::frontend::ascii::AsAscii;
    AsciiString::from(
        name.as_bytes()
            .as_ascii_slice()
            .expect("an ASCII register name")
            .to_vec(),
    )
}
