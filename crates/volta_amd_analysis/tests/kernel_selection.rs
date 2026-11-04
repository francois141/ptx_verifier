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
