//! The lowering context (the program under construction) and what every
//! instruction family shares: type-aware operand resolution, type checks and
//! loud rejection of unsupported forms.

use std::collections::HashMap;
use std::fmt;

use crate::frontend::ast::{
    self, Address, AddressBase, CmpOp as AstCmpOp, FromAscii, MulMode, Operand as AstOperand,
    ScalarType, ShflMode as AstShflMode, StateSpace,
};
use crate::frontend::lex::DottedIdent;
use id_collections::Id;
use volta_common::Span;

use crate::ir::source_map::SourceMap;
use crate::ir::symbols::{LabelScopeId, RegId, SpecialRegKind, SymbolTable};
use crate::ir::types::{ScalarTypeExt, TypeCompatibility, check_type_compatibility};
use crate::ir::{
    CmpOp, InstrId, LoweredInstr, MemSpace, MulMode as LoweredMulMode, Operand, Predicate, ShflMode,
};

use super::error::{LowerError, LowerResult};

/// Build the loud rejection for a modifier or instruction form the model
/// does not implement. Policy: lowering must never drop a semantic modifier
/// silently; anything unmodeled errors here, naming the modifier.
pub(super) fn unsupported(instruction: impl Into<String>, reason: impl Into<String>) -> LowerError {
    LowerError::UnsupportedInstruction {
        instruction: instruction.into(),
        reason: Some(reason.into()),
    }
}

/// An operand resolved with its type information (for type checking)
#[derive(Debug, Clone)]
pub struct ResolvedOperand {
    /// The lowered operand
    pub operand: Operand,
    /// The declared type of the operand (None for immediates, which are polymorphic)
    pub ty: Option<ScalarType>,
    /// The name of the operand (for error messages)
    pub name: Option<String>,
}

impl ResolvedOperand {
    /// Create a resolved operand for a register
    fn register(operand: Operand, ty: ScalarType, name: String) -> Self {
        Self {
            operand,
            ty: Some(ty),
            name: Some(name),
        }
    }

    /// Create a resolved operand for an immediate (type is polymorphic)
    fn immediate(operand: Operand) -> Self {
        Self {
            operand,
            ty: None,
            name: None,
        }
    }

    /// Create a resolved operand for a special register
    fn special_reg(operand: Operand, ty: ScalarType, name: String) -> Self {
        Self {
            operand,
            ty: Some(ty),
            name: Some(name),
        }
    }
}

/// Resolved destination register with type information
#[derive(Debug, Clone)]
pub struct ResolvedDst {
    /// The register ID
    pub reg: RegId,
    /// The declared type
    pub ty: ScalarType,
    /// The register name (for error messages)
    pub name: String,
}

/// State of a block-scope `.param` in the nvcc callseq idiom (`st.param` the
/// argument, `call __symexpf`, `ld.param` the result). The `.param` traffic
/// emits nothing; the call becomes one `UnaryOp::Exp` at the consuming load.
#[derive(Debug, Clone, Copy)]
pub(super) enum LocalParamSlot {
    /// Declared but not yet written
    Empty,
    /// Holds the operand last stored via `st.param`
    Stored(Operand),
    /// Holds the pending result of `__symexpf` applied to the operand
    PendingExp(Operand),
}

/// Context for the lowering pass
pub struct LoweringContext {
    /// Symbol table being built
    pub(super) symbols: SymbolTable,
    /// Span of each emitted instruction
    pub(super) source_map: SourceMap,
    /// Lowered instructions
    pub(super) instructions: Vec<LoweredInstr>,
    /// Predicates for each instruction
    pub(super) predicates: Vec<Option<Predicate>>,
    /// Pending labels (name + declaring scope), pointing to the next
    /// instruction. The scope is captured when the label is seen, since a
    /// label ending a `{}` block is flushed after `label_scope` has popped.
    pending_labels: Vec<(String, LabelScopeId)>,
    /// Forward references to resolve (PC, label name, the scope active at
    /// the reference site - needed since resolution happens later, once
    /// `label_scope` has moved on).
    forward_refs: Vec<(InstrId, String, LabelScopeId)>,
    /// Current instruction span (set before lowering each instruction)
    pub(super) current_span: Option<Span>,
    /// Block-scope `.param` variables (callseq idiom); flat because the
    /// blocks re-declare them before each use
    pub(super) local_params: HashMap<String, LocalParamSlot>,
    /// The label scope currently active (see `LabelScopeId`) - the
    /// function body's top level to start, pushed/popped around each
    /// `Statement::Block`.
    pub(super) label_scope: LabelScopeId,
    /// The arrival count each named barrier has been used with, so one
    /// barrier cannot fire on two different counts (see `lower_bar`).
    barrier_arrivals: HashMap<BarrierKey, ArrivalCount>,
}

