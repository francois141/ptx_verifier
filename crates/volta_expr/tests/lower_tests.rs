use volta_expr::FullOutputs;
use volta_expr::symbolic_full::{ExprArena, ExprNode, PrmtSelector, Type, Width};

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

/// A byte permute lowers to its four result bytes, each taken out of its source word and moved
/// into place: `0x3120` swaps bytes 1 and 2.
#[test]
fn a_prmt_lowers_to_its_bytes_moved_into_place() {
    let mut arena = ExprArena::new();
    let a = arena.intern_string("a");
    let word = arena.input_element(a, 0);
    let zero = arena.int(0);
    let permuted = arena.prmt(word, zero, PrmtSelector(0x3120));

    let lowered = FullOutputs {
        arena,
        outputs: vec![("o".to_string(), vec![(0, permuted)])],
    }
    .lower()
    .unwrap();
    let root = lowered.element("o", 0).unwrap();
    assert_eq!(
        lowered.arena.display_expr(root),
        "((((0 | (a[0] & 255)) | (((a[0] >>> 16) & 255) << 8)) | (((a[0] >>> 8) & 255) << 16)) \
         | (((a[0] >>> 24) & 255) << 24))"
    );
}

/// Triton fuses the factor two into the mask. Include bit zero (a left shift),
/// bit 31 (a logical right shift), both mask orders, and complemented signs.
#[test]
fn triton_scaled_sign_bits_lower_to_the_original_bit() {
    for index in 0..32 {
        for complemented in [false, true] {
            for swapped in [false, true] {
                let mut arena = ExprArena::new();
                let bits = Type::Bits(Width(32));
                let a = arena.intern_string("a");
                let word = arena.input_element(a, 0);
                let one = arena.int(1);
                let two = arena.int(2);
                let moved = if index == 0 {
                    arena.shl(bits, word, one)
                } else {
                    let shift = arena.int(index - 1);
                    arena.lshr(bits, word, shift)
                };
                let moved = if complemented {
                    arena.bit_xor(bits, moved, two)
                } else {
                    moved
                };
                let masked = if swapped {
                    arena.bit_and(bits, two, moved)
                } else {
                    arena.bit_and(bits, moved, two)
                };
                let lowered = FullOutputs {
                    arena,
                    outputs: vec![("o".into(), vec![(0, masked)])],
                }
                .lower()
                .unwrap();
                let actual = lowered.arena.display_expr(lowered.element("o", 0).unwrap());
                let mut expected = volta_expr::symbolic_simplified::ExprArena::new();
                let a = expected.intern_string("a");
                let word = expected.input_element(a, 0);
                let shift = expected.int(index);
                let moved = expected.lshr(word, shift);
                let one = expected.int(1);
                let bit = expected.bit_and(moved, one);
                let bit = if complemented {
                    expected.sub(one, bit)
                } else {
                    bit
                };
                let two = expected.int(2);
                let result = expected.mul(two, bit);
                assert_eq!(actual, expected.display_expr(result), "bit {index}");
            }
        }
    }
}

#[test]
fn sign_bit_and_multibit_masks_stay_opaque() {
    for mask in [3, 6, 0x8000_0000] {
        let mut arena = ExprArena::new();
        let bits = Type::Bits(Width(32));
        let a = arena.intern_string("a");
        let word = arena.input_element(a, 0);
        let mask_id = arena.int(mask);
        let masked = arena.bit_and(bits, word, mask_id);
        let lowered = FullOutputs {
            arena,
            outputs: vec![("o".into(), vec![(0, masked)])],
        }
        .lower()
        .unwrap();
        assert_eq!(
            lowered.arena.display_expr(lowered.element("o", 0).unwrap()),
            format!("(a[0] & {mask})")
        );
    }
}
