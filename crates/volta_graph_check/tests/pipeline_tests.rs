//! `E_pipeline` (graph-construction step 5) on its own: which pairs of `tcgen05` effects an
//! implicit-pipelining rule orders.

mod common;

use common::*;
use volta_graph::{AccessMode, AsyncOpKind, EventId, Footprint, OperandRole, Proxy};
use volta_graph_check::pipeline::{PipelineRule, pipeline_edges};

#[test]
fn same_issuer_mmas_on_one_accumulator_are_pipelined_in_issue_order() {
    let mut s = Scenario::new(2);
    let (_, a) = s.mma(0, (0, 8));
    let (_, b) = s.mma(0, (0, 8));
    let (_, c) = s.mma(0, (0, 8));
    let (g, _) = s.completed(2);
    let edges = pipeline_edges(&g);
    let edge = edges.edge(&g, a, b).expect("an eligible pair");
    assert_eq!(edge.rule, PipelineRule::MmaAccumulatorChain);
    assert_eq!(
        edge.roles,
        (OperandRole::Accumulator, OperandRole::Accumulator)
    );
    assert_eq!(
        edge.cells,
        Footprint::Tensor {
            lane: 0,
            lanes: 128,
            col: 0,
            cols: 8
        }
    );
    assert!(edges.edge(&g, a, c).is_some() && edges.edge(&g, b, c).is_some());
    assert!(edges.edge(&g, b, a).is_none(), "only in issue order");
    assert_eq!(edges.edges(&g).len(), 3);
}

#[test]
fn other_issuers_or_accumulators_are_not_pipelined() {
    let mut s = Scenario::new(2);
    let (_, a) = s.mma(0, (0, 8));
    let (_, other_thread) = s.mma(1, (0, 8));
    let (_, other_shape) = s.mma(0, (0, 16));
    let (g, _) = s.completed(2);
    let edges = pipeline_edges(&g);
    assert!(edges.edge(&g, a, other_thread).is_none());
    assert!(edges.edge(&g, a, other_shape).is_none());
}

#[test]
fn operand_reads_are_not_covered() {
    let mut s = Scenario::new(1);
    let (_, d) = s.mma(0, (0, 8));
    let (_, effects) = s.tmem_op(
        0,
        AsyncOpKind::Tcgen05Mma,
        &[
            Cells {
                mode: AccessMode::Read,
                role: OperandRole::MmaA,
                lanes: (0, 128),
                cols: (0, 8),
            },
            Cells::accumulator(AccessMode::Write, (0, 8)),
        ],
    );
    let (g, _) = s.completed(1);
    let edges = pipeline_edges(&g);
    assert!(
        edges.edge(&g, d, effects[0]).is_none(),
        "an A read from Tensor Memory"
    );
    assert!(edges.edge(&g, d, effects[1]).is_some());
}

#[test]
fn an_mma_without_an_accumulator_write_has_no_edge() {
    let mut s = Scenario::new(1);
    let (_, read) = s.tmem_op(
        0,
        AsyncOpKind::Tcgen05Mma,
        &[Cells::accumulator(AccessMode::Read, (0, 8))],
    );
    let (_, d) = s.mma(0, (0, 8));
    let (g, _) = s.completed(1);
    assert!(pipeline_edges(&g).edge(&g, read[0], d).is_none());
}

#[test]
fn a_store_then_an_mma_is_not_a_rule_even_when_waited() {
    let mut s = Scenario::new(1);
    let (st, write) = s.tmem_st(0, 0, (0, 8));
    s.warp_wait(0, &[0], &[st]);
    let (_, d) = s.mma(0, (0, 8));
    s.async_op(0, AsyncOpKind::BulkCopy, AccessMode::Write, 0, Proxy::Async);
    let (g, _) = s.completed(1);
    assert!(pipeline_edges(&g).edge(&g, write, d).is_none());
}

#[test]
fn a_waited_store_then_load_of_one_warp_is_pipelined() {
    let mut s = Scenario::new(1);
    let (st, write) = s.tmem_st(0, 0, (0, 1));
    s.warp_wait(0, &[0], &[st]);
    let (_, read) = s.tmem_ld(0, 0, (0, 1));
    let (g, _) = s.completed(1);
    let edges = pipeline_edges(&g);
    let edge = edges
        .edge(&g, write, read)
        .expect("pairs 11-13 with the store waited");
    assert_eq!(edge.rule, PipelineRule::WaitedLoadStore);
    assert_eq!(edge.roles, (OperandRole::TmemData, OperandRole::TmemData));
    assert_eq!(
        edge.cells,
        Footprint::Tensor {
            lane: 0,
            lanes: 32,
            col: 0,
            cols: 1
        }
    );
    assert!(edges.edge(&g, read, write).is_none(), "only in issue order");
    assert_eq!(edges.edges(&g).len(), 1);
}

#[test]
fn waited_store_store_and_load_store_pairs_are_pipelined() {
    let mut s = Scenario::new(1);
    let (first, w1) = s.tmem_st(0, 0, (0, 1));
    s.warp_wait(0, &[0], &[first]);
    let (_, w2) = s.tmem_st(0, 0, (0, 1));
    let (ld, read) = s.tmem_ld(0, 0, (4, 1));
    s.warp_wait(0, &[0], &[ld]);
    let (_, w3) = s.tmem_st(0, 0, (4, 1));
    let (g, _) = s.completed(1);
    let edges = pipeline_edges(&g);
    for (a, b) in [(w1, w2), (read, w3)] {
        assert_eq!(
            edges.edge(&g, a, b).map(|e| e.rule),
            Some(PipelineRule::WaitedLoadStore)
        );
    }
}