/// How a `bar.*` names the barrier it arrives at. A register id's value is
/// unknown at lowering time, so every register-id barrier in the function
/// shares one key and is held to one arrival count.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum BarrierKey {
    Id(u64),
    Register,
}

impl fmt::Display for BarrierKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Id(id) => write!(f, "barrier {}", id),
            Self::Register => write!(f, "a register-named barrier"),
        }
    }
}

/// How many threads one `bar.*` waits for.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ArrivalCount {
    FullCta,
    Threads(u64),
}

impl fmt::Display for ArrivalCount {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::FullCta => write!(f, "the whole CTA"),
            Self::Threads(n) => write!(f, "{} threads", n),
        }
    }
}

impl LoweringContext {
    pub fn new() -> Self {
        Self {
            symbols: SymbolTable::new(),
            source_map: SourceMap::default(),
            instructions: Vec::new(),
            predicates: Vec::new(),
            pending_labels: Vec::new(),
            forward_refs: Vec::new(),
            current_span: None,
            local_params: HashMap::new(),
            label_scope: SymbolTable::ROOT_LABEL_SCOPE,
            barrier_arrivals: HashMap::new(),
        }
    }

    /// Require every immediate-count arrival at one barrier to name the same
    /// count (register ids share a single count). A register count is left to
    /// the evaluator, which pins each id's first concrete count for the run.
    pub(super) fn check_barrier_arrivals(
        &mut self,
        mnemonic: &str,
        barrier_id: &Operand,
        thread_count: Option<&Operand>,
    ) -> LowerResult<()> {
        fn immediate(op: &Operand) -> Option<u64> {
            match op {
                Operand::ImmI64(v) => u64::try_from(*v).ok(),
                Operand::ImmU64(v) => Some(*v),
                _ => None,
            }
        }

        let key = match immediate(barrier_id) {
            Some(id) => BarrierKey::Id(id),
            None => BarrierKey::Register,
        };
        let count = match thread_count {
            None => ArrivalCount::FullCta,
            Some(op) => match immediate(op) {
                Some(count) => ArrivalCount::Threads(count),
                None => return Ok(()),
            },
        };

        match self.barrier_arrivals.insert(key, count) {
            Some(previous) if previous != count => Err(unsupported(
                mnemonic,
                format!(
                    "{} fires on {} here but on {} elsewhere in this kernel; Volta \
                     pins one arrival count per barrier id so the evaluator can \
                     take a barrier's count from any arrival at it. This is \
                     stricter than the ISA, which only requires the threads \
                     meeting at one barrier phase to agree - if this kernel \
                     reuses the id with different counts in disjoint phases, it \
                     is legal and this check is too restrictive",
                    key, count, previous
                ),
            )),
            _ => Ok(()),
        }
    }

    /// Get current PC (next instruction index)
    pub(super) fn current_pc(&self) -> InstrId {
        InstrId::from_index(self.instructions.len() as u32)
    }

    /// Emit an instruction
    pub(super) fn emit(
        &mut self,
        instr: LoweredInstr,
        predicate: Option<Predicate>,
    ) -> LowerResult<()> {
        // Resolve pending labels to this PC
        let pc = self.current_pc();
        for (label, scope) in self.pending_labels.drain(..) {
            self.symbols.declare_label(&label, scope, pc)?;
        }

        self.source_map.record_instruction(pc, self.current_span);

        self.instructions.push(instr);
        self.predicates.push(predicate);
        Ok(())
    }

    /// Record a label to be resolved to the next instruction. Captures
    /// `label_scope` now, not at `emit()`-flush time - see the field doc
    /// on `pending_labels`.
    pub(super) fn record_label(&mut self, name: &str) {
        self.pending_labels
            .push((name.to_string(), self.label_scope));
    }

    /// Record a forward reference to a label, from `scope` (the scope
    /// active at the branch site - see the field doc on `forward_refs`).
    pub(super) fn record_forward_ref(&mut self, label: &str, scope: LabelScopeId) {
        self.forward_refs
            .push((self.current_pc(), label.to_string(), scope));
    }

