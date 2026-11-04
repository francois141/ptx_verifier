//! PTX syntax checking and module summaries.

use std::path::Path;
use std::process::ExitCode;

use volta_common::file_cache::FileCache;
use volta_common::report::{Report, locate_path, report_error};
use volta_ptx_analysis::frontend::ascii::{AsAscii, AsciiChar};
use volta_ptx_analysis::frontend::ast::{Module, TopLevelItem};
use volta_ptx_analysis::frontend::parse;

/// Parse a PTX file and report any errors
pub(crate) fn cmd_parse(file: &Path) -> ExitCode {
    let mut files = FileCache::new();

    let contents = match files.read(file) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: failed to read {}: {}", file.display(), e);
            return ExitCode::FAILURE;
        }
    };

    let ascii_src: &[AsciiChar] = match contents.as_bytes().as_ascii_slice() {
        Some(src) => src,
        None => {
            eprintln!("error: file contains non-ASCII character");
            return ExitCode::FAILURE;
        }
    };

    let mut parser = parse::Parser::new(ascii_src);
    match parser.parse_module().map_err(locate_path(file)) {
        Ok(module) => {
            println!("Parsed successfully: {}", file.display());
            print_module_summary(&module);
            ExitCode::SUCCESS
        }
        Err(e) => {
            let _ = report_error(
                &mut std::io::stderr(),
                &files,
                Report {
                    path: e.path.as_deref(),
                    span: e.span,
                    title: e.error.title(),
                    message: e.error.message().as_deref(),
                },
            );
            ExitCode::FAILURE
        }
    }
}

/// Print a summary of the parsed module
fn print_module_summary(module: &Module) {
    let mut entries = 0;
    let mut functions = 0;

    for item in &module.items {
        match item {
            TopLevelItem::Entry(_) => entries += 1,
            TopLevelItem::Function(_) => functions += 1,
            _ => {}
        }
    }

    println!("  Entries (kernels): {}", entries);
    if functions > 0 {
        println!("  Functions: {}", functions);
    }
}
