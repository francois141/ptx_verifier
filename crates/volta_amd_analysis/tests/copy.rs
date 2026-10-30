//! Print the IR the copy fixture lowers to, or the error that stops its parsing or lowering.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::lower_kernel;

#[test]
fn prints_the_copy_kernel_ir() {
    let source = include_str!("fixtures/copy.s");
    let parsed = match parse_kernel(source, "copy") {
        Ok(parsed) => parsed,
        Err(error) => {
            println!("parse error: {error}");
            return;
        }
    };
    match lower_kernel(&parsed) {
        Ok(kernel) => {
            println!("{} ({})", kernel.name, kernel.target);
            for (index, (instruction, lowered)) in parsed
                .instructions
                .iter()
                .zip(&kernel.instructions)
                .enumerate()
            {
                println!("  {index:3}  {:<20} {lowered:?}", instruction.opcode);
            }
        }
        Err(error) => println!("lowering error: {error}"),
    }
}