    /// Resolve all forward references, patching branch targets.
    pub(super) fn resolve_forward_refs(&mut self) -> LowerResult<()> {
        for (pc, label, scope) in &self.forward_refs {
            let Some(target) = self.symbols.resolve_label(label, *scope) else {
                return Err(LowerError::UndefinedLabel {
                    name: label.clone(),
                });
            };
            if let Some(LoweredInstr::Bra { target: t }) =
                self.instructions.get_mut(pc.to_index() as usize)
            {
                *t = target;
            }
        }
        Ok(())
    }

    /// Resolve a register operand to RegId
    pub(super) fn resolve_register(&self, name: &str) -> LowerResult<RegId> {
        // Look up register by exact name (including any % prefix)
        self.symbols.resolve_register(name).ok_or_else(|| {
            let suggestions = self.symbols.find_similar_registers(name);
            LowerError::UndefinedRegister {
                name: name.to_string(),
                suggestions,
            }
        })
    }

    /// Resolve a shared, local, or module-global symbol to its address: the
    /// space-relative offset from the symbol table for shared/local, an
    /// absolute address in a reserved region for module globals.
    fn resolve_mem_symbol(&self, name: &str) -> Option<Operand> {
        if let Some(info) = self.symbols.get_shared_var(name) {
            return Some(Operand::ImmU64(info.offset));
        }
        if let Some(info) = self.symbols.get_local_var(name) {
            return Some(Operand::ImmU64(info.offset));
        }
        if let Some(info) = self.symbols.get_global_var(name) {
            return Some(Operand::ImmU64(info.addr));
        }
        if let Some(id) = self.symbols.get_param(name) {
            return Some(Operand::ImmU64(self.symbols.param_slot(id).offset));
        }
        None
    }

    /// Resolve an operand (register, immediate, or special register)
    pub(super) fn resolve_operand(&self, op: &AstOperand) -> LowerResult<Operand> {
        match op {
            AstOperand::Ident(name) => {
                let name_str = name.to_string();
                // PTX predefined constant: warp size
                if name_str == "WARP_SZ" {
                    return Ok(Operand::ImmI64(32));
                }
                // Check for special register first (e.g., %tid.x, %ntid.x)
                if let Some(kind) = SpecialRegKind::from_name(&name_str) {
                    return Ok(Operand::SpecialReg(kind));
                }
                // Check if it's a declared register
                if let Some(reg_id) = self.symbols.resolve_register(&name_str) {
                    return Ok(Operand::Reg(reg_id));
                }
                // Check if it's a shared/local/global memory symbol
                if let Some(op) = self.resolve_mem_symbol(&name_str) {
                    return Ok(op);
                }
                // Not found - return error with suggestions
                let suggestions = self.symbols.find_similar_registers(&name_str);
                Err(LowerError::UndefinedRegister {
                    name: name_str,
                    suggestions,
                })
            }
            AstOperand::ImmInt(val) => Ok(Operand::ImmI64(*val)),
            AstOperand::ImmUInt(val) => Ok(Operand::ImmU64(*val)),
            AstOperand::ImmFloat(val) => {
                // A NaN bit pattern (e.g. 0f7FC00000) is no real number, so
                // reject it at this float-literal ingestion point. Infinities
                // pass (reductions seed running max/min with 0fFF800000).
                if val.is_nan() {
                    return Err(LowerError::NanLiteral);
                }
                Ok(Operand::ImmF64(*val))
            }
            AstOperand::Symbol(name) => {
                let name_str = name.to_string();
                // Check if it's a shared/local/global memory symbol
                if let Some(op) = self.resolve_mem_symbol(&name_str) {
                    return Ok(op);
                }
                // Unknown symbol
                Err(LowerError::UnsupportedInstruction {
                    instruction: format!("symbol reference: {}", name),
                    reason: Some(format!(
                        "Unknown symbol '{}' - not a shared, local, or global variable",
                        name
                    )),
                })
            }
            AstOperand::Underscore => {
                // Underscore means "don't care" - we create a dummy register
                // This is used for predicates we want to discard
                Err(LowerError::UnsupportedInstruction {
                    instruction: "underscore operand".to_string(),
                    reason: Some("Underscore operands not yet implemented".to_string()),
                })
            }
            AstOperand::Address(addr) => {
                // Address operand - resolve the base
                self.resolve_address(addr)
            }
            AstOperand::Vector(_ops) => {
                // Vector operand - not handled inline, should be handled by instruction
                Err(LowerError::UnsupportedInstruction {
                    instruction: "vector operand".to_string(),
                    reason: Some(
                        "Vector operands should be handled by the instruction".to_string(),
                    ),
                })
            }
            AstOperand::TensorCoordAddress { .. } => {
                // Tensor descriptor + coordinate-vector operand - not handled inline,
                // should be handled by the instruction (e.g. cp.async.bulk.tensor).
                Err(LowerError::UnsupportedInstruction {
                    instruction: "tensor descriptor + coordinate operand".to_string(),
                    reason: Some(
                        "Tensor coordinate operands should be handled by the instruction"
                            .to_string(),
                    ),
                })
            }
            AstOperand::PredicateOperand {
                negated: _,
                name: _,
            } => Err(LowerError::UnsupportedInstruction {
                instruction: "predicate operand".to_string(),
                reason: Some("Use resolve_predicate_operand for predicates".to_string()),
            }),
            AstOperand::PredicatePair(_, _) => Err(LowerError::UnsupportedInstruction {
                instruction: "predicate pair".to_string(),
                reason: Some("Predicate pairs not yet implemented".to_string()),
            }),
            AstOperand::VectorElement(name, component) => {
                // Check if this is actually a special register like %tid.x
                // The parser might mis-parse %tid.x as a VectorElement
                let full_name = format!(
                    "{}.{}",
                    name,
                    match component.canonicalize() {
                        ast::CanonVectorComponent::X => "x",
                        ast::CanonVectorComponent::Y => "y",
                        ast::CanonVectorComponent::Z => "z",
                        ast::CanonVectorComponent::W => "w",
                    }
                );
                if let Some(kind) = SpecialRegKind::from_name(&full_name) {
                    return Ok(Operand::SpecialReg(kind));
                }
                // Otherwise it's a real vector element which we don't support yet
                Err(LowerError::UnsupportedInstruction {
                    instruction: "vector element".to_string(),
                    reason: Some("Vector elements not yet implemented".to_string()),
                })
            }
            AstOperand::Expr(_) => Err(LowerError::UnsupportedInstruction {
                instruction: "expression operand".to_string(),
                reason: Some("Expression operands not yet implemented".to_string()),
            }),
        }
    }

