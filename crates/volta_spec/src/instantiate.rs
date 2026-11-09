//! Turn a [`ParsedSpec`] (named, symbolic dims) into the concrete
//! `(SpecEnv, Vec<OutputSpec>)` pair `crate::spec::unfold` needs, given a value
//! for every declared `dim`. Separate from parsing so one parsed spec serves many sizes.

use std::collections::{HashMap, HashSet};
use std::fmt;

use crate::spec::{OutputSpec, Shape, SpecEnv};

use crate::ast::{Elements, Padding, ParsedSpec};

#[derive(Debug)]
pub enum InstantiateErrorKind {
    /// A `dim` the spec declares has no caller-supplied value.
    MissingDimValue(String),
    /// An `array`'s shape references a dim name never declared via `dim`.
    UnknownDim(String),
    DuplicateDim(String),
    DuplicateParam(String),
    DuplicateArray(String),
    /// An output equation's LHS array was never declared via `array`.
    UnknownArray(String),
    /// An index array with no caller-supplied integers.
    MissingIndices(String),
    /// Integers supplied for an array that is not declared `index`.
    NotAnIndexArray(String),
    /// An index array's integers, not one per element of its shape.
    IndicesLength {
        array: String,
        expected: u64,
        found: usize,
    },
    /// An output equation defining an index array, whose integers the caller gives.
    IndexArrayOutput(String),
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
            Self::DuplicateParam(name) => {
                write!(
                    f,
                    "param '{}' declared more than once (or also as a dim)",
                    name
                )
            }
            Self::DuplicateArray(name) => write!(f, "array '{}' declared more than once", name),
            Self::UnknownArray(name) => write!(
                f,
                "output equation for '{}', which was never declared as an array",
                name
            ),
            Self::MissingIndices(name) => {
                write!(f, "no integers given for index array '{name}'")
            }
            Self::NotAnIndexArray(name) => {
                write!(
                    f,
                    "integers given for '{name}', which is not an index array"
                )
            }
            Self::IndicesLength {
                array,
                expected,
                found,
            } => write!(
                f,
                "{found} integers given for index array '{array}' of {expected} elements"
            ),
            Self::IndexArrayOutput(name) => {
                write!(f, "output equation for index array '{name}'")
            }
        }
    }
}

impl std::error::Error for InstantiateErrorKind {}

/// Resolve `spec` under `dim_values` (dim name -> concrete value) into the
/// `(SpecEnv, Vec<OutputSpec>)` pair ready for `spec::unfold`; `spec` has no index arrays.
pub fn instantiate(
    spec: &ParsedSpec,
    dim_values: &HashMap<String, u64>,
) -> Result<(SpecEnv, Vec<OutputSpec>), InstantiateErrorKind> {
    instantiate_with_indices(spec, dim_values, &HashMap::new())
}

/// `instantiate`, with each index array's integers, row-major, from `indices`.
pub fn instantiate_with_indices(
    spec: &ParsedSpec,
    dim_values: &HashMap<String, u64>,
    indices: &HashMap<String, Vec<i64>>,
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

    let mut params = HashSet::with_capacity(spec.params.len());
    for p in &spec.params {
        if dims.contains_key(&p.name) || !params.insert(p.name.clone()) {
            return Err(InstantiateErrorKind::DuplicateParam(p.name.clone()));
        }
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

    let mut given = HashMap::new();
    for a in &spec.arrays {
        if a.elements != Elements::Indices {
            continue;
        }
        let values = indices
            .get(&a.name)
            .ok_or_else(|| InstantiateErrorKind::MissingIndices(a.name.clone()))?;
        let expected = arrays[&a.name].size();
        if values.len() as u64 != expected {
            return Err(InstantiateErrorKind::IndicesLength {
                array: a.name.clone(),
                expected,
                found: values.len(),
            });
        }
        given.insert(a.name.clone(), values.clone());
    }
    if let Some(name) = indices.keys().find(|name| !given.contains_key(*name)) {
        return Err(InstantiateErrorKind::NotAnIndexArray(name.clone()));
    }

    let outputs = spec
        .outputs
        .iter()
        .map(|o| {
            if given.contains_key(&o.array) {
                return Err(InstantiateErrorKind::IndexArrayOutput(o.array.clone()));
            }
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

    let zero_padded = spec
        .arrays
        .iter()
        .filter(|a| a.padding == Padding::Zero)
        .map(|a| a.name.clone())
        .collect();
    Ok((
        SpecEnv {
            dims,
            arrays,
            params,
            zero_padded,
            indices: given,
        },
        outputs,
    ))
}
