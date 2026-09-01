//! Instruction parsing module
//!
//! This module provides parsing functions to convert unparsed instructions
//! (with raw modifier strings) into strongly-typed instruction structures.

use crate::ascii::{AsciiChar, AsciiSliceExt, AsciiString, ascii};
use crate::ast::*;
use crate::instr::InstrKind;
use crate::lex::DottedIdent;

/// Destructure the operand list into exactly `N` operands, or return the
/// arity error. `N` is inferred from the destructuring pattern:
/// `let [dst, a, b] = expect_operands(operands)?;` -- the check and the
/// extraction cannot drift apart.
fn expect_operands<const N: usize>(
    operands: Vec<Operand>,
) -> Result<[Operand; N], InstrParseError> {
    let got = operands.len();
    operands
        .try_into()
        .map_err(|_| InstrParseError::WrongOperandCount { expected: N, got })
}

/// Error type for instruction parsing
#[derive(Debug, Clone, PartialEq)]
pub enum InstrParseError {
    MissingModifier(&'static [AsciiChar]),
    InvalidModifier(AsciiString),
    MissingType,
    InvalidType(AsciiString),
    InvalidTypeForInstruction(ScalarType),
    WrongOperandCount {
        expected: usize,
        got: usize,
    },
    UnexpectedModifier(AsciiString),
    /// A `::`-qualified modifier (e.g. `shared::cta`, `L2::cache_hint`) that
    /// the parser does not understand. These used to be skipped silently,
    /// which could drop an explicit state space.
    QualifiedModifier(AsciiString),
    InvalidModifierForType {
        modifier: &'static str,
        ty: ScalarType,
    },
    ModifierRequiresModifier {
        modifier: &'static str,
        required: &'static str,
    },
}

impl InstrParseError {
    pub fn title(&self) -> &'static str {
        match self {
            InstrParseError::MissingModifier(_) => "Missing Modifier",
            InstrParseError::InvalidModifier(_) => "Invalid Modifier",
            InstrParseError::MissingType => "Missing Type",
            InstrParseError::InvalidType(_) => "Invalid Type",
            InstrParseError::InvalidTypeForInstruction(_) => "Invalid Type for Instruction",
            InstrParseError::WrongOperandCount { .. } => "Wrong Operand Count",
            InstrParseError::UnexpectedModifier(_) => "Unexpected Modifier",
            InstrParseError::QualifiedModifier(_) => "Unsupported Qualified Modifier",
            InstrParseError::InvalidModifierForType { .. } => "Invalid Modifier for Type",
            InstrParseError::ModifierRequiresModifier { .. } => "Missing Required Modifier",
        }
    }

    pub fn message(&self) -> Option<String> {
        Some(match self {
            InstrParseError::MissingModifier(name) => {
                format!("Missing required modifier: .{}", name.as_str())
            }
            InstrParseError::InvalidModifier(name) => format!("Invalid modifier: .{}", name),
            InstrParseError::MissingType => "Missing type.".to_string(),
            InstrParseError::InvalidType(name) => format!("Invalid type: .{}", name),
            InstrParseError::InvalidTypeForInstruction(ty) => {
                format!("Invalid type for instruction: {:?}", ty)
            }
            InstrParseError::WrongOperandCount { expected, got } => {
                format!(
                    "Wrong number of operands: expected {}, got {}",
                    expected, got
                )
            }
            InstrParseError::UnexpectedModifier(name) => format!("Unexpected modifier: .{}", name),
            InstrParseError::QualifiedModifier(name) => {
                format!("::-qualified modifier not supported: .{}", name)
            }
            InstrParseError::InvalidModifierForType { modifier, ty } => {
                format!("Modifier '.{}' not valid for type .{:?}", modifier, ty)
            }
            InstrParseError::ModifierRequiresModifier { modifier, required } => {
                format!("Modifier '.{}' requires modifier '.{}'", modifier, required)
            }
        })
    }
}

/// Rejects a modifier if it is set, returning an `InvalidModifierForType` error.
macro_rules! reject_modifier {
    ($flag:ident, $ty:expr) => {
        if $flag {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: stringify!($flag),
                ty: $ty,
            });
        }
    };
    ($flag:ident, $name:literal, $ty:expr) => {
        if $flag {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: $name,
                ty: $ty,
            });
        }
    };
}

/// Helper struct to consume modifiers during parsing
pub struct ModifierParser {
    modifiers: Vec<DottedIdent>,
    pos: usize,
}

impl ModifierParser {
    pub fn new(modifiers: Vec<DottedIdent>) -> Self {
        Self { modifiers, pos: 0 }
    }

    /// Peek at the current modifier without consuming it
    pub fn peek(&self) -> Option<&DottedIdent> {
        self.modifiers.get(self.pos)
    }

    /// Peek at the current modifier as a simple string (returns None if qualified)
    pub fn peek_simple(&self) -> Option<&AsciiString> {
        match self.peek() {
            Some(DottedIdent::Simple(s)) => Some(s),
            _ => None,
        }
    }

    /// Consume and return the current modifier
    #[allow(clippy::should_implement_trait)] // cursor over modifiers, not an Iterator
    pub fn next(&mut self) -> Option<DottedIdent> {
        if self.pos < self.modifiers.len() {
            let m = self.modifiers[self.pos].clone();
            self.pos += 1;
            Some(m)
        } else {
            None
        }
    }

    /// Try to consume a simple modifier if it matches the given value
    #[must_use]
    pub fn try_consume(&mut self, value: &'static [AsciiChar]) -> bool {
        if let Some(m) = self.peek_simple()
            && m.as_slice() == value
        {
            self.pos += 1;
            return true;
        }
        false
    }

    /// Try to consume a simple modifier if it matches the given value
    /// Consume the common `{.ftz}{.sat}` float-modifier pair.
    pub fn ftz_sat(&mut self) -> (bool, bool) {
        (
            self.try_consume(ascii("ftz")),
            self.try_consume(ascii("sat")),
        )
    }

    pub fn try_consume_or_err(
        &mut self,
        value: &'static [AsciiChar],
    ) -> Result<(), InstrParseError> {
        if let Some(m) = self.peek_simple()
            && m.as_slice() == value
        {
            self.pos += 1;
            return Ok(());
        }
        Err(InstrParseError::MissingModifier(value))
    }

    /// Try to parse a value of type `T` from the current modifier position.
    /// If successful, advances the position and returns the parsed value.
    pub fn try_parse<T: FromAscii>(&mut self) -> Option<T> {
        if let Some(m) = self.peek_simple()
            && let Some(val) = T::from_ascii(m)
        {
            self.pos += 1;
            return Some(val);
        }
        None
    }

    /// Parse a required scalar type
    pub fn require_scalar_type(&mut self) -> Result<ScalarType, InstrParseError> {
        self.try_parse::<ScalarType>()
            .ok_or(InstrParseError::MissingType)
    }

    /// Consume any run of cache performance-hint qualifiers (eviction
    /// priorities, prefetch sizes) at the current position, ignoring them.
    /// Anything else `::`-qualified - notably `L2::cache_hint`, which
    /// requires a cache-policy operand we do not parse - is left in place
    /// for `reject_qualified` to error on.
    pub fn skip_cache_perf_hints(&mut self) {
        while matches!(self.peek(), Some(DottedIdent::Qualified(parts)) if is_cache_perf_hint(parts))
        {
            self.pos += 1;
        }
    }

    /// Reject any `::`-qualified modifier at the current position (like
    /// `shared::cta` or `L2::cache_hint`). These were once skipped silently,
    /// which could drop an explicit state space and misdirect the access;
    /// unmodeled semantics must error loudly instead.
    pub fn reject_qualified(&self) -> Result<(), InstrParseError> {
        if let Some(DottedIdent::Qualified(parts)) = self.peek() {
            return Err(InstrParseError::QualifiedModifier(crate::ascii::join(
                parts,
                ascii("::"),
            )));
        }
        Ok(())
    }

    /// Check if all modifiers have been consumed
    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.pos >= self.modifiers.len()
    }

    /// Get remaining modifiers
    #[must_use]
    pub fn remaining(&self) -> &[DottedIdent] {
        &self.modifiers[self.pos..]
    }

    /// Finish parsing and ensure all modifiers were consumed.
    /// Returns an error if there are any remaining unconsumed modifiers.
    pub fn finish(&self) -> Result<(), InstrParseError> {
        if let Some(m) = self.modifiers.get(self.pos) {
            let s = match m {
                DottedIdent::Simple(s) => s.clone(),
                DottedIdent::Qualified(parts) => {
                    // Format as "a::b::c"
                    crate::ascii::join(parts, ascii("::"))
                }
            };
            Err(InstrParseError::UnexpectedModifier(s))
        } else {
            Ok(())
        }
    }
}

/// Whether a `::`-qualified modifier (split at `::`) is a cache-control
/// qualifier that is a pure performance hint taking no extra operand, and
/// can therefore be accepted and ignored on `ld`, `st`, and
/// `ld.global.nc`: the eviction priorities (PTX ISA 9.7.9.2: "Cache
/// eviction priority on load or store instructions is treated as a
/// performance hint") and the prefetch sizes ("The .level::prefetch_size
/// qualifier is treated as a performance hint only"). The sets are the
/// spec's exact enumerations - note L2 eviction is narrower than L1's.
/// `L2::cache_hint` is deliberately excluded: it requires an additional
/// cache-policy operand that we do not parse.
pub fn is_cache_perf_hint(parts: &[AsciiString]) -> bool {
    let [level, hint] = parts else {
        return false;
    };
    match level.as_bytes() {
        // .level1::eviction_priority
        b"L1" => matches!(
            hint.as_bytes(),
            b"evict_normal" | b"evict_unchanged" | b"evict_first" | b"evict_last" | b"no_allocate"
        ),
        b"L2" => matches!(
            hint.as_bytes(),
            // .level2::eviction_priority
            b"evict_normal" | b"evict_first" | b"evict_last"
            // .level::prefetch_size
            | b"64B" | b"128B" | b"256B"
        ),
        _ => false,
    }
}

