//! The interpreter: a lowered kernel's instructions in order, each over the indices
//! of its operands, with values as expressions of an `ExprArena`.
//! Arguments are laid out row-major in HBM, so their symbols and outputs use offsets.

use id_collections::IdVec;
use volta_expr::{ExprArena, ExprId, Real, SymbolicOutputs};

use crate::ir::{
    Accumulation, ActivationFunc, ArithOp, Index, InstrId, LoweredInstr, LoweredKernel, Order,
    Reduction, ScalarOperand, Sign, TensorId, TensorRegion,
};

use super::EvalError;
use super::alias;
use super::tensor::{Clobber, TensorState};

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
    /// Each tensor's aliases: the tiles `address=` places over its bytes.
    aliases: IdVec<TensorId, Vec<TensorId>>,
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
            aliases: alias::aliases(&kernel.tensors),
        }
    }

    fn step(&mut self, instr: InstrId, instruction: &LoweredInstr) -> Result<(), EvalError> {
        for Write {
            tensor,
            index,
            value,
        } in self.writes(instr, instruction)?
        {
            let tile = self.tensors[tensor].tensor();
            if let Some((partition, bytes)) = alias::element_bytes(tile, &index) {
                for &other in &self.aliases[tensor] {
                    for clobbered in
                        alias::overlapping(self.tensors[other].tensor(), partition, &bytes)
                    {
                        let through = tile.name.clone();
                        self.tensors[other].clobber(clobbered, Clobber { instr, through });
                    }
                }
            }
            self.tensors[tensor].write(index, value);
        }
        Ok(())
    }

    /// The elements `instruction` writes, every operand read before any is written.
    /// A copy's regions have one shape once indexed dimensions are dropped, so their
    /// row-major orders pair their elements; every other instruction works on its tile
    /// regions' `[partitions, free]` views, and an elementwise one's views coincide.
    fn writes(
        &mut self,
        instr: InstrId,
        instruction: &LoweredInstr,
    ) -> Result<Vec<Write>, EvalError> {
        let mut writes = Vec::new();
        match instruction {
            LoweredInstr::Mov { dst, src } => {
                let pairs = indices(instr, dst, &self.tensors)?.zip(src.shape.indices());
                for (to, from) in pairs {
                    let value = self.tensors[src.tensor].read(
                        &mut self.arena,
                        instr,
                        &src.element(&from),
                    )?;
                    writes.push(Write {
                        tensor: dst.tensor,
                        index: dst.element(&to),
                        value,
                    });
                }
            }
            LoweredInstr::Memset { dst, value } => {
                let value = self
                    .arena
                    .float_from_f64(value.get())
                    .expect("a Scalar is finite");
                for [p, f] in elements(dst) {
                    writes.push(Write::at(dst, [p, f], value));
                }
            }
            LoweredInstr::Arith { op, dst, lhs, rhs } => {
                for at in elements(dst) {
                    let a = self.read(instr, lhs, at)?;
                    let b = self.read(instr, rhs, at)?;
                    let value = self.arith(*op, a, b);
                    writes.push(Write::at(dst, at, value));
                }
            }
            LoweredInstr::Activation {
                func,
                dst,
                data,
                scale,
                bias,
                reduce,
            } => {
                let [partitions, free] = dst.tile_extents();
                for partition in 0..partitions {
                    let mut row = Vec::new();
                    for element in 0..free {
                        let at = [partition, element];
                        let mut x = self.read(instr, data, at)?;
                        if let Some(scale) = scale {
                            let scale = self.scalar(instr, scale, at)?;
                            x = self.arith(ArithOp::Multiply, x, scale);
                        }
                        if let Some(bias) = bias {
                            let bias = self.scalar(instr, bias, at)?;
                            x = self.arith(ArithOp::Add, x, bias);
                        }
                        let value = self.activation(*func, x);
                        writes.push(Write::at(dst, at, value));
                        row.push(value);
                    }
                    writes.extend(self.reduce_row(reduce.as_ref(), partition, row));
                }
            }
            LoweredInstr::Reduce {
                op,
                dst,
                data,
                sign,
            } => {
                let [_, free] = data.tile_extents();
                let [_, results] = dst.tile_extents();
                let inner = free / results;
                for [partition, result] in elements(dst) {
                    let mut values = Vec::new();
                    for element in result * inner..(result + 1) * inner {
                        values.push(self.read(instr, data, [partition, element])?);
                    }
                    let mut reduced = self.fold(*op, values);
                    if *sign == Sign::Negated {
                        reduced = self.arena.neg(reduced);
                    }
                    writes.push(Write::at(dst, [partition, result], reduced));
                }
            }
            LoweredInstr::TensorScalar {
                dst,
                data,
                first,
                second,
                reduce,
            } => {
                let [partitions, free] = dst.tile_extents();
                for partition in 0..partitions {
                    let mut row = Vec::new();
                    for element in 0..free {
                        let at = [partition, element];
                        let mut value = self.read(instr, data, at)?;
                        for step in [Some(first), second.as_ref()].into_iter().flatten() {
                            let operand = self.scalar(instr, &step.operand, at)?;
                            value = self.arith(step.op, value, operand);
                        }
                        writes.push(Write::at(dst, at, value));
                        row.push(value);
                    }
                    writes.extend(self.reduce_row(reduce.as_ref(), partition, row));
                }
            }
            LoweredInstr::Scan {
                dst,
                data0,
                data1,
                initial,
                op0,
                op1,
            } => {
                let [partitions, free] = dst.tile_extents();
                for partition in 0..partitions {
                    let mut acc = self.scalar(instr, initial, [partition, 0])?;
                    for element in 0..free {
                        let at = [partition, element];
                        let a = self.read(instr, data0, at)?;
                        let b = self.read(instr, data1, at)?;
                        let step = self.ordered(*op0, a, acc);
                        acc = self.ordered(*op1, step, b);
                        writes.push(Write::at(dst, at, acc));
                    }
                }
            }
            LoweredInstr::Matmul {
                dst,
                stationary,
                moving,
                accumulation,
            } => self.matmul(instr, dst, [stationary, moving], *accumulation, &mut writes)?,
            LoweredInstr::Transpose { dst, data } => {
                for [p, f] in elements(data) {
                    let value = self.read(instr, data, [p, f])?;
                    writes.push(Write::at(dst, [f, p], value));
                }
            }
        }
        Ok(writes)
    }

    /// The element at `[partition, free]` of the tile region's view.
    fn read(
        &mut self,
        instr: InstrId,
        region: &TensorRegion,
        [partition, free]: [u64; 2],
    ) -> Result<ExprId, EvalError> {
        let index = region.tile_index(partition, free);
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

    /// `op(first, second)`, or `op(second, first)` if `order` reverses it.
    fn ordered(&mut self, (op, order): (ArithOp, Order), first: ExprId, second: ExprId) -> ExprId {
        match order {
            Order::Given => self.arith(op, first, second),
            Order::Reversed => self.arith(op, second, first),
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

    /// The write of `reduction`'s result for one partition's `row` of an instruction's
    /// result, if it has one.
    fn reduce_row(
        &mut self,
        reduction: Option<&Reduction>,
        partition: u64,
        row: Vec<ExprId>,
    ) -> Option<Write> {
        let Reduction { op, res } = reduction?;
        let reduced = self.fold(*op, row);
        Some(Write::at(res, [partition, 0], reduced))
    }

    /// The value a scalar operand contributes at `[partition, _]`: a literal, or the
    /// operand region's single element in that partition.
    fn scalar(
        &mut self,
        instr: InstrId,
        operand: &ScalarOperand,
        [partition, _]: [u64; 2],
    ) -> Result<ExprId, EvalError> {
        match operand {
            ScalarOperand::Constant(value) => Ok(self
                .arena
                .float_from_f64(value.get())
                .expect("a Scalar is finite")),
            ScalarOperand::Broadcast(tile) => self.read(instr, tile, [partition, 0]),
        }
    }

    /// Each `dst[row, column]` as the sum over `k` of `stationary[k, row] * moving[k, column]`,
    /// added to the element's value as `accumulation` says. `dst` is in PSUM and the
    /// operands in SBUF, so none alias.
    fn matmul(
        &mut self,
        instr: InstrId,
        dst: &TensorRegion,
        [stationary, moving]: [&TensorRegion; 2],
        accumulation: Accumulation,
        writes: &mut Vec<Write>,
    ) -> Result<(), EvalError> {
        let [contraction, rows] = stationary.tile_extents();
        let [_, columns] = moving.tile_extents();
        for row in 0..rows {
            for column in 0..columns {
                let index = dst.tile_index(row, column);
                let earlier = match accumulation {
                    Accumulation::Overwrite => None,
                    Accumulation::FirstOverwrites => {
                        self.tensors[dst.tensor].written(instr, &index)?
                    }
                    Accumulation::Accumulate => {
                        Some(self.tensors[dst.tensor].read(&mut self.arena, instr, &index)?)
                    }
                };
                let mut sum = match earlier {
                    Some(earlier) => earlier,
                    None => self.arena.int(0),
                };
                for k in 0..contraction {
                    let a = self.read(instr, stationary, [k, row])?;
                    let b = self.read(instr, moving, [k, column])?;
                    let product = self.arena.mul(a, b);
                    sum = self.arena.add(sum, product);
                }
                writes.push(Write::at(dst, [row, column], sum));
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
    /// `value` written at `[partition, free]` of the tile region's view.
    fn at(region: &TensorRegion, [partition, free]: [u64; 2], value: ExprId) -> Self {
        Self {
            tensor: region.tensor,
            index: region.tile_index(partition, free),
            value,
        }
    }
}

/// Every `[partition, free]` position of a tile region's view, partition-major.
fn elements(region: &TensorRegion) -> impl Iterator<Item = [u64; 2]> {
    let [partitions, free] = region.tile_extents();
    (0..partitions).flat_map(move |partition| (0..free).map(move |element| [partition, element]))
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
