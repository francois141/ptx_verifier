//! NVIDIA PTX: `volta_ptx_analysis`'s abstract interpreter, then the graph branch's checks over
//! the event graph it records.

use volta_ptx_analysis::AnalysisConfig;
use volta_ptx_analysis::frontend::ascii::AsAscii;
use volta_ptx_analysis::frontend::parse::Parser;

use super::{Frontend, FrontendError, GraphEvidence, KernelRun};
use crate::kernel::verify_kernel;

pub struct PtxFrontend;

impl Frontend for PtxFrontend {
    /// The default kernel is the module's first entry.
    fn analyze(
        &self,
        source: &str,
        kernel: Option<&str>,
        launch: AnalysisConfig,
    ) -> Result<KernelRun, FrontendError> {
        let ascii = source
            .as_bytes()
            .as_ascii_slice()
            .ok_or_else(|| FrontendError::Parse {
                title: "PTX source contains a non-ASCII character".into(),
                message: None,
                span: None,
            })?;

        let module = Parser::new(ascii)
            .parse_module()
            .map_err(|e| FrontendError::Parse {
                title: e.error.title().into(),
                message: e.error.message(),
                span: e.span,
            })?;

        let verified = verify_kernel(&module, kernel, launch)
            .map_err(|e| FrontendError::Analysis(e.to_string()))?;
        let parts = verified.analysis.into_parts();

        Ok(KernelRun {
            outputs: parts.outputs.map_err(|why| why.to_string()),
            graph: GraphEvidence::Checked {
                graph: Box::new(parts.graph),
                report: Box::new(verified.graph),
            },
        })
    }
}
