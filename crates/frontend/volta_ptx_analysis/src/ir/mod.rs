//! Lowered PTX instructions: the output of the lowering pass, with resolved
//! register indices and branch PCs, unneeded modifiers stripped, and unified
//! instruction formats.

pub mod mma;
pub mod source_map;
pub mod symbols;
pub mod tcgen05;
pub mod tensor_map;
pub mod types;

use std::fmt;
use std::ops::RangeInclusive;

use crate::frontend::ast::{ClampWrapMode, ScalarType, ShiftDir};
use id_collections::{IdVec, id_type};

use crate::ir::source_map::SourceMap;
use crate::ir::symbols::{ParamId, RegId, SpecialRegKind, SymbolTable};
use crate::ir::tcgen05::{
    Tcgen05Collector, Tcgen05FenceDirection, Tcgen05LdStShape, Tcgen05MmaA, Tcgen05MmaKind,
    Tcgen05MmaScales,
};
use crate::ir::tensor_map::{TensorLoadMode, TensormapFieldWrite};
use crate::ir::types::RegCounts;
pub use volta_graph::BulkWaitScope;

/// Instruction index (program counter)
#[id_type]
pub struct InstrId(pub u32);

impl fmt::Display for InstrId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "pc:{}", self.0)
    }
}

/// The PTX ISA's range for an `mbarrier.init` expected arrival count and an
/// `mbarrier.arrive` count.
pub const MBARRIER_COUNT_RANGE: RangeInclusive<u64> = 1..=(1 << 20) - 1;

/// The PTX ISA's range for an mbarrier phase's tx-count.
pub const MBARRIER_TX_COUNT_RANGE: RangeInclusive<i64> = -((1 << 20) - 1)..=(1 << 20) - 1;

/// A resolved operand - either a register, immediate, or special register
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Operand {
    /// A general-purpose register
    Reg(RegId),
    /// A special register (resolved at runtime based on thread ID)
    SpecialReg(SpecialRegKind),
    /// Immediate signed integer
    ImmI64(i64),
    /// Immediate unsigned integer
    ImmU64(u64),
    /// Immediate float
    ImmF64(f64),
}

impl Operand {
    /// Extract the RegId if this is a general-purpose register operand.
    pub fn as_reg(&self) -> Option<RegId> {
        match self {
            Self::Reg(r) => Some(*r),
            _ => None,
        }
    }
}

/// The optional third data operand of `cp.async`.
#[derive(Debug, Clone, Copy)]
pub enum CpAsyncSrcSize {
    /// Neither `src-size` nor `ignore-src` given: all `cp_size` bytes are copied.
    Full,
    /// The `src-size` operand: this many bytes (must be <= `cp_size`) are
    /// copied, the rest of the destination is zero-filled.
    Sized(Operand),
    /// The `ignore-src` predicate operand: if true at runtime, the
    /// destination is entirely zero-filled; if false, behaves as `Full`.
    IgnoreSrc(Operand),
}

/// A predicate guard for an instruction
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Predicate {
    pub reg: RegId,
    pub negated: bool,
}

/// Comparison operators for setp/set
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CmpOp {
    // Ordered comparisons (for integers or floats, return false if NaN)
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
    // Unsigned integer comparisons
    Lo,
    Ls,
    Hi,
    Hs,
    // Unordered float comparisons (return true if NaN)
    Equ,
    Neu,
    Ltu,
    Leu,
    Gtu,
    Geu,
    // NaN checks
    Num, // Both operands are numbers (not NaN)
    Nan, // Either operand is NaN
}

/// Binary arithmetic/logic operations
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BinOp {
    // Arithmetic
    Add,
    Sub,
    Mul,
    Div,
    Rem,
    // Bitwise
    And,
    Or,
    Xor,
    // Shifts
    Shl,
    Shr,
    // Min/Max
    Min,
    Max,
}

impl BinOp {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Add => "add",
            Self::Sub => "sub",
            Self::Mul => "mul",
            Self::Div => "div",
            Self::Rem => "rem",
            Self::And => "and",
            Self::Or => "or",
            Self::Xor => "xor",
            Self::Shl => "shl",
            Self::Shr => "shr",
            Self::Min => "min",
            Self::Max => "max",
        }
    }
}

