use volta_expr::FullOutputs;
use volta_expr::symbolic_full::{ExprArena, ExprNode, Type, Width};

/// A full arena keeps `(1 < 2) ? a[0] * 1.0 : a[1]` as built while its values follow the
/// simplified folds (the condition is `true`, the select is `a[0]`), and lowering applies them.
#[test]
fn full_operations_stay_as_built_and_lower_to_their_folds() {
    let mut arena = ExprArena::new();
    let a = arena.intern_string("a");
    let x = arena.input_element(a, 0);
    let y = arena.input_element(a, 1);
    let one = arena.int(1);
    let two = arena.int(2);
    let condition = arena.lt(Type::Pred, one, two);
    let unit = arena.float_from_f64(1.0).unwrap();
    let scaled = arena.mul(Type::Real, x, unit);
    let chosen = arena.select(Type::Real, condition, scaled, y);

    assert!(matches!(arena.node(chosen), ExprNode::Select(..)));
    assert_eq!(arena.as_bool(condition), Some(true));
    assert_eq!(arena.value(chosen), x);
    assert_eq!(arena.display_expr(chosen), "((1 < 2) ? (a[0] * 1) : a[1])");

    let lowered = FullOutputs {
        arena,
        outputs: vec![("o".to_string(), vec![(0, chosen)])],
    }
    .lower()
    .unwrap();
    let root = lowered.element("o", 0).unwrap();
    assert_eq!(lowered.arena.display_expr(root), "a[0]");
    assert_eq!(lowered.arena.node_count(), 1);
}

/// Flipping or clearing a float's sign bit lowers to `-x` or `|x|`; the same masks on untyped
/// bits stay bitwise.
#[test]
fn sign_masks_of_floats_lower_to_negation_and_absolute_value() {
    let mut arena = ExprArena::new();
    let a = arena.intern_string("a");
    let x = arena.input_element(a, 0);
    let flip = arena.int(0x8000_0000);
    let clear = arena.int(0x7fff_ffff);
    let float = Type::Float(Width(32));
    let bits = Type::Bits(Width(32));
    let roots = [
        arena.bit_xor(float, x, flip),
        arena.bit_and(float, clear, x),
        arena.bit_xor(bits, x, flip),
    ];

    let lowered = FullOutputs {
        arena,
        outputs: vec![("o".to_string(), (0..).zip(roots).collect())],
    }
    .lower()
    .unwrap();
    let text = |index| {
        lowered
            .arena
            .display_expr(lowered.element("o", index).unwrap())
    };
    assert_eq!(text(0), "(-a[0])");
    assert_eq!(text(1), "abs(a[0])");
    assert_eq!(text(2), "(a[0] ^ 2147483648)");
}