    /// Resolve an operand with type information (for type checking)
    pub(super) fn resolve_operand_typed(&self, op: &AstOperand) -> LowerResult<ResolvedOperand> {
        match op {
            AstOperand::Ident(name) => {
                let name_str = name.to_string();
                // PTX predefined constant: warp size (polymorphic immediate)
                if name_str == "WARP_SZ" {
                    return Ok(ResolvedOperand::immediate(Operand::ImmI64(32)));
                }
                // Check for special register first
                if let Some(kind) = SpecialRegKind::from_name(&name_str) {
                    let ty = kind.ty();
                    return Ok(ResolvedOperand::special_reg(
                        Operand::SpecialReg(kind),
                        ty,
                        name_str,
                    ));
                }
                // Check if it's a declared register
                if let Some(info) = self.symbols.get_register(&name_str) {
                    return Ok(ResolvedOperand::register(
                        Operand::Reg(info.id),
                        info.declared_type,
                        name_str,
                    ));
                }
                // A shared/local/global memory symbol: its address is a
                // constant, so treat it as an (untyped) immediate - `mov.u32`
                // takes shared addresses, `mov.u64` local depot addresses.
                if let Some(op) = self.resolve_mem_symbol(&name_str) {
                    return Ok(ResolvedOperand::immediate(op));
                }
                // Not found - return error
                let suggestions = self.symbols.find_similar_registers(&name_str);
                Err(LowerError::UndefinedRegister {
                    name: name_str,
                    suggestions,
                })
            }
            AstOperand::ImmInt(_) | AstOperand::ImmUInt(_) | AstOperand::ImmFloat(_) => {
                // Immediates are polymorphic - their type is determined by context
                Ok(ResolvedOperand::immediate(self.resolve_operand(op)?))
            }
            AstOperand::VectorElement(name, component) => {
                // Check if this is actually a special register like %tid.x
                let full_name = format!(
                    "{}.{}",
                    name,
                    match component.canonicalize() {
                        ast::CanonVectorComponent::X => "x",
                        ast::CanonVectorComponent::Y => "y",
                        ast::CanonVectorComponent::Z => "z",
                        ast::CanonVectorComponent::W => "w",
                    }
                );
                if let Some(kind) = SpecialRegKind::from_name(&full_name) {
                    let ty = kind.ty();
                    return Ok(ResolvedOperand::special_reg(
                        Operand::SpecialReg(kind),
                        ty,
                        full_name,
                    ));
                }
                // Otherwise delegate to resolve_operand (which will error)
                Ok(ResolvedOperand::immediate(self.resolve_operand(op)?))
            }
            _ => {
                // For other operand types, delegate to resolve_operand
                // These are typically address operands or other special cases
                Ok(ResolvedOperand::immediate(self.resolve_operand(op)?))
            }
        }
    }

