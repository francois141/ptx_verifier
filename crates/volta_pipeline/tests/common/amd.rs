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

/// A named parameter used by the tests and generated launch files.
#[derive(Clone, Debug)]
pub struct LaunchParam {
    pub name: String,
    pub value: LaunchValue,
}

#[derive(Clone, Copy, Debug)]
pub enum LaunchValue {
    Int(i32),
    Float(f32),
    /// The tests use the array's base address. Launch files refer to it by name.
    Ptr {
        array: &'static str,
        base: u64,
    },
}

fn param(name: impl Into<String>, value: LaunchValue) -> LaunchParam {
    LaunchParam {
        name: name.into(),
        value,
    }
}

/// Encode a null 64-bit pointer as two zero words.
fn null_pointer(name: &str) -> [LaunchParam; 2] {
    ["low", "high"].map(|half| {
        let name = format!("{name} ({half} word, null)");
        param(name, LaunchValue::Int(0))
    })
}

/// Pack parameters using the AMD frontend's layout. Align each value to its size.
fn kernarg_bytes(params: &[LaunchParam]) -> Vec<u8> {
    let mut bytes = Vec::new();
    for param in params {
        let value = match param.value {
            LaunchValue::Int(value) => value.to_le_bytes().to_vec(),
            LaunchValue::Float(value) => value.to_le_bytes().to_vec(),
            LaunchValue::Ptr { base, .. } => base.to_le_bytes().to_vec(),
        };
        bytes.resize(bytes.len().next_multiple_of(value.len()), 0);
        bytes.extend(value);
    }
    bytes
}

/// One fp32 array of a launch file.
pub struct LaunchArray {
    pub name: &'static str,
    pub kind: ArrayKind,
    pub shape: Vec<i32>,
}

