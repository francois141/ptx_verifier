//! Z3 backend, a comparison point against `canon`: VC pairs go to auditable
//! SMT-LIB2 text (see `translate`), solved by linked libz3 in a killable
//! worker (see `ffi` and [`init_worker`]).

mod ffi;
mod translate;

pub use ffi::{EvalOutcome, eval_smtlib2, init_worker, z3_version};
pub use translate::{Builder, ExpMode, Unsupported, translate_root};

use std::fmt;
use std::time::Duration;

use volta_equivalence::check::EquivCheckError;
use volta_expr::{ExprArena, ExprId, SymbolicOutputs};

/// Outcome of one Z3 query.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Z3Verdict {
    /// `unsat` on `(not (= a b))`: the expressions are proved equal.
    Equivalent,
    /// `sat`: the sides differ in some model. A genuine countermodel for
    /// exp-free queries; with exp it is not definitive, since the bounded
    /// `e`/`uexp` underconstrain the real exp.
    NotEquivalent,
    /// `unknown`: Z3 gave up within budget. Expected for exp-heavy
    /// (softmax/attention) VCs under [`ExpMode::PowerBounded`], since no
    /// decidable theory covers symbolic real exponents.
    Unknown,
    /// The budget expired (worker killed or z3's in-band cancel). Expected
    /// for attention VCs under [`ExpMode::AdditionAxiom`], the paper's "with
    /// axiom" baseline.
    Timeout,
}

#[derive(Debug, thiserror::Error)]
pub enum Z3Error {
    #[error(transparent)]
    Unsupported(#[from] Unsupported),
    #[error("z3 produced unexpected output: {0:?}")]
    UnexpectedOutput(String),
    #[error("z3 worker failed: {0}")]
    Worker(String),
}

/// One element's verdict and solve time. `solve` is measured inside the
/// worker around libz3's evaluation only (excluding ~10ms spawn/context
/// scaffolding and translation); timeouts report the budget.
#[derive(Debug, Clone)]
pub struct Z3CheckResult {
    pub verdict: Z3Verdict,
    pub solve: Duration,
}

/// An `unknown` whose `:reason-unknown` blames the budget (z3 4.8 says
/// "canceled", "timeout" or "resource") rather than genuine incompleteness
/// ("incomplete (theory arithmetic)").
fn unknown_reason_is_budget(output: &str) -> bool {
    output.lines().any(|l| {
        let l = l.trim();
        l.contains(":reason-unknown")
            && (l.contains("timeout") || l.contains("canceled") || l.contains("resource"))
    })
}

/// Check `a` (in `arena_a`) == `b` (in `arena_b`) over the reals with Z3 in
/// `mode`. `timeout` is a hard bound (worker killed), reported as
/// [`Z3Verdict::Timeout`] with the budget as solve time.
pub fn check_equivalent(
    arena_a: &ExprArena,
    a: ExprId,
    arena_b: &ExprArena,
    b: ExprId,
    timeout: Option<Duration>,
    mode: ExpMode,
) -> Result<Z3CheckResult, Z3Error> {
    let mut builder = Builder::with_exp_mode(mode);
    let ta = translate_root(&mut builder, arena_a, a)?;
    let tb = translate_root(&mut builder, arena_b, b)?;

    let body = builder.wrap_in_lets(&format!("(not (= {} {}))", ta, tb));
    let mut query = builder.preamble();
    query.push_str(&format!("(assert {})\n", body));
    query.push_str("(check-sat)\n");
    // Harmless on decided queries (empty reason, no error); on `unknown`
    // it distinguishes a budget cancellation from a genuine give-up.
    query.push_str("(get-info :reason-unknown)\n");

    let (verdict, measured) = match ffi::eval_smtlib2(&query, timeout) {
        // A SIGKILLed worker leaves no in-band time (and can only exist
        // when a deadline was set); the budget substitution below is the
        // only time a hard timeout ever reports.
        ffi::EvalOutcome::HardTimeout => (Z3Verdict::Timeout, None),
        ffi::EvalOutcome::ChildDied(how) => return Err(Z3Error::Worker(how)),
        ffi::EvalOutcome::Output { text, solve } => {
            let verdict = match text.lines().map(str::trim).find(|l| !l.is_empty()) {
                Some("unsat") => Z3Verdict::Equivalent,
                Some("sat") => Z3Verdict::NotEquivalent,
                Some("unknown") | Some("timeout") => {
                    if unknown_reason_is_budget(&text) {
                        Z3Verdict::Timeout
                    } else {
                        Z3Verdict::Unknown
                    }
                }
                _ => return Err(Z3Error::UnexpectedOutput(text)),
            };
            (verdict, Some(solve))
        }
    };
    // Timeout rows report the BUDGET (the paper's convention), so the hard
    // kill (no in-band time) and z3's soft cancel (nearly the budget) read
    // identically.
    let solve = match (verdict, timeout) {
        (Z3Verdict::Timeout, Some(budget)) => budget,
        // Timeout without a configured budget only arises from the
        // in-band path (a hard timeout requires a deadline), so a
        // measurement is always present here.
        _ => measured.expect("non-hard-timeout outcomes carry an in-band solve time"),
    };

    Ok(Z3CheckResult { verdict, solve })
}

/// The CLI convention for Z3 timeouts: `0` means no limit.
pub fn timeout_from_secs(secs: u64) -> Option<Duration> {
    (secs != 0).then(|| Duration::from_secs(secs))
}

/// Per-element outcome from the Z3 backend - a finer-grained result than
/// the decision procedure's binary equivalent/not, since Z3 can also fail
/// to decide (`Unknown`) or refuse a VC outright (`Unsupported`).
#[derive(Debug, Clone)]
pub enum ElementOutcome {
    Equivalent,
    NotEquivalent,
    Unknown,
    Timeout,
    Unsupported(String),
    /// The `z3` call itself failed for a reason other than an unsupported
    /// fragment (e.g. malformed output, worker crash) - recorded per
    /// element rather than aborting the whole comparison.
    Error(String),
}

#[derive(Debug, Clone)]
pub struct ElementResult {
    pub array: String,
    pub index: u64,
    pub outcome: ElementOutcome,
    /// In-worker solver time (see [`Z3CheckResult`]; the budget for
    /// timeouts); zero for elements that never reached the solver
    /// (unsupported fragment, worker error).
    pub solve: Duration,
}

/// Per-outcome element counts. A named struct rather than a positional
/// tuple: the six counts are all `usize`, and a transposition anywhere in
/// the report/JSON/print chain would compile silently.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Z3Counts {
    pub equivalent: usize,
    pub not_equivalent: usize,
    pub unknown: usize,
    pub timeout: usize,
    pub unsupported: usize,
    pub error: usize,
}

