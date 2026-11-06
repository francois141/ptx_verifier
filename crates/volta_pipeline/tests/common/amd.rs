//! AMD kernels of `volta_amd_analysis/tests/fixtures/` through the analysis stage and the graph
//! branch, recorded for the graph viewer like the PTX runs.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisResult, ArrayDef, ArrayKind, OutputType, WorkgroupLaunch, analyze,
};
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

pub const GEMM_A_BASE: u64 = 0x10000;
pub const GEMM_B_BASE: u64 = 0x20000;
pub const GEMM_C_BASE: u64 = 0x30000;

/// A, B and C at the test addresses, sized for an M x K by K x N matrix product.
pub fn gemm_arrays([m, n, k]: [u64; 3]) -> [ArrayDef; 3] {
    [
        ("A", GEMM_A_BASE, m * k, ArrayKind::Input),
        ("B", GEMM_B_BASE, k * n, ArrayKind::Input),
        ("C", GEMM_C_BASE, m * n, ArrayKind::Output(OutputType::F32)),
    ]
    .map(|(name, base, len, kind)| ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    })
}

/// The shared GEMM instance, with the mangled main-loop flag selecting its specialization.
macro_rules! ck_gemm_kernel {
    ($main_loop:literal) => {
        concat!(
            "_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4",
            "gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThrough",
            "ES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4",
            "ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2",
            "ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_",
            "24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEE",
            $main_loop,
            "ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_",
            "10TailNumberE10EEEvNT_8ArgumentE",
        )
    };
}

/// Two waves accumulating a 64 x 64 tile, without a K-block main loop.
pub const CK_GEMM_KERNEL: &str = ck_gemm_kernel!("Lb0");
/// The same instance with its K-block main loop enabled.
pub const CK_GEMM_MAIN_LOOP_KERNEL: &str = ck_gemm_kernel!("Lb1");

/// The kernel's `GridwiseGemm::Argument` for dimensions [M, N, K], as CK's host constructor
/// lays it out: a vtable pointer and a workspace pointer, the `Problem`'s fifteen `index_t`s
/// padded to the 64 x 64 x 64 block tile, the three empty element ops, then the pointers.
pub fn ck_gemm_kernarg(a: u64, b: u64, c: u64, dims: [i32; 3]) -> Vec<u8> {
    let [m, n, k] = dims;
    let [mpadded, npadded, kpadded] = dims.map(|d| (d + 63) / 64 * 64);
    let kread = (k + 3) / 4 * 4;
    let problem: [i32; 15] = [
        // M, N, K.
        m,
        n,
        k,
        // StrideA (row-major), StrideB (column-major), StrideC (row-major).
        k,
        k,
        n,
        1, // KBatch
        mpadded,
        npadded,
        kread,
        kpadded,
        // AK0 and BK0 divide KPadded by K1.
        kpadded / 4,
        kpadded / 4,
        // MBlock and NBlock.
        mpadded / 64,
        npadded / 64,
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