/// Unary operations
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UnaryOp {
    // Arithmetic
    Neg,
    Abs,
    // Bitwise
    Not,
    // Floating-point
    Rcp,
    Sqrt,
    Rsqrt,
    // Transcendental
    Ex2,
    Lg2,
    /// Natural exponential e^x (from `call __symexpf`, the paper's hook for
    /// symbolic exp; there is no such PTX instruction)
    Exp,
    /// Hyperbolic tangent (evaluated as `(e^2x - 1) / (e^2x + 1)`, staying
    /// in the interpreted exp fragment rather than becoming an opaque atom
    /// - the same approach as `Ex2`).
    Tanh,
}

/// Whether a named-barrier instruction is `.aligned` (every `bar.*`, and `barrier.*.aligned`):
/// a warp executes an aligned barrier as one collective, so its arriving lanes must all be at
/// that one instruction.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BarrierAlignment {
    Aligned,
    Unaligned,
}

/// Memory space
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum MemSpace {
    Global,
    Shared,
    Local,
    Param,
    Const,
}

/// Which side of the generic-to-tensor-map-proxy ordering a `fence.proxy.tensormap::generic`
/// is.
#[derive(Debug, Clone, PartialEq)]
pub enum TensormapFence {
    /// `.release.scope`: after the tensor map's generic-proxy writes.
    Release,
    /// `.acquire.scope [addr], 128`: before a tensor-map-proxy use of the map at `addr`.
    Acquire {
        addr_base: Operand,
        addr_offset: i64,
    },
}

/// Shuffle mode for warp shuffle operations
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ShflMode {
    Up,
    Down,
    Bfly,
    Idx,
}

/// Integer multiply mode (hi/lo for wide multiply)
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MulMode {
    Lo,
    Hi,
    Wide,
}

/// Float result clamp (PTX `.sat`/`.relu`), exact over the reals: `min(max(x,
/// 0), 1)` and `max(x, 0)` (NaN handling is out of model). Integer
/// `.sat`/`.relu` stay rejected.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Clamp {
    /// `.sat`: clamp the result to [0.0, 1.0].
    Sat,
    /// `.relu`: clamp the result to [0.0, +inf).
    Relu,
}

/// A lowered instruction - fully resolved with no strings
#[derive(Debug, Clone)]
pub enum LoweredInstr {
    // =========================================================================
    // Data Movement
    // =========================================================================
    /// Load from parameter space: dst = params[param_id]
    LoadParam { dst: RegId, param_id: ParamId },

    /// Load from memory: dst = mem[base + offset]
    Load {
        dst: RegId,
        space: MemSpace,
        base: Operand,
        offset: i64,
        ty: ScalarType,
    },

    /// Vector load: dst[0..n] = mem[base + offset]
    LoadVec {
        dst: Vec<RegId>,
        space: MemSpace,
        base: Operand,
        offset: i64,
        ty: ScalarType,
    },

    /// Store to memory: mem[base + offset] = src
    Store {
        space: MemSpace,
        base: Operand,
        offset: i64,
        src: Operand,
        ty: ScalarType,
    },

    /// Vector store. Unlike `LoadVec`'s destinations, each source may be any
    /// operand, e.g. an immediate in the "zero-init one lane" idiom `{%f1,
    /// %f2, 0f00000000, %f4}`.
    StoreVec {
        space: MemSpace,
        base: Operand,
        offset: i64,
        src: Vec<Operand>,
        ty: ScalarType,
    },

    /// Async copy
    CpAsync {
        dst_base: Operand,
        dst_offset: i64,
        src_base: Operand,
        src_offset: i64,
        /// Always 4, 8, or 16 per the ISA.
        cp_size: u32,
        src_size: CpAsyncSrcSize,
    },

    /// Move/copy: dst = src
    Mov {
        dst: RegId,
        src: Operand,
        ty: ScalarType,
    },

    /// Convert address to generic: dst = cvta.to.space(src)
    Cvta { dst: RegId, src: Operand },

    /// `mapa.shared::cluster d, a, rank`: `a`'s shared variable in CTA `rank`
    /// of the cluster. Clusters are assumed to hold one CTA, so the only valid
    /// rank is 0 and the executing CTA's address is also its cluster address.
    Mapa {
        dst: RegId,
        src: Operand,
        rank: Operand,
    },

    /// `prmt.b32 d, a, b, selector` byte permutation.
    Prmt {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        selector: Operand,
    },

    /// `lop3.b32 d, a, b, c, lut` three-input logical operation.
    Lop3 {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        src_c: Operand,
        lut: Operand,
    },

    // =========================================================================
    // Arithmetic
    // =========================================================================
    /// Binary operation: dst = src_a op src_b
    BinOp {
        op: BinOp,
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        ty: ScalarType,
        /// Float value clamp (`.sat`) applied to the result; float forms only.
        clamp: Option<Clamp>,
    },