    /// Resolve a destination register with type information (for type checking)
    pub(super) fn resolve_dst_typed(&self, op: &AstOperand) -> LowerResult<ResolvedDst> {
        match op {
            AstOperand::Ident(name) => {
                let name_str = name.to_string();
                // Check if it's a special register (not allowed as destination)
                if SpecialRegKind::from_name(&name_str).is_some() {
                    return Err(LowerError::SpecialRegAsDestination {
                        instruction: "destination".to_string(),
                        register: name_str,
                    });
                }
                // Look up the register
                if let Some(info) = self.symbols.get_register(&name_str) {
                    return Ok(ResolvedDst {
                        reg: info.id,
                        ty: info.declared_type,
                        name: name_str,
                    });
                }
                // Not found
                let suggestions = self.symbols.find_similar_registers(&name_str);
                Err(LowerError::UndefinedRegister {
                    name: name_str,
                    suggestions,
                })
            }
            _ => Err(LowerError::InvalidOperand {
                instruction: "instruction".to_string(),
                operand: format!("{:?}", op),
                reason: "destination must be a register",
            }),
        }
    }

    /// Resolve an address operand to base operand
    pub(super) fn resolve_address(&self, addr: &Address) -> LowerResult<Operand> {
        match &addr.base {
            AddressBase::Register(name) => {
                let name_str = name.to_string();
                let reg_id = self.resolve_register(&name_str)?;
                Ok(Operand::Reg(reg_id))
            }
            AddressBase::Symbol(name) => {
                // The parser only treats a `%`-prefixed base as `Register`, but
                // PTX allows unprefixed register names (`[xp]`), so check the
                // register table before falling back to a memory symbol.
                let name_str = name.to_string();
                if let Some(info) = self.symbols.get_register(&name_str) {
                    return Ok(Operand::Reg(info.id));
                }
                if let Some(op) = self.resolve_mem_symbol(&name_str) {
                    Ok(op)
                } else {
                    Err(LowerError::UndefinedSymbol { name: name_str })
                }
            }
            AddressBase::Immediate(val) => Ok(Operand::ImmI64(*val)),
        }
    }

    /// Get offset from address
    pub(super) fn get_address_offset(&self, addr: &Address) -> i64 {
        match &addr.offset {
            Some(expr) => {
                // Try to evaluate constant expression
                Self::eval_const_expr(expr).unwrap_or(0)
            }
            None => 0,
        }
    }

    /// Try to evaluate a constant expression
    fn eval_const_expr(expr: &ast::Expr) -> Option<i64> {
        match expr {
            ast::Expr::IntLitS(v) => Some(*v),
            ast::Expr::IntLitU(v) => Some(*v as i64),
            ast::Expr::Binary(lhs, op, rhs) => {
                let l = Self::eval_const_expr(lhs)?;
                let r = Self::eval_const_expr(rhs)?;
                Some(match op {
                    ast::BinaryOp::Add => l.wrapping_add(r),
                    ast::BinaryOp::Sub => l.wrapping_sub(r),
                    ast::BinaryOp::Mul => l.wrapping_mul(r),
                    ast::BinaryOp::Div => l.checked_div(r)?,
                    ast::BinaryOp::Shl => l.wrapping_shl(r as u32),
                    ast::BinaryOp::Shr => l.wrapping_shr(r as u32),
                    ast::BinaryOp::BitAnd => l & r,
                    ast::BinaryOp::BitXor => l ^ r,
                    ast::BinaryOp::BitOr => l | r,
                    _ => todo!("implement missing part"),
                })
            }
            ast::Expr::Unary(op, inner) => {
                let v = Self::eval_const_expr(inner)?;
                Some(match op {
                    ast::UnaryOp::Neg => v.wrapping_neg(),
                    ast::UnaryOp::Pos => v,
                    _ => return None,
                })
            }
            _ => None,
        }
    }

