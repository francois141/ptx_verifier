//! End-to-end evaluator tests: small synthetic kernels (1-2 threads) check
//! each mechanism cheaply; the paper's Harris reduction kernels check real
//! equivalence.

use std::path::PathBuf;

use volta_analysis::driver::{EquivOutcome, analyze_kernel, check_output_equivalence};
use volta_analysis::lowered::MemSpace;
use volta_analysis::numeric;
use volta_analysis::{AnalysisError, LowerError};

/// Check equivalence along the reference run's output arrays.
fn check_equiv(a: &AnalysisOutput, b: &AnalysisOutput) -> EquivOutcome {
    let arrays: Vec<String> = a.outputs.iter().map(|(n, _)| n.clone()).collect();
    check_output_equivalence(a, b, &arrays).unwrap()
}
use volta_analysis::eval::{
    AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, EvalError, ParamValue, ThreadId,
};
use volta_frontend::ascii::AsAscii;
use volta_frontend::ast::Module;
use volta_frontend::parse::Parser;

fn parse(src: &str) -> Module {
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error))
}

/// The volta_bench paper-benchmark kernel tree (PTX + CUDA sources).
const KERNELS_DIR: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/../volta_bench/kernels");

fn parse_file(rel: &str) -> Module {
    let path = PathBuf::from(KERNELS_DIR).join(rel);
    let src =
        std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("read {}: {}", path.display(), e));
    parse(&src)
}

const HEADER: &str = ".version 8.0\n.target sm_80\n.address_size 64\n\n";

fn wrap(body: &str) -> String {
    format!("{}{}", HEADER, body)
}

/// Same as [`wrap`], but `sm_90a` - for tests exercising the sm_90+-gated
/// `fence.proxy.async` hazard check (`TargetFeatures::async_proxy_fence`).
const HEADER_SM90A: &str = ".version 8.0\n.target sm_90a\n.address_size 64\n\n";

fn wrap_sm90a(body: &str) -> String {
    format!("{}{}", HEADER_SM90A, body)
}

/// Same as [`wrap`], but `sm_100a` - the `tcgen05` family is only valid
/// on Blackwell-class targets (lowering rejects it on `sm_80`).
const HEADER_SM100A: &str = ".version 8.6\n.target sm_100a\n.address_size 64\n\n";

fn wrap_sm100a(body: &str) -> String {
    format!("{}{}", HEADER_SM100A, body)
}

/// in/out f32 arrays at fixed bases.
fn in_out_config(threads: u32, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

fn display_output(output: &AnalysisOutput, array: &str, index: u64) -> String {
    let (_, elems) = output
        .outputs
        .iter()
        .find(|(n, _)| n == array)
        .expect("output array");
    let (_, e) = elems
        .iter()
        .find(|(i, _)| *i == index)
        .expect("element written");
    output.arena.display_expr(*e)
}

// =========================================================================
// Synthetic kernels: one mechanism each
// =========================================================================

/// Two threads write the same shared address without synchronization.
#[test]
fn test_shared_write_write_race() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b32 %r<3>;
    .shared .align 4 .b8 sdata[8];

    mov.u32 %r1, %tid.x;
    mov.u32 %r2, sdata;
    st.shared.u32 [%r2], %r1;
    ret;
}
",
    );
    let module = parse(&src);
    let config = AnalysisConfig::new((2, 1, 1));
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected data race, got: {}",
        err
    );
}

/// Neighbor exchange through shared memory, correctly synchronized:
/// out[tid] = in[tid ^ 1].
const SWAP_BODY: &str = ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b32 %r<7>;
    .reg .b64 %rd<7>;
    .shared .align 4 .b8 sdata[8];

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 2;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    mov.u32 %r3, sdata;
    add.s32 %r4, %r3, %r2;
    st.shared.f32 [%r4], %f1;
    BARRIER
    xor.b32 %r5, %r1, 1;
    shl.b32 %r5, %r5, 2;
    add.s32 %r6, %r3, %r5;
    ld.shared.f32 %f2, [%r6];
    add.s64 %rd5, %rd2, %rd3;
    st.global.f32 [%rd5], %f2;
    ret;
}
";

#[test]
fn test_shared_exchange_with_barrier() {
    let src = wrap(&SWAP_BODY.replace("BARRIER", "bar.sync 0;"));
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[1]");
    assert_eq!(display_output(&output, "out", 1), "in[0]");
    assert_eq!(output.stats.block_syncs, 2);
}

#[test]
fn test_shared_exchange_without_barrier_races() {
    let src = wrap(&SWAP_BODY.replace("BARRIER", ""));
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected data race, got: {}",
        err
    );
}

/// A store through the `.extern .shared` window must not be visible through a
/// static `.shared` variable (the dynamic segment follows all static ones),
/// so the `lut` read surfaces as `UndefinedOutput`.
#[test]
fn test_extern_shared_store_invisible_through_static_shared() {
    let src = wrap(
        ".extern .shared .align 16 .b8 buf[];
.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<2>;
    .shared .align 4 .f32 lut[64];

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, buf;
    mov.f32 %f1, 0f42280000;
    st.shared.f32 [%r1], %f1;
    mov.u32 %r2, lut;
    ld.shared.f32 %f2, [%r2];
    st.global.f32 [%rd1], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected undefined output (buf and lut must not alias), got: {}",
        err
    );
}

/// Unsynchronized accesses to the extern window and to a static `.shared`
/// variable from different threads are not a race: the regions are disjoint.
#[test]
fn test_extern_vs_static_shared_no_false_race() {
    let src = wrap(
        ".extern .shared .align 16 .b8 buf[];
.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<3>;
    .reg .f32 %f<4>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<2>;
    .shared .align 4 .f32 lut[64];

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p1, %r1, 0;
    setp.eq.s32 %p2, %r1, 1;
    mov.u32 %r2, buf;
    mov.f32 %f1, 0f42280000;
@%p1 st.shared.f32 [%r2], %f1;
    mov.u32 %r3, lut;
    mov.f32 %f2, 0f40E00000;
@%p2 st.shared.f32 [%r3], %f2;
@%p2 ld.shared.f32 %f3, [%r3];
@%p2 st.global.f32 [%rd1], %f3;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = in_out_config(2, 1);
    config.dynamic_shared_bytes = 16;
    let output = analyze_kernel(&module, None, config)
        .expect("disjoint extern/static shared accesses must not race");
    assert_eq!(display_output(&output, "out", 0), "7");
}

/// Extern-only kernels are unaffected by extern-window placement: the window
/// starts at offset 0, roundtrips work, a missing size errors, and
/// dynamic_shared_bytes bounds it.
#[test]
fn test_extern_only_shared_placement_and_bounds() {
    let body = ".extern .shared .align 16 .b8 buf[];
.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, buf;
    mov.f32 %f1, 0f42280000;
    st.shared.f32 [%r1OFFSET], %f1;
    ld.shared.f32 %f2, [%r1];
    st.global.f32 [%rd1], %f2;
    ret;
}
";
    // In-bounds roundtrip at buf[0].
    let src = wrap(&body.replace("OFFSET", ""));
    let module = parse(&src);
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    let output = analyze_kernel(&module, None, config).expect("in-bounds extern access");
    assert_eq!(display_output(&output, "out", 0), "42");

    // Without dynamic_shared_bytes the launch is rejected.
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Config { message })
                if message.contains("dynamic_shared_bytes")
        ),
        "expected missing dynamic_shared_bytes error, got: {}",
        err
    );

    // A store ending one byte past the window end is out of bounds.
    let src = wrap(&body.replace("OFFSET", "+16"));
    let module = parse(&src);
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::OutOfBounds { .. })),
        "expected out-of-bounds, got: {}",
        err
    );
}

/// Threads waiting on different barrier ids never fire: deadlock.
#[test]
fn test_mismatched_barriers_deadlock() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<2>;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p1, %r1, 0;
    @%p1 bra $L1;
    bar.sync 0;
    bra $L2;
$L1:
    bar.sync 1;
$L2:
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::Deadlock { .. })),
        "expected deadlock, got: {}",
        err
    );
}

/// A thread that exits counts as having arrived at the barrier (paper's
/// Sync rule allows `return`), so this does NOT deadlock.
#[test]
fn test_exited_thread_releases_barrier() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<2>;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p1, %r1, 0;
    @%p1 ret;
    bar.sync 0;
    ret;
}
",
    );
    let module = parse(&src);
    analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1))).unwrap();
}

/// `mbarrier.init` with `count = 2` needs both threads' `arrive` before
/// `try_wait.parity` proceeds: the scheduler wakes a thread when a
/// *different* thread's arrive completes the phase.
#[test]
fn test_mbarrier_wait_wakes_on_another_threads_arrive() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .f32 %f<2>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<4>;
    .shared .align 8 .b64 mbar;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p0, %r1, 0;
    mov.u32 %r2, mbar;

    @%p0 mbarrier.init.shared::cta.b64 [%r2], 2;
    bar.sync 0;
    mbarrier.arrive.shared::cta.b64 _, [%r2];
    mbarrier.try_wait.parity.shared::cta.b64 %p1, [%r2], 0;

    ld.param.u64 %rd1, [k_param_1];
    mul.wide.u32 %rd2, %r1, 4;
    add.s64 %rd3, %rd1, %rd2;
    mov.f32 %f1, 0f3F800000;
    st.global.f32 [%rd3], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "1");
}

/// Same shape, but only thread 0 arrives: `count = 2` is never satisfied, so
/// its `try_wait.parity` blocks forever - a genuine deadlock of the whole
/// CTA.
#[test]
fn test_mbarrier_wait_never_satisfied_deadlocks() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<3>;
    .shared .align 8 .b64 mbar;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p0, %r1, 0;
    mov.u32 %r2, mbar;

    @%p0 mbarrier.init.shared::cta.b64 [%r2], 2;
    bar.sync 0;
    @%p0 mbarrier.arrive.shared::cta.b64 _, [%r2];
    mbarrier.try_wait.parity.shared::cta.b64 %p1, [%r2], 0;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::Deadlock { .. })),
        "expected deadlock, got: {}",
        err
    );
}

/// `mbarrier.arrive.expect_tx` + `mbarrier.complete_tx` end to end: the wait
/// is not satisfied by the arrival alone, only once `complete_tx` clears the
/// outstanding transaction.
#[test]
fn test_mbarrier_expect_tx_blocks_until_complete_tx() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p0;
    .reg .f32 %f0;
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;
    .shared .align 8 .b64 mbar;

    mov.u32 %r1, mbar;
    mbarrier.init.shared::cta.b64 [%r1], 1;
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [%r1], 16;
    mbarrier.complete_tx.shared::cta.b64 [%r1], 16;
    mbarrier.try_wait.parity.shared::cta.b64 %p0, [%r1], 0;

    ld.param.u64 %rd1, [k_param_1];
    mov.f32 %f0, 0f3F800000;
    st.global.f32 [%rd1], %f0;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `mbarrier.arrive`/`try_wait.parity` is a χ happens-before edge (PTX ISA
/// 9.7.14.16.19): thread 0 writes then arrives, thread 1 waits then reads,
/// with no race reported.
#[test]
fn test_mbarrier_arrive_wait_establishes_happens_before() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .f32 %f<2>;
    .reg .b32 %r<7>;
    .reg .b64 %rd<4>;
    .shared .align 8 .b64 mbar;
    .shared .align 4 .b32 data;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p0, %r1, 0;
    mov.u32 %r2, mbar;
    mov.u32 %r4, data;

    @%p0 mbarrier.init.shared::cta.b64 [%r2], 1;
    @%p0 mov.u32 %r5, 42;
    @%p0 st.shared.u32 [%r4], %r5;
    @%p0 mbarrier.arrive.shared::cta.b64 _, [%r2];

    @!%p0 mbarrier.try_wait.parity.shared::cta.b64 %p1, [%r2], 0;
    @!%p0 ld.shared.u32 %r6, [%r4];
    @!%p0 cvt.rn.f32.u32 %f1, %r6;

    ld.param.u64 %rd1, [k_param_1];
    mul.wide.u32 %rd2, %r1, 4;
    add.s64 %rd3, %rd1, %rd2;
    @!%p0 st.global.f32 [%rd3], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 1), "42");
}

/// Same write/read pair, but thread 1 reads without waiting: must race, so
/// the sibling test's success comes from the mbarrier edge, not the kernel
/// shape.
#[test]
fn test_same_write_read_without_the_wait_still_races() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<7>;
    .shared .align 4 .b32 data;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p0, %r1, 0;
    mov.u32 %r4, data;

    @%p0 mov.u32 %r5, 42;
    @%p0 st.shared.u32 [%r4], %r5;

    @!%p0 ld.shared.u32 %r6, [%r4];
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected a data race, got: {}",
        err
    );
}

/// `.relaxed` on `mbarrier.arrive`/`try_wait.parity` is rejected at lowering:
/// it has no ordering semantics (9.7.14.16.16/.19), so accepting it would
/// make the happens-before edge unsound.
#[test]
fn test_mbarrier_relaxed_semantics_rejected() {
    for (form, expect) in [
        (
            "mbarrier.arrive.relaxed.cta.shared::cta.b64 _, [%r2];",
            "mbarrier.arrive",
        ),
        (
            "mbarrier.try_wait.parity.relaxed.cta.shared::cta.b64 %p1, [%r2], 0;",
            "mbarrier.try_wait",
        ),
    ] {
        let src = wrap(&format!(
            ".visible .entry k()
{{
    .reg .pred %p<2>;
    .reg .b32 %r<3>;
    .shared .align 8 .b64 mbar;

    mov.u32 %r2, mbar;
    mbarrier.init.shared::cta.b64 [%r2], 1;
    mbarrier.arrive.shared::cta.b64 _, [%r2];
    {form}
    ret;
}}
"
        ));
        let module = parse(&src);
        let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction { instruction, .. }) => {
                assert_eq!(instruction, expect, "wrong instruction name for {}", form);
            }
            other => panic!(
                "expected UnsupportedInstruction for {}, got: {}",
                form, other
            ),
        }
    }
}

/// `tcgen05.fence::before_thread_sync`/`::after_thread_sync` parse (via the
/// `::`-glued trie fallback) and are pure ordering fences: eval just falls
/// through.
#[test]
fn test_tcgen05_fence_is_a_no_op() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f0;
    .reg .b64 %rd0;

    tcgen05.fence::before_thread_sync;
    tcgen05.fence::after_thread_sync;

    ld.param.u64 %rd0, [k_param_0];
    mov.f32 %f0, 0f3F800000;
    st.global.f32 [%rd0], %f0;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `tcgen05.commit`'s `.mbarrier::arrive::one` alone satisfies a `count = 1`
/// mbarrier's `try_wait.parity`; `.shared::cluster` covers the optional
/// state-space path.
#[test]
fn test_tcgen05_commit_satisfies_mbarrier_wait() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p0;
    .reg .f32 %f0;
    .reg .b32 %r0;
    .reg .b64 %rd0;
    .shared .align 8 .b64 mbar;

    mov.u32 %r0, mbar;
    mbarrier.init.shared::cta.b64 [%r0], 1;
    tcgen05.commit.cta_group::1.mbarrier::arrive::one.shared::cluster.b64 [%r0];
    mbarrier.try_wait.parity.shared::cta.b64 %p0, [%r0], 0;

    ld.param.u64 %rd0, [k_param_0];
    mov.f32 %f0, 0f3F800000;
    st.global.f32 [%rd0], %f0;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// Lower `body` (one warp's kernel body using `%r<6>` and a `taddr_slot`)
/// under `header`.
fn tcgen05_kernel(header: &str, body: &str) -> Module {
    parse(&format!(
        "{header}.visible .entry k()
{{
    .reg .b32 %r<6>;
    .shared .align 4 .b32 taddr_slot;

    mov.u32 %r3, taddr_slot;
{body}
    ret;
}}
"
    ))
}

/// The warp-collective `tcgen05.*` instructions require `.sync.aligned`
/// (PTX ISA: "The mandatory .sync qualifier" / "The mandatory .aligned
/// qualifier"); dropping either is invalid PTX.
#[test]
fn test_tcgen05_rejects_missing_sync_aligned() {
    for (body, missing) in [
        (
            "    tcgen05.alloc.cta_group::1.aligned.shared::cta.b32 [%r3], 32;",
            ".sync",
        ),
        (
            "    tcgen05.alloc.cta_group::1.sync.shared::cta.b32 [%r3], 32;",
            ".aligned",
        ),
        ("    tcgen05.ld.32x32b.x1.b32 %r1, [%r3];", ".sync"),
        ("    tcgen05.st.sync.32x32b.x1.b32 [%r3], %r1;", ".aligned"),
        ("    tcgen05.wait::ld.aligned;", ".sync"),
        (
            "    tcgen05.dealloc.cta_group::1.sync.b32 %r3, 32;",
            ".aligned",
        ),
        (
            "    tcgen05.relinquish_alloc_permit.cta_group::1.sync;",
            ".aligned",
        ),
    ] {
        let module = tcgen05_kernel(HEADER_SM100A, body);
        expect_invalid_instruction(&module, &format!("mandatory {missing} qualifier"));
    }
}

/// `nCols` below the 32-column allocation unit is invalid even when it is
/// a power of 2, and the column count must not increase between two
/// allocations (PTX ISA 9.7.18.7.1).
#[test]
fn test_tcgen05_alloc_rejects_invalid_sizes_and_order() {
    let alloc = |n: u32| {
        format!("    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], {n};\n")
    };
    let err = analyze_kernel(
        &tcgen05_kernel(HEADER_SM100A, &alloc(16)),
        None,
        AnalysisConfig::new((32, 1, 1)),
    )
    .unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05InvalidColumnCount { num_cols: 16, .. })
        ),
        "{err}"
    );
    let err = analyze_kernel(
        &tcgen05_kernel(HEADER_SM100A, &(alloc(32) + &alloc(64))),
        None,
        AnalysisConfig::new((32, 1, 1)),
    )
    .unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05IncreasingColumnCount {
                previous: 32,
                requested: 64,
                ..
            })
        ),
        "{err}"
    );
}

/// `.exclusive` allocation and deallocation (PTX ISA 9.4+) are rejected as
/// unsupported naming `.exclusive`, not judged by the non-exclusive rules (96
/// columns is not a power of 2).
#[test]
fn test_tcgen05_exclusive_alloc_and_dealloc_are_not_implemented() {
    for body in [
        "    tcgen05.alloc.exclusive.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 96;",
        "    tcgen05.dealloc.exclusive.cta_group::1.sync.aligned.b32 %r3, 96;",
    ] {
        let err = analyze_kernel(
            &tcgen05_kernel(HEADER_SM100A, body),
            None,
            AnalysisConfig::new((32, 1, 1)),
        )
        .unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. }) => {
                let reason = reason.as_deref().unwrap_or("");
                assert!(
                    reason.contains(".exclusive") && reason.contains("not implemented"),
                    "{reason}"
                );
            }
            other => panic!("expected UnsupportedInstruction, got: {other}"),
        }
    }
}

/// A `tcgen05.st` whose column range starts in one allocation and runs
/// past its end is rejected, even though the next columns belong to an
/// adjacent live allocation (so every cell it touches is allocated).
#[test]
fn test_tcgen05_access_past_an_allocation_into_an_adjacent_one_is_rejected() {
    let module = tcgen05_kernel(
        HEADER_SM100A,
        "    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3+0], 32;
    mov.u32 %r1, 0;
    // Columns 31 and 32: the last of the first allocation, the first of
    // the second.
    mov.u32 %r2, 31;
    tcgen05.st.sync.aligned.32x32b.x2.b32 [%r2], {%r1, %r1};
    tcgen05.wait::st.sync.aligned;",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05AccessOutsideAllocation {
                start_col: 31,
                num_cols: 2,
                ..
            })
        ),
        "{err}"
    );
}

/// `tcgen05.ld`/`.st` decode `taddr` as a Tensor Memory address (PTX ISA
/// 9.7.17.1.1: `[31:16]=lane, [15:0]=column`): two warps each pack their own
/// quadrant and read back exactly their own value.
#[test]
fn test_tcgen05_st_ld_respects_warp_quadrant_addressing() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<2>;
    .reg .f32 %f<2>;
    .reg .b32 %r<10>;
    .reg .b64 %rd<3>;
    .shared .align 4 .b32 taddr_slot;

    mov.u32 %r9, %tid.x;
    setp.lt.u32 %p1, %r9, 32;
    mov.u32 %r3, taddr_slot;
    @%p1 tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    bar.sync 0;
    ld.shared.u32 %r1, [%r3];
    bar.sync 0;

    shr.u32 %r4, %r9, 5;
    shl.u32 %r5, %r4, 5;
    shl.u32 %r6, %r5, 16;
    or.b32 %r7, %r1, %r6;

    tcgen05.st.sync.aligned.32x32b.x1.b32 [%r7], %r4;
    tcgen05.wait::st.sync.aligned;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r8, [%r7];
    tcgen05.wait::ld.sync.aligned;
    cvt.rn.f32.u32 %f1, %r8;

    ld.param.u64 %rd1, [k_param_0];
    mul.wide.u32 %rd2, %r9, 4;
    add.s64 %rd2, %rd1, %rd2;
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 64,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "0");
    assert_eq!(display_output(&output, "out", 31), "0");
    assert_eq!(display_output(&output, "out", 32), "1");
    assert_eq!(display_output(&output, "out", 63), "1");
}

/// A `taddr` naming a lane quadrant other than the issuing warp's (PTX ISA
/// 9.7.17.8.1) must error, not be silently "corrected" by deriving the lane
/// from `ThreadId`.
#[test]
fn test_tcgen05_st_rejects_wrong_quadrant_address() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b32 %r<6>;
    .shared .align 4 .b32 taddr_slot;

    mov.u32 %r5, %tid.x;
    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    bar.sync 0;
    ld.shared.u32 %r1, [%r3];
    bar.sync 0;

    // Wrong on purpose: this warp's own quadrant is 0, not 32.
    or.b32 %r2, %r1, 2097152;
    tcgen05.st.sync.aligned.32x32b.x1.b32 [%r2], %r5;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05LaneRestrictionViolation {
            lane_base,
            expected_quadrant_base,
            ..
        }) => {
            assert_eq!(*lane_base, 32);
            assert_eq!(*expected_quadrant_base, 0);
        }
        other => panic!("expected Tcgen05LaneRestrictionViolation, got: {}", other),
    }
}

/// One warp allocates Tensor Memory, then runs `body` with `%r1` its
/// quadrant-0 base, `%r2` a stored value, and `%r4` a `count = 32` mbarrier
/// (for the `tcgen05.wait` tests).
fn tcgen05_wait_ordering_kernel(body: &str) -> Module {
    parse(&wrap(&format!(
        ".visible .entry k()
{{
    .reg .b32 %r<6>;
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mbar;

    mov.u32 %r2, %tid.x;
    mov.u32 %r3, taddr_slot;
    mov.u32 %r4, mbar;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    mbarrier.init.shared::cta.b64 [%r4], 32;
    bar.sync 0;
    ld.shared.u32 %r1, [%r3];
    bar.sync 0;

{body}
    ret;
}}
"
    )))
}

/// A `tcgen05.wait::ld` placed *after* a barrier arrival is too late: the
/// wait is what completes the `.ld` for its issuer, so the barrier orders
/// nothing about it for the other participants. The arrival is rejected.
#[test]
fn test_tcgen05_wait_ld_after_bar_sync_is_rejected() {
    let module = tcgen05_wait_ordering_kernel(
        "    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r5, [%r1];
    bar.sync 0;
    tcgen05.wait::ld.sync.aligned;",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05UnwaitedAtSync { pending, .. }) => {
            assert!(!pending.is_write);
        }
        other => panic!("expected Tcgen05UnwaitedAtSync, got: {}", other),
    }
}

/// Same for `tcgen05.wait::st` after an mbarrier arrive.
#[test]
fn test_tcgen05_wait_st_after_mbarrier_arrive_is_rejected() {
    let module = tcgen05_wait_ordering_kernel(
        "    tcgen05.st.sync.aligned.32x32b.x1.b32 [%r1], %r2;
    mbarrier.arrive.shared::cta.b64 _, [%r4];
    tcgen05.wait::st.sync.aligned;",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05UnwaitedAtSync { pending, .. }) => {
            assert!(pending.is_write);
        }
        other => panic!("expected Tcgen05UnwaitedAtSync, got: {}", other),
    }
}

