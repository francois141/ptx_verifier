use crate::frontend::ast::{Counter, Instruction, Kernel, Operand, RegFile};
use crate::frontend::parse::parse_kernel;
use crate::ir::{LoweredInstr, Sgpr, Vgpr};

use super::{LowerError, lower_instruction, lower_kernel};

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

fn sgpr(first: u32, last: u32) -> Operand {
    Operand::Reg {
        file: RegFile::Scalar,
        first,
        last,
    }
}

fn vgpr(index: u32) -> Operand {
    Operand::Reg {
        file: RegFile::Vector,
        first: index,
        last: index,
    }
}

fn instr(opcode: &str, operands: &[Operand]) -> Instruction {
    Instruction {
        opcode: opcode.into(),
        operands: operands.to_vec(),
    }
}

#[test]
fn preserves_shift_input_and_combined_wait_limits() {
    let shift = instr("v_lshlrev_b32_e32", &[vgpr(0), Operand::Imm(34), vgpr(7)]);
    assert_eq!(
        lower_instruction(&shift),
        Ok(LoweredInstr::Shl32 {
            dst: Vgpr(0),
            src: Vgpr(7),
            shift: 34,
        })
    );
    let wait = instr(
        "s_waitcnt",
        &[
            Operand::Wait {
                counter: Counter::Vm,
                value: 63,
            },
            Operand::Wait {
                counter: Counter::Lgkm,
                value: 15,
            },
        ],
    );
    assert_eq!(
        lower_instruction(&wait),
        Ok(LoweredInstr::WaitCnt {
            vmcnt: Some(63),
            lgkmcnt: Some(15),
        })
    );
}

#[test]
fn rejects_unsupported_operand_forms() {
    use Operand::Imm;

    let cases = [
        instr("s_load_dwordx4", &[sgpr(0, 1), sgpr(0, 1), Imm(0)]),
        instr("s_load_dwordx4", &[sgpr(1, 4), sgpr(0, 1), Imm(0)]),
        instr("s_load_dwordx4", &[sgpr(100, 103), sgpr(0, 1), Imm(0)]),
        instr("s_load_dwordx4", &[sgpr(0, 3), sgpr(1, 2), Imm(0)]),
        instr("s_load_dwordx4", &[sgpr(0, 3), sgpr(0, 1), Imm(0x100000)]),
        instr("v_lshlrev_b32_e32", &[sgpr(0, 0), Imm(2), vgpr(0)]),
        instr("v_lshlrev_b32_e32", &[vgpr(0), Imm(1u64 << 32), vgpr(0)]),
        instr(
            "global_load_dword",
            &[
                vgpr(1),
                Operand::Reg {
                    file: RegFile::Vector,
                    first: 0,
                    last: 1,
                },
                sgpr(0, 1),
            ],
        ),
        instr("global_load_dword", &[vgpr(256), vgpr(0), sgpr(0, 1)]),
        instr("global_store_dword", &[vgpr(0), vgpr(1), sgpr(2, 4)]),
        instr(
            "s_waitcnt",
            &[Operand::Wait {
                counter: Counter::Lgkm,
                value: 16,
            }],
        ),
        instr(
            "s_waitcnt",
            &[Operand::Wait {
                counter: Counter::Vm,
                value: 64,
            }],
        ),
    ];
    for instruction in cases {
        assert!(lower_instruction(&instruction).is_err(), "{instruction:?}");
    }
}

#[test]
fn rejects_unknown_opcodes_wrong_arity_and_duplicate_counters() {
    use Operand::Imm;

    let wait = Operand::Wait {
        counter: Counter::Lgkm,
        value: 0,
    };
    let instructions = [
        instr("s_load_dwordx4", &[sgpr(0, 3), sgpr(0, 1), Imm(0)]),
        instr("v_lshlrev_b32_e32", &[vgpr(0), Imm(2), vgpr(0)]),
        instr("s_waitcnt", std::slice::from_ref(&wait)),
        instr("global_load_dword", &[vgpr(1), vgpr(0), sgpr(0, 1)]),
        instr("global_store_dword", &[vgpr(0), vgpr(1), sgpr(2, 3)]),
        instr("s_endpgm", &[]),
    ];
    for mut instruction in instructions {
        instruction.operands.push(Imm(0));
        assert!(lower_instruction(&instruction).is_err(), "{instruction:?}");
    }
    assert_eq!(
        lower_instruction(&instr("s_load_dwordx2", &[sgpr(0, 1), sgpr(0, 1), Imm(0)])),
        Err("unsupported instruction")
    );
    assert_eq!(
        lower_instruction(&instr("s_waitcnt", &[wait.clone(), wait])),
        Err("duplicate wait counter")
    );
}

#[test]
fn reports_instruction_error_location() {
    let kernel = Kernel {
        name: "test".into(),
        target: "amdgcn-amd-amdhsa--gfx950".into(),
        instructions: vec![instr("s_endpgm", &[]), instr("unknown", &[])],
        descriptor: Default::default(),
    };
    assert_eq!(
        lower_kernel(&kernel).unwrap_err(),
        LowerError::Instruction {
            index: 1,
            opcode: "unknown".into(),
            reason: "unsupported instruction",
        }
    );
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

#[test]
fn validates_target_features_without_discarding_them() {
    for suffix in [
        "",
        ":xnack+",
        ":xnack-",
        ":sramecc+",
        ":sramecc-",
        ":xnack+:sramecc+",
        ":xnack+:sramecc-",
        ":xnack-:sramecc+",
        ":xnack-:sramecc-",
        ":sramecc+:xnack+",
        ":sramecc+:xnack-",
        ":sramecc-:xnack+",
        ":sramecc-:xnack-",
    ] {
        let mut kernel = parse_kernel(COPY, "copy").unwrap();
        kernel.target = format!("amdgcn-amd-amdhsa--gfx950{suffix}");
        assert_eq!(lower_kernel(&kernel).unwrap().target, kernel.target);
    }
    for suffix in [
        ":",
        "::xnack-",
        ":banana",
        ":xnack",
        ":sramecc",
        ":xnack+:xnack-",
        ":xnack-:xnack-",
        ":sramecc+:sramecc-",
        ":sramecc+:sramecc+",
        ":xnack-:",
    ] {
        let mut kernel = parse_kernel(COPY, "copy").unwrap();
        kernel.target = format!("amdgcn-amd-amdhsa--gfx950{suffix}");
        assert_eq!(
            lower_kernel(&kernel).unwrap_err(),
            LowerError::UnsupportedTarget {
                target: kernel.target.clone()
            }
        );
    }
}
