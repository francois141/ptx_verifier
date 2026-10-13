//! Translates the arithmetic + Exp + Max/Min fragment of `ExprArena` to SMT-LIB2 as a *direct
//! semantic image*: no canonicalization, all algebra left to Z3, so timings measure the solver.
//! Caveat: SMT division is underspecified at zero, so `x/x = 1` is falsifiable (unlike `canon`).

use std::collections::{BTreeSet, HashMap};

use volta_expr::{ExprArena, ExprId, ExprNode, Real, RealRepr};

#[derive(Debug, Clone, thiserror::Error)]
#[error("unsupported by the Z3 backend: {0}")]
pub struct Unsupported(pub String);

/// How `Exp` nodes are encoded for the solver; the paper's section 6.5 baselines.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ExpMode {
    /// `(^ e a)` with `e` a free constant strictly bounded around Euler's number (a rational
    /// `e` proved false equivalences); z3 answers `unknown` on exp identities.
    #[default]
    PowerBounded,
    /// Uninterpreted `(uexp a)` plus `forall x y. uexp(x)*uexp(y) = uexp(x+y)` - the paper's
    /// "with axiom" baseline; z3 E-matches without bound on softmax VCs (reported as Timeout).
    AdditionAxiom,
}

/// Declared symbols and `let` bindings for one query, shared by both sides of a VC element so
/// shared inputs resolve to one constant. `bindings` is in dependency order, so wrapping the
/// body in them in order is always well-scoped.
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
    /// per `exp_mode` (see [`ExpMode`]).
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

    /// Wrap `body` in every `let` binding, first outermost, so each definition's free variables
    /// are in scope. Built linearly: re-copying per binding would be quadratic, and attention
    /// queries have tens of thousands of bindings (nested lets parse fast; `define-fun` don't).
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

/// Quote a launch-config `sym:` parameter into the reserved `p!` namespace, disjoint from
/// generated names (`|tN|` = `tN`, `e`, `uexp`, `sN`) and `e!` elements; escaping keeps it
/// injective (z3 accepts `\|`/`\\` inside quoted symbols).
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

/// Exact SMT real literal for a `Real` (integer or exact fraction, negation outside), the same
/// reading as `canon` and the oracle; a shortest decimal could flip verdicts. Infinities have no
/// real image and are refused loudly.
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

/// Translate one expression to its term (literal, declared symbol, or `|tN|` binder). `memo`
/// binds shared nodes once, keeping the query linear in the arena; `stacker`-guarded because an
/// N-iteration accumulator is an N-deep spine.
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

/// Translate a whole root expression with a fresh memo. Use one call per side (reference and
/// optimized) on the same `Builder`, so launch-config symbols resolve to the same constants.
pub fn translate_root(
    bld: &mut Builder,
    arena: &ExprArena,
    id: ExprId,
) -> Result<String, Unsupported> {
    let mut memo = Memo::new();
    translate(bld, &mut memo, arena, id)
}
