//! The result shape every graph property checker returns.

use volta_graph::EventId;

/// The three verdicts a property can have.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Verdict {
    Pass,
    Fail,
    Unknown,
}

/// An obligation a checker could not discharge, and why.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Unresolved {
    /// The event the obligation concerns, when there is one.
    pub event: Option<EventId>,
    pub reason: String,
}

impl Unresolved {
    pub fn at(event: EventId, reason: impl Into<String>) -> Self {
        Unresolved {
            event: Some(event),
            reason: reason.into(),
        }
    }

    pub fn global(reason: impl Into<String>) -> Self {
        Unresolved {
            event: None,
            reason: reason.into(),
        }
    }
}

/// One property's outcome. `Pass` carries what was established (a vacuous pass only when the
/// checker found no applicable obligation); `Fail` carries every violation found, earliest in
/// trace order first; `Unknown` lists every unresolved obligation. A checker never turns a
/// missing prerequisite or an unsupported case into `Pass`.
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

/// The graph properties, each checked by its own module.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Property {
    WellFormed,
    BarrierProtocol,
    AsyncCompletion,
    PipelineOrder,
    ProxyOrder,
    MemoryConflicts,
    ResourceLifetime,
    Progress,
}

impl Property {
    pub const ALL: [Property; 8] = [
        Property::WellFormed,
        Property::BarrierProtocol,
        Property::AsyncCompletion,
        Property::PipelineOrder,
        Property::ProxyOrder,
        Property::MemoryConflicts,
        Property::ResourceLifetime,
        Property::Progress,
    ];

    /// The properties whose certificates this property's checker consumes; [`Self::ALL`]
    /// lists every property after its prerequisites.
    pub fn prerequisites(self) -> &'static [Property] {
        use Property::*;
        match self {
            WellFormed => &[],
            BarrierProtocol | PipelineOrder => &[WellFormed],
            AsyncCompletion => &[WellFormed, BarrierProtocol],
            ProxyOrder | ResourceLifetime | Progress => {
                &[WellFormed, BarrierProtocol, AsyncCompletion]
            }
            MemoryConflicts => &[
                WellFormed,
                BarrierProtocol,
                AsyncCompletion,
                PipelineOrder,
                ProxyOrder,
            ],
        }
    }

    pub fn name(self) -> &'static str {
        match self {
            Property::WellFormed => "graph well-formedness",
            Property::BarrierProtocol => "barrier protocol and generation stability",
            Property::AsyncCompletion => "async completion and wait associations",
            Property::PipelineOrder => "async pipeline ordering",
            Property::ProxyOrder => "cross-proxy ordering",
            Property::MemoryConflicts => "memory-conflict freedom",
            Property::ResourceLifetime => "resource lifetime",
            Property::Progress => "progress",
        }
    }
}
