//! Lowering a parsed NKI kernel into its tensors and the instructions over them.
//! A parameter's shape is the call's, which the parser records; a declared
//! tensor's is its declaration's.

mod error;

use std::collections::BTreeMap;

use id_collections::IdVec;

use crate::frontend::ast::{Buffer, Instruction, Kernel, Operand, Scalar, Statement, TensorName};
use crate::ir::{
    ActivationFunc, ArithOp, Index, Initial, LoweredInstr, LoweredKernel, Memory, ScalarOperand,
    ScalarStep, Shape, Tensor, TensorId, TensorRegion,
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
                let shape = vec![
                    u64::from(tile.shape.partitions.get()),
                    tile.shape.free.get(),
                ];
                let memory = memory(tile.buffer);
                scope.add(
                    tile.name.clone(),
                    memory,
                    Shape(shape),
                    Initial::Uninitialized,
                );
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
            let [partitions, _] = dst.extents()?;
            result_shape(&reduce_res, Shape(vec![partitions, 1]))?;
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
            let [partitions, _] = data.extents()?;
            result_shape(&dst, Shape(vec![partitions, 1]))?;
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
            let [partitions, _] = dst.extents()?;

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
                [stationary.extents()?, moving.extents()?];
            if contraction != moving_contraction {
                return Err(StatementError::ContractionMismatch([
                    stationary.described(),
                    moving.described(),
                ]));
            }
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
            let [partitions, free] = data.extents()?;
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
            let expected = Shape(vec![partitions, 1]);
            if tile.region.shape != expected {
                let (tensor, shape) = tile.described();
                return Err(StatementError::NotBroadcastable {
                    tensor,
                    shape,
                    expected,
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

/// Two operands that must name regions of one shape.
fn same_shape(left: &RegionOperand, right: &RegionOperand) -> Result<(), StatementError> {
    if left.region.shape == right.region.shape {
        return Ok(());
    }
    Err(StatementError::ShapeMismatch([
        left.described(),
        right.described(),
    ]))
}

/// Check that `dst` names a region of the shape `expected` of the instruction's result.
fn result_shape(dst: &RegionOperand, expected: Shape) -> Result<(), StatementError> {
    if dst.region.shape == expected {
        return Ok(());
    }
    let (tensor, shape) = dst.described();
    Err(StatementError::ResultShape {
        tensor,
        shape,
        expected,
    })
}

/// A tensor operand: a region of a tensor, the whole tensor if not subscripted.
struct RegionOperand<'a> {
    name: &'a TensorName,
    memory: Memory,
    region: TensorRegion,
}

impl RegionOperand<'_> {
    /// The region's `[partitions, free]` extents, if it is a region of an on-chip
    /// tile; every SBUF and PSUM tensor is a two-dimensional tile.
    fn extents(&self) -> Result<[u64; 2], StatementError> {
        match (self.memory, &self.region.shape.0[..]) {
            (Memory::Sbuf | Memory::Psum, &[partitions, free]) => Ok([partitions, free]),
            _ => Err(StatementError::OffChip(self.name.clone())),
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
        (self.name.clone(), self.region.shape.clone())
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
    /// subscript's slices resolved against its shape.
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
        let extents = entry.shape.0.as_slice();

        let region = if dims.is_empty() {
            TensorRegion {
                tensor: id,
                start: Index(vec![0; extents.len()]),
                shape: entry.shape.clone(),
            }
        } else {
            if dims.len() != extents.len() {
                return Err(StatementError::RegionRank {
                    tensor: name.clone(),
                    shape: entry.shape.clone(),
                    slices: dims.len(),
                });
            }
            let mut start = Vec::new();
            let mut shape = Vec::new();
            for (dimension, (bounds, &extent)) in dims.iter().zip(extents).enumerate() {
                let low = bounds.start.unwrap_or(0);
                let high = bounds.stop.unwrap_or(extent);
                if low >= high || high > extent {
                    return Err(StatementError::RegionBounds {
                        tensor: name.clone(),
                        dimension,
                        extent,
                    });
                }
                start.push(low);
                shape.push(high - low);
            }
            TensorRegion {
                tensor: id,
                start: Index(start),
                shape: Shape(shape),
            }
        };

        Ok(RegionOperand {
            name: &entry.name,
            memory: entry.memory,
            region,
        })
    }

    /// Operand `keyword`, a region of an on-chip tile.
    fn tile(
        &self,
        operand: &Operand,
        keyword: &'static str,
    ) -> Result<RegionOperand<'_>, StatementError> {
        let tile = self.region(operand, keyword)?;
        tile.extents()?;
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
