//! Representation invariants of an [`EventGraph`]: structure only, no property of the execution.
//! A graph that validates has every typed edge running forward in trace order, so the relation
//! they generate is acyclic; consumers rely on that only after validating.

use std::collections::HashMap;

use crate::graph::EventGraph;
use crate::ids::{AccessId, EventId, GenerationId, ThreadIx};
use crate::model::{
    AccessMode, ContributionKind, EventKind, ExecContext, Footprint, GenerationKind, Space,
    SyncObjectKind, Terminal,
};

/// One violated representation invariant.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GraphDefect {
    pub event: Option<EventId>,
    pub message: String,
}

struct Defects(Vec<GraphDefect>);

impl Defects {
    fn at(&mut self, event: EventId, message: String) {
        self.0.push(GraphDefect {
            event: Some(event),
            message,
        });
    }

    fn global(&mut self, message: String) {
        self.0.push(GraphDefect {
            event: None,
            message,
        });
    }
}

impl EventGraph {
    /// Check every representation invariant; `Err` lists all violations found.
    pub fn validate(&self) -> Result<(), Vec<GraphDefect>> {
        let mut d = Defects(Vec::new());
        self.validate_contexts(&mut d);
        let access_events = self.validate_accesses(&mut d);
        self.validate_program_order(&mut d);
        self.validate_async_ops(&access_events, &mut d);
        self.validate_generations(&mut d);
        self.validate_objects(&mut d);
        self.validate_terminal(&mut d);
        if d.0.is_empty() { Ok(()) } else { Err(d.0) }
    }

    fn validate_contexts(&self, d: &mut Defects) {
        let threads = self.threads();
        for (id, ev) in self.events.iter() {
            match ev.ctx {
                ExecContext::Thread(t) if t.0 >= threads => d.at(
                    id,
                    format!("thread {} is outside the CTA's {} threads", t.0, threads),
                ),
                ExecContext::Thread(_) => {
                    if matches!(
                        ev.kind,
                        EventKind::GenerationComplete(_) | EventKind::AsyncComplete(_)
                    ) {
                        d.at(id, "a completion event in a thread context".to_string());
                    }
                }
                ExecContext::Async(op) => {
                    if op.0 as usize >= self.async_ops.len() {
                        d.at(id, format!("unknown async op {}", op.0));
                    } else if !matches!(ev.kind, EventKind::Access(_) | EventKind::AsyncComplete(_))
                    {
                        d.at(id, "an async context holds a non-effect event".to_string());
                    }
                }
                ExecContext::Generation(g) => {
                    if ev.kind != EventKind::GenerationComplete(g) {
                        d.at(id, "a generation context holds another event".to_string());
                    }
                }
            }
            if ev
                .pc
                .is_some_and(|pc| pc.0 as usize >= self.provenance.instructions.len())
            {
                d.at(
                    id,
                    "program point outside the provenance's instruction table".to_string(),
                );
            }
        }
    }

    /// Checks every access and returns access -> the one event holding it.
    fn validate_accesses(&self, d: &mut Defects) -> HashMap<AccessId, EventId> {
        let mut holder: HashMap<AccessId, EventId> = HashMap::new();
        for (id, ev) in self.events.iter() {
            let EventKind::Access(a) = ev.kind else {
                continue;
            };
            if a.0 as usize >= self.accesses.len() {
                d.at(id, format!("unknown access {}", a.0));
                continue;
            }
            if holder.insert(a, id).is_some() {
                d.at(id, format!("access {} is held by two events", a.0));
            }
            let acc = &self.accesses[a];
            if let ExecContext::Thread(t) = ev.ctx
                && acc.attributed != t
            {
                d.at(
                    id,
                    "a synchronous access attributed to another thread".to_string(),
                );
            }
            if acc.attributed.0 >= self.threads() {
                d.at(id, "access attributed outside the CTA".to_string());
            }
            match (acc.mode, acc.value) {
                (AccessMode::Write, None) => d.at(id, "a write without a stored value".to_string()),
                (AccessMode::Read, Some(_)) => d.at(id, "a read with a stored value".to_string()),
                (_, Some(v)) if v.0 as usize >= self.values.len() => {
                    d.at(id, "unknown stored value".to_string())
                }
                _ => {}
            }
            let shape_ok = match acc.footprint {
                Footprint::Bytes { addr, width } => {
                    acc.space != Space::Tensor
                        && width > 0
                        && u128::from(addr) + u128::from(width) <= u128::from(u64::MAX) + 1
                }
                Footprint::Tensor {
                    lane,
                    lanes,
                    col: _,
                    cols,
                } => {
                    acc.space == Space::Tensor
                        && lanes > 0
                        && cols > 0
                        && u32::from(lane) + u32::from(lanes) <= 128
                }
            };
            if !shape_ok {
                d.at(
                    id,
                    format!("malformed footprint {:?} in {:?}", acc.footprint, acc.space),
                );
            }
        }
        for a in self.accesses.count() {
            if !holder.contains_key(&a) {
                d.global(format!("access {} belongs to no event", a.0));
            }
        }
        holder
    }

