//! AWS Trainium NKI: `volta_trainium_analysis` lowers the `@nki.jit` kernel and executes it.
//! It is called with the parameter shapes its own `assert param.shape == (...)`s state, so it
//! takes no launch; its interpreter records no memory events, so a run carries no race evidence.

use volta_ptx_analysis::AnalysisConfig;
use volta_trainium_analysis::frontend::error::ParseError;
use volta_trainium_analysis::frontend::parse::{asserted_shapes, parse_kernel};
use volta_trainium_analysis::{evaluate, lower_kernel};

use super::{Frontend, FrontendError, GraphEvidence, KernelRun, only_kernel};

pub struct NkiFrontend;

impl Frontend for NkiFrontend {
    /// The default kernel is the source's only `@nki.jit` function.
    fn analyze(
        &self,
        source: &str,
        kernel: Option<&str>,
        launch: AnalysisConfig,
    ) -> Result<KernelRun, FrontendError> {
        if !is_empty(&launch) {
            return Err(FrontendError::Launch(
                "NKI kernels take their shapes from their `assert`s: give no launch dims, \
                 arrays, params or globals"
                    .into(),
            ));
        }

        let name = match kernel {
            Some(name) => name.to_string(),
            None => only_kernel(jit_functions(source))?,
        };
        let parse_error = |e: ParseError| FrontendError::Parse {
            title: "NKI parse error".into(),
            message: Some(e.to_string()),
            span: None,
        };
        let shapes = asserted_shapes(source, &name).map_err(parse_error)?;
        let shapes: Vec<(&str, &[u64])> = shapes
            .iter()
            .map(|(param, extents)| (param.as_str(), extents.as_slice()))
            .collect();
        let parsed = parse_kernel(source, &name, &shapes).map_err(parse_error)?;

        let lowered = lower_kernel(&parsed)
            .map_err(|e| FrontendError::Analysis(format!("lowering failed: {e}")))?;

        Ok(KernelRun {
            outputs: evaluate(&lowered).map_err(|e| e.to_string()),
            graph: GraphEvidence::NotRecorded,
        })
    }
}

fn is_empty(launch: &AnalysisConfig) -> bool {
    launch.block_dim == (1, 1, 1)
        && launch.grid_dim == (1, 1, 1)
        && launch.arrays.is_empty()
        && launch.params.is_empty()
        && launch.global_values.is_empty()
        && launch.dynamic_shared_bytes == 0
}

/// The functions `source` decorates `@nki.jit` on the line before their `def`.
fn jit_functions(source: &str) -> Vec<String> {
    let lines: Vec<&str> = source.lines().map(str::trim).collect();

    lines
        .windows(2)
        .filter(|pair| pair[0] == "@nki.jit")
        .filter_map(|pair| {
            let (name, _) = pair[1].strip_prefix("def ")?.split_once('(')?;
            Some(name.trim().to_string())
        })
        .collect()
}
