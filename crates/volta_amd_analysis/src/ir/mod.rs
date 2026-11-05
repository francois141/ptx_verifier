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

/// A VOP3 source: a VGPR, an SGPR, or an inline integer constant whose 32 bits are the
/// operand, so in an f32 slot `1` is a denormal (LLVM 21.1.8's `printImmediate32`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Vop3Src {
    Vgpr(Vgpr),
    Sgpr(Sgpr),
    Inline(u32),
}

/// A VOP3 f32 source with its input modifiers: `abs` takes the absolute value, then `neg`
/// negates it. The modifiers act on the real the source holds, not on its bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ModifiedSrc {
    pub src: Vop3Src,
    pub abs: bool,
    pub neg: bool,
}

impl ModifiedSrc {
    pub fn is_modified(self) -> bool {
        self.abs || self.neg
    }
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
/// four, eight or sixteen.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarLoadDst {
    Dword(Sgpr),
    Dwordx2([Sgpr; 2]),
    Dwordx4([Sgpr; 4]),
    Dwordx8([Sgpr; 8]),
    Dwordx16([Sgpr; 16]),
}

/// The source of a scalar ALU instruction: an SGPR or a constant whose 32 bits are the operand.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarSrc {
    Sgpr(Sgpr),
    Const(u32),
}

/// A 64-bit scalar ALU source: an aligned SGPR pair, VCC or EXEC as lane masks, or a
/// constant: a sign-extended inline integer, or a 32-bit literal with a clear sign bit.
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

/// A lane mask that selects or receives one bit per lane: VCC or an aligned SGPR pair.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LaneMask {
    Vcc,
    Sgprs([Sgpr; 2]),
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
    /// The high word of the signed product; SCC is unchanged.
    MulHiI32,
    /// SCC is the borrow out.
    SubU32,
    /// `src0 - src1 - SCC`; SCC is the borrow out.
    SubbU32,
    /// Signed minimum; SCC is whether src0 < src1 (CDNA4 §12.1).
    MinI32,
    /// Unsigned minimum; SCC is whether src0 < src1.
    MinU32,
    /// Signed maximum; SCC is whether src0 >= src1 (CDNA4 §12.1).
    MaxI32,
    /// Unsigned maximum; SCC is whether src0 >= src1.
    MaxU32,
    /// SCC is whether the result is nonzero, as for every op below.
    AndB32,
    OrB32,
    XorB32,
    /// `src0 & !src1`.
    AndN2B32,
    /// `src0 | !src1`.
    OrN2B32,
    /// `!(src0 & src1)`.
    NandB32,
    /// `!(src0 | src1)`.
    NorB32,
    /// `!(src0 ^ src1)`.
    XnorB32,
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
    /// SCC is whether the result is nonzero, as for `OrB64` and `AndN2B64`.
    AndB64,
    OrB64,
    XorB64,
    /// `src0 & !src1`.
    AndN2B64,
    /// `src0 | !src1`.
    OrN2B64,
    /// `!(src0 & src1)`.
    NandB64,
    /// `!(src0 | src1)`.
    NorB64,
    /// `!(src0 ^ src1)`.
    XnorB64,
    /// `SCC ? src0 : src1`; SCC is unchanged.
    CSelectB64,
}

/// A 64-bit scalar shift; the count uses its low six bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarShift64 {
    LShlB64,
    LShrB64,
    /// The arithmetic shift right.
    AShrI64,
}

/// A scalar comparison of two words, which writes SCC.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarCmpOp {
    LtI32,
    EqI32,
    LeI32,
    GtI32,
    LgI32,
    GeI32,
    LtU32,
    EqU32,
    LeU32,
    GtU32,
    LgU32,
    GeU32,
    /// Whether bit `src1 & 31` of `src0` is clear.
    BitCmp0B32,
    /// Whether bit `src1 & 31` of `src0` is set.
    BitCmp1B32,
}

