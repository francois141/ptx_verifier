//! One run over every workgroup of a launch grid, checked against verified runs of each
//! workgroup alone: the same output elements with equivalent values, no element stored twice,
//! and an event graph whose LDS accesses verify for every workgroup.

use crate::common;

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    ArrayDef, ArrayKind, EvalError, OutputType, Terminal, WorkgroupLaunch, analyze_grid,
};
use volta_equivalence::check::EquivCheckOptions;
use volta_graph_check::{GraphConclusion, check_graph};
use volta_pipeline::{EquivalenceVerdict, check_equivalence};

use common::amd::{
    CK_FMHA_KERNEL, CK_GEMM_MAIN_LOOP_KERNEL, FMHA_K_BASE, FMHA_Q_BASE, check_amd_launch,
    ck_fixture, ck_fmha_kernarg, ck_gemm_kernarg, fmha_arrays,
};

/// A one-dimensional grid of `grid` workgroups of `workitems` work-items, selecting `workgroup`.
fn launch(grid: u32, workgroup: u32, workitems: u32) -> WorkgroupLaunch {
    WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (workitems, 1, 1),
        workgroup_id: (workgroup, 0, 0),
        grid_size: (grid, 1, 1),
    }
}

/// CK GEMM's arguments and arrays for dimensions [M, N, K], with A, B and C 256 KiB apart so
/// every grid here fits, and its one-dimensional grid of 64 x 64 tiles.
fn ck_gemm_launch(dims: [i32; 3]) -> (Vec<u8>, [ArrayDef; 3], u32) {
    let [m, n, k] = dims.map(|d| d as u64);
    let arrays = [
        ("A", 0x10000, m * k, ArrayKind::Input),
        ("B", 0x50000, k * n, ArrayKind::Input),
        ("C", 0x90000, m * n, ArrayKind::Output(OutputType::F32)),
    ]
    .map(|(name, base, len, kind)| ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    });
    let tiles = dims.map(|d| (d as u32).div_ceil(64));
    let kernarg = ck_gemm_kernarg(0x10000, 0x50000, 0x90000, dims);
    (kernarg, arrays, tiles[0] * tiles[1])
}

// Test that one run over CK GEMM's three M tiles gives each tile the output elements and values
// of a run of that tile alone, including the last tile's 32 rows, with no element stored twice
// and LDS accesses that verify.
#[test]
fn ck_gemm_grid_run_matches_each_tile_run() {
    let (kernarg, arrays, tiles) = ck_gemm_launch([160, 40, 192]);
    let source = ck_fixture!("ck_gemm");
    let kernel = parse_kernel(source, CK_GEMM_MAIN_LOOP_KERNEL).unwrap();
    let grid = analyze_grid(&kernel, &launch(tiles, 0, 128), &kernarg, &arrays).unwrap();
    assert_eq!(grid.terminal, Terminal::Completed);
    assert!(grid.conflicts.is_empty(), "{:?}", grid.conflicts);
    assert_eq!(
        check_graph(&grid.graph).conclusion(),
        GraphConclusion::Verified
    );

    // Compare each tile with a verified run that selects it: equal footprints and equivalent
    // values.
    let mut written = Vec::new();
    for (index, (id, outputs)) in grid.workgroups.iter().enumerate() {
        let expected = check_amd_launch(
            "ck_gemm.s",
            source,
            CK_GEMM_MAIN_LOOP_KERNEL,
            &launch(tiles, index as u32, 128),
            &kernarg,
            &arrays,
        )
        .verified_outputs();
        let verdict = check_equivalence(
            &expected,
            outputs,
            &["C".into()],
            &EquivCheckOptions::default(),
        )
        .0;
        assert!(
            matches!(verdict, EquivalenceVerdict::Equivalent { checked, total } if checked == total),
            "tile {id:?}: {verdict:?}"
        );
        written.push(outputs.outputs[0].1.len());
    }
    assert_eq!(written, [2560, 2560, 1280]);
}

// Test that CK GEMM's tile map, which branches on the workgroup index once the grid has several
// tiles in both M and N, stops a run over a 3 x 3 tile grid at that branch.
#[test]
fn ck_gemm_tile_map_branch_depends_on_the_workgroup() {
    let (kernarg, arrays, tiles) = ck_gemm_launch([144, 144, 192]);
    let kernel = parse_kernel(ck_fixture!("ck_gemm"), CK_GEMM_MAIN_LOOP_KERNEL).unwrap();
    let grid = analyze_grid(&kernel, &launch(tiles, 0, 128), &kernarg, &arrays).unwrap();
    assert!(
        matches!(
            grid.terminal,
            Terminal::Aborted {
                error: EvalError::DependsOnWorkgroup,
                ..
            }
        ),
        "{:?}",
        grid.terminal
    );
    assert!(grid.workgroups.is_empty());
}

// Test that one run over two attention heads gives each head the outputs of a run of that head
// alone, comparing 64 outputs per head, with no element stored twice and verified LDS accesses.
#[test]
fn ck_fmha_grid_run_matches_each_head_run() {
    let kernarg = ck_fmha_kernarg(FMHA_Q_BASE, FMHA_K_BASE, 2);
    let arrays = fmha_arrays(2 * 4096);
    let source = ck_fixture!("ck_fmha");
    let kernel = parse_kernel(source, CK_FMHA_KERNEL).unwrap();
    let grid = analyze_grid(&kernel, &launch(2, 0, 256), &kernarg, &arrays).unwrap();
    assert_eq!(grid.terminal, Terminal::Completed);
    assert!(grid.conflicts.is_empty(), "{:?}", grid.conflicts);
    assert_eq!(
        check_graph(&grid.graph).conclusion(),
        GraphConclusion::Verified
    );
    assert_eq!(grid.workgroups.len(), 2);

    for (index, (id, outputs)) in grid.workgroups.iter().enumerate() {
        let expected = check_amd_launch(
            "ck_fmha.s",
            source,
            CK_FMHA_KERNEL,
            &launch(2, index as u32, 256),
            &kernarg,
            &arrays,
        )
        .verified_outputs();
        let options = EquivCheckOptions {
            sample: 64,
            ..EquivCheckOptions::default()
        };
        let verdict = check_equivalence(&expected, outputs, &["O".into()], &options).0;
        assert!(
            matches!(verdict, EquivalenceVerdict::Equivalent { .. }),
            "head {id:?}: {verdict:?}"
        );
    }
}
