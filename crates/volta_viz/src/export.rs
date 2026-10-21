//! One kernel run as the viewer's JSON document (`volta-viz 1`): the graph's events placed in
//! lanes, its typed edges, the checks' findings resolved to events, and the PTX source the
//! events' program points map back to.
//!
//! A large trace holds tens of thousands of near-identical events, so events are rows of
//! indices into the document's string and detail-pair tables, and each async op is listed once
//! (`[issue, completion, effects...]`) rather than as two edges per effect.

use std::collections::{BTreeMap, BTreeSet, HashMap};

use volta_expr::ExprArena;
use volta_graph::{
    AccessMode, AsyncOpId, BarrierArrivals, BlockedOn, CollectiveSide, ContributionKind,
    EventGraph, EventId, EventKind, ExecContext, FenceKind, Footprint, GenerationId,
    GenerationKind, GroupFamily, OrderingKind, Parity, Proxy, Space, StoredValue, SyncObjectId,
    SyncObjectKind, Terminal, ThreadIx,
};
use volta_graph_check::barrier_epoch::EpochViolation;
use volta_graph_check::domain::ConflictKind;
use volta_graph_check::pipeline::pipeline_edges;
use volta_graph_check::resource_lifetime::LifetimeViolation;
use volta_graph_check::{GraphConclusion, GraphReport, Property, PropertyResult, Verdict};

use crate::json::Json;
use crate::store::RunId;

/// The longest stored-value expression a document carries; longer ones are cut.
const MAX_VALUE_BYTES: usize = 400;

/// What the analysis produced for one run.
pub enum Outcome<'a> {
    /// The execution ran (to completion or not) and recorded `graph`, whose stored values are
    /// expressions of `arena`. `report` is the six checks' result, when the run checked them.
    Executed {
        graph: &'a EventGraph,
        arena: &'a ExprArena,
        report: Option<&'a GraphReport>,
    },
    /// The execution never started (no such kernel, a lowering or configuration error).
    NotStarted { error: String },
}

/// One kernel run to visualize.
pub struct Run<'a> {
    pub id: &'a RunId,
    /// The PTX file the source was read from, as the producer names it; `None` for source a
    /// test built itself.
    pub ptx_file: Option<&'a str>,
    pub source: &'a str,
    pub outcome: Outcome<'a>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Status {
    Verified,
    Rejected,
    Unknown,
    /// Executed, but the run did not check the graph.
    Unchecked,
    NotStarted,
}

impl Status {
    fn of(outcome: &Outcome) -> Status {
        match outcome {
            Outcome::NotStarted { .. } => Status::NotStarted,
            Outcome::Executed { report: None, .. } => Status::Unchecked,
            Outcome::Executed {
                report: Some(report),
                ..
            } => match report.conclusion() {
                GraphConclusion::Verified => Status::Verified,
                GraphConclusion::Rejected { .. } => Status::Rejected,
                GraphConclusion::Unknown { .. } => Status::Unknown,
            },
        }
    }

    fn name(self) -> &'static str {
        match self {
            Status::Verified => "verified",
            Status::Rejected => "rejected",
            Status::Unknown => "unknown",
            Status::Unchecked => "unchecked",
            Status::NotStarted => "not-started",
        }
    }
}

/// The run's index entry: what the test list shows without loading the document.
pub fn summary(run: &Run) -> Json {
    let (kernel, terminal, threads, events) = match &run.outcome {
        Outcome::Executed { graph, .. } => (
            Json::str(graph.provenance().kernel.clone()),
            Json::str(terminal_name(graph.terminal())),
            Json::uint(graph.threads()),
            Json::uint(graph.events().len() as u64),
        ),
        Outcome::NotStarted { .. } => (Json::Null, Json::Null, Json::Null, Json::Null),
    };
    Json::Obj(vec![
        ("key", Json::str(run.id.key())),
        ("suite", Json::str(run.id.suite.clone())),
        ("test", Json::str(run.id.test.clone())),
        ("run", Json::uint(run.id.ordinal.get())),
        ("ptx", Json::opt(run.ptx_file, Json::str)),
        ("kernel", kernel),
        ("status", Json::str(Status::of(&run.outcome).name())),
        ("terminal", terminal),
        ("threads", threads),
        ("events", events),
    ])
}

