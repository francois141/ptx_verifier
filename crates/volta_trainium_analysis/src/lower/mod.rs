//! Lowering a parsed NKI kernel into its tensors and the instructions over them.
//! A parameter's shape is the call's, which the parser records; a declared
//! tensor's is its declaration's.

mod error;

use std::collections::BTreeMap;

use id_collections::IdVec;

use crate::frontend::ast::{
    Buffer, Instruction, Kernel, Operand, RegionProblem, Scalar, Selected, Statement, TensorName,
    resolve_region,
};
use crate::ir::{
    ActivationFunc, ArithOp, Index, Initial, LoweredInstr, LoweredKernel, Memory, ScalarOperand,
    ScalarStep, Selection, Shape, Tensor, TensorId, TensorRegion,
};

pub use error::{LowerError, StatementError};

const NKI_LANGUAGE: &str = "nki.language";

/// Lower `kernel` into its tensors, the parameters first and then the declared
/// tensors in declaration order, its instructions in order, and the tensor it returns.
pub fn lower_kernel(kernel: &Kernel) -> Result<LoweredKernel, LowerError> {
    let mut scope = Scope::default();
    let params = kernel
        .params
        .iter()
        .map(|param| {
            let shape = Shape(param.shape.iter().map(|extent| extent.get()).collect());
            scope.add(param.name.clone(), Memory::Hbm, shape, Initial::Argument)
        })
        .collect();

    let mut instructions = Vec::new();
    for (index, statement) in kernel.body.iter().enumerate() {
        let at = |error| LowerError::Statement { index, error };
        match statement {
            Statement::Declare(tile) => {
                let shape = Shape(tile.shape.extents());
                if shape.element_count().is_none() {
                    return Err(at(StatementError::ElementCountOverflow(tile.name.clone())));
                }
                let memory = memory(tile.buffer);
                scope.add(tile.name.clone(), memory, shape, Initial::Uninitialized);
            }
            Statement::DeclareHbm(tensor) => {
                let shape = Shape(tensor.shape.iter().map(|extent| extent.get()).collect());
                let name = tensor.name.clone();
                scope.add(name, Memory::Hbm, shape, Initial::Uninitialized);
            }
            Statement::Instruction(instruction) => {
                instructions.push(lower_instruction(instruction, &scope).map_err(at)?);
            }
        }
    }

    let returned = kernel
        .returned
        .as_ref()
        .map(|tensor| scope.returned(tensor))
        .transpose()?;

    Ok(LoweredKernel {
        name: kernel.name.clone(),
        params,
        tensors: scope.into_tensors(),
        instructions: IdVec::from_vec(instructions),
        returned,
    })
}

fn memory(buffer: Buffer) -> Memory {
    match buffer {
        Buffer::Sbuf => Memory::Sbuf,
        Buffer::Psum => Memory::Psum,
    }
}