    /// Unary operation: dst = op(src)
    UnaryOp {
        op: UnaryOp,
        dst: RegId,
        src: Operand,
        ty: ScalarType,
    },

    /// `copysign.type d, a, b` (PTX ISA Block 32): `dst = |magnitude_src|`
    /// with `sign_src`'s sign - `.f32`/`.f64` only, no packed lane form.
    Copysign {
        dst: RegId,
        sign_src: Operand,
        magnitude_src: Operand,
        ty: ScalarType,
    },

    /// Fused multiply-add: dst = src_a * src_b + src_c
    Fma {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        src_c: Operand,
        /// Type of `src_c` and `dst`.
        ty: ScalarType,
        /// Type of the multiplicands `src_a`/`src_b`: `ty`, except for
        /// mixed precision `fma.rn.f32.{f16,bf16}` (f16/bf16 multiplicands,
        /// f32 accumulator).
        mul_ty: ScalarType,
        /// Float value clamp (`.sat`/`.relu`) applied to the result.
        clamp: Option<Clamp>,
    },

    /// Multiply-add (integer): dst = src_a * src_b + src_c
    Mad {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        src_c: Operand,
        ty: ScalarType,
        mode: MulMode,
    },

    /// Wide multiply: dst (64-bit) = src_a (32-bit) * src_b (32-bit)
    MulWide {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        src_ty: ScalarType,
    },

    /// High half of the product: dst = (src_a * src_b) >> bits(ty)
    /// (nvcc's divide-by-constant idiom)
    MulHi {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        ty: ScalarType,
    },

    /// Bit field insert: insert bits from src_a into src_b at position start with length len
    Bfi {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        start: Operand,
        len: Operand,
        ty: ScalarType,
    },

    /// Bit field extract: dst = zero/sign-extended bits [start, start+len) of src_a
    Bfe {
        dst: RegId,
        src_a: Operand,
        start: Operand,
        len: Operand,
        ty: ScalarType,
    },

    // =========================================================================
    // Comparison & Selection
    // =========================================================================
    /// Set predicate: dst = (src_a cmp src_b)
    Setp {
        cmp: CmpOp,
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        ty: ScalarType,
    },

    /// Select: dst = pred ? src_a : src_b
    Selp {
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        pred: Operand,
        ty: ScalarType,
    },

    // =========================================================================
    // Type Conversion
    // =========================================================================
    /// Convert type: dst = convert(src)
    Cvt {
        dst: RegId,
        src: Operand,
        dst_ty: ScalarType,
        src_ty: ScalarType,
        /// Float value clamp (`.sat`/`.relu`) applied to the converted
        /// result; float->float conversions only.
        clamp: Option<Clamp>,
    },

    /// `cvt.rn{.relu}.f16x2.e4m3x2` (PTX ISA 9.7.9.22), the only fp8
    /// direction in the corpus. A `Value::Pair` source is already real
    /// (identity); a `Value::Scalar` is a bit pattern, decoded as e4m3.
    CvtE4m3x2ToF16x2 {
        dst: RegId,
        src: Operand,
        relu: bool,
    },

    /// Two-source packed-half convert `cvt.rnd.f16x2.f32 dst, src_hi,
    /// src_lo`: writes a `Value::Pair` directly, never bit-encoded, since the
    /// sources are exact reals.
    CvtPackHalves {
        dst: RegId,
        src_hi: Operand,
        src_lo: Operand,
        /// Per-lane destination type (`F16` for an `f16x2` dst, `Bf16` for
        /// `bf16x2`), precomputed at lowering time.
        dst_half_ty: ScalarType,
        src_ty: ScalarType,
    },

    /// Vector-destination unpack `mov.bN {lo, hi}, src`, decided by `src`'s
    /// runtime kind: a `Value::Pair` distributes its real halves directly; a
    /// `Value::Scalar` uses bitwise `And`/`Shr`.
    UnpackHalves {
        /// `None` when the PTX discards that half with the `_` sink.
        lo: Option<RegId>,
        hi: Option<RegId>,
        src: Operand,
        /// The `mov`'s full-width type (e.g. `B32` for a 2x16 unpack).
        ty: ScalarType,
    },

    /// `mov.b32`/`mov.b64 dst, {lo, hi}`: a `Value::Pair`, since bit ops on real
    /// halves build nonsense (concrete integer halves recombine on demand); two f16x2
    /// halves of a `.b64` are its four 16-bit lanes (see `pack_b64_lanes`).
    PackHalves {
        dst: RegId,
        lo: Operand,
        hi: Operand,
    },