/// The control: the same `.ld`/`.st` waited *before* the arrivals pass.
#[test]
fn test_tcgen05_wait_before_sync_is_accepted() {
    let module = tcgen05_wait_ordering_kernel(
        "    tcgen05.st.sync.aligned.32x32b.x1.b32 [%r1], %r2;
    tcgen05.wait::st.sync.aligned;
    mbarrier.arrive.shared::cta.b64 _, [%r4];
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r5, [%r1];
    tcgen05.wait::ld.sync.aligned;
    bar.sync 0;",
    );
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// `tcgen05.dealloc` with an un-waited `tcgen05.ld`/`.st` still
/// outstanding on the range is rejected: the async op would touch columns
/// that are no longer allocated.
#[test]
fn test_tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected() {
    for (op, is_write) in [
        ("tcgen05.ld.sync.aligned.32x32b.x1.b32 %r5, [%r1];", false),
        ("tcgen05.st.sync.aligned.32x32b.x1.b32 [%r1], %r2;", true),
    ] {
        let module = tcgen05_wait_ordering_kernel(&format!(
            "    {op}
    tcgen05.dealloc.cta_group::1.sync.aligned.b32 %r1, 32;"
        ));
        let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
        match &err {
            AnalysisError::Eval(EvalError::Tcgen05AsyncHazard { prior, current, .. }) => {
                assert_eq!(prior.is_write, is_write, "{op}");
                assert!(current.is_write);
            }
            other => panic!("{op}: expected Tcgen05AsyncHazard, got: {}", other),
        }
    }
}

/// The control: the same `.ld`/`.st` waited before the `tcgen05.dealloc`
/// pass.
#[test]
fn test_tcgen05_dealloc_after_waiting_is_accepted() {
    let module = tcgen05_wait_ordering_kernel(
        "    tcgen05.st.sync.aligned.32x32b.x1.b32 [%r1], %r2;
    tcgen05.wait::st.sync.aligned;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r5, [%r1];
    tcgen05.wait::ld.sync.aligned;
    tcgen05.dealloc.cta_group::1.sync.aligned.b32 %r1, 32;",
    );
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// `tensormap.replace` (8x8 f16 map built in shared) +
/// `cp.async.bulk.tensor`: a 4x4 box at (6, 6) reads input in bounds and
/// `fill_mode` zeros past `global_dim`; `complete_tx` unblocks the wait.
#[test]
fn test_cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds() {
    let template = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p0;
    .reg .b16 %rs<3>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    .shared .align 128 .b8 sd0[128];
    .global .align 128 .b8 gbl[128];
    .shared .align 8 .b8 full[8];
    .shared .align 16 .b8 sa[32];

    ld.param.u64 %rd1, [k_param_0];

    mbarrier.init.shared::cta.b64 [full], 1;
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [full], 32;

    tensormap.replace.tile.global_address.shared::cta.b1024.b64 [sd0], %rd1;
    tensormap.replace.tile.rank.shared::cta.b1024.b32 [sd0], 1;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 0, 8;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 1, 8;
    tensormap.replace.tile.global_stride.shared::cta.b1024.b64 [sd0], 0, 16;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 0, 4;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 1, 4;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 0, 1;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 1, 1;
    tensormap.replace.tile.elemtype.shared::cta.b1024.b32 [sd0], 6;
    tensormap.replace.tile.interleave_layout.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_mode.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_atomicity.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.fill_mode.shared::cta.b1024.b32 [sd0], 0;

    tensormap.cp_fenceproxy.global.shared::cta.tensormap::generic.release.gpu.sync.aligned [gbl], [sd0], 128;
    fence.proxy.tensormap::generic.acquire.gpu [gbl], 128;

    mov.u32 %r1, 6;
    mov.u32 %r2, 6;
    cp.async.bulk.tensor.2d.shared::cluster.global.tile.mbarrier::complete_tx::bytes [sa], [gbl, {%r1, %r2}], [full];

    mbarrier.try_wait.parity.shared::cta.b64 %p0, [full], 0;

    ld.shared.u16 %rs1, [sa];
    ld.shared.u16 %rs2, [sa+30];

    ld.param.u64 %rd2, [k_param_1];
    st.global.u16 [%rd2], %rs1;
    st.global.u16 [%rd2+2], %rs2;
    ret;
}
",
    );
    for scope in ["cluster", "cta"] {
        let src = template.replace("shared::cluster.global", &format!("shared::{scope}.global"));
        let module = parse(&src);
        let mut config = AnalysisConfig::new((1, 1, 1));
        config.arrays = vec![
            ArrayDef {
                name: "in".to_string(),
                base: 0x10000,
                elem_width: 2,
                len: 64,
                kind: ArrayKind::Input,
            },
            ArrayDef {
                name: "out".to_string(),
                base: 0x20000,
                elem_width: 2,
                len: 2,
                kind: ArrayKind::Output,
            },
        ];
        config.params = vec![
            ParamValue::ArrayPtr("in".to_string()),
            ParamValue::ArrayPtr("out".to_string()),
        ];
        let output = analyze_kernel(&module, None, config).unwrap();
        assert_eq!(display_output(&output, "out", 0), "in[54]", "{scope}");
        assert_eq!(display_output(&output, "out", 1), "0", "{scope}");
    }
}

/// `cp.async.bulk.tensor` on a tensor-map missing a field (`.fill_mode`) must
/// error naming it: an incomplete map is a kernel bug, not a gap to fill with
/// a default.
#[test]
fn test_cp_async_bulk_tensor_rejects_an_incomplete_tensor_map() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<3>;
    .reg .b64 %rd<2>;

    .shared .align 128 .b8 sd0[128];
    .global .align 128 .b8 gbl[128];
    .shared .align 8 .b8 full[8];
    .shared .align 16 .b8 sa[32];

    ld.param.u64 %rd1, [k_param_0];

    mbarrier.init.shared::cta.b64 [full], 1;

    tensormap.replace.tile.global_address.shared::cta.b1024.b64 [sd0], %rd1;
    tensormap.replace.tile.rank.shared::cta.b1024.b32 [sd0], 1;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 0, 8;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 1, 8;
    tensormap.replace.tile.global_stride.shared::cta.b1024.b64 [sd0], 0, 16;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 0, 4;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 1, 4;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 0, 1;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 1, 1;
    tensormap.replace.tile.elemtype.shared::cta.b1024.b32 [sd0], 6;
    tensormap.replace.tile.interleave_layout.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_mode.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_atomicity.shared::cta.b1024.b32 [sd0], 0;

    tensormap.cp_fenceproxy.global.shared::cta.tensormap::generic.release.gpu.sync.aligned [gbl], [sd0], 128;
    fence.proxy.tensormap::generic.acquire.gpu [gbl], 128;

    mov.u32 %r1, 0;
    mov.u32 %r2, 0;
    cp.async.bulk.tensor.2d.shared::cluster.global.tile.mbarrier::complete_tx::bytes [sa], [gbl, {%r1, %r2}], [full];
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "in".to_string(),
        base: 0x10000,
        elem_width: 2,
        len: 64,
        kind: ArrayKind::Input,
    }];
    config.params = vec![ParamValue::ArrayPtr("in".to_string())];
    let err = analyze_kernel(&module, None, config).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::TensorMapFieldMissing { field, .. }) => {
            assert_eq!(field, "fill_mode");
        }
        other => panic!("expected TensorMapFieldMissing, got: {}", other),
    }
}

/// `elect.sync` elects the lowest *live* lane in the mask (PTX ISA
/// 9.7.14.15): with a full warp, lane 0 gets `dst = 0` and `dst_pred` true;
/// each thread encodes both as one f32.
#[test]
fn test_elect_sync_elects_the_lowest_active_lane() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<2>;
    .reg .f32 %f<4>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    mov.u32 %r1, %tid.x;
    elect.sync %r2|%p0, -1;

    mov.f32 %f1, 0f00000000;
    @%p0 cvt.rn.f32.u32 %f2, %r2;
    @%p0 mov.f32 %f3, 0f447A0000;
    @%p0 add.f32 %f1, %f2, %f3;

    ld.param.u64 %rd1, [k_param_0];
    mul.wide.u32 %rd2, %r1, 4;
    add.s64 %rd2, %rd1, %rd2;
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 32,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1000");
    assert_eq!(display_output(&output, "out", 1), "0");
    assert_eq!(display_output(&output, "out", 31), "0");
}

/// Same shape, but lane 0 exits before `elect.sync`: exited lanes count as
/// arrived but cannot be leader, so lane 1 is elected.
#[test]
fn test_elect_sync_skips_an_already_exited_lane() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .f32 %f<4>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p1, %r1, 0;
    @%p1 ret;

    elect.sync %r2|%p0, -1;

    mov.f32 %f1, 0f00000000;
    @%p0 cvt.rn.f32.u32 %f2, %r2;
    @%p0 mov.f32 %f3, 0f447A0000;
    @%p0 add.f32 %f1, %f2, %f3;

    ld.param.u64 %rd1, [k_param_0];
    mul.wide.u32 %rd2, %r1, 4;
    add.s64 %rd2, %rd1, %rd2;
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 32,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 1), "1001");
    assert_eq!(display_output(&output, "out", 5), "0");
}

/// `tcgen05.mma` with `triton_generated.ptx`'s exact `idesc`/descriptors
/// (`.kind::f16`, M=128, N=256, 128B swizzle) over uninitialized shared
/// buffers: every `(m, n, k)` address must land in bounds.
#[test]
fn test_tcgen05_mma_real_kernel_descriptors_run_to_completion() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<5>;
    .shared .align 1024 .b8 a_buf[16384];
    .shared .align 1024 .b8 b_buf[32768];
    .shared .align 4 .b32 taddr_slot;

    // tcgen05.alloc is warp-collective: every lane of this one-warp CTA
    // issues it unconditionally.
    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 256;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r5, %tid.x;
    setp.eq.s32 %p1, %r5, 0;

    mov.u64 %rd1, a_buf;
    shr.u64 %rd1, %rd1, 4;
    or.b64 %rd1, %rd1, 4611756662049472512;
    mov.u64 %rd2, b_buf;
    shr.u64 %rd2, %rd2, 4;
    or.b64 %rd2, %rd2, 4611756662083026944;
    mov.u32 %r2, 138477584;
    mov.pred %p0, 0;
    // tcgen05.mma is single-thread-issued: only the warp's lane 0 issues it.
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd1, %rd2, %r2, {0,0,0,0}, %p0;
    ret;
}
",
    );
    let module = parse(&src);
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// A synthetic `.kind::f16` `tcgen05.mma` (M=128, N=8) with
/// `SwizzleMode::None` K-major descriptors packed at 32 bytes/row reaches
/// `exec_tcgen05_mma`'s addressing end to end.
#[test]
fn test_tcgen05_mma_no_swizzle_mode_runs_to_completion() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<5>;
    .shared .align 1024 .b8 a_buf[4096];
    .shared .align 1024 .b8 b_buf[1024];
    .shared .align 4 .b32 taddr_slot;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r5, %tid.x;
    setp.eq.s32 %p1, %r5, 0;

    // SwizzleMode::None, stride_dim_byte_offset = 32 bytes (K=16 f16
    // elements, tightly packed - no atom concept for this mode).
    mov.u64 %rd1, a_buf;
    shr.u64 %rd1, %rd1, 4;
    or.b64 %rd1, %rd1, 70377334112256;
    mov.u64 %rd2, b_buf;
    shr.u64 %rd2, %rd2, 4;
    or.b64 %rd2, %rd2, 70377334112256;
    // dense, D=f32, A/B=f16, no negate/transpose, M=128, N=8.
    mov.u32 %r2, 134348816;
    mov.pred %p0, 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd1, %rd2, %r2, {0,0,0,0}, %p0;
    ret;
}
",
    );
    let module = parse(&src);
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// LLVM's NVPTX backend emits 5-operand `tcgen05.mma` with no
/// `disable-output-lane`, so the mask is optional (no lane disabled): like
/// `test_tcgen05_mma_numeric_correctness`, must produce `136`.
#[test]
fn test_tcgen05_mma_without_an_explicit_disable_output_lane_mask() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .b32 %r<7>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .b16 %rs<2>;
    .shared .align 1024 .b8 a_buf[16384];
    .shared .align 1024 .b8 b_buf[4096];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .reg .pred %pw;
    .reg .b32 %rbar;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r6, %tid.x;
    setp.eq.s32 %p1, %r6, 0;

    mov.u64 %rd1, a_buf;
    mov.u64 %rd2, b_buf;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+0], %rs1;
    mov.f32 %f1, 0f40000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+2], %rs1;
    mov.f32 %f1, 0f40400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+4], %rs1;
    mov.f32 %f1, 0f40800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+6], %rs1;
    mov.f32 %f1, 0f40A00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+8], %rs1;
    mov.f32 %f1, 0f40C00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+10], %rs1;
    mov.f32 %f1, 0f40E00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+12], %rs1;
    mov.f32 %f1, 0f41000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+14], %rs1;
    mov.f32 %f1, 0f41100000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+16], %rs1;
    mov.f32 %f1, 0f41200000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+18], %rs1;
    mov.f32 %f1, 0f41300000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+20], %rs1;
    mov.f32 %f1, 0f41400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+22], %rs1;
    mov.f32 %f1, 0f41500000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+24], %rs1;
    mov.f32 %f1, 0f41600000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+26], %rs1;
    mov.f32 %f1, 0f41700000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+28], %rs1;
    mov.f32 %f1, 0f41800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+30], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+0], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+144], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+288], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+432], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+576], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+720], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+864], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1008], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1024], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1168], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1312], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1456], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1600], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1744], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1888], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+2032], %rs1;

    shr.u64 %rd3, %rd1, 4;
    or.b64 %rd3, %rd3, 4611756662049472512;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd4, %rd4, 4611756662049472512;
    mov.u32 %r2, 134414352;
    mov.pred %p0, 0;
    // Proper async completion: publish the operand stores to the async
    // proxy, commit the MMA to an mbarrier, wait on it, then fence.
    fence.proxy.async.shared::cta;
    mov.u32 %rbar, mma_bar;
    @%p1 mbarrier.init.shared.b64 [%rbar], 1;
    bar.sync 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd3, %rd4, %r2, %p0;
    @%p1 tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%rbar];
MMA_WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%rbar], 0;
    @!%pw bra MMA_WAIT;
    tcgen05.fence::after_thread_sync;

    tcgen05.ld.sync.aligned.32x32b.x1.b32 %f1, [%r1];
    ld.param.u64 %rd1, [k_param_0];
    @%p1 st.global.f32 [%rd1], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "136");
}

/// `tcgen05.mma` decodes concrete operands from their bits: `A`/`B` hold raw
/// f16 `0x3C00` (1.0, not 15360) and `D` is seeded with raw f32 1.0 via
/// `tcgen05.st`, so `D[0][0] = 16 + 1 = 17`.
#[test]
fn test_tcgen05_mma_decodes_raw_operand_and_accumulator_bits() {
    let a_offsets = (0..16).map(|k| 2 * k);
    let b_offsets = [
        0, 144, 288, 432, 576, 720, 864, 1008, 1024, 1168, 1312, 1456, 1600, 1744, 1888, 2032,
    ];
    let mut stores = String::new();
    for off in a_offsets {
        stores += &format!("    @%p1 st.shared.b16 [%rd1+{off}], %rs1;\n");
    }
    for off in b_offsets {
        stores += &format!("    @%p1 st.shared.b16 [%rd2+{off}], %rs1;\n");
    }
    let src = wrap(&format!(
        ".visible .entry k(
    .param .u64 k_param_0
)
{{
    .reg .pred %p<3>;
    .reg .b32 %r<8>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .b16 %rs<2>;
    .shared .align 1024 .b8 a_buf[16384];
    .shared .align 1024 .b8 b_buf[4096];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .reg .pred %pw;
    .reg .b32 %rbar;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r6, %tid.x;
    setp.eq.s32 %p1, %r6, 0;

    mov.b32 %r7, 0x3F800000;
    tcgen05.st.sync.aligned.32x32b.x1.b32 [%r1], %r7;
    tcgen05.wait::st.sync.aligned;

    mov.u64 %rd1, a_buf;
    mov.u64 %rd2, b_buf;
    mov.b16 %rs1, 0x3C00;
{stores}
    shr.u64 %rd3, %rd1, 4;
    or.b64 %rd3, %rd3, 4611756662049472512;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd4, %rd4, 4611756662049472512;
    mov.u32 %r2, 134414352;
    mov.pred %p0, 1;
    fence.proxy.async.shared::cta;
    mov.u32 %rbar, mma_bar;
    @%p1 mbarrier.init.shared.b64 [%rbar], 1;
    bar.sync 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd3, %rd4, %r2, %p0;
    @%p1 tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%rbar];
MMA_WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%rbar], 0;
    @!%pw bra MMA_WAIT;
    tcgen05.fence::after_thread_sync;

    tcgen05.ld.sync.aligned.32x32b.x1.b32 %f1, [%r1];
    ld.param.u64 %rd1, [k_param_0];
    @%p1 st.global.f32 [%rd1], %f1;
    ret;
}}
"
    ));
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "17");
}

/// Numeric check: `A[0][k] = k+1` and `B[k][0] = 1` as f16 at hand-computed
/// 128B-swizzled addresses (B transposed, crossing a stride atom at `k=8`);
/// `D[0][0]` must read back as `136`.
#[test]
fn test_tcgen05_mma_numeric_correctness() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .b32 %r<7>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .b16 %rs<2>;
    .shared .align 1024 .b8 a_buf[16384];
    .shared .align 1024 .b8 b_buf[4096];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .reg .pred %pw;
    .reg .b32 %rbar;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r6, %tid.x;
    setp.eq.s32 %p1, %r6, 0;

    mov.u64 %rd1, a_buf;
    mov.u64 %rd2, b_buf;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+0], %rs1;
    mov.f32 %f1, 0f40000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+2], %rs1;
    mov.f32 %f1, 0f40400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+4], %rs1;
    mov.f32 %f1, 0f40800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+6], %rs1;
    mov.f32 %f1, 0f40A00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+8], %rs1;
    mov.f32 %f1, 0f40C00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+10], %rs1;
    mov.f32 %f1, 0f40E00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+12], %rs1;
    mov.f32 %f1, 0f41000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+14], %rs1;
    mov.f32 %f1, 0f41100000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+16], %rs1;
    mov.f32 %f1, 0f41200000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+18], %rs1;
    mov.f32 %f1, 0f41300000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+20], %rs1;
    mov.f32 %f1, 0f41400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+22], %rs1;
    mov.f32 %f1, 0f41500000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+24], %rs1;
    mov.f32 %f1, 0f41600000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+26], %rs1;
    mov.f32 %f1, 0f41700000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+28], %rs1;
    mov.f32 %f1, 0f41800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+30], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+0], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+144], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+288], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+432], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+576], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+720], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+864], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1008], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1024], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1168], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1312], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1456], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1600], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1744], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1888], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+2032], %rs1;

    shr.u64 %rd3, %rd1, 4;
    or.b64 %rd3, %rd3, 4611756662049472512;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd4, %rd4, 4611756662049472512;
    mov.u32 %r2, 134414352;
    mov.pred %p0, 0;
    // Proper async completion: publish the operand stores to the async
    // proxy, commit the MMA to an mbarrier, wait on it, then fence.
    fence.proxy.async.shared::cta;
    mov.u32 %rbar, mma_bar;
    @%p1 mbarrier.init.shared.b64 [%rbar], 1;
    bar.sync 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd3, %rd4, %r2, {0,0,0,0}, %p0;
    @%p1 tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%rbar];
MMA_WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%rbar], 0;
    @!%pw bra MMA_WAIT;
    tcgen05.fence::after_thread_sync;

    tcgen05.ld.sync.aligned.32x32b.x1.b32 %f1, [%r1];
    ld.param.u64 %rd1, [k_param_0];
    @%p1 st.global.f32 [%rd1], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "136");
}

/// Like `test_tcgen05_mma_numeric_correctness`, but `disable-output-lane`
/// masks lane 0 (PTX ISA 9.7.17.10.9.1): `D[0][0]` is never written, so it
/// reads back as `UndefinedOutput`, not `136`.
#[test]
fn test_tcgen05_mma_disable_output_lane_skips_the_write() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .b32 %r<7>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .b16 %rs<2>;
    .shared .align 1024 .b8 a_buf[16384];
    .shared .align 1024 .b8 b_buf[4096];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .reg .pred %pw;
    .reg .b32 %rbar;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r6, %tid.x;
    setp.eq.s32 %p1, %r6, 0;

    mov.u64 %rd1, a_buf;
    mov.u64 %rd2, b_buf;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+0], %rs1;
    mov.f32 %f1, 0f40000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+2], %rs1;
    mov.f32 %f1, 0f40400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+4], %rs1;
    mov.f32 %f1, 0f40800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+6], %rs1;
    mov.f32 %f1, 0f40A00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+8], %rs1;
    mov.f32 %f1, 0f40C00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+10], %rs1;
    mov.f32 %f1, 0f40E00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+12], %rs1;
    mov.f32 %f1, 0f41000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+14], %rs1;
    mov.f32 %f1, 0f41100000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+16], %rs1;
    mov.f32 %f1, 0f41200000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+18], %rs1;
    mov.f32 %f1, 0f41300000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+20], %rs1;
    mov.f32 %f1, 0f41400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+22], %rs1;
    mov.f32 %f1, 0f41500000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+24], %rs1;
    mov.f32 %f1, 0f41600000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+26], %rs1;
    mov.f32 %f1, 0f41700000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+28], %rs1;
    mov.f32 %f1, 0f41800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+30], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+0], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+144], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+288], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+432], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+576], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+720], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+864], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1008], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1024], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1168], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1312], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1456], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1600], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1744], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+1888], %rs1;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+2032], %rs1;

    shr.u64 %rd3, %rd1, 4;
    or.b64 %rd3, %rd3, 4611756662049472512;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd4, %rd4, 4611756662049472512;
    mov.u32 %r2, 134414352;
    mov.pred %p0, 0;
    // Proper async completion: publish the operand stores to the async
    // proxy, commit the MMA to an mbarrier, wait on it, then fence.
    fence.proxy.async.shared::cta;
    mov.u32 %rbar, mma_bar;
    @%p1 mbarrier.init.shared.b64 [%rbar], 1;
    bar.sync 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd3, %rd4, %r2, {1,0,0,0}, %p0;
    @%p1 tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%rbar];
MMA_WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%rbar], 0;
    @!%pw bra MMA_WAIT;
    tcgen05.fence::after_thread_sync;

    tcgen05.ld.sync.aligned.32x32b.x1.b32 %f1, [%r1];
    ld.param.u64 %rd1, [k_param_0];
    @%p1 st.global.f32 [%rd1], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected UndefinedOutput (lane 0 must never be written), got: {}",
        err
    );
}

/// Two-warp CTA: thread 0 issues an M=128, N=8 `tcgen05.mma` (D spans both
/// warps' lanes) committed to `mma_bar`. `%r1` = TMEM base, `%r4` = mbarrier,
/// `%r6` = `count = 32` `gate`, `%p2` = "in warp 0".
fn tcgen05_mma_two_warp_kernel(body: &str) -> Module {
    parse(&wrap(&format!(
        ".visible .entry k()
{{
    .reg .pred %p<4>;
    .reg .pred %pw;
    .reg .b32 %r<8>;
    .reg .b64 %rd<3>;
    .shared .align 1024 .b8 a_buf[4096];
    .shared .align 1024 .b8 b_buf[1024];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .shared .align 8 .b64 gate;

    mov.u32 %r3, taddr_slot;
    mov.u32 %r4, mma_bar;
    mov.u32 %r6, gate;
    mov.u32 %r5, %tid.x;
    setp.eq.s32 %p1, %r5, 0;
    setp.lt.u32 %p2, %r5, 32;
    @!%p2 bra ALLOCATED;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
ALLOCATED:
    @%p1 mbarrier.init.shared.b64 [%r4], 1;
    @%p1 mbarrier.init.shared.b64 [%r6], 32;
    bar.sync 0;
    ld.shared.u32 %r1, [%r3];

    mov.u64 %rd1, a_buf;
    shr.u64 %rd1, %rd1, 4;
    or.b64 %rd1, %rd1, 70377334112256;
    mov.u64 %rd2, b_buf;
    shr.u64 %rd2, %rd2, 4;
    or.b64 %rd2, %rd2, 70377334112256;
    mov.u32 %r2, 134348816;
    mov.pred %p0, 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd1, %rd2, %r2, {{0,0,0,0}}, %p0;
    @%p1 tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%r4];

{body}
    ret;
}}
"
    )))
}

/// A `bar.sync` between commit and completion orders nothing about the MMA:
/// warp 1, released by `gate` via a bare `complete_tx` (no edge), still races
/// the MMA's write of `D`.
#[test]
fn test_tcgen05_mma_bar_sync_before_completion_orders_nothing() {
    let module = tcgen05_mma_two_warp_kernel(
        "    bar.sync 0;
    @!%p2 bra READ;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
    setp.eq.s32 %p3, %r5, 1;
    @%p3 mbarrier.complete_tx.shared::cta.b64 [%r6], 32;
    bra DONE;
READ:
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [%r6], 1;
GATE:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r6], 0;
    @!%pw bra GATE;
    add.u32 %r7, %r1, 2097152;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r7, [%r7];
    tcgen05.wait::ld.sync.aligned;
DONE:",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::TensorMemoryRace {
            lane,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*lane, 32);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread.warp(), ThreadId(32).warp());
        }
        other => panic!("expected TensorMemoryRace, got: {}", other),
    }
}

/// The commit only attaches the completing mbarrier phase: `D` stays locked
/// until a waiter observes it, so warp 0 reading `D` right after the commit
/// hits the in-flight record.
#[test]
fn test_tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard() {
    let module = tcgen05_mma_two_warp_kernel(
        "    @!%p2 bra DONE;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r7, [%r1];
    tcgen05.wait::ld.sync.aligned;
DONE:",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05AsyncHazard {
            quadrant,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*quadrant, 0);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert!(!current.is_write);
        }
        other => panic!("expected Tcgen05AsyncHazard, got: {}", other),
    }
}

