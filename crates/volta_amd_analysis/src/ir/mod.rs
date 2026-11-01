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
    And32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    Or32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    AddF32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    MulF32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    MaxF32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    /// `dst = 2^src`.
    Exp2F32 {
        dst: Vgpr,
        src: Src0,
    },
    RcpF32 {
        dst: Vgpr,
        src: Src0,
    },
    /// Sets each lane's VCC bit to `src0 < src1`.
    CmpLtF32 {
        src0: Src0,
        src1: Vgpr,
    },
    /// `dst = VCC ? src1 : src0` in each lane.
    CndMask32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
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
        src: Vgpr,
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
