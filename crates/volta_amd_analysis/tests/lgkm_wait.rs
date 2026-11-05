//! LGKM's all-ones field supplies no completion evidence, regardless of issue-history length.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisResult, ArrayDef, ArrayKind, EvalError, OutputType, Sgpr, Terminal, Vgpr,
    WorkgroupLaunch, analyze,
};
use volta_expr::ExprNode;
use volta_graph::GenerationKind;

fn run(body: &str) -> AnalysisResult {
    let source = format!(
        r#".amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
.text
k:
s_load_dwordx4 s[4:7], s[0:1], 0
s_waitcnt lgkmcnt(0)
v_lshlrev_b32_e32 v2, 2, v0
global_load_dword v1, v2, s[4:5]
s_waitcnt vmcnt(0)
{body}
s_endpgm
.section .rodata
.amdhsa_kernel k
.amdhsa_group_segment_fixed_size 256
.amdhsa_user_sgpr_count 2
.amdhsa_user_sgpr_kernarg_segment_ptr 1
.amdhsa_system_sgpr_workgroup_id_x 0
.amdhsa_system_sgpr_workgroup_id_y 0
.amdhsa_system_sgpr_workgroup_id_z 0
.amdhsa_system_vgpr_workitem_id 0
.end_amdhsa_kernel
"#
    );
    let parsed = parse_kernel(&source, "k").unwrap();
    let arrays = [
        ArrayDef {
            name: "input".into(),
            base: 0x10000,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".into(),
            base: 0x20000,
            len: 64,
            kind: ArrayKind::Output(OutputType::F32),
        },
    ];
    let kernarg: Vec<_> = arrays
        .iter()
        .flat_map(|array| array.base.to_le_bytes())
        .collect();
    analyze(
        &parsed,
        &WorkgroupLaunch {
            kernarg_address: 0x1000,
            workgroup_size: (64, 1, 1),
        },
        &kernarg,
        &arrays,
    )
    .unwrap()
}

fn assert_copy(result: &AnalysisResult) {
    assert_eq!(result.terminal, Terminal::Completed);
    let outputs = result.symbolic_outputs.as_ref().unwrap();
    assert_eq!(outputs.outputs.len(), 1);
    assert_eq!(outputs.outputs[0].0, "out");
    assert_eq!(outputs.outputs[0].1.len(), 64);
    for i in 0..64 {
        let value = outputs.element("out", i).unwrap();
        assert!(matches!(
            outputs.arena.node(value),
            ExprNode::InputElement { array, index }
                if outputs.arena.string(*array) == "input" && *index == i
        ));
    }
}

fn assert_aborted(result: &AnalysisResult, expected: EvalError) {
    assert!(matches!(&result.terminal, Terminal::Aborted { error, .. } if *error == expected));
    assert!(result.symbolic_outputs.is_none());
}

fn assert_no_maximal_wait_generation(result: &AnalysisResult) {
    assert!(result.graph.generations().values().all(|generation| {
        generation.kind != GenerationKind::AsyncGroupWait { keep_pending: 15 }
    }));
}

#[test]
fn maximal_lgkm_keeps_a_ds_read_pending_on_both_sides_of_the_field_limit() {
    // The read plus the later writes leave 1, 14, 15, 16 or 17 DS instructions in flight.
    for writes in [0, 13, 14, 15, 16] {
        let body = format!(
            "ds_write_b32 v2, v1\ns_waitcnt lgkmcnt(0)\nds_read_b32 v4, v2\n{}s_waitcnt lgkmcnt(15)\nglobal_store_dword v2, v4, s[6:7]",
            "ds_write_b32 v2, v1\n".repeat(writes)
        );
        let pending = run(&body);
        assert_aborted(
            &pending,
            EvalError::PendingVgpr {
                lane: 0,
                reg: Vgpr(4),
            },
        );
        assert_no_maximal_wait_generation(&pending);
        // Only the initialization write completed. No later DS instruction acquired evidence.
        assert!(
            pending
                .graph
                .async_ops()
                .values()
                .skip(1)
                .all(|op| op.tracking.is_empty())
        );

        let drained = run(&body.replace("lgkmcnt(15)", "lgkmcnt(0)"));
        assert_copy(&drained);
    }
}

