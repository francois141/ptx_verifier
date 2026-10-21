//! The memory domains the checks partition their obligations by (§1.3: "obligations are thus
//! partitioned by memory domain, not opcode"):
//!
//! * `M`: the ordinary non-atomic effects on byte-addressed memory (global and shared),
//!   synchronous or asynchronous, the shared-memory effects of `tcgen05` operations included.
//!   Algorithms 2 and 3 range over it.
//! * `A`: the Tensor Memory effects of `tcgen05` operations. Algorithms 4 and 6 range over it.
//!
//! Atomic and reduction effects belong to neither: the initial contract excludes them (§2).

use std::collections::HashSet;

use volta_graph::{
    AccessMode, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext, Footprint, MemAccess,
    OrderingKind, Space,
};

/// How a conflicting pair's earlier and later effects access their shared location.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum ConflictKind {
    WriteRead,
    WriteWrite,
    ReadWrite,
}

impl ConflictKind {
    /// The kind of an `earlier` -> `later` pair; `None` for two reads, which never conflict.
    pub fn of(earlier: AccessMode, later: AccessMode) -> Option<ConflictKind> {
        match (earlier, later) {
            (AccessMode::Write, AccessMode::Read) => Some(ConflictKind::WriteRead),
            (AccessMode::Write, AccessMode::Write) => Some(ConflictKind::WriteWrite),
            (AccessMode::Read, AccessMode::Write) => Some(ConflictKind::ReadWrite),
            (AccessMode::Read, AccessMode::Read) => None,
        }
    }
}

/// One byte of global or shared memory. A single CTA is analyzed, so every shared byte has the
/// same owner.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct ByteLocation {
    pub space: Space,
    pub addr: u64,
}

/// One 32-bit Tensor Memory cell.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct TmemCell {
    pub lane: u8,
    pub col: u16,
}

/// Whether an effect belongs to `M`.
pub fn in_m(access: &MemAccess) -> bool {
    access.ordering == OrderingKind::Ordinary && access.space != Space::Tensor
}

/// The bytes some effect of `M` writes: no conflicting pair of `M` lies elsewhere.
pub fn written_bytes(graph: &EventGraph) -> HashSet<ByteLocation> {
    graph
        .accesses()
        .values()
        .filter(|a| in_m(a) && a.mode == AccessMode::Write)
        .flat_map(bytes)
        .collect()
}

/// Whether an effect is outside the initial contract (an atomic or a reduction).
pub fn outside_contract(access: &MemAccess) -> bool {
    access.ordering != OrderingKind::Ordinary
}

/// Whether `kind` is a `tcgen05` operation, whose Tensor Memory effects form `A`.
pub fn is_tcgen05(kind: AsyncOpKind) -> bool {
    matches!(
        kind,
        AsyncOpKind::Tcgen05Mma | AsyncOpKind::Tcgen05Ld | AsyncOpKind::Tcgen05St
    )
}

/// The bytes of a byte-addressed footprint, ascending.
pub fn bytes(access: &MemAccess) -> impl Iterator<Item = ByteLocation> + use<> {
    let space = access.space;
    let range = match access.footprint {
        Footprint::Bytes { addr, width } => addr..addr + u64::from(width),
        Footprint::Tensor { .. } => 0..0,
    };
    range.map(move |addr| ByteLocation { space, addr })
}

/// One effect of `A`: its event, access and operation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TmemEffect {
    pub event: EventId,
    pub access: MemAccess,
    pub op: volta_graph::AsyncOpId,
}

impl TmemEffect {
    /// The effect's lanes and columns, as half-open ranges.
    pub fn rectangle(&self) -> ((u32, u32), (u32, u32)) {
        match self.access.footprint {
            Footprint::Tensor {
                lane,
                lanes,
                col,
                cols,
            } => (
                (u32::from(lane), u32::from(lane) + u32::from(lanes)),
                (u32::from(col), u32::from(col) + u32::from(cols)),
            ),
            Footprint::Bytes { .. } => ((0, 0), (0, 0)),
        }
    }
}

/// The Tensor Memory effects of the graph in trace order: those of `tcgen05` operations
/// (`A`), and the others, which no modeled rule covers.
pub fn tensor_effects(graph: &EventGraph) -> (Vec<TmemEffect>, Vec<EventId>) {
    let mut a = Vec::new();
    let mut unsupported = Vec::new();
    for (id, ev) in graph.events().iter() {
        let EventKind::Access(acc) = ev.kind else {
            continue;
        };
        let access = *graph.access(acc);
        if access.space != Space::Tensor {
            continue;
        }
        match ev.ctx {
            ExecContext::Async(op) if is_tcgen05(graph.async_op(op).kind) => a.push(TmemEffect {
                event: id,
                access,
                op,
            }),
            _ => unsupported.push(id),
        }
    }
    (a, unsupported)
}

/// The first cell two rectangles share, if any.
pub fn first_shared_cell(
    ((al, ah), (ac, ach)): ((u32, u32), (u32, u32)),
    ((bl, bh), (bc, bch)): ((u32, u32), (u32, u32)),
) -> Option<TmemCell> {
    let (lane, lane_end) = (al.max(bl), ah.min(bh));
    let (col, col_end) = (ac.max(bc), ach.min(bch));
    (lane < lane_end && col < col_end).then_some(TmemCell {
        lane: lane as u8,
        col: col as u16,
    })
}