/// Parse an instruction from its kind, modifiers, and operands
pub fn parse_instruction(
    kind: InstrKind,
    modifiers: Vec<DottedIdent>,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mut mp = ModifierParser::new(modifiers.clone());

    match kind {
        // =====================================================================
        // Integer Arithmetic (Blocks 1-11)
        // =====================================================================
        InstrKind::Add => parse_add(&mut mp, operands),
        InstrKind::Sub => parse_sub(&mut mp, operands),
        InstrKind::Mul => parse_mul(&mut mp, operands),
        InstrKind::Mad => parse_mad(&mut mp, operands),
        InstrKind::Mul24 => parse_mul24(&mut mp, operands),
        InstrKind::Mad24 => parse_mad24(&mut mp, operands),
        InstrKind::Sad => parse_sad(&mut mp, operands),
        InstrKind::Div => parse_div(&mut mp, operands),
        InstrKind::Rem => parse_rem(&mut mp, operands),
        InstrKind::Abs => parse_abs(&mut mp, operands),
        InstrKind::Neg => parse_neg(&mut mp, operands),
        InstrKind::Min => parse_min(&mut mp, operands),
        InstrKind::Max => parse_max(&mut mp, operands),

        // =====================================================================
        // Bit Manipulation (Blocks 14-24)
        // =====================================================================
        InstrKind::Popc => parse_popc(&mut mp, operands),
        InstrKind::Clz => parse_clz(&mut mp, operands),
        InstrKind::Bfind => parse_bfind(&mut mp, operands),
        InstrKind::Fns => parse_fns(&mut mp, operands),
        InstrKind::Brev => parse_brev(&mut mp, operands),
        InstrKind::Bfe => parse_bfe(&mut mp, operands),
        InstrKind::Bfi => parse_bfi(&mut mp, operands),
        InstrKind::Szext => parse_szext(&mut mp, operands),
        InstrKind::Bmsk => parse_bmsk(&mut mp, operands),
        InstrKind::Dp4a => parse_dp4a(&mut mp, operands),
        InstrKind::Dp2a => parse_dp2a(&mut mp, operands),

        // =====================================================================
        // Extended-Precision Arithmetic (Blocks 25-30)
        // =====================================================================
        InstrKind::AddCc => parse_add_cc(&mut mp, operands),
        InstrKind::Addc => parse_addc(&mut mp, operands),
        InstrKind::SubCc => parse_sub_cc(&mut mp, operands),
        InstrKind::Subc => parse_subc(&mut mp, operands),
        InstrKind::MadCc => parse_mad_cc(&mut mp, operands),
        InstrKind::Madc => parse_madc(&mut mp, operands),

        // =====================================================================
        // Floating-Point (Blocks 31-52)
        // =====================================================================
        InstrKind::Testp => parse_testp(&mut mp, operands),
        InstrKind::Copysign => parse_copysign(&mut mp, operands),
        InstrKind::Fma => parse_fma(&mut mp, operands),
        InstrKind::Rcp => parse_rcp(&mut mp, operands),
        InstrKind::Sqrt => parse_sqrt(&mut mp, operands),
        InstrKind::Rsqrt => parse_rsqrt(&mut mp, operands),
        InstrKind::Sin => parse_sin(&mut mp, operands),
        InstrKind::Cos => parse_cos(&mut mp, operands),
        InstrKind::Lg2 => parse_lg2(&mut mp, operands),
        InstrKind::Ex2 => parse_ex2(&mut mp, operands),
        InstrKind::Tanh => parse_tanh(&mut mp, operands),

        // =====================================================================
        // Comparison and Selection (Blocks 66-71)
        // =====================================================================
        InstrKind::Set => parse_set(&mut mp, operands),
        InstrKind::Setp => parse_setp(&mut mp, operands),
        InstrKind::Selp => parse_selp(&mut mp, operands),
        InstrKind::Slct => parse_slct(&mut mp, operands),

        // =====================================================================
        // Logic and Shift (Blocks 72-85)
        // =====================================================================
        InstrKind::And => parse_logic(&mut mp, operands, InstrKind::And),
        InstrKind::Or => parse_logic(&mut mp, operands, InstrKind::Or),
        InstrKind::Xor => parse_logic(&mut mp, operands, InstrKind::Xor),
        InstrKind::Not => parse_not(&mut mp, operands),
        InstrKind::Cnot => parse_cnot(&mut mp, operands),
        InstrKind::Lop3 => parse_lop3(&mut mp, operands),
        InstrKind::Shf => parse_shf(&mut mp, operands),
        InstrKind::Shl => parse_shift(&mut mp, operands, InstrKind::Shl),
        InstrKind::Shr => parse_shift(&mut mp, operands, InstrKind::Shr),

        // =====================================================================
        // Data Movement (Blocks 81-102)
        // =====================================================================
        InstrKind::Mov => parse_mov(&mut mp, operands),
        InstrKind::Shfl => parse_shfl(&mut mp, operands),
        InstrKind::ShflSync => parse_shfl_sync(&mut mp, operands),
        InstrKind::Prmt => parse_prmt(&mut mp, operands),
        InstrKind::Ld => parse_ld(&mut mp, operands),
        InstrKind::Ldu => parse_ldu(&mut mp, operands),
        InstrKind::St => parse_st(&mut mp, operands),
        InstrKind::CpAsync => parse_cp_async(&mut mp, operands),
        InstrKind::CpAsyncCommitGroup => parse_cp_async_commit_group(&mut mp, operands),
        InstrKind::CpAsyncWaitGroup => parse_cp_async_wait_group(&mut mp, operands),
        InstrKind::CpAsyncWaitAll => parse_cp_async_wait_all(&mut mp, operands),
        InstrKind::Cvt => parse_cvt(&mut mp, operands),
        InstrKind::Cvta => parse_cvta(&mut mp, operands),
        InstrKind::Isspacep => parse_isspacep(&mut mp, operands),
        InstrKind::Mapa => parse_mapa(&mut mp, operands),
        InstrKind::Getctarank => parse_getctarank(&mut mp, operands),

        // =====================================================================
        // Control Flow (Blocks 127-131)
        // =====================================================================
        InstrKind::Bra => parse_bra(&mut mp, operands),
        InstrKind::BrxIdx => parse_brx_idx(&mut mp, operands),
        InstrKind::Call => parse_call(&mut mp, operands),
        InstrKind::Ret => parse_ret(&mut mp),
        InstrKind::Exit => Ok(ParsedInstruction::Exit),

        // =====================================================================
        // Synchronization (Blocks 132-145)
        // =====================================================================
        InstrKind::Bar => parse_bar(&mut mp, operands),
        InstrKind::Barrier => parse_barrier(&mut mp, operands),
        InstrKind::BarWarpSync => parse_bar_warp_sync(&mut mp, operands),
        InstrKind::BarrierCluster => parse_barrier_cluster(&mut mp, operands),
        InstrKind::Membar => parse_membar(&mut mp, operands),
        InstrKind::Fence => parse_fence(&mut mp, operands),
        InstrKind::Atom => parse_atom(&mut mp, operands),
        InstrKind::Red => parse_red(&mut mp, operands),
        InstrKind::Vote => parse_vote(&mut mp, operands),
        InstrKind::VoteSync => parse_vote_sync(&mut mp, operands),
        InstrKind::MatchSync => parse_match_sync(&mut mp, operands),
        InstrKind::Activemask => parse_activemask(&mut mp, operands),
        InstrKind::ReduxSync => parse_redux_sync(&mut mp, operands),
        InstrKind::Griddepcontrol => parse_griddepcontrol(&mut mp, operands),
        InstrKind::ElectSync => parse_elect_sync(&mut mp, operands),

        // =====================================================================
        // Mbarrier (Blocks 146-154)
        // =====================================================================
        InstrKind::MbarrierInit => parse_mbarrier_init(&mut mp, operands),
        InstrKind::MbarrierInval => parse_mbarrier_inval(&mut mp, operands),
        InstrKind::MbarrierExpectTx => parse_mbarrier_expect_tx(&mut mp, operands),
        InstrKind::MbarrierCompleteTx => parse_mbarrier_complete_tx(&mut mp, operands),
        InstrKind::MbarrierArrive => parse_mbarrier_arrive(&mut mp, operands),
        InstrKind::MbarrierArriveDrop => parse_mbarrier_arrive_drop(&mut mp, operands),
        InstrKind::MbarrierTestWait | InstrKind::MbarrierTryWait => {
            parse_mbarrier_wait(&mut mp, operands, kind)
        }
        InstrKind::MbarrierPendingCount => parse_mbarrier_pending_count(&mut mp, operands),

        // =====================================================================
        // Stack (Blocks 183-185)
        // =====================================================================
        InstrKind::Stacksave => parse_stacksave(&mut mp, operands),
        InstrKind::Stackrestore => parse_stackrestore(&mut mp, operands),
        InstrKind::Alloca => parse_alloca(&mut mp, operands),

        // =====================================================================
        // Miscellaneous (Blocks 194-198)
        // =====================================================================
        InstrKind::Brkpt => Ok(ParsedInstruction::Brkpt),
        InstrKind::Nanosleep => parse_nanosleep(&mut mp, operands),
        InstrKind::Pmevent => parse_pmevent(&mut mp, operands),
        InstrKind::Trap => Ok(ParsedInstruction::Trap),
        InstrKind::Setmaxnreg => parse_setmaxnreg(&mut mp, operands),

        // =====================================================================
        // Other instructions -> use Other variant
        // =====================================================================
        _ => Ok(ParsedInstruction::Other {
            kind,
            modifiers,
            operands,
        }),
    }
}

// =============================================================================
// Integer Arithmetic Instruction Parsers
// =============================================================================

