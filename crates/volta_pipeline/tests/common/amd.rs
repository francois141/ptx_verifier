//! AMD kernels of `volta_amd_analysis/tests/fixtures/` through the analysis stage and the graph
//! branch, recorded for the graph viewer like the PTX runs.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisResult, ArrayDef, ArrayKind, OutputType, WorkgroupLaunch, analyze,
};
use volta_expr::SymbolicOutputs;
use volta_graph_check::{GraphConclusion, GraphReport, check_graph};
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

impl AmdChecked {
    /// The run's outputs, which a test may compare only once the graph check concluded
    /// `Verified` (so the run completed), the rule every PTX kernel's outputs meet too.
    pub fn verified_outputs(self) -> SymbolicOutputs {
        let conclusion = self.report.conclusion();
        assert_eq!(
            conclusion,
            GraphConclusion::Verified,
            "the graph check did not verify the kernel"
        );
        self.analysis
            .symbolic_outputs
            .expect("a verified run completed, so its outputs read back")
    }
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
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (workitems, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (1, 1, 1),
    };
    check_amd_launch(file, source, kernel, &launch, kernarg, arrays)
}

/// `check_amd` for the workgroup `launch` selects.
pub fn check_amd_launch(
    file: &str,
    source: &str,
    kernel: &str,
    launch: &WorkgroupLaunch,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> AmdChecked {
    let parsed = parse_kernel(source, kernel).unwrap_or_else(|e| panic!("{file}: {e}"));
    let analysis = analyze(&parsed, launch, kernarg, arrays)
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

/// The `kentry` of the CK attention instance `ck_fmha.hip` compiles: four waves over a 64 x 64
/// query/key tile.
pub const CK_FMHA_KERNEL: &str = concat!(
    "_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_2",
    "4BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi6",
    "4ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17Compose",
    "dAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsIL",
    "b0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantS",
    "caleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEEL",
    "b0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21Fm",
    "haFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT",
    "2_",
);
pub const FMHA_Q_BASE: u64 = 0x10000;
pub const FMHA_K_BASE: u64 = 0x20000;
pub const FMHA_V_BASE: u64 = 0x30000;
pub const FMHA_O_BASE: u64 = 0x40000;

/// Q, K, V and O at the test addresses, each holding `len` words of contiguous heads.
pub fn fmha_arrays(len: u64) -> [ArrayDef; 4] {
    [
        ("Q", FMHA_Q_BASE, ArrayKind::Input),
        ("K", FMHA_K_BASE, ArrayKind::Input),
        ("V", FMHA_V_BASE, ArrayKind::Input),
        ("O", FMHA_O_BASE, ArrayKind::Output(OutputType::F32)),
    ]
    .map(|(name, base, kind)| ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    })
}

/// CK's arguments for contiguous [batch, head, sequence, dimension] tensors, 64 x 64 per head.
pub fn ck_fmha_kernarg(q: u64, k: u64, heads: i32) -> Vec<u8> {
    let mut bytes = Vec::new();
    // The tensors, then a null sink pointer, which disables the optional sink.
    for pointer in [q, k, FMHA_V_BASE, FMHA_O_BASE, 0] {
        bytes.extend(pointer.to_le_bytes());
    }
    // seqlen_q, seqlen_k, hdim_q, hdim_v, num_head_q and nhead_ratio_qk.
    for field in [64_i32, 64, 64, 64, heads, 1] {
        bytes.extend(field.to_le_bytes());
    }
    // The fast-exp2 build takes the host's scale times log2(e), here for the formula's 1 / 8.
    bytes.extend((std::f32::consts::LOG2_E / 8.0).to_le_bytes());
    // Row and head strides of Q, K, V and O, then num_head_q_total and head_start.
    for field in [64_i32, 64, 64, 64, 4096, 4096, 4096, 4096, 0, 0] {
        bytes.extend(field.to_le_bytes());
    }
    // Each batch contains all heads, with strides measured in elements.
    for _ in 0..4 {
        bytes.extend((heads * 4096).to_le_bytes());
    }
    // Padding, then null cumulative sequence length pointers.
    bytes.resize(144, 0);
    bytes
}