/// The run's full document.
pub fn document(run: &Run) -> Json {
    let mut fields = vec![
        ("format", Json::str("volta-viz 1")),
        ("meta", summary(run)),
        ("source", Json::str(run.source)),
    ];
    match &run.outcome {
        Outcome::NotStarted { error } => fields.push(("error", Json::str(error.clone()))),
        Outcome::Executed {
            graph,
            arena,
            report,
        } => fields.extend(graph_fields(graph, arena, *report, run.source)),
    }
    Json::Obj(fields)
}

/// Each distinct string and `(key, value)` detail pair of a document, stored once.
#[derive(Default)]
struct Interner {
    strings: Vec<String>,
    string_ids: HashMap<String, u32>,
    pairs: Vec<(u32, u32)>,
    pair_ids: HashMap<(u32, u32), u32>,
}

impl Interner {
    fn string(&mut self, s: &str) -> u32 {
        if let Some(&id) = self.string_ids.get(s) {
            return id;
        }
        let id = self.strings.len() as u32;
        self.strings.push(s.to_string());
        self.string_ids.insert(s.to_string(), id);
        id
    }

    fn pair(&mut self, key: &str, value: &str) -> u32 {
        let pair = (self.string(key), self.string(value));
        let next = self.pairs.len() as u32;
        let id = *self.pair_ids.entry(pair).or_insert(next);
        if id == next {
            self.pairs.push(pair);
        }
        id
    }
}

/// `[lane, pc or -1, category, label, detail pairs...]`, all but the lane and pc interned.
fn event_row(
    graph: &EventGraph,
    arena: &ExprArena,
    lanes: &Lanes,
    interner: &mut Interner,
    id: EventId,
) -> Json {
    let ev = graph.event(id);
    let (category, label, info) = describe(graph, arena, id);
    let mut row = vec![
        Json::uint(lanes.lane_of(graph, ev.ctx) as u64),
        ev.pc.map_or(Json::Int(-1), |pc| Json::uint(pc.0)),
        Json::uint(interner.string(category)),
        Json::uint(interner.string(&label)),
    ];
    row.extend(info.iter().map(|(k, v)| Json::uint(interner.pair(k, v))));
    Json::Arr(row)
}

fn graph_fields(
    graph: &EventGraph,
    arena: &ExprArena,
    report: Option<&GraphReport>,
    source: &str,
) -> Vec<(&'static str, Json)> {
    let lanes = Lanes::of(graph);
    let mut interner = Interner::default();
    let events: Vec<Json> = graph
        .events()
        .iter()
        .map(|(id, _)| event_row(graph, arena, &lanes, &mut interner, id))
        .collect();
    let lines = LineIndex::new(source);
    let p = graph.provenance();
    vec![
        (
            "launch",
            Json::Obj(vec![
                ("block", dims(p.block_dim)),
                ("grid", dims(p.grid_dim)),
                (
                    "targets",
                    Json::Arr(p.targets.iter().map(|t| Json::str(t.clone())).collect()),
                ),
                (
                    "assumptions",
                    Json::Arr(
                        p.assumptions
                            .iter()
                            .map(|a| Json::str(a.describe()))
                            .collect(),
                    ),
                ),
            ]),
        ),
        (
            "instructions",
            Json::Arr(
                p.instructions
                    .iter()
                    .map(|i| {
                        Json::Obj(vec![
                            ("kind", Json::str(i.kind)),
                            (
                                "line",
                                Json::opt(i.span.and_then(|(lo, _)| lines.line(lo)), |l| {
                                    Json::uint(l as u64)
                                }),
                            ),
                        ])
                    })
                    .collect(),
            ),
        ),
        ("lanes", lanes.to_json()),
        (
            "strings",
            Json::Arr(interner.strings.into_iter().map(Json::Str).collect()),
        ),
        (
            "pairs",
            Json::Arr(
                interner
                    .pairs
                    .iter()
                    .flat_map(|&(k, v)| [Json::uint(k), Json::uint(v)])
                    .collect(),
            ),
        ),
        ("events", Json::Arr(events)),
        ("edges", edges(graph)),
        ("asyncOps", async_ops(graph)),
        ("terminal", terminal(graph)),
        ("checks", Json::opt(report, |r| checks(graph, r))),
        ("conclusion", Json::opt(report, conclusion)),
    ]
}