/// Parse add instruction (Blocks 1, 33, 53, 63)
/// Block 1: add.type / add{.sat}.s32 (sat ONLY for s32)
/// Block 33: add{.rnd}{.ftz}{.sat}.f32 / add{.rnd}{.ftz}.f32x2 / add{.rnd}.f64
/// Block 53: add{.rnd}{.ftz}{.sat}.f16/f16x2 / add{.rnd}.bf16/bf16x2
/// Block 63: add{.rnd}{.sat}.f32.atype (NO ftz for mixed precision)
fn parse_add(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let rnd = mp.try_parse::<FpRound>();
    let (ftz, sat) = mp.ftz_sat();
    let ty = mp.require_scalar_type()?;
    // For mixed precision (Block 63): add{.rnd}{.sat}.f32.atype
    let src_type = mp.try_parse::<ScalarType>();

    let [dst, src_a, src_b] = expect_operands(operands)?;

    // Mixed precision (Block 63): add{.rnd}{.sat}.f32.src_type - NO ftz allowed
    if let Some(src_type) = src_type {
        reject_modifier!(ftz, src_type);
        mp.finish()?;
        return Ok(ParsedInstruction::Add(AddInstr::MixedPrecision {
            rnd,
            sat,
            src_type,
            dst,
            src_a,
            src_b,
        }));
    }

    let instr = match ty {
        // Integer types without sat support (Block 1) - NO ftz, NO sat
        ScalarType::U16
        | ScalarType::U32
        | ScalarType::U64
        | ScalarType::S16
        | ScalarType::S64
        | ScalarType::U16x2
        | ScalarType::S16x2 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            AddInstr::Integer {
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // s32 supports sat (Block 1) - NO ftz
        ScalarType::S32 => {
            reject_modifier!(ftz, ty);
            AddInstr::IntegerSat {
                sat,
                dst,
                src_a,
                src_b,
            }
        }

        // Float32 (Block 33): add{.rnd}{.ftz}{.sat}.f32 - all allowed
        ScalarType::F32 => AddInstr::Float32 {
            rnd,
            ftz,
            sat,
            dst,
            src_a,
            src_b,
        },

        // Float32x2 (Block 33): add{.rnd}{.ftz}.f32x2 - NO sat
        ScalarType::F32x2 => {
            reject_modifier!(sat, ty);
            AddInstr::Float32x2 {
                rnd,
                ftz,
                dst,
                src_a,
                src_b,
            }
        }

        // Float64 (Block 33): add{.rnd}.f64 - NO ftz, NO sat
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            AddInstr::Float64 {
                rnd,
                dst,
                src_a,
                src_b,
            }
        }

        // Half f16/f16x2 (Block 53): add{.rnd}{.ftz}{.sat}.f16 - all allowed
        ScalarType::F16 | ScalarType::F16x2 => AddInstr::HalfF16 {
            rnd,
            ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
        },

        // Half bf16/bf16x2 (Block 53): add{.rnd}.bf16 - NO ftz, NO sat
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            AddInstr::HalfBf16 {
                rnd,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Add(instr))
}

/// Parse sub instruction (Blocks 2, 34, 54, 64)
/// Block 2: sub.type / sub{.sat}.s32 (sat ONLY for s32)
/// Block 34: sub{.rnd}{.ftz}{.sat}.f32 / sub{.rnd}{.ftz}.f32x2 / sub{.rnd}.f64
/// Block 54: sub{.rnd}{.ftz}{.sat}.f16/f16x2 / sub{.rnd}.bf16/bf16x2
/// Block 64: sub{.rnd}{.sat}.f32.atype (NO ftz for mixed precision)
fn parse_sub(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let rnd = mp.try_parse::<FpRound>();
    let (ftz, sat) = mp.ftz_sat();
    let ty = mp.require_scalar_type()?;
    // For mixed precision (Block 64): sub{.rnd}{.sat}.f32.atype
    let src_type = mp.try_parse::<ScalarType>();

    let [dst, src_a, src_b] = expect_operands(operands)?;

    // Mixed precision (Block 64): sub{.rnd}{.sat}.f32.src_type - NO ftz allowed
    if let Some(src_type) = src_type {
        reject_modifier!(ftz, src_type);
        mp.finish()?;
        return Ok(ParsedInstruction::Sub(SubInstr::MixedPrecision {
            rnd,
            sat,
            src_type,
            dst,
            src_a,
            src_b,
        }));
    }

    let instr = match ty {
        // Integer types without sat support (Block 2) - NO ftz, NO sat
        ScalarType::U16 | ScalarType::U32 | ScalarType::U64 | ScalarType::S16 | ScalarType::S64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            SubInstr::Integer {
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // s32 supports sat (Block 2) - NO ftz
        ScalarType::S32 => {
            reject_modifier!(ftz, ty);
            SubInstr::IntegerSat {
                sat,
                dst,
                src_a,
                src_b,
            }
        }

        // Float32 (Block 34): sub{.rnd}{.ftz}{.sat}.f32 - all allowed
        ScalarType::F32 => SubInstr::Float32 {
            rnd,
            ftz,
            sat,
            dst,
            src_a,
            src_b,
        },

        // Float32x2 (Block 34): sub{.rnd}{.ftz}.f32x2 - NO sat
        ScalarType::F32x2 => {
            reject_modifier!(sat, ty);
            SubInstr::Float32x2 {
                rnd,
                ftz,
                dst,
                src_a,
                src_b,
            }
        }

        // Float64 (Block 34): sub{.rnd}.f64 - NO ftz, NO sat
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            SubInstr::Float64 {
                rnd,
                dst,
                src_a,
                src_b,
            }
        }

        // Half f16/f16x2 (Block 54): sub{.rnd}{.ftz}{.sat}.f16 - all allowed
        ScalarType::F16 | ScalarType::F16x2 => SubInstr::HalfF16 {
            rnd,
            ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
        },

        // Half bf16/bf16x2 (Block 54): sub{.rnd}.bf16 - NO ftz, NO sat
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            SubInstr::HalfBf16 {
                rnd,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Sub(instr))
}

/// Parse mul instruction (Block 3 for integer, Block 35 for float, Block 55 for half)
/// Block 3: mul.mode.type (integer - mode required, NO ftz/sat)
/// Block 35: mul{.rnd}{.ftz}{.sat}.f32 / mul{.rnd}{.ftz}.f32x2 / mul{.rnd}.f64
/// Block 55: mul{.rnd}{.ftz}{.sat}.f16/f16x2 / mul{.rnd}.bf16/bf16x2
fn parse_mul(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    // Try FP modifiers first
    let rnd = mp.try_parse::<FpRound>();
    let (ftz, sat) = mp.ftz_sat();

    // Try integer mul mode
    let mode = mp.try_parse::<MulMode>();

    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    let instr = if let Some(mode) = mode {
        // Integer multiply (Block 3): mul.mode.type - NO ftz, NO sat
        reject_modifier!(ftz, ty);
        reject_modifier!(sat, ty);
        MulInstr::Integer {
            mode,
            ty,
            dst,
            src_a,
            src_b,
        }
    } else {
        // Float multiply - validate by type
        match ty {
            // Float32 (Block 35): mul{.rnd}{.ftz}{.sat}.f32 - all allowed
            ScalarType::F32 => MulInstr::Float {
                rnd,
                ftz,
                sat,
                ty,
                dst,
                src_a,
                src_b,
            },

            // Float32x2 (Block 35): mul{.rnd}{.ftz}.f32x2 - NO sat
            ScalarType::F32x2 => {
                reject_modifier!(sat, ty);
                MulInstr::Float {
                    rnd,
                    ftz,
                    sat: false,
                    ty,
                    dst,
                    src_a,
                    src_b,
                }
            }

            // Float64 (Block 35): mul{.rnd}.f64 - NO ftz, NO sat
            ScalarType::F64 => {
                reject_modifier!(ftz, ty);
                reject_modifier!(sat, ty);
                MulInstr::Float {
                    rnd,
                    ftz: false,
                    sat: false,
                    ty,
                    dst,
                    src_a,
                    src_b,
                }
            }

            // Half f16/f16x2 (Block 55): mul{.rnd}{.ftz}{.sat}.f16 - all allowed
            ScalarType::F16 | ScalarType::F16x2 => MulInstr::Float {
                rnd,
                ftz,
                sat,
                ty,
                dst,
                src_a,
                src_b,
            },

            // Half bf16/bf16x2 (Block 55): mul{.rnd}.bf16 - NO ftz, NO sat
            ScalarType::Bf16 | ScalarType::Bf16x2 => {
                reject_modifier!(ftz, ty);
                reject_modifier!(sat, ty);
                MulInstr::Float {
                    rnd,
                    ftz: false,
                    sat: false,
                    ty,
                    dst,
                    src_a,
                    src_b,
                }
            }

            _ => {
                return Err(InstrParseError::InvalidTypeForInstruction(ty));
            }
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Mul(instr))
}

/// Parse mad instruction (Block 4 for integer, Block 37 for float)
/// Block 4: mad.mode.type / mad.hi.sat.s32 (sat ONLY for hi+s32)
/// Block 37: mad{.ftz}{.sat}.f32 / mad.rnd{.ftz}{.sat}.f32 / mad.rnd.f64
fn parse_mad(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    // Try FP modifiers
    let rnd = mp.try_parse::<FpRound>();
    let (ftz, sat) = mp.ftz_sat();

    // Try integer mode
    let mode = mp.try_parse::<MulMode>();

    // Check for sat after mode (mad.hi.sat.s32)
    let sat = sat || mp.try_consume(ascii("sat"));

    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    let instr = if let Some(mode) = mode {
        // Integer mad (Block 4): mad.mode{.sat}.type
        // NO ftz allowed for integer
        reject_modifier!(ftz, ty);
        // sat only allowed for mad.hi.sat.s32
        if sat && !(mode == MulMode::Hi && ty == ScalarType::S32) {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "sat",
                ty,
            });
        }
        MadInstr::Integer {
            mode,
            sat,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        }
    } else {
        // Float mad (Block 37) - validate by type
        match ty {
            // Float32: mad{.ftz}{.sat}.f32 or mad.rnd{.ftz}{.sat}.f32 - all allowed
            ScalarType::F32 => MadInstr::Float {
                rnd,
                ftz,
                sat,
                ty,
                dst,
                src_a,
                src_b,
                src_c,
            },

            // Float64: mad.rnd.f64 - NO ftz, NO sat
            ScalarType::F64 => {
                reject_modifier!(ftz, ty);
                reject_modifier!(sat, ty);
                MadInstr::Float {
                    rnd,
                    ftz: false,
                    sat: false,
                    ty,
                    dst,
                    src_a,
                    src_b,
                    src_c,
                }
            }

            _ => {
                return Err(InstrParseError::InvalidTypeForInstruction(ty));
            }
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Mad(instr))
}

/// Parse mul24 instruction (Block 5)
fn parse_mul24(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<MulMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Mul24(Mul24Instr {
        mode,
        ty,
        dst,
        src_a,
        src_b,
    }))
}

/// Parse mad24 instruction (Block 6)
/// Block 6: mad24.mode.type / mad24.hi.sat.s32 (sat ONLY for hi mode)
fn parse_mad24(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<MulMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    let sat = mp.try_consume(ascii("sat"));
    let ty = mp.require_scalar_type()?;

    // sat only allowed for mad24.hi.sat.s32
    if sat && mode != MulMode::Hi {
        return Err(InstrParseError::ModifierRequiresModifier {
            modifier: "sat",
            required: "hi",
        });
    }

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Mad24(Mad24Instr {
        mode,
        sat,
        ty,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

/// Parse sad instruction (Block 7)
fn parse_sad(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Sad(SadInstr {
        ty,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

/// Parse div instruction (Blocks 8, 38)
/// Block 8: div.type (integer) - NO ftz
/// Block 38: div.approx{.ftz}.f32 / div.full{.ftz}.f32 / div.rnd{.ftz}.f32 / div.rnd.f64 (NO ftz)
fn parse_div(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let approx = mp.try_consume(ascii("approx"));
    let full = mp.try_consume(ascii("full"));
    let rnd = mp.try_parse::<FpRound>();
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    let instr = if approx {
        // div.approx{.ftz}.f32 - ftz only for f32
        if ftz && ty != ScalarType::F32 {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "ftz",
                ty,
            });
        }
        DivInstr::Approx {
            ftz,
            dst,
            src_a,
            src_b,
        }
    } else if full {
        // div.full{.ftz}.f32 - ftz only for f32
        if ftz && ty != ScalarType::F32 {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "ftz",
                ty,
            });
        }
        DivInstr::Full {
            ftz,
            dst,
            src_a,
            src_b,
        }
    } else if let Some(rnd) = rnd {
        // div.rnd{.ftz}.f32 or div.rnd.f64 - NO ftz for f64
        if ftz && ty == ScalarType::F64 {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "ftz",
                ty,
            });
        }
        DivInstr::Ieee {
            rnd,
            ftz,
            ty,
            dst,
            src_a,
            src_b,
        }
    } else {
        // div.type (integer) - NO ftz
        reject_modifier!(ftz, ty);
        DivInstr::Integer {
            ty,
            dst,
            src_a,
            src_b,
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Div(instr))
}

/// Parse rem instruction (Block 9)
fn parse_rem(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Rem(RemInstr {
        ty,
        dst,
        src_a,
        src_b,
    }))
}

/// Parse abs instruction (Blocks 10, 39, 58)
/// Block 10: abs.type (integer) - NO ftz
/// Block 39: abs{.ftz}.f32 / abs.f64 (NO ftz for f64)
/// Block 58: abs{.ftz}.f16/f16x2 / abs.bf16/bf16x2 (NO ftz for bf16)
fn parse_abs(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    let instr = match ty {
        // Integer types (Block 10) - NO ftz
        ScalarType::S16 | ScalarType::S32 | ScalarType::S64 => {
            reject_modifier!(ftz, ty);
            AbsInstr::Integer { ty, dst, src }
        }

        // Float32 (Block 39): abs{.ftz}.f32 - ftz allowed
        ScalarType::F32 => AbsInstr::Float32 { ftz, dst, src },

        // Float64 (Block 39): abs.f64 - NO ftz
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            AbsInstr::Float64 { dst, src }
        }

        // Half f16/f16x2 (Block 58): abs{.ftz}.f16 - ftz allowed
        ScalarType::F16 | ScalarType::F16x2 => AbsInstr::HalfF16 { ftz, ty, dst, src },

        // Half bf16/bf16x2 (Block 58): abs.bf16 - NO ftz
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            AbsInstr::HalfBf16 { ty, dst, src }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Abs(instr))
}

/// Parse neg instruction (Blocks 11, 40, 57)
/// Block 11: neg.type (integer) - NO ftz
/// Block 40: neg{.ftz}.f32 / neg.f64 (NO ftz for f64)
/// Block 57: neg{.ftz}.f16/f16x2 / neg.bf16/bf16x2 (NO ftz for bf16)
fn parse_neg(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    let instr = match ty {
        // Integer types (Block 11) - NO ftz
        ScalarType::S16 | ScalarType::S32 | ScalarType::S64 => {
            reject_modifier!(ftz, ty);
            NegInstr::Integer { ty, dst, src }
        }

        // Float32 (Block 40): neg{.ftz}.f32 - ftz allowed
        ScalarType::F32 => NegInstr::Float32 { ftz, dst, src },

        // Float64 (Block 40): neg.f64 - NO ftz
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            NegInstr::Float64 { dst, src }
        }

        // Half f16/f16x2 (Block 57): neg{.ftz}.f16 - ftz allowed
        ScalarType::F16 | ScalarType::F16x2 => NegInstr::HalfF16 { ftz, ty, dst, src },

        // Half bf16/bf16x2 (Block 57): neg.bf16 - NO ftz
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            NegInstr::HalfBf16 { ty, dst, src }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Neg(instr))
}

