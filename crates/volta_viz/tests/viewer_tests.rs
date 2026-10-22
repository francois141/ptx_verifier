//! The viewer's run store and page on a hand-built graph: what a document records (lanes,
//! typed edges, async ops, interned event text, the checks' conclusion) and what the page
//! embeds. No producer involved; PTX-driven runs are recorded by `volta_bench`.

use std::num::NonZeroU32;
use std::path::{Path, PathBuf};

use volta_expr::ExprArena;
use volta_graph::{
    AbortCause, AccessMode, AsyncOpKind, BarrierArrivals, CollectiveSide, ContributionKind,
    EventGraph, EventId, Footprint, GenerationEvidence, GenerationKind, GraphBuilder,
    InstructionInfo, MemAccess, MemberOrdering, OperandRole, OrderingKind, ProgramPoint,
    Provenance, Proxy, Space, StoredValue, SyncObjectKind, Terminal, ThreadIx,
};
use volta_graph_check::check_graph;
use volta_viz::{Outcome, Run, RunId, write_page, write_run};

const SOURCE: &str = "// a < b\n.entry k()\n{\n  ret;\n}\n";
const PC: ProgramPoint = ProgramPoint(0);

/// A fresh, empty directory for one test.
fn scratch(name: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("volta-viz-{}-{name}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    dir
}

fn access(
    thread: u32,
    space: Space,
    mode: AccessMode,
    addr: u64,
    b: &mut GraphBuilder,
    arena: &mut ExprArena,
) -> MemAccess {
    let value = (mode == AccessMode::Write).then(|| b.value(StoredValue::Scalar(arena.int(7))));
    MemAccess {
        space,
        mode,
        ordering: OrderingKind::Ordinary,
        proxy: Proxy::Generic,
        footprint: Footprint::Bytes { addr, width: 4 },
        role: OperandRole::Plain,
        attributed: ThreadIx(thread),
        value,
    }
}

/// The events the assertions name.
struct Events {
    contributions: [EventId; 2],
    completion: EventId,
    resumes: [EventId; 2],
    issue: EventId,
    effects: [EventId; 2],
    async_completion: EventId,
}

/// Two threads of kernel `k`, whose one instruction is `ret`.
fn provenance() -> Provenance {
    Provenance {
        kernel: "k".to_string(),
        block_dim: (2, 1, 1),
        grid_dim: (1, 1, 1),
        targets: vec!["Sm80".to_string()],
        assumptions: Vec::new(),
        instructions: vec![InstructionInfo {
            kind: "Store",
            span: Some((SOURCE.find("ret").unwrap(), SOURCE.find("ret").unwrap() + 3)),
        }],
    }
}

/// Two threads write shared memory around a full-CTA barrier, then thread 0 runs one
/// two-effect `cp.async` to completion.
fn barrier_then_copy(arena: &mut ExprArena) -> (EventGraph, Events) {
    let mut b = GraphBuilder::new(provenance());
    let bar = b.sync_object(SyncObjectKind::NamedBarrier { id: 0 });
    let g = b.open_generation(
        bar,
        0,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::FullCta,
        },
    );
    let mut contributions = Vec::new();
    for t in 0..2 {
        let w = access(
            t,
            Space::Shared,
            AccessMode::Write,
            4 * u64::from(t),
            &mut b,
            arena,
        );
        b.thread_access(ThreadIx(t), PC, w);
        contributions.push(b.contribute(ThreadIx(t), PC, g, ContributionKind::Blocking));
    }
    let completion = b.complete_generation(g, GenerationEvidence::default());
    let resumes = [b.resume(ThreadIx(0), PC, g), b.resume(ThreadIx(1), PC, g)];
    let op = b.async_issue(ThreadIx(0), PC, AsyncOpKind::CpAsync);
    let source = access(0, Space::Global, AccessMode::Read, 0x1000, &mut b, arena);
    let destination = access(0, Space::Shared, AccessMode::Write, 16, &mut b, arena);
    let effects = [b.async_effect(op, source), b.async_effect(op, destination)];
    let async_completion = b.async_complete(op);
    for t in 0..2 {
        b.exit(ThreadIx(t), PC);
    }
    let graph = b.finish(Terminal::Completed);
    let issue = graph.async_ops().values().next().unwrap().issue;
    let events = Events {
        contributions: [contributions[0], contributions[1]],
        completion,
        resumes,
        issue,
        effects,
        async_completion,
    };
    (graph, events)
}

