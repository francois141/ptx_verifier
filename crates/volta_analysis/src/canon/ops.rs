//! Canonical polynomial and rational algebra on *transient* owned polys (`PV::Owned`):
//! only terms and exp arguments are interned, whole polys only at `Session` sharing
//! boundaries (keeps chains linear in memory). `arena` invariants hold; ops tick the budget.

use std::collections::HashMap;

use super::arena::{Poly, PolyId, Rat, Term, TermId};
use super::coeff::Coeff;
use super::{CanonError, Session};
use crate::logging::debug;

/// A polynomial value: interned (shared) or transient (exclusively owned).
#[derive(Debug, Clone)]
pub(crate) enum PV {
    Id(PolyId),
    Owned(Poly),
}

/// A rational value over `PV`s (the transient counterpart of `Rat`).
#[derive(Debug, Clone)]
pub(crate) struct RatV {
    pub numer: PV,
    pub denom: PV,
}

impl RatV {
    pub fn from_rat(r: Rat) -> RatV {
        RatV {
            numer: PV::Id(r.numer),
            denom: PV::Id(r.denom),
        }
    }
}

impl Session {
    pub(crate) fn tick(&mut self, n: u64) -> Result<(), CanonError> {
        self.ops += n;
        if self.ops > self.budget {
            Err(CanonError::Budget { limit: self.budget })
        } else {
            Ok(())
        }
    }

    // =====================================================================
    // PV helpers
    // =====================================================================

    /// Take the underlying vector (clones only for interned inputs).
    pub(crate) fn pv_into(&self, pv: PV) -> Poly {
        match pv {
            PV::Id(p) => self.arena.polys.get(p).clone(),
            PV::Owned(v) => v,
        }
    }

    pub(crate) fn pv_slice<'a>(&'a self, pv: &'a PV) -> &'a [(TermId, Coeff)] {
        match pv {
            PV::Id(p) => self.arena.polys.get(*p),
            PV::Owned(v) => v,
        }
    }

    pub(crate) fn pv_is_zero(&self, pv: &PV) -> bool {
        self.pv_slice(pv).is_empty()
    }

    pub(crate) fn pv_is_one(&self, pv: &PV) -> bool {
        matches!(self.pv_slice(pv), [(t, c)] if *t == self.arena.const_term && c.is_one())
    }

    pub(crate) fn pv_eq(&self, a: &PV, b: &PV) -> bool {
        if let (PV::Id(pa), PV::Id(pb)) = (a, b) {
            return pa == pb;
        }
        self.pv_slice(a) == self.pv_slice(b)
    }

    pub(crate) fn pv_intern(&mut self, pv: PV) -> PolyId {
        match pv {
            PV::Id(p) => p,
            PV::Owned(v) => self.arena.intern_poly(v),
        }
    }

    pub(crate) fn ratv_intern(&mut self, rv: RatV) -> Rat {
        Rat {
            numer: self.pv_intern(rv.numer),
            denom: self.pv_intern(rv.denom),
        }
    }

    pub(crate) fn ratv_one_denom(&self, numer: Poly) -> RatV {
        RatV {
            numer: PV::Owned(numer),
            denom: PV::Id(self.arena.one),
        }
    }

    // =====================================================================
    // Polynomials (owned-vector core)
    // =====================================================================

    /// `a + b`: merge of two sorted term lists; `E + (-E)` cancels here.
    pub(crate) fn poly_add_vec(&mut self, mut a: Poly, mut b: Poly) -> Result<Poly, CanonError> {
        if a.is_empty() {
            return Ok(b);
        }
        if b.is_empty() {
            return Ok(a);
        }
        // Append fast path: chain unwinding yields fresh terms with *smaller* ids
        // than everything accumulated, so under descending order this is an O(1)
        // append and a K-step chain stays O(K) overall.
        if a.last().unwrap().0 > b.first().unwrap().0 {
            self.tick(b.len() as u64)?;
            a.append(&mut b);
            return Ok(a);
        }
        if b.last().unwrap().0 > a.first().unwrap().0 {
            self.tick(a.len() as u64)?;
            b.append(&mut a);
            return Ok(b);
        }
        self.tick((a.len() + b.len()) as u64)?;

        let mut out: Poly = Vec::with_capacity(a.len() + b.len());
        let (mut i, mut j) = (0, 0);
        while i < a.len() && j < b.len() {
            let (ta, ca) = a[i];
            let (tb, cb) = b[j];
            match tb.cmp(&ta) {
                std::cmp::Ordering::Less => {
                    out.push((ta, ca));
                    i += 1;
                }
                std::cmp::Ordering::Greater => {
                    out.push((tb, cb));
                    j += 1;
                }
                std::cmp::Ordering::Equal => {
                    let c = ca.add(&cb)?;
                    if !c.is_zero() {
                        out.push((ta, c));
                    }
                    i += 1;
                    j += 1;
                }
            }
        }
        out.extend_from_slice(&a[i..]);
        out.extend_from_slice(&b[j..]);
        Ok(out)
    }

