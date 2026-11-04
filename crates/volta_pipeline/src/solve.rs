//! A kernel's outputs against a spec: the kernel must write exactly the spec's elements, then
//! the canonical decision procedure decides each one.

use std::collections::HashMap;
use std::fmt;

use volta_equivalence::check::{EquivCheckOptions, EquivCheckReport};
use volta_expr::SymbolicOutputs;
use volta_spec::{InstantiateErrorKind, OutputSpec, ParsedSpec, SpecEnv, SpecError};

use crate::equivalence::{EquivalenceVerdict, check_equivalence};

/// A spec at concrete dims: for each array it defines, the value of every element.
#[derive(Debug)]
pub struct Spec {
    env: SpecEnv,
    outputs: Vec<OutputSpec>,
    arrays: Vec<String>,
}

#[derive(Debug)]
pub enum InvalidSpec {
    Instantiate(InstantiateErrorKind),
    /// The spec defines no output array, so there is nothing to check.
    NoOutputs,
}

impl fmt::Display for InvalidSpec {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Instantiate(e) => write!(f, "{e}"),
            Self::NoOutputs => write!(f, "spec declares no output equations to check"),
        }
    }
}

impl std::error::Error for InvalidSpec {}

impl Spec {
    pub fn new(parsed: &ParsedSpec, dims: &HashMap<String, u64>) -> Result<Self, InvalidSpec> {
        let (env, outputs) =
            volta_spec::instantiate(parsed, dims).map_err(InvalidSpec::Instantiate)?;
        let mut arrays: Vec<String> = Vec::new();
        for output in &parsed.outputs {
            if !arrays.contains(&output.array) {
                arrays.push(output.array.clone());
            }
        }
        if arrays.is_empty() {
            return Err(InvalidSpec::NoOutputs);
        }
        Ok(Self {
            env,
            outputs,
            arrays,
        })
    }

    /// The arrays the spec defines, in declaration order: the arrays a kernel is checked on.
    pub fn arrays(&self) -> &[String] {
        &self.arrays
    }

    /// The first array `kernel` does not write exactly the spec's indices of: each spec
    /// output defines every flat index of its shape.
    fn index_set_mismatch(&self, kernel: &SymbolicOutputs) -> Option<EquivalenceVerdict> {
        self.arrays.iter().find_map(|name| {
            let expected = self
                .outputs
                .iter()
                .filter(|s| &s.array == name)
                .map(|s| s.shape.size())
                .max()
                .unwrap_or(0);
            let written: Vec<u64> = kernel
                .outputs
                .iter()
                .find(|(n, _)| n == name)
                .map_or_else(Vec::new, |(_, elems)| {
                    elems.iter().map(|&(index, _)| index).collect()
                });
            let unwritten: Vec<u64> = (0..expected)
                .filter(|index| written.binary_search(index).is_err())
                .collect();
            let unexpected: Vec<u64> = written.iter().copied().filter(|&i| i >= expected).collect();
            (!unwritten.is_empty() || !unexpected.is_empty()).then(|| {
                EquivalenceVerdict::IndexSetMismatch {
                    array: name.clone(),
                    unwritten,
                    unexpected,
                }
            })
        })
    }
}

/// The canonical solver's verdict on `kernel` against `spec`, with its report when it ran.
/// `options.sample` also caps the spec's unfolding (a Sum-heavy spec over a big footprint is
/// impractical to unroll), so `kernel` is compared on that prefix of each array, then restored.
pub fn check_against_spec(
    kernel: &mut SymbolicOutputs,
    spec: &Spec,
    options: &EquivCheckOptions,
) -> Result<(EquivalenceVerdict, Option<EquivCheckReport>), SpecError> {
    // Before sampling truncates either side, so a sampled prefix cannot hide an unwritten element.
    if let Some(mismatch) = spec.index_set_mismatch(kernel) {
        return Ok((mismatch, None));
    }
    let untruncated: u64 = kernel
        .outputs
        .iter()
        .filter(|(n, _)| spec.arrays.contains(n))
        .map(|(_, elems)| elems.len() as u64)
        .sum();
    let baseline = volta_spec::unfold(&spec.outputs, &spec.env, options.sample)?;
    let written = (options.sample > 0).then(|| {
        let written = kernel.outputs.clone();
        for (name, elems) in &mut kernel.outputs {
            if spec.arrays.contains(name) {
                elems.truncate(options.sample as usize);
            }
        }
        written
    });
    let (mut verdict, report) = check_equivalence(kernel, &baseline, &spec.arrays, options);
    if let Some(written) = written {
        kernel.outputs = written;
    }
    if let EquivalenceVerdict::Equivalent { checked, total } = &mut verdict {
        *total = (*total).max(untruncated);
        *checked = (*checked).min(*total);
    }
    Ok((verdict, report))
}
