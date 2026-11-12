//! Lowering parsed AMD assembly into typed instructions for symbolic execution.

use std::collections::BTreeMap;
use std::fmt;

use id_collections::IdVec;

use crate::frontend::ast::{Counter, Instruction, Kernel, Operand, RegFile};
use crate::ir::{
    self, Agpr, BranchCondition, BufferAddress, BufferImmOffset, BufferLoadDst, BufferStoreSrc,
    DsReadDst, DsWriteData, F64Op, F64Src, GlobalAddress, GlobalLoadDst, GlobalStoreSrc, InstrId,
    LaneMask, LaneReg, LaneRegs, LdsAccesses, LoweredInstr, LoweredKernel, MfmaSrcC, ModifiedSrc,
    PackedF32Op, ScalarCmpOp, ScalarDst64, ScalarLoadDst, ScalarSrc, ScalarSrc64, Sgpr, Src0, Vgpr,
    Vop3Src,
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

/// What lowering reports for an opcode it does not know.
const UNKNOWN_OPCODE: &str = "unsupported instruction";

/// Inline asm may leave a VOP1, VOP2 or VOPC instruction's encoding to the assembler, which takes
/// the 32-bit one when the operands fit it and the 64-bit one otherwise. Both compute the same, so
/// an unsuffixed opcode no arm names is lowered in the first encoding that fits.
fn lower_instruction(
    instruction: &Instruction,
    labels: &BTreeMap<String, usize>,
) -> Result<LoweredInstr, &'static str> {
    let lowered = lower_as_written(instruction, labels);

    if encoding_undefined(&instruction.opcode) && matches!(lowered, Err(UNKNOWN_OPCODE)) {
        let encoded = |suffix: &str| Instruction {
            opcode: format!("{}{suffix}", instruction.opcode),
            operands: instruction.operands.clone(),
        };

        return lower_as_written(&encoded("_e32"), labels)
            .or_else(|_| lower_as_written(&encoded("_e64"), labels));
    }

    lowered
}

/// Whether `opcode` is a vector opcode written without an `_e32` or `_e64` encoding suffix.
fn encoding_undefined(opcode: &str) -> bool {
    opcode.starts_with("v_") && !opcode.ends_with("_e32") && !opcode.ends_with("_e64")
}

