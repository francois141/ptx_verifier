use volta_expr::symbolic::*;

#[test]
fn test_constant_folding() {
    let mut arena = ExprArena::new();

    // Integer arithmetic
    let a = arena.int(3);
    let b = arena.int(4);
    let e = arena.add(a, b);
    assert_eq!(arena.as_i64(e), Some(7));

    let a = arena.int(10);
    let b = arena.int(3);
    let e = arena.sub(a, b);
    assert_eq!(arena.as_i64(e), Some(7));

    let a = arena.int(3);
    let b = arena.int(4);
    let e = arena.mul(a, b);
    assert_eq!(arena.as_i64(e), Some(12));

    // Shifts
    let a = arena.int(1);
    let b = arena.int(4);
    let e = arena.shl(a, b);
    assert_eq!(arena.as_i64(e), Some(16));

    // Bitwise
    let a = arena.int(0xFF);
    let b = arena.int(0x0F);
    let e = arena.bit_and(a, b);
    assert_eq!(arena.as_i64(e), Some(0x0F));
}

#[test]
fn test_identity_simplification() {
    let mut arena = ExprArena::new();

    // x + 0 = x
    let x = arena.symbol();
    let zero = arena.int(0);
    let e = arena.add(x, zero);
    assert_eq!(e, x);

    // 0 + x = x
    let x = arena.symbol();
    let zero = arena.int(0);
    let e = arena.add(zero, x);
    assert_eq!(e, x);

    // x * 1 = x
    let x = arena.symbol();
    let one = arena.int(1);
    let e = arena.mul(x, one);
    assert_eq!(e, x);

    // 1 * x = x
    let x = arena.symbol();
    let one = arena.int(1);
    let e = arena.mul(one, x);
    assert_eq!(e, x);

    // x - 0 = x
    let x = arena.symbol();
    let zero = arena.int(0);
    let e = arena.sub(x, zero);
    assert_eq!(e, x);

    // x / 1 = x
    let x = arena.symbol();
    let one = arena.int(1);
    let e = arena.div(x, one);
    assert_eq!(e, x);
}

#[test]
fn test_logical_shift_right() {
    let mut arena = ExprArena::new();

    // 128 >>> 1 = 64
    let a = arena.int(128);
    let b = arena.int(1);
    let e = arena.lshr(a, b);
    assert_eq!(arena.as_i64(e), Some(64));

    // -1 >>> 1 should be a large positive number (logical shift)
    let a = arena.int(-1);
    let b = arena.int(1);
    let e = arena.lshr(a, b);
    assert_eq!(arena.as_i64(e), Some(i64::MAX));

    // Nested: (128 >>> 1) << 2 = 256
    let a = arena.int(128);
    let b = arena.int(1);
    let c = arena.int(2);
    let step1 = arena.lshr(a, b);
    let e = arena.shl(step1, c);
    assert_eq!(arena.as_i64(e), Some(256));
}

#[test]
fn test_div() {
    let mut arena = ExprArena::new();

    // 10 / 3 = 3 (eager folding in constructor)
    let a = arena.int(10);
    let b = arena.int(3);
    let e = arena.div(a, b);
    assert_eq!(arena.as_i64(e), Some(3));

    // 10.0 / 2.0 = 5.0
    let a = arena.float_from_f64(10.0).unwrap();
    let b = arena.float_from_f64(2.0).unwrap();
    let e = arena.div(a, b);
    assert_eq!(arena.as_f64(e), Some(5.0));
}

#[test]
fn test_node_lookup() {
    let mut arena = ExprArena::new();

    let a = arena.int(42);
    assert_eq!(arena.node(a), &ExprNode::IntConst(42));

    let b = arena.float_from_f64(2.5).unwrap();
    assert_eq!(
        arena.node(b),
        &ExprNode::RealConst(Real::from_f64(2.5).unwrap())
    );

    let c = arena.bool_val(true);
    assert_eq!(arena.node(c), &ExprNode::BoolConst(true));

    let d = arena.param_symbol("alpha");
    if let ExprNode::ParamSymbol(sid) = arena.node(d) {
        assert_eq!(arena.string(*sid), "alpha");
    } else {
        panic!("expected ParamSymbol");
    }

    let sid = arena.intern_string("input");
    let e = arena.input_element(sid, 0);
    assert!(matches!(
        arena.node(e),
        ExprNode::InputElement { array, index: 0 } if arena.string(*array) == "input"
    ));

    let u = arena.undefined();
    assert_eq!(arena.node(u), &ExprNode::Undefined);
}

