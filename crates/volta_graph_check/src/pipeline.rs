//! **Implicit tensor-pipeline ordering** (§1.2, step 5): the typed relation `E_pipeline`.
//!
//! ```text
//! EligiblePipeline(x, y, a, b)  =>  (a, b) in E_pipeline
//! ```
//!
//! * Candidate pairs `(x, y)` of dynamic `tcgen05` operations are matched to the supported PTX
//!   rules by opcode and operand role; the matched rule's issue-order, warp, CTA-group,
//!   address, shape and instruction-specific preconditions are checked, and an edge joins each
//!   covered pair of effects `a ∈ Effects(x)`, `b ∈ Effects(y)`. An edge keeps its rule, its
//!   operand roles and the physical cells it covers. It orders operand accesses only: not
//!   whole-operation completion, not general memory visibility.
//! * Supported rule ([`PipelineRule::MmaAccumulatorChain`], PTX ISA "implicitly pipelined
//!   tcgen05 instructions"): `tcgen05.mma.cta_group::1` (Volta's only form) then another, issued
//!   by the same thread in that program order (so one warp, issue order), on the same
//!   accumulator: identical Tensor Memory `D` footprints, hence the same address and `M x N`
//!   shape. It covers their accumulator (`D`) effects; `A`/`B` reads are not covered. An MMA
//!   without an accumulator write has unknown preconditions and gets no edge.
//! * Every edge joins two operations of one thread, so all are constructed immediately; none
//!   needs a thread handoff's validation. No projection of [`crate::relation`] contains them.

use std::collections::HashMap;

use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext, Footprint,
    OperandRole, Space, ThreadIx,
};

/// A supported implicit-pipelining rule of the PTX ISA.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum PipelineRule {
    /// `tcgen05.mma` -> `tcgen05.mma` of one thread on one accumulator.
    MmaAccumulatorChain,
}

/// One edge `(a, b)` of `E_pipeline`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PipelineEdge {
    pub rule: PipelineRule,
    pub from: EventId,
    pub to: EventId,
    pub roles: (OperandRole, OperandRole),
    /// The cells both effects touch.
    pub cells: Footprint,
}

/// `E_pipeline` of one graph: the accumulator chains, ops in issue order.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct PipelineEdges {
    chains: Vec<Vec<AsyncOpId>>,
    position: HashMap<AsyncOpId, (usize, usize)>,
}

/// A Tensor Memory rectangle: first lane, lanes, first column, columns.
type Rectangle = (u8, u8, u16, u16);

/// The accumulator footprints an MMA writes, sorted: its `D`.
fn accumulator(graph: &EventGraph, op: AsyncOpId) -> Vec<Rectangle> {
    let mut d: Vec<Rectangle> = graph
        .async_op(op)
        .effects
        .iter()
        .map(|&a| graph.access(a))
        .filter(|a| {
            a.space == Space::Tensor
                && a.role == OperandRole::Accumulator
                && a.mode == AccessMode::Write
        })
        .filter_map(|a| match a.footprint {
            Footprint::Tensor {
                lane,
                lanes,
                col,
                cols,
            } => Some((lane, lanes, col, cols)),
            Footprint::Bytes { .. } => None,
        })
        .collect();
    d.sort_unstable();
    d
}

/// `E_pipeline` of `graph`.
pub fn pipeline_edges(graph: &EventGraph) -> PipelineEdges {
    let mut keys: HashMap<(ThreadIx, Vec<Rectangle>), usize> = HashMap::new();
    let mut edges = PipelineEdges::default();
    for (op, a) in graph.async_ops().iter() {
        if a.kind != AsyncOpKind::Tcgen05Mma {
            continue;
        }
        let d = accumulator(graph, op);
        if d.is_empty() {
            continue;
        }
        let next = keys.len();
        let chain = *keys.entry((a.issuer, d)).or_insert(next);
        if chain == edges.chains.len() {
            edges.chains.push(Vec::new());
        }
        edges
            .position
            .insert(op, (chain, edges.chains[chain].len()));
        edges.chains[chain].push(op);
    }
    edges
}

impl PipelineEdges {
    /// The edge `(a, b)`, if `EligiblePipeline` holds for `a`'s and `b`'s operations and
    /// effects: `a` an accumulator effect of an MMA chained before `b`'s, sharing cells.
    pub fn edge(&self, graph: &EventGraph, a: EventId, b: EventId) -> Option<PipelineEdge> {
        let (x, ax) = accumulator_effect(graph, a)?;
        let (y, by) = accumulator_effect(graph, b)?;
        let (&(cx, px), &(cy, py)) = (self.position.get(&x)?, self.position.get(&y)?);
        if cx != cy || px >= py {
            return None;
        }
        let cells = shared_cells(ax, by)?;
        Some(PipelineEdge {
            rule: PipelineRule::MmaAccumulatorChain,
            from: a,
            to: b,
            roles: (OperandRole::Accumulator, OperandRole::Accumulator),
            cells,
        })
    }

    /// Every edge of `E_pipeline`, in issue order of their operations.
    pub fn edges(&self, graph: &EventGraph) -> Vec<PipelineEdge> {
        let effects = |op: AsyncOpId| -> Vec<EventId> {
            graph
                .events()
                .iter()
                .filter(|(_, ev)| {
                    ev.ctx == ExecContext::Async(op) && matches!(ev.kind, EventKind::Access(_))
                })
                .map(|(id, _)| id)
                .collect()
        };
        let mut out = Vec::new();
        for chain in &self.chains {
            for (i, &x) in chain.iter().enumerate() {
                for &y in &chain[i + 1..] {
                    for a in effects(x) {
                        for b in effects(y) {
                            out.extend(self.edge(graph, a, b));
                        }
                    }
                }
            }
        }
        out
    }
}

/// `event`'s operation and footprint, if it is an MMA's accumulator effect.
fn accumulator_effect(graph: &EventGraph, event: EventId) -> Option<(AsyncOpId, Footprint)> {
    let ev = graph.event(event);
    let (ExecContext::Async(op), EventKind::Access(acc)) = (ev.ctx, ev.kind) else {
        return None;
    };
    let access = graph.access(acc);
    (graph.async_op(op).kind == AsyncOpKind::Tcgen05Mma
        && access.space == Space::Tensor
        && access.role == OperandRole::Accumulator)
        .then_some((op, access.footprint))
}

fn shared_cells(a: Footprint, b: Footprint) -> Option<Footprint> {
    let (
        Footprint::Tensor {
            lane: al,
            lanes: an,
            col: ac,
            cols: acn,
        },
        Footprint::Tensor {
            lane: bl,
            lanes: bn,
            col: bc,
            cols: bcn,
        },
    ) = (a, b)
    else {
        return None;
    };
    let lane = al.max(bl);
    let lane_end = (u32::from(al) + u32::from(an)).min(u32::from(bl) + u32::from(bn));
    let col = ac.max(bc);
    let col_end = (u32::from(ac) + u32::from(acn)).min(u32::from(bc) + u32::from(bcn));
    (u32::from(lane) < lane_end && u32::from(col) < col_end).then(|| Footprint::Tensor {
        lane,
        lanes: (lane_end - u32::from(lane)) as u8,
        col,
        cols: (col_end - u32::from(col)) as u16,
    })
}
