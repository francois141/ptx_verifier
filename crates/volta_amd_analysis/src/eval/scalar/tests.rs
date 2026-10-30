//! Tests for scalar argument loads and the waits that make their results available.
//! ISA references are to AMD's CDNA4 ISA Reference Guide (5 August 2025):
//! https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf

use volta_expr::ExprArena;

use crate::frontend::parse::parse_kernel;
use crate::ir::{LoweredInstr, Sgpr};
use crate::lower_kernel;

use super::{EvalError, KernargBuffer, WaveRegisters, execute_scalar};

const ADDRESS: u64 = 0x0000_1234_abcd_0000;
const WAIT: LoweredInstr = LoweredInstr::WaitCnt {
    vmcnt: None,
    lgkmcnt: Some(0),
};

fn registers(arena: &mut ExprArena, address: u64) -> WaveRegisters {
    let mut registers = WaveRegisters::default();
    for (reg, word) in [(Sgpr(0), address as u32), (Sgpr(1), (address >> 32) as u32)] {
        registers
            .write_sgpr(reg, arena.int(i64::from(word)))
            .unwrap();
    }
    registers
}

fn load(dst: [Sgpr; 4], offset: u32) -> LoweredInstr {
    LoweredInstr::ScalarLoadDwordx4 {
        dst,
        base: [Sgpr(0), Sgpr(1)],
        offset,
    }
}

// Test that the compiled load replaces its argument-buffer pointer with four words after waiting.
// ISA: §12.6, S_LOAD_DWORDX4 (word order); §13 (little-endian data).
#[test]
fn loads_compiled_kernel_arguments_after_wait() {
    let source = include_str!("../../../tests/fixtures/copy.s");
    let kernel = lower_kernel(&parse_kernel(source, "copy").unwrap()).unwrap();
    let mut arena = ExprArena::new();
    let mut registers = registers(&mut arena, ADDRESS);
    let words = [0x8765_4320u32, 0x1234, 0xfeed_0000, 0x5678];
    let bytes: Vec<_> = words.into_iter().flat_map(u32::to_le_bytes).collect();
    let kernarg = KernargBuffer {
        address: ADDRESS,
        bytes: &bytes,
    };

    // The load reads s0/s1 before marking all four destinations pending.
    // The fixture uses xnack-; §8.2.1.1 explains the source-overwrite restriction for replay.
    execute_scalar(
        &kernel.instructions[0],
        &mut registers,
        &kernarg,
        &mut arena,
    )
    .unwrap();
    assert_eq!(
        execute_scalar(
            &kernel.instructions[0],
            &mut registers,
            &kernarg,
            &mut arena
        ),
        Err(EvalError::PendingSgpr(Sgpr(0)))
    );

    execute_scalar(
        &kernel.instructions[2],
        &mut registers,
        &kernarg,
        &mut arena,
    )
    .unwrap();
    for (reg, word) in words.into_iter().enumerate() {
        let value = registers.read_sgpr(Sgpr(reg as u8)).unwrap();
        assert_eq!(arena.as_int_const(value), Some(i64::from(word)));
    }
}

