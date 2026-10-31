//! Print how the copy fixture's analysis ends, or the error that stops its parsing or launch.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{Terminal, WorkgroupLaunch, analyze};

const KERNARG_ADDRESS: u64 = 0x1000;
const IN: u64 = 0x10000;
const OUT: u64 = 0x20000;

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
    match analyze(&parsed, &launch, &kernarg) {
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
