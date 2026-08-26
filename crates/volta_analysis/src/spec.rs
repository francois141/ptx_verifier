//! Mathematical specifications: describe an output array's contents as a
//! formula over other arrays (e.g. matmul's `C[i,j] = sum_k A[i,k] *
//! B[k,j]`), then unfold the formula into an [`AnalysisOutput`] using the
//! same [`ExprArena`] constructors the interpreter itself uses. The result
//! plugs directly into the existing equivalence pipeline
//! (`driver::paired_elements`, `driver::check_output_equivalence_with`) as
//! a stand-in for a second kernel's output, so a PTX kernel can be checked
//! against a spec exactly the way two kernels are checked against each
//! other.
//!
//! Every bound is concrete: a `Sum`'s range and an output array's shape
//! must resolve to fixed integers under a [`SpecEnv`], because `SpecExpr`
//! builds a fixed `ExprId` DAG by unrolling - the fragment has no
//! reduction/quantifier node. This mirrors the interpreter's own
//! concrete-addressing requirement (`IndexInput`, structured-CTA
//! concreteness): a spec's array indices are restricted to the small
//! affine [`IndexExpr`] sublanguage for the same reason a kernel's
//! addresses must be concrete before a read resolves to one
//! `InputElement`.

use std::collections::HashMap;
use std::fmt;

use crate::eval::{AnalysisOutput, Stats};
use crate::symbolic::{ExprArena, ExprId, NanError, StringId};

/// A row-major shape for flattening a multi-dimensional index into the
/// flat element index that `InputElement` and `AnalysisOutput::outputs`
/// use - the same convention a kernel's own address arithmetic produces
/// (`ArrayDef`'s `elem_width`-scaled offsets), so a spec's reads/writes
/// line up with what the interpreter would have produced.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Shape(Vec<u64>);

impl Shape {
    pub fn new(dims: impl Into<Vec<u64>>) -> Self {
        Shape(dims.into())
    }

    pub fn dims(&self) -> &[u64] {
        &self.0
    }

    pub fn rank(&self) -> usize {
        self.0.len()
    }

    /// Total element count (product of dims; 1 for a rank-0 shape).
    pub fn size(&self) -> u64 {
        self.0.iter().product()
    }

    /// Flatten a multi-dim index (same rank as the shape, each component
    /// already checked in bounds) to a flat row-major element index.
    fn flatten(&self, indices: &[u64]) -> u64 {
        debug_assert_eq!(indices.len(), self.0.len());
        self.0
            .iter()
            .zip(indices)
            .fold(0u64, |flat, (&d, &i)| flat * d + i)
    }

    /// Every multi-dim index in ascending flat order (so `unfold`'s
    /// per-array element list comes out sorted by index, matching
    /// `AnalysisOutput::outputs`'s contract).
    fn indices(&self) -> impl Iterator<Item = Vec<u64>> + '_ {
        (0..self.size()).map(move |mut flat| {
            let mut idx = vec![0u64; self.0.len()];
            for (slot, &d) in idx.iter_mut().zip(&self.0).rev() {
                *slot = flat % d;
                flat /= d;
            }
            idx
        })
    }
}

/// A `Sum`'s loop bound: either a literal, or a name resolved against
/// `SpecEnv::dims` (so the same spec can be reused across configs that
/// share array shapes but differ in e.g. K).
#[derive(Debug, Clone)]
pub enum Bound {
    Const(u64),
    Named(String),
}

impl From<u64> for Bound {
    fn from(v: u64) -> Self {
        Bound::Const(v)
    }
}

/// An index expression: the small affine sublanguage allowed in array
/// index position. Deliberately not full `SpecExpr` - an index must
/// resolve to one concrete `u64` per element, the same requirement a
/// kernel's own address computation is under.
#[derive(Debug, Clone)]
pub enum IndexExpr {
    Int(u64),
    Var(String),
    Add(Box<IndexExpr>, Box<IndexExpr>),
    Mul(Box<IndexExpr>, Box<IndexExpr>),
}

impl IndexExpr {
    pub fn int(v: u64) -> Self {
        IndexExpr::Int(v)
    }

    pub fn var(name: impl Into<String>) -> Self {
        IndexExpr::Var(name.into())
    }
}

