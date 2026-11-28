//! If-conversion of a branch on a symbolic predicate: both arms run from the thread's registers
//! to the branch's immediate post-dominator, and every register they leave different becomes a
//! select on the predicate. An arm may only compute into registers, so the path a thread does
//! not take records no access, synchronization or exit.

use volta_expr::symbolic_full::{ExprId, Type, Width};

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::Interpreter;
use crate::eval::value::{RegFile, Value};
use crate::ir::types::RegClass;
use crate::ir::{InstrId, LoweredInstr, LoweredProgram, Predicate};

/// Each instruction's immediate post-dominator: where the paths leaving it meet again.
pub(in crate::eval) struct Joins {
    ipdom: Vec<Option<usize>>,
}

/// A node of the control-flow graph: an instruction, or the exit every return reaches.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Node {
    Instr(usize),
    Exit,
}

impl Joins {
    /// The post-dominator tree by Cooper, Harvey and Kennedy's iteration over the reversed
    /// control-flow graph, rooted at the exit (index `n`).
    pub(in crate::eval) fn of(program: &LoweredProgram) -> Self {
        let n = program.instructions.len();
        let successors: Vec<Vec<usize>> = (0..n)
            .map(|i| {
                successors(program, i)
                    .into_iter()
                    .map(|node| match node {
                        Node::Instr(j) => j,
                        Node::Exit => n,
                    })
                    .collect()
            })
            .collect();

        let mut predecessors = vec![Vec::new(); n + 1];
        for (i, targets) in successors.iter().enumerate() {
            for &j in targets {
                predecessors[j].push(i);
            }
        }

        let order = postorder_from_exit(&predecessors, n);
        let mut position = vec![usize::MAX; n + 1];
        for (k, &node) in order.iter().enumerate() {
            position[node] = k;
        }

        let mut ipdom = vec![None; n + 1];
        ipdom[n] = Some(n);
        let mut changed = true;

        while changed {
            changed = false;

            for &node in order.iter().rev().filter(|&&node| node != n) {
                let mut processed = successors[node].iter().filter(|&&s| ipdom[s].is_some());
                let Some(&first) = processed.next() else {
                    continue;
                };

                let new = processed.fold(first, |a, &b| intersect(&ipdom, &position, a, b));

                if ipdom[node] != Some(new) {
                    ipdom[node] = Some(new);
                    changed = true;
                }
            }
        }

        ipdom.truncate(n);
        let ipdom = ipdom.into_iter().map(|d| d.filter(|&d| d < n)).collect();

        Self { ipdom }
    }

    /// The instruction where the paths leaving `pc` meet again, unless they meet only at exit.
    fn join(&self, pc: InstrId) -> Option<InstrId> {
        let index = usize::try_from(pc.0).ok()?;
        let join = (*self.ipdom.get(index)?)?;

        Some(InstrId(u32::try_from(join).ok()?))
    }
}

fn successors(program: &LoweredProgram, i: usize) -> Vec<Node> {
    let next = if i + 1 < program.instructions.len() {
        Node::Instr(i + 1)
    } else {
        Node::Exit
    };
    let pc = InstrId(i as u32);

    match program.instruction(pc) {
        Some(LoweredInstr::Bra { target }) => {
            let target = Node::Instr(target.0 as usize);
            if program.predicate(pc).is_some() {
                vec![target, next]
            } else {
                vec![target]
            }
        }
        Some(LoweredInstr::Ret | LoweredInstr::Exit | LoweredInstr::Trap) => vec![Node::Exit],
        _ => vec![next],
    }
}

/// The nodes that reach the exit, in postorder of a depth-first walk of the reversed graph.
fn postorder_from_exit(predecessors: &[Vec<usize>], exit: usize) -> Vec<usize> {
    let mut order = Vec::new();
    let mut visited = vec![false; predecessors.len()];
    let mut stack = vec![(exit, 0usize)];
    visited[exit] = true;

    while let Some((node, next)) = stack.pop() {
        if let Some(&p) = predecessors[node].get(next) {
            stack.push((node, next + 1));
            if !visited[p] {
                visited[p] = true;
                stack.push((p, 0));
            }
        } else {
            order.push(node);
        }
    }

    order
}

fn intersect(ipdom: &[Option<usize>], position: &[usize], mut a: usize, mut b: usize) -> usize {
    while a != b {
        while position[a] < position[b] {
            a = ipdom[a].expect("a processed node has a post-dominator");
        }
        while position[b] < position[a] {
            b = ipdom[b].expect("a processed node has a post-dominator");
        }
    }

    a
}