/// A scalar comparison of two 64-bit values, which writes SCC.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarCmp64Op {
    EqU64,
    LgU64,
}

/// The condition of a conditional branch, which is uniform across the wave.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BranchCondition {
    /// SCC is clear.
    Scc0,
    /// SCC is set.
    Scc1,
    /// Some lane's VCC bit is set.
    VccNz,
    /// No lane's VCC bit is set.
    VccZ,
    /// No lane is active.
    ExecZ,
    /// Some lane is active.
    ExecNz,
}

/// A raw buffer instruction's address in each lane: the byte offset in the lane's VGPR plus
/// the instruction's immediate byte offset, within the buffer the four-SGPR resource
/// describes. The SGPR offset is the inline constant 0.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct BufferAddress {
    pub vgpr_offset: Vgpr,
    pub rsrc: [Sgpr; 4],
    pub imm_offset: BufferImmOffset,
}

/// A MUBUF instruction's unsigned 12-bit immediate byte offset.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct BufferImmOffset(u16);

impl BufferImmOffset {
    pub const ZERO: Self = Self(0);

    pub fn new(bytes: i64) -> Option<Self> {
        u16::try_from(bytes)
            .ok()
            .filter(|bytes| *bytes <= 0xfff)
            .map(Self)
    }

    pub fn bytes(self) -> u64 {
        u64::from(self.0)
    }
}

/// A DS instruction's accesses in each lane, at its address VGPR plus each byte offset: the one
/// of `ds_{read,write}_b*`, or the two of `ds_{read,write}2{,st64}_b*`, whose offsets lowering
/// has scaled by the element size (and by 64 for `st64`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LdsAccesses<T> {
    One { offset: u16, regs: T },
    Two { offsets: [u32; 2], regs: [T; 2] },
}

impl<T: Copy> LdsAccesses<T> {
    pub fn accesses(self) -> Vec<(u32, T)> {
        match self {
            Self::One { offset, regs } => vec![(u32::from(offset), regs)],
            Self::Two { offsets, regs } => offsets.into_iter().zip(regs).collect(),
        }
    }
}

/// The registers a DS write stores at one address, one per dword: a single VGPR or AGPR, or an
/// even-aligned tuple of two, three or four of one file.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DsWriteData {
    B32(LaneReg),
    B64(LaneRegs<2>),
    B96(LaneRegs<3>),
    B128(LaneRegs<4>),
}

impl DsWriteData {
    pub fn regs(self) -> Vec<LaneReg> {
        match self {
            Self::B32(reg) => vec![reg],
            Self::B64(regs) => regs.regs().to_vec(),
            Self::B96(regs) => regs.regs().to_vec(),
            Self::B128(regs) => regs.regs().to_vec(),
        }
    }
}

/// The VGPRs a DS read loads from one address, one per dword: a single VGPR, or consecutive
/// VGPRs of an even-aligned tuple.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DsReadDst {
    B32(Vgpr),
    B64([Vgpr; 2]),
    B96([Vgpr; 3]),
    B128([Vgpr; 4]),
}

impl DsReadDst {
    pub fn regs(&self) -> &[Vgpr] {
        match self {
            Self::B32(reg) => std::slice::from_ref(reg),
            Self::B64(regs) => regs,
            Self::B96(regs) => regs,
            Self::B128(regs) => regs,
        }
    }
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

/// The VGPRs a buffer load writes, one per dword: a single VGPR, or an even-aligned tuple of
/// two, three or four.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BufferLoadDst {
    Dword(Vgpr),
    Dwordx2([Vgpr; 2]),
    Dwordx3([Vgpr; 3]),
    Dwordx4([Vgpr; 4]),
}

impl BufferLoadDst {
    pub fn regs(&self) -> &[Vgpr] {
        match self {
            Self::Dword(reg) => std::slice::from_ref(reg),
            Self::Dwordx2(regs) => regs,
            Self::Dwordx3(regs) => regs,
            Self::Dwordx4(regs) => regs,
        }
    }
}

