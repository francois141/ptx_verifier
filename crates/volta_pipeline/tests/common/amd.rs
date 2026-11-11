//! AMD test helpers require a verified graph before returning outputs for snapshots, specs or
//! Lean export. Snapshot files contain one `array[index] = expr` line; `VOLTA_BLESS=1` rewrites
//! them. `check_amd` also records runs for the graph viewer.

use std::fmt::Write as _;
use std::io::{IsTerminal, Write};
use std::path::{Path, PathBuf};

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisError, AnalysisResult, ArrayDef, ArrayKind, OutputType, Terminal, WorkgroupLaunch,
    analyze,
};
use volta_expr::SymbolicOutputs;
use volta_graph_check::{GraphConclusion, GraphReport, check_graph};
use volta_viz::Outcome;

use super::record_run;

/// The source text of the AMD test kernel `tests/amd/<name>.s`.
#[allow(unused_macros)]
macro_rules! amd_fixture {
    ($name:literal) => {
        include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/tests/amd/",
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
        kernarg_address: KERNARG_ADDRESS,
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

const KERNARG_ADDRESS: u64 = 0x1000;
pub const WORKITEMS: u32 = 64;

/// An array of one word per work-item of `check_run`'s wave.
pub fn array(name: &str, base: u64, kind: ArrayKind) -> ArrayDef {
    array_of(name, base, u64::from(WORKITEMS), kind)
}

/// An array of `len` words.
pub fn array_of(name: &str, base: u64, len: u64, kind: ArrayKind) -> ArrayDef {
    ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    }
}

/// Run the kernel `tests/amd/<name>.s` is named after (its file stem) on one wave, with `arrays` in global memory
/// and their bases as the kernel's pointer arguments, in order. Once its graph verifies, compare
/// its outputs with `<name>.out`.
pub fn check_run(name: &str, arrays: &[ArrayDef]) {
    check_run_on(name, WORKITEMS, arrays);
}

/// `check_run` on a workgroup of `workitems` work-items along X.
pub fn check_run_on(name: &str, workitems: u32, arrays: &[ArrayDef]) {
    check_run_kernel(name, kernel_of(name), workitems, &kernarg(arrays), arrays);
}

/// The symbolic outputs `check_run` compares, of fixture `name`'s kernel on one wave, once its
/// graph verifies.
pub fn outputs(name: &str, arrays: &[ArrayDef]) -> Result<SymbolicOutputs, String> {
    run_outputs(name, kernel_of(name), WORKITEMS, &kernarg(arrays), arrays)
}

/// The kernel a fixture is named after: the last component of `success/copy`.
fn kernel_of(fixture: &str) -> &str {
    fixture.rsplit('/').next().unwrap_or(fixture)
}

fn kernarg(arrays: &[ArrayDef]) -> Vec<u8> {
    arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect()
}

/// Run kernel `kernel` of `tests/amd/<fixture>.s` on a workgroup of `workitems` work-items
/// along X, with `kernarg` as its argument buffer. Once its graph verifies, compare its outputs
/// with `<fixture>.out`.
pub fn check_run_kernel(
    fixture: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) {
    let result = run(fixture, kernel, workitems, kernarg, arrays);
    report(fixture, result.is_ok());
    if let Err(error) = result {
        panic!("{fixture}: {error}");
    }
}

/// Require a fixture kernel to fail in the specified way, using one wave and array pointers.
pub fn check_rejected_kernel(
    fixture: &str,
    kernel: &str,
    arrays: &[ArrayDef],
    expected: impl FnOnce(&Result<AnalysisResult, AnalysisError>) -> bool,
) {
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/amd")
        .join(format!("{fixture}.s"));
    let source = std::fs::read_to_string(path).unwrap();
    let parsed = parse_kernel(&source, kernel).unwrap();
    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    let launch = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: (WORKITEMS, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (1, 1, 1),
    };
    let result = analyze(&parsed, &launch, &kernarg, arrays);
    let passed = expected(&result);
    report(&format!("{kernel} (rejected)"), passed);
    assert!(passed, "{kernel}: unexpected outcome: {result:?}");
}

/// Written to stderr directly, past the test harness's output capture.
fn report(name: &str, passed: bool) {
    let (verdict, color) = if passed {
        ("PASS", "32")
    } else {
        ("FAIL", "31")
    };
    let mut stderr = std::io::stderr();
    let line = if stderr.is_terminal() {
        format!("\x1b[{color}m{verdict}\x1b[0m {name}\n")
    } else {
        format!("{verdict} {name}\n")
    };
    stderr.write_all(line.as_bytes()).unwrap();
}

/// `tests/amd/<name>`, without an extension.
pub fn fixture(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/amd")
        .join(name)
}

fn run(
    name: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<(), String> {
    let outputs = run_outputs(name, kernel, workitems, kernarg, arrays)?;
    let mut actual = String::new();
    for (array, elements) in &outputs.outputs {
        for &(index, value) in elements {
            let expr = outputs.arena.display_expr(value);
            writeln!(actual, "{array}[{index}] = {expr}").unwrap();
        }
    }
    expect_file(&fixture(name).with_extension("out"), &actual)
}

fn run_outputs(
    name: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<SymbolicOutputs, String> {
    let source =
        std::fs::read_to_string(fixture(name).with_extension("s")).map_err(|e| e.to_string())?;
    let kernel = parse_kernel(&source, kernel).map_err(|e| e.to_string())?;

    let launch = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: (workitems, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (1, 1, 1),
    };
    let result = analyze(&kernel, &launch, kernarg, arrays).map_err(|e| e.to_string())?;

    if let Terminal::Aborted { wave, pc, error } = &result.terminal {
        return Err(format!(
            "wave {} aborted at instruction {} ({}): {error}",
            wave.0, pc.0, kernel.instructions[pc.0 as usize].opcode
        ));
    }
    // Reject unverified runs before their outputs can be compared or blessed.
    let conclusion = check_graph(&result.graph).conclusion();
    if conclusion != GraphConclusion::Verified {
        return Err(format!(
            "the graph check did not verify the kernel: {conclusion:?}"
        ));
    }
    result.symbolic_outputs.ok_or("no symbolic outputs".into())
}

/// Compare `actual` with the file at `path`, or rewrite the file under `VOLTA_BLESS=1`.
fn expect_file(path: &Path, actual: &str) -> Result<(), String> {
    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        return std::fs::write(path, actual).map_err(|e| format!("write {}: {e}", path.display()));
    }

    let expected = std::fs::read_to_string(path).map_err(|e| {
        format!(
            "read {}: {e} (rerun with VOLTA_BLESS=1 to create it)",
            path.display()
        )
    })?;

    if actual != expected {
        return Err(format!(
            "outputs differ from {} (rerun with VOLTA_BLESS=1 to accept)",
            path.display()
        ));
    }
    Ok(())
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

/// The `kentry` of the CK RMSNorm instance `ck_rmsnorm2d.hip` compiles: four waves normalizing
/// one row of up to 1,024 elements.
pub const CK_RMSNORM_KERNEL: &str = concat!(
    "_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2d",
    "FwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi",
    "1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFus",
    "edAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsn",
    "orm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffL",
    "b0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_",
);
pub const RMSNORM_X_BASE: u64 = 0x10000;
pub const RMSNORM_GAMMA_BASE: u64 = 0x20000;
pub const RMSNORM_Y_BASE: u64 = 0x30000;

/// X and Y at the test addresses, each `rows` contiguous rows of `columns` elements, and gamma
/// with one element per column.
pub fn rmsnorm_arrays(rows: u64, columns: u64) -> [ArrayDef; 3] {
    [
        ("x", RMSNORM_X_BASE, rows * columns, ArrayKind::Input),
        ("gamma", RMSNORM_GAMMA_BASE, columns, ArrayKind::Input),
        (
            "y",
            RMSNORM_Y_BASE,
            rows * columns,
            ArrayKind::Output(OutputType::F32),
        ),
    ]
    .map(|(name, base, len, kind)| ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    })
}

/// CK's `Rmsnorm2dFwd::Kargs` for `rows` contiguous rows of `columns` elements normalized with
/// `epsilon`. The tensors this instance does not use have null pointers.
pub fn ck_rmsnorm_kernarg(rows: i32, columns: i32, epsilon: f32) -> Vec<u8> {
    let mut bytes = Vec::new();
    // p_x, p_x_residual, p_sm_scale and p_gamma, then p_y, p_y_residual, p_y_scale, p_invRms
    // and p_y_unquant.
    for pointer in [
        RMSNORM_X_BASE,
        0,
        0,
        RMSNORM_GAMMA_BASE,
        RMSNORM_Y_BASE,
        0,
        0,
        0,
        0,
    ] {
        bytes.extend(pointer.to_le_bytes());
    }
    bytes.extend(epsilon.to_le_bytes());
    // m and n, then the row strides of X, the X residual, Y and the Y residual.
    for field in [rows, columns, columns, columns, columns, columns] {
        bytes.extend(field.to_le_bytes());
    }
    // Padding to the struct's eight-byte alignment.
    bytes.resize(104, 0);
    bytes
}

/// The `kernel_reduce_threadwise` entry `ck_avgpool2d.hip` compiles: 256 work-items, each
/// averaging the window of one output element.
pub const CK_AVGPOOL2D_KERNEL: &str = concat!(
    "_ZN2ck24kernel_reduce_threadwiseINS_36GridwiseReduction_mk_to_m_threadwiseIfffiNS_16Tens",
    "orDescriptorINS_5TupleIJNS_5EmbedINS3_IJiiiiEEES5_Lb0EEENS_11PassThroughIiEENS_3PadIiiiL",
    "b0EEESA_S8_S8_NS4_INS3_IJiiEEESB_Lb0EEESC_S8_NS_23Merge_v2_magic_divisionIS5_EENSD_ISB_E",
    "ENS_8RightPadIiiLb0EEESH_EEENS3_IJNS_8SequenceIJLi0EEEENSJ_IJLi1EEEENSJ_IJLi2EEEENSJ_IJL",
    "i3EEEENSJ_IJLi4EEEENSJ_IJLi5EEEENSJ_IJLi6EEEENSJ_IJLi7EEEENSJ_IJLi8EEEENSJ_IJLi9ELi11ELi",
    "13ELi14EEEENSJ_IJLi10ELi12EEEENSJ_IJLi15EEEENSJ_IJLi16EEEEEEENS3_IJNSJ_IJLi1ELi2ELi3ELi4",
    "EEEESP_SQ_SR_SS_NSJ_IJLi9EEEENSJ_IJLi10ELi11EEEENSJ_IJLi12ELi13EEEENSJ_IJLi14EEEESV_SW_N",
    "SJ_IJLi17EEEENSJ_IJLi18EEEEEEENSJ_IJLi17ELi18EEEExEENS2_INS3_IJS6_SE_SH_EEENS3_IJSK_SY_S",
    "P_EEENS3_IJSY_SP_SQ_EEESQ_xEENS_6reduce3AddENS_16tensor_operation12element_wise11PassThr",
    "oughENS1F_11UnaryDivideELNS_25InMemoryDataOperationEnumE0ELb0ELi256ELi1ELi1ELi0ELi1ELi1E",
    "EELb0ELb1ELb0EfffiS17_S1B_S1G_S1H_EEvT7_T8_T9_T10_T5_PKT3_PKT6_S1O_PT4_PS1S_",
);
pub const AVGPOOL_INPUT_BASE: u64 = 0x10000;
pub const AVGPOOL_OUTPUT_BASE: u64 = 0x20000;

/// One launch of CK's 2D average pooling over NHWC tensors. Each pair is [height, width].
#[derive(Clone, Copy, Debug)]
pub struct AvgPool2d {
    pub batch: i32,
    pub channels: i32,
    pub input: [i32; 2],
    pub window: [i32; 2],
    pub stride: [i32; 2],
    pub dilation: [i32; 2],
    /// Rows and columns of zeros before the input.
    pub left_pad: [i32; 2],
    /// Rows and columns of zeros after the input.
    pub right_pad: [i32; 2],
}

impl AvgPool2d {
    /// The output's [height, width]: how many window positions fit the padded input.
    pub fn output(&self) -> [i32; 2] {
        std::array::from_fn(|axis| {
            let padded = self.input[axis] + self.left_pad[axis] + self.right_pad[axis];
            let window_span = self.dilation[axis] * (self.window[axis] - 1) + 1;
            (padded - window_span) / self.stride[axis] + 1
        })
    }

    /// The number of output elements. Each work-item computes one.
    pub fn output_len(&self) -> i32 {
        let [height, width] = self.output();
        self.batch * height * width * self.channels
    }
}

/// The input and output tensors at the test addresses, in NHWC order without gaps.
pub fn avgpool_arrays(pool: &AvgPool2d) -> [ArrayDef; 2] {
    let [height, width] = pool.input;
    let input_len = pool.batch * height * width * pool.channels;
    [
        ("input", AVGPOOL_INPUT_BASE, input_len, ArrayKind::Input),
        (
            "output",
            AVGPOOL_OUTPUT_BASE,
            pool.output_len(),
            ArrayKind::Output(OutputType::F32),
        ),
    ]
    .map(|(name, base, len, kind)| ArrayDef {
        name: name.into(),
        base,
        len: len as u64,
        kind,
    })
}

/// CK's multiplier and shift for dividing by `divisor` with a multiplication, as
/// `MagicDivision::CalculateMagicNumbers` computes them. CK stores both as `uint32_t` words.
fn ck_magic_division(divisor: i32) -> [i32; 2] {
    assert!(divisor > 0, "CK divides by tensor lengths");
    let divisor = divisor as u64;
    // The smallest shift whose power of two reaches the divisor.
    let shift = divisor.next_power_of_two().trailing_zeros();
    let multiplier = (((1 << shift) - divisor) << 32) / divisor + 1;
    [multiplier as u32 as i32, shift as i32]
}

/// The fields of a CK `Merge` transform, which joins dimensions of `lengths` into one index:
/// the lengths, a division multiplier and a shift for each, then the merged length.
fn ck_merge(lengths: &[i32]) -> Vec<i32> {
    let magic: Vec<[i32; 2]> = lengths.iter().map(|&l| ck_magic_division(l)).collect();
    let mut fields = lengths.to_vec();
    fields.extend(magic.iter().map(|&[multiplier, _]| multiplier));
    fields.extend(magic.iter().map(|&[_, shift]| shift));
    fields.push(lengths.iter().product());
    fields
}

/// The fields of a CK `RightPad` transform that rounds `length` up to whole tiles of `tile`:
/// the padded length, the length and the padding.
fn ck_right_pad(length: i32, tile: i32) -> [i32; 3] {
    let padded = (length + tile - 1) / tile * tile;
    [padded, length, padded - length]
}

/// A CK tensor descriptor's bytes: its transforms' `fields`, its element count, then its
/// 64-bit element space, the buffer size in elements that bounds the kernel's accesses. CK
/// computes the space from the tensor's `lengths` and `strides`: one past its last element.
fn ck_descriptor(fields: &[i32], elements: i32, lengths: [i32; 4], strides: [i32; 4]) -> Vec<u8> {
    let last_element: i64 = lengths
        .iter()
        .zip(strides)
        .map(|(&length, stride)| i64::from(length - 1) * i64::from(stride))
        .sum();
    let mut bytes: Vec<u8> = fields
        .iter()
        .chain([&elements])
        .flat_map(|field| field.to_le_bytes())
        .collect();
    bytes.resize(bytes.len().next_multiple_of(8), 0);
    bytes.extend((last_element + 1).to_le_bytes());
    bytes
}

/// The arguments CK's `DevicePool2dFwd_NHWC_NHWC` passes its kernel for `pool`, as its host
/// code lays them out: the input and output tensor descriptors by value, the window size to
/// divide by, a scale of 1, the input, a weight of 0 for the output's old values, the output.
pub fn ck_avgpool2d_kernarg(pool: &AvgPool2d) -> Vec<u8> {
    let (n, c) = (pool.batch, pool.channels);
    let [hi, wi] = pool.input;
    let output = pool.output();
    let [ho, wo] = output;
    let [y, x] = pool.window;
    // CK rounds the output elements (M) up to whole workgroups of 256 work-items, and the
    // window positions (K) up to whole steps of one.
    let m = ck_right_pad(n * ho * wo * c, 256);
    let k = ck_right_pad(y * x, 1);

    // The input descriptor maps an output element and a window position to an input element.
    let input_lengths = [n, hi, wi, c];
    let input_strides = [hi * wi * c, wi * c, c, 1];
    let mut input_fields = Vec::new();
    input_fields.extend(input_lengths);
    input_fields.extend(input_strides);
    // Zeros surround H and W. N and C pass through this step and the next.
    input_fields.push(n);
    for axis in 0..2 {
        let (left, right) = (pool.left_pad[axis], pool.right_pad[axis]);
        input_fields.extend([pool.input[axis] + left + right, left, right]);
    }
    input_fields.push(c);
    // A window position and an output position, scaled by the dilation and the stride, index
    // each padded axis.
    input_fields.push(n);
    for axis in 0..2 {
        input_fields.extend([
            pool.window[axis],
            output[axis],
            pool.dilation[axis],
            pool.stride[axis],
        ]);
    }
    input_fields.push(c);
    input_fields.extend(ck_merge(&[n, ho, wo, c]));
    input_fields.extend(ck_merge(&[y, x]));
    input_fields.extend(m);
    input_fields.extend(k);
    let mut bytes = ck_descriptor(&input_fields, m[0] * k[0], input_lengths, input_strides);

    // The output descriptor maps an output element to its offset. CK gives the output tensor
    // the input's height and width here, so they size its element space.
    let output_strides = [ho * wo * c, wo * c, c, 1];
    let mut output_fields = Vec::new();
    output_fields.extend(input_lengths);
    output_fields.extend(output_strides);
    output_fields.extend(ck_merge(&[n, ho, wo, c]));
    output_fields.extend(m);
    bytes.extend(ck_descriptor(
        &output_fields,
        m[0],
        input_lengths,
        output_strides,
    ));

    // The input operation has no fields. The window size follows at the next word.
    bytes.resize(bytes.len() + 4, 0);
    bytes.extend((y * x).to_le_bytes());
    // The scale, padded to the pointers' alignment, then the input and a null index input.
    bytes.extend(1.0_f32.to_le_bytes());
    bytes.resize(bytes.len() + 4, 0);
    bytes.extend(AVGPOOL_INPUT_BASE.to_le_bytes());
    bytes.extend(0_u64.to_le_bytes());
    // The weight of the output's old values, padded, then the output and a null index output.
    bytes.extend(0.0_f32.to_le_bytes());
    bytes.resize(bytes.len() + 4, 0);
    bytes.extend(AVGPOOL_OUTPUT_BASE.to_le_bytes());
    bytes.extend(0_u64.to_le_bytes());
    assert_eq!(bytes.len(), 392, "the kernel's argument size");
    bytes
}
