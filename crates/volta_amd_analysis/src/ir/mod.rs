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
    /// The shift input is preserved; AMD uses its low five bits.
    Shl32 {
        dst: Vgpr,
        src: Vgpr,
        shift: u32,
    },
    AddF32 {
        dst: Vgpr,
        src0: Vgpr,
        src1: Vgpr,
    },
    GlobalLoadDword {
        dst: Vgpr,
        vaddr: Vgpr,
        saddr: [Sgpr; 2],
    },
    GlobalStoreDword {
        vaddr: Vgpr,
        src: Vgpr,
        saddr: [Sgpr; 2],
    },
    /// An omitted counter is unconstrained, not an implicit wait for zero.
    WaitCnt {
        vmcnt: Option<u8>,
        lgkmcnt: Option<u8>,
    },
    EndPgm,
}