    /// `c * a` for a scalar, in place.
    pub(crate) fn poly_scale_vec(&mut self, mut a: Poly, c: &Coeff) -> Result<Poly, CanonError> {
        if c.is_one() {
            return Ok(a);
        }
        if c.is_zero() {
            return Ok(Vec::new());
        }
        self.tick(a.len() as u64)?;
        for (_, ca) in a.iter_mut() {
            *ca = ca.mul(c)?;
        }
        Ok(a)
    }

    /// `(c * t) * a` for a monomial: the building block of multiplication.
    pub(crate) fn poly_mul_monomial_vec(
        &mut self,
        a: Poly,
        t: TermId,
        c: &Coeff,
    ) -> Result<Poly, CanonError> {
        if c.is_zero() || a.is_empty() {
            return Ok(Vec::new());
        }
        if t == self.arena.const_term {
            return self.poly_scale_vec(a, c);
        }
        self.tick(a.len() as u64)?;
        let mut out: Poly = Vec::with_capacity(a.len());
        for (ta, ca) in a {
            out.push((self.term_mul(ta, t)?, ca.mul(c)?));
        }
        // Term ids permute under multiplication; restore sortedness. Merging
        // duplicates cannot be skipped: t*x and t*y may collide (exp fusion).
        out.sort_by_key(|(t, _)| std::cmp::Reverse(*t));
        merge_sorted(out)
    }

    /// Full product `a * b` (distribution; the paper's monomial collection).
    pub(crate) fn poly_mul_vec(
        &mut self,
        a: &[(TermId, Coeff)],
        b: &[(TermId, Coeff)],
    ) -> Result<Poly, CanonError> {
        if a.is_empty() || b.is_empty() {
            return Ok(Vec::new());
        }
        self.tick((a.len() * b.len()) as u64)?;

        let mut acc: HashMap<TermId, Coeff> = HashMap::with_capacity(a.len() * b.len());
        // Clone the operand slices' data up front so `term_mul` can borrow
        // the session mutably inside the loop.
        let a: Vec<_> = a.to_vec();
        let b: Vec<_> = b.to_vec();
        for &(ta, ca) in &a {
            for &(tb, cb) in &b {
                let t = self.term_mul(ta, tb)?;
                let c = ca.mul(&cb)?;
                match acc.entry(t) {
                    std::collections::hash_map::Entry::Occupied(mut e) => {
                        let sum = e.get().add(&c)?;
                        if sum.is_zero() {
                            e.remove();
                        } else {
                            *e.get_mut() = sum;
                        }
                    }
                    std::collections::hash_map::Entry::Vacant(e) => {
                        e.insert(c);
                    }
                }
            }
        }
        let mut out: Poly = acc.into_iter().collect();
        out.sort_by_key(|(t, _)| std::cmp::Reverse(*t));
        Ok(out)
    }

    /// Interned-id addition (used for exp-argument fusion, which must
    /// produce interned polys).
    pub(crate) fn poly_add_ids(&mut self, a: PolyId, b: PolyId) -> Result<PolyId, CanonError> {
        if a == self.arena.zero {
            return Ok(b);
        }
        if b == self.arena.zero {
            return Ok(a);
        }
        let va = self.arena.polys.get(a).clone();
        let vb = self.arena.polys.get(b).clone();
        let sum = self.poly_add_vec(va, vb)?;
        Ok(self.arena.intern_poly(sum))
    }

    // =====================================================================
    // Terms
    // =====================================================================

