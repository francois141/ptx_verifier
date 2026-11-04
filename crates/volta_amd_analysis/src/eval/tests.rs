use volta_expr::ExprArena;

use crate::ir::{CndMaskSrc, LaneMask, Sgpr, Vgpr, Vop3Src};

use super::EvalError;
use super::arithm::evaluate_cndmask_e64;
use super::wave::{LoadCounter, WaveRegisters};

#[test]
fn conditional_negation_preserves_raw_sign_bits_in_both_source_positions() {
    let mut arena = ExprArena::default();
    let mut registers = WaveRegisters::default();
    for bits in [
        0,
        1,
        0x8000_0000,
        0x3f80_0000,
        0x7f80_0000,
        0x7fc1_2345,
        u32::MAX,
    ] {
        let original = arena.int(i64::from(bits));
        registers.write_vgpr(0, Vgpr(1), original).unwrap();
        for selected in [false, true] {
            let mask = arena.bool_val(selected);
            registers.write_vcc(0, mask).unwrap();
            let negated = CndMaskSrc {
                value: Vop3Src::Vgpr(Vgpr(1)),
                negate: true,
            };
            let plain = CndMaskSrc {
                negate: false,
                ..negated
            };
            let (a, b) = if selected {
                (plain, negated)
            } else {
                (negated, plain)
            };
            let result =
                evaluate_cndmask_e64(&mut arena, &registers, 0, a, b, LaneMask::Vcc).unwrap();
            assert_eq!(
                arena.as_int_const(result),
                Some(i64::from(bits ^ 0x8000_0000))
            );
            assert_eq!(registers.read_vgpr(0, Vgpr(1)).unwrap(), original);
        }
    }
}

#[test]
fn negation_survives_mixed_word_and_symbolic_float_selection() {
    let mut arena = ExprArena::default();
    let mut registers = WaveRegisters::default();
    let input = arena.param_symbol("x");
    let zero = arena.int(0);
    let condition = arena.lt(input, zero);
    registers.write_vcc(0, condition).unwrap();
    registers.write_vgpr(0, Vgpr(1), input).unwrap();
    let bits = arena.int(i64::from(2.0f32.to_bits()));
    registers.write_sgpr(Sgpr(8), bits).unwrap();
    let result = evaluate_cndmask_e64(
        &mut arena,
        &registers,
        0,
        CndMaskSrc {
            value: Vop3Src::Sgpr(Sgpr(8)),
            negate: true,
        },
        CndMaskSrc {
            value: Vop3Src::Vgpr(Vgpr(1)),
            negate: true,
        },
        LaneMask::Vcc,
    )
    .unwrap();
    let minus_two = arena.float_from_f64(-2.0).unwrap();
    let minus_input = arena.neg(input);
    let expected = arena.select(condition, minus_input, minus_two);
    assert_eq!(arena.display_expr(result), arena.display_expr(expected));
    let wide = arena.int(1_i64 << 40);
    registers.write_vgpr(0, Vgpr(1), wide).unwrap();
    assert_eq!(
        evaluate_cndmask_e64(
            &mut arena,
            &registers,
            0,
            CndMaskSrc {
                value: Vop3Src::Vgpr(Vgpr(1)),
                negate: true
            },
            CndMaskSrc {
                value: Vop3Src::Inline(0),
                negate: false
            },
            LaneMask::Vcc,
        ),
        Err(EvalError::SymbolicWord { lane: 0 })
    );
}

#[test]
fn concrete_comparison_masks_preserve_all_64_bits_and_raw_reads() {
    let mut arena = ExprArena::default();
    let mut registers = WaveRegisters::default();
    let expected = 0x8000_0001_8000_0001u64;
    let bits = std::array::from_fn(|lane| arena.bool_val(expected & (1 << lane) != 0));
    registers
        .write_lane_mask(&mut arena, [Sgpr(8), Sgpr(9)], bits)
        .unwrap();
    assert_eq!(
        registers
            .read_sgpr_pair(&arena, [Sgpr(8), Sgpr(9)])
            .unwrap(),
        expected
    );
    for lane in 0..64 {
        let value = registers
            .read_lane_condition(&mut arena, lane, LaneMask::Sgprs([Sgpr(8), Sgpr(9)]))
            .unwrap();
        assert_eq!(arena.as_bool(value), Some(expected & (1 << lane) != 0));
    }
}

#[test]
fn symbolic_mask_halves_are_replaced_by_scalar_writes_and_loads() {
    let mut arena = ExprArena::default();
    let mut registers = WaveRegisters::default();
    let input = arena.param_symbol("x");
    let bits = std::array::from_fn(|lane| {
        let bound = arena.int(lane as i64);
        arena.lt(input, bound)
    });
    let pair = [Sgpr(8), Sgpr(9)];
    registers.write_lane_mask(&mut arena, pair, bits).unwrap();
    for (lane, bit) in bits.iter().enumerate() {
        assert_eq!(
            registers
                .read_lane_condition(&mut arena, lane, LaneMask::Sgprs(pair))
                .unwrap(),
            *bit
        );
    }
    assert_eq!(
        registers.read_sgpr(Sgpr(8)),
        Err(EvalError::SymbolicSgpr(Sgpr(8)))
    );
    assert_eq!(
        registers.read_sgpr_pair(&arena, pair),
        Err(EvalError::SymbolicSgpr(Sgpr(8)))
    );
    let zero = arena.int(0);
    registers.write_sgpr(Sgpr(8), zero).unwrap();
    let low = registers
        .read_lane_condition(&mut arena, 31, LaneMask::Sgprs(pair))
        .unwrap();
    assert_eq!(arena.as_bool(low), Some(false));
    assert_eq!(
        registers
            .read_lane_condition(&mut arena, 32, LaneMask::Sgprs(pair))
            .unwrap(),
        bits[32]
    );
    registers.start_scalar_load([Sgpr(9)], [zero]).unwrap();
    assert_eq!(
        registers.read_lane_condition(&mut arena, 0, LaneMask::Sgprs(pair)),
        Err(EvalError::PendingSgpr(Sgpr(9)))
    );
    assert_eq!(
        registers.write_lane_mask(&mut arena, pair, bits),
        Err(EvalError::PendingSgpr(Sgpr(9)))
    );
    assert_eq!(registers.read_sgpr_word(&arena, Sgpr(8)).unwrap(), 0);
    registers.finish_scalar_loads();
    assert_eq!(registers.read_sgpr_pair(&arena, pair).unwrap(), 0);
    registers.write_lane_mask(&mut arena, pair, bits).unwrap();
    registers.start_scalar_load([Sgpr(8)], [zero]).unwrap();
    assert_eq!(
        registers.read_lane_condition(&mut arena, 63, LaneMask::Sgprs(pair)),
        Err(EvalError::PendingSgpr(Sgpr(8)))
    );
}

#[test]
fn packed_destination_validation_is_atomic_when_the_high_half_is_pending() {
    let mut arena = ExprArena::default();
    let mut registers = WaveRegisters::default();
    let original = arena.int(7);
    let replacement = arena.int(9);
    registers.write_vgpr(0, Vgpr(2), original).unwrap();
    registers
        .start_vector_load(0, &[Vgpr(3)], &[original], LoadCounter::Vm)
        .unwrap();
    assert_eq!(
        registers.write_vgpr_pair(0, [Vgpr(2), Vgpr(3)], [replacement; 2]),
        Err(EvalError::PendingVgpr {
            lane: 0,
            reg: Vgpr(3)
        })
    );
    assert_eq!(registers.read_vgpr(0, Vgpr(2)).unwrap(), original);
}
