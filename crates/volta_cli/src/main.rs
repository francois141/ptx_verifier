//! Volta CLI - PTX analysis tool: `parse <file>` (syntax check), `analyze <file>` (symbolically
//! execute one kernel), `compare <file1> <file2>` (equivalence), `verify <file>` (against a spec),
//! `solve <file>` (any ISA's kernel, optionally checked against a spec),
//! `extract lean <file>` (graph checks followed by Lean proof obligations),
//! `viz <store>` (the event-graph viewer page over recorded runs).

mod cli;
mod commands;
mod config;
mod output;
mod ptx;
mod spec;

use std::process::ExitCode;

use clap::Parser;
use volta_common::run_log;

use cli::{Cli, Commands, ExtractFormat};
use commands::{
    cmd_analyze, cmd_compare, cmd_extract_lean, cmd_parse, cmd_solve, cmd_verify, cmd_viz,
};

fn main() -> ExitCode {
    let cli = Cli::parse();

    let command_name = match &cli.command {
        Commands::Parse { .. } => "parse",
        Commands::Analyze(_) => "analyze",
        Commands::Compare(_) => "compare",
        Commands::Verify(_) => "verify",
        Commands::Solve(_) => "solve",
        Commands::Extract { .. } => "extract lean",
        Commands::Viz(_) => "viz",
    };
    let mut log = run_log::RunLog::open(&cli.log_dir, command_name, cli.no_log_file);

    #[cfg(feature = "logging")]
    env_logger::Builder::new()
        .filter_level(cli.log_level.into())
        .format_timestamp(None)
        .format_target(false)
        .target(env_logger::Target::Pipe(log.tee(std::io::stderr())))
        .init();

    let code = match cli.command {
        Commands::Parse { file } => cmd_parse(&file),
        Commands::Analyze(args) => cmd_analyze(args, &mut log),
        Commands::Compare(args) => cmd_compare(args, &mut log),
        Commands::Verify(args) => cmd_verify(args, &mut log),
        Commands::Solve(args) => cmd_solve(args, &mut log),
        Commands::Extract {
            format: ExtractFormat::Lean(args),
        } => cmd_extract_lean(args, &mut log),
        Commands::Viz(args) => cmd_viz(&args),
    };

    if let Some(path) = log.path() {
        eprintln!("log: {}", path.display());
    }
    code
}