/// The MMA's shared operands stay write-locked from issue until a waiter
/// observes completion, even across a `bar.sync`: warp 1 overwriting `A` must
/// race.
#[test]
fn test_tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard() {
    let module = tcgen05_mma_two_warp_kernel(
        "    bar.sync 0;
    @%p2 bra DONE;
    mov.u64 %rd1, a_buf;
    st.shared.u32 [%rd1], %r5;
DONE:",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::AsyncCopyHazard {
            space,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*space, MemSpace::Shared);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(!prior.is_write);
            assert_eq!(current.thread, ThreadId(32));
            assert!(current.is_write);
        }
        other => panic!("expected AsyncCopyHazard, got: {}", other),
    }
}

/// The control: a `bar.sync` *after* warp 0 observed the completion does
/// order the MMA before warp 1's read.
#[test]
fn test_tcgen05_mma_bar_sync_after_completion_orders_the_read() {
    let module = tcgen05_mma_two_warp_kernel(
        "    @!%p2 bra SYNC;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
SYNC:
    bar.sync 0;
    @%p2 bra DONE;
    add.u32 %r6, %r1, 2097152;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r7, [%r6];
    tcgen05.wait::ld.sync.aligned;
DONE:",
    );
    analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

/// The control: warp 1 waiting on `mma_bar` itself is ordered after the
/// completion, whatever `bar.sync` ran before it.
#[test]
fn test_tcgen05_mma_every_reader_waiting_is_accepted() {
    let module = tcgen05_mma_two_warp_kernel(
        "    bar.sync 0;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
    @%p2 bra DONE;
    add.u32 %r6, %r1, 2097152;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r7, [%r6];
    tcgen05.wait::ld.sync.aligned;
DONE:",
    );
    analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

/// The MMA may write `D` any time after issue, so a `bar.sync` before the
/// commit orders nothing: warp 1's earlier read of `D`, ordered by a bare
/// `complete_tx` only, races the write.
#[test]
fn test_tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing() {
    let module = parse(&wrap(
        ".visible .entry k()
{
    .reg .pred %p<4>;
    .reg .pred %pw;
    .reg .b32 %r<9>;
    .reg .b64 %rd<3>;
    .shared .align 1024 .b8 a_buf[4096];
    .shared .align 1024 .b8 b_buf[1024];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .shared .align 8 .b64 gate;

    mov.u32 %r3, taddr_slot;
    mov.u32 %r4, mma_bar;
    mov.u32 %r6, gate;
    mov.u32 %r5, %tid.x;
    setp.eq.s32 %p1, %r5, 0;
    setp.lt.u32 %p2, %r5, 32;
    @!%p2 bra ALLOCATED;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
ALLOCATED:
    @%p1 mbarrier.init.shared.b64 [%r4], 1;
    @%p1 mbarrier.init.shared.b64 [%r6], 1;
    bar.sync 0;
    ld.shared.u32 %r1, [%r3];
    @!%p2 bra READ;
    @!%p1 bra SYNC;

    mbarrier.arrive.expect_tx.shared::cta.b64 _, [%r6], 4;
GATE:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r6], 0;
    @!%pw bra GATE;
    mov.u64 %rd1, a_buf;
    shr.u64 %rd1, %rd1, 4;
    or.b64 %rd1, %rd1, 70377334112256;
    mov.u64 %rd2, b_buf;
    shr.u64 %rd2, %rd2, 4;
    or.b64 %rd2, %rd2, 70377334112256;
    mov.u32 %r2, 134348816;
    mov.pred %p0, 0;
    tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd1, %rd2, %r2, {0,0,0,0}, %p0;
    bra SYNC;

READ:
    add.u32 %r7, %r1, 2097152;
    tcgen05.ld.sync.aligned.32x32b.x1.b32 %r8, [%r7];
    tcgen05.wait::ld.sync.aligned;
    setp.eq.s32 %p3, %r5, 32;
    @%p3 mbarrier.complete_tx.shared::cta.b64 [%r6], 4;

SYNC:
    bar.sync 0;
    @!%p1 bra DONE;
    tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%r4];
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
DONE:
    ret;
}
",
    ));
    let err = analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::TensorMemoryRace {
            lane,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*lane, 32);
            assert_eq!(prior.thread, ThreadId(32));
            assert!(!prior.is_write);
            assert_eq!(current.thread, ThreadId(0));
            assert!(current.is_write);
        }
        other => panic!("expected TensorMemoryRace, got: {}", other),
    }
}

/// `tcgen05.dealloc` of `D`'s columns while the MMA writing them is still
/// in flight - committed, but no thread has observed `mma_bar` - is
/// rejected.
#[test]
fn test_tcgen05_dealloc_with_an_mma_in_flight_is_rejected() {
    let module = tcgen05_mma_two_warp_kernel(
        "    @!%p2 bra DONE;
    tcgen05.dealloc.cta_group::1.sync.aligned.b32 %r1, 32;
DONE:",
    );
    let err = analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05AsyncHazard { prior, current, .. }) => {
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert!(current.is_write);
        }
        other => panic!("expected Tcgen05AsyncHazard, got: {}", other),
    }
}

/// The control: deallocating after waiting on `mma_bar` is accepted.
#[test]
fn test_tcgen05_dealloc_after_the_mma_completed_is_accepted() {
    let module = tcgen05_mma_two_warp_kernel(
        "    @!%p2 bra DONE;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
    tcgen05.dealloc.cta_group::1.sync.aligned.b32 %r1, 32;
DONE:",
    );
    analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

/// `.kind::f8f6f4` with e4m3 `A`, e5m2 `B`, K = 32, `SwizzleMode::None` (`LBO
/// = 128`): `D[0][0] = 136 + 2 * 136 = 408` holds only with 1-byte elements,
/// `LBO` stepping and per-operand decoders.
#[test]
fn test_tcgen05_mma_kind_f8f6f4_numeric_correctness() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .b32 %r<7>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .shared .align 1024 .b8 a_buf[4096];
    .shared .align 1024 .b8 b_buf[256];
    .shared .align 4 .b32 taddr_slot;
    .shared .align 8 .b64 mma_bar;
    .reg .pred %pw;
    .reg .b32 %rbar;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 32;
    ld.shared.u32 %r1, [%r3];

    mov.u32 %r6, %tid.x;
    setp.eq.s32 %p1, %r6, 0;

    // A row 0: e4m3 1..=16, at k = 0..15 (first core matrix) and again
    // at k = 16..31 (second core matrix, LBO = 128 bytes away).
    mov.u64 %rd1, a_buf;
    mov.u64 %rd2, b_buf;
    @%p1 st.shared.b32 [%rd1+0], 0x48444038;
    @%p1 st.shared.b32 [%rd1+4], 0x504e4c4a;
    @%p1 st.shared.b32 [%rd1+8], 0x54535251;
    @%p1 st.shared.b32 [%rd1+12], 0x58575655;
    @%p1 st.shared.b32 [%rd1+128], 0x48444038;
    @%p1 st.shared.b32 [%rd1+132], 0x504e4c4a;
    @%p1 st.shared.b32 [%rd1+136], 0x54535251;
    @%p1 st.shared.b32 [%rd1+140], 0x58575655;
    // B row 0: e5m2 1.0 (0x3c) at k = 0..15, 2.0 (0x40) at k = 16..31.
    @%p1 st.shared.b32 [%rd2+0], 0x3c3c3c3c;
    @%p1 st.shared.b32 [%rd2+4], 0x3c3c3c3c;
    @%p1 st.shared.b32 [%rd2+8], 0x3c3c3c3c;
    @%p1 st.shared.b32 [%rd2+12], 0x3c3c3c3c;
    @%p1 st.shared.b32 [%rd2+128], 0x40404040;
    @%p1 st.shared.b32 [%rd2+132], 0x40404040;
    @%p1 st.shared.b32 [%rd2+136], 0x40404040;
    @%p1 st.shared.b32 [%rd2+140], 0x40404040;

    // SwizzleMode::None, LBO = 128, SBO = 256, descriptor version 1.
    shr.u64 %rd3, %rd1, 4;
    or.b64 %rd3, %rd3, 70437464178688;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd4, %rd4, 70437464178688;
    // dense, D=f32, A=e4m3, B=e5m2, no negate/transpose, M=128, N=8.
    mov.u32 %r2, 134349840;
    mov.pred %p0, 0;
    fence.proxy.async.shared::cta;
    mov.u32 %rbar, mma_bar;
    @%p1 mbarrier.init.shared.b64 [%rbar], 1;
    bar.sync 0;
    @%p1 tcgen05.mma.cta_group::1.kind::f8f6f4 [%r1+0], %rd3, %rd4, %r2, {0,0,0,0}, %p0;
    @%p1 tcgen05.commit.cta_group::1.mbarrier::arrive::one.b64 [%rbar];
MMA_WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%rbar], 0;
    @!%pw bra MMA_WAIT;
    tcgen05.fence::after_thread_sync;

    tcgen05.ld.sync.aligned.32x32b.x1.b32 %f1, [%r1];
    ld.param.u64 %rd1, [k_param_0];
    @%p1 st.global.f32 [%rd1], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "408");
}

/// Only `.kind::f16` and `.kind::f8f6f4` are modeled; other kinds are
/// rejected at lowering naming the rejected and modeled kinds, not the
/// generic "not yet implemented".
#[test]
fn test_tcgen05_mma_rejects_unmodeled_kind() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p0;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    mov.u32 %r1, 0;
    mov.u64 %rd1, 0;
    mov.u64 %rd2, 0;
    mov.u32 %r2, 0;
    mov.pred %p0, 0;
    tcgen05.mma.cta_group::1.kind::tf32 [%r1+0], %rd1, %rd2, %r2, {0,0,0,0}, %p0;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        }) => {
            assert_eq!(instruction, "tcgen05.mma");
            let reason = reason.as_deref().unwrap_or("");
            for expected in ["kind::tf32", ".kind::f16", ".kind::f8f6f4"] {
                assert!(
                    reason.contains(expected),
                    "expected the reason to mention {expected}, got: {reason:?}"
                );
            }
        }
        other => panic!("expected UnsupportedInstruction, got: {}", other),
    }
}

/// A bf16 `idesc` operand type is rejected at eval with a message specific to
/// that gap, proving validation reports the actual problem, not the
/// descriptor-addressing error.
#[test]
fn test_tcgen05_mma_rejects_unmodeled_idesc_fields() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p0;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    mov.u32 %r1, 0;
    mov.u64 %rd1, 0;
    mov.u64 %rd2, 0;
    // dtype=F32, atype=bf16, M=128, N=256 (bit-packed by hand; see the
    // session notes for the derivation).
    mov.u32 %r2, 138412176;
    mov.pred %p0, 0;
    tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd1, %rd2, %r2, {0,0,0,0}, %p0;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(
                what.contains("bf16"),
                "expected the bf16-operand error, got: {}",
                what
            );
        }
        other => panic!("expected EvalError::Unsupported, got: {}", other),
    }
}

/// An `idesc` with the K Dimension bit (29) set is rejected rather than
/// run at the kind's base `K`: the corpus f16 descriptor (dense, D=f32,
/// A/B=f16, M=128, N=256 - otherwise fully modeled) plus `1 << 29`.
#[test]
fn test_tcgen05_mma_rejects_k_dimension_bit() {
    let idesc = 138477584u32 | (1 << 29);
    let src = wrap(&format!(
        ".visible .entry k()
{{
    .reg .pred %p0;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    mov.u32 %r1, 0;
    mov.u64 %rd1, 0;
    mov.u64 %rd2, 0;
    mov.u32 %r2, {idesc};
    mov.pred %p0, 0;
    tcgen05.mma.cta_group::1.kind::f16 [%r1+0], %rd1, %rd2, %r2, {{0,0,0,0}}, %p0;
    ret;
}}
"
    ));
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(
                what.contains("K Dimension bit (29)") && what.contains("K = 16"),
                "expected the K-dimension error, got: {}",
                what
            );
        }
        other => panic!("expected EvalError::Unsupported, got: {}", other),
    }
}

/// The corpus f16 `idesc`: dense, D=f32, A/B=f16, B transposed, M=128,
/// N=256 - fully valid and modeled.
const F16_IDESC: u32 = 138477584;
/// A well-formed `Swizzle128B` shared-memory descriptor (start 0, stride
/// 1024, the fixed `0b001` at bits 46-48) - the corpus kernel's `a-desc`.
const SWIZZLE128B_DESC: u64 = 0x4000_4040_0000_0000;

/// Replace `idesc`'s M field (bits 24-28, `M >> 4`) and N field (bits
/// 17-22, `N >> 3`).
fn with_shape(idesc: u32, m: u32, n: u32) -> u32 {
    (idesc & !(0x1F << 24) & !(0x3F << 17)) | ((m >> 4) << 24) | ((n >> 3) << 17)
}

/// Run one `tcgen05.mma{.ws}.cta_group::1.kind::{kind}` (issued by thread
/// 0, D in a fresh 512-column allocation) with the given `idesc` and
/// descriptors.
fn run_tcgen05_mma(
    kind: &str,
    ws: bool,
    idesc: u32,
    a_desc: u64,
    b_desc: u64,
) -> Result<AnalysisOutput, AnalysisError> {
    run_tcgen05_mma_at(0, kind, ws, idesc, a_desc, b_desc)
}

/// [`run_tcgen05_mma`] with `D` at `d_offset` from the allocation's base
/// address.
fn run_tcgen05_mma_at(
    d_offset: u32,
    kind: &str,
    ws: bool,
    idesc: u32,
    a_desc: u64,
    b_desc: u64,
) -> Result<AnalysisOutput, AnalysisError> {
    let mma = if ws {
        format!("tcgen05.mma.ws.cta_group::1.kind::{kind} [%r1+{d_offset}], %rd1, %rd2, %r2, %p0")
    } else {
        format!("tcgen05.mma.cta_group::1.kind::{kind} [%r1+{d_offset}], %rd1, %rd2, %r2, %p0")
    };
    let src = wrap_sm100a(&format!(
        ".visible .entry k()
{{
    .reg .pred %p<2>;
    .reg .b32 %r<5>;
    .reg .b64 %rd<3>;
    // At shared address 0, where the descriptors' operands start.
    .shared .align 1024 .b8 operands[32768];
    .shared .align 4 .b32 taddr_slot;

    mov.u32 %r3, taddr_slot;
    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [%r3], 512;
    bar.sync 0;
    ld.shared.u32 %r1, [%r3];
    mov.u32 %r4, %tid.x;
    setp.eq.u32 %p1, %r4, 0;
    mov.u64 %rd1, {a_desc};
    mov.u64 %rd2, {b_desc};
    mov.u32 %r2, {idesc};
    mov.pred %p0, 0;
    @%p1 {mma};
    ret;
}}
"
    ));
    analyze_kernel(&parse(&src), None, AnalysisConfig::new((32, 1, 1)))
}

/// Assert `result` is an `InvalidEncoding` whose message contains `needle`.
fn expect_invalid_encoding(result: Result<AnalysisOutput, AnalysisError>, needle: &str) {
    match result {
        Err(AnalysisError::Eval(EvalError::InvalidEncoding { what, .. })) => {
            assert!(what.contains(needle), "expected {needle:?} in: {what}");
        }
        Err(other) => panic!("expected InvalidEncoding ({needle}), got: {other}"),
        Ok(_) => panic!("expected InvalidEncoding ({needle}), got Ok"),
    }
}

/// Shapes outside PTX ISA Table 48's `.cta_group::1` dense set are invalid:
/// `M = 32` is `.ws`-only, N <= 256, `.ws` takes N = 64/128/256, and Table
/// 63's 8-bit transposed B needs N % 16 == 0.
#[test]
fn test_tcgen05_mma_rejects_invalid_shapes() {
    let d = SWIZZLE128B_DESC;
    for (ws, m, n) in [
        (false, 32, 64),
        (false, 128, 264),
        (true, 128, 16),
        (true, 128, 0),
    ] {
        expect_invalid_encoding(
            run_tcgen05_mma("f16", ws, with_shape(F16_IDESC, m, n), d, d),
            "is not a valid .cta_group::1 dense shape",
        );
    }
    // The same M = 32 is a valid (and modeled) `.ws` shape.
    run_tcgen05_mma("f16", true, with_shape(F16_IDESC, 32, 64), d, d)
        .expect("M = 32, N = 64 under .ws");
    // The fp8 corpus idesc (M = 128, N = 16), with B transposed and N = 8.
    let fp8_idesc = with_shape(0x0804_0010 | 1 << 16, 128, 8);
    expect_invalid_encoding(
        run_tcgen05_mma("f8f6f4", false, fp8_idesc, d, d),
        "steps of 16",
    );
}

/// Reserved/limited `idesc` fields: bits 6 and 23 must be 0, saturate (bit 3)
/// is integer-only, B-reuse shift (bits 30-31) is `.ws`-only, and D type
/// (bits 4-5) must be at most f32 = 1.
#[test]
fn test_tcgen05_mma_rejects_invalid_idesc_fields() {
    let d = SWIZZLE128B_DESC;
    for bit in [6, 23] {
        expect_invalid_encoding(
            run_tcgen05_mma("f16", false, F16_IDESC | 1 << bit, d, d),
            &format!("reserved bit {bit}"),
        );
    }
    expect_invalid_encoding(
        run_tcgen05_mma("f16", false, F16_IDESC | 1 << 3, d, d),
        "saturate",
    );
    expect_invalid_encoding(
        run_tcgen05_mma("f16", false, F16_IDESC | 1 << 30, d, d),
        "maximum shift",
    );
    // Under `.ws` the same shift is a legal (performance-only) hint.
    run_tcgen05_mma("f16", true, with_shape(F16_IDESC, 128, 64) | 1 << 30, d, d)
        .expect("max shift under .ws");
    for dtype in [2, 3] {
        expect_invalid_encoding(
            run_tcgen05_mma("f16", false, (F16_IDESC & !(0b11 << 4)) | dtype << 4, d, d),
            "D type field",
        );
    }
}

/// Malformed shared-memory descriptors (PTX ISA Table 49) are rejected: a
/// reserved bit, or the fixed `0b001` at bits 46-48 missing.
#[test]
fn test_tcgen05_mma_rejects_malformed_descriptors() {
    let d = SWIZZLE128B_DESC;
    expect_invalid_encoding(
        run_tcgen05_mma("f16", false, F16_IDESC, d | 1 << 15, d),
        "a-desc",
    );
    expect_invalid_encoding(
        run_tcgen05_mma("f16", false, F16_IDESC, d, d & !(1 << 46)),
        "fixed-constant field at bit 46",
    );
}

/// `D` must start at Tensor Memory lane 0: a `[d-tmem]` address with a
/// nonzero lane field (bits 31-16) is rejected as unmodeled, naming the
/// lane, rather than read as a column far outside the allocation.
#[test]
fn test_tcgen05_mma_rejects_a_d_address_off_lane_0() {
    let d = SWIZZLE128B_DESC;
    run_tcgen05_mma_at(8, "f16", false, F16_IDESC, d, d).expect("D at lane 0, column 8");
    for lane in [32, 128] {
        match run_tcgen05_mma_at(lane << 16, "f16", false, F16_IDESC, d, d) {
            Err(AnalysisError::Eval(EvalError::Unsupported { what, .. })) => {
                let needle = format!("[d-tmem] at lane {lane}");
                assert!(what.contains(&needle), "expected {needle:?} in: {what}");
            }
            Err(other) => panic!("lane {lane}: expected Unsupported, got: {other}"),
            Ok(_) => panic!("lane {lane}: expected Unsupported, got Ok"),
        }
    }
}

/// PTX ISA Table 65: for 8- and 16-bit operands a transposed matrix may
/// use every swizzling mode except 128B with 32B atomicity.
#[test]
fn test_tcgen05_mma_rejects_invalid_layout_combinations() {
    let d = SWIZZLE128B_DESC;
    // `F16_IDESC` transposes B; give B 128B-with-32B-atomicity (mode 1).
    let atomic32 = (d & !(0x7 << 61)) | 1 << 61;
    expect_invalid_encoding(
        run_tcgen05_mma("f16", false, F16_IDESC, d, atomic32),
        "transposed B with 128B swizzling with 32B atomicity",
    );
}

/// `membar.level` is mandatory `.cta`/`.gl`/`.sys` (PTX ISA 9.7.15.4): `.gl`
/// lowers, `.cluster`/`.gpu` or no level fail to parse; `membar.proxy` parses
/// but is unimplemented.
#[test]
fn test_membar_levels() {
    let kernel = |level: &str| {
        parse(&wrap(&format!(
            ".visible .entry k()\n{{\n    membar{level};\n    ret;\n}}\n"
        )))
    };
    let analyze = |level| analyze_kernel(&kernel(level), None, AnalysisConfig::new((1, 1, 1)));
    for level in [".cta", ".gl", ".sys"] {
        analyze(level).unwrap_or_else(|e| panic!("membar{level}: {e}"));
    }
    for level in [".cluster", ".gpu", ""] {
        match analyze(level) {
            Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
                let reason = reason.unwrap_or_default();
                assert!(reason.contains("parsing failed"), "membar{level}: {reason}");
            }
            other => panic!("membar{level}: expected a parse failure, got {other:?}"),
        }
    }
    for proxy in ["alias", "async"] {
        let src = wrap_sm90a(&format!(
            ".visible .entry k()\n{{\n    membar.proxy.{proxy};\n    ret;\n}}\n"
        ));
        match analyze_kernel(&parse(&src), None, AnalysisConfig::new((1, 1, 1))) {
            Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
                let reason = reason.unwrap_or_default();
                assert!(reason.contains("not implemented yet"), "{proxy}: {reason}");
            }
            other => panic!("membar.proxy.{proxy}: expected unsupported, got {other:?}"),
        }
    }
}

fn expect_invalid_instruction(module: &Module, needle: &str) {
    match analyze_kernel(module, None, AnalysisConfig::new((32, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::InvalidInstruction { reason, .. })) => {
            assert!(reason.contains(needle), "expected {needle:?} in: {reason}");
        }
        Err(other) => panic!("expected InvalidInstruction ({needle}), got: {other}"),
        Ok(_) => panic!("expected InvalidInstruction ({needle}), got Ok"),
    }
}

/// `mbarrier.init`/`inval`/`test_wait`/`try_wait` take only `.shared{::cta}`
/// (PTX ISA 9.7.15.16), so `.shared::cluster` is invalid; on `arrive` it is
/// valid but unmodeled.
#[test]
fn test_mbarrier_shared_cluster_validity() {
    let kernel = |body: &str| {
        parse(&wrap_sm90a(&format!(
            ".visible .entry k()
{{
    .reg .pred %p<2>;
    .reg .b32 %r<4>;
{body}
    ret;
}}
"
        )))
    };
    for body in [
        "    mbarrier.init.shared::cluster.b64 [%r1], 1;",
        "    mbarrier.inval.shared::cluster.b64 [%r1];",
        "    mbarrier.test_wait.parity.shared::cluster.b64 %p0, [%r1], %r2;",
        "    mbarrier.try_wait.parity.shared::cluster.b64 %p0, [%r1], %r2;",
    ] {
        expect_invalid_instruction(&kernel(body), "has no .shared::cluster form");
    }
    let arrive = kernel("    mbarrier.arrive.shared::cluster.b64 _, [%r1];");
    match analyze_kernel(&arrive, None, AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
            let reason = reason.unwrap_or_default();
            assert!(reason.contains("single-CTA analysis only"), "{reason}");
        }
        other => panic!("expected unsupported, got {other:?}"),
    }
}

/// `redux.sync` forms (PTX ISA 9.7.15.13): `.add/.min/.max` on `.u32/.s32`,
/// `.and/.or/.xor` on `.b32`, `.min/.max{.abs}{.NaN}` on `.f32`; others are
/// invalid, `.abs`/`.NaN` unmodeled.
#[test]
fn test_redux_sync_forms() {
    let kernel = |form: &str| {
        let r = if form.ends_with("f32") { "%f" } else { "%r" };
        parse(&format!(
            ".version 8.8\n.target sm_100a\n.address_size 64\n\n.visible .entry k()
{{
    .reg .b32 %r<4>;
    .reg .f32 %f<4>;
    redux.sync.{form} {r}1, {r}2, -1;
    ret;
}}
"
        ))
    };
    let analyze = |form| analyze_kernel(&kernel(form), None, AnalysisConfig::new((32, 1, 1)));
    for form in ["add.u32", "max.s32", "xor.b32", "min.f32", "max.f32"] {
        analyze(form).unwrap_or_else(|e| panic!("{form}: {e}"));
    }
    for form in ["add.f32", "and.u32", "min.b32", "xor.s32"] {
        expect_invalid_instruction(&kernel(form), "not a redux.sync form");
    }
    for form in ["add.NaN.u32", "or.abs.b32"] {
        expect_invalid_instruction(&kernel(form), "only apply to redux.sync.f32");
    }
    for form in ["min.abs.f32", "max.NaN.f32"] {
        match analyze(form) {
            Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { .. })) => {}
            other => panic!("{form}: expected unsupported, got {other:?}"),
        }
    }
}

/// nvcc's warp-max sign trick fuses into one `ReduxSyncBroadcastMax`, but
/// never over a `.NaN` reduction: that is invalid on `.s32`, so the normal
/// lowering must see (and reject) it.
#[test]
fn test_redux_sync_sign_trick_never_fuses_nan() {
    let kernel = |nan: &str| {
        parse(&wrap(&format!(
            ".visible .entry k()
{{
    .reg .pred %p<2>;
    .reg .b32 %r<4>;
    .reg .f16 %h<2>;
    mov.b32 %r1, {{%h1, %h1}};
    redux.sync.max{nan}.s32 %r2, %r1, -1;
    setp.lt.s32 %p1, %r2, 0;
    @%p1 redux.sync.min.s32 %r2, %r1, -1;
    ret;
}}
"
        )))
    };
    let result = analyze_kernel(&kernel(""), None, AnalysisConfig::new((32, 1, 1)));
    assert!(
        !matches!(
            result,
            Err(AnalysisError::Lower(LowerError::InvalidInstruction { .. }))
        ),
        "{:?}",
        result.err()
    );
    expect_invalid_instruction(&kernel(".NaN"), "only apply to redux.sync.f32");
}