/// Parse min instruction (Blocks 12, 41, 59)
/// Block 12: min.atype (NO relu) / min{.relu}.btype (btype = s16x2, s32)
/// Block 41: min{.ftz}{.NaN}{.xorsign.abs}.f32 / min.f64 (NO modifiers)
/// Block 59: min{.ftz}{.NaN}{.xorsign.abs}.f16/f16x2 / min{.NaN}{.xorsign.abs}.bf16 (NO ftz)
fn parse_min(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ftz = mp.try_consume(ascii("ftz"));
    let nan = mp.try_consume(ascii("NaN"));
    let xorsign = mp.try_consume(ascii("xorsign"));
    let abs = mp.try_consume(ascii("abs"));
    // relu can appear before or after the type (min.relu.s16x2 or min.s16x2.relu)
    let relu = mp.try_consume(ascii("relu"));

    let ty = mp.require_scalar_type()?;

    let relu = relu || mp.try_consume(ascii("relu"));

    let operand_count = operands.len();
    if operand_count < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operand_count,
        });
    }

    let mut ops = operands.into_iter();
    let dst = ops.next().unwrap();
    let src_a = ops.next().unwrap();
    let src_b = ops.next().unwrap();
    let src_c = ops.next();

    if ops.next().is_some() {
        return Err(InstrParseError::WrongOperandCount {
            expected: 4,
            got: operand_count,
        });
    }
    // Only the f32 form has a 3-input (accumulate) variant; for any other
    // type a 4th operand would previously be dropped silently.
    if src_c.is_some() && ty != ScalarType::F32 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operand_count,
        });
    }

    let instr = match ty {
        // Integer types that don't support relu (Block 12, atype) - NO modifiers
        ScalarType::U16
        | ScalarType::U32
        | ScalarType::U64
        | ScalarType::U16x2
        | ScalarType::S16
        | ScalarType::S64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(nan, "NaN", ty);
            reject_modifier!(xorsign, ty);
            reject_modifier!(abs, ty);
            reject_modifier!(relu, ty);
            MinInstr::Integer {
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // Integer types that support relu (Block 12, btype) - only relu allowed
        ScalarType::S16x2 | ScalarType::S32 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(nan, "NaN", ty);
            reject_modifier!(xorsign, ty);
            reject_modifier!(abs, ty);
            MinInstr::IntegerRelu {
                relu,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // Float32 (Block 41): min{.ftz}{.NaN}{.xorsign.abs}.f32 - all allowed
        ScalarType::F32 => {
            reject_modifier!(relu, ty);
            if let Some(src_c) = src_c {
                // 3-operand form: no xorsign
                reject_modifier!(xorsign, ty);
                MinInstr::Float32Acc {
                    ftz,
                    nan,
                    abs,
                    dst,
                    src_a,
                    src_b,
                    src_c,
                }
            } else {
                // 2-operand form: xorsign.abs or just abs
                MinInstr::Float32 {
                    ftz,
                    nan,
                    xorsign_abs: xorsign,
                    abs,
                    dst,
                    src_a,
                    src_b,
                }
            }
        }

        // Float64 (Block 41): min.f64 - NO modifiers at all
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(nan, "NaN", ty);
            reject_modifier!(xorsign, ty);
            reject_modifier!(abs, ty);
            reject_modifier!(relu, ty);
            MinInstr::Float64 { dst, src_a, src_b }
        }

        // Half f16/f16x2 (Block 59): min{.ftz}{.NaN}{.xorsign.abs}.f16 - all allowed
        ScalarType::F16 | ScalarType::F16x2 => {
            reject_modifier!(relu, ty);
            MinInstr::HalfF16 {
                ftz,
                nan,
                xorsign_abs: xorsign,
                abs,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // Half bf16/bf16x2 (Block 59): min{.NaN}{.xorsign.abs}.bf16 - NO ftz
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(relu, ty);
            MinInstr::HalfBf16 {
                nan,
                xorsign_abs: xorsign,
                abs,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Min(instr))
}

/// Parse max instruction (Blocks 13, 42, 60)
/// Block 13: max.atype (NO relu) / max{.relu}.btype (btype = s16x2, s32)
/// Block 42: max{.ftz}{.NaN}{.xorsign.abs}.f32 / max.f64 (NO modifiers)
/// Block 60: max{.ftz}{.NaN}{.xorsign.abs}.f16/f16x2 / max{.NaN}{.xorsign.abs}.bf16 (NO ftz)
fn parse_max(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ftz = mp.try_consume(ascii("ftz"));
    let nan = mp.try_consume(ascii("NaN"));
    let xorsign = mp.try_consume(ascii("xorsign"));
    let abs = mp.try_consume(ascii("abs"));
    // relu can appear before or after the type (max.relu.s16x2 or max.s16x2.relu)
    let relu = mp.try_consume(ascii("relu"));

    let ty = mp.require_scalar_type()?;

    let relu = relu || mp.try_consume(ascii("relu"));

    let operand_count = operands.len();
    if operand_count < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operand_count,
        });
    }

    let mut ops = operands.into_iter();
    let dst = ops.next().unwrap();
    let src_a = ops.next().unwrap();
    let src_b = ops.next().unwrap();
    let src_c = ops.next();

    if ops.next().is_some() {
        return Err(InstrParseError::WrongOperandCount {
            expected: 4,
            got: operand_count,
        });
    }
    // Only the f32 form has a 3-input (accumulate) variant; for any other
    // type a 4th operand would previously be dropped silently.
    if src_c.is_some() && ty != ScalarType::F32 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operand_count,
        });
    }

    let instr = match ty {
        // Integer types that don't support relu (Block 13, atype) - NO modifiers
        ScalarType::U16
        | ScalarType::U32
        | ScalarType::U64
        | ScalarType::U16x2
        | ScalarType::S16
        | ScalarType::S64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(nan, "NaN", ty);
            reject_modifier!(xorsign, ty);
            reject_modifier!(abs, ty);
            reject_modifier!(relu, ty);
            MaxInstr::Integer {
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // Integer types that support relu (Block 13, btype) - only relu allowed
        ScalarType::S16x2 | ScalarType::S32 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(nan, "NaN", ty);
            reject_modifier!(xorsign, ty);
            reject_modifier!(abs, ty);
            MaxInstr::IntegerRelu {
                relu,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // Float32 (Block 42): max{.ftz}{.NaN}{.xorsign.abs}.f32 - all allowed
        ScalarType::F32 => {
            reject_modifier!(relu, ty);
            if let Some(src_c) = src_c {
                // 3-operand form: no xorsign
                reject_modifier!(xorsign, ty);
                MaxInstr::Float32Acc {
                    ftz,
                    nan,
                    abs,
                    dst,
                    src_a,
                    src_b,
                    src_c,
                }
            } else {
                // 2-operand form: xorsign.abs or just abs
                MaxInstr::Float32 {
                    ftz,
                    nan,
                    xorsign_abs: xorsign,
                    abs,
                    dst,
                    src_a,
                    src_b,
                }
            }
        }

        // Float64 (Block 42): max.f64 - NO modifiers at all
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(nan, "NaN", ty);
            reject_modifier!(xorsign, ty);
            reject_modifier!(abs, ty);
            reject_modifier!(relu, ty);
            MaxInstr::Float64 { dst, src_a, src_b }
        }

        // Half f16/f16x2 (Block 60): max{.ftz}{.NaN}{.xorsign.abs}.f16 - all allowed
        ScalarType::F16 | ScalarType::F16x2 => {
            reject_modifier!(relu, ty);
            MaxInstr::HalfF16 {
                ftz,
                nan,
                xorsign_abs: xorsign,
                abs,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        // Half bf16/bf16x2 (Block 60): max{.NaN}{.xorsign.abs}.bf16 - NO ftz
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(relu, ty);
            MaxInstr::HalfBf16 {
                nan,
                xorsign_abs: xorsign,
                abs,
                ty,
                dst,
                src_a,
                src_b,
            }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Max(instr))
}

// =============================================================================
// Bit Manipulation Instruction Parsers
// =============================================================================

/// Parse popc instruction (Block 14)
fn parse_popc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Popc(PopcInstr { ty, dst, src }))
}

/// Parse clz instruction (Block 15)
fn parse_clz(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Clz(ClzInstr { ty, dst, src }))
}

/// Parse bfind instruction (Block 16)
fn parse_bfind(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let shiftamt = mp.try_consume(ascii("shiftamt"));
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Bfind(BfindInstr {
        shiftamt,
        ty,
        dst,
        src,
    }))
}

/// Parse fns instruction (Block 17)
fn parse_fns(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("b32"))?; // fns.b32 - type is required

    let [dst, mask, base, offset] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Fns(FnsInstr {
        dst,
        mask,
        base,
        offset,
    }))
}

/// Parse brev instruction (Block 18)
fn parse_brev(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Brev(BrevInstr { ty, dst, src }))
}

/// Parse bfe instruction (Block 19)
fn parse_bfe(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, start, len] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Bfe(BfeInstr {
        ty,
        dst,
        src_a,
        start,
        len,
    }))
}

/// Parse bfi instruction (Block 20)
fn parse_bfi(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b, start, len] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Bfi(BfiInstr {
        ty,
        dst,
        src_a,
        src_b,
        start,
        len,
    }))
}

/// Parse szext instruction (Block 21)
fn parse_szext(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<ClampWrapMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    let ty = mp.require_scalar_type()?;

    let [dst, src, pos] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Szext(SzextInstr {
        mode,
        ty,
        dst,
        src,
        pos,
    }))
}

/// Parse bmsk instruction (Block 22)
fn parse_bmsk(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<ClampWrapMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    mp.try_consume_or_err(ascii("b32"))?; // bmsk.mode.b32 - type is required

    let [dst, start, len] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Bmsk(BmskInstr {
        mode,
        dst,
        start,
        len,
    }))
}

/// Parse dp4a instruction (Block 23)
fn parse_dp4a(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let atype = mp.require_scalar_type()?;
    let btype = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Dp4a(Dp4aInstr {
        atype,
        btype,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

/// Parse dp2a instruction (Block 24)
fn parse_dp2a(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<MulMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    let atype = mp.require_scalar_type()?;
    let btype = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Dp2a(Dp2aInstr {
        mode,
        atype,
        btype,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

// =============================================================================
// Extended-Precision Arithmetic Parsers
// =============================================================================

/// Parse add.cc instruction (Block 25)
fn parse_add_cc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::AddCc(AddCcInstr {
        ty,
        dst,
        src_a,
        src_b,
    }))
}

/// Parse addc instruction (Block 26)
fn parse_addc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let cc = mp.try_consume(ascii("cc"));
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Addc(AddcInstr {
        cc,
        ty,
        dst,
        src_a,
        src_b,
    }))
}

/// Parse sub.cc instruction (Block 27)
fn parse_sub_cc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::SubCc(SubCcInstr {
        ty,
        dst,
        src_a,
        src_b,
    }))
}

/// Parse subc instruction (Block 28)
fn parse_subc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let cc = mp.try_consume(ascii("cc"));
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Subc(SubcInstr {
        cc,
        ty,
        dst,
        src_a,
        src_b,
    }))
}