#[test]
fn maximal_lgkm_does_not_release_a_lane_exchange() {
    let body = format!(
        "ds_bpermute_b32 v4, v2, v1\n{}s_waitcnt lgkmcnt(15)\nglobal_store_dword v2, v4, s[6:7]",
        "ds_write_b32 v2, v1\n".repeat(16)
    );
    let pending = run(&body);
    assert_aborted(
        &pending,
        EvalError::PendingVgpr {
            lane: 0,
            reg: Vgpr(4),
        },
    );
    assert_no_maximal_wait_generation(&pending);
    assert!(
        pending
            .graph
            .async_ops()
            .values()
            .all(|op| op.tracking.is_empty())
    );
    assert_copy(&run(&body.replace("lgkmcnt(15)", "lgkmcnt(0)")));
}

#[test]
fn endpgm_completes_ds_writes_that_the_maximal_field_left_pending() {
    for writes in [1, 15, 17] {
        let body = format!(
            "{}s_waitcnt lgkmcnt(15)\nglobal_store_dword v2, v1, s[6:7]",
            "ds_write_b32 v2, v1\n".repeat(writes)
        );
        let result = run(&body);
        assert_copy(&result);
        assert_eq!(result.graph.async_ops().len(), writes);
        // These writes only complete at END's implicit zero wait, never at the maximal field.
        assert_no_maximal_wait_generation(&result);
        assert_eq!(result.graph.generations().len(), 1);
        for op in result.graph.async_ops().values() {
            assert!(op.completion.is_some());
            assert_eq!(op.tracking.len(), 1);
            assert_eq!(
                result.graph.generation(op.tracking[0]).kind,
                GenerationKind::AsyncGroupWait { keep_pending: 0 }
            );
        }
    }
}

#[test]
fn an_actual_partial_lgkm_wait_still_releases_the_older_ds_read() {
    let body = "ds_write_b32 v2, v1\ns_waitcnt lgkmcnt(0)\nds_read_b32 v4, v2\nds_write_b32 v2, v1\ns_waitcnt lgkmcnt(1)\nglobal_store_dword v2, v4, s[6:7]";
    let result = run(body);
    assert_copy(&result);
    assert!(result.graph.generations().values().any(|generation| {
        generation.kind == GenerationKind::AsyncGroupWait { keep_pending: 1 }
    }));
}

#[test]
fn scalar_loads_remain_pending_across_maximal_lgkm_without_rejecting_the_noop() {
    for consumer in ["s_mov_b32 s10, s8", "s_mov_b32 s8, 0"] {
        let body = format!("s_load_dword s8, s[0:1], 0\ns_waitcnt lgkmcnt(15)\n{consumer}");
        let pending = run(&body);
        assert_aborted(&pending, EvalError::PendingSgpr(Sgpr(8)));
        assert_no_maximal_wait_generation(&pending);

        let drained = format!(
            "{}\nglobal_store_dword v2, v1, s[6:7]",
            body.replace("lgkmcnt(15)", "lgkmcnt(15)\ns_waitcnt lgkmcnt(0)")
        );
        assert_copy(&run(&drained));
    }
}

#[test]
fn scalar_loads_still_reject_actual_partial_lgkm_waits() {
    for outstanding in [1, 14] {
        let body = format!(
            "s_load_dword s8, s[0:1], 0\nds_write_b32 v2, v1\ns_waitcnt lgkmcnt({outstanding})\nglobal_store_dword v2, v1, s[6:7]"
        );
        assert_aborted(&run(&body), EvalError::UnsupportedInstruction);
        assert_copy(&run(
            &body.replace(&format!("lgkmcnt({outstanding})"), "lgkmcnt(0)")
        ));
    }
}

