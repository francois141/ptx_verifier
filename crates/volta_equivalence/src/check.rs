//! Output equivalence checking: pairs two analysis runs' written elements
//! and decides each pair with the canonicalizer (plus the optional f64 oracle).

use std::fmt;
use std::num::NonZeroUsize;
use std::time::{Duration, Instant};

use volta_expr::{ExprId, SymbolicOutputs};

use crate::equiv::{DEFAULT_RECYCLE_TERMS, EquivError, EquivSession};
use crate::numeric;

/// A single output element where the two kernels disagree.
#[derive(Debug, Clone)]
pub struct Mismatch {
    pub array: String,
    pub index: u64,
}

/// Result of comparing two analysis outputs.
#[derive(Debug)]
pub enum EquivOutcome {
    Equivalent,
    NotEquivalent { mismatches: Vec<Mismatch> },
}

/// Errors from output comparison.
#[derive(Debug)]
pub enum EquivCheckError {
    /// The two outputs have different arrays or element counts.
    ShapeMismatch { message: String },
    /// The underlying symbolic check failed.
    Equiv(EquivError),
    /// The f64 oracle contradicted (or could not confirm) a verdict.
    Numeric { message: String },
    /// A later solve iteration disagreed with iteration 1 on an element's
    /// verdict. The decision procedure is deterministic, so this can only
    /// mean a bug (or memory corruption) - a hard error, never papered over.
    IterationDisagreement { message: String },
}

impl fmt::Display for EquivCheckError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ShapeMismatch { message } => write!(f, "output shape mismatch: {}", message),
            Self::Equiv(e) => write!(f, "equivalence check failed: {}", e),
            Self::Numeric { message } => write!(f, "numeric oracle: {}", message),
            Self::IterationDisagreement { message } => {
                write!(f, "solve iterations disagree: {}", message)
            }
        }
    }
}

impl std::error::Error for EquivCheckError {}

impl From<EquivError> for EquivCheckError {
    fn from(e: EquivError) -> Self {
        Self::Equiv(e)
    }
}

/// Options for [`check_output_equivalence_with`].
#[derive(Debug, Clone)]
pub struct EquivCheckOptions {
    /// Check at most this many common elements per array (0 = all).
    pub sample: u64,
    /// Confirm every verdict with the f64 numeric oracle.
    pub verify_numeric: bool,
    /// Recycle the VC intern tables past this many interned terms
    /// (0 = never); see `EquivSession::with_recycle_terms`.
    pub recycle_terms: usize,
    /// Solve iterations (default 1), each re-solving the same elements from a *fresh* session
    /// (cold-start timings, bounded memory). The verdict is iteration 1's; later ones must agree,
    /// else [`EquivCheckError::IterationDisagreement`]. `verify_numeric` runs on iteration 1 only.
    pub iterations: NonZeroUsize,
}

impl Default for EquivCheckOptions {
    fn default() -> Self {
        Self {
            sample: 0,
            verify_numeric: false,
            recycle_terms: DEFAULT_RECYCLE_TERMS,
            iterations: NonZeroUsize::MIN,
        }
    }
}

/// One checked element's iteration-1 decision-procedure check duration.
#[derive(Debug, Clone)]
pub struct ElementCheckTime {
    pub array: String,
    pub index: u64,
    /// The element's `EquivSession::check` duration in solve iteration 1.
    pub check: Duration,
}

