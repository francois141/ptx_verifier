//! Equivalence checking of symbolic expressions: a thin wrapper over `canon`.
//! Use one `EquivSession` for many elements of a kernel pair, so shared
//! structure (score polys, softmax denominators) is free after the first.

use crate::canon::{CanonError, Session};
use crate::logging::info;
use crate::symbolic::{ExprArena, ExprId};

/// Errors from equivalence checking.
#[derive(Debug)]
pub enum EquivError {
    /// The decision procedure failed (undefined value, coefficient
    /// overflow, or an oversized VC).
    Canon(CanonError),
}

impl From<CanonError> for EquivError {
    fn from(e: CanonError) -> Self {
        Self::Canon(e)
    }
}

impl std::fmt::Display for EquivError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Canon(e) => write!(f, "{}", e),
        }
    }
}

impl std::error::Error for EquivError {}

pub type EquivResult<T> = Result<T, EquivError>;

/// A reusable checking session fixed to one kernel pair (memos key on
/// `(Side, ExprId)`). Past a term bound its intern tables are dropped and
/// rebuilt lazily, trading re-canonicalization for a hard memory cap.
pub struct EquivSession<'a> {
    session: Session,
    recycle_terms: usize,
    arena1: &'a ExprArena,
    arena2: &'a ExprArena,
}

/// Default recycle bound. Bytes per term are workload-dependent: polynomial
/// terms (matmul) run a few hundred bytes, exp-heavy attention terms average
/// 2-4 KB, so 4M terms retains roughly 1-16 GiB.
pub const DEFAULT_RECYCLE_TERMS: usize = 4_000_000;

impl<'a> EquivSession<'a> {
    pub fn new(arena1: &'a ExprArena, arena2: &'a ExprArena) -> Self {
        Self::with_recycle_terms(arena1, arena2, DEFAULT_RECYCLE_TERMS)
    }

    /// A session that recycles its intern tables past `recycle_terms`
    /// interned terms (`0` = never): lower bounds memory, costs re-canon.
    pub fn with_recycle_terms(
        arena1: &'a ExprArena,
        arena2: &'a ExprArena,
        recycle_terms: usize,
    ) -> Self {
        Self {
            session: Session::new(),
            recycle_terms,
            arena1,
            arena2,
        }
    }

    /// Check whether `e1` (in the first arena) and `e2` (in the second)
    /// are equivalent over the reals.
    pub fn check(&mut self, e1: ExprId, e2: ExprId) -> EquivResult<bool> {
        if self.recycle_terms != 0 && self.session.interned_terms() > self.recycle_terms {
            info!(
                "recycling VC session at {} interned terms",
                self.session.interned_terms()
            );
            self.session = Session::new();
        }
        Ok(self
            .session
            .check_equivalent(self.arena1, e1, self.arena2, e2)?)
    }
}

