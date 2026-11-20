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

/// mlp sizes its own SBUF heap at 200 KiB a partition (its context encoding path at
/// `MAX_AVAILABLE_SBUF_SIZE`, about 208 KiB), past `HARDWARE`'s 192 KiB.
const MLP_SBUF: TileSizes = TileSizes {
    sbuf_fmax_bytes: 224 * 1024,
    ..TileSizes::HARDWARE
};

fn calls() -> Vec<Call> {
    let mlp = |s: u64| {
        vec![
            T("hidden", vec![1, s, 512]),
            T("gate_w", vec![512, 256]),
            T("up_w", vec![512, 256]),
            T("down_w", vec![256, 512]),
        ]
    };
    vec![
        call(
            "rmsnorm_quant row [1, 4, 256]",
            "rmsnorm_quant.py",
            vec![T("hidden", vec![1, 4, 256]), T("ln_w", vec![1, 256])],
        ),
        call(
            "rmsnorm_quant static [1, 4, 256]",
            "rmsnorm_quant.py",
            vec![
                T("hidden", vec![1, 4, 256]),
                T("ln_w", vec![1, 256]),
                T("input_dequant_scale", vec![128, 1]),
            ],
        ),
        call(
            "output_projection_tkg d 128, 2 heads, s 4, h 512",
            "output_projection_tkg.py",
            vec![
                T("attention", vec![128, 1, 2, 4]),
                T("weight", vec![256, 512]),
            ],
        ),
        Call {
            tile_sizes: MLP_SBUF,
            ..call("mlp tkg s 4, h 512, i 256", "mlp.py", mlp(4))
        },
        Call {
            tile_sizes: MLP_SBUF,
            ..call("mlp cte s 512, h 512, i 256", "mlp.py", mlp(512))
        },
        call(
            "qkv cte s 512, h 512, d 128, 2 + 1 + 1 heads",
            "qkv.py",
            vec![
                T("input", vec![1, 512, 512]),
                T("fused_qkv_weights", vec![512, 512]),
            ],
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
