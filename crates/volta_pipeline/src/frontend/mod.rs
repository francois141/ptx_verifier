//! The interpreters behind one interface. Each instruction set's `Frontend` runs a kernel's
//! source under a launch into a `KernelRun`, and every frontend inherits `solve`: the run's
//! outputs checked against a spec by the caller's `Solver`.

use std::fmt;
use std::path::Path;

use volta_common::span::Span;
use volta_expr::SymbolicOutputs;
use volta_graph::EventGraph;
use volta_graph_check::{Deadlock, GraphConclusion, GraphReport, PropertySummary};
use volta_ptx_analysis::AnalysisConfig;

use crate::aggregate::{Decision, GraphBranch, KernelEvidence, decide};
use crate::solve::{Solution, Solver, Spec, solve};

// =========================================================================
// NVIDIA PTX
// =========================================================================

mod ptx;

pub use ptx::PtxFrontend;

// =========================================================================
// AMD gfx950
// =========================================================================

mod amd;

pub use amd::AmdFrontend;

// =========================================================================
// AWS Trainium NKI
// =========================================================================

mod nki;

pub use nki::NkiFrontend;

// =========================================================================
// The interface every frontend implements
// =========================================================================

/// An instruction set Volta interprets, named by its kernel files' extension.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Isa {
    Ptx,
    Amd,
    Trainium,
}

impl Isa {
    pub const ALL: [Isa; 3] = [Isa::Ptx, Isa::Amd, Isa::Trainium];

    /// The ISA whose kernel files carry `path`'s extension.
    pub fn of_path(path: &Path) -> Option<Isa> {
        let extension = path.extension()?.to_str()?;
        Isa::ALL
            .into_iter()
            .find(|isa| isa.extension() == extension)
    }

    pub fn extension(self) -> &'static str {
        match self {
            Isa::Ptx => "ptx",
            Isa::Amd => "s",
            Isa::Trainium => "py",
        }
    }

    pub fn name(self) -> &'static str {
        match self {
            Isa::Ptx => "NVIDIA PTX",
            Isa::Amd => "AMD gfx950",
            Isa::Trainium => "AWS Trainium NKI",
        }
    }

    pub fn frontend(self) -> &'static dyn Frontend {
        match self {
            Isa::Ptx => &PtxFrontend,
            Isa::Amd => &AmdFrontend,
            Isa::Trainium => &NkiFrontend,
        }
    }
}

/// One ISA's interpreter. Launches come in the launch flags' vocabulary (`AnalysisConfig`):
/// a frontend maps what its ISA has and rejects the rest, never ignoring a setting it lacks.
pub trait Frontend {
    /// Run kernel `kernel` of `source`, or the source's default kernel, under `launch`.
    fn analyze(
        &self,
        source: &str,
        kernel: Option<&str>,
        launch: AnalysisConfig,
    ) -> Result<KernelRun, FrontendError>;

    /// `analyze`, then the run's outputs against `spec` by `solver`.
    fn solve(
        &self,
        source: &str,
        kernel: Option<&str>,
        launch: AnalysisConfig,
        spec: &Spec,
        solver: &Solver,
    ) -> Result<(KernelRun, Solution), SolveError> {
        let mut run = self
            .analyze(source, kernel, launch)
            .map_err(SolveError::Frontend)?;
        let solution = run.solve(spec, solver)?;
        Ok((run, solution))
    }
}

/// One kernel's execution: what it wrote, and the race evidence its ISA records.
pub struct KernelRun {
    /// The written output elements, or why the run has none.
    pub outputs: Result<SymbolicOutputs, String>,
    pub graph: GraphEvidence,
}

pub enum GraphEvidence {
    /// The run's event graph and the graph branch's report on it.
    Checked {
        graph: Box<EventGraph>,
        report: Box<GraphReport>,
    },
    /// The ISA's interpreter records no memory events, so nothing speaks for race freedom.
    NotRecorded,
}

