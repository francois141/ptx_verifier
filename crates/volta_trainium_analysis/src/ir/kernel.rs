//! A lowered kernel: its parameters, tensors, instructions and returned tensor. `Display`
//! renders it the way the fixtures' expected `.ir` files hold it.

use std::fmt;

use id_collections::IdVec;

use super::{InstrId, LoweredInstr, ScalarOperand, Tensor, TensorId, TensorRegion};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LoweredKernel {
    pub name: String,
    /// The arguments in order, each an HBM tensor.
    pub params: Vec<TensorId>,
    pub tensors: IdVec<TensorId, Tensor>,
    pub instructions: IdVec<InstrId, LoweredInstr>,
    /// The HBM tensor it allocates and returns, if any.
    pub returned: Option<TensorId>,
}

impl fmt::Display for LoweredKernel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = |tensor: TensorId| self.tensors[tensor].name.as_str();
        let scalar = |operand: ScalarOperand| match operand {
            ScalarOperand::Constant(value) => value.to_string(),
            ScalarOperand::Broadcast(tensor) => name(tensor).to_string(),
        };
        let region = |region: &TensorRegion| {
            let whole = region.start.0.iter().all(|&start| start == 0)
                && region.shape == self.tensors[region.tensor].shape;
            if whole {
                return name(region.tensor).to_string();
            }
            let dims: Vec<String> = region
                .start
                .0
                .iter()
                .zip(&region.shape.0)
                .map(|(start, extent)| format!("{start}:{}", start + extent))
                .collect();
            format!("{}[{}]", name(region.tensor), dims.join(", "))
        };

        let params: Vec<&str> = self.params.iter().map(|&param| name(param)).collect();
        write!(f, "kernel {}({})", self.name, params.join(", "))?;
        match self.returned {
            Some(returned) => writeln!(f, " -> {}", name(returned))?,
            None => writeln!(f)?,
        }

        for tensor in self.tensors.values() {
            let memory = tensor.memory.name();
            writeln!(f, "  {}: {memory}{}", tensor.name, tensor.shape)?;
        }

        for instruction in self.instructions.values() {
            match instruction.clone() {
                LoweredInstr::Mov { dst, src } => {
                    writeln!(f, "  {} = mov({})", region(&dst), region(&src))?
                }
                LoweredInstr::Arith { op, dst, lhs, rhs } => writeln!(
                    f,
                    "  {} = {}({}, {})",
                    name(dst),
                    op.name(),
                    name(lhs),
                    name(rhs)
                )?,
                LoweredInstr::Activation { func, dst, data } => {
                    writeln!(f, "  {} = {}({})", name(dst), func.name(), name(data))?
                }
                LoweredInstr::ActivationReduce {
                    func,
                    dst,
                    data,
                    reduce_op,
                    reduce_res,
                } => writeln!(
                    f,
                    "  {}, {} = {}({}) reduce {}",
                    name(dst),
                    name(reduce_res),
                    func.name(),
                    name(data),
                    reduce_op.name()
                )?,
                LoweredInstr::Reduce { op, dst, data } => {
                    writeln!(f, "  {} = reduce {}({})", name(dst), op.name(), name(data))?
                }
                LoweredInstr::TensorScalar {
                    dst,
                    data,
                    first,
                    second,
                } => {
                    let mut expr = format!(
                        "{}({}, {})",
                        first.op.name(),
                        name(data),
                        scalar(first.operand)
                    );
                    if let Some(step) = second {
                        expr = format!("{}({}, {})", step.op.name(), expr, scalar(step.operand));
                    }
                    writeln!(f, "  {} = {expr}", name(dst))?
                }
                LoweredInstr::Matmul {
                    dst,
                    stationary,
                    moving,
                } => writeln!(
                    f,
                    "  {} = matmul({}, {})",
                    name(dst),
                    name(stationary),
                    name(moving)
                )?,
                LoweredInstr::Transpose { dst, data } => {
                    writeln!(f, "  {} = transpose({})", name(dst), name(data))?
                }
            }
        }
        Ok(())
    }
}
