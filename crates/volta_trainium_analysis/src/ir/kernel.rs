//! A lowered kernel: its parameters, tensors, instructions and returned tensor. `Display`
//! renders it the way the fixtures' expected `.ir` files hold it.

use std::fmt;

use id_collections::IdVec;

use super::{
    Accumulation, InstrId, LoweredInstr, Reduction, ScalarOperand, Selection, Sign, Tensor,
    TensorId, TensorRegion,
};

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
        let region = |region: &TensorRegion| {
            let whole = region.start.0.iter().all(|&start| start == 0)
                && region.shape == self.tensors[region.tensor].shape
                && region.selections.iter().all(|&s| s == Selection::Slice);
            if whole {
                return name(region.tensor).to_string();
            }
            let dims: Vec<String> = region
                .start
                .0
                .iter()
                .zip(&region.shape.0)
                .zip(&region.selections)
                .map(|((start, extent), selection)| match selection {
                    Selection::Index => start.to_string(),
                    Selection::Slice => format!("{start}:{}", start + extent),
                })
                .collect();
            format!("{}[{}]", name(region.tensor), dims.join(", "))
        };
        let scalar = |operand: &ScalarOperand| match operand {
            ScalarOperand::Constant(value) => value.to_string(),
            ScalarOperand::Broadcast(tile) => region(tile),
        };

        // `dst = expr`, or `dst, res = expr reduce op` with a reduction.
        let reduced = |dst: String, expr: String, reduce: Option<&Reduction>| match reduce {
            Some(Reduction { op, res }) => {
                format!("{dst}, {} = {expr} reduce {}", region(res), op.name())
            }
            None => format!("{dst} = {expr}"),
        };

        let params: Vec<&str> = self.params.iter().map(|&param| name(param)).collect();
        write!(f, "kernel {}({})", self.name, params.join(", "))?;
        match self.returned {
            Some(returned) => writeln!(f, " -> {}", name(returned))?,
            None => writeln!(f)?,
        }

        for tensor in self.tensors.values() {
            let memory = tensor.memory.name();
            write!(f, "  {}: {memory}{}", tensor.name, tensor.shape)?;
            match tensor.address {
                Some(address) => writeln!(
                    f,
                    " at ({}, {}), {} bytes each",
                    address.partition, address.offset, address.element_bytes
                )?,
                None => writeln!(f)?,
            }
        }

        for instruction in self.instructions.values() {
            match instruction {
                LoweredInstr::Mov { dst, src } => {
                    writeln!(f, "  {} = mov({})", region(dst), region(src))?
                }
                LoweredInstr::Arith { op, dst, lhs, rhs } => writeln!(
                    f,
                    "  {} = {}({}, {})",
                    region(dst),
                    op.name(),
                    region(lhs),
                    region(rhs)
                )?,
                LoweredInstr::Activation {
                    func,
                    dst,
                    data,
                    bias,
                    reduce,
                } => {
                    let data = match bias {
                        Some(bias) => format!("add({}, {})", region(data), scalar(bias)),
                        None => region(data),
                    };
                    let expr = format!("{}({data})", func.name());
                    writeln!(f, "  {}", reduced(region(dst), expr, reduce.as_ref()))?
                }
                LoweredInstr::Memset { dst, value } => {
                    writeln!(f, "  {} = memset({value})", region(dst))?
                }
                LoweredInstr::Reduce {
                    op,
                    dst,
                    data,
                    sign,
                } => {
                    let reduce = format!("reduce {}({})", op.name(), region(data));
                    match sign {
                        Sign::Kept => writeln!(f, "  {} = {reduce}", region(dst))?,
                        Sign::Negated => writeln!(f, "  {} = neg({reduce})", region(dst))?,
                    }
                }
                LoweredInstr::TensorScalar {
                    dst,
                    data,
                    first,
                    second,
                    reduce,
                } => {
                    let mut expr = format!(
                        "{}({}, {})",
                        first.op.name(),
                        region(data),
                        scalar(&first.operand)
                    );
                    if let Some(step) = second {
                        expr = format!("{}({}, {})", step.op.name(), expr, scalar(&step.operand));
                    }
                    writeln!(f, "  {}", reduced(region(dst), expr, reduce.as_ref()))?
                }
                LoweredInstr::Matmul {
                    dst,
                    stationary,
                    moving,
                    accumulation,
                } => {
                    let accumulate = match accumulation {
                        Accumulation::FirstOverwrites => "",
                        Accumulation::Overwrite => ", accumulate=False",
                        Accumulation::Accumulate => ", accumulate=True",
                    };
                    writeln!(
                        f,
                        "  {} = matmul({}, {}{accumulate})",
                        region(dst),
                        region(stationary),
                        region(moving)
                    )?
                }
                LoweredInstr::Transpose { dst, data } => {
                    writeln!(f, "  {} = transpose({})", region(dst), region(data))?
                }
            }
        }
        Ok(())
    }
}