/// An uninitialized shared read is tolerated during execution (the paper's
/// race example depends on it), but an output computed from one is an error.
#[test]
fn test_uninitialized_shared_read_flows_to_output() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;
    .shared .align 4 .b8 sdata[8];

    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, sdata;
    ld.shared.u32 %r2, [%r1];
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected undefined output, got: {}",
        err
    );
}

#[test]
fn test_out_of_bounds_shared_access() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b32 %r<3>;
    .shared .align 4 .b8 sdata[8];

    mov.u32 %r1, %tid.x;
    mov.u32 %r2, sdata;
    st.shared.u32 [%r2+64], %r1;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::OutOfBounds { .. })),
        "expected out-of-bounds, got: {}",
        err
    );
}

// =========================================================================
// Natural alignment (PTX ISA 6.4.1): misaligned accesses are UB, so rejected
// =========================================================================

/// A 4-byte load at an address 2 mod 4 is misaligned.
#[test]
fn test_misaligned_scalar_load() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.f32 %f1, [%rd1+2];
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 4)).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 4, .. })
        ),
        "expected misaligned access, got: {}",
        err
    );
}

/// A 4-byte store at an address 2 mod 4 is misaligned (write side of the
/// same chokepoint).
#[test]
fn test_misaligned_scalar_store() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b32 %r<3>;
    .shared .align 4 .b8 sdata[16];

    mov.u32 %r1, %tid.x;
    mov.u32 %r2, sdata;
    st.shared.u32 [%r2+2], %r1;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 4, .. })
        ),
        "expected misaligned access, got: {}",
        err
    );
}

/// 2-byte accesses at addresses 2 mod 4 are *naturally aligned* (natural
/// alignment is relative to the access size, not any fixed width): the
/// ordinary f16 access pattern must keep working.
#[test]
fn test_aligned_u16_access_at_2_mod_4() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u16 %rs1, [%rd1+2];
    st.global.u16 [%rd2+2], %rs1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 4,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 4,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).expect("aligned u16 access");
    assert_eq!(display_output(&output, "out", 1), "in[1]");
}

/// The access size of a vector load is the *total* bytes accessed
/// (ld.v4.f32 is one 16-byte access), so an address 4 mod 16 is misaligned
/// even though every element taken alone is 4-aligned.
#[test]
fn test_misaligned_vector_load() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.v4.f32 {%f1, %f2, %f3, %f4}, [%rd1+4];
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 8)).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 16, .. })
        ),
        "expected misaligned vector access, got: {}",
        err
    );
}

/// The same vector load at a 16-byte boundary is legal.
#[test]
fn test_aligned_vector_load() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.v4.f32 {%f1, %f2, %f3, %f4}, [%rd1];
    st.global.f32 [%rd2], %f4;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 8)).expect("aligned v4 load");
    assert_eq!(display_output(&output, "out", 0), "in[3]");
}

/// A vector store's source list may mix immediates with registers (nvcc's
/// `{%f1, 0f00000000, %f2, 0f3F800000}` init idiom), unlike a vector load's
/// destination.
#[test]
fn test_vector_store_with_immediate_source() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    st.global.v4.f32 [%rd2], {%f1, 0f00000000, %f2, 0f3F800000};
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = in_out_config(1, 8);
    config.arrays[1].len = 4; // out: exactly the 4 stored elements
    let output = analyze_kernel(&module, None, config).expect("vector store with immediate");
    assert_eq!(display_output(&output, "out", 0), "in[0]");
    assert_eq!(display_output(&output, "out", 1), "0");
    assert_eq!(display_output(&output, "out", 2), "in[1]");
    assert_eq!(display_output(&output, "out", 3), "1");
}

/// One full-warp ldmatrix.x4 body; each lane supplies the row address
/// `sdata + tid*16 + extra` (lane i*8+r owns row r of matrix i).
fn ldmatrix_body(extra: u32) -> String {
    format!(
        ".visible .entry k()
{{
    .reg .b32 %r<10>;
    .shared .align 16 .b8 sdata[1024];

    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 4;
    mov.u32 %r3, sdata;
    add.s32 %r4, %r3, %r2;
    add.s32 %r4, %r4, {};
    ldmatrix.sync.aligned.x4.m8n8.shared.b16 {{%r5, %r6, %r7, %r8}}, [%r4];
    ret;
}}
",
        extra
    )
}

/// ldmatrix row addresses are legal at 16-byte boundaries: each 8x8 b16
/// matrix row is fetched by four lanes as one 16-byte access.
#[test]
fn test_aligned_ldmatrix() {
    let module = parse(&wrap(&ldmatrix_body(0)));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("aligned ldmatrix");
}

/// A row address 8 mod 16 violates ldmatrix's 16-byte row alignment
/// (PTX ISA 9.7.14.5.15) even though each lane's own 4-byte read would be
/// 4-aligned.
#[test]
fn test_misaligned_ldmatrix_row_address() {
    let module = parse(&wrap(&ldmatrix_body(8)));
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 16, .. })
        ),
        "expected misaligned ldmatrix row, got: {}",
        err
    );
}

/// `ldmatrix.trans.x1`: lane `l` gets (row `2*(l%4)`, col `l/4`) low and (row
/// `2*(l%4)+1`, col `l/4`) high, the transpose of the plain mapping; outputs
/// are checked against `in[expected_index]`.
#[test]
fn test_ldmatrix_trans_mapping() {
    let mut init = String::new();
    for k in 0..64u32 {
        init.push_str(&format!(
            "    ld.global.u16 %rs1, [%rd1+{off}];\n    st.shared.u16 [%r1+{off}], %rs1;\n",
            off = k * 2
        ));
    }
    let src = wrap(&format!(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .pred %p<2>;
    .reg .b32 %r<10>;
    .reg .b16 %rs<5>;
    .reg .b64 %rd<5>;
    .shared .align 16 .b8 sdata[128];

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, sdata;
    mov.u32 %r2, %tid.x;
    setp.eq.u32 %p1, %r2, 0;
    @!%p1 bra $L1;
{init}
$L1:
    bar.sync 0;
    shl.b32 %r3, %r2, 4;
    add.s32 %r4, %r1, %r3;
    ldmatrix.sync.aligned.x1.trans.m8n8.shared.b16 {{%r5}}, [%r4];
    mov.b32 {{%rs2, %rs3}}, %r5;
    shl.b32 %r6, %r2, 2;
    cvt.s64.s32 %rd3, %r6;
    add.s64 %rd4, %rd2, %rd3;
    st.global.u16 [%rd4], %rs2;
    st.global.u16 [%rd4+2], %rs3;
    ret;
}}
",
        init = init
    ));

    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 64,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).expect("ldmatrix.trans mapping");

    for lane in 0u64..32 {
        let row_lo = 2 * (lane % 4);
        let row_hi = row_lo + 1;
        let col = lane / 4;
        let expect_lo = row_lo * 8 + col;
        let expect_hi = row_hi * 8 + col;
        assert_eq!(
            display_output(&output, "out", 2 * lane),
            format!("in[{}]", expect_lo),
            "lane {} low half",
            lane
        );
        assert_eq!(
            display_output(&output, "out", 2 * lane + 1),
            format!("in[{}]", expect_hi),
            "lane {} high half",
            lane
        );
    }
}

/// `mma.sync`'s accumulator may be an immediate (nvcc's `{0f00000000, ...}`
/// first-tile idiom): with all-zero packed A/B, `D = C`, so thread 0's
/// registers get the literal `{1.0, 0, 0, 0}`.
#[test]
fn test_mma_with_immediate_accumulator() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b16 %rs<3>;
    .reg .b32 %r<9>;
    .reg .f32 %f<5>;
    .reg .b64 %rd<4>;

    mov.u16 %rs1, 0;
    mov.u16 %rs2, 0;
    mov.b32 %r1, {%rs1, %rs2};
    mov.b32 %r2, {%rs1, %rs2};
    mov.b32 %r3, {%rs1, %rs2};
    mov.b32 %r4, {%rs1, %rs2};
    mov.b32 %r5, {%rs1, %rs2};
    mov.b32 %r6, {%rs1, %rs2};

    mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32 \
        {%f1, %f2, %f3, %f4}, {%r1, %r2, %r3, %r4}, {%r5, %r6}, \
        {0f3F800000, 0f00000000, 0f00000000, 0f00000000};

    ld.param.u64 %rd1, [k_param_0];
    mov.u32 %r7, %tid.x;
    mul.lo.u32 %r8, %r7, 16;
    cvt.u64.u32 %rd2, %r8;
    add.s64 %rd3, %rd1, %rd2;
    st.global.v4.f32 [%rd3], {%f1, %f2, %f3, %f4};
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 128,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).expect("mma with immediate accumulator");
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "0");
    assert_eq!(display_output(&output, "out", 2), "0");
    assert_eq!(display_output(&output, "out", 3), "0");
}

/// An `mma.sync` f32 accumulator holding a raw bit pattern (`mov.b32`) is
/// decoded as f32 bits: thread 0's `D[0][0]` is 1.0, not 1065353216.
#[test]
fn test_mma_accumulator_register_decodes_raw_bits() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b16 %rs<3>;
    .reg .b32 %r<11>;
    .reg .f32 %f<5>;
    .reg .b64 %rd<4>;

    mov.u16 %rs1, 0;
    mov.u16 %rs2, 0;
    mov.b32 %r1, {%rs1, %rs2};
    mov.b32 %r2, {%rs1, %rs2};
    mov.b32 %r3, {%rs1, %rs2};
    mov.b32 %r4, {%rs1, %rs2};
    mov.b32 %r5, {%rs1, %rs2};
    mov.b32 %r6, {%rs1, %rs2};
    mov.b32 %r9, 0x3F800000;
    mov.b32 %r10, 0;

    mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32 \
        {%f1, %f2, %f3, %f4}, {%r1, %r2, %r3, %r4}, {%r5, %r6}, \
        {%r9, %r10, %r10, %r10};

    ld.param.u64 %rd1, [k_param_0];
    mov.u32 %r7, %tid.x;
    mul.lo.u32 %r8, %r7, 16;
    cvt.u64.u32 %rd2, %r8;
    add.s64 %rd3, %rd1, %rd2;
    st.global.v4.f32 [%rd3], {%f1, %f2, %f3, %f4};
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 128,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).expect("mma with bit-pattern accumulator");
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "0");
}

/// One full-warp wmma.load.a body with base `sdata + extra` and the given
/// stride (in f16 elements).
fn wmma_load_body(extra: u32, stride: u32) -> String {
    format!(
        ".visible .entry k()
{{
    .reg .b32 %r<12>;
    .shared .align 32 .b8 sdata[2048];

    mov.u32 %r1, sdata;
    add.s32 %r1, %r1, {};
    mov.u32 %r2, {};
    wmma.load.a.sync.aligned.row.m16n16k16.shared.f16 \
         {{%r3, %r4, %r5, %r6, %r7, %r8, %r9, %r10}}, [%r1], %r2;
    ret;
}}
",
        extra, stride
    )
}

/// One full-warp wmma.store.d body with base `sdata + extra` and the given
/// stride (in f32 elements).
fn wmma_store_body(extra: u32, stride: u32) -> String {
    format!(
        ".visible .entry k()
{{
    .reg .b32 %r<3>;
    .reg .f32 %f<9>;
    .shared .align 32 .b8 sdata[4096];

    mov.f32 %f1, 0f3F800000;
    mov.f32 %f2, 0f3F800000;
    mov.f32 %f3, 0f3F800000;
    mov.f32 %f4, 0f3F800000;
    mov.f32 %f5, 0f3F800000;
    mov.f32 %f6, 0f3F800000;
    mov.f32 %f7, 0f3F800000;
    mov.f32 %f8, 0f3F800000;
    mov.u32 %r1, sdata;
    add.s32 %r1, %r1, {};
    mov.u32 %r2, {};
    wmma.store.d.sync.aligned.row.m16n16k16.shared.f32 \
         [%r1], {{%f1, %f2, %f3, %f4, %f5, %f6, %f7, %f8}}, %r2;
    ret;
}}
",
        extra, stride
    )
}

/// wmma with a 32-byte-aligned base and the default stride (16 elements)
/// is legal, for both the f16 a-fragment load and the f32 d-fragment store.
#[test]
fn test_aligned_wmma_load_and_store() {
    let module = parse(&wrap(&wmma_load_body(0, 16)));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("aligned wmma.load");

    let module = parse(&wrap(&wmma_store_body(0, 16)));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("aligned wmma.store");
}

/// A stride *larger* than the default is explicitly allowed (a submatrix
/// of a larger matrix) as long as it keeps rows aligned.
#[test]
fn test_wmma_stride_above_default_is_legal() {
    let module = parse(&wrap(&wmma_load_body(0, 32)));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("stride-32 wmma.load");
}

/// nvcc's bank-conflict skew (`half tile[..][16 + 8]`, Conv2D-opt) gives a
/// 48-byte stride: not a multiple of the 32-byte fragment but 16-byte
/// aligned, which must stay legal.
#[test]
fn test_wmma_skewed_stride_is_legal() {
    let module = parse(&wrap(&wmma_load_body(0, 24)));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("stride-24 wmma.load");
}

/// A wmma base address 8 mod 32 violates the 32-byte fragment alignment
/// (PTX ISA 9.7.14.4.2) even though each f16 element read is 2-aligned.
#[test]
fn test_wmma_load_base_misaligned() {
    let module = parse(&wrap(&wmma_load_body(8, 16)));
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 32, .. })
        ),
        "expected misaligned wmma base, got: {}",
        err
    );
}

/// The store side enforces the same base alignment.
#[test]
fn test_wmma_store_base_misaligned() {
    let module = parse(&wrap(&wmma_store_body(8, 16)));
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 32, .. })
        ),
        "expected misaligned wmma store base, got: {}",
        err
    );
}

/// A stride below the leading dimension (16 elements for m16n16k16) is
/// undefined behavior by itself (PTX ISA 9.7.14.4.3).
#[test]
fn test_wmma_stride_below_default() {
    let module = parse(&wrap(&wmma_load_body(0, 8)));
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WmmaStrideTooSmall {
                stride: 8,
                minimum: 16,
                ..
            })
        ),
        "expected wmma stride below default, got: {}",
        err
    );
}

/// A stride that is legal in *size* but whose byte pitch breaks the
/// 16-byte stride granularity leaves rows past the first misaligned:
/// 20 f16 elements = 40 bytes.
#[test]
fn test_wmma_stride_misaligned() {
    let module = parse(&wrap(&wmma_load_body(0, 20)));
    let err = analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 16, .. })
        ),
        "expected misaligned wmma stride, got: {}",
        err
    );
}

/// An array base that is not a multiple of the element width is rejected
/// when the analysis is configured, not per access.
#[test]
fn test_config_rejects_misaligned_array_base() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "in".to_string(),
        base: 2,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    }];
    config.params = vec![ParamValue::ArrayPtr("in".to_string())];
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::Config { .. })),
        "expected config error, got: {}",
        err
    );
}

/// nvcc's u16 magic-number division (Conv2D-opt): the immediate -17873 is u16
/// 47663 = ceil(2^19/11), so `mul.wide.u16` operands are reinterpreted as
/// unsigned.
#[test]
fn test_mul_wide_u16_magic_division() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<5>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_1];
    mov.u16 %rs1, 14;
    mul.wide.u16 %r1, %rs1, -17873;
    shr.u32 %r2, %r1, 19;
    cvt.u16.u32 %rs2, %r2;
    mul.lo.s16 %rs3, %rs2, 11;
    sub.s16 %rs4, %rs1, %rs3;
    cvt.u32.u16 %r3, %rs4;
    st.global.u32 [%rd1], %r2;
    st.global.u32 [%rd1+4], %r3;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 2)).expect("analysis");
    // 14 / 11 = 1, 14 % 11 = 3.
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "3");
}

/// `mul.hi.u32` must zero-extend a canonically-signed operand: the high
/// half of 0xFFFFFFFF * 2 is 1, not -1's sign fill.
#[test]
fn test_mul_hi_u32_negative_operand() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, -1;
    mul.hi.u32 %r2, %r1, 2;
    st.global.u32 [%rd1], %r2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `shf`'s shift amount is `.u32`: `-1` is 0xFFFFFFFF, which `.clamp`
/// saturates to 32 (left gives `lo`, right `hi`) - not 0; `.wrap` takes the
/// low 5 bits, i.e. 31.
#[test]
fn test_shf_clamp_negative_shift_amount_saturates() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<8>;
    .reg .s32 %s<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, 0x11111111;
    mov.u32 %r2, 0x22222222;
    mov.s32 %s1, -1;
    shf.l.clamp.b32 %r3, %r1, %r2, %s1;
    shf.r.clamp.b32 %r4, %r1, %r2, %s1;
    shf.l.wrap.b32 %r5, %r1, %r2, %s1;
    shf.r.wrap.b32 %r6, %r1, %r2, %s1;
    st.global.u32 [%rd1], %r3;
    st.global.u32 [%rd1+4], %r4;
    st.global.u32 [%rd1+8], %r5;
    st.global.u32 [%rd1+12], %r6;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 4)).expect("analysis");
    // shf.l.clamp, n = min(0xFFFFFFFF, 32) = 32: the whole of hi is shifted
    // out and lo fills the result, so d = lo = 0x11111111.
    assert_eq!(
        display_output(&output, "out", 0),
        0x1111_1111u32.to_string()
    );
    // shf.r.clamp, n = 32: the whole of lo is shifted out and hi fills the
    // result, so d = hi = 0x22222222.
    assert_eq!(
        display_output(&output, "out", 1),
        0x2222_2222u32.to_string()
    );
    // shf.l.wrap, n = 0xFFFFFFFF & 0x1f = 31:
    // d = (hi << 31) | (lo >> 1) = 0 | 0x08888888.
    assert_eq!(
        display_output(&output, "out", 2),
        0x0888_8888u32.to_string()
    );
    // shf.r.wrap, n = 31: d = (hi << 1) | (lo >> 31) = 0x44444444 | 0.
    assert_eq!(
        display_output(&output, "out", 3),
        0x4444_4444u32.to_string()
    );
}

/// A shift's amount is `.u32` for every operand type, so a `.b16` shift
/// by 0x10000 is over-wide (>= 16), not a shift by 0x10000 & 0xFFFF = 0.
#[test]
fn test_b16_shift_amount_is_read_as_u32() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<5>;
    .reg .b32 %r<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, 0x10000;
    mov.b16 %h1, 1;
    mov.b16 %h2, 0x8000;
    shl.b16 %h3, %h1, %r1;
    shr.u16 %h4, %h2, %r1;
    cvt.u32.u16 %r2, %h3;
    cvt.u32.u16 %r3, %h4;
    shr.s16 %h4, %h2, %r1;
    cvt.u32.u16 %r4, %h4;
    st.global.u32 [%rd1], %r2;
    st.global.u32 [%rd1+4], %r3;
    st.global.u32 [%rd1+8], %r4;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 3)).expect("analysis");
    // shl.b16 1 by >= 16: every bit is shifted out, so d = 0 (not 1).
    assert_eq!(display_output(&output, "out", 0), "0");
    // shr.u16 0x8000 by >= 16: logical shift, so d = 0 (not 0x8000).
    assert_eq!(display_output(&output, "out", 1), "0");
    // shr.s16 0x8000 by >= 16: arithmetic shift fills with the sign bit,
    // so d = 0xFFFF (not 0x8000).
    assert_eq!(display_output(&output, "out", 2), 0xFFFFu32.to_string());
}

/// Integer `abs` re-reads a concrete operand at its signed width: 0xFFFFFFFB
/// is -5 to `abs.s32`, and the result wraps (`abs.s32` of i32::MIN is
/// i32::MIN).
#[test]
fn test_int_abs_read_at_signed_width() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<8>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, 0xFFFFFFFB;
    abs.s32 %r2, %r1;
    mov.u32 %r4, 0x80000000;
    abs.s32 %r5, %r4;
    st.global.u32 [%rd1], %r2;
    st.global.u32 [%rd1+4], %r5;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 2)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "5");
    assert_eq!(
        display_output(&output, "out", 1),
        0x8000_0000u32.to_string()
    );
}

/// `abs.f32` decodes a raw bit pattern first: 0xC0A00000 (-5.0) gives 5.0 and
/// 0xFF800000 (-inf) gives inf. A symbolic operand stays an `abs` node.
#[test]
fn test_float_abs_decodes_raw_bits() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<7>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.b32 %f1, 0xC0A00000;
    abs.f32 %f2, %f1;
    mov.b32 %f3, 0xFF800000;
    abs.f32 %f4, %f3;
    ld.global.f32 %f5, [%rd1];
    abs.f32 %f6, %f5;
    st.global.f32 [%rd2], %f2;
    st.global.f32 [%rd2+4], %f4;
    st.global.f32 [%rd2+8], %f6;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 3)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "5");
    assert_eq!(display_output(&output, "out", 1), "inf");
    assert_eq!(display_output(&output, "out", 2), "abs(in[0])");
}

/// Every float consumer decodes a raw `mov.b32`/`mov.b16` bit pattern
/// (0x3F800000 is 1.0): `fma`, `rcp`/`sqrt`, both `copysign` operands, and
/// float-to-float `cvt` (f16 0x3C00).
#[test]
fn test_float_ops_decode_raw_bit_patterns() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<2>;
    .reg .f32 %f<12>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.b32 %f1, 0x3F800000;
    fma.rn.f32 %f2, %f1, %f1, %f1;
    mov.b32 %f3, 0x40800000;
    rcp.rn.f32 %f4, %f3;
    sqrt.rn.f32 %f5, %f3;
    mov.b16 %h1, 0x3C00;
    cvt.f32.f16 %f6, %h1;
    mov.b32 %f7, 0xBF800000;
    copysign.f32 %f8, %f7, %f3;
    ld.global.f32 %f9, [%rd1];
    copysign.f32 %f10, %f7, %f9;
    st.global.f32 [%rd2], %f2;
    st.global.f32 [%rd2+4], %f4;
    st.global.f32 [%rd2+8], %f5;
    st.global.f32 [%rd2+12], %f6;
    st.global.f32 [%rd2+16], %f8;
    st.global.f32 [%rd2+20], %f10;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 6)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "2");
    assert_eq!(display_output(&output, "out", 1), "0.25");
    assert_eq!(display_output(&output, "out", 2), "sqrt(4)");
    assert_eq!(display_output(&output, "out", 3), "1");
    assert_eq!(display_output(&output, "out", 4), "-4");
    assert_eq!(display_output(&output, "out", 5), "(-abs(in[0]))");
}

/// Mixed precision `fma.rn.f32.f16` decodes its multiplicands as f16 bits
/// and only its accumulator as f32 bits: `0x3C00 * 0x4000 + 0x3F800000`
/// is `1 * 2 + 1 = 3`.
#[test]
fn test_mixed_precision_fma_decodes_multiplicands_at_their_own_type() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<3>;
    .reg .f32 %f<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd2, [k_param_1];
    mov.b16 %h1, 0x3C00;
    mov.b16 %h2, 0x4000;
    mov.b32 %f1, 0x3F800000;
    fma.rn.f32.f16 %f2, %h1, %h2, %f1;
    st.global.f32 [%rd2], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "3");
}

/// A raw bit pattern that decodes to NaN is rejected loudly rather than
/// left in place as an integer: Volta's real-valued model has no NaN.
#[test]
fn test_float_op_rejects_nan_bit_pattern() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd2, [k_param_1];
    mov.b32 %f1, 0x7FC00000;
    add.f32 %f2, %f1, %f1;
    st.global.f32 [%rd2], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(what.contains("NaN"), "{what}");
        }
        other => panic!("expected Unsupported NaN, got: {}", other),
    }
}

/// `neg` re-reads a concrete operand as its type: 0xFFFFFFFB is -5 to
/// `neg.s32` (i32::MIN wraps to itself); `neg.f32` decodes raw bits
/// (0xC0A00000 is -5.0). Symbolic stays a `neg` node.
#[test]
fn test_neg_reads_operand_as_instruction_type() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<5>;
    .reg .f32 %f<7>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, 0xFFFFFFFB;
    neg.s32 %r2, %r1;
    mov.u32 %r3, 0x80000000;
    neg.s32 %r4, %r3;
    mov.b32 %f1, 0xC0A00000;
    neg.f32 %f2, %f1;
    mov.b32 %f3, 0xFF800000;
    neg.f32 %f4, %f3;
    ld.global.f32 %f5, [%rd1];
    neg.f32 %f6, %f5;
    st.global.u32 [%rd2], %r2;
    st.global.u32 [%rd2+4], %r4;
    st.global.f32 [%rd2+8], %f2;
    st.global.f32 [%rd2+12], %f4;
    st.global.f32 [%rd2+16], %f6;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 5)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "5");
    assert_eq!(
        display_output(&output, "out", 1),
        0x8000_0000u32.to_string()
    );
    assert_eq!(display_output(&output, "out", 2), "5");
    assert_eq!(display_output(&output, "out", 3), "inf");
    assert_eq!(display_output(&output, "out", 4), "(-in[0])");
}

