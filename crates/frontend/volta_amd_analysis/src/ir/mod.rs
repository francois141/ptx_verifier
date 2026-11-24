//! Typed AMD instructions between lowering and execution.

use std::collections::BTreeMap;

use id_collections::{IdVec, id_type};
use volta_common::float_bits::F8Format;

pub use crate::frontend::ast::DppSelect;

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

impl Sgpr {
    /// M0, at its operand encoding 124, past the general-purpose SGPRs.
    pub const M0: Sgpr = Sgpr(124);
}

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
pub enum MfmaSrcC<const N: usize = 4> {
    Regs(LaneRegs<N>),
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

/// A float source with its input modifiers: `abs` takes the absolute value, then `neg` negates
/// it. The modifiers act on the real the source holds, not on its bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ModifiedSrc<S = Vop3Src> {
    pub src: S,
    pub abs: bool,
    pub neg: bool,
}

impl<S> ModifiedSrc<S> {
    pub fn is_modified(&self) -> bool {
        self.abs || self.neg
    }
}

/// An f64 source: a VGPR pair, an SGPR pair, or the 64 bits of a constant.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum F64Src {
    Vgprs([Vgpr; 2]),
    Sgprs([Sgpr; 2]),
    Const(u64),
}

/// An f64 operation over its modified sources.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum F64Op {
    Add([ModifiedSrc<F64Src>; 2]),
    Mul([ModifiedSrc<F64Src>; 2]),
    Min([ModifiedSrc<F64Src>; 2]),
    Max([ModifiedSrc<F64Src>; 2]),
    Fma([ModifiedSrc<F64Src>; 3]),
    Rcp([ModifiedSrc<F64Src>; 1]),
    Sqrt([ModifiedSrc<F64Src>; 1]),
    /// `1 / sqrt(src)`.
    Rsq([ModifiedSrc<F64Src>; 1]),
}

/// The source type of a conversion to f64.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CvtToF64Op {
    F32,
    I32,
    U32,
}

/// The result type of a conversion from f64; integer results truncate toward zero and clamp.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CvtFromF64Op {
    F32,
    I32,
    U32,
}

/// Packed f32 arithmetic with two selected components per source. The operand count
/// follows the operation; every component remains a separate mathematical expression.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PackedF32Op {
    Add([[ModifiedSrc; 2]; 2]),
    Mul([[ModifiedSrc; 2]; 2]),
    Fma([[ModifiedSrc; 2]; 3]),
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

/// A 64-bit scalar ALU source: an aligned SGPR pair, VCC or EXEC as lane masks, a constant
/// (a sign-extended inline integer, or a 32-bit literal with a clear sign bit), or the LDS
/// aperture's base.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarSrc64 {
    Sgprs([Sgpr; 2]),
    Vcc,
    Exec,
    Const(u64),
    SharedBase,
}

/// The LDS aperture's base, `src_shared_base`: the shared aperture `SH_MEM_BASES` places at
/// bits 63:48, its low word 0. Kernels only form generic pointers from it to convert back to
/// LDS offsets by truncation; the model accesses no memory through it.
pub const SHARED_APERTURE_BASE: u64 = 0x0001_0000_0000_0000;

/// A 64-bit scalar ALU destination: an aligned SGPR pair, VCC, or EXEC, the wave's mask of
/// active lanes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarDst64 {
    Sgprs([Sgpr; 2]),
    Vcc,
    Exec,
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
    /// `(src0 << n) + src1` for `n` in 1..=4; SCC is the carry out of the 64-bit sum.
    LShlAddU32(u8),
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
    /// The field of `src0` at bit `src1[4:0]`, `src1[22:16]` bits wide.
    BfeU32,
    /// `BfeU32`'s field, sign-extended from its top bit.
    BfeI32,
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

/// The operand order of a scalar operation that writes EXEC.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExecOrder {
    /// `src op EXEC`.
    SrcExec,
    /// `EXEC op src`.
    ExecSrc,
}

/// Which EXEC a scalar operation that writes EXEC copies to its destination.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExecCopy {
    /// EXEC as it was before the operation (`saveexec`).
    Saved,
    /// EXEC as the operation leaves it (`wrexec`).
    Written,
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
/// the scalar offset plus the instruction's immediate byte offset, within the buffer the
/// four-SGPR resource describes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct BufferAddress {
    /// `None` for `off`: the address has no per-lane offset.
    pub vgpr_offset: Option<Vgpr>,
    pub rsrc: [Sgpr; 4],
    pub soffset: ScalarSrc,
    pub imm_offset: BufferImmOffset,
}