    fn validate_program_order(&self, d: &mut Defects) {
        let mut expected: Vec<Vec<EventId>> = vec![Vec::new(); self.threads() as usize];
        for (id, ev) in self.events.iter() {
            if let ExecContext::Thread(t) = ev.ctx
                && t.0 < self.threads()
            {
                expected[t.0 as usize].push(id);
            }
        }
        for (t, order) in self.program_order.iter() {
            if order.as_slice() != expected[t.0 as usize].as_slice() {
                d.global(format!(
                    "thread {} program-order index disagrees with its events",
                    t.0
                ));
            }
            if let Some(exit) = order
                .iter()
                .position(|&e| self.events[e].kind == EventKind::Exit)
                && exit + 1 != order.len()
            {
                d.at(
                    order[exit + 1],
                    format!("thread {} has an event after its exit", t.0),
                );
            }
        }
    }

    fn validate_async_ops(&self, access_events: &HashMap<AccessId, EventId>, d: &mut Defects) {
        for (op, a) in self.async_ops.iter() {
            let issue = &self.events[a.issue];
            if issue.ctx != ExecContext::Thread(a.issuer) || issue.kind != EventKind::AsyncIssue(op)
            {
                d.at(
                    a.issue,
                    format!(
                        "async op {} issue event is not its issuer's AsyncIssue",
                        op.0
                    ),
                );
            }
            for &effect in &a.effects {
                match access_events.get(&effect) {
                    Some(&ev) if self.events[ev].ctx == ExecContext::Async(op) && ev > a.issue => {}
                    Some(&ev) => d.at(
                        ev,
                        format!(
                            "effect of op {} outside its context or before its issue",
                            op.0
                        ),
                    ),
                    None => d.global(format!("effect {} of op {} has no event", effect.0, op.0)),
                }
            }
            if let Some(done) = a.completion {
                let ev = &self.events[done];
                if ev.ctx != ExecContext::Async(op) || ev.kind != EventKind::AsyncComplete(op) {
                    d.at(
                        done,
                        format!("completion of op {} is not its AsyncComplete", op.0),
                    );
                }
                if done <= a.issue {
                    d.at(done, format!("op {} completes before it is issued", op.0));
                }
            }
            for &g in &a.tracking {
                let listed = self.generations.get(g).is_some_and(|genr| {
                    genr.contributions.iter().any(|c| {
                        Some(c.event) == a.completion
                            && matches!(c.kind, ContributionKind::AsyncCompletion { op: o, .. } if o == op)
                    })
                });
                if !listed {
                    d.global(format!(
                        "op {} tracks generation {} that does not list it",
                        op.0, g.0
                    ));
                }
            }
        }
        for (id, ev) in self.events.iter() {
            if let EventKind::Access(acc) = ev.kind
                && let ExecContext::Async(op) = ev.ctx
                && (op.0 as usize) < self.async_ops.len()
                && !self.async_ops[op].effects.contains(&acc)
            {
                d.at(
                    id,
                    format!("access in op {}'s context is not one of its effects", op.0),
                );
            }
        }
    }