    /// `mov.b128 dst, {e0, e1, e2, e3}`: a `Value::Quad`, as `PackHalves`
    /// writes a pair. A quad is four lanes whose width follows the register
    /// class (8-bit lanes only ever in `Bits32`).
    PackQuad {
        dst: RegId,
        /// Lane 0 is the least significant / lowest-addressed, matching
        /// `Value::Quad`'s tuple order.
        elems: [Operand; 4],
    },

    /// `mov.b128 {e0, e1, e2, e3}, src`, the reverse of `PackQuad` (any
    /// element may be `_`). Only a `Value::Quad` source is modeled; a 128-bit
    /// scalar fails loudly at eval time.
    UnpackQuad {
        /// `None` where the PTX discards that lane with the `_` sink.
        elems: [Option<RegId>; 4],
        src: Operand,
    },

    /// Funnel shift `shf.{l,r}.{clamp,wrap}.b32` of `hi:lo`, keeping the high
    /// (`.l`) or low (`.r`) 32 bits (PTX ISA 9.7.9.7). A `Value::Pair` with
    /// `n == 16` is evaluated as the exact f16 lane shuffle.
    Shf {
        dst: RegId,
        /// Low word: bits 31:0 of the shifted 64-bit value.
        lo: Operand,
        /// High word: bits 63:32 of the shifted 64-bit value.
        hi: Operand,
        shift: Operand,
        dir: ShiftDir,
        mode: ClampWrapMode,
    },

    // =========================================================================
    // Control Flow
    // =========================================================================
    /// Unconditional branch
    Bra { target: InstrId },

    /// Return
    Ret,

    /// Exit thread
    Exit,

    // =========================================================================
    // Synchronization
    // =========================================================================
    /// Named barrier, blocking arrival: `bar.sync a{, b}` - arrive at
    /// barrier `a` and wait until `thread_count` threads have arrived
    /// (the whole CTA when the count operand is absent).
    BarSync {
        barrier_id: Operand,
        thread_count: Option<Operand>,
        alignment: BarrierAlignment,
    },

    /// Named barrier, non-blocking arrival: `bar.arrive a, b` - arrive at
    /// barrier `a` and keep running. The ISA makes the count mandatory
    /// here, so it is not optional as it is for `BarSync`.
    BarArrive {
        barrier_id: Operand,
        thread_count: Operand,
        alignment: BarrierAlignment,
    },

    /// Warp barrier: bar.warp.sync mask
    BarWarpSync { mask: Operand },

    /// `setmaxnreg.{inc,dec}.sync.aligned.u32 count`: a full-warp rendezvous.
    /// Its effect on the warp's register count is not modeled.
    Setmaxnreg,

    /// Memory fence
    Membar,

    /// `fence{.sem}.scope` or `fence.proxy.alias{.sem}.scope`: a pure
    /// ordering fence with no data effect to model. `fence.proxy.async` is
    /// the separate `FenceProxyAsync`, which has one.
    Fence,

    /// `fence.proxy.async{.space}`: a generic/async proxy fence by this thread
    /// within `restrict` (`None` = all; both `.shared::` spaces map to
    /// `Shared`). No data effect.
    FenceProxyAsync { restrict: Option<MemSpace> },

    /// Seal all of this thread's uncommitted `CpAsync` copies into a new
    /// async-group at the back of its completion queue.
    CpAsyncCommitGroup,

    /// Block until at most `n` of this thread's async-groups remain
    /// pending.
    CpAsyncWaitGroup { n: u32 },

    /// `cp.async.mbarrier.arrive{.noinc}`: once this thread's prior `CpAsync`
    /// copies complete, arrive on the mbarrier at `addr_base + addr_offset`;
    /// without `.noinc` the pending count is pre-incremented.
    CpAsyncMbarrierArrive {
        addr_base: Operand,
        addr_offset: i64,
        noinc: bool,
    },

    // =========================================================================
    // Warp-Level Operations
    // =========================================================================
    /// Warp shuffle with sync
    ShflSync {
        mode: ShflMode,
        dst: RegId,
        dst_pred: Option<RegId>,
        src: Operand,
        offset_or_lane: Operand,
        clamp: Operand,
        membermask: Operand,
    },

    /// `elect.sync d|p, membermask`: the lowest live lane gets `dst = lane
    /// id` and `dst_pred = true`; other live mask lanes get `false` and an
    /// `Undefined` `dst` (the ISA defines `d` only for the leader).
    ElectSync {
        dst: Option<RegId>,
        dst_pred: RegId,
        membermask: Operand,
    },