#[test]
fn test_query_methods() {
    let mut arena = ExprArena::new();

    let i = arena.int(10);
    assert_eq!(arena.as_i64(i), Some(10));
    assert_eq!(arena.as_u64(i), Some(10));
    assert_eq!(arena.as_f64(i), Some(10.0));
    assert_eq!(arena.as_bool(i), Some(true));
    assert!(arena.is_concrete(i));
    assert!(!arena.is_undefined(i));

    let f = arena.float_from_f64(2.5).unwrap();
    assert_eq!(arena.as_f64(f), Some(2.5));
    assert!(arena.is_concrete(f));

    let b = arena.bool_val(false);
    assert_eq!(arena.as_bool(b), Some(false));
    assert!(arena.is_concrete(b));

    let s = arena.symbol();
    assert!(!arena.is_concrete(s));
    assert!(arena.as_i64(s).is_none());

    let u = arena.undefined();
    assert!(arena.is_undefined(u));
    assert!(!arena.is_concrete(u));
}

#[test]
fn test_select_folding() {
    let mut arena = ExprArena::new();

    let t = arena.bool_val(true);
    let a = arena.int(1);
    let b = arena.int(2);
    let e = arena.select(t, a, b);
    assert_eq!(e, a);

    let f = arena.bool_val(false);
    let c = arena.int(3);
    let d = arena.int(4);
    let e = arena.select(f, c, d);
    assert_eq!(e, d);
}

#[test]
fn test_select_folds_sign_idiom() {
    let mut arena = ExprArena::new();

    // (v != 0) ? ((v > 0) ? c : -c) : 0, the setp+selp+selp pattern
    // nvcc/Triton emit for a signed step - should fold to sign(v) * c.
    let v = arena.symbol();
    let zero = arena.int(0);
    let c = arena.float_from_f64(-0.0001).unwrap();
    let neg_c = arena.float_from_f64(0.0001).unwrap();

    let is_positive = arena.gt(v, zero);
    let inner = arena.select(is_positive, c, neg_c);
    let is_nonzero = arena.ne(v, zero);
    let folded = arena.select(is_nonzero, inner, zero);

    let &ExprNode::Mul(sign_id, c_id) = arena.node(folded) else {
        panic!("expected sign(v) * c, got {:?}", arena.node(folded));
    };
    assert!(matches!(arena.node(sign_id), ExprNode::Sign(inner) if *inner == v));
    let (ExprNode::RealConst(folded_c), ExprNode::RealConst(orig_c)) =
        (arena.node(c_id), arena.node(c))
    else {
        panic!("expected the folded multiplier to stay a real constant");
    };
    assert_eq!(folded_c, orig_c);

    // A mismatched second branch (not the negation of the first) must
    // not fold - it isn't the sign idiom.
    let mut arena = ExprArena::new();
    let v = arena.symbol();
    let zero = arena.int(0);
    let c = arena.float_from_f64(-0.0001).unwrap();
    let other = arena.float_from_f64(0.5).unwrap();
    let is_positive = arena.gt(v, zero);
    let inner = arena.select(is_positive, c, other);
    let is_nonzero = arena.ne(v, zero);
    let not_folded = arena.select(is_nonzero, inner, zero);
    assert!(matches!(arena.node(not_folded), ExprNode::Select(..)));
}

#[test]
fn test_display() {
    let mut arena = ExprArena::new();

    let a = arena.int(3);
    let b = arena.int(4);
    let e = arena.add(a, b);
    // Constant folding means this is just "7"
    assert_eq!(arena.display_expr(e), "7");

    // Build a symbolic expression: (x + 1)
    let x = arena.symbol();
    let one = arena.int(1);
    let e = arena.add(x, one);
    let s = arena.display_expr(e);
    // Should contain " + 1" and parentheses
    assert!(s.contains(" + "));
    assert!(s.contains("1"));
}

