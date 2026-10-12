//! Volta Benchmark Suite: reproduces the evaluation of "Equivalence Checking of ML GPU
//! Kernels" (Tables 1-7, Section 6.2: reductions, matmuls, attention, conv, GEMMs,
//! TileLang, FaialAA races) over the PTX collected in `kernels/`.

pub mod benchmarks;
pub mod config;
pub mod manifest;
pub mod reporter;
pub mod results;
pub mod runner;
pub mod solve;
pub mod z3_phase;

pub use benchmarks::all_benchmarks;
pub use config::{BenchmarkCategory, BenchmarkDef, BenchmarkSuite, ExpectedOutcome, KernelRun};
pub use reporter::{
    TableMode, print_all_results, print_results_table, print_single_result, print_summary,
};
pub use runner::{ActualOutcome, BenchmarkResult, BenchmarkRunner, BenchmarkStats, RunnerConfig};
pub use solve::{RACE_SKIP_NOTE, SolveBackend, SolveItem};
pub use z3_phase::{Z3ModeRun, Z3Options, Z3Phase, Z3PhaseOutcome};

/// Default kernels directory: the paper benchmark collection.
pub const KERNELS_DIR: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/kernels");