    /// Monomial product: merge factor multisets and fuse exponentials
    /// (`e^p · e^q = e^{p+q}`; `e^0` vanishes).
    pub(crate) fn term_mul(&mut self, a: TermId, b: TermId) -> Result<TermId, CanonError> {
        if a == self.arena.const_term {
            return Ok(b);
        }
        if b == self.arena.const_term {
            return Ok(a);
        }
        let key = if a <= b { (a, b) } else { (b, a) };
        if let Some(&t) = self.term_mul_memo.get(&key) {
            return Ok(t);
        }

        let ta = self.arena.terms.get(a).clone();
        let tb = self.arena.terms.get(b).clone();
        self.tick((ta.factors.len() + tb.factors.len() + 1) as u64)?;

        let mut factors = Vec::with_capacity(ta.factors.len() + tb.factors.len());
        let (mut i, mut j) = (0, 0);
        while i < ta.factors.len() && j < tb.factors.len() {
            let (fa, pa) = ta.factors[i];
            let (fb, pb) = tb.factors[j];
            match fa.cmp(&fb) {
                std::cmp::Ordering::Less => {
                    factors.push((fa, pa));
                    i += 1;
                }
                std::cmp::Ordering::Greater => {
                    factors.push((fb, pb));
                    j += 1;
                }
                std::cmp::Ordering::Equal => {
                    factors.push((fa, pa.checked_add(pb).ok_or(CanonError::PowerOverflow)?));
                    i += 1;
                    j += 1;
                }
            }
        }
        factors.extend_from_slice(&ta.factors[i..]);
        factors.extend_from_slice(&tb.factors[j..]);

        let exp = match (ta.exp, tb.exp) {
            (None, e) | (e, None) => e,
            (Some(p), Some(q)) => {
                let fused = self.poly_add_ids(p, q)?;
                if fused == self.arena.zero {
                    None // e^0 = 1
                } else {
                    Some(fused)
                }
            }
        };

        let t = self.arena.terms.intern(Term { factors, exp });
        self.term_mul_memo.insert(key, t);
        Ok(t)
    }

    /// `a / b` as a monomial, if `b`'s factors divide `a`'s (exponentials
    /// always divide; symbol/atom powers must not go negative).
    pub(crate) fn term_div(&mut self, a: TermId, b: TermId) -> Result<Option<TermId>, CanonError> {
        if b == self.arena.const_term {
            return Ok(Some(a));
        }
        let ta = self.arena.terms.get(a).clone();
        let tb = self.arena.terms.get(b).clone();
        self.tick((ta.factors.len() + tb.factors.len() + 1) as u64)?;

        let mut factors = Vec::with_capacity(ta.factors.len());
        let mut i = 0;
        for &(fb, pb) in &tb.factors {
            // Copy factors of `a` below fb, then divide at fb.
            loop {
                if i >= ta.factors.len() {
                    return Ok(None); // fb not present in a
                }
                let (fa, pa) = ta.factors[i];
                if fa < fb {
                    factors.push((fa, pa));
                    i += 1;
                } else if fa == fb {
                    if pa < pb {
                        return Ok(None); // would need a negative power
                    }
                    if pa > pb {
                        factors.push((fa, pa - pb));
                    }
                    i += 1;
                    break;
                } else {
                    return Ok(None); // fb not present in a
                }
            }
        }
        factors.extend_from_slice(&ta.factors[i..]);

        let exp = match (ta.exp, tb.exp) {
            (e, None) => e,
            (a_exp, Some(q)) => {
                let neg_q_vec = {
                    let v = self.arena.polys.get(q).clone();
                    self.poly_scale_vec(v, &Coeff::MINUS_ONE)?
                };
                let diff = match a_exp {
                    Some(p) => {
                        let vp = self.arena.polys.get(p).clone();
                        self.poly_add_vec(vp, neg_q_vec)?
                    }
                    None => neg_q_vec,
                };
                if diff.is_empty() {
                    None
                } else {
                    Some(self.arena.intern_poly(diff))
                }
            }
        };

        Ok(Some(self.arena.terms.intern(Term { factors, exp })))
    }

    // =====================================================================
    // Rationals
    // =====================================================================