fn dims((x, y, z): (u32, u32, u32)) -> Json {
    Json::Arr(vec![Json::uint(x), Json::uint(y), Json::uint(z)])
}

/// 1-based line numbers of source byte offsets.
struct LineIndex {
    starts: Vec<usize>,
    len: usize,
}

impl LineIndex {
    fn new(source: &str) -> LineIndex {
        let starts = std::iter::once(0)
            .chain(source.match_indices('\n').map(|(i, _)| i + 1))
            .collect();
        LineIndex {
            starts,
            len: source.len(),
        }
    }

    fn line(&self, offset: usize) -> Option<usize> {
        (offset <= self.len).then(|| self.starts.partition_point(|&s| s <= offset))
    }
}

// =========================================================================
// Lanes
// =========================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum LaneKind {
    Thread,
    /// The effects and completions of one thread's asynchronous operations.
    Async,
    /// The generation completions of one synchronization object.
    Object,
}

struct Lane {
    kind: LaneKind,
    label: String,
    /// The thread a thread or async lane belongs to.
    thread: Option<ThreadIx>,
}

/// Each thread's lane, followed by its async lane if it issues any; then one lane per
/// synchronization object with a completed generation.
struct Lanes {
    lanes: Vec<Lane>,
    thread: BTreeMap<ThreadIx, usize>,
    asynchronous: BTreeMap<ThreadIx, usize>,
    object: BTreeMap<SyncObjectId, usize>,
}

impl Lanes {
    fn of(graph: &EventGraph) -> Lanes {
        let issuers: BTreeSet<ThreadIx> = graph.async_ops().values().map(|op| op.issuer).collect();
        let mut lanes = Lanes {
            lanes: Vec::new(),
            thread: BTreeMap::new(),
            asynchronous: BTreeMap::new(),
            object: BTreeMap::new(),
        };
        for t in (0..graph.threads()).map(ThreadIx) {
            lanes.thread.insert(t, lanes.lanes.len());
            lanes.lanes.push(Lane {
                kind: LaneKind::Thread,
                label: format!("t{}", t.0),
                thread: Some(t),
            });
            if issuers.contains(&t) {
                lanes.asynchronous.insert(t, lanes.lanes.len());
                lanes.lanes.push(Lane {
                    kind: LaneKind::Async,
                    label: format!("async t{}", t.0),
                    thread: Some(t),
                });
            }
        }
        let completing: BTreeSet<SyncObjectId> = graph
            .generations()
            .values()
            .filter(|g| g.completion.is_some())
            .map(|g| g.object)
            .collect();
        for object in completing {
            lanes.object.insert(object, lanes.lanes.len());
            lanes.lanes.push(Lane {
                kind: LaneKind::Object,
                label: object_name(graph, object),
                thread: None,
            });
        }
        lanes
    }

    fn lane_of(&self, graph: &EventGraph, ctx: ExecContext) -> usize {
        match ctx {
            ExecContext::Thread(t) => self.thread[&t],
            ExecContext::Async(op) => self.asynchronous[&graph.async_op(op).issuer],
            ExecContext::Generation(g) => self.object[&graph.generation(g).object],
        }
    }

    fn to_json(&self) -> Json {
        Json::Arr(
            self.lanes
                .iter()
                .map(|lane| {
                    Json::Obj(vec![
                        (
                            "kind",
                            Json::str(match lane.kind {
                                LaneKind::Thread => "thread",
                                LaneKind::Async => "async",
                                LaneKind::Object => "object",
                            }),
                        ),
                        ("label", Json::str(lane.label.clone())),
                        ("thread", Json::opt(lane.thread, |t| Json::uint(t.0))),
                    ])
                })
                .collect(),
        )
    }
}