/// The registers a buffer store reads, one per dword: a single VGPR or AGPR, or an
/// even-aligned tuple of two, three or four of one file.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BufferStoreSrc {
    Dword(LaneReg),
    Dwordx2(LaneRegs<2>),
    Dwordx3(LaneRegs<3>),
    Dwordx4(LaneRegs<4>),
}

impl BufferStoreSrc {
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

impl TernaryOp {
    /// Whether the operation reads its sources as f32s rather than as words.
    pub fn is_f32(self) -> bool {
        matches!(self, Self::Min3F32 | Self::Max3F32 | Self::Med3F32)
    }
}

/// A VOP3 operation on two concrete 32-bit integers. Symbolic operands are rejected.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Vop3BinOp {
    /// The low word of the product.
    MulLoU32,
    /// The high word of the unsigned product.
    MulHiU32,
    /// The high word of the signed product.
    MulHiI32,
    /// `src1` plus the number of set bits in `src0`.
    BcntU32,
    /// `src1` plus the number of set bits in `src0` below bit `lane`, all 32 from lane 32 on.
    MbcntLoU32,
    /// `src1` plus the number of set bits in `src0` below bit `lane - 32`, none up to lane 32.
    MbcntHiU32,
}

/// A VOP1 operation of one source: the f32 ops and the conversion to u32 read it as an f32,
/// the others as a word.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnaryOp {
    Mov32,
    /// The source's 32 bits in reverse order.
    BfRev32,
    /// The u32 source as an f32.
    CvtF32U32,
    /// The f32 source truncated toward zero and clamped to the u32 range.
    CvtU32F32,
    /// `1 / src`, the reciprocal integer division expansions use.
    RcpIflagF32,
    /// `2^src`.
    Exp2F32,
    /// `log2(src)`.
    Log2F32,
    RcpF32,
    SqrtF32,
    /// `1 / sqrt(src)`.
    RsqF32,
}

/// The relation tested between two ordered values.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CmpPredicate {
    Lt,
    Eq,
    Le,
    Gt,
    Ne,
    Ge,
}

/// Whether a comparison orders integer words as signed or unsigned.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Signedness {
    Signed,
    Unsigned,
}

/// A VOPC comparison of two sources, read as f32s or, for the integer ops, as words.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CmpOp {
    /// The integer comparisons read their words as signed (`I32`) or unsigned (`U32`).
    LtI32,
    EqI32,
    LeI32,
    GtI32,
    NeI32,
    GeI32,
    LtU32,
    EqU32,
    LeU32,
    GtU32,
    NeU32,
    GeU32,
    LtF32,
    LeF32,
    GtF32,
    GeF32,
    EqF32,
    /// Less or greater: an ordered not-equal, which is `!=` for Volta's NaN-free reals.
    LgF32,
}

