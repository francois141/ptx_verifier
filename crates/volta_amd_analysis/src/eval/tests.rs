//! Tests for register reads and writes and for executing AMD instructions.
//! Values are kept in an expression arena, which stores numbers and symbolic formulas.

use volta_expr::{ExprArena, ExprNode};

use crate::ir::{LoweredInstr, Sgpr, Vgpr};

use super::interp::execute_lane;
use super::{EvalError, WaveRegisters};

// Test that a scalar tuple reads the respective component registers, which means
// if one component is directly changed, the tuple should reflect that change.
#[test]
fn scalar_tuples_share_their_component_registers() {
    // Initialize s[0:1] as two register cells holding expression handles for 10 and 20.
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();
    let tuple = [Sgpr(0), Sgpr(1)];
    let words = [arena.int(10), arena.int(20)];
    for (reg, value) in tuple.into_iter().zip(words) {
        registers.write_sgpr(reg, value).unwrap();
    }

    // Writing s0 directly must also be visible through the tuple s[0:1].
    let replacement = arena.int(30);
    registers.write_sgpr(Sgpr(0), replacement).unwrap();

    // The tuple must now read [30, 20]: s0 changed, s1 unchanged
    assert_eq!(
        tuple.map(|reg| registers.read_sgpr(reg).unwrap()),
        [replacement, words[1]]
    );
}

// Test that two lanes have separate values for the same vector register number,
// so writing to that register in one lane does not change the other lane's value.
#[test]
fn vector_registers_are_independent_across_lanes() {
    // Give the same VGPR different values in the first and last lanes (work-items).
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();
    let first = arena.int(10);
    let last = arena.int(20);
    registers.write_vgpr(0, Vgpr(255), first).unwrap();
    registers.write_vgpr(63, Vgpr(255), last).unwrap();

    // Check that each lane reads back its own value after both writes.
    assert_eq!(registers.read_vgpr(0, Vgpr(255)), Ok(first));
    assert_eq!(registers.read_vgpr(63, Vgpr(255)), Ok(last));
}

// Test that reading a valid but unwritten register reports an uninitialized value,
// while reading or writing outside the valid register or lane range reports an
// invalid index.
#[test]
fn rejects_uninitialized_and_out_of_bounds_registers() {
    // Leave the registers unwritten; create a value for the later write attempts.
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();
    let value = arena.int(1);

    // These registers exist, but reading them before a write must report uninitialized.
    assert_eq!(
        registers.read_sgpr(Sgpr(0)),
        Err(EvalError::UninitializedSgpr(Sgpr(0)))
    );
    assert_eq!(
        registers.read_vgpr(0, Vgpr(0)),
        Err(EvalError::UninitializedVgpr {
            lane: 0,
            reg: Vgpr(0)
        })
    );

    // s102 is just past the supported scalar-register range; reject reads and writes.
    assert_eq!(
        registers.read_sgpr(Sgpr(102)),
        Err(EvalError::InvalidSgpr(Sgpr(102)))
    );
    assert_eq!(
        registers.write_sgpr(Sgpr(102), value),
        Err(EvalError::InvalidSgpr(Sgpr(102)))
    );

    // A wave has lanes 0 through 63, so lane 64 is invalid even for a valid VGPR.
    assert_eq!(
        registers.read_vgpr(64, Vgpr(0)),
        Err(EvalError::InvalidLane(64))
    );
    assert_eq!(
        registers.write_vgpr(64, Vgpr(0), value),
        Err(EvalError::InvalidLane(64))
    );

    // Check that s101, the last valid scalar register, can still be written and read.
    registers.write_sgpr(Sgpr(101), value).unwrap();
    assert_eq!(registers.read_sgpr(Sgpr(101)), Ok(value));
}

// Test that shifting a known value wraps shift counts at 32 and discards overflow bits.
// When input and output use the same register, the result must use its original value.
// The register with the same number in another lane should remain unchanged.
#[test]
fn shifts_in_place_with_amd_count_and_width_rules() {
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();

    // Counts use only five bits: 34 becomes 2, and 32 becomes 0.
    // The middle case checks overflow: 0x80000001 << 1 keeps the low 32 bits, giving 2.
    for (input, shift, expected) in [(3, 34, 12), (0x80000001, 1, 2), (7, 32, 7)] {
        // Give v0 the same starting value in both lanes; only lane 0 will execute the shift.
        let value = arena.int(input);
        registers.write_vgpr(0, Vgpr(0), value).unwrap();
        registers.write_vgpr(1, Vgpr(0), value).unwrap();

        // Execute only lane 0, with v0 as both source and destination.
        // The evaluator must read the old value before overwriting that register.
        execute_lane(
            &LoweredInstr::Shl32 {
                dst: Vgpr(0),
                src: Vgpr(0),
                shift,
            },
            0,
            &mut registers,
            &mut arena,
        )
        .unwrap();

        // Check that lane 0 contains the expected number and lane 1 still contains its input.
        let result = registers.read_vgpr(0, Vgpr(0)).unwrap();
        assert!(matches!(arena.node(result), ExprNode::IntConst(value) if *value == expected));
        assert_eq!(registers.read_vgpr(1, Vgpr(0)), Ok(value));
    }
}

// Test that shifting an unknown value produces an expression describing the shift,
// and leaves the original value unchanged when the result goes into another register.
#[test]
fn shifts_symbolic_values_with_distinct_source_and_destination() {
    // Put an unknown value in v7. It is initialized, even though its number is not known.
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();
    let value = arena.symbol();
    registers.write_vgpr(0, Vgpr(7), value).unwrap();

    // Write the result into v0 so we can separately check that v7 was not changed.
    execute_lane(
        &LoweredInstr::Shl32 {
            dst: Vgpr(0),
            src: Vgpr(7),
            shift: 34,
        },
        0,
        &mut registers,
        &mut arena,
    )
    .unwrap();

    // Check that v0 contains a shift of the original symbol by 2, because 34 wraps to 2.
    let result = registers.read_vgpr(0, Vgpr(0)).unwrap();
    assert_eq!(
        arena.display_expr(result),
        format!("({} << 2)", arena.display_expr(value))
    );

    // Check that v7 still contains the original symbol.
    assert_eq!(registers.read_vgpr(0, Vgpr(7)), Ok(value));
}

// Test that an unwritten source and an unsupported instruction each cause an error,
// without changing the destination register or creating new expressions.
#[test]
fn rejects_uninitialized_shift_sources_and_unsupported_instructions() {
    // Give v1 an initial value and save the expression count for the checks after failure.
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();
    let original = arena.int(99);
    registers.write_vgpr(0, Vgpr(1), original).unwrap();
    let node_count = arena.node_count();

    // v0 has never been written, so the shift must fail before changing v1.
    assert_eq!(
        execute_lane(
            &LoweredInstr::Shl32 {
                dst: Vgpr(1),
                src: Vgpr(0),
                shift: 1,
            },
            0,
            &mut registers,
            &mut arena,
        ),
        Err(EvalError::UninitializedVgpr {
            lane: 0,
            reg: Vgpr(0)
        })
    );

    // This wait is unsupported by the lane executor, so check that it returns an error.
    assert_eq!(
        execute_lane(
            &LoweredInstr::WaitCnt {
                vmcnt: Some(0),
                lgkmcnt: None,
            },
            0,
            &mut registers,
            &mut arena,
        ),
        Err(EvalError::UnsupportedInstruction)
    );

    // Check that v1 still holds its original value and no new expressions were created.
    assert_eq!(registers.read_vgpr(0, Vgpr(1)), Ok(original));
    assert_eq!(arena.node_count(), node_count);
}
