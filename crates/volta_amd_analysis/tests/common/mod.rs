//! A fixture's run, checked against its expected symbolic outputs: `tests/fixtures/<name>.out`
//! beside `<name>.s`, one `array[index] = expr` line per written element as in the PTX tests'
//! `.out` files. `VOLTA_BLESS=1` rewrites the file instead.

use std::fmt::Write;
use std::path::Path;

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze};

const KERNARG_ADDRESS: u64 = 0x1000;
const WORKITEMS: u32 = 64;

/// An array of one word per work-item.
pub fn array(name: &str, base: u64, kind: ArrayKind) -> ArrayDef {
    ArrayDef {
        name: name.into(),
        base,
        len: u64::from(WORKITEMS),
        kind,
    }
}

/// Run kernel `name` of `tests/fixtures/<name>.s` on one wave, with `arrays` in global memory
/// and their bases as the kernel's pointer arguments, in order, and compare its outputs with
/// `<name>.out`.
pub fn check_run(name: &str, arrays: &[ArrayDef]) {
    let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let source = std::fs::read_to_string(fixture.with_extension("s")).unwrap();
    let kernel = parse_kernel(&source, name).unwrap_or_else(|e| panic!("{name}: {e}"));

    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    let launch = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: (WORKITEMS, 1, 1),
    };
    let result =
        analyze(&kernel, &launch, &kernarg, arrays).unwrap_or_else(|e| panic!("{name}: {e}"));

    if let Terminal::Aborted { wave, pc, error } = &result.terminal {
        panic!(
            "{name}: wave {} aborted at instruction {} ({}): {error}",
            wave.0, pc.0, kernel.instructions[pc.0 as usize].opcode
        );
    }

    let outputs = result.symbolic_outputs.unwrap();
    let mut actual = String::new();
    for (array, elements) in &outputs.outputs {
        for &(index, value) in elements {
            let expr = outputs.arena.display_expr(value);
            writeln!(actual, "{array}[{index}] = {expr}").unwrap();
        }
    }

    print!("{actual}");

    let out_path = fixture.with_extension("out");
    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        std::fs::write(&out_path, &actual)
            .unwrap_or_else(|e| panic!("write {}: {e}", out_path.display()));
        return;
    }

    let expected = std::fs::read_to_string(&out_path).unwrap_or_else(|e| {
        panic!(
            "read {}: {e} (rerun with VOLTA_BLESS=1 to create it)",
            out_path.display()
        )
    });

    assert!(
        actual == expected,
        "outputs differ from {} (rerun with VOLTA_BLESS=1 to accept)\n\
         --- expected\n{expected}--- actual\n{actual}",
        out_path.display()
    );
}