impl Z3Counts {
    pub fn total(&self) -> usize {
        self.equivalent
            + self.not_equivalent
            + self.unknown
            + self.timeout
            + self.unsupported
            + self.error
    }

    /// Every checked element was proved equivalent (vacuously true for an
    /// empty footprint, matching the decision backend's outcome there).
    pub fn all_equivalent(&self) -> bool {
        self.equivalent == self.total()
    }

    /// Compact `equiv/diff/unknown/timeout/unsupported/error` form for
    /// tables.
    pub fn compact(&self) -> String {
        format!(
            "{}/{}/{}/{}/{}/{}",
            self.equivalent,
            self.not_equivalent,
            self.unknown,
            self.timeout,
            self.unsupported,
            self.error
        )
    }
}

impl fmt::Display for Z3Counts {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "equivalent: {}  not-equivalent: {}  unknown: {}  timeout: {}  unsupported: {}  error: {}",
            self.equivalent,
            self.not_equivalent,
            self.unknown,
            self.timeout,
            self.unsupported,
            self.error
        )
    }
}

#[derive(Debug, Clone, Default)]
pub struct Z3EquivReport {
    pub elements: Vec<ElementResult>,
}

impl Z3EquivReport {
    pub fn counts(&self) -> Z3Counts {
        let mut c = Z3Counts::default();
        for e in &self.elements {
            match &e.outcome {
                ElementOutcome::Equivalent => c.equivalent += 1,
                ElementOutcome::NotEquivalent => c.not_equivalent += 1,
                ElementOutcome::Unknown => c.unknown += 1,
                ElementOutcome::Timeout => c.timeout += 1,
                ElementOutcome::Unsupported(_) => c.unsupported += 1,
                ElementOutcome::Error(_) => c.error += 1,
            }
        }
        c
    }

    /// Total in-worker solver time across all elements, in seconds
    /// (timeout elements count their budget; see [`Z3CheckResult`]).
    pub fn total_solve_secs(&self) -> f64 {
        self.elements
            .iter()
            .map(|e| e.solve)
            .sum::<Duration>()
            .as_secs_f64()
    }
}

