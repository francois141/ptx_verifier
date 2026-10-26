# volta_equivalence

The equivalence branch: given two `SymbolicOutputs` (two kernels, or a kernel
and an unfolded spec), decide element by element whether they compute the same
value. It depends only on `volta_expr`, so its inputs can come from any
producer: in memory, a `.vcdump`, or `.vexpr` text.

## High-level logic

```
ref outputs, opt outputs, arrays to check
   │ paired_elements           pair each named array's written elements (index sets must match)
   │ sampled_elements          optionally keep each array's first N elements
   ▼
for each element: EquivSession::check(ref_expr, opt_expr)
   │   canonicalize both sides into normal forms, compare
   ▼
Equivalent / Different / Unknown per element  ──(--verify-numeric)──► f64 oracle confirms
```

## Decision procedure (`canon/`, `equiv.rs`)

This is the paper's canonicalizer. Each expression is rewritten bottom-up, with
memoization, into a **canonical rational form**:

```
Σ c · monomial · e^{poly}   /   Σ c · monomial · e^{poly}
```

- Coefficients are exact i128 rationals (`coeff.rs`). `e^a · e^b` fuses when
  terms are multiplied. `max`/`min` flatten into sorted atom lists.
- Terms and polynomials are interned in one `Session` shared by both kernels
  and all elements (`arena.rs`). Two equal normal forms are then the same id.
- Operations outside the fragment (sqrt, log, bitwise, comparisons, select,
  symbolic array reads) become opaque `Atom::Uninterp` atoms. This is sound
  but incomplete: two such atoms are equal only if they are structurally equal.
- Fraction equality tries, in order: id comparison, then monomial quotient
  (catches softmax rescaling), then cross-multiplication under a term budget.
- Two performance invariants hold: single-use chain intermediates stay
  transient owned vectors (interning them all costs O(K²) memory per
  accumulator), and polynomials sort by descending `TermId` so unwinding a
  chain appends in O(1).

`EquivSession` reuses intern tables across elements and recycles them past a
term bound (`with_recycle_terms`, default 4M), trading re-canonicalization
time for bounded memory. One warm FlashAttention row can retain several GiB.

## Output checking (`check.rs`)

- `paired_elements(ref, opt, arrays)`: pairs written elements per named
  array. Both sides must write identical index sets. Arrays not named are not
  compared, and the caller must name at least one.
- `check_output_equivalence_with(ref, opt, arrays, EquivCheckOptions)`: the
  per-element check. Options: `sample`, `verify_numeric`, `recycle_terms`, and
  `iterations` (re-solve N times with fresh sessions, for cold-start timings and
  a determinism check). The report has the outcome, checked/total counts and
  per-iteration and per-element timings.

## Numeric oracle (`numeric.rs`)

Evaluates both DAGs in f64 at seeded random inputs. It confirms an EQUIV or DIFF
claim (`--verify-numeric`). The pipeline treats a claimed difference as a
refutation only when the oracle separates the two sides. Agreement at random
points means equality almost surely for this fragment (Schwartz-Zippel).

## VC dumps (`vc_dump.rs`)

`VcDump { reference, optimized }` is a serialized pair of `SymbolicOutputs`, so
symbolic execution can be skipped on later runs (`volta compare --dump-vcs` /
`--from-dump`). The format is the `VOLTAVCD` magic, a u16 major/minor version,
and a bincode payload with decode allocations capped. `validate()` runs on load,
so a corrupt dump errors instead of panicking.

## Tests

Spec-to-spec only: `tests/spec_equivalence_tests.rs` over `tests/specs/*.spec`,
and `tests/spec_identity_tests.rs`, one test per
`tests/specs/equivalent/<case>_{lhs,rhs}.spec` identity. PTX-driven tests live
in `volta_pipeline/tests/`.