/// The words each lane of a buffer load to LDS moves.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BufferLdsWidth {
    Dword,
    Dwordx4,
}

impl BufferLdsWidth {
    pub fn words(self) -> u32 {
        match self {
            Self::Dword => 1,
            Self::Dwordx4 => 4,
        }
    }
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
    Dwordx2([Vgpr; 2]),
    Dwordx3([Vgpr; 3]),
    Dwordx4([Vgpr; 4]),
}

impl GlobalLoadDst {
    pub fn regs(&self) -> &[Vgpr] {
        match self {
            Self::Dword(reg) => std::slice::from_ref(reg),
            Self::Dwordx2(regs) => regs,
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
    /// 16 bits, zero-extended: a bf16 element in the low half and +0 in the high one.
    Ushort(Vgpr),
    Dword(Vgpr),
    Dwordx2([Vgpr; 2]),
    Dwordx3([Vgpr; 3]),
    Dwordx4([Vgpr; 4]),
}

impl BufferLoadDst {
    pub fn regs(&self) -> &[Vgpr] {
        match self {
            Self::Ushort(reg) | Self::Dword(reg) => std::slice::from_ref(reg),
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
    /// The low 16 bits: a bf16 element.
    Short(LaneReg),
    Dword(LaneReg),
    Dwordx2(LaneRegs<2>),
    Dwordx3(LaneRegs<3>),
    Dwordx4(LaneRegs<4>),
}

impl BufferStoreSrc {
    pub fn regs(self) -> Vec<LaneReg> {
        match self {
            Self::Short(reg) | Self::Dword(reg) => vec![reg],
            Self::Dwordx2(regs) => regs.regs().to_vec(),
            Self::Dwordx3(regs) => regs.regs().to_vec(),
            Self::Dwordx4(regs) => regs.regs().to_vec(),
        }
    }
}

/// A global instruction's address in each lane: its base plus a signed 13-bit immediate byte
/// offset.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct GlobalAddress {
    pub base: GlobalBase,
    pub offset: i16,
}

/// A global address before its immediate offset: an SGPR-pair base plus a 32-bit VGPR offset,
/// or, for `off`, a 64-bit address in a VGPR pair.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GlobalBase {
    Scalar { vaddr: Vgpr, saddr: [Sgpr; 2] },
    Vector([Vgpr; 2]),
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
    /// The 16-bit ops below write their 16-bit result zero-extended, as gfx9's VOP2 does:
    /// `src0 + src1`.
    AddU16,
    /// `src0 - src1`.
    SubU16,
    /// The logical `src1 >> src0` of the low halves, the count's low four bits.
    LShrRevB16,
    /// The arithmetic `src1 >> src0` of the low halves, the count's low four bits.
    AShrRevI16,
    AddF32,
    /// `src0 - src1`.
    SubF32,
    /// `src1 - src0`.
    SubRevF32,
    MulF32,
    MinF32,
    MaxF32,
}

/// A scalar operation of one 32-bit source.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScalarUnaryOp32 {
    /// `|src|`, signed; SCC is whether the result is nonzero.
    AbsI32,
    /// The source's 32 bits in reverse order; SCC is unchanged.
    BRevB32,
}

impl ScalarUnaryOp32 {
    pub fn name(self) -> &'static str {
        match self {
            Self::AbsI32 => "s_abs_i32",
            Self::BRevB32 => "s_brev_b32",
        }
    }
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
    /// Each result byte chosen from the 64-bit `src0:src1` by a byte of `src2`: 0 to 7 name
    /// its bytes, low first, and 12 a zero byte.
    Perm32,
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

/// A VOP1 operation of one source: the f32 ops and the conversions to integers read it as an
/// f32, the others as a word.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnaryOp {
    Mov32,
    /// Invert all 32 bits of a concrete word.
    Not32,
    /// The source's 32 bits in reverse order.
    BfRev32,
    /// The i32 source as an f32.
    CvtF32I32,
    /// The u32 source as an f32.
    CvtF32U32,
    /// The signed 4-bit integer in bits 3:0 of the source, divided by 16.
    CvtOffF32I4,
    /// One byte of the source as an unsigned integer, as an f32.
    CvtF32Ubyte(WordByte),
    /// The f32 source truncated toward zero and clamped to the i32 range.
    CvtI32F32,
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
    /// The integer nearest the f32 source, ties to even, as an f32.
    RndneF32,
    /// The f32 source rounded toward zero, as an f32.
    TruncF32,
    /// The mantissa `m` of `src = m * 2^e`, `|m|` in [1/2, 1), and `e` as an i32: LLVM's
    /// denormal-safe f32 division and reciprocal scale through them.
    FrexpMantF32,
    FrexpExpI32F32,
}

