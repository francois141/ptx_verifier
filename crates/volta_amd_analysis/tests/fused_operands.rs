//! Operand boundaries for the packed-add and negated-select compiler forms.

use volta_amd_analysis::frontend::ast::{Instruction, Operand, RegFile};
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{LowerError, LoweredInstr, lower_kernel};

fn lower_instruction(instruction: &Instruction) -> Result<LoweredInstr, LowerError> {
    let mut kernel = parse_kernel(include_str!("fixtures/copy.s"), "copy").unwrap();
    kernel.instructions = vec![instruction.clone()];
    Ok(lower_kernel(&kernel)?.instructions.into_vec().remove(0))
}

fn instr(opcode: &str, operands: &[Operand]) -> Instruction {
    Instruction {
        opcode: opcode.into(),
        operands: operands.to_vec(),
    }
}

fn vgpr(index: u32) -> Operand {
    Operand::Reg {
        file: RegFile::Vector,
        first: index,
        last: index,
    }
}

#[test]
fn rejects_packed_profiles_and_negation_outside_the_supported_forms() {
    let pair = vgpr_pair(2);
    let rhs = Operand::InlineFloat(1.0f32.to_bits());
    let selectors = Operand::OpSelHi([true, false]);
    assert!(matches!(
        lower_instruction(&instr(
            "v_pk_add_f32",
            &[pair.clone(), pair.clone(), rhs.clone(), selectors.clone()]
        )),
        Ok(LoweredInstr::PackedAddF32 { .. })
    ));
    for operands in [
        vec![pair.clone(), pair.clone(), rhs.clone()],
        vec![
            pair.clone(),
            pair.clone(),
            rhs.clone(),
            Operand::OpSelHi([true, true]),
        ],
        vec![
            pair.clone(),
            pair.clone(),
            rhs.clone(),
            selectors.clone(),
            selectors.clone(),
        ],
        vec![vgpr_pair(3), pair.clone(), rhs.clone(), selectors.clone()],
        vec![pair.clone(), vgpr_pair(3), rhs, selectors.clone()],
        vec![pair.clone(), pair, vgpr(1), selectors],
    ] {
        assert!(lower_instruction(&instr("v_pk_add_f32", &operands)).is_err());
    }
    let negated = Operand::NegatedReg {
        file: RegFile::Vector,
        index: 1,
    };
    for opcode in ["v_add_f32_e32", "v_and_b32_e32", "v_cndmask_b32_e32"] {
        let mut operands = vec![vgpr(0), negated.clone(), vgpr(2)];
        if opcode == "v_cndmask_b32_e32" {
            operands.push(Operand::Vcc);
        }
        assert!(lower_instruction(&instr(opcode, &operands)).is_err());
    }
}

fn vgpr_pair(first: u32) -> Operand {
    Operand::Reg {
        file: RegFile::Vector,
        first,
        last: first + 1,
    }
}
