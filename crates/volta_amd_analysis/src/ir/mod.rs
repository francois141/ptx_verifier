//! Typed AMD instructions between lowering and execution.

use std::collections::BTreeMap;

use id_collections::{IdVec, id_type};

/// An instruction's position in its kernel body.
#[id_type]
pub struct InstrId(pub u32);

#[derive(Debug, Clone)]
pub struct LoweredKernel {
    pub name: String,
    pub target: String,
    pub instructions: IdVec<InstrId, LoweredInstr>,
    pub descriptor: BTreeMap<String, u64>,
}

/// A physical 32-bit scalar register; tuples retain their constituent registers.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Sgpr(pub u8);

/// A physical 32-bit vector register, with a separate value in each lane.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Vgpr(pub u8);

/// A physical 32-bit accumulation register, with a separate value in each lane. The matrix core
/// reads and writes AGPRs like VGPRs, and memory instructions store them.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Agpr(pub u8);

/// A register with a separate value in each lane: a VGPR or an AGPR.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LaneReg {
    Vgpr(Vgpr),
    Agpr(Agpr),
}

/// `N` consecutive registers of one per-lane file, as a tuple operand names them.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LaneRegs<const N: usize> {
    Vgprs([Vgpr; N]),
    Agprs([Agpr; N]),
}

impl<const N: usize> LaneRegs<N> {
    pub fn regs(self) -> [LaneReg; N] {
        match self {
            Self::Vgprs(regs) => regs.map(LaneReg::Vgpr),
            Self::Agprs(regs) => regs.map(LaneReg::Agpr),
        }
    }
}

/// An MFMA's accumulator input: registers of the destination's file that coincide with the
/// destination or do not overlap it, or an inline constant for every element, as a `Vop3Src`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MfmaSrcC {
    Regs(LaneRegs<4>),
    Inline(u32),
}

/// A VOP3 source: a VGPR, or an inline integer constant whose 32 bits are the operand, so in
/// an f32 slot `1` is a denormal (LLVM 21.1.8's `printImmediate32`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Vop3Src {
    Vgpr(Vgpr),
    Inline(u32),
}

/// The first source of a VOP2 instruction: a VGPR, an SGPR, or a constant (inline
/// or literal) whose 32 bits are the operand.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Src0 {
    Vgpr(Vgpr),
    Sgpr(Sgpr),
    Const(u32),
}

/// The SGPRs a scalar load writes, one per dword: a single SGPR, or an aligned tuple of two,
/// four or eight.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarLoadDst {
    Dword(Sgpr),
    Dwordx2([Sgpr; 2]),
    Dwordx4([Sgpr; 4]),
    Dwordx8([Sgpr; 8]),
}

/// The source of a scalar ALU instruction: an SGPR or a constant whose 32 bits are the operand.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarSrc {
    Sgpr(Sgpr),
    Const(u32),
}

/// A 64-bit scalar ALU source: an aligned SGPR pair, VCC or EXEC as lane masks, or a
/// constant, which a 32-bit inline constant gives sign-extended.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarSrc64 {
    Sgprs([Sgpr; 2]),
    Vcc,
    Exec,
    Const(u64),
}

/// A 64-bit scalar ALU destination. EXEC is never written, so every lane stays active.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarDst64 {
    Sgprs([Sgpr; 2]),
    Vcc,
}

/// A 32-bit scalar ALU operation of two sources over words, with its effect on SCC.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarOp32 {
    /// SCC is the carry out.
    AddU32,
    /// `src0 + src1 + SCC`; SCC is the carry out.
    AddcU32,
    /// SCC is the signed overflow.
    AddI32,
    /// SCC is the signed overflow.
    SubI32,
    /// The low word of the product; SCC is unchanged.
    MulI32,
    /// The high word of the unsigned product; SCC is unchanged.
    MulHiU32,
    /// SCC is whether the result is nonzero, as for every op below.
    AndB32,
    XorB32,
    /// `src0 << src1`, using the count's low five bits.
    LShlB32,
    /// The logical `src0 >> src1`.
    LShrB32,
    /// The arithmetic `src0 >> src1`.
    AShrI32,
    /// `SCC ? src0 : src1`; SCC is unchanged.
    CSelectB32,
}

/// A 64-bit scalar ALU operation of two sources over lane masks or words.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarOp64 {
    /// SCC is whether the result is nonzero, as for `AndN2B64`.
    AndB64,
    /// `src0 & !src1`.
    AndN2B64,
    /// `SCC ? src0 : src1`; SCC is unchanged.
    CSelectB64,
}

