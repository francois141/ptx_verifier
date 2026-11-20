//! Lowering a parsed NKI kernel into its tensors and the instructions over them.
//! A parameter's shape is the call's, which the parser records; a declared
//! tensor's is its declaration's.

mod error;

use std::borrow::Cow;
use std::collections::BTreeMap;

use id_collections::IdVec;

use crate::frontend::ast::{
    Address, Buffer, Instruction, Kernel, Operand, RegionProblem, Scalar, Selected, Statement,
    TensorName, resolve_region,
};
use crate::ir::{
    Accumulation, ActivationFunc, ArithOp, Comparison, Copied, Descriptors, Index, Initial, Layout,
    LoweredInstr, LoweredKernel, MatmulPass, Memory, Mover, Order, Reduction, ScalarOperand,
    ScalarStep, Selection, Shape, Sign, Tensor, TensorId, TensorRegion,
};

pub use error::{LowerError, PatternProblem, StatementError};

const NKI_LANGUAGE: &str = "nki.language";

/// The one `reduce_cmd` lowered: reset the accumulator, then reduce this instruction's
/// result. The others carry an accumulator across instructions, which is not modelled.
const RESET_REDUCE: &str = "nki.isa.reduce_cmd.reset_reduce";
const LOAD_REDUCE: &str = "nki.isa.reduce_cmd.load_reduce";

/// The compute engines an instruction's `engine=` may pick, by `nki.isa` member;
/// `engine.unknown` lets the compiler choose. Which engine runs an instruction does not
/// change its result, but tensor indirection runs on the vector or scalar engine only.
const ENGINES: [(&str, Option<Engine>); 10] = [
    ("nki.isa.engine.vector", Some(Engine::Vector)),
    ("nki.isa.engine.scalar", Some(Engine::Scalar)),
    ("nki.isa.engine.gpsimd", Some(Engine::Gpsimd)),
    ("nki.isa.engine.tensor", Some(Engine::Tensor)),
    ("nki.isa.engine.unknown", None),
    // The DMA queue a `dma_copy` issues on; it does not change the copy.
    ("nki.isa.engine.sync", None),
    ("nki.isa.vector_engine", Some(Engine::Vector)),
    ("nki.isa.scalar_engine", Some(Engine::Scalar)),
    ("nki.isa.gpsimd_engine", Some(Engine::Gpsimd)),
    ("nki.isa.tensor_engine", Some(Engine::Tensor)),
];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Engine {
    Vector,
    Scalar,
    Gpsimd,
    Tensor,
}

/// The partitions tensor indirection on the vector and scalar engines reads one
/// column of offsets from.
const INDIRECT_GROUP: u64 = 16;