    // =========================================================================
    // Tensor Core
    // =========================================================================
    /// Cooperative matrix load from shared memory (ldmatrix.sync)
    Ldmatrix {
        dst: Vec<RegId>,
        addr: Operand,
        /// Constant byte offset folded from a `[reg+imm]` address operand
        /// (e.g. `[%r202+16384]`); zero for a bare-register address.
        addr_offset: i64,
        num: u32, // x1, x2, or x4
        trans: bool,
    },

    /// `movmatrix.sync.aligned.m8n8.trans.b16` (PTX ISA 9.7.14.5.16): the
    /// warp's 8x8 b16 matrix, in `ldmatrix`'s fragment layout, transposed
    /// across lanes (`eval::warp::exec_movmatrix`).
    Movmatrix { dst: RegId, src: Operand },

    /// `stmatrix...m8n8.shared.b16` (PTX ISA 9.7.14.5.17): `ldmatrix`'s
    /// store-direction mirror, with the same row addressing
    /// (`eval::warp::exec_stmatrix`) and `shared::cta`-only scope.
    Stmatrix {
        addr: Operand,
        addr_offset: i64,
        src: Vec<Operand>,
        num: u32,
        trans: bool,
    },

    /// `mma.sync` matrix multiply-accumulate. `src_c` may be any operand:
    /// nvcc's first-tile idiom passes immediate-zero literals (`{0f00000000,
    /// ...}`) as the accumulator.
    Mma {
        shape: crate::ir::mma::MmaShape,
        dst: Vec<RegId>,
        src_a: Vec<RegId>,
        src_b: Vec<RegId>,
        src_c: Vec<Operand>,
        a_layout: crate::ir::mma::MmaLayout,
        b_layout: crate::ir::mma::MmaLayout,
        a_type: ScalarType,
        b_type: ScalarType,
        d_type: ScalarType,
    },

    /// WMMA cooperative matrix load (wmma.load.{a,b,c}.sync)
    WmmaLoad {
        operand: crate::ir::mma::MmaOperand,
        shape: crate::ir::mma::MmaShape,
        layout: crate::ir::mma::MmaLayout,
        dst: Vec<RegId>,
        addr: Operand,
        /// Constant byte offset folded from a `[reg+imm]` address operand;
        /// zero for a bare-register address.
        addr_offset: i64,
        stride: Operand,
        elem_type: ScalarType,
        space: MemSpace,
    },

    /// WMMA cooperative matrix store (wmma.store.d.sync)
    WmmaStore {
        shape: crate::ir::mma::MmaShape,
        layout: crate::ir::mma::MmaLayout,
        src: Vec<RegId>,
        addr: Operand,
        /// Constant byte offset folded from a `[reg+imm]` address operand;
        /// zero for a bare-register address.
        addr_offset: i64,
        stride: Operand,
        elem_type: ScalarType,
        space: MemSpace,
    },

    /// WMMA matrix multiply-accumulate (wmma.mma.sync)
    WmmaMma {
        shape: crate::ir::mma::MmaShape,
        dst: Vec<RegId>,
        src_a: Vec<RegId>,
        src_b: Vec<RegId>,
        src_c: Vec<RegId>,
    },

    // =========================================================================
    // TensorCore 5th Generation - Tensor Memory Allocation (PTX ISA 9.7.17.7)
    // =========================================================================
    /// `tcgen05.alloc.cta_group::1...[dst], nCols`: allocate `num_cols`
    /// Tensor Memory columns, writing the resulting address into shared
    /// memory at `dst_base + dst_offset`.
    Tcgen05Alloc {
        dst_base: Operand,
        dst_offset: i64,
        num_cols: Operand,
    },

    /// `tcgen05.dealloc.cta_group::1...taddr, nCols`: deallocate the Tensor
    /// Memory range starting at `taddr`.
    Tcgen05Dealloc { taddr: Operand, num_cols: Operand },

    /// `tcgen05.relinquish_alloc_permit.cta_group::1...`: this CTA gives up
    /// the right to allocate any further Tensor Memory.
    Tcgen05RelinquishAllocPermit,

