//! Parse Clang AMD kernels into opcodes, typed operands, and launch settings.
//! Lowering validates opcodes and instruction-specific operand constraints.

use std::collections::BTreeMap;

use super::ast::{Counter, Instruction, Kernel, Operand, RegFile};

/// A statement's first word and the rest.
fn word(line: &str) -> (&str, &str) {
    line.split_once(char::is_whitespace)
        .map_or((line, ""), |(head, tail)| (head, tail.trim()))
}

/// Parse an unsigned decimal or hexadecimal integer.
fn integer(text: &str) -> Option<u64> {
    match text.strip_prefix("0x") {
        Some(hex) => u64::from_str_radix(hex, 16).ok(),
        None => text.parse().ok(),
    }
}

/// Parse a register, register range, integer, or wait counter.
fn operand(text: &str) -> Option<Operand> {
    if let Some(value) = integer(text) {
        return Some(Operand::Imm(value));
    }
    if let Some((name, rest)) = text.split_once('(') {
        let counter = match name {
            "vmcnt" => Counter::Vm,
            "lgkmcnt" => Counter::Lgkm,
            _ => return None,
        };
        let value = integer(rest.strip_suffix(')')?)?;
        return Some(Operand::Wait { counter, value });
    }
    let (file, rest) = if let Some(rest) = text.strip_prefix('s') {
        (RegFile::Scalar, rest)
    } else if let Some(rest) = text.strip_prefix('v') {
        (RegFile::Vector, rest)
    } else {
        return None;
    };
    let (first, last): (u32, u32) = match rest.strip_prefix('[').and_then(|r| r.strip_suffix(']')) {
        Some(range) => {
            let (first, last) = range.split_once(':')?;
            (first.parse().ok()?, last.parse().ok()?)
        }
        None => {
            let index = rest.parse().ok()?;
            (index, index)
        }
    };
    (first <= last).then_some(Operand::Reg { file, first, last })
}

pub fn parse_kernel(source: &str, name: &str) -> Result<Kernel, String> {
    // Clang uses `;` for assembly comments.
    let lines: Vec<&str> = source
        .lines()
        .map(|line| line.split_once(';').map_or(line, |(code, _)| code).trim())
        .filter(|line| !line.is_empty())
        .collect();

    // Read the GPU target declared for this assembly file.
    let target = lines
        .iter()
        .find_map(|line| match word(line) {
            (".amdgcn_target", rest) => Some(rest.trim_matches('"').to_string()),
            _ => None,
        })
        .ok_or("missing .amdgcn_target")?;

    // The instruction body ends at a section switch or function-end label.
    let entry = lines
        .iter()
        .position(|line| line.strip_suffix(':') == Some(name))
        .ok_or_else(|| format!("kernel {name:?} not found"))?;
    let mut instructions = Vec::new();
    for line in &lines[entry + 1..] {
        let (opcode, rest) = word(line);
        if opcode == ".section" || opcode.starts_with(".Lfunc_end") {
            break;
        }
        if opcode.starts_with('.') || line.ends_with(':') {
            return Err(format!("unsupported statement {line:?}"));
        }
        // Accept comma-separated operands and space-separated wait counters.
        let operands = rest
            .split([',', ' ', '\t'])
            .filter(|piece| !piece.is_empty())
            .map(|piece| {
                operand(piece).ok_or_else(|| format!("unsupported operand {piece:?} in {line:?}"))
            })
            .collect::<Result<_, _>>()?;
        instructions.push(Instruction {
            opcode: opcode.into(),
            operands,
        });
    }

    // Read launch settings from the kernel's separate descriptor block.
    let start = lines
        .iter()
        .position(|line| word(line) == (".amdhsa_kernel", name))
        .ok_or_else(|| format!("missing .amdhsa_kernel {name}"))?;
    let mut descriptor = BTreeMap::new();
    for line in &lines[start + 1..] {
        if *line == ".end_amdhsa_kernel" {
            return Ok(Kernel {
                name: name.into(),
                target,
                instructions,
                descriptor,
            });
        }
        let (head, value) = word(line);
        match (head.strip_prefix(".amdhsa_"), value.parse::<u64>()) {
            (Some(setting), Ok(value)) => {
                descriptor.insert(setting.into(), value);
            }
            _ => {
                return Err(format!(
                    "expected a numeric .amdhsa_ setting, found {line:?}"
                ));
            }
        }
    }
    Err("missing .end_amdhsa_kernel".into())
}

