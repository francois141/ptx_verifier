//! Lowering parsed AMD assembly into typed instructions for symbolic execution.

#[cfg(test)]
mod tests;

use std::fmt;

use crate::frontend::ast::{Counter, Instruction, Kernel, Operand, RegFile};
use crate::ir::{LoweredInstr, LoweredKernel, Sgpr, Vgpr};

#[derive(Debug, PartialEq, Eq)]
pub enum LowerError {
    UnsupportedTarget {
        target: String,
    },
    Instruction {
        /// Zero-based index in the parsed kernel body.
        index: usize,
        opcode: String,
        reason: &'static str,
    },
}

impl fmt::Display for LowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::UnsupportedTarget { target } => write!(f, "unsupported target {target:?}"),
            Self::Instruction {
                index,
                opcode,
                reason,
            } => {
                write!(f, "instruction {index} ({opcode}): {reason}")
            }
        }
    }
}

impl std::error::Error for LowerError {}

/// Lower a parsed kernel into typed instructions, preserving order and launch metadata.
/// Return `LowerError` for unsupported targets, instructions, or operand forms.
pub fn lower_kernel(kernel: &Kernel) -> Result<LoweredKernel, LowerError> {
    if !supported_target(&kernel.target) {
        return Err(LowerError::UnsupportedTarget {
            target: kernel.target.clone(),
        });
    }
    let instructions = kernel
        .instructions
        .iter()
        .enumerate()
        .map(|(index, instruction)| {
            lower_instruction(instruction).map_err(|reason| LowerError::Instruction {
                index,
                opcode: instruction.opcode.clone(),
                reason,
            })
        })
        .collect::<Result<_, _>>()?;
    Ok(LoweredKernel {
        name: kernel.name.clone(),
        target: kernel.target.clone(),
        instructions,
        descriptor: kernel.descriptor.clone(),
    })
}

fn supported_target(target: &str) -> bool {
    let mut parts = target.split(':');
    if parts.next() != Some("amdgcn-amd-amdhsa--gfx950") {
        return false;
    }
    let (mut xnack, mut sramecc) = (false, false);
    for feature in parts {
        let present = match feature {
            "xnack+" | "xnack-" => &mut xnack,
            "sramecc+" | "sramecc-" => &mut sramecc,
            _ => return false,
        };
        if std::mem::replace(present, true) {
            return false;
        }
    }
    true
}

fn lower_instruction(instruction: &Instruction) -> Result<LoweredInstr, &'static str> {
    use LoweredInstr::*;

    match (instruction.opcode.as_str(), instruction.operands.as_slice()) {
        ("s_load_dwordx4", [dst, base, offset]) => Ok(ScalarLoadDwordx4 {
            dst: sgprs(dst).ok_or("expected an aligned four-SGPR destination")?,
            base: sgprs(base).ok_or("expected an aligned SGPR base pair")?,
            offset: immediate(offset, 0xfffff)
                .ok_or("expected a nonnegative 20-bit byte offset")?,
        }),
        ("v_lshlrev_b32_e32", [dst, shift, src]) => Ok(Shl32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: vgpr(src).ok_or("expected one source VGPR")?,
            shift: immediate(shift, u32::MAX).ok_or("expected a 32-bit immediate shift input")?,
        }),
        ("global_load_dword", [dst, vaddr, saddr]) => Ok(GlobalLoadDword {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            vaddr: vgpr(vaddr).ok_or("expected one address VGPR")?,
            saddr: sgprs(saddr).ok_or("expected an aligned SGPR base pair")?,
        }),
        ("global_store_dword", [vaddr, src, saddr]) => Ok(GlobalStoreDword {
            vaddr: vgpr(vaddr).ok_or("expected one address VGPR")?,
            src: vgpr(src).ok_or("expected one source VGPR")?,
            saddr: sgprs(saddr).ok_or("expected an aligned SGPR base pair")?,
        }),
        ("s_waitcnt", operands) => lower_wait(operands),
        ("s_endpgm", []) => Ok(EndPgm),
        (
            "s_load_dwordx4" | "v_lshlrev_b32_e32" | "global_load_dword" | "global_store_dword"
            | "s_endpgm",
            _,
        ) => Err("unsupported operand count"),
        _ => Err("unsupported instruction"),
    }
}

fn sgprs<const N: usize>(operand: &Operand) -> Option<[Sgpr; N]> {
    let Operand::Reg {
        file: RegFile::Scalar,
        first,
        last,
    } = operand
    else {
        return None;
    };
    if last.checked_sub(*first)? != N as u32 - 1 || *first % N as u32 != 0 || *last > 101 {
        return None;
    }
    Some(std::array::from_fn(|i| Sgpr((*first + i as u32) as u8)))
}

fn vgpr(operand: &Operand) -> Option<Vgpr> {
    match operand {
        Operand::Reg {
            file: RegFile::Vector,
            first,
            last,
        } if first == last => u8::try_from(*first).ok().map(Vgpr),
        _ => None,
    }
}

fn immediate(operand: &Operand, max: u32) -> Option<u32> {
    match operand {
        Operand::Imm(value) if *value <= u64::from(max) => Some(*value as u32),
        _ => None,
    }
}

fn lower_wait(operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    if operands.is_empty() {
        return Err("expected vmcnt(n) or lgkmcnt(n)");
    }
    let (mut vmcnt, mut lgkmcnt) = (None, None);
    for operand in operands {
        let (slot, value) = match operand {
            Operand::Wait {
                counter: Counter::Vm,
                value,
            } if *value <= 63 => (&mut vmcnt, *value),
            Operand::Wait {
                counter: Counter::Lgkm,
                value,
            } if *value <= 15 => (&mut lgkmcnt, *value),
            _ => return Err("unsupported wait counter or value"),
        };
        if slot.replace(value as u8).is_some() {
            return Err("duplicate wait counter");
        }
    }
    Ok(LoweredInstr::WaitCnt { vmcnt, lgkmcnt })
}
