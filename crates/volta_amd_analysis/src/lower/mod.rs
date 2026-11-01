//! Lowering parsed AMD assembly into typed instructions for symbolic execution.

use std::fmt;

use id_collections::IdVec;

use crate::frontend::ast::{Counter, Instruction, Kernel, Operand, RegFile};
use crate::ir::{GlobalAddress, LoweredInstr, LoweredKernel, ScalarSrc, Sgpr, Src0, Vgpr, Vop3Src};

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
    if kernel.target.split(':').next() != Some("amdgcn-amd-amdhsa--gfx950") {
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
        instructions: IdVec::from_vec(instructions),
        descriptor: kernel.descriptor.clone(),
    })
}

fn lower_instruction(instruction: &Instruction) -> Result<LoweredInstr, &'static str> {
    use LoweredInstr::*;

    match (instruction.opcode.as_str(), instruction.operands.as_slice()) {
        ("s_load_dwordx2", [dst, base, offset]) => Ok(ScalarLoadDwordx2 {
            dst: sgprs(dst).ok_or("expected an aligned SGPR destination pair")?,
            base: sgprs(base).ok_or("expected an aligned SGPR base pair")?,
            offset: immediate(offset, 0xfffff)
                .ok_or("expected a nonnegative 20-bit byte offset")?,
        }),
        ("s_load_dwordx4", [dst, base, offset]) => Ok(ScalarLoadDwordx4 {
            dst: sgprs(dst).ok_or("expected an aligned four-SGPR destination")?,
            base: sgprs(base).ok_or("expected an aligned SGPR base pair")?,
            offset: immediate(offset, 0xfffff)
                .ok_or("expected a nonnegative 20-bit byte offset")?,
        }),
        ("s_mov_b32", [dst, src]) => Ok(MovScalar32 {
            dst: sgpr(dst).ok_or("expected one destination SGPR")?,
            src: scalar_source(src).ok_or("expected an SGPR or a 32-bit constant source")?,
        }),
        ("v_lshlrev_b32_e32", [dst, shift, src]) => Ok(Shl32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: vgpr(src).ok_or("expected one source VGPR")?,
            shift: immediate(shift, u32::MAX).ok_or("expected a 32-bit immediate shift input")?,
        }),
        ("v_and_b32_e32", [dst, src0, src1]) => Ok(And32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: first_source(src0)?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("v_or_b32_e32", [dst, src0, src1]) => Ok(Or32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: first_source(src0)?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("v_add_f32_e32", [dst, src0, src1]) => Ok(AddF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: first_source(src0)?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("v_mul_f32_e32", [dst, src0, src1]) => Ok(MulF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: first_source(src0)?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("v_max_f32_e32", [dst, src0, src1]) => Ok(MaxF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: first_source(src0)?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("v_exp_f32_e32", [dst, src]) => Ok(Exp2F32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: first_source(src)?,
        }),
        ("v_rcp_f32_e32", [dst, src]) => Ok(RcpF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: first_source(src)?,
        }),
        ("v_cmp_lt_f32_e32", [vcc, src0, src1]) => {
            expect_vcc(vcc)?;
            Ok(CmpLtF32 {
                src0: first_source(src0)?,
                src1: vgpr(src1).ok_or("expected one VGPR second source")?,
            })
        }
        ("v_cndmask_b32_e32", [dst, src0, src1, vcc]) => {
            expect_vcc(vcc)?;
            Ok(CndMask32 {
                dst: vgpr(dst).ok_or("expected one destination VGPR")?,
                src0: first_source(src0)?,
                src1: vgpr(src1).ok_or("expected one VGPR second source")?,
            })
        }
        ("v_fma_f32", [dst, src0, src1, src2]) => Ok(FmaF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: vop3_src(src0).ok_or("expected a VGPR or an inline constant first source")?,
            src1: vop3_src(src1).ok_or("expected a VGPR or an inline constant second source")?,
            src2: vop3_src(src2).ok_or("expected a VGPR or an inline constant third source")?,
        }),
        // VOP2 also accepts an SGPR or a constant as src0; only VGPR sources are supported.
        ("v_fmac_f32_e32", [dst, src0, src1]) => Ok(FmacF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: vgpr(src0).ok_or("expected one VGPR first source")?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("global_load_dword", [dst, vaddr, saddr, offset @ ..]) => Ok(GlobalLoadDword {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_load_dwordx3", [dst, vaddr, saddr, offset @ ..]) => Ok(GlobalLoadDwordx3 {
            dst: vgprs(dst).ok_or("expected an even-aligned three-VGPR destination")?,
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_load_dwordx4", [dst, vaddr, saddr, offset @ ..]) => Ok(GlobalLoadDwordx4 {
            dst: vgprs(dst).ok_or("expected an even-aligned four-VGPR destination")?,
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_store_dword", [vaddr, src, saddr, offset @ ..]) => Ok(GlobalStoreDword {
            src: vgpr(src).ok_or("expected one source VGPR")?,
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("s_waitcnt", operands) => lower_wait(operands),
        ("s_nop", [wait_states]) => {
            immediate(wait_states, 15).ok_or("expected a wait count from 0 to 15")?;
            Ok(Nop)
        }
        ("s_endpgm", []) => Ok(EndPgm),
        (
            "s_load_dwordx2"
            | "s_load_dwordx4"
            | "s_mov_b32"
            | "v_lshlrev_b32_e32"
            | "v_and_b32_e32"
            | "v_or_b32_e32"
            | "v_add_f32_e32"
            | "v_mul_f32_e32"
            | "v_max_f32_e32"
            | "v_exp_f32_e32"
            | "v_rcp_f32_e32"
            | "v_cmp_lt_f32_e32"
            | "v_cndmask_b32_e32"
            | "v_fma_f32"
            | "v_fmac_f32_e32"
            | "global_load_dword"
            | "global_load_dwordx3"
            | "global_load_dwordx4"
            | "global_store_dword"
            | "s_nop"
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

fn sgpr(operand: &Operand) -> Option<Sgpr> {
    sgprs(operand).map(|[reg]| reg)
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

/// gfx950 requires VGPR tuples to start at an even register (LLVM 21.1.8's `validateVGPRAlign`).
fn vgprs<const N: usize>(operand: &Operand) -> Option<[Vgpr; N]> {
    let Operand::Reg {
        file: RegFile::Vector,
        first,
        last,
    } = *operand
    else {
        return None;
    };
    let first = u8::try_from(first).ok()?;
    let last = u8::try_from(last).ok()?;
    let count = usize::from(last.checked_sub(first)?) + 1;
    if count != N || first % 2 != 0 {
        return None;
    }
    Some(std::array::from_fn(|i| Vgpr(first + i as u8)))
}

/// Before GFX10, VOP3 takes no literal, only inline constants (LLVM 21.1.8's
/// `validateVOPLiteral`), of which the frontend reads the integers 0 to 64 and the floats.
fn vop3_src(operand: &Operand) -> Option<Vop3Src> {
    match operand {
        Operand::Imm(value) if *value <= 64 => Some(Vop3Src::Inline(*value as u32)),
        Operand::InlineFloat(bits) => Some(Vop3Src::Inline(*bits)),
        _ => vgpr(operand).map(Vop3Src::Vgpr),
    }
}

/// Only src0 of a VOP2 encoding can name an SGPR or a 32-bit literal; src1 is a VGPR.
fn first_source(operand: &Operand) -> Result<Src0, &'static str> {
    if let Some(bits) = constant(operand) {
        return Ok(Src0::Const(bits));
    }
    if let Some(reg) = vgpr(operand) {
        return Ok(Src0::Vgpr(reg));
    }
    sgpr(operand)
        .map(Src0::Sgpr)
        .ok_or("expected a VGPR, an SGPR or a 32-bit constant first source")
}

fn scalar_source(operand: &Operand) -> Option<ScalarSrc> {
    constant(operand)
        .map(ScalarSrc::Const)
        .or_else(|| sgpr(operand).map(ScalarSrc::Sgpr))
}

/// An e32 comparison writes, and `v_cndmask_b32_e32` reads, VCC implicitly; Clang still prints it.
fn expect_vcc(operand: &Operand) -> Result<(), &'static str> {
    match operand {
        Operand::Vcc => Ok(()),
        _ => Err("expected vcc"),
    }
}

/// Global offsets are signed 13-bit before GFX10 (LLVM 21.1.8's `validateFlatOffset`).
fn global_address(
    vaddr: &Operand,
    saddr: &Operand,
    offset: &[Operand],
) -> Result<GlobalAddress, &'static str> {
    let offset = match offset {
        [] => 0,
        [Operand::Offset(offset)] => i16::try_from(*offset)
            .ok()
            .filter(|offset| (-4096..=4095).contains(offset))
            .ok_or("expected a signed 13-bit byte offset")?,
        _ => return Err("unsupported operand count"),
    };
    Ok(GlobalAddress {
        vaddr: vgpr(vaddr).ok_or("expected one address VGPR")?,
        saddr: sgprs(saddr).ok_or("expected an aligned SGPR base pair")?,
        offset,
    })
}

/// A 32-bit literal or an inline float, as the 32 bits of the operand.
fn constant(operand: &Operand) -> Option<u32> {
    match operand {
        Operand::InlineFloat(bits) => Some(*bits),
        _ => immediate(operand, u32::MAX),
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
