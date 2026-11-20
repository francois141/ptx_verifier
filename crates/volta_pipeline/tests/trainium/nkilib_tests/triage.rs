//! How far each core nkilib kernel not yet checked gets through Volta at one small call:
//! traced, lowered, run, then its graph under `BASELINE` and write after write ordered. The
//! table is `external/trainium/nkilib/triage.txt` (`VOLTA_BLESS=1` rewrites it); a stage's
//! failure is the kernel's first blocker.

use std::fmt::Write;
use std::path::PathBuf;

use volta_graph_check::{GraphConclusion, check_graph};
use volta_trainium_analysis::frontend::parse::TileSizes;
use volta_trainium_analysis::{Execution, OrderingPolicy, evaluate, lower_kernel, record_graph};

use super::Arg::Tensor as T;
use super::{Arg, NKILIB, WAW, nkilib_source, traced};

struct Call {
    label: &'static str,
    wrapper: &'static str,
    args: Vec<Arg>,
    tile_sizes: TileSizes,
}

fn call(label: &'static str, wrapper: &'static str, args: Vec<Arg>) -> Call {
    Call {
        label,
        wrapper,
        args,
        tile_sizes: TileSizes::HARDWARE,
    }
}

fn calls() -> Vec<Call> {
    vec![
        call(
            "rmsnorm_quant row [1, 4, 256]",
            "rmsnorm_quant.py",
            vec![T("hidden", vec![1, 4, 256]), T("ln_w", vec![1, 256])],
        ),
        call(
            "attention_cte causal s 128, d 64",
            "attention_cte.py",
            vec![
                T("q", vec![1, 128, 64]),
                T("k", vec![1, 64, 128]),
                T("v", vec![1, 128, 64]),
            ],
        ),
        call(
            "attention_tkg s_active 1, s_prior 128, d 64",
            "attention_tkg.py",
            vec![
                T("q", vec![64, 1]),
                T("k_active", vec![64, 1]),
                T("v_active", vec![1, 1, 1, 64]),
                T("k_prior", vec![1, 1, 64, 128]),
                T("v_prior", vec![1, 1, 128, 64]),
                T("mask", vec![128, 1, 1, 1]),
                T("out", vec![1, 1, 64, 1]),
            ],
        ),
    ]
}

/// The furthest stage `call` reaches, or the first line of the error that stopped it, its
/// paths relative to nki-library's source and the wrappers.
fn outcome(call: &Call) -> String {
    let kernel = match traced(call.wrapper, &call.args, call.tile_sizes) {
        Ok(kernel) => kernel,
        Err(e) => return format!("trace: {}", shortened(&e.to_string())),
    };
    let statements = kernel.body.len();
    let lowered = match lower_kernel(&kernel) {
        Ok(lowered) => lowered,
        Err(e) => return format!("lower: {}", shortened(&e.to_string())),
    };
    let run = evaluate(&lowered);
    if let Err(e) = &run {
        return format!("run: {}", shortened(&e.to_string()));
    }
    let execution = Execution::of(&run);
    let verdict = |policy: OrderingPolicy| {
        let report = check_graph(&record_graph(&lowered, policy, &execution));
        match report.conclusion() {
            GraphConclusion::Verified => "race free".to_string(),
            _ => format!("{} conflicts", report.memory_conflict.violations().len()),
        }
    };
    format!(
        "ran {statements} statements; BASELINE {}, WAW {}",
        verdict(OrderingPolicy::BASELINE),
        verdict(WAW)
    )
}

fn shortened(message: &str) -> String {
    let source = format!("{}/", nkilib_source().display());
    let wrappers = format!("{}/", PathBuf::from(NKILIB).display());
    let line = message.lines().next().unwrap_or_default();
    let line = line.replace(&source, "").replace(&wrappers, "");
    match line.char_indices().nth(160) {
        Some((end, _)) => format!("{}...", &line[..end]),
        None => line,
    }
}

#[test]
fn core_kernels_reach_the_stages_in_the_triage_table() {
    let mut table = String::from(
        "# Each core nkilib kernel not yet checked, at one call: the first stage that stops it\n\
         # (trace, lower, run) and why, or its graph's verdict under BASELINE and with write\n\
         # after write ordered (WAW).\n",
    );
    for call in calls() {
        writeln!(table, "{}\n    {}", call.label, outcome(&call)).unwrap();
    }
    crate::common::trainium::compare(PathBuf::from(NKILIB).join("triage.txt"), table);
}