#[test]
fn a_load_or_store_without_its_wait_in_between_is_not_pipelined() {
    let mut s = Scenario::new(1);
    let (_, unwaited) = s.tmem_st(0, 0, (0, 1));
    let (_, read) = s.tmem_ld(0, 0, (0, 1));
    let (late, written) = s.tmem_st(0, 0, (4, 1));
    let (_, reread) = s.tmem_ld(0, 0, (4, 1));
    s.warp_wait(0, &[0], &[late]);
    let (g, _) = s.completed(1);
    let edges = pipeline_edges(&g);
    assert!(edges.edge(&g, unwaited, read).is_none(), "no wait at all");
    assert!(
        edges.edge(&g, written, reread).is_none(),
        "the wait comes after the later issue"
    );
}

#[test]
fn a_wait_completing_another_operation_does_not_count() {
    let mut s = Scenario::new(1);
    let (_, write) = s.tmem_st(0, 0, (0, 1));
    let (other, _) = s.tmem_st(0, 0, (4, 1));
    s.warp_wait(0, &[0], &[other]);
    let (_, read) = s.tmem_ld(0, 0, (0, 1));
    let (g, _) = s.completed(1);
    assert!(pipeline_edges(&g).edge(&g, write, read).is_none());
}

#[test]
fn loads_and_stores_of_different_warps_are_not_pipelined() {
    let mut s = Scenario::new(33);
    let (st, write) = s.tmem_st(0, 0, (0, 1));
    s.warp_wait(0, &[0], &[st]);
    s.barrier(&[0, 32], &[]);
    let (_, read) = s.tmem_ld(32, 0, (0, 1));
    let (g, _) = s.completed(33);
    assert!(pipeline_edges(&g).edge(&g, write, read).is_none());
}

/// A `tcgen05.cp` writing scale factors and an MMA by `issuer` reading them as `scale_A`, with
/// an accumulator write of its own.
fn copy_and_scaled_mma(
    s: &mut Scenario,
    copier: u32,
    issuer: u32,
    copy_first: bool,
) -> (EventId, Vec<EventId>) {
    let copy = |s: &mut Scenario| {
        let (_, w) = s.tmem_op(
            copier,
            AsyncOpKind::Tcgen05Cp,
            &[Cells {
                mode: AccessMode::Write,
                role: OperandRole::Destination,
                lanes: (0, 128),
                cols: (16, 4),
            }],
        );
        w[0]
    };
    let mma = |s: &mut Scenario| {
        s.tmem_op(
            issuer,
            AsyncOpKind::Tcgen05Mma,
            &[
                Cells {
                    mode: AccessMode::Read,
                    role: OperandRole::MmaScaleA,
                    lanes: (0, 128),
                    cols: (16, 1),
                },
                Cells::accumulator(AccessMode::Write, (0, 8)),
            ],
        )
        .1
    };
    if copy_first {
        let w = copy(s);
        (w, mma(s))
    } else {
        let m = mma(s);
        (copy(s), m)
    }
}

#[test]
fn a_copy_then_an_mma_of_one_thread_is_pipelined_on_the_scales() {
    let mut s = Scenario::new(1);
    let (write, mma) = copy_and_scaled_mma(&mut s, 0, 0, true);
    let (g, _) = s.completed(1);
    let edges = pipeline_edges(&g);
    let edge = edges.edge(&g, write, mma[0]).expect("an eligible pair");
    assert_eq!(edge.rule, PipelineRule::CopyThenMma);
    assert_eq!(
        edge.roles,
        (OperandRole::Destination, OperandRole::MmaScaleA)
    );
    assert_eq!(
        edge.cells,
        Footprint::Tensor {
            lane: 0,
            lanes: 128,
            col: 16,
            cols: 1
        }
    );
    assert!(
        edges.edge(&g, write, mma[1]).is_none(),
        "not the accumulator"
    );
    assert_eq!(edges.edges(&g).len(), 1);
}

#[test]
fn a_copy_after_an_mma_or_by_another_thread_is_not_pipelined() {
    let mut s = Scenario::new(2);
    let (later_write, mma) = copy_and_scaled_mma(&mut s, 0, 0, false);
    let (other_write, other_mma) = copy_and_scaled_mma(&mut s, 1, 0, true);
    let (g, _) = s.completed(2);
    let edges = pipeline_edges(&g);
    assert!(
        edges.edge(&g, later_write, mma[0]).is_none(),
        "the MMA came first"
    );
    assert!(
        edges.edge(&g, other_write, other_mma[0]).is_none(),
        "another issuer"
    );
}

#[test]
fn a_copy_and_an_mma_of_two_warps_are_pipelinable() {
    let mut s = Scenario::new(64);
    let (write, mma) = copy_and_scaled_mma(&mut s, 0, 32, true);
    let (g, _) = s.completed(64);
    assert!(
        volta_graph_check::pipeline::pipelinable(&g, write, mma[0]),
        "the ISA's pipelined pattern across threads (9.7.16.6.4.3)"
    );
    assert!(
        pipeline_edges(&g).edge(&g, write, mma[0]).is_none(),
        "no edge without the fences"
    );
}
