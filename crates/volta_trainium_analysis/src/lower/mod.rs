//! Lowering a parsed NKI kernel into its tensors and the instructions over them.
//! A parameter's shape is the one its `assert` binds, which must precede the
//! parameter's first use as an operand.

mod error;

use std::collections::BTreeMap;

use id_collections::IdVec;

use crate::frontend::ast::{Buffer, Instruction, Kernel, Operand, Statement, TensorName};
use crate::ir::{
    ActivationFunc, ArithOp, LoweredInstr, LoweredKernel, Memory, Shape, Tensor, TensorId,
};

pub use error::{LowerError, StatementError};

const NKI_LANGUAGE: &str = "nki.language";

/// Lower `kernel` into its tensors, the parameters first and then the tiles in
/// declaration order, and its instructions in order.
pub fn lower_kernel(kernel: &Kernel) -> Result<LoweredKernel, LowerError> {
    let mut scope = Scope::default();
    let params = kernel
        .params
        .iter()
        .map(|param| scope.add(param.clone(), Memory::Hbm, None))
        .collect();

    let mut instructions = Vec::new();
    for (index, statement) in kernel.body.iter().enumerate() {
        let at = |error| LowerError::Statement { index, error };
        match statement {
            Statement::AssertShape { tensor, shape } => {
                scope
                    .assert_shape(tensor, Shape(shape.clone()))
                    .map_err(at)?;
            }
            Statement::Declare(tile) => {
                let shape = vec![
                    u64::from(tile.shape.partitions.get()),
                    tile.shape.free.get(),
                ];
                scope.add(tile.name.clone(), memory(tile.buffer), Some(Shape(shape)));
            }
            Statement::Instruction(instruction) => {
                instructions.push(lower_instruction(instruction, &scope).map_err(at)?);
            }
        }
    }

    Ok(LoweredKernel {
        name: kernel.name.clone(),
        params,
        tensors: scope.into_tensors()?,
        instructions: IdVec::from_vec(instructions),
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
            let [dst, src] = [scope.shaped(dst, "dst")?, scope.shaped(src, "src")?];
            same_shape(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.id,
                src: src.id,
            })
        }

        "tensor_copy" => {
            let [dst, src] = operands(instruction, &["dst", "src"])?;
            let [dst, src] = [scope.shaped(dst, "dst")?, scope.shaped(src, "src")?];
            for tile in [&dst, &src] {
                tile_extents(tile)?;
            }
            same_shape(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.id,
                src: src.id,
            })
        }

        // =====================================================================
        // Elementwise
        // =====================================================================
        "tensor_tensor" => {
            let [dst, data1, data2, op] = operands(instruction, &["dst", "data1", "data2", "op"])?;
            let op = arith_op(op)?;
            let [dst, lhs, rhs] = [
                scope.shaped(dst, "dst")?,
                scope.shaped(data1, "data1")?,
                scope.shaped(data2, "data2")?,
            ];
            for tile in [&dst, &lhs, &rhs] {
                tile_extents(tile)?;
            }
            same_shape(&lhs, &rhs)?;
            same_shape(&dst, &lhs)?;
            Ok(LoweredInstr::Arith {
                op,
                dst: dst.id,
                lhs: lhs.id,
                rhs: rhs.id,
            })
        }

        "activation" => {
            let [dst, op, data] = operands(instruction, &["dst", "op", "data"])?;
            let func = activation_func(op)?;
            let [dst, data] = [scope.shaped(dst, "dst")?, scope.shaped(data, "data")?];
            for tile in [&dst, &data] {
                tile_extents(tile)?;
            }
            same_shape(&dst, &data)?;
            Ok(LoweredInstr::Activation {
                func,
                dst: dst.id,
                data: data.id,
            })
        }

        // =====================================================================
        // Tensor Engine
        // =====================================================================
        "nc_matmul" => {
            let [dst, stationary, moving] =
                operands(instruction, &["dst", "stationary", "moving"])?;
            let [dst, stationary, moving] = [
                scope.shaped(dst, "dst")?,
                scope.shaped(stationary, "stationary")?,
                scope.shaped(moving, "moving")?,
            ];
            in_memory(&stationary, Memory::Sbuf)?;
            in_memory(&moving, Memory::Sbuf)?;
            in_memory(&dst, Memory::Psum)?;
            let [[contraction, rows], [moving_contraction, columns]] =
                [tile_extents(&stationary)?, tile_extents(&moving)?];
            if contraction != moving_contraction {
                return Err(StatementError::ContractionMismatch([
                    (stationary.name.clone(), stationary.shape.clone()),
                    (moving.name.clone(), moving.shape.clone()),
                ]));
            }
            result_shape(&dst, Shape(vec![rows, columns]))?;
            Ok(LoweredInstr::Matmul {
                dst: dst.id,
                stationary: stationary.id,
                moving: moving.id,
            })
        }

        "nc_transpose" => {
            let [dst, data] = operands(instruction, &["dst", "data"])?;
            let [dst, data] = [scope.shaped(dst, "dst")?, scope.shaped(data, "data")?];
            tile_extents(&dst)?;
            let [partitions, free] = tile_extents(&data)?;
            result_shape(&dst, Shape(vec![free, partitions]))?;
            Ok(LoweredInstr::Transpose {
                dst: dst.id,
                data: data.id,
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

// =============================================================================
// Operand Checks
// =============================================================================

/// `operand`'s `[partitions, free]` extents; every SBUF and PSUM tensor is a two-dimensional tile.
fn tile_extents(operand: &Shaped) -> Result<[u64; 2], StatementError> {
    match (operand.memory, &operand.shape.0[..]) {
        (Memory::Sbuf | Memory::Psum, &[partitions, free]) => Ok([partitions, free]),
        _ => Err(StatementError::OffChip(operand.name.clone())),
    }
}

fn in_memory(operand: &Shaped, expected: Memory) -> Result<(), StatementError> {
    if operand.memory == expected {
        return Ok(());
    }
    Err(StatementError::WrongMemory {
        tensor: operand.name.clone(),
        expected,
    })
}

/// Check that `dst` has the shape `expected` of the instruction's result.
fn result_shape(dst: &Shaped, expected: Shape) -> Result<(), StatementError> {
    if *dst.shape == expected {
        return Ok(());
    }
    Err(StatementError::ResultShape {
        tensor: dst.name.clone(),
        shape: dst.shape.clone(),
        expected,
    })
}

fn same_shape(left: &Shaped, right: &Shaped) -> Result<(), StatementError> {
    if left.shape == right.shape {
        return Ok(());
    }
    Err(StatementError::ShapeMismatch([
        (left.name.clone(), left.shape.clone()),
        (right.name.clone(), right.shape.clone()),
    ]))
}

// =============================================================================
// Scope
// =============================================================================

/// A tensor as lowering sees it: a parameter has no shape until one is asserted.
struct Entry {
    name: TensorName,
    memory: Memory,
    shape: Option<Shape>,
}

/// A tensor operand whose shape is bound.
struct Shaped<'a> {
    id: TensorId,
    name: &'a TensorName,
    memory: Memory,
    shape: &'a Shape,
}

/// The tensors named so far. The parser guarantees every name a statement uses
/// is a parameter or an earlier tile, and that no name is declared twice.
#[derive(Default)]
struct Scope {
    ids: BTreeMap<TensorName, TensorId>,
    entries: IdVec<TensorId, Entry>,
}

impl Scope {
    fn add(&mut self, name: TensorName, memory: Memory, shape: Option<Shape>) -> TensorId {
        let id = self.entries.push(Entry {
            name: name.clone(),
            memory,
            shape,
        });
        self.ids.insert(name, id);
        id
    }

    /// Bind the shape of a parameter not yet asserted, or check a bound shape against it.
    fn assert_shape(&mut self, tensor: &TensorName, asserted: Shape) -> Result<(), StatementError> {
        let entry = &mut self.entries[self.ids[tensor]];
        match &entry.shape {
            None => entry.shape = Some(asserted),
            Some(shape) if *shape == asserted => {}
            Some(shape) => {
                return Err(StatementError::ShapeContradiction {
                    tensor: tensor.clone(),
                    shape: shape.clone(),
                    asserted,
                });
            }
        }
        Ok(())
    }

    /// Operand `keyword`, a tensor whose shape is bound.
    fn shaped(
        &self,
        operand: &Operand,
        keyword: &'static str,
    ) -> Result<Shaped<'_>, StatementError> {
        let Operand::Tensor(name) = operand else {
            return Err(StatementError::NotATensor { keyword });
        };
        let id = self.ids[name];
        let entry = &self.entries[id];
        let Some(shape) = &entry.shape else {
            return Err(StatementError::Unshaped(name.clone()));
        };
        Ok(Shaped {
            id,
            name: &entry.name,
            memory: entry.memory,
            shape,
        })
    }

    fn into_tensors(self) -> Result<IdVec<TensorId, Tensor>, LowerError> {
        self.entries.try_map(|_, entry| {
            let Some(shape) = entry.shape else {
                return Err(LowerError::UnassertedParam(entry.name));
            };
            Ok(Tensor {
                name: entry.name.0,
                memory: entry.memory,
                shape,
            })
        })
    }
}
