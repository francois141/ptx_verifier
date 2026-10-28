//! Symbol table for PTX lowering: tracks register declarations, labels,
//! parameters, and shared memory allocations.

use std::collections::HashMap;
use std::fmt;

use crate::frontend::ast::ScalarType;
use id_collections::{IdVec, id_type};

use crate::ir::InstrId;
use crate::ir::types::{RegClass, RegCounts};
use crate::lower::{LowerError, LowerResult};

/// The kind of symbol in the PTX namespace
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SymbolKind {
    Register,
    Parameter,
    Label,
    SharedVariable,
    LocalVariable,
    GlobalVariable,
}

impl fmt::Display for SymbolKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Register => write!(f, "register"),
            Self::Parameter => write!(f, "parameter"),
            Self::Label => write!(f, "label"),
            Self::SharedVariable => write!(f, "shared variable"),
            Self::LocalVariable => write!(f, "local variable"),
            Self::GlobalVariable => write!(f, "global variable"),
        }
    }
}

/// Index of a register within its class
#[id_type]
pub struct RegIndex(pub u32);

impl fmt::Display for RegIndex {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// A resolved register reference
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct RegId {
    pub class: RegClass,
    pub index: RegIndex,
}

impl RegId {
    /// Create a new RegId
    pub fn new(class: RegClass, index: u32) -> Self {
        Self {
            class,
            index: RegIndex(index),
        }
    }
}

impl fmt::Display for RegId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}[{}]", self.class, self.index)
    }
}

/// Parameter index
#[id_type]
pub struct ParamId(pub u32);

impl fmt::Display for ParamId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "param:{}", self.0)
    }
}

/// One `{}` block's label scope: PTX scopes labels to their block, so same-named
/// labels in sibling blocks are independent (nvcc's per-block spin-wait idiom).
/// Labels are the only block-scoped kind; all others share `SymbolTable::reserve_name`.
#[id_type]
pub struct LabelScopeId(pub u32);

/// Information about a declared register
#[derive(Debug, Clone)]
pub struct RegInfo {
    pub id: RegId,
    pub declared_type: ScalarType,
}

/// Special register kinds (thread-dependent values known at runtime)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum SpecialRegKind {
    // Thread identification
    TidX,
    TidY,
    TidZ,
    NtidX,
    NtidY,
    NtidZ,
    CtaidX,
    CtaidY,
    CtaidZ,
    NctaidX,
    NctaidY,
    NctaidZ,
    // Cluster
    ClusterCtaidX,
    ClusterCtaidY,
    ClusterCtaidZ,
    ClusterNctaidX,
    ClusterNctaidY,
    ClusterNctaidZ,
    ClusterCtarank,
    ClusterNctarank,
    ClusteridX,
    ClusteridY,
    ClusteridZ,
    NclusteridX,
    NclusteridY,
    NclusteridZ,
    IsExplicitCluster,
    // Warp-level
    LaneId,
    WarpId,
    NWarpId,
    LanemaskEq,
    LanemaskLt,
    LanemaskLe,
    LanemaskGt,
    LanemaskGe,
    // SM identification
    SmId,
    NSmId,
    // Grid
    GridId,
    // Clock
    Clock,
    Clock64,
    // Dynamic shared memory
    DynamicSmemSize,
}

impl SpecialRegKind {
    /// Get the type of this special register
    pub fn ty(&self) -> ScalarType {
        match self {
            // 32-bit unsigned
            Self::TidX
            | Self::TidY
            | Self::TidZ
            | Self::NtidX
            | Self::NtidY
            | Self::NtidZ
            | Self::CtaidX
            | Self::CtaidY
            | Self::CtaidZ
            | Self::NctaidX
            | Self::NctaidY
            | Self::NctaidZ
            | Self::ClusterCtaidX
            | Self::ClusterCtaidY
            | Self::ClusterCtaidZ
            | Self::ClusterNctaidX
            | Self::ClusterNctaidY
            | Self::ClusterNctaidZ
            | Self::ClusterCtarank
            | Self::ClusterNctarank
            | Self::ClusteridX
            | Self::ClusteridY
            | Self::ClusteridZ
            | Self::NclusteridX
            | Self::NclusteridY
            | Self::NclusteridZ
            | Self::LaneId
            | Self::WarpId
            | Self::NWarpId
            | Self::LanemaskEq
            | Self::LanemaskLt
            | Self::LanemaskLe
            | Self::LanemaskGt
            | Self::LanemaskGe
            | Self::Clock
            | Self::SmId
            | Self::NSmId
            | Self::GridId
            | Self::DynamicSmemSize => ScalarType::U32,
            // 64-bit unsigned
            Self::Clock64 => ScalarType::U64,
            Self::IsExplicitCluster => ScalarType::Pred,
        }
    }