/// Symbolic integer division is rejected rather than modeled as exact
/// rational division, which would prove `(x / 2) * 2` equal to `x`.
/// Concrete integer division (index math) still evaluates exactly.
#[test]
fn test_symbolic_integer_div_is_unsupported() {
    let kernel = |divide: &str| {
        wrap(&format!(
            ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .b32 %r<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u32 %r1, [%rd1];
    {divide};
    st.global.u32 [%rd2], %r2;
    ret;
}}
"
        ))
    };

    let module = parse(&kernel("div.u32 %r2, %r1, 2"));
    let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(
                what.contains("div.u32"),
                "expected the integer-division error, got: {}",
                what
            );
        }
        other => panic!("expected EvalError::Unsupported, got: {}", other),
    }

    let module = parse(&kernel("mov.u32 %r3, 7;\n    div.u32 %r2, %r3, 2"));
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "3");
}

/// `shl.b64`/`shr.b64` take their shift amount in a `.u32` register, as
/// the ISA types it - not rejected as a width mismatch against `.b64`.
#[test]
fn test_b64_shift_by_u32_register() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<3>;
    .reg .b64 %rd<6>;

    ld.param.u64 %rd2, [k_param_1];
    mov.u64 %rd3, 3;
    mov.u32 %r2, 40;
    shl.b64 %rd4, %rd3, %r2;
    shr.u64 %rd5, %rd4, %r2;
    st.global.u64 [%rd2], %rd4;
    st.global.u64 [%rd2+8], %rd5;
    ret;
}
",
    );
    let mut config = in_out_config(1, 2);
    for array in &mut config.arrays {
        array.elem_width = 8;
    }
    let output = analyze_kernel(&parse(&src), None, config).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), (3u64 << 40).to_string());
    assert_eq!(display_output(&output, "out", 1), "3");
}

/// A constant operand of add/sub/mul only matters mod 2^N, so the
/// instruction's signedness must not change it: `add.s32 x, -1` and
/// `add.u32 x, -1` are the same op, and `-1` stays `-1` under `.u32`.
#[test]
fn test_ring_op_constant_signedness_is_irrelevant() {
    let kernel = |op: &str| {
        let module = parse(&wrap(&format!(
            ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u32 %r1, [%rd1];
    {op};
    st.global.u32 [%rd2], %r2;
    ret;
}}
"
        )));
        analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis")
    };
    for (signed, unsigned) in [
        ("add.s32 %r2, %r1, -1", "add.u32 %r2, %r1, -1"),
        ("sub.s32 %r2, %r1, -7", "sub.u32 %r2, %r1, -7"),
        ("mul.lo.s32 %r2, %r1, -3", "mul.lo.u32 %r2, %r1, -3"),
    ] {
        assert!(
            matches!(
                check_equiv(&kernel(signed), &kernel(unsigned)),
                EquivOutcome::Equivalent
            ),
            "`{signed}` not proved equal to `{unsigned}`"
        );
    }

    // A negative constant reads as a subtraction, whatever the signedness.
    for op in [
        "add.u32 %r2, %r1, -1",
        "add.s32 %r2, %r1, -1",
        "sub.u32 %r2, %r1, 1",
    ] {
        let rendered = display_output(&kernel(op), "out", 0);
        assert!(
            rendered.contains("- 1") && !rendered.contains("4294967295"),
            "`{op}` rendered as {rendered}"
        );
    }
}

#[test]
fn test_bfe_extract_and_sign_fill() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<10>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];

    // 0b1010 = 10; bits [0:4) unsigned = 0b1010 = 10 (no sign bit).
    mov.u32 %r1, 10;
    bfe.u32 %r2, %r1, 0, 4;
    st.global.u32 [%rd1], %r2;

    // Signed: the field's top bit (bit 3 of 0b1010) is 1, so it sign-fills to
    // 0xFFFFFFFA (-6 in 4-bit two's complement).
    mov.u32 %r3, 10;
    bfe.s32 %r4, %r3, 0, 4;
    st.global.u32 [%rd1+4], %r4;

    // start=40 is beyond the s32 msb (31): the whole result is filled with
    // a's own sign bit (bit 31 of -1 is 1) - not 0, which a plain
    // `(a >> 40) & mask` would wrongly produce for any width > 0.
    mov.u32 %r5, -1;
    bfe.s32 %r6, %r5, 40, 4;
    st.global.u32 [%rd1+8], %r6;

    // len == 0: the result is always 0, regardless of a's sign.
    mov.u32 %r7, -1;
    bfe.u32 %r8, %r7, 4, 0;
    st.global.u32 [%rd1+12], %r8;

    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, out_only_config(4, 4)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "10");
    assert_eq!(display_output(&output, "out", 1), "4294967290");
    assert_eq!(display_output(&output, "out", 2), "4294967295");
    assert_eq!(display_output(&output, "out", 3), "0");
}

#[test]
fn test_bfi_clips_field_to_register_width() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<6>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];

    // Plain insert: a=0b11 into bits [4:6) of b=0 gives 0b110000 = 48.
    bfi.b32 %r1, 3, 0, 4, 2;
    st.global.u32 [%rd1], %r1;

    // len=64 overruns the b32 msb: only bits [4:32) are replaced, so b's
    // low nibble (5) survives - not 0, which a full-width mask produces.
    bfi.b32 %r2, 0, 5, 4, 64;
    st.global.u32 [%rd1+4], %r2;

    // start=64 is beyond the msb: nothing is inserted, the result is b.
    bfi.b32 %r3, -1, 5, 64, 4;
    st.global.u32 [%rd1+8], %r3;

    // start=40 (also beyond the b32 msb) with len=0: again b.
    bfi.b32 %r4, -1, 7, 40, 0;
    st.global.u32 [%rd1+12], %r4;

    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, out_only_config(4, 4)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "48");
    assert_eq!(display_output(&output, "out", 1), "5");
    assert_eq!(display_output(&output, "out", 2), "5");
    assert_eq!(display_output(&output, "out", 3), "7");
}

#[test]
fn test_mov_vector_destination_unpack_values() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b16 %rs<4>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];

    // 0x1234ABCD: lo 16 bits = 0xABCD = 43981, hi 16 bits = 0x1234 = 4660.
    mov.u32 %r1, 0x1234ABCD;
    mov.b32 {%rs1, %rs2}, %r1;
    st.global.u16 [%rd1], %rs1;
    st.global.u16 [%rd1+2], %rs2;

    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, out_only_config(2, 2)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "43981");
    assert_eq!(display_output(&output, "out", 1), "4660");
}

#[test]
fn test_cvt_pack_halves_values() {
    // cvt.rn.f16x2.f32 d, a, b: `a` goes to the *high* half and `b` to the
    // *low* (opposite mov.b32's brace order); also exercises storing a Pair and
    // reading its 2-byte granules back.
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];

    mov.f32 %f1, 0f3FC00000; // 1.5
    mov.f32 %f2, 0f40200000; // 2.5
    cvt.rn.f16x2.f32 %r1, %f1, %f2;
    st.global.b32 [%rd1], %r1;

    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, out_only_config(2, 2)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "2.5"); // low half: b
    assert_eq!(display_output(&output, "out", 1), "1.5"); // high half: a
}

#[test]
fn test_mov_unpack_native_pair_source() {
    // `ld.global.b32` over a 2-byte array yields a `Value::Pair`; `mov.b32
    // {lo,hi}` must split its real halves directly, not bit-mask an opaque
    // integer (nvcc/Triton's f16 idiom).
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.b32 %r1, [%rd1];
    mov.b32 {%rs1, %rs2}, %r1;
    st.global.u16 [%rd2], %rs1;
    st.global.u16 [%rd2+2], %rs2;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).expect("pair unpack analysis");
    assert_eq!(display_output(&output, "out", 0), "in[0]");
    assert_eq!(display_output(&output, "out", 1), "in[1]");
}

#[test]
fn test_mov_pack_b32_always_builds_pair() {
    // The mirror image: `mov.b32 dst, {lo, hi}` always writes `Value::Pair(lo,
    // hi)`, not bit-packing, so packed f16 or integer halves round-trip exactly
    // through memory.
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u16 %rs1, [%rd1];
    ld.global.u16 %rs2, [%rd1+2];
    mov.b32 %r1, {%rs1, %rs2};
    st.global.b32 [%rd2], %r1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).expect("pair pack analysis");
    assert_eq!(display_output(&output, "out", 0), "in[0]");
    assert_eq!(display_output(&output, "out", 1), "in[1]");
}

/// `mov.b64 dst, {lo, hi}` with concrete 32-bit integer halves yields the
/// exact 64-bit integer: the `Value::Pair` is recombined when consumed as a
/// scalar (here, the u64 output).
#[test]
fn test_mov_pack_b64_integer_halves_recombine() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    mov.u32 %r1, 5;
    mov.u32 %r2, 3;
    mov.b64 %rd2, {%r1, %r2};
    st.global.u64 [%rd1], %rd2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, out_only_config(8, 1)).expect("b64 pack analysis");
    // 5 | (3 << 32) = 12884901893
    assert_eq!(display_output(&output, "out", 0), "12884901893");
}

/// Output-only config: one `out` array of `len` `elem_width`-byte
/// elements, passed as the kernel's single parameter.
fn out_only_config(elem_width: u64, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width,
        len,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// A byte-element global scratch array (kind Input, so it is never
/// compared as an output) plus a u32 `out` array.
fn u8_scratch_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "scratch".to_string(),
            base: 0x30000,
            elem_width: 1,
            len: 8,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("scratch".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// Value-boundary canonicalization: `mov.u32 %r, -1` and `not.b32 %r, 0` hold
/// the same hardware value, so both kernels must export the same canonical
/// constant.
#[test]
fn test_mov_neg1_equivalent_to_not_zero() {
    let mov_kernel = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    mov.u32 %r1, -1;
    st.global.u32 [%rd1], %r1;
    ret;
}
",
    );
    let not_kernel = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    not.b32 %r1, 0;
    st.global.u32 [%rd1], %r1;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&mov_kernel), None, out_only_config(4, 1)).unwrap();
    let b = analyze_kernel(&parse(&not_kernel), None, out_only_config(4, 1)).unwrap();
    assert_eq!(display_output(&a, "out", 0), "4294967295");
    assert_eq!(display_output(&b, "out", 0), "4294967295");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// Value-boundary canonicalization at setp/selp: `-1` and a computed
/// 4294967295 are reinterpreted at the instruction type, so both build
/// identical comparison and select nodes.
#[test]
fn test_setp_selp_canonicalize_operands() {
    let literal = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u32 %r1, [%rd1];
    setp.eq.s32 %p1, %r1, -1;
    selp.b32 %r2, -1, 0, %p1;
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let computed = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u32 %r1, [%rd1];
    not.b32 %r3, 0;
    setp.eq.s32 %p1, %r1, %r3;
    selp.b32 %r2, %r3, 0, %p1;
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&literal), None, in_out_config(1, 1)).unwrap();
    let b = analyze_kernel(&parse(&computed), None, in_out_config(1, 1)).unwrap();
    let da = display_output(&a, "out", 0);
    let db = display_output(&b, "out", 0);
    assert_eq!(da, db);
    assert!(da.contains("== -1"), "compare canonicalized at s32: {}", da);
    assert!(
        da.contains("? 4294967295"),
        "select arm canonicalized at b32: {}",
        da
    );
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// `st.u8` keeps only the low byte of the stored value (hardware chops
/// 300 to 44); `ld.u8` zero-extends it back.
#[test]
fn test_store_u8_truncates_to_low_bits() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, 44;
    add.s32 %r2, %r1, 256;
    st.global.u8 [%rd1], %r2;
    ld.global.u8 %r3, [%rd1];
    st.global.u32 [%rd2], %r3;
    ret;
}
",
    );
    let output = analyze_kernel(&parse(&src), None, u8_scratch_config()).unwrap();
    assert_eq!(display_output(&output, "out", 0), "44");
}

/// `ld.s8` sign-extends: byte 0xFF reads as -1, and storing it at 32 bits
/// exports the canonical 4294967295, the same constant as storing -1
/// directly.
#[test]
fn test_load_s8_sign_extends() {
    let via_byte = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, 255;
    st.global.u8 [%rd1], %r1;
    ld.global.s8 %r2, [%rd1];
    st.global.s32 [%rd2], %r2;
    ret;
}
",
    );
    let direct = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, -1;
    st.global.u32 [%rd2], %r1;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&via_byte), None, u8_scratch_config()).unwrap();
    let b = analyze_kernel(&parse(&direct), None, u8_scratch_config()).unwrap();
    assert_eq!(display_output(&a, "out", 0), "4294967295");
    assert_eq!(display_output(&b, "out", 0), "4294967295");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// cvt reads its source at the *source* format (ISA Table 15): `cvt.s64.s32`
/// of an `and.b32` result 4294967288 widens -8, and `cvt.u64.u32` of
/// `sub.s32`'s -8 widens 4294967288.
#[test]
fn test_cvt_reinterprets_at_source_format() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<5>;
    .reg .b64 %rd<4>;

    ld.param.u64 %rd1, [k_param_0];
    mov.u32 %r1, -5;
    and.b32 %r2, %r1, -4;
    cvt.s64.s32 %rd2, %r2;
    st.global.s64 [%rd1], %rd2;
    mov.u32 %r3, 3;
    sub.s32 %r4, %r3, 11;
    cvt.u64.u32 %rd3, %r4;
    st.global.u64 [%rd1+8], %rd3;
    ret;
}
",
    );
    let output = analyze_kernel(&parse(&src), None, out_only_config(8, 2)).unwrap();
    // (-5 & -4) at 32 bits is 0xFFFFFFF8; sign-extended through s32: -8.
    assert_eq!(display_output(&output, "out", 0), "-8");
    // 3 - 11 = -8; zero-extended through u32: 4294967288.
    assert_eq!(display_output(&output, "out", 1), "4294967288");
}

/// A symbolic value stored below its source register's width would need
/// a truncation node we do not model: loud error, not silent nonsense.
#[test]
fn test_symbolic_sub_register_store_rejected() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.u32 %r1, [%rd1];
    st.global.u8 [%rd2], %r1;
    ret;
}
",
    );
    let err = analyze_kernel(&parse(&src), None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Unsupported { what, .. })
                if what.contains("symbolic value stored")
        ),
        "expected symbolic sub-register store rejection, got: {}",
        err
    );
}

/// A symbolic scalar loaded at a type narrower than the destination
/// register would need an extension node we do not model: loud error.
#[test]
fn test_symbolic_sub_register_load_rejected() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.s8 %r1, [%rd1];
    st.global.u32 [%rd2], %r1;
    ret;
}
",
    );
    // The byte array serves as the kernel's input here: loading one of
    // its symbolic elements at s8 into a 32-bit register would need an
    // extension.
    let err = analyze_kernel(&parse(&src), None, u8_scratch_config()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Unsupported { what, .. })
                if what.contains("symbolic value loaded")
        ),
        "expected symbolic sub-register load rejection, got: {}",
        err
    );
}

/// A bits-type or unsigned sub-register symbolic load needs no extension
/// node: zero-extension is the identity on the number (PTX's rule for
/// `.b8`/`.u8` loads too).
#[test]
fn test_unsigned_sub_register_load_passes_through() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.b8 %r1, [%rd1];
    st.global.u32 [%rd2], %r1;
    ret;
}
",
    );
    let output = analyze_kernel(&parse(&src), None, u8_scratch_config()).unwrap();
    assert_eq!(display_output(&output, "out", 0), "scratch[0]");
}

/// LLVM's NVPTX fp8 idiom (`RoPEFloat8Kernel`): a byte loaded into a 16-bit
/// register feeds `cvt.rn.f16x2.e4m3x2`; the low lane is the element's real
/// value and the discarded high lane stays `Undefined`.
#[test]
fn test_e4m3x2_scalar_source_from_a_zero_extended_byte_load() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<2>;
    .reg .b32 %r<2>;
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    ld.param.u64 %rd1, [k_param_1];

    mov.u16 %h0, 0;
    ld.global.b8 %h0, [%rd0];
    cvt.rn.f16x2.e4m3x2 %r0, %h0;
    mov.b32 {%h1, _}, %r0;
    cvt.f32.f16 %f0, %h1;
    st.global.f32 [%rd1], %f0;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 1,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 1,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
}

/// The flip side: a kernel that *keeps* that high lane (from the load's
/// `Undefined` upper byte) must get a loud `UndefinedOutput`, not a
/// fabricated `0.0`.
#[test]
fn test_e4m3x2_scalar_source_high_lane_is_undefined_not_fabricated() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<2>;
    .reg .b32 %r<2>;
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    ld.param.u64 %rd1, [k_param_1];

    mov.u16 %h0, 0;
    ld.global.b8 %h0, [%rd0];
    cvt.rn.f16x2.e4m3x2 %r0, %h0;
    mov.b32 {_, %h1}, %r0;
    cvt.f32.f16 %f0, %h1;
    st.global.f32 [%rd1], %f0;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 1,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 1,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(&err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected UndefinedOutput for the discarded/kept high lane, got: {}",
        err
    );
}

/// Storing a packed f16x2 pair (a 32-bit value) at a sub-4-byte width would
/// stuff both halves into one 2-byte granule: a loud error, not silent
/// nonsense.
#[test]
fn test_pair_sub_width_store_rejected() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    mov.u16 %rs1, 1;
    mov.u16 %rs2, 2;
    st.global.u16 [%rd1], %rs1;
    st.global.u16 [%rd1+2], %rs2;
    ld.global.u32 %r1, [%rd1];
    st.global.u16 [%rd1+4], %r1;
    ret;
}
",
    );
    let err = analyze_kernel(&parse(&src), None, u8_scratch_config()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Unsupported { what, .. })
                if what.contains("pair stored")
        ),
        "expected pair sub-width store rejection, got: {}",
        err
    );
}

/// Branching on input data violates structured-CTA.
#[test]
fn test_symbolic_branch_rejected() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.global.f32 %f1, [%rd1];
    setp.gt.f32 %p1, %f1, 0f00000000;
    @%p1 bra $L1;
$L1:
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::NotConcrete { .. })),
        "expected structured-CTA violation, got: {}",
        err
    );
}

/// The `__symexpf` callseq idiom becomes symbolic exp.
#[test]
fn test_symexpf_callseq() {
    let src = wrap(
        ".extern .func  (.param .b32 func_retval0) __symexpf
(
    .param .b32 __symexpf_param_0
)
;

.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.f32 %f1, [%rd1];
    { // callseq 0, 0
    .reg .b32 temp_param_reg;
    .param .b32 param0;
    st.param.f32 [param0+0], %f1;
    .param .b32 retval0;
    call.uni (retval0),
    __symexpf,
    (
    param0
    );
    ld.param.f32 %f2, [retval0+0];
    } // callseq 0
    st.global.f32 [%rd2], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "exp(in[0])");
}

/// `tanh.approx.f32` is `(e^2x - 1) / (e^2x + 1)`, staying in the exp
/// fragment (like `Ex2`) instead of an opaque atom: it displays in that form
/// and folds to zero at 0.
#[test]
fn test_tanh_approx_expands_to_exp_fragment() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    ld.global.f32 %f1, [%rd1];
    tanh.approx.f32 %f2, %f1;
    st.global.f32 [%rd2], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(
        display_output(&output, "out", 0),
        "((exp((in[0] * 2)) - 1) / (exp((in[0] * 2)) + 1))"
    );
}

/// `tanh(0) = 0` is checked through canon's equivalence, not display:
/// `exp(0)` is not folded to `1` at construction, so canon's algebra proves
/// the collapse.
#[test]
fn test_tanh_approx_zero_equivalent_to_zero() {
    let tanh_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    mov.f32 %f1, 0f00000000;
    tanh.approx.f32 %f2, %f1;
    st.global.f32 [%rd1], %f2;
    ret;
}
",
    );
    let zero_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    mov.f32 %f1, 0f00000000;
    st.global.f32 [%rd1], %f1;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&tanh_src), None, out_only_config(4, 1)).expect("tanh analysis");
    let b = analyze_kernel(&parse(&zero_src), None, out_only_config(4, 1)).expect("zero analysis");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// shfl.sync.idx exchanges lane values (2 lanes, mask 0x3):
/// out[tid] = in[tid ^ 1].
#[test]
fn test_shfl_sync_idx_exchange() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<7>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 2;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    xor.b32 %r3, %r1, 1;
    mov.u32 %r4, 31;
    mov.u32 %r5, 3;
    shfl.sync.idx.b32 %f2, %f1, %r3, %r4, %r5;
    add.s64 %rd5, %rd2, %rd3;
    st.global.f32 [%rd5], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[1]");
    assert_eq!(display_output(&output, "out", 1), "in[0]");
    // Warp syncs count once per fired group.
    assert_eq!(output.stats.warp_syncs, 1);
}

/// Output-only config for a full 32-lane warp, storing `len`
/// `elem_width`-byte elements as the kernel's single parameter.
fn warp_out_config(elem_width: u64, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width,
        len,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// `redux.sync.max.u32`/`.min.s32` fold every lane's value (0..31, and
/// its `- 16` shift) across the full warp and broadcast the single result
/// to every lane - one `redux.sync` fires per group.
#[test]
fn test_redux_sync_max_min_full_warp() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    mov.u32 %r0, %tid.x;
    redux.sync.max.u32 %r1, %r0, -1;
    sub.s32 %r2, %r0, 16;
    redux.sync.min.s32 %r3, %r2, -1;
    mul.wide.u32 %rd1, %r0, 8;
    add.u64 %rd2, %rd0, %rd1;
    st.global.u32 [%rd2], %r1;
    add.u64 %rd2, %rd2, 4;
    st.global.u32 [%rd2], %r3;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, warp_out_config(4, 64)).unwrap();
    // max(0..31) = 31, min(-16..15) = -16, broadcast to lanes 0 and 31;
    // `st.global.u32` stores raw unsigned bits, so -16 reads back as
    // 4294967280.
    assert_eq!(display_output(&output, "out", 0), "31");
    assert_eq!(display_output(&output, "out", 1), "4294967280");
    assert_eq!(display_output(&output, "out", 62), "31");
    assert_eq!(display_output(&output, "out", 63), "4294967280");
    assert_eq!(output.stats.warp_syncs, 2);
}

/// `redux.sync.and`/`.or`/`.add` over the same 0..31 lane values (all
/// `.b32`/`.u32`, no signedness distinction).
#[test]
fn test_redux_sync_and_or_add_full_warp() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b32 %r<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    mov.u32 %r0, %tid.x;
    redux.sync.and.b32 %r1, %r0, -1;
    redux.sync.or.b32 %r2, %r0, -1;
    redux.sync.add.u32 %r3, %r0, -1;
    mul.wide.u32 %rd1, %r0, 12;
    add.u64 %rd2, %rd0, %rd1;
    st.global.u32 [%rd2], %r1;
    add.u64 %rd2, %rd2, 4;
    st.global.u32 [%rd2], %r2;
    add.u64 %rd2, %rd2, 4;
    st.global.u32 [%rd2], %r3;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, warp_out_config(4, 96)).unwrap();
    // AND(0..31) = 0, OR(0..31) = 31, SUM(0..31) = 496.
    assert_eq!(display_output(&output, "out", 0), "0");
    assert_eq!(display_output(&output, "out", 1), "31");
    assert_eq!(display_output(&output, "out", 2), "496");
    assert_eq!(output.stats.warp_syncs, 3);
}

/// A predicated `redux.sync` fires only for lanes that take it: lanes 16..31
/// skip the guarded `max.s32` and keep their sentinel; all lanes get the
/// `min.s32` result.
#[test]
fn test_redux_sync_partial_mask_skips_unguarded_lanes() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    mov.u32 %r0, %tid.x;
    sub.s32 %r1, %r0, 16;
    redux.sync.min.s32 %r2, %r1, -1;
    setp.lt.u32 %p0, %r0, 16;
    mov.u32 %r3, 999;
@%p0 redux.sync.max.s32 %r3, %r1, 0x0000ffff;
    mul.wide.u32 %rd1, %r0, 8;
    add.u64 %rd2, %rd0, %rd1;
    st.global.u32 [%rd2], %r2;
    add.u64 %rd2, %rd2, 4;
    st.global.u32 [%rd2], %r3;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, warp_out_config(4, 64)).unwrap();
    // Lane 0 (guarded, mask 0..15): min over 32 lanes is -16, max over 0..15 is
    // -1; stored as raw unsigned bits, they read back as 4294967280/4294967295.
    assert_eq!(display_output(&output, "out", 0), "4294967280");
    assert_eq!(display_output(&output, "out", 1), "4294967295");
    // Lane 16 (not guarded): still gets the full-warp min, but never
    // executes the guarded redux, so its sentinel is untouched.
    assert_eq!(display_output(&output, "out", 32), "4294967280");
    assert_eq!(display_output(&output, "out", 33), "999");
    assert_eq!(output.stats.warp_syncs, 2);
}

