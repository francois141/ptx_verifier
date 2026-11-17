//! The interpreter: a lowered kernel's instructions in order, each over the indices
//! of its operands, with values as expressions of an `ExprArena`.
//! Arguments are laid out row-major in HBM, so their symbols and outputs use offsets.

use std::collections::{HashMap, HashSet};

use id_collections::IdVec;
use volta_expr::FullOutputs;
use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, Real, Type};

use crate::ir::{
    Accumulation, ActivationFunc, ArithOp, Index, InstrId, LoweredInstr, LoweredKernel, MatmulPass,
    Order, Reduction, ScalarOperand, Sign, TensorId, TensorRegion,
};

use super::EvalError;
use super::alias;
use super::tensor::TensorState;

/// Run `kernel` and return, in parameter order, each argument it wrote, then the tensor it
/// returns, each with its written elements by offset. An unwritten argument element holds
/// its input symbol; any other unwritten element reads `Undefined`, an error only once an
/// output reaches it (as PTX's), since a kernel may evict a whole tile and refill its gaps.
pub fn evaluate(kernel: &LoweredKernel) -> Result<FullOutputs, EvalError> {
    run(kernel, AliasReads::Reject)
}

/// `evaluate`, but a read through a placed tile of bytes another tile wrote, element for
/// element, sees that value, as the shared memory does: a kernel whose allocator overlaps
/// two live tiles runs to the outputs the hardware would give, for a spec to refute.
pub fn evaluate_sharing_aliases(kernel: &LoweredKernel) -> Result<FullOutputs, EvalError> {
    run(kernel, AliasReads::Shared)
}

/// What a read through a placed tile sees of bytes a write through another tile covered.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum AliasReads {
    /// Nothing: the read is `EvalError::ClobberedRead`, so a kernel is checked only on
    /// values its own tiles wrote, and every overlap of live tiles is reported.
    Reject,
    /// The value written, where an element covers exactly the bytes written.
    Shared,
}

fn run(kernel: &LoweredKernel, alias_reads: AliasReads) -> Result<FullOutputs, EvalError> {
    let mut interp = Interpreter::new(kernel, alias_reads);
    for (instr, instruction) in kernel.instructions.iter() {
        interp.step(instr, instruction)?;
    }
    let outputs: Vec<TensorId> = kernel
        .params
        .iter()
        .copied()
        .chain(kernel.returned)
        .collect();
    let undefined_reads = std::mem::take(&mut interp.undefined_reads);
    let outputs = interp.into_outputs(&outputs);
    match first_undefined_reached(&outputs, &undefined_reads) {
        Some(read) => Err(read.clone()),
        None => Ok(outputs),
    }
}

/// The uninitialized read, among `reads`, of the first `Undefined` an output reaches.
fn first_undefined_reached<'r>(
    outputs: &FullOutputs,
    reads: &'r HashMap<ExprId, EvalError>,
) -> Option<&'r EvalError> {
    let mut seen = HashSet::new();
    let mut stack: Vec<ExprId> = outputs
        .outputs
        .iter()
        .flat_map(|(_, elements)| elements.iter().map(|&(_, root)| root))
        .collect();
    stack.reverse();
    while let Some(id) = stack.pop() {
        if !seen.insert(id) {
            continue;
        }
        if let Some(read) = reads.get(&id) {
            return Some(read);
        }
        outputs
            .arena
            .node(id)
            .for_each_child(|child| stack.push(child));
    }
    None
}

struct Interpreter<'a> {
    arena: ExprArena,
    tensors: IdVec<TensorId, TensorState<'a>>,
    /// Each tensor's aliases: the tiles `address=` places over its bytes.
    aliases: IdVec<TensorId, Vec<TensorId>>,
    alias_reads: AliasReads,
    /// Each `Undefined` an uninitialized read gave, and that read.
    undefined_reads: HashMap<ExprId, EvalError>,
}

