//! Translates the arithmetic + Exp + Max/Min fragment of `ExprArena` into
//! SMT-LIB2 text for Z3 as a **direct semantic image**: every node maps
//! to its defining SMT term, and all algebraic reasoning - commutativity,
//! associativity, cancellation, distribution, max/min case analysis - is
//! left to the solver. This is deliberate: the backend exists to measure
//! what an off-the-shelf solver can do against `canon` (the paper's
//! section 6.5 comparison), so the translation must not pre-digest the
//! query. An earlier design canonicalized aggressively (sorted multisets,
//! structural interning, opaque max/min atoms, a short-circuit for
//! structurally identical sides); it made many corpus queries never reach
//! Z3 at all, measuring the translator instead of the solver, and its
//! opaque atoms were both unsound to key naively and incomplete however
//! keyed. `max`/`min` render as `ite` over real comparisons - Z3's native
//! case-split machinery, exactly the treatment the paper waves at
//! ("handled by case splits") - which makes sat verdicts genuine
//! countermodels for exp-free queries.
//!
//! What the translation still owns (fidelity and transport, not
//! reasoning):
//!
//! - **Exact literals**: a `RealConst` renders as its exact rational
//!   (`p/q` - the arena stores exact rationals, the same reading `canon`
//!   and the numeric oracle use); shortest-decimal rendering of the old
//!   f64 constants would silently reinterpret `0.1f64` as 1/10 and let
//!   the backends reach opposite verdicts on the same VC. The infinities
//!   have no SMT real image and are refused loudly.
//! - **DAG sharing**: `ExprArena` is a DAG (the softmax row-max is
//!   shared by every term), so each compound node is bound to a `let`
//!   variable once per side, memoized by `ExprId`. Text stays linear in
//!   the arena; z3 parses 100k-deep nested lets instantly (flat
//!   `define-fun` chains do not - measured, macro expansion chokes).
//! - **Namespaces**: generated names (`|tN|` binders, `e`, `uexp`, `sN`
//!   machine symbols) and user-controlled names must never collide -
//!   `|t0|` and `t0` are the *same* SMT symbol, so an unprefixed user
//!   symbol named `t0` would be captured by a let binding and corrupt
//!   the query. The rendered names are an injection of the typed
//!   `SymbolRef` namespaces: `sym:` parameters as `|p!name|`, input
//!   elements as `|e!array[index]|`, machine symbols as `sN`.
//! - **The exponential** ([`ExpMode`]): the default renders `Exp(a)` as
//!   `(^ e a)` with `e` a free constant strictly bounded between two
//!   rationals bracketing Euler's number (defining `e` as a rational let
//!   z3 prove `exp(1)` equal to it - a false EQUIVALENT); the
//!   [`ExpMode::AdditionAxiom`] mode renders `(uexp a)` with the
//!   quantified addition law, the paper's "with axiom" baseline that
//!   drives Z3 into an unbounded instantiation loop on softmax VCs.
//!
//! One semantic divergence to know: SMT-LIB real division is total but
//! underspecified at zero, so identities like `x/x = 1` that hold in
//! `canon`'s rational-field model are falsifiable here (countermodel
//! `x = 0`) - the direct encoding inherits SMT's semantics rather than
//! papering over them. Corpus VCs only divide inside exp-laden softmax
//! terms, where the verdict is `unknown` regardless.
//!
//! Ops with no real-arithmetic image in this encoding (`Select`,
//! comparisons, bitwise ops, `Rem`, `Log`, `Sqrt`, `Abs`,
//! `SymbolicRead`, ...) are refused as `Unsupported` rather than modeled
//! unsoundly. (`Select` and comparisons could be encoded via `ite`/Bool
//! like max/min - unimplemented because no corpus VC contains them.)

use std::collections::{BTreeSet, HashMap};

use volta_analysis::symbolic::{ExprArena, ExprId, ExprNode, Real, RealRepr};

#[derive(Debug, Clone, thiserror::Error)]
#[error("unsupported by the Z3 backend: {0}")]
pub struct Unsupported(pub String);

/// How `Exp` nodes are encoded for the solver (see the module docs).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ExpMode {
    /// `(^ e a)` with `e` a free constant strictly bounded around
    /// Euler's number: sound, and z3 answers `unknown` on the exp
    /// identities - the paper's no-intervention baseline.
    #[default]
    PowerBounded,
    /// Uninterpreted `(uexp a)` plus the quantified addition law
    /// `forall x y. uexp(x)*uexp(y) = uexp(x+y)` - the paper's
    /// "with axiom" baseline, which drives z3 into an unbounded
    /// E-matching loop on softmax-shaped VCs (reported as Timeout).
    AdditionAxiom,
}

/// Accumulates declared symbols and `let` bindings for one query. The
/// reference and optimized sides of one VC element share a `Builder`, so
/// a shared input symbol (e.g. both kernels reading `in[5]`) resolves to
/// the same declared constant. `bindings` is filled in dependency order
/// (a binding's definition only references earlier bindings), so wrapping
/// the final query body in the bindings in order is always well-scoped.
#[derive(Default)]
pub struct Builder {
    /// Names needing `(declare-const _ Real)`, sorted for deterministic
    /// output.
    reals: BTreeSet<String>,
    bindings: Vec<(String, String)>,
    uses_exp: bool,
    exp_mode: ExpMode,
}