// ---------------------------------------------------------------
// Exact real folding
// ---------------------------------------------------------------

fn real_of(arena: &mut ExprArena, v: f64) -> ExprId {
    arena.float_from_f64(v).unwrap()
}

fn real_const(arena: &ExprArena, e: ExprId) -> &Real {
    match arena.node(e) {
        ExprNode::RealConst(r) => r,
        other => panic!("expected RealConst, got {:?}", other),
    }
}

/// Division and reciprocal fold to the same exact rational: the fold algebra and canon's
/// field algebra coincide by construction (else one value under two constants flips verdicts).
#[test]
fn div_and_rcp_fold_to_the_same_exact_rational() {
    let mut ar = ExprArena::new();
    let one = real_of(&mut ar, 1.0);
    let three = real_of(&mut ar, 3.0);
    let d = ar.div(one, three);
    let three2 = real_of(&mut ar, 3.0);
    let r = ar.rcp(three2);
    let third = Real::from_rational(rug::Rational::from((1, 3)));
    assert_eq!(real_const(&ar, d), &third);
    assert_eq!(real_const(&ar, r), &third);
    // And distinct from the f64 approximation of 1/3.
    assert_ne!(real_const(&ar, d), &Real::from_f64(1.0 / 3.0).unwrap());
}

/// fma folds exactly as mul-then-add (one algebra, no fused rounding).
#[test]
fn fma_folds_exactly_as_mul_plus_add() {
    let mut ar = ExprArena::new();
    let (a, b, c) = (
        real_of(&mut ar, 0.1),
        real_of(&mut ar, 0.2),
        real_of(&mut ar, 0.3),
    );
    let fused = ar.fma(a, b, c);
    let prod = ar.mul(a, b);
    let spelled = ar.add(prod, c);
    assert_eq!(real_const(&ar, fused), real_const(&ar, spelled));
    // The old f64 folds disagreed: mul_add rounds once, mul+add twice.
    assert_ne!(
        real_const(&ar, fused),
        &Real::from_f64(0.1f64.mul_add(0.2, 0.3)).unwrap()
    );
}

/// The exact sum of two f64 constants is not the f64 the hardware
/// would produce: `0.1 + 0.2` folds to the exact rational sum, which
/// differs from the literal 0.30000000000000004 (0d3FD3333333333334).
#[test]
fn addition_is_exact_not_rounded() {
    let mut ar = ExprArena::new();
    let a = real_of(&mut ar, 0.1);
    let b = real_of(&mut ar, 0.2);
    let sum = ar.add(a, b);
    assert_ne!(
        real_const(&ar, sum),
        &Real::from_f64(0.1 + 0.2).unwrap(),
        "the exact sum must not equal the rounded f64 sum"
    );
    let exact = Real::from_f64(0.1)
        .unwrap()
        .try_add(&Real::from_f64(0.2).unwrap())
        .unwrap();
    assert_eq!(real_const(&ar, sum), &exact);
}

/// x / 0 (including 0 / 0) builds the node unfolded instead of minting
/// a NaN or folding to 0; canon then errors loudly on the formally
/// zero denominator.
#[test]
fn division_by_concrete_zero_stays_symbolic() {
    let mut ar = ExprArena::new();
    let z1 = real_of(&mut ar, 0.0);
    let z2 = real_of(&mut ar, 0.0);
    let e = ar.div(z1, z2);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

    let one = real_of(&mut ar, 1.0);
    let z3 = real_of(&mut ar, 0.0);
    let e = ar.div(one, z3);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

    let iz1 = ar.int(0);
    let iz2 = ar.int(0);
    let e = ar.div(iz1, iz2);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

    // rcp(0) stays symbolic as well.
    let z4 = real_of(&mut ar, 0.0);
    let e = ar.rcp(z4);
    assert!(matches!(ar.node(e), ExprNode::Rcp(_)));
}