#[cfg(test)]
mod tests {
    use super::*;
    use Operand::{Imm, Reg, Wait};

    const COPY: &str = include_str!("../../tests/fixtures/copy.s");

    fn sgpr(first: u32, last: u32) -> Operand {
        Reg {
            file: RegFile::Scalar,
            first,
            last,
        }
    }

    fn vgpr(first: u32, last: u32) -> Operand {
        Reg {
            file: RegFile::Vector,
            first,
            last,
        }
    }

    fn instr(opcode: &str, operands: &[Operand]) -> Instruction {
        Instruction {
            opcode: opcode.into(),
            operands: operands.to_vec(),
        }
    }

    #[test]
    fn parses_the_compiled_copy_kernel() {
        let kernel = parse_kernel(COPY, "copy").unwrap();
        assert!(kernel.target.starts_with("amdgcn-amd-amdhsa--gfx950"));
        let lgkm = Wait {
            counter: Counter::Lgkm,
            value: 0,
        };
        let vm = Wait {
            counter: Counter::Vm,
            value: 0,
        };
        assert_eq!(
            kernel.instructions,
            [
                instr("s_load_dwordx4", &[sgpr(0, 3), sgpr(0, 1), Imm(0)]),
                instr("v_lshlrev_b32_e32", &[vgpr(0, 0), Imm(2), vgpr(0, 0)]),
                instr("s_waitcnt", &[lgkm]),
                instr("global_load_dword", &[vgpr(1, 1), vgpr(0, 0), sgpr(0, 1)]),
                instr("s_waitcnt", &[vm]),
                instr("global_store_dword", &[vgpr(0, 0), vgpr(1, 1), sgpr(2, 3)]),
                instr("s_endpgm", &[]),
            ]
        );
        assert_eq!(kernel.descriptor["kernarg_size"], 16);
        assert_eq!(kernel.descriptor["user_sgpr_kernarg_segment_ptr"], 1);
        assert_eq!(kernel.descriptor["system_vgpr_workitem_id"], 0);
    }

    #[test]
    fn parses_operand_forms_and_rejects_others() {
        assert_eq!(operand("0x10"), Some(Imm(16)));
        assert_eq!(operand("s[4:5]"), Some(sgpr(4, 5)));
        assert_eq!(operand("v7"), Some(vgpr(7, 7)));
        let vm3 = Wait {
            counter: Counter::Vm,
            value: 3,
        };
        assert_eq!(operand("vmcnt(3)"), Some(vm3));
        for bad in ["s[3:0]", "s[0]", "x0", "glc", "expcnt(0)", "vmcnt(x)", "-1"] {
            assert_eq!(operand(bad), None, "{bad}");
        }

        // An unsupported modifier must not be dropped from an otherwise supported load.
        let line = "global_load_dword v1, v0, s[0:1]";
        let source = COPY.replacen(line, &format!("{line} glc"), 1);
        assert_ne!(source, COPY, "the load instruction was not found");
        assert_eq!(
            parse_kernel(&source, "copy").unwrap_err(),
            format!("unsupported operand \"glc\" in \"{line} glc\"")
        );
    }

    #[test]
    fn ignores_comments() {
        let verbose = COPY.replacen("\ncopy:\n", "\ncopy: ; @copy\n; %bb.0:\n", 1);
        assert_ne!(verbose, COPY, "the copy: label was not found");
        let plain = parse_kernel(COPY, "copy").unwrap();
        let kernel = parse_kernel(&verbose, "copy").unwrap();
        assert_eq!(kernel.instructions, plain.instructions);
    }

    #[test]
    fn rejects_what_it_cannot_represent() {
        assert!(parse_kernel(COPY, "other").is_err());
        let with_label = COPY.replacen("\ncopy:\n", "\ncopy:\n.LBB0_1:\n", 1);
        assert_ne!(with_label, COPY, "the copy: label was not found");
        assert_eq!(
            parse_kernel(&with_label, "copy").unwrap_err(),
            "unsupported statement \".LBB0_1:\""
        );

        // A descriptor cut off before its end marker.
        let unterminated = &COPY[..COPY.find(".end_amdhsa_kernel").unwrap()];
        assert_eq!(
            parse_kernel(unterminated, "copy").unwrap_err(),
            "missing .end_amdhsa_kernel"
        );
    }
}
