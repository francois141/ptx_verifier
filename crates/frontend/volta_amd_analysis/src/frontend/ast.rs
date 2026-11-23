//! The parsed form of one compiled AMD kernel.

use std::collections::BTreeMap;

/// One kernel extracted from assembly produced by Clang.
#[derive(Debug, Clone)]
pub struct Kernel {
    pub name: String,
    /// The `.amdgcn_target` string.
    pub target: String,
    /// The kernel body in order.
    pub instructions: Vec<Instruction>,
    /// Each instruction's byte range in the source, without its comment.
    pub spans: Vec<(usize, usize)>,
    /// Each label of the body and the index of the instruction it precedes.
    pub labels: BTreeMap<String, usize>,
    /// The numeric `.amdhsa_*` settings of the kernel descriptor, keyed without the prefix.
    pub descriptor: BTreeMap<String, u64>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Instruction {
    pub opcode: String,
    pub operands: Vec<Operand>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RegFile {
    Scalar,
    Vector,
    Accumulator,
}

/// An `s_waitcnt` counter supported by this frontend.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Counter {
    Vm,
    Lgkm,
    /// Export and GDS operations, which no modeled instruction issues.
    Exp,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Operand {
    /// Inclusive register range; a single register has `first == last`.
    Reg {
        file: RegFile,
        first: u32,
        last: u32,
    },
    /// An integer literal; the negative inline constants -1 to -16 are written signed.
    Imm(i64),
    /// One of the inline float constants ±0.5, ±1.0, ±2.0 and ±4.0, as its f32 bits.
    InlineFloat(u32),
    /// A floating-point source with its sign negated.
    Neg(Box<Operand>),
    /// The absolute value of a floating-point register source.
    Abs(Box<Operand>),
    /// The vector condition code, one bit per lane.
    Vcc,
    /// The mask of the wave's active lanes.
    Exec,
    /// The scalar register M0, which holds an LDS address for loads to LDS.
    M0,
    /// A buffer load's `lds` flag: the data goes to LDS at M0 rather than to VGPRs.
    Lds,
    /// A lane-permute's `bound_ctrl:1` flag.
    BoundCtrl,
    /// A DPP instruction's lane selection, and its `row_mask:` and `bank_mask:` write masks.
    DppSelect(DppSelect),
    RowMask(u8),
    BankMask(u8),
    /// A branch target.
    Label(String),
    /// `ds_swizzle_b32`'s `offset:swizzle(SWAP,n)`: each lane reads lane `lane ^ n`.
    SwizzleSwap(u8),
    /// A buffer instruction's `offen` flag: its address VGPR is a byte offset.
    Offen,
    /// A memory instruction's `off` in place of an address register.
    Off,
    /// The `offset0:n` and `offset1:n` of a two-address LDS instruction, in units of its size.
    Offset0(u64),
    Offset1(u64),
    /// The truth table of `v_bitop3_b32`.
    BitOp3(u8),
    /// Source-word selectors for packed instructions.
    OpSel(Vec<bool>),
    OpSelHi(Vec<bool>),
    /// Negate selected sources for the low or high result of a packed instruction.
    NegLo(Vec<bool>),
    NegHi(Vec<bool>),
    /// `vmcnt(n)`, `expcnt(n)` or `lgkmcnt(n)`.
    Wait {
        counter: Counter,
        value: u64,
    },
    /// A memory instruction's `offset:n` byte offset, which may be negative.
    Offset(i64),
    /// An SDWA instruction's `dst_sel:DWORD` and `dst_unused:UNUSED_PAD`, the only destination
    /// form supported: the whole result word is written.
    SdwaDstDword,
    SdwaDstUnusedPad,
    /// An SDWA instruction's `src0_sel:` or `src1_sel:` selector.
    Src0Sel(SdwaSel),
    Src1Sel(SdwaSel),
    /// A memory instruction's `sc0`, `sc1` or `nt` cache-policy bit (CDNA4 ISA §9.1.10).
    CachePolicy(CachePolicy),
}

/// The cache-policy bits gfx940 and later print in place of `glc`, `slc` and `dlc`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CachePolicy {
    Sc0,
    Sc1,
    Nt,
}

/// The lane each lane of a DPP instruction reads its first source from, within a quad, a row
/// of 16 lanes, or the wave (CDNA4 ISA §6.3.6, "DPP"); `None` is out of range.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DppSelect {
    QuadPerm([u8; 4]),
    RowShl(u8),
    RowShr(u8),
    RowRor(u8),
    WaveShl1,
    WaveRol1,
    WaveShr1,
    WaveRor1,
    RowMirror,
    RowHalfMirror,
    RowBcast15,
    RowBcast31,
}

impl DppSelect {
    pub fn source_lane(self, lane: usize) -> Option<usize> {
        let row = lane & !15;
        let in_row = lane % 16;
        match self {
            Self::QuadPerm(perm) => Some((lane & !3) | usize::from(perm[lane % 4])),
            Self::RowShl(n) => (in_row + usize::from(n) < 16).then(|| lane + usize::from(n)),
            Self::RowShr(n) => in_row.checked_sub(usize::from(n)).map(|i| row + i),
            Self::RowRor(n) => Some(row + (in_row + 16 - usize::from(n)) % 16),
            Self::WaveShl1 => (lane < 63).then_some(lane + 1),
            Self::WaveRol1 => Some((lane + 1) % 64),
            Self::WaveShr1 => lane.checked_sub(1),
            Self::WaveRor1 => Some((lane + 63) % 64),
            Self::RowMirror => Some(row + 15 - in_row),
            Self::RowHalfMirror => Some((lane & !7) + 7 - lane % 8),
            Self::RowBcast15 => (lane >= 16).then(|| row - 1),
            Self::RowBcast31 => (lane >= 32).then_some(31),
        }
    }
}

/// The part of a source word an SDWA instruction reads, zero-extended to a word.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SdwaSel {
    Dword,
    Word0,
    Word1,
}