/// A zero *numerator* over a non-concrete divisor also stays unfolded, for either zero: folding
/// `0 / x` to 0 would hide a formally-zero `x` from canon's loud division error.
#[test]
fn zero_numerator_over_symbolic_divisor_stays_symbolic() {
    let mut ar = ExprArena::new();

    let iz = ar.int(0);
    let s = ar.symbol();
    let e = ar.div(iz, s);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

    let rz = real_of(&mut ar, 0.0);
    let e = ar.div(rz, s);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

    // Fully concrete quotients still fold.
    let iz = ar.int(0);
    let three = ar.int(3);
    let e = ar.div(iz, three);
    assert_eq!(ar.as_i64(e), Some(0));
    let rz = real_of(&mut ar, 0.0);
    let rthree = real_of(&mut ar, 3.0);
    let e = ar.div(rz, rthree);
    assert!(real_const(&ar, e).is_zero());
}

/// `abs` folds integer and real constants exactly (an integer wraps
/// at i64::MIN; the interpreter re-reads it at the instruction's
/// width) and builds a node over a symbolic argument.
#[test]
fn abs_folds_constants() {
    let mut ar = ExprArena::new();
    let i = ar.int(-7);
    let e = ar.abs(i);
    assert_eq!(ar.as_i64(e), Some(7));
    let i = ar.int(i64::MIN);
    let e = ar.abs(i);
    assert_eq!(ar.as_i64(e), Some(i64::MIN));
    let r = real_of(&mut ar, -2.5);
    let e = ar.abs(r);
    assert_eq!(real_const(&ar, e).to_f64(), 2.5);
    let x = ar.symbol();
    let e = ar.abs(x);
    assert!(matches!(ar.node(e), ExprNode::Abs(a) if *a == x));
}

/// The extended-real fold table: the unambiguous forms fold, the
/// undefined forms (inf - inf, 0 * inf, inf / inf, x / 0) build nodes.
#[test]
fn extended_real_folds() {
    let mut ar = ExprArena::new();
    let pinf = real_of(&mut ar, f64::INFINITY);
    let ninf = real_of(&mut ar, f64::NEG_INFINITY);
    let two = real_of(&mut ar, 2.0);
    let neg3 = real_of(&mut ar, -3.0);
    let zero = real_of(&mut ar, 0.0);

    // inf +/- finite, neg, abs.
    let e = ar.add(pinf, two);
    assert!(real_const(&ar, e).is_pos_inf());
    let e = ar.sub(ninf, two);
    assert!(real_const(&ar, e).is_neg_inf());
    let e = ar.neg(pinf);
    assert!(real_const(&ar, e).is_neg_inf());
    let e = ar.abs(ninf);
    assert!(real_const(&ar, e).is_pos_inf());

    // inf * nonzero follows the sign rules.
    let e = ar.mul(pinf, neg3);
    assert!(real_const(&ar, e).is_neg_inf());
    let e = ar.mul(ninf, neg3);
    assert!(real_const(&ar, e).is_pos_inf());

    // Undefined forms stay unfolded.
    let e = ar.add(pinf, ninf);
    assert!(matches!(ar.node(e), ExprNode::Add(_, _)));
    let e = ar.sub(pinf, pinf);
    assert!(matches!(ar.node(e), ExprNode::Sub(_, _)));
    let e = ar.mul(zero, pinf);
    assert!(matches!(ar.node(e), ExprNode::Mul(_, _)));
    let e = ar.fma(zero, pinf, two);
    assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
    let e = ar.div(pinf, pinf);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));
    let e = ar.div(two, pinf);
    assert!(matches!(ar.node(e), ExprNode::Div(_, _)));
    let e = ar.rcp(pinf);
    assert!(matches!(ar.node(e), ExprNode::Rcp(_)));

    // Comparisons use the extended-real total order.
    let e = ar.lt(ninf, two);
    assert_eq!(ar.as_bool(e), Some(true));
    let e = ar.ge(pinf, two);
    assert_eq!(ar.as_bool(e), Some(true));
    let e = ar.le(ninf, ninf);
    assert_eq!(ar.as_bool(e), Some(true));
    let e = ar.lt(ninf, ninf);
    assert_eq!(ar.as_bool(e), Some(false));
}

