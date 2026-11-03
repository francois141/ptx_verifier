//! Lowering parsed AMD assembly into typed instructions for symbolic execution.

use std::collections::BTreeMap;
use std::fmt;

use id_collections::IdVec;

use crate::frontend::ast::{Counter, Instruction, Kernel, Operand, RegFile};
use crate::ir::{
    self, Agpr, BranchCondition, GlobalAddress, GlobalLoadDst, GlobalStoreSrc, InstrId, LaneReg,
    LaneRegs, LoweredInstr, LoweredKernel, MfmaSrcC, ScalarCmpOp, ScalarDst64, ScalarLoadDst,
    ScalarSrc, ScalarSrc64, Sgpr, Src0, Vgpr, Vop3Src,
};

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
            lower_instruction(instruction, &kernel.labels).map_err(|reason| {
                LowerError::Instruction {
                    index,
                    opcode: instruction.opcode.clone(),
                    reason,
                }
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

fn lower_instruction(
    instruction: &Instruction,
    labels: &BTreeMap<String, usize>,
) -> Result<LoweredInstr, &'static str> {
    use LoweredInstr::*;

    match (instruction.opcode.as_str(), instruction.operands.as_slice()) {
        ("s_movk_i32", [dst, src]) => Ok(MovScalar32 {
            dst: sgpr(dst).ok_or("expected one destination SGPR")?,
            src: ScalarSrc::Const(simm16(src).ok_or("expected a 16-bit integer")?),
        }),
        ("s_mov_b64", [dst, src]) => Ok(MovScalar64 {
            dst: scalar_dst64(dst)?,
            src: scalar_source64(src)?,
        }),
        ("s_abs_i32", [dst, src]) => Ok(AbsScalar32 {
            dst: sgpr(dst).ok_or("expected one destination SGPR")?,
            src: scalar_source(src).ok_or("expected an SGPR or a 32-bit constant source")?,
        }),
        ("s_add_u32", operands) => lower_scalar_op32(ir::ScalarOp32::AddU32, operands),
        ("s_addc_u32", operands) => lower_scalar_op32(ir::ScalarOp32::AddcU32, operands),
        ("s_add_i32", operands) => lower_scalar_op32(ir::ScalarOp32::AddI32, operands),
        ("s_sub_i32", operands) => lower_scalar_op32(ir::ScalarOp32::SubI32, operands),
        ("s_mul_i32", operands) => lower_scalar_op32(ir::ScalarOp32::MulI32, operands),
        ("s_mul_hi_u32", operands) => lower_scalar_op32(ir::ScalarOp32::MulHiU32, operands),
        ("s_and_b32", operands) => lower_scalar_op32(ir::ScalarOp32::AndB32, operands),
        ("s_xor_b32", operands) => lower_scalar_op32(ir::ScalarOp32::XorB32, operands),
        ("s_lshl_b32", operands) => lower_scalar_op32(ir::ScalarOp32::LShlB32, operands),
        ("s_lshr_b32", operands) => lower_scalar_op32(ir::ScalarOp32::LShrB32, operands),
        ("s_ashr_i32", operands) => lower_scalar_op32(ir::ScalarOp32::AShrI32, operands),
        ("s_cselect_b32", operands) => lower_scalar_op32(ir::ScalarOp32::CSelectB32, operands),
        ("s_and_b64", operands) => lower_scalar_op64(ir::ScalarOp64::AndB64, operands),
        ("s_andn2_b64", operands) => lower_scalar_op64(ir::ScalarOp64::AndN2B64, operands),
        ("s_cselect_b64", operands) => lower_scalar_op64(ir::ScalarOp64::CSelectB64, operands),
        ("s_lshl_b64", [dst, src, shift]) => Ok(LShlScalar64 {
            dst: sgprs(dst).ok_or("expected an aligned SGPR destination pair")?,
            src: scalar_source64(src)?,
            shift: scalar_source(shift).ok_or("expected an SGPR or a 32-bit constant count")?,
        }),
        ("s_cmp_gt_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GtI32, operands),
        ("s_cmp_ge_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GeI32, operands),
        ("s_cmp_lt_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LtU32, operands),
        ("s_cmp_ge_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GeU32, operands),
        ("s_bitcmp1_b32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::BitCmp1B32, operands),
        ("s_branch", [target]) => Ok(Branch {
            target: branch_target(target, labels)?,
        }),
        ("s_cbranch_scc1", [target]) => Ok(CondBranch {
            condition: BranchCondition::Scc1,
            target: branch_target(target, labels)?,
        }),
        ("s_cbranch_vccnz", [target]) => Ok(CondBranch {
            condition: BranchCondition::VccNz,
            target: branch_target(target, labels)?,
        }),
        ("s_cbranch_execz", [target]) => Ok(CondBranch {
            condition: BranchCondition::ExecZ,
            target: branch_target(target, labels)?,
        }),
        ("s_barrier", []) => Ok(Barrier),
        ("v_readfirstlane_b32", [dst, src]) => Ok(ReadFirstLane {
            dst: sgpr(dst).ok_or("expected one destination SGPR")?,
            src: vgpr(src).ok_or("expected one source VGPR")?,
        }),
        ("s_load_dword", [dst, base, offset]) => lower_scalar_load(
            sgpr(dst)
                .map(ScalarLoadDst::Dword)
                .ok_or("expected one destination SGPR")?,
            base,
            offset,
        ),
        ("s_load_dwordx2", [dst, base, offset]) => lower_scalar_load(
            sgprs(dst)
                .map(ScalarLoadDst::Dwordx2)
                .ok_or("expected an aligned SGPR destination pair")?,
            base,
            offset,
        ),
        ("s_load_dwordx4", [dst, base, offset]) => lower_scalar_load(
            sgprs(dst)
                .map(ScalarLoadDst::Dwordx4)
                .ok_or("expected an aligned four-SGPR destination")?,
            base,
            offset,
        ),
        ("s_load_dwordx8", [dst, base, offset]) => lower_scalar_load(
            sgprs(dst)
                .map(ScalarLoadDst::Dwordx8)
                .ok_or("expected an aligned eight-SGPR destination")?,
            base,
            offset,
        ),
        ("s_mov_b32", [dst, src]) => Ok(MovScalar32 {
            dst: sgpr(dst).ok_or("expected one destination SGPR")?,
            src: scalar_source(src).ok_or("expected an SGPR or a 32-bit constant source")?,
        }),
        ("v_and_b32_e32", operands) => lower_bin_op(ir::BinOp::And32, operands),
        ("v_or_b32_e32", operands) => lower_bin_op(ir::BinOp::Or32, operands),
        ("v_xor_b32_e32", operands) => lower_bin_op(ir::BinOp::Xor32, operands),
        ("v_lshlrev_b32_e32", operands) => lower_bin_op(ir::BinOp::LShlRev32, operands),
        ("v_lshrrev_b32_e32", operands) => lower_bin_op(ir::BinOp::LShrRev32, operands),
        ("v_add_u32_e32", operands) => lower_bin_op(ir::BinOp::AddU32, operands),
        ("v_sub_u32_e32", operands) => lower_bin_op(ir::BinOp::SubU32, operands),
        ("v_subrev_u32_e32", operands) => lower_bin_op(ir::BinOp::SubRevU32, operands),
        ("v_ashrrev_i32_e32", operands) => lower_bin_op(ir::BinOp::AShrRevI32, operands),
        ("v_xnor_b32_e32", operands) => lower_bin_op(ir::BinOp::Xnor32, operands),
        ("v_min_i32_e32", operands) => lower_bin_op(ir::BinOp::MinI32, operands),
        ("v_max_i32_e32", operands) => lower_bin_op(ir::BinOp::MaxI32, operands),
        ("v_min_u32_e32", operands) => lower_bin_op(ir::BinOp::MinU32, operands),
        ("v_max_u32_e32", operands) => lower_bin_op(ir::BinOp::MaxU32, operands),
        ("v_mul_u32_u24_e32", operands) => lower_bin_op(ir::BinOp::MulU32U24, operands),
        ("v_mul_hi_u32_u24_e32", operands) => lower_bin_op(ir::BinOp::MulHiU32U24, operands),
        ("v_mul_i32_i24_e32", operands) => lower_bin_op(ir::BinOp::MulI32I24, operands),
        ("v_mul_hi_i32_i24_e32", operands) => lower_bin_op(ir::BinOp::MulHiI32I24, operands),
        ("v_add_f32_e32", operands) => lower_bin_op(ir::BinOp::AddF32, operands),
        ("v_sub_f32_e32", operands) => lower_bin_op(ir::BinOp::SubF32, operands),
        ("v_subrev_f32_e32", operands) => lower_bin_op(ir::BinOp::SubRevF32, operands),
        ("v_mul_f32_e32", operands) => lower_bin_op(ir::BinOp::MulF32, operands),
        ("v_min_f32_e32", operands) => lower_bin_op(ir::BinOp::MinF32, operands),
        ("v_max_f32_e32", operands) => lower_bin_op(ir::BinOp::MaxF32, operands),
        ("v_add_lshl_u32", operands) => lower_ternary_op(ir::TernaryOp::AddLShl32, operands),
        ("v_bfe_u32", operands) => lower_ternary_op(ir::TernaryOp::Bfe32, operands),
        ("v_lshl_or_b32", operands) => lower_ternary_op(ir::TernaryOp::LShlOr32, operands),
        ("v_or3_b32", operands) => lower_ternary_op(ir::TernaryOp::Or3_32, operands),
        ("v_lshl_add_u32", operands) => lower_ternary_op(ir::TernaryOp::LShlAdd32, operands),
        ("v_add3_u32", operands) => lower_ternary_op(ir::TernaryOp::Add3_32, operands),
        ("v_and_or_b32", operands) => lower_ternary_op(ir::TernaryOp::AndOr32, operands),
        ("v_xad_u32", operands) => lower_ternary_op(ir::TernaryOp::Xad32, operands),
        ("v_bfi_b32", operands) => lower_ternary_op(ir::TernaryOp::Bfi32, operands),
        ("v_bfe_i32", operands) => lower_ternary_op(ir::TernaryOp::BfeI32, operands),
        ("v_alignbit_b32", operands) => lower_ternary_op(ir::TernaryOp::AlignBit32, operands),
        ("v_alignbyte_b32", operands) => lower_ternary_op(ir::TernaryOp::AlignByte32, operands),
        ("v_mad_u32_u24", operands) => lower_ternary_op(ir::TernaryOp::MadU32U24, operands),
        ("v_mad_i32_i24", operands) => lower_ternary_op(ir::TernaryOp::MadI32I24, operands),
        ("v_min3_i32", operands) => lower_ternary_op(ir::TernaryOp::Min3I32, operands),
        ("v_min3_u32", operands) => lower_ternary_op(ir::TernaryOp::Min3U32, operands),
        ("v_max3_i32", operands) => lower_ternary_op(ir::TernaryOp::Max3I32, operands),
        ("v_max3_u32", operands) => lower_ternary_op(ir::TernaryOp::Max3U32, operands),
        ("v_med3_i32", operands) => lower_ternary_op(ir::TernaryOp::Med3I32, operands),
        ("v_med3_u32", operands) => lower_ternary_op(ir::TernaryOp::Med3U32, operands),
        ("v_sad_u32", operands) => lower_ternary_op(ir::TernaryOp::SadU32, operands),
        // The IEEE 754-2019 `minimum3`/`maximum3` differ from `min3`/`max3` only on NaN and
        // signed zeros, neither of which Volta's reals have.
        ("v_min3_f32" | "v_minimum3_f32", operands) => {
            lower_ternary_op(ir::TernaryOp::Min3F32, operands)
        }
        ("v_max3_f32" | "v_maximum3_f32", operands) => {
            lower_ternary_op(ir::TernaryOp::Max3F32, operands)
        }
        ("v_med3_f32", operands) => lower_ternary_op(ir::TernaryOp::Med3F32, operands),
        ("v_bitop3_b32", [operands @ .., Operand::BitOp3(table)]) => {
            lower_ternary_op(ir::TernaryOp::BitOp3(*table), operands)
        }
        ("v_exp_f32_e32", operands) => lower_unary_op(ir::UnaryOp::Exp2F32, operands),
        ("v_log_f32_e32", operands) => lower_unary_op(ir::UnaryOp::Log2F32, operands),
        ("v_rcp_f32_e32", operands) => lower_unary_op(ir::UnaryOp::RcpF32, operands),
        ("v_sqrt_f32_e32", operands) => lower_unary_op(ir::UnaryOp::SqrtF32, operands),
        ("v_rsq_f32_e32", operands) => lower_unary_op(ir::UnaryOp::RsqF32, operands),
        ("v_cmp_lt_f32_e32", operands) => lower_cmp(ir::CmpOp::LtF32, operands),
        ("v_cmp_le_f32_e32", operands) => lower_cmp(ir::CmpOp::LeF32, operands),
        ("v_cmp_eq_f32_e32", operands) => lower_cmp(ir::CmpOp::EqF32, operands),
        ("v_cmp_lg_f32_e32", operands) => lower_cmp(ir::CmpOp::LgF32, operands),
        ("v_cndmask_b32_e32", [dst, src0, src1, vcc]) => {
            expect_vcc(vcc)?;
            Ok(CndMask32 {
                dst: vgpr(dst).ok_or("expected one destination VGPR")?,
                src0: first_source(src0)?,
                src1: vgpr(src1).ok_or("expected one VGPR second source")?,
            })
        }
        // gfx950 also accepts an SGPR or an inline constant source; only a VGPR is supported.
        ("v_accvgpr_write_b32", [dst, src]) => Ok(AccvgprWrite32 {
            dst: agpr(dst).ok_or("expected one destination AGPR")?,
            src: vgpr(src).ok_or("expected one source VGPR")?,
        }),
        ("v_accvgpr_read_b32", [dst, src]) => Ok(AccvgprRead32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: agpr(src).ok_or("expected one source AGPR")?,
        }),
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
        // A nonzero cbsz, abid or blgp modifier is an unsupported operand of the frontend.
        ("v_mfma_f32_16x16x4_f32", [dst, src_a, src_b, src_c]) => {
            let dst =
                lane_regs(dst).ok_or("expected an aligned four-VGPR or four-AGPR destination")?;
            Ok(Mfma16x16x4F32 {
                dst,
                src_a: lane_reg(src_a).ok_or("expected one VGPR or AGPR A source")?,
                src_b: lane_reg(src_b).ok_or("expected one VGPR or AGPR B source")?,
                src_c: mfma_src_c(dst, src_c)?,
            })
        }
        ("global_load_dword", [dst, vaddr, saddr, offset @ ..]) => Ok(GlobalLoad {
            dst: GlobalLoadDst::Dword(vgpr(dst).ok_or("expected one destination VGPR")?),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_load_dwordx3", [dst, vaddr, saddr, offset @ ..]) => Ok(GlobalLoad {
            dst: GlobalLoadDst::Dwordx3(
                vgprs(dst).ok_or("expected an even-aligned three-VGPR destination")?,
            ),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_load_dwordx4", [dst, vaddr, saddr, offset @ ..]) => Ok(GlobalLoad {
            dst: GlobalLoadDst::Dwordx4(
                vgprs(dst).ok_or("expected an even-aligned four-VGPR destination")?,
            ),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_store_dword", [vaddr, src, saddr, offset @ ..]) => Ok(GlobalStore {
            src: GlobalStoreSrc::Dword(lane_reg(src).ok_or("expected one source VGPR or AGPR")?),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_store_dwordx2", [vaddr, src, saddr, offset @ ..]) => Ok(GlobalStore {
            src: GlobalStoreSrc::Dwordx2(
                lane_regs(src).ok_or("expected an even-aligned VGPR or AGPR source pair")?,
            ),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_store_dwordx3", [vaddr, src, saddr, offset @ ..]) => Ok(GlobalStore {
            src: GlobalStoreSrc::Dwordx3(
                lane_regs(src).ok_or("expected an even-aligned three-VGPR or AGPR source")?,
            ),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("global_store_dwordx4", [vaddr, src, saddr, offset @ ..]) => Ok(GlobalStore {
            src: GlobalStoreSrc::Dwordx4(
                lane_regs(src).ok_or("expected an even-aligned four-VGPR or AGPR source")?,
            ),
            address: global_address(vaddr, saddr, offset)?,
        }),
        ("s_waitcnt", operands) => lower_wait(operands),
        ("s_nop", [wait_states]) => {
            immediate(wait_states, 15).ok_or("expected a wait count from 0 to 15")?;
            Ok(Nop)
        }
        ("s_endpgm", []) => Ok(EndPgm),
        (
            "s_load_dword"
            | "s_load_dwordx2"
            | "s_load_dwordx4"
            | "s_load_dwordx8"
            | "s_movk_i32"
            | "s_mov_b64"
            | "s_abs_i32"
            | "s_lshl_b64"
            | "s_branch"
            | "s_cbranch_scc1"
            | "s_cbranch_vccnz"
            | "s_cbranch_execz"
            | "s_barrier"
            | "v_readfirstlane_b32"
            | "s_mov_b32"
            | "v_mfma_f32_16x16x4_f32"
            | "v_cndmask_b32_e32"
            | "v_accvgpr_write_b32"
            | "v_accvgpr_read_b32"
            | "v_fma_f32"
            | "v_fmac_f32_e32"
            | "global_load_dword"
            | "global_load_dwordx3"
            | "global_load_dwordx4"
            | "global_store_dword"
            | "global_store_dwordx2"
            | "global_store_dwordx3"
            | "global_store_dwordx4"
            | "s_nop"
            | "s_endpgm",
            _,
        ) => Err("unsupported operand count"),
        _ => Err("unsupported instruction"),
    }
}

fn lower_scalar_load(
    dst: ScalarLoadDst,
    base: &Operand,
    offset: &Operand,
) -> Result<LoweredInstr, &'static str> {
    Ok(LoweredInstr::ScalarLoad {
        dst,
        base: sgprs(base).ok_or("expected an aligned SGPR base pair")?,
        offset: immediate(offset, 0xfffff).ok_or("expected a nonnegative 20-bit byte offset")?,
    })
}

fn lower_bin_op(op: ir::BinOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::BinOp {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        src0: first_source(src0)?,
        src1: vgpr(src1).ok_or("expected one VGPR second source")?,
    })
}

fn lower_ternary_op(op: ir::TernaryOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1, src2] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::TernaryOp {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        srcs: [
            vop3_src(src0).ok_or("expected a VGPR or an inline constant first source")?,
            vop3_src(src1).ok_or("expected a VGPR or an inline constant second source")?,
            vop3_src(src2).ok_or("expected a VGPR or an inline constant third source")?,
        ],
    })
}

fn lower_unary_op(op: ir::UnaryOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, src] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::UnaryOp {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        src: first_source(src)?,
    })
}

fn lower_cmp(op: ir::CmpOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [vcc, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    expect_vcc(vcc)?;
    Ok(LoweredInstr::Cmp {
        op,
        src0: first_source(src0)?,
        src1: vgpr(src1).ok_or("expected one VGPR second source")?,
    })
}

fn lower_scalar_op32(
    op: ir::ScalarOp32,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    let (src0, src1) = scalar_sources(src0, src1)?;
    Ok(LoweredInstr::ScalarOp32 {
        op,
        dst: sgpr(dst).ok_or("expected one destination SGPR")?,
        src0,
        src1,
    })
}

fn lower_scalar_op64(
    op: ir::ScalarOp64,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::ScalarOp64 {
        op,
        dst: scalar_dst64(dst)?,
        src0: scalar_source64(src0)?,
        src1: scalar_source64(src1)?,
    })
}

fn lower_scalar_cmp(op: ScalarCmpOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    let (src0, src1) = scalar_sources(src0, src1)?;
    Ok(LoweredInstr::ScalarCmp { op, src0, src1 })
}

/// A SOP2 or SOPC encoding holds at most one 32-bit literal.
fn scalar_sources(src0: &Operand, src1: &Operand) -> Result<(ScalarSrc, ScalarSrc), &'static str> {
    let src0 = scalar_source(src0).ok_or("expected an SGPR or a 32-bit constant first source")?;
    let src1 = scalar_source(src1).ok_or("expected an SGPR or a 32-bit constant second source")?;
    let literal = |src: ScalarSrc| matches!(src, ScalarSrc::Const(bits) if !is_inline(bits));
    if literal(src0) && literal(src1) && src0 != src1 {
        return Err("expected at most one 32-bit literal");
    }
    Ok((src0, src1))
}