impl CmpOp {
    /// Whether the comparison reads its sources as f32s rather than as words.
    pub fn is_f32(self) -> bool {
        match self {
            Self::LtI32
            | Self::EqI32
            | Self::LeI32
            | Self::GtI32
            | Self::NeI32
            | Self::GeI32
            | Self::LtU32
            | Self::EqU32
            | Self::LeU32
            | Self::GtU32
            | Self::NeU32
            | Self::GeU32 => false,
            Self::LtF32 | Self::LeF32 | Self::GtF32 | Self::GeF32 | Self::EqF32 | Self::LgF32 => {
                true
            }
        }
    }
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
    /// `dst = src op shift`; SCC is whether the result is nonzero.
    ShiftScalar64 {
        op: ScalarShift64,
        dst: [Sgpr; 2],
        src: ScalarSrc64,
        shift: ScalarSrc,
    },
    ScalarCmp {
        op: ScalarCmpOp,
        src0: ScalarSrc,
        src1: ScalarSrc,
    },
    ScalarCmp64 {
        op: ScalarCmp64Op,
        src0: ScalarSrc64,
        src1: ScalarSrc64,
    },
    /// Sets SCC to whether bit `index & 63` of `src` equals `expected`.
    BitCmpScalar64 {
        src: ScalarSrc64,
        index: ScalarSrc,
        expected: bool,
    },
    Branch {
        target: InstrId,
    },
    CondBranch {
        condition: BranchCondition,
        target: InstrId,
    },
    /// Waits until every wave of the workgroup that has not exited reaches a barrier.
    Barrier,
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
        srcs: [ModifiedSrc; 3],
    },
    /// `dst = op(src0, src1)` in each lane.
    Vop3BinOp {
        op: Vop3BinOp,
        dst: Vgpr,
        src0: Vop3Src,
        src1: Vop3Src,
    },
    /// `dst = op src` in each lane.
    UnaryOp {
        op: UnaryOp,
        dst: Vgpr,
        src: Src0,
    },
    /// Copy a 64-bit source's words, low first, into a VGPR pair in each lane.
    Mov64 {
        dst: [Vgpr; 2],
        src: [Src0; 2],
    },
    /// Sets each lane's VCC bit to `src0 op src1`.
    Cmp {
        op: CmpOp,
        src0: Src0,
        src1: Vgpr,
    },
    /// Sets each lane's bit of VCC or an SGPR-pair mask to `src0 op src1`. Each source is two
    /// concrete words, low word first, that form one 64-bit integer of the given signedness.
    /// Lowering enforces each encoding's source forms.
    Cmp64 {
        op: CmpPredicate,
        signedness: Signedness,
        dst: LaneMask,
        src0: [Src0; 2],
        src1: [Src0; 2],
    },
    /// Sets each lane's bit of VCC or an SGPR-pair mask to `src0 op src1`. Only an f32
    /// comparison's sources may carry input modifiers.
    CmpE64 {
        op: CmpOp,
        dst: LaneMask,
        src0: ModifiedSrc,
        src1: ModifiedSrc,
    },
    /// `dst = VCC ? src1 : src0` in each lane.
    CndMask32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    /// `dst = mask ? src1 : src0` in each lane. Any input modifier reads both sources as f32s.
    CndMask32E64 {
        dst: Vgpr,
        src0: ModifiedSrc,
        src1: ModifiedSrc,
        mask: LaneMask,
    },
    /// `dst = src0 * src1 + src2` over unsigned 64-bit words, with the u32 sources and the
    /// carry out of 64 bits in each lane's bit of `carry`.
    MadU64U32 {
        dst: [Vgpr; 2],
        carry: [Sgpr; 2],
        src0: Vop3Src,
        src1: Vop3Src,
        src2: [Vgpr; 2],
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
        src0: ModifiedSrc,
        src1: ModifiedSrc,
        src2: ModifiedSrc,
    },
    /// `dst = src0 * src1 + dst`.
    FmacF32 {
        dst: Vgpr,
        src0: Src0,
        src1: Vgpr,
    },
    /// Add two f32 components; lowering resolves each source's word selectors.
    PackedAddF32 {
        dst: [Vgpr; 2],
        src0: [Vop3Src; 2],
        src1: [Vop3Src; 2],
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
    /// Words out of the buffer's range read as zero.
    BufferLoad {
        dst: BufferLoadDst,
        address: BufferAddress,
    },
    /// Words out of the buffer's range are dropped.
    BufferStore {
        src: BufferStoreSrc,
        address: BufferAddress,
    },
    /// The accesses write in order, so the second of two overlapping ones wins.
    DsWrite {
        addr: Vgpr,
        accesses: LdsAccesses<DsWriteData>,
    },
    /// The accesses' words load as one pending load for `lgkmcnt`.
    DsRead {
        addr: Vgpr,
        accesses: LdsAccesses<DsReadDst>,
    },
    /// Each lane reads `src` from the lane selected by its byte address plus `offset`.
    DsBPermute {
        dst: Vgpr,
        addr: Vgpr,
        src: Vgpr,
        offset: u16,
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
