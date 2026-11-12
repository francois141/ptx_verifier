//! 5th-generation tensor core types of the IR (`tcgen05.*`): an MMA's kind and
//! `A` operand, a `.ws` collector buffer qualifier, a `tcgen05.ld`/`.st` access
//! shape and its Tensor Memory cells, and a `tcgen05.fence`'s direction.

use crate::ir::Operand;

/// `tcgen05.mma`'s `.kind` qualifier: selects the
/// operand element types `idesc`'s type fields are interpreted against and
/// the fixed `K` of one dense `.cta_group::1` operation (Table 42).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tcgen05MmaKind {
    /// `.kind::f16`: f16/bf16 operands, `K = 16`.
    F16,
    /// `.kind::f8f6f4`: 8/6/4-bit float operands, `K = 32`.
    F8f6f4,
    /// `.kind::mxf8f6f4` (`.block_scale`): `.kind::f8f6f4`'s operands, each
    /// 32-element block of an `A` row and a `B` column scaled by a UE8M0
    /// factor read from Tensor Memory, `K = 32`.
    Mxf8f6f4,
}

/// The Tensor Memory addresses of a `.block_scale` `tcgen05.mma`'s
/// `scale_A` and `scale_B` matrices (`[scale-A-tmem]`, `[scale-B-tmem]`).
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Tcgen05MmaScales {
    pub a: (Operand, i64),
    pub b: (Operand, i64),
}

/// `tcgen05.ld`/`.st`'s shape qualifier (PTX ISA 9.7.17.8, Tables 52/53):
/// the rectangle of Tensor Memory one `.x1` unit of the access covers, and
/// hence how a thread's registers map onto `(lane, column)` cells.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tcgen05LdStShape {
    /// `.32x32b`: the warp's full 32-lane quadrant, one column per `.x1`.
    S32x32b,
    /// `.16x256b`: half a quadrant (16 lanes) by 8 columns per `.x1`, so
    /// four registers per thread per unit.
    S16x256b,
    /// `.16x32bx2`: two `.16x32b` accesses of the same 16 lanes, one column
    /// per `.x1`: threads 0-15 at `taddr`, threads 16-31 at `taddr +
    /// immHalfSplitoff` (`half_split_off` columns further).
    S16x32bx2 { half_split_off: u32 },
}

impl Tcgen05LdStShape {
    /// Registers each thread supplies/receives per `.x1` unit.
    pub fn regs_per_unit(self) -> u32 {
        match self {
            Self::S32x32b | Self::S16x32bx2 { .. } => 1,
            Self::S16x256b => 4,
        }
    }

    /// Tensor Memory columns one `.x1` unit spans.
    pub fn cols_per_unit(self) -> u32 {
        match self {
            Self::S32x32b | Self::S16x32bx2 { .. } => 1,
            Self::S16x256b => 8,
        }
    }

    /// Tensor Memory lanes the access spans, starting at the `taddr` lane.
    pub fn num_lanes(self) -> u32 {
        match self {
            Self::S32x32b => 32,
            Self::S16x256b | Self::S16x32bx2 { .. } => 16,
        }
    }

    /// Tensor Memory columns an access of `regs` registers per thread
    /// spans: one `.x1` unit per `regs_per_unit` registers, each unit
    /// `cols_per_unit` columns wide (`.16x32bx2`: the hull of both halves).
    pub fn num_cols(self, regs: usize) -> u32 {
        let unit_cols = (regs as u32 / self.regs_per_unit()) * self.cols_per_unit();
        match self {
            Self::S16x32bx2 { half_split_off } => half_split_off + unit_cols,
            Self::S32x32b | Self::S16x256b => unit_cols,
        }
    }

    /// `(lane, column)` offsets from taddr of register `reg` of thread `t =
    /// lane_in_warp`: identity for `.32x32b`; for `.16x256b`, lane `t / 4 + 8
    /// * (reg / 2)` and column `2 * (t % 4) + reg % 2`; for `.16x32bx2`, lane
    /// `t % 16` and column `reg`, plus `half_split_off` for `t >= 16`.
    pub fn cell(self, lane_in_warp: u32, reg: u32) -> (u32, u32) {
        match self {
            Self::S32x32b => (lane_in_warp, reg),
            Self::S16x256b => {
                let (unit, within) = (reg / 4, reg % 4);
                let lane = lane_in_warp / 4 + 8 * (within / 2);
                let col = unit * 8 + 2 * (lane_in_warp % 4) + within % 2;
                (lane, col)
            }
            Self::S16x32bx2 { half_split_off } => {
                if lane_in_warp < 16 {
                    (lane_in_warp, reg)
                } else {
                    (lane_in_warp - 16, half_split_off + reg)
                }
            }
        }
    }
}

/// `tcgen05.mma`'s `A` operand: a shared-memory matrix descriptor (`a-desc`)
/// or a Tensor Memory address (`[a-tmem]`), told apart by the brackets.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Tcgen05MmaA {
    Desc(Operand),
    Tmem { base: Operand, offset: i64 },
}

/// `tcgen05.mma.ws`'s `.collector::bN::op` qualifier (PTX ISA
/// 9.7.17.10.10.3): how the `B` matrix interacts with collector buffer
/// `buffer` (0-3). Absent on the instruction = `b0::discard`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Tcgen05Collector {
    pub buffer: u8,
    pub op: Tcgen05CollectorOp,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tcgen05CollectorOp {
    /// Fill the buffer with the `B` read from memory.
    Fill,
    /// `B` may be read from the buffer; it stays valid.
    Use,
    /// `B` may be read from the buffer, which is then discarded.
    LastUse,
    /// Discard the buffer's contents.
    Discard,
}

/// Which side of a thread synchronization a `tcgen05.fence` orders.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tcgen05FenceDirection {
    /// `::before_thread_sync`
    BeforeThreadSync,
    /// `::after_thread_sync`
    AfterThreadSync,
}