/// Whether a 32-bit operand is one of CDNA4's inline integer or float constants (§6.2).
fn is_inline(bits: u32) -> bool {
    let integer = bits as i32;
    (-16..=64).contains(&integer)
        || [0.5f32, -0.5, 1.0, -1.0, 2.0, -2.0, 4.0, -4.0]
            .iter()
            .any(|value| value.to_bits() == bits)
}

/// 64-bit operations take only inline constants before GFX12, sign-extended to 64 bits.
fn scalar_source64(operand: &Operand) -> Result<ScalarSrc64, &'static str> {
    match operand {
        Operand::Vcc => Ok(ScalarSrc64::Vcc),
        Operand::Exec => Ok(ScalarSrc64::Exec),
        Operand::Imm(value) if (-16..=64).contains(value) => Ok(ScalarSrc64::Const(*value as u64)),
        _ => sgprs(operand)
            .map(ScalarSrc64::Sgprs)
            .ok_or("expected an aligned SGPR pair, vcc, exec or an inline integer constant"),
    }
}

/// EXEC is never a destination, so every lane of a full wave stays active.
fn scalar_dst64(operand: &Operand) -> Result<ScalarDst64, &'static str> {
    match operand {
        Operand::Vcc => Ok(ScalarDst64::Vcc),
        _ => sgprs(operand)
            .map(ScalarDst64::Sgprs)
            .ok_or("expected an aligned SGPR pair or vcc destination"),
    }
}