    /// Parse from PTX name (with or without % prefix)
    pub fn from_name(name: &str) -> Option<Self> {
        let name = name.strip_prefix('%').unwrap_or(name);
        Some(match name {
            "tid.x" => Self::TidX,
            "tid.y" => Self::TidY,
            "tid.z" => Self::TidZ,
            "ntid.x" => Self::NtidX,
            "ntid.y" => Self::NtidY,
            "ntid.z" => Self::NtidZ,
            "ctaid.x" => Self::CtaidX,
            "ctaid.y" => Self::CtaidY,
            "ctaid.z" => Self::CtaidZ,
            "nctaid.x" => Self::NctaidX,
            "nctaid.y" => Self::NctaidY,
            "nctaid.z" => Self::NctaidZ,
            "cluster_ctaid.x" => Self::ClusterCtaidX,
            "cluster_ctaid.y" => Self::ClusterCtaidY,
            "cluster_ctaid.z" => Self::ClusterCtaidZ,
            "cluster_nctaid.x" => Self::ClusterNctaidX,
            "cluster_nctaid.y" => Self::ClusterNctaidY,
            "cluster_nctaid.z" => Self::ClusterNctaidZ,
            "cluster_ctarank" => Self::ClusterCtarank,
            "cluster_nctarank" => Self::ClusterNctarank,
            "clusterid.x" => Self::ClusteridX,
            "clusterid.y" => Self::ClusteridY,
            "clusterid.z" => Self::ClusteridZ,
            "nclusterid.x" => Self::NclusteridX,
            "nclusterid.y" => Self::NclusteridY,
            "nclusterid.z" => Self::NclusteridZ,
            "is_explicit_cluster" => Self::IsExplicitCluster,
            "laneid" => Self::LaneId,
            "warpid" => Self::WarpId,
            "nwarpid" => Self::NWarpId,
            "lanemask_eq" => Self::LanemaskEq,
            "lanemask_lt" => Self::LanemaskLt,
            "lanemask_le" => Self::LanemaskLe,
            "lanemask_gt" => Self::LanemaskGt,
            "lanemask_ge" => Self::LanemaskGe,
            "clock" => Self::Clock,
            "clock64" => Self::Clock64,
            "smid" => Self::SmId,
            "nsmid" => Self::NSmId,
            "gridid" => Self::GridId,
            "dynamic_smem_size" => Self::DynamicSmemSize,
            _ => return None,
        })
    }

    /// Get the PTX name for this special register
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::TidX => "%tid.x",
            Self::TidY => "%tid.y",
            Self::TidZ => "%tid.z",
            Self::NtidX => "%ntid.x",
            Self::NtidY => "%ntid.y",
            Self::NtidZ => "%ntid.z",
            Self::CtaidX => "%ctaid.x",
            Self::CtaidY => "%ctaid.y",
            Self::CtaidZ => "%ctaid.z",
            Self::NctaidX => "%nctaid.x",
            Self::NctaidY => "%nctaid.y",
            Self::NctaidZ => "%nctaid.z",
            Self::ClusterCtaidX => "%cluster_ctaid.x",
            Self::ClusterCtaidY => "%cluster_ctaid.y",
            Self::ClusterCtaidZ => "%cluster_ctaid.z",
            Self::ClusterNctaidX => "%cluster_nctaid.x",
            Self::ClusterNctaidY => "%cluster_nctaid.y",
            Self::ClusterNctaidZ => "%cluster_nctaid.z",
            Self::ClusterCtarank => "%cluster_ctarank",
            Self::ClusterNctarank => "%cluster_nctarank",
            Self::ClusteridX => "%clusterid.x",
            Self::ClusteridY => "%clusterid.y",
            Self::ClusteridZ => "%clusterid.z",
            Self::NclusteridX => "%nclusterid.x",
            Self::NclusteridY => "%nclusterid.y",
            Self::NclusteridZ => "%nclusterid.z",
            Self::IsExplicitCluster => "%is_explicit_cluster",
            Self::LaneId => "%laneid",
            Self::WarpId => "%warpid",
            Self::NWarpId => "%nwarpid",
            Self::LanemaskEq => "%lanemask_eq",
            Self::LanemaskLt => "%lanemask_lt",
            Self::LanemaskLe => "%lanemask_le",
            Self::LanemaskGt => "%lanemask_gt",
            Self::LanemaskGe => "%lanemask_ge",
            Self::Clock => "%clock",
            Self::Clock64 => "%clock64",
            Self::SmId => "%smid",
            Self::NSmId => "%nsmid",
            Self::GridId => "%gridid",
            Self::DynamicSmemSize => "%dynamic_smem_size",
        }
    }
}

/// Information about a shared memory allocation
#[derive(Debug, Clone)]
pub struct SharedMemInfo {
    pub offset: u64,
    pub size_bytes: u64,
    pub is_extern: bool,
}

/// A `.extern .shared` declaration awaiting placement: extern names alias the
/// dynamic window the CUDA ABI bases *after* all static `.shared` allocations,
/// not all known yet, so `finalize_shared_layout` assigns the offset later.
#[derive(Debug, Clone)]
struct PendingExternShared {
    name: String,
    /// Declared alignment, already raised to the element size.
    alignment: u64,
}

/// Placement state of the `.extern .shared` (dynamic shared) window.
#[derive(Debug, Clone)]
enum ExternSharedLayout {
    /// Declarations are still being collected; extern variables are recorded
    /// here, unplaced, and are absent from `shared_vars`.
    Collecting(Vec<PendingExternShared>),
    /// All static declarations are known; every extern variable is present
    /// in `shared_vars` at offset `extern_base`.
    Finalized { extern_base: u64 },
}

/// Information about a function-scope local memory allocation (e.g. the
/// `__local_depot` stack array nvcc emits for spilled locals).
#[derive(Debug, Clone)]
pub struct LocalMemInfo {
    pub offset: u64,
    pub size_bytes: u64,
}

/// Information about a module-scope `.global` variable (e.g. values set by the
/// host via `cudaMemcpyToSymbol`). Assigned addresses in a reserved region so
/// they cannot collide with caller-chosen input array addresses.
#[derive(Debug, Clone)]
pub struct GlobalVarInfo {
    pub addr: u64,
    pub size_bytes: u64,
}

/// Where a kernel parameter lives in param space (`mov.b64 %rd, param` takes
/// its address): offsets from 0 in declaration order, each aligned as declared.
#[derive(Debug, Clone, Copy)]
pub struct ParamSlot {
    pub offset: u64,
    pub size: u64,
    pub layout: ParamLayout,
}

/// A scalar parameter is read by value (`LoadParam`); an aggregate
/// (`.param .b8 name[N]`, a by-value struct) by byte address.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ParamLayout {
    Scalar,
    Aggregate,
}

/// Where shared memory sits in the generic address space: `cvta.shared.u64`
/// adds it and `cvta.to.shared.u64` subtracts it. Aligned far beyond any
/// alignment rounding a kernel applies to a generic pointer, and above every
/// global array, so generic shared and global addresses never coincide.
pub const SHARED_GENERIC_BASE: u64 = 0x6000_0000_0000_0000;