    // =========================================================================
    // TensorCore 5th Generation - Tensor Memory Register Load/Store (PTX ISA 9.7.17.8)
    // =========================================================================
    /// `tcgen05.ld.sync.aligned.shape.num.b32`: collective load into
    /// `dst.len()` registers per thread from the Tensor Memory rectangle at
    /// `taddr_base + taddr_offset` (`Tcgen05LdStShape::cell`).
    Tcgen05Ld {
        shape: Tcgen05LdStShape,
        dst: Vec<RegId>,
        taddr_base: Operand,
        taddr_offset: i64,
    },

    /// `tcgen05.st.sync.aligned.shape.num.b32 [taddr], r`: collective async
    /// store of `src.len()` registers per thread, to the same rectangle
    /// `Tcgen05Ld` reads.
    Tcgen05St {
        shape: Tcgen05LdStShape,
        taddr_base: Operand,
        taddr_offset: i64,
        src: Vec<Operand>,
    },

    /// `tcgen05.wait::{ld,st}`: completes this warp's prior `.ld`/`.st`; the
    /// data effect already happened, as execution is sequential.
    Tcgen05Wait { is_st: bool },

    // =========================================================================
    // TensorCore 5th Generation - Matrix Multiply and Accumulate (PTX ISA 9.7.17.10)
    // =========================================================================
    /// Single-thread `tcgen05.mma` (dense `.kind::{f16,f8f6f4,mxf8f6f4}`): `D =
    /// A*B (+D)` into Tensor Memory, skipping `disable_output_lane` lanes
    /// (9.7.17.10.9.1); `collector` is `Some` iff `.ws`, `scales` iff
    /// `.kind::mxf8f6f4`.
    Tcgen05Mma {
        kind: Tcgen05MmaKind,
        collector: Option<Tcgen05Collector>,
        scales: Option<Tcgen05MmaScales>,
        d_tmem_base: Operand,
        d_tmem_offset: i64,
        a: Tcgen05MmaA,
        b_desc: Operand,
        idesc: Operand,
        disable_output_lane: Vec<Operand>,
        enable_input_d: Operand,
    },

    // =========================================================================
    // TensorCore 5th Generation - Fence & Commit (PTX ISA 9.7.17.11)
    // =========================================================================
    /// `tcgen05.fence::before_thread_sync` / `::after_thread_sync`: pure
    /// ordering fence, no data effect - a no-op under Volta's sequential,
    /// non-reordering execution model. The event graph keeps its direction.
    Tcgen05Fence { direction: Tcgen05FenceDirection },

    /// `tcgen05.commit...mbarrier::arrive::one`: once all of this thread's
    /// async `tcgen05` ops complete, arrive (count 1) on the mbarrier at
    /// `addr_base + addr_offset`.
    Tcgen05Commit {
        addr_base: Operand,
        addr_offset: i64,
    },

    // =========================================================================
    // Tensor-map objects & TMA tensor copy (PTX ISA 5.5.8, 9.7.9.27, 9.7.9.26.5.2, 9.7.14.17)
    // =========================================================================
    /// `tensormap.replace.mode.field{.ss}.b1024.type`: write one named field
    /// of the tensor-map at `addr_base + addr_offset`, in an explicit
    /// `.global`/`.shared::cta` `space` (`lower_tensormap_replace`).
    TensormapReplace {
        space: MemSpace,
        addr_base: Operand,
        addr_offset: i64,
        field: TensormapFieldWrite,
    },

    /// `tensormap.cp_fenceproxy`: copy the tensor-map at `src`
    /// (`.shared::cta`) to `dst` (`.global`) for later `cp.async.bulk.tensor`
    /// use, then a `fence.proxy.tensormap::generic.release`.
    TensormapCpFenceproxy {
        dst_base: Operand,
        dst_offset: i64,
        src_base: Operand,
        src_offset: i64,
    },

    /// `fence.proxy.tensormap::generic{.release.scope | .acquire.scope
    /// [addr], 128}`: a proxy-ordering fence with no data effect.
    FenceProxyTensormap { fence: TensormapFence },

    /// `cp.async.bulk.tensor...{.tile,.im2col}.mbarrier::complete_tx::bytes`: TMA
    /// copy, global to the executing CTA's shared memory (no remote/multicast).
    CpAsyncBulkTensorLoad {
        dst_base: Operand,
        dst_offset: i64,
        tensormap_base: Operand,
        tensormap_offset: i64,
        coords: Vec<Operand>,
        mode: TensorLoadMode,
        mbar_base: Operand,
        mbar_offset: i64,
    },

    /// `cp.async.bulk.tensor...global.shared::cta.tile.bulk_group`: TMA
    /// store from the executing CTA's shared memory to global, tracked by the
    /// issuer's bulk async-groups.
    CpAsyncBulkTensorStore {
        tensormap_base: Operand,
        tensormap_offset: i64,
        coords: Vec<Operand>,
        src_base: Operand,
        src_offset: i64,
    },