// =========================================================================
// Edges
// =========================================================================

/// The typed edges besides program order (implicit in each thread lane's sequence) and the
/// async ops' spawn and completion edges (see `async_ops`), as flat `[from, to, ...]` lists
/// per kind.
fn edges(graph: &EventGraph) -> Json {
    let mut by_kind: BTreeMap<&'static str, Vec<Json>> = BTreeMap::new();
    let mut push = |kind, from: EventId, to: EventId| {
        by_kind
            .entry(kind)
            .or_default()
            .extend([Json::uint(from.0), Json::uint(to.0)]);
    };
    for g in graph.generations().values() {
        let Some(completion) = g.completion else {
            continue;
        };
        for c in &g.contributions {
            push("contribute", c.event, completion);
        }
        for &r in &g.releases {
            push("release", completion, r);
        }
    }
    for e in pipeline_edges(graph).edges(graph) {
        push("pipeline", e.from, e.to);
    }
    Json::Obj(
        by_kind
            .into_iter()
            .map(|(kind, list)| (kind, Json::Arr(list)))
            .collect(),
    )
}

/// Each async op as `[issue, completion or -1, effect events...]`: the issue spawns every
/// effect, and every effect precedes the completion.
fn async_ops(graph: &EventGraph) -> Json {
    let mut access_event = BTreeMap::new();
    for (id, ev) in graph.events().iter() {
        if let EventKind::Access(a) = ev.kind {
            access_event.insert(a, id);
        }
    }
    Json::Arr(
        graph
            .async_ops()
            .values()
            .map(|op| {
                let mut row = vec![
                    Json::uint(op.issue.0),
                    op.completion.map_or(Json::Int(-1), |c| Json::uint(c.0)),
                ];
                row.extend(op.effects.iter().map(|a| Json::uint(access_event[a].0)));
                Json::Arr(row)
            })
            .collect(),
    )
}

// =========================================================================
// Event descriptions
// =========================================================================