/// One-shot equivalence check (a fresh session per call; prefer
/// `EquivSession` in loops).
pub fn check_equivalent(
    arena1: &ExprArena,
    e1: ExprId,
    arena2: &ExprArena,
    e2: ExprId,
) -> EquivResult<bool> {
    EquivSession::new(arena1, arena2).check(e1, e2)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simple_equivalence() {
        // (a + b) == (b + a)
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let b = arena.param_symbol("b");
        let e1 = arena.add(a, b);
        let e2 = arena.add(b, a);
        assert!(check_equivalent(&arena, e1, &arena, e2).unwrap());
    }

    #[test]
    fn test_distributivity() {
        // a * (b + c) == a*b + a*c
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let b = arena.param_symbol("b");
        let c = arena.param_symbol("c");
        let bc = arena.add(b, c);
        let e1 = arena.mul(a, bc);
        let ab = arena.mul(a, b);
        let ac = arena.mul(a, c);
        let e2 = arena.add(ab, ac);
        assert!(check_equivalent(&arena, e1, &arena, e2).unwrap());
    }

    #[test]
    fn test_not_equivalent() {
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let b = arena.param_symbol("b");
        assert!(!check_equivalent(&arena, a, &arena, b).unwrap());
    }

    #[test]
    fn test_reduction_pattern() {
        let mut arena = ExprArena::new();
        let i0 = arena.param_symbol("input_0");
        let i1 = arena.param_symbol("input_1");
        let i2 = arena.param_symbol("input_2");
        let i3 = arena.param_symbol("input_3");

        let t1 = arena.add(i3, i2);
        let t2 = arena.add(i1, i0);
        let e1 = arena.add(t1, t2);

        let t3 = arena.add(i3, i1);
        let t4 = arena.add(i2, i0);
        let e2 = arena.add(t3, t4);
        assert!(check_equivalent(&arena, e1, &arena, e2).unwrap());
    }

    #[test]
    fn test_exp_identity() {
        // exp(a) * exp(b) == exp(a + b)
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let b = arena.param_symbol("b");
        let ea = arena.exp(a);
        let eb = arena.exp(b);
        let e1 = arena.mul(ea, eb);
        let ab = arena.add(a, b);
        let e2 = arena.exp(ab);
        assert!(check_equivalent(&arena, e1, &arena, e2).unwrap());
    }

    #[test]
    fn test_fma_expansion() {
        // fma(a, b, c) == a*b + c
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let b = arena.param_symbol("b");
        let c = arena.param_symbol("c");
        let e1 = arena.fma(a, b, c);
        let ab = arena.mul(a, b);
        let e2 = arena.add(ab, c);
        assert!(check_equivalent(&arena, e1, &arena, e2).unwrap());
    }

    #[test]
    fn test_softmax_normalization_equivalence() {
        // exp(a)/(exp(a)+exp(b)) == exp(a-M)/(exp(a-M)+exp(b-M)), M = max(a,b)
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let b = arena.param_symbol("b");
        let m = arena.max(a, b);

        let ea = arena.exp(a);
        let eb = arena.exp(b);
        let d1 = arena.add(ea, eb);
        let e1 = arena.div(ea, d1);

        let am = arena.sub(a, m);
        let bm = arena.sub(b, m);
        let eam = arena.exp(am);
        let ebm = arena.exp(bm);
        let d2 = arena.add(eam, ebm);
        let e2 = arena.div(eam, d2);

        assert!(check_equivalent(&arena, e1, &arena, e2).unwrap());
    }

    #[test]
    fn test_session_reuse_across_elements() {
        // The same session checks several related identities.
        let mut arena = ExprArena::new();
        let sid = arena.intern_string("a");
        let tid = arena.intern_string("b");
        let elements: Vec<(ExprId, ExprId)> = (0..4)
            .map(|i| {
                let a = arena.input_element(sid, i);
                let b = arena.input_element(tid, i);
                (arena.add(a, b), arena.add(b, a))
            })
            .collect();
        let mut session = EquivSession::new(&arena, &arena);
        for (ab, ba) in elements {
            assert!(session.check(ab, ba).unwrap());
        }
    }

    #[test]
    fn test_undefined_error() {
        let mut arena = ExprArena::new();
        let a = arena.param_symbol("a");
        let u = arena.undefined();
        assert!(check_equivalent(&arena, a, &arena, u).is_err());
    }

    /// Regression: a named symbol spelling a machine symbol's name (`"s{N}"`)
    /// must not intern to the same canon variable as machine `Symbol(N)`.
    #[test]
    fn named_symbol_does_not_alias_machine_symbol() {
        use crate::symbolic::ExprNode;

        let mut arena = ExprArena::new();
        let machine = arena.symbol();
        let ExprNode::Symbol(sym) = *arena.node(machine) else {
            panic!("arena.symbol() must produce ExprNode::Symbol");
        };
        let named = arena.param_symbol(sym.to_string());
        assert!(
            !check_equivalent(&arena, machine, &arena, named).unwrap(),
            "machine Symbol({}) and NamedSymbol(\"{}\") are independent values",
            sym.0,
            sym
        );
        // And a named symbol still correlates with itself across arenas.
        let mut other = ExprArena::new();
        let named_other = other.param_symbol(sym.to_string());
        assert!(check_equivalent(&arena, named, &other, named_other).unwrap());
    }
}
