//! Benchmark configuration types: one kernel (race check) or a
//! reference/optimized pair (equivalence check), each with a full
//! `AnalysisConfig`.

use volta_analysis::eval::{AnalysisConfig, ArrayDef, ArrayKind};

/// Category of benchmark (maps to paper sections)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum BenchmarkCategory {
    /// Harris reduction tutorial (Table 1)
    Reduction,
    /// Boehm matmul tutorial (Table 2)
    MatMul,
    /// Flash attention variants (Table 3)
    Attention,
    /// Causal attention, fused vs naive masking (Table 4)
    CausalAttention,
    /// LLM-generated convolution (Section 6.2)
    Convolution,
    /// Claude Code generated GEMM (Table 5)
    AgentGenerated,
    /// TileLang compiler generated (Table 6)
    CompilerGenerated,
    /// FaialAA data race benchmarks (Table 7)
    DataRace,
}

impl BenchmarkCategory {
    pub fn name(&self) -> &'static str {
        match self {
            Self::Reduction => "Reduction",
            Self::MatMul => "Matrix Multiplication",
            Self::Attention => "Attention",
            Self::CausalAttention => "Causal Attention",
            Self::Convolution => "Convolution",
            Self::AgentGenerated => "Agent-Generated GEMM",
            Self::CompilerGenerated => "Compiler-Generated (TileLang)",
            Self::DataRace => "Data Race Detection",
        }
    }

    pub fn table_ref(&self) -> &'static str {
        match self {
            Self::Reduction => "Table 1",
            Self::MatMul => "Table 2",
            Self::Attention => "Table 3",
            Self::CausalAttention => "Table 4",
            Self::Convolution => "Section 6.2",
            Self::AgentGenerated => "Table 5",
            Self::CompilerGenerated => "Table 6",
            Self::DataRace => "Table 7",
        }
    }

    pub fn all() -> [Self; 8] {
        [
            Self::Reduction,
            Self::MatMul,
            Self::Attention,
            Self::CausalAttention,
            Self::Convolution,
            Self::AgentGenerated,
            Self::CompilerGenerated,
            Self::DataRace,
        ]
    }
}

/// Expected outcome of a benchmark
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExpectedOutcome {
    /// Kernels should be proven equivalent
    Equivalent,
    /// An error rejecting the kernel should be reported (data race, or
    /// another soundness error such as an out-of-bounds/uninitialized access)
    DataRace,
    /// Kernel should be proven race-free
    RaceFree,
}

/// One kernel to analyze under a specific configuration.
#[derive(Debug, Clone)]
pub struct KernelRun {
    /// Path relative to the benchmarks kernels directory
    pub path: String,
    /// Kernel entry name (mangled)
    pub kernel: String,
    pub config: AnalysisConfig,
}

impl KernelRun {
    pub fn new(path: &str, kernel: &str, config: AnalysisConfig) -> Self {
        Self {
            path: path.to_string(),
            kernel: kernel.to_string(),
            config,
        }
    }
}

/// A single benchmark definition
#[derive(Debug, Clone)]
pub struct BenchmarkDef {
    /// Display name (e.g. "(Red-1, Red-2)")
    pub name: String,
    pub category: BenchmarkCategory,
    pub expected: ExpectedOutcome,
    pub reference: KernelRun,
    /// Present for equivalence benchmarks
    pub optimized: Option<KernelRun>,
}

impl BenchmarkDef {
    pub fn equivalence(
        name: impl Into<String>,
        category: BenchmarkCategory,
        reference: KernelRun,
        optimized: KernelRun,
    ) -> Self {
        Self {
            name: name.into(),
            category,
            expected: ExpectedOutcome::Equivalent,
            reference,
            optimized: Some(optimized),
        }
    }

    pub fn race_check(
        name: impl Into<String>,
        category: BenchmarkCategory,
        kernel: KernelRun,
        expect_race: bool,
    ) -> Self {
        Self {
            name: name.into(),
            category,
            expected: if expect_race {
                ExpectedOutcome::DataRace
            } else {
                ExpectedOutcome::RaceFree
            },
            reference: kernel,
            optimized: None,
        }
    }
}

/// A suite of benchmarks
#[derive(Debug, Clone, Default)]
pub struct BenchmarkSuite {
    pub benchmarks: Vec<BenchmarkDef>,
}

impl BenchmarkSuite {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn extend(&mut self, benchmarks: impl IntoIterator<Item = BenchmarkDef>) {
        self.benchmarks.extend(benchmarks);
    }

    pub fn filter_category(&self, category: BenchmarkCategory) -> Vec<&BenchmarkDef> {
        self.benchmarks
            .iter()
            .filter(|b| b.category == category)
            .collect()
    }

    pub fn categories(&self) -> Vec<BenchmarkCategory> {
        BenchmarkCategory::all()
            .into_iter()
            .filter(|c| self.benchmarks.iter().any(|b| b.category == *c))
            .collect()
    }
}

// =========================================================================
// Array helpers shared by benchmark definitions
// =========================================================================

fn array(name: &str, base: u64, elem_width: u64, len: u64, kind: ArrayKind) -> ArrayDef {
    ArrayDef {
        name: name.to_string(),
        base,
        elem_width,
        len,
        kind,
    }
}

pub fn f32_input(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::Input)
}

pub fn f32_output(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::Output)
}

pub fn f32_inout(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::InputOutput)
}

// `u32` arrays share `f32`'s 4-byte layout (`ArrayDef` has no element
// type, only a width); the prefix documents intent.

pub fn u32_input(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::Input)
}

pub fn u32_output(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::Output)
}

pub fn u32_inout(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::InputOutput)
}

/// An index array: element `i` holds the concrete value `i`.
pub fn u32_index(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 4, len, ArrayKind::IndexInput)
}

pub fn f16_input(name: &str, base: u64, len: u64) -> ArrayDef {
    array(name, base, 2, len, ArrayKind::Input)
}