/// The *integer* zero annihilates `0 * x` like the real zero except against a concrete infinity
/// (0 * inf stays unfolded), in both operand orders and through fma's zero shortcut, including
/// the mixed form with a non-real-constant addend that skips `try_fma`.
#[test]
fn integer_zero_times_infinity_stays_unfolded() {
    let mut ar = ExprArena::new();
    let iz = ar.int(0);
    let pinf = real_of(&mut ar, f64::INFINITY);
    let ninf = real_of(&mut ar, f64::NEG_INFINITY);
    let x = ar.symbol();

    for (a, b) in [(iz, pinf), (pinf, iz), (iz, ninf), (ninf, iz)] {
        let e = ar.mul(a, b);
        assert!(matches!(ar.node(e), ExprNode::Mul(_, _)));
    }

    // The annihilation itself is intact for everything else.
    let e = ar.mul(iz, x);
    assert_eq!(ar.as_i64(e), Some(0));
    let two = real_of(&mut ar, 2.0);
    let e = ar.mul(iz, two);
    assert_eq!(ar.as_i64(e), Some(0));

    // fma: an integer-zero multiplicand against an infinity stays
    // unfolded rather than collapsing to the addend...
    let c = real_of(&mut ar, 5.0);
    let e = ar.fma(iz, pinf, c);
    assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
    let e = ar.fma(ninf, iz, c);
    assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
    // ...as does a real-zero * inf whose addend is an integer.
    let rz = real_of(&mut ar, 0.0);
    let ic = ar.int(5);
    let e = ar.fma(rz, pinf, ic);
    assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
    // The zero shortcut itself is intact.
    let e = ar.fma(iz, x, c);
    assert_eq!(e, c);
}

/// The layout the arena's economics rest on, statically: `Real` is pointer-sized (a boxed repr
/// with a `NonNull` niche) and `ExprNode` stays 16 bytes on GiB-scale arenas.
#[test]
fn real_and_expr_node_stay_small() {
    assert_eq!(std::mem::size_of::<Real>(), 8);
    assert_eq!(std::mem::size_of::<ExprNode>(), 16);
}

/// Max/min: concrete pairs fold totally; the running-max/min seeds
/// (-inf for max, +inf for min) still absorb against symbolic values.
#[test]
fn max_min_absorption_and_exact_folds() {
    let mut ar = ExprArena::new();
    let ninf = real_of(&mut ar, f64::NEG_INFINITY);
    let pinf = real_of(&mut ar, f64::INFINITY);
    let two = real_of(&mut ar, 2.0);
    let x = ar.symbol();

    let e = ar.max(ninf, x);
    assert_eq!(e, x);
    let e = ar.max(x, ninf);
    assert_eq!(e, x);
    let e = ar.min(pinf, x);
    assert_eq!(e, x);
    let e = ar.min(x, pinf);
    assert_eq!(e, x);

    let e = ar.max(ninf, two);
    assert_eq!(real_const(&ar, e), &Real::from_f64(2.0).unwrap());
    let e = ar.max(pinf, two);
    assert!(real_const(&ar, e).is_pos_inf());
    let e = ar.min(ninf, two);
    assert!(real_const(&ar, e).is_neg_inf());

    let e = ar.max(x, x);
    assert_eq!(e, x);
}

/// Concrete real eq/ne now fold (exact comparisons; previously only
/// integers folded and a concrete float `setp.eq` guard failed as
/// not-concrete).
#[test]
fn real_eq_ne_fold() {
    let mut ar = ExprArena::new();
    let a = real_of(&mut ar, 1.5);
    let b = real_of(&mut ar, 1.5);
    let c = real_of(&mut ar, 2.5);
    let e = ar.eq(a, b);
    assert_eq!(ar.as_bool(e), Some(true));
    let e = ar.eq(a, c);
    assert_eq!(ar.as_bool(e), Some(false));
    let e = ar.ne(a, c);
    assert_eq!(ar.as_bool(e), Some(true));
}

/// NaN is rejected at every ingestion point.
#[test]
fn nan_is_rejected() {
    assert_eq!(Real::from_f64(f64::NAN), Err(NanError));
    let mut ar = ExprArena::new();
    assert!(ar.float_from_f64(f64::NAN).is_err());
    assert!(
        ar.float_from_f64(f64::from_bits(0x7FF8_0000_0000_0000))
            .is_err()
    );
}

