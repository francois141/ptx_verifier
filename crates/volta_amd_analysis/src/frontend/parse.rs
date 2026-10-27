//! Extract one kernel from assembly produced by Clang for an AMD GPU: a
//! straight-line body as instruction text, and its numeric kernel descriptor.
//! TODO: Opcodes and operands are not validated; a directive or label in the 
//  body should be marked an error.

use std::collections::BTreeMap;

use super::ast::{Instruction, Kernel};

/// A statement's first word and the rest.
fn word(line: &str) -> (&str, &str) {
    line.split_once(char::is_whitespace)
        .map_or((line, ""), |(head, tail)| (head, tail.trim()))
}

pub fn parse_kernel(source: &str, name: &str) -> Result<Kernel, String> {
    // Clang writes `;` comments; drop them and blank lines.
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

    // Collect instructions after the kernel's label, stopping at a section switch
    // (`.section`) or a function-end label (`.Lfunc_end`).
    let entry = lines
        .iter()
        .position(|line| line.strip_suffix(':') == Some(name))
        .ok_or_else(|| format!("kernel {name:?} not found"))?;
    let mut instructions = Vec::new();
    for line in &lines[entry + 1..] {
        let (opcode, operands) = word(line);
        if opcode == ".section" || opcode.starts_with(".Lfunc_end") {
            break;
        }
        if opcode.starts_with('.') || line.ends_with(':') {
            return Err(format!("unsupported statement {line:?}"));
        }
        instructions.push(Instruction {
            opcode: opcode.into(),
            operands: operands.into(),
        });
    }

    // Read the numeric launch settings in the separate descriptor block, from
    // `.amdhsa_kernel <name>` through `.end_amdhsa_kernel`.
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

    const COPY: &str = include_str!("../../tests/fixtures/copy.s");

    fn text(kernel: &Kernel) -> Vec<(&str, &str)> {
        kernel
            .instructions
            .iter()
            .map(|i| (i.opcode.as_str(), i.operands.as_str()))
            .collect()
    }

    #[test]
    fn parses_the_compiled_copy_kernel() {
        let kernel = parse_kernel(COPY, "copy").unwrap();
        assert!(kernel.target.starts_with("amdgcn-amd-amdhsa--gfx950"));
        assert_eq!(
            text(&kernel),
            [
                ("s_load_dwordx4", "s[0:3], s[0:1], 0x0"),
                ("v_lshlrev_b32_e32", "v0, 2, v0"),
                ("s_waitcnt", "lgkmcnt(0)"),
                ("global_load_dword", "v1, v0, s[0:1]"),
                ("s_waitcnt", "vmcnt(0)"),
                ("global_store_dword", "v0, v1, s[2:3]"),
                ("s_endpgm", ""),
            ]
        );
        assert_eq!(kernel.descriptor["kernarg_size"], 16);
        assert_eq!(kernel.descriptor["user_sgpr_kernarg_segment_ptr"], 1);
        assert_eq!(kernel.descriptor["system_vgpr_workitem_id"], 0);
    }

    /// Clang's default output adds `;` comments such as `copy: ; @copy` and `; %bb.0:`.
    #[test]
    fn ignores_comments() {
        let verbose = COPY.replacen("\ncopy:\n", "\ncopy: ; @copy\n; %bb.0:\n", 1);
        assert_ne!(verbose, COPY, "the copy: label was not found");
        let plain = parse_kernel(COPY, "copy").unwrap();
        let kernel = parse_kernel(&verbose, "copy").unwrap();
        assert_eq!(text(&kernel), text(&plain));
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
