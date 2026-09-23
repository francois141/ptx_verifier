//! Lowered PTX instructions
//!
//! This module defines the lowered instruction set that results from the
//! lowering pass. These instructions have:
//! - Resolved register references (indices instead of strings)
//! - Resolved branch targets (PCs instead of label names)
//! - Stripped unnecessary modifiers
//! - Unified instruction formats

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

/// Float value clamp applied to an instruction's result (PTX `.sat`/`.relu`).
///
/// Over the floats-as-reals model these are exact value transformations:
/// `.sat` is `min(max(x, 0), 1)` and `.relu` is `max(x, 0)`. (The spec's
/// `.sat` additionally flushes a NaN result to +0.0, and cvt's `.relu`
/// canonicalizes NaN; NaN is out of model over the reals, as everywhere
/// else in the interpreter.)
///
/// Lowering only sets a clamp on scalar floating-point forms; the
/// integer `.sat`/`.relu` modifiers (wrap-avoiding integer saturation)
/// are different operations and stay rejected.
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

    /// Vector store. Unlike `LoadVec`'s destination (always plain
    /// registers), each source element may be any operand - a store reads
    /// its source rather than writing it, so an immediate (e.g. `{%f1,
    /// %f2, 0f00000000, %f4}`, a common "zero-init one lane" idiom) is
    /// just as valid as a register.
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
        ty: ScalarType,
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

    /// `cvt.rn{.relu}.f16x2.e4m3x2 dst, src` (PTX ISA 9.7.9.22): unpack two
    /// packed `.e4m3` fp8 bytes into an `.f16x2` pair. Scoped to exactly
    /// this one direction/type pair - the only form observed in practice
    /// (nothing in the corpus produces an `.e4m3x2` value, and `.e5m2x2`
    /// never appears at all); a symmetric addition would cover either if
    /// ever needed.
    ///
    /// At eval time `src`'s value kind decides the path, same reasoning as
    /// `UnpackHalves`: a `Value::Pair` (the common case - a symbolic fp8
    /// input array element, already split from a `Value::Quad` by a
    /// preceding `mov.b32 {h0,h1}, r`) is identity-over-the-reals, exactly
    /// like every other float<->float `cvt` - no bit decode, since each
    /// byte-slot already *is* the real value that array position holds. A
    /// `Value::Scalar` (a concrete 16-bit pattern that never went through
    /// array materialization, e.g. a `cp.async` zero-fill word or a
    /// literal `mov.b16`) is a genuine bit pattern and is decoded via
    /// `eval::fp8::decode_e4m3_byte`.
    CvtE4m3x2ToF16x2 {
        dst: RegId,
        src: Operand,
        relu: bool,
    },

    /// Two-source packed-half convert: `cvt.rnd.f16x2.f32 dst, src_hi, src_lo`.
    /// Writes a `Value::Pair` directly (never bit-encoded, matching every
    /// other producer of packed f16 pairs) rather than composing it via
    /// `Cvt` + `mov.b32`'s bitwise pack, since the two source values are
    /// exact reals here, not integer bit patterns.
    CvtPackHalves {
        dst: RegId,
        src_hi: Operand,
        src_lo: Operand,
        /// Per-lane destination type (`F16` for an `f16x2` dst, `Bf16` for
        /// `bf16x2`), precomputed at lowering time.
        dst_half_ty: ScalarType,
        src_ty: ScalarType,
    },

    /// Vector-destination unpack: `mov.bN {lo, hi}, src`. `src`'s *runtime*
    /// value kind decides the semantics, which lowering cannot know
    /// statically: a `Value::Pair` (e.g. a native packed-f16 granule read
    /// straight out of memory, or an `f32x2` result in a 64-bit register)
    /// distributes its two real-valued halves
    /// directly, matching every other packed-pair producer/consumer
    /// (`CvtPackHalves`, `eval/memory.rs`'s granule combining) - never
    /// bit-encoded; a `Value::Scalar` falls back to the bitwise `And`/`Shr`
    /// decomposition this used to always emit.
    UnpackHalves {
        /// `None` when the PTX discards that half with the `_` sink.
        lo: Option<RegId>,
        hi: Option<RegId>,
        src: Operand,
        /// The `mov`'s full-width type (e.g. `B32` for a 2x16 unpack).
        ty: ScalarType,
    },

    /// Vector-source pack: `mov.b32 dst, {lo, hi}` and `mov.b64 dst, {lo,
    /// hi}`. Always writes a `Value::Pair(lo, hi)` rather than bit-shifting -
    /// the two source halves are frequently real-valued (an f16 element from
    /// `cvt.*.f16.*` or a plain 2-byte load; two f32 values feeding packed
    /// `f32x2` arithmetic), and bit ops on a real number silently build a
    /// nonsense expression rather than erroring. This is exact whether the
    /// halves are real or genuinely integer: a later `UnpackHalves` or a
    /// store to a half-width-elem_width array round-trips either way, and
    /// `scalar_operand` recombines a pair of concrete integer halves (the
    /// `mov.b64` address/constant idiom) into the wide bit pattern on
    /// demand. Only a packed value with symbolic halves later used as a true
    /// scalar in its own right (added, compared, stored as one wide integer)
    /// fails loudly instead of silently computing garbage - preferred, per
    /// this codebase's convention elsewhere (see `canon_stored`'s docs).
    PackHalves {
        dst: RegId,
        lo: Operand,
        hi: Operand,
    },

    /// Four-element vector-source pack: `mov.b128 dst, {e0, e1, e2, e3}`.
    /// Writes a `Value::Quad` for exactly the reason `PackHalves` writes a
    /// `Value::Pair`: the lanes are frequently real-valued (here, the four
    /// f32 accumulator slots a kernel zero-fills through one 128-bit
    /// register), and bit ops on a real number silently build a nonsense
    /// expression rather than erroring.
    ///
    /// This widens `Value::Quad` past its original
    /// four-8-bit-lanes-in-a-`b32` reading exactly as `Value::Pair` already
    /// spans both 2x16-in-`b32` and 2x32-in-`b64`: a quad is "four
    /// independent lanes in one register", with the lane width following
    /// the register class. The two readings cannot be confused, since they
    /// live in different `RegClass` arrays and every 8-bit-lane consumer
    /// (`CvtE4m3x2ToF16x2`, `UnpackHalves`'s quad arm, `gather_fp8_fragment`)
    /// takes a `Bits32` operand.
    PackQuad {
        dst: RegId,
        /// Lane 0 is the least significant / lowest-addressed, matching
        /// `Value::Quad`'s tuple order.
        elems: [Operand; 4],
    },

    /// Four-element vector-destination unpack: `mov.b128 {e0, e1, e2, e3},
    /// src` - the reverse of `PackQuad`, and how a kernel reads the four
    /// lanes of a 128-bit register back out (the zero-fill idiom: one
    /// `mov.b128 %zero, {%r,%r,%r,%r}`, then one unpack per accumulator
    /// quad). Any element may be the `_` sink, as in `UnpackHalves`.
    ///
    /// Only a `Value::Quad` source is modeled - the `PackQuad` round-trip,
    /// which is exact whatever the lanes hold. A `Value::Scalar` 128-bit
    /// bit pattern would need a bitwise decomposition there is no 128-bit
    /// scalar arithmetic for here, so it fails loudly at eval time rather
    /// than computing garbage.
    UnpackQuad {
        /// `None` where the PTX discards that lane with the `_` sink.
        elems: [Option<RegId>; 4],
        src: Operand,
    },

    /// Funnel shift: `shf.{l,r}.{clamp,wrap}.b32 dst, lo, hi, shift` (PTX
    /// ISA 9.7.9.7). Shifts the 64-bit value formed by concatenating `hi`
    /// (bits 63:32) and `lo` (bits 31:0), writing the 32 most-significant
    /// bits for `.l` and the 32 least-significant for `.r`:
    ///
    /// ```text
    /// n = (.clamp) ? min(shift, 32) : shift & 0x1f
    /// .l: dst = (hi << n) | (lo >> (32 - n))
    /// .r: dst = (hi << (32 - n)) | (lo >> n)
    /// ```
    ///
    /// Like `UnpackHalves`, the operands' *runtime* value kinds decide the
    /// semantics and lowering cannot know them statically: a `Value::Pair`
    /// (two f16 lanes) has no bit pattern to shift, so `n == 16` on such an
    /// operand is evaluated as the exact lane shuffle it is - the "advance
    /// an f16 pair by one element" idiom behind a strided/unaligned gather.
    /// Plain integer scalars take the ordinary bitwise path.
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
    /// CTA barrier: bar.sync barrier_id
    BarSync { barrier_id: u32 },

    /// Warp barrier: bar.warp.sync mask
    BarWarpSync { mask: Operand },

    /// Memory fence
    Membar { scope: MembarScope },

    /// `fence{.sem}.scope` (plain thread fence) or `fence.proxy.alias{.sem}
    /// .scope` (bi-directional alias-proxy fence): a pure ordering fence,
    /// no data effect to model - the same treatment as `Tcgen05Fence`/
    /// `FenceProxyTensormap`. `fence.proxy.async{...}` is a distinct
    /// variant (`FenceProxyAsync`, below) - unlike these, it has a real
    /// data-visibility effect Volta tracks.
    Fence,

    /// `fence.proxy.async{.global|.shared::cta|.shared::cluster}{.sem}
    /// .scope`: clears the executing thread's own outstanding
    /// "unfenced async-proxy write" marks for bytes matching `restrict`
    /// (`None` = unrestricted, both `Global` and `Shared`) - see
    /// `RaceTracker::clear_async_proxy_fence`. `.shared::cta` and
    /// `.shared::cluster` both lower to `MemSpace::Shared`: `MemSpace` has
    /// no cluster-vs-cta distinction, and neither does anything else this
    /// tracks.
    FenceProxyAsync { restrict: Option<MemSpace> },

    /// Seal all of this thread's uncommitted `CpAsync` copies into a new
    /// async-group at the back of its completion queue.
    CpAsyncCommitGroup,

    /// Block until at most `n` of this thread's async-groups remain
    /// pending.
    CpAsyncWaitGroup { n: u32 },

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

    /// Elect one active lane as leader: `elect.sync d|p, membermask`. The
    /// deterministic-lowest-live-lane leader gets `dst = its lane id` (when
    /// `dst` isn't sink) and `dst_pred = true`; every other live lane in
    /// the mask gets `dst_pred = false` and, if `dst` isn't sink, an
    /// `Undefined` `dst` - the ISA defines `d`'s value only for the elected
    /// thread.
    ElectSync {
        dst: Option<RegId>,
        dst_pred: RegId,
        membermask: Operand,
    },

    /// Warp-synchronized reduction: `redux.sync.op.type d, a, membermask`
    /// (PTX ISA Block 143). Folds every live mask lane's `a` with `op` -
    /// `Add`/`And`/`Or`/`Xor`/`Min`/`Max` (the AST's `RedOp::Inc`/`Dec`
    /// have no `BinOp` equivalent and are rejected at lowering, since
    /// they are not valid `redux.sync` ops per the ISA) - and broadcasts
    /// the single result to `dst` on every live lane.
    ReduxSync {
        op: BinOp,
        ty: ScalarType,
        dst: RegId,
        src: Operand,
        membermask: Operand,
    },

    /// The warp-max "sortable signed int" idiom, recognized whole at
    /// lowering time (see `match_warp_max_sign_trick`): nvcc computes
    /// a real-valued row/warp max by broadcasting the value into both
    /// halves of a b32 register, reducing with a signed-int
    /// `redux.sync.max.s32` (whose bit-pattern order only matches real
    /// order for nonnegative values), then correcting the all-negative
    /// case with a second, predicated `redux.sync.min.s32` on the same
    /// broadcast source. Volta's real-valued semantics need none of that:
    /// `src` here is the broadcast's *underlying* real-valued operand (not
    /// the broadcast b32 register), reduced directly with real `max` -
    /// exact for any sign, so the bit-trick's fixup step is provably a
    /// no-op and is elided entirely (never lowered). `dst` gets the result
    /// as a `Value::Pair(result, result)`, matching how the source was
    /// broadcast and how callers read it back as an f16x2 operand.
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

    /// Matrix multiply-accumulate via mma.sync API. `src_c` (the
    /// accumulator) may be any operand, not just a register: nvcc's
    /// "first tile has no accumulator yet" idiom passes immediate-zero
    /// literals directly (`{0f00000000, ...}`) rather than zeroing
    /// registers first.
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
    /// `tcgen05.ld.sync.aligned.32x32b.num.b32 r, [taddr]`: collective async
    /// load of `dst.len()` columns starting at `taddr_base + taddr_offset`
    /// into one register per column, per lane.
    Tcgen05Ld {
        dst: Vec<RegId>,
        taddr_base: Operand,
        taddr_offset: i64,
    },

    /// `tcgen05.st.sync.aligned.32x32b.num.b32 [taddr], r`: collective async
    /// store of `src.len()` columns starting at `taddr_base + taddr_offset`
    /// from one register per column, per lane.
    Tcgen05St {
        taddr_base: Operand,
        taddr_offset: i64,
        src: Vec<Operand>,
    },

    /// `tcgen05.wait::ld.sync.aligned` / `tcgen05.wait::st.sync.aligned`:
    /// release every pending `.ld` (`is_st = false`) or `.st`
    /// (`is_st = true`) async-hazard footprint this warp's quadrant holds
    /// (`RaceTracker::tcgen05_wait`). Volta's sequential execution model
    /// already gives every `tcgen05.ld`/`.st` its full data effect
    /// immediately, so there is no data effect left to wait for here - this
    /// exists purely to release the async-hazard tracking those two
    /// instructions record.
    Tcgen05Wait { is_st: bool },

    // =========================================================================
    // TensorCore 5th Generation - Matrix Multiply and Accumulate (PTX ISA 9.7.17.10)
    // =========================================================================
    /// `tcgen05.mma.cta_group::1.kind::{f16,f8f6f4} [d-tmem], a-desc, b-desc,
    /// idesc, {disable-output-lane}, enable-input-d`: single-thread-issued (unlike
    /// `mma.sync`/`wmma`) `D = A*B+D` (or `A*B` if `enable-input-d` is
    /// false) into Tensor Memory at `d_tmem_base + d_tmem_offset`, skipping
    /// any lane (`m`, for `.cta_group::1`'s dense M=128 shape) whose bit is
    /// set in `disable_output_lane` (a 4-element vector forming a 128-bit
    /// mask, PTX ISA 9.7.17.10.9.1: "least significant bit of the first
    /// element... corresponding to lane 0"). `a_desc`/`b_desc` are 64-bit
    /// shared-memory matrix descriptors (9.7.17.4.1); `idesc` is the 32-bit
    /// instruction descriptor (9.7.17.4.2) giving M/N/element
    /// types/transpose/negate - all decoded from their concrete values at
    /// eval time (`eval::tcgen05_mma`), since only the register operands
    /// are visible at lowering. Scoped to dense `.kind::f16`/`.kind::f8f6f4`
    /// with `A` in shared memory (not `[a-tmem]`), no `scale-input-d`; the
    /// `.sp`/`.ws`/block-scaled forms are separate mnemonics, rejected at
    /// lowering.
    Tcgen05Mma {
        kind: Tcgen05MmaKind,
        d_tmem_base: Operand,
        d_tmem_offset: i64,
        a_desc: Operand,
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

    /// `tcgen05.commit.cta_group::1.mbarrier::arrive::one{.shared::cluster}.b64
    /// [mbar]`: once every async `tcgen05` op issued by this thread so far
    /// has completed, perform an mbarrier arrive-on(count=1) on the object
    /// at `addr_base + addr_offset` - the same effect as a plain
    /// `mbarrier.arrive` with no explicit count.
    Tcgen05Commit {
        addr_base: Operand,
        addr_offset: i64,
    },

    // =========================================================================
    // Asynchronous Warpgroup-Level Matrix Multiply-Accumulate
    // (PTX ISA 9.7.17.5-7)
    // =========================================================================
    /// `wgmma.mma_async.sync.aligned.m64nNk16.f32.f16.f16 d, a-desc, b-desc,
    /// scale-d, imm-scale-a, imm-scale-b, imm-trans-a, imm-trans-b` (the
    /// shared-memory-`A` syntax form, PTX ISA 9.7.17.5.2). `D = A*B+D` (or
    /// `A*B` if `scale_d` is false), computed warpgroup-wide (128 threads):
    /// each thread produces and writes only its own `n/2`-register slice of
    /// `dst` (also the read-if-`scale_d` accumulator - the same registers
    /// serve both roles, per
    /// `tensor_core::wgmma_m64n_k16::matrix_d`). `A`/`B` are both
    /// shared-memory-resident 64-bit matrix descriptors, decoded at eval
    /// time (`eval::wgmma::decode_wgmma_matrix_descriptor`). Scoped to
    /// dense `.f32.f16.f16` only; the alternate register-resident-`A`
    /// syntax form (`d, a, b-desc, ...`, no `imm-trans-a`) and any negate
    /// (`imm-scale-a`/`imm-scale-b` = -1) are rejected at lowering - see
    /// `lowering::lower_wgmma_mma_async`.
    WgmmaMmaAsync {
        shape: crate::tensor_core::MmaShape,
        dst: Vec<RegId>,
        a_desc: Operand,
        b_desc: Operand,
        scale_d: Operand,
        transpose_a: bool,
        transpose_b: bool,
    },

    /// `wgmma.fence.sync.aligned;` (PTX ISA 9.7.17.7.1): orders a
    /// warpgroup's *register* accesses (the accumulator and matrix-A-
    /// fragment registers) against a following `wgmma.mma_async`. Volta
    /// does not model register-hazard tracking at all (a deliberate,
    /// separate scope decision - mirrors `Tcgen05Fence`'s existing no-op
    /// treatment above), so this has no data effect to model: a genuine
    /// no-op, not a "modeled-then-discarded" one - nothing is tracked for
    /// it to release.
    WgmmaFence,

    /// `wgmma.commit_group.sync.aligned;` (PTX ISA 9.7.17.7.2): batches
    /// all prior uncommitted `wgmma.mma_async` ops issued by this warp
    /// into a new "wgmma-group", for a later `wgmma.wait_group` to wait
    /// on. Volta's evaluation is eager/sequential and does not track
    /// "wgmma-group" membership at all (out of scope, see `WgmmaFence`),
    /// so this is a genuine no-op.
    WgmmaCommitGroup,

    /// `wgmma.wait_group.sync.aligned N;` (PTX ISA 9.7.17.7.3): waits
    /// until at most `N` wgmma-groups remain pending. `N` is a
    /// compile-time non-negative integer, validated at lowering
    /// (`resolve_const_u32`) and kept - the eval-time register-hazard
    /// tracker (`ThreadState::wgmma`) needs it to know how many
    /// committed groups to release.
    WgmmaWaitGroup { n: u32 },

    /// `stmatrix.sync.aligned.x{1,2,4}[.trans].m8n8.shared.b16 [addr],
    /// {src...}` (PTX ISA 9.7.14.5.17) - `ldmatrix`'s store-direction
    /// mirror: same row-addressing convention
    /// (`eval::warp::exec_stmatrix`), `shared::cta` only (same scope
    /// `ldmatrix` already has).
    Stmatrix {
        addr: Operand,
        addr_offset: i64,
        src: Vec<Operand>,
        num: u32,
        trans: bool,
    },

    // =========================================================================
    // Tensor-map objects & TMA tensor copy (PTX ISA 5.5.8, 9.7.9.27,
    // 9.7.9.26.5.2, 9.7.14.17)
    // =========================================================================
    /// `tensormap.replace.mode.field{.ss}.b1024.type [addr], {ord,} new_val`:
    /// write one named field of the tensor-map object at `addr_base +
    /// addr_offset` (`space`-qualified - Volta requires an explicit
    /// `.global`/`.shared::cta` state space, see
    /// `lowering::lower_tensormap_replace`).
    TensormapReplace {
        space: MemSpace,
        addr_base: Operand,
        addr_offset: i64,
        field: TensormapFieldWrite,
    },

    /// `tensormap.cp_fenceproxy.global.shared::cta.tensormap::generic
    /// .release.scope.sync.aligned [dst], [src], 128`: materialize a
    /// structured copy of the tensor-map object at `src` (always
    /// `.shared::cta`) to `dst` (always `.global`, per the ISA's fixed
    /// `.cp_qualifiers`), so a later `cp.async.bulk.tensor` can address it
    /// through `dst`. The release-proxy fence has no data effect to model
    /// (Volta's execution model does not reorder across proxies).
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

    /// `cp.async.bulk.tensor.dim.shared::cluster.global.tile
    /// .mbarrier::complete_tx::bytes [dstMem], [tensorMap, {coords}],
    /// [mbar]`: TMA tensor copy, global to shared. Scoped to exactly this
    /// form (`.tile` load mode, the `global -> shared::cluster` direction,
    /// mbarrier-based completion) - see
    /// `lowering::lower_cp_async_bulk_tensor` for what is rejected.
    /// `tensormap_space` is the tensor-map object's own state space
    /// (`.param`/`.const`/`.global` per the ISA; Volta requires `.global`
    /// - see the lowering function).
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

    /// `mbarrier.arrive{.expect_tx}{.shared{::cta}}.b64 state, [addr]{,
    /// count}`: signal one arrival (or `count`, if given) at the
    /// `mbarrier` object, optionally also bumping its expected
    /// async-transaction count (`.expect_tx`). `state` is the destination
    /// for the opaque phase token; `None` when written as `_` - the corpus
    /// only ever consumes the `.parity` wait form, never this token.
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

    /// `mbarrier.test_wait.parity`/`mbarrier.try_wait.parity{...}.b64
    /// waitComplete, [addr], phaseParity`: block until the phase
    /// identified by `phase_parity` has completed, then write
    /// `waitComplete = true`. `test_wait` and `try_wait` collapse to this
    /// one blocking form - the ISA's distinction (an instantaneous poll vs.
    /// a hardware-bounded spin) doesn't matter to a scheduler that already
    /// picks one valid interleaving, and the source's own `@!p bra retry`
    /// loop would otherwise spin Volta's round-robin scheduler forever
    /// without ever giving the producer thread a turn (it only yields at
    /// explicit blocking points, not at ordinary branches).
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

/// Generates the instruction-kind profiling table from one variant list:
/// `KIND_COUNT`, `KIND_NAMES` (indexed by `kind_index`), `kind_index`, and
/// `kind_name` all come from the same source, so they cannot drift. The
/// `kind_list_is_exhaustive` helper is a compile-time check: adding a
/// `LoweredInstr` variant without adding it to the list fails to compile
/// there, and a misspelled list entry fails as an unknown pattern.
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
    BarWarpSync,
    Membar,
    Fence,
    FenceProxyAsync,
    CpAsyncCommitGroup,
    CpAsyncWaitGroup,
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
    /// Collect all general-purpose registers read by this instruction.
    ///
    /// Does not include predicate guards (check `LoweredProgram::predicate`
    /// separately) or special registers.
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
            Self::BarSync { .. } => vec![],
            Self::BarWarpSync { mask } => from_op(mask).into_iter().collect(),
            Self::Membar { .. } | Self::Fence | Self::FenceProxyAsync { .. } => vec![],
            Self::CpAsyncCommitGroup | Self::CpAsyncWaitGroup { .. } => vec![],

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
                a_desc,
                b_desc,
                idesc,
                disable_output_lane,
                enable_input_d,
                ..
            } => {
                let mut r = from_ops(&[*d_tmem_base, *a_desc, *b_desc, *idesc, *enable_input_d]);
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
            | Self::Activemask { dst } => vec![*dst],

            // Vector destinations
            Self::LoadVec { dst, .. }
            | Self::Ldmatrix { dst, .. }
            | Self::Mma { dst, .. }
            | Self::WmmaLoad { dst, .. }
            | Self::WmmaMma { dst, .. }
            | Self::Tcgen05Ld { dst, .. }
            | Self::WgmmaMmaAsync { dst, .. } => dst.clone(),

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
            | Self::BarWarpSync { .. }
            | Self::Membar { .. }
            | Self::Fence
            | Self::FenceProxyAsync { .. }
            | Self::CpAsyncCommitGroup
            | Self::CpAsyncWaitGroup { .. }
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