/// A scalar comparison of two words, which writes SCC.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarCmpOp {
    GtI32,
    GeI32,
    LtU32,
    GeU32,
    /// Whether bit `src1 & 31` of `src0` is set.
    BitCmp1B32,
}

/// The condition of a conditional branch, which is uniform across the wave.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BranchCondition {
    /// SCC is set.
    Scc1,
    /// Some lane's VCC bit is set.
    VccNz,
    /// No lane is active.
    ExecZ,
}

/// The VGPRs a global load writes, one per dword: a single VGPR, or an even-aligned tuple of
/// three or four.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GlobalLoadDst {
    Dword(Vgpr),
    Dwordx3([Vgpr; 3]),
    Dwordx4([Vgpr; 4]),
}

impl GlobalLoadDst {
    pub fn regs(&self) -> &[Vgpr] {
        match self {
            Self::Dword(reg) => std::slice::from_ref(reg),
            Self::Dwordx3(regs) => regs,
            Self::Dwordx4(regs) => regs,
        }
    }
}

/// The registers a global store reads, one per dword: a single VGPR or AGPR, or an
/// even-aligned tuple of two, three or four of one file.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GlobalStoreSrc {
    Dword(LaneReg),
    Dwordx2(LaneRegs<2>),
    Dwordx3(LaneRegs<3>),
    Dwordx4(LaneRegs<4>),
}

impl GlobalStoreSrc {
    pub fn regs(self) -> Vec<LaneReg> {
        match self {
            Self::Dword(reg) => vec![reg],
            Self::Dwordx2(regs) => regs.regs().to_vec(),
            Self::Dwordx3(regs) => regs.regs().to_vec(),
            Self::Dwordx4(regs) => regs.regs().to_vec(),
        }
    }
}

/// A global instruction's address in each lane: the SGPR-pair base, plus the lane's VGPR as a
/// 32-bit unsigned offset, plus a signed 13-bit immediate byte offset.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct GlobalAddress {
    pub vaddr: Vgpr,
    pub saddr: [Sgpr; 2],
    pub offset: i16,
}

/// A VOP2 operation of two sources: the 32-bit ops read their operands as words, the f32 ops
/// as floats. Shifts use the count's low five bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BinOp {
    And32,
    Or32,
    Xor32,
    /// `src1 << src0`.
    LShlRev32,
    /// The logical `src1 >> src0`.
    LShrRev32,
    /// The low word of `src0 + src1`.
    AddU32,
    /// The low word of `src0 - src1`.
    SubU32,
    /// The low word of `src1 - src0`.
    SubRevU32,
    /// The arithmetic `src1 >> src0`.
    AShrRevI32,
    /// `!(src0 ^ src1)`.
    Xnor32,
    MinI32,
    MaxI32,
    MinU32,
    MaxU32,
    /// The low word of the product of the sources' low 24 bits, zero-extended.
    MulU32U24,
    /// The high word of that product.
    MulHiU32U24,
    /// The low word of the product of the sources' low 24 bits, sign-extended.
    MulI32I24,
    /// The high word of that product.
    MulHiI32I24,
    AddF32,
    /// `src0 - src1`.
    SubF32,
    /// `src1 - src0`.
    SubRevF32,
    MulF32,
    MinF32,
    MaxF32,
}

/// A VOP3 operation of three sources: the f32 ops read them as floats, the others as words.
/// Shift counts and the field offset and width use their low five bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TernaryOp {
    /// `(src0 + src1) << src2`.
    AddLShl32,
    /// Bit-field extract: `(src0 >> src1) & ((1 << src2) - 1)`.
    Bfe32,
    /// `(src0 << src1) | src2`.
    LShlOr32,
    /// `src0 | src1 | src2`.
    Or3_32,
    /// The low word of `(src0 << src1) + src2`.
    LShlAdd32,
    /// The low word of `src0 + src1 + src2`.
    Add3_32,
    /// `(src0 & src1) | src2`.
    AndOr32,
    /// The low word of `(src0 ^ src1) + src2`.
    Xad32,
    /// Bit-field insert: `(src0 & src1) | (!src0 & src2)`.
    Bfi32,
    /// `Bfe32`'s field, sign-extended from its top bit.
    BfeI32,
    /// The low word of the 64-bit `src0:src1` shifted right by `src2`.
    AlignBit32,
    /// The low word of the 64-bit `src0:src1` shifted right by `src2 & 3` bytes.
    AlignByte32,
    /// The low word of `MulU32U24`'s product plus `src2`.
    MadU32U24,
    /// The low word of `MulI32I24`'s product plus `src2`.
    MadI32I24,
    Min3I32,
    Min3U32,
    Max3I32,
    Max3U32,
    /// The median of the three sources.
    Med3I32,
    Med3U32,
    /// The low word of `|src0 - src1| + src2`, unsigned.
    SadU32,
    Min3F32,
    Max3F32,
    Med3F32,
    /// Each result bit is bit `4 * a + 2 * b + c` of the table, for the sources' bits `a`, `b`
    /// and `c`.
    BitOp3(u8),
}