type Info = Vec<(&'static str, String)>;

/// The event's category (its node style), one-line label and detail rows.
fn describe(graph: &EventGraph, arena: &ExprArena, id: EventId) -> (&'static str, String, Info) {
    let ev = graph.event(id);
    let mut info: Info = vec![("context", context_name(graph, ev.ctx))];
    let (category, label) = match ev.kind {
        EventKind::Access(a) => {
            let a = graph.access(a);
            let mode = match a.mode {
                AccessMode::Read => "read",
                AccessMode::Write => "write",
            };
            info.push(("space", space_name(a.space).to_string()));
            info.push(("footprint", footprint(a.footprint)));
            info.push((
                "proxy",
                match a.proxy {
                    Proxy::Generic => "generic",
                    Proxy::Async => "async",
                }
                .to_string(),
            ));
            info.push((
                "ordering",
                match a.ordering {
                    OrderingKind::Ordinary => "ordinary",
                    OrderingKind::Atomic => "atomic",
                    OrderingKind::Reduction => "reduction",
                }
                .to_string(),
            ));
            info.push(("operand", format!("{:?}", a.role)));
            info.push(("attributed to", format!("t{}", a.attributed.0)));
            if let Some(v) = a.value {
                info.push(("value", stored_value(arena, graph.value(v))));
            }
            (
                mode,
                format!("{mode} {} {}", space_name(a.space), footprint(a.footprint)),
            )
        }
        EventKind::Contribute(g) => {
            let how = graph
                .generation(g)
                .contributions
                .iter()
                .find(|c| c.event == id)
                .map_or("contribution".to_string(), |c| contribution(c.kind));
            info.push(("generation", generation_name(graph, g)));
            info.push(("contribution", how.clone()));
            ("sync", format!("{how} → {}", generation_name(graph, g)))
        }
        EventKind::WaitStart { object, parity } => {
            info.push(("object", object_name(graph, object)));
            info.push(("parity", parity_bit(parity).to_string()));
            (
                "wait",
                format!(
                    "wait {} parity {}",
                    object_name(graph, object),
                    parity_bit(parity)
                ),
            )
        }
        EventKind::Resume(g) => {
            info.push(("generation", generation_name(graph, g)));
            ("resume", format!("resume ← {}", generation_name(graph, g)))
        }
        EventKind::GenerationComplete(g) => {
            let genr = graph.generation(g);
            info.push(("generation", generation_name(graph, g)));
            info.push(("kind", generation_kind(genr.kind)));
            info.push(("contributions", genr.contributions.len().to_string()));
            info.push(("releases", genr.releases.len().to_string()));
            info.push((
                "surplus arrivals",
                genr.evidence.surplus_arrivals.to_string(),
            ));
            info.push(("pending tx", genr.evidence.pending_tx.to_string()));
            (
                "generation",
                format!("{} complete", generation_name(graph, g)),
            )
        }
        EventKind::AsyncIssue(op) => {
            async_info(graph, op, &mut info);
            ("issue", format!("issue {}", async_name(graph, op)))
        }
        EventKind::AsyncComplete(op) => {
            async_info(graph, op, &mut info);
            (
                "async-complete",
                format!("complete {}", async_name(graph, op)),
            )
        }
        EventKind::GroupCommit(family) => (
            "commit",
            match family {
                GroupFamily::CpAsync => "cp.async.commit_group",
                GroupFamily::Wgmma => "wgmma.commit_group",
            }
            .to_string(),
        ),
        EventKind::Fence(kind) => (
            "fence",
            match kind {
                FenceKind::ProxyAsync { space: Some(s) } => {
                    format!("fence.proxy.async {}", space_name(s))
                }
                FenceKind::ProxyAsync { space: None } => "fence.proxy.async".to_string(),
                FenceKind::Tcgen05BeforeThreadSync => {
                    "tcgen05.fence::before_thread_sync".to_string()
                }
                FenceKind::Tcgen05AfterThreadSync => "tcgen05.fence::after_thread_sync".to_string(),
            },
        ),
        EventKind::ObjectInit(o) => ("lifetime", format!("init {}", object_name(graph, o))),
        EventKind::ObjectInval(o) => ("lifetime", format!("inval {}", object_name(graph, o))),
        EventKind::TmemAlloc {
            start_col,
            num_cols,
        } => (
            "tmem",
            format!("tcgen05.alloc cols [{start_col}, +{num_cols})"),
        ),
        EventKind::TmemDealloc {
            start_col,
            num_cols,
        } => (
            "tmem",
            format!("tcgen05.dealloc cols [{start_col}, +{num_cols})"),
        ),
        EventKind::Exit => ("exit", "exit".to_string()),
    };
    (category, label, info)
}

fn async_info(graph: &EventGraph, op: AsyncOpId, info: &mut Info) {
    let a = graph.async_op(op);
    info.push(("operation", async_name(graph, op)));
    info.push(("issuer", format!("t{}", a.issuer.0)));
    info.push(("effects", a.effects.len().to_string()));
    if !a.tracking.is_empty() {
        let tracking: Vec<String> = a
            .tracking
            .iter()
            .map(|&g| generation_name(graph, g))
            .collect();
        info.push(("tracked by", tracking.join(", ")));
    }
}

fn context_name(graph: &EventGraph, ctx: ExecContext) -> String {
    match ctx {
        ExecContext::Thread(t) => format!("thread t{}", t.0),
        ExecContext::Async(op) => format!("async {}", async_name(graph, op)),
        ExecContext::Generation(g) => format!("generation {}", generation_name(graph, g)),
    }
}

fn async_name(graph: &EventGraph, op: AsyncOpId) -> String {
    format!("{} a{}", graph.async_op(op).kind.name(), op.0)
}

fn object_name(graph: &EventGraph, object: SyncObjectId) -> String {
    match &graph.object(object).kind {
        SyncObjectKind::NamedBarrier { id } => format!("barrier {id}"),
        SyncObjectKind::Mbarrier {
            addr,
            expected_arrivals,
        } => format!("mbarrier {addr:#x} (count {expected_arrivals})"),
        SyncObjectKind::WarpCollective { warp } => format!("warp {warp} collectives"),
        SyncObjectKind::WarpgroupCollective { warpgroup } => {
            format!("warpgroup {warpgroup} collectives")
        }
        SyncObjectKind::AsyncGroupWait { thread } => format!("cp.async groups t{}", thread.0),
    }
}

fn generation_name(graph: &EventGraph, g: GenerationId) -> String {
    let genr = graph.generation(g);
    format!("{} #{}", object_name(graph, genr.object), genr.index)
}

fn generation_kind(kind: GenerationKind) -> String {
    match kind {
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::FullCta,
        } => "barrier of the full CTA".to_string(),
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::Count(n),
        } => format!("barrier of {n} threads"),
        GenerationKind::MbarrierPhase => "mbarrier phase".to_string(),
        GenerationKind::Collective { pc, mask, side } => format!(
            "collective {} at pc {}, mask {mask:#010x}",
            match side {
                CollectiveSide::Entry => "entry",
                CollectiveSide::Exit => "exit",
            },
            pc.0
        ),
        GenerationKind::AsyncGroupWait { keep_pending } => {
            format!("cp.async.wait_group {keep_pending}")
        }
    }
}