/// Threads 0 and 1 of warp 0 meet at one collective with `ordering`, which has no effects.
fn one_collective(ordering: MemberOrdering) -> EventGraph {
    let mut b = GraphBuilder::new(provenance());
    let warp = b.sync_object(SyncObjectKind::WarpCollective { warp: 0 });
    for side in [CollectiveSide::Entry, CollectiveSide::Exit] {
        let kind = GenerationKind::Collective {
            pc: PC,
            mask: 0b11,
            side,
            ordering,
        };
        let g = b.open_generation(warp, 0, kind);
        for t in 0..2 {
            b.contribute(ThreadIx(t), PC, g, ContributionKind::Blocking);
        }
        b.complete_generation(g, GenerationEvidence::default());
        for t in 0..2 {
            b.resume(ThreadIx(t), PC, g);
        }
    }
    for t in 0..2 {
        b.exit(ThreadIx(t), PC);
    }
    b.finish(Terminal::Completed)
}

fn id(test: &str, ordinal: u32) -> RunId {
    RunId {
        suite: "viewer_tests".to_string(),
        test: test.to_string(),
        ordinal: NonZeroU32::new(ordinal).unwrap(),
    }
}

fn document(dir: &Path, key: &str) -> String {
    std::fs::read_to_string(dir.join(format!("{key}.json"))).unwrap()
}