impl std::ops::Add for IndexExpr {
    type Output = Self;
    fn add(self, other: Self) -> Self {
        IndexExpr::Add(Box::new(self), Box::new(other))
    }
}

impl std::ops::Mul for IndexExpr {
    type Output = Self;
    fn mul(self, other: Self) -> Self {
        IndexExpr::Mul(Box::new(self), Box::new(other))
    }
}

/// A symbolic math expression: constants, array reads, arithmetic, and
/// `Sum` (unrolled over a concrete range at unfold time). Evaluating one
/// under a `SpecEnv` and a set of bound variables produces an `ExprId` in
/// the target arena - the same kind of node the interpreter would have
/// produced by actually executing a kernel.
#[derive(Debug, Clone)]
pub enum SpecExpr {
    Int(i64),
    Real(f64),
    /// A bound variable: an output index (from `OutputSpec::vars`) or a
    /// `Sum`'s loop variable.
    Var(String),
    /// `array[indices]`, flattened row-major per `SpecEnv::arrays`.
    Index {
        array: String,
        indices: Vec<IndexExpr>,
    },
    Add(Box<SpecExpr>, Box<SpecExpr>),
    Sub(Box<SpecExpr>, Box<SpecExpr>),
    Mul(Box<SpecExpr>, Box<SpecExpr>),
    Div(Box<SpecExpr>, Box<SpecExpr>),
    Neg(Box<SpecExpr>),
    Min(Box<SpecExpr>, Box<SpecExpr>),
    Max(Box<SpecExpr>, Box<SpecExpr>),
    /// `sum_{var=0}^{bound-1} body`, unrolled into `bound` additions.
    Sum {
        var: String,
        bound: Bound,
        body: Box<SpecExpr>,
    },
}

impl SpecExpr {
    pub fn int(v: i64) -> Self {
        SpecExpr::Int(v)
    }

    pub fn real(v: f64) -> Self {
        SpecExpr::Real(v)
    }

    pub fn var(name: impl Into<String>) -> Self {
        SpecExpr::Var(name.into())
    }

    pub fn index(array: impl Into<String>, indices: impl Into<Vec<IndexExpr>>) -> Self {
        SpecExpr::Index {
            array: array.into(),
            indices: indices.into(),
        }
    }

    pub fn min(self, other: Self) -> Self {
        SpecExpr::Min(Box::new(self), Box::new(other))
    }

    pub fn max(self, other: Self) -> Self {
        SpecExpr::Max(Box::new(self), Box::new(other))
    }

    pub fn sum(var: impl Into<String>, bound: impl Into<Bound>, body: Self) -> Self {
        SpecExpr::Sum {
            var: var.into(),
            bound: bound.into(),
            body: Box::new(body),
        }
    }
}

impl std::ops::Add for SpecExpr {
    type Output = Self;
    fn add(self, other: Self) -> Self {
        SpecExpr::Add(Box::new(self), Box::new(other))
    }
}

impl std::ops::Sub for SpecExpr {
    type Output = Self;
    fn sub(self, other: Self) -> Self {
        SpecExpr::Sub(Box::new(self), Box::new(other))
    }
}

impl std::ops::Mul for SpecExpr {
    type Output = Self;
    fn mul(self, other: Self) -> Self {
        SpecExpr::Mul(Box::new(self), Box::new(other))
    }
}

impl std::ops::Div for SpecExpr {
    type Output = Self;
    fn div(self, other: Self) -> Self {
        SpecExpr::Div(Box::new(self), Box::new(other))
    }
}

impl std::ops::Neg for SpecExpr {
    type Output = Self;
    fn neg(self) -> Self {
        SpecExpr::Neg(Box::new(self))
    }
}

/// One output array's definition: for every index in `shape` (row-major),
/// bind `vars[d]` to that dimension's concrete value and evaluate `body`.
/// `vars` must have the same length as `shape`.
#[derive(Debug, Clone)]
pub struct OutputSpec {
    pub array: String,
    pub shape: Shape,
    pub vars: Vec<String>,
    pub body: SpecExpr,
}

/// The concrete context a spec unfolds under: named loop bounds (e.g. `K`
/// in matmul) and the shapes of every array a spec's `SpecExpr::Index`
/// nodes read.
#[derive(Debug, Clone, Default)]
pub struct SpecEnv {
    pub dims: HashMap<String, u64>,
    pub arrays: HashMap<String, Shape>,
}

