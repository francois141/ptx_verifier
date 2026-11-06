//! The interpreter: a lowered kernel's instructions in order, each over the indices
//! of its operands, with values as expressions of an `ExprArena`.
//! Arguments are laid out row-major in HBM, so their symbols and outputs use offsets.

use id_collections::IdVec;
use volta_expr::{ExprArena, ExprId, Real, SymbolicOutputs};

use crate::ir::{
    ActivationFunc, ArithOp, Index, InstrId, LoweredInstr, LoweredKernel, ScalarOperand, TensorId,
    TensorRegion,
};

use super::EvalError;
use super::tensor::TensorState;

/// Run `kernel` and return, in parameter order, each argument it wrote, then the tensor it
/// returns, each with its written elements by offset. An unwritten argument element holds
/// its input symbol.
pub fn evaluate(kernel: &LoweredKernel) -> Result<SymbolicOutputs, EvalError> {
    let mut interp = Interpreter::new(kernel);
    for (instr, instruction) in kernel.instructions.iter() {
        interp.step(instr, instruction)?;
    }
    let outputs: Vec<TensorId> = kernel
        .params
        .iter()
        .copied()
        .chain(kernel.returned)
        .collect();
    Ok(interp.into_outputs(&outputs))
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

    fn step(&mut self, instr: InstrId, instruction: &LoweredInstr) -> Result<(), EvalError> {
        for Write {
            tensor,
            index,
            value,
        } in self.writes(instr, instruction)?
        {
            self.tensors[tensor].write(index, value);
        }
        Ok(())
    }

    /// The elements `instruction` writes, every operand read before any is written.
    /// An elementwise instruction's regions have one shape, so `dst`'s local indices
    /// index them all.
    fn writes(
        &mut self,
        instr: InstrId,
        instruction: &LoweredInstr,
    ) -> Result<Vec<Write>, EvalError> {
        let mut writes = Vec::new();
        match instruction {
            LoweredInstr::Mov { dst, src } => {
                for at in indices(instr, dst, &self.tensors)? {
                    let value = self.read(instr, src, &at)?;
                    writes.push(Write::at(dst, &at, value));
                }
            }
            LoweredInstr::Memset { dst, value } => {
                let value = self
                    .arena
                    .float_from_f64(value.get())
                    .expect("a Scalar is finite");
                for at in indices(instr, dst, &self.tensors)? {
                    writes.push(Write::at(dst, &at, value));
                }
            }
            LoweredInstr::Arith { op, dst, lhs, rhs } => {
                for at in indices(instr, dst, &self.tensors)? {
                    let a = self.read(instr, lhs, &at)?;
                    let b = self.read(instr, rhs, &at)?;
                    let value = self.arith(*op, a, b);
                    writes.push(Write::at(dst, &at, value));
                }
            }
            LoweredInstr::Activation { func, dst, data } => {
                for at in indices(instr, dst, &self.tensors)? {
                    let x = self.read(instr, data, &at)?;
                    let value = self.activation(*func, x);
                    writes.push(Write::at(dst, &at, value));
                }
            }
            LoweredInstr::ActivationReduce {
                func,
                dst,
                data,
                reduce_op,
                reduce_res,
            } => {
                let [partitions, free] = extents(dst);
                for partition in 0..partitions {
                    let mut values = Vec::new();
                    for element in 0..free {
                        let at = Index(vec![partition, element]);
                        let x = self.read(instr, data, &at)?;
                        let value = self.activation(*func, x);
                        writes.push(Write::at(dst, &at, value));
                        values.push(value);
                    }
                    let reduced = self.fold(*reduce_op, values);
                    writes.push(Write::at(reduce_res, &Index(vec![partition, 0]), reduced));
                }
            }
            LoweredInstr::Reduce { op, dst, data } => {
                let [partitions, free] = extents(data);
                for partition in 0..partitions {
                    let mut values = Vec::new();
                    for element in 0..free {
                        let at = Index(vec![partition, element]);
                        values.push(self.read(instr, data, &at)?);
                    }
                    let reduced = self.fold(*op, values);
                    writes.push(Write::at(dst, &Index(vec![partition, 0]), reduced));
                }
            }
            LoweredInstr::TensorScalar {
                dst,
                data,
                first,
                second,
            } => {
                for at in indices(instr, dst, &self.tensors)? {
                    let mut value = self.read(instr, data, &at)?;
                    for step in [Some(first), second.as_ref()].into_iter().flatten() {
                        let operand = self.scalar(instr, &step.operand, &at)?;
                        value = self.arith(step.op, value, operand);
                    }
                    writes.push(Write::at(dst, &at, value));
                }
            }
            LoweredInstr::Matmul {
                dst,
                stationary,
                moving,
            } => self.matmul(instr, dst, [stationary, moving], &mut writes)?,
            LoweredInstr::Transpose { dst, data } => {
                for at in indices(instr, data, &self.tensors)? {
                    let value = self.read(instr, data, &at)?;
                    writes.push(Write::at(dst, &at.transposed(), value));
                }
            }
        }
        Ok(writes)
    }

    /// The element of `region` at its local index `at`.
    fn read(
        &mut self,
        instr: InstrId,
        region: &TensorRegion,
        at: &Index,
    ) -> Result<ExprId, EvalError> {
        let index = region.start.shifted(at);
        self.tensors[region.tensor].read(&mut self.arena, instr, &index)
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
            ActivationFunc::Relu => {
                let zero = self.arena.int(0);
                self.arena.max(x, zero)
            }
            ActivationFunc::Square => self.arena.mul(x, x),
            ActivationFunc::Rsqrt => {
                let root = self.arena.sqrt(x);
                self.arena.rcp(root)
            }
            ActivationFunc::Exp => self.arena.exp(x),
            ActivationFunc::Reciprocal => self.arena.rcp(x),
        }
    }

    fn arith(&mut self, op: ArithOp, a: ExprId, b: ExprId) -> ExprId {
        match op {
            ArithOp::Add => self.arena.add(a, b),
            ArithOp::Subtract => self.arena.sub(a, b),
            ArithOp::Multiply => self.arena.mul(a, b),
            ArithOp::Maximum => self.arena.max(a, b),
        }
    }

    /// `op` folded left over `values`, seeded with the first rather than an identity,
    /// so a fold of `maximum` needs no `-inf`. A tile's free size is positive, so
    /// `values` is never empty.
    fn fold(&mut self, op: ArithOp, values: Vec<ExprId>) -> ExprId {
        let mut values = values.into_iter();
        let first = values.next().expect("a tile has a free element");
        values.fold(first, |accumulated, value| {
            self.arith(op, accumulated, value)
        })
    }

    /// The value a scalar operand contributes at the local index `at`: a literal, or
    /// the operand region's single free element in `at`'s partition.
    fn scalar(
        &mut self,
        instr: InstrId,
        operand: &ScalarOperand,
        at: &Index,
    ) -> Result<ExprId, EvalError> {
        match operand {
            ScalarOperand::Constant(value) => Ok(self
                .arena
                .float_from_f64(value.get())
                .expect("a Scalar is finite")),
            ScalarOperand::Broadcast(tile) => self.read(instr, tile, &Index(vec![at.0[0], 0])),
        }
    }

    /// Each `dst[row, column]` as the sum over `k` of `stationary[k, row] * moving[k, column]`.
    /// With `nc_matmul`'s default `accumulate=None`, a PSUM element's first write overwrites
    /// it and later ones accumulate. `dst` is in PSUM and the operands in SBUF, so none alias.
    fn matmul(
        &mut self,
        instr: InstrId,
        dst: &TensorRegion,
        [stationary, moving]: [&TensorRegion; 2],
        writes: &mut Vec<Write>,
    ) -> Result<(), EvalError> {
        let [contraction, rows] = extents(stationary);
        let [_, columns] = extents(moving);
        for row in 0..rows {
            for column in 0..columns {
                let at = Index(vec![row, column]);
                let mut sum = match self.tensors[dst.tensor].written(&dst.start.shifted(&at)) {
                    Some(earlier) => earlier,
                    None => self.arena.int(0),
                };
                for k in 0..contraction {
                    let a = self.read(instr, stationary, &Index(vec![k, row]))?;
                    let b = self.read(instr, moving, &Index(vec![k, column]))?;
                    let product = self.arena.mul(a, b);
                    sum = self.arena.add(sum, product);
                }
                writes.push(Write::at(dst, &at, sum));
            }
        }
        Ok(())
    }

    fn into_outputs(self, outputs: &[TensorId]) -> SymbolicOutputs {
        let outputs = outputs
            .iter()
            .map(|&output| {
                let tensor = &self.tensors[output];
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

/// One element an instruction writes, by its index in the whole tensor.
struct Write {
    tensor: TensorId,
    index: Index,
    value: ExprId,
}

impl Write {
    /// `value` written to `region`'s element at its local index `at`.
    fn at(region: &TensorRegion, at: &Index, value: ExprId) -> Self {
        Self {
            tensor: region.tensor,
            index: region.start.shifted(at),
            value,
        }
    }
}

/// A tile region's `[partitions, free]` extents: lowering makes every tile operand
/// a two-dimensional region of an on-chip tile.
fn extents(region: &TensorRegion) -> [u64; 2] {
    let [partitions, free] = region.shape.0[..] else {
        unreachable!("a tile region has two dimensions, not {}", region.shape);
    };
    [partitions, free]
}

/// The local indices of `region` in row-major order; its element count must fit in a `u64`.
fn indices<'r>(
    instr: InstrId,
    region: &'r TensorRegion,
    tensors: &IdVec<TensorId, TensorState<'_>>,
) -> Result<impl Iterator<Item = Index> + use<'r>, EvalError> {
    if region.shape.element_count().is_none() {
        return Err(EvalError::ElementCountOverflow {
            instr,
            tensor: tensors[region.tensor].name().to_owned(),
        });
    }
    Ok(region.shape.indices())
}
