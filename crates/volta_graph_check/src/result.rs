//! The result shape every graph check returns, and the six checks themselves.

use volta_graph::EventId;

/// The three verdicts a check can have.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Verdict {
    Pass,
    Fail,
    Unknown,
}

impl Verdict {
    pub fn name(self) -> &'static str {
        match self {
            Verdict::Pass => "PASS",
            Verdict::Fail => "FAIL",
            Verdict::Unknown => "UNKNOWN",
        }
    }
}

/// An obligation a check could not discharge, and why.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Unresolved {
    /// The events the obligation concerns, in trace order; empty when it concerns the graph.
    pub events: Vec<EventId>,
    pub reason: String,
}

impl Unresolved {
    pub fn at(event: EventId, reason: impl Into<String>) -> Self {
        Unresolved {
            events: vec![event],
            reason: reason.into(),
        }
    }

    pub fn between(earlier: EventId, later: EventId, reason: impl Into<String>) -> Self {
        Unresolved {
            events: vec![earlier, later],
            reason: reason.into(),
        }
    }

    pub fn global(reason: impl Into<String>) -> Self {
        Unresolved {
            events: Vec::new(),
            reason: reason.into(),
        }
    }
}

/// One check's outcome. `Pass` carries what was established (a vacuous pass only when the
/// check found no applicable obligation); `Fail` carries the violations its algorithm returns;
/// `Unknown` lists every unresolved obligation. A check never turns a missing prerequisite or
/// an unsupported case into `Pass`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PropertyResult<E, V> {
    Pass(E),
    Fail(Vec<V>),
    Unknown(Vec<Unresolved>),
}

impl<E, V> PropertyResult<E, V> {
    pub fn verdict(&self) -> Verdict {
        match self {
            PropertyResult::Pass(_) => Verdict::Pass,
            PropertyResult::Fail(_) => Verdict::Fail,
            PropertyResult::Unknown(_) => Verdict::Unknown,
        }
    }

    pub fn violations(&self) -> &[V] {
        match self {
            PropertyResult::Fail(v) => v,
            _ => &[],
        }
    }

    pub fn unresolved(&self) -> &[Unresolved] {
        match self {
            PropertyResult::Unknown(u) => u,
            _ => &[],
        }
    }

    /// `Fail` if any violation, else `Unknown` if any unresolved obligation, else `Pass`.
    pub fn from_findings(evidence: E, violations: Vec<V>, unresolved: Vec<Unresolved>) -> Self {
        if !violations.is_empty() {
            PropertyResult::Fail(violations)
        } else if !unresolved.is_empty() {
            PropertyResult::Unknown(unresolved)
        } else {
            PropertyResult::Pass(evidence)
        }
    }
}

/// The six checks of the Volta v2 design (§1.3), in the design's order.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Property {
    /// Algorithm 1 over named barriers (`bar.arrive`, `bar.sync`).
    NamedBarrierEpoch,
    /// Algorithm 1 over mbarrier phases.
    MbarrierEpoch,
    /// Algorithm 2.
    MemoryConflict,
    /// Algorithm 3.
    ProxyOrder,
    /// Algorithm 4, with Algorithm 5's synchronization search.
    TensorOrder,
    /// Algorithm 6.
    ResourceLifetime,
}

impl Property {
    pub const ALL: [Property; 6] = [
        Property::NamedBarrierEpoch,
        Property::MbarrierEpoch,
        Property::MemoryConflict,
        Property::ProxyOrder,
        Property::TensorOrder,
        Property::ResourceLifetime,
    ];

    /// The checks that must pass before this one can run: both barrier-epoch checks validate
    /// the candidate joins `G_HB` and `D` contain, and Algorithm 3 requires Algorithm 2's
    /// pass. [`Self::ALL`] lists every check after its prerequisites.
    pub fn prerequisites(self) -> &'static [Property] {
        use Property::*;
        match self {
            NamedBarrierEpoch | MbarrierEpoch => &[],
            MemoryConflict | TensorOrder | ResourceLifetime => &[NamedBarrierEpoch, MbarrierEpoch],
            ProxyOrder => &[NamedBarrierEpoch, MbarrierEpoch, MemoryConflict],
        }
    }

    pub fn name(self) -> &'static str {
        match self {
            Property::NamedBarrierEpoch => "barrier epochs (named barriers)",
            Property::MbarrierEpoch => "barrier epochs (mbarrier phases)",
            Property::MemoryConflict => "memory-conflict freedom",
            Property::ProxyOrder => "proxy ordering",
            Property::TensorOrder => "tensor-operation ordering",
            Property::ResourceLifetime => "resource lifetime",
        }
    }

    /// The algorithm of the design that implements the check.
    pub fn algorithm(self) -> &'static str {
        match self {
            Property::NamedBarrierEpoch | Property::MbarrierEpoch => "Algorithm 1",
            Property::MemoryConflict => "Algorithm 2",
            Property::ProxyOrder => "Algorithm 3",
            Property::TensorOrder => "Algorithms 4 and 5",
            Property::ResourceLifetime => "Algorithm 6",
        }
    }
}
