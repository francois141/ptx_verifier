//! AMD kernels of `volta_amd_analysis/tests/fixtures/` through the analysis stage and the graph
//! branch, recorded for the graph viewer like the PTX runs.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{AnalysisResult, ArrayDef, WorkgroupLaunch, analyze};
use volta_graph_check::{GraphReport, check_graph};
use volta_viz::Outcome;

use super::record_run;

/// The source text of `volta_amd_analysis`'s fixture `tests/fixtures/<name>.s`.
#[allow(unused_macros)]
macro_rules! amd_fixture {
    ($name:literal) => {
        include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/../volta_amd_analysis/tests/fixtures/",
            $name,
            ".s"
        ))
    };
}
#[allow(unused_imports)]
pub(crate) use amd_fixture;

/// One AMD kernel through the analysis stage and the graph branch.
pub struct AmdChecked {
    pub analysis: AnalysisResult,
    pub report: GraphReport,
}

/// Run `kernel` of `source` (the fixture `file`) on a workgroup of `workitems` work-items along
/// X, with `kernarg` as its argument buffer, then check its graph; panics if the run cannot
/// start.
pub fn check_amd(
    file: &str,
    source: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> AmdChecked {
    let parsed = parse_kernel(source, kernel).unwrap_or_else(|e| panic!("{file}: {e}"));
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (workitems, 1, 1),
    };
    let analysis = analyze(&parsed, &launch, kernarg, arrays)
        .unwrap_or_else(|e| panic!("{file}: analysis cannot start: {e}"));
    let report = check_graph(&analysis.graph);
    let outcome = Outcome::Executed {
        graph: &analysis.graph,
        arena: analysis.arena(),
        report: Some(&report),
    };
    record_run(Some(file), source, outcome);
    AmdChecked { analysis, report }
}

/// The `ck::kernel_gemm_xdl_cshuffle_v3` instance `ck_gemm.hip` compiles: two waves, each
/// accumulating a 32 x 64 slice of a 64 x 64 tile with `v_mfma_f32_16x16x4_f32`.
pub const CK_GEMM_KERNEL: &str = concat!(
    "_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4",
    "gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThrough",
    "ES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4",
    "ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2",
    "ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_",
    "24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_",
    "10TailNumberE10EEEvNT_8ArgumentE",
);

/// The kernel's `GridwiseGemm::Argument` for an 8 x 8 x 8 problem, as CK's host constructor
/// lays it out: a vtable pointer and a workspace pointer, the `Problem`'s fifteen `index_t`s
/// padded to the 64 x 64 x 64 block tile, the three empty element ops, then the pointers.
pub fn ck_gemm_kernarg(a: u64, b: u64, c: u64) -> Vec<u8> {
    let (m, n, k) = (8, 8, 8);
    let problem: [i32; 15] = [
        m, n, k, // M, N, K
        k, k, n, // StrideA (row-major A), StrideB (column-major B), StrideC (row-major C)
        1, // KBatch
        64, 64, // MPadded, NPadded
        8,  // KRead
        64, // KPadded
        16, 16, // AK0, BK0: KPadded / K1
        1, 1, // MBlock, NBlock
    ];
    let mut bytes = vec![0u8; 16];
    bytes.extend(problem.iter().flat_map(|field| field.to_le_bytes()));
    bytes.resize(80, 0);
    for pointer in [a, b, c] {
        bytes.extend(pointer.to_le_bytes());
    }
    bytes.resize(112, 0); // is_reduce = false, then padding.
    bytes
}
