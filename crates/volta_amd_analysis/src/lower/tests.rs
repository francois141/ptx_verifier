use crate::frontend::ast::{Counter, Operand, RegFile};
use crate::frontend::parse::parse_kernel;
use crate::ir::{LoweredInstr, Sgpr, Vgpr};

use super::{LowerError, lower_kernel};

const COPY: &str = include_str!("../../tests/fixtures/copy.s");

#[test]
fn lowers_the_compiled_copy_kernel() {
    let parsed = parse_kernel(COPY, "copy").unwrap();
    let lowered = lower_kernel(&parsed).unwrap();
    assert_eq!(lowered.name, parsed.name);
    assert_eq!(lowered.target, parsed.target);
    assert_eq!(lowered.descriptor, parsed.descriptor);
    assert_eq!(
        lowered.instructions,
        [
            LoweredInstr::ScalarLoadDwordx4 {
                dst: [Sgpr(0), Sgpr(1), Sgpr(2), Sgpr(3)],
                base: [Sgpr(0), Sgpr(1)],
                offset: 0,
            },
            LoweredInstr::Shl32 {
                dst: Vgpr(0),
                src: Vgpr(0),
                shift: 2,
            },
            LoweredInstr::WaitCnt {
                vmcnt: None,
                lgkmcnt: Some(0),
            },
            LoweredInstr::GlobalLoadDword {
                dst: Vgpr(1),
                vaddr: Vgpr(0),
                saddr: [Sgpr(0), Sgpr(1)],
            },
            LoweredInstr::WaitCnt {
                vmcnt: Some(0),
                lgkmcnt: None,
            },
            LoweredInstr::GlobalStoreDword {
                vaddr: Vgpr(0),
                src: Vgpr(1),
                saddr: [Sgpr(2), Sgpr(3)],
            },
            LoweredInstr::EndPgm,
        ]
    );
}

#[test]
fn preserves_shift_input_and_combined_wait_limits() {
    let mut kernel = parse_kernel(COPY, "copy").unwrap();
    // Reversed assembly operands must become source v7 and shift input 34.
    kernel.instructions[1].operands[1] = Operand::Imm(34);
    kernel.instructions[1].operands[2] = Operand::Reg {
        file: RegFile::Vector,
        first: 7,
        last: 7,
    };
    kernel.instructions[2].operands = vec![
        Operand::Wait {
            counter: Counter::Vm,
            value: 63,
        },
        Operand::Wait {
            counter: Counter::Lgkm,
            value: 15,
        },
    ];
    let lowered = lower_kernel(&kernel).unwrap();
    assert_eq!(
        lowered.instructions[1],
        LoweredInstr::Shl32 {
            dst: Vgpr(0),
            src: Vgpr(7),
            shift: 34,
        }
    );
    assert_eq!(
        lowered.instructions[2],
        LoweredInstr::WaitCnt {
            vmcnt: Some(63),
            lgkmcnt: Some(15),
        }
    );
}

#[test]
fn rejects_unsupported_operand_forms() {
    let register = |file, first, last| Operand::Reg { file, first, last };
    let cases = [
        (0, 0, register(RegFile::Scalar, 0, 1)),
        (0, 0, register(RegFile::Scalar, 1, 4)),
        (0, 0, register(RegFile::Scalar, 100, 103)),
        (0, 1, register(RegFile::Scalar, 1, 2)),
        (0, 2, Operand::Imm(0x100000)),
        (1, 0, register(RegFile::Scalar, 0, 0)),
        (1, 1, Operand::Imm(1u64 << 32)),
        (3, 1, register(RegFile::Vector, 0, 1)),
        (3, 0, register(RegFile::Vector, 256, 256)),
        (5, 2, register(RegFile::Scalar, 2, 4)),
        (
            2,
            0,
            Operand::Wait {
                counter: Counter::Lgkm,
                value: 16,
            },
        ),
        (
            4,
            0,
            Operand::Wait {
                counter: Counter::Vm,
                value: 64,
            },
        ),
    ];
    for (index, operand, replacement) in cases {
        let mut kernel = parse_kernel(COPY, "copy").unwrap();
        kernel.instructions[index].operands[operand] = replacement;
        let error = lower_kernel(&kernel).unwrap_err();
        assert!(matches!(error, LowerError::Instruction { index: at, .. } if at == index));
    }
}

#[test]
fn rejects_unknown_opcodes_wrong_arity_and_duplicate_counters() {
    for index in 0..7 {
        let mut kernel = parse_kernel(COPY, "copy").unwrap();
        kernel.instructions[index].operands.push(Operand::Imm(0));
        assert!(matches!(
            lower_kernel(&kernel),
            Err(LowerError::Instruction { index: at, .. }) if at == index
        ));
    }
    let mut kernel = parse_kernel(COPY, "copy").unwrap();
    kernel.instructions[0].opcode = "s_load_dwordx2".into();
    assert!(matches!(
        lower_kernel(&kernel),
        Err(LowerError::Instruction { index: 0, .. })
    ));

    let mut kernel = parse_kernel(COPY, "copy").unwrap();
    let wait = kernel.instructions[2].operands[0].clone();
    kernel.instructions[2].operands.push(wait);
    assert!(matches!(
        lower_kernel(&kernel),
        Err(LowerError::Instruction { index: 2, .. })
    ));
}

#[test]
fn rejects_other_targets() {
    let mut kernel = parse_kernel(COPY, "copy").unwrap();
    kernel.target = "amdgcn-amd-amdhsa--gfx942".into();
    assert!(matches!(
        lower_kernel(&kernel),
        Err(LowerError::UnsupportedTarget { .. })
    ));
}