fn lower_as_written(
    instruction: &Instruction,
    labels: &BTreeMap<String, usize>,
) -> Result<LoweredInstr, &'static str> {
    use LoweredInstr::*;
    use ir::ExecCopy::{Saved, Written};
    use ir::ExecOrder::{ExecSrc, SrcExec};

    // These comparisons write EXEC as well as their mask. Only scalar instructions, which read
    // concrete masks, may change the active lanes.
    let opcode = instruction.opcode.as_str();
    if opcode.starts_with("v_cmpx_") {
        return Err("unsupported EXEC write: only scalar instructions may write exec");
    }

    match (opcode, instruction.operands.as_slice()) {
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
        // NOT shares XOR's concrete-word evaluation and nonzero-result SCC rule.
        ("s_not_b32", [dst, src]) => Ok(ScalarOp32 {
            op: ir::ScalarOp32::XorB32,
            dst: sgpr(dst).ok_or("expected one destination SGPR")?,
            src0: scalar_source(src).ok_or("expected an SGPR or a 32-bit constant source")?,
            src1: ScalarSrc::Const(u32::MAX),
        }),
        ("s_not_b64", [dst, src]) => Ok(ScalarOp64 {
            op: ir::ScalarOp64::XorB64,
            dst: scalar_dst64(dst)?,
            src0: scalar_source64(src)?,
            src1: ScalarSrc64::Const(u64::MAX),
        }),
        ("s_add_u32", operands) => lower_scalar_op32(ir::ScalarOp32::AddU32, operands),
        ("s_addc_u32", operands) => lower_scalar_op32(ir::ScalarOp32::AddcU32, operands),
        ("s_add_i32", operands) => lower_scalar_op32(ir::ScalarOp32::AddI32, operands),
        ("s_sub_i32", operands) => lower_scalar_op32(ir::ScalarOp32::SubI32, operands),
        ("s_sub_u32", operands) => lower_scalar_op32(ir::ScalarOp32::SubU32, operands),
        ("s_subb_u32", operands) => lower_scalar_op32(ir::ScalarOp32::SubbU32, operands),
        ("s_mul_i32", operands) => lower_scalar_op32(ir::ScalarOp32::MulI32, operands),
        ("s_mul_hi_u32", operands) => lower_scalar_op32(ir::ScalarOp32::MulHiU32, operands),
        ("s_mul_hi_i32", operands) => lower_scalar_op32(ir::ScalarOp32::MulHiI32, operands),
        ("s_min_i32", operands) => lower_scalar_op32(ir::ScalarOp32::MinI32, operands),
        ("s_min_u32", operands) => lower_scalar_op32(ir::ScalarOp32::MinU32, operands),
        ("s_max_i32", operands) => lower_scalar_op32(ir::ScalarOp32::MaxI32, operands),
        ("s_max_u32", operands) => lower_scalar_op32(ir::ScalarOp32::MaxU32, operands),
        ("s_and_b32", operands) => lower_scalar_op32(ir::ScalarOp32::AndB32, operands),
        ("s_or_b32", operands) => lower_scalar_op32(ir::ScalarOp32::OrB32, operands),
        ("s_xor_b32", operands) => lower_scalar_op32(ir::ScalarOp32::XorB32, operands),
        ("s_andn2_b32", operands) => lower_scalar_op32(ir::ScalarOp32::AndN2B32, operands),
        ("s_orn2_b32", operands) => lower_scalar_op32(ir::ScalarOp32::OrN2B32, operands),
        ("s_nand_b32", operands) => lower_scalar_op32(ir::ScalarOp32::NandB32, operands),
        ("s_nor_b32", operands) => lower_scalar_op32(ir::ScalarOp32::NorB32, operands),
        ("s_xnor_b32", operands) => lower_scalar_op32(ir::ScalarOp32::XnorB32, operands),
        ("s_lshl_b32", operands) => lower_scalar_op32(ir::ScalarOp32::LShlB32, operands),
        ("s_lshr_b32", operands) => lower_scalar_op32(ir::ScalarOp32::LShrB32, operands),
        ("s_ashr_i32", operands) => lower_scalar_op32(ir::ScalarOp32::AShrI32, operands),
        ("s_cselect_b32", operands) => lower_scalar_op32(ir::ScalarOp32::CSelectB32, operands),
        ("s_and_b64", operands) => lower_scalar_op64(ir::ScalarOp64::AndB64, operands),
        ("s_or_b64", operands) => lower_scalar_op64(ir::ScalarOp64::OrB64, operands),
        ("s_xor_b64", operands) => lower_scalar_op64(ir::ScalarOp64::XorB64, operands),
        ("s_andn2_b64", operands) => lower_scalar_op64(ir::ScalarOp64::AndN2B64, operands),
        ("s_orn2_b64", operands) => lower_scalar_op64(ir::ScalarOp64::OrN2B64, operands),
        ("s_nand_b64", operands) => lower_scalar_op64(ir::ScalarOp64::NandB64, operands),
        ("s_nor_b64", operands) => lower_scalar_op64(ir::ScalarOp64::NorB64, operands),
        ("s_xnor_b64", operands) => lower_scalar_op64(ir::ScalarOp64::XnorB64, operands),
        ("s_cselect_b64", operands) => lower_scalar_op64(ir::ScalarOp64::CSelectB64, operands),
        ("s_and_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::AndB64, SrcExec, Saved, operands)
        }
        ("s_or_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::OrB64, SrcExec, Saved, operands)
        }
        ("s_xor_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::XorB64, SrcExec, Saved, operands)
        }
        ("s_andn2_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::AndN2B64, SrcExec, Saved, operands)
        }
        ("s_orn2_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::OrN2B64, SrcExec, Saved, operands)
        }
        ("s_nand_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::NandB64, SrcExec, Saved, operands)
        }
        ("s_nor_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::NorB64, SrcExec, Saved, operands)
        }
        ("s_xnor_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::XnorB64, SrcExec, Saved, operands)
        }
        // `!src & EXEC` and `!src | EXEC` are the N2 operations with EXEC as the first operand.
        ("s_andn1_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::AndN2B64, ExecSrc, Saved, operands)
        }
        ("s_orn1_saveexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::OrN2B64, ExecSrc, Saved, operands)
        }
        ("s_andn1_wrexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::AndN2B64, ExecSrc, Written, operands)
        }
        ("s_andn2_wrexec_b64", operands) => {
            lower_exec_op64(ir::ScalarOp64::AndN2B64, SrcExec, Written, operands)
        }
        ("s_lshl_b64", operands) => lower_scalar_shift64(ir::ScalarShift64::LShlB64, operands),
        ("s_lshr_b64", operands) => lower_scalar_shift64(ir::ScalarShift64::LShrB64, operands),
        ("s_ashr_i64", operands) => lower_scalar_shift64(ir::ScalarShift64::AShrI64, operands),
        ("s_cmp_lt_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LtI32, operands),
        ("s_cmp_eq_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::EqI32, operands),
        ("s_cmp_le_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LeI32, operands),
        ("s_cmp_gt_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GtI32, operands),
        ("s_cmp_lg_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LgI32, operands),
        ("s_cmp_ge_i32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GeI32, operands),
        ("s_cmp_lt_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LtU32, operands),
        ("s_cmp_eq_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::EqU32, operands),
        ("s_cmp_le_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LeU32, operands),
        ("s_cmp_gt_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GtU32, operands),
        ("s_cmp_lg_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::LgU32, operands),
        ("s_cmp_ge_u32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::GeU32, operands),
        ("s_cmp_eq_u64", operands) => lower_scalar_cmp64(ir::ScalarCmp64Op::EqU64, operands),
        ("s_cmp_lg_u64", operands) => lower_scalar_cmp64(ir::ScalarCmp64Op::LgU64, operands),
        ("s_bitcmp0_b32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::BitCmp0B32, operands),
        ("s_bitcmp1_b32", operands) => lower_scalar_cmp(ir::ScalarCmpOp::BitCmp1B32, operands),
        ("s_bitcmp0_b64", operands) => lower_bitcmp64(false, operands),
        ("s_bitcmp1_b64", operands) => lower_bitcmp64(true, operands),
        ("s_branch", [target]) => Ok(Branch {
            target: branch_target(target, labels)?,
        }),
        ("s_cbranch_scc0", [target]) => Ok(CondBranch {
            condition: BranchCondition::Scc0,
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
        ("s_cbranch_vccz", [target]) => Ok(CondBranch {
            condition: BranchCondition::VccZ,
            target: branch_target(target, labels)?,
        }),
        ("s_cbranch_execz", [target]) => Ok(CondBranch {
            condition: BranchCondition::ExecZ,
            target: branch_target(target, labels)?,
        }),
        ("s_cbranch_execnz", [target]) => Ok(CondBranch {
            condition: BranchCondition::ExecNz,
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
        ("s_load_dwordx16", [dst, base, offset]) => lower_scalar_load(
            sgprs(dst)
                .map(ScalarLoadDst::Dwordx16)
                .ok_or("expected an aligned sixteen-SGPR destination")?,
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
        ("v_mul_lo_u32", operands) => lower_vop3_bin_op(ir::Vop3BinOp::MulLoU32, operands),
        ("v_mul_hi_u32", operands) => lower_vop3_bin_op(ir::Vop3BinOp::MulHiU32, operands),
        ("v_mul_hi_i32", operands) => lower_vop3_bin_op(ir::Vop3BinOp::MulHiI32, operands),
        ("v_bcnt_u32_b32", operands) => lower_vop3_bin_op(ir::Vop3BinOp::BcntU32, operands),
        ("v_mbcnt_lo_u32_b32", operands) => lower_vop3_bin_op(ir::Vop3BinOp::MbcntLoU32, operands),
        ("v_mbcnt_hi_u32_b32", operands) => lower_vop3_bin_op(ir::Vop3BinOp::MbcntHiU32, operands),
        ("v_mov_b32_e32", operands) => lower_unary_op(ir::UnaryOp::Mov32, operands),
        ("v_mov_b64_e32", [dst, src]) => Ok(Mov64 {
            dst: vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
            src: src0_words(src)?,
        }),
        ("v_not_b32_e32", operands) => lower_unary_op(ir::UnaryOp::Not32, operands),
        ("v_not_b32_e64", [dst, src]) => Ok(UnaryOp {
            op: ir::UnaryOp::Not32,
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: src0_from_vop3(
                vop3_src(src).ok_or("expected a VGPR, an SGPR or an inline constant source")?,
            ),
        }),
        ("v_bfrev_b32_e32", operands) => lower_unary_op(ir::UnaryOp::BfRev32, operands),
        ("v_cvt_f32_i32_e32", operands) => lower_unary_op(ir::UnaryOp::CvtF32I32, operands),
        ("v_cvt_f32_u32_e32", operands) => lower_unary_op(ir::UnaryOp::CvtF32U32, operands),
        ("v_cvt_i32_f32_e32", operands) => lower_unary_op(ir::UnaryOp::CvtI32F32, operands),
        ("v_cvt_u32_f32_e32", operands) => lower_unary_op(ir::UnaryOp::CvtU32F32, operands),
        ("v_rcp_iflag_f32_e32", operands) => lower_unary_op(ir::UnaryOp::RcpIflagF32, operands),
        ("v_exp_f32_e32", operands) => lower_unary_op(ir::UnaryOp::Exp2F32, operands),
        ("v_log_f32_e32", operands) => lower_unary_op(ir::UnaryOp::Log2F32, operands),
        ("v_rcp_f32_e32", operands) => lower_unary_op(ir::UnaryOp::RcpF32, operands),
        ("v_sqrt_f32_e32", operands) => lower_unary_op(ir::UnaryOp::SqrtF32, operands),
        ("v_rsq_f32_e32", operands) => lower_unary_op(ir::UnaryOp::RsqF32, operands),
        ("v_add_f32_e64", operands) => lower_bin_op(ir::BinOp::AddF32, operands),
        ("v_sub_f32_e64", operands) => lower_bin_op(ir::BinOp::SubF32, operands),
        ("v_subrev_f32_e64", operands) => lower_bin_op(ir::BinOp::SubRevF32, operands),
        ("v_mul_f32_e64", operands) => lower_bin_op(ir::BinOp::MulF32, operands),
        ("v_min_f32_e64", operands) => lower_bin_op(ir::BinOp::MinF32, operands),
        ("v_max_f32_e64", operands) => lower_bin_op(ir::BinOp::MaxF32, operands),
        ("v_cmp_lt_f32_e32", operands) => lower_cmp(ir::CmpOp::LtF32, operands),
        ("v_cmp_le_f32_e32", operands) => lower_cmp(ir::CmpOp::LeF32, operands),
        ("v_cmp_eq_f32_e32", operands) => lower_cmp(ir::CmpOp::EqF32, operands),
        ("v_cmp_lg_f32_e32", operands) => lower_cmp(ir::CmpOp::LgF32, operands),
        ("v_cmp_gt_f32_e32", operands) => lower_cmp(ir::CmpOp::GtF32, operands),
        ("v_cmp_ge_f32_e32", operands) => lower_cmp(ir::CmpOp::GeF32, operands),
        // Over Volta's NaN-free reals, each negated comparison equals the opposite ordered one.
        ("v_cmp_nge_f32_e32", operands) => lower_cmp(ir::CmpOp::LtF32, operands),
        ("v_cmp_nlg_f32_e32", operands) => lower_cmp(ir::CmpOp::EqF32, operands),
        ("v_cmp_ngt_f32_e32", operands) => lower_cmp(ir::CmpOp::LeF32, operands),
        ("v_cmp_nle_f32_e32", operands) => lower_cmp(ir::CmpOp::GtF32, operands),
        ("v_cmp_neq_f32_e32", operands) => lower_cmp(ir::CmpOp::LgF32, operands),
        ("v_cmp_nlt_f32_e32", operands) => lower_cmp(ir::CmpOp::GeF32, operands),
        ("v_cmp_lt_i32_e32", operands) => lower_cmp(ir::CmpOp::LtI32, operands),
        ("v_cmp_eq_i32_e32", operands) => lower_cmp(ir::CmpOp::EqI32, operands),
        ("v_cmp_le_i32_e32", operands) => lower_cmp(ir::CmpOp::LeI32, operands),
        ("v_cmp_gt_i32_e32", operands) => lower_cmp(ir::CmpOp::GtI32, operands),
        ("v_cmp_ne_i32_e32", operands) => lower_cmp(ir::CmpOp::NeI32, operands),
        ("v_cmp_ge_i32_e32", operands) => lower_cmp(ir::CmpOp::GeI32, operands),
        ("v_cmp_lt_u32_e32", operands) => lower_cmp(ir::CmpOp::LtU32, operands),
        ("v_cmp_eq_u32_e32", operands) => lower_cmp(ir::CmpOp::EqU32, operands),
        ("v_cmp_le_u32_e32", operands) => lower_cmp(ir::CmpOp::LeU32, operands),
        ("v_cmp_gt_u32_e32", operands) => lower_cmp(ir::CmpOp::GtU32, operands),
        ("v_cmp_ne_u32_e32", operands) => lower_cmp(ir::CmpOp::NeU32, operands),
        ("v_cmp_ge_u32_e32", operands) => lower_cmp(ir::CmpOp::GeU32, operands),
        (mnemonic, operands) if cmp64_opcode(mnemonic).is_some() => lower_cmp64(mnemonic, operands),
        ("v_cmp_lt_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::LtF32, operands),
        ("v_cmp_eq_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::EqF32, operands),
        ("v_cmp_le_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::LeF32, operands),
        ("v_cmp_gt_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::GtF32, operands),
        ("v_cmp_lg_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::LgF32, operands),
        ("v_cmp_ge_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::GeF32, operands),
        // Over Volta's NaN-free reals, each negated comparison equals the opposite ordered one.
        ("v_cmp_nge_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::LtF32, operands),
        ("v_cmp_nlg_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::EqF32, operands),
        ("v_cmp_ngt_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::LeF32, operands),
        ("v_cmp_nle_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::GtF32, operands),
        ("v_cmp_neq_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::LgF32, operands),
        ("v_cmp_nlt_f32_e64", operands) => lower_cmp_e64(ir::CmpOp::GeF32, operands),
        ("v_cmp_lt_i32_e64", operands) => lower_cmp_e64(ir::CmpOp::LtI32, operands),
        ("v_cmp_eq_i32_e64", operands) => lower_cmp_e64(ir::CmpOp::EqI32, operands),
        ("v_cmp_le_i32_e64", operands) => lower_cmp_e64(ir::CmpOp::LeI32, operands),
        ("v_cmp_gt_i32_e64", operands) => lower_cmp_e64(ir::CmpOp::GtI32, operands),
        ("v_cmp_ne_i32_e64", operands) => lower_cmp_e64(ir::CmpOp::NeI32, operands),
        ("v_cmp_ge_i32_e64", operands) => lower_cmp_e64(ir::CmpOp::GeI32, operands),
        ("v_cmp_lt_u32_e64", operands) => lower_cmp_e64(ir::CmpOp::LtU32, operands),
        ("v_cmp_eq_u32_e64", operands) => lower_cmp_e64(ir::CmpOp::EqU32, operands),
        ("v_cmp_le_u32_e64", operands) => lower_cmp_e64(ir::CmpOp::LeU32, operands),
        ("v_cmp_gt_u32_e64", operands) => lower_cmp_e64(ir::CmpOp::GtU32, operands),
        ("v_cmp_ne_u32_e64", operands) => lower_cmp_e64(ir::CmpOp::NeU32, operands),
        ("v_cmp_ge_u32_e64", operands) => lower_cmp_e64(ir::CmpOp::GeU32, operands),
        ("v_cndmask_b32_e64", [dst, src0, src1, mask]) => Ok(CndMask32E64 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: modified_src(src0)
                .ok_or("expected a VGPR, an SGPR or an inline constant first source")?,
            src1: modified_src(src1)
                .ok_or("expected a VGPR, an SGPR or an inline constant second source")?,
            mask: lane_mask(mask).ok_or("expected vcc or an aligned SGPR pair as the mask")?,
        }),
        ("v_mad_u64_u32", [dst, carry, src0, src1, src2]) => Ok(MadU64U32 {
            dst: vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
            carry: sgprs(carry).ok_or("expected an aligned SGPR carry pair")?,
            src0: vop3_src(src0)
                .ok_or("expected a VGPR, an SGPR or an inline constant first source")?,
            src1: vop3_src(src1)
                .ok_or("expected a VGPR, an SGPR or an inline constant second source")?,
            src2: vgprs(src2).ok_or("expected an even-aligned VGPR addend pair")?,
        }),
        ("v_cndmask_b32_e32", [dst, src0, src1, vcc]) => {
            expect_vcc(vcc)?;
            Ok(CndMask32 {
                dst: vgpr(dst).ok_or("expected one destination VGPR")?,
                src0: first_source(src0)?,
                src1: vgpr(src1).ok_or("expected one VGPR second source")?,
            })
        }
        ("v_accvgpr_write_b32", [dst, src]) => Ok(AccvgprWrite32 {
            dst: agpr(dst).ok_or("expected one destination AGPR")?,
            src: vop3_src(src).ok_or("expected a VGPR, an SGPR or an inline constant source")?,
        }),
        ("v_accvgpr_read_b32", [dst, src]) => Ok(AccvgprRead32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src: agpr(src).ok_or("expected one source AGPR")?,
        }),
        ("v_fma_f32", [dst, src0, src1, src2]) => Ok(FmaF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: modified_src(src0)
                .ok_or("expected a VGPR, an SGPR or an inline constant first source")?,
            src1: modified_src(src1)
                .ok_or("expected a VGPR, an SGPR or an inline constant second source")?,
            src2: modified_src(src2)
                .ok_or("expected a VGPR, an SGPR or an inline constant third source")?,
        }),
        ("v_fmac_f32_e32", [dst, src0, src1]) => Ok(FmacF32 {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            src0: first_source(src0)?,
            src1: vgpr(src1).ok_or("expected one VGPR second source")?,
        }),
        ("v_add_f64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Add),
        ("v_mul_f64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Mul),
        ("v_min_f64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Min),
        ("v_max_f64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Max),
        ("v_fma_f64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Fma),
        ("v_rcp_f64_e32", operands) => lower_f64_op(Encoding::E32, operands, F64Op::Rcp),
        ("v_rcp_f64_e64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Rcp),
        ("v_sqrt_f64_e32", operands) => lower_f64_op(Encoding::E32, operands, F64Op::Sqrt),
        ("v_sqrt_f64_e64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Sqrt),
        ("v_rsq_f64_e32", operands) => lower_f64_op(Encoding::E32, operands, F64Op::Rsq),
        ("v_rsq_f64_e64", operands) => lower_f64_op(Encoding::E64, operands, F64Op::Rsq),
        ("v_cvt_f64_f32_e32", operands) => {
            lower_cvt_to_f64(ir::CvtToF64Op::F32, Encoding::E32, operands)
        }
        ("v_cvt_f64_f32_e64", operands) => {
            lower_cvt_to_f64(ir::CvtToF64Op::F32, Encoding::E64, operands)
        }
        ("v_cvt_f64_i32_e32", operands) => {
            lower_cvt_to_f64(ir::CvtToF64Op::I32, Encoding::E32, operands)
        }
        ("v_cvt_f64_i32_e64", operands) => {
            lower_cvt_to_f64(ir::CvtToF64Op::I32, Encoding::E64, operands)
        }
        ("v_cvt_f64_u32_e32", operands) => {
            lower_cvt_to_f64(ir::CvtToF64Op::U32, Encoding::E32, operands)
        }
        ("v_cvt_f64_u32_e64", operands) => {
            lower_cvt_to_f64(ir::CvtToF64Op::U32, Encoding::E64, operands)
        }
        ("v_cvt_f32_f64_e32", operands) => {
            lower_cvt_from_f64(ir::CvtFromF64Op::F32, Encoding::E32, operands)
        }
        ("v_cvt_f32_f64_e64", operands) => {
            lower_cvt_from_f64(ir::CvtFromF64Op::F32, Encoding::E64, operands)
        }
        ("v_cvt_i32_f64_e32", operands) => {
            lower_cvt_from_f64(ir::CvtFromF64Op::I32, Encoding::E32, operands)
        }
        ("v_cvt_i32_f64_e64", operands) => {
            lower_cvt_from_f64(ir::CvtFromF64Op::I32, Encoding::E64, operands)
        }
        ("v_cvt_u32_f64_e32", operands) => {
            lower_cvt_from_f64(ir::CvtFromF64Op::U32, Encoding::E32, operands)
        }
        ("v_cvt_u32_f64_e64", operands) => {
            lower_cvt_from_f64(ir::CvtFromF64Op::U32, Encoding::E64, operands)
        }
        (mnemonic, operands) if cmp_f64_opcode(mnemonic).is_some() => {
            lower_cmp_f64(mnemonic, operands)
        }
        ("v_pk_add_f32", operands) => lower_packed_f32(operands, PackedF32Op::Add),
        ("v_pk_mul_f32", operands) => lower_packed_f32(operands, PackedF32Op::Mul),
        ("v_pk_fma_f32", operands) => lower_packed_f32(operands, PackedF32Op::Fma),
        ("v_pk_mov_b32", operands) => lower_packed_move(operands),
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
        ("buffer_load_dword", [dst, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferLoad {
            dst: BufferLoadDst::Dword(vgpr(dst).ok_or("expected one destination VGPR")?),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_load_dwordx2", [dst, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferLoad {
            dst: BufferLoadDst::Dwordx2(
                vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
            ),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_load_dwordx3", [dst, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferLoad {
            dst: BufferLoadDst::Dwordx3(
                vgprs(dst).ok_or("expected an even-aligned three-VGPR destination")?,
            ),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_load_dwordx4", [dst, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferLoad {
            dst: BufferLoadDst::Dwordx4(
                vgprs(dst).ok_or("expected an even-aligned four-VGPR destination")?,
            ),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_store_dword", [src, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferStore {
            src: BufferStoreSrc::Dword(lane_reg(src).ok_or("expected one source VGPR or AGPR")?),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_store_dwordx2", [src, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferStore {
            src: BufferStoreSrc::Dwordx2(
                lane_regs(src).ok_or("expected an even-aligned VGPR or AGPR source pair")?,
            ),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_store_dwordx3", [src, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferStore {
            src: BufferStoreSrc::Dwordx3(
                lane_regs(src).ok_or("expected an even-aligned three-VGPR or AGPR source")?,
            ),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("buffer_store_dwordx4", [src, vaddr, rsrc, soffset, modifiers @ ..]) => Ok(BufferStore {
            src: BufferStoreSrc::Dwordx4(
                lane_regs(src).ok_or("expected an even-aligned four-VGPR or AGPR source")?,
            ),
            address: buffer_address(vaddr, rsrc, soffset, modifiers)?,
        }),
        ("ds_bpermute_b32", [dst, addr, src, modifiers @ ..]) => Ok(DsBPermute {
            dst: vgpr(dst).ok_or("expected one destination VGPR")?,
            addr: vgpr(addr).ok_or("expected one address VGPR")?,
            src: vgpr(src).ok_or("expected one source VGPR")?,
            offset: lds_offset(modifiers)?,
        }),
        ("ds_bpermute_b32", _) => Err("unsupported operand count"),
        (mnemonic, operands) if mnemonic.starts_with("ds_") => lower_ds(mnemonic, operands),
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
            | "s_load_dwordx16"
            | "s_movk_i32"
            | "s_mov_b64"
            | "s_abs_i32"
            | "s_not_b32"
            | "s_not_b64"
            | "s_branch"
            | "s_cbranch_scc0"
            | "s_cbranch_scc1"
            | "s_cbranch_vccnz"
            | "s_cbranch_vccz"
            | "s_cbranch_execz"
            | "s_cbranch_execnz"
            | "s_barrier"
            | "v_readfirstlane_b32"
            | "v_bitop3_b32"
            | "v_mov_b64_e32"
            | "v_not_b32_e64"
            | "v_cndmask_b32_e64"
            | "v_mad_u64_u32"
            | "buffer_load_dword"
            | "buffer_load_dwordx2"
            | "buffer_load_dwordx3"
            | "buffer_load_dwordx4"
            | "buffer_store_dword"
            | "buffer_store_dwordx2"
            | "buffer_store_dwordx3"
            | "buffer_store_dwordx4"
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
        _ => Err(UNKNOWN_OPCODE),
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

/// Either encoding: each source is a register or a constant, with any input modifiers.
fn lower_bin_op(op: ir::BinOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::BinOp {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        src0: bin_op_source(src0).ok_or("expected a VGPR, an SGPR or a constant first source")?,
        src1: bin_op_source(src1).ok_or("expected a VGPR, an SGPR or a constant second source")?,
    })
}

/// A source with its input modifiers; a 32-bit literal is its bits, as an inline constant is.
fn bin_op_source(operand: &Operand) -> Option<ModifiedSrc> {
    modified_src(operand).or_else(|| {
        constant(operand).map(|bits| ModifiedSrc {
            src: Vop3Src::Inline(bits),
            abs: false,
            neg: false,
        })
    })
}

fn lower_ternary_op(op: ir::TernaryOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1, src2] = operands else {
        return Err("unsupported operand count");
    };
    let srcs = [
        modified_src(src0).ok_or("expected a VGPR, an SGPR or an inline constant first source")?,
        modified_src(src1).ok_or("expected a VGPR, an SGPR or an inline constant second source")?,
        modified_src(src2).ok_or("expected a VGPR, an SGPR or an inline constant third source")?,
    ];
    if !op.is_f32() && srcs.iter().any(|src| src.is_modified()) {
        return Err("input modifiers require f32 sources");
    }
    Ok(LoweredInstr::TernaryOp {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        srcs,
    })
}

fn lower_vop3_bin_op(
    op: ir::Vop3BinOp,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::Vop3BinOp {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        src0: vop3_src(src0)
            .ok_or("expected a VGPR, an SGPR or an inline constant first source")?,
        src1: vop3_src(src1)
            .ok_or("expected a VGPR, an SGPR or an inline constant second source")?,
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

#[derive(Debug, Clone, Copy)]
enum Encoding {
    E32,
    E64,
}

/// `v_cmp_{lt,eq,le,gt,ne,ge}_{i64,u64}_{e32,e64}`.
fn cmp64_opcode(mnemonic: &str) -> Option<(ir::CmpPredicate, ir::Signedness, Encoding)> {
    let mut parts = mnemonic.strip_prefix("v_cmp_")?.split('_');
    let op = match parts.next()? {
        "lt" => ir::CmpPredicate::Lt,
        "eq" => ir::CmpPredicate::Eq,
        "le" => ir::CmpPredicate::Le,
        "gt" => ir::CmpPredicate::Gt,
        "ne" => ir::CmpPredicate::Ne,
        "ge" => ir::CmpPredicate::Ge,
        _ => return None,
    };
    let signedness = match parts.next()? {
        "i64" => ir::Signedness::Signed,
        "u64" => ir::Signedness::Unsigned,
        _ => return None,
    };
    let encoding = match parts.next()? {
        "e32" => Encoding::E32,
        "e64" => Encoding::E64,
        _ => return None,
    };
    parts.next().is_none().then_some((op, signedness, encoding))
}

fn lower_cmp64(mnemonic: &str, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let (op, signedness, encoding) = cmp64_opcode(mnemonic).ok_or("unsupported instruction")?;
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    let (dst, src0, src1) = match encoding {
        // An e32 comparison writes VCC, and its second source must be a VGPR pair.
        Encoding::E32 => {
            expect_vcc(dst)?;
            let src1 =
                vgprs::<2>(src1).ok_or("expected an even-aligned VGPR second source pair")?;
            (LaneMask::Vcc, src0_words(src0)?, src1.map(Src0::Vgpr))
        }
        // An e64 comparison writes VCC or an SGPR pair, and its VOP3 encoding holds no literal.
        Encoding::E64 => (
            lane_mask(dst).ok_or("expected vcc or an aligned SGPR destination pair")?,
            vop3_words(src0)?,
            vop3_words(src1)?,
        ),
    };
    Ok(LoweredInstr::Cmp64 {
        op,
        signedness,
        dst,
        src0,
        src1,
    })
}

fn lower_cmp_e64(op: ir::CmpOp, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    let src0 =
        modified_src(src0).ok_or("expected a VGPR, an SGPR or an inline constant first source")?;
    let src1 =
        modified_src(src1).ok_or("expected a VGPR, an SGPR or an inline constant second source")?;
    if !op.is_f32() && (src0.is_modified() || src1.is_modified()) {
        return Err("input modifiers require an f32 comparison");
    }
    Ok(LoweredInstr::CmpE64 {
        op,
        dst: lane_mask(dst).ok_or("expected vcc or an aligned SGPR destination pair")?,
        src0,
        src1,
    })
}

/// `v_cmp_{lt,eq,le,gt,lg,ge,nge,nlg,ngt,nle,neq,nlt}_f64_{e32,e64}`. Over Volta's NaN-free
/// reals, each negated comparison equals the opposite ordered one.
fn cmp_f64_opcode(mnemonic: &str) -> Option<(ir::CmpPredicate, Encoding)> {
    let (predicate, encoding) = mnemonic.strip_prefix("v_cmp_")?.split_once("_f64_")?;
    let op = match predicate {
        "lt" | "nge" => ir::CmpPredicate::Lt,
        "eq" | "nlg" => ir::CmpPredicate::Eq,
        "le" | "ngt" => ir::CmpPredicate::Le,
        "gt" | "nle" => ir::CmpPredicate::Gt,
        "lg" | "neq" => ir::CmpPredicate::Ne,
        "ge" | "nlt" => ir::CmpPredicate::Ge,
        _ => return None,
    };
    let encoding = match encoding {
        "e32" => Encoding::E32,
        "e64" => Encoding::E64,
        _ => return None,
    };
    Some((op, encoding))
}

fn lower_cmp_f64(mnemonic: &str, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let (op, encoding) = cmp_f64_opcode(mnemonic).ok_or("unsupported instruction")?;
    let [dst, src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    let invalid = "expected a register pair or a constant f64 source";
    let src0 = f64_source(src0, encoding).ok_or(invalid)?;
    let src1 = f64_source(src1, encoding).ok_or(invalid)?;
    let dst = match encoding {
        // An e32 comparison writes VCC, and its second source must be a VGPR pair.
        Encoding::E32 => {
            expect_vcc(dst)?;
            if !matches!(src1.src, F64Src::Vgprs(_)) {
                return Err("expected an even-aligned VGPR second source pair");
            }
            LaneMask::Vcc
        }
        Encoding::E64 => lane_mask(dst).ok_or("expected vcc or an aligned SGPR destination pair")?,
    };
    Ok(LoweredInstr::CmpF64 {
        op,
        dst,
        src0,
        src1,
    })
}

/// An f64 source: a register pair or an inline constant. An inline float keeps its value and an
/// inline integer gives its sign-extended bits. A 32-bit encoding also takes a literal, which
/// supplies the high word (CDNA4 §6.2.1.1).
fn f64_src(operand: &Operand, encoding: Encoding) -> Option<F64Src> {
    match operand {
        Operand::InlineFloat(bits) => {
            Some(F64Src::Const(f64::from(f32::from_bits(*bits)).to_bits()))
        }
        Operand::Imm(value) if (-16..=64).contains(value) => Some(F64Src::Const(*value as u64)),
        Operand::Imm(_) => match encoding {
            Encoding::E32 => word(operand).map(|bits| F64Src::Const(u64::from(bits) << 32)),
            Encoding::E64 => None,
        },
        _ => vgprs::<2>(operand)
            .map(F64Src::Vgprs)
            .or_else(|| sgprs::<2>(operand).map(F64Src::Sgprs)),
    }
}

/// An f64 source and its input modifiers, which only a 64-bit encoding holds.
fn f64_source(operand: &Operand, encoding: Encoding) -> Option<ModifiedSrc<F64Src>> {
    let source = with_modifiers(operand, |source| f64_src(source, encoding))?;
    (matches!(encoding, Encoding::E64) || !source.is_modified()).then_some(source)
}

fn lower_f64_op<const N: usize>(
    encoding: Encoding,
    operands: &[Operand],
    operation: fn([ModifiedSrc<F64Src>; N]) -> F64Op,
) -> Result<LoweredInstr, &'static str> {
    let [dst, sources @ ..] = operands else {
        return Err("unsupported operand count");
    };
    let srcs = sources
        .iter()
        .map(|source| f64_source(source, encoding))
        .collect::<Option<Vec<_>>>()
        .ok_or("expected a register pair or a constant f64 source")?;
    Ok(LoweredInstr::F64 {
        dst: vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
        op: operation(srcs.try_into().map_err(|_| "unsupported operand count")?),
    })
}

/// A 32-bit encoding also takes a literal, and only a 64-bit f32 conversion takes input modifiers.
fn lower_cvt_to_f64(
    op: ir::CvtToF64Op,
    encoding: Encoding,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src] = operands else {
        return Err("unsupported operand count");
    };
    let src = with_modifiers(src, |source| match encoding {
        Encoding::E32 => first_source(source).ok(),
        Encoding::E64 => vop3_src(source).map(src0_from_vop3),
    })
    .ok_or("expected a VGPR, an SGPR or a constant source")?;
    if src.is_modified() && (op != ir::CvtToF64Op::F32 || matches!(encoding, Encoding::E32)) {
        return Err("input modifiers require the 64-bit encoding of an f32 conversion");
    }
    Ok(LoweredInstr::CvtToF64 {
        op,
        dst: vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
        src,
    })
}

fn lower_cvt_from_f64(
    op: ir::CvtFromF64Op,
    encoding: Encoding,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src] = operands else {
        return Err("unsupported operand count");
    };
    Ok(LoweredInstr::CvtFromF64 {
        op,
        dst: vgpr(dst).ok_or("expected one destination VGPR")?,
        src: f64_source(src, encoding).ok_or("expected a register pair or a constant f64 source")?,
    })
}

/// Resolve packed f32 sources into the words and negations used by each result.
fn lower_packed_f32<const N: usize>(
    operands: &[Operand],
    operation: fn([[ModifiedSrc; 2]; N]) -> PackedF32Op,
) -> Result<LoweredInstr, &'static str> {
    let Some((dst, operands)) = operands.split_first() else {
        return Err("expected a destination pair and packed f32 sources");
    };
    if operands.len() < N {
        return Err("expected one operand per packed f32 source");
    }
    let (sources, modifiers) = operands.split_at(N);
    let mut low = None;
    let mut high = None;
    let mut negate_low = None;
    let mut negate_high = None;
    for modifier in modifiers {
        let (slot, bits) = match modifier {
            Operand::OpSel(bits) => (&mut low, bits),
            Operand::OpSelHi(bits) => (&mut high, bits),
            Operand::NegLo(bits) => (&mut negate_low, bits),
            Operand::NegHi(bits) => (&mut negate_high, bits),
            _ => return Err("expected packed source selectors or negation modifiers"),
        };
        let bits: [bool; N] = bits
            .as_slice()
            .try_into()
            .map_err(|_| "expected one modifier bit per source")?;
        if slot.replace(bits).is_some() {
            return Err("duplicate packed source modifier");
        }
    }
    let low = low.unwrap_or([false; N]);
    let high = high.unwrap_or([true; N]);
    let negate_low = negate_low.unwrap_or([false; N]);
    let negate_high = negate_high.unwrap_or([false; N]);
    // gfx950 cannot select [0,1] for binary low results, or src1/src2 high words for FMA.
    // LLVM's validateOpSel enforces these restrictions independently of source register class.
    if (N == 2 && !low[0] && low[1]) || (N == 3 && (low[1] || low[2])) {
        return Err("unsupported packed f32 low-word selectors on gfx950");
    }

    validate_packed_scalar_sources(sources)?;
    let sources = sources
        .iter()
        .enumerate()
        .map(|(i, source)| {
            packed_f32_source(source, [low[i], high[i]], [negate_low[i], negate_high[i]])
        })
        .collect::<Result<Vec<_>, _>>()?
        .try_into()
        .map_err(|_| "expected one operand per packed f32 source")?;
    Ok(LoweredInstr::PackedF32 {
        dst: vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
        op: operation(sources),
    })
}

/// Select the f32 words and negations used by the two packed results.
fn packed_f32_source(
    operand: &Operand,
    high: [bool; 2],
    negate: [bool; 2],
) -> Result<[ModifiedSrc; 2], &'static str> {
    let words = packed_source_words(operand)?;
    Ok(std::array::from_fn(|i| ModifiedSrc {
        src: words[usize::from(high[i])],
        abs: false,
        neg: negate[i],
    }))
}

/// A packed move selects one word from each source and preserves both values unchanged.
fn lower_packed_move(operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [dst, _, _, modifiers @ ..] = operands else {
        return Err("expected a destination pair and two packed move sources");
    };
    let selectors = match modifiers {
        [] => [false; 2],
        [Operand::OpSel(bits)] => bits
            .as_slice()
            .try_into()
            .map_err(|_| "expected one selector bit per packed move source")?,
        _ => return Err("expected only packed move source selectors"),
    };
    let sources = &operands[1..3];
    validate_packed_scalar_sources(sources)?;
    let select = |index: usize| -> Result<Src0, &'static str> {
        let words = packed_source_words(&sources[index])?;
        let word = words[usize::from(selectors[index])];
        // This instruction's sources are 64-bit, and an inline constant's high word is unknown.
        if matches!(word, Vop3Src::Inline(_)) && selectors[index] {
            return Err("expected the low-word selector for an inline constant");
        }
        Ok(src0_from_vop3(word))
    };
    Ok(LoweredInstr::Mov64 {
        dst: vgprs(dst).ok_or("expected an even-aligned VGPR destination pair")?,
        src: [select(0)?, select(1)?],
    })
}

/// Packed instructions may reuse one scalar pair, but cannot read distinct scalar pairs.
fn validate_packed_scalar_sources(sources: &[Operand]) -> Result<(), &'static str> {
    let mut scalar_pair = None;
    for source in sources {
        if let Some(pair) = sgprs::<2>(source) {
            if scalar_pair.is_some_and(|previous| previous != pair) {
                return Err("expected at most one distinct SGPR source pair");
            }
            scalar_pair = Some(pair);
        }
    }
    Ok(())
}

/// Packed sources are aligned register pairs, or an inline constant that fills both words.
/// Packed f32 operations read it through either selector, as in LLVM's gfx950 packed-to-scalar
/// conversion; a packed move restricts it further.
fn packed_source_words(operand: &Operand) -> Result<[Vop3Src; 2], &'static str> {
    if let Some(pair) = vgprs::<2>(operand) {
        Ok(pair.map(Vop3Src::Vgpr))
    } else if let Some(pair) = sgprs::<2>(operand) {
        Ok(pair.map(Vop3Src::Sgpr))
    } else if let Some(src @ Vop3Src::Inline(_)) = vop3_src(operand) {
        Ok([src; 2])
    } else {
        Err("expected an aligned VGPR or SGPR pair, or an inline constant")
    }
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
    let (src0, src1) = scalar_sources64(src0, src1)?;
    Ok(LoweredInstr::ScalarOp64 {
        op,
        dst: scalar_dst64(dst)?,
        src0,
        src1,
    })
}

/// A scalar operation that writes EXEC (CDNA4 §12.3). Its destination receives a copy of EXEC,
/// so it is an SGPR pair or VCC.
fn lower_exec_op64(
    op: ir::ScalarOp64,
    order: ir::ExecOrder,
    copy: ir::ExecCopy,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src] = operands else {
        return Err("unsupported operand count");
    };
    if matches!(dst, Operand::Exec) {
        return Err("expected an aligned SGPR pair or vcc destination");
    }
    Ok(LoweredInstr::ExecOp64 {
        op,
        order,
        copy,
        dst: scalar_dst64(dst)?,
        src: scalar_source64(src)?,
    })
}

fn lower_scalar_shift64(
    op: ir::ScalarShift64,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [dst, src, shift] = operands else {
        return Err("unsupported operand count");
    };
    let (src, shift) = scalar_source64_and_word(src, shift)?;
    Ok(LoweredInstr::ShiftScalar64 {
        op,
        dst: sgprs(dst).ok_or("expected an aligned SGPR destination pair")?,
        src,
        shift,
    })
}

fn lower_scalar_cmp64(
    op: ir::ScalarCmp64Op,
    operands: &[Operand],
) -> Result<LoweredInstr, &'static str> {
    let [src0, src1] = operands else {
        return Err("unsupported operand count");
    };
    let (src0, src1) = scalar_sources64(src0, src1)?;
    Ok(LoweredInstr::ScalarCmp64 { op, src0, src1 })
}

fn lower_bitcmp64(expected: bool, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let [src, index] = operands else {
        return Err("unsupported operand count");
    };
    let (src, index) = scalar_source64_and_word(src, index)?;
    Ok(LoweredInstr::BitCmpScalar64 {
        src,
        index,
        expected,
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

/// Supported 64-bit sources are register pairs, lane masks and constants. Inline integers
/// sign-extend, and a literal must have a clear sign bit, so zero and sign extension agree.
fn scalar_source64(operand: &Operand) -> Result<ScalarSrc64, &'static str> {
    match operand {
        Operand::Vcc => Ok(ScalarSrc64::Vcc),
        Operand::Exec => Ok(ScalarSrc64::Exec),
        Operand::Imm(value) if (-16..=i64::from(i32::MAX)).contains(value) => {
            Ok(ScalarSrc64::Const(*value as u64))
        }
        _ => sgprs(operand).map(ScalarSrc64::Sgprs).ok_or(
            "expected an SGPR pair, vcc, exec or a constant with a defined 64-bit extension",
        ),
    }
}

/// Whether a 64-bit source is a constant that only a literal can encode.
fn is_literal64(src: ScalarSrc64) -> bool {
    matches!(src, ScalarSrc64::Const(bits) if !(-16..=64).contains(&(bits as i64)))
}

/// A SOP2 or SOPC encoding holds at most one 32-bit literal.
fn scalar_sources64(
    src0: &Operand,
    src1: &Operand,
) -> Result<(ScalarSrc64, ScalarSrc64), &'static str> {
    let src0 = scalar_source64(src0)?;
    let src1 = scalar_source64(src1)?;
    if is_literal64(src0) && is_literal64(src1) && src0 != src1 {
        return Err("expected at most one 32-bit literal");
    }
    Ok((src0, src1))
}

/// A 64-bit source and a 32-bit count or index, which share the one 32-bit literal.
fn scalar_source64_and_word(
    src: &Operand,
    word: &Operand,
) -> Result<(ScalarSrc64, ScalarSrc), &'static str> {
    let src = scalar_source64(src)?;
    let word = scalar_source(word).ok_or("expected an SGPR or a 32-bit constant count or index")?;
    if let (ScalarSrc64::Const(wide), ScalarSrc::Const(bits)) = (src, word)
        && is_literal64(src)
        && !is_inline(bits)
        && wide != u64::from(bits)
    {
        return Err("expected at most one 32-bit literal");
    }
    Ok((src, word))
}

/// A 64-bit scalar destination: an aligned SGPR pair, VCC or EXEC.
fn scalar_dst64(operand: &Operand) -> Result<ScalarDst64, &'static str> {
    match operand {
        Operand::Exec => Ok(ScalarDst64::Exec),
        Operand::Vcc => Ok(ScalarDst64::Vcc),
        _ => sgprs(operand)
            .map(ScalarDst64::Sgprs)
            .ok_or("expected an aligned SGPR pair, vcc or exec destination"),
    }
}

fn lane_mask(operand: &Operand) -> Option<LaneMask> {
    match operand {
        Operand::Vcc => Some(LaneMask::Vcc),
        _ => sgprs(operand).map(LaneMask::Sgprs),
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

/// Only the offset-enabled raw form is supported: `offen`, an SGPR offset of the inline
/// constant 0, and an optional 12-bit immediate (LLVM 21.1.8's `isLegalMUBUFImmOffset`).
fn buffer_address(
    vaddr: &Operand,
    rsrc: &Operand,
    soffset: &Operand,
    modifiers: &[Operand],
) -> Result<BufferAddress, &'static str> {
    if *soffset != Operand::Imm(0) {
        return Err("expected an SGPR offset of 0");
    }

    let imm_offset = match modifiers {
        [Operand::Offen] => BufferImmOffset::ZERO,
        [Operand::Offen, Operand::Offset(offset)] => {
            BufferImmOffset::new(*offset).ok_or("expected an unsigned 12-bit byte offset")?
        }
        _ => return Err("expected offen and an optional byte offset"),
    };

    Ok(BufferAddress {
        vgpr_offset: vgpr(vaddr).ok_or("expected one offset VGPR")?,
        rsrc: sgprs(rsrc).ok_or("expected an aligned four-SGPR buffer resource")?,
        imm_offset,
    })
}

#[derive(Debug, Clone, Copy)]
enum DsDirection {
    Read,
    Write,
}

/// One access, or two whose `offset0` and `offset1` count elements of `stride` times the width.
#[derive(Debug, Clone, Copy)]
enum DsAccessCount {
    One,
    Two { stride: u32 },
}

#[derive(Debug, Clone, Copy)]
enum DsWidth {
    B32,
    B64,
    B96,
    B128,
}

impl DsWidth {
    fn bytes(self) -> u32 {
        match self {
            Self::B32 => 4,
            Self::B64 => 8,
            Self::B96 => 12,
            Self::B128 => 16,
        }
    }
}

/// `ds_{read,write}{,2,2st64}_b{32,64,96,128}`, whose two-access forms exist only for 32 and
/// 64 bits.
fn ds_opcode(mnemonic: &str) -> Option<(DsDirection, DsAccessCount, DsWidth)> {
    let rest = mnemonic.strip_prefix("ds_")?;
    let (direction, rest) = match rest.strip_prefix("read") {
        Some(rest) => (DsDirection::Read, rest),
        None => (DsDirection::Write, rest.strip_prefix("write")?),
    };
    let (count, width) = rest.split_once("_b")?;
    let width = match width {
        "32" => DsWidth::B32,
        "64" => DsWidth::B64,
        "96" => DsWidth::B96,
        "128" => DsWidth::B128,
        _ => return None,
    };
    let count = match (count, width) {
        ("", _) => DsAccessCount::One,
        ("2", DsWidth::B32 | DsWidth::B64) => DsAccessCount::Two { stride: 1 },
        ("2st64", DsWidth::B32 | DsWidth::B64) => DsAccessCount::Two { stride: 64 },
        _ => return None,
    };
    Some((direction, count, width))
}

fn lower_ds(mnemonic: &str, operands: &[Operand]) -> Result<LoweredInstr, &'static str> {
    let (direction, count, width) = ds_opcode(mnemonic).ok_or("unsupported instruction")?;
    let addr = |operand| vgpr(operand).ok_or("expected one address VGPR");
    match (direction, count, operands) {
        (DsDirection::Write, DsAccessCount::One, [address, data, modifiers @ ..]) => {
            Ok(LoweredInstr::DsWrite {
                addr: addr(address)?,
                accesses: LdsAccesses::One {
                    offset: lds_offset(modifiers)?,
                    regs: ds_write_data(width, data)?,
                },
            })
        }
        (
            DsDirection::Write,
            DsAccessCount::Two { stride },
            [address, data0, data1, modifiers @ ..],
        ) => Ok(LoweredInstr::DsWrite {
            addr: addr(address)?,
            accesses: LdsAccesses::Two {
                offsets: lds_offset_pair(width, stride, modifiers)?,
                regs: [ds_write_data(width, data0)?, ds_write_data(width, data1)?],
            },
        }),
        (DsDirection::Read, DsAccessCount::One, [dst, address, modifiers @ ..]) => {
            Ok(LoweredInstr::DsRead {
                addr: addr(address)?,
                accesses: LdsAccesses::One {
                    offset: lds_offset(modifiers)?,
                    regs: ds_read_dst(width, dst)?,
                },
            })
        }
        (DsDirection::Read, DsAccessCount::Two { stride }, [dst, address, modifiers @ ..]) => {
            Ok(LoweredInstr::DsRead {
                addr: addr(address)?,
                accesses: LdsAccesses::Two {
                    offsets: lds_offset_pair(width, stride, modifiers)?,
                    regs: ds_read2_dst(width, dst)?,
                },
            })
        }
        _ => Err("unsupported operand count"),
    }
}

fn ds_write_data(width: DsWidth, operand: &Operand) -> Result<DsWriteData, &'static str> {
    match width {
        DsWidth::B32 => lane_reg(operand).map(DsWriteData::B32),
        DsWidth::B64 => lane_regs(operand).map(DsWriteData::B64),
        DsWidth::B96 => lane_regs(operand).map(DsWriteData::B96),
        DsWidth::B128 => lane_regs(operand).map(DsWriteData::B128),
    }
    .ok_or("expected VGPR or AGPR data of the access width, an even-aligned tuple if wider")
}

fn ds_read_dst(width: DsWidth, operand: &Operand) -> Result<DsReadDst, &'static str> {
    match width {
        DsWidth::B32 => vgpr(operand).map(DsReadDst::B32),
        DsWidth::B64 => vgprs(operand).map(DsReadDst::B64),
        DsWidth::B96 => vgprs(operand).map(DsReadDst::B96),
        DsWidth::B128 => vgprs(operand).map(DsReadDst::B128),
    }
    .ok_or("expected a VGPR destination of the access width, an even-aligned tuple if wider")
}

/// A `read2` destination is one tuple, whose halves the two accesses load.
fn ds_read2_dst(width: DsWidth, operand: &Operand) -> Result<[DsReadDst; 2], &'static str> {
    match width {
        DsWidth::B32 => {
            vgprs(operand).map(|[low, high]| [DsReadDst::B32(low), DsReadDst::B32(high)])
        }
        DsWidth::B64 => vgprs(operand)
            .map(|[r0, r1, r2, r3]| [DsReadDst::B64([r0, r1]), DsReadDst::B64([r2, r3])]),
        DsWidth::B96 | DsWidth::B128 => None,
    }
    .ok_or("expected an even-aligned VGPR destination of twice the access width")
}

fn lds_offset(modifiers: &[Operand]) -> Result<u16, &'static str> {
    match modifiers {
        [] => Ok(0),
        [Operand::Offset(offset)] => {
            u16::try_from(*offset).map_err(|_| "expected an unsigned 16-bit byte offset")
        }
        _ => Err("unsupported operand count"),
    }
}

/// The two accesses' byte offsets. Clang omits a zero `offset0` or `offset1`.
fn lds_offset_pair(
    width: DsWidth,
    stride: u32,
    modifiers: &[Operand],
) -> Result<[u32; 2], &'static str> {
    let (mut offset0, mut offset1) = (None, None);
    for modifier in modifiers {
        let (slot, value) = match modifier {
            Operand::Offset0(value) => (&mut offset0, *value),
            Operand::Offset1(value) => (&mut offset1, *value),
            _ => return Err("expected offset0 and offset1 modifiers"),
        };
        let value = u8::try_from(value).map_err(|_| "expected an 8-bit offset")?;
        if slot.replace(value).is_some() {
            return Err("duplicate offset modifier");
        }
    }
    Ok([offset0, offset1].map(|offset| u32::from(offset.unwrap_or(0)) * stride * width.bytes()))
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
        _ => vgpr(operand)
            .map(Vop3Src::Vgpr)
            .or_else(|| sgpr(operand).map(Vop3Src::Sgpr)),
    }
}

/// A source and its input modifiers, written `-src`, `|src|` or `-|src|`.
fn with_modifiers<S>(
    operand: &Operand,
    decode: impl FnOnce(&Operand) -> Option<S>,
) -> Option<ModifiedSrc<S>> {
    let (neg, operand) = match operand {
        Operand::Neg(source) => (true, source.as_ref()),
        _ => (false, operand),
    };
    let (abs, operand) = match operand {
        Operand::Abs(source) => (true, source.as_ref()),
        _ => (false, operand),
    };
    Some(ModifiedSrc {
        src: decode(operand)?,
        abs,
        neg,
    })
}

/// A VOP3 source and its input modifiers.
fn modified_src(operand: &Operand) -> Option<ModifiedSrc> {
    with_modifiers(operand, vop3_src)
}

/// A VOP3 source as the wider first-source type.
fn src0_from_vop3(src: Vop3Src) -> Src0 {
    match src {
        Vop3Src::Vgpr(reg) => Src0::Vgpr(reg),
        Vop3Src::Sgpr(reg) => Src0::Sgpr(reg),
        Vop3Src::Inline(bits) => Src0::Const(bits),
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

/// An even-aligned VGPR pair's or an aligned SGPR pair's words, low first.
fn pair_words(operand: &Operand) -> Option<[Src0; 2]> {
    vgprs::<2>(operand)
        .map(|pair| pair.map(Src0::Vgpr))
        .or_else(|| sgprs::<2>(operand).map(|pair| pair.map(Src0::Sgpr)))
}

/// A constant's two words after sign extension, low first.
fn constant_words(value: i64) -> [Src0; 2] {
    [value as u32, (value >> 32) as u32].map(Src0::Const)
}

/// A 64-bit first source's words: a register pair or a constant. Inline integers sign-extend
/// (CDNA4 §6.2). A literal with a clear sign bit extends the same way whether zero- or
/// sign-extended, and any other literal is rejected because the two would differ.
fn src0_words(operand: &Operand) -> Result<[Src0; 2], &'static str> {
    match operand {
        Operand::Imm(value) if (-16..=i64::from(i32::MAX)).contains(value) => {
            Ok(constant_words(*value))
        }
        _ => pair_words(operand)
            .ok_or("expected a register pair or a constant with a defined 64-bit extension"),
    }
}

/// A 64-bit VOP3 source's words: a register pair or an inline integer, which sign-extends.
fn vop3_words(operand: &Operand) -> Result<[Src0; 2], &'static str> {
    match operand {
        Operand::Imm(value) if (-16..=64).contains(value) => Ok(constant_words(*value)),
        _ => pair_words(operand).ok_or("expected a register pair or an inline integer constant"),
    }
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
