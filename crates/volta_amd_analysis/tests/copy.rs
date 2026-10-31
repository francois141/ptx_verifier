//! Print the copy fixture's buffers and how its analysis ends, or the error that stops its
//! parsing or launch.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze};
use volta_expr::SymbolicOutputs;

const KERNARG_ADDRESS: u64 = 0x1000;
const IN: u64 = 0x10000;
const OUT: u64 = 0x20000;
const LEN: u64 = 64;
const WORDS_PER_ROW: u64 = 8;

#[test]
fn prints_the_copy_kernel_run() {
    let source = include_str!("fixtures/copy.s");
    let parsed = match parse_kernel(source, "copy") {
        Ok(parsed) => parsed,
        Err(error) => {
            println!("parse error: {error}");
            return;
        }
    };
    let kernarg: Vec<u8> = [IN, OUT].into_iter().flat_map(u64::to_le_bytes).collect();
    let launch = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: (64, 1, 1),
    };
    let input = ArrayDef {
        name: "in".into(),
        base: IN,
        len: LEN,
        kind: ArrayKind::Input,
    };
    let output = ArrayDef {
        name: "out".into(),
        base: OUT,
        len: LEN,
        kind: ArrayKind::Output,
    };
    print_input_buffer(&input);
    match analyze(&parsed, &launch, &kernarg, &[input, output]) {
        Ok(result) => match result.terminal {
            Terminal::Completed => {
                println!("{}: completed", parsed.name);
                print_outputs(&result.symbolic_outputs.unwrap());
            }
            Terminal::Aborted { wave, pc, error } => println!(
                "{}: wave {} aborted at instruction {} ({}): {error}",
                parsed.name, wave.0, pc.0, parsed.instructions[pc.0 as usize].opcode
            ),
        },
        Err(error) => println!("analysis error: {error}"),
    }
}

// Each word of an input array holds the symbol of its element, one row of words per line.
fn print_input_buffer(array: &ArrayDef) {
    println!(
        "input buffer {:?}: {} words at {:#x}",
        array.name, array.len, array.base
    );
    for row in (0..array.len).step_by(WORDS_PER_ROW as usize) {
        let words: Vec<String> = (row..array.len.min(row + WORDS_PER_ROW))
            .map(|index| format!("{}[{index}]", array.name))
            .collect();
        println!("  {:#x}: {}", array.base + 4 * row, words.join(" "));
    }
}

// Each written output element and the expression stored in it, one element per line.
fn print_outputs(outputs: &SymbolicOutputs) {
    for (name, elements) in &outputs.outputs {
        for &(index, value) in elements {
            println!("  {name}[{index}] = {}", outputs.arena.display_expr(value));
        }
    }
}