fn branch_target(
    operand: &Operand,
    labels: &BTreeMap<String, usize>,
) -> Result<InstrId, &'static str> {
    let Operand::Label(label) = operand else {
        return Err("expected a label");
    };
    let index = labels.get(label).ok_or("undefined label")?;
    Ok(InstrId(
        u32::try_from(*index).map_err(|_| "label beyond 2^32 instructions")?,
    ))
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
    let alignment = N.min(4) as u32;
    if last.checked_sub(*first)? != N as u32 - 1 || *first % alignment != 0 || *last > 101 {
        return None;
    }
    Some(std::array::from_fn(|i| Sgpr((*first + i as u32) as u8)))
}

fn sgpr(operand: &Operand) -> Option<Sgpr> {
    sgprs(operand).map(|[reg]| reg)
}

fn vgpr(operand: &Operand) -> Option<Vgpr> {
    vector_tuple(operand, RegFile::Vector).map(|[reg]| Vgpr(reg))
}

fn agpr(operand: &Operand) -> Option<Agpr> {
    vector_tuple(operand, RegFile::Accumulator).map(|[reg]| Agpr(reg))
}

fn vgprs<const N: usize>(operand: &Operand) -> Option<[Vgpr; N]> {
    vector_tuple(operand, RegFile::Vector).map(|regs| regs.map(Vgpr))
}

