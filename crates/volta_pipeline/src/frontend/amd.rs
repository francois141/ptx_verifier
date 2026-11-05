//! AMD gfx950 assembly: `volta_amd_analysis` runs workgroup 0 of the kernel. This frontend does
//! not run the graph checks on its event graph yet, so a run carries no race evidence.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, OutputType, Terminal, WorkgroupLaunch, analyze};
use volta_ptx_analysis::{AnalysisConfig, ParamValue};

use super::{Frontend, FrontendError, GraphEvidence, KernelRun, only_kernel};

/// Where the kernel argument buffer sits: below the first array a launch file lays out.
const KERNARG_ADDRESS: u64 = 0x1000;

pub struct AmdFrontend;

impl Frontend for AmdFrontend {
    /// The default kernel is the source's only `.amdhsa_kernel` descriptor.
    fn analyze(
        &self,
        source: &str,
        kernel: Option<&str>,
        launch: AnalysisConfig,
    ) -> Result<KernelRun, FrontendError> {
        let name = match kernel {
            Some(name) => name.to_string(),
            None => only_kernel(descriptors(source))?,
        };
        let parsed = parse_kernel(source, &name).map_err(|message| FrontendError::Parse {
            title: "AMD assembly parse error".into(),
            message: Some(message),
            span: None,
        })?;

        let (workgroup, kernarg, arrays) = workgroup_launch(&launch)?;
        let result = analyze(&parsed, &workgroup, &kernarg, &arrays)
            .map_err(|e| FrontendError::Analysis(e.to_string()))?;

        let outputs = result
            .symbolic_outputs
            .ok_or_else(|| match &result.terminal {
                Terminal::Aborted { wave, pc, error } => {
                    format!("wave {} aborted at instruction {}: {error}", wave.0, pc.0)
                }
                Terminal::Completed => "the run completed without outputs".into(),
            });

        Ok(KernelRun {
            outputs,
            graph: GraphEvidence::NotRecorded,
        })
    }
}

/// The kernels `source`'s `.amdhsa_kernel` descriptors name.
fn descriptors(source: &str) -> Vec<String> {
    source
        .lines()
        .filter_map(|line| {
            let (directive, name) = line.trim().split_once(char::is_whitespace)?;
            (directive == ".amdhsa_kernel").then(|| name.trim().to_string())
        })
        .collect()
}

/// `launch` as `volta_amd_analysis` takes it. The parameters fill the argument buffer as clang
/// lays out kernel arguments: each at the next offset aligned to its size.
fn workgroup_launch(
    launch: &AnalysisConfig,
) -> Result<(WorkgroupLaunch, Vec<u8>, Vec<ArrayDef>), FrontendError> {
    if !launch.global_values.is_empty() {
        return Err(FrontendError::Launch(
            "AMD kernels take no module-scope globals".into(),
        ));
    }

    if launch.dynamic_shared_bytes != 0 {
        return Err(FrontendError::Launch(
            "AMD kernels take their LDS size from their descriptor, not a dynamic shared size"
                .into(),
        ));
    }

    let arrays = launch
        .arrays
        .iter()
        .map(word_array)
        .collect::<Result<_, _>>()?;

    let mut kernarg = Vec::new();
    for param in &launch.params {
        let bytes = argument(launch, param)?;
        kernarg.resize(kernarg.len().next_multiple_of(bytes.len()), 0);
        kernarg.extend(bytes);
    }

    let workgroup = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: launch.block_dim,
    };
    Ok((workgroup, kernarg, arrays))
}

fn word_array(array: &volta_ptx_analysis::ArrayDef) -> Result<ArrayDef, FrontendError> {
    let kind = match array.kind {
        volta_ptx_analysis::ArrayKind::Input => ArrayKind::Input,
        // A launch carries no element type, so every output word is read as an f32.
        volta_ptx_analysis::ArrayKind::Output => ArrayKind::Output(OutputType::F32),
        volta_ptx_analysis::ArrayKind::InputOutput | volta_ptx_analysis::ArrayKind::IndexInput => {
            return Err(FrontendError::Launch(format!(
                "AMD array `{}` must be `in` or `out`",
                array.name
            )));
        }
    };

    if array.elem_width != 4 {
        return Err(FrontendError::Launch(format!(
            "AMD array `{}` has {}-byte elements; AMD arrays hold 32-bit words",
            array.name, array.elem_width
        )));
    }

    Ok(ArrayDef {
        name: array.name.clone(),
        base: array.base,
        len: array.len,
        kind,
    })
}

/// The bytes of one kernel argument: a 64-bit array base, a 32-bit integer or an f32.
fn argument(launch: &AnalysisConfig, param: &ParamValue) -> Result<Vec<u8>, FrontendError> {
    match param {
        ParamValue::ArrayPtr(name) => launch
            .array(name)
            .map(|array| array.base.to_le_bytes().to_vec())
            .ok_or_else(|| FrontendError::Launch(format!("`ptr:{name}` names no array"))),

        ParamValue::Int(value) => i32::try_from(*value)
            .map(|value| value.to_le_bytes().to_vec())
            .map_err(|_| {
                FrontendError::Launch(format!("`int:{value}` does not fit a 32-bit argument"))
            }),

        ParamValue::Float(value) => {
            let single = *value as f32;
            if f64::from(single) == *value {
                Ok(single.to_le_bytes().to_vec())
            } else {
                Err(FrontendError::Launch(format!(
                    "`float:{value}` is not exactly an f32"
                )))
            }
        }

        ParamValue::SymFloat(name) => Err(FrontendError::Launch(format!(
            "`sym:{name}` has no bytes: AMD kernel arguments are concrete"
        ))),

        ParamValue::Struct(_) => Err(FrontendError::Launch(
            "AMD kernels take no struct parameters".into(),
        )),
    }
}