// Test that lgkmcnt(0) makes loaded values readable, and writing to a register
// before its load finishes returns an error.
// ISA: §8.3 (out-of-order completion and waiting for all scalar loads).
#[test]
fn waits_for_all_scalar_loads() {
    let bytes: Vec<_> = (1u32..=8).flat_map(u32::to_le_bytes).collect();
    let kernarg = KernargBuffer {
        address: ADDRESS,
        bytes: &bytes,
    };
    let mut arena = ExprArena::new();
    let mut registers = registers(&mut arena, ADDRESS);
    for (dst, offset) in [
        ([Sgpr(4), Sgpr(5), Sgpr(6), Sgpr(7)], 0),
        ([Sgpr(8), Sgpr(9), Sgpr(10), Sgpr(11)], 16),
    ] {
        execute_scalar(&load(dst, offset), &mut registers, &kernarg, &mut arena).unwrap();
    }

    // A different counter or a positive threshold cannot establish which scalar loads finished.
    // Rejecting these wait forms is an evaluator restriction.
    for wait in [
        LoweredInstr::WaitCnt {
            vmcnt: Some(0),
            lgkmcnt: None,
        },
        LoweredInstr::WaitCnt {
            vmcnt: None,
            lgkmcnt: Some(1),
        },
    ] {
        assert_eq!(
            execute_scalar(&wait, &mut registers, &kernarg, &mut arena),
            Err(EvalError::UnsupportedInstruction)
        );
        for reg in 4..12 {
            assert_eq!(
                registers.read_sgpr(Sgpr(reg)),
                Err(EvalError::PendingSgpr(Sgpr(reg)))
            );
        }
    }
    assert_eq!(
        registers.write_sgpr(Sgpr(4), arena.int(99)),
        Err(EvalError::PendingSgpr(Sgpr(4)))
    );

    execute_scalar(&WAIT, &mut registers, &kernarg, &mut arena).unwrap();
    for reg in 4..12 {
        let value = registers.read_sgpr(Sgpr(reg)).unwrap();
        assert_eq!(arena.as_int_const(value), Some(i64::from(reg - 3)));
    }
}

// Test that the base and offset lose their low two bits before they are added.
// ISA: §8.2.1.1 paragraph immediately below the offset-fields table.
#[test]
fn aligns_scalar_load_address_components() {
    let bytes: Vec<_> = (1u32..=8).flat_map(u32::to_le_bytes).collect();
    let kernarg = KernargBuffer {
        address: ADDRESS,
        bytes: &bytes,
    };
    let dst = [Sgpr(4), Sgpr(5), Sgpr(6), Sgpr(7)];
    let mut arena = ExprArena::new();
    let mut registers = registers(&mut arena, ADDRESS + 3);

    // The base becomes ADDRESS and offset 19 becomes 16, selecting the fifth word.
    execute_scalar(&load(dst, 19), &mut registers, &kernarg, &mut arena).unwrap();
    execute_scalar(&WAIT, &mut registers, &kernarg, &mut arena).unwrap();
    let value = registers.read_sgpr(Sgpr(4)).unwrap();
    assert_eq!(arena.as_int_const(value), Some(5));
}

// Test that invalid addresses fail without replacing the destination registers.
// This checks our evaluator's supported inputs and error handling, not hardware fault behavior.
#[test]
fn rejects_invalid_scalar_load_addresses() {
    let bytes = [0u8; 16];
    let kernarg = KernargBuffer {
        address: ADDRESS,
        bytes: &bytes,
    };
    let dst = [Sgpr(0), Sgpr(1), Sgpr(2), Sgpr(3)];
    for (base, offset, expected) in [
        (
            ADDRESS - 4,
            0,
            EvalError::KernargRead {
                address: ADDRESS - 4,
            },
        ),
        (
            ADDRESS,
            4,
            EvalError::KernargRead {
                address: ADDRESS + 4,
            },
        ),
        (u64::MAX - 3, 4, EvalError::AddressOverflow),
        (u64::MAX - 3, 0, EvalError::AddressOverflow),
    ] {
        let mut arena = ExprArena::new();
        let mut registers = registers(&mut arena, base);
        let original = registers.read_sgpr(Sgpr(0)).unwrap();
        assert_eq!(
            execute_scalar(&load(dst, offset), &mut registers, &kernarg, &mut arena),
            Err(expected)
        );
        assert_eq!(registers.read_sgpr(Sgpr(0)).unwrap(), original);
        assert_eq!(
            registers.read_sgpr(Sgpr(2)),
            Err(EvalError::UninitializedSgpr(Sgpr(2)))
        );
    }

    // Address words must be known unsigned 32-bit values.
    let mut arena = ExprArena::new();
    for invalid in [arena.symbol(), arena.int(-1), arena.int(1i64 << 32)] {
        let mut registers = registers(&mut arena, ADDRESS);
        registers.write_sgpr(Sgpr(0), invalid).unwrap();
        assert_eq!(
            execute_scalar(&load(dst, 0), &mut registers, &kernarg, &mut arena),
            Err(EvalError::InvalidAddressRegister(Sgpr(0)))
        );
    }
}
