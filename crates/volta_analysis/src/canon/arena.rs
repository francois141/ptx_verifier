//! Interned canonical forms.
//!
//! Four interned layers give every canonical object a stable id, so
//! structural equality anywhere in the engine is an integer compare:
//!
//! ```text
//! Poly   = sorted Vec<(TermId, Coeff)>      Σ c·term (sums, exp args)
//! Term   = monomial factors + optional e^{poly}
//! Factor = input symbol | opaque atom
//! Atom   = max/min | uninterpreted op over rationals
//! ```
//!
//! `Rat` (a numerator/denominator pair of polys) is plain `Copy` data; it
//! needs no interner of its own.

use std::collections::HashMap;
use std::hash::Hash;

use id_collections::{IdVec, id_type};

use super::coeff::Coeff;
use crate::symbolic::{SymbolId, SymbolRef};

#[id_type]
pub struct PolyId(pub u32);

#[id_type]
pub struct TermId(pub u32);

#[id_type]
pub struct FactorId(pub u32);

#[id_type]
pub struct AtomId(pub u32);

#[id_type]
pub struct SymId(pub u32);

/// A multiplicative factor of a monomial (exp factors live on `Term::exp`).
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Factor {
    /// A named input symbol (e.g. `Q[5]`, `alpha`)
    Symbol(SymId),
    /// An opaque atom (max/min/uninterpreted)
    Atom(AtomId),
}

/// A canonical monomial: sorted factors with positive powers, and at most
/// one fused exponential `e^{exp}` (the invariant behind `e^a·e^b = e^{a+b}`).
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Term {
    /// Sorted by `FactorId`, powers >= 1; empty = the constant term
    pub factors: Vec<(FactorId, u32)>,
    /// The fused exponential's argument, if any (never the zero poly)
    pub exp: Option<PolyId>,
}

impl Term {
    pub fn constant() -> Term {
        Term {
            factors: Vec::new(),
            exp: None,
        }
    }

    pub fn is_constant(&self) -> bool {
        self.factors.is_empty() && self.exp.is_none()
    }
}

/// A canonical polynomial: sorted by *descending* `TermId`, no zero
/// coefficients. Descending because chain canonicalization interns fresh
/// terms with decreasing ids as it unwinds - descending order turns each
/// accumulator step into an O(1) append (see `ops::poly_add_vec`).
pub type Poly = Vec<(TermId, Coeff)>;

/// The operator of an uninterpreted atom. These stay opaque in the
/// canonical form: two atoms are equal iff the operator and all canonical
/// arguments are equal.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum UninterpOp {
    /// `exp` with a genuinely rational (non-polynomial) argument; the
    /// polynomial case fuses into `Term::exp` instead.
    Exp,
    Log,
    Sqrt,
    Abs,
    Sign,
    Rem,
    BitAnd,
    BitOr,
    BitXor,
    BitNot,
    Shl,
    Shr,
    LShr,
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
    And,
    Or,
    Not,
    Select,
    /// A data-dependent read of the named input array.
    ArrayRead(String),
}

/// An opaque atom. Arguments are canonical rationals, so identical
/// computations intern to the same atom id.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Atom {
    /// max/min over flattened, sorted, deduplicated arguments (>= 2 of them)
    MaxMin { is_max: bool, args: Vec<Rat> },
    /// Uninterpreted operation (comparisons, bitwise, select, rem, ...)
    Uninterp { op: UninterpOp, args: Vec<Rat> },
}

/// A canonical rational: `numer / denom`. `denom` is the constant-one poly
/// for polynomial values, and is normalized to leading coefficient 1.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Rat {
    pub numer: PolyId,
    pub denom: PolyId,
}

/// A hash-consing interner: value -> id, id -> value.
#[derive(Debug)]
pub struct Interner<Id: id_collections::Id, T> {
    values: IdVec<Id, T>,
    ids: HashMap<T, Id>,
}

impl<Id: id_collections::Id, T: Clone + Eq + Hash> Interner<Id, T> {
    fn new() -> Self {
        Self {
            values: IdVec::new(),
            ids: HashMap::new(),
        }
    }