/// The outcome of a comparison plus how much of the footprint it covered.
#[derive(Debug)]
pub struct EquivCheckReport {
    pub outcome: EquivOutcome,
    /// Elements actually compared (less than total when sampling).
    pub elements_checked: u64,
    /// Comparable elements in the reference footprints.
    pub elements_total: u64,
    /// Per-iteration summed `EquivSession::check` time and nothing else (pairing and the oracle
    /// excluded), the figure to put beside another backend's solver time. One entry per
    /// `EquivCheckOptions::iterations`, in order; never empty.
    pub check_iters: Vec<Duration>,
    /// Iteration 1's per-element check durations in `sampled_elements` order: the same
    /// measurements `check_iters[0]` sums, recorded outside the timed spans.
    pub element_checks: Vec<ElementCheckTime>,
    /// Time spent pairing the two footprints (`paired_elements`). Callers
    /// that account "VC generation" as symbolic execution plus pairing
    /// (the bench harness) add this to their execution time.
    pub pair_time: Duration,
    /// Total f64-oracle time (`verify_verdict`, iteration 1 only). `Some` exactly when
    /// `EquivCheckOptions::verify_numeric` was set (`None` = oracle off, not free); kept out of
    /// `check_iters` so solve timings don't move when the oracle is toggled.
    pub verify_time: Option<Duration>,
}

impl EquivCheckReport {
    /// Iteration 1's decision-procedure time - the verdict-producing run,
    /// and the historical meaning of this report's single timing field.
    pub fn check_time(&self) -> Duration {
        self.check_iters[0]
    }
}

/// One array's paired footprint: its name and the common `(index,
/// reference expr, optimized expr)` triples for the elements both runs
/// wrote.
pub type PairedFootprint = (String, Vec<(u64, ExprId, ExprId)>);
/// Per-array paired footprints, in `paired_elements` order.
pub type PairedFootprints = Vec<PairedFootprint>;

/// Pair up the two runs' written elements for each named array (identical index sets required;
/// unnamed arrays, e.g. FlashAttention's optimized-only `l`/`m`, are not compared). An empty list
/// is an error, not a vacuous pass. Shared by every backend so they check the same elements.
pub fn paired_elements(
    reference: &SymbolicOutputs,
    optimized: &SymbolicOutputs,
    arrays: &[String],
) -> Result<PairedFootprints, EquivCheckError> {
    if arrays.is_empty() {
        return Err(EquivCheckError::ShapeMismatch {
            message: "no arrays specified to check".to_string(),
        });
    }
    let mut result = Vec::with_capacity(arrays.len());
    for name in arrays {
        let Some((_, ref_elems)) = reference.outputs.iter().find(|(n, _)| n == name) else {
            return Err(EquivCheckError::ShapeMismatch {
                message: format!("reference run has no output array '{}'", name),
            });
        };
        let Some((_, opt_elems)) = optimized.outputs.iter().find(|(n, _)| n == name) else {
            return Err(EquivCheckError::ShapeMismatch {
                message: format!("optimized run has no output array '{}'", name),
            });
        };

        if ref_elems.len() != opt_elems.len() {
            return Err(EquivCheckError::ShapeMismatch {
                message: format!(
                    "array '{}': {} elements written vs {}",
                    name,
                    ref_elems.len(),
                    opt_elems.len()
                ),
            });
        }
        let mut common = Vec::with_capacity(ref_elems.len());
        for (&(ri, r), &(oi, o)) in ref_elems.iter().zip(opt_elems.iter()) {
            if ri != oi {
                return Err(EquivCheckError::ShapeMismatch {
                    message: format!(
                        "array '{}': written footprints differ (element {} vs {})",
                        name, ri, oi
                    ),
                });
            }
            common.push((ri, r, o));
        }
        result.push((name.clone(), common));
    }
    Ok(result)
}

/// Flatten paired footprints into the check list: each array's element prefix, capped at
/// `sample` per array (0 = all), in `paired` order. The one definition of *which* elements are
/// checked - decision procedure, Z3 backend and bench re-solve loop correspond positionally.
pub fn sampled_elements(
    paired: &[PairedFootprint],
    sample: u64,
) -> Vec<(&str, u64, ExprId, ExprId)> {
    let mut sampled = Vec::new();
    for (name, common) in paired {
        let limit = match sample {
            0 => common.len(),
            n => common.len().min(n as usize),
        };
        for &(index, r, o) in common.iter().take(limit) {
            sampled.push((name.as_str(), index, r, o));
        }
    }
    sampled
}