/// Errors from unfolding a spec: all boundary violations in the spec
/// itself (an unbound variable, an unknown array/dim, a rank or bounds
/// mismatch) or in a float literal (see `NanError`).
#[derive(Debug)]
pub enum SpecError {
    UnboundVar(String),
    UnknownDim(String),
    UnknownArray(String),
    ShapeVarMismatch {
        array: String,
        expected: usize,
        found: usize,
    },
    IndexRankMismatch {
        array: String,
        expected: usize,
        found: usize,
    },
    IndexOutOfBounds {
        array: String,
        index: Vec<u64>,
        shape: Vec<u64>,
    },
    Nan(NanError),
}

impl fmt::Display for SpecError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::UnboundVar(name) => write!(f, "unbound variable '{}'", name),
            Self::UnknownDim(name) => write!(f, "unknown named bound '{}'", name),
            Self::UnknownArray(name) => write!(f, "unknown array '{}'", name),
            Self::ShapeVarMismatch {
                array,
                expected,
                found,
            } => write!(
                f,
                "output '{}': {} shape dims but {} bound variables",
                array, expected, found
            ),
            Self::IndexRankMismatch {
                array,
                expected,
                found,
            } => write!(
                f,
                "array '{}': indexed with {} indices but shape has rank {}",
                array, found, expected
            ),
            Self::IndexOutOfBounds {
                array,
                index,
                shape,
            } => write!(
                f,
                "array '{}': index {:?} out of bounds for shape {:?}",
                array, index, shape
            ),
            Self::Nan(_) => write!(f, "spec contains a NaN float literal"),
        }
    }
}

impl std::error::Error for SpecError {}

impl From<NanError> for SpecError {
    fn from(e: NanError) -> Self {
        Self::Nan(e)
    }
}

/// Unfold every `OutputSpec` into one `AnalysisOutput`, sharing a single
/// arena (so array symbols read by more than one output, or more than
/// once within a `Sum`, share identity - the same `InputElement` node
/// class the interpreter itself would produce for repeated reads).
///
/// `sample` caps each output array's emitted elements to its first
/// `sample` indices in ascending flat order (0 = all), the same
/// each-array-prefix convention `driver::sampled_elements` uses on the
/// decision-check side. Unlike that function, this cap also bounds
/// *construction* cost: a real kernel's output footprint can be far
/// larger than is practical to unroll a `Sum`-heavy spec over (e.g. one
/// row of a 4096x4096x4096 matmul is already a 4096-term sum per
/// element), and `Shape::indices()` is a lazy range map, so `.take(n)`
/// never visits the skipped indices. A caller checking a sampled
/// footprint against this spec must sample the kernel's own output the
/// same way (same prefix length, same ascending order) so the two sides'
/// index sets still match under `driver::paired_elements`.
pub fn unfold(
    specs: &[OutputSpec],
    env: &SpecEnv,
    sample: u64,
) -> Result<AnalysisOutput, SpecError> {
    let mut arena = ExprArena::new();
    let mut array_ids: HashMap<String, StringId> = HashMap::new();
    let mut outputs = Vec::with_capacity(specs.len());
    for spec in specs {
        if spec.vars.len() != spec.shape.rank() {
            return Err(SpecError::ShapeVarMismatch {
                array: spec.array.clone(),
                expected: spec.shape.rank(),
                found: spec.vars.len(),
            });
        }
        let limit = match sample {
            0 => spec.shape.size(),
            n => spec.shape.size().min(n),
        } as usize;
        let mut elems = Vec::with_capacity(limit);
        for idx in spec.shape.indices().take(limit) {
            let bindings: HashMap<String, u64> =
                spec.vars.iter().cloned().zip(idx.iter().copied()).collect();
            let flat = spec.shape.flatten(&idx);
            let value = eval(&spec.body, env, &bindings, &mut arena, &mut array_ids)?;
            elems.push((flat, value));
        }
        outputs.push((spec.array.clone(), elems));
    }
    Ok(AnalysisOutput {
        arena,
        outputs,
        stats: Stats::default(),
        op_counts: Default::default(),
    })
}