/// Float `.sat` clamps the result to [0, 1]; concrete operands fold all
/// the way to the clamped constant.
#[test]
fn test_add_sat_f32_concrete_clamps() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<5>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.f32 %f1, 0f3F400000;
    add.sat.f32 %f2, %f1, %f1;
    st.global.f32 [%rd1], %f2;
    mov.f32 %f3, 0fBF400000;
    add.sat.f32 %f4, %f3, 0f3E800000;
    st.global.f32 [%rd1+4], %f4;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    // 0.75 + 0.75 = 1.5 saturates to 1.0.
    assert_eq!(display_output(&output, "out", 0), "1");
    // -0.75 + 0.25 = -0.5 saturates to 0.0.
    assert_eq!(display_output(&output, "out", 1), "0");
}

/// f16 input/output arrays alongside an f32 input (elem_width 2 out).
fn f32_in_f16_out_config(threads: u32, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// nvcc's fused-ReLU epilogue `cvt.rn.relu.f16.f32` is the exact value
/// transformation max(x, 0) on a symbolic input.
#[test]
fn test_cvt_relu_symbolic_is_max() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<2>;
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
    cvt.rn.relu.f16.f32 %rs1, %f1;
    st.global.u16 [%rd2], %rs1;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, f32_in_f16_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "max(in[0], 0)");
}

/// ReLU via the fused cvt epilogue is equivalent to ReLU via an explicit
/// max.f32 against zero (with flipped operand order): the clamp and the
/// max are the same real function, and canon flattens max atoms.
#[test]
fn test_relu_epilogue_equivalent_to_explicit_max() {
    const PROLOGUE: &str = ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<2>;
    .reg .f32 %f<4>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<7>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 2;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    shl.b32 %r3, %r1, 1;
    cvt.u64.u32 %rd5, %r3;
    add.s64 %rd6, %rd2, %rd5;
";
    let fused = wrap(&format!(
        "{}    cvt.rn.relu.f16.f32 %rs1, %f1;
    st.global.u16 [%rd6], %rs1;
    ret;
}}
",
        PROLOGUE
    ));
    let explicit = wrap(&format!(
        "{}    mov.f32 %f2, 0f00000000;
    max.f32 %f3, %f2, %f1;
    cvt.rn.f16.f32 %rs1, %f3;
    st.global.u16 [%rd6], %rs1;
    ret;
}}
",
        PROLOGUE
    ));
    let a = analyze_kernel(&parse(&fused), None, f32_in_f16_out_config(2, 2)).unwrap();
    let b = analyze_kernel(&parse(&explicit), None, f32_in_f16_out_config(2, 2)).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

// =========================================================================
// Paper kernels: Harris reductions
// =========================================================================

/// Config for the reduction kernels: int arrays, `n` input elements.
fn reduction_config(threads: u32, n: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len: n,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 1,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

fn run_reduction(
    file: &str,
    kernel: &str,
    threads: u32,
    n: u64,
    dynamic_shared: u64,
) -> AnalysisOutput {
    let module = parse_file(file);
    let mut config = reduction_config(threads, n);
    config.dynamic_shared_bytes = dynamic_shared;
    analyze_kernel(&module, Some(kernel), config)
        .unwrap_or_else(|e| panic!("{} failed: {}", file, e))
}

fn red1() -> AnalysisOutput {
    run_reduction(
        "01_reduction/Red-1.ptx",
        "_Z17reduce1024_1blockPKiPi",
        128,
        128,
        0,
    )
}

#[test]
fn test_red1_race_free() {
    let output = red1();
    assert_eq!(output.outputs.len(), 1);
    assert!(output.stats.block_syncs > 0);
}

#[test]
fn test_red1_self_equivalence() {
    let a = red1();
    let b = red1();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_red2_equivalent() {
    let a = red1();
    let b = run_reduction("01_reduction/Red-2.ptx", "_Z7reduce2PiS_", 128, 128, 0);
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_red3_equivalent() {
    let a = red1();
    // Red-3 uses extern (dynamic) shared memory: 128 ints.
    let b = run_reduction("01_reduction/Red-3.ptx", "_Z7reduce3PiS_", 128, 128, 512);
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_red4_equivalent() {
    let a = red1();
    // Red-4 adds `in[i] + in[i + 64]` on load; threads 64..128's `in[128..192)`
    // loads land in sdata's unused half, so the sum covers `in[0..128)` and the
    // input spans 192.
    let b = run_reduction("01_reduction/Red-4.ptx", "_Z7reduce0PiS_", 128, 192, 0);
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// A deliberately wrong reduction (dropping one element) must be caught.
#[test]
fn test_red1_wrong_input_not_equivalent() {
    let a = red1();
    // Same kernel, but with only 127 of the 128 inputs shared: rename the
    // input array so its symbols differ.
    let module = parse_file("01_reduction/Red-1.ptx");
    let mut config = reduction_config(128, 128);
    config.arrays[0].name = "other".to_string();
    config.params[0] = ParamValue::ArrayPtr("other".to_string());
    let b = analyze_kernel(&module, Some("_Z17reduce1024_1blockPKiPi"), config).unwrap();
    assert!(matches!(
        check_equiv(&a, &b),
        EquivOutcome::NotEquivalent { .. }
    ));
}

// =========================================================================
// Exact real-constant folding: fold algebra = canon's algebra, so equal values fold equally
// =========================================================================

/// One-input/one-output f32 config over `in`/`out` (single thread).
fn one_elem_config() -> AnalysisConfig {
    in_out_config(1, 1)
}

/// `div.rn.f32 d, 1.0, 3.0` and `rcp.approx.f32 d, 3.0` fold to the same
/// exact rational 1/3, so kernels using either spelling are equivalent.
#[test]
fn test_div_by_three_equivalent_to_rcp_of_three() {
    let div_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
    div.rn.f32 %f2, 0f3F800000, 0f40400000;
    mul.f32 %f3, %f1, %f2;
    st.global.f32 [%rd2], %f3;
    ret;
}
",
    );
    let rcp_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
    mov.f32 %f2, 0f40400000;
    rcp.approx.f32 %f3, %f2;
    mul.f32 %f4, %f1, %f3;
    st.global.f32 [%rd2], %f4;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&div_src), None, one_elem_config()).unwrap();
    let b = analyze_kernel(&parse(&rcp_src), None, one_elem_config()).unwrap();
    // Both fold to the exact rational 1/3.
    assert_eq!(display_output(&a, "out", 0), "(in[0] * 1/3)");
    assert_eq!(display_output(&b, "out", 0), "(in[0] * 1/3)");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// `sum / N` vs the strength-reduced `t = 1.0 / N; sum * t` at concrete
/// N = 768: 1/768 is not dyadic, so the old fold rounded `t` to fl(1/768)
/// and reported a false DIFF; the exact fold makes them equivalent.
#[test]
fn test_div_by_n_equivalent_to_mul_by_computed_reciprocal() {
    let div_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
    div.rn.f32 %f2, %f1, 0f44400000;
    st.global.f32 [%rd2], %f2;
    ret;
}
",
    );
    let recip_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<5>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
    div.rn.f32 %f2, 0f3F800000, 0f44400000;
    mul.f32 %f3, %f1, %f2;
    st.global.f32 [%rd2], %f3;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&div_src), None, one_elem_config()).unwrap();
    let b = analyze_kernel(&parse(&recip_src), None, one_elem_config()).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// f64 in/out config for the double-precision constant tests.
fn f64_out_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 8,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// Concrete fma folds exactly as mul-then-add: one algebra, no fused
/// rounding (the old f64 folds could disagree between the two spellings).
#[test]
fn test_concrete_fma_equivalent_to_mul_add() {
    let fma_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f64 %fd<5>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.f64 %fd1, 0d3FB999999999999A;
    mov.f64 %fd2, 0d3FC999999999999A;
    mov.f64 %fd3, 0d3FD3333333333333;
    fma.rn.f64 %fd4, %fd1, %fd2, %fd3;
    st.global.f64 [%rd1], %fd4;
    ret;
}
",
    );
    let mul_add_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f64 %fd<6>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.f64 %fd1, 0d3FB999999999999A;
    mov.f64 %fd2, 0d3FC999999999999A;
    mov.f64 %fd3, 0d3FD3333333333333;
    mul.f64 %fd4, %fd1, %fd2;
    add.f64 %fd5, %fd4, %fd3;
    st.global.f64 [%rd1], %fd5;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&fma_src), None, f64_out_config()).unwrap();
    let b = analyze_kernel(&parse(&mul_add_src), None, f64_out_config()).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// Model-faithful: 0.1 + 0.2 computed at runtime is the exact rational sum,
/// NOT the pre-rounded f64 literal 0d3FD3333333333334 the hardware would
/// produce.
#[test]
fn test_runtime_sum_differs_from_prerounded_literal() {
    let sum_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f64 %fd<4>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.f64 %fd1, 0d3FB999999999999A;
    mov.f64 %fd2, 0d3FC999999999999A;
    add.f64 %fd3, %fd1, %fd2;
    st.global.f64 [%rd1], %fd3;
    ret;
}
",
    );
    let literal_src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f64 %fd<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.f64 %fd1, 0d3FD3333333333334;
    st.global.f64 [%rd1], %fd1;
    ret;
}
",
    );
    let a = analyze_kernel(&parse(&sum_src), None, f64_out_config()).unwrap();
    let b = analyze_kernel(&parse(&literal_src), None, f64_out_config()).unwrap();
    assert!(matches!(
        check_equiv(&a, &b),
        EquivOutcome::NotEquivalent { .. }
    ));
}

/// A NaN literal (0f7FC00000) is rejected at lowering: NaN denotes no
/// real number, so it cannot enter the analysis model.
#[test]
fn test_nan_literal_rejected_at_lowering() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<2>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.f32 %f1, 0f7FC00000;
    st.global.f32 [%rd1], %f1;
    ret;
}
",
    );
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let err = analyze_kernel(&parse(&src), None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Lower(_)),
        "expected lowering rejection of the NaN literal, got: {}",
        err
    );
    assert!(
        err.to_string().contains("NaN literal"),
        "unexpected message: {}",
        err
    );
}

/// A NaN float parameter is a config validation error.
#[test]
fn test_nan_float_param_rejected() {
    let src = wrap(
        ".visible .entry k(
    .param .f32 k_param_0
)
{
    ret;
}
",
    );
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.params = vec![ParamValue::Float(f64::NAN)];
    let err = analyze_kernel(&parse(&src), None, config).unwrap_err();
    assert!(
        matches!(&err, AnalysisError::Eval(EvalError::Config { message }) if message.contains("NaN")),
        "expected NaN config validation error, got: {}",
        err
    );
}

/// `0.0 / 0.0` no longer mints a NaN: the division stays a symbolic node
/// and the decision procedure errors loudly on the formally-zero
/// denominator when the element is checked.
#[test]
fn test_zero_over_zero_is_a_loud_equivalence_error() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<2>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    div.rn.f32 %f2, 0f00000000, 0f00000000;
    st.global.f32 [%rd1], %f2;
    ret;
}
",
    );
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let a = analyze_kernel(&parse(&src), None, config.clone()).unwrap();
    // The output expression is the unfolded division, not a constant.
    assert_eq!(display_output(&a, "out", 0), "(0 / 0)");
    let b = analyze_kernel(&parse(&src), None, config).unwrap();
    let arrays: Vec<String> = a.outputs.iter().map(|(n, _)| n.clone()).collect();
    let err = check_output_equivalence(&a, &b, &arrays).unwrap_err();
    assert!(
        err.to_string().contains("division"),
        "expected a division-by-zero equivalence error, got: {}",
        err
    );
}

// =========================================================================
// The paper's Sync at warp level: exited lanes arrive and join the chi-clear (Sync'/syncMem)
// =========================================================================

/// Tail-exit warp reduction: lanes 16..31 exit and the survivors run a
/// full-mask `shfl.sync.down` tree; exited lanes count as arrived (paper's
/// Sync rule, and the ISA's), so it sums in[0..16].
#[test]
fn test_tail_exit_warp_shfl_reduction() {
    let mut body = String::from(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<7>;
    .reg .f32 %f<7>;
    .reg .b32 %r<13>;
    .reg .b64 %rd<6>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    setp.gt.u32 %p1, %r1, 15;
@%p1 ret;
    shl.b32 %r2, %r1, 2;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    mov.u32 %r3, 31;
    mov.u32 %r4, -1;
",
    );
    for (round, offset) in [8u32, 4, 2, 1].into_iter().enumerate() {
        let (w, p, r) = (round + 2, round + 2, round + 5);
        body.push_str(&format!(
            "    mov.u32 %r{r}, {offset};
    shfl.sync.down.b32 %f{w}, %f1, %r{r}, %r3, %r4;
    add.u32 %r{r2}, %r1, {offset};
    setp.lt.u32 %p{p}, %r{r2}, 16;
@%p{p} add.f32 %f1, %f1, %f{w};
",
            r2 = round + 9,
        ));
    }
    body.push_str(
        "    setp.ne.u32 %p6, %r1, 0;
@%p6 ret;
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&wrap(&body));
    let a = analyze_kernel(&module, None, in_out_config(32, 16)).unwrap();
    assert_eq!(a.stats.warp_syncs, 4);

    // Reference: one thread sums in[0..16] sequentially.
    let mut ref_body = String::from(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<3>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
",
    );
    for i in 1..16 {
        ref_body.push_str(&format!(
            "    ld.global.f32 %f2, [%rd1+{}];
    add.f32 %f1, %f1, %f2;
",
            i * 4
        ));
    }
    ref_body.push_str(
        "    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let b = analyze_kernel(&parse(&wrap(&ref_body)), None, in_out_config(1, 16)).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// A shfl value sourced from an exited in-mask lane is Undefined (ISA:
/// "results are undefined if a thread sources a register from an inactive
/// thread"); the group still fires.
#[test]
fn test_shfl_from_exited_lane_is_undefined() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .f32 %f<3>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<6>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    setp.gt.u32 %p1, %r1, 15;
@%p1 ret;
    shl.b32 %r2, %r1, 2;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    mov.u32 %r3, 31;
    mov.u32 %r4, -1;
    mov.u32 %r5, 8;
    shfl.sync.down.b32 %f2, %f1, %r5, %r3, %r4;
    add.s64 %rd5, %rd2, %rd3;
    st.global.f32 [%rd5], %f2;
    ret;
}
",
    );
    let module = parse(&src);
    // Lanes 8..15 source exited lanes 16..23 and store the Undefined result.
    let err = analyze_kernel(&module, None, in_out_config(32, 16)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected undefined output from exited source lane, got: {}",
        err
    );
}

/// Not a race: a lane reads shared and exits, then the survivor
/// bar.warp.syncs the full mask and writes the byte; syncMem clears over all
/// of I, the returned lane included.
#[test]
fn test_bar_warp_sync_clears_chi_for_exited_reader() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<4>;
    .shared .align 4 .b8 sdata[8];

    mov.u32 %r1, %tid.x;
    mov.u32 %r2, sdata;
    setp.eq.u32 %p1, %r1, 1;
@%p1 ld.shared.u32 %r3, [%r2];
@%p1 ret;
    bar.warp.sync 3;
    st.shared.u32 [%r2], %r1;
    ret;
}
",
    );
    let module = parse(&src);
    analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1)))
        .expect("read-then-exit / sync / write must not race under the paper's syncMem");
}

/// Mirrored variant: a lane writes shared memory and exits; the survivor
/// syncs and reads the byte back. No race, and the exited lane's value is
/// visible (syncMem clears ordering state, not memory).
#[test]
fn test_bar_warp_sync_clears_chi_for_exited_writer() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<5>;
    .reg .b64 %rd<2>;
    .shared .align 4 .b8 sdata[8];

    ld.param.u64 %rd1, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, %tid.x;
    mov.u32 %r2, sdata;
    setp.eq.u32 %p1, %r1, 1;
    mov.u32 %r3, 42;
@%p1 st.shared.u32 [%r2], %r3;
@%p1 ret;
    bar.warp.sync 3;
    ld.shared.u32 %r4, [%r2];
    st.global.u32 [%rd1], %r4;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 1))
        .expect("write-then-exit / sync / read must not race under the paper's syncMem");
    assert_eq!(display_output(&output, "out", 0), "42");
}

/// bar.warp.sync end-to-end (previously UnsupportedInstruction at
/// lowering): the neighbor exchange synchronized by a warp barrier instead
/// of a CTA barrier.
#[test]
fn test_bar_warp_sync_neighbor_exchange() {
    let src = wrap(&SWAP_BODY.replace("BARRIER", "bar.warp.sync 3;"));
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[1]");
    assert_eq!(display_output(&output, "out", 1), "in[0]");
    assert_eq!(output.stats.block_syncs, 0);
    assert_eq!(output.stats.warp_syncs, 1);
}

/// `barrier.sync{.aligned} a` (no thread count) is the same full-CTA
/// barrier as `bar.sync a` (ISA: "bar{.cta}.sync is equivalent to
/// barrier{.cta}.sync.aligned").
#[test]
fn test_barrier_sync_is_bar_sync() {
    for form in ["barrier.sync 0;", "barrier.cta.sync.aligned 0;"] {
        let src = wrap(&SWAP_BODY.replace("BARRIER", form));
        let module = parse(&src);
        let output = analyze_kernel(&module, None, in_out_config(2, 2))
            .unwrap_or_else(|e| panic!("{} failed: {}", form, e));
        assert_eq!(display_output(&output, "out", 0), "in[1]");
        assert_eq!(display_output(&output, "out", 1), "in[0]");
        assert_eq!(output.stats.block_syncs, 2);
    }
}

// =========================================================================
// activemask: exact for the converged case (existing, non-exited lanes)
// =========================================================================

/// activemask kernel: each thread records its mask; a CTA barrier after the
/// query means no thread has exited yet, making the all-alive answer
/// deterministic.
fn activemask_body(barrier: &str) -> String {
    format!(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .pred %p<2>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;

    ld.param.u64 %rd1, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r2, %tid.x;
    {barrier}
    activemask.b32 %r1;
    shl.b32 %r3, %r2, 2;
    cvt.u64.u32 %rd2, %r3;
    add.s64 %rd3, %rd1, %rd2;
    st.global.u32 [%rd3], %r1;
    ret;
}}
"
    )
}

/// All 32 lanes alive: every thread reads 0xFFFFFFFF. The barrier comes
/// *after* activemask here, so each thread queries while all others are
/// alive (blocked or not-yet-run, never exited).
#[test]
fn test_activemask_all_alive_full_warp() {
    let body = activemask_body("").replace(
        "activemask.b32 %r1;",
        "activemask.b32 %r1;\n    bar.sync 0;",
    );
    let module = parse(&wrap(&body));
    let output = analyze_kernel(&module, None, in_out_config(32, 32)).unwrap();
    for i in 0..32 {
        assert_eq!(display_output(&output, "out", i), "4294967295");
    }
}

/// A 16-thread block: warp lanes 16..31 do not exist and contribute 0, so
/// every thread reads 0xFFFF (again with the barrier after the query, so
/// all queries happen before any exit).
#[test]
fn test_activemask_16_thread_block() {
    let body = activemask_body("").replace(
        "activemask.b32 %r1;",
        "activemask.b32 %r1;\n    bar.sync 0;",
    );
    let module = parse(&wrap(&body));
    let output = analyze_kernel(&module, None, in_out_config(16, 16)).unwrap();
    for i in 0..16 {
        assert_eq!(display_output(&output, "out", i), "65535");
    }
}

/// Tail-exit: threads 16..31 exit before the barrier. Only thread 0 is
/// asserted: later survivors also see earlier survivors' exits, and the model
/// promises nothing about exit order.
#[test]
fn test_activemask_after_tail_exit() {
    let mut body = activemask_body("bar.sync 0;");
    body = body.replace(
        "    mov.u32 %r2, %tid.x;\n",
        "    mov.u32 %r2, %tid.x;\n    setp.gt.u32 %p1, %r2, 15;\n@%p1 ret;\n",
    );
    let module = parse(&wrap(&body));
    let output = analyze_kernel(&module, None, in_out_config(32, 32)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "65535");
}

// =========================================================================
// Bounds hardening: ownership, whole-vector footprints, overflow-proof addresses (release-active)
// =========================================================================

/// The paper's own §6.2 pattern: `__shared__ int A[48]` read at
/// `A[tid]` by 64 threads - threads 48..63 read out of bounds and must be
/// caught (hardware happens to tolerate this; the model must not).
#[test]
fn test_shared_array_overflow_read_is_out_of_bounds() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b32 %r<6>;
    .shared .align 4 .b8 A[192];

    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 2;
    mov.u32 %r3, A;
    add.s32 %r4, %r3, %r2;
    ld.shared.u32 %r5, [%r4];
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::OutOfBounds { addr: 192, .. })
        ),
        "expected out-of-bounds at A+192, got: {}",
        err
    );
}

/// A v4 load starting in shared array A whose tail runs into adjacent B: the
/// whole-footprint ownership check makes it a loud OutOfBounds, not a silent
/// neighbor read.
#[test]
fn test_vector_straddling_adjacent_shared_arrays() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b32 %r<7>;
    .shared .align 4 .b8 A[40];
    .shared .align 4 .b8 B[64];

    mov.u32 %r1, A;
    ld.shared.v4.u32 {%r2, %r3, %r4, %r5}, [%r1+32];
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::OutOfBounds {
                addr: 32,
                width: 16,
                ..
            })
        ),
        "expected the v4 straddle to be out of bounds, got: {}",
        err
    );
}

/// `x[tid - 1]` at tid = 0 with the array at address 0 wraps to
/// 0xFFFF_FFFF_FFFF_FFFC; the subtraction-form bounds check rejects it in
/// every build profile, including release.
#[test]
fn test_negative_index_wrap_is_out_of_bounds() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<2>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<6>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    add.s32 %r2, %r1, -1;
    cvt.s64.s32 %rd3, %r2;
    shl.b64 %rd3, %rd3, 2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = in_out_config(1, 4);
    config.arrays[0].base = 0; // x based at 0: base + (-4) wraps
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::OutOfBounds { addr, width: 4, .. })
                if addr == u64::MAX - 3
        ),
        "expected the wrapped address to be out of bounds, got: {}",
        err
    );
}

/// Aligned in-bounds accesses at region edges still pass: a shared array's
/// last scalar element (adjacent array following) and an exact-fit v4 ending
/// at the region end.
#[test]
fn test_region_edge_exact_fit_accesses_pass() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<13>;
    .reg .b64 %rd<2>;
    .shared .align 4 .b8 A[48];
    .shared .align 4 .b8 B[64];

    ld.param.u64 %rd1, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, A;
    mov.u32 %r2, 1;
    mov.u32 %r3, 2;
    mov.u32 %r4, 3;
    mov.u32 %r5, 4;
    st.shared.v4.u32 [%r1+32], {%r2, %r3, %r4, %r5};
    mov.u32 %r6, 7;
    st.shared.u32 [%r1+44], %r6;
    ld.shared.u32 %r7, [%r1+44];
    ld.shared.v4.u32 {%r8, %r9, %r10, %r11}, [%r1+32];
    mov.u32 %r12, B;
    st.shared.u32 [%r12], %r7;
    ld.shared.u32 %r7, [%r12];
    st.global.u32 [%rd1], %r7;
    st.global.u32 [%rd1+4], %r8;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 2))
        .expect("exact-fit edge accesses must stay in bounds");
    // The scalar store at A+44 overwrote the v4's last element; the v4
    // read back yields {1, 2, 3, 7}.
    assert_eq!(display_output(&output, "out", 0), "7");
    assert_eq!(display_output(&output, "out", 1), "1");
}

/// An array at 0x7FFF_FFFF_FFFF_FFF0: the +16 access crosses the i64 sign
/// boundary without u64 wrap. Addresses are u64 mod 2^64 (as on hardware), so
/// this is in bounds.
#[test]
fn test_upper_half_address_space_access_in_bounds() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1+16];
    st.global.f32 [%rd2], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = in_out_config(1, 8);
    config.arrays[0].base = 0x7FFF_FFFF_FFFF_FFF0;
    let output = analyze_kernel(&module, None, config)
        .expect("crossing 2^63 without wrapping u64 is in bounds");
    assert_eq!(display_output(&output, "out", 0), "in[4]");
}

// =========================================================================
// Cross-family region overlap: config arrays vs the module-global window
// =========================================================================

/// A config array overlapping the reserved module-global window is a loud
/// setup error, not a silent shadowing: both families land in the one
/// global region list, whose disjointness `check_bounds` relies on.
#[test]
fn test_array_overlapping_module_global_window_rejected() {
    const MODULE_GLOBAL_BASE: u64 = 0x7000_0000_0000_0000;
    let src = wrap(
        ".global .align 4 .b32 g;
.visible .entry k()
{
    ret;
}
",
    );

    // The probe scenario: an array based exactly at the module-global
    // base, covering the global `g`.
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays.push(ArrayDef {
        name: "in".to_string(),
        base: MODULE_GLOBAL_BASE,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    });
    let err = analyze_kernel(&module, None, config.clone()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Config { message })
                if message.contains("module-global")
        ),
        "expected a module-global overlap config error, got: {}",
        err
    );

    // Range overlap, not just base membership: an array based below the
    // window whose tail reaches into it is rejected too.
    config.arrays[0].base = MODULE_GLOBAL_BASE - 8;
    let err = analyze_kernel(&module, None, config.clone()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Config { message })
                if message.contains("module-global")
        ),
        "expected a module-global overlap config error, got: {}",
        err
    );

    // Half-open boundary: an array ending exactly at the window base does
    // not overlap and is accepted.
    config.arrays[0].base = MODULE_GLOBAL_BASE - 16;
    analyze_kernel(&module, None, config).expect("an array ending at the window base is disjoint");
}