/// A CK launch for one workgroup.
pub struct Launch {
    pub description: String,
    /// Select the kernel when the fixture defines more than one.
    pub kernel: Option<&'static str>,
    /// The number of work-items in the workgroup.
    pub workitems: u32,
    /// Use the frontend's default array addresses, starting at 0x10000. Each base is rounded
    /// up to a 64 KiB boundary. These addresses must match the pointer values in `params`.
    pub arrays: Vec<LaunchArray>,
    pub params: Vec<LaunchParam>,
    /// The spec filename under `volta_equivalence/tests/specs/`.
    pub spec: &'static str,
    pub dims: Vec<(&'static str, u64)>,
}

impl Launch {
    /// Render JSON with one array and one parameter per line.
    pub fn render(&self) -> String {
        let description = format!(
            "{} volta_pipeline's AMD tests generate this file; VOLTA_BLESS=1 rewrites it",
            self.description
        );
        let mut text = String::new();
        writeln!(text, "{{").unwrap();
        writeln!(text, r#"  "description": {description:?},"#).unwrap();
        if let Some(kernel) = self.kernel {
            writeln!(text, r#"  "kernel": "{kernel}","#).unwrap();
        }
        // Omitting the grid selects one workgroup. The AMD frontend runs workgroup 0.
        writeln!(text, r#"  "block": {},"#, self.workitems).unwrap();

        // Align array names and kinds to keep the JSON readable.
        writeln!(text, r#"  "arrays": ["#).unwrap();
        let name_width = self.arrays.iter().map(|a| a.name.len()).max().unwrap_or(0) + 3;
        for (position, array) in self.arrays.iter().enumerate() {
            let name = format!(r#""{}","#, array.name);
            let kind = match array.kind {
                ArrayKind::Input => r#""in","#,
                ArrayKind::Output(_) => r#""out","#,
            };
            let shape = &array.shape;
            let comma = if position + 1 < self.arrays.len() {
                ","
            } else {
                ""
            };
            let fields = format!(r#""name": {name:<name_width$} "kind": {kind:<6} "dtype": "f32""#);
            writeln!(text, r#"    {{{fields}, "shape": {shape:?}}}{comma}"#).unwrap();
        }
        writeln!(text, "  ],").unwrap();

        writeln!(text, r#"  "params": ["#).unwrap();
        for (position, param) in self.params.iter().enumerate() {
            let value = match param.value {
                LaunchValue::Int(value) => format!(r#""int": {value}"#),
                // Preserve the exact f32 value when the JSON reader parses it as f64.
                LaunchValue::Float(value) => format!(r#""float": {:?}"#, f64::from(value)),
                LaunchValue::Ptr { array, .. } => format!(r#""ptr": "{array}""#),
            };
            let comma = if position + 1 < self.params.len() {
                ","
            } else {
                ""
            };
            writeln!(text, r#"    {{"name": {:?}, {value}}}{comma}"#, param.name).unwrap();
        }
        writeln!(text, "  ],").unwrap();

        let specs = "../../crates/volta_equivalence/tests/specs";
        writeln!(text, r#"  "spec": "{specs}/{}","#, self.spec).unwrap();
        let dims: Vec<String> = self
            .dims
            .iter()
            .map(|(name, value)| format!(r#""{name}": {value}"#))
            .collect();
        writeln!(text, r#"  "dims": {{{}}}"#, dims.join(", ")).unwrap();
        writeln!(text, "}}").unwrap();
        text
    }
}

/// Check the generated launch against `examples/lean/<file>`.
/// `VOLTA_BLESS=1` updates the file instead.
pub fn check_launch_file(file: &str, launch: &Launch) {
    let text = launch.render();
    // Validate the generated JSON before comparing or saving it.
    // Rust debug escaping can produce strings that JSON rejects.
    if let Err(error) = volta_ptx_analysis::LaunchFile::from_json(&text) {
        panic!("{file}: the generated launch file does not load: {error}");
    }
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../examples/lean")
        .join(file);
    if let Err(error) = expect_file(&path, &text) {
        panic!("{file}: {error}");
    }
}

/// Build CK GEMM arguments for dimensions [M, N, K].
/// `matrices` lists A, B and C in order, with each array's name and address.
pub fn ck_gemm_params(matrices: [(&'static str, u64); 3], dims: [i32; 3]) -> Vec<LaunchParam> {
    let [m, n, k] = dims;
    // Round each dimension up to the kernel's 64 x 64 x 64 tile.
    let [mpadded, npadded, kpadded] = dims.map(|d| (d + 63) / 64 * 64);
    let kread = (k + 3) / 4 * 4;
    // The kernel never reads `BaseArgument`'s vtable and workspace pointers.
    let mut params = Vec::new();
    params.extend(null_pointer("BaseArgument vtable pointer, unread"));
    params.extend(null_pointer("p_workspace_"));
    for (name, value) in [
        ("M", m),
        ("N", n),
        ("K", k),
        // A and C are row-major. B is column-major.
        ("StrideA", k),
        ("StrideB", k),
        ("StrideC", n),
        ("KBatch", 1),
        ("MPadded", mpadded),
        ("NPadded", npadded),
        ("KRead", kread),
        ("KPadded", kpadded),
        // AK0 and BK0 count groups of four elements in padded K.
        ("AK0", kpadded / 4),
        ("BK0", kpadded / 4),
        ("MBlock", mpadded / 64),
        ("NBlock", npadded / 64),
    ] {
        params.push(param(name, LaunchValue::Int(value)));
    }
    // Reserve one word for the three empty operation objects and padding.
    let element_ops = "a_element_op_, b_element_op_, c_element_op_ (no fields) and padding";
    params.push(param(element_ops, LaunchValue::Int(0)));
    let pointers = ["p_a_grid", "p_b_grid", "p_c_grid"];
    for (name, (array, base)) in pointers.into_iter().zip(matrices) {
        params.push(param(name, LaunchValue::Ptr { array, base }));
    }
    params.push(param("is_reduce (false) and padding", LaunchValue::Int(0)));
    params.push(param("padding", LaunchValue::Int(0)));
    params
}

/// Pack CK GEMM's named parameters into kernel argument bytes.
pub fn ck_gemm_kernarg(a: u64, b: u64, c: u64, dims: [i32; 3]) -> Vec<u8> {
    // Packing uses addresses only. Array names do not affect these bytes.
    let bytes = kernarg_bytes(&ck_gemm_params([("A", a), ("B", b), ("C", c)], dims));
    assert_eq!(bytes.len(), 112, "the kernel's argument size");
    bytes
}

/// Create a `volta solve` launch for an 8 x 8 x 8 GEMM without a K-block main loop.
pub fn gemm_launch() -> Launch {
    let matrix = |name, kind| LaunchArray {
        name,
        kind,
        shape: vec![8, 8],
    };
    let matrices = [("A", GEMM_A_BASE), ("B", GEMM_B_BASE), ("C", GEMM_C_BASE)];
    let description = "CK GEMM of 8 x 8 fp32 matrices, C = A B with B stored column-major, in \
                       one workgroup of two waves that pads the problem to its 64 x 64 x 64 \
                       block tile. The parameters are the fields of CK's by-value \
                       GridwiseGemm::Argument. volta solve accepts this launch.";
    Launch {
        description: description.into(),
        kernel: Some(CK_GEMM_KERNEL),
        workitems: 128,
        arrays: vec![
            matrix("A", ArrayKind::Input),
            matrix("B", ArrayKind::Input),
            matrix("C", ArrayKind::Output(OutputType::F32)),
        ],
        params: ck_gemm_params(matrices, [8, 8, 8]),
        spec: "matmul_transposed.spec",
        dims: vec![("M", 8), ("N", 8), ("K", 8)],
    }
}

/// Entry point compiled from `ck_fmha.hip`.
/// The kernel uses four waves for a 64 x 64 query/key tile.
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

/// A pointer parameter to the attention test array at `base`.
fn fmha_pointer(base: u64) -> LaunchValue {
    let array = match base {
        FMHA_Q_BASE => "Q",
        FMHA_K_BASE => "K",
        FMHA_V_BASE => "V",
        FMHA_O_BASE => "O",
        _ => panic!("no attention test array at {base:#x}"),
    };
    LaunchValue::Ptr { array, base }
}

/// CK attention arguments for contiguous [batch, head, sequence, dimension] tensors.
/// Each head is 64 x 64. `q` and `k` select the query and key arrays.
pub fn ck_fmha_params(q: u64, k: u64, heads: i32) -> Vec<LaunchParam> {
    let int = |name: String, value| param(name, LaunchValue::Int(value));
    let tensors = ["q", "k", "v", "o"];
    let mut params = vec![
        param("q_ptr", fmha_pointer(q)),
        param("k_ptr", fmha_pointer(k)),
        param("v_ptr", fmha_pointer(FMHA_V_BASE)),
        param("o_ptr", fmha_pointer(FMHA_O_BASE)),
    ];
    // A null sink pointer disables the optional sink.
    params.extend(null_pointer("sink_ptr"));
    for (name, value) in [
        ("seqlen_q", 64),
        ("seqlen_k", 64),
        ("hdim_q", 64),
        ("hdim_v", 64),
        ("num_head_q", heads),
        ("nhead_ratio_qk", 1),
    ] {
        params.push(int(name.into(), value));
    }
    // The kernel uses exp2, so multiply the formula's 1 / 8 scale by log2(e).
    let scale = LaunchValue::Float(std::f32::consts::LOG2_E / 8.0);
    params.push(param("scale_s", scale));
    // Store row and head strides in elements.
    params.extend(tensors.map(|tensor| int(format!("stride_{tensor}"), 64)));
    params.extend(tensors.map(|tensor| int(format!("nhead_stride_{tensor}"), 4096)));
    params.push(int("num_head_q_total".into(), 0));
    params.push(int("head_start".into(), 0));
    // Each batch contains all heads.
    params.extend(tensors.map(|tensor| int(format!("batch_stride_{tensor}"), heads * 4096)));
    // Align the cumulative sequence-length pointers and set them to null.
    params.push(int("padding".into(), 0));
    params.extend(null_pointer("cu_seqlen_q_ptr"));
    params.extend(null_pointer("cu_seqlen_k_ptr"));
    params
}

/// Pack CK attention's named parameters into kernel argument bytes.
pub fn ck_fmha_kernarg(q: u64, k: u64, heads: i32) -> Vec<u8> {
    let bytes = kernarg_bytes(&ck_fmha_params(q, k, heads));
    assert_eq!(bytes.len(), 144, "the kernel's argument size");
    bytes
}

/// Create a `volta solve` launch for one batch and one head.
/// `q` and `k` select the query and key arrays.
pub fn fmha_launch(q: u64, k: u64, note: &str) -> Launch {
    let input = |name| LaunchArray {
        name,
        kind: ArrayKind::Input,
        shape: vec![1, 1, 64, 64],
    };
    let output = LaunchArray {
        name: "O",
        kind: ArrayKind::Output(OutputType::F32),
        shape: vec![64, 64],
    };
    let description = format!(
        "CK forward attention over one batch and one head of 64 x 64 fp32 tensors, in one \
         workgroup of four waves, against softmax(Q K^T / 8) V. The parameters are the fields \
         of CK's by-value FmhaFwdBatchModeKargs. {note}"
    );
    Launch {
        description,
        kernel: Some(CK_FMHA_KERNEL),
        workitems: 256,
        arrays: vec![input("Q"), input("K"), input("V"), output],
        params: ck_fmha_params(q, k, 1),
        spec: "attention_batch_head.spec",
        dims: vec![
            ("B", 1),
            ("G", 1),
            ("N", 64),
            ("H", 64),
            ("Batch", 0),
            ("Head", 0),
        ],
    }
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

    /// The dims of `avg_pool2d_nhwc.spec` for this launch, in the spec's order.
    pub fn spec_dims(&self) -> [(&'static str, u64); 14] {
        let [output_height, output_width] = self.output();
        [
            ("N", self.batch),
            ("H", self.input[0]),
            ("W", self.input[1]),
            ("C", self.channels),
            ("HOUT", output_height),
            ("WOUT", output_width),
            ("KH", self.window[0]),
            ("KW", self.window[1]),
            ("SH", self.stride[0]),
            ("SW", self.stride[1]),
            ("DH", self.dilation[0]),
            ("DW", self.dilation[1]),
            ("PH", self.left_pad[0]),
            ("PW", self.left_pad[1]),
        ]
        .map(|(name, value)| (name, value as u64))
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

/// `values` as fields, each labelled `what` and then its entry of `dims`.
fn labelled(what: &str, dims: &[&str], values: &[i32]) -> Vec<(String, i32)> {
    dims.iter()
        .zip(values)
        .map(|(dim, &value)| (format!("{what} {dim}"), value))
        .collect()
}

/// The fields of a CK `Merge` transform, which joins the dimensions `dims` into the index
/// `index`: their lengths, a division multiplier and a shift for each, then the merged length.
fn ck_merge(index: &str, dims: &[&str], lengths: &[i32]) -> Vec<(String, i32)> {
    let magic: Vec<[i32; 2]> = lengths.iter().map(|&l| ck_magic_division(l)).collect();
    let multipliers: Vec<i32> = magic.iter().map(|&[multiplier, _]| multiplier).collect();
    let shifts: Vec<i32> = magic.iter().map(|&[_, shift]| shift).collect();
    let merge = format!("merge {index}:");
    let mut fields = labelled(&format!("{merge} length"), dims, lengths);
    fields.extend(labelled(
        &format!("{merge} division multiplier for"),
        dims,
        &multipliers,
    ));
    fields.extend(labelled(
        &format!("{merge} division shift for"),
        dims,
        &shifts,
    ));
    let merged = format!("{merge} merged length {}", dims.join(" * "));
    fields.push((merged, lengths.iter().product()));
    fields
}

/// The fields of a CK `RightPad` transform that rounds the index `index`, of `length`, up to
/// whole tiles of `tile`: the padded length, the length and the padding.
fn ck_right_pad(index: &str, length: i32, tile: i32) -> [(String, i32); 3] {
    let padded = (length + tile - 1) / tile * tile;
    [
        (
            format!("{index} rounded up to a multiple of {tile}"),
            padded,
        ),
        (index.to_string(), length),
        (format!("{index} padding"), padded - length),
    ]
}

/// The fields that end a CK tensor descriptor: its element count, padding, then its 64-bit
/// element space as two words. The space is the buffer size in elements that bounds the
/// kernel's accesses: one past the last element of a tensor of `lengths` and `strides`.
fn ck_descriptor_end(elements: i32, lengths: [i32; 4], strides: [i32; 4]) -> [(String, i32); 4] {
    let last_element: i64 = lengths
        .iter()
        .zip(strides)
        .map(|(&length, stride)| i64::from(length - 1) * i64::from(stride))
        .sum();
    let space = last_element + 1;
    [
        ("element count".into(), elements),
        ("padding".into(), 0),
        ("element space (low word)".into(), space as i32),
        ("element space (high word)".into(), (space >> 32) as i32),
    ]
}

/// The parameters CK's `DevicePool2dFwd_NHWC_NHWC` passes its kernel for `pool`, in the order
/// its host code lays them out: the words of the input and output tensor descriptors, the
/// window size to divide by, a scale of 1, the input, a weight of 0 for the output's old
/// values, then the output.
pub fn ck_avgpool2d_params(pool: &AvgPool2d) -> Vec<LaunchParam> {
    let (n, c) = (pool.batch, pool.channels);
    let [hi, wi] = pool.input;
    let [ho, wo] = pool.output();
    let [y, x] = pool.window;
    // CK rounds the output elements (M) up to whole workgroups of 256 work-items, and the
    // window positions (K) up to whole steps of one.
    let m = ck_right_pad("M", n * ho * wo * c, 256);
    let k = ck_right_pad("K", y * x, 1);
    let (padded_m, padded_k) = (m[0].1, k[0].1);

    // The input descriptor maps an output element and a window position to an input element.
    let input_lengths = [n, hi, wi, c];
    let input_strides = [hi * wi * c, wi * c, c, 1];
    let input_dims = ["N", "Hi", "Wi", "C"];
    let mut input_fields = labelled("tensor length", &input_dims, &input_lengths);
    input_fields.extend(labelled("tensor stride", &input_dims, &input_strides));
    // Zeros surround H and W. N and C pass through this step and the next.
    input_fields.push(("pass-through N".into(), n));
    for (axis, dim) in ["H", "W"].into_iter().enumerate() {
        let (left, right) = (pool.left_pad[axis], pool.right_pad[axis]);
        input_fields.push((format!("padded {dim}i"), pool.input[axis] + left + right));
        input_fields.push((format!("left pad {dim}"), left));
        input_fields.push((format!("right pad {dim}"), right));
    }
    input_fields.push(("pass-through C".into(), c));
    // A window position and an output position, scaled by the dilation and the stride, index
    // each padded axis.
    input_fields.push(("pass-through N".into(), n));
    for (axis, [window, dim]) in [["Y", "H"], ["X", "W"]].into_iter().enumerate() {
        input_fields.push((format!("window {window}"), pool.window[axis]));
        input_fields.push((format!("output {dim}o"), [ho, wo][axis]));
        input_fields.push((format!("dilation {dim}"), pool.dilation[axis]));
        input_fields.push((format!("stride {dim}"), pool.stride[axis]));
    }
    input_fields.push(("pass-through C".into(), c));
    let output_dims = ["N", "Ho", "Wo", "C"];
    input_fields.extend(ck_merge("M", &output_dims, &[n, ho, wo, c]));
    input_fields.extend(ck_merge("K", &["Y", "X"], &[y, x]));
    input_fields.extend(m.clone());
    input_fields.extend(k);
    input_fields.extend(ck_descriptor_end(
        padded_m * padded_k,
        input_lengths,
        input_strides,
    ));

    // The output descriptor maps an output element to its offset. CK gives the output tensor
    // the input's height and width here, so they size its element space.
    let output_strides = [ho * wo * c, wo * c, c, 1];
    let ck_dims = ["N", "H (CK passes Hi)", "W (CK passes Wi)", "C"];
    let mut output_fields = labelled("tensor length", &ck_dims, &input_lengths);
    output_fields.extend(labelled("tensor stride", &output_dims, &output_strides));
    output_fields.extend(ck_merge("M", &output_dims, &[n, ho, wo, c]));
    output_fields.extend(m);
    output_fields.extend(ck_descriptor_end(padded_m, input_lengths, output_strides));

    // Each descriptor field is one 32-bit parameter, labelled with the kernel argument it
    // belongs to.
    let mut params = Vec::new();
    for (argument, fields) in [
        ("in_grid_desc_m_k", input_fields),
        ("out_grid_desc_m", output_fields),
    ] {
        for (name, value) in fields {
            let name = format!("{argument}: {name}");
            params.push(param(name, LaunchValue::Int(value)));
        }
    }
    // The input operation has no fields. The window size follows at the next word.
    let divider = "acc_elementwise_op: divider, the window size";
    params.push(param(
        "in_elementwise_op (no fields) and padding",
        LaunchValue::Int(0),
    ));
    params.push(param(divider, LaunchValue::Int(y * x)));
    // The scale, then the input and a null index input. A pointer aligns itself to 8 bytes.
    let input = LaunchValue::Ptr {
        array: "input",
        base: AVGPOOL_INPUT_BASE,
    };
    params.push(param("alpha", LaunchValue::Float(1.0)));
    params.push(param("p_in", input));
    params.extend(null_pointer("p_in_index"));
    // The weight of the output's old values, then the output and a null index output.
    let output = LaunchValue::Ptr {
        array: "output",
        base: AVGPOOL_OUTPUT_BASE,
    };
    params.push(param("beta", LaunchValue::Float(0.0)));
    params.push(param("p_out", output));
    params.extend(null_pointer("p_out_index"));
    params
}

/// Pack CK pooling's named parameters into kernel argument bytes.
pub fn ck_avgpool2d_kernarg(pool: &AvgPool2d) -> Vec<u8> {
    let bytes = kernarg_bytes(&ck_avgpool2d_params(pool));
    assert_eq!(bytes.len(), 392, "the kernel's argument size");
    bytes
}

/// Create a `volta solve` launch for pooling within one workgroup.
pub fn avgpool_launch(pool: &AvgPool2d, note: &str) -> Launch {
    let outputs = pool.output_len();
    assert!(
        outputs <= 256,
        "a launch file holds one workgroup of 256 outputs, not {outputs}"
    );
    let (n, c) = (pool.batch, pool.channels);
    let [hi, wi] = pool.input;
    let [ho, wo] = pool.output();
    let description = format!(
        "CK average pooling of a {n} x {hi} x {wi} x {c} NHWC fp32 tensor into {ho} x {wo}: \
         windows {:?}, strides {:?}, dilations {:?}, zero padding {:?} before and {:?} after, \
         each as [height, width]. {note} The parameters are the words of CK's two by-value \
         tensor descriptors, then its other kernel arguments.",
        pool.window, pool.stride, pool.dilation, pool.left_pad, pool.right_pad
    );
    let input = LaunchArray {
        name: "input",
        kind: ArrayKind::Input,
        shape: vec![n, hi, wi, c],
    };
    let output = LaunchArray {
        name: "output",
        kind: ArrayKind::Output(OutputType::F32),
        shape: vec![n, ho, wo, c],
    };
    Launch {
        description,
        kernel: None,
        workitems: 256,
        arrays: vec![input, output],
        params: ck_avgpool2d_params(pool),
        spec: "avg_pool2d_nhwc.spec",
        dims: pool.spec_dims().to_vec(),
    }
}