    /// Resolve an operand that must be a compile-time integer immediate, as
    /// required by `cp.async`'s `cp-size` and `cp.async.wait_group`'s `n`.
    pub(super) fn resolve_const_u32(
        &self,
        op: &AstOperand,
        instruction: &str,
        reason: &'static str,
    ) -> LowerResult<u32> {
        let invalid = || LowerError::InvalidOperand {
            instruction: instruction.to_string(),
            operand: format!("{:?}", op),
            reason,
        };
        let val = match self.resolve_operand(op)? {
            Operand::ImmI64(v) => v,
            Operand::ImmU64(v) => v as i64,
            _ => return Err(invalid()),
        };
        u32::try_from(val).map_err(|_| invalid())
    }

    /// Resolve destination register (must not be a special register)
    pub(super) fn resolve_dst(&self, op: &AstOperand) -> LowerResult<RegId> {
        match op {
            AstOperand::Ident(name) => {
                let name_str = name.to_string();
                // Check if it's a special register
                if SpecialRegKind::from_name(&name_str).is_some() {
                    return Err(LowerError::SpecialRegAsDestination {
                        instruction: "destination".to_string(),
                        register: name_str,
                    });
                }
                self.resolve_register(&name_str)
            }
            _ => Err(LowerError::InvalidOperand {
                instruction: "instruction".to_string(),
                operand: format!("{:?}", op),
                reason: "destination must be a register",
            }),
        }
    }

    /// Resolve a vector-store source list, e.g. `{%f1, %f2, 0f00000000, %f4}`.
    /// Unlike `resolve_dst_vector`, elements may be any operand
    /// `resolve_operand` accepts (immediates too), since a store reads them.
    pub(super) fn resolve_operand_vector(&self, op: &AstOperand) -> LowerResult<Vec<Operand>> {
        match op {
            AstOperand::Vector(elems) => elems.iter().map(|e| self.resolve_operand(e)).collect(),
            _ => Ok(vec![self.resolve_operand(op)?]),
        }
    }

    /// Resolve a vector of destination registers
    pub(super) fn resolve_dst_vector(&self, op: &AstOperand) -> LowerResult<Vec<RegId>> {
        match op {
            AstOperand::Vector(regs) => {
                let mut result = Vec::with_capacity(regs.len());
                for reg_op in regs {
                    match reg_op {
                        AstOperand::Ident(name) => {
                            let name_str = name.to_string();
                            result.push(self.resolve_register(&name_str)?);
                        }
                        _ => {
                            return Err(LowerError::InvalidOperand {
                                instruction: "vector load".to_string(),
                                operand: format!("{:?}", reg_op),
                                reason: "vector element must be a register",
                            });
                        }
                    }
                }
                Ok(result)
            }
            AstOperand::Ident(name) => {
                // Single register - return as single-element vector
                let name_str = name.to_string();
                Ok(vec![self.resolve_register(&name_str)?])
            }
            _ => Err(LowerError::InvalidOperand {
                instruction: "vector load".to_string(),
                operand: format!("{:?}", op),
                reason: "destination must be a register or vector of registers",
            }),
        }
    }

    /// Resolve a predicate guard
    pub(super) fn resolve_predicate(&self, pred: &ast::Predicate) -> LowerResult<Predicate> {
        let name_str = pred.reg.to_string();
        let reg = self.resolve_register(&name_str)?;
        Ok(Predicate {
            reg,
            negated: pred.negated,
        })
    }

    /// Convert AST memory space to lowered memory space. Generic (spaceless)
    /// and unmodeled spaces are rejected: spaces are separate here, so
    /// defaulting to global would access the wrong memory.
    pub(super) fn convert_space(
        &self,
        space: Option<StateSpace>,
        instruction: &str,
    ) -> LowerResult<MemSpace> {
        match space {
            Some(StateSpace::Global) => Ok(MemSpace::Global),
            Some(StateSpace::Shared) => Ok(MemSpace::Shared),
            Some(StateSpace::Local) => Ok(MemSpace::Local),
            Some(StateSpace::Param) => Ok(MemSpace::Param),
            Some(StateSpace::Const) => Ok(MemSpace::Const),
            Some(other) => Err(unsupported(
                instruction,
                format!("state space {:?} is not modeled", other),
            )),
            None => Err(unsupported(
                instruction,
                "generic (spaceless) memory access - the state space must be explicit",
            )),
        }
    }