impl<'a> Interpreter<'a> {
    fn new(kernel: &'a LoweredKernel, alias_reads: AliasReads) -> Self {
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
            alias_reads,
            undefined_reads: HashMap::new(),
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
                    let other_tile = self.tensors[other].tensor();
                    for aliased in alias::overlapping(other_tile, partition, &bytes) {
                        // Sharing aliases, an element over exactly these bytes now holds the
                        // value written, as the hardware's memory does; otherwise it is clobbered.
                        let exact = alias::element_bytes(other_tile, &aliased)
                            == Some((partition, bytes.clone()));
                        if exact && self.alias_reads == AliasReads::Shared {
                            self.tensors[other].write(aliased, value);
                        } else {
                            let through = tile.name.clone();
                            self.tensors[other].clobber(aliased, instr, through);
                        }
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
            LoweredInstr::Mov { dst, src, .. } => {
                let pairs = indices(instr, dst, &self.tensors)?.zip(src.shape.indices());
                for (to, from) in pairs {
                    let value = self.element(instr, src.tensor, &src.element(&from))?;
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
            LoweredInstr::Identity { dst } => {
                for [p, f] in elements(dst) {
                    let value = self.arena.int(i64::from(p == f));
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
                        reduced = self.arena.neg(Type::Real, reduced);
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
                            value = self.ordered((step.op, step.order), value, operand);
                        }
                        writes.push(Write::at(dst, at, value));
                        row.push(value);
                    }
                    writes.extend(self.reduce_row(reduce.as_ref(), partition, row));
                }
            }
            LoweredInstr::ScalarTensorTensor {
                dst,
                data,
                op0,
                operand0,
                op1,
                operand1,
                reduce,
            } => {
                let [partitions, free] = dst.tile_extents();
                for partition in 0..partitions {
                    let mut row = Vec::new();
                    for element in 0..free {
                        let at = [partition, element];
                        let x = self.read(instr, data, at)?;
                        let scalar = self.scalar(instr, operand0, at)?;
                        let step = self.ordered(*op0, x, scalar);
                        let other = self.read(instr, operand1, at)?;
                        let value = self.ordered(*op1, step, other);
                        writes.push(Write::at(dst, at, value));
                        row.push(value);
                    }
                    writes.extend(self.reduce_row(reduce.as_ref(), partition, row));
                }
            }
            LoweredInstr::PartitionReduce { op, dst, data } => {
                let [partitions, free] = data.tile_extents();
                for element in 0..free {
                    let mut values = Vec::new();
                    for partition in 0..partitions {
                        values.push(self.read(instr, data, [partition, element])?);
                    }
                    let reduced = self.fold(*op, values);
                    writes.push(Write::at(dst, [0, element], reduced));
                }
            }
            LoweredInstr::Cumulative {
                dst,
                src,
                op0,
                imm0,
                op1,
                initial,
            } => {
                let [partitions, free] = dst.tile_extents();
                for partition in 0..partitions {
                    let mut acc = match initial {
                        Some(initial) => Some(self.scalar(instr, initial, [partition, 0])?),
                        None => None,
                    };
                    for element in 0..free {
                        let at = [partition, element];
                        let x = self.read(instr, src, at)?;
                        let imm = self.scalar(instr, &ScalarOperand::Constant(*imm0), at)?;
                        let step = self.arith(*op0, x, imm);
                        // `op1(step, identity)` is `step` for every op the docs allow.
                        let value = match acc {
                            None => step,
                            Some(acc) => self.arith(*op1, step, acc),
                        };
                        acc = Some(value);
                        writes.push(Write::at(dst, at, value));
                    }
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
                pass,
            } => {
                if *pass == MatmulPass::Transpose {
                    self.identity(instr, moving)?;
                }
                self.matmul(instr, dst, [stationary, moving], *accumulation, &mut writes)?
            }
            LoweredInstr::Gather { dst, data, index } => {
                for [partition, column] in elements(dst) {
                    let docs = self.offset(instr, index, data, [0, column])?;
                    let group = self.offset(instr, index, data, [partition, column])?;
                    if docs != group {
                        return Err(EvalError::IndirectReadings {
                            instr,
                            partition,
                            column,
                            offsets: [docs, group],
                        });
                    }
                    let value = self.read(instr, data, [partition, docs])?;
                    writes.push(Write::at(dst, [partition, column], value));
                }
            }
            LoweredInstr::Transpose { dst, data, .. } => {
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
        self.element(instr, region.tensor, &index)
    }

    /// The element at `index` of `tensor`: an uninitialized one is a fresh `Undefined`.
    fn element(
        &mut self,
        instr: InstrId,
        tensor: TensorId,
        index: &Index,
    ) -> Result<ExprId, EvalError> {
        match self.tensors[tensor].read(&mut self.arena, instr, index) {
            Err(read @ EvalError::UninitializedRead { .. }) => {
                let undefined = self.arena.undefined();
                self.undefined_reads.insert(undefined, read);
                Ok(undefined)
            }
            value => value,
        }
    }

    /// The offset into `data`'s free dimension that gathered `column` of `partition`
    /// reads: element `[group + column % 16, column / 16]` of `index`, `group` the first
    /// partition of `partition`'s 16-partition group.
    fn offset(
        &mut self,
        instr: InstrId,
        index: &TensorRegion,
        data: &TensorRegion,
        [partition, column]: [u64; 2],
    ) -> Result<u64, EvalError> {
        const GROUP: u64 = 16;
        let row = partition - partition % GROUP + column % GROUP;
        let value = self.read(instr, index, [row, column / GROUP])?;
        let [_, extent] = data.tile_extents();
        let offset = match self.arena.value_node(value) {
            ExprNode::IntConst(value) => u64::try_from(*value).ok(),
            ExprNode::RealConst(value) => {
                let rounded = value.to_f64();
                let exact = Real::from_f64(rounded).is_ok_and(|exact| exact == *value);
                (exact && rounded.fract() == 0.0 && rounded >= 0.0).then_some(rounded as u64)
            }
            _ => None,
        };
        match offset {
            Some(offset) if offset < extent => Ok(offset),
            _ => Err(EvalError::IndirectOffset {
                instr,
                tensor: self.tensors[index.tensor].name().to_string(),
                index: index.tile_index(row, column / GROUP),
                extent,
            }),
        }
    }

    fn activation(&mut self, func: ActivationFunc, x: ExprId) -> ExprId {
        match func {
            ActivationFunc::Sigmoid => self.arena.sigmoid(Type::Real, x),
            ActivationFunc::Relu => {
                let zero = self.arena.int(0);
                self.arena.max(Type::Real, x, zero)
            }
            ActivationFunc::Square => self.arena.mul(Type::Real, x, x),
            ActivationFunc::Rsqrt => self.arena.rsqrt(Type::Real, x),
            ActivationFunc::Exp => self.arena.exp(Type::Real, x),
            ActivationFunc::Copy => x,
            ActivationFunc::Sqrt => self.arena.sqrt(Type::Real, x),
            ActivationFunc::Abs => self.arena.abs(Type::Real, x),
            ActivationFunc::Reciprocal => self.arena.rcp(Type::Real, x),
        }
    }

    fn arith(&mut self, op: ArithOp, a: ExprId, b: ExprId) -> ExprId {
        match op {
            ArithOp::Add => self.arena.add(Type::Real, a, b),
            ArithOp::Subtract => self.arena.sub(Type::Real, a, b),
            ArithOp::Multiply => self.arena.mul(Type::Real, a, b),
            ArithOp::Maximum => self.arena.max(Type::Real, a, b),
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
    /// Check that `region`'s `[partitions, free]` view holds the concrete identity.
    fn identity(&mut self, instr: InstrId, region: &TensorRegion) -> Result<(), EvalError> {
        for [p, f] in elements(region) {
            let value = self.read(instr, region, [p, f])?;
            let expected = Real::from_i64(i64::from(p == f));
            let holds = match self.arena.node(value) {
                ExprNode::IntConst(value) => Real::from_i64(*value) == expected,
                ExprNode::RealConst(value) => *value == expected,
                _ => false,
            };
            if !holds {
                return Err(EvalError::NotIdentity {
                    instr,
                    tensor: self.tensors[region.tensor].name().to_owned(),
                    index: region.tile_index(p, f),
                });
            }
        }
        Ok(())
    }

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
                    Accumulation::Accumulate => Some(self.element(instr, dst.tensor, &index)?),
                };
                let mut sum = match earlier {
                    Some(earlier) => earlier,
                    None => self.arena.int(0),
                };
                for k in 0..contraction {
                    let a = self.read(instr, stationary, [k, row])?;
                    let b = self.read(instr, moving, [k, column])?;
                    let product = self.arena.mul(Type::Real, a, b);
                    sum = self.arena.add(Type::Real, sum, product);
                }
                writes.push(Write::at(dst, [row, column], sum));
            }
        }
        Ok(())
    }

    fn into_outputs(self, outputs: &[TensorId]) -> FullOutputs {
        let outputs = outputs
            .iter()
            .map(|&output| {
                let tensor = &self.tensors[output];
                (tensor.name().to_owned(), tensor.written_by_offset())
            })
            .filter(|(_, elements)| !elements.is_empty())
            .collect();
        FullOutputs {
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
