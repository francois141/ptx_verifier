//! Event-graph viewer generation.

use std::path::PathBuf;
use std::process::ExitCode;

use clap::Args;

#[derive(Args)]
pub(crate) struct VizArgs {
    /// Directory of recorded runs (the `VOLTA_VIZ_DIR` the tests recorded into)
    store: PathBuf,

    /// The HTML page to write
    #[arg(short, long, default_value = "volta-graphs.html")]
    output: PathBuf,
}

/// Write the viewer page over the runs recorded in `args.store`
pub(crate) fn cmd_viz(args: &VizArgs) -> ExitCode {
    match volta_viz::write_page(&args.store, &args.output) {
        Ok(runs) => {
            println!(
                "Wrote {} run(s) from {} to {}",
                runs,
                args.store.display(),
                args.output.display()
            );
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!(
                "error: cannot build {} from {}: {}",
                args.output.display(),
                args.store.display(),
                e
            );
            ExitCode::FAILURE
        }
    }
}