/// A synchronizing collective's (`bar.warp.sync`) member edges are plain contribute and release
/// edges; an execution-only one's (`shfl.sync`, `ldmatrix`, ...) are the dashed kinds alone.
#[test]
fn an_execution_only_collectives_edges_are_dashed_kinds() {
    let dir = scratch("collectives");
    let arena = ExprArena::new();
    let orderings = [MemberOrdering::ExecutionOnly, MemberOrdering::Synchronizing];
    for (ordinal, ordering) in (1..).zip(orderings) {
        let graph = one_collective(ordering);
        let run_id = id("one_collective", ordinal);
        let run = Run {
            id: &run_id,
            ptx_file: None,
            source: SOURCE,
            outcome: Outcome::Executed {
                graph: &graph,
                arena: &arena,
                report: None,
            },
        };
        write_run(&dir, &run).unwrap();
        let doc = document(&dir, &run_id.key());
        let execution_only = ordering == MemberOrdering::ExecutionOnly;
        for kind in ["contribute", "release"] {
            let dashed = format!(r#""{kind}-execution-only":["#);
            let plain = format!(r#""{kind}":["#);
            assert_eq!(doc.contains(&dashed), execution_only, "{ordering:?}: {doc}");
            assert_eq!(doc.contains(&plain), !execution_only, "{ordering:?}: {doc}");
        }
    }
}

#[test]
fn a_document_lays_out_lanes_edges_and_async_ops() {
    let dir = scratch("document");
    let mut arena = ExprArena::new();
    let (graph, e) = barrier_then_copy(&mut arena);
    let report = check_graph(&graph);
    let run_id = id("barrier_then_copy", 1);
    let run = Run {
        id: &run_id,
        ptx_file: Some("success/barrier_then_copy.ptx"),
        source: SOURCE,
        outcome: Outcome::Executed {
            graph: &graph,
            arena: &arena,
            report: Some(&report),
        },
    };
    write_run(&dir, &run).unwrap();
    let doc = document(&dir, &run_id.key());

    assert!(
        doc.starts_with(
            r#"{"format":"volta-viz 1","meta":{"key":"viewer_tests/barrier_then_copy""#
        )
    );
    assert!(
        doc.contains(r#""status":"race-free","terminal":"completed","threads":2"#),
        "{doc}"
    );
    assert!(doc.contains(
        r#""lanes":[{"kind":"thread","label":"t0","thread":0},{"kind":"async","label":"async t0","thread":0},{"kind":"thread","label":"t1","thread":1},{"kind":"object","label":"barrier 0","thread":null}]"#
    ), "{doc}");
    let [c0, c1] = e.contributions.map(|x| x.0);
    let [r0, r1] = e.resumes.map(|x| x.0);
    let done = e.completion.0;
    assert!(doc.contains(&format!(
        r#""edges":{{"contribute":[{c0},{done},{c1},{done}],"release":[{done},{r0},{done},{r1}]}}"#
    )), "{doc}");
    let [a, b] = e.effects.map(|x| x.0);
    assert!(
        doc.contains(&format!(
            r#""asyncOps":[[{},{},{a},{b}]]"#,
            e.issue.0, e.async_completion.0
        )),
        "{doc}"
    );
    assert!(doc.contains(r#""write shared [0x0, +4)""#), "{doc}");
    assert!(
        doc.contains(r#""line":4"#),
        "the instruction maps to `ret`'s line: {doc}"
    );
    assert!(
        doc.contains(r#""conclusion":{"status":"race-free","reasons":[]}"#),
        "{doc}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn the_page_embeds_every_run_and_escapes_its_text() {
    let dir = scratch("page");
    let mut arena = ExprArena::new();
    let (graph, _) = barrier_then_copy(&mut arena);
    let executed = id("barrier_then_copy", 1);
    let failed = id("barrier_then_copy", 2);
    write_run(
        &dir,
        &Run {
            id: &executed,
            ptx_file: None,
            source: SOURCE,
            outcome: Outcome::Executed {
                graph: &graph,
                arena: &arena,
                report: None,
            },
        },
    )
    .unwrap();
    write_run(
        &dir,
        &Run {
            id: &failed,
            ptx_file: None,
            source: SOURCE,
            outcome: Outcome::NotStarted {
                cause: AbortCause::Unsupported,
                error: "lowering failed: </script>".to_string(),
            },
        },
    )
    .unwrap();
    let page_path = dir.join("page.html");
    assert_eq!(write_page(&dir, &page_path).unwrap(), 2);
    let page = std::fs::read_to_string(&page_path).unwrap();

    assert!(page.starts_with("<!doctype html>"));
    assert!(page.contains(r#""key":"viewer_tests/barrier_then_copy","#));
    assert!(page.contains(r#""key":"viewer_tests/barrier_then_copy~2","#));
    assert!(page.contains(r#""status":"unchecked""#));
    assert!(page.contains(r#""status":"unsupported""#));
    assert!(page.contains(r#"id="run-0""#) && page.contains(r#"id="run-1""#));
    assert!(!page.contains("a < b") && !page.contains("failed: </script>"));
    assert_eq!(
        page.matches("</script>").count(),
        4,
        "index, two runs, the viewer"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

/// Thread 0 writes shared word 0, then `end` closes the trace: thread 1 writing the same word
/// unordered and both exiting, or the execution stopping with `cause`.
fn one_write_then(end: Option<AbortCause>, arena: &mut ExprArena) -> EventGraph {
    let mut b = GraphBuilder::new(provenance());
    let w = access(0, Space::Shared, AccessMode::Write, 0, &mut b, arena);
    b.thread_access(ThreadIx(0), PC, w);
    match end {
        Some(cause) => b.finish(Terminal::Aborted {
            thread: Some(ThreadIx(0)),
            pc: Some(PC),
            cause,
            reason: "stopped".to_string(),
        }),
        None => {
            let w = access(1, Space::Shared, AccessMode::Write, 0, &mut b, arena);
            b.thread_access(ThreadIx(1), PC, w);
            for t in 0..2 {
                b.exit(ThreadIx(t), PC);
            }
            b.finish(Terminal::Completed)
        }
    }
}

#[test]
fn a_run_is_named_by_its_outcome() {
    let dir = scratch("outcomes");
    let mut arena = ExprArena::new();
    let cases = [
        (None, "race-condition"),
        (Some(AbortCause::Unsupported), "unsupported"),
        (Some(AbortCause::Error), "error"),
    ];
    for (ordinal, (end, status)) in (1..).zip(cases) {
        let graph = one_write_then(end, &mut arena);
        let report = check_graph(&graph);
        let run_id = id("one_write", ordinal);
        let run = Run {
            id: &run_id,
            ptx_file: None,
            source: SOURCE,
            outcome: Outcome::Executed {
                graph: &graph,
                arena: &arena,
                report: Some(&report),
            },
        };
        write_run(&dir, &run).unwrap();
        let doc = document(&dir, &run_id.key());
        assert!(
            doc.contains(&format!(r#""status":"{status}","terminal""#)),
            "{doc}"
        );
        assert!(
            doc.contains(&format!(r#""conclusion":{{"status":"{status}""#)),
            "{doc}"
        );
    }
    let _ = std::fs::remove_dir_all(&dir);
}