/// Parse mad.cc instruction (Block 29)
fn parse_mad_cc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp.try_parse::<MulMode>();
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::MadCc(MadCcInstr {
        mode,
        ty,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

/// Parse madc instruction (Block 30)
fn parse_madc(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp.try_parse::<MulMode>();
    let cc = mp.try_consume(ascii("cc"));
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Madc(MadcInstr {
        mode,
        cc,
        ty,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

// =============================================================================
// Floating-Point Instruction Parsers
// =============================================================================

/// Parse testp instruction (Block 31)
fn parse_testp(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let op = mp
        .try_parse::<TestpOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("op")))?;
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Testp(TestpInstr { op, ty, dst, src }))
}

/// Parse copysign instruction (Block 32)
fn parse_copysign(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, magnitude, sign] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Copysign(CopysignInstr {
        ty,
        dst,
        magnitude,
        sign,
    }))
}

/// Parse fma instruction (Blocks 36, 56, 65)
/// Block 36: fma.rnd{.ftz}{.sat}.f32 / fma.rnd{.ftz}.f32x2 / fma.rnd.f64
/// Block 56: fma.rnd{.ftz}{.sat}.f16/f16x2 / fma.rnd{.ftz}.relu.f16/f16x2 / fma.rnd{.relu}.bf16/bf16x2
/// Block 65: fma.rnd{.sat}.f32.abtype for mixed precision (abtype = f16/bf16, NO ftz)
fn parse_fma(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let rnd = mp.try_parse::<FpRound>().unwrap_or(FpRound::Rn);
    let (ftz, sat) = mp.ftz_sat();
    let oob = mp.try_consume(ascii("oob"));
    let relu = mp.try_consume(ascii("relu"));
    let ty = mp.require_scalar_type()?;
    // For mixed precision (Block 65): fma.rnd{.sat}.f32.abtype
    let src_type = mp.try_parse::<ScalarType>();

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    // OOB mode (Block 56): fma.rnd.oob{.relu}.type for half types
    if oob {
        mp.finish()?;
        return Ok(ParsedInstruction::Fma(FmaInstr::Oob {
            rnd,
            relu,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        }));
    }

    // Mixed precision (Block 65): fma.rnd{.sat}.f32.src_type - NO ftz allowed
    if let Some(src_type) = src_type {
        reject_modifier!(ftz, src_type);
        mp.finish()?;
        return Ok(ParsedInstruction::Fma(FmaInstr::MixedPrecision {
            rnd,
            sat,
            src_type,
            dst,
            src_a,
            src_b,
            src_c,
        }));
    }

    let instr = match ty {
        // Float32 (Block 36): fma.rnd{.ftz}{.sat}.f32 - all modifiers allowed
        ScalarType::F32 => FmaInstr::Float32 {
            rnd,
            ftz,
            sat,
            dst,
            src_a,
            src_b,
            src_c,
        },

        // Float32x2 (Block 36): fma.rnd{.ftz}.f32x2 - NO sat
        ScalarType::F32x2 => {
            reject_modifier!(sat, ty);
            FmaInstr::Float32x2 {
                rnd,
                ftz,
                dst,
                src_a,
                src_b,
                src_c,
            }
        }

        // Float64 (Block 36): fma.rnd.f64 - NO ftz, NO sat
        ScalarType::F64 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            FmaInstr::Float64 {
                rnd,
                dst,
                src_a,
                src_b,
                src_c,
            }
        }

        // Half f16/f16x2 (Block 56) - dispatch based on relu vs sat
        // fma.rnd{.ftz}{.sat}.f16 OR fma.rnd{.ftz}.relu.f16 (mutually exclusive)
        ScalarType::F16 | ScalarType::F16x2 => {
            if relu {
                // relu variant: no sat allowed
                if sat {
                    return Err(InstrParseError::ModifierRequiresModifier {
                        modifier: "sat",
                        required: "!relu",
                    });
                }
                FmaInstr::HalfF16Relu {
                    rnd,
                    ftz,
                    ty,
                    dst,
                    src_a,
                    src_b,
                    src_c,
                }
            } else {
                FmaInstr::HalfF16Sat {
                    rnd,
                    ftz,
                    sat,
                    ty,
                    dst,
                    src_a,
                    src_b,
                    src_c,
                }
            }
        }

        // Half bf16/bf16x2 (Block 56): fma.rnd{.relu}.bf16 - NO ftz, NO sat
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            reject_modifier!(ftz, ty);
            reject_modifier!(sat, ty);
            FmaInstr::HalfBf16 {
                rnd,
                relu,
                ty,
                dst,
                src_a,
                src_b,
                src_c,
            }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Fma(instr))
}

/// Parse rcp instruction (Blocks 43, 44)
/// Block 43: rcp.approx{.ftz}.f32 / rcp.rnd{.ftz}.f32 / rcp.rnd.f64 (NO ftz)
/// Block 44: rcp.approx.ftz.f64 (ftz REQUIRED for f64 approx)
fn parse_rcp(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let approx = mp.try_consume(ascii("approx"));
    let rnd = mp.try_parse::<FpRound>();
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    let instr = if approx {
        // rcp.approx{.ftz}.f32 or rcp.approx.ftz.f64 (Block 44 - ftz REQUIRED for f64)
        if ty == ScalarType::F64 && !ftz {
            return Err(InstrParseError::MissingModifier(ascii("ftz")));
        }
        RcpInstr::Approx { ftz, ty, dst, src }
    } else if let Some(rnd) = rnd {
        // rcp.rnd{.ftz}.f32 or rcp.rnd.f64 - NO ftz for f64
        if ftz && ty == ScalarType::F64 {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "ftz",
                ty,
            });
        }
        RcpInstr::Ieee {
            rnd,
            ftz,
            ty,
            dst,
            src,
        }
    } else {
        // Default to approx if no explicit mode (shouldn't happen in valid PTX)
        if ty == ScalarType::F64 && !ftz {
            return Err(InstrParseError::MissingModifier(ascii("ftz")));
        }
        RcpInstr::Approx { ftz, ty, dst, src }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Rcp(instr))
}

/// Parse sqrt instruction (Block 45)
/// Block 45: sqrt.approx{.ftz}.f32 / sqrt.rnd{.ftz}.f32 / sqrt.rnd.f64 (NO ftz)
fn parse_sqrt(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let approx = mp.try_consume(ascii("approx"));
    let rnd = mp.try_parse::<FpRound>();
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    let instr = if approx {
        // sqrt.approx{.ftz}.f32 - approx only for f32
        if ty == ScalarType::F64 {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
        SqrtInstr::Approx { ftz, dst, src }
    } else if let Some(rnd) = rnd {
        // sqrt.rnd{.ftz}.f32 or sqrt.rnd.f64 - NO ftz for f64
        if ftz && ty == ScalarType::F64 {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "ftz",
                ty,
            });
        }
        SqrtInstr::Ieee {
            rnd,
            ftz,
            ty,
            dst,
            src,
        }
    } else {
        // Default to approx if no explicit mode - only for f32
        if ty == ScalarType::F64 {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
        SqrtInstr::Approx { ftz, dst, src }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Sqrt(instr))
}

/// Parse rsqrt instruction (Block 46)
fn parse_rsqrt(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let approx = mp.try_consume(ascii("approx"));
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Rsqrt(RsqrtInstr {
        approx,
        ftz,
        ty,
        dst,
        src,
    }))
}

/// Parse sin instruction (Block 48)
fn parse_sin(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("approx"))?; // sin.approx{.ftz}.f32 - approx is required
    let ftz = mp.try_consume(ascii("ftz"));
    mp.try_consume_or_err(ascii("f32"))?; // type is required

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Sin(SinInstr { ftz, dst, src }))
}

/// Parse cos instruction (Block 49)
fn parse_cos(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("approx"))?; // cos.approx{.ftz}.f32 - approx is required
    let ftz = mp.try_consume(ascii("ftz"));
    mp.try_consume_or_err(ascii("f32"))?; // type is required

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Cos(CosInstr { ftz, dst, src }))
}

/// Parse lg2 instruction (Block 50)
fn parse_lg2(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("approx"))?; // lg2.approx{.ftz}.f32 - approx is required
    let ftz = mp.try_consume(ascii("ftz"));
    mp.try_consume_or_err(ascii("f32"))?; // type is required

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Lg2(Lg2Instr { ftz, dst, src }))
}

/// Parse ex2 instruction (Blocks 51, 62)
/// Block 51: ex2.approx{.ftz}.f32 - ftz optional
/// Block 62: ex2.approx.atype (atype = f16, f16x2) - NO ftz allowed
/// Block 62: ex2.approx.ftz.btype (btype = bf16, bf16x2) - ftz REQUIRED
fn parse_ex2(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("approx"))?; // ex2.approx - approx is required
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?; // type is required

    let [dst, src] = expect_operands(operands)?;

    let instr = match ty {
        // Float32 (Block 51): ex2.approx{.ftz}.f32 - ftz optional
        ScalarType::F32 => Ex2Instr::Float32 { ftz, dst, src },

        // Half f16/f16x2 (Block 62): ex2.approx.f16 - NO ftz allowed
        ScalarType::F16 | ScalarType::F16x2 => {
            reject_modifier!(ftz, ty);
            Ex2Instr::HalfF16 { ty, dst, src }
        }

        // Half bf16/bf16x2 (Block 62): ex2.approx.ftz.bf16 - ftz REQUIRED
        ScalarType::Bf16 | ScalarType::Bf16x2 => {
            if !ftz {
                return Err(InstrParseError::MissingModifier(ascii("ftz")));
            }
            Ex2Instr::HalfBf16 { ty, dst, src }
        }

        _ => {
            return Err(InstrParseError::InvalidTypeForInstruction(ty));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Ex2(instr))
}

/// Parse tanh instruction (Blocks 52, 61)
fn parse_tanh(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("approx"))?; // tanh.approx.type - approx is required
    let ty = mp.require_scalar_type()?; // type is required

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Tanh(TanhInstr { ty, dst, src }))
}

// =============================================================================
// Comparison and Selection Parsers
// =============================================================================

/// Parse set instruction (Blocks 66, 70)
/// Block 66: set.CmpOp{.ftz}.dtype.stype - ftz only for float stypes (f32, f64)
/// Block 70: set.CmpOp{.ftz}.dtype.f16 - ftz allowed, NOT for bf16
fn parse_set(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let cmp_op = mp
        .try_parse::<CmpOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("CmpOp")))?;
    let bool_op = mp.try_parse::<BoolOp>();
    let ftz = mp.try_consume(ascii("ftz"));
    let dst_type = mp.require_scalar_type()?;
    let src_type = mp.require_scalar_type()?;

    // ftz only allowed for float source types (f32, f64, f16, f16x2), NOT for bf16 or integers
    if ftz {
        match src_type {
            ScalarType::F32 | ScalarType::F64 | ScalarType::F16 | ScalarType::F16x2 => {}
            _ => {
                return Err(InstrParseError::InvalidModifierForType {
                    modifier: "ftz",
                    ty: src_type,
                });
            }
        }
    }

    if operands.len() < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    let dst = ops.next().unwrap();
    let src_a = ops.next().unwrap();
    let src_b = ops.next().unwrap();
    let src_c = ops.next();

    // bool_op and src_c are coupled: both present or both absent
    let instr = match (bool_op, src_c) {
        (Some(bool_op), Some(src_c)) => SetInstr::WithBoolOp {
            cmp_op,
            bool_op,
            ftz,
            dst_type,
            src_type,
            dst,
            src_a,
            src_b,
            src_c,
        },
        (None, None) => SetInstr::Simple {
            cmp_op,
            ftz,
            dst_type,
            src_type,
            dst,
            src_a,
            src_b,
        },
        // Mismatch: bool_op without src_c or src_c without bool_op
        // For now, use Simple form and ignore the extra
        (Some(_), None) => SetInstr::Simple {
            cmp_op,
            ftz,
            dst_type,
            src_type,
            dst,
            src_a,
            src_b,
        },
        (None, Some(_src_c)) => SetInstr::Simple {
            cmp_op,
            ftz,
            dst_type,
            src_type,
            dst,
            src_a,
            src_b,
        },
    };

    mp.finish()?;
    Ok(ParsedInstruction::Set(instr))
}