fn resolve_bound(bound: &Bound, env: &SpecEnv) -> Result<u64, SpecError> {
    match bound {
        Bound::Const(n) => Ok(*n),
        Bound::Named(name) => env
            .dims
            .get(name)
            .copied()
            .ok_or_else(|| SpecError::UnknownDim(name.clone())),
    }
}

fn eval_index(expr: &IndexExpr, bindings: &HashMap<String, u64>) -> Result<u64, SpecError> {
    match expr {
        IndexExpr::Int(v) => Ok(*v),
        IndexExpr::Var(name) => bindings
            .get(name)
            .copied()
            .ok_or_else(|| SpecError::UnboundVar(name.clone())),
        IndexExpr::Add(a, b) => Ok(eval_index(a, bindings)? + eval_index(b, bindings)?),
        IndexExpr::Mul(a, b) => Ok(eval_index(a, bindings)? * eval_index(b, bindings)?),
    }
}

fn array_string_id(
    array: &str,
    arena: &mut ExprArena,
    array_ids: &mut HashMap<String, StringId>,
) -> StringId {
    *array_ids
        .entry(array.to_string())
        .or_insert_with(|| arena.intern_string(array.to_string()))
}

fn eval(
    expr: &SpecExpr,
    env: &SpecEnv,
    bindings: &HashMap<String, u64>,
    arena: &mut ExprArena,
    array_ids: &mut HashMap<String, StringId>,
) -> Result<ExprId, SpecError> {
    match expr {
        SpecExpr::Int(v) => Ok(arena.int(*v)),
        SpecExpr::Real(v) => Ok(arena.float_from_f64(*v)?),
        SpecExpr::Var(name) => {
            let v = bindings
                .get(name)
                .copied()
                .ok_or_else(|| SpecError::UnboundVar(name.clone()))?;
            Ok(arena.int(v as i64))
        }
        SpecExpr::Index { array, indices } => {
            let shape = env
                .arrays
                .get(array)
                .ok_or_else(|| SpecError::UnknownArray(array.clone()))?;
            if indices.len() != shape.rank() {
                return Err(SpecError::IndexRankMismatch {
                    array: array.clone(),
                    expected: shape.rank(),
                    found: indices.len(),
                });
            }
            let idx: Vec<u64> = indices
                .iter()
                .map(|e| eval_index(e, bindings))
                .collect::<Result<_, _>>()?;
            if idx.iter().zip(shape.dims()).any(|(&i, &d)| i >= d) {
                return Err(SpecError::IndexOutOfBounds {
                    array: array.clone(),
                    index: idx,
                    shape: shape.dims().to_vec(),
                });
            }
            let flat = shape.flatten(&idx);
            let sid = array_string_id(array, arena, array_ids);
            Ok(arena.input_element(sid, flat))
        }
        SpecExpr::Add(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids)?,
                eval(b, env, bindings, arena, array_ids)?,
            );
            Ok(arena.add(a, b))
        }
        SpecExpr::Sub(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids)?,
                eval(b, env, bindings, arena, array_ids)?,
            );
            Ok(arena.sub(a, b))
        }
        SpecExpr::Mul(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids)?,
                eval(b, env, bindings, arena, array_ids)?,
            );
            Ok(arena.mul(a, b))
        }
        SpecExpr::Div(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids)?,
                eval(b, env, bindings, arena, array_ids)?,
            );
            Ok(arena.div(a, b))
        }
        SpecExpr::Neg(a) => {
            let a = eval(a, env, bindings, arena, array_ids)?;
            Ok(arena.neg(a))
        }
        SpecExpr::Min(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids)?,
                eval(b, env, bindings, arena, array_ids)?,
            );
            Ok(arena.min(a, b))
        }
        SpecExpr::Max(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids)?,
                eval(b, env, bindings, arena, array_ids)?,
            );
            Ok(arena.max(a, b))
        }
        SpecExpr::Sum { var, bound, body } => {
            let n = resolve_bound(bound, env)?;
            let mut acc = arena.int(0);
            for i in 0..n {
                let mut inner = bindings.clone();
                inner.insert(var.clone(), i);
                let term = eval(body, env, &inner, arena, array_ids)?;
                acc = arena.add(acc, term);
            }
            Ok(acc)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::driver::{EquivCheckOptions, EquivOutcome, check_output_equivalence_with};

    /// `C[i,j] = sum_k A[i,k] * B[k,j]` over an M x N x K env.
    fn matmul_spec() -> Vec<OutputSpec> {
        let body = SpecExpr::sum(
            "k",
            Bound::Named("K".to_string()),
            SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("k")])
                * SpecExpr::index("B", vec![IndexExpr::var("k"), IndexExpr::var("j")]),
        );
        vec![OutputSpec {
            array: "C".to_string(),
            shape: Shape::new(vec![2, 2]),
            vars: vec!["i".to_string(), "j".to_string()],
            body,
        }]
    }

    fn matmul_env() -> SpecEnv {
        SpecEnv {
            dims: HashMap::from([("K".to_string(), 3)]),
            arrays: HashMap::from([
                ("A".to_string(), Shape::new(vec![2, 3])),
                ("B".to_string(), Shape::new(vec![3, 2])),
            ]),
        }
    }

    #[test]
    fn unfold_produces_one_element_per_output_index_in_ascending_order() {
        let output = unfold(&matmul_spec(), &matmul_env(), 0).unwrap();
        assert_eq!(output.outputs.len(), 1);
        let (name, elems) = &output.outputs[0];
        assert_eq!(name, "C");
        let indices: Vec<u64> = elems.iter().map(|&(i, _)| i).collect();
        assert_eq!(indices, vec![0, 1, 2, 3]);
    }

    /// The whole point of the module: a spec's unfolded `AnalysisOutput`
    /// must be a valid right-hand side for the same equivalence pipeline
    /// used to compare two kernels. Build the matmul sum a second, more
    /// direct way (manual `Fma` chain over the same `InputElement`s) and
    /// check the two sides through `check_output_equivalence_with`
    /// unchanged - if this passes, `unfold`'s output is exactly the kind
    /// of `ExprId` tree the rest of the pipeline expects.
    #[test]
    fn unfolded_matmul_is_equivalent_to_a_hand_built_reference() {
        let spec_output = unfold(&matmul_spec(), &matmul_env(), 0).unwrap();

        let mut arena = ExprArena::new();
        let a = arena.intern_string("A");
        let b = arena.intern_string("B");
        let mut elems = Vec::new();
        for i in 0u64..2 {
            for j in 0u64..2 {
                let mut acc = arena.int(0);
                for k in 0u64..3 {
                    let av = arena.input_element(a, i * 3 + k);
                    let bv = arena.input_element(b, k * 2 + j);
                    let term = arena.mul(av, bv);
                    acc = arena.add(acc, term);
                }
                elems.push((i * 2 + j, acc));
            }
        }
        let hand_built = AnalysisOutput {
            arena,
            outputs: vec![("C".to_string(), elems)],
            stats: Stats::default(),
            op_counts: Default::default(),
        };

        let report = check_output_equivalence_with(
            &spec_output,
            &hand_built,
            &["C".to_string()],
            &EquivCheckOptions::default(),
        )
        .unwrap();
        assert!(matches!(report.outcome, EquivOutcome::Equivalent));
        assert_eq!(report.elements_checked, 4);
    }

    #[test]
    fn unbound_index_variable_is_rejected() {
        let body = SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("missing")]);
        let specs = vec![OutputSpec {
            array: "C".to_string(),
            shape: Shape::new(vec![1, 1]),
            vars: vec!["i".to_string(), "j".to_string()],
            body,
        }];
        let env = SpecEnv {
            dims: HashMap::new(),
            arrays: HashMap::from([("A".to_string(), Shape::new(vec![1, 1]))]),
        };
        assert!(matches!(
            unfold(&specs, &env, 0),
            Err(SpecError::UnboundVar(name)) if name == "missing"
        ));
    }

    #[test]
    fn out_of_bounds_index_is_rejected() {
        let body = SpecExpr::index("A", vec![IndexExpr::var("i")]);
        let specs = vec![OutputSpec {
            array: "C".to_string(),
            shape: Shape::new(vec![5]),
            vars: vec!["i".to_string()],
            body,
        }];
        let env = SpecEnv {
            dims: HashMap::new(),
            arrays: HashMap::from([("A".to_string(), Shape::new(vec![3]))]),
        };
        assert!(matches!(
            unfold(&specs, &env, 0),
            Err(SpecError::IndexOutOfBounds { .. })
        ));
    }
}
