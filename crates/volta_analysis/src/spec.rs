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

/// A reduction's (`sum`/`max`) loop bound: either a literal, or a name
/// resolved against `SpecEnv::dims` (so the same spec can be reused across
/// configs that share array shapes but differ in e.g. K).
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

/// The operator combining a reduction's terms. A typed enum rather than a
/// bool so the empty-range identity (`sum` = 0, `max` = -infinity) and any
/// future addition stay exhaustively matched instead of silently falling
/// through a `sum: bool` flag.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ReduceOp {
    Sum,
    Max,
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
/// `Reduce` (unrolled over a concrete range at unfold time). Evaluating one
/// under a `SpecEnv` and a set of bound variables produces an `ExprId` in
/// the target arena - the same kind of node the interpreter would have
/// produced by actually executing a kernel.
#[derive(Debug, Clone)]
pub enum SpecExpr {
    Int(i64),
    Real(f64),
    /// A bound variable: an output index (from `OutputSpec::vars`) or a
    /// `Reduce`'s loop variable.
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
    Exp(Box<SpecExpr>),
    Log(Box<SpecExpr>),
    Sqrt(Box<SpecExpr>),
    Abs(Box<SpecExpr>),
    /// `op_{var=0}^{bound-1} body`, unrolled into `bound` terms combined by
    /// `op` (`Sum`'s identity for an empty range is `0`; `Max`'s is
    /// `-infinity`, matching `ExprArena::max`'s running-max chain
    /// convention).
    Reduce {
        op: ReduceOp,
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

    pub fn exp(self) -> Self {
        SpecExpr::Exp(Box::new(self))
    }

    pub fn log(self) -> Self {
        SpecExpr::Log(Box::new(self))
    }

    pub fn sqrt(self) -> Self {
        SpecExpr::Sqrt(Box::new(self))
    }

    pub fn abs(self) -> Self {
        SpecExpr::Abs(Box::new(self))
    }

    pub fn reduce(
        op: ReduceOp,
        var: impl Into<String>,
        bound: impl Into<Bound>,
        body: Self,
    ) -> Self {
        SpecExpr::Reduce {
            op,
            var: var.into(),
            bound: bound.into(),
            body: Box::new(body),
        }
    }

    pub fn sum(var: impl Into<String>, bound: impl Into<Bound>, body: Self) -> Self {
        Self::reduce(ReduceOp::Sum, var, bound, body)
    }

    pub fn max_reduce(var: impl Into<String>, bound: impl Into<Bound>, body: Self) -> Self {
        Self::reduce(ReduceOp::Max, var, bound, body)
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
    let mut memo: ReduceMemo = HashMap::new();
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
            let value = eval(
                &spec.body,
                env,
                &bindings,
                &mut arena,
                &mut array_ids,
                &mut memo,
            )?;
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

/// Resolve a bare name in expression/index position: a bound variable
/// (an output index or a `Sum`'s loop variable) takes precedence, falling
/// back to a `dim`'s concrete value so e.g. `sum(...) / N` can reference a
/// declared `dim` directly instead of requiring its value hardcoded as a
/// literal at every call site.
fn resolve_var(
    name: &str,
    env: &SpecEnv,
    bindings: &HashMap<String, u64>,
) -> Result<u64, SpecError> {
    bindings
        .get(name)
        .copied()
        .or_else(|| env.dims.get(name).copied())
        .ok_or_else(|| SpecError::UnboundVar(name.to_string()))
}

fn eval_index(
    expr: &IndexExpr,
    env: &SpecEnv,
    bindings: &HashMap<String, u64>,
) -> Result<u64, SpecError> {
    match expr {
        IndexExpr::Int(v) => Ok(*v),
        IndexExpr::Var(name) => resolve_var(name, env, bindings),
        IndexExpr::Add(a, b) => Ok(eval_index(a, env, bindings)? + eval_index(b, env, bindings)?),
        IndexExpr::Mul(a, b) => Ok(eval_index(a, env, bindings)? * eval_index(b, env, bindings)?),
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

/// Cache for `Reduce` results, keyed on a reduction site (the `SpecExpr`
/// node's address - stable for one `unfold` call, since `specs` is
/// borrowed and never reallocated) plus the *relevant* subset of the
/// enclosing bindings: the free variables the reduction's body actually
/// reads, excluding its own loop variable. Two evaluations of the same
/// site with the same relevant bindings always produce the same result
/// (`env` and the rest of the arena's history don't affect it), so this
/// turns the O(elements x range) unrolling a naively-recomputed reduction
/// would cost into O(distinct relevant-binding tuples x range) - e.g. a
/// softmax row's denominator/max, invariant in the output column index,
/// gets built once per row instead of once per element.
type ReduceMemo = HashMap<(usize, Vec<(String, u64)>), ExprId>;

/// The variable names `expr` reads (for `Reduce`'s memo key): a nested
/// `Reduce`'s own loop variable is excluded from its body's contribution
/// (standard capture), but anything else propagates up.
fn free_vars(expr: &SpecExpr, out: &mut std::collections::HashSet<String>) {
    match expr {
        SpecExpr::Int(_) | SpecExpr::Real(_) => {}
        SpecExpr::Var(name) => {
            out.insert(name.clone());
        }
        SpecExpr::Index { indices, .. } => {
            for idx in indices {
                index_free_vars(idx, out);
            }
        }
        SpecExpr::Add(a, b)
        | SpecExpr::Sub(a, b)
        | SpecExpr::Mul(a, b)
        | SpecExpr::Div(a, b)
        | SpecExpr::Min(a, b)
        | SpecExpr::Max(a, b) => {
            free_vars(a, out);
            free_vars(b, out);
        }
        SpecExpr::Neg(a)
        | SpecExpr::Exp(a)
        | SpecExpr::Log(a)
        | SpecExpr::Sqrt(a)
        | SpecExpr::Abs(a) => {
            free_vars(a, out);
        }
        SpecExpr::Reduce { var, body, .. } => {
            let mut inner = std::collections::HashSet::new();
            free_vars(body, &mut inner);
            inner.remove(var);
            out.extend(inner);
        }
    }
}

fn index_free_vars(expr: &IndexExpr, out: &mut std::collections::HashSet<String>) {
    match expr {
        IndexExpr::Int(_) => {}
        IndexExpr::Var(name) => {
            out.insert(name.clone());
        }
        IndexExpr::Add(a, b) | IndexExpr::Mul(a, b) => {
            index_free_vars(a, out);
            index_free_vars(b, out);
        }
    }
}

#[allow(clippy::too_many_arguments)]
fn eval_reduce(
    site: &SpecExpr,
    op: ReduceOp,
    var: &str,
    bound: &Bound,
    body: &SpecExpr,
    env: &SpecEnv,
    bindings: &HashMap<String, u64>,
    arena: &mut ExprArena,
    array_ids: &mut HashMap<String, StringId>,
    memo: &mut ReduceMemo,
) -> Result<ExprId, SpecError> {
    let mut relevant = std::collections::HashSet::new();
    free_vars(body, &mut relevant);
    relevant.remove(var);
    let mut key_vars: Vec<(String, u64)> = relevant
        .into_iter()
        .filter_map(|name| bindings.get(&name).map(|&v| (name, v)))
        .collect();
    key_vars.sort();
    let key = (site as *const SpecExpr as usize, key_vars);
    if let Some(&cached) = memo.get(&key) {
        return Ok(cached);
    }

    let n = resolve_bound(bound, env)?;
    let mut inner = bindings.clone();
    let result = match op {
        ReduceOp::Sum => {
            let mut acc = arena.int(0);
            for i in 0..n {
                inner.insert(var.to_string(), i);
                let term = eval(body, env, &inner, arena, array_ids, memo)?;
                acc = arena.add(acc, term);
            }
            acc
        }
        ReduceOp::Max => {
            // Empty range -> -infinity, the same running-max identity
            // `ExprArena::max` already uses for its chains.
            let mut acc = arena.float_from_f64(f64::NEG_INFINITY)?;
            for i in 0..n {
                inner.insert(var.to_string(), i);
                let term = eval(body, env, &inner, arena, array_ids, memo)?;
                acc = arena.max(acc, term);
            }
            acc
        }
    };
    memo.insert(key, result);
    Ok(result)
}

fn eval(
    expr: &SpecExpr,
    env: &SpecEnv,
    bindings: &HashMap<String, u64>,
    arena: &mut ExprArena,
    array_ids: &mut HashMap<String, StringId>,
    memo: &mut ReduceMemo,
) -> Result<ExprId, SpecError> {
    match expr {
        SpecExpr::Int(v) => Ok(arena.int(*v)),
        SpecExpr::Real(v) => Ok(arena.float_from_f64(*v)?),
        SpecExpr::Var(name) => {
            let v = resolve_var(name, env, bindings)?;
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
                .map(|e| eval_index(e, env, bindings))
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
                eval(a, env, bindings, arena, array_ids, memo)?,
                eval(b, env, bindings, arena, array_ids, memo)?,
            );
            Ok(arena.add(a, b))
        }
        SpecExpr::Sub(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids, memo)?,
                eval(b, env, bindings, arena, array_ids, memo)?,
            );
            Ok(arena.sub(a, b))
        }
        SpecExpr::Mul(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids, memo)?,
                eval(b, env, bindings, arena, array_ids, memo)?,
            );
            Ok(arena.mul(a, b))
        }
        SpecExpr::Div(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids, memo)?,
                eval(b, env, bindings, arena, array_ids, memo)?,
            );
            Ok(arena.div(a, b))
        }
        SpecExpr::Neg(a) => {
            let a = eval(a, env, bindings, arena, array_ids, memo)?;
            Ok(arena.neg(a))
        }
        SpecExpr::Min(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids, memo)?,
                eval(b, env, bindings, arena, array_ids, memo)?,
            );
            Ok(arena.min(a, b))
        }
        SpecExpr::Max(a, b) => {
            let (a, b) = (
                eval(a, env, bindings, arena, array_ids, memo)?,
                eval(b, env, bindings, arena, array_ids, memo)?,
            );
            Ok(arena.max(a, b))
        }
        SpecExpr::Exp(a) => {
            let a = eval(a, env, bindings, arena, array_ids, memo)?;
            Ok(arena.exp(a))
        }
        SpecExpr::Log(a) => {
            let a = eval(a, env, bindings, arena, array_ids, memo)?;
            Ok(arena.log(a))
        }
        SpecExpr::Sqrt(a) => {
            let a = eval(a, env, bindings, arena, array_ids, memo)?;
            Ok(arena.sqrt(a))
        }
        SpecExpr::Abs(a) => {
            let a = eval(a, env, bindings, arena, array_ids, memo)?;
            Ok(arena.abs(a))
        }
        SpecExpr::Reduce {
            op,
            var,
            bound,
            body,
        } => eval_reduce(
            expr, *op, var, bound, body, env, bindings, arena, array_ids, memo,
        ),
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

    /// A `dim`'s concrete value must be usable directly as a plain
    /// numeric value in an expression body (e.g. a mean's divisor), not
    /// just as a `Sum` bound or an array's shape dimension - regression
    /// test for the gap where `SpecExpr::Var`/`IndexExpr::Var` only
    /// checked `bindings` and never fell back to `SpecEnv::dims`.
    #[test]
    fn dim_value_is_usable_directly_in_an_expression() {
        // mean[i] = sum(j in 0..N, A[i,j]) / N
        let body = SpecExpr::sum(
            "j",
            Bound::Named("N".to_string()),
            SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("j")]),
        ) / SpecExpr::var("N");
        let specs = vec![OutputSpec {
            array: "mean".to_string(),
            shape: Shape::new(vec![2]),
            vars: vec!["i".to_string()],
            body,
        }];
        let env = SpecEnv {
            dims: HashMap::from([("N".to_string(), 4)]),
            arrays: HashMap::from([("A".to_string(), Shape::new(vec![2, 4]))]),
        };
        let output = unfold(&specs, &env, 0).unwrap();

        let mut hand_arena = ExprArena::new();
        let a = hand_arena.intern_string("A");
        let mut elems = Vec::new();
        for i in 0u64..2 {
            let mut acc = hand_arena.int(0);
            for j in 0u64..4 {
                let term = hand_arena.input_element(a, i * 4 + j);
                acc = hand_arena.add(acc, term);
            }
            let n = hand_arena.int(4);
            elems.push((i, hand_arena.div(acc, n)));
        }
        let hand_built = AnalysisOutput {
            arena: hand_arena,
            outputs: vec![("mean".to_string(), elems)],
            stats: Stats::default(),
            op_counts: Default::default(),
        };

        let report = check_output_equivalence_with(
            &output,
            &hand_built,
            &["mean".to_string()],
            &EquivCheckOptions::default(),
        )
        .unwrap();
        assert!(matches!(report.outcome, EquivOutcome::Equivalent));
    }

    /// Sanity check for the transcendental variants added for the spec
    /// grammar's builtin functions (`exp`/`log`/`sqrt`/`abs`): the
    /// unfolded tree must land on the matching arena node.
    #[test]
    fn transcendental_ops_unfold_to_the_matching_arena_node() {
        use crate::symbolic::ExprNode;
        let body = SpecExpr::index("A", vec![IndexExpr::var("i")])
            .exp()
            .log()
            .sqrt()
            .abs();
        let specs = vec![OutputSpec {
            array: "C".to_string(),
            shape: Shape::new(vec![1]),
            vars: vec!["i".to_string()],
            body,
        }];
        let env = SpecEnv {
            dims: HashMap::new(),
            arrays: HashMap::from([("A".to_string(), Shape::new(vec![1]))]),
        };
        let output = unfold(&specs, &env, 0).unwrap();
        let (_, elems) = &output.outputs[0];
        let (_, id) = elems[0];
        assert!(matches!(output.arena.node(id), ExprNode::Abs(_)));
    }

    /// `max` reduction computes the same value as a hand-built running-max
    /// chain (`M[i] = max(j in 0..N, A[i,j])`), including the empty-range
    /// identity built into `ExprArena::max`'s own chain convention.
    #[test]
    fn max_reduction_matches_a_hand_built_running_max() {
        let body = SpecExpr::max_reduce(
            "j",
            Bound::Named("N".to_string()),
            SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("j")]),
        );
        let specs = vec![OutputSpec {
            array: "M".to_string(),
            shape: Shape::new(vec![2]),
            vars: vec!["i".to_string()],
            body,
        }];
        let env = SpecEnv {
            dims: HashMap::from([("N".to_string(), 3)]),
            arrays: HashMap::from([("A".to_string(), Shape::new(vec![2, 3]))]),
        };
        let spec_output = unfold(&specs, &env, 0).unwrap();

        let mut arena = ExprArena::new();
        let a = arena.intern_string("A");
        let mut elems = Vec::new();
        for i in 0u64..2 {
            let mut acc = arena.float_from_f64(f64::NEG_INFINITY).unwrap();
            for j in 0u64..3 {
                let v = arena.input_element(a, i * 3 + j);
                acc = arena.max(acc, v);
            }
            elems.push((i, acc));
        }
        let hand_built = AnalysisOutput {
            arena,
            outputs: vec![("M".to_string(), elems)],
            stats: Stats::default(),
            op_counts: Default::default(),
        };

        let report = check_output_equivalence_with(
            &spec_output,
            &hand_built,
            &["M".to_string()],
            &EquivCheckOptions::default(),
        )
        .unwrap();
        assert!(matches!(report.outcome, EquivOutcome::Equivalent));
    }

    /// The whole point of adding `Reduce`'s memo cache: a reduction whose
    /// body doesn't depend on the output's other bound variable (here the
    /// row max in `out[i,k] = A[i,k] - max(j in 0..N, A[i,j])`, invariant
    /// in `k`) must be built exactly once per distinct value of the
    /// variables it *does* depend on, not once per output element -
    /// checked directly by asserting every element in a row shares the
    /// exact same `ExprId` for its row-max subterm, and that the two rows
    /// don't share one.
    #[test]
    fn max_reduction_is_memoized_across_output_elements_that_share_its_bindings() {
        use crate::symbolic::ExprNode;

        let body = SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("k")])
            - SpecExpr::max_reduce(
                "j",
                Bound::Named("N".to_string()),
                SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("j")]),
            );
        let specs = vec![OutputSpec {
            array: "out".to_string(),
            shape: Shape::new(vec![2, 3]),
            vars: vec!["i".to_string(), "k".to_string()],
            body,
        }];
        let env = SpecEnv {
            dims: HashMap::from([("N".to_string(), 3)]),
            arrays: HashMap::from([("A".to_string(), Shape::new(vec![2, 3]))]),
        };
        let output = unfold(&specs, &env, 0).unwrap();
        let (_, elems) = &output.outputs[0];
        assert_eq!(elems.len(), 6);

        let row_max_id = |flat: u64| {
            let (_, id) = elems.iter().find(|&&(f, _)| f == flat).unwrap();
            match output.arena.node(*id) {
                ExprNode::Sub(_, max_id) => *max_id,
                other => panic!("expected a Sub node, got {:?}", other),
            }
        };
        let row0: Vec<_> = (0..3).map(row_max_id).collect();
        let row1: Vec<_> = (3..6).map(row_max_id).collect();
        assert!(
            row0.iter().all(|&id| id == row0[0]),
            "row 0's max should be the same ExprId for every column: {:?}",
            row0
        );
        assert!(
            row1.iter().all(|&id| id == row1[0]),
            "row 1's max should be the same ExprId for every column: {:?}",
            row1
        );
        assert_ne!(
            row0[0], row1[0],
            "the two rows' maxes must not collapse into one"
        );
    }
}