/// Parse setp instruction (Blocks 67, 71)
/// Block 67: setp.CmpOp{.ftz}.type - ftz only for float types (f32, f64)
/// Block 71: setp.CmpOp{.ftz}.f16 - ftz allowed, NOT for bf16
fn parse_setp(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let cmp_op = mp
        .try_parse::<CmpOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("CmpOp")))?;
    let bool_op = mp.try_parse::<BoolOp>();
    let ftz = mp.try_consume(ascii("ftz"));
    let ty = mp.require_scalar_type()?;

    // ftz only allowed for float types (f32, f64, f16, f16x2), NOT for bf16 or integers
    if ftz {
        match ty {
            ScalarType::F32 | ScalarType::F64 | ScalarType::F16 | ScalarType::F16x2 => {}
            _ => {
                return Err(InstrParseError::InvalidModifierForType {
                    modifier: "ftz",
                    ty,
                });
            }
        }
    }

    let operand_count = operands.len();
    if operand_count < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operand_count,
        });
    }

    let mut ops = operands.into_iter();
    let first = ops.next().unwrap();

    // Extract dst_p and dst_q from first operand
    // If it's a PredicatePair (p|q), both predicates are in the pair
    // If it's a simple register, there's only dst_p (no dst_q)
    let (dst_p, dst_q) = match first {
        Operand::PredicatePair(p, q) => (Operand::Ident(p), Some(Operand::Ident(q))),
        other => (other, None),
    };

    let src_a = ops.next().unwrap();
    let src_b = ops.next().unwrap();
    let src_c = ops.next();

    if ops.next().is_some() {
        return Err(InstrParseError::WrongOperandCount {
            expected: 4,
            got: operand_count,
        });
    }

    // bool_op and src_c are coupled: both present or both absent. A mismatch
    // used to fall back to the Simple form, silently dropping the boolean
    // combination (or the extra operand); reject it instead.
    let instr = match (bool_op, src_c) {
        (Some(bool_op), Some(src_c)) => SetpInstr::WithBoolOp {
            cmp_op,
            bool_op,
            ftz,
            ty,
            dst_p,
            dst_q,
            src_a,
            src_b,
            src_c,
        },
        (None, None) => SetpInstr::Simple {
            cmp_op,
            ftz,
            ty,
            dst_p,
            dst_q,
            src_a,
            src_b,
        },
        (Some(_), None) => {
            return Err(InstrParseError::WrongOperandCount {
                expected: 4,
                got: operand_count,
            });
        }
        (None, Some(_)) => {
            return Err(InstrParseError::WrongOperandCount {
                expected: 3,
                got: operand_count,
            });
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Setp(instr))
}

/// Parse selp instruction (Block 68)
fn parse_selp(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Selp(SelpInstr {
        ty,
        dst,
        src_a,
        src_b,
        src_c,
    }))
}

/// Parse slct instruction (Block 69)
/// Block 69: slct.dtype.s32 (NO ftz) / slct{.ftz}.dtype.f32
fn parse_slct(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ftz = mp.try_consume(ascii("ftz"));
    let dst_type = mp.require_scalar_type()?;
    let src_type = mp.require_scalar_type()?;

    let [dst, src_a, src_b, src_c] = expect_operands(operands)?;

    // src_type determines form: s32 = Integer (NO ftz), f32 = Float (ftz optional)
    let instr = match src_type {
        ScalarType::S32 => {
            reject_modifier!(ftz, src_type);
            SlctInstr::Integer {
                dst_type,
                dst,
                src_a,
                src_b,
                src_c,
            }
        }
        ScalarType::F32 => SlctInstr::Float {
            ftz,
            dst_type,
            dst,
            src_a,
            src_b,
            src_c,
        },
        _ => {
            // Per spec, only s32 and f32 are valid src_types
            return Err(InstrParseError::InvalidTypeForInstruction(src_type));
        }
    };

    mp.finish()?;
    Ok(ParsedInstruction::Slct(instr))
}

// =============================================================================
// Logic and Shift Parsers
// =============================================================================

/// Parse and/or/xor instruction (Blocks 72-74)
fn parse_logic(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
    kind: InstrKind,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    let instr = LogicInstr {
        ty,
        dst,
        src_a,
        src_b,
    };

    mp.finish()?;
    Ok(match kind {
        InstrKind::And => ParsedInstruction::And(instr),
        InstrKind::Or => ParsedInstruction::Or(instr),
        InstrKind::Xor => ParsedInstruction::Xor(instr),
        _ => unreachable!(),
    })
}

/// Parse not instruction (Block 75)
fn parse_not(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Not(NotInstr { ty, dst, src }))
}

/// Parse cnot instruction (Block 76)
fn parse_cnot(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Cnot(CnotInstr { ty, dst, src }))
}

/// Parse lop3 instruction (Block 77)
fn parse_lop3(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let bool_op = mp.try_parse::<BoolOp>();
    mp.try_consume_or_err(ascii("b32"))?; // lop3{.BoolOp}.b32 - type is required

    if operands.len() < 5 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 5,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::Lop3(Lop3Instr {
        bool_op,
        dst: ops.next().unwrap(),
        dst_pred: None, // TODO: handle d|p form
        src_a: ops.next().unwrap(),
        src_b: ops.next().unwrap(),
        src_c: ops.next().unwrap(),
        lut: ops.next().unwrap(),
        pred_q: ops.next(),
    }))
}

/// Parse shf instruction (Block 78)
fn parse_shf(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let dir = mp
        .try_parse::<ShiftDir>()
        .ok_or(InstrParseError::MissingModifier(ascii("direction")))?;
    let mode = mp
        .try_parse::<ClampWrapMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    mp.try_consume_or_err(ascii("b32"))?; // shf.dir.mode.b32 - type is required

    let [dst, lo, hi, shift] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Shf(ShfInstr {
        dir,
        mode,
        dst,
        lo,
        hi,
        shift,
    }))
}

/// Parse shl/shr instruction (Blocks 79-80)
fn parse_shift(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
    kind: InstrKind,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src_a, src_b] = expect_operands(operands)?;

    let instr = ShiftInstr {
        ty,
        dst,
        src_a,
        src_b,
    };

    mp.finish()?;
    Ok(match kind {
        InstrKind::Shl => ParsedInstruction::Shl(instr),
        InstrKind::Shr => ParsedInstruction::Shr(instr),
        _ => unreachable!(),
    })
}

// =============================================================================
// Data Movement Parsers
// =============================================================================

/// Parse mov instruction (Block 81)
fn parse_mov(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Mov(MovInstr { ty, dst, src }))
}

/// Parse shfl instruction (Block 83, deprecated)
fn parse_shfl(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<ShflMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    mp.try_consume_or_err(ascii("b32"))?; // shfl.mode.b32 - type is required

    // Exact arity: extra operands would be dropped silently.
    if operands.len() != 4 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 4,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::Shfl(ShflInstr {
        mode,
        dst: ops.next().unwrap(),
        dst_pred: None,
        src: ops.next().unwrap(),
        src_b: ops.next().unwrap(),
        src_c: ops.next().unwrap(),
    }))
}

/// Parse shfl.sync instruction (Block 84)
fn parse_shfl_sync(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<ShflMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    mp.try_consume_or_err(ascii("b32"))?; // shfl.sync.mode.b32 - type is required

    // Exact arity: extra operands would be dropped silently.
    if operands.len() != 5 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 5,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::ShflSync(ShflSyncInstr {
        mode,
        dst: ops.next().unwrap(),
        dst_pred: None,
        src: ops.next().unwrap(),
        src_b: ops.next().unwrap(),
        src_c: ops.next().unwrap(),
        membermask: ops.next().unwrap(),
    }))
}

/// Parse prmt instruction (Block 85)
fn parse_prmt(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("b32"))?; // prmt.b32{.mode} - type is required
    let mode = if let Some(m) = mp.peek_simple() {
        PrmtMode::from_ascii(m)
            .inspect(|_| {
                let _ = mp.next(); // consume peeked mode
            })
            .unwrap_or(PrmtMode::None)
    } else {
        PrmtMode::None
    };

    let [dst, src_a, src_b, selector] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Prmt(PrmtInstr {
        mode,
        dst,
        src_a,
        src_b,
        selector,
    }))
}

/// Parse ld instruction (Blocks 86, 87)
fn parse_ld(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mmio = mp.try_consume(ascii("mmio"));
    let semantics = mp.try_parse::<MemSemantics>().unwrap_or(MemSemantics::Weak);
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    let cache_op = mp.try_parse::<CacheOp>();
    // Eviction-priority and prefetch-size qualifiers are pure performance
    // hints with no extra operand; accept and ignore them. Any other
    // qualified modifier (a ::-qualified state space we did not parse
    // above, L2::cache_hint - which requires a cache-policy operand we do
    // not parse, ...) is unsupported; error loudly.
    mp.skip_cache_perf_hints();
    mp.reject_qualified()?;
    let nc = mp.try_consume(ascii("nc"));
    let vec = mp.try_parse::<VecWidth>();
    let unified = mp.try_consume(ascii("unified"));
    let ty = mp.require_scalar_type()?;

    let [dst, addr] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Ld(LdInstr {
        semantics,
        scope,
        space,
        space_qualifier: None,
        cache_op,
        vec,
        nc,
        mmio,
        unified,
        ty,
        dst,
        addr,
    }))
}

/// Parse ldu instruction (Block 88)
fn parse_ldu(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let space = mp.try_parse::<StateSpace>();
    let vec = mp.try_parse::<VecWidth>();
    let ty = mp.require_scalar_type()?;

    let [dst, addr] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Ldu(LduInstr {
        space,
        vec,
        ty,
        dst,
        addr,
    }))
}

/// Parse st instruction (Block 89)
fn parse_st(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mmio = mp.try_consume(ascii("mmio"));
    let semantics = mp.try_parse::<MemSemantics>().unwrap_or(MemSemantics::Weak);
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    let cache_op = mp.try_parse::<CacheOp>();
    // Eviction-priority and prefetch-size qualifiers are pure performance
    // hints with no extra operand; accept and ignore them. Any other
    // qualified modifier (a ::-qualified state space we did not parse
    // above, L2::cache_hint - which requires a cache-policy operand we do
    // not parse, ...) is unsupported; error loudly.
    mp.skip_cache_perf_hints();
    mp.reject_qualified()?;
    let vec = mp.try_parse::<VecWidth>();
    let ty = mp.require_scalar_type()?;

    let [addr, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::St(StInstr {
        semantics,
        scope,
        space,
        space_qualifier: None,
        cache_op,
        vec,
        mmio,
        ty,
        addr,
        src,
    }))
}

/// Parse asynchronous copies
fn parse_cp_async(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let cache_op = mp
        .try_parse::<CacheOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("ca")))?;
    mp.try_consume_or_err(ascii("shared"))?;
    mp.skip_cache_perf_hints();
    mp.reject_qualified()?;
    mp.try_consume_or_err(ascii("global"))?;
    mp.skip_cache_perf_hints();
    mp.reject_qualified()?;

    // Operands: [dst], [src], cp-size, and an optional 4th (src-size or
    // ignore-src - which one is resolved during lowering, from the
    // operand's register class).
    let (dst, src, cp_size, extra) = if operands.len() == 4 {
        let [dst, src, cp_size, extra] = expect_operands(operands)?;
        (dst, src, cp_size, Some(extra))
    } else {
        let [dst, src, cp_size] = expect_operands(operands)?;
        (dst, src, cp_size, None)
    };

    mp.finish()?;
    Ok(ParsedInstruction::CpAsync(CpAsyncInstr {
        cache_op,
        dst,
        src,
        cp_size,
        extra,
    }))
}

