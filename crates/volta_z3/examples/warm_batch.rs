//! Cold vs warm vs batched Z3 over the first N paired elements of a
//! .vcdump's first output array.
//!
//! - cold: the harness's setup - every element is its own query in its own
//!   worker (fresh context), timed inside the worker.
//! - warm: ONE worker/context; a single script with the shared preamble,
//!   then per element `(push 1) (assert ...) (check-sat) (pop 1)`. The
//!   translation Builder is also shared, so the let-DAG memo carries over.
//! - batched: ONE query asserting the disjunction of all negated
//!   equalities; `unsat` proves every element equivalent at once.
//!
//! Usage:
//!   cargo run --release -p volta_z3 --example warm_batch -- <dump> <N>

use std::path::Path;
use std::time::Duration;

use volta_z3::{Builder, EvalOutcome, ExpMode, eval_smtlib2, init_worker, translate_root};

fn eval(label: &str, query: &str) -> (String, f64) {
    match eval_smtlib2(query, Some(Duration::from_secs(600))) {
        EvalOutcome::Output { text, solve } => (text, solve.as_secs_f64()),
        EvalOutcome::HardTimeout => panic!("{label}: hard timeout"),
        EvalOutcome::ChildDied(_) => panic!("{label}: worker died"),
    }
}

fn main() {
    init_worker();
    let mut args = std::env::args().skip(1);
    let usage = "usage: warm_batch <dump.vcdump> <n-elements>";
    let dump_path = args.next().expect(usage);
    let n: usize = args.next().expect(usage).parse().expect(usage);

    let dump =
        volta_analysis::driver::vc_dump::read_vc_dump(Path::new(&dump_path)).expect("read dump");
    let (name, ref_elems) = &dump.reference.outputs[0];
    let opt_elems: std::collections::HashMap<u64, _> = dump
        .optimized
        .outputs
        .iter()
        .find(|(o, _)| o == name)
        .expect("array present in optimized snapshot")
        .1
        .iter()
        .map(|(i, e)| (*i, *e))
        .collect();
    let pairs: Vec<_> = ref_elems
        .iter()
        .filter_map(|(i, r)| opt_elems.get(i).map(|o| (*i, *r, *o)))
        .take(n)
        .collect();
    println!("array {name}, {} elements", pairs.len());

    // --- cold: fresh builder + fresh worker per element ---
    let mut cold_total = 0.0;
    for (i, r, o) in &pairs {
        let mut b = Builder::with_exp_mode(ExpMode::PowerBounded);
        let ta = translate_root(&mut b, &dump.reference.arena, *r).expect("translate");
        let tb = translate_root(&mut b, &dump.optimized.arena, *o).expect("translate");
        let body = b.wrap_in_lets(&format!("(not (= {} {}))", ta, tb));
        let q = format!("{}(assert {})\n(check-sat)\n", b.preamble(), body);
        let (text, secs) = eval("cold", &q);
        let verdict = text
            .lines()
            .find(|l| !l.trim().is_empty())
            .unwrap_or("?")
            .trim();
        println!("  cold {name}[{i:3}]: {verdict:6} {:8.2} ms", secs * 1e3);
        cold_total += secs;
    }
    println!(
        "cold total ({} solver calls): {:.2} ms",
        pairs.len(),
        cold_total * 1e3
    );

    // --- warm: one worker, one context, push/check/pop per element ---
    let mut b = Builder::with_exp_mode(ExpMode::PowerBounded);
    let mut checks = String::new();
    for (_, r, o) in &pairs {
        let ta = translate_root(&mut b, &dump.reference.arena, *r).expect("translate");
        let tb = translate_root(&mut b, &dump.optimized.arena, *o).expect("translate");
        let body = b.wrap_in_lets(&format!("(not (= {} {}))", ta, tb));
        checks.push_str(&format!(
            "(push 1)\n(assert {})\n(check-sat)\n(pop 1)\n",
            body
        ));
    }
    let q = format!("{}{}", b.preamble(), checks);
    let (text, secs) = eval("warm", &q);
    let unsat = text.lines().filter(|l| l.trim() == "unsat").count();
    println!(
        "warm total (1 process, {} check-sats, {} unsat, query {} KiB): {:.2} ms",
        pairs.len(),
        unsat,
        q.len() / 1024,
        secs * 1e3
    );

    // --- batched: one disjunction, one check-sat ---
    let mut b = Builder::with_exp_mode(ExpMode::PowerBounded);
    let mut disjuncts = Vec::new();
    for (_, r, o) in &pairs {
        let ta = translate_root(&mut b, &dump.reference.arena, *r).expect("translate");
        let tb = translate_root(&mut b, &dump.optimized.arena, *o).expect("translate");
        disjuncts.push(format!("(not (= {} {}))", ta, tb));
    }
    let body = b.wrap_in_lets(&format!("(or {})", disjuncts.join(" ")));
    let q = format!("{}(assert {})\n(check-sat)\n", b.preamble(), body);
    let (text, secs) = eval("batched", &q);
    let verdict = text
        .lines()
        .find(|l| !l.trim().is_empty())
        .unwrap_or("?")
        .trim();
    println!(
        "batched (1 check-sat over {}-way disjunction, query {} KiB): {verdict} in {:.2} ms",
        pairs.len(),
        q.len() / 1024,
        secs * 1e3
    );
}
