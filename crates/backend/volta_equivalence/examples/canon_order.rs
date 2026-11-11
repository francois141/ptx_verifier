//! Probe canon `Session` reuse, timing each check. A: one session, footprint
//! order; B: one session, mid-row element first; C: fresh session per element.
//! Usage: cargo run --release -p volta_equivalence --example canon_order -- <dump>

use std::time::Instant;

use volta_equivalence::equiv::EquivSession;
use volta_equivalence::vc_dump::read_vc_dump;
use volta_expr::{ExprArena, ExprId};

/// Time a replica of the session's `ensure_ref_counts` prepass: parent
/// counts over every node of the arena (the one-time per-side cost the
/// first check of a session pays).
fn time_sweep(label: &str, arena: &ExprArena) {
    let t = Instant::now();
    let n = arena.node_count();
    let mut counts = vec![0u32; n];
    for i in 0..n {
        arena.node(ExprId(i as u32)).for_each_child(|c| {
            counts[c.0 as usize] = counts[c.0 as usize].saturating_add(1);
        });
    }
    let shared = counts.iter().filter(|&&c| c >= 2).count();
    println!(
        "  sweep({label}): {n} nodes ({shared} shared)  {:9.2} ms",
        t.elapsed().as_secs_f64() * 1e3
    );
}

fn main() {
    let path = std::env::args().nth(1).expect("usage: canon_order <dump>");
    let dump = read_vc_dump(std::path::Path::new(&path)).expect("read dump");
    let (name, ref_elems) = &dump.reference.outputs[0];
    let opt: std::collections::HashMap<u64, _> = dump
        .optimized
        .outputs
        .iter()
        .find(|(o, _)| o == name)
        .expect("array present in optimized snapshot")
        .1
        .iter()
        .map(|(i, e)| (*i, *e))
        .collect();
    let pairs: Vec<(u64, _, _)> = ref_elems
        .iter()
        .filter_map(|(i, r)| opt.get(i).map(|o| (*i, *r, *o)))
        .collect();
    println!(
        "array {name}: {} elements; ref arena {} nodes, opt arena {} nodes",
        pairs.len(),
        dump.reference.arena.node_count(),
        dump.optimized.arena.node_count()
    );

    let run = |label: &str, order: &[usize]| {
        let mut s = EquivSession::new(&dump.reference.arena, &dump.optimized.arena);
        for &k in order {
            let (i, r, o) = pairs[k];
            let t = Instant::now();
            let eq = s.check(r, o).expect("check");
            println!(
                "  {label}  slot {k:4} ({name}[{i:6}])  eq={eq}  {:9.2} ms",
                t.elapsed().as_secs_f64() * 1e3
            );
        }
    };

    // The one-time prepass, measured in isolation for each side.
    time_sweep("ref", &dump.reference.arena);
    time_sweep("opt", &dump.optimized.arena);

    // A: footprint order across row boundaries (row stride 64 for both the
    // matmul tile and FA1's 16x64 output). Slot 64/128 = row 1/2 starts:
    // mid-session, they pay their row's shared structure but no prepass.
    run("A(in-order)   ", &[0, 1, 2, 3, 64, 65, 128, 130]);
    // B: first check is a mid-tile element, then the usual first two.
    run("B(el325 first)", &[325, 0, 1]);
    // C: every element pays for its own fresh session.
    for k in [0usize, 1, 64, 325] {
        run(&format!("C(fresh el{k:<4})"), &[k]);
    }
}