/// The shared address a `.shared` operand names: `.shared` addressing keeps
/// only the low 32 bits, and the generic window sits on a 2^32 boundary, so a
/// generic shared address (ThunderKittens passes `&smem` to `tcgen05.alloc`)
/// names the byte at its offset; any other address is taken as given.
pub fn shared_operand_addr(addr: u64) -> u64 {
    match addr.checked_sub(SHARED_GENERIC_BASE) {
        Some(offset) if offset < 1 << 32 => offset,
        _ => addr,
    }
}

/// Where kernel parameters sit in the generic address space (`cvta.param.u64`),
/// below the shared window; a TMA tensor-map operand there names a parameter's map.
pub const PARAM_GENERIC_BASE: u64 = 0x5000_0000_0000_0000;

/// Base address for module-scope `.global` variables; `Interpreter::new` rejects
/// configs whose arrays overlap `[MODULE_GLOBAL_BASE, + module_global_size())`.
pub const MODULE_GLOBAL_BASE: u64 = 0x7000_0000_0000_0000;

/// Round `offset` up to a multiple of `alignment` (a power of two), `None` on
/// u64 overflow (release-active). Callers pass at least the element size, so
/// every lowering-assigned address is naturally aligned.
fn align_up(offset: u64, alignment: u64) -> Option<u64> {
    // PTX requires `.align` values to be powers of two (and every scalar
    // element size is one); the bit trick below is wrong otherwise.
    debug_assert!(
        alignment.is_power_of_two(),
        "alignment {} is not a power of two",
        alignment
    );
    Some(offset.checked_add(alignment - 1)? & !(alignment - 1))
}

/// The loud rejection for a declaration whose size or placement overflows u64
/// (release-active): `.shared .u32 A[0x4000000000000001]` would otherwise wrap
/// to byte size 4 and be silently mismodeled.
fn size_overflow(kind: &str, name: &str) -> LowerError {
    LowerError::VariableSizeOverflow {
        what: format!("{} '{}'", kind, name),
    }
}

/// Symbol table built during lowering
#[derive(Debug, Clone)]
pub struct SymbolTable {
    /// All declared names mapped to their kind (for duplicate checking).
    /// PTX uses a single namespace for all identifiers within a function.
    all_names: HashMap<String, SymbolKind>,

    /// Register name → info
    registers: HashMap<String, RegInfo>,
    /// Count of registers per class
    reg_counts: [u32; RegClass::COUNT],

    /// Parameter name → id; ids are dense in declaration order.
    params: HashMap<String, ParamId>,
    /// Each parameter's place in param space, indexed by `ParamId`.
    param_slots: IdVec<ParamId, ParamSlot>,

    /// Label name → instruction PC, one inner map per label scope (see
    /// `LabelScopeId`).
    labels: HashMap<LabelScopeId, HashMap<String, InstrId>>,
    /// Each label scope's enclosing scope (`None` for the root). Indexed by
    /// `LabelScopeId`; scope 0 (`ROOT_LABEL_SCOPE`) is always the function
    /// body's top-level scope, seeded in `new()`.
    label_scope_parents: IdVec<LabelScopeId, Option<LabelScopeId>>,

    /// Shared memory allocations. Extern variables only appear here once
    /// `finalize_shared_layout` has placed them.
    shared_vars: HashMap<String, SharedMemInfo>,
    /// Total static shared memory size (packing cursor for statics). The
    /// dynamic extern window begins at `extern_shared_base()`, at or after
    /// this offset.
    shared_mem_size: u64,
    /// Has extern shared memory
    has_extern_shared: bool,
    /// Placement state of the `.extern .shared` window
    extern_layout: ExternSharedLayout,

    /// Function-scope local memory allocations (per-thread space)
    local_vars: HashMap<String, LocalMemInfo>,
    /// Total local memory size per thread
    local_mem_size: u64,

    /// Module-scope `.global` variables
    global_vars: HashMap<String, GlobalVarInfo>,
    /// Bytes of the reserved module-global region allocated so far
    module_global_size: u64,
}

impl SymbolTable {
    /// The function body's top-level label scope - always the first scope
    /// created (`new()` seeds it with no parent).
    pub const ROOT_LABEL_SCOPE: LabelScopeId = LabelScopeId(0);

    pub fn new() -> Self {
        let mut label_scope_parents = IdVec::new();
        let root = label_scope_parents.push(None);
        debug_assert_eq!(root, Self::ROOT_LABEL_SCOPE);

        Self {
            all_names: HashMap::new(),
            registers: HashMap::new(),
            reg_counts: [0; RegClass::COUNT],
            params: HashMap::new(),
            param_slots: IdVec::new(),
            labels: HashMap::new(),
            label_scope_parents,
            shared_vars: HashMap::new(),
            shared_mem_size: 0,
            has_extern_shared: false,
            extern_layout: ExternSharedLayout::Collecting(Vec::new()),
            local_vars: HashMap::new(),
            local_mem_size: 0,
            global_vars: HashMap::new(),
            module_global_size: 0,
        }
    }

    /// Reserve a name in the global namespace.
    /// Returns an error if the name is already in use.
    fn reserve_name(&mut self, name: &str, kind: SymbolKind) -> LowerResult<()> {
        if let Some(&existing) = self.all_names.get(name) {
            return Err(LowerError::DuplicateName {
                name: name.to_string(),
                existing,
                attempted: kind,
            });
        }
        self.all_names.insert(name.to_string(), kind);
        Ok(())
    }