fn lower_instruction(
    instruction: &Instruction,
    scope: &Scope,
) -> Result<LoweredInstr, StatementError> {
    match instruction.opcode.as_str() {
        // =====================================================================
        // Data Movement
        // =====================================================================
        "dma_copy" => {
            let [dst, src] = operands(instruction, &["dst", "src"])?;
            let [dst, src] = [scope.region(dst, "dst")?, scope.region(src, "src")?];
            same_shape(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.region,
                src: src.region,
            })
        }

        "tensor_copy" => {
            let [dst, src] = operands(instruction, &["dst", "src"])?;
            let [dst, src] = [scope.tile(dst, "dst")?, scope.tile(src, "src")?];
            same_shape(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.region,
                src: src.region,
            })
        }

        "memset" => {
            let [dst, value] = operands(instruction, &["dst", "value"])?;
            let dst = scope.tile(dst, "dst")?;
            let value = match value {
                Operand::Scalar(value) => *value,
                Operand::Int(value) => Scalar::new(*value as f64).expect("an integer is finite"),
                _ => return Err(StatementError::NotAScalar { keyword: "value" }),
            };
            Ok(LoweredInstr::Memset {
                dst: dst.region,
                value,
            })
        }

        // =====================================================================
        // Elementwise
        // =====================================================================
        "tensor_tensor" => {
            let [dst, data1, data2, op] = operands(instruction, &["dst", "data1", "data2", "op"])?;
            let op = arith_op(op)?;
            let [dst, lhs, rhs] = [
                scope.tile(dst, "dst")?,
                scope.tile(data1, "data1")?,
                scope.tile(data2, "data2")?,
            ];
            same_shape(&lhs, &rhs)?;
            same_shape(&dst, &lhs)?;
            Ok(LoweredInstr::Arith {
                op,
                dst: dst.region,
                lhs: lhs.region,
                rhs: rhs.region,
            })
        }

        "activation" => {
            let [dst, op, data] = operands(instruction, &["dst", "op", "data"])?;
            let func = activation_func(op)?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            Ok(LoweredInstr::Activation {
                func,
                dst: dst.region,
                data: data.region,
            })
        }

        "activation_reduce" => {
            let [dst, op, data, reduce_op, reduce_res] = operands(
                instruction,
                &["dst", "op", "data", "reduce_op", "reduce_res"],
            )?;
            let func = activation_func(op)?;
            let reduce_op = arith_op(reduce_op)?;
            let [dst, data, reduce_res] = [
                scope.tile(dst, "dst")?,
                scope.tile(data, "data")?,
                scope.tile(reduce_res, "reduce_res")?,
            ];
            same_shape(&dst, &data)?;
            let [partitions, _] = data.matrix()?;
            per_partition(&reduce_res, partitions)?;
            Ok(LoweredInstr::ActivationReduce {
                func,
                dst: dst.region,
                data: data.region,
                reduce_op,
                reduce_res: reduce_res.region,
            })
        }

        "reciprocal" => {
            let [dst, data] = operands(instruction, &["dst", "data"])?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            Ok(LoweredInstr::Activation {
                func: ActivationFunc::Reciprocal,
                dst: dst.region,
                data: data.region,
            })
        }

        "tensor_reduce" => {
            let [dst, data, op, axis] = operands(instruction, &["dst", "data", "op", "axis"])?;
            let op = arith_op(op)?;
            free_axis(axis)?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            let [partitions, _] = data.matrix()?;
            per_partition(&dst, partitions)?;
            Ok(LoweredInstr::Reduce {
                op,
                dst: dst.region,
                data: data.region,
            })
        }

        "tensor_scalar" => {
            let ([dst, data, op0, operand0], [op1, operand1]) = operands_with_optional(
                instruction,
                &["dst", "data", "op0", "operand0"],
                &["op1", "operand1"],
            )?;

            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            let [partitions, _] = dst.region.tile_extents();

            let first = scalar_step(op0, operand0, "operand0", partitions, scope)?;
            let second = match (op1, operand1) {
                (Some(op), Some(operand)) => {
                    Some(scalar_step(op, operand, "operand1", partitions, scope)?)
                }
                (None, None) => None,
                _ => {
                    return Err(StatementError::UnpairedOperands {
                        opcode: instruction.opcode.clone(),
                        keywords: ["op1", "operand1"],
                    });
                }
            };

            Ok(LoweredInstr::TensorScalar {
                dst: dst.region,
                data: data.region,
                first,
                second,
            })
        }

        // =====================================================================
        // Tensor Engine
        // =====================================================================
        "nc_matmul" => {
            let [dst, stationary, moving] =
                operands(instruction, &["dst", "stationary", "moving"])?;
            let [dst, stationary, moving] = [
                scope.tile(dst, "dst")?,
                scope.tile(stationary, "stationary")?,
                scope.tile(moving, "moving")?,
            ];
            stationary.in_memory(Memory::Sbuf)?;
            moving.in_memory(Memory::Sbuf)?;
            dst.in_memory(Memory::Psum)?;
            let [[contraction, rows], [moving_contraction, columns]] =
                [stationary.matrix()?, moving.matrix()?];
            if contraction != moving_contraction {
                return Err(StatementError::ContractionMismatch([
                    stationary.described(),
                    moving.described(),
                ]));
            }
            dst.matrix()?;
            result_shape(&dst, Shape(vec![rows, columns]))?;
            Ok(LoweredInstr::Matmul {
                dst: dst.region,
                stationary: stationary.region,
                moving: moving.region,
            })
        }

        "nc_transpose" => {
            let [dst, data] = operands(instruction, &["dst", "data"])?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            let [partitions, free] = data.matrix()?;
            dst.matrix()?;
            result_shape(&dst, Shape(vec![free, partitions]))?;
            Ok(LoweredInstr::Transpose {
                dst: dst.region,
                data: data.region,
            })
        }

        opcode => Err(StatementError::UnsupportedInstruction(opcode.into())),
    }
}

// =============================================================================
// Operands
// =============================================================================

/// The operands of `instruction` in the order of `keywords`, exactly its operand keywords.
fn operands<'a, const N: usize>(
    instruction: &'a Instruction,
    keywords: &'static [&'static str; N],
) -> Result<[&'a Operand; N], StatementError> {
    let given = &instruction.operands;
    if given.len() != N || !keywords.iter().all(|keyword| given.contains_key(*keyword)) {
        return Err(StatementError::Operands {
            opcode: instruction.opcode.clone(),
            keywords,
        });
    }
    Ok(keywords.map(|keyword| &given[keyword]))
}