#[test]
fn maximal_lgkm_accepts_a_long_mixed_queue_without_retiring_it() {
    let body = format!(
        "s_load_dword s8, s[0:1], 0\n{}s_waitcnt lgkmcnt(15)\ns_waitcnt lgkmcnt(0)\ns_mov_b32 s10, s8\nglobal_store_dword v2, v1, s[6:7]",
        "ds_write_b32 v2, v1\n".repeat(16)
    );
    let result = run(&body);
    assert_copy(&result);
    assert_no_maximal_wait_generation(&result);
}

#[test]
fn a_combined_wait_completes_vm_loads_while_maximal_lgkm_is_a_noop() {
    let body = format!(
        "ds_bpermute_b32 v4, v2, v1\n{}global_load_dword v5, v2, s[4:5]\ns_waitcnt vmcnt(0) lgkmcnt(15)\nglobal_store_dword v2, v5, s[6:7]",
        "ds_write_b32 v2, v1\n".repeat(16)
    );
    let result = run(&body);
    assert_copy(&result);
    assert_no_maximal_wait_generation(&result);
}

/// Distinct destinations keep every issue live without reusing a pending register.
fn vm_loads(count: u8) -> String {
    (16..16 + count)
        .map(|reg| format!("global_load_dword v{reg}, v2, s[4:5]\n"))
        .collect()
}

#[test]
fn vm_wait_maximal_field_keeps_loads_pending_across_the_field_limit() {
    for count in [1, 62, 63, 64, 65] {
        let body = format!(
            "{}s_waitcnt vmcnt(63)\nglobal_store_dword v2, v16, s[6:7]",
            vm_loads(count)
        );
        assert_aborted(
            &run(&body),
            EvalError::PendingVgpr {
                lane: 0,
                reg: Vgpr(16),
            },
        );
        assert_copy(&run(&body.replace("vmcnt(63)", "vmcnt(0)")));
    }
}

#[test]
fn vm_wait_maximal_field_does_not_allow_overwriting_a_pending_destination() {
    let body = format!(
        "{}s_waitcnt vmcnt(63)\nv_mov_b32_e32 v16, 0\nglobal_store_dword v2, v1, s[6:7]",
        vm_loads(65)
    );
    assert_aborted(
        &run(&body),
        EvalError::PendingVgpr {
            lane: 0,
            reg: Vgpr(16),
        },
    );
    assert_copy(&run(&body.replace("vmcnt(63)", "vmcnt(0)")));
}

#[test]
fn vm_wait_actual_partial_fields_release_only_the_guaranteed_prefix() {
    for (count, outstanding, ready, pending) in [(2, 1, 16, 17), (65, 62, 18, 19)] {
        let prefix = format!("{}s_waitcnt vmcnt({outstanding})\n", vm_loads(count));
        let completed = format!("{prefix}global_store_dword v2, v{ready}, s[6:7]");
        assert_copy(&run(&completed));
        let incomplete = format!("{prefix}global_store_dword v2, v{pending}, s[6:7]");
        assert_aborted(
            &run(&incomplete),
            EvalError::PendingVgpr {
                lane: 0,
                reg: Vgpr(pending),
            },
        );
        assert_copy(&run(
            &incomplete.replace(&format!("vmcnt({outstanding})"), "vmcnt(0)")
        ));
    }
}

#[test]
fn vm_wait_maximal_field_keeps_vm_pending_while_combined_lgkm_zero_completes_ds() {
    let prefix = format!(
        "ds_write_b32 v2, v1\ns_waitcnt lgkmcnt(0)\nds_read_b32 v4, v2\n{}s_waitcnt vmcnt(63) lgkmcnt(0)\n",
        vm_loads(65)
    );
    assert_copy(&run(&format!("{prefix}global_store_dword v2, v4, s[6:7]")));
    let incomplete = format!("{prefix}global_store_dword v2, v16, s[6:7]");
    assert_aborted(
        &run(&incomplete),
        EvalError::PendingVgpr {
            lane: 0,
            reg: Vgpr(16),
        },
    );
    assert_copy(&run(&incomplete.replace("vmcnt(63)", "vmcnt(0)")));
}