    /// Convert AST comparison operator to lowered comparison operator
    pub(super) fn convert_cmp_op(&self, op: AstCmpOp) -> CmpOp {
        match op {
            AstCmpOp::Eq => CmpOp::Eq,
            AstCmpOp::Ne => CmpOp::Ne,
            AstCmpOp::Lt => CmpOp::Lt,
            AstCmpOp::Le => CmpOp::Le,
            AstCmpOp::Gt => CmpOp::Gt,
            AstCmpOp::Ge => CmpOp::Ge,
            AstCmpOp::Lo => CmpOp::Lo,
            AstCmpOp::Ls => CmpOp::Ls,
            AstCmpOp::Hi => CmpOp::Hi,
            AstCmpOp::Hs => CmpOp::Hs,
            AstCmpOp::Equ => CmpOp::Equ,
            AstCmpOp::Neu => CmpOp::Neu,
            AstCmpOp::Ltu => CmpOp::Ltu,
            AstCmpOp::Leu => CmpOp::Leu,
            AstCmpOp::Gtu => CmpOp::Gtu,
            AstCmpOp::Geu => CmpOp::Geu,
            AstCmpOp::Num => CmpOp::Num,
            AstCmpOp::Nan => CmpOp::Nan,
        }
    }

    /// Convert AST shuffle mode to lowered shuffle mode
    pub(super) fn convert_shfl_mode(&self, mode: AstShflMode) -> ShflMode {
        match mode {
            AstShflMode::Up => ShflMode::Up,
            AstShflMode::Down => ShflMode::Down,
            AstShflMode::Bfly => ShflMode::Bfly,
            AstShflMode::Idx => ShflMode::Idx,
        }
    }

    /// Convert AST mul mode to lowered mul mode
    pub(super) fn convert_mul_mode(&self, mode: MulMode) -> LoweredMulMode {
        match mode {
            MulMode::Hi => LoweredMulMode::Hi,
            MulMode::Lo => LoweredMulMode::Lo,
            MulMode::Wide => LoweredMulMode::Wide,
        }
    }

    // =========================================================================
    // Type Checking Helpers
    // =========================================================================

    /// Check operand/instruction type compatibility per PTX 9.4: `.bX` matches
    /// any same-size type, signed/unsigned of one size mix, floats must match
    /// exactly.
    pub(super) fn check_operand_type(
        &self,
        resolved: &ResolvedOperand,
        expected: ScalarType,
        instruction: &str,
    ) -> LowerResult<()> {
        // Immediates are polymorphic - they take on the instruction's type
        let Some(actual) = resolved.ty else {
            return Ok(());
        };

        match check_type_compatibility(actual, expected) {
            TypeCompatibility::Compatible => Ok(()),
            TypeCompatibility::Incompatible => {
                let name = resolved
                    .name
                    .clone()
                    .unwrap_or_else(|| "operand".to_string());
                Err(LowerError::TypeMismatch {
                    register: name,
                    declared_type: actual,
                    used_as: expected,
                    instruction: instruction.to_string(),
                    hint: self.type_mismatch_hint(actual, expected),
                })
            }
        }
    }

    /// Check that a destination register's type is compatible with the instruction's type.
    pub(super) fn check_dst_type(
        &self,
        dst: &ResolvedDst,
        expected: ScalarType,
        instruction: &str,
    ) -> LowerResult<()> {
        match check_type_compatibility(dst.ty, expected) {
            TypeCompatibility::Compatible => Ok(()),
            TypeCompatibility::Incompatible => Err(LowerError::TypeMismatch {
                register: dst.name.clone(),
                declared_type: dst.ty,
                used_as: expected,
                instruction: instruction.to_string(),
                hint: self.type_mismatch_hint(dst.ty, expected),
            }),
        }
    }

