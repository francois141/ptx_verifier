//! Kernels whose generic-proxy writes reach a later effect through another proxy uncovered: the
//! proxy-order check (Algorithm 4) must fail, naming the pair and the fence it lacks.

#[macro_use]
mod common;

use volta_graph::{AccessMode, AsyncOpKind, Space};
use volta_graph_check::proxy_order::{MissingFence, ProxyOrderViolation};

use common::*;

/// The first uncovered pair of `ptx`'s execution and its sides; panics unless the check failed.
fn violation(ptx: &Ptx) -> (ProxyOrderViolation, Side, Side) {
    let checked = check(ptx, None, tma_config(32));
    let graph = &checked.analysis.graph;
    let [v] = checked.report.proxy_order.violations() else {
        panic!(
            "expected one proxy-order violation, got: {:?}",
            checked.report.proxy_order
        );
    };
    (*v, side(graph, v.generic), side(graph, v.asynchronous))
}

fn assert_tensor_map_read_uncovered(ptx: &Ptx, missing: MissingFence) {
    let (v, generic, tensor_map) = violation(ptx);
    assert_eq!(v.missing, missing, "{v:?}");
    assert_eq!(v.location.space, Space::Global, "{v:?}");
    assert_eq!(generic, Side::plain(0, AccessMode::Write));
    assert_eq!(
        tensor_map,
        Side::effect(0, AccessMode::Read, AsyncOpKind::TensorCopy)
    );
}

/// Thread 0 copies the tensor map to global memory with `tensormap.cp_fenceproxy`, whose
/// release is there, but its TMA reads the map with no acquire. The control is
/// `cp_async_bulk_tensor_without_fence_proxy_async_is_clean`.
#[test]
fn test_tma_without_tensormap_acquire_fence() {
    assert_tensor_map_read_uncovered(
        &ptx!(parse "execution_error/tma_without_tensormap_acquire_fence"),
        MissingFence::TensormapAcquire,
    );
}

/// Thread 0 replaces the tensor map's fields in global memory and acquires it, with no release
/// between its writes and the acquire.
#[test]
fn test_tma_without_tensormap_release_fence() {
    assert_tensor_map_read_uncovered(
        &ptx!(parse "execution_error/tma_without_tensormap_release_fence"),
        MissingFence::TensormapRelease,
    );
}

/// An acquire covers only the tensor map it names: acquiring `other` leaves the copy's read of
/// `gbl` uncovered.
#[test]
fn test_tma_acquires_another_tensor_map() {
    assert_tensor_map_read_uncovered(
        &ptx!(parse "execution_error/tma_acquires_another_tensor_map"),
        MissingFence::TensormapAcquire,
    );
}