fn lane_reg(operand: &Operand) -> Option<LaneReg> {
    lane_regs(operand).map(|regs| {
        let [reg] = regs.regs();
        reg
    })
}

fn lane_regs<const N: usize>(operand: &Operand) -> Option<LaneRegs<N>> {
    vgprs(operand).map(LaneRegs::Vgprs).or_else(|| {
        vector_tuple(operand, RegFile::Accumulator).map(|regs| LaneRegs::Agprs(regs.map(Agpr)))
    })
}

/// The indices of an `N`-register operand of `file`. gfx950 requires VGPR and AGPR tuples to
/// start at an even register (LLVM 21.1.8's `validateVGPRAlign`).
fn vector_tuple<const N: usize>(operand: &Operand, file: RegFile) -> Option<[u8; N]> {
    let Operand::Reg {
        file: operand_file,
        first,
        last,
    } = *operand
    else {
        return None;
    };
    let first = u8::try_from(first).ok()?;
    let last = u8::try_from(last).ok()?;
    let count = usize::from(last.checked_sub(first)?) + 1;
    if operand_file != file || count != N || (N > 1 && first % 2 != 0) {
        return None;
    }
    Some(std::array::from_fn(|i| first + i as u8))
}

/// A partial overlap with `dst` is rejected, as the result of reading it is not established.
fn mfma_src_c(dst: LaneRegs<4>, operand: &Operand) -> Result<MfmaSrcC, &'static str> {
    if let Some(Vop3Src::Inline(bits)) = vop3_src(operand) {
        return Ok(MfmaSrcC::Inline(bits));
    }
    let src = lane_regs::<4>(operand)
        .ok_or("expected an inline constant or an aligned four-register accumulator")?;
    let (dst_first, src_first) = match (dst, src) {
        (LaneRegs::Vgprs(dst), LaneRegs::Vgprs(src)) => (dst[0].0, src[0].0),
        (LaneRegs::Agprs(dst), LaneRegs::Agprs(src)) => (dst[0].0, src[0].0),
        _ => return Err("expected the accumulator in the destination's register file"),
    };
    if dst_first != src_first && dst_first.abs_diff(src_first) < 4 {
        return Err("expected the accumulator to coincide with the destination or not overlap it");
    }
    Ok(MfmaSrcC::Regs(src))
}