    fn validate_generations(&self, d: &mut Defects) {
        let mut contribute_events: HashMap<EventId, GenerationId> = HashMap::new();
        let mut resume_events: HashMap<EventId, GenerationId> = HashMap::new();
        for (id, ev) in self.events.iter() {
            match ev.kind {
                EventKind::Contribute(g) => {
                    contribute_events.insert(id, g);
                }
                EventKind::Resume(g) => {
                    resume_events.insert(id, g);
                }
                _ => {}
            }
        }
        let mut seen_index: HashMap<
            (
                crate::ids::SyncObjectId,
                u32,
                Option<crate::model::CollectiveSide>,
            ),
            GenerationId,
        > = HashMap::new();
        for (g, genr) in self.generations.iter() {
            if genr.object.0 as usize >= self.objects.len() {
                d.global(format!("generation {} of an unknown object", g.0));
                continue;
            }
            let object = &self.objects[genr.object].kind;
            let kind_ok = matches!(
                (&genr.kind, object),
                (
                    GenerationKind::Barrier { .. },
                    SyncObjectKind::NamedBarrier { .. }
                ) | (
                    GenerationKind::MbarrierPhase,
                    SyncObjectKind::Mbarrier { .. }
                ) | (
                    GenerationKind::Collective { .. },
                    SyncObjectKind::WarpCollective { .. }
                ) | (
                    GenerationKind::Collective { .. },
                    SyncObjectKind::WarpgroupCollective { .. }
                ) | (
                    GenerationKind::AsyncGroupWait { .. },
                    SyncObjectKind::AsyncGroupWait { .. }
                )
            );
            if !kind_ok {
                d.global(format!(
                    "generation {} kind {:?} does not fit object {:?}",
                    g.0, genr.kind, object
                ));
            }
            let side = match genr.kind {
                GenerationKind::Collective { side, .. } => Some(side),
                _ => None,
            };
            if let Some(other) = seen_index.insert((genr.object, genr.index, side), g) {
                d.global(format!(
                    "generations {} and {} share an index of one object",
                    other.0, g.0
                ));
            }
            for c in &genr.contributions {
                let Some(ev) = self.events.get(c.event) else {
                    d.global(format!(
                        "generation {} contribution names unknown event",
                        g.0
                    ));
                    continue;
                };
                let ok = match c.kind {
                    ContributionKind::Blocking
                    | ContributionKind::Arrival { .. }
                    | ContributionKind::CompleteTx { .. } => {
                        ev.kind == EventKind::Contribute(g)
                            && matches!(ev.ctx, ExecContext::Thread(_))
                    }
                    ContributionKind::Exited => {
                        ev.kind == EventKind::Exit && matches!(ev.ctx, ExecContext::Thread(_))
                    }
                    ContributionKind::AsyncCompletion { op, .. } => {
                        ev.kind == EventKind::AsyncComplete(op)
                            && self
                                .async_ops
                                .get(op)
                                .is_some_and(|a| a.tracking.contains(&g))
                    }
                };
                if !ok {
                    d.at(
                        c.event,
                        format!(
                            "contribution {:?} to generation {} has the wrong event",
                            c.kind, g.0
                        ),
                    );
                }
                if let Some(done) = genr.completion
                    && c.event >= done
                {
                    d.at(
                        c.event,
                        format!("contribution to generation {} after its completion", g.0),
                    );
                }
            }
            match genr.completion {
                Some(done) => {
                    let ev = &self.events[done];
                    if ev.kind != EventKind::GenerationComplete(g) {
                        d.at(
                            done,
                            format!("completion of generation {} is another event", g.0),
                        );
                    }
                }
                None => {
                    if !genr.releases.is_empty() {
                        d.global(format!(
                            "generation {} releases threads but never completed",
                            g.0
                        ));
                    }
                }
            }
            for &r in &genr.releases {
                let ok = self.events.get(r).is_some_and(|ev| {
                    ev.kind == EventKind::Resume(g)
                        && matches!(ev.ctx, ExecContext::Thread(_))
                        && genr.completion.is_some_and(|done| r > done)
                });
                if !ok {
                    d.at(
                        r,
                        format!("release of generation {} is not a later Resume", g.0),
                    );
                }
            }
        }
        for (ev, g) in contribute_events {
            let listed = self.generations.get(g).is_some_and(|genr| {
                genr.contributions.iter().filter(|c| c.event == ev).count() == 1
            });
            if !listed {
                d.at(
                    ev,
                    format!(
                        "Contribute event not listed exactly once by generation {}",
                        g.0
                    ),
                );
            }
        }
        for (ev, g) in resume_events {
            let listed = self
                .generations
                .get(g)
                .is_some_and(|genr| genr.releases.contains(&ev));
            if !listed {
                d.at(ev, format!("Resume event not listed by generation {}", g.0));
            }
        }
    }

    fn validate_objects(&self, d: &mut Defects) {
        for (o, obj) in self.objects.iter() {
            if let Some(init) = obj.init
                && self.events.get(init).map(|e| e.kind) != Some(EventKind::ObjectInit(o))
            {
                d.global(format!("object {} init is not its ObjectInit", o.0));
            }
            if let Some(inval) = obj.inval {
                if self.events.get(inval).map(|e| e.kind) != Some(EventKind::ObjectInval(o)) {
                    d.global(format!("object {} inval is not its ObjectInval", o.0));
                }
                if obj.init.is_none_or(|init| init >= inval) {
                    d.at(
                        inval,
                        format!("object {} invalidated before it was initialized", o.0),
                    );
                }
            }
        }
        for (id, ev) in self.events.iter() {
            if let EventKind::WaitStart { object, .. } = ev.kind
                && !matches!(
                    self.objects.get(object).map(|o| &o.kind),
                    Some(SyncObjectKind::Mbarrier { .. })
                )
            {
                d.at(id, "a wait on something other than an mbarrier".to_string());
            }
        }
    }

    fn validate_terminal(&self, d: &mut Defects) {
        let exited = |t: ThreadIx| {
            self.program_order[t]
                .last()
                .is_some_and(|&e| self.events[e].kind == EventKind::Exit)
        };
        match &self.terminal {
            Terminal::Completed => {
                for t in self.program_order.count() {
                    if !exited(t) {
                        d.global(format!(
                            "execution completed but thread {} never exited",
                            t.0
                        ));
                    }
                }
            }
            Terminal::Stuck { blocked } => {
                let mut listed = vec![0u32; self.threads() as usize];
                for b in blocked {
                    if b.thread.0 >= self.threads() {
                        d.global("a blocked thread outside the CTA".to_string());
                        continue;
                    }
                    listed[b.thread.0 as usize] += 1;
                }
                for t in self.program_order.count() {
                    let n = listed[t.0 as usize];
                    match (exited(t), n) {
                        (true, 0) | (false, 1) => {}
                        (true, _) => d.global(format!("exited thread {} listed as blocked", t.0)),
                        (false, _) => {
                            d.global(format!("live thread {} listed {} times as blocked", t.0, n))
                        }
                    }
                }
            }
            Terminal::Aborted { .. } => {}
        }
    }
}