/// Parse cp.async.commit_group.
fn parse_cp_async_commit_group(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let [] = expect_operands(operands)?;
    mp.finish()?;
    Ok(ParsedInstruction::CpAsyncCommitGroup)
}

/// Parse cp.async.wait_group.
fn parse_cp_async_wait_group(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let [n] = expect_operands(operands)?;
    mp.finish()?;
    Ok(ParsedInstruction::CpAsyncWaitGroup(CpAsyncWaitGroupInstr {
        n,
    }))
}

/// Parse cp.async.wait_all.
fn parse_cp_async_wait_all(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let [] = expect_operands(operands)?;
    mp.finish()?;
    Ok(ParsedInstruction::CpAsyncWaitAll)
}

/// Parse cvt instruction (Blocks 99, 100)
/// Block 99: Standard conversions with various rounding modes
/// Block 100: cvt.pack.sat for packing conversions
fn parse_cvt(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let int_rnd = mp.try_parse::<IntRound>();
    let fp_rnd = mp.try_parse::<FpRound>();
    let (ftz, sat) = mp.ftz_sat();
    let relu = mp.try_consume(ascii("relu"));
    let satfinite = mp.try_consume(ascii("satfinite"));
    // Block 100: pack mode for packing conversions
    let pack = mp.try_consume(ascii("pack"));
    // Block 99: stochastic rounding (cvt.rs)
    let stochastic_rnd = mp.try_consume(ascii("rs"));
    // Block 99: round to nearest away (cvt.rna for tf32)
    let rna = mp.try_consume(ascii("rna"));
    // Block-scaled conversions (.scaled{::...}) are not modeled; reject
    // loudly rather than silently dropping the modifier.
    if let Some(m) = mp.peek_simple()
        && m.as_slice() == ascii("scaled")
    {
        return Err(InstrParseError::UnexpectedModifier(m.clone()));
    }
    mp.reject_qualified()?;
    let dst_type = mp.require_scalar_type()?;
    let src_type = mp.try_parse::<ScalarType>().unwrap_or(dst_type);

    let operand_count = operands.len();
    let mut ops = operands.into_iter();
    let dst = ops.next().ok_or(InstrParseError::WrongOperandCount {
        expected: 2,
        got: 0,
    })?;

    let instr = if pack {
        // Pack conversion: cvt.pack.sat.dtype.atype d, a, b
        let src_a = ops.next().ok_or(InstrParseError::WrongOperandCount {
            expected: 3,
            got: 1,
        })?;
        let src_b = ops.next().ok_or(InstrParseError::WrongOperandCount {
            expected: 3,
            got: 2,
        })?;
        CvtInstr::Pack {
            sat,
            dst_type,
            src_type,
            dst,
            src_a,
            src_b,
        }
    } else {
        // Standard conversion
        let src = ops.next().ok_or(InstrParseError::WrongOperandCount {
            expected: 2,
            got: 1,
        })?;

        // Determine rounding mode (mutually exclusive)
        let rnd = if let Some(ir) = int_rnd {
            Some(CvtRounding::Integer(ir))
        } else if let Some(fr) = fp_rnd {
            Some(CvtRounding::Float(fr))
        } else if stochastic_rnd {
            Some(CvtRounding::Stochastic)
        } else if rna {
            Some(CvtRounding::Rna)
        } else {
            None
        };

        // A second source operand only makes sense for the two-source
        // "convert and pack" form into a packed x2 destination - no
        // `.pack` keyword, the destination type alone signals it (e.g.
        // `cvt.rn.f16x2.f32 d, a, b`). Any other leftover operand is a
        // genuine error, caught below.
        match ops.next() {
            None => CvtInstr::Standard {
                rnd,
                ftz,
                sat,
                relu,
                satfinite,
                dst_type,
                src_type,
                dst,
                src,
            },
            Some(src_lo) if matches!(dst_type, ScalarType::F16x2 | ScalarType::Bf16x2) => {
                if ftz {
                    return Err(InstrParseError::InvalidModifierForType {
                        modifier: "ftz",
                        ty: dst_type,
                    });
                }
                if sat {
                    return Err(InstrParseError::InvalidModifierForType {
                        modifier: "sat",
                        ty: dst_type,
                    });
                }
                if relu {
                    return Err(InstrParseError::InvalidModifierForType {
                        modifier: "relu",
                        ty: dst_type,
                    });
                }
                if satfinite {
                    return Err(InstrParseError::InvalidModifierForType {
                        modifier: "satfinite",
                        ty: dst_type,
                    });
                }
                CvtInstr::PackHalves {
                    rnd,
                    dst_type,
                    src_type,
                    dst,
                    src_hi: src,
                    src_lo,
                }
            }
            Some(_) => {
                return Err(InstrParseError::WrongOperandCount {
                    expected: 2,
                    got: operand_count,
                });
            }
        }
    };

    // Leftover operands beyond what each form above already consumed.
    if ops.next().is_some() {
        return Err(InstrParseError::WrongOperandCount {
            expected: if pack { 3 } else { 2 },
            got: operand_count,
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Cvt(instr))
}

/// Parse cvta instruction (Block 98)
fn parse_cvta(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let to_generic = mp.try_consume(ascii("to"));
    let space = mp
        .try_parse::<StateSpace>()
        .ok_or(InstrParseError::MissingModifier(ascii("space")))?;
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Cvta(CvtaInstr {
        to_generic: !to_generic, // "to" means converting TO generic, not from generic
        space,
        ty,
        dst,
        src,
    }))
}

/// Parse isspacep instruction (Block 97)
fn parse_isspacep(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let space = mp
        .try_parse::<StateSpace>()
        .ok_or(InstrParseError::MissingModifier(ascii("space")))?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Isspacep(IsspacepInstr {
        space,
        space_qualifier: None,
        dst,
        src,
    }))
}

/// Parse mapa instruction (Block 101)
fn parse_mapa(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let space = mp.try_parse::<StateSpace>();
    let ty = mp.require_scalar_type()?;

    let [dst, src, cta] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Mapa(MapaInstr {
        space,
        space_qualifier: None,
        ty,
        dst,
        src,
        cta,
    }))
}

/// Parse getctarank instruction (Block 102)
fn parse_getctarank(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let space = mp.try_parse::<StateSpace>();
    let ty = mp.require_scalar_type()?;

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Getctarank(GetctarankInstr {
        space,
        space_qualifier: None,
        ty,
        dst,
        src,
    }))
}

// =============================================================================
// Control Flow Parsers
// =============================================================================

/// Parse bra instruction (Block 127)
fn parse_bra(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let uniform = mp.try_consume(ascii("uni"));

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Bra(BraInstr {
        uniform,
        target: operands.into_iter().next().unwrap(),
    }))
}

/// Parse brx.idx instruction (Block 128)
fn parse_brx_idx(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let uniform = mp.try_consume(ascii("uni"));

    let [index, target_list] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::BrxIdx(BrxIdxInstr {
        uniform,
        index,
        target_list,
    }))
}

/// Parse call instruction (Block 129)
fn parse_call(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let uniform = mp.try_consume(ascii("uni"));

    // Call operands are complex - for now just store them
    mp.finish()?;
    Ok(ParsedInstruction::Call(CallInstr {
        uniform,
        return_operands: Vec::new(),
        target: operands.first().cloned().unwrap_or(Operand::Underscore),
        arguments: operands.into_iter().skip(1).collect(),
    }))
}

/// Parse ret instruction (Block 130)
fn parse_ret(mp: &mut ModifierParser) -> Result<ParsedInstruction, InstrParseError> {
    let uniform = mp.try_consume(ascii("uni"));
    mp.finish()?;
    Ok(ParsedInstruction::Ret(RetInstr { uniform }))
}

// =============================================================================
// Synchronization Parsers
// =============================================================================

/// Parse bar instruction (Block 132)
fn parse_bar(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let _ = mp.try_consume(ascii("cta")); // bar{.cta} - cta is optional

    let mode = if mp.try_consume(ascii("sync")) {
        BarMode::Sync
    } else if mp.try_consume(ascii("arrive")) {
        BarMode::Arrive
    } else if mp.try_consume(ascii("red")) {
        BarMode::Red
    } else {
        BarMode::Sync
    };

    mp.finish()?;
    Ok(ParsedInstruction::Bar(BarInstr { mode, operands }))
}

/// Parse barrier instruction (Block 132)
fn parse_barrier(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let cta = mp.try_consume(ascii("cta"));

    let mode = if mp.try_consume(ascii("sync")) {
        BarMode::Sync
    } else if mp.try_consume(ascii("arrive")) {
        BarMode::Arrive
    } else if mp.try_consume(ascii("red")) {
        BarMode::Red
    } else {
        BarMode::Sync
    };

    let aligned = mp.try_consume(ascii("aligned"));

    mp.finish()?;
    Ok(ParsedInstruction::Barrier(BarrierInstr {
        cta,
        mode,
        aligned,
        operands,
    }))
}

/// Parse bar.warp.sync instruction (Block 133)
fn parse_bar_warp_sync(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::BarWarpSync(BarWarpSyncInstr {
        membermask: operands.into_iter().next().unwrap(),
    }))
}

/// Parse barrier.cluster instruction (Block 134)
fn parse_barrier_cluster(
    mp: &mut ModifierParser,
    _operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let arrive = mp.try_consume(ascii("arrive"));
    let sem = mp.try_parse::<MemSemantics>();
    let aligned = mp.try_consume(ascii("aligned"));

    mp.finish()?;
    Ok(ParsedInstruction::BarrierCluster(BarrierClusterInstr {
        arrive,
        sem,
        aligned,
    }))
}

/// Parse membar instruction (Block 135)
fn parse_membar(
    mp: &mut ModifierParser,
    _operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let level = mp.try_parse::<MemScope>().unwrap_or(MemScope::Cta);

    mp.finish()?;
    Ok(ParsedInstruction::Membar(MembarInstr { level }))
}

/// Parse fence instruction (Block 135)
fn parse_fence(
    mp: &mut ModifierParser,
    _operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let sem = if let Some(m) = mp.peek_simple() {
        FenceSem::from_ascii(m).inspect(|_| {
            let _ = mp.next(); // consume peeked sem
        })
    } else {
        None
    };
    let scope = mp.try_parse::<MemScope>();
    let proxy = mp.try_consume(ascii("proxy"));

    mp.finish()?;
    Ok(ParsedInstruction::Fence(FenceInstr { sem, scope, proxy }))
}

/// Parse atom instruction (Block 136)
/// noftz only valid for atom.add.noftz.{f16,f16x2,bf16,bf16x2}
fn parse_atom(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let semantics = mp
        .try_parse::<MemSemantics>()
        .unwrap_or(MemSemantics::Relaxed);
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    let op = mp
        .try_parse::<AtomOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("op")))?;
    let noftz = mp.try_consume(ascii("noftz"));
    let ty = mp.require_scalar_type()?;

    // noftz only valid for add operation with half-precision types
    if noftz {
        let is_half_type = matches!(
            ty,
            ScalarType::F16 | ScalarType::F16x2 | ScalarType::Bf16 | ScalarType::Bf16x2
        );
        if op != AtomOp::Add || !is_half_type {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "noftz",
                ty,
            });
        }
    }

    if operands.len() < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::Atom(AtomInstr {
        semantics,
        scope,
        space,
        op,
        ty,
        dst: ops.next().unwrap(),
        addr: ops.next().unwrap(),
        src_b: ops.next().unwrap(),
        src_c: ops.next(),
    }))
}