// =========================================================================
// Hostile declaration sizes: checked packing arithmetic
// =========================================================================

/// A shared declaration whose byte size overflows u64 (2^31 * 2^31 u32
/// elements) is rejected at lowering; release-wrapping would silently give it
/// a tiny size.
#[test]
fn test_hostile_shared_declaration_size_rejected() {
    let src = wrap(
        ".visible .entry k()
{
    .shared .align 4 .u32 A[2147483648][2147483648];

    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Lower(LowerError::VariableSizeOverflow { what }) if what.contains("A")
        ),
        "expected a variable-size overflow error, got: {}",
        err
    );
}

// =========================================================================
// cvta restriction: only cvta.to.global (the corpus form) is accepted
// =========================================================================

fn cvta_kernel(form: &str) -> String {
    wrap(&format!(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .b32 %r<2>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[16];

    ld.param.u64 %rd1, [k_param_1];
    mov.u32 %r1, sdata;
    cvt.u64.u32 %rd2, %r1;
    {form}
    ret;
}}
"
    ))
}

/// The corpus's one cvta form is accepted as the identity.
#[test]
fn test_cvta_to_global_accepted() {
    let module = parse(&cvta_kernel("cvta.to.global.u64 %rd3, %rd1;"));
    analyze_kernel(&module, None, in_out_config(1, 1)).expect("cvta.to.global is the corpus form");
}

/// Other cvta forms are rejected by name: `cvta.global` is compatible but
/// unused by the corpus, while shared/local forms would mint addresses in the
/// wrong space.
#[test]
fn test_cvta_other_forms_rejected() {
    for (form, expect, reason_fragment) in [
        ("cvta.global.u64 %rd3, %rd1;", "cvta.global", "corpus"),
        (
            "cvta.shared.u64 %rd3, %rd2;",
            "cvta.shared",
            "per-space windows",
        ),
        (
            "cvta.to.shared.u64 %rd3, %rd1;",
            "cvta.to.shared",
            "per-space windows",
        ),
    ] {
        let module = parse(&cvta_kernel(form));
        let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction {
                instruction,
                reason,
            }) => {
                assert_eq!(instruction, expect, "wrong instruction name for {}", form);
                assert!(
                    reason.as_deref().unwrap_or("").contains(reason_fragment),
                    "reason for {} should mention '{}', got: {:?}",
                    form,
                    reason_fragment,
                    reason
                );
            }
            other => panic!(
                "expected UnsupportedInstruction for {}, got: {}",
                form, other
            ),
        }
    }
}

// =========================================================================
// cp.async: in-flight hazard locking and post-completion visibility
// =========================================================================

/// Reading one's own `cp.async` destination before `wait_group` is a hazard
/// even same-thread: the destination lock also blocks the issuer, unlike
/// χ-tracking.
#[test]
fn test_cp_async_same_thread_peek_before_wait_is_hazard() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, sdata;
    cp.async.ca.shared.global [%r1], [%rd1], 4;
    cp.async.commit_group;
    ld.shared.u32 %r2, [%r1];
    ld.param.u64 %rd2, [out];
    cvta.to.global.u64 %rd2, %rd2;
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an async-copy hazard, got: {}",
        err
    );
}

/// The happy path: `cp.async` + `commit_group` + `wait_group 0` correctly
/// deposits the source value into shared memory, readable once waited on.
#[test]
fn test_cp_async_wait_group_completes_copy() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, sdata;
    cp.async.ca.shared.global [%r1], [%rd1], 4;
    cp.async.commit_group;
    cp.async.wait_group 0;
    ld.shared.u32 %r2, [%r1];
    ld.param.u64 %rd2, [out];
    cvta.to.global.u64 %rd2, %rd2;
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// Another thread touching the destination while thread 0's copy is in flight
/// is a hazard; the barrier exposes the interleaving (otherwise thread 0
/// would finish first).
#[test]
fn test_cp_async_cross_thread_read_of_locked_destination_is_hazard() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    mov.u32 %r1, %tid.x;
    setp.eq.u32 %p1, %r1, 0;
    mov.u32 %r2, sdata;
    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;

    @%p1 cp.async.ca.shared.global [%r2], [%rd1], 4;
    @%p1 cp.async.commit_group;
    @%p1 bar.sync 0;
    @%p1 cp.async.wait_group 0;
    @%p1 bra $DONE;

    @!%p1 ld.shared.u32 %r3, [%r2];
    @!%p1 bar.sync 0;

$DONE:
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an async-copy hazard, got: {}",
        err
    );
}

/// A different thread writing the source while thread 0's copy is still in
/// flight must also be a hazard (the source-lock half, not just the
/// destination half).
#[test]
fn test_cp_async_cross_thread_write_of_locked_source_is_hazard() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    mov.u32 %r1, %tid.x;
    setp.eq.u32 %p1, %r1, 0;
    mov.u32 %r2, sdata;
    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;

    @%p1 cp.async.ca.shared.global [%r2], [%rd1], 4;
    @%p1 cp.async.commit_group;
    @%p1 bar.sync 0;
    @%p1 cp.async.wait_group 0;
    @%p1 bra $DONE;

    @!%p1 mov.u32 %r4, 7;
    @!%p1 st.global.u32 [%rd1], %r4;
    @!%p1 bar.sync 0;

$DONE:
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an async-copy hazard, got: {}",
        err
    );
}

/// `wait_group` orders only the issuer's own later instructions: another
/// thread reading the destination after it, unsynchronized, is still a data
/// race (via χ, not the lock).
#[test]
fn test_cp_async_post_wait_cross_thread_read_without_sync_is_data_race() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    mov.u32 %r1, %tid.x;
    setp.eq.u32 %p1, %r1, 0;
    mov.u32 %r2, sdata;
    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;

    @%p1 cp.async.ca.shared.global [%r2], [%rd1], 4;
    @%p1 cp.async.commit_group;
    @%p1 cp.async.wait_group 0;

    @!%p1 ld.shared.u32 %r3, [%r2];
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected an ordinary data race (missing sync after wait_group), got: {}",
        err
    );
}

/// Same as above, but with the required `bar.sync` between thread 0's
/// `wait_group` and thread 1's read: this must succeed, confirming the
/// race in the previous test is exactly about the missing synchronization.
#[test]
fn test_cp_async_post_wait_cross_thread_read_with_sync_succeeds() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<6>;
    .shared .align 4 .b8 sdata[4];

    mov.u32 %r1, %tid.x;
    setp.eq.u32 %p1, %r1, 0;
    mov.u32 %r2, sdata;
    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;

    @%p1 cp.async.ca.shared.global [%r2], [%rd1], 4;
    @%p1 cp.async.commit_group;
    @%p1 cp.async.wait_group 0;
    bar.sync 0;

    @!%p1 ld.shared.u32 %r3, [%r2];
    @!%p1 ld.param.u64 %rd2, [out];
    @!%p1 cvta.to.global.u64 %rd2, %rd2;
    @!%p1 st.global.u32 [%rd2], %r3;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

// =========================================================================
// `fence.proxy.async` / async-proxy hazard (sm_90+ only)
// =========================================================================

/// `cp.async` -> `wait_group` -> `ld.shared` under `sm_90a` with no fence:
/// `cp.async` is a generic-proxy op (PTX ISA 9.7.10.28.3), so no
/// `fence.proxy.async` is needed.
#[test]
fn test_cp_async_without_fence_proxy_async_is_clean_on_sm90() {
    let src = wrap_sm90a(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, sdata;
    cp.async.ca.shared.global [%r1], [%rd1], 4;
    cp.async.commit_group;
    cp.async.wait_group 0;
    ld.shared.u32 %r2, [%r1];
    ld.param.u64 %rd2, [out];
    cvta.to.global.u64 %rd2, %rd2;
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// Same kernel, same `sm_90a` target, with a (redundant)
/// `fence.proxy.async.shared::cta;` between `wait_group` and the read -
/// must pass clean too.
#[test]
fn test_cp_async_with_fence_proxy_async_succeeds_on_sm90() {
    let src = wrap_sm90a(
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, sdata;
    cp.async.ca.shared.global [%r1], [%rd1], 4;
    cp.async.commit_group;
    cp.async.wait_group 0;
    fence.proxy.async.shared::cta;
    ld.shared.u32 %r2, [%r1];
    ld.param.u64 %rd2, [out];
    cvta.to.global.u64 %rd2, %rd2;
    st.global.u32 [%rd2], %r2;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// Regression guard for a real astra2 sm_89 MatrixVectorMultiplicationFloat16
/// kernel: `cp.async`, `wait_group`, `bar.sync`, cross-thread read, no fence;
/// below sm_90 it must never be flagged.
#[test]
fn test_cp_async_cross_thread_pattern_without_fence_is_clean_on_sm89() {
    let src = format!(
        "{}{}",
        ".version 8.0\n.target sm_89\n.address_size 64\n\n",
        ".visible .entry k(
    .param .u64 in,
    .param .u64 out
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    mov.u32 %r1, %tid.x;
    setp.eq.u32 %p1, %r1, 0;
    mov.u32 %r2, sdata;
    ld.param.u64 %rd1, [in];
    cvta.to.global.u64 %rd1, %rd1;

    @%p1 cp.async.ca.shared.global [%r2], [%rd1], 4;
    @%p1 cp.async.commit_group;
    @%p1 cp.async.wait_group 0;
    bar.sync 0;

    @!%p1 ld.shared.u32 %r3, [%r2];
    @!%p1 ld.param.u64 %rd2, [out];
    @!%p1 cvta.to.global.u64 %rd2, %rd2;
    @!%p1 st.global.u32 [%rd2], %r3;
    ret;
}
",
    );
    let module = parse(&src);
    let output = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// TMA's async-proxy write needs no `fence.proxy.async` either: the
/// completion carries an implicit proxy fence (PTX ISA 9.7.9.25.2). Same body
/// as the bulk-tensor test, under `sm_90a`.
#[test]
fn test_cp_async_bulk_tensor_without_fence_proxy_async_is_clean_on_sm90() {
    let src = wrap_sm90a(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .pred %p0;
    .reg .b16 %rs<3>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    .shared .align 128 .b8 sd0[128];
    .global .align 128 .b8 gbl[128];
    .shared .align 8 .b8 full[8];
    .shared .align 16 .b8 sa[32];

    ld.param.u64 %rd1, [k_param_0];

    mbarrier.init.shared::cta.b64 [full], 1;
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [full], 32;

    tensormap.replace.tile.global_address.shared::cta.b1024.b64 [sd0], %rd1;
    tensormap.replace.tile.rank.shared::cta.b1024.b32 [sd0], 1;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 0, 8;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 1, 8;
    tensormap.replace.tile.global_stride.shared::cta.b1024.b64 [sd0], 0, 16;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 0, 4;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 1, 4;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 0, 1;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 1, 1;
    tensormap.replace.tile.elemtype.shared::cta.b1024.b32 [sd0], 6;
    tensormap.replace.tile.interleave_layout.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_mode.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_atomicity.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.fill_mode.shared::cta.b1024.b32 [sd0], 0;

    tensormap.cp_fenceproxy.global.shared::cta.tensormap::generic.release.gpu.sync.aligned [gbl], [sd0], 128;
    fence.proxy.tensormap::generic.acquire.gpu [gbl], 128;

    mov.u32 %r1, 6;
    mov.u32 %r2, 6;
    cp.async.bulk.tensor.2d.shared::cluster.global.tile.mbarrier::complete_tx::bytes [sa], [gbl, {%r1, %r2}], [full];

    mbarrier.try_wait.parity.shared::cta.b64 %p0, [full], 0;

    ld.shared.u16 %rs1, [sa];
    ld.shared.u16 %rs2, [sa+30];

    ld.param.u64 %rd2, [k_param_1];
    st.global.u16 [%rd2], %rs1;
    st.global.u16 [%rd2+2], %rs2;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[54]");
    assert_eq!(display_output(&output, "out", 1), "0");
}

/// A TMA destination read does require the copy's completion: without the
/// `mbarrier.try_wait.parity`, the reads race the in-flight copy's
/// destination lock.
#[test]
fn test_cp_async_bulk_tensor_read_without_waiting_is_an_inflight_hazard() {
    let src = wrap_sm90a(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %rs<3>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<3>;

    .shared .align 128 .b8 sd0[128];
    .global .align 128 .b8 gbl[128];
    .shared .align 8 .b8 full[8];
    .shared .align 16 .b8 sa[32];

    ld.param.u64 %rd1, [k_param_0];

    mbarrier.init.shared::cta.b64 [full], 1;
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [full], 32;

    tensormap.replace.tile.global_address.shared::cta.b1024.b64 [sd0], %rd1;
    tensormap.replace.tile.rank.shared::cta.b1024.b32 [sd0], 1;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 0, 8;
    tensormap.replace.tile.global_dim.shared::cta.b1024.b32 [sd0], 1, 8;
    tensormap.replace.tile.global_stride.shared::cta.b1024.b64 [sd0], 0, 16;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 0, 4;
    tensormap.replace.tile.box_dim.shared::cta.b1024.b32 [sd0], 1, 4;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 0, 1;
    tensormap.replace.tile.element_stride.shared::cta.b1024.b32 [sd0], 1, 1;
    tensormap.replace.tile.elemtype.shared::cta.b1024.b32 [sd0], 6;
    tensormap.replace.tile.interleave_layout.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_mode.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.swizzle_atomicity.shared::cta.b1024.b32 [sd0], 0;
    tensormap.replace.tile.fill_mode.shared::cta.b1024.b32 [sd0], 0;

    tensormap.cp_fenceproxy.global.shared::cta.tensormap::generic.release.gpu.sync.aligned [gbl], [sd0], 128;
    fence.proxy.tensormap::generic.acquire.gpu [gbl], 128;

    mov.u32 %r1, 6;
    mov.u32 %r2, 6;
    cp.async.bulk.tensor.2d.shared::cluster.global.tile.mbarrier::complete_tx::bytes [sa], [gbl, {%r1, %r2}], [full];

    ld.shared.u16 %rs1, [sa];
    ld.shared.u16 %rs2, [sa+30];

    ld.param.u64 %rd2, [k_param_1];
    st.global.u16 [%rd2], %rs1;
    st.global.u16 [%rd2+2], %rs2;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let err = analyze_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an in-flight async-copy hazard, got: {}",
        err
    );
}

/// Two-warp CTA: thread 0 arms the `count = 1` mbarrier `full` (`%r4`) for 16
/// bytes and bulk-copies `in[0..4]` into `buf`. `%r6` = `count = 32` `gate`,
/// `%p2` = "in warp 0".
fn bulk_copy_two_warp_kernel(body: &str) -> Module {
    parse(&wrap_sm90a(&format!(
        ".visible .entry k(
    .param .u64 k_param_0
)
{{
    .reg .pred %p<4>;
    .reg .pred %pw;
    .reg .b32 %r<8>;
    .reg .b64 %rd<2>;
    .shared .align 16 .b8 buf[16];
    .shared .align 8 .b64 full;
    .shared .align 8 .b64 gate;

    ld.param.u64 %rd1, [k_param_0];
    mov.u32 %r4, full;
    mov.u32 %r6, gate;
    mov.u32 %r5, %tid.x;
    setp.eq.s32 %p1, %r5, 0;
    setp.lt.u32 %p2, %r5, 32;
    @%p1 mbarrier.init.shared.b64 [%r4], 1;
    @%p1 mbarrier.init.shared.b64 [%r6], 32;
    bar.sync 0;
    @!%p1 bra ISSUED;
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [%r4], 16;
    cp.async.bulk.shared::cta.global.mbarrier::complete_tx::bytes [buf], [%rd1], 16, [%r4];
ISSUED:
{body}
    ret;
}}
"
    )))
}

/// `in` as four `u32`s, passed as the kernel's only parameter.
fn bulk_copy_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "in".to_string(),
        base: 0x10000,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    }];
    config.params = vec![ParamValue::ArrayPtr("in".to_string())];
    config
}

/// A `bar.sync` after the issue orders nothing about the copy's write: warp
/// 1, released by `gate`'s bare `complete_tx`, reads `buf` unordered with it
/// (a χ race, not the lock).
#[test]
fn test_cp_async_bulk_bar_sync_before_completion_orders_nothing() {
    let module = bulk_copy_two_warp_kernel(
        "    bar.sync 0;
    @!%p2 bra READ;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
    setp.eq.s32 %p3, %r5, 1;
    @%p3 mbarrier.complete_tx.shared::cta.b64 [%r6], 32;
    bra DONE;
READ:
    mbarrier.arrive.expect_tx.shared::cta.b64 _, [%r6], 1;
GATE:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r6], 0;
    @!%pw bra GATE;
    ld.shared.u32 %r7, [buf];
DONE:",
    );
    let err = analyze_kernel(&module, None, bulk_copy_config()).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::DataRace {
            space,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*space, MemSpace::Shared);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread.warp(), ThreadId(32).warp());
            assert!(!current.is_write);
        }
        other => panic!("expected DataRace, got: {}", other),
    }
}

/// The copy's destination stays locked against every access from the
/// issue until a waiter observes `full` - a `bar.sync` in between lifts
/// nothing. Nobody waits here, and warp 1 reads `buf` after the barrier.
#[test]
fn test_cp_async_bulk_read_after_bar_sync_is_an_inflight_hazard() {
    let module = bulk_copy_two_warp_kernel(
        "    bar.sync 0;
    @%p2 bra DONE;
    ld.shared.u32 %r7, [buf];
DONE:",
    );
    let err = analyze_kernel(&module, None, bulk_copy_config()).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::AsyncCopyHazard { prior, current, .. }) => {
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread, ThreadId(32));
        }
        other => panic!("expected AsyncCopyHazard, got: {}", other),
    }
}

/// The control: a `bar.sync` *after* warp 0 observed the completion does
/// order the copy before warp 1's read.
#[test]
fn test_cp_async_bulk_bar_sync_after_completion_orders_the_read() {
    let module = bulk_copy_two_warp_kernel(
        "    @!%p2 bra SYNC;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
SYNC:
    bar.sync 0;
    @%p2 bra DONE;
    ld.shared.u32 %r7, [buf];
DONE:",
    );
    analyze_kernel(&module, None, bulk_copy_config()).unwrap();
}

/// The control: every reader waiting on `full` itself is ordered after the
/// copy, whatever `bar.sync` ran before it.
#[test]
fn test_cp_async_bulk_every_reader_waiting_is_accepted() {
    let module = bulk_copy_two_warp_kernel(
        "    bar.sync 0;
WAIT:
    mbarrier.try_wait.parity.shared.b64 %pw, [%r4], 0;
    @!%pw bra WAIT;
    @%p2 bra DONE;
    ld.shared.u32 %r7, [buf];
DONE:",
    );
    analyze_kernel(&module, None, bulk_copy_config()).unwrap();
}

// =========================================================================
// `wgmma.mma_async` / `stmatrix` (sm_90+)
// =========================================================================

/// `wgmma.fence` -> `mma_async.m64n8k16.f32.f16.f16` -> `commit_group` ->
/// `wait_group 0`, unswizzled K-major (LBO 128): thread 0's `%d0` must be
/// `sum(1..=16) = 136`.
#[test]
fn test_wgmma_mma_async_numeric_correctness() {
    let src = wrap_sm90a(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<6>;
    .reg .f32 %f<2>;
    .reg .b16 %rs<2>;
    .reg .f32 %d<4>;
    .shared .align 16 .b8 a_row[256];
    .shared .align 16 .b8 b_col[256];

    mov.u32 %r0, %tid.x;
    setp.eq.u32 %p1, %r0, 0;

    mov.u64 %rd1, a_row;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+0], %rs1;
    mov.f32 %f1, 0f40000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+2], %rs1;
    mov.f32 %f1, 0f40400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+4], %rs1;
    mov.f32 %f1, 0f40800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+6], %rs1;
    mov.f32 %f1, 0f40A00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+8], %rs1;
    mov.f32 %f1, 0f40C00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+10], %rs1;
    mov.f32 %f1, 0f40E00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+12], %rs1;
    mov.f32 %f1, 0f41000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+14], %rs1;
    mov.f32 %f1, 0f41100000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+128], %rs1;
    mov.f32 %f1, 0f41200000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+130], %rs1;
    mov.f32 %f1, 0f41300000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+132], %rs1;
    mov.f32 %f1, 0f41400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+134], %rs1;
    mov.f32 %f1, 0f41500000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+136], %rs1;
    mov.f32 %f1, 0f41600000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+138], %rs1;
    mov.f32 %f1, 0f41700000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+140], %rs1;
    mov.f32 %f1, 0f41800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+142], %rs1;

    mov.u64 %rd2, b_col;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+0], %rs1;
    @%p1 st.shared.b16 [%rd2+2], %rs1;
    @%p1 st.shared.b16 [%rd2+4], %rs1;
    @%p1 st.shared.b16 [%rd2+6], %rs1;
    @%p1 st.shared.b16 [%rd2+8], %rs1;
    @%p1 st.shared.b16 [%rd2+10], %rs1;
    @%p1 st.shared.b16 [%rd2+12], %rs1;
    @%p1 st.shared.b16 [%rd2+14], %rs1;
    @%p1 st.shared.b16 [%rd2+128], %rs1;
    @%p1 st.shared.b16 [%rd2+130], %rs1;
    @%p1 st.shared.b16 [%rd2+132], %rs1;
    @%p1 st.shared.b16 [%rd2+134], %rs1;
    @%p1 st.shared.b16 [%rd2+136], %rs1;
    @%p1 st.shared.b16 [%rd2+138], %rs1;
    @%p1 st.shared.b16 [%rd2+140], %rs1;
    @%p1 st.shared.b16 [%rd2+142], %rs1;

    fence.proxy.async.shared::cta;
    bar.sync 0;

    shr.u64 %rd3, %rd1, 4;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd3, %rd3, 0x80000;
    or.b64 %rd4, %rd4, 0x80000;
    setp.ne.u32 %p2, %r0, %r0;

    wgmma.fence.sync.aligned;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    wgmma.commit_group.sync.aligned;
    wgmma.wait_group.sync.aligned 0;

    ld.param.u64 %rd5, [k_param_0];
    @%p1 st.global.f32 [%rd5], %d0;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "136");
}

/// Two chained same-shape `wgmma.mma_async` calls with one fence before and
/// one commit/wait after (the H100 GEMM pattern) must not be flagged (ISA
/// fence exemption): `272`.
#[test]
fn test_wgmma_chained_same_shape_accumulator_needs_no_extra_fence() {
    let src = wrap_sm90a(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<6>;
    .reg .f32 %f<2>;
    .reg .b16 %rs<2>;
    .reg .f32 %d<4>;
    .shared .align 16 .b8 a_row[256];
    .shared .align 16 .b8 b_col[256];

    mov.u32 %r0, %tid.x;
    setp.eq.u32 %p1, %r0, 0;

    mov.u64 %rd1, a_row;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+0], %rs1;
    mov.f32 %f1, 0f40000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+2], %rs1;
    mov.f32 %f1, 0f40400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+4], %rs1;
    mov.f32 %f1, 0f40800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+6], %rs1;
    mov.f32 %f1, 0f40A00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+8], %rs1;
    mov.f32 %f1, 0f40C00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+10], %rs1;
    mov.f32 %f1, 0f40E00000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+12], %rs1;
    mov.f32 %f1, 0f41000000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+14], %rs1;
    mov.f32 %f1, 0f41100000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+128], %rs1;
    mov.f32 %f1, 0f41200000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+130], %rs1;
    mov.f32 %f1, 0f41300000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+132], %rs1;
    mov.f32 %f1, 0f41400000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+134], %rs1;
    mov.f32 %f1, 0f41500000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+136], %rs1;
    mov.f32 %f1, 0f41600000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+138], %rs1;
    mov.f32 %f1, 0f41700000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+140], %rs1;
    mov.f32 %f1, 0f41800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd1+142], %rs1;

    mov.u64 %rd2, b_col;
    mov.f32 %f1, 0f3F800000;
    cvt.rn.f16.f32 %rs1, %f1;
    @%p1 st.shared.b16 [%rd2+0], %rs1;
    @%p1 st.shared.b16 [%rd2+2], %rs1;
    @%p1 st.shared.b16 [%rd2+4], %rs1;
    @%p1 st.shared.b16 [%rd2+6], %rs1;
    @%p1 st.shared.b16 [%rd2+8], %rs1;
    @%p1 st.shared.b16 [%rd2+10], %rs1;
    @%p1 st.shared.b16 [%rd2+12], %rs1;
    @%p1 st.shared.b16 [%rd2+14], %rs1;
    @%p1 st.shared.b16 [%rd2+128], %rs1;
    @%p1 st.shared.b16 [%rd2+130], %rs1;
    @%p1 st.shared.b16 [%rd2+132], %rs1;
    @%p1 st.shared.b16 [%rd2+134], %rs1;
    @%p1 st.shared.b16 [%rd2+136], %rs1;
    @%p1 st.shared.b16 [%rd2+138], %rs1;
    @%p1 st.shared.b16 [%rd2+140], %rs1;
    @%p1 st.shared.b16 [%rd2+142], %rs1;

    fence.proxy.async.shared::cta;
    bar.sync 0;

    shr.u64 %rd3, %rd1, 4;
    shr.u64 %rd4, %rd2, 4;
    or.b64 %rd3, %rd3, 0x80000;
    or.b64 %rd4, %rd4, 0x80000;
    setp.ne.u32 %p2, %r0, %r0;

    wgmma.fence.sync.aligned;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    setp.eq.u32 %p2, %r0, %r0;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    wgmma.commit_group.sync.aligned;
    wgmma.wait_group.sync.aligned 0;

    ld.param.u64 %rd5, [k_param_0];
    @%p1 st.global.f32 [%rd5], %d0;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "272");
}

