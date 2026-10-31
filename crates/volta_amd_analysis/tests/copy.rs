//! Print the copy fixture's buffers and how its analysis ends, or the error that stops its
//! parsing or launch.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{InputArray, Terminal, WorkgroupLaunch, analyze};

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
    let input = InputArray {
        name: "in".into(),
        base: IN,
        len: LEN,
    };
    print_input_buffer(&input);
    println!(
        "output buffer: {LEN} words at {OUT:#x}, not an input array; the analysis records no \
         global stores, so it holds no contents for it"
    );
    match analyze(&parsed, &launch, &kernarg, &[input]) {
        Ok(result) => match result.terminal {
            Terminal::Completed => println!("{}: completed", parsed.name),
            Terminal::Aborted { wave, pc, error } => println!(
                "{}: wave {} aborted at instruction {} ({}): {error}",
                parsed.name, wave.0, pc.0, parsed.instructions[pc.0 as usize].opcode
            ),
        },
        Err(error) => println!("analysis error: {error}"),
    }
}

// Each word of an input array holds the symbol of its element, one row of words per line.
fn print_input_buffer(array: &InputArray) {
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