/// A byte of a 32-bit word, from the least significant.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WordByte {
    B0,
    B1,
    B2,
    B3,
}

impl WordByte {
    pub fn shift(self) -> u32 {
        match self {
            WordByte::B0 => 0,
            WordByte::B1 => 8,
            WordByte::B2 => 16,
            WordByte::B3 => 24,
        }
    }
}

/// What a DPP lane whose source lane is out of range or inactive does: keep its destination,
/// or read 0 as its first source (`bound_ctrl:1`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DppBound {
    Keep,
    Zero,
}

/// A DPP instruction's lane selection and write masks: a lane writes only when its row
/// (lanes `16 r ..`) and bank (lanes `4 b ..` of each row) are enabled.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct DppControl {
    pub select: DppSelect,
    pub row_mask: u8,
    pub bank_mask: u8,
    pub bound: DppBound,
}

impl DppControl {
    pub fn writes(self, lane: usize) -> bool {
        self.row_mask >> (lane / 16) & 1 == 1 && self.bank_mask >> (lane / 4 % 4) & 1 == 1
    }
}

/// A 32-bit vector add or subtract with a carry (or borrow) out, and for `Addc`, `Subb` and
/// `SubbRev` a carry in; `Rev` operations subtract `src0` from `src1`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CarryOp {
    Add,
    Addc,
    Sub,
    Subb,
    SubRev,
    SubbRev,
}

impl CarryOp {
    /// The result word and the carry out, over concrete words.
    pub fn apply(self, a: u32, b: u32, carry_in: bool) -> (u32, bool) {
        let (a, b, c) = (u64::from(a), u64::from(b), u64::from(carry_in));
        match self {
            Self::Add | Self::Addc => {
                let sum = a + b + c;
                (sum as u32, sum >> 32 != 0)
            }
            Self::Sub | Self::Subb => (a.wrapping_sub(b + c) as u32, b + c > a),
            Self::SubRev | Self::SubbRev => (b.wrapping_sub(a + c) as u32, a + c > b),
        }
    }
}

/// A 64-bit multiply-add's addend: a VGPR pair, or an inline integer sign-extended to 64 bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Addend64 {
    Vgprs([Vgpr; 2]),
    Inline(i64),
}

/// The VOP1 or VOP2 operation a DPP instruction applies to its permuted first source.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DppOp {
    Mov,
    Bin(BinOp),
}

/// The operation of an SDWA instruction on its selected source words.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SdwaOp {
    /// `src0 & src1`.
    And32,
    /// `src0 | src1`.
    Or32,
    /// `src0 ^ src1`.
    Xor32,
    /// `VCC ? src1 : src0`.
    CndMask32,
    /// `VCC ? src0 : src1`: a `v_cndmask_b32_sdwa` selecting a half of its second source, its
    /// operands swapped so the selected one comes first.
    CndMask32Swapped,
    /// The selected half shifted left by `src1`: `v_lshlrev_b32_sdwa`, its operands swapped so
    /// the selected one comes first.
    LShl32,
}

/// How an SDWA source's selected 16-bit half widens to a word: `sext(...)` sign-extends it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HalfExtension {
    Zero,
    Sign,
}