/// Hazard A (`WgmmaFenceHazard`): an ordinary register write between the two
/// calls breaks the same-shape chain, and the second call's accumulator read
/// has no `wgmma.fence`.
#[test]
fn test_wgmma_fence_hazard_ordinary_write_breaks_chain() {
    let src = wrap_sm90a(
        ".visible .entry k()
{
    .reg .pred %p<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .f32 %d<4>;
    .shared .align 16 .b8 a_row[256];
    .shared .align 16 .b8 b_col[256];

    mov.u32 %r0, %tid.x;
    setp.eq.u32 %p1, %r0, 0;
    mov.u64 %rd1, a_row;
    mov.u64 %rd2, b_col;
    bar.sync 0;

    shr.u64 %rd3, %rd1, 4;
    shr.u64 %rd4, %rd2, 4;
    setp.ne.u32 %p2, %r0, %r0;

    wgmma.fence.sync.aligned;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    wgmma.commit_group.sync.aligned;
    wgmma.wait_group.sync.aligned 0;

    // Ordinary write to %d0, released and no longer pending - breaks the
    // same-shape chain, and no wgmma.fence follows it.
    mov.f32 %f1, 0f00000000;
    mov.f32 %d0, %f1;

    setp.eq.u32 %p2, %r0, %r0;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    wgmma.commit_group.sync.aligned;
    wgmma.wait_group.sync.aligned 0;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((128, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::WgmmaFenceHazard { .. })),
        "expected a wgmma fence hazard, got: {}",
        err
    );
}

/// Hazard B (`WgmmaWaitGroupHazard`): a plain read of an accumulator
/// register still pending a `wgmma.wait_group` release.
#[test]
fn test_wgmma_wait_group_hazard_plain_read_of_pending_accumulator() {
    let src = wrap_sm90a(
        ".visible .entry k()
{
    .reg .pred %p<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .f32 %d<4>;
    .shared .align 16 .b8 a_row[256];
    .shared .align 16 .b8 b_col[256];

    mov.u32 %r0, %tid.x;
    setp.eq.u32 %p1, %r0, 0;
    mov.u64 %rd1, a_row;
    mov.u64 %rd2, b_col;
    bar.sync 0;

    shr.u64 %rd3, %rd1, 4;
    shr.u64 %rd4, %rd2, 4;
    setp.ne.u32 %p2, %r0, %r0;

    wgmma.fence.sync.aligned;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    wgmma.commit_group.sync.aligned;
    // No wait_group yet - %d0 is still pending when read below.
    mov.f32 %f1, %d0;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((128, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WgmmaWaitGroupHazard { .. })
        ),
        "expected a wgmma wait_group hazard, got: {}",
        err
    );
}

/// Likewise, an ordinary *write* to a pending accumulator register before
/// `wgmma.wait_group` is a hazard (`write_reg`'s hazard-B check, not just
/// `read_reg`'s).
#[test]
fn test_wgmma_wait_group_hazard_plain_write_of_pending_accumulator() {
    let src = wrap_sm90a(
        ".visible .entry k()
{
    .reg .pred %p<3>;
    .reg .b32 %r<2>;
    .reg .b64 %rd<5>;
    .reg .f32 %f<2>;
    .reg .f32 %d<4>;
    .shared .align 16 .b8 a_row[256];
    .shared .align 16 .b8 b_col[256];

    mov.u32 %r0, %tid.x;
    setp.eq.u32 %p1, %r0, 0;
    mov.u64 %rd1, a_row;
    mov.u64 %rd2, b_col;
    bar.sync 0;

    shr.u64 %rd3, %rd1, 4;
    shr.u64 %rd4, %rd2, 4;
    setp.ne.u32 %p2, %r0, %r0;

    wgmma.fence.sync.aligned;
    wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 {%d0, %d1, %d2, %d3}, %rd3, %rd4, %p2, 1, 1, 0, 0;
    wgmma.commit_group.sync.aligned;
    // No wait_group yet - %d0 is still pending when written below.
    mov.f32 %f1, 0f00000000;
    mov.f32 %d0, %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((128, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WgmmaWaitGroupHazard { .. })
        ),
        "expected a wgmma wait_group hazard, got: {}",
        err
    );
}

/// `stmatrix.x1.m8n8.shared.b16`: lane `l`'s value lands at `row_addr[l/4] +
/// (l%4)*4`, a bijection onto the 128 bytes; lane 5's value is read back at
/// `src+20`.
#[test]
fn test_stmatrix_writes_the_expected_byte_per_lane() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .pred %p<2>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<3>;
    .shared .align 16 .b8 buf[128];

    mov.u32 %r0, %tid.x;
    setp.eq.u32 %p1, %r0, 0;

    // Only lanes 0-7's addresses are consulted (num=1): `src + tid*16` gives
    // lane r row r's address.
    mov.u32 %r1, buf;
    mad.lo.u32 %r2, %r0, 16, %r1;

    // Per-lane source value: distinct and directly checkable.
    add.u32 %r3, %r0, 1000;

    stmatrix.sync.aligned.x1.m8n8.shared.b16 [%r2], {%r3};
    bar.sync 0;

    ld.param.u64 %rd1, [k_param_0];
    ld.shared.u32 %r4, [%r1+20];
    @%p1 st.global.u32 [%rd1], %r4;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1005");
}

// =========================================================================
// Packed single precision (f32x2, sm_100+)
// =========================================================================

/// Two threads, two f32 elements each: `out[i] = in[i] * in[i] + in[i]`;
/// `BODY` maps `{%f1, %f2}` to `{%f3, %f4}`, or `[%rd4]` to `[%rd5]` for
/// 64-bit memory variants.
fn f32x2_kernel(body: &str) -> String {
    wrap(&format!(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .f32 %f<5>;
    .reg .b32 %r<5>;
    .reg .b64 %rd<12>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 3;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    add.s64 %rd5, %rd2, %rd3;
    {body}
    ret;
}}
",
    ))
}

const F32X2_SCALAR_REFERENCE: &str = "ld.global.v2.f32 {%f1, %f2}, [%rd4];
    fma.rn.f32 %f3, %f1, %f1, %f1;
    fma.rn.f32 %f4, %f2, %f2, %f2;
    st.global.v2.f32 [%rd5], {%f3, %f4};";

fn f32x2_outcome(candidate_body: &str) -> EquivOutcome {
    let reference = analyze_kernel(
        &parse(&f32x2_kernel(F32X2_SCALAR_REFERENCE)),
        None,
        in_out_config(2, 4),
    )
    .unwrap();
    let candidate = analyze_kernel(
        &parse(&f32x2_kernel(candidate_body)),
        None,
        in_out_config(2, 4),
    )
    .unwrap();
    check_equiv(&reference, &candidate)
}

/// `mov.b64 %rd, {%f_lo, %f_hi}` packs two f32 registers, `fma.rn.f32x2`
/// works per lane, `mov.b64 {%f_lo, %f_hi}, %rd` unpacks the result.
#[test]
fn test_f32x2_fma_via_register_pack() {
    let outcome = f32x2_outcome(
        "ld.global.v2.f32 {%f1, %f2}, [%rd4];
    mov.b64 %rd6, {%f1, %f2};
    fma.rn.f32x2 %rd7, %rd6, %rd6, %rd6;
    mov.b64 {%f3, %f4}, %rd7;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// `mul.f32x2` then `add.f32x2` compute the same reals as the fused form.
#[test]
fn test_f32x2_mul_add_via_register_pack() {
    let outcome = f32x2_outcome(
        "ld.global.v2.f32 {%f1, %f2}, [%rd4];
    mov.b64 %rd6, {%f1, %f2};
    mul.rn.f32x2 %rd8, %rd6, %rd6;
    add.rn.f32x2 %rd7, %rd8, %rd6;
    mov.b64 {%f3, %f4}, %rd7;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// A 64-bit load over two adjacent f32 inputs yields the pair directly,
/// and a 64-bit store of the pair writes both output elements.
#[test]
fn test_f32x2_fma_via_64bit_memory_access() {
    let outcome = f32x2_outcome(
        "ld.global.b64 %rd6, [%rd4];
    fma.rn.f32x2 %rd7, %rd6, %rd6, %rd6;
    st.global.b64 [%rd5], %rd7;",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// A concrete 64-bit pattern used as an f32x2 operand decodes into its two
/// lanes (1.0f each); the point is that the constant lanes read correctly.
#[test]
fn test_f32x2_constant_bit_pattern_operand() {
    let outcome = f32x2_outcome(
        "ld.global.v2.f32 {%f1, %f2}, [%rd4];
    mov.b64 %rd6, {%f1, %f2};
    mov.b64 %rd8, 4575657222473777152;
    fma.rn.f32x2 %rd9, %rd6, %rd8, %rd6;
    sub.f32x2 %rd10, %rd9, %rd6;
    fma.rn.f32x2 %rd7, %rd10, %rd10, %rd10;
    mov.b64 {%f3, %f4}, %rd7;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// The lanes really are computed: dropping the addend changes the result.
#[test]
fn test_f32x2_wrong_lane_math_is_not_equivalent() {
    let outcome = f32x2_outcome(
        "ld.global.v2.f32 {%f1, %f2}, [%rd4];
    mov.b64 %rd6, {%f1, %f2};
    mul.rn.f32x2 %rd7, %rd6, %rd6;
    mov.b64 {%f3, %f4}, %rd7;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(
        matches!(outcome, EquivOutcome::NotEquivalent { .. }),
        "{:?}",
        outcome
    );
}

/// `mov.b64 %rd, {%r_lo, %r_hi}` with concrete integer halves still builds
/// the 64-bit integer (here a byte offset of 8) when read as a scalar.
#[test]
fn test_mov_b64_integer_pack_recombines_as_scalar() {
    let packed = f32x2_kernel(
        "ld.global.f32 %f1, [%rd4];
    mov.u32 %r3, 8;
    mov.u32 %r4, 0;
    mov.b64 %rd6, {%r3, %r4};
    add.s64 %rd7, %rd2, %rd6;
    st.global.f32 [%rd7], %f1;",
    );
    let direct = f32x2_kernel(
        "ld.global.f32 %f1, [%rd4];
    st.global.f32 [%rd2+8], %f1;",
    );
    let a = analyze_kernel(&parse(&packed), None, in_out_config(1, 4)).unwrap();
    let b = analyze_kernel(&parse(&direct), None, in_out_config(1, 4)).unwrap();
    assert_eq!(display_output(&a, "out", 2), display_output(&b, "out", 2));
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// nvcc/Triton's own way of building an `f32x2` operand: two 32-bit loads
/// zero-extended into 64-bit registers, `shl.b64` by 32 and `or.b64` to
/// place them in the two lanes (with an `and.b64` lane mask thrown in).
#[test]
fn test_f32x2_operand_assembled_with_shift_and_or() {
    let outcome = f32x2_outcome(
        "ld.global.b32 %rd6, [%rd4];
    ld.global.b32 %rd8, [%rd4+4];
    shl.b64 %rd9, %rd8, 32;
    or.b64 %rd10, %rd9, %rd6;
    and.b64 %rd11, %rd10, 4294967295;
    or.b64 %rd6, %rd11, %rd9;
    fma.rn.f32x2 %rd7, %rd6, %rd6, %rd6;
    mov.b64 {%f3, %f4}, %rd7;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// `shr.u64` by 32 moves the high lane down; the low lane is then read
/// through a 64-bit-to-32-bit unpack.
#[test]
fn test_f32x2_lane_extracted_with_shift() {
    let outcome = f32x2_outcome(
        "ld.global.b64 %rd6, [%rd4];
    fma.rn.f32x2 %rd7, %rd6, %rd6, %rd6;
    shr.u64 %rd8, %rd7, 32;
    mov.b64 {%f3, _}, %rd7;
    mov.b64 {%f4, _}, %rd8;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// `cvt.u64.u32` zero-extension is the other way nvcc/Triton feed one f32
/// into an `f32x2` lane, and `cvt.u32.u64` truncation reads a lane back.
#[test]
fn test_f32x2_operand_assembled_with_cvt_zero_extension() {
    let outcome = f32x2_outcome(
        "ld.global.v2.f32 {%f1, %f2}, [%rd4];
    mov.b32 %r3, %f1;
    mov.b32 %r4, %f2;
    cvt.u64.u32 %rd6, %r3;
    cvt.u64.u32 %rd8, %r4;
    shl.b64 %rd9, %rd8, 32;
    or.b64 %rd10, %rd6, %rd9;
    fma.rn.f32x2 %rd7, %rd10, %rd10, %rd10;
    shr.u64 %rd11, %rd7, 32;
    cvt.u32.u64 %r3, %rd7;
    cvt.u32.u64 %r4, %rd11;
    mov.b32 %f3, %r3;
    mov.b32 %f4, %r4;
    st.global.v2.f32 [%rd5], {%f3, %f4};",
    );
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// Every lane storing the same reduced value to one shared address (the
/// post-reduction layout idiom) is not a race; a store of a different value
/// still is.
#[test]
fn test_same_value_warp_uniform_store_is_not_a_race() {
    let body = |value: &str| {
        wrap(&format!(
            ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
    .reg .pred %p<2>;
    .reg .f32 %f<4>;
    .reg .b32 %r<6>;
    .reg .b64 %rd<4>;
    .shared .align 4 .b8 sdata[4];

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    ld.global.f32 %f1, [%rd1];
    {value}
    mov.u32 %r3, sdata;
    st.shared.f32 [%r3], %f2;
    bar.sync 0;
    ld.shared.f32 %f3, [%r3];
    setp.eq.u32 %p1, %r1, 0;
    @%p1 st.global.f32 [%rd2], %f3;
    ret;
}}
",
        ))
    };
    // Both threads store in[0] * 2: identical expressions, no race.
    let same = parse(&body("mul.f32 %f2, %f1, 0f40000000;"));
    let out = analyze_kernel(&same, None, in_out_config(2, 1)).expect("same-value store");
    assert_eq!(display_output(&out, "out", 0), "(in[0] * 2)");
    // Thread-dependent values at the same address: a real race.
    let differ = parse(&body("cvt.rn.f32.u32 %f2, %r1;"));
    let err = analyze_kernel(&differ, None, in_out_config(2, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected data race, got: {}",
        err
    );
}

/// A concrete 32-bit word in shared memory (here the zero a `cp.async`
/// zero-fill or a plain store leaves behind) can be overwritten and read
/// back one 16-bit half at a time: its halves are known bit patterns.
#[test]
fn test_concrete_scalar_granule_splits_for_half_width_access() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<4>;
    .reg .f32 %f<5>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<3>;
    .shared .align 4 .b8 sdata[4];

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r3, sdata;
    mov.u32 %r2, 0;
    st.shared.b32 [%r3], %r2;
    ld.global.f32 %f1, [%rd1];
    cvt.rn.f16.f32 %h1, %f1;
    st.shared.b16 [%r3+2], %h1;
    ld.shared.b16 %h2, [%r3+2];
    ld.shared.b16 %h3, [%r3];
    cvt.f32.f16 %f2, %h2;
    cvt.f32.f16 %f3, %h3;
    add.f32 %f4, %f2, %f3;
    st.global.f32 [%rd2], %f4;
    ret;
}
",
    );
    let out = analyze_kernel(&parse(&src), None, in_out_config(1, 1)).expect("split scalar");
    assert_eq!(display_output(&out, "out", 0), "in[0]");
}

/// `copysign.type d, a, b` (PTX ISA): `d = |b|` with `a`'s sign - opposite of
/// a naive operand reading. Pins all four sign combinations and the
/// `copysign.f32 %v0, %x0, %v0` reuse idiom.
#[test]
fn test_copysign_combines_the_sign_of_a_with_the_magnitude_of_b() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<9>;
    .reg .b64 %rd<2>;

    // d = copysign(sign_src=+2.0, magnitude_src=+3.0) = +3.0
    mov.f32 %f1, 0f40000000;
    mov.f32 %f2, 0f40400000;
    copysign.f32 %f3, %f1, %f2;

    // d = copysign(sign_src=-2.0, magnitude_src=+3.0) = -3.0
    mov.f32 %f4, 0fC0000000;
    mov.f32 %f5, 0f40400000;
    copysign.f32 %f6, %f4, %f5;

    // d = copysign(sign_src=+2.0, magnitude_src=-3.0) = +3.0
    mov.f32 %f7, 0f40000000;
    mov.f32 %f8, 0fC0400000;
    copysign.f32 %f8, %f7, %f8;
    add.f32 %f3, %f3, %f8;

    // d = copysign(sign_src=-2.0, magnitude_src=-3.0) = -3.0
    // (register self-reuse for dst, matching the real GELU idiom:
    // `copysign.f32 %v0, %x0, %v0`)
    mov.f32 %f4, 0fC0000000;
    mov.f32 %f7, 0fC0400000;
    copysign.f32 %f7, %f4, %f7;
    add.f32 %f6, %f6, %f7;

    add.f32 %f3, %f3, %f6;

    ld.param.u64 %rd1, [k_param_0];
    st.global.f32 [%rd1], %f3;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    // `abs`/`select` don't fold over constants (canon treats `Abs` as opaque),
    // so check via the f64 oracle: (+3) + (-3) + (+3) + (-3) = 0.
    let (_, elems) = output.outputs.iter().find(|(n, _)| n == "out").unwrap();
    let (_, expr) = elems.iter().find(|(i, _)| *i == 0).unwrap();
    let value = numeric::eval_f64(&output.arena, *expr, 0).expect("numeric eval");
    assert_eq!(value, 0.0);
}

/// `copysign.f16` parses (the type parser accepts any `ScalarType`), so
/// `lower_copysign`'s `.f32`/`.f64` restriction must reject it with a
/// specific reason.
#[test]
fn test_copysign_rejects_a_type_other_than_f32_f64() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b16 %h<3>;
    copysign.f16 %h0, %h1, %h2;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Lower(LowerError::UnsupportedInstruction { instruction, .. }) => {
            assert_eq!(instruction, "copysign");
        }
        other => panic!("expected UnsupportedInstruction, got: {}", other),
    }
}

/// The fp8-elementwise idiom: `ld.global.v2.b32` (a `Value::Quad`) ->
/// `mov.b32 {h,h}` -> `cvt.rn.f16x2.e4m3x2` is the identity over symbolic
/// reals: `x[0]`..`x[3]` stay distinct.
#[test]
fn test_e4m3x2_vector_load_keeps_four_symbolic_bytes_independent() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<4>;
    .reg .b16 %h<8>;
    .reg .f32 %f<4>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    ld.param.u64 %rd1, [k_param_1];

    ld.global.v2.b32 {%r0,%r1}, [%rd0];

    mov.b32 {%h0,%h1}, %r0;

    cvt.rn.f16x2.e4m3x2 %r2, %h0;
    cvt.rn.f16x2.e4m3x2 %r3, %h1;

    mov.b32 {%h4,%h5}, %r2;
    mov.b32 {%h6,%h7}, %r3;

    cvt.f32.f16 %f0, %h4;
    cvt.f32.f16 %f1, %h5;
    cvt.f32.f16 %f2, %h6;
    cvt.f32.f16 %f3, %h7;

    st.global.f32 [%rd1], %f0;
    st.global.f32 [%rd1+4], %f1;
    st.global.f32 [%rd1+8], %f2;
    st.global.f32 [%rd1+12], %f3;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 8,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 4,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
    assert_eq!(display_output(&output, "out", 1), "x[1]");
    assert_eq!(display_output(&output, "out", 2), "x[2]");
    assert_eq!(display_output(&output, "out", 3), "x[3]");
}

/// LLVM's NVPTX backend extracts a `Quad` register's low 16 bits via
/// `cvt.u16.u32` (`GELUFloat8Kernel`); like `truncates_pair`, this must keep
/// the low `Pair` of byte lanes.
#[test]
fn test_e4m3x2_low_half_extracted_via_cvt_u16_u32_truncation_of_a_quad() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b32 %r<3>;
    .reg .b16 %h<4>;
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    ld.param.u64 %rd1, [k_param_1];

    ld.global.b32 %r0, [%rd0];

    cvt.u16.u32 %h0, %r0;
    mov.b32 {_, %h1}, %r0;

    cvt.rn.f16x2.e4m3x2 %r1, %h0;
    cvt.rn.f16x2.e4m3x2 %r2, %h1;

    mov.b32 {%h2, _}, %r1;
    mov.b32 {%h3, _}, %r2;

    cvt.f32.f16 %f0, %h2;
    cvt.f32.f16 %f1, %h3;

    st.global.f32 [%rd1], %f0;
    st.global.f32 [%rd1+4], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 4,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
    assert_eq!(display_output(&output, "out", 1), "x[2]");
}

/// `ld.b16` of two fp8 elements yields a 2-byte `Value::Pair`; storing or
/// reloading it at that native width is not a half-extraction - only a
/// narrower store truncates.
#[test]
fn test_byte_pair_round_trips_through_shared_memory_at_native_16_bit_width() {
    let src = wrap(
        ".extern .shared .align 16 .b8 buf[];
.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .b16 %h<2>;
    .reg .b32 %r<2>;
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd0, [k_param_0];
    ld.param.u64 %rd1, [k_param_1];

    ld.global.b16 %h0, [%rd0];
    mov.u32 %r0, buf;
    st.shared.b16 [%r0], %h0;
    ld.shared.b16 %h1, [%r0];

    cvt.rn.f16x2.e4m3x2 %r1, %h1;
    mov.b32 {%h0, %h1}, %r1;
    cvt.f32.f16 %f0, %h0;
    cvt.f32.f16 %f1, %h1;

    st.global.f32 [%rd1], %f0;
    st.global.f32 [%rd1+4], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.dynamic_shared_bytes = 16;
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 2,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
    assert_eq!(display_output(&output, "out", 1), "x[1]");
}

/// A concrete 16-bit source (e.g. `mov.u16`) gets a real `.e4m3` bit decode:
/// `0xB838` packs -1.0 high and +1.0 low (PTX ISA 9.7.9.22: low byte of `a`
/// -> low half of `d`).
#[test]
fn test_e4m3x2_decodes_a_concrete_scalar_bit_pattern() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b16 %h<4>;
    .reg .b32 %r0;
    .reg .f32 %f<2>;
    .reg .b64 %rd0;

    mov.u16 %h0, 47160; // 0xB838
    cvt.rn.f16x2.e4m3x2 %r0, %h0;
    mov.b32 {%h2,%h3}, %r0;
    cvt.f32.f16 %f0, %h2;
    cvt.f32.f16 %f1, %h3;

    ld.param.u64 %rd0, [k_param_0];
    st.global.f32 [%rd0], %f0;
    st.global.f32 [%rd0+4], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    let (_, elems) = output.outputs.iter().find(|(n, _)| n == "out").unwrap();
    let get = |i: u64| {
        let (_, e) = elems.iter().find(|(idx, _)| *idx == i).unwrap();
        numeric::eval_f64(&output.arena, *e, 0).expect("numeric eval")
    };
    assert_eq!(get(0), 1.0);
    assert_eq!(get(1), -1.0);
}

/// Same concrete `0xB838` pattern as above, but with `.relu`: the
/// already-positive lower byte (+1.0) is untouched, the negative upper
/// byte (-1.0) clamps to 0.
#[test]
fn test_e4m3x2_relu_clamps_a_negative_decoded_lane_to_zero() {
    let src = wrap(
        ".visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .b16 %h<4>;
    .reg .b32 %r0;
    .reg .f32 %f<2>;
    .reg .b64 %rd0;

    mov.u16 %h0, 47160; // 0xB838
    cvt.rn.relu.f16x2.e4m3x2 %r0, %h0;
    mov.b32 {%h2,%h3}, %r0;
    cvt.f32.f16 %f0, %h2;
    cvt.f32.f16 %f1, %h3;

    ld.param.u64 %rd0, [k_param_0];
    st.global.f32 [%rd0], %f0;
    st.global.f32 [%rd0+4], %f1;
    ret;
}
",
    );
    let module = parse(&src);
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    let (_, elems) = output.outputs.iter().find(|(n, _)| n == "out").unwrap();
    let get = |i: u64| {
        let (_, e) = elems.iter().find(|(idx, _)| *idx == i).unwrap();
        numeric::eval_f64(&output.arena, *e, 0).expect("numeric eval")
    };
    assert_eq!(get(0), 1.0);
    assert_eq!(get(1), 0.0);
}

/// `0x7F` is `.e4m3`'s NaN (PTX ISA 5.2.3); Volta's real-valued model cannot
/// represent NaN, so a concrete byte hitting it must error loudly.
#[test]
fn test_e4m3x2_rejects_the_concrete_nan_byte_pattern() {
    let src = wrap(
        ".visible .entry k()
{
    .reg .b16 %h0;
    .reg .b32 %r0;

    mov.u16 %h0, 32512; // 0x7F00: upper byte 0x7F = NaN, lower byte 0x00 = 0.0
    cvt.rn.f16x2.e4m3x2 %r0, %h0;
    ret;
}
",
    );
    let module = parse(&src);
    let err = analyze_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(what.contains("NaN"), "unexpected message: {}", what);
        }
        other => panic!("expected Unsupported (NaN byte), got: {}", other),
    }
}
