//! Lowering a parsed NKI kernel into its tensors and the instructions over them.
//! A parameter's shape is the one its `assert` binds, which must precede the
//! parameter's first use as an operand.

mod error;

use std::collections::BTreeMap;

use id_collections::IdVec;

use crate::frontend::ast::{Buffer, Instruction, Kernel, Operand, Statement, TensorName};
use crate::ir::{ArithOp, LoweredInstr, LoweredKernel, Memory, Shape, Tensor, TensorId};

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
        "dma_copy" => {
            let [dst, src] = operands(instruction, &["dst", "src"])?;
            let [dst, src] = [scope.shaped(dst, "dst")?, scope.shaped(src, "src")?];
            same_shape(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.id,
                src: src.id,
            })
        }

        "tensor_tensor" => {
            let [dst, data1, data2, op] = operands(instruction, &["dst", "data1", "data2", "op"])?;
            let op = arith_op(op)?;
            let [dst, lhs, rhs] = [
                scope.shaped(dst, "dst")?,
                scope.shaped(data1, "data1")?,
                scope.shaped(data2, "data2")?,
            ];
            for tile in [&dst, &lhs, &rhs] {
                if tile.memory == Memory::Hbm {
                    return Err(StatementError::OffChip(tile.name.clone()));
                }
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

        opcode => Err(StatementError::UnsupportedInstruction(opcode.into())),
    }
}

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

/// A `nki.language` arithmetic function, e.g. `nl.add`.
fn arith_op(operand: &Operand) -> Result<ArithOp, StatementError> {
    let name = match operand {
        Operand::Member(member) => member
            .strip_prefix(NKI_LANGUAGE)
            .and_then(|name| name.strip_prefix('.')),
        Operand::Tensor(_) => None,
    };
    ArithOp::ALL
        .into_iter()
        .find(|op| Some(op.name()) == name)
        .ok_or_else(|| StatementError::UnsupportedArithOp(operand.clone()))
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