/// The operands of `instruction`: every `required` keyword, and each `optional`
/// one if present. Any other keyword is an error.
fn operands_with_optional<'a, const R: usize, const O: usize>(
    instruction: &'a Instruction,
    required: &'static [&'static str; R],
    optional: &'static [&'static str; O],
) -> Result<([&'a Operand; R], [Option<&'a Operand>; O]), StatementError> {
    let given = &instruction.operands;
    let known = |keyword: &String| {
        required.contains(&keyword.as_str()) || optional.contains(&keyword.as_str())
    };
    if !required.iter().all(|keyword| given.contains_key(*keyword)) || !given.keys().all(known) {
        return Err(StatementError::Operands {
            opcode: instruction.opcode.clone(),
            keywords: required,
        });
    }
    Ok((
        required.map(|keyword| &given[keyword]),
        optional.map(|keyword| given.get(keyword)),
    ))
}

/// The name of a `nki.language` member, e.g. `add` for `nl.add`.
fn language_member(operand: &Operand) -> Option<&str> {
    let Operand::Member(member) = operand else {
        return None;
    };
    member.strip_prefix(NKI_LANGUAGE)?.strip_prefix('.')
}

/// A `nki.language` arithmetic function, e.g. `nl.add`.
fn arith_op(operand: &Operand) -> Result<ArithOp, StatementError> {
    let name = language_member(operand);
    ArithOp::ALL
        .into_iter()
        .find(|op| Some(op.name()) == name)
        .ok_or_else(|| StatementError::UnsupportedArithOp(operand.clone()))
}

/// A `nki.language` activation function, e.g. `nl.sigmoid`.
fn activation_func(operand: &Operand) -> Result<ActivationFunc, StatementError> {
    let name = language_member(operand);
    ActivationFunc::ALL
        .into_iter()
        .find(|func| Some(func.name()) == name)
        .ok_or_else(|| StatementError::UnsupportedActivation(operand.clone()))
}

/// A reduction's `axis`: a tile's one free axis, `1` or `(1,)`. Axis 0 is the
/// partition axis, which `nki.isa` reductions cannot reduce.
fn free_axis(axis: &Operand) -> Result<(), StatementError> {
    match axis {
        Operand::Int(1) => Ok(()),
        Operand::Ints(axes) if axes[..] == [1] => Ok(()),
        _ => Err(StatementError::UnsupportedAxis(axis.clone())),
    }
}

/// A `tensor_scalar` step: its `nki.language` op, and an operand that is a literal
/// or a tile region of one free element per partition of the destination.
fn scalar_step(
    op: &Operand,
    operand: &Operand,
    keyword: &'static str,
    partitions: u64,
    scope: &Scope,
) -> Result<ScalarStep, StatementError> {
    let op = arith_op(op)?;
    let operand = match operand {
        Operand::Scalar(value) => ScalarOperand::Constant(*value),
        _ => {
            let tile = scope.tile(operand, keyword)?;
            if tile.region.tile_extents() != [partitions, 1] {
                let (tensor, shape) = tile.described();
                return Err(StatementError::NotBroadcastable {
                    tensor,
                    shape,
                    expected: Shape(vec![partitions, 1]),
                });
            }
            ScalarOperand::Broadcast(tile.region)
        }
    };
    Ok(ScalarStep { op, operand })
}

// =============================================================================
// Operand Checks
// =============================================================================

/// Two operands that must name regions of one shape, their indexed dimensions dropped.
fn same_shape(left: &RegionOperand, right: &RegionOperand) -> Result<(), StatementError> {
    if left.kept == right.kept {
        return Ok(());
    }
    Err(StatementError::ShapeMismatch([
        left.described(),
        right.described(),
    ]))
}

/// Check that `dst` names a region of the shape `expected` of the instruction's result.
fn result_shape(dst: &RegionOperand, expected: Shape) -> Result<(), StatementError> {
    if dst.kept == expected {
        return Ok(());
    }
    let (tensor, shape) = dst.described();
    Err(StatementError::ResultShape {
        tensor,
        shape,
        expected,
    })
}

/// Check that the tile region `dst` holds one element per partition of `partitions`,
/// as a reduction's result: `t[:, 0:1]`, or `t[:, 0]` with its free dimension dropped.
fn per_partition(dst: &RegionOperand, partitions: u64) -> Result<(), StatementError> {
    if dst.region.tile_extents() == [partitions, 1] {
        return Ok(());
    }
    let (tensor, shape) = dst.described();
    Err(StatementError::ResultShape {
        tensor,
        shape,
        expected: Shape(vec![partitions, 1]),
    })
}

/// A tensor operand: a region of a tensor, the whole tensor if not subscripted.
struct RegionOperand<'a> {
    name: &'a TensorName,
    memory: Memory,
    region: TensorRegion,
    /// The region's shape with its indexed dimensions dropped, which shape rules compare.
    kept: Shape,
}