/// Verify that a later solve iteration reproduced iteration 1's verdict
/// for one element. `iteration` is 1-based (so always >= 2 here). The
/// decision procedure is deterministic; a disagreement is a hard error.
fn check_iteration_agreement(
    first: bool,
    later: bool,
    array: &str,
    index: u64,
    iteration: usize,
) -> Result<(), EquivCheckError> {
    if first == later {
        return Ok(());
    }
    Err(EquivCheckError::IterationDisagreement {
        message: format!(
            "array '{}' element {}: iteration {} returned {} but iteration 1 returned {}",
            array,
            index,
            iteration,
            if later {
                "equivalent"
            } else {
                "not equivalent"
            },
            if first {
                "equivalent"
            } else {
                "not equivalent"
            },
        ),
    })
}

/// Check two analysis outputs element by element under `options`. Each solve iteration shares
/// one `EquivSession` across all elements, so shared structure canonicalizes once; each further
/// iteration re-solves the same elements from a fresh session.
pub fn check_output_equivalence_with(
    reference: &SymbolicOutputs,
    optimized: &SymbolicOutputs,
    arrays: &[String],
    options: &EquivCheckOptions,
) -> Result<EquivCheckReport, EquivCheckError> {
    let pair_start = Instant::now();
    let paired = paired_elements(reference, optimized, arrays)?;
    let pair_time = pair_start.elapsed();

    // Flatten the sampled elements once: every iteration solves exactly
    // this list, in this order (`sampled_elements` takes each array's
    // prefix, so "the same sampled elements" holds by construction).
    let elements_total: u64 = paired.iter().map(|(_, common)| common.len() as u64).sum();
    let checked = sampled_elements(&paired, options.sample);

    let mut verify_time = options.verify_numeric.then_some(Duration::ZERO);
    let mut check_iters = Vec::with_capacity(options.iterations.get());
    let mut element_checks = Vec::with_capacity(checked.len());
    let mut first_verdicts: Vec<bool> = Vec::with_capacity(checked.len());
    for iteration in 1..=options.iterations.get() {
        let mut session = EquivSession::with_recycle_terms(
            &reference.arena,
            &optimized.arena,
            options.recycle_terms,
        );
        let mut iter_time = Duration::ZERO;
        for (slot, &(name, index, r, o)) in checked.iter().enumerate() {
            let check_start = Instant::now();
            let equivalent = session.check(r, o)?;
            let check = check_start.elapsed();
            iter_time += check;
            if iteration == 1 {
                element_checks.push(ElementCheckTime {
                    array: name.to_string(),
                    index,
                    check,
                });
                if let Some(verify_time) = verify_time.as_mut() {
                    let verify_start = Instant::now();
                    numeric::verify_verdict(&reference.arena, r, &optimized.arena, o, equivalent)
                        .map_err(|message| EquivCheckError::Numeric {
                        message: format!("array '{}' element {}: {}", name, index, message),
                    })?;
                    *verify_time += verify_start.elapsed();
                }
                first_verdicts.push(equivalent);
            } else {
                check_iteration_agreement(
                    first_verdicts[slot],
                    equivalent,
                    name,
                    index,
                    iteration,
                )?;
            }
        }
        check_iters.push(iter_time);
    }

    let mismatches: Vec<Mismatch> = checked
        .iter()
        .zip(&first_verdicts)
        .filter(|&(_, &equivalent)| !equivalent)
        .map(|(&(name, index, _, _), _)| Mismatch {
            array: name.to_string(),
            index,
        })
        .collect();
    let outcome = if mismatches.is_empty() {
        EquivOutcome::Equivalent
    } else {
        EquivOutcome::NotEquivalent { mismatches }
    };
    Ok(EquivCheckReport {
        outcome,
        elements_checked: checked.len() as u64,
        elements_total,
        check_iters,
        element_checks,
        pair_time,
        verify_time,
    })
}

