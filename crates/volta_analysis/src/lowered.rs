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
use volta_frontend::ast::ScalarType;

use crate::source_map::SourceMap;
use crate::symbols::{ParamId, RegId, SpecialRegKind, SymbolTable};
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
    /// straight out of memory) distributes its two real-valued halves
    /// directly, matching every other packed-f16 producer/consumer
    /// (`CvtPackHalves`, `eval/memory.rs`'s granule combining) - never
    /// bit-encoded; a `Value::Scalar` falls back to the bitwise `And`/`Shr`
    /// decomposition this used to always emit.
    UnpackHalves {
        lo: RegId,
        hi: RegId,
        src: Operand,
        /// The `mov`'s full-width type (e.g. `B32` for a 2x16 unpack).
        ty: ScalarType,
    },

    /// Vector-source pack: `mov.b32 dst, {lo, hi}`. Always writes a
    /// `Value::Pair(lo, hi)` rather than bit-shifting - the two source
    /// halves are frequently real-valued (an f16 element from `cvt.*.f16.*`
    /// or a plain 2-byte load), and bit ops on a real number silently build
    /// a nonsense expression rather than erroring. This is exact whether
    /// the halves are real or genuinely integer: a later `UnpackHalves` or
    /// a store to a 2-byte-elem_width array round-trips either way: only a
    /// packed value later used as a true scalar in its own right (added,
    /// compared, stored as one wide integer) would now loudly fail instead
    /// of silently computing garbage - preferred, per this codebase's
    /// convention elsewhere (see `canon_stored`'s docs). Scoped to a 32-bit
    /// `mov` only: `Value::Pair` is fixed at two 16-bit halves everywhere
    /// else in this model, so a `mov.b64 dst, {lo, hi}` (two 32-bit
    /// halves, the idiom for building a 64-bit value/address - unrelated
    /// to f16 packing) keeps the bitwise `BinOp` pack instead.
    PackHalves {
        dst: RegId,
        lo: Operand,
        hi: Operand,
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

    // =========================================================================
    // Tensor Core
    // =========================================================================
    /// Cooperative matrix load from shared memory (ldmatrix.sync)
    Ldmatrix {
        dst: Vec<RegId>,
        addr: Operand,
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
    BinOp,
    UnaryOp,
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
    CvtPackHalves,
    UnpackHalves,
    PackHalves,
    Bra,
    Ret,
    Exit,
    BarSync,
    BarWarpSync,
    Membar,
    CpAsyncCommitGroup,
    CpAsyncWaitGroup,
    Shfl,
    ShflSync,
    Ldmatrix,
    Mma,
    WmmaLoad,
    WmmaStore,
    WmmaMma,
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

            // Arithmetic
            Self::BinOp { src_a, src_b, .. } => from_ops(&[*src_a, *src_b]),
            Self::UnaryOp { src, .. } => from_op(src).into_iter().collect(),
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
            Self::CvtPackHalves { src_hi, src_lo, .. } => from_ops(&[*src_hi, *src_lo]),
            Self::UnpackHalves { src, .. } => from_op(src).into_iter().collect(),
            Self::PackHalves { lo, hi, .. } => from_ops(&[*lo, *hi]),

            // Control flow
            Self::Bra { .. } | Self::Ret | Self::Exit | Self::Trap | Self::Nop => vec![],

            // Warp queries
            Self::Activemask { .. } => vec![],

            // Synchronization
            Self::BarSync { .. } => vec![],
            Self::BarWarpSync { mask } => from_op(mask).into_iter().collect(),
            Self::Membar { .. } => vec![],
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
            | Self::BinOp { dst, .. }
            | Self::UnaryOp { dst, .. }
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
            | Self::CvtPackHalves { dst, .. }
            | Self::PackHalves { dst, .. }
            | Self::Activemask { dst } => vec![*dst],

            // Vector destinations
            Self::LoadVec { dst, .. }
            | Self::Ldmatrix { dst, .. }
            | Self::Mma { dst, .. }
            | Self::WmmaLoad { dst, .. }
            | Self::WmmaMma { dst, .. } => dst.clone(),

            // Shuffle: dst + optional dst_pred
            Self::Shfl { dst, dst_pred, .. } | Self::ShflSync { dst, dst_pred, .. } => {
                let mut r = vec![*dst];
                if let Some(p) = dst_pred {
                    r.push(*p);
                }
                r
            }

            // Unpack: two destinations
            Self::UnpackHalves { lo, hi, .. } => vec![*lo, *hi],

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
            | Self::CpAsyncCommitGroup
            | Self::CpAsyncWaitGroup { .. }
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