    pub fn intern(&mut self, value: T) -> Id {
        if let Some(&id) = self.ids.get(&value) {
            return id;
        }
        let id = self.values.push(value.clone());
        self.ids.insert(value, id);
        id
    }

    pub fn get(&self, id: Id) -> &T {
        &self.values[id]
    }

    pub fn len(&self) -> usize {
        self.ids.len()
    }
}

/// Owned mirror of [`SymbolRef`] for the symbol intern table.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum SymbolKey {
    Param(String),
    Element { array: String, index: u64 },
    Machine(SymbolId),
}

impl From<SymbolRef<'_>> for SymbolKey {
    fn from(sym: SymbolRef<'_>) -> Self {
        match sym {
            SymbolRef::Param(name) => SymbolKey::Param(name.to_string()),
            SymbolRef::Element { array, index } => SymbolKey::Element {
                array: array.to_string(),
                index,
            },
            SymbolRef::Machine(id) => SymbolKey::Machine(id),
        }
    }
}

/// The intern tables for one canonicalization session.
#[derive(Debug)]
pub struct CanonArena {
    pub symbols: Interner<SymId, SymbolKey>,
    pub factors: Interner<FactorId, Factor>,
    pub terms: Interner<TermId, Term>,
    pub polys: Interner<PolyId, Poly>,
    pub atoms: Interner<AtomId, Atom>,

    /// The empty (zero) polynomial
    pub zero: PolyId,
    /// The constant-one polynomial
    pub one: PolyId,
    /// The empty monomial
    pub const_term: TermId,
}

impl Default for CanonArena {
    fn default() -> Self {
        Self::new()
    }
}

impl CanonArena {
    pub fn new() -> Self {
        let mut symbols = Interner::new();
        let mut factors = Interner::new();
        let mut terms = Interner::new();
        let mut polys = Interner::new();
        let mut atoms = Interner::new();
        let _ = (&mut symbols, &mut factors, &mut atoms);

        let const_term = terms.intern(Term::constant());
        let zero = polys.intern(Vec::new());
        let one = polys.intern(vec![(const_term, Coeff::ONE)]);

        Self {
            symbols,
            factors,
            terms,
            polys,
            atoms,
            zero,
            one,
            const_term,
        }
    }

    /// Intern a polynomial; the caller guarantees descending sortedness and
    /// no zeros.
    pub fn intern_poly(&mut self, poly: Poly) -> PolyId {
        debug_assert!(poly.windows(2).all(|w| w[0].0 > w[1].0), "poly not sorted");
        debug_assert!(poly.iter().all(|(_, c)| !c.is_zero()), "zero coeff kept");
        self.polys.intern(poly)
    }

    /// The polynomial `c` (a constant).
    pub fn const_poly(&mut self, c: Coeff) -> PolyId {
        if c.is_zero() {
            self.zero
        } else {
            let term = self.const_term;
            self.intern_poly(vec![(term, c)])
        }
    }

    /// The polynomial consisting of a single symbol.
    pub fn symbol_poly(&mut self, sym: SymbolRef<'_>) -> PolyId {
        let sym = self.symbols.intern(SymbolKey::from(sym));
        let factor = self.factors.intern(Factor::Symbol(sym));
        let term = self.terms.intern(Term {
            factors: vec![(factor, 1)],
            exp: None,
        });
        self.intern_poly(vec![(term, Coeff::ONE)])
    }

    /// The polynomial consisting of a single atom factor.
    pub fn atom_poly(&mut self, atom: Atom) -> PolyId {
        let id = self.atoms.intern(atom);
        let factor = self.factors.intern(Factor::Atom(id));
        let term = self.terms.intern(Term {
            factors: vec![(factor, 1)],
            exp: None,
        });
        self.intern_poly(vec![(term, Coeff::ONE)])
    }

    /// The rational `p / 1`.
    pub fn rat_poly(&self, numer: PolyId) -> Rat {
        Rat {
            numer,
            denom: self.one,
        }
    }

    /// The rational `0`.
    pub fn rat_zero(&self) -> Rat {
        Rat {
            numer: self.zero,
            denom: self.one,
        }
    }
}
