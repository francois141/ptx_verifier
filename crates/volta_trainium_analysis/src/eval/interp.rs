//! The interpreter: a lowered kernel's instructions in order, each over the indices
//! of its operands, with values as expressions of an `ExprArena`.
//! Arguments are laid out row-major in HBM, so their symbols and outputs use offsets.

use id_collections::IdVec;
use volta_expr::{ExprArena, ExprId, Real, SymbolicOutputs};

use crate::ir::{ActivationFunc, ArithOp, Index, InstrId, LoweredInstr, LoweredKernel, TensorId};

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

    /// An elementwise instruction's operands have one shape, so `dst`'s indices index them all.
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
            LoweredInstr::Matmul {
                dst,
                stationary,
                moving,
            } => self.matmul(instr, dst, [stationary, moving])?,
            LoweredInstr::Transpose { dst, data } => {
                // Every element is read before any is written: `dst` may be `data` itself.
                let mut values = Vec::new();
                for index in self.tensors[data].indices(instr)? {
                    let value = self.tensors[data].read(&mut self.arena, instr, &index)?;
                    values.push((index.transposed(), value));
                }
                for (index, value) in values {
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

    /// Each `dst[row, column]` as the sum over `k` of `stationary[k, row] * moving[k, column]`.
    /// With `nc_matmul`'s default `accumulate=None`, a PSUM element's first write overwrites
    /// it and later ones accumulate. `dst` is in PSUM and the operands in SBUF, so none alias.
    fn matmul(
        &mut self,
        instr: InstrId,
        dst: TensorId,
        [stationary, moving]: [TensorId; 2],
    ) -> Result<(), EvalError> {
        let [contraction, rows] = self.tensors[stationary].tile_shape();
        let [_, columns] = self.tensors[moving].tile_shape();
        for row in 0..rows {
            for column in 0..columns {
                let index = Index(vec![row, column]);
                let mut sum = match self.tensors[dst].written(&index) {
                    Some(earlier) => earlier,
                    None => self.arena.int(0),
                };
                for k in 0..contraction {
                    let a = self.tensors[stationary].read(
                        &mut self.arena,
                        instr,
                        &Index(vec![k, row]),
                    )?;
                    let b = self.tensors[moving].read(
                        &mut self.arena,
                        instr,
                        &Index(vec![k, column]),
                    )?;
                    let product = self.arena.mul(a, b);
                    sum = self.arena.add(sum, product);
                }
                self.tensors[dst].write(index, sum);
            }
        }
        Ok(())
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