impl KernelRun {
    /// The run's outputs against `spec` by `solver`. The outputs are left as the run wrote them.
    /// The Lean solver states nothing of a run whose recorded graph is not `Verified`, so no
    /// prover works on a rejected kernel; runs of an ISA recording no graph claim no race freedom.
    pub fn solve(&mut self, spec: &Spec, solver: &Solver) -> Result<Solution, SolveError> {
        if let (Solver::Lean { .. }, GraphEvidence::Checked { report, .. }) = (solver, &self.graph)
        {
            match report.conclusion() {
                GraphConclusion::Verified => {}
                GraphConclusion::Rejected { failed, deadlock } => {
                    return Err(SolveError::Rejected { failed, deadlock });
                }
                GraphConclusion::Unknown { reasons } => {
                    return Err(SolveError::Incomplete(reasons));
                }
            }
        }
        solve(
            self.outputs.as_mut().map_err(|why| why.as_str()),
            spec,
            solver,
        )
    }

    /// `decide` over `solution` and the run's graph branch; a run without a graph is at best
    /// UNKNOWN.
    pub fn decide(&self, solution: &Solution) -> Decision {
        let (graph, assumptions) = match &self.graph {
            GraphEvidence::Checked { graph, report } => (
                GraphBranch::Checked(report),
                graph.provenance().assumptions.as_slice(),
            ),
            GraphEvidence::NotRecorded => (GraphBranch::NotRecorded, &[][..]),
        };
        let kernels = [KernelEvidence {
            label: "kernel",
            graph,
            assumptions,
        }];
        decide(&solution.verdict(), &kernels)
    }
}

/// Why a frontend could not run a kernel at all.
#[derive(Debug)]
pub enum FrontendError {
    /// The source does not parse; `span` locates the error when the parser reports one.
    Parse {
        title: String,
        message: Option<String>,
        span: Option<Span>,
    },
    /// No kernel was named, and the source does not define exactly one.
    NoDefaultKernel { found: Vec<String> },
    /// The launch asks for something this ISA's interpreter does not model.
    Launch(String),
    /// The kernel cannot run (no such kernel, a lowering error, an invalid configuration).
    Analysis(String),
}

impl fmt::Display for FrontendError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Parse {
                title,
                message: Some(message),
                ..
            } => write!(f, "{title}: {message}"),
            Self::Parse { title, .. } => write!(f, "{title}"),
            Self::NoDefaultKernel { found } if found.is_empty() => {
                write!(f, "the source defines no kernel to default to; name one")
            }
            Self::NoDefaultKernel { found } => write!(
                f,
                "the source defines {} kernels ({}); name one",
                found.len(),
                found.join(", ")
            ),
            Self::Launch(message) => write!(f, "unsupported launch: {message}"),
            Self::Analysis(message) => write!(f, "{message}"),
        }
    }
}

impl std::error::Error for FrontendError {}

#[derive(Debug)]
pub enum SolveError {
    Frontend(FrontendError),
    Spec(volta_spec::SpecError),
    /// The graph branch rejected the run, so the Lean solver states nothing of it.
    Rejected {
        failed: Vec<PropertySummary>,
        deadlock: Option<Deadlock>,
    },
    /// The graph branch left the run unverified, so the Lean solver states nothing of it.
    Incomplete(Vec<String>),
    /// The prover could not run (no Lean toolchain, no agent, an I/O failure).
    Prover(volta_lean::Error),
}

impl fmt::Display for SolveError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Frontend(e) => write!(f, "{e}"),
            Self::Spec(e) => write!(f, "building spec: {e}"),
            Self::Rejected { failed, deadlock } => {
                let reasons = deadlock
                    .iter()
                    .map(|d| {
                        format!(
                            "trace deadlocked with {} blocked thread(s)",
                            d.blocked.len()
                        )
                    })
                    .chain(failed.iter().map(|s| match s.findings.first() {
                        Some(witness) => format!("{} failed: {witness}", s.property.name()),
                        None => format!("{} failed", s.property.name()),
                    }))
                    .collect::<Vec<_>>();
                write!(f, "graph verification REJECTED: {}", reasons.join("; "))
            }
            Self::Incomplete(reasons) => {
                write!(f, "graph verification is UNKNOWN: {}", reasons.join("; "))
            }
            Self::Prover(e) => write!(f, "Lean prover: {e}"),
        }
    }
}

impl std::error::Error for SolveError {}

/// The one kernel of `found`, the kernels a source defines.
fn only_kernel(found: Vec<String>) -> Result<String, FrontendError> {
    match <[String; 1]>::try_from(found) {
        Ok([kernel]) => Ok(kernel),
        Err(found) => Err(FrontendError::NoDefaultKernel { found }),
    }
}