    /// Declare a register or range (`%r<100>` declares %r0 through %r99),
    /// returning the RegId of the first one.
    pub fn declare_register(
        &mut self,
        base_name: &str,
        ty: ScalarType,
        count: u32,
    ) -> Result<RegId, LowerError> {
        let class = RegClass::from_scalar_type(ty);

        // PTX scopes declarations to blocks, but we flatten them. nvcc
        // re-declares helper registers like `temp_param_reg` in every callseq
        // block, so an identical single-register re-declaration is idempotent.
        if count == 1
            && let Some(existing) = self.registers.get(base_name)
            && existing.declared_type == ty
        {
            return Ok(existing.id);
        }

        let base_index = self.reg_counts[class as usize];

        // Parse the base name (strip angle brackets if present)
        let base = base_name.trim_end_matches(|c: char| c == '<' || c == '>' || c.is_ascii_digit());

        for i in 0..count {
            let name = if count == 1 {
                base_name.to_string()
            } else {
                format!("{}{}", base, i)
            };

            self.reserve_name(&name, SymbolKind::Register)?;

            let id = RegId::new(class, base_index + i);
            self.registers.insert(
                name,
                RegInfo {
                    id,
                    declared_type: ty,
                },
            );
        }

        self.reg_counts[class as usize] += count;
        Ok(RegId::new(class, base_index))
    }

    /// Declare a kernel parameter of `size` bytes, placed after the previous
    /// one at `alignment` (a power of two). Returns its ParamId.
    pub fn declare_param(
        &mut self,
        name: &str,
        size: u64,
        alignment: u64,
        layout: ParamLayout,
    ) -> LowerResult<ParamId> {
        self.reserve_name(name, SymbolKind::Parameter)?;

        // Every declared slot's end was checked to fit in u64.
        let end_of_previous = match self.param_slots.iter().last() {
            Some((_, previous)) => previous.offset + previous.size,
            None => 0,
        };

        let offset = match align_up(end_of_previous, alignment.max(1)) {
            Some(offset) => offset,
            None => return Err(size_overflow("parameter", name)),
        };

        if offset.checked_add(size).is_none() {
            return Err(size_overflow("parameter", name));
        }

        let slot = ParamSlot {
            offset,
            size,
            layout,
        };
        let id = self.param_slots.push(slot);
        self.params.insert(name.to_string(), id);
        Ok(id)
    }

    pub fn param_slot(&self, id: ParamId) -> ParamSlot {
        self.param_slots[id]
    }

    /// Create a new label scope nested inside `parent` (one per `{}` block
    /// entered while lowering) and return its id.
    pub fn push_label_scope(&mut self, parent: LabelScopeId) -> LabelScopeId {
        self.label_scope_parents.push(Some(parent))
    }

    /// Declare a label at the given PC within `scope`. Cross-kind collisions use
    /// the flat `reserve_name` namespace; a same-named label is a redeclaration
    /// only if visible from `scope` (declared there or in an enclosing scope).
    pub fn declare_label(
        &mut self,
        name: &str,
        scope: LabelScopeId,
        pc: InstrId,
    ) -> LowerResult<()> {
        match self.all_names.get(name) {
            Some(SymbolKind::Label) => {}
            Some(&existing) => {
                return Err(LowerError::DuplicateName {
                    name: name.to_string(),
                    existing,
                    attempted: SymbolKind::Label,
                });
            }
            None => {
                self.all_names.insert(name.to_string(), SymbolKind::Label);
            }
        }

        let mut cur = Some(scope);
        while let Some(s) = cur {
            if self.labels.get(&s).is_some_and(|m| m.contains_key(name)) {
                return Err(LowerError::DuplicateName {
                    name: name.to_string(),
                    existing: SymbolKind::Label,
                    attempted: SymbolKind::Label,
                });
            }
            cur = self.label_scope_parents[s];
        }

        self.labels
            .entry(scope)
            .or_default()
            .insert(name.to_string(), pc);
        Ok(())
    }

    /// Declare a shared memory variable: statics are packed in declaration
    /// order; `.extern .shared` ones are only recorded, since their window's
    /// offset is unknown until `finalize_shared_layout` runs.
    pub fn declare_shared(
        &mut self,
        name: &str,
        element_ty: ScalarType,
        num_elements: u64,
        is_extern: bool,
        alignment: u64,
    ) -> LowerResult<()> {
        if matches!(self.extern_layout, ExternSharedLayout::Finalized { .. }) {
            panic!("declare_shared({name}) after finalize_shared_layout");
        }

        self.reserve_name(name, SymbolKind::SharedVariable)?;

        let elem_size = (element_ty.bits() as u64).div_ceil(8);
        let alignment = alignment.max(elem_size);

        if is_extern {
            self.has_extern_shared = true;
            let ExternSharedLayout::Collecting(pending) = &mut self.extern_layout else {
                unreachable!("state checked above");
            };
            pending.push(PendingExternShared {
                name: name.to_string(),
                alignment,
            });
            return Ok(());
        }

        let size_bytes = num_elements
            .checked_mul(elem_size)
            .ok_or_else(|| size_overflow("shared variable", name))?;
        let offset = align_up(self.shared_mem_size, alignment)
            .ok_or_else(|| size_overflow("shared variable", name))?;
        let end = offset
            .checked_add(size_bytes)
            .ok_or_else(|| size_overflow("shared variable", name))?;

        self.shared_vars.insert(
            name.to_string(),
            SharedMemInfo {
                offset,
                size_bytes,
                is_extern: false,
            },
        );

        self.shared_mem_size = end;
        Ok(())
    }