/// A VOP1 operation of one source, read as an f32.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnaryOp {
    /// `2^src`.
    Exp2F32,
    /// `log2(src)`.
    Log2F32,
    RcpF32,
    SqrtF32,
    /// `1 / sqrt(src)`.
    RsqF32,
}

/// A VOPC comparison of two f32 sources.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CmpOp {
    LtF32,
    LeF32,
    EqF32,
    /// Less or greater: an ordered not-equal, which is `!=` for Volta's NaN-free reals.
    LgF32,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LoweredInstr {
    ScalarLoad {
        dst: ScalarLoadDst,
        base: [Sgpr; 2],
        offset: u32,
    },
    MovScalar32 {
        dst: Sgpr,
        src: ScalarSrc,
    },
    MovScalar64 {
        dst: ScalarDst64,
        src: ScalarSrc64,
    },
    /// `dst = |src|`, signed; SCC is whether the result is nonzero.
    AbsScalar32 {
        dst: Sgpr,
        src: ScalarSrc,
    },
    ScalarOp32 {
        op: ScalarOp32,
        dst: Sgpr,
        src0: ScalarSrc,
        src1: ScalarSrc,
    },
    ScalarOp64 {
        op: ScalarOp64,
        dst: ScalarDst64,
        src0: ScalarSrc64,
        src1: ScalarSrc64,
    },
    /// `dst = src << (shift & 63)`; SCC is whether the result is nonzero.
    LShlScalar64 {
        dst: [Sgpr; 2],
        src: ScalarSrc64,
        shift: ScalarSrc,
    },
    ScalarCmp {
        op: ScalarCmpOp,
        src0: ScalarSrc,
        src1: ScalarSrc,
    },
    Branch {
        target: InstrId,
    },
    CondBranch {
        condition: BranchCondition,
        target: InstrId,
    },
    /// Copy the first active lane's value, lane 0's, into an SGPR.
    ReadFirstLane {
        dst: Sgpr,
        src: Vgpr,
    },
    /// `dst = src0 op src1` in each lane.
    BinOp {
        op: BinOp,
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    /// `dst = op(src0, src1, src2)` in each lane.
    TernaryOp {
        op: TernaryOp,
        dst: Vgpr,
        srcs: [Vop3Src; 3],
    },
    /// `dst = op src` in each lane.
    UnaryOp {
        op: UnaryOp,
        dst: Vgpr,
        src: Src0,
    },
    /// Sets each lane's VCC bit to `src0 op src1`.
    Cmp {
        op: CmpOp,
        src0: Src0,
        src1: Vgpr,
    },
    /// `dst = VCC ? src1 : src0` in each lane.
    CndMask32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    /// Copy a VGPR's word into an AGPR.
    AccvgprWrite32 {
        dst: Agpr,
        src: Vgpr,
    },
    /// Copy an AGPR's word into a VGPR.
    AccvgprRead32 {
        dst: Vgpr,
        src: Agpr,
    },
    /// `dst = src0 * src1 + src2`.
    FmaF32 {
        dst: Vgpr,
        src0: Vop3Src,
        src1: Vop3Src,
        src2: Vop3Src,
    },
    /// `dst = src0 * src1 + dst`.
    FmacF32 {
        dst: Vgpr,
        src0: Vgpr,
        src1: Vgpr,
    },
    /// The wave's `D = A * B + C` over f32, for a 16 x 4 `A`, a 4 x 16 `B` and 16 x 16 `C` and
    /// `D`: lane `l` holds `A[l % 16][l / 16]` and `B[l / 16][l % 16]`, and its `r`th
    /// accumulator register `C[4 * (l / 16) + r][l % 16]`.
    Mfma16x16x4F32 {
        dst: LaneRegs<4>,
        src_a: LaneReg,
        src_b: LaneReg,
        src_c: MfmaSrcC,
    },
    GlobalLoad {
        dst: GlobalLoadDst,
        address: GlobalAddress,
    },
    GlobalStore {
        src: GlobalStoreSrc,
        address: GlobalAddress,
    },
    /// An omitted counter is unconstrained, not an implicit wait for zero.
    WaitCnt {
        vmcnt: Option<u8>,
        lgkmcnt: Option<u8>,
    },
    /// Waits out a hazard, which execution does not model.
    Nop,
    EndPgm,
}