    /// `cp.async.bulk.commit_group`: seal the thread's TMA stores since the
    /// last commit into a bulk async-group.
    CpAsyncBulkCommitGroup,

    /// `cp.async.bulk.wait_group{.read} n`: complete the thread's bulk
    /// groups but the newest `n` (with `.read`, only their source reads).
    CpAsyncBulkWaitGroup { n: u32, scope: BulkWaitScope },

    /// `cp.async.bulk...mbarrier::complete_tx::bytes`: non-tensor copy of
    /// `size` contiguous bytes, global to shared, completing `size` tx-bytes
    /// on `mbar` (`lower::tma::lower_cp_async_bulk`).
    CpAsyncBulkLoad {
        dst_base: Operand,
        dst_offset: i64,
        src_base: Operand,
        src_offset: i64,
        size: Operand,
        mbar_base: Operand,
        mbar_offset: i64,
    },

    // =========================================================================
    // Cluster launch control (PTX ISA 9.7.19)
    // =========================================================================
    /// `clusterlaunchcontrol.try_cancel.async.shared::cta.mbarrier::complete_tx::bytes.b128
    /// [addr], [mbar]`: request to cancel a not-yet-launched cluster, writing
    /// the 16-byte response to `addr` and completing 16 tx-bytes on `mbar`.
    ClcTryCancel {
        addr_base: Operand,
        addr_offset: i64,
        mbar_base: Operand,
        mbar_offset: i64,
    },

    /// `clusterlaunchcontrol.query_cancel.is_canceled.pred.b128 dst, response`.
    ClcQueryIsCanceled { dst: RegId, response: RegId },

    /// `clusterlaunchcontrol.query_cancel.get_first_ctaid{::dim}.{v4.}b32.b128`.
    /// No destination: evaluating it is always an error (see
    /// `exec_clc_query_get_first_ctaid`).
    ClcQueryGetFirstCtaid { response: RegId },

    // =========================================================================
    // mbarrier: phased arrive/wait barriers (PTX ISA 9.7.13.15)
    // =========================================================================
    /// `mbarrier.init{.shared{::cta}}.b64 [addr], count`: create a fresh
    /// `mbarrier` object at `addr_base + addr_offset` needing `count`
    /// arrivals to complete its first phase.
    MbarrierInit {
        addr_base: Operand,
        addr_offset: i64,
        count: Operand,
    },

    /// `mbarrier.arrive{.expect_tx}`: one arrival (or `count`), optionally
    /// bumping the expected tx count. `state` gets the opaque phase token;
    /// `None` for `_` (the corpus only uses `.parity` waits).
    MbarrierArrive {
        state: Option<RegId>,
        addr_base: Operand,
        addr_offset: i64,
        count: Option<Operand>,
        expect_tx: Option<Operand>,
    },

    /// `mbarrier.expect_tx{.sem.scope}{.space}.b64 [addr], txCount`:
    /// announce `txCount` more async-transaction bytes for the forming
    /// phase, without arriving.
    MbarrierExpectTx {
        addr_base: Operand,
        addr_offset: i64,
        tx_count: Operand,
    },

    /// `mbarrier.complete_tx{.sem.scope}{.space}.b64 [addr], txCount`:
    /// signal that `txCount` bytes of a previously-`expect_tx`'d async
    /// transaction have completed.
    MbarrierCompleteTx {
        addr_base: Operand,
        addr_offset: i64,
        tx_count: Operand,
    },

    /// The retry loop `L: mbarrier.{test,try}_wait.parity p, ..; @!p bra L;`
    /// as one instruction: block until `phase_parity`'s phase completes, set
    /// `waitComplete`, fall through past the dropped `bra` (no other form).
    MbarrierWaitParity {
        wait_complete: RegId,
        addr_base: Operand,
        addr_offset: i64,
        phase_parity: Operand,
    },

    // =========================================================================
    // Special
    // =========================================================================
    /// Abort execution. Reaching this during evaluation is an analysis error.
    Trap,

    /// No operation (placeholder)
    Nop,
}