    /// Establish the `Rat` invariants for `numer / denom`: a zero numerator becomes `0/1`;
    /// a symbol/atom-free monomial denominator folds into the numerator; otherwise scale
    /// so the denominator's leading coefficient is 1 (scalar multiples intern identically).
    pub(crate) fn rat_normalize_v(&mut self, numer: PV, denom: PV) -> Result<RatV, CanonError> {
        if self.pv_is_zero(&denom) {
            return Err(CanonError::DivisionByZero);
        }
        if self.pv_is_zero(&numer) {
            return Ok(RatV::from_rat(self.arena.rat_zero()));
        }
        if self.pv_is_one(&denom) {
            return Ok(RatV {
                numer,
                denom: PV::Id(self.arena.one),
            });
        }

        let (d_first, d_single) = {
            let d = self.pv_slice(&denom);
            (d[0], d.len() == 1)
        };
        if d_single {
            let (t, c) = d_first;
            let term = self.arena.terms.get(t).clone();
            if term.factors.is_empty() {
                // 1 / (c * e^{p}) = (1/c) * e^{-p}
                let inv_c = c.recip()?;
                let inv_t = match term.exp {
                    None => self.arena.const_term,
                    Some(p) => {
                        let vp = self.arena.polys.get(p).clone();
                        let neg = self.poly_scale_vec(vp, &Coeff::MINUS_ONE)?;
                        let neg = self.arena.intern_poly(neg);
                        self.arena.terms.intern(Term {
                            factors: Vec::new(),
                            exp: Some(neg),
                        })
                    }
                };
                let nv = self.pv_into(numer);
                let folded = self.poly_mul_monomial_vec(nv, inv_t, &inv_c)?;
                return Ok(RatV {
                    numer: PV::Owned(folded),
                    denom: PV::Id(self.arena.one),
                });
            }
        }

        // Scale so the denominator's leading coefficient is 1.
        let lead = d_first.1;
        if lead.is_one() {
            return Ok(RatV { numer, denom });
        }
        let inv = lead.recip()?;
        let nv = self.pv_into(numer);
        let dv = self.pv_into(denom);
        let numer = self.poly_scale_vec(nv, &inv)?;
        let denom = self.poly_scale_vec(dv, &inv)?;
        Ok(RatV {
            numer: PV::Owned(numer),
            denom: PV::Owned(denom),
        })
    }

    pub(crate) fn rat_add_v(&mut self, a: RatV, b: RatV) -> Result<RatV, CanonError> {
        // Fast path: two polynomial values (the accumulator-chain case).
        if self.pv_is_one(&a.denom) && self.pv_is_one(&b.denom) {
            let va = self.pv_into(a.numer);
            let vb = self.pv_into(b.numer);
            let sum = self.poly_add_vec(va, vb)?;
            return Ok(self.ratv_one_denom(sum));
        }
        if self.pv_eq(&a.denom, &b.denom) {
            let va = self.pv_into(a.numer);
            let vb = self.pv_into(b.numer);
            let numer = self.poly_add_vec(va, vb)?;
            return self.rat_normalize_v(PV::Owned(numer), a.denom);
        }
        let an = self.pv_into(a.numer);
        let ad = self.pv_into(a.denom);
        let bn = self.pv_into(b.numer);
        let bd = self.pv_into(b.denom);
        let n1 = self.poly_mul_vec(&an, &bd)?;
        let n2 = self.poly_mul_vec(&bn, &ad)?;
        let numer = self.poly_add_vec(n1, n2)?;
        let denom = self.poly_mul_vec(&ad, &bd)?;
        self.rat_normalize_v(PV::Owned(numer), PV::Owned(denom))
    }

    pub(crate) fn rat_neg_v(&mut self, a: RatV) -> Result<RatV, CanonError> {
        let nv = self.pv_into(a.numer);
        let numer = self.poly_scale_vec(nv, &Coeff::MINUS_ONE)?;
        Ok(RatV {
            numer: PV::Owned(numer),
            denom: a.denom,
        })
    }

    pub(crate) fn rat_sub_v(&mut self, a: RatV, b: RatV) -> Result<RatV, CanonError> {
        let nb = self.rat_neg_v(b)?;
        self.rat_add_v(a, nb)
    }

    pub(crate) fn rat_mul_v(&mut self, a: RatV, b: RatV) -> Result<RatV, CanonError> {
        // Fast path: multiplying a polynomial by a monomial (running
        // rescales like `o * e^{m - m'}`) avoids the general convolution.
        if self.pv_is_one(&a.denom) && self.pv_is_one(&b.denom) {
            let (mono, other) = if self.pv_slice(&a.numer).len() == 1 {
                (a.numer, b.numer)
            } else if self.pv_slice(&b.numer).len() == 1 {
                (b.numer, a.numer)
            } else {
                let an = self.pv_into(a.numer);
                let bn = self.pv_into(b.numer);
                let prod = self.poly_mul_vec(&an, &bn)?;
                return Ok(self.ratv_one_denom(prod));
            };
            let &[(t, c)] = self.pv_slice(&mono) else {
                unreachable!("checked single-term above")
            };
            let ov = self.pv_into(other);
            let prod = self.poly_mul_monomial_vec(ov, t, &c)?;
            return Ok(self.ratv_one_denom(prod));
        }
        let an = self.pv_into(a.numer);
        let ad = self.pv_into(a.denom);
        let bn = self.pv_into(b.numer);
        let bd = self.pv_into(b.denom);
        let numer = self.poly_mul_vec(&an, &bn)?;
        let denom = self.poly_mul_vec(&ad, &bd)?;
        self.rat_normalize_v(PV::Owned(numer), PV::Owned(denom))
    }

