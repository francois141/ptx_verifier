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

/// The source of a scalar ALU instruction: an SGPR or a constant whose 32 bits are the operand.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarSrc {
    Sgpr(Sgpr),
    Const(u32),
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
/// as floats.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BinOp {
    And32,
    Or32,
    Xor32,
    AddF32,
    /// `src0 - src1`.
    SubF32,
    MulF32,
    MinF32,
    MaxF32,
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
    ScalarLoadDwordx2 {
        dst: [Sgpr; 2],
        base: [Sgpr; 2],
        offset: u32,
    },
    ScalarLoadDwordx4 {
        dst: [Sgpr; 4],
        base: [Sgpr; 2],
        offset: u32,
    },
    MovScalar32 {
        dst: Sgpr,
        src: ScalarSrc,
    },
    /// The shift input is preserved; AMD uses its low five bits.
    Shl32 {
        dst: Vgpr,
        src: Vgpr,
        shift: u32,
    },
    /// Logical right shift using the shift count's low five bits.
    LShr32 {
        dst: Vgpr,
        src: Vgpr,
        shift: u32,
    },
    /// Add two words, then shift the sum left using the shift count's low five bits.
    AddShl32 {
        dst: Vgpr,
        src0: Vgpr,
        src1: Vgpr,
        shift: u32,
    },
    /// `dst = src0 op src1` in each lane.
    BinOp {
        op: BinOp,
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
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
    GlobalLoadDword {
        dst: Vgpr,
        address: GlobalAddress,
    },
    GlobalLoadDwordx3 {
        dst: [Vgpr; 3],
        address: GlobalAddress,
    },
    GlobalLoadDwordx4 {
        dst: [Vgpr; 4],
        address: GlobalAddress,
    },
    GlobalStoreDword {
        src: LaneReg,
        address: GlobalAddress,
    },
    GlobalStoreDwordx2 {
        src: LaneRegs<2>,
        address: GlobalAddress,
    },
    GlobalStoreDwordx3 {
        src: LaneRegs<3>,
        address: GlobalAddress,
    },
    GlobalStoreDwordx4 {
        src: LaneRegs<4>,
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