impl Builder {
    pub fn new() -> Self {
        Self::default()
    }

    /// A builder whose `Exp` encoding follows `mode` (see [`ExpMode`]).
    pub fn with_exp_mode(mode: ExpMode) -> Self {
        Self {
            exp_mode: mode,
            ..Self::default()
        }
    }

    fn declare(&mut self, name: String) -> String {
        self.reals.insert(name.clone());
        name
    }

    fn bind(&mut self, def: String) -> String {
        let name = format!("|t{}|", self.bindings.len());
        self.bindings.push((name.clone(), def));
        name
    }

    /// SMT-LIB2 preamble: every declared symbol as a `declare-const`,
    /// plus - when the query uses `Exp` - the encoding of the exponential
    /// per `exp_mode` (see the module docs).
    pub fn preamble(&self) -> String {
        use std::fmt::Write as _;
        let mut out = String::new();
        if self.uses_exp {
            match self.exp_mode {
                ExpMode::PowerBounded => {
                    out.push_str("(declare-const e Real)\n");
                    out.push_str("(assert (< 2.718281828459045 e))\n");
                    out.push_str("(assert (< e 2.7182818284590455))\n");
                }
                ExpMode::AdditionAxiom => {
                    out.push_str("(declare-fun uexp (Real) Real)\n");
                    out.push_str(
                        "(assert (forall ((x Real) (y Real)) \
                         (= (* (uexp x) (uexp y)) (uexp (+ x y)))))\n",
                    );
                }
            }
        }
        for name in &self.reals {
            let _ = writeln!(out, "(declare-const {} Real)", name);
        }
        out
    }

    /// Wrap `body` in every accumulated `let` binding, first binding
    /// outermost - so each definition's free variables are already in
    /// scope. Built linearly (prefixes, body, closing parens): re-copying
    /// the accumulated string per binding would be quadratic in the query
    /// size, and attention-scale queries have tens of thousands of
    /// bindings.
    pub fn wrap_in_lets(&self, body: &str) -> String {
        let bindings_len: usize = self
            .bindings
            .iter()
            .map(|(n, d)| n.len() + d.len() + 12)
            .sum();
        let mut out = String::with_capacity(bindings_len + body.len() + self.bindings.len());
        for (name, def) in &self.bindings {
            out.push_str("(let ((");
            out.push_str(name);
            out.push(' ');
            out.push_str(def);
            out.push_str(")) ");
        }
        out.push_str(body);
        out.extend(std::iter::repeat_n(')', self.bindings.len()));
        out
    }
}

/// Quote a launch-config `sym:` parameter into the reserved `p!`
/// namespace. The prefix keeps user-controlled names disjoint from every
/// generated name (`tN` binders, `e`, `uexp`, `sN`) and from the `e!`
/// element namespace; the escaping keeps the mapping injective (z3
/// accepts `\|`/`\\` inside quoted symbols).
fn quote_param(name: &str) -> String {
    format!("|p!{}|", escape(name))
}

/// Quote a launch-config input-array element into the reserved `e!`
/// namespace. The fixed `[index]` suffix after the escaped array name
/// keeps the mapping injective per array.
fn quote_element(array: &str, index: u64) -> String {
    format!("|e!{}[{}]|", escape(array), index)
}

fn escape(name: &str) -> String {
    name.replace('\\', "\\\\").replace('|', "\\|")
}

/// Exact SMT real literal for a `Real` constant: the rational rendered as
/// an integer or an exact fraction, negation outside (see the module docs
/// for why not the shortest decimal). The infinities have no real image
/// and are refused loudly, exactly as non-finite f64 constants were.
fn real_literal(v: &Real) -> Result<String, Unsupported> {
    let q = match v.repr() {
        RealRepr::NegInf | RealRepr::PosInf => {
            return Err(Unsupported(format!(
                "non-finite float constant {}",
                v.to_f64()
            )));
        }
        RealRepr::Rational(q) => q,
    };
    // rug's canonical form: reduced, denominator positive, sign on the
    // numerator. Render the magnitude and put the negation outside.
    let numer = q.numer().to_string();
    if numer == "0" {
        return Ok("0.0".to_string());
    }
    let (negative, digits) = match numer.strip_prefix('-') {
        Some(d) => (true, d),
        None => (false, numer.as_str()),
    };
    let denom = q.denom();
    let body = if *denom == 1 {
        format!("{}.0", digits)
    } else {
        format!("(/ {}.0 {}.0)", digits, denom)
    };
    Ok(if negative {
        format!("(- {})", body)
    } else {
        body
    })
}

fn int_literal(v: i64) -> String {
    let body = format!("{}.0", (v as i128).unsigned_abs());
    if v < 0 { format!("(- {})", body) } else { body }
}

type Memo = HashMap<ExprId, String>;