/// Whether `instr` only computes into registers, so running it on a path not taken is harmless.
fn computes_into_registers(instr: &LoweredInstr) -> bool {
    matches!(
        instr,
        LoweredInstr::LoadParam { .. }
            | LoweredInstr::Mov { .. }
            | LoweredInstr::Cvta { .. }
            | LoweredInstr::Prmt { .. }
            | LoweredInstr::Lop3 { .. }
            | LoweredInstr::BinOp { .. }
            | LoweredInstr::UnaryOp { .. }
            | LoweredInstr::Copysign { .. }
            | LoweredInstr::Fma { .. }
            | LoweredInstr::Mad { .. }
            | LoweredInstr::MulWide { .. }
            | LoweredInstr::MulHi { .. }
            | LoweredInstr::Bfi { .. }
            | LoweredInstr::Bfe { .. }
            | LoweredInstr::Setp { .. }
            | LoweredInstr::Selp { .. }
            | LoweredInstr::Cvt { .. }
            | LoweredInstr::CvtRoundInt { .. }
            | LoweredInstr::Bmsk { .. }
            | LoweredInstr::Set { .. }
            | LoweredInstr::CvtE4m3x2ToF16x2 { .. }
            | LoweredInstr::CvtPackHalves { .. }
            | LoweredInstr::UnpackHalves { .. }
            | LoweredInstr::PackHalves { .. }
            | LoweredInstr::PackQuad { .. }
            | LoweredInstr::UnpackQuad { .. }
            | LoweredInstr::Shf { .. }
            | LoweredInstr::Bra { .. }
    )
}

impl Interpreter<'_> {
    /// Runs the branch at `pc` on the symbolic `condition` both ways and merges the arms'
    /// registers, leaving thread `t` at the join.
    pub(in crate::eval) fn if_convert(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        predicate: Predicate,
        target: InstrId,
        condition: ExprId,
    ) -> EvalResult<()> {
        let join = self
            .joins
            .get_or_init(|| Joins::of(self.program))
            .join(pc)
            .ok_or_else(|| EvalError::Unsupported {
                pc,
                what: "a branch on a symbolic predicate whose paths never meet again".to_string(),
            })?;

        let before = self.threads[t].regs.clone();
        let taken = self.run_arm(t, target, join)?;

        self.threads[t].regs = before;
        let fallthrough = self.run_arm(t, InstrId(pc.0 + 1), join)?;

        let (when_true, when_false) = if predicate.negated {
            (fallthrough, taken)
        } else {
            (taken, fallthrough)
        };

        let undefined = self.undefined;
        let arena = &mut self.arena;
        let merged = RegFile::merged(&when_true, &when_false, |class, a, b| {
            let a = a.unwrap_or(Value::Scalar(undefined));
            let b = b.unwrap_or(Value::Scalar(undefined));
            let ty = |lanes: u16| match class {
                RegClass::Pred => Type::Pred,
                _ => Type::Bits(Width(class_bits(class) / lanes)),
            };

            match (a, b) {
                (Value::Scalar(a), Value::Scalar(b)) => {
                    Some(Value::Scalar(arena.select(ty(1), condition, a, b)))
                }
                (Value::Pair(a0, a1), Value::Pair(b0, b1)) => Some(Value::Pair(
                    arena.select(ty(2), condition, a0, b0),
                    arena.select(ty(2), condition, a1, b1),
                )),
                _ => None,
            }
        })
        .ok_or_else(|| EvalError::Unsupported {
            pc,
            what: "the arms of a branch on a symbolic predicate leave a register holding \
                   values of different kinds"
                .to_string(),
        })?;

        self.threads[t].regs = merged;
        self.threads[t].pc = join;

        Ok(())
    }

    /// Runs thread `t` from `start` to `join`, returning its registers there.
    fn run_arm(&mut self, t: ThreadId, start: InstrId, join: InstrId) -> EvalResult<RegFile> {
        self.threads[t].pc = start;

        while self.threads[t].pc != join {
            let pc = self.threads[t].pc;
            let instr = self.program.instruction(pc);

            if !instr.is_some_and(computes_into_registers) {
                let what = instr.map_or("the end of the program", |i| i.kind_name());
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "a branch on a symbolic predicate reaches {what}, which does more than \
                         compute into registers"
                    ),
                });
            }

            self.step(t)?;
        }

        Ok(self.threads[t].regs.clone())
    }
}

fn class_bits(class: RegClass) -> u16 {
    match class {
        RegClass::Pred => 1,
        RegClass::Bits8 => 8,
        RegClass::Bits16 => 16,
        RegClass::Bits32 => 32,
        RegClass::Bits64 => 64,
        RegClass::Bits128 => 128,
    }
}