    /// Place the `.extern .shared` window after all static allocations (aligned
    /// to 16 and every extern's alignment). Call exactly once, after collection and
    /// before resolving shared addresses; errors if the base overflows u64.
    pub fn finalize_shared_layout(&mut self) -> LowerResult<()> {
        let pending = match &mut self.extern_layout {
            ExternSharedLayout::Collecting(pending) => std::mem::take(pending),
            ExternSharedLayout::Finalized { .. } => {
                panic!("finalize_shared_layout called twice")
            }
        };

        let alignment = pending.iter().fold(16, |a, e| a.max(e.alignment));
        let extern_base = align_up(self.shared_mem_size, alignment).ok_or_else(|| {
            LowerError::VariableSizeOverflow {
                what: format!(
                    ".extern .shared window (based after {:#x} static shared bytes)",
                    self.shared_mem_size
                ),
            }
        })?;

        for e in pending {
            self.shared_vars.insert(
                e.name,
                SharedMemInfo {
                    offset: extern_base,
                    size_bytes: 0, // Size supplied at launch (dynamic shared bytes)
                    is_extern: true,
                },
            );
        }

        self.extern_layout = ExternSharedLayout::Finalized { extern_base };
        Ok(())
    }

    /// Base offset of the dynamic (`.extern .shared`) window, or `None` if the
    /// kernel declares no extern shared memory. Panics if
    /// `finalize_shared_layout` has not run.
    pub fn extern_shared_base(&self) -> Option<u64> {
        match self.extern_layout {
            ExternSharedLayout::Finalized { extern_base } => {
                self.has_extern_shared.then_some(extern_base)
            }
            ExternSharedLayout::Collecting(_) => {
                panic!("extern_shared_base read before finalize_shared_layout")
            }
        }
    }

    /// Declare a function-scope local memory variable (per-thread space)
    pub fn declare_local(
        &mut self,
        name: &str,
        element_ty: ScalarType,
        num_elements: u64,
        alignment: u64,
    ) -> LowerResult<()> {
        self.reserve_name(name, SymbolKind::LocalVariable)?;

        let elem_size = (element_ty.bits() as u64).div_ceil(8);
        let alignment = alignment.max(elem_size).max(1);
        let size_bytes = num_elements
            .checked_mul(elem_size)
            .ok_or_else(|| size_overflow("local variable", name))?;
        let offset = align_up(self.local_mem_size, alignment)
            .ok_or_else(|| size_overflow("local variable", name))?;
        let end = offset
            .checked_add(size_bytes)
            .ok_or_else(|| size_overflow("local variable", name))?;

        self.local_vars
            .insert(name.to_string(), LocalMemInfo { offset, size_bytes });

        self.local_mem_size = end;
        Ok(())
    }

    /// Declare a module-scope `.global` variable, assigning it an address in
    /// the reserved module-global region.
    pub fn declare_global_var(
        &mut self,
        name: &str,
        element_ty: ScalarType,
        num_elements: u64,
        alignment: u64,
    ) -> LowerResult<()> {
        self.reserve_name(name, SymbolKind::GlobalVariable)?;

        let elem_size = (element_ty.bits() as u64).div_ceil(8);
        let alignment = alignment.max(elem_size).max(1);
        let size_bytes = num_elements
            .checked_mul(elem_size)
            .ok_or_else(|| size_overflow("global variable", name))?;
        let offset = align_up(self.module_global_size, alignment)
            .ok_or_else(|| size_overflow("global variable", name))?;
        let end = offset
            .checked_add(size_bytes)
            .ok_or_else(|| size_overflow("global variable", name))?;
        // The variable must also fit above the reserved base: this establishes
        // once that the window end `Interpreter::new` computes is representable.
        if MODULE_GLOBAL_BASE.checked_add(end).is_none() {
            return Err(size_overflow("global variable", name));
        }

        self.global_vars.insert(
            name.to_string(),
            GlobalVarInfo {
                addr: MODULE_GLOBAL_BASE + offset,
                size_bytes,
            },
        );

        self.module_global_size = end;
        Ok(())
    }

    /// Look up a register, returning full info for type checking
    pub fn get_register(&self, name: &str) -> Option<&RegInfo> {
        self.registers.get(name)
    }

    /// Look up just the RegId
    pub fn resolve_register(&self, name: &str) -> Option<RegId> {
        self.registers.get(name).map(|info| info.id)
    }

    /// Look up a parameter
    pub fn get_param(&self, name: &str) -> Option<ParamId> {
        self.params.get(name).copied()
    }

    /// Look up a label, walking outward from `scope` through its enclosing
    /// blocks (real lexical scoping - see `declare_label`). A label
    /// declared in a sibling or unrelated block is correctly invisible.
    pub fn resolve_label(&self, name: &str, scope: LabelScopeId) -> Option<InstrId> {
        let mut cur = Some(scope);
        while let Some(s) = cur {
            if let Some(&pc) = self.labels.get(&s).and_then(|m| m.get(name)) {
                return Some(pc);
            }
            cur = self.label_scope_parents[s];
        }
        None
    }

    /// Look up shared memory variable
    pub fn get_shared_var(&self, name: &str) -> Option<&SharedMemInfo> {
        self.shared_vars.get(name)
    }

    /// Iterate over all shared memory variables
    pub fn shared_vars(&self) -> impl Iterator<Item = &SharedMemInfo> {
        self.shared_vars.values()
    }

    /// Iterate over all function-scope local memory variables
    pub fn local_vars(&self) -> impl Iterator<Item = &LocalMemInfo> {
        self.local_vars.values()
    }

    /// Look up a function-scope local memory variable
    pub fn get_local_var(&self, name: &str) -> Option<&LocalMemInfo> {
        self.local_vars.get(name)
    }

    /// Look up a module-scope `.global` variable
    pub fn get_global_var(&self, name: &str) -> Option<&GlobalVarInfo> {
        self.global_vars.get(name)
    }

    /// Iterate over all module-scope `.global` variables
    pub fn global_vars(&self) -> impl Iterator<Item = &GlobalVarInfo> {
        self.global_vars.values()
    }

    /// Bytes of the module-global window in use, starting at `MODULE_GLOBAL_BASE`;
    /// the window end is representable in u64 (`declare_global_var` checks it).
    pub fn module_global_size(&self) -> u64 {
        self.module_global_size
    }

    /// Get all register counts
    pub fn register_counts(&self) -> RegCounts {
        RegCounts::new(self.reg_counts)
    }

