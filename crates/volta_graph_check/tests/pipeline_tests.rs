//! The pipeline-order checker in isolation.

mod common;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, Footprint, MemAccess, OperandRole, OrderingKind, Proxy,
    Space, StoredValue,
};
use volta_graph_check::Verdict;
use volta_graph_check::pipeline::check_pipeline;

/// A `tcgen05.mma` by `issuer` writing accumulator columns `[col, col + cols)` of all lanes
/// (no accumulator when `cols == 0`), after reading `A` from shared memory.
fn mma(s: &mut Scenario, issuer: u32, col: u16, cols: u16) -> AsyncOpId {
    let op = s.b.async_issue(t(issuer), PC, AsyncOpKind::Tcgen05Mma);
    s.b.async_effect(
        op,
        MemAccess {
            space: Space::Shared,
            mode: AccessMode::Read,
            ordering: OrderingKind::Ordinary,
            proxy: Proxy::Async,
            footprint: Footprint::Bytes { addr: 0, width: 2 },
            role: OperandRole::MmaA,
            attributed: t(issuer),
            value: None,
        },
    );
    if cols > 0 {
        let value = Some(s.b.value(StoredValue::Opaque));
        s.b.async_effect(
            op,
            MemAccess {
                space: Space::Tensor,
                mode: AccessMode::Write,
                ordering: OrderingKind::Ordinary,
                proxy: Proxy::Async,
                footprint: Footprint::Tensor {
                    lane: 0,
                    lanes: 128,
                    col,
                    cols,
                },
                role: OperandRole::Accumulator,
                attributed: t(issuer),
                value,
            },
        );
    }
    op
}

#[test]
fn same_issuer_mmas_on_one_accumulator_are_pipelined_in_issue_order() {
    let mut s = Scenario::new(2);
    let a = mma(&mut s, 0, 0, 8);
    let b = mma(&mut s, 0, 0, 8);
    let c = mma(&mut s, 0, 0, 8);
    let (g, _) = s.completed(2);
    let (result, cert) = check_pipeline(&g);
    assert_eq!(result.verdict(), Verdict::Pass);
    assert!(cert.orders(a, b) && cert.orders(a, c) && cert.orders(b, c));
    assert!(!cert.orders(b, a));
    let PropertyResultPass { pairs } = pass(&result);
    assert_eq!(pairs, 3);
}

struct PropertyResultPass {
    pairs: usize,
}

fn pass(result: &volta_graph_check::pipeline::PipelineResult) -> PropertyResultPass {
    match result {
        volta_graph_check::PropertyResult::Pass(e) => PropertyResultPass {
            pairs: e.certified_pairs,
        },
        other => panic!("{other:?}"),
    }
}

#[test]
fn other_issuers_or_accumulators_are_not_pipelined() {
    let mut s = Scenario::new(2);
    let a = mma(&mut s, 0, 0, 8);
    let other_thread = mma(&mut s, 1, 0, 8);
    let other_shape = mma(&mut s, 0, 0, 16);
    let (g, _) = s.completed(2);
    let (_, cert) = check_pipeline(&g);
    assert!(!cert.orders(a, other_thread));
    assert!(!cert.orders(a, other_shape));
}

#[test]
fn an_mma_without_an_accumulator_is_unknown() {
    let mut s = Scenario::new(1);
    mma(&mut s, 0, 0, 0);
    let (g, _) = s.completed(1);
    assert_eq!(check_pipeline(&g).0.verdict(), Verdict::Unknown);
}
