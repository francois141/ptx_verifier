//! Tests for scalar argument loads and the waits that make their results available.
//! ISA references are to AMD's CDNA4 ISA Reference Guide (5 August 2025):
//! https://www.amd.com/content/dam/amd/en/documents/instinct-tech-docs/instruction-set-architectures/amd-instinct-cdna4-instruction-set-architecture.pdf

use id_collections::IdVec;
use volta_expr::{ExprArena, ExprId};

use crate::frontend::parse::parse_kernel;
use crate::ir::{InstrId, LoweredInstr, Sgpr};
use crate::lower_kernel;

use super::super::launch::WorkgroupLaunch;
use super::super::wave::{WaveId, WaveRegisters, WaveState};
use super::{EvalError, Interpreter, KernargBuffer};

const ADDRESS: u64 = 0x0000_1234_abcd_0000;
const WAIT: LoweredInstr = LoweredInstr::WaitCnt {
    vmcnt: None,
    lgkmcnt: Some(0),
};

const WAVE: WaveId = WaveId(0);

// One wave whose s[0:1] hold `base`, with `bytes` as the argument buffer at `ADDRESS`.
fn interpreter(base: u64, bytes: &[u8]) -> Interpreter<'_> {
    let mut arena = ExprArena::new();
    let mut registers = WaveRegisters::default();
    for (reg, word) in [(Sgpr(0), base as u32), (Sgpr(1), (base >> 32) as u32)] {
        registers
            .write_sgpr(reg, arena.int(i64::from(word)))
            .unwrap();
    }
    Interpreter {
        arena,
        kernarg: KernargBuffer {
            address: ADDRESS,
            bytes,
        },
        waves: IdVec::from_vec(vec![WaveState::new(registers)]),
    }
}

fn sgpr(interp: &Interpreter, reg: Sgpr) -> Result<ExprId, EvalError> {
    interp.waves[WAVE].registers.read_sgpr(reg)
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
    let words = [0x8765_4320u32, 0x1234, 0xfeed_0000, 0x5678];
    let bytes: Vec<_> = words.into_iter().flat_map(u32::to_le_bytes).collect();
    let launch = WorkgroupLaunch {
        kernarg_address: ADDRESS,
        workgroup_size: (64, 1, 1),
    };
    let mut interp = Interpreter::new(&kernel, &launch, &bytes).unwrap();

    // The load reads s0/s1 before marking all four destinations pending.
    // The fixture uses xnack-; §8.2.1.1 explains the source-overwrite restriction for replay.
    let load = &kernel.instructions[InstrId(0)];
    interp.execute_scalar(WAVE, load).unwrap();
    assert_eq!(
        interp.execute_scalar(WAVE, load),
        Err(EvalError::PendingSgpr(Sgpr(0)))
    );

    interp
        .execute_scalar(WAVE, &kernel.instructions[InstrId(2)])
        .unwrap();
    for (reg, word) in words.into_iter().enumerate() {
        let value = sgpr(&interp, Sgpr(reg as u8)).unwrap();
        assert_eq!(interp.arena.as_int_const(value), Some(i64::from(word)));
    }
}

// Test that lgkmcnt(0) makes loaded values readable, and writing to a register
// before its load finishes returns an error.
// ISA: §8.3 (out-of-order completion and waiting for all scalar loads).
#[test]
fn waits_for_all_scalar_loads() {
    let bytes: Vec<_> = (1u32..=8).flat_map(u32::to_le_bytes).collect();
    let mut interp = interpreter(ADDRESS, &bytes);
    for (dst, offset) in [
        ([Sgpr(4), Sgpr(5), Sgpr(6), Sgpr(7)], 0),
        ([Sgpr(8), Sgpr(9), Sgpr(10), Sgpr(11)], 16),
    ] {
        interp.execute_scalar(WAVE, &load(dst, offset)).unwrap();
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
            interp.execute_scalar(WAVE, &wait),
            Err(EvalError::UnsupportedInstruction)
        );
        for reg in 4..12 {
            assert_eq!(
                sgpr(&interp, Sgpr(reg)),
                Err(EvalError::PendingSgpr(Sgpr(reg)))
            );
        }
    }
    let value = interp.arena.int(99);
    assert_eq!(
        interp.waves[WAVE].registers.write_sgpr(Sgpr(4), value),
        Err(EvalError::PendingSgpr(Sgpr(4)))
    );

    interp.execute_scalar(WAVE, &WAIT).unwrap();
    for reg in 4..12 {
        let value = sgpr(&interp, Sgpr(reg)).unwrap();
        assert_eq!(interp.arena.as_int_const(value), Some(i64::from(reg - 3)));
    }
}

// Test that the base and offset lose their low two bits before they are added.
// ISA: §8.2.1.1 paragraph immediately below the offset-fields table.
#[test]
fn aligns_scalar_load_address_components() {
    let bytes: Vec<_> = (1u32..=8).flat_map(u32::to_le_bytes).collect();
    let dst = [Sgpr(4), Sgpr(5), Sgpr(6), Sgpr(7)];
    let mut interp = interpreter(ADDRESS + 3, &bytes);

    // The base becomes ADDRESS and offset 19 becomes 16, selecting the fifth word.
    interp.execute_scalar(WAVE, &load(dst, 19)).unwrap();
    interp.execute_scalar(WAVE, &WAIT).unwrap();
    let value = sgpr(&interp, Sgpr(4)).unwrap();
    assert_eq!(interp.arena.as_int_const(value), Some(5));
}

// Test that invalid addresses fail without replacing the destination registers.
// This checks our evaluator's supported inputs and error handling, not hardware fault behavior.
#[test]
fn rejects_invalid_scalar_load_addresses() {
    let bytes = [0u8; 16];
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
        let mut interp = interpreter(base, &bytes);
        let original = sgpr(&interp, Sgpr(0)).unwrap();
        assert_eq!(
            interp.execute_scalar(WAVE, &load(dst, offset)),
            Err(expected)
        );
        assert_eq!(sgpr(&interp, Sgpr(0)).unwrap(), original);
        assert_eq!(
            sgpr(&interp, Sgpr(2)),
            Err(EvalError::UninitializedSgpr(Sgpr(2)))
        );
    }

    // Address words must be known unsigned 32-bit values.
    let invalid_words: [fn(&mut ExprArena) -> ExprId; 3] = [
        ExprArena::symbol,
        |arena| arena.int(-1),
        |arena| arena.int(1i64 << 32),
    ];
    for invalid in invalid_words {
        let mut interp = interpreter(ADDRESS, &bytes);
        let value = invalid(&mut interp.arena);
        interp.waves[WAVE]
            .registers
            .write_sgpr(Sgpr(0), value)
            .unwrap();
        assert_eq!(
            interp.execute_scalar(WAVE, &load(dst, 0)),
            Err(EvalError::InvalidAddressRegister(Sgpr(0)))
        );
    }
}
