//! Selected kernel definitions must be unique within an assembly module.

use volta_amd_analysis::frontend::parse::parse_kernel;

const COPY: &str = include_str!("fixtures/copy.s");

#[test]
fn rejects_multiple_selected_kernel_entry_labels() {
    let duplicate_entry = format!("{COPY}\n.text\ncopy:\ns_endpgm\n.section .rodata\n");
    assert_eq!(
        parse_kernel(&duplicate_entry, "copy").unwrap_err(),
        "multiple entry labels for kernel \"copy\""
    );
}

#[test]
fn rejects_spaced_quoted_and_inline_duplicate_entry_labels() {
    for definition in [
        "copy :",
        "\"copy\":",
        "\"copy\" :",
        "copy: s_endpgm",
        "copy : s_endpgm",
        "\"copy\": s_endpgm",
        "\"copy\" : s_endpgm",
        "copy_extra: copy:",
        "copy_extra: \"copy\": s_endpgm",
    ] {
        let source = format!("{COPY}\n.text\n{definition}\n.section .rodata\n");
        assert_eq!(
            parse_kernel(&source, "copy").unwrap_err(),
            "multiple entry labels for kernel \"copy\"",
            "{definition}"
        );
    }
}

#[test]
fn parses_standalone_spaced_and_quoted_selected_entries_without_changing_the_body() {
    let original = parse_kernel(COPY, "copy").unwrap();
    for definition in [
        "copy :",
        "copy\t:",
        "\"copy\":",
        "\"copy\" \t: ; selected entry",
    ] {
        let source = COPY.replacen("\ncopy:\n", &format!("\n{definition}\n"), 1);
        assert_ne!(source, COPY);
        let parsed = parse_kernel(&source, "copy").unwrap();
        assert_eq!(parsed.instructions, original.instructions, "{definition}");
        assert_eq!(parsed.labels, original.labels, "{definition}");
        assert_eq!(parsed.descriptor, original.descriptor, "{definition}");
        assert_eq!(parsed.target, original.target, "{definition}");
    }
}

#[test]
fn rejects_lone_selected_entries_that_would_drop_inline_statements() {
    for definition in [
        "copy: s_endpgm",
        "copy : s_endpgm",
        "\"copy\": s_endpgm",
        "\"copy\" : s_endpgm",
        "copy: .Lbody:",
        "other_label: copy:",
    ] {
        let source = COPY.replacen("\ncopy:\n", &format!("\n{definition}\n"), 1);
        assert_ne!(source, COPY);
        assert_eq!(
            parse_kernel(&source, "copy").unwrap_err(),
            "unsupported inline entry label for kernel \"copy\"",
            "{definition}"
        );
    }
}

#[test]
fn unrelated_spaced_quoted_and_inline_labels_do_not_match_a_name_prefix() {
    for definition in [
        "copy_extra :",
        "\"copy_extra\":",
        "\"copy_extra\" : s_endpgm",
        "copy2: s_endpgm",
        "copy_extra: copy2: s_endpgm",
    ] {
        let source = format!("{COPY}\n.text\n{definition}\n.section .rodata\n");
        assert_eq!(
            parse_kernel(&source, "copy").unwrap().instructions,
            parse_kernel(COPY, "copy").unwrap().instructions,
            "{definition}"
        );
    }
}

#[test]
fn rejects_multiple_selected_kernel_descriptors() {
    let start = COPY.find(".amdhsa_kernel copy\n").unwrap();
    let end =
        COPY[start..].find(".end_amdhsa_kernel").unwrap() + start + ".end_amdhsa_kernel".len();
    let duplicate_descriptor = format!("{COPY}\n{}\n", &COPY[start..end]);
    assert_eq!(
        parse_kernel(&duplicate_descriptor, "copy").unwrap_err(),
        "multiple .amdhsa_kernel blocks for kernel \"copy\""
    );
}

#[test]
fn unrelated_function_and_descriptor_names_do_not_make_selection_ambiguous() {
    let source = format!(
        "{COPY}\n.text\ncopy_extra:\ns_endpgm\n.section .rodata\n.amdhsa_kernel copy_extra\n.amdhsa_kernarg_size 0\n.end_amdhsa_kernel\n"
    );
    assert_eq!(parse_kernel(&source, "copy").unwrap().instructions.len(), 7);
    assert_eq!(
        parse_kernel(&source, "copy_extra")
            .unwrap()
            .instructions
            .len(),
        1
    );
}