    /// Relaxed type checking for ld/st/cvt instructions (PTX 9.4.1).
    /// Allows operands to be wider than the instruction type.
    /// The value will be truncated (store) or extended (load) as needed.
    pub(super) fn check_operand_type_relaxed(
        &self,
        resolved: &ResolvedOperand,
        instr_ty: ScalarType,
        instruction: &str,
    ) -> LowerResult<()> {
        // Immediates are polymorphic
        let Some(actual) = resolved.ty else {
            return Ok(());
        };

        let actual_bits = actual.bits();
        let instr_bits = instr_ty.bits();

        // Operand can be wider than instruction type (will be truncated/extended)
        if actual_bits >= instr_bits {
            // Still check type category compatibility (no float<->int mixing)
            // unless one is a bit-type
            if actual.is_bits_type() || instr_ty.is_bits_type() {
                return Ok(());
            }
            // Float<->int mixing is still invalid
            if actual.is_float() != instr_ty.is_float() {
                let name = resolved
                    .name
                    .clone()
                    .unwrap_or_else(|| "operand".to_string());
                return Err(LowerError::TypeMismatch {
                    register: name,
                    declared_type: actual,
                    used_as: instr_ty,
                    instruction: instruction.to_string(),
                    hint: "Cannot mix float and integer types; use cvt for conversion".to_string(),
                });
            }
            return Ok(());
        }

        // Operand is narrower than instruction type - not allowed even with relaxed rules
        let name = resolved
            .name
            .clone()
            .unwrap_or_else(|| "operand".to_string());
        Err(LowerError::TypeMismatch {
            register: name,
            declared_type: actual,
            used_as: instr_ty,
            instruction: instruction.to_string(),
            hint: format!(
                "Operand is {} bits but instruction requires at least {} bits",
                actual_bits, instr_bits
            ),
        })
    }

    /// Relaxed type checking for destination registers (ld instructions).
    /// Destination can be wider than instruction type (value will be extended).
    pub(super) fn check_dst_type_relaxed(
        &self,
        dst: &ResolvedDst,
        instr_ty: ScalarType,
        instruction: &str,
    ) -> LowerResult<()> {
        let dst_bits = dst.ty.bits();
        let instr_bits = instr_ty.bits();

        // Destination can be wider (value will be extended)
        if dst_bits >= instr_bits {
            // Check type category compatibility
            if dst.ty.is_bits_type() || instr_ty.is_bits_type() {
                return Ok(());
            }
            if dst.ty.is_float() != instr_ty.is_float() {
                return Err(LowerError::TypeMismatch {
                    register: dst.name.clone(),
                    declared_type: dst.ty,
                    used_as: instr_ty,
                    instruction: instruction.to_string(),
                    hint: "Cannot mix float and integer types; use cvt for conversion".to_string(),
                });
            }
            return Ok(());
        }

        // Destination is narrower - not allowed
        Err(LowerError::TypeMismatch {
            register: dst.name.clone(),
            declared_type: dst.ty,
            used_as: instr_ty,
            instruction: instruction.to_string(),
            hint: format!(
                "Destination register is {} bits but instruction produces {} bits",
                dst_bits, instr_bits
            ),
        })
    }

    /// Generate a helpful hint for type mismatch errors
    pub(super) fn type_mismatch_hint(&self, actual: ScalarType, expected: ScalarType) -> String {
        // Float<->int mismatch
        if actual.is_float() && expected.is_integer() {
            return format!(
                "Use cvt.{}.{} to convert float to integer",
                crate::ir::types::format_scalar_type(expected),
                crate::ir::types::format_scalar_type(actual)
            );
        }
        if actual.is_integer() && expected.is_float() {
            return format!(
                "Use cvt.{}.{} to convert integer to float",
                crate::ir::types::format_scalar_type(expected),
                crate::ir::types::format_scalar_type(actual)
            );
        }

        // Size mismatch
        if actual.bits() != expected.bits() {
            return format!(
                "Type size mismatch: {} is {} bits, expected {} bits",
                crate::ir::types::format_scalar_type(actual),
                actual.bits(),
                expected.bits()
            );
        }

        "Declare register with compatible type".to_string()
    }
}

impl Default for LoweringContext {
    fn default() -> Self {
        Self::new()
    }
}

/// Parse a `ScalarType` from a modifier string (e.g., "f16", "f32", "b16").
pub(super) fn parse_scalar_type_modifier(modifier: &DottedIdent) -> Option<ScalarType> {
    let ascii = modifier.to_ascii_string();
    ScalarType::from_ascii(&ascii)
}

/// Resolve an operand that must be a memory address (`[addr]`, or a bare
/// register/immediate as a zero-offset address) to `(base, offset)`. Shared
/// by the tensormap/TMA lowerings below.
pub(super) fn resolve_addr_operand(
    ctx: &LoweringContext,
    op: &AstOperand,
) -> LowerResult<(Operand, i64)> {
    match op {
        AstOperand::Address(a) => Ok((ctx.resolve_address(a)?, ctx.get_address_offset(a))),
        other => Ok((ctx.resolve_operand(other)?, 0)),
    }
}