/// A 16-bit half of a 32-bit word.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WordHalf {
    Low,
    High,
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
    /// Whether neither source is a NaN: always, for Volta's NaN-free reals.
    OF32,
    /// Whether either source is a NaN: never.
    UF32,
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
            Self::LtF32
            | Self::LeF32
            | Self::GtF32
            | Self::GeF32
            | Self::EqF32
            | Self::LgF32
            | Self::OF32
            | Self::UF32 => true,
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
    /// `dst = op src`.
    ScalarUnary32 {
        op: ScalarUnaryOp32,
        dst: Sgpr,
        src: ScalarSrc,
    },
    /// `dst` = the number of set bits of a 64-bit source; SCC is whether it is nonzero.
    ScalarBitCount64 {
        dst: Sgpr,
        src: ScalarSrc64,
    },
    /// Set (`value` true) or clear bit `bit[4:0]` of `dst`, leaving its other bits and SCC.
    ScalarBitSet32 {
        dst: Sgpr,
        bit: ScalarSrc,
        value: bool,
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
    /// `EXEC = op` over `src` and EXEC, in the order `order` gives; SCC is whether any lane stays
    /// active. `dst` receives the EXEC that `copy` selects.
    ExecOp64 {
        op: ScalarOp64,
        order: ExecOrder,
        copy: ExecCopy,
        dst: ScalarDst64,
        src: ScalarSrc64,
    },
    /// `dst = src op shift`; SCC is whether the result is nonzero.
    ShiftScalar64 {
        op: ScalarShift64,
        dst: [Sgpr; 2],
        src: ScalarSrc64,
        shift: ScalarSrc,
    },
    /// `dst` is the field of `src` that `field` encodes (offset in bits 5:0, width in bits
    /// 22:16), sign-extended from its top bit; SCC is whether the result is nonzero.
    BfeI64Scalar {
        dst: [Sgpr; 2],
        src: ScalarSrc64,
        field: ScalarSrc,
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
    /// Copy the lowest active lane's value into an SGPR, or lane 0's when no lane is active.
    ReadFirstLane {
        dst: Sgpr,
        src: Vgpr,
    },
    /// `dst = src` of lane `lane % 64`, whether or not that lane is active.
    ReadLane {
        dst: Sgpr,
        src: Vgpr,
        lane: ScalarSrc,
    },
    /// Lane `lane % 64` of `dst` = `src`, whether or not that lane is active.
    WriteLane {
        dst: Vgpr,
        src: ScalarSrc,
        lane: ScalarSrc,
    },
    /// The IEEE f32 division sequence over the reals, where no operand needs rescaling:
    /// `v_div_scale_f32` is its first source and clears its lane's bit of `scaled`,
    /// `v_div_fmas_f32` is an fma that requires VCC clear, `v_div_fixup_f32` its quotient.
    DivScaleF32 {
        dst: Vgpr,
        scaled: LaneMask,
        src: ModifiedSrc,
    },
    DivFmasF32 {
        dst: Vgpr,
        srcs: [ModifiedSrc; 3],
    },
    DivFixupF32 {
        dst: Vgpr,
        quotient: ModifiedSrc,
    },
    /// `dst = src0 op src1` in each lane, in either encoding. Only f32 operations take input
    /// modifiers.
    BinOp {
        op: BinOp,
        dst: Vgpr,
        src0: ModifiedSrc,
        src1: ModifiedSrc,
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
    /// `dst = op src` in each lane; only an f32 operation's e64 form has input modifiers.
    UnaryOp {
        op: UnaryOp,
        dst: Vgpr,
        src: ModifiedSrc,
    },
    /// `dst = src0 * 2^src1` in each lane, `src1` an i32.
    LdexpF32 {
        dst: Vgpr,
        src0: ModifiedSrc,
        src1: Vop3Src,
    },
    /// Copy two selected source words into a VGPR pair in each lane.
    Mov64 {
        dst: [Vgpr; 2],
        src: [Src0; 2],
    },
    /// Store `half` of `src` (`ds_write_b16`: its low bf16, `_d16_hi`: its high one) at the
    /// 2-byte aligned `addr + offset`, keeping the other half of its LDS word.
    DsWriteB16 {
        addr: Vgpr,
        offset: u16,
        src: Vgpr,
        half: WordHalf,
    },
    /// `dst = (src << shift) + addend` over concrete unsigned 64-bit words, the shift taken
    /// modulo 64 (`v_lshlrev_b64` has no addend, `v_lshl_add_u64` a shift of at most 4).
    ShiftAdd64 {
        dst: [Vgpr; 2],
        src: [Src0; 2],
        shift: Vop3Src,
        addend: Option<[Src0; 2]>,
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
    /// Sets each lane's bit of VCC or an SGPR-pair mask to `src0 op src1` over f64 values.
    CmpF64 {
        op: CmpPredicate,
        dst: LaneMask,
        src0: ModifiedSrc<F64Src>,
        src1: ModifiedSrc<F64Src>,
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
    /// `dst = op(src0 of the lane `control` selects, src1)` in each active lane `control`
    /// writes; every source lane is read before any destination is written.
    Dpp {
        op: DppOp,
        dst: Vgpr,
        src0: ModifiedSrc<Vgpr>,
        src1: ModifiedSrc,
        control: DppControl,
    },
    /// `dst = op(src0, src1, carry_in)` over concrete words in each active lane, its carry
    /// out in `carry_out`, whose inactive lanes' bits are cleared.
    CarryOp32 {
        op: CarryOp,
        dst: Vgpr,
        carry_out: LaneMask,
        src0: Vop3Src,
        src1: Vop3Src,
        carry_in: Option<LaneMask>,
    },
    /// A VOP2 SDWA instruction reading one 16-bit half of `src0`, widened by `extension`, and
    /// all of `src1`, writing the whole word (`dst_sel:DWORD`, `dst_unused:UNUSED_PAD`).
    SdwaWord {
        op: SdwaOp,
        dst: Vgpr,
        src0: Vgpr,
        half: WordHalf,
        extension: HalfExtension,
        src1: Vop3Src,
    },
    /// `dst = src0 * src1 + src2` over 64-bit words, the 32-bit sources and the addend of the
    /// given signedness. An unsigned op writes the carry out of 64 bits in each lane's bit of
    /// `carry`; a signed op's `carry` is left unknown.
    Mad64 {
        signedness: Signedness,
        dst: [Vgpr; 2],
        carry: [Sgpr; 2],
        src0: Vop3Src,
        src1: Vop3Src,
        src2: Addend64,
    },
    /// Copy a VGPR, an SGPR or an inline constant into an AGPR without changing its value.
    AccvgprWrite32 {
        dst: Agpr,
        src: Vop3Src,
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
    /// The two f32 sources as `format` codes, `srcs[0]` in the low byte, written to `half` of
    /// `dst`; the other half keeps its bits.
    CvtPkF8F32 {
        format: F8Format,
        dst: Vgpr,
        srcs: [Src0; 2],
        half: WordHalf,
    },
    /// `dst = op(srcs)` in each lane, as one f64 value across the pair.
    F64 {
        dst: [Vgpr; 2],
        op: F64Op,
    },
    /// Convert a source to one f64 value across the pair in each lane.
    CvtToF64 {
        op: CvtToF64Op,
        dst: [Vgpr; 2],
        src: ModifiedSrc<Src0>,
    },
    /// Convert an f64 source in each lane.
    CvtFromF64 {
        op: CvtFromF64Op,
        dst: Vgpr,
        src: ModifiedSrc<F64Src>,
    },
    /// Compute two f32 results; lowering resolves source-word selectors and negation.
    PackedF32 {
        dst: [Vgpr; 2],
        op: PackedF32Op,
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
    /// The wave's `D = A * B + C` for a 16 x 32 bf16 `A`, a 32 x 16 bf16 `B` and 16 x 16 f32 `C`
    /// and `D`: lane `l` holds `A[l % 16][8 * (l / 16) + j]` and `B[8 * (l / 16) + j][l % 16]` as
    /// its `j`th bf16, and accumulator register `r` holds `C[4 * (l / 16) + r][l % 16]`.
    Mfma16x16x32Bf16 {
        dst: LaneRegs<4>,
        src_a: LaneRegs<4>,
        src_b: LaneRegs<4>,
        src_c: MfmaSrcC,
    },
    /// The wave's `D = A * B + C` over bf16 `A` and `B` and f32 `C` and `D`, for a 32 x 16 `A`,
    /// a 16 x 32 `B` and 32 x 32 `C` and `D`: lane `l` holds `A[l % 32][8 * (l / 32) + j]` and
    /// `B[8 * (l / 32) + j][l % 32]` as the `j`th bf16 of its source registers, low half first,
    /// and its `r`th accumulator register `C[8 * (r / 4) + 4 * (l / 32) + r % 4][l % 32]`.
    Mfma32x32x16Bf16 {
        dst: LaneRegs<16>,
        src_a: LaneRegs<4>,
        src_b: LaneRegs<4>,
        src_c: MfmaSrcC<16>,
    },
    /// The two f32 sources as the bf16 halves of `dst`, `srcs[0]` in the low half.
    CvtPkBf16F32 {
        dst: Vgpr,
        srcs: [ModifiedSrc; 2],
    },
    /// Swap the odd 16-lane rows of `dst` with the even rows of `src`, writing both registers.
    Permlane16Swap {
        dst: Vgpr,
        src: Vgpr,
    },
    /// Swap lanes 32 to 63 of `dst` with lanes 0 to 31 of `src`, writing both registers.
    Permlane32Swap {
        dst: Vgpr,
        src: Vgpr,
    },
    GlobalLoad {
        dst: GlobalLoadDst,
        address: GlobalAddress,
    },
    /// `global_store_short_d16_hi`: store the high 16 bits of `src`, one bf16 element.
    GlobalStoreHigh16 {
        src: LaneReg,
        address: GlobalAddress,
    },
    /// `global_load_ushort`: 16 bits zero-extended, as `buffer_load_ushort` loads them.
    GlobalLoadUshort {
        dst: Vgpr,
        address: GlobalAddress,
    },
    /// `global_store_short`: store the low 16 bits of `src`, one bf16 element.
    GlobalStoreShort {
        src: LaneReg,
        address: GlobalAddress,
    },
    /// Load a lane's private (scratch) dwords at byte `offset`, addressed by the offset alone
    /// (`vaddr` and `saddr` both `off`), as a compiler's register spills are.
    ScratchLoad {
        dst: GlobalLoadDst,
        offset: u16,
    },
    /// Store registers to a lane's private dwords at byte `offset`.
    ScratchStore {
        src: GlobalStoreSrc,
        offset: u16,
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
    /// Each active lane loads `width` words as `BufferLoad` does and writes them to LDS at
    /// `M0 + 4 * words * lane` instead of to VGPRs; `vmcnt` counts it.
    BufferLoadLds {
        width: BufferLdsWidth,
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
    /// A transposing read of 16-bit elements: each lane addresses 8 bytes at its address VGPR
    /// plus `offset`, and receives four elements gathered across its group of lanes.
    DsReadTrB16 {
        dst: [Vgpr; 2],
        addr: Vgpr,
        offset: u16,
    },
    /// `ds_swizzle_b32` in its swap mode: each active lane reads `src` of lane `lane ^ xor`,
    /// an LDS lane exchange that accesses no LDS memory.
    DsSwizzle {
        dst: Vgpr,
        src: Vgpr,
        xor: u8,
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

impl LoweredInstr {
    /// The instruction's family, as the event graph's provenance names it.
    pub fn name(&self) -> &'static str {
        match self {
            Self::ScalarLoad { .. } => "s_load",
            Self::MovScalar32 { .. } => "s_mov_b32",
            Self::MovScalar64 { .. } => "s_mov_b64",
            Self::ScalarUnary32 { op, .. } => op.name(),
            Self::ScalarBitCount64 { .. } => "s_bcnt1_i32_b64",
            Self::ScalarBitSet32 { value, .. } => {
                if *value {
                    "s_bitset1_b32"
                } else {
                    "s_bitset0_b32"
                }
            }
            Self::ScalarOp32 { .. } => "scalar op",
            Self::ScalarOp64 { .. } => "scalar op (64-bit)",
            Self::ExecOp64 { .. } => "scalar op (EXEC)",
            Self::ShiftScalar64 { .. } => "scalar shift (64-bit)",
            Self::BfeI64Scalar { .. } => "s_bfe_i64",
            Self::ScalarCmp { .. } => "s_cmp",
            Self::ScalarCmp64 { .. } => "s_cmp (64-bit)",
            Self::BitCmpScalar64 { .. } => "s_bitcmp (64-bit)",
            Self::Branch { .. } => "s_branch",
            Self::CondBranch { .. } => "s_cbranch",
            Self::Barrier => "s_barrier",
            Self::ReadFirstLane { .. } => "v_readfirstlane_b32",
            Self::ReadLane { .. } => "v_readlane_b32",
            Self::WriteLane { .. } => "v_writelane_b32",
            Self::DivScaleF32 { .. } => "v_div_scale_f32",
            Self::DivFmasF32 { .. } => "v_div_fmas_f32",
            Self::DivFixupF32 { .. } => "v_div_fixup_f32",
            Self::BinOp { .. } => "vector op",
            Self::TernaryOp { .. } => "vector op (3 sources)",
            Self::Vop3BinOp { .. } => "vector op (e64)",
            Self::UnaryOp { .. } => "vector op (1 source)",
            Self::LdexpF32 { .. } => "v_ldexp_f32",
            Self::Mov64 { .. } => "vector move (64-bit)",
            Self::Cmp { .. } => "v_cmp",
            Self::Cmp64 { .. } => "v_cmp (64-bit)",
            Self::CmpF64 { .. } => "v_cmp (f64)",
            Self::CmpE64 { .. } => "v_cmp (e64)",
            Self::CndMask32 { .. } => "v_cndmask_b32",
            Self::CndMask32E64 { .. } => "v_cndmask_b32 (e64)",
            Self::SdwaWord { .. } => "vector op (SDWA)",
            Self::Dpp { .. } => "vector op (DPP)",
            Self::DsWriteB16 {
                half: WordHalf::Low,
                ..
            } => "ds_write_b16",
            Self::DsWriteB16 {
                half: WordHalf::High,
                ..
            } => "ds_write_b16_d16_hi",
            Self::ShiftAdd64 { .. } => "64-bit vector shift",
            Self::CarryOp32 { .. } => "vector add/sub with carry",
            Self::Mad64 { signedness, .. } => match signedness {
                Signedness::Unsigned => "v_mad_u64_u32",
                Signedness::Signed => "v_mad_i64_i32",
            },
            Self::AccvgprWrite32 { .. } => "v_accvgpr_write_b32",
            Self::AccvgprRead32 { .. } => "v_accvgpr_read_b32",
            Self::FmaF32 { .. } => "v_fma_f32",
            Self::FmacF32 { .. } => "v_fmac_f32",
            Self::CvtPkF8F32 { format, .. } => match format {
                F8Format::E4M3 => "v_cvt_pk_fp8_f32",
                F8Format::E5M2 => "v_cvt_pk_bf8_f32",
            },
            Self::F64 { .. } => "f64 op",
            Self::CvtToF64 { .. } => "v_cvt to f64",
            Self::CvtFromF64 { .. } => "v_cvt from f64",
            Self::PackedF32 { .. } => "packed f32 op",
            Self::Mfma16x16x4F32 { .. } => "v_mfma_f32_16x16x4_f32",
            Self::Mfma32x32x16Bf16 { .. } => "v_mfma_f32_32x32x16_bf16",
            Self::Mfma16x16x32Bf16 { .. } => "v_mfma_f32_16x16x32_bf16",
            Self::CvtPkBf16F32 { .. } => "v_cvt_pk_bf16_f32",
            Self::Permlane32Swap { .. } => "v_permlane32_swap_b32",
            Self::Permlane16Swap { .. } => "v_permlane16_swap_b32",
            Self::BufferLoadLds { .. } => "buffer_load (to LDS)",
            Self::DsReadTrB16 { .. } => "ds_read_b64_tr_b16",
            Self::GlobalLoad { .. } => "global_load",
            Self::GlobalStoreHigh16 { .. } => "global_store_short_d16_hi",
            Self::GlobalLoadUshort { .. } => "global_load_ushort",
            Self::GlobalStoreShort { .. } => "global_store_short",
            Self::ScratchLoad { .. } => "scratch_load",
            Self::ScratchStore { .. } => "scratch_store",
            Self::GlobalStore { .. } => "global_store",
            Self::BufferLoad { .. } => "buffer_load",
            Self::BufferStore { .. } => "buffer_store",
            Self::DsWrite { .. } => "ds_write",
            Self::DsRead { .. } => "ds_read",
            Self::DsBPermute { .. } => "ds_bpermute_b32",
            Self::DsSwizzle { .. } => "ds_swizzle_b32",
            Self::WaitCnt { .. } => "s_waitcnt",
            Self::Nop => "s_nop",
            Self::EndPgm => "s_endpgm",
        }
    }
}
