//! Lowered PTX instructions: the output of the lowering pass, with resolved
//! register indices and branch PCs, unneeded modifiers stripped, and unified
//! instruction formats.

use std::fmt;

use id_collections::{IdVec, id_type};
use volta_common::Span;
use volta_frontend::ast::{ClampWrapMode, ScalarType, ShiftDir};

use crate::source_map::SourceMap;
use crate::symbols::{ParamId, RegId, SpecialRegKind, SymbolTable};
use crate::tensor_map::TensormapFieldWrite;
use crate::types::RegCounts;

/// Instruction index (program counter)
#[id_type]
pub struct InstrId(pub u32);

impl fmt::Display for InstrId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "pc:{}", self.0)
    }
}

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
    /// Check if this is a register (general or special)
    pub fn is_register(&self) -> bool {
        matches!(self, Self::Reg(_) | Self::SpecialReg(_))
    }

    /// Check if this is an immediate
    pub fn is_immediate(&self) -> bool {
        matches!(self, Self::ImmI64(_) | Self::ImmU64(_) | Self::ImmF64(_))
    }

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
    Sin,
    Cos,
    /// Natural exponential e^x (from `call __symexpf`, the paper's hook for
    /// symbolic exp; there is no such PTX instruction)
    Exp,
    /// Hyperbolic tangent (evaluated as `(e^2x - 1) / (e^2x + 1)`, staying
    /// in the interpreted exp fragment rather than becoming an opaque atom
    /// - the same approach as `Ex2`).
    Tanh,
}

impl UnaryOp {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Neg => "neg",
            Self::Abs => "abs",
            Self::Not => "not",
            Self::Rcp => "rcp",
            Self::Sqrt => "sqrt",
            Self::Rsqrt => "rsqrt",
            Self::Ex2 => "ex2",
            Self::Lg2 => "lg2",
            Self::Sin => "sin",
            Self::Cos => "cos",
            Self::Exp => "exp",
            Self::Tanh => "tanh",
        }
    }
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

/// `tcgen05.mma`'s `.kind` qualifier: selects the
/// operand element types `idesc`'s type fields are interpreted against and
/// the fixed `K` of one dense `.cta_group::1` operation (Table 42).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tcgen05MmaKind {
    /// `.kind::f16`: f16/bf16 operands, `K = 16`.
    F16,
    /// `.kind::f8f6f4`: 8/6/4-bit float operands, `K = 32`.
    F8f6f4,
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
}

impl Tcgen05LdStShape {
    /// Registers each thread supplies/receives per `.x1` unit.
    pub fn regs_per_unit(self) -> u32 {
        match self {
            Self::S32x32b => 1,
            Self::S16x256b => 4,
        }
    }

    /// Tensor Memory columns one `.x1` unit spans.
    pub fn cols_per_unit(self) -> u32 {
        match self {
            Self::S32x32b => 1,
            Self::S16x256b => 8,
        }
    }

    /// Tensor Memory lanes the access spans, starting at the `taddr` lane.
    pub fn num_lanes(self) -> u32 {
        match self {
            Self::S32x32b => 32,
            Self::S16x256b => 16,
        }
    }

    /// Tensor Memory columns an access of `regs` registers per thread
    /// spans: one `.x1` unit per `regs_per_unit` registers, each unit
    /// `cols_per_unit` columns wide.
    pub fn num_cols(self, regs: usize) -> u32 {
        (regs as u32 / self.regs_per_unit()) * self.cols_per_unit()
    }

