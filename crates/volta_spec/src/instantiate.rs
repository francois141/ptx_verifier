//! Turn a [`ParsedSpec`] (named dims, still symbolic) into the concrete
//! `(SpecEnv, Vec<OutputSpec>)` pair `volta_analysis::spec::unfold` needs,
//! given a caller-supplied value for every declared `dim`. Kept separate
//! from parsing so the same parsed spec is reusable across dim values
//! (e.g. checking the same `matmul.spec` file at several sizes) without
//! re-parsing.

use std::collections::HashMap;
use std::fmt;

use volta_analysis::spec::{OutputSpec, Shape, SpecEnv};

use crate::ast::ParsedSpec;

#[derive(Debug)]
pub enum InstantiateErrorKind {
    /// A `dim` the spec declares has no caller-supplied value.
    MissingDimValue(String),
    /// An `array`'s shape references a dim name never declared via `dim`.
    UnknownDim(String),
    DuplicateDim(String),
    DuplicateArray(String),
    /// An output equation's LHS array was never declared via `array`.
    UnknownArray(String),
}

impl fmt::Display for InstantiateErrorKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::MissingDimValue(name) => {
                write!(f, "no value given for dim '{}'", name)
            }
            Self::UnknownDim(name) => {
                write!(f, "reference to dim '{}', which was never declared", name)
            }
            Self::DuplicateDim(name) => write!(f, "dim '{}' declared more than once", name),
            Self::DuplicateArray(name) => write!(f, "array '{}' declared more than once", name),
            Self::UnknownArray(name) => write!(
                f,
                "output equation for '{}', which was never declared as an array",
                name
            ),
        }
    }
}

impl std::error::Error for InstantiateErrorKind {}

/// Resolve `spec` under `dim_values` (dim name -> concrete value) into the
/// `(SpecEnv, Vec<OutputSpec>)` pair ready for `spec::unfold`.
pub fn instantiate(
    spec: &ParsedSpec,
    dim_values: &HashMap<String, u64>,
) -> Result<(SpecEnv, Vec<OutputSpec>), InstantiateErrorKind> {
    let mut dims = HashMap::with_capacity(spec.dims.len());
    for d in &spec.dims {
        if dims.contains_key(&d.name) {
            return Err(InstantiateErrorKind::DuplicateDim(d.name.clone()));
        }
        let value = dim_values
            .get(&d.name)
            .copied()
            .ok_or_else(|| InstantiateErrorKind::MissingDimValue(d.name.clone()))?;
        dims.insert(d.name.clone(), value);
    }

    let mut arrays = HashMap::with_capacity(spec.arrays.len());
    for a in &spec.arrays {
        if arrays.contains_key(&a.name) {
            return Err(InstantiateErrorKind::DuplicateArray(a.name.clone()));
        }
        let resolved_dims: Vec<u64> = a
            .dims
            .iter()
            .map(|d| {
                dims.get(d)
                    .copied()
                    .ok_or_else(|| InstantiateErrorKind::UnknownDim(d.clone()))
            })
            .collect::<Result<_, _>>()?;
        arrays.insert(a.name.clone(), Shape::new(resolved_dims));
    }

    let outputs = spec
        .outputs
        .iter()
        .map(|o| {
            let shape = arrays
                .get(&o.array)
                .cloned()
                .ok_or_else(|| InstantiateErrorKind::UnknownArray(o.array.clone()))?;
            Ok(OutputSpec {
                array: o.array.clone(),
                shape,
                vars: o.vars.clone(),
                body: o.body.clone(),
            })
        })
        .collect::<Result<Vec<_>, InstantiateErrorKind>>()?;

    Ok((SpecEnv { dims, arrays }, outputs))
}