/// to_float folds exactly: a large i64 becomes the rational it
/// denotes, not the nearest f64 (canon treats ToFloat as identity, so
/// the eager fold must be exact too).
#[test]
fn to_float_is_exact() {
    let mut ar = ExprArena::new();
    let big = ar.int(i64::MAX);
    let f = ar.to_float(big);
    let exact = Real::from_i64(i64::MAX);
    assert_eq!(real_const(&ar, f), &exact);
    assert_ne!(exact, Real::from_f64(i64::MAX as f64).unwrap());
}

/// Display: integers print bare, f64-representable dyadics print in
/// f64's shortest form, exact non-representable rationals print p/q.
#[test]
fn real_display() {
    let mut ar = ExprArena::new();
    let e = real_of(&mut ar, 42.0);
    assert_eq!(ar.display_expr(e), "42");
    let e = real_of(&mut ar, 0.0);
    assert_eq!(ar.display_expr(e), "0");
    let e = real_of(&mut ar, -0.0);
    assert_eq!(ar.display_expr(e), "0");
    let e = real_of(&mut ar, 0.1);
    assert_eq!(ar.display_expr(e), "0.1");
    let e = real_of(&mut ar, -2.5);
    assert_eq!(ar.display_expr(e), "-2.5");
    let e = real_of(&mut ar, f64::INFINITY);
    assert_eq!(ar.display_expr(e), "inf");
    let e = real_of(&mut ar, f64::NEG_INFINITY);
    assert_eq!(ar.display_expr(e), "-inf");
    let one = real_of(&mut ar, 1.0);
    let three = real_of(&mut ar, 3.0);
    let e = ar.div(one, three);
    assert_eq!(ar.display_expr(e), "1/3");
}

/// `validate` accepts every arena the constructors can build...
#[test]
fn validate_accepts_constructed_arenas() {
    let mut ar = ExprArena::new();
    let x = ar.param_symbol("x");
    let y = ar.symbol();
    let s = ar.add(x, y);
    let m = ar.max(s, x);
    let _ = ar.select(m, s, x);
    assert_eq!(ar.validate(), Ok(()));
}

/// ...and rejects forward/self references (e.g. `Add(0, 0)` at node 0, which would recurse
/// without bound) and out-of-range string ids, which only a corrupt or crafted dump contains.
#[test]
fn validate_rejects_malformed_arenas() {
    let arena = |json: &str| serde_json::from_str::<ExprArena>(json).unwrap();
    let cyclic = arena(r#"{"nodes": [{"Add": [0, 0]}], "strings": []}"#);
    assert!(cyclic.validate().is_err());

    let forward = arena(r#"{"nodes": [{"Neg": 1}, {"IntConst": 1}], "strings": []}"#);
    assert!(forward.validate().is_err());

    let oob_string = arena(r#"{"nodes": [{"ParamSymbol": 3}], "strings": ["x"]}"#);
    assert!(oob_string.validate().is_err());
}

/// 60 levels of self-adds would print ~2^60 leaves; the prefix stops after the bytes it keeps.
#[test]
fn display_expr_prefix_cuts_exponentially_shared_expressions_cheaply() {
    let mut arena = ExprArena::new();
    let mut e = arena.symbol();
    for _ in 0..60 {
        e = arena.add(e, e);
    }
    let text = arena.display_expr_prefix(e, 32);
    assert!(text.ends_with('…'), "{text}");
    assert!(text.len() <= 32 + '…'.len_utf8(), "{text}");
    let small = arena.int(3);
    assert_eq!(
        arena.display_expr_prefix(small, 32),
        arena.display_expr(small)
    );
}

/// `display_expr` re-walks shared subexpressions, so 30 levels of self-adds print ~2^30 leaves
/// from a ~30-node arena, far past the 50MB cap; it must end quickly with the placeholder.
#[test]
fn display_expr_caps_exponentially_shared_expressions() {
    let mut arena = ExprArena::new();
    let mut e = arena.symbol();
    for _ in 0..30 {
        e = arena.add(e, e);
    }
    let text = arena.display_expr(e);
    assert!(text.len() < 51 * 1024 * 1024);
    assert!(text.contains("exceeds"), "unexpected output: {text}");
}