/// Generates `KIND_COUNT`, `KIND_NAMES`, `kind_index` and `kind_name` from
/// one variant list; `kind_list_is_exhaustive` makes a missing or misspelled
/// `LoweredInstr` variant a compile error.
macro_rules! define_instr_kinds {
    ($($variant:ident),+ $(,)?) => {
        /// Number of distinct `LoweredInstr` kinds.
        pub const KIND_COUNT: usize = KIND_NAMES.len();

        /// Short, static name of each instruction kind, indexed by
        /// `LoweredInstr::kind_index`.
        pub const KIND_NAMES: [&str; [$(stringify!($variant)),+].len()] =
            [$(stringify!($variant)),+];

        impl LoweredInstr {
            /// Dense index of this instruction's kind, for `KIND_NAMES`
            /// and fixed-size per-kind counters.
            pub fn kind_index(&self) -> usize {
                let mut i = 0usize;
                $(
                    if matches!(self, LoweredInstr::$variant { .. }) {
                        return i;
                    }
                    i += 1;
                )+
                let _ = i;
                unreachable!("variant missing from define_instr_kinds!")
            }

            /// Short, static instruction-kind name for profiling/stats.
            pub fn kind_name(&self) -> &'static str {
                KIND_NAMES[self.kind_index()]
            }

            #[allow(dead_code)]
            fn kind_list_is_exhaustive(&self) {
                match self {
                    $(LoweredInstr::$variant { .. } => {}),+
                }
            }
        }
    };
}

define_instr_kinds!(
    LoadParam,
    Load,
    LoadVec,
    Store,
    StoreVec,
    CpAsync,
    Mov,
    Cvta,
    Mapa,
    Prmt,
    Lop3,
    BinOp,
    UnaryOp,
    Copysign,
    Fma,
    Mad,
    MulWide,
    MulHi,
    Bfi,
    Bfe,
    Setp,
    Selp,
    Cvt,
    CvtE4m3x2ToF16x2,
    CvtPackHalves,
    UnpackHalves,
    PackHalves,
    PackQuad,
    UnpackQuad,
    Shf,
    Bra,
    Ret,
    Exit,
    BarSync,
    BarArrive,
    BarWarpSync,
    Setmaxnreg,
    Membar,
    Fence,
    FenceProxyAsync,
    CpAsyncCommitGroup,
    CpAsyncWaitGroup,
    CpAsyncMbarrierArrive,
    ShflSync,
    ElectSync,
    Ldmatrix,
    Movmatrix,
    Mma,
    WmmaLoad,
    WmmaStore,
    WmmaMma,
    Tcgen05Alloc,
    Tcgen05Dealloc,
    Tcgen05RelinquishAllocPermit,
    Tcgen05Ld,
    Tcgen05St,
    Tcgen05Wait,
    Tcgen05Mma,
    Tcgen05Fence,
    Tcgen05Commit,
    Stmatrix,
    TensormapReplace,
    TensormapCpFenceproxy,
    FenceProxyTensormap,
    CpAsyncBulkTensorLoad,
    CpAsyncBulkTensorStore,
    CpAsyncBulkCommitGroup,
    CpAsyncBulkWaitGroup,
    CpAsyncBulkLoad,
    ClcTryCancel,
    ClcQueryIsCanceled,
    ClcQueryGetFirstCtaid,
    MbarrierInit,
    MbarrierArrive,
    MbarrierExpectTx,
    MbarrierCompleteTx,
    MbarrierWaitParity,
    Trap,
    Nop,
);

/// A fully lowered and resolved PTX program
#[derive(Debug)]
pub struct LoweredProgram {
    /// Linear sequence of instructions
    pub instructions: IdVec<InstrId, LoweredInstr>,

    /// Predicate guards for each instruction (None if unconditional)
    pub predicates: IdVec<InstrId, Option<Predicate>>,

    /// Symbol table (preserved for error messages and debugging)
    pub symbols: SymbolTable,

    /// Source map for error reporting (maps lowered elements to source spans)
    pub source_map: SourceMap,

    /// Entry point PC (usually 0)
    pub entry_pc: InstrId,
}

impl LoweredProgram {
    /// Get instruction at PC
    pub fn instruction(&self, pc: InstrId) -> Option<&LoweredInstr> {
        self.instructions.get(pc)
    }

    /// Get predicate for instruction at PC
    pub fn predicate(&self, pc: InstrId) -> Option<&Predicate> {
        self.predicates.get(pc).and_then(|p| p.as_ref())
    }

    /// Get register counts per class
    pub fn register_counts(&self) -> RegCounts {
        self.symbols.register_counts()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_binop_names() {
        assert_eq!(BinOp::Add.as_str(), "add");
        assert_eq!(BinOp::Mul.as_str(), "mul");
        assert_eq!(BinOp::Shl.as_str(), "shl");
    }
}