fn contribution(kind: ContributionKind) -> String {
    match kind {
        ContributionKind::Blocking => "blocking arrival".to_string(),
        ContributionKind::Arrival {
            count,
            expect_tx: 0,
        } => format!("arrive ×{count}"),
        ContributionKind::Arrival { count, expect_tx } => {
            format!("arrive ×{count}, expect_tx {expect_tx}")
        }
        ContributionKind::Exited => "exited".to_string(),
        ContributionKind::AsyncCompletion { op, tx_bytes } => {
            format!("completion of a{} ({tx_bytes} tx bytes)", op.0)
        }
        ContributionKind::CompleteTx { bytes } => format!("complete_tx {bytes}"),
    }
}

fn parity_bit(p: Parity) -> u8 {
    match p {
        Parity::Even => 0,
        Parity::Odd => 1,
    }
}

fn space_name(s: Space) -> &'static str {
    match s {
        Space::Global => "global",
        Space::Shared => "shared",
        Space::Tensor => "tmem",
    }
}

fn footprint(f: Footprint) -> String {
    match f {
        Footprint::Bytes { addr, width } => format!("[{addr:#x}, +{width})"),
        Footprint::Tensor {
            lane,
            lanes,
            col,
            cols,
        } => format!("lanes [{lane}, +{lanes}) × cols [{col}, +{cols})"),
    }
}

fn stored_value(arena: &ExprArena, value: StoredValue) -> String {
    let render = |e| arena.display_expr_prefix(e, MAX_VALUE_BYTES);
    match value {
        StoredValue::Scalar(e) => render(e),
        StoredValue::Pair(lo, hi) => format!("({}, {})", render(lo), render(hi)),
        StoredValue::Quad(lanes) => {
            let lanes: Vec<String> = lanes.into_iter().map(render).collect();
            format!("({})", lanes.join(", "))
        }
        StoredValue::Opaque => "opaque".to_string(),
    }
}

// =========================================================================
// Terminal state, checks and conclusion
// =========================================================================

fn terminal_name(terminal: &Terminal) -> &'static str {
    match terminal {
        Terminal::Completed => "completed",
        Terminal::Stuck { .. } => "stuck",
        Terminal::Aborted { .. } => "aborted",
    }
}

/// A thread's last event: where a stuck or aborted thread stopped.
fn last_event(graph: &EventGraph, thread: ThreadIx) -> Vec<Json> {
    graph
        .program_order(thread)
        .last()
        .map(|e| Json::uint(e.0))
        .into_iter()
        .collect()
}