/// Lower `kernel` into its tensors, the parameters first and then the declared
/// tensors in declaration order, its instructions in order, and the tensor it returns.
pub fn lower_kernel(kernel: &Kernel) -> Result<LoweredKernel, LowerError> {
    let mut scope = Scope::default();
    let params = kernel
        .params
        .iter()
        .map(|param| {
            let shape = Shape(param.shape.iter().map(|extent| extent.get()).collect());
            let initial = match &param.contents {
                None => Initial::Argument,
                Some(contents) => Initial::Integers(contents.clone()),
            };
            scope.add(param.name.clone(), Memory::Hbm, shape, initial, None)
        })
        .collect();

    let mut instructions = Vec::new();
    let mut origins = Vec::new();
    for (index, statement) in kernel.body.iter().enumerate() {
        let at = |error| LowerError::Statement { index, error };
        match statement {
            Statement::Declare(tile) => {
                let shape = Shape(tile.shape.extents());
                if shape.element_count().is_none() {
                    return Err(at(StatementError::ElementCountOverflow(tile.name.clone())));
                }
                let memory = memory(tile.buffer);
                let (name, address) = (tile.name.clone(), tile.address);
                scope.add(name, memory, shape, Initial::Uninitialized, address);
            }
            Statement::DeclareHbm(tensor) => {
                let shape = Shape(tensor.shape.iter().map(|extent| extent.get()).collect());
                let name = tensor.name.clone();
                scope.add(name, Memory::Hbm, shape, Initial::Uninitialized, None);
            }
            Statement::Instruction(instruction) => {
                instructions.push(lower_instruction(instruction, &scope).map_err(at)?);
                origins.push(instruction.origin.clone());
            }
        }
    }

    scope.placed_all_or_none()?;
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
        origins: IdVec::from_vec(origins),
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
    let (instruction, engine) = without_engine(instruction)?;
    let instruction = &instruction;
    match instruction.opcode.as_str() {
        // =====================================================================
        // Data Movement
        // =====================================================================
        "dma_copy" => {
            let (instruction, descriptors) = without_dge_mode(instruction)?;
            let [dst, src] = operands(&instruction, &["dst", "src"])?;
            let [dst, src] = [scope.region(dst, "dst")?, scope.region(src, "src")?];
            same_elements(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.region,
                src: src.region,
                mover: Mover::Dma(descriptors),
            })
        }

        "tensor_copy" => {
            let [dst, src] = operands(instruction, &["dst", "src"])?;
            if let Operand::Indirect {
                tensor,
                index,
                count,
            } = src
            {
                return gather(dst, [tensor, index], *count, engine, scope);
            }
            let [dst, src] = [scope.tile(dst, "dst")?, scope.tile(src, "src")?];
            same_shape(&dst, &src)?;
            Ok(LoweredInstr::Mov {
                dst: dst.region,
                src: src.region,
                mover: Mover::Engine,
            })
        }

        "iota" => {
            let ([dst, pattern], [offset, channel_multiplier]) = operands_with_optional(
                instruction,
                &["dst", "pattern"],
                &["offset", "channel_multiplier"],
            )?;
            let dst = scope.tile(dst, "dst")?;
            let Operand::Pairs(pattern) = pattern else {
                return Err(StatementError::NotAPattern { keyword: "pattern" });
            };
            let [_, free] = dst.region.tile_extents();
            if pattern.iter().map(|&(_, count)| count).product::<u64>() != free {
                let (tensor, shape) = dst.described();
                return Err(StatementError::ResultShape {
                    tensor,
                    shape,
                    expected: Shape(vec![dst.region.tile_extents()[0], free]),
                });
            }
            Ok(LoweredInstr::Iota {
                dst: dst.region,
                pattern: pattern.clone(),
                offset: integer(offset, "offset")?,
                channel_multiplier: integer(channel_multiplier, "channel_multiplier")?,
            })
        }

        "range_select" => {
            let (
                [dst, on_true, comp_op0, comp_op1, bound0, bound1],
                [
                    reduce_cmd,
                    reduce_res,
                    reduce_op,
                    range_start,
                    on_false_value,
                ],
            ) = operands_with_optional(
                instruction,
                &[
                    "dst",
                    "on_true_tile",
                    "comp_op0",
                    "comp_op1",
                    "bound0",
                    "bound1",
                ],
                &[
                    "reduce_cmd",
                    "reduce_res",
                    "reduce_op",
                    "range_start",
                    "on_false_value",
                ],
            )?;
            let [dst, on_true] = [
                scope.tile(dst, "dst")?,
                scope.tile(on_true, "on_true_tile")?,
            ];
            same_shape(&dst, &on_true)?;
            let [partitions, _] = dst.region.tile_extents();
            let mut bounds = Vec::new();
            for (bound, keyword) in [(bound0, "bound0"), (bound1, "bound1")] {
                let bound = scope.tile(bound, keyword)?;
                per_partition(&bound, partitions)?;
                bounds.push(bound.region);
            }
            let reduce = match (reduce_op, reduce_res, reduce_cmd) {
                (Some(op), Some(res), Some(cmd)) => {
                    reset_reduce(cmd)?;
                    Some(reduction(op, res, &dst, scope)?)
                }
                (None, None, _) => None,
                _ => {
                    return Err(StatementError::UnpairedOperands {
                        opcode: instruction.opcode.clone(),
                        keywords: &["reduce_op", "reduce_res", "reduce_cmd"],
                    });
                }
            };
            let on_false = match on_false_value {
                None | Some(Operand::None) => Scalar::new(f32::MIN as f64).expect("a number"),
                Some(Operand::Scalar(value)) => *value,
                Some(_) => {
                    return Err(StatementError::NotAScalar {
                        keyword: "on_false_value",
                    });
                }
            };
            let range_start = match range_start {
                None | Some(Operand::None) => 0,
                Some(Operand::Int(start)) => *start,
                Some(_) => {
                    return Err(StatementError::NotAnInteger {
                        keyword: "range_start",
                    });
                }
            };
            Ok(LoweredInstr::RangeSelect {
                dst: dst.region,
                on_true: on_true.region,
                bounds: bounds.try_into().expect("two bounds"),
                comparisons: [comparison(comp_op0)?, comparison(comp_op1)?],
                range_start,
                on_false,
                reduce,
            })
        }

        "tensor_copy_predicated" => {
            let ([dst, src, predicate], [reverse]) = operands_with_optional(
                instruction,
                &["dst", "src", "predicate"],
                &["reverse_pred"],
            )?;
            let [dst, src, predicate] = [
                scope.tile(dst, "dst")?,
                scope.tile(src, "src")?,
                scope.tile(predicate, "predicate")?,
            ];
            same_shape(&dst, &src)?;
            same_shape(&dst, &predicate)?;
            let copied_where = match reverse {
                None | Some(Operand::None) | Some(Operand::Bool(false)) => Copied::Nonzero,
                Some(Operand::Bool(true)) => Copied::Zero,
                Some(_) => {
                    return Err(StatementError::NotABool {
                        keyword: "reverse_pred",
                    });
                }
            };
            Ok(LoweredInstr::CopyPredicated {
                dst: dst.region,
                src: src.region,
                predicate: predicate.region,
                copied_where,
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

        "shared_identity_matrix" => {
            let [dst] = operands(instruction, &["dst"])?;
            let dst = scope.tile(dst, "dst")?;
            let [rows, _] = dst.matrix()?;
            result_shape(&dst, Shape(vec![rows, rows]))?;
            Ok(LoweredInstr::Identity { dst: dst.region })
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
            let ([dst, op, data], [scale, bias, reduce_op, reduce_res, reduce_cmd]) =
                operands_with_optional(
                    instruction,
                    &["dst", "op", "data"],
                    &["scale", "bias", "reduce_op", "reduce_res", "reduce_cmd"],
                )?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            let reduce = match (reduce_op, reduce_res, reduce_cmd) {
                (Some(op), Some(res), Some(cmd)) => {
                    reset_reduce(cmd)?;
                    Some(reduction(op, res, &dst, scope)?)
                }
                (None, None, None) => None,
                _ => {
                    return Err(StatementError::UnpairedOperands {
                        opcode: instruction.opcode.clone(),
                        keywords: &["reduce_op", "reduce_res", "reduce_cmd"],
                    });
                }
            };
            Ok(LoweredInstr::Activation {
                func: activation_func(op)?,
                scale: broadcast_operand(scale, "scale", &dst, scope)?,
                bias: broadcast_operand(bias, "bias", &dst, scope)?,
                dst: dst.region,
                data: data.region,
                reduce,
            })
        }

        // `activation` with `reduce_cmd=reset_reduce`, as the NKI docs define it.
        "activation_reduce" => {
            let ([dst, op, data, reduce_op, reduce_res], [scale, bias]) = operands_with_optional(
                instruction,
                &["dst", "op", "data", "reduce_op", "reduce_res"],
                &["scale", "bias"],
            )?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            Ok(LoweredInstr::Activation {
                func: activation_func(op)?,
                scale: broadcast_operand(scale, "scale", &dst, scope)?,
                bias: broadcast_operand(bias, "bias", &dst, scope)?,
                reduce: Some(reduction(reduce_op, reduce_res, &data, scope)?),
                dst: dst.region,
                data: data.region,
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
                scale: None,
                bias: None,
                reduce: None,
            })
        }

        "tensor_reduce" => {
            let ([dst, data, op, axis], [negate, keepdims]) = operands_with_optional(
                instruction,
                &["dst", "data", "op", "axis"],
                &["negate", "keepdims"],
            )?;
            // Either way `dst` holds the result's elements per partition; `reduced_shape`
            // accepts the kept axes as extents of 1 or dropped.
            if !matches!(keepdims, None | Some(Operand::Bool(_))) {
                return Err(StatementError::NotABool {
                    keyword: "keepdims",
                });
            }
            let op = arith_op(op)?;
            let sign = match negate {
                None | Some(Operand::Bool(false)) => Sign::Kept,
                Some(Operand::Bool(true)) => Sign::Negated,
                Some(_) => return Err(StatementError::NotABool { keyword: "negate" }),
            };
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            let kept = trailing_axes(axis, &data.kept)?;
            reduced_shape(&dst, &kept)?;
            Ok(LoweredInstr::Reduce {
                op,
                dst: dst.region,
                data: data.region,
                sign,
            })
        }

        // One `tensor_scalar` step, then its result's reduction into `reduce_res`.
        "tensor_scalar_reduce" => {
            let ([dst, data, op0, operand0, reduce_op, reduce_res], [reduce_cmd]) =
                operands_with_optional(
                    instruction,
                    &["dst", "data", "op0", "operand0", "reduce_op", "reduce_res"],
                    &["reduce_cmd"],
                )?;
            if let Some(cmd) = reduce_cmd {
                reset_reduce(cmd)?;
            }
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            let [partitions, _] = dst.region.tile_extents();
            Ok(LoweredInstr::TensorScalar {
                first: scalar_step(op0, operand0, "operand0", partitions, scope)?,
                second: None,
                reduce: Some(reduction(reduce_op, reduce_res, &dst, scope)?),
                dst: dst.region,
                data: data.region,
            })
        }

        "tensor_scalar" => {
            let ([dst, data, op0, operand0], [op1, operand1, reverse0, reverse1]) =
                operands_with_optional(
                    instruction,
                    &["dst", "data", "op0", "operand0"],
                    &["op1", "operand1", "reverse0", "reverse1"],
                )?;

            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            same_shape(&dst, &data)?;
            let [partitions, _] = dst.region.tile_extents();

            let first = ScalarStep {
                order: order(reverse0, "reverse0")?,
                ..scalar_step(op0, operand0, "operand0", partitions, scope)?
            };
            let second = match (op1, operand1) {
                (Some(op), Some(operand)) => Some(ScalarStep {
                    order: order(reverse1, "reverse1")?,
                    ..scalar_step(op, operand, "operand1", partitions, scope)?
                }),
                (None, None) => None,
                _ => {
                    return Err(StatementError::UnpairedOperands {
                        opcode: instruction.opcode.clone(),
                        keywords: &["op1", "operand1"],
                    });
                }
            };

            Ok(LoweredInstr::TensorScalar {
                dst: dst.region,
                data: data.region,
                first,
                second,
                reduce: None,
            })
        }

        "scalar_tensor_tensor" => {
            let ([dst, data, op0, operand0, op1, operand1], optional) = operands_with_optional(
                instruction,
                &["dst", "data", "op0", "operand0", "op1", "operand1"],
                &[
                    "reverse0",
                    "reverse1",
                    "reduce_op",
                    "reduce_res",
                    "reduce_cmd",
                ],
            )?;
            let [reverse0, reverse1, reduce_op, reduce_res, reduce_cmd] = optional;
            if let Some(cmd) = reduce_cmd {
                reset_reduce(cmd)?;
            }
            let [dst, data, operand1] = [
                scope.tile(dst, "dst")?,
                scope.tile(data, "data")?,
                scope.tile(operand1, "operand1")?,
            ];
            same_shape(&dst, &data)?;
            same_shape(&dst, &operand1)?;
            let [partitions, _] = dst.region.tile_extents();
            let reduce = match (reduce_op, reduce_res) {
                (Some(op), Some(res)) => Some(reduction(op, res, &dst, scope)?),
                (None, None) => None,
                _ => {
                    return Err(StatementError::UnpairedOperands {
                        opcode: instruction.opcode.clone(),
                        keywords: &["reduce_op", "reduce_res"],
                    });
                }
            };
            Ok(LoweredInstr::ScalarTensorTensor {
                op0: (arith_op(op0)?, order(reverse0, "reverse0")?),
                operand0: scalar_operand(operand0, "operand0", partitions, scope)?,
                op1: (arith_op(op1)?, order(reverse1, "reverse1")?),
                operand1: operand1.region,
                reduce,
                dst: dst.region,
                data: data.region,
            })
        }

        "tensor_partition_reduce" => {
            let [dst, op, data] = operands(instruction, &["dst", "op", "data"])?;
            let op = arith_op(op)?;
            if !matches!(op, ArithOp::Add | ArithOp::Maximum) {
                return Err(StatementError::UnsupportedArithOp(
                    instruction.operands["op"].clone(),
                ));
            }
            let [dst, data] = [scope.tile(dst, "dst")?, scope.tile(data, "data")?];
            let [_, free] = data.region.tile_extents();
            if dst.region.tile_extents() != [1, free] {
                let (tensor, shape) = dst.described();
                return Err(StatementError::ResultShape {
                    tensor,
                    shape,
                    expected: Shape(vec![1, free]),
                });
            }
            Ok(LoweredInstr::PartitionReduce {
                op,
                dst: dst.region,
                data: data.region,
            })
        }

        "tensor_scalar_cumulative" => {
            let ([dst, src, op0, op1, imm0], [imm1, reduce_cmd]) = operands_with_optional(
                instruction,
                &["dst", "src", "op0", "op1", "imm0"],
                &["imm1", "reduce_cmd"],
            )?;
            let [dst, src] = [scope.tile(dst, "dst")?, scope.tile(src, "src")?];
            same_shape(&dst, &src)?;
            let imm1 = imm1.filter(|imm1| **imm1 != Operand::None);
            let initial = match (reduce_cmd, imm1) {
                (None, None) => None,
                (Some(cmd), None) if is_member(cmd, RESET_REDUCE) => None,
                (Some(cmd), Some(imm1)) if is_member(cmd, LOAD_REDUCE) => {
                    let [partitions, _] = dst.region.tile_extents();
                    Some(scalar_operand(imm1, "imm1", partitions, scope)?)
                }
                (Some(cmd), _) => return Err(StatementError::UnsupportedReduceCmd(cmd.clone())),
                (None, Some(imm1)) => {
                    return Err(StatementError::UnsupportedReduceCmd(imm1.clone()));
                }
            };
            let imm0 = match imm0 {
                Operand::Scalar(value) => *value,
                Operand::Int(value) => Scalar::new(*value as f64).expect("an integer is finite"),
                _ => return Err(StatementError::NotAScalar { keyword: "imm0" }),
            };
            Ok(LoweredInstr::Cumulative {
                op0: arith_op(op0)?,
                imm0,
                op1: arith_op(op1)?,
                initial,
                dst: dst.region,
                src: src.region,
            })
        }

        "tensor_tensor_scan" => {
            let ([dst, data0, data1, initial, op0, op1], [reverse0, reverse1]) =
                operands_with_optional(
                    instruction,
                    &["dst", "data0", "data1", "initial", "op0", "op1"],
                    &["reverse0", "reverse1"],
                )?;
            let [dst, data0, data1] = [
                scope.tile(dst, "dst")?,
                scope.tile(data0, "data0")?,
                scope.tile(data1, "data1")?,
            ];
            let [partitions, _] = data0.matrix()?;
            same_shape(&data0, &data1)?;
            same_shape(&dst, &data0)?;
            Ok(LoweredInstr::Scan {
                initial: scalar_operand(initial, "initial", partitions, scope)?,
                op0: (arith_op(op0)?, order(reverse0, "reverse0")?),
                op1: (arith_op(op1)?, order(reverse1, "reverse1")?),
                dst: dst.region,
                data0: data0.region,
                data1: data1.region,
            })
        }

        // =====================================================================
        // Tensor Engine
        // =====================================================================
        "nc_matmul" => {
            // `tile_position` and `tile_size` place the matmul on part of the Tensor engine's
            // array, which does not change its product.
            let ([dst, stationary, moving], [accumulate, is_transpose, _, _]) =
                operands_with_optional(
                    instruction,
                    &["dst", "stationary", "moving"],
                    &["accumulate", "is_transpose", "tile_position", "tile_size"],
                )?;
            let pass = match is_transpose {
                None | Some(Operand::Bool(false)) => MatmulPass::Multiply,
                Some(Operand::Bool(true)) => MatmulPass::Transpose,
                Some(_) => {
                    return Err(StatementError::NotABool {
                        keyword: "is_transpose",
                    });
                }
            };
            let accumulation = match accumulate {
                None | Some(Operand::None) => Accumulation::FirstOverwrites,
                Some(Operand::Bool(false)) => Accumulation::Overwrite,
                Some(Operand::Bool(true)) => Accumulation::Accumulate,
                Some(_) => {
                    return Err(StatementError::NotABool {
                        keyword: "accumulate",
                    });
                }
            };
            let [dst, stationary, moving] = [
                scope.tile(dst, "dst")?,
                scope.tile(stationary, "stationary")?,
                scope.tile(moving, "moving")?,
            ];
            stationary.in_memory(Memory::Sbuf)?;
            moving.in_memory(Memory::Sbuf)?;
            dst.in_memory(Memory::Psum)?;
            let [[contraction, rows], [moving_contraction, columns]] =
                [stationary.matrix()?, moving.flattened()?];
            if contraction != moving_contraction {
                return Err(StatementError::ContractionMismatch([
                    stationary.described(),
                    moving.described(),
                ]));
            }
            if dst.flattened()? != [rows, columns] {
                result_shape(&dst, Shape(vec![rows, columns]))?;
            }
            Ok(LoweredInstr::Matmul {
                dst: dst.region,
                stationary: stationary.region,
                moving: moving.region,
                accumulation,
                pass,
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
                middle: 1,
                mover: Mover::Engine,
            })
        }

        "nc_stream_shuffle" => {
            let [dst, src, mask] = operands(instruction, &["dst", "src", "shuffle_mask"])?;
            let [dst, src] = [scope.tile(dst, "dst")?, scope.tile(src, "src")?];
            let [[partitions, free], [sources, source_free]] = [dst.flattened()?, src.flattened()?];
            if free != source_free {
                return Err(StatementError::ShapeMismatch([
                    dst.described(),
                    src.described(),
                ]));
            }
            let Operand::Ints(mask) = mask else {
                return Err(StatementError::ShuffleMask(mask.clone()));
            };
            const QUADRANT: u64 = 32;
            const UNWRITTEN: u64 = 255;
            let entries: Option<Vec<Option<u64>>> = mask
                .iter()
                .map(|&entry| match entry {
                    UNWRITTEN => Some(None),
                    entry if entry < sources => Some(Some(entry)),
                    _ => None,
                })
                .collect();
            match entries {
                Some(entries)
                    if mask.len() as u64 == QUADRANT
                        && partitions <= QUADRANT
                        && sources <= QUADRANT =>
                {
                    Ok(LoweredInstr::Shuffle {
                        dst: dst.region,
                        src: src.region,
                        mask: entries,
                    })
                }
                _ => Err(StatementError::ShuffleMask(Operand::Ints(mask.clone()))),
            }
        }

        // A transpose the DMA engines perform, from a region in any memory into a tile: a 2-D
        // one (`axes=(1, 0)`), or with the default axes one swapping the ends of a region
        // whose other dimensions have extent 1.
        "dma_transpose" => {
            let (instruction, descriptors) = without_dge_mode(instruction)?;
            let ([dst, src], [axes]) =
                operands_with_optional(&instruction, &["dst", "src"], &["axes"])?;
            let [dst, data] = [scope.tile(dst, "dst")?, scope.region(src, "src")?];
            let (first, middle, last) = match axes {
                None | Some(Operand::None) => data.ends()?,
                Some(Operand::Ints(axes)) if axes[..] == [1, 0] => {
                    let [rows, columns] = data.matrix()?;
                    (rows, Vec::new(), columns)
                }
                Some(axes) => return Err(StatementError::UnsupportedTransposeAxes(axes.clone())),
            };
            let size = middle.iter().product();
            if dst.ends()? != (last, middle, first) {
                let (tensor, shape) = dst.described();
                let mut expected = data.kept.0.clone();
                expected.reverse();
                return Err(StatementError::ResultShape {
                    tensor,
                    shape,
                    expected: Shape(expected),
                });
            }
            Ok(LoweredInstr::Transpose {
                dst: dst.region,
                data: data.region,
                middle: size,
                mover: Mover::Dma(descriptors),
            })
        }

        opcode => Err(StatementError::UnsupportedInstruction(opcode.into())),
    }
}

// =============================================================================
// Operands
// =============================================================================

/// A DMA `instruction` without its `dge_mode=`, and how that mode generates its
/// descriptors: `nisa.dge_mode.unknown` (the default), `none`, `hwdge` or `swdge`, the first two also
/// written as their values 0 and 3.
fn without_dge_mode(
    instruction: &Instruction,
) -> Result<(Instruction, Descriptors), StatementError> {
    let mut instruction = instruction.clone();
    let descriptors = match instruction.operands.remove("dge_mode") {
        None | Some(Operand::Int(0)) => Descriptors::CompilerChosen,
        Some(Operand::Int(3)) => Descriptors::OutOfBand,
        Some(Operand::Member(member)) if member == "nki.isa.dge_mode.unknown" => {
            Descriptors::CompilerChosen
        }
        Some(Operand::Member(member)) if member == "nki.isa.dge_mode.none" => {
            Descriptors::OutOfBand
        }
        Some(Operand::Member(member)) if member == "nki.isa.dge_mode.hwdge" => {
            Descriptors::Hardware
        }
        Some(Operand::Member(member)) if member == "nki.isa.dge_mode.swdge" => {
            Descriptors::Software
        }
        Some(other) => return Err(StatementError::UnsupportedDgeMode(other)),
    };
    Ok((instruction, descriptors))
}

/// `instruction` without its `engine=`, which must name a compute engine if given, and
/// the engine it names.
fn without_engine(
    instruction: &Instruction,
) -> Result<(Cow<'_, Instruction>, Option<Engine>), StatementError> {
    let Some(given) = instruction.operands.get("engine") else {
        return Ok((Cow::Borrowed(instruction), None));
    };
    let engine = ENGINES
        .iter()
        .find(|(name, _)| matches!(given, Operand::Member(member) if member == name));
    let Some(&(_, engine)) = engine else {
        return Err(StatementError::UnsupportedEngine(given.clone()));
    };
    let mut instruction = instruction.clone();
    instruction.operands.remove("engine");
    Ok((Cow::Owned(instruction), engine))
}

/// `tensor_copy(dst, data.indirect(index, num_elem=count))`: `dst` a `[partitions,
/// count]` tile region, `data` a matrix tile and `index` an SBUF matrix of its
/// partitions, `count` by default the index's size, as the NKI docs give it.
fn gather(
    dst: &Operand,
    [data, index]: [&TensorName; 2],
    count: Option<u64>,
    engine: Option<Engine>,
    scope: &Scope,
) -> Result<LoweredInstr, StatementError> {
    if let Some(engine @ Engine::Gpsimd) = engine {
        let member = ENGINES.iter().find(|(_, named)| *named == Some(engine));
        let member = member.expect("every engine has a member").0;
        return Err(StatementError::IndirectEngine(Operand::Member(
            member.into(),
        )));
    }
    let dst = scope.tile(dst, "dst")?;
    let data = scope.tile(&Operand::Tensor(data.clone()), "src")?;
    let index = scope.tile(&Operand::Tensor(index.clone()), "index")?;
    index.in_memory(Memory::Sbuf)?;
    let [partitions, _] = data.matrix()?;
    if partitions % INDIRECT_GROUP != 0 {
        return Err(StatementError::IndirectPartitions(partitions));
    }
    let columns = match index.kept.0[..] {
        [rows, columns] if rows == partitions => columns,
        _ => {
            return Err(StatementError::IndirectIndex {
                tensor: index.name.clone(),
                shape: index.kept.clone(),
                partitions,
            });
        }
    };
    let capacity = INDIRECT_GROUP * columns;
    let count = count.unwrap_or(partitions * columns);
    if count > capacity {
        return Err(StatementError::IndirectCount { count, capacity });
    }
    result_shape(&dst, Shape(vec![partitions, count]))?;
    Ok(LoweredInstr::Gather {
        dst: dst.region,
        data: data.region,
        index: index.region,
    })
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

/// A `nki.language` arithmetic function, e.g. `nl.add`; `nl.max`, which nkilib's kernels
/// pass as an op, is `nl.maximum`.
fn arith_op(operand: &Operand) -> Result<ArithOp, StatementError> {
    let name = match language_member(operand) {
        Some("max") => Some("maximum"),
        name => name,
    };
    ArithOp::ALL
        .into_iter()
        .find(|op| Some(op.name()) == name)
        .ok_or_else(|| StatementError::UnsupportedArithOp(operand.clone()))
}

/// A `nki.language` comparison, e.g. `nl.greater_equal`.
fn comparison(operand: &Operand) -> Result<Comparison, StatementError> {
    let name = language_member(operand);
    Comparison::ALL
        .into_iter()
        .find(|comparison| Some(comparison.name()) == name)
        .ok_or_else(|| StatementError::UnsupportedComparison(operand.clone()))
}

/// An optional integer operand, 0 if absent: `iota`'s `offset` and `channel_multiplier`.
fn integer(operand: Option<&Operand>, keyword: &'static str) -> Result<i64, StatementError> {
    match operand {
        None | Some(Operand::None) => Ok(0),
        Some(Operand::Int(value)) => {
            i64::try_from(*value).map_err(|_| StatementError::NotAnInteger { keyword })
        }
        Some(_) => Err(StatementError::NotAnInteger { keyword }),
    }
}

/// A `nki.language` activation function, e.g. `nl.sigmoid`.
fn activation_func(operand: &Operand) -> Result<ActivationFunc, StatementError> {
    let name = language_member(operand);
    ActivationFunc::ALL
        .into_iter()
        .find(|func| Some(func.name()) == name)
        .ok_or_else(|| StatementError::UnsupportedActivation(operand.clone()))
}

/// The dimensions of `data`'s region, of kept shape `shape`, that a `tensor_reduce`
/// over `axis` keeps: `axis` must be its trailing free axes, e.g. `1`, `(1,)` or
/// `[3, 4]`. Axis 0 is the partition axis, which `nki.isa` reductions cannot reduce.
fn trailing_axes(axis: &Operand, shape: &Shape) -> Result<Shape, StatementError> {
    let axes = match axis {
        Operand::Int(axis) => std::slice::from_ref(axis),
        Operand::Ints(axes) => &axes[..],
        _ => return Err(StatementError::UnsupportedAxis(axis.clone())),
    };
    let rank = shape.0.len() as u64;
    let first = rank.saturating_sub(axes.len() as u64);
    let trailing = first >= 1 && axes.iter().copied().eq(first..rank);
    if !trailing {
        return Err(StatementError::UnsupportedAxis(axis.clone()));
    }
    Ok(Shape(shape.0[..first as usize].to_vec()))
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
    Ok(ScalarStep {
        op: arith_op(op)?,
        operand: scalar_operand(operand, keyword, partitions, scope)?,
        order: Order::Given,
    })
}

/// An operand broadcast across a destination of `partitions` partitions: a literal, or
/// a tile region of one free element per partition.
fn scalar_operand(
    operand: &Operand,
    keyword: &'static str,
    partitions: u64,
    scope: &Scope,
) -> Result<ScalarOperand, StatementError> {
    if let Operand::Scalar(value) = operand {
        return Ok(ScalarOperand::Constant(*value));
    }
    let tile = scope.tile(operand, keyword)?;
    if tile.region.tile_extents() != [partitions, 1] {
        let (tensor, shape) = tile.described();
        return Err(StatementError::NotBroadcastable {
            tensor,
            shape,
            expected: Shape(vec![partitions, 1]),
        });
    }
    Ok(ScalarOperand::Broadcast(tile.region))
}

/// An activation's optional `scale` or `bias`, broadcast across `dst` like a
/// `tensor_scalar` operand.
fn broadcast_operand(
    operand: Option<&Operand>,
    keyword: &'static str,
    dst: &RegionOperand,
    scope: &Scope,
) -> Result<Option<ScalarOperand>, StatementError> {
    let [partitions, _] = dst.region.tile_extents();
    operand
        .map(|operand| scalar_operand(operand, keyword, partitions, scope))
        .transpose()
}

/// A scan op's operand order from its optional `reverse0` or `reverse1`.
fn order(reverse: Option<&Operand>, keyword: &'static str) -> Result<Order, StatementError> {
    match reverse {
        None | Some(Operand::Bool(false)) => Ok(Order::Given),
        Some(Operand::Bool(true)) => Ok(Order::Reversed),
        Some(_) => Err(StatementError::NotABool { keyword }),
    }
}

/// The reduction by `op` of an instruction's elementwise result, of the shape of
/// `result`, into `res`, one element per partition.
fn reduction(
    op: &Operand,
    res: &Operand,
    result: &RegionOperand,
    scope: &Scope,
) -> Result<Reduction, StatementError> {
    let op = arith_op(op)?;
    let res = scope.tile(res, "reduce_res")?;
    let [partitions, _] = result.matrix()?;
    per_partition(&res, partitions)?;
    Ok(Reduction {
        op,
        res: res.region,
    })
}

/// Whether `operand` is the `nki` member `member`.
fn is_member(operand: &Operand, member: &str) -> bool {
    matches!(operand, Operand::Member(given) if given == member)
}

/// Check that a `reduce_cmd` is `nisa.reduce_cmd.reset_reduce`.
fn reset_reduce(cmd: &Operand) -> Result<(), StatementError> {
    match cmd {
        Operand::Member(member) if member == RESET_REDUCE => Ok(()),
        _ => Err(StatementError::UnsupportedReduceCmd(cmd.clone())),
    }
}

// =============================================================================
// Operand Checks
// =============================================================================

/// Two operands that must name regions of one shape, their indexed dimensions and free
/// dimensions of extent 1 dropped: an engine pairs free elements in row-major order, which
/// those dimensions do not change (nkilib's `[[8, 128], [8, 1], [1, 4]]` view of a tile).
fn same_shape(left: &RegionOperand, right: &RegionOperand) -> Result<(), StatementError> {
    if left.kept == right.kept || squeezed(&left.kept) == squeezed(&right.kept) {
        return Ok(());
    }
    Err(StatementError::ShapeMismatch([
        left.described(),
        right.described(),
    ]))
}

/// Check that a DMA's regions have one shape once extent-1 dimensions are dropped too: a
/// DMA moves elements in row-major order, which those dimensions do not change.
fn same_elements(left: &RegionOperand, right: &RegionOperand) -> Result<(), StatementError> {
    let squeezed = |shape: &Shape| -> Vec<u64> {
        shape
            .0
            .iter()
            .copied()
            .filter(|&extent| extent != 1)
            .collect()
    };
    if squeezed(&left.kept) == squeezed(&right.kept) {
        return Ok(());
    }
    same_shape(left, right)
}

/// A shape's partitions and its free extents other than 1, which `same_shape` and
/// `result_shape` compare.
fn squeezed(shape: &Shape) -> Option<(u64, Vec<u64>)> {
    let (&partitions, free) = shape.0.split_first()?;
    Some((
        partitions,
        free.iter().copied().filter(|&e| e != 1).collect(),
    ))
}

/// Check that `dst` names a region of the shape `expected` of the instruction's result, up to
/// free dimensions of extent 1, as `same_shape`.
fn result_shape(dst: &RegionOperand, expected: Shape) -> Result<(), StatementError> {
    if dst.kept == expected || squeezed(&dst.kept) == squeezed(&expected) {
        return Ok(());
    }
    let (tensor, shape) = dst.described();
    Err(StatementError::ResultShape {
        tensor,
        shape,
        expected,
    })
}

/// Check that the tile region `dst` holds a `tensor_reduce`'s result, `kept` its data's
/// partitions and unreduced dimensions: `kept`'s elements per partition, so the result
/// of reducing every free axis is `t[:, 0:1]` or `t[:, 0]`.
fn reduced_shape(dst: &RegionOperand, kept: &Shape) -> Result<(), StatementError> {
    let [partitions, ref outer @ ..] = kept.0[..] else {
        unreachable!("a tile region keeps its partitions");
    };
    if dst.region.tile_extents() == [partitions, outer.iter().product()] {
        return Ok(());
    }
    let expected = if outer.is_empty() {
        Shape(vec![partitions, 1])
    } else {
        kept.clone()
    };
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
    /// Its `[rows, columns]` shape, for an instruction over tiles of one free dimension, other
    /// free dimensions of extent 1 allowed (nkilib's `[[8, 128], [4, 1], [1, 4]]` views).
    fn matrix(&self) -> Result<[u64; 2], StatementError> {
        let [rows, ref free @ ..] = self.kept.0[..] else {
            return Err(StatementError::NotAMatrix {
                tensor: self.name.clone(),
                shape: self.kept.clone(),
            });
        };
        let wide: Vec<u64> = free.iter().copied().filter(|&extent| extent != 1).collect();
        match (free.len(), &wide[..]) {
            (1.., [columns]) => Ok([rows, *columns]),
            (1.., []) => Ok([rows, 1]),
            _ => Err(StatementError::NotAMatrix {
                tensor: self.name.clone(),
                shape: self.kept.clone(),
            }),
        }
    }

    /// Its partitions and its free dimensions flattened row-major, as a matmul reads its
    /// moving operand and writes its result.
    fn flattened(&self) -> Result<[u64; 2], StatementError> {
        match self.kept.0[..] {
            [partitions, ref free @ ..] if !free.is_empty() => {
                Ok([partitions, free.iter().product()])
            }
            _ => Err(StatementError::NotAMatrix {
                tensor: self.name.clone(),
                shape: self.kept.clone(),
            }),
        }
    }

    /// Its first extent, the extents between, those of 1 dropped, and its last: the region a
    /// DMA transpose with the docs' default axes (`(1, 0)`, `(2, 1, 0)`, `(3, 1, 2, 0)`)
    /// swaps the ends of, keeping the middle in place.
    fn ends(&self) -> Result<(u64, Vec<u64>, u64), StatementError> {
        match self.kept.0[..] {
            [first, ref middle @ .., last] => {
                let middle = middle
                    .iter()
                    .copied()
                    .filter(|&extent| extent != 1)
                    .collect();
                Ok((first, middle, last))
            }
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
    address: Option<Address>,
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
        address: Option<Address>,
    ) -> TensorId {
        let id = self.entries.push(Entry {
            name: name.clone(),
            memory,
            shape,
            initial,
            address,
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
            Operand::Pattern {
                tensor,
                pattern,
                offset,
            } => return self.pattern(tensor, pattern, *offset),
            Operand::Broadcast { tensor, shape } => return self.broadcast(tensor, shape),
            Operand::Indirect { .. } => return Err(StatementError::IndirectOperand { keyword }),
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
                shape: Shape(shape),
                layout: Layout::Rectangle {
                    start: Index(start),
                    selections,
                },
            },
            kept: Shape(kept),
        })
    }

    /// `tensor.ap(pattern, offset)`, each of its elements within the tensor and, on
    /// chip, the first pair its partitions: a step of the tile's free size, every other
    /// element in the partition it starts in.
    fn pattern(
        &self,
        name: &TensorName,
        pattern: &[[u64; 2]],
        offset: u64,
    ) -> Result<RegionOperand<'_>, StatementError> {
        let id = self.ids[name];
        let entry = &self.entries[id];
        let problem = |problem| StatementError::AccessPattern {
            tensor: name.clone(),
            problem,
        };
        if pattern.is_empty() {
            return Err(problem(PatternProblem::Empty));
        }
        if pattern.iter().any(|&[_, count]| count == 0) {
            return Err(problem(PatternProblem::ZeroCount));
        }
        let span = |pairs: &[[u64; 2]]| {
            pairs.iter().try_fold(0u64, |span, &[step, count]| {
                step.checked_mul(count - 1)?.checked_add(span)
            })
        };
        let size = entry.shape.element_count();
        let last = span(pattern).and_then(|span| span.checked_add(offset));
        if !matches!((last, size), (Some(last), Some(size)) if last < size) {
            return Err(problem(PatternProblem::OutOfBounds));
        }
        if entry.memory != Memory::Hbm {
            let free: u64 = entry.shape.0[1..].iter().product();
            if pattern[0][0] != free {
                return Err(problem(PatternProblem::PartitionStep { free }));
            }
            let within = span(&pattern[1..]).and_then(|span| span.checked_add(offset % free));
            if !matches!(within, Some(within) if within < free) {
                return Err(problem(PatternProblem::CrossesPartition { free }));
            }
        }
        let counts = Shape(pattern.iter().map(|&[_, count]| count).collect());
        Ok(RegionOperand {
            name: &entry.name,
            memory: entry.memory,
            region: TensorRegion {
                tensor: id,
                shape: counts.clone(),
                layout: Layout::Pattern {
                    offset,
                    steps: pattern.iter().map(|&[step, _]| step).collect(),
                    storage: entry.shape.clone(),
                },
            },
            kept: counts,
        })
    }

    /// `nl.broadcast_to(tensor, shape)`: `tensor` read at `shape` through a pattern
    /// stepping 0 along each dimension it repeats, so it may repeat a tile's partition.
    fn broadcast(
        &self,
        name: &TensorName,
        target: &[u64],
    ) -> Result<RegionOperand<'_>, StatementError> {
        let id = self.ids[name];
        let entry = &self.entries[id];
        let extents = &entry.shape.0;
        let broadcastable = extents.len() == target.len()
            && extents
                .iter()
                .zip(target)
                .all(|(&from, &to)| from == to || from == 1);
        if !broadcastable {
            return Err(StatementError::BroadcastShape {
                tensor: name.clone(),
                shape: entry.shape.clone(),
                target: Shape(target.to_vec()),
            });
        }
        let mut steps = vec![0; extents.len()];
        let mut stride = 1;
        for (dimension, &extent) in extents.iter().enumerate().rev() {
            if extent == target[dimension] {
                steps[dimension] = stride;
            }
            stride *= extent;
        }
        let shape = Shape(target.to_vec());
        Ok(RegionOperand {
            name: &entry.name,
            memory: entry.memory,
            region: TensorRegion {
                tensor: id,
                shape: shape.clone(),
                layout: Layout::Pattern {
                    offset: 0,
                    steps,
                    storage: entry.shape.clone(),
                },
            },
            kept: shape,
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
        if tile.region.indexes_first_dimension() {
            return Err(StatementError::PartitionIndexed(tile.name.clone()));
        }
        Ok(tile)
    }

    /// Check that `address=` places every on-chip tile or none of them.
    fn placed_all_or_none(&self) -> Result<(), LowerError> {
        let tiles = self
            .entries
            .values()
            .filter(|entry| entry.memory != Memory::Hbm);
        let (placed, unplaced): (Vec<_>, Vec<_>) = tiles.partition(|entry| entry.address.is_some());
        match (placed.first(), unplaced.first()) {
            (Some(placed), Some(unplaced)) => Err(LowerError::MixedAllocation {
                placed: placed.name.clone(),
                unplaced: unplaced.name.clone(),
            }),
            _ => Ok(()),
        }
    }

    /// The tensor a kernel returns: one it allocates in HBM, not an argument or a tile.
    fn returned(&self, name: &TensorName) -> Result<TensorId, LowerError> {
        let id = self.ids[name];
        let entry = &self.entries[id];
        if (entry.memory, &entry.initial) != (Memory::Hbm, &Initial::Uninitialized) {
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
            address: entry.address,
        })
    }
}