/// Before GFX10, VOP3 takes no literal, only inline constants (LLVM 21.1.8's
/// `validateVOPLiteral`): the integers -16 to 64 and the floats.
fn vop3_src(operand: &Operand) -> Option<Vop3Src> {
    match operand {
        Operand::Imm(value) if (-16..=64).contains(value) => Some(Vop3Src::Inline(*value as u32)),
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

/// A 32-bit literal or an inline constant, as the 32 bits of the operand.
fn constant(operand: &Operand) -> Option<u32> {
    match operand {
        Operand::InlineFloat(bits) => Some(*bits),
        _ => word(operand),
    }
}

/// A 32-bit literal is its bits; a negative one is an inline constant in two's complement.
fn word(operand: &Operand) -> Option<u32> {
    match operand {
        Operand::Imm(value) if (i64::from(i32::MIN)..=i64::from(u32::MAX)).contains(value) => {
            Some(*value as u32)
        }
        _ => None,
    }
}

fn immediate(operand: &Operand, max: u32) -> Option<u32> {
    match operand {
        Operand::Imm(value) if (0..=i64::from(max)).contains(value) => Some(*value as u32),
        _ => None,
    }
}

/// `s_movk_i32`'s 16-bit immediate, sign-extended to 32 bits; the assembly may print it unsigned.
fn simm16(operand: &Operand) -> Option<u32> {
    match operand {
        Operand::Imm(value) if (-0x8000..=0xffff).contains(value) => {
            Some(i32::from(*value as u16 as i16) as u32)
        }
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