fn terminal(graph: &EventGraph) -> Json {
    let mut fields = vec![("kind", Json::str(terminal_name(graph.terminal())))];
    let notes: Vec<Json> = match graph.terminal() {
        Terminal::Completed => Vec::new(),
        Terminal::Stuck { blocked } => blocked
            .iter()
            .map(|b| {
                let on = match &b.on {
                    BlockedOn::Barrier { generation } => {
                        format!("waits in {}", generation_name(graph, *generation))
                    }
                    BlockedOn::Collective {
                        generation,
                        missing,
                    } => {
                        let missing: Vec<String> =
                            missing.iter().map(|t| format!("t{}", t.0)).collect();
                        format!(
                            "waits in {} for {}",
                            generation_name(graph, *generation),
                            missing.join(", ")
                        )
                    }
                    BlockedOn::Mbarrier {
                        object,
                        parity,
                        state,
                    } => format!(
                        "waits for {} parity {} ({} phases completed, {}/{} arrived, {} tx \
                         pending)",
                        object_name(graph, *object),
                        parity_bit(*parity),
                        state.completed_phases,
                        state.arrived,
                        state.expected,
                        state.pending_tx
                    ),
                };
                finding(
                    format!("t{} at pc {} {on}", b.thread.0, b.pc.0),
                    last_event(graph, b.thread),
                )
            })
            .collect(),
        Terminal::Aborted { thread, pc, reason } => {
            let at = match (thread, pc) {
                (Some(t), Some(pc)) => format!("t{} at pc {}: ", t.0, pc.0),
                (Some(t), None) => format!("t{}: ", t.0),
                (None, _) => String::new(),
            };
            let events = thread.map_or(Vec::new(), |t| last_event(graph, t));
            vec![finding(format!("{at}{reason}"), events)]
        }
    };
    fields.push(("notes", Json::Arr(notes)));
    Json::Obj(fields)
}

fn finding(text: String, events: Vec<Json>) -> Json {
    Json::Obj(vec![
        ("text", Json::Str(text)),
        ("events", Json::Arr(events)),
    ])
}

fn event_list(events: &[EventId]) -> Vec<Json> {
    events.iter().map(|e| Json::uint(e.0)).collect()
}

/// A check's findings: each violation (`Fail`) or unresolved obligation (`Unknown`), with the
/// events it concerns.
fn findings<E, V>(
    result: &PropertyResult<E, V>,
    violation: impl Fn(&V) -> (String, Vec<EventId>),
) -> Vec<Json> {
    match result {
        PropertyResult::Pass(_) => Vec::new(),
        PropertyResult::Fail(violations) => violations
            .iter()
            .map(|v| {
                let (text, events) = violation(v);
                finding(text, event_list(&events))
            })
            .collect(),
        PropertyResult::Unknown(unresolved) => unresolved
            .iter()
            .map(|u| finding(u.reason.clone(), event_list(&u.events)))
            .collect(),
    }
}

fn epoch_violation(graph: &EventGraph, v: &EpochViolation) -> (String, Vec<EventId>) {
    let mut events = vec![v.synchronization, v.operation];
    events.extend(v.predecessor);
    (
        format!(
            "e{} of {} is not separated from synchronization e{} of {}",
            v.operation.0,
            generation_name(graph, v.next),
            v.synchronization.0,
            generation_name(graph, v.generation)
        ),
        events,
    )
}

fn conflict_kind(kind: ConflictKind) -> &'static str {
    match kind {
        ConflictKind::WriteRead => "write → read",
        ConflictKind::WriteWrite => "write → write",
        ConflictKind::ReadWrite => "read → write",
    }
}

fn lifetime_violation(v: &LifetimeViolation) -> (String, Vec<EventId>) {
    match v {
        LifetimeViolation::DoubleFree { alloc, deallocs } => {
            let mut events = vec![*alloc];
            events.extend(deallocs);
            (
                format!("allocation e{} is freed {} times", alloc.0, deallocs.len()),
                events,
            )
        }
        LifetimeViolation::NeverDeallocated { alloc } => (
            format!("allocation e{} is never freed", alloc.0),
            vec![*alloc],
        ),
        LifetimeViolation::UnmatchedDeallocation { dealloc } => (
            format!("e{} frees columns no allocation provides", dealloc.0),
            vec![*dealloc],
        ),
        LifetimeViolation::Uncovered { effect, alloc } => {
            let mut events = vec![*effect];
            events.extend(alloc);
            (
                format!("no allocation covers the footprint of e{}", effect.0),
                events,
            )
        }
        LifetimeViolation::UseNotBeforeDeallocation {
            effect,
            alloc,
            dealloc,
        } => (
            format!(
                "use e{} is not ordered before the deallocation e{}",
                effect.0, dealloc.0
            ),
            vec![*alloc, *effect, *dealloc],
        ),
        LifetimeViolation::AllocationNotBeforeUse { effect, alloc } => (
            format!(
                "allocation e{} is not ordered before the use e{}",
                alloc.0, effect.0
            ),
            vec![*alloc, *effect],
        ),
    }
}