/// Check `volta_equivalence::check::sampled_elements` over `paired_elements` (the
/// decision procedure's exact list) with Z3, recording each element's outcome
/// without aborting; `Err` is only a pairing failure.
pub fn check_output_equivalence(
    reference: &SymbolicOutputs,
    optimized: &SymbolicOutputs,
    arrays: &[String],
    sample: u64,
    timeout: Option<Duration>,
    mode: ExpMode,
) -> Result<Z3EquivReport, EquivCheckError> {
    let paired = volta_equivalence::check::paired_elements(reference, optimized, arrays)?;
    let mut elements = Vec::new();
    for (name, index, r, o) in volta_equivalence::check::sampled_elements(&paired, sample) {
        let (outcome, solve) =
            match check_equivalent(&reference.arena, r, &optimized.arena, o, timeout, mode) {
                Ok(res) => (
                    match res.verdict {
                        Z3Verdict::Equivalent => ElementOutcome::Equivalent,
                        Z3Verdict::NotEquivalent => ElementOutcome::NotEquivalent,
                        Z3Verdict::Unknown => ElementOutcome::Unknown,
                        Z3Verdict::Timeout => ElementOutcome::Timeout,
                    },
                    res.solve,
                ),
                Err(Z3Error::Unsupported(u)) => (ElementOutcome::Unsupported(u.0), Duration::ZERO),
                Err(e) => (ElementOutcome::Error(e.to_string()), Duration::ZERO),
            };
        elements.push(ElementResult {
            array: name.to_string(),
            index,
            outcome,
            solve,
        });
    }
    Ok(Z3EquivReport { elements })
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Wire the worker entry for this crate's own test binary (real
    /// binaries call `volta_z3::init_worker()` at the top of `main`;
    /// libtest owns this binary's `main`, so the hook runs pre-main).
    #[ctor::ctor]
    fn worker_hook() {
        crate::init_worker();
    }

    /// The whole point of the subprocess design: evaluation is
    /// thread-safe (the old fork-based worker silently required a
    /// single-threaded process).
    #[test]
    fn parallel_checks_are_thread_safe() {
        let handles: Vec<_> = (0..4)
            .map(|i| {
                std::thread::spawn(move || {
                    let mut ar = ExprArena::new();
                    let x = ar.param_symbol(format!("x{}", i));
                    let y = ar.param_symbol(format!("y{}", i));
                    let lhs = ar.add(x, y);
                    let rhs = ar.add(y, x);
                    check_equivalent(&ar, lhs, &ar, rhs, None, ExpMode::PowerBounded)
                        .unwrap()
                        .verdict
                })
            })
            .collect();
        for h in handles {
            assert_eq!(h.join().unwrap(), Z3Verdict::Equivalent);
        }
    }

    fn check(arena_a: &ExprArena, a: ExprId, arena_b: &ExprArena, b: ExprId) -> Z3Verdict {
        check_mode(arena_a, a, arena_b, b, ExpMode::PowerBounded)
    }

    fn check_mode(
        arena_a: &ExprArena,
        a: ExprId,
        arena_b: &ExprArena,
        b: ExprId,
        mode: ExpMode,
    ) -> Z3Verdict {
        // Generous: solver needs only ms uncontended, but the whole suite
        // shares the cores and every test really runs z3 (no structural
        // short-circuits by design).
        check_equivalent(arena_a, a, arena_b, b, Some(Duration::from_secs(60)), mode)
            .unwrap()
            .verdict
    }

    #[test]
    fn commutative_add_is_equivalent() {
        // x + 1 vs 1 + x: commutativity is the solver's job now - Z3
        // proves it, the translation does not pre-normalize it away.
        let mut ar = ExprArena::new();
        let x = ar.param_symbol("x");
        let one = ar.int(1);
        let lhs = ar.add(x, one);
        let rhs = ar.add(one, x);
        assert_eq!(check(&ar, lhs, &ar, rhs), Z3Verdict::Equivalent);
    }

    #[test]
    fn cross_arena_named_symbol_correlates_by_string() {
        // Two independent arenas, each with its own "x" - correlated by
        // name, exactly like `canon`'s own convention.
        let mut ar_a = ExprArena::new();
        let x_a = ar_a.param_symbol("x");
        let two_a = ar_a.int(2);
        let lhs = ar_a.mul(x_a, two_a);

        let mut ar_b = ExprArena::new();
        let x_b = ar_b.param_symbol("x");
        let rhs = ar_b.add(x_b, x_b);

        assert_eq!(check(&ar_a, lhs, &ar_b, rhs), Z3Verdict::Equivalent);
    }

    #[test]
    fn distinct_symbols_are_not_equivalent() {
        let mut ar = ExprArena::new();
        let x = ar.param_symbol("x");
        let y = ar.param_symbol("y");
        assert_eq!(check(&ar, x, &ar, y), Z3Verdict::NotEquivalent);
    }

    #[test]
    fn exp_addition_law_is_unknown_without_an_axiom() {
        // exp(a)*exp(b) vs exp(a+b): true over the reals, but Z3 alone
        // (native `^`, no axiom) has no decision procedure for symbolic
        // real exponents - the paper's no-intervention baseline.
        let mut ar = ExprArena::new();
        let a = ar.param_symbol("a");
        let b = ar.param_symbol("b");
        let ea = ar.exp(a);
        let eb = ar.exp(b);
        let lhs = ar.mul(ea, eb);
        let sum = ar.add(a, b);
        let rhs = ar.exp(sum);
        assert_eq!(check(&ar, lhs, &ar, rhs), Z3Verdict::Unknown);

        // With the paper's addition-law axiom the toy law itself is a
        // direct instantiation: proved.
        assert_eq!(
            check_mode(&ar, lhs, &ar, rhs, ExpMode::AdditionAxiom),
            Z3Verdict::Equivalent
        );
    }

    /// Table 8 in miniature: a softmax rescaling identity under the addition
    /// axiom sends z3 into an E-matching loop that ignores its soft timeout,
    /// so the hard deadline must fire.
    #[test]
    fn axiom_mode_softmax_rescaling_hard_times_out() {
        let n = 8;
        let mut ar = ExprArena::new();
        let m = ar.param_symbol("m");
        // lhs: sum_i exp(s_i - m); rhs: exp(-m) * sum_i exp(s_i). Equal
        // over the reals via the addition law, but a Sum-of-Exps vs a
        // Prod structurally - no short-circuit, the solver must run.
        let mut lhs_terms = Vec::new();
        let mut rhs_terms = Vec::new();
        for i in 0..n {
            let s = ar.param_symbol(format!("s{}", i));
            let shifted = ar.sub(s, m);
            lhs_terms.push(ar.exp(shifted));
            rhs_terms.push(ar.exp(s));
        }
        let mut lhs = lhs_terms[0];
        for &t in &lhs_terms[1..] {
            lhs = ar.add(lhs, t);
        }
        let neg_m = ar.neg(m);
        let e_neg_m = ar.exp(neg_m);
        let mut rhs_sum = rhs_terms[0];
        for &t in &rhs_terms[1..] {
            rhs_sum = ar.add(rhs_sum, t);
        }
        let rhs = ar.mul(e_neg_m, rhs_sum);

        let res = check_equivalent(
            &ar,
            lhs,
            &ar,
            rhs,
            Some(Duration::from_secs(2)),
            ExpMode::AdditionAxiom,
        )
        .unwrap();
        assert_eq!(res.verdict, Z3Verdict::Timeout);
        // Timeout rows report the budget itself (the paper's convention),
        // whichever mechanism fired - the parent's hard kill or z3's own
        // soft cancellation.
        assert_eq!(res.solve, Duration::from_secs(2));
    }

    /// The reported solve time is in-worker: positive, and no larger than the
    /// parent's wall time, which also pays the worker spawn/exec/pipe
    /// overhead this measurement excludes.
    #[test]
    fn solve_time_is_in_worker_and_bounded_by_wall_time() {
        let mut ar = ExprArena::new();
        let x = ar.param_symbol("x");
        let y = ar.param_symbol("y");
        let lhs = ar.add(x, y);
        let rhs = ar.add(y, x);
        let wall_start = std::time::Instant::now();
        let res = check_equivalent(
            &ar,
            lhs,
            &ar,
            rhs,
            Some(Duration::from_secs(60)),
            ExpMode::PowerBounded,
        )
        .unwrap();
        let wall = wall_start.elapsed();
        assert_eq!(res.verdict, Z3Verdict::Equivalent);
        assert!(
            res.solve > Duration::ZERO,
            "in-worker solve time must be a real measurement"
        );
        assert!(
            res.solve <= wall,
            "in-worker solve time {:?} cannot exceed the parent's wall time {:?}",
            res.solve,
            wall
        );
    }

    /// Diagnostic: run with `--ignored --nocapture` to print how much of
    /// `eval_smtlib2`'s wall time is worker scaffolding versus in-libz3
    /// solving for a trivial query.
    #[test]
    #[ignore = "diagnostic: prints the spawn-vs-solve overhead split"]
    fn spawn_overhead_split() {
        let query = "(assert false)(check-sat)\n";
        let iterations = 20;
        let mut wall_total = Duration::ZERO;
        let mut solve_total = Duration::ZERO;
        for _ in 0..iterations {
            let wall_start = std::time::Instant::now();
            match ffi::eval_smtlib2(query, Some(Duration::from_secs(30))) {
                ffi::EvalOutcome::Output { text, solve } => {
                    wall_total += wall_start.elapsed();
                    solve_total += solve;
                    assert_eq!(text.trim(), "unsat");
                }
                _ => panic!("trivial query must produce output"),
            }
        }
        let per = |d: Duration| d.as_secs_f64() * 1e3 / iterations as f64;
        println!(
            "trivial query x{}: wall {:.3}ms/call, in-worker solve {:.3}ms/call, \
             excluded scaffolding {:.3}ms/call",
            iterations,
            per(wall_total),
            per(solve_total),
            per(wall_total - solve_total),
        );
    }

    /// Budget-vs-incompleteness classification of `unknown` reasons.
    #[test]
    fn unknown_reason_classification() {
        assert!(unknown_reason_is_budget(
            "unknown\n(:reason-unknown \"canceled\")\n"
        ));
        assert!(unknown_reason_is_budget(
            "unknown\n(:reason-unknown \"timeout\")\n"
        ));
        assert!(!unknown_reason_is_budget(
            "unknown\n(:reason-unknown \"incomplete\")\n"
        ));
        assert!(!unknown_reason_is_budget(
            "unknown\n(:reason-unknown \"smt tactic failed to show goal to be sat/unsat (incomplete (theory arithmetic))\")\n"
        ));
    }

    #[test]
    fn select_is_unsupported() {
        // A concrete condition constant-folds away (see `ExprArena`'s
        // "constructors constant-fold eagerly"), so use a symbolic
        // predicate to force an actual `Select` node.
        let mut ar = ExprArena::new();
        let c = ar.param_symbol("cond");
        let t = ar.int(1);
        let f = ar.int(0);
        let id = ar.select(c, t, f);
        let result = check_equivalent(&ar, id, &ar, id, None, ExpMode::PowerBounded);
        assert!(matches!(result, Err(Z3Error::Unsupported(_))));
    }

    /// max/min are real ite case splits, so structurally different but
    /// equal maxes across the two arenas are proved equal by the solver.
    /// (Two earlier opaque-atom designs got this wrong or incomplete.)
    #[test]
    fn maxmin_compound_args_unify_across_arenas() {
        let build = |flip: bool| {
            let mut ar = ExprArena::new();
            let x = ar.param_symbol("x");
            let y = ar.param_symbol("y");
            let z = ar.param_symbol("z");
            let sum = if flip { ar.add(y, x) } else { ar.add(x, y) };
            let m = ar.max(sum, z);
            (ar, m)
        };
        let (ar_a, ma) = build(false);
        let (ar_b, mb) = build(true);
        assert_eq!(check(&ar_a, ma, &ar_b, mb), Z3Verdict::Equivalent);
    }

    /// Nested running-max chains reassociated differently across the two
    /// sides are proved equal via the ite semantics.
    #[test]
    fn maxmin_key_is_traversal_order_independent() {
        let build = |outer_first: bool| {
            let mut ar = ExprArena::new();
            let s0 = ar.param_symbol("s0");
            let s1 = ar.param_symbol("s1");
            let s2 = ar.param_symbol("s2");
            let m1 = ar.max(s0, s1);
            let m2 = ar.max(m1, s2);
            let root = if outer_first {
                ar.add(m2, m1)
            } else {
                ar.add(m1, m2)
            };
            (ar, root)
        };
        let (ar_a, ra) = build(false);
        let (ar_b, rb) = build(true);
        assert_eq!(check(&ar_a, ra, &ar_b, rb), Z3Verdict::Equivalent);
    }

    /// Named and machine symbols are disjoint namespaces (as in canon and
    /// the numeric oracle): a symbol literally named "s{N}" is not the
    /// machine `Symbol(N)`.
    #[test]
    fn named_symbol_does_not_alias_machine_symbol() {
        use volta_expr::ExprNode;

        let mut ar = ExprArena::new();
        let machine = ar.symbol();
        let ExprNode::Symbol(sym) = *ar.node(machine) else {
            panic!("arena.symbol() must produce ExprNode::Symbol");
        };
        let named = ar.param_symbol(sym.to_string());
        assert_eq!(check(&ar, machine, &ar, named), Z3Verdict::NotEquivalent);
    }

    /// A user symbol named `t0` must not be captured by the generated `|t0|`
    /// let binding (a false EQUIVALENT); user symbols live in reserved
    /// `p!`/`e!` namespaces.
    #[test]
    fn user_symbol_named_t0_is_not_captured() {
        let mut ar_a = ExprArena::new();
        let a = ar_a.param_symbol("a");
        let b = ar_a.param_symbol("b");
        let lhs = ar_a.mul(a, b);

        let mut ar_b = ExprArena::new();
        let rhs = ar_b.param_symbol("t0");

        assert_eq!(check(&ar_a, lhs, &ar_b, rhs), Z3Verdict::NotEquivalent);
    }

    /// A user symbol named `e` must not collide with the exp-base constant;
    /// the `Exp` node matters, since only exp-using queries declare the base.
    #[test]
    fn user_symbol_named_e_is_distinct_from_exp_base() {
        let mut ar = ExprArena::new();
        let e_sym = ar.param_symbol("e");
        let x = ar.param_symbol("x");
        let ex = ar.exp(x);
        let lhs = ar.mul(e_sym, ex);
        let rhs = ar.mul(ex, e_sym);
        // Capture would be a duplicate declaration of `e` (a z3 error,
        // not Equivalent).
        assert_eq!(check(&ar, lhs, &ar, rhs), Z3Verdict::Equivalent);
        // Probe freeness in an exp-free query: z3 cannot build a model for
        // any query with `^` and a free exponent, so with the base declared a
        // sat check only sees Unknown.
        let mut ar_b = ExprArena::new();
        let approx = ar_b.float_from_f64(2.718281828459045).unwrap();
        assert_eq!(check(&ar, e_sym, &ar_b, approx), Z3Verdict::NotEquivalent);
    }

    /// The same guard for the axiom encoding: a user symbol named `uexp`
    /// must coexist with the declared `uexp` function.
    #[test]
    fn user_symbol_named_uexp_is_distinct_from_uexp_function() {
        let mut ar = ExprArena::new();
        let u_sym = ar.param_symbol("uexp");
        let x = ar.param_symbol("x");
        let ex = ar.exp(x);
        let lhs = ar.mul(u_sym, ex);
        let rhs = ar.mul(ex, u_sym);
        assert_eq!(
            check_mode(&ar, lhs, &ar, rhs, ExpMode::AdditionAxiom),
            Z3Verdict::Equivalent
        );
    }

    /// Float constants must translate as their exact binary value, not their
    /// shortest decimal (`0.1f64` != 1/10), or z3 and canon/the oracle could
    /// reach opposite verdicts.
    #[test]
    fn float_literals_use_exact_binary_semantics() {
        // Divisions stay symbolic (`x / c`) to avoid integer constant
        // folding. 0.5f64 is exactly 1/2, so x * 0.5 == x / 2 over the reals.
        let mut ar_a = ExprArena::new();
        let x = ar_a.param_symbol("x");
        let half = ar_a.float_from_f64(0.5).unwrap();
        let lhs = ar_a.mul(x, half);
        let mut ar_b = ExprArena::new();
        let x = ar_b.param_symbol("x");
        let two = ar_b.int(2);
        let rhs = ar_b.div(x, two);
        assert_eq!(check(&ar_a, lhs, &ar_b, rhs), Z3Verdict::Equivalent);

        // 0.1f64 is NOT 1/10 (exactly 3602879701896397/2^55), so x*0.1 !=
        // x/10, in canon and in the Z3 backend alike.
        let mut ar_c = ExprArena::new();
        let x = ar_c.param_symbol("x");
        let tenth = ar_c.float_from_f64(0.1).unwrap();
        let lhs = ar_c.mul(x, tenth);
        let mut ar_d = ExprArena::new();
        let x = ar_d.param_symbol("x");
        let ten = ar_d.int(10);
        let rhs = ar_d.div(x, ten);
        assert_eq!(check(&ar_c, lhs, &ar_d, rhs), Z3Verdict::NotEquivalent);
    }

    #[test]
    fn negative_zero_equals_zero() {
        let mut ar_a = ExprArena::new();
        let nz = ar_a.float_from_f64(-0.0).unwrap();
        let mut ar_b = ExprArena::new();
        let z = ar_b.float_from_f64(0.0).unwrap();
        assert_eq!(check(&ar_a, nz, &ar_b, z), Z3Verdict::Equivalent);
    }

    /// Regression: translation used to recurse once per chain element and
    /// overflow the stack at ~16-20k-deep Fma spines (a matmul
    /// accumulator's shape). Translation-only: no solver involved.
    #[test]
    fn deep_fma_chain_translates_without_stack_overflow() {
        let mut ar = ExprArena::new();
        let a = ar.param_symbol("a");
        let b = ar.param_symbol("b");
        let mut acc = ar.param_symbol("acc");
        for _ in 0..100_000 {
            acc = ar.fma(a, b, acc);
        }
        let mut bld = Builder::new();
        assert!(translate_root(&mut bld, &ar, acc).is_ok());
    }

    /// `flatten` must not re-expand a node reachable twice in one chain (e.g.
    /// `Add(x, x)` doubling): 64 levels would be ~10^19 leaf visits without
    /// the visited cutoff.
    #[test]
    fn self_sharing_doubling_chain_translates_linearly() {
        let mut ar = ExprArena::new();
        let mut x = ar.param_symbol("x");
        for _ in 0..64 {
            x = ar.add(x, x);
        }
        let mut bld = Builder::new();
        assert!(translate_root(&mut bld, &ar, x).is_ok());

        let mut ar2 = ExprArena::new();
        let mut y = ar2.param_symbol("y");
        for _ in 0..64 {
            y = ar2.mul(y, y);
        }
        let mut bld2 = Builder::new();
        assert!(translate_root(&mut bld2, &ar2, y).is_ok());
    }

    /// The self-compare case goes to the solver like everything else
    /// (there is deliberately no structural short-circuit - the point is
    /// to measure Z3) and is proved.
    #[test]
    fn self_compare_is_proved_by_the_solver() {
        let mut ar = ExprArena::new();
        let x = ar.param_symbol("x");
        let y = ar.param_symbol("y");
        let sum = ar.add(x, y);
        let m = ar.max(sum, x);
        let res = check_equivalent(&ar, m, &ar, m, None, ExpMode::PowerBounded).unwrap();
        assert_eq!(res.verdict, Z3Verdict::Equivalent);
    }

    /// `exp(1)` must not prove equal to the rational 2718281828459045/10^15
    /// (a false EQUIVALENT): the exp base is a free constant strictly bounded
    /// around Euler's e.
    #[test]
    fn exp_of_one_is_not_a_rational() {
        let mut ar_a = ExprArena::new();
        let one = ar_a.int(1);
        let lhs = ar_a.exp(one);
        let mut ar_b = ExprArena::new();
        let rhs = ar_b.float_from_f64(2.718281828459045).unwrap();
        assert_eq!(check(&ar_a, lhs, &ar_b, rhs), Z3Verdict::NotEquivalent);
    }

    /// A `+` chain feeding a max atom must key the same whether or not a
    /// subterm is DAG-shared (else a false NOT-EQUIVALENT); multiset splicing
    /// ensures it.
    #[test]
    fn maxmin_key_is_sharing_independent() {
        // Side A: `xy = x + y` is one shared node, used by the subtrahend
        // AND inside the max argument. Side B: two separate x+y nodes.
        let mut ar_a = ExprArena::new();
        let x = ar_a.param_symbol("x");
        let y = ar_a.param_symbol("y");
        let w = ar_a.param_symbol("w");
        let z = ar_a.param_symbol("z");
        let p = ar_a.param_symbol("p");
        let xy = ar_a.add(x, y);
        let sub = ar_a.sub(p, xy);
        let arg = ar_a.add(xy, w);
        let m = ar_a.max(arg, z);
        let root_a = ar_a.add(sub, m);

        let mut ar_b = ExprArena::new();
        let x = ar_b.param_symbol("x");
        let y = ar_b.param_symbol("y");
        let w = ar_b.param_symbol("w");
        let z = ar_b.param_symbol("z");
        let p = ar_b.param_symbol("p");
        let xy1 = ar_b.add(x, y);
        let sub = ar_b.sub(p, xy1);
        let xy2 = ar_b.add(y, x);
        let arg = ar_b.add(xy2, w);
        let m = ar_b.max(arg, z);
        let root_b = ar_b.add(sub, m);

        assert_eq!(check(&ar_a, root_a, &ar_b, root_b), Z3Verdict::Equivalent);
    }

    /// `min(y - max(x,z), w)` vs `min(y + (-max(x,z)), w)`: Sub vs
    /// Add-of-Neg inside min/max arguments - the solver proves it (this
    /// was a measured false-DIFF class under the old opaque-atom design).
    #[test]
    fn sub_and_add_neg_are_one_term_inside_atoms() {
        let mut ar_a = ExprArena::new();
        let x = ar_a.param_symbol("x");
        let y = ar_a.param_symbol("y");
        let z = ar_a.param_symbol("z");
        let w = ar_a.param_symbol("w");
        let m = ar_a.max(x, z);
        let diff = ar_a.sub(y, m);
        let root_a = ar_a.min(diff, w);

        let mut ar_b = ExprArena::new();
        let x = ar_b.param_symbol("x");
        let y = ar_b.param_symbol("y");
        let z = ar_b.param_symbol("z");
        let w = ar_b.param_symbol("w");
        let m = ar_b.max(x, z);
        let neg = ar_b.neg(m);
        let sum = ar_b.add(y, neg);
        let root_b = ar_b.min(sum, w);

        assert_eq!(check(&ar_a, root_a, &ar_b, root_b), Z3Verdict::Equivalent);
    }

    /// Fma(a, b, c) renders as its definition a*b + c, so it is proved
    /// equal to the written-out form (common compiler variance).
    #[test]
    fn fma_desugars_to_mul_add() {
        let mut ar_a = ExprArena::new();
        let a = ar_a.param_symbol("a");
        let b = ar_a.param_symbol("b");
        let c = ar_a.param_symbol("c");
        let lhs = ar_a.fma(a, b, c);

        let mut ar_b = ExprArena::new();
        let a = ar_b.param_symbol("a");
        let b = ar_b.param_symbol("b");
        let c = ar_b.param_symbol("c");
        let prod = ar_b.mul(a, b);
        let rhs = ar_b.add(prod, c);

        let res = check_equivalent(&ar_a, lhs, &ar_b, rhs, None, ExpMode::PowerBounded).unwrap();
        assert_eq!(res.verdict, Z3Verdict::Equivalent);
    }

    /// Exact cancellation: x - x is the literal 0,
    /// x / x is the literal 1, -(-x) is x.
    #[test]
    fn cancellation_and_involution() {
        let mut ar = ExprArena::new();
        let x = ar.param_symbol("x");
        let d = ar.sub(x, x);
        let mut zr = ExprArena::new();
        let zero = zr.float_from_f64(0.0).unwrap();
        assert_eq!(
            check_equivalent(&ar, d, &zr, zero, None, ExpMode::PowerBounded)
                .unwrap()
                .verdict,
            Z3Verdict::Equivalent
        );

        // x / x vs 1 is NOT valid over SMT reals (division is underspecified
        // at zero, so x = 0 is a countermodel), a documented divergence from
        // canon's field semantics.
        let q = ar.div(x, x);
        let mut on = ExprArena::new();
        let one = on.float_from_f64(1.0).unwrap();
        assert_eq!(
            check_equivalent(&ar, q, &on, one, None, ExpMode::PowerBounded)
                .unwrap()
                .verdict,
            Z3Verdict::NotEquivalent
        );

        let n = ar.neg(x);
        let nn = ar.neg(n);
        let res = check_equivalent(&ar, nn, &ar, x, None, ExpMode::PowerBounded).unwrap();
        assert_eq!(res.verdict, Z3Verdict::Equivalent);
    }

    /// `x + (-0.1)` vs `x - 0.1`: negative literals vs negated positives
    /// are the solver's problem now, and it proves them equal.
    #[test]
    fn negative_literals_unify_with_negated_positives() {
        let mut ar_a = ExprArena::new();
        let x = ar_a.param_symbol("x");
        let neg_tenth = ar_a.float_from_f64(-0.1).unwrap();
        let lhs = ar_a.add(x, neg_tenth);

        let mut ar_b = ExprArena::new();
        let x = ar_b.param_symbol("x");
        let tenth = ar_b.float_from_f64(0.1).unwrap();
        let rhs = ar_b.sub(x, tenth);

        let res = check_equivalent(&ar_a, lhs, &ar_b, rhs, None, ExpMode::PowerBounded).unwrap();
        assert_eq!(res.verdict, Z3Verdict::Equivalent);

        // And exact cancellation across the two spellings: (x + -0.1) -
        // (x - 0.1) is the literal 0.
        let mut ar_c = ExprArena::new();
        let x = ar_c.param_symbol("x");
        let neg_tenth = ar_c.float_from_f64(-0.1).unwrap();
        let sum = ar_c.add(x, neg_tenth);
        let tenth = ar_c.float_from_f64(0.1).unwrap();
        let diff = ar_c.sub(x, tenth);
        let zero_expr = ar_c.sub(sum, diff);
        let mut zr = ExprArena::new();
        let zero = zr.float_from_f64(0.0).unwrap();
        assert_eq!(
            check_equivalent(&ar_c, zero_expr, &zr, zero, None, ExpMode::PowerBounded)
                .unwrap()
                .verdict,
            Z3Verdict::Equivalent
        );
    }
}