    /// `(lane, column)` offsets from taddr of register `reg` of thread `t =
    /// lane_in_warp`: identity for `.32x32b`; for `.16x256b`, lane `t / 4 + 8
    /// * (reg / 2)` and column `2 * (t % 4) + reg % 2`.
    pub fn cell(self, lane_in_warp: u32, reg: u32) -> (u32, u32) {
        match self {
            Self::S32x32b => (lane_in_warp, reg),
            Self::S16x256b => {
                let (unit, within) = (reg / 4, reg % 4);
                let lane = lane_in_warp / 4 + 8 * (within / 2);
                let col = unit * 8 + 2 * (lane_in_warp % 4) + within % 2;
                (lane, col)
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
    Cvta {
        dst: RegId,
        src: Operand,
        space: MemSpace,
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

    /// Set with value: dst = (src_a cmp src_b) ? 1 : 0
    Set {
        cmp: CmpOp,
        dst: RegId,
        src_a: Operand,
        src_b: Operand,
        src_ty: ScalarType,
        dst_ty: ScalarType,
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

    /// `mov.b32`/`mov.b64 dst, {lo, hi}`: always a `Value::Pair`, since bit
    /// ops on real halves build nonsense. Concrete integer halves recombine
    /// on demand; symbolic ones used as a scalar fail.
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
    },

    /// Named barrier, non-blocking arrival: `bar.arrive a, b` - arrive at
    /// barrier `a` and keep running. The ISA makes the count mandatory
    /// here, so it is not optional as it is for `BarSync`.
    BarArrive {
        barrier_id: Operand,
        thread_count: Operand,
    },

    /// Warp barrier: bar.warp.sync mask
    BarWarpSync { mask: Operand },

    /// Memory fence
    Membar { scope: MembarScope },

    /// `fence{.sem}.scope` or `fence.proxy.alias{.sem}.scope`: a pure
    /// ordering fence with no data effect to model. `fence.proxy.async` is
    /// the separate `FenceProxyAsync`, which has one.
    Fence,

    /// `fence.proxy.async{.space}`: clears this thread's unfenced async-proxy
    /// write marks within `restrict` (`None` = all; both `.shared::` spaces
    /// map to `Shared`), via `RaceTracker::clear_async_proxy_fence`.
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
    /// Warp shuffle
    Shfl {
        mode: ShflMode,
        dst: RegId,
        dst_pred: Option<RegId>,
        src: Operand,
        offset_or_lane: Operand,
        clamp: Operand,
    },

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

    /// `redux.sync.op.type d, a, membermask` (PTX ISA Block 143): fold every
    /// live mask lane's `a` with `op` and broadcast the result; `Inc`/`Dec`
    /// are not valid redux ops and are rejected at lowering.
    ReduxSync {
        op: BinOp,
        ty: ScalarType,
        dst: RegId,
        src: Operand,
        membermask: Operand,
    },

    /// nvcc's warp-max sign-trick idiom (`match_warp_max_sign_trick`),
    /// lowered as a real `max` of the underlying value, exact for any sign,
    /// so the fixup is elided; `dst` gets `Value::Pair(result, result)`.
    ReduxSyncBroadcastMax {
        dst: RegId,
        src: Operand,
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

    /// `mma.sync` matrix multiply-accumulate. `src_c` may be any operand:
    /// nvcc's first-tile idiom passes immediate-zero literals (`{0f00000000,
    /// ...}`) as the accumulator.
    Mma {
        shape: crate::tensor_core::MmaShape,
        dst: Vec<RegId>,
        src_a: Vec<RegId>,
        src_b: Vec<RegId>,
        src_c: Vec<Operand>,
        a_layout: crate::tensor_core::MmaLayout,
        b_layout: crate::tensor_core::MmaLayout,
        a_type: ScalarType,
        b_type: ScalarType,
        d_type: ScalarType,
        c_type: ScalarType,
    },

    /// WMMA cooperative matrix load (wmma.load.{a,b,c}.sync)
    WmmaLoad {
        operand: crate::tensor_core::MmaOperand,
        shape: crate::tensor_core::MmaShape,
        layout: crate::tensor_core::MmaLayout,
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
        shape: crate::tensor_core::MmaShape,
        layout: crate::tensor_core::MmaLayout,
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
        shape: crate::tensor_core::MmaShape,
        dst: Vec<RegId>,
        src_a: Vec<RegId>,
        src_b: Vec<RegId>,
        src_c: Vec<RegId>,
        a_layout: crate::tensor_core::MmaLayout,
        b_layout: crate::tensor_core::MmaLayout,
        d_type: ScalarType,
        c_type: ScalarType,
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
        num_cols: u32,
    },

    /// `tcgen05.dealloc.cta_group::1...taddr, nCols`: deallocate the Tensor
    /// Memory range starting at `taddr`.
    Tcgen05Dealloc { taddr: Operand, num_cols: u32 },

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

    /// `tcgen05.wait::{ld,st}`: release this warp quadrant's pending
    /// `.ld`/`.st` async-hazard footprints (`RaceTracker::tcgen05_wait`); the
    /// data effect already happened, as execution is sequential.
    Tcgen05Wait { is_st: bool },

    // =========================================================================
    // TensorCore 5th Generation - Matrix Multiply and Accumulate (PTX ISA 9.7.17.10)
    // =========================================================================
    /// Single-thread `tcgen05.mma` (dense `.kind::{f16,f8f6f4}`): `D = A*B
    /// (+D)` into Tensor Memory, skipping `disable_output_lane` lanes
    /// (9.7.17.10.9.1); `collector` is `Some` iff `.ws`.
    Tcgen05Mma {
        kind: Tcgen05MmaKind,
        collector: Option<Tcgen05Collector>,
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
    /// non-reordering execution model.
    Tcgen05Fence,

    /// `tcgen05.commit...mbarrier::arrive::one`: once all of this thread's
    /// async `tcgen05` ops complete, arrive (count 1) on the mbarrier at
    /// `addr_base + addr_offset`.
    Tcgen05Commit {
        addr_base: Operand,
        addr_offset: i64,
    },

    // =========================================================================
    // Asynchronous Warpgroup-Level Matrix Multiply-Accumulate (PTX ISA 9.7.17.5-7)
    // =========================================================================
    /// Shared-memory-`A` `wgmma.mma_async` (PTX ISA 9.7.17.5.2), `.f16.f16`
    /// or FP8 into `.f32`: warpgroup-wide `D = A*B (+D)`, each thread owning
    /// `n/2` `dst` registers. Register-`A` and negate are rejected.
    WgmmaMmaAsync {
        shape: crate::tensor_core::MmaShape,
        dst: Vec<RegId>,
        a_desc: Operand,
        b_desc: Operand,
        scale_d: Operand,
        a_type: ScalarType,
        b_type: ScalarType,
        transpose_a: bool,
        transpose_b: bool,
    },

    /// `wgmma.fence` (PTX ISA 9.7.17.7.1): orders a warpgroup's register
    /// accesses before `wgmma.mma_async`. Volta does not track register
    /// hazards here (like `Tcgen05Fence`), so this is a genuine no-op.
    WgmmaFence,

    /// `wgmma.commit_group` (PTX ISA 9.7.17.7.2): batches this warp's
    /// uncommitted `wgmma.mma_async` ops into a wgmma-group; a no-op, since
    /// evaluation is eager and group membership is not tracked.
    WgmmaCommitGroup,

    /// `wgmma.wait_group N` (PTX ISA 9.7.17.7.3): wait until at most `N`
    /// groups are pending. `N` is a lowering-validated constant, kept for
    /// `ThreadState::wgmma` to know how many groups to release.
    WgmmaWaitGroup { n: u32 },

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
    /// use; the release-proxy fence has no data effect to model.
    TensormapCpFenceproxy {
        dst_base: Operand,
        dst_offset: i64,
        src_base: Operand,
        src_offset: i64,
    },

    /// `fence.proxy.tensormap::generic{.release.scope | .acquire.scope
    /// [addr], 128}`: a pure proxy-ordering fence, no data effect to model -
    /// the same treatment as `Tcgen05Fence`.
    FenceProxyTensormap,

    /// `cp.async.bulk.tensor...tile.mbarrier::complete_tx::bytes`: TMA copy,
    /// global to the executing CTA's shared memory (no remote/multicast).
    /// `tensormap_space` must be `.global`.
    CpAsyncBulkTensorLoad {
        dst_base: Operand,
        dst_offset: i64,
        tensormap_space: MemSpace,
        tensormap_base: Operand,
        tensormap_offset: i64,
        coords: Vec<Operand>,
        mbar_base: Operand,
        mbar_offset: i64,
    },

    /// `cp.async.bulk...mbarrier::complete_tx::bytes`: non-tensor copy of
    /// `size` contiguous bytes, global to shared, completing `size` tx-bytes
    /// on `mbar` (`lowering::lower_cp_async_bulk`).
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

    /// `clusterlaunchcontrol.query_cancel.get_first_ctaid{::dim}.{v4.}b32.b128`:
    /// `dst` holds the requested ctaid components (sinks dropped).
    ClcQueryGetFirstCtaid { dst: Vec<RegId>, response: RegId },

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

    /// `mbarrier.inval{.shared{::cta}}.b64 [addr]`: destroy the `mbarrier`
    /// object at `addr_base + addr_offset`.
    MbarrierInval {
        addr_base: Operand,
        addr_offset: i64,
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

    /// `mbarrier.complete_tx{.sem.scope}{.space}.b64 [addr], txCount`:
    /// signal that `txCount` bytes of a previously-`expect_tx`'d async
    /// transaction have completed.
    MbarrierCompleteTx {
        addr_base: Operand,
        addr_offset: i64,
        tx_count: Operand,
    },

    /// `mbarrier.{test,try}_wait.parity`: block until `phase_parity`'s phase
    /// completes, then set `waitComplete`. Both collapse to blocking, else
    /// the `@!p bra retry` loop would spin round-robin forever.
    MbarrierWaitParity {
        wait_complete: RegId,
        addr_base: Operand,
        addr_offset: i64,
        phase_parity: Operand,
    },

    // =========================================================================
    // Special
    // =========================================================================
    /// Query active lanes in the warp: dst = mask of active threads
    Activemask { dst: RegId },

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
    Set,
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
    Membar,
    Fence,
    FenceProxyAsync,
    CpAsyncCommitGroup,
    CpAsyncWaitGroup,
    CpAsyncMbarrierArrive,
    Shfl,
    ShflSync,
    ElectSync,
    ReduxSync,
    ReduxSyncBroadcastMax,
    Ldmatrix,
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
    WgmmaMmaAsync,
    WgmmaFence,
    WgmmaCommitGroup,
    WgmmaWaitGroup,
    Stmatrix,
    TensormapReplace,
    TensormapCpFenceproxy,
    FenceProxyTensormap,
    CpAsyncBulkTensorLoad,
    CpAsyncBulkLoad,
    ClcTryCancel,
    ClcQueryIsCanceled,
    ClcQueryGetFirstCtaid,
    MbarrierInit,
    MbarrierInval,
    MbarrierArrive,
    MbarrierCompleteTx,
    MbarrierWaitParity,
    Activemask,
    Trap,
    Nop,
);

impl LoweredInstr {
    /// Collect all general-purpose registers read by this instruction,
    /// excluding predicate guards (see `LoweredProgram::predicate`) and
    /// special registers.
    pub fn source_regs(&self) -> Vec<RegId> {
        fn from_op(op: &Operand) -> Option<RegId> {
            op.as_reg()
        }
        fn from_ops(ops: &[Operand]) -> Vec<RegId> {
            ops.iter().filter_map(from_op).collect()
        }

        match self {
            // Data movement
            Self::LoadParam { .. } => vec![],
            Self::Load { base, .. } => from_op(base).into_iter().collect(),
            Self::LoadVec { base, .. } => from_op(base).into_iter().collect(),
            Self::Store { base, src, .. } => {
                let mut r = Vec::new();
                r.extend(from_op(base));
                r.extend(from_op(src));
                r
            }
            Self::StoreVec { base, src, .. } => {
                let mut r: Vec<RegId> = from_op(base).into_iter().collect();
                r.extend(from_ops(src));
                r
            }
            Self::CpAsync {
                dst_base,
                src_base,
                src_size,
                ..
            } => {
                let mut r: Vec<RegId> = from_op(dst_base).into_iter().collect();
                r.extend(from_op(src_base));
                match src_size {
                    CpAsyncSrcSize::Sized(op) | CpAsyncSrcSize::IgnoreSrc(op) => {
                        r.extend(from_op(op));
                    }
                    CpAsyncSrcSize::Full => {}
                }
                r
            }
            Self::Mov { src, .. } => from_op(src).into_iter().collect(),
            Self::Cvta { src, .. } => from_op(src).into_iter().collect(),
            Self::Prmt {
                src_a,
                src_b,
                selector,
                ..
            } => from_ops(&[*src_a, *src_b, *selector]),
            Self::Lop3 {
                src_a,
                src_b,
                src_c,
                lut,
                ..
            } => from_ops(&[*src_a, *src_b, *src_c, *lut]),

            // Arithmetic
            Self::BinOp { src_a, src_b, .. } => from_ops(&[*src_a, *src_b]),
            Self::UnaryOp { src, .. } => from_op(src).into_iter().collect(),
            Self::Copysign {
                sign_src,
                magnitude_src,
                ..
            } => from_ops(&[*sign_src, *magnitude_src]),
            Self::Fma {
                src_a,
                src_b,
                src_c,
                ..
            }
            | Self::Mad {
                src_a,
                src_b,
                src_c,
                ..
            } => from_ops(&[*src_a, *src_b, *src_c]),
            Self::MulWide { src_a, src_b, .. } | Self::MulHi { src_a, src_b, .. } => {
                from_ops(&[*src_a, *src_b])
            }
            Self::Bfi {
                src_a,
                src_b,
                start,
                len,
                ..
            } => from_ops(&[*src_a, *src_b, *start, *len]),
            Self::Bfe {
                src_a, start, len, ..
            } => from_ops(&[*src_a, *start, *len]),

            // Comparison & selection
            Self::Setp { src_a, src_b, .. } | Self::Set { src_a, src_b, .. } => {
                from_ops(&[*src_a, *src_b])
            }
            Self::Selp {
                src_a, src_b, pred, ..
            } => from_ops(&[*src_a, *src_b, *pred]),

            // Type conversion
            Self::Cvt { src, .. } => from_op(src).into_iter().collect(),
            Self::CvtE4m3x2ToF16x2 { src, .. } => from_op(src).into_iter().collect(),
            Self::CvtPackHalves { src_hi, src_lo, .. } => from_ops(&[*src_hi, *src_lo]),
            Self::UnpackHalves { src, .. } => from_op(src).into_iter().collect(),
            Self::PackHalves { lo, hi, .. } => from_ops(&[*lo, *hi]),
            Self::PackQuad { elems, .. } => from_ops(elems),
            Self::UnpackQuad { src, .. } => from_op(src).into_iter().collect(),
            Self::Shf { lo, hi, shift, .. } => from_ops(&[*lo, *hi, *shift]),

            // Control flow
            Self::Bra { .. } | Self::Ret | Self::Exit | Self::Trap | Self::Nop => vec![],

            // Warp queries
            Self::Activemask { .. } => vec![],

            // Synchronization
            Self::BarSync {
                barrier_id,
                thread_count,
            } => from_op(barrier_id)
                .into_iter()
                .chain(thread_count.as_ref().and_then(from_op))
                .collect(),
            Self::BarArrive {
                barrier_id,
                thread_count,
            } => from_op(barrier_id)
                .into_iter()
                .chain(from_op(thread_count))
                .collect(),
            Self::BarWarpSync { mask } => from_op(mask).into_iter().collect(),
            Self::Membar { .. } | Self::Fence | Self::FenceProxyAsync { .. } => vec![],
            Self::CpAsyncCommitGroup | Self::CpAsyncWaitGroup { .. } => vec![],
            Self::CpAsyncMbarrierArrive { addr_base, .. } => {
                from_op(addr_base).into_iter().collect()
            }

            // Warp shuffle
            Self::Shfl {
                src,
                offset_or_lane,
                clamp,
                ..
            } => from_ops(&[*src, *offset_or_lane, *clamp]),
            Self::ShflSync {
                src,
                offset_or_lane,
                clamp,
                membermask,
                ..
            } => from_ops(&[*src, *offset_or_lane, *clamp, *membermask]),
            Self::ElectSync { membermask, .. } => from_op(membermask).into_iter().collect(),
            Self::ReduxSync {
                src, membermask, ..
            } => from_ops(&[*src, *membermask]),
            Self::ReduxSyncBroadcastMax {
                src, membermask, ..
            } => from_ops(&[*src, *membermask]),

            // Tensor core
            Self::Ldmatrix { addr, .. } => from_op(addr).into_iter().collect(),
            Self::Mma {
                src_a,
                src_b,
                src_c,
                ..
            } => {
                let mut r = Vec::new();
                r.extend(src_a.iter().copied());
                r.extend(src_b.iter().copied());
                r.extend(from_ops(src_c));
                r
            }
            Self::WmmaMma {
                src_a,
                src_b,
                src_c,
                ..
            } => {
                let mut r = Vec::new();
                r.extend(src_a.iter().copied());
                r.extend(src_b.iter().copied());
                r.extend(src_c.iter().copied());
                r
            }
            Self::WmmaLoad { addr, stride, .. } => {
                let mut r = Vec::new();
                r.extend(from_op(addr));
                r.extend(from_op(stride));
                r
            }
            Self::WmmaStore {
                src, addr, stride, ..
            } => {
                let mut r = Vec::new();
                r.extend(src.iter().copied());
                r.extend(from_op(addr));
                r.extend(from_op(stride));
                r
            }

            // Tensor Memory allocation
            Self::Tcgen05Alloc { dst_base, .. } => from_op(dst_base).into_iter().collect(),
            Self::Tcgen05Dealloc { taddr, .. } => from_op(taddr).into_iter().collect(),
            Self::Tcgen05RelinquishAllocPermit => vec![],

            // Tensor Memory register load/store
            Self::Tcgen05Ld { taddr_base, .. } => from_op(taddr_base).into_iter().collect(),
            Self::Tcgen05St {
                taddr_base, src, ..
            } => {
                let mut r = Vec::new();
                r.extend(from_op(taddr_base));
                r.extend(from_ops(src));
                r
            }
            Self::Tcgen05Wait { .. } => vec![],

            // Matrix multiply and accumulate
            Self::Tcgen05Mma {
                d_tmem_base,
                a,
                b_desc,
                idesc,
                disable_output_lane,
                enable_input_d,
                ..
            } => {
                let a = match a {
                    Tcgen05MmaA::Desc(desc) => *desc,
                    Tcgen05MmaA::Tmem { base, .. } => *base,
                };
                let mut r = from_ops(&[*d_tmem_base, a, *b_desc, *idesc, *enable_input_d]);
                r.extend(from_ops(disable_output_lane));
                r
            }

            // Fence & commit
            Self::Tcgen05Fence => vec![],
            Self::Tcgen05Commit { addr_base, .. } => from_op(addr_base).into_iter().collect(),

            // Asynchronous warpgroup-level matrix multiply-accumulate
            Self::WgmmaMmaAsync {
                dst,
                a_desc,
                b_desc,
                scale_d,
                ..
            } => {
                let mut r = from_ops(&[*a_desc, *b_desc, *scale_d]);
                // Conservatively "maybe read": `scale_d` gates whether the
                // accumulator is actually read, but that's a runtime value
                // at eval time, not something known here.
                r.extend(dst.iter().copied());
                r
            }
            Self::WgmmaFence | Self::WgmmaCommitGroup | Self::WgmmaWaitGroup { .. } => vec![],
            Self::Stmatrix { addr, src, .. } => {
                let mut r = from_op(addr).into_iter().collect::<Vec<_>>();
                r.extend(from_ops(src));
                r
            }

            // Tensor-map objects & TMA tensor copy
            Self::TensormapReplace {
                addr_base, field, ..
            } => {
                let mut r: Vec<RegId> = from_op(addr_base).into_iter().collect();
                match field {
                    TensormapFieldWrite::GlobalAddress(v)
                    | TensormapFieldWrite::Rank(v)
                    | TensormapFieldWrite::BoxDim { new_val: v, .. }
                    | TensormapFieldWrite::GlobalDim { new_val: v, .. }
                    | TensormapFieldWrite::GlobalStride { new_val: v, .. }
                    | TensormapFieldWrite::ElementStride { new_val: v, .. } => {
                        r.extend(from_op(v));
                    }
                    TensormapFieldWrite::Elemtype(_)
                    | TensormapFieldWrite::InterleaveLayout(_)
                    | TensormapFieldWrite::SwizzleMode(_)
                    | TensormapFieldWrite::SwizzleAtomicity(_)
                    | TensormapFieldWrite::FillMode(_) => {}
                }
                r
            }
            Self::TensormapCpFenceproxy {
                dst_base, src_base, ..
            } => from_ops(&[*dst_base, *src_base]),
            Self::FenceProxyTensormap => vec![],
            Self::CpAsyncBulkTensorLoad {
                dst_base,
                tensormap_base,
                coords,
                mbar_base,
                ..
            } => {
                let mut r: Vec<RegId> = from_ops(&[*dst_base, *tensormap_base, *mbar_base]);
                r.extend(from_ops(coords));
                r
            }
            Self::CpAsyncBulkLoad {
                dst_base,
                src_base,
                size,
                mbar_base,
                ..
            } => from_ops(&[*dst_base, *src_base, *size, *mbar_base]),
            Self::ClcTryCancel {
                addr_base,
                mbar_base,
                ..
            } => from_ops(&[*addr_base, *mbar_base]),
            Self::ClcQueryIsCanceled { response, .. }
            | Self::ClcQueryGetFirstCtaid { response, .. } => vec![*response],

            // mbarrier
            Self::MbarrierInit {
                addr_base, count, ..
            } => from_ops(&[*addr_base, *count]),
            Self::MbarrierInval { addr_base, .. } => from_op(addr_base).into_iter().collect(),
            Self::MbarrierArrive {
                addr_base,
                count,
                expect_tx,
                ..
            } => {
                let mut r: Vec<RegId> = from_op(addr_base).into_iter().collect();
                if let Some(c) = count {
                    r.extend(from_op(c));
                }
                if let Some(tx) = expect_tx {
                    r.extend(from_op(tx));
                }
                r
            }
            Self::MbarrierCompleteTx {
                addr_base,
                tx_count,
                ..
            } => from_ops(&[*addr_base, *tx_count]),
            Self::MbarrierWaitParity {
                addr_base,
                phase_parity,
                ..
            } => from_ops(&[*addr_base, *phase_parity]),
        }
    }

    /// Collect all general-purpose registers written by this instruction.
    pub fn dest_regs(&self) -> Vec<RegId> {
        match self {
            // Single destination
            Self::LoadParam { dst, .. }
            | Self::Load { dst, .. }
            | Self::Mov { dst, .. }
            | Self::Cvta { dst, .. }
            | Self::Prmt { dst, .. }
            | Self::Lop3 { dst, .. }
            | Self::BinOp { dst, .. }
            | Self::UnaryOp { dst, .. }
            | Self::Copysign { dst, .. }
            | Self::Fma { dst, .. }
            | Self::Mad { dst, .. }
            | Self::MulWide { dst, .. }
            | Self::MulHi { dst, .. }
            | Self::Bfi { dst, .. }
            | Self::Bfe { dst, .. }
            | Self::Setp { dst, .. }
            | Self::Selp { dst, .. }
            | Self::Set { dst, .. }
            | Self::Cvt { dst, .. }
            | Self::CvtE4m3x2ToF16x2 { dst, .. }
            | Self::CvtPackHalves { dst, .. }
            | Self::PackHalves { dst, .. }
            | Self::PackQuad { dst, .. }
            | Self::Shf { dst, .. }
            | Self::ReduxSync { dst, .. }
            | Self::ReduxSyncBroadcastMax { dst, .. }
            | Self::Activemask { dst }
            | Self::ClcQueryIsCanceled { dst, .. } => vec![*dst],

            // Vector destinations
            Self::LoadVec { dst, .. }
            | Self::Ldmatrix { dst, .. }
            | Self::Mma { dst, .. }
            | Self::WmmaLoad { dst, .. }
            | Self::WmmaMma { dst, .. }
            | Self::Tcgen05Ld { dst, .. }
            | Self::WgmmaMmaAsync { dst, .. }
            | Self::ClcQueryGetFirstCtaid { dst, .. } => dst.clone(),

            // Shuffle: dst + optional dst_pred
            Self::Shfl { dst, dst_pred, .. } | Self::ShflSync { dst, dst_pred, .. } => {
                let mut r = vec![*dst];
                if let Some(p) = dst_pred {
                    r.push(*p);
                }
                r
            }

            // Unpack: two destinations
            Self::UnpackHalves { lo, hi, .. } => lo.iter().chain(hi.iter()).copied().collect(),

            // Unpack: four destinations, any of them sinkable
            Self::UnpackQuad { elems, .. } => elems.iter().flatten().copied().collect(),

            // Elect: required dst_pred + optional dst (sink-able lane id)
            Self::ElectSync { dst, dst_pred, .. } => {
                let mut r = vec![*dst_pred];
                r.extend(dst.iter().copied());
                r
            }

            // mbarrier: optional destination (arrive's discardable phase
            // token) or a required one (wait's boolean result)
            Self::MbarrierArrive { state, .. } => state.iter().copied().collect(),
            Self::MbarrierWaitParity { wait_complete, .. } => vec![*wait_complete],

            // No destination
            Self::Store { .. }
            | Self::StoreVec { .. }
            | Self::CpAsync { .. }
            | Self::WmmaStore { .. }
            | Self::Bra { .. }
            | Self::Ret
            | Self::Exit
            | Self::Trap
            | Self::BarSync { .. }
            | Self::BarArrive { .. }
            | Self::BarWarpSync { .. }
            | Self::Membar { .. }
            | Self::Fence
            | Self::FenceProxyAsync { .. }
            | Self::CpAsyncCommitGroup
            | Self::CpAsyncWaitGroup { .. }
            | Self::CpAsyncMbarrierArrive { .. }
            | Self::Tcgen05Alloc { .. }
            | Self::Tcgen05Dealloc { .. }
            | Self::Tcgen05RelinquishAllocPermit
            | Self::Tcgen05St { .. }
            | Self::Tcgen05Wait { .. }
            | Self::Tcgen05Mma { .. }
            | Self::Tcgen05Fence
            | Self::Tcgen05Commit { .. }
            | Self::WgmmaFence
            | Self::WgmmaCommitGroup
            | Self::WgmmaWaitGroup { .. }
            | Self::Stmatrix { .. }
            | Self::TensormapReplace { .. }
            | Self::TensormapCpFenceproxy { .. }
            | Self::FenceProxyTensormap
            | Self::CpAsyncBulkTensorLoad { .. }
            | Self::CpAsyncBulkLoad { .. }
            | Self::ClcTryCancel { .. }
            | Self::MbarrierInit { .. }
            | Self::MbarrierInval { .. }
            | Self::MbarrierCompleteTx { .. }
            | Self::Nop => vec![],
        }
    }
}

/// Scope for memory barriers
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MembarScope {
    Cta,
    Gpu,
    Sys,
}

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

    /// Format a register for error messages
    pub fn format_reg(&self, reg: RegId) -> String {
        self.symbols
            .register_name(reg)
            .map(|s| s.to_string())
            .unwrap_or_else(|| format!("{:?}[{}]", reg.class, reg.index))
    }

    /// Get the source span for an instruction
    pub fn instruction_span(&self, pc: InstrId) -> Option<Span> {
        self.source_map.instruction_span(pc)
    }

    /// Number of instructions
    pub fn len(&self) -> usize {
        self.instructions.len()
    }

    /// Check if program is empty
    pub fn is_empty(&self) -> bool {
        self.instructions.is_empty()
    }

    /// Get register counts per class
    pub fn register_counts(&self) -> RegCounts {
        self.symbols.register_counts()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::RegClass;

    #[test]
    fn test_operand_types() {
        let reg = Operand::Reg(RegId::new(RegClass::Bits32, 0));
        assert!(reg.is_register());
        assert!(!reg.is_immediate());

        let imm = Operand::ImmI64(42);
        assert!(!imm.is_register());
        assert!(imm.is_immediate());
    }

    #[test]
    fn test_binop_names() {
        assert_eq!(BinOp::Add.as_str(), "add");
        assert_eq!(BinOp::Mul.as_str(), "mul");
        assert_eq!(BinOp::Shl.as_str(), "shl");
    }
}
