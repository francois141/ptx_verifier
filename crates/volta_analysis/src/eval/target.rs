//! Target-arch-derived analysis features: a fact about the analyzed module's
//! `.target` directive, not user launch config, so deliberately kept out of
//! `eval::config::AnalysisConfig`.

use volta_frontend::ast::{Arch, Target};

/// Analysis behavior gated by the module's declared target architecture, e.g.
/// whether a missing `fence.proxy.async` between a generic-proxy shared write
/// and a later async-proxy read of it (a `tcgen05.mma` operand) is a hazard.
#[derive(Debug, Clone, Copy)]
pub struct TargetFeatures {
    /// Only sm_90+ has an async proxy (`fence.proxy.async` is illegal below
    /// sm_90, and pre-Hopper `cp.async` shares the generic path), so a missing
    /// fence on sm_89-or-earlier is not a bug and must never be flagged.
    pub async_proxy_fence: bool,
}

impl TargetFeatures {
    /// Derives features from a module's `.target` directive. Uses `.any()`:
    /// the same PTX must be valid on every listed arch, so a hazard real on
    /// any one of them (e.g. Hopper+) is still real.
    pub fn from_target(target: &Target) -> Self {
        Self {
            async_proxy_fence: target.archs.iter().any(|a| *a >= Arch::Sm90),
        }
    }
}
