//! A lowered kernel: its parameters, tensors and instructions. `Display`
//! renders it the way the fixtures' expected `.ir` files hold it.

use std::fmt;

use id_collections::IdVec;

use super::{InstrId, LoweredInstr, Tensor, TensorId};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LoweredKernel {
    pub name: String,
    /// The arguments in order, each an HBM tensor.
    pub params: Vec<TensorId>,
    pub tensors: IdVec<TensorId, Tensor>,
    pub instructions: IdVec<InstrId, LoweredInstr>,
}

impl fmt::Display for LoweredKernel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = |tensor: TensorId| self.tensors[tensor].name.as_str();

        let params: Vec<&str> = self.params.iter().map(|&param| name(param)).collect();
        writeln!(f, "kernel {}({})", self.name, params.join(", "))?;

        for tensor in self.tensors.values() {
            let memory = tensor.memory.name();
            writeln!(f, "  {}: {memory}{}", tensor.name, tensor.shape)?;
        }

        for instruction in self.instructions.values() {
            match *instruction {
                LoweredInstr::Mov { dst, src } => {
                    writeln!(f, "  {} = mov({})", name(dst), name(src))?
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
                LoweredInstr::Transpose { dst, data } => {
                    writeln!(f, "  {} = transpose({})", name(dst), name(data))?
                }
            }
        }
        Ok(())
    }
}