impl RegionOperand<'_> {
    /// Its `[rows, columns]` shape, for an instruction over tiles of one free dimension.
    fn matrix(&self) -> Result<[u64; 2], StatementError> {
        match self.kept.0[..] {
            [rows, columns] => Ok([rows, columns]),
            _ => Err(StatementError::NotAMatrix {
                tensor: self.name.clone(),
                shape: self.kept.clone(),
            }),
        }
    }

    fn in_memory(&self, expected: Memory) -> Result<(), StatementError> {
        if self.memory == expected {
            return Ok(());
        }
        Err(StatementError::WrongMemory {
            tensor: self.name.clone(),
            expected,
        })
    }

    /// Its tensor and the region's shape, for an error.
    fn described(&self) -> (TensorName, Shape) {
        (self.name.clone(), self.kept.clone())
    }
}

// =============================================================================
// Scope
// =============================================================================

struct Entry {
    name: TensorName,
    memory: Memory,
    shape: Shape,
    initial: Initial,
}

/// The tensors named so far. The parser guarantees every name a statement uses
/// is a parameter or an earlier tile, and that no name is declared twice.
#[derive(Default)]
struct Scope {
    ids: BTreeMap<TensorName, TensorId>,
    entries: IdVec<TensorId, Entry>,
}

impl Scope {
    fn add(
        &mut self,
        name: TensorName,
        memory: Memory,
        shape: Shape,
        initial: Initial,
    ) -> TensorId {
        let id = self.entries.push(Entry {
            name: name.clone(),
            memory,
            shape,
            initial,
        });
        self.ids.insert(name, id);
        id
    }

    /// Operand `keyword`, a tensor or a region of one: the whole tensor, or the
    /// subscript resolved against its shape.
    fn region(
        &self,
        operand: &Operand,
        keyword: &'static str,
    ) -> Result<RegionOperand<'_>, StatementError> {
        let (name, dims) = match operand {
            Operand::Tensor(name) => (name, [].as_slice()),
            Operand::Region { tensor, dims } => (tensor, dims.as_slice()),
            _ => return Err(StatementError::NotATensor { keyword }),
        };
        let id = self.ids[name];
        let entry = &self.entries[id];

        let selected = resolve_region(dims, &entry.shape.0).map_err(|problem| match problem {
            RegionProblem::TooManyIndices => StatementError::RegionRank {
                tensor: name.clone(),
                shape: entry.shape.clone(),
                indices: dims.len(),
            },
            RegionProblem::OutOfBounds { dimension } => StatementError::RegionBounds {
                tensor: name.clone(),
                dimension,
                extent: entry.shape.0[dimension],
            },
        })?;

        let (mut start, mut shape, mut selections, mut kept) = (vec![], vec![], vec![], vec![]);
        for selected in selected {
            match selected {
                Selected::Index(index) => {
                    start.push(index);
                    shape.push(1);
                    selections.push(Selection::Index);
                }
                Selected::Slice { start: low, extent } => {
                    start.push(low);
                    shape.push(extent);
                    selections.push(Selection::Slice);
                    kept.push(extent);
                }
            }
        }

        Ok(RegionOperand {
            name: &entry.name,
            memory: entry.memory,
            region: TensorRegion {
                tensor: id,
                start: Index(start),
                shape: Shape(shape),
                selections,
            },
            kept: Shape(kept),
        })
    }

    /// Operand `keyword`, a region of an on-chip tile that keeps its partition dimension.
    fn tile(
        &self,
        operand: &Operand,
        keyword: &'static str,
    ) -> Result<RegionOperand<'_>, StatementError> {
        let tile = self.region(operand, keyword)?;
        if !matches!(tile.memory, Memory::Sbuf | Memory::Psum) {
            return Err(StatementError::OffChip(tile.name.clone()));
        }
        if tile.region.selections[0] == Selection::Index {
            return Err(StatementError::PartitionIndexed(tile.name.clone()));
        }
        Ok(tile)
    }

    /// The tensor a kernel returns: one it allocates in HBM, not an argument or a tile.
    fn returned(&self, name: &TensorName) -> Result<TensorId, LowerError> {
        let id = self.ids[name];
        let entry = &self.entries[id];
        if (entry.memory, entry.initial) != (Memory::Hbm, Initial::Uninitialized) {
            return Err(LowerError::ReturnsUnallocated(name.clone()));
        }
        Ok(id)
    }

    fn into_tensors(self) -> IdVec<TensorId, Tensor> {
        self.entries.map(|_, entry| Tensor {
            name: entry.name.0,
            memory: entry.memory,
            shape: entry.shape,
            initial: entry.initial,
        })
    }
}
