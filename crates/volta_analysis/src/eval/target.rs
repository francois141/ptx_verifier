//! Target-arch-derived analysis features - a fact about the module being
//! analyzed (its `.target` directive), not user launch config (kept
//! separate from `eval::config::AnalysisConfig` on purpose - see
//! `TargetFeatures::from_target`'s doc comment).

use volta_frontend::ast::{Arch, Target};

/// Analysis behavior gated by the module's declared target architecture.
/// The first (and so far only) feature: whether a missing
/// `fence.proxy.async` between an async-proxy write (`cp.async`, TMA) and a
/// later access to the same bytes is a reportable hazard.
#[derive(Debug, Clone, Copy)]
pub struct TargetFeatures {
    /// Only sm_90+ has an "async proxy" at all - `fence.proxy.async` isn't
    /// even a legal instruction below sm_90 (PTX ISA target notes), and
    /// pre-Hopper `cp.async` writes shared memory through the same path
    /// generic loads read from, so there is no proxy-ordering gap to close
    /// there. A kernel lacking this fence on sm_89-or-earlier is not a bug
    /// and must never be flagged - confirmed against the real corpus (see
    /// `RaceTracker`'s module doc comment).
    pub async_proxy_fence: bool,
}

impl TargetFeatures {
    /// Derives features from a module's `.target` directive. Uses `.any()`,
    /// not `.all()`: a multi-arch module that *could* run on Hopper+ gets
    /// the stricter check even if it also lists an older arch - the same
    /// PTX must be valid on every listed target, so a hazard that's only
    /// real on one of them is still real.
    pub fn from_target(target: &Target) -> Self {
        Self {
            async_proxy_fence: target.archs.iter().any(|a| *a >= Arch::Sm90),
        }
    }
}