    /// Number of declared kernel parameters
    pub fn param_count(&self) -> usize {
        self.params.len()
    }

    /// Check if kernel uses dynamic (extern) shared memory
    pub fn has_extern_shared(&self) -> bool {
        self.has_extern_shared
    }

    /// Find similar register names for error suggestions
    pub fn find_similar_registers(&self, name: &str) -> Vec<String> {
        self.registers
            .keys()
            .filter(|k| levenshtein_distance(k, name) <= 2)
            .take(3)
            .cloned()
            .collect()
    }
}

impl Default for SymbolTable {
    fn default() -> Self {
        Self::new()
    }
}

/// Simple Levenshtein distance for typo suggestions
fn levenshtein_distance(a: &str, b: &str) -> usize {
    if a == b {
        return 0;
    }
    if a.is_empty() {
        return b.len();
    }
    if b.is_empty() {
        return a.len();
    }

    let a_chars: Vec<char> = a.chars().collect();
    let b_chars: Vec<char> = b.chars().collect();

    let mut prev: Vec<usize> = (0..=b_chars.len()).collect();
    let mut curr = vec![0; b_chars.len() + 1];

    for (i, ca) in a_chars.iter().enumerate() {
        curr[0] = i + 1;
        for (j, cb) in b_chars.iter().enumerate() {
            let cost = if ca == cb { 0 } else { 1 };
            curr[j + 1] = (prev[j + 1] + 1).min(curr[j] + 1).min(prev[j] + cost);
        }
        std::mem::swap(&mut prev, &mut curr);
    }

    prev[b_chars.len()]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_register_declaration() {
        let mut symbols = SymbolTable::new();
        symbols.declare_register("%r", ScalarType::U32, 10).unwrap();

        // Should have %r0 through %r9
        assert!(symbols.get_register("%r0").is_some());
        assert!(symbols.get_register("%r9").is_some());
        assert!(symbols.get_register("%r10").is_none());

        // All should be U32
        assert_eq!(
            symbols.get_register("%r5").unwrap().declared_type,
            ScalarType::U32
        );
    }

    #[test]
    fn test_single_register() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_register("%myReg", ScalarType::F32, 1)
            .unwrap();

        assert!(symbols.get_register("%myReg").is_some());
        assert_eq!(
            symbols.get_register("%myReg").unwrap().declared_type,
            ScalarType::F32
        );
    }

    #[test]
    fn test_duplicate_register_error() {
        let mut symbols = SymbolTable::new();
        symbols.declare_register("%r", ScalarType::U32, 5).unwrap();

        // Try to declare overlapping range
        let result = symbols.declare_register("%r", ScalarType::U32, 3);
        assert!(result.is_err());
    }

    #[test]
    fn test_special_registers() {
        assert_eq!(
            SpecialRegKind::from_name("%tid.x"),
            Some(SpecialRegKind::TidX)
        );
        assert_eq!(
            SpecialRegKind::from_name("tid.x"),
            Some(SpecialRegKind::TidX)
        );
        assert_eq!(
            SpecialRegKind::from_name("%laneid"),
            Some(SpecialRegKind::LaneId)
        );
        assert_eq!(SpecialRegKind::from_name("%unknown"), None);
    }

    #[test]
    fn test_labels() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        let root = SymbolTable::ROOT_LABEL_SCOPE;
        symbols
            .declare_label("LOOP", root, InstrId::from_index(10))
            .unwrap();
        symbols
            .declare_label("END", root, InstrId::from_index(50))
            .unwrap();

        assert_eq!(
            symbols.resolve_label("LOOP", root),
            Some(InstrId::from_index(10))
        );
        assert_eq!(
            symbols.resolve_label("END", root),
            Some(InstrId::from_index(50))
        );
        assert_eq!(symbols.resolve_label("MISSING", root), None);
    }

    #[test]
    fn test_duplicate_label_error() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        let root = SymbolTable::ROOT_LABEL_SCOPE;
        symbols
            .declare_label("LOOP", root, InstrId::from_index(10))
            .unwrap();

        // Try to declare the same label again, in the same scope.
        let result = symbols.declare_label("LOOP", root, InstrId::from_index(20));
        assert!(result.is_err());
    }

    /// Two sibling `{}` blocks (nvcc's per-buffer `mbarrier.try_wait.parity`
    /// spin-wait idiom) legally reuse a label name: not a redeclaration.
    #[test]
    fn test_sibling_scopes_may_reuse_a_label_name() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        let root = SymbolTable::ROOT_LABEL_SCOPE;
        let block_a = symbols.push_label_scope(root);
        let block_b = symbols.push_label_scope(root);

        symbols
            .declare_label("waitLoop", block_a, InstrId::from_index(10))
            .unwrap();
        symbols
            .declare_label("waitLoop", block_b, InstrId::from_index(20))
            .unwrap();

        assert_eq!(
            symbols.resolve_label("waitLoop", block_a),
            Some(InstrId::from_index(10))
        );
        assert_eq!(
            symbols.resolve_label("waitLoop", block_b),
            Some(InstrId::from_index(20))
        );
    }

    /// Declaring the same label name twice *within the same* block is
    /// still a genuine duplicate, not two independent declarations.
    #[test]
    fn test_duplicate_label_within_the_same_scope_still_errors() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        let block = symbols.push_label_scope(SymbolTable::ROOT_LABEL_SCOPE);
        symbols
            .declare_label("foo", block, InstrId::from_index(0))
            .unwrap();
        let result = symbols.declare_label("foo", block, InstrId::from_index(1));
        assert!(result.is_err());
    }

    /// A label declared inside a nested block is not visible from the
    /// enclosing scope: visibility only flows inward.
    #[test]
    fn test_label_not_visible_outside_its_own_scope() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        let root = SymbolTable::ROOT_LABEL_SCOPE;
        let block = symbols.push_label_scope(root);
        symbols
            .declare_label("inner", block, InstrId::from_index(0))
            .unwrap();

        assert_eq!(symbols.resolve_label("inner", root), None);
        assert_eq!(
            symbols.resolve_label("inner", block),
            Some(InstrId::from_index(0))
        );
    }

    /// A label declared in an enclosing scope *is* visible from a nested
    /// block - the common case (an inline-asm block's `bra` targeting a
    /// label outside it).
    #[test]
    fn test_label_visible_from_a_nested_scope() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        let root = SymbolTable::ROOT_LABEL_SCOPE;
        symbols
            .declare_label("outer", root, InstrId::from_index(0))
            .unwrap();
        let block = symbols.push_label_scope(root);

        assert_eq!(
            symbols.resolve_label("outer", block),
            Some(InstrId::from_index(0))
        );
    }

    #[test]
    fn test_duplicate_param_error() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_param("ptr", 8, 8, ParamLayout::Scalar)
            .unwrap();

        // Try to declare same param again
        let result = symbols.declare_param("ptr", 8, 8, ParamLayout::Scalar);
        assert!(result.is_err());
    }

    #[test]
    fn test_duplicate_shared_error() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("smem", ScalarType::F32, 256, false, 4)
            .unwrap();

        // Try to declare same shared var again
        let result = symbols.declare_shared("smem", ScalarType::F32, 128, false, 4);
        assert!(result.is_err());
    }

    // =========================================================================
    // Hostile declaration sizes: every packing sum/product is checked
    // =========================================================================

    /// `.shared .u32 A[0x4000000000000001]` (byte size 2^64 + 4, release-wraps
    /// to 4): every packer entry point must reject the overflow loudly.
    #[test]
    fn test_hostile_element_count_rejected_per_space() {
        let huge = 0x4000_0000_0000_0001; // * 4 bytes wraps u64 to 4
        let mut symbols = SymbolTable::new();
        assert!(matches!(
            symbols.declare_shared("a", ScalarType::U32, huge, false, 4),
            Err(LowerError::VariableSizeOverflow { .. })
        ));
        assert!(matches!(
            symbols.declare_local("b", ScalarType::U32, huge, 4),
            Err(LowerError::VariableSizeOverflow { .. })
        ));
        assert!(matches!(
            symbols.declare_global_var("c", ScalarType::U32, huge, 4),
            Err(LowerError::VariableSizeOverflow { .. })
        ));
    }

    /// Placement overflow: a size that multiplies fine can still push the
    /// packing cursor (or the module-global window end) past u64.
    #[test]
    fn test_hostile_placement_overflow_rejected() {
        // The second variable's aligned offset + size runs off the end.
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("big", ScalarType::B8, u64::MAX - 8, false, 1)
            .unwrap();
        assert!(matches!(
            symbols.declare_shared("next", ScalarType::B8, 16, false, 1),
            Err(LowerError::VariableSizeOverflow { .. })
        ));

        // A module global whose size fits u64 but whose *address range*
        // `MODULE_GLOBAL_BASE + end` does not.
        let mut symbols = SymbolTable::new();
        assert!(matches!(
            symbols.declare_global_var("d", ScalarType::B8, 0x9000_0000_0000_0001, 1),
            Err(LowerError::VariableSizeOverflow { .. })
        ));

        // The extern window's aligned base overflows past hostile statics.
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("big", ScalarType::B8, u64::MAX - 7, false, 1)
            .unwrap();
        symbols
            .declare_shared("dyn", ScalarType::B8, 1, true, 1)
            .unwrap();
        assert!(matches!(
            symbols.finalize_shared_layout(),
            Err(LowerError::VariableSizeOverflow { .. })
        ));
    }

    // =========================================================================
    // Shared memory layout: statics pack from 0, the extern window follows
    // =========================================================================

    /// The bug shape: an extern declared *before* the statics (module-level
    /// declarations are collected first) must still be placed after them.
    #[test]
    fn test_extern_shared_placed_after_statics() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("buf", ScalarType::B8, 1, true, 16)
            .unwrap();
        symbols
            .declare_shared("lut", ScalarType::F32, 64, false, 4)
            .unwrap();
        symbols.finalize_shared_layout().unwrap();

        let lut = symbols.get_shared_var("lut").unwrap();
        assert_eq!((lut.offset, lut.size_bytes), (0, 256));
        let buf = symbols.get_shared_var("buf").unwrap();
        assert!(buf.is_extern);
        assert_eq!(buf.offset, 256);
        assert_eq!(symbols.extern_shared_base(), Some(256));
    }

    /// With no statics the extern window stays at offset 0 (the pre-fix
    /// placement for every extern-only kernel in the corpus).
    #[test]
    fn test_extern_only_shared_base_zero() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("buf", ScalarType::B8, 1, true, 16)
            .unwrap();
        symbols.finalize_shared_layout().unwrap();

        assert_eq!(symbols.get_shared_var("buf").unwrap().offset, 0);
        assert_eq!(symbols.extern_shared_base(), Some(0));
    }

    /// All extern declarations alias one buffer: same base for every name,
    /// aligned to the largest declared alignment (at least 16).
    #[test]
    fn test_extern_shared_common_base_and_alignment() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("a", ScalarType::B8, 1, true, 4)
            .unwrap();
        symbols
            .declare_shared("b", ScalarType::B8, 1, true, 128)
            .unwrap();
        // 20 bytes of statics; the window rounds up to the 128 boundary.
        symbols
            .declare_shared("lut", ScalarType::F32, 5, false, 4)
            .unwrap();
        symbols.finalize_shared_layout().unwrap();

        assert_eq!(symbols.extern_shared_base(), Some(128));
        assert_eq!(symbols.get_shared_var("a").unwrap().offset, 128);
        assert_eq!(symbols.get_shared_var("b").unwrap().offset, 128);
    }

    /// Even a byte-aligned extern window is based at a 16-byte boundary.
    #[test]
    fn test_extern_shared_base_min_16_alignment() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("buf", ScalarType::B8, 1, true, 1)
            .unwrap();
        symbols
            .declare_shared("x", ScalarType::U32, 1, false, 4)
            .unwrap();
        symbols.finalize_shared_layout().unwrap();

        assert_eq!(symbols.extern_shared_base(), Some(16));
    }

    /// Packing is naturally aligned in every variable space: after an odd-sized
    /// `.b8` variable, wider ones still land on multiples of their element size
    /// (the evaluator's alignment checks trust lowering-assigned addresses).
    #[test]
    fn test_var_packing_is_naturally_aligned() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("pad", ScalarType::B8, 3, false, 1)
            .unwrap();
        symbols
            .declare_shared("halves", ScalarType::F16, 5, false, 2)
            .unwrap();
        symbols
            .declare_shared("words", ScalarType::F32, 2, false, 4)
            .unwrap();
        symbols.finalize_shared_layout().unwrap();
        // pad: [0, 3); halves: aligned up to 4, [4, 14); words: up to 16.
        assert_eq!(symbols.get_shared_var("pad").unwrap().offset, 0);
        assert_eq!(symbols.get_shared_var("halves").unwrap().offset, 4);
        assert_eq!(symbols.get_shared_var("words").unwrap().offset, 16);

        symbols
            .declare_local("depot", ScalarType::B8, 5, 1)
            .unwrap();
        symbols
            .declare_local("spill", ScalarType::F64, 1, 8)
            .unwrap();
        assert_eq!(symbols.get_local_var("depot").unwrap().offset, 0);
        assert_eq!(symbols.get_local_var("spill").unwrap().offset, 8);

        symbols
            .declare_global_var("flag", ScalarType::B8, 1, 1)
            .unwrap();
        symbols
            .declare_global_var("table", ScalarType::F64, 2, 8)
            .unwrap();
        // MODULE_GLOBAL_BASE is itself naturally aligned for any scalar
        // width, so the offsets' alignment carries over to the addresses.
        assert_eq!(MODULE_GLOBAL_BASE % 16, 0);
        assert_eq!(symbols.get_global_var("flag").unwrap().addr % 8, 0);
        assert_eq!(
            symbols.get_global_var("table").unwrap().addr,
            MODULE_GLOBAL_BASE + 8
        );
    }

    /// Static-only tables finalize to "no extern window".
    #[test]
    fn test_finalize_without_externs() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("lut", ScalarType::F32, 64, false, 4)
            .unwrap();
        symbols.finalize_shared_layout().unwrap();

        assert_eq!(symbols.extern_shared_base(), None);
        assert_eq!(symbols.get_shared_var("lut").unwrap().offset, 0);
    }

    #[test]
    #[should_panic(expected = "after finalize_shared_layout")]
    fn test_declare_shared_after_finalize_panics() {
        let mut symbols = SymbolTable::new();
        symbols.finalize_shared_layout().unwrap();
        let _ = symbols.declare_shared("late", ScalarType::F32, 1, false, 4);
    }

    #[test]
    #[should_panic(expected = "before finalize_shared_layout")]
    fn test_extern_base_before_finalize_panics() {
        let symbols = SymbolTable::new();
        let _ = symbols.extern_shared_base();
    }

    #[test]
    fn test_levenshtein() {
        assert_eq!(levenshtein_distance("hello", "hello"), 0);
        assert_eq!(levenshtein_distance("hello", "hallo"), 1);
        assert_eq!(levenshtein_distance("hello", ""), 5);
        assert_eq!(levenshtein_distance("", "hello"), 5);
    }

    // =========================================================================
    // Cross-namespace conflict tests (PTX uses a single namespace)
    // =========================================================================

    #[test]
    fn test_label_conflicts_with_param() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        symbols
            .declare_param("foo", 8, 8, ParamLayout::Scalar)
            .unwrap();

        // Label should conflict with param
        let result =
            symbols.declare_label("foo", SymbolTable::ROOT_LABEL_SCOPE, InstrId::from_index(0));
        assert!(result.is_err());
    }

    #[test]
    fn test_label_conflicts_with_register() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        symbols.declare_register("foo", ScalarType::U32, 1).unwrap();

        // Label should conflict with register
        let result =
            symbols.declare_label("foo", SymbolTable::ROOT_LABEL_SCOPE, InstrId::from_index(0));
        assert!(result.is_err());
    }

    #[test]
    fn test_label_conflicts_with_shared() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        symbols
            .declare_shared("foo", ScalarType::U32, 256, false, 4)
            .unwrap();

        // Label should conflict with shared
        let result =
            symbols.declare_label("foo", SymbolTable::ROOT_LABEL_SCOPE, InstrId::from_index(0));
        assert!(result.is_err());
    }

    #[test]
    fn test_param_conflicts_with_register() {
        let mut symbols = SymbolTable::new();
        symbols.declare_register("foo", ScalarType::U32, 1).unwrap();

        // Param should conflict with register
        let result = symbols.declare_param("foo", 8, 8, ParamLayout::Scalar);
        assert!(result.is_err());
    }

    #[test]
    fn test_shared_conflicts_with_param() {
        let mut symbols = SymbolTable::new();
        symbols
            .declare_param("foo", 8, 8, ParamLayout::Scalar)
            .unwrap();

        // Shared should conflict with param
        let result = symbols.declare_shared("foo", ScalarType::U32, 256, false, 4);
        assert!(result.is_err());
    }

    #[test]
    fn test_register_conflicts_with_label() {
        use id_collections::Id;
        let mut symbols = SymbolTable::new();
        symbols
            .declare_label("foo", SymbolTable::ROOT_LABEL_SCOPE, InstrId::from_index(0))
            .unwrap();

        // Register should conflict with label
        let result = symbols.declare_register("foo", ScalarType::U32, 1);
        assert!(result.is_err());
    }
}
