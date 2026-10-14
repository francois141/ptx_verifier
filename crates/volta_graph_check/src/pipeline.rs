//! **Instruction/operand-specific asynchronous pipeline ordering.**
//!
//! * Property: the pairs of asynchronous effects certified as ordered by an instruction's own
//!   pipelining satisfy that instruction's conditions, operand by operand. The certificate is
//!   what the memory-conflict checker may use instead of a completion wait.
//! * Modeled pairing (PTX ISA, tcgen05 implicitly pipelined instructions): two
//!   `tcgen05.mma.cta_group::1` (Volta's only form) issued by the same thread, in that program
//!   order, on the same accumulator: identical Tensor Memory `D` footprints, hence the same
//!   `M x N` shape. Only their accumulator (`D`) effects are ordered; their `A`/`B` reads
//!   (shared memory or `[a-tmem]`) are not covered by the pairing.
//! * Uses: async ops of kind `Tcgen05Mma`, their effects' space, role, mode and footprint, the
//!   issuer's program order (issue positions).
//! * Prerequisites: a well-formed graph.
//! * `Pass`: every certified pair meets the conditions (the evidence counts chains and
//!   pairs); same-issuer MMA pairs on overlapping but unequal accumulators are not certified
//!   and left to the memory-conflict checker. `Unknown`: an MMA without an accumulator write,
//!   whose pairing cannot be decided.

use std::collections::HashMap;

use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, EventGraph, Footprint, OperandRole, Space, ThreadIx,
};

use crate::result::{PropertyResult, Unresolved};

/// Pipelined accumulator chains: an op's chain and its position in it.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct PipelineCertificate {
    position: HashMap<AsyncOpId, (usize, usize)>,
}

impl PipelineCertificate {
    /// No pipelined pair (for testing later checkers in isolation).
    pub fn none() -> Self {
        PipelineCertificate::default()
    }

    /// Whether `first`'s accumulator effects are ordered before `second`'s by pipelining.
    pub fn orders(&self, first: AsyncOpId, second: AsyncOpId) -> bool {
        match (self.position.get(&first), self.position.get(&second)) {
            (Some(&(c1, p1)), Some(&(c2, p2))) => c1 == c2 && p1 < p2,
            _ => false,
        }
    }

    /// The ops pipelined after `op` on its accumulator, in issue order.
    pub fn successors(&self, op: AsyncOpId) -> impl Iterator<Item = AsyncOpId> + '_ {
        let here = self.position.get(&op).copied();
        self.position.iter().filter_map(move |(&other, &(c, p))| {
            here.filter(|&(hc, hp)| hc == c && p > hp).map(|_| other)
        })
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PipelineEvidence {
    pub chains: usize,
    pub certified_pairs: usize,
}

/// No violation is possible: the checker only certifies.
pub type PipelineResult = PropertyResult<PipelineEvidence, std::convert::Infallible>;

/// The accumulator footprints an MMA writes (its `D`), sorted.
fn accumulator(graph: &EventGraph, op: AsyncOpId) -> Vec<Footprint> {
    let mut d: Vec<Footprint> = graph
        .async_op(op)
        .effects
        .iter()
        .map(|&a| graph.access(a))
        .filter(|a| {
            a.space == Space::Tensor
                && a.role == OperandRole::Accumulator
                && a.mode == AccessMode::Write
        })
        .map(|a| a.footprint)
        .collect();
    d.sort_by_key(|f| match *f {
        Footprint::Tensor {
            lane,
            lanes,
            col,
            cols,
        } => (
            u32::from(lane),
            u32::from(lanes),
            u32::from(col),
            u32::from(cols),
        ),
        Footprint::Bytes { .. } => (u32::MAX, 0, 0, 0),
    });
    d
}

pub fn check_pipeline(graph: &EventGraph) -> (PipelineResult, PipelineCertificate) {
    if graph.validate().is_err() {
        return (
            PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]),
            PipelineCertificate::none(),
        );
    }
    let mut unresolved = Vec::new();
    let mut chains: HashMap<(ThreadIx, Vec<Footprint>), usize> = HashMap::new();
    let mut members: Vec<usize> = Vec::new();
    let mut certificate = PipelineCertificate::none();
    for (op, a) in graph.async_ops().iter() {
        if a.kind != AsyncOpKind::Tcgen05Mma {
            continue;
        }
        let d = accumulator(graph, op);
        if d.is_empty() {
            unresolved.push(Unresolved::at(
                a.issue,
                format!("tcgen05.mma {} has no accumulator write to pipeline", op.0),
            ));
            continue;
        }
        let next = chains.len();
        let chain = *chains.entry((a.issuer, d)).or_insert(next);
        if chain == members.len() {
            members.push(0);
        }
        certificate.position.insert(op, (chain, members[chain]));
        members[chain] += 1;
    }
    let certified_pairs = members.iter().map(|&n| n * n.saturating_sub(1) / 2).sum();
    (
        PropertyResult::from_findings(
            PipelineEvidence {
                chains: members.len(),
                certified_pairs,
            },
            Vec::new(),
            unresolved,
        ),
        certificate,
    )
}