    pub(crate) fn rat_div_v(&mut self, a: RatV, b: RatV) -> Result<RatV, CanonError> {
        if self.pv_is_zero(&b.numer) {
            return Err(CanonError::DivisionByZero);
        }
        let an = self.pv_into(a.numer);
        let ad = self.pv_into(a.denom);
        let bn = self.pv_into(b.numer);
        let bd = self.pv_into(b.denom);
        let numer = self.poly_mul_vec(&an, &bd)?;
        let denom = self.poly_mul_vec(&ad, &bn)?;
        self.rat_normalize_v(PV::Owned(numer), PV::Owned(denom))
    }

    // =====================================================================
    // Equality
    // =====================================================================

    /// Decide `a = b` over the reals (denominators are nonzero by the
    /// domain's construction). Escalates: id equality, monomial-quotient,
    /// full cross-multiplication.
    pub fn equivalent(&mut self, a: Rat, b: Rat) -> Result<bool, CanonError> {
        if a == b {
            return Ok(true);
        }

        // Monomial-quotient: if d_a = q * d_b for a monomial q, then
        // a = b  iff  n_a = q * n_b. Decides softmax rescalings in O(|d|).
        if a.denom != b.denom
            && let Some(verdict) = self.try_monomial_quotient(a, b)?
        {
            debug!("VC decided by monomial quotient: {}", verdict);
            return Ok(verdict);
        }

        // Cross-multiply canonical forms (transient results; compared as
        // vectors, never interned).
        let na = self.arena.polys.get(a.numer).clone();
        let db = self.arena.polys.get(b.denom).clone();
        let nb = self.arena.polys.get(b.numer).clone();
        let da = self.arena.polys.get(a.denom).clone();
        debug!(
            "VC cross-multiplying: |n_a|={} |d_b|={} |n_b|={} |d_a|={}",
            na.len(),
            db.len(),
            nb.len(),
            da.len()
        );
        let lhs = self.poly_mul_vec(&na, &db)?;
        let rhs = self.poly_mul_vec(&nb, &da)?;
        Ok(lhs == rhs)
    }

    /// If some monomial `q` satisfies `a.denom = q * b.denom`, the fractions
    /// compare in linear time. Returns None when no such q exists (fall back
    /// to cross-multiplication).
    fn try_monomial_quotient(&mut self, a: Rat, b: Rat) -> Result<Option<bool>, CanonError> {
        let da = self.arena.polys.get(a.denom).clone();
        let db = self.arena.polys.get(b.denom).clone();
        if da.is_empty() || db.is_empty() || da.len() != db.len() {
            return Ok(None);
        }

        // d_a's first term must be q times *some* term of d_b.
        let (ta, ca) = da[0];
        for &(tb, cb) in &db {
            let Some(qt) = self.term_div(ta, tb)? else {
                continue;
            };
            let qc = ca.mul(&cb.recip()?)?;
            let scaled = self.poly_mul_monomial_vec(db.clone(), qt, &qc)?;
            if scaled != da {
                continue;
            }
            let nb = self.arena.polys.get(b.numer).clone();
            let scaled_numer = self.poly_mul_monomial_vec(nb, qt, &qc)?;
            let na = self.arena.polys.get(a.numer);
            return Ok(Some(&scaled_numer == na));
        }
        Ok(None)
    }
}

/// Merge duplicate term ids in a sorted (term, coeff) list.
fn merge_sorted(sorted: Poly) -> Result<Poly, CanonError> {
    let mut out: Poly = Vec::with_capacity(sorted.len());
    for (t, c) in sorted {
        match out.last_mut() {
            Some((last_t, last_c)) if *last_t == t => {
                let sum = last_c.add(&c)?;
                if sum.is_zero() {
                    out.pop();
                } else {
                    *last_c = sum;
                }
            }
            _ => out.push((t, c)),
        }
    }
    Ok(out)
}
