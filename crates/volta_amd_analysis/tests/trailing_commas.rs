//! Ordinary trailing commas preserve operands and lowering's arity checks.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::lower_kernel;

fn kernel_source(body: &str, descriptor: &str) -> String {
    format!(
        ".amdgcn_target \"amdgcn-amd-amdhsa--gfx950\"\n\
         test:\n{body}\n.Lfunc_end0:\n\
         .amdhsa_kernel test\n{descriptor}\n.end_amdhsa_kernel\n"
    )
}

#[test]
fn accepts_one_trailing_comma_without_changing_instructions() {
    for line in [
        "v_lshlrev_b32_e32 v0, 2, v0",
        "s_load_dwordx4 s[0:3], s[4:5], 0",
        "global_load_dword v1, v0, s[0:1]",
        "global_store_dword v0, v1, s[2:3]",
    ] {
        let plain = parse_kernel(&kernel_source(line, ""), "test").unwrap();
        let lowered = lower_kernel(&plain).unwrap();
        for suffix in [",", ",  ", ", ; trailing comment"] {
            let source = kernel_source(&format!("{line}{suffix}"), "");
            let parsed = parse_kernel(&source, "test").unwrap();
            assert_eq!(parsed.instructions, plain.instructions, "{line}{suffix}");
            assert_eq!(
                lower_kernel(&parsed).unwrap().instructions,
                lowered.instructions,
                "{line}{suffix}"
            );
        }
    }
}

#[test]
fn trailing_comma_preserves_invalid_operands_for_lowering() {
    for line in [
        "s_endpgm 0",
        "v_lshlrev_b32_e32 v0, 2",
        "global_load_dword v1, v0",
    ] {
        let plain = parse_kernel(&kernel_source(line, ""), "test").unwrap();
        let parsed = parse_kernel(&kernel_source(&format!("{line},"), ""), "test").unwrap();
        assert_eq!(parsed.instructions, plain.instructions, "{line}");
        assert!(lower_kernel(&plain).is_err(), "{line}");
        assert!(lower_kernel(&parsed).is_err(), "{line},");
    }
}