fn checks(graph: &EventGraph, report: &GraphReport) -> Json {
    Json::Arr(
        Property::ALL
            .iter()
            .map(|&property| {
                let summary = report.summary(property);
                let findings = match property {
                    Property::NamedBarrierEpoch => {
                        findings(&report.named_barrier_epoch, |v| epoch_violation(graph, v))
                    }
                    Property::MbarrierEpoch => {
                        findings(&report.mbarrier_epoch, |v| epoch_violation(graph, v))
                    }
                    Property::MemoryConflict => findings(&report.memory_conflict, |c| {
                        (
                            format!(
                                "{} conflict at {} {:#x}: e{} and e{} are unordered",
                                conflict_kind(c.kind),
                                space_name(c.location.space),
                                c.location.addr,
                                c.earlier.0,
                                c.later.0
                            ),
                            vec![c.earlier, c.later],
                        )
                    }),
                    Property::ProxyOrder => findings(&report.proxy_order, |never| match *never {}),
                    Property::TensorOrder => findings(&report.tensor_order, |c| {
                        (
                            format!(
                                "{} conflict at tmem lane {}, column {}: e{} and e{} are \
                                 unordered",
                                conflict_kind(c.kind),
                                c.cell.lane,
                                c.cell.col,
                                c.earlier.0,
                                c.later.0
                            ),
                            vec![c.earlier, c.later],
                        )
                    }),
                    Property::ResourceLifetime => {
                        findings(&report.resource_lifetime, lifetime_violation)
                    }
                };
                Json::Obj(vec![
                    ("name", Json::str(property.name())),
                    ("algorithm", Json::str(property.algorithm())),
                    (
                        "verdict",
                        Json::str(match summary.verdict {
                            Verdict::Pass => "pass",
                            Verdict::Fail => "fail",
                            Verdict::Unknown => "unknown",
                        }),
                    ),
                    ("evidence", Json::opt(summary.evidence, Json::Str)),
                    ("findings", Json::Arr(findings)),
                ])
            })
            .collect(),
    )
}

fn conclusion(report: &GraphReport) -> Json {
    let (status, reasons) = match report.conclusion() {
        GraphConclusion::Verified => (Status::Verified, Vec::new()),
        GraphConclusion::Rejected { failed, deadlock } => {
            let mut reasons: Vec<String> = failed
                .iter()
                .map(|s| format!("{} failed", s.property.name()))
                .collect();
            if let Some(d) = deadlock {
                reasons.push(format!("deadlock: {} thread(s) blocked", d.blocked.len()));
            }
            (Status::Rejected, reasons)
        }
        GraphConclusion::Unknown { reasons } => (Status::Unknown, reasons),
    };
    Json::Obj(vec![
        ("status", Json::str(status.name())),
        (
            "reasons",
            Json::Arr(reasons.into_iter().map(Json::Str).collect()),
        ),
    ])
}

#[cfg(test)]
mod tests {
    use super::LineIndex;

    #[test]
    fn offsets_map_to_one_based_lines() {
        let lines = LineIndex::new("ab\ncd\n\nef");
        assert_eq!(lines.line(0), Some(1));
        assert_eq!(lines.line(2), Some(1));
        assert_eq!(lines.line(3), Some(2));
        assert_eq!(lines.line(6), Some(3));
        assert_eq!(lines.line(7), Some(4));
        assert_eq!(lines.line(10), None);
    }
}