/// Check that two analysis outputs agree on every element of every named
/// array under the default options: all elements checked, no numeric
/// oracle.
pub fn check_output_equivalence(
    reference: &SymbolicOutputs,
    optimized: &SymbolicOutputs,
    arrays: &[String],
) -> Result<EquivOutcome, EquivCheckError> {
    check_output_equivalence_with(reference, optimized, arrays, &EquivCheckOptions::default())
        .map(|report| report.outcome)
}

#[cfg(test)]
mod tests {
    use super::*;
    use volta_expr::ExprArena;

    fn output_with(arrays: &[(&str, &[u64])]) -> SymbolicOutputs {
        let mut arena = ExprArena::new();
        let outputs = arrays
            .iter()
            .map(|(name, indices)| {
                let elems = indices
                    .iter()
                    .map(|&i| {
                        let sid = arena.intern_string(*name);
                        (i, arena.input_element(sid, i))
                    })
                    .collect();
                (name.to_string(), elems)
            })
            .collect();
        SymbolicOutputs { arena, outputs }
    }

    fn names(names: &[&str]) -> Vec<String> {
        names.iter().map(|n| n.to_string()).collect()
    }

    /// The caller's array list is the spec: named arrays must exist on
    /// BOTH sides, unnamed arrays on either side are ignored, and naming
    /// nothing is an error rather than a vacuous pass.
    #[test]
    fn paired_elements_follows_the_callers_list() {
        let reference = output_with(&[("out", &[0, 1])]);
        let optimized = output_with(&[("out", &[0, 1]), ("aux", &[0])]);

        // Unnamed optimized-only "aux" is ignored.
        let paired = paired_elements(&reference, &optimized, &names(&["out"])).unwrap();
        assert_eq!(paired.len(), 1);
        assert_eq!(paired[0].1.len(), 2);

        // Naming an array absent from either side is an error.
        assert!(paired_elements(&reference, &optimized, &names(&["aux"])).is_err());
        assert!(paired_elements(&optimized, &reference, &names(&["out", "aux"])).is_err());
        assert!(paired_elements(&reference, &optimized, &names(&["missing"])).is_err());

        // An empty list is an error, not a vacuous pass.
        assert!(paired_elements(&reference, &optimized, &[]).is_err());

        // Differing footprints for a named array are an error.
        let narrower = output_with(&[("out", &[0])]);
        assert!(paired_elements(&reference, &narrower, &names(&["out"])).is_err());
    }

    /// `iterations = N` re-solves the same elements N times: the report
    /// carries one timing per iteration, the verdict is iteration 1's, and
    /// element counts don't multiply.
    #[test]
    fn iterations_time_every_solve_and_keep_one_verdict() {
        let reference = output_with(&[("out", &[0, 1, 2])]);
        let optimized = output_with(&[("out", &[0, 1, 2])]);
        let options = EquivCheckOptions {
            iterations: NonZeroUsize::new(3).unwrap(),
            ..EquivCheckOptions::default()
        };
        let report =
            check_output_equivalence_with(&reference, &optimized, &names(&["out"]), &options)
                .unwrap();
        assert_eq!(report.check_iters.len(), 3);
        assert_eq!(report.check_time(), report.check_iters[0]);
        assert_eq!(report.elements_checked, 3);
        assert_eq!(report.elements_total, 3);
        assert!(matches!(report.outcome, EquivOutcome::Equivalent));
        // Oracle off: no oracle-time bucket, rather than a zero one.
        assert_eq!(report.verify_time, None);
        // Per-element times: iteration 1 only (no multiplication across
        // iterations), in `sampled_elements` order, summing to iteration
        // 1's total.
        assert_eq!(
            report
                .element_checks
                .iter()
                .map(|e| (e.array.as_str(), e.index))
                .collect::<Vec<_>>(),
            vec![("out", 0), ("out", 1), ("out", 2)]
        );
        assert_eq!(
            report
                .element_checks
                .iter()
                .map(|e| e.check)
                .sum::<Duration>(),
            report.check_iters[0]
        );

        // Sampling caps the per-array element count once, not per iteration, and a
        // NotEquivalent verdict (one side reads a different input array) survives the
        // later iterations' agreement check.
        let mut arena = ExprArena::new();
        let sid = arena.intern_string("other");
        let elems: Vec<(u64, ExprId)> = (0..3).map(|i| (i, arena.input_element(sid, i))).collect();
        let mismatched = SymbolicOutputs {
            arena,
            outputs: vec![("out".to_string(), elems)],
        };
        let options = EquivCheckOptions {
            sample: 2,
            iterations: NonZeroUsize::new(2).unwrap(),
            ..EquivCheckOptions::default()
        };
        let report =
            check_output_equivalence_with(&reference, &mismatched, &names(&["out"]), &options)
                .unwrap();
        assert_eq!(report.elements_checked, 2);
        assert_eq!(report.elements_total, 3);
        assert_eq!(report.check_iters.len(), 2);
        let EquivOutcome::NotEquivalent { mismatches } = report.outcome else {
            panic!("input-element reads of different arrays must differ");
        };
        assert_eq!(mismatches.len(), 2);
    }