/// Translate one expression to its rendered term (a literal, a declared
/// symbol, or the `|tN|` binder of its definition). `memo` caches this
/// arena's `ExprId -> term` mapping, so a node shared by many parents is
/// bound once - the query's size is linear in the arena, not the tree
/// expansion. Guarded by `stacker::maybe_grow` like every other deep
/// recursion over expression chains in this workspace: an accumulator
/// loop of N iterations is an N-deep spine.
fn translate(
    bld: &mut Builder,
    memo: &mut Memo,
    arena: &ExprArena,
    id: ExprId,
) -> Result<String, Unsupported> {
    if let Some(t) = memo.get(&id) {
        return Ok(t.clone());
    }
    let t = stacker::maybe_grow(64 * 1024, 8 * 1024 * 1024, || {
        translate_uncached(bld, memo, arena, id)
    })?;
    memo.insert(id, t.clone());
    Ok(t)
}

fn translate_uncached(
    bld: &mut Builder,
    memo: &mut Memo,
    arena: &ExprArena,
    id: ExprId,
) -> Result<String, Unsupported> {
    let bin = |bld: &mut Builder, memo: &mut Memo, op: &str, a: ExprId, b: ExprId| {
        let ta = translate(bld, memo, arena, a)?;
        let tb = translate(bld, memo, arena, b)?;
        Ok::<String, Unsupported>(bld.bind(format!("({} {} {})", op, ta, tb)))
    };

    match arena.node(id) {
        ExprNode::IntConst(v) => Ok(int_literal(*v)),
        ExprNode::RealConst(v) => real_literal(v),
        ExprNode::BoolConst(v) => Ok(if *v { "1.0" } else { "0.0" }.to_string()),

        ExprNode::ParamSymbol(sid) => Ok(bld.declare(quote_param(arena.string(*sid)))),
        ExprNode::InputElement { array, index } => {
            Ok(bld.declare(quote_element(arena.string(*array), *index)))
        }
        ExprNode::Symbol(sym) => Ok(bld.declare(sym.to_string())),

        ExprNode::Add(a, b) => bin(bld, memo, "+", *a, *b),
        ExprNode::Sub(a, b) => bin(bld, memo, "-", *a, *b),
        ExprNode::Mul(a, b) => bin(bld, memo, "*", *a, *b),
        ExprNode::Div(a, b) => bin(bld, memo, "/", *a, *b),
        ExprNode::Neg(a) => {
            let ta = translate(bld, memo, arena, *a)?;
            Ok(bld.bind(format!("(- {})", ta)))
        }
        ExprNode::Rcp(a) => {
            let ta = translate(bld, memo, arena, *a)?;
            Ok(bld.bind(format!("(/ 1.0 {})", ta)))
        }
        ExprNode::Fma(a, b, c) => {
            let ta = translate(bld, memo, arena, *a)?;
            let tb = translate(bld, memo, arena, *b)?;
            let tc = translate(bld, memo, arena, *c)?;
            Ok(bld.bind(format!("(+ (* {} {}) {})", ta, tb, tc)))
        }
        ExprNode::Exp(a) => {
            let ta = translate(bld, memo, arena, *a)?;
            bld.uses_exp = true;
            let def = match bld.exp_mode {
                ExpMode::PowerBounded => format!("(^ e {})", ta),
                ExpMode::AdditionAxiom => format!("(uexp {})", ta),
            };
            Ok(bld.bind(def))
        }

        // max/min are ite over real comparisons - the solver's own case
        // split, not an opaque atom.
        ExprNode::Max(a, b) => {
            let ta = translate(bld, memo, arena, *a)?;
            let tb = translate(bld, memo, arena, *b)?;
            Ok(bld.bind(format!("(ite (>= {} {}) {} {})", ta, tb, ta, tb)))
        }
        ExprNode::Min(a, b) => {
            let ta = translate(bld, memo, arena, *a)?;
            let tb = translate(bld, memo, arena, *b)?;
            Ok(bld.bind(format!("(ite (<= {} {}) {} {})", ta, tb, ta, tb)))
        }

        // Conversion: identity over the reals (matches
        // `canon::canonicalize`'s treatment of the same node exactly).
        // Not bound itself - it forwards straight to the child.
        ExprNode::ToFloat(a) => translate(bld, memo, arena, *a),

        other => Err(Unsupported(describe(other))),
    }
}

/// Short, best-effort name for an unsupported node - the exact variant
/// name via `Debug`, not the full (potentially huge) subtree.
fn describe(node: &ExprNode) -> String {
    let s = format!("{:?}", node);
    s.split([' ', '{', '(']).next().unwrap_or(&s).to_string()
}

/// Translate a whole root expression, returning its rendered term text.
/// Starts a fresh per-arena memo; use one call per side (reference and
/// optimized) sharing the same `Builder`, so launch-config symbols
/// resolve to the same declared constants across the two sides.
pub fn translate_root(
    bld: &mut Builder,
    arena: &ExprArena,
    id: ExprId,
) -> Result<String, Unsupported> {
    let mut memo = Memo::new();
    translate(bld, &mut memo, arena, id)
}