/// Parse red instruction (Block 137)
/// noftz only valid for red.{add,min,max}.noftz.{f16,f16x2,bf16,bf16x2}
fn parse_red(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let semantics = mp
        .try_parse::<MemSemantics>()
        .unwrap_or(MemSemantics::Relaxed);
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    let op = mp
        .try_parse::<RedOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("op")))?;
    let noftz = mp.try_consume(ascii("noftz"));
    let ty = mp.require_scalar_type()?;

    // noftz only valid for add/min/max operations with half-precision types
    if noftz {
        let is_half_type = matches!(
            ty,
            ScalarType::F16 | ScalarType::F16x2 | ScalarType::Bf16 | ScalarType::Bf16x2
        );
        let is_valid_op = matches!(op, RedOp::Add | RedOp::Min | RedOp::Max);
        if !is_valid_op || !is_half_type {
            return Err(InstrParseError::InvalidModifierForType {
                modifier: "noftz",
                ty,
            });
        }
    }

    let [addr, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Red(RedInstr {
        semantics,
        scope,
        space,
        op,
        ty,
        addr,
        src,
    }))
}

/// Parse vote instruction (Block 139, deprecated)
fn parse_vote(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<VoteMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    // vote.mode returns .pred for all/any/uni, or .b32 for ballot
    let _ = mp.try_consume(ascii("pred"));
    let _ = mp.try_consume(ascii("b32"));

    let [dst, src] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::Vote(VoteInstr { mode, dst, src }))
}

/// Parse vote.sync instruction (Block 140)
fn parse_vote_sync(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = mp
        .try_parse::<VoteMode>()
        .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;
    // vote.sync.mode returns .pred for all/any/uni, or .b32 for ballot
    let _ = mp.try_consume(ascii("pred"));
    let _ = mp.try_consume(ascii("b32"));

    let [dst, src, membermask] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::VoteSync(VoteSyncInstr {
        mode,
        dst,
        src,
        membermask,
    }))
}

/// Parse match.sync instruction (Block 141)
fn parse_match_sync(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mode = if let Some(m) = mp.peek_simple() {
        MatchMode::from_ascii(m).inspect(|_| {
            let _ = mp.next(); // consume peeked mode
        })
    } else {
        None
    }
    .ok_or(InstrParseError::MissingModifier(ascii("mode")))?;

    let ty = mp.require_scalar_type()?;

    if operands.len() < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::MatchSync(MatchSyncInstr {
        mode,
        ty,
        dst: ops.next().unwrap(),
        dst_pred: None,
        src: ops.next().unwrap(),
        membermask: ops.next().unwrap(),
    }))
}

/// Parse activemask instruction (Block 142)
fn parse_activemask(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("b32"))?; // activemask.b32 - type is required

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Activemask(ActivemaskInstr {
        dst: operands.into_iter().next().unwrap(),
    }))
}

/// Parse redux.sync instruction (Block 143)
fn parse_redux_sync(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let op = mp
        .try_parse::<RedOp>()
        .ok_or(InstrParseError::MissingModifier(ascii("op")))?;
    let abs = mp.try_consume(ascii("abs"));
    let nan = mp.try_consume(ascii("NaN"));
    let ty = mp.require_scalar_type()?;

    let [dst, src, membermask] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::ReduxSync(ReduxSyncInstr {
        op,
        ty,
        abs,
        nan,
        dst,
        src,
        membermask,
    }))
}

/// Parse griddepcontrol instruction (Block 144)
fn parse_griddepcontrol(
    mp: &mut ModifierParser,
    _operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let action = match mp.peek_simple() {
        Some(m) => {
            let result = GriddepcontrolAction::from_ascii(m)
                .ok_or_else(|| InstrParseError::InvalidModifier(m.clone()));
            let _ = mp.next(); // consume peeked action
            result
        }
        None => Err(InstrParseError::MissingModifier(ascii("action"))),
    }?;

    mp.finish()?;
    Ok(ParsedInstruction::Griddepcontrol(GriddepcontrolInstr {
        action,
    }))
}

/// Parse elect.sync instruction (Block 145)
fn parse_elect_sync(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    if operands.len() < 2 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 2,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::ElectSync(ElectSyncInstr {
        dst: ops.next().unwrap(),
        dst_pred: ops.next().unwrap(),
        membermask: ops.next().unwrap_or(Operand::Underscore),
    }))
}

// =============================================================================
// Mbarrier Parsers
// =============================================================================

/// Parse mbarrier.init instruction (Block 146)
fn parse_mbarrier_init(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let space = mp.try_parse::<StateSpace>();
    mp.try_consume_or_err(ascii("b64"))?; // mbarrier.init{.ss}.b64 - type is required

    let [addr, count] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::MbarrierInit(MbarrierInitInstr {
        space,
        space_qualifier: None,
        addr,
        count,
    }))
}

/// Parse mbarrier.inval instruction (Block 147)
fn parse_mbarrier_inval(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let space = mp.try_parse::<StateSpace>();
    mp.try_consume_or_err(ascii("b64"))?; // mbarrier.inval{.ss}.b64 - type is required

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::MbarrierInval(MbarrierInvalInstr {
        space,
        space_qualifier: None,
        addr: operands.into_iter().next().unwrap(),
    }))
}

/// Parse mbarrier.expect_tx instruction (Block 148)
fn parse_mbarrier_expect_tx(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let sem = mp.try_parse::<MemSemantics>();
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    mp.try_consume_or_err(ascii("b64"))?;

    let [addr, tx_count] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::MbarrierExpectTx(MbarrierExpectTxInstr {
        sem,
        scope,
        space,
        space_qualifier: None,
        addr,
        tx_count,
    }))
}

/// Parse mbarrier.complete_tx instruction (Block 149)
fn parse_mbarrier_complete_tx(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let sem = mp.try_parse::<MemSemantics>();
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    mp.try_consume_or_err(ascii("b64"))?;

    let [addr, tx_count] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::MbarrierCompleteTx(
        MbarrierCompleteTxInstr {
            sem,
            scope,
            space,
            space_qualifier: None,
            addr,
            tx_count,
        },
    ))
}

/// Parse mbarrier.arrive instruction (Block 150)
fn parse_mbarrier_arrive(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let sem = mp.try_parse::<MemSemantics>();
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    let expect_tx = mp.try_consume(ascii("expect_tx"));
    let no_complete = mp.try_consume(ascii("noComplete"));
    mp.try_consume_or_err(ascii("b64"))?;

    if operands.len() < 2 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 2,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::MbarrierArrive(MbarrierArriveInstr {
        sem,
        scope,
        space,
        space_qualifier: None,
        expect_tx,
        no_complete,
        state: ops.next().unwrap(),
        addr: ops.next().unwrap(),
        count: ops.next(),
    }))
}

/// Parse mbarrier.arrive_drop instruction (Block 151)
fn parse_mbarrier_arrive_drop(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let sem = mp.try_parse::<MemSemantics>();
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    let expect_tx = mp.try_consume(ascii("expect_tx"));
    let no_complete = mp.try_consume(ascii("noComplete"));
    mp.try_consume_or_err(ascii("b64"))?;

    if operands.len() < 2 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 2,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::MbarrierArriveDrop(
        MbarrierArriveDropInstr {
            sem,
            scope,
            space,
            space_qualifier: None,
            expect_tx,
            no_complete,
            state: ops.next().unwrap(),
            addr: ops.next().unwrap(),
            count: ops.next(),
        },
    ))
}

/// Parse mbarrier.test_wait or mbarrier.try_wait instruction (Block 153)
fn parse_mbarrier_wait(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
    kind: InstrKind,
) -> Result<ParsedInstruction, InstrParseError> {
    let parity = mp.try_consume(ascii("parity"));
    let sem = mp.try_parse::<MemSemantics>();
    let scope = mp.try_parse::<MemScope>();
    let space = mp.try_parse::<StateSpace>();
    mp.try_consume_or_err(ascii("b64"))?;

    if operands.len() < 3 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 3,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();

    mp.finish()?;
    if kind == InstrKind::MbarrierTestWait {
        Ok(ParsedInstruction::MbarrierTestWait(MbarrierTestWaitInstr {
            parity,
            sem,
            scope,
            space,
            space_qualifier: None,
            wait_complete: ops.next().unwrap(),
            addr: ops.next().unwrap(),
            state_or_parity: ops.next().unwrap(),
        }))
    } else {
        Ok(ParsedInstruction::MbarrierTryWait(MbarrierTryWaitInstr {
            parity,
            sem,
            scope,
            space,
            space_qualifier: None,
            wait_complete: ops.next().unwrap(),
            addr: ops.next().unwrap(),
            state_or_parity: ops.next().unwrap(),
            suspend_hint: ops.next(),
        }))
    }
}

/// Parse mbarrier.pending_count instruction (Block 154)
fn parse_mbarrier_pending_count(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("b64"))?;

    let [count, state] = expect_operands(operands)?;

    mp.finish()?;
    Ok(ParsedInstruction::MbarrierPendingCount(
        MbarrierPendingCountInstr { count, state },
    ))
}

// =============================================================================
// Stack and Misc Parsers
// =============================================================================

/// Parse stacksave instruction (Block 183)
fn parse_stacksave(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Stacksave(StacksaveInstr {
        ty,
        dst: operands.into_iter().next().unwrap(),
    }))
}

/// Parse stackrestore instruction (Block 184)
fn parse_stackrestore(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Stackrestore(StackrestoreInstr {
        ty,
        src: operands.into_iter().next().unwrap(),
    }))
}

/// Parse alloca instruction (Block 185)
fn parse_alloca(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let ty = mp.require_scalar_type()?;

    if operands.len() < 2 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 2,
            got: operands.len(),
        });
    }

    let mut ops = operands.into_iter();
    mp.finish()?;
    Ok(ParsedInstruction::Alloca(AllocaInstr {
        ty,
        ptr: ops.next().unwrap(),
        size: ops.next().unwrap(),
        align: ops.next(),
    }))
}

/// Parse nanosleep instruction (Block 195)
fn parse_nanosleep(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    mp.try_consume_or_err(ascii("u32"))?;

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Nanosleep(NanosleepInstr {
        duration: operands.into_iter().next().unwrap(),
    }))
}

/// Parse pmevent instruction (Block 196)
fn parse_pmevent(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let mask = mp.try_consume(ascii("mask"));

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Pmevent(PmeventInstr {
        mask,
        event: operands.into_iter().next().unwrap(),
    }))
}

/// Parse setmaxnreg instruction (Block 198)
fn parse_setmaxnreg(
    mp: &mut ModifierParser,
    operands: Vec<Operand>,
) -> Result<ParsedInstruction, InstrParseError> {
    let action = match mp.peek_simple() {
        Some(m) => {
            let result = SetmaxnregAction::from_ascii(m)
                .ok_or_else(|| InstrParseError::InvalidModifier(m.clone()));
            let _ = mp.next();
            result
        }
        None => Err(InstrParseError::MissingModifier(ascii("action"))),
    }?;

    mp.try_consume_or_err(ascii("sync"))?;
    mp.try_consume_or_err(ascii("aligned"))?;
    mp.try_consume_or_err(ascii("u32"))?;

    if operands.len() != 1 {
        return Err(InstrParseError::WrongOperandCount {
            expected: 1,
            got: operands.len(),
        });
    }

    mp.finish()?;
    Ok(ParsedInstruction::Setmaxnreg(SetmaxnregInstr {
        action,
        reg_count: operands.into_iter().next().unwrap(),
    }))
}