    /// With `verify_numeric` on, the oracle's time is reported in its own
    /// bucket (`Some` exactly when the flag is set), never folded into the
    /// solve iterations.
    #[test]
    fn verify_numeric_time_is_reported_separately() {
        let reference = output_with(&[("out", &[0, 1])]);
        let optimized = output_with(&[("out", &[0, 1])]);
        let options = EquivCheckOptions {
            verify_numeric: true,
            ..EquivCheckOptions::default()
        };
        let report =
            check_output_equivalence_with(&reference, &optimized, &names(&["out"]), &options)
                .unwrap();
        assert!(matches!(report.outcome, EquivOutcome::Equivalent));
        assert!(report.verify_time.is_some());
    }

    /// `sampled_elements` is the one definition of which elements get
    /// checked: each array's prefix, capped per array, in `paired` order.
    #[test]
    fn sampled_elements_takes_each_arrays_prefix() {
        let reference = output_with(&[("a", &[0, 1, 2]), ("b", &[7])]);
        let optimized = output_with(&[("a", &[0, 1, 2]), ("b", &[7])]);
        let paired = paired_elements(&reference, &optimized, &names(&["a", "b"])).unwrap();

        let all = sampled_elements(&paired, 0);
        assert_eq!(
            all.iter().map(|&(n, i, _, _)| (n, i)).collect::<Vec<_>>(),
            vec![("a", 0), ("a", 1), ("a", 2), ("b", 7)]
        );

        let capped = sampled_elements(&paired, 2);
        assert_eq!(
            capped
                .iter()
                .map(|&(n, i, _, _)| (n, i))
                .collect::<Vec<_>>(),
            vec![("a", 0), ("a", 1), ("b", 7)]
        );
    }

    /// The determinism guard: agreeing iterations pass, a flipped verdict is a hard error naming
    /// the element and iteration. Exercised directly, since deterministic canon can't disagree.
    #[test]
    fn iteration_agreement_guard() {
        assert!(check_iteration_agreement(true, true, "out", 7, 2).is_ok());
        assert!(check_iteration_agreement(false, false, "out", 7, 3).is_ok());

        let err = check_iteration_agreement(true, false, "out", 7, 2).unwrap_err();
        let EquivCheckError::IterationDisagreement { message } = &err else {
            panic!("disagreement must be IterationDisagreement, got {}", err);
        };
        assert!(message.contains("'out'"), "names the array: {}", message);
        assert!(
            message.contains("element 7"),
            "names the element: {}",
            message
        );
        assert!(
            message.contains("iteration 2"),
            "names the iteration: {}",
            message
        );
    }
}
