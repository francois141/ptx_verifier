//! A deterministic text dump of an [`EventGraph`] (`volta-graph 1`): everything is printed in
//! id order, so two equal graphs dump byte-identically and diffs show trace changes.

use std::fmt::{self, Write};

use id_collections::Id;

use crate::graph::EventGraph;
use crate::model::{
    AbortCause, AccessMode, ArrivalOrdering, AsyncOpKind, BarrierArrivals, BlockedOn,
    CollectiveSide, ContributionKind, EventKind, ExecContext, FenceKind, Footprint, GenerationKind,
    GroupFamily, MemberOrdering, OrderingKind, Parity, Proxy, Space, StoredValue, SyncObjectKind,
    Terminal,
};

impl EventGraph {
    /// Write the dump to `out`.
    pub fn write_dump(&self, out: &mut impl Write) -> fmt::Result {
        let p = &self.provenance;
        writeln!(out, "volta-graph 1")?;
        writeln!(
            out,
            "kernel {:?} block {},{},{} grid {},{},{} targets {}",
            p.kernel,
            p.block_dim.0,
            p.block_dim.1,
            p.block_dim.2,
            p.grid_dim.0,
            p.grid_dim.1,
            p.grid_dim.2,
            p.targets.join(",")
        )?;
        for a in &p.assumptions {
            writeln!(out, "assume {:?}", a)?;
        }
        for (o, obj) in self.objects.iter() {
            write!(out, "object o{} ", o.0)?;
            match &obj.kind {
                SyncObjectKind::NamedBarrier { id } => write!(out, "named-barrier {}", id)?,
                SyncObjectKind::Mbarrier {
                    addr,
                    expected_arrivals,
                } => write!(out, "mbarrier {:#x} expected={}", addr, expected_arrivals)?,
                SyncObjectKind::WarpCollective { warp } => write!(out, "warp {}", warp)?,
                SyncObjectKind::WarpgroupCollective { warpgroup } => {
                    write!(out, "warpgroup {}", warpgroup)?
                }
                SyncObjectKind::AsyncGroupWait { thread } => {
                    write!(out, "cp-async-groups t{}", thread.0)?
                }
            }
            writeln!(
                out,
                " init={} inval={}",
                opt_event(obj.init),
                opt_event(obj.inval)
            )?;
        }
        for (g, genr) in self.generations.iter() {
            write!(
                out,
                "generation g{} o{}#{} ",
                g.0, genr.object.0, genr.index
            )?;
            match genr.kind {
                GenerationKind::Barrier { arrivals } => match arrivals {
                    BarrierArrivals::FullCta => write!(out, "barrier full-cta")?,
                    BarrierArrivals::Count(n) => write!(out, "barrier count={}", n)?,
                },
                GenerationKind::MbarrierPhase => {
                    write!(out, "phase parity={}", parity(Parity::of_phase(genr.index)))?
                }
                GenerationKind::MbarrierPreInit => {
                    write!(out, "pre-init parity={}", parity(Parity::Odd))?
                }
                GenerationKind::Collective {
                    pc,
                    mask,
                    side,
                    ordering,
                } => write!(
                    out,
                    "collective pc{} mask={:#010x} {} {}",
                    pc.0,
                    mask,
                    match side {
                        CollectiveSide::Entry => "entry",
                        CollectiveSide::Exit => "exit",
                    },
                    match ordering {
                        MemberOrdering::Synchronizing => "synchronizing",
                        MemberOrdering::ExecutionOnly => "execution-only",
                    }
                )?,
                GenerationKind::AsyncGroupWait { keep_pending } => {
                    write!(out, "wait-group keep={}", keep_pending)?
                }
            }
            writeln!(
                out,
                " complete={} surplus={} pending_tx={}",
                opt_event(genr.completion),
                genr.evidence.surplus_arrivals,
                genr.evidence.pending_tx
            )?;
            for c in &genr.contributions {
                write!(out, "  contrib e{} ", c.event.0)?;
                match c.kind {
                    ContributionKind::Blocking => writeln!(out, "blocking")?,
                    ContributionKind::Arrival {
                        count,
                        expect_tx,
                        ordering,
                    } => writeln!(
                        out,
                        "arrive count={} expect_tx={} {}",
                        count,
                        expect_tx,
                        match ordering {
                            ArrivalOrdering::Release => "release",
                            ArrivalOrdering::AsyncTracked => "async-tracked",
                        }
                    )?,
                    ContributionKind::Exited => writeln!(out, "exited")?,
                    ContributionKind::AsyncCompletion { op, tx_bytes } => {
                        writeln!(out, "async-completion a{} tx={}", op.0, tx_bytes)?
                    }
                    ContributionKind::CompleteTx { bytes } => {
                        writeln!(out, "complete-tx {}", bytes)?
                    }
                    ContributionKind::ExpectTx { bytes } => writeln!(out, "expect-tx {}", bytes)?,
                }
            }
            if !genr.releases.is_empty() {
                write!(out, "  release")?;
                for r in &genr.releases {
                    write!(out, " e{}", r.0)?;
                }
                writeln!(out)?;
            }
        }
        for (op, a) in self.async_ops.iter() {
            let kind = match a.kind {
                AsyncOpKind::CpAsync => "cp-async".to_string(),
                AsyncOpKind::BulkCopy => "bulk-copy".to_string(),
                AsyncOpKind::TensorCopy => "tensor-copy".to_string(),
                AsyncOpKind::ClcResponse => "clc-response".to_string(),
                AsyncOpKind::Tcgen05Mma => "tcgen05-mma".to_string(),
                AsyncOpKind::Tcgen05Ld => "tcgen05-ld".to_string(),
                AsyncOpKind::Tcgen05St => "tcgen05-st".to_string(),
                AsyncOpKind::WgmmaMma { instance } => format!("wgmma#{}", instance),
            };
            write!(
                out,
                "op a{} {} issuer=t{} pc{} issue=e{} complete={} tracking=",
                op.0,
                kind,
                a.issuer.0,
                a.pc.0,
                a.issue.0,
                opt_event(a.completion)
            )?;
            let tracking: Vec<String> = a.tracking.iter().map(|g| format!("g{}", g.0)).collect();
            writeln!(out, "[{}] effects={}", tracking.join(","), a.effects.len())?;
        }
        for (id, ev) in self.events.iter() {
            write!(out, "e{} ", id.0)?;
            match ev.ctx {
                ExecContext::Thread(t) => write!(out, "t{}", t.0)?,
                ExecContext::Async(op) => write!(out, "a{}", op.0)?,
                ExecContext::Generation(g) => write!(out, "g{}", g.0)?,
            }
            match ev.pc {
                Some(pc) => write!(out, " pc{} ", pc.0)?,
                None => write!(out, " - ")?,
            }
            match ev.kind {
                EventKind::Access(acc) => {
                    let a = &self.accesses[acc];
                    write!(
                        out,
                        "{} {} {} {} {:?} by t{} ",
                        match a.mode {
                            AccessMode::Read => "read",
                            AccessMode::Write => "write",
                        },
                        match a.ordering {
                            OrderingKind::Ordinary => "ordinary",
                            OrderingKind::Atomic => "atomic",
                            OrderingKind::Reduction => "reduction",
                        },
                        match a.proxy {
                            Proxy::Generic => "generic",
                            Proxy::Async => "async",
                            Proxy::TensorMap => "tensormap",
                        },
                        space(a.space),
                        a.role,
                        a.attributed.0
                    )?;
                    match a.footprint {
                        Footprint::Bytes { addr, width } => {
                            write!(out, "[{:#x},+{})", addr, width)?
                        }
                        Footprint::Tensor {
                            lane,
                            lanes,
                            col,
                            cols,
                        } => write!(out, "lanes[{},+{}) cols[{},+{})", lane, lanes, col, cols)?,
                    }
                    if let Some(v) = a.value {
                        match self.values[v] {
                            StoredValue::Scalar(e) => write!(out, " = n{}", e.to_index())?,
                            StoredValue::Pair(lo, hi) => {
                                write!(out, " = (n{}, n{})", lo.to_index(), hi.to_index())?
                            }
                            StoredValue::Quad(lanes) => write!(
                                out,
                                " = (n{}, n{}, n{}, n{})",
                                lanes[0].to_index(),
                                lanes[1].to_index(),
                                lanes[2].to_index(),
                                lanes[3].to_index()
                            )?,
                            StoredValue::Opaque => write!(out, " = opaque")?,
                        }
                    }
                    writeln!(out)?;
                }
                EventKind::Contribute(g) => writeln!(out, "contribute g{}", g.0)?,
                EventKind::WaitStart { object, parity: p } => {
                    writeln!(out, "wait-start o{} parity={}", object.0, parity(p))?
                }
                EventKind::Resume(g) => writeln!(out, "resume g{}", g.0)?,
                EventKind::GenerationComplete(g) => writeln!(out, "complete g{}", g.0)?,
                EventKind::AsyncIssue(op) => writeln!(out, "issue a{}", op.0)?,
                EventKind::AsyncComplete(op) => writeln!(out, "async-complete a{}", op.0)?,
                EventKind::GroupCommit(GroupFamily::CpAsync) => {
                    writeln!(out, "commit-group cp.async")?
                }
                EventKind::GroupCommit(GroupFamily::Wgmma) => writeln!(out, "commit-group wgmma")?,
                EventKind::Fence(FenceKind::ProxyAsync { space: s }) => match s {
                    Some(s) => writeln!(out, "fence proxy.async {}", space(s))?,
                    None => writeln!(out, "fence proxy.async")?,
                },
                EventKind::Fence(FenceKind::Tcgen05BeforeThreadSync) => {
                    writeln!(out, "fence tcgen05::before_thread_sync")?
                }
                EventKind::Fence(FenceKind::TensormapRelease) => {
                    writeln!(out, "fence proxy.tensormap release")?
                }
                EventKind::Fence(FenceKind::TensormapAcquire { addr }) => {
                    writeln!(out, "fence proxy.tensormap acquire {:#x}", addr)?
                }
                EventKind::Fence(FenceKind::Tcgen05AfterThreadSync) => {
                    writeln!(out, "fence tcgen05::after_thread_sync")?
                }
                EventKind::ObjectInit(o) => writeln!(out, "init o{}", o.0)?,
                EventKind::ObjectInval(o) => writeln!(out, "inval o{}", o.0)?,
                EventKind::TmemAlloc {
                    start_col,
                    num_cols,
                } => writeln!(out, "tmem-alloc cols[{},+{})", start_col, num_cols)?,
                EventKind::TmemDealloc {
                    start_col,
                    num_cols,
                } => writeln!(out, "tmem-dealloc cols[{},+{})", start_col, num_cols)?,
                EventKind::TmemRelinquish => writeln!(out, "tmem-relinquish")?,
                EventKind::Exit => writeln!(out, "exit")?,
            }
        }
        match &self.terminal {
            Terminal::Completed => writeln!(out, "terminal completed")?,
            Terminal::Stuck { blocked } => {
                writeln!(out, "terminal stuck")?;
                for b in blocked {
                    write!(out, "  blocked t{} pc{} ", b.thread.0, b.pc.0)?;
                    match &b.on {
                        BlockedOn::Barrier { generation } => {
                            writeln!(out, "barrier g{}", generation.0)?
                        }
                        BlockedOn::Collective {
                            generation,
                            missing,
                        } => {
                            let missing: Vec<String> =
                                missing.iter().map(|t| format!("t{}", t.0)).collect();
                            writeln!(
                                out,
                                "collective g{} missing [{}]",
                                generation.0,
                                missing.join(",")
                            )?
                        }
                        BlockedOn::Mbarrier {
                            object,
                            parity: p,
                            state,
                        } => writeln!(
                            out,
                            "mbarrier o{} parity={} phases={} arrived={}/{} pending_tx={}",
                            object.0,
                            parity(*p),
                            state.completed_phases,
                            state.arrived,
                            state.expected,
                            state.pending_tx
                        )?,
                    }
                }
            }
            Terminal::Aborted {
                thread,
                pc,
                cause,
                reason,
            } => {
                let cause = match cause {
                    AbortCause::Unsupported => "unsupported",
                    AbortCause::Error => "error",
                };
                write!(out, "terminal aborted {cause}")?;
                if let Some(t) = thread {
                    write!(out, " t{}", t.0)?;
                }
                if let Some(pc) = pc {
                    write!(out, " pc{}", pc.0)?;
                }
                writeln!(out, ": {}", reason)?;
            }
        }
        Ok(())
    }

    /// The dump as a string.
    pub fn dump(&self) -> String {
        let mut text = String::new();
        self.write_dump(&mut text)
            .expect("writing to a String cannot fail");
        text
    }
}

fn opt_event(e: Option<crate::ids::EventId>) -> String {
    match e {
        Some(e) => format!("e{}", e.0),
        None => "-".to_string(),
    }
}

fn parity(p: Parity) -> u8 {
    match p {
        Parity::Even => 0,
        Parity::Odd => 1,
    }
}

fn space(s: Space) -> &'static str {
    match s {
        Space::Global => "global",
        Space::Shared => "shared",
        Space::Tensor => "tensor",
    }
}
