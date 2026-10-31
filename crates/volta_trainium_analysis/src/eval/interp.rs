//! The interpreter: a lowered kernel's instructions in order, each elementwise over
//! the indices of its operands' one shape, with values as expressions of an `ExprArena`.
//! Arguments are laid out row-major in HBM, so their symbols and outputs use offsets.

use id_collections::IdVec;
use volta_expr::{ExprArena, ExprId, Real, SymbolicOutputs};

use crate::ir::{ActivationFunc, ArithOp, InstrId, LoweredInstr, LoweredKernel, TensorId};

use super::EvalError;
use super::tensor::TensorState;

/// Run `kernel` and return, in parameter order, each argument it wrote with its written
/// elements by offset. An unwritten argument element holds its input symbol.
pub fn evaluate(kernel: &LoweredKernel) -> Result<SymbolicOutputs, EvalError> {
    let mut interp = Interpreter::new(kernel);
    for (instr, instruction) in kernel.instructions.iter() {
        interp.step(instr, instruction)?;
    }
    Ok(interp.into_outputs(&kernel.params))
}

struct Interpreter<'a> {
    arena: ExprArena,
    tensors: IdVec<TensorId, TensorState<'a>>,
}

impl<'a> Interpreter<'a> {
    fn new(kernel: &'a LoweredKernel) -> Self {
        let mut arena = ExprArena::new();
        let tensors = kernel
            .tensors
            .values()
            .map(|tensor| TensorState::new(tensor, &mut arena))
            .collect();
        Self {
            arena,
            tensors: IdVec::from_vec(tensors),
        }
    }

    /// Lowering gives an instruction's operands one shape, so `dst`'s indices index them all.
    fn step(&mut self, instr: InstrId, instruction: &LoweredInstr) -> Result<(), EvalError> {
        match *instruction {
            LoweredInstr::Mov { dst, src } => {
                for index in self.tensors[dst].indices(instr)? {
                    let value = self.tensors[src].read(&mut self.arena, instr, &index)?;
                    self.tensors[dst].write(index, value);
                }
            }
            LoweredInstr::Arith { op, dst, lhs, rhs } => {
                for index in self.tensors[dst].indices(instr)? {
                    let a = self.tensors[lhs].read(&mut self.arena, instr, &index)?;
                    let b = self.tensors[rhs].read(&mut self.arena, instr, &index)?;
                    let value = match op {
                        ArithOp::Add => self.arena.add(a, b),
                    };
                    self.tensors[dst].write(index, value);
                }
            }
            LoweredInstr::Activation { func, dst, data } => {
                for index in self.tensors[dst].indices(instr)? {
                    let x = self.tensors[data].read(&mut self.arena, instr, &index)?;
                    let value = self.activation(func, x);
                    self.tensors[dst].write(index, value);
                }
            }
        }
        Ok(())
    }

    fn activation(&mut self, func: ActivationFunc, x: ExprId) -> ExprId {
        match func {
            ActivationFunc::Sigmoid => {
                let one = self.arena.real(Real::one());
                let negated = self.arena.neg(x);
                let exp = self.arena.exp(negated);
                let denominator = self.arena.add(one, exp);
                self.arena.rcp(denominator)
            }
        }
    }

    fn into_outputs(self, params: &[TensorId]) -> SymbolicOutputs {
        let outputs = params
            .iter()
            .map(|&param| {
                let tensor = &self.tensors[param];
                (tensor.name().to_owned(), tensor.written_by_offset())
            })
            .filter(|(_, elements)| !elements.is_empty())
            .collect();
        SymbolicOutputs {
            arena: self.arena,
            outputs,
        }
    }
}
