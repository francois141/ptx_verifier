//! The equivalence branch: symbolic outputs in, a verdict out. It never sees a graph.

use volta_equivalence::check::{
    EquivCheckOptions, EquivCheckReport, EquivOutcome, check_output_equivalence_with,
};
use volta_equivalence::numeric::verify_verdict;
use volta_expr::SymbolicOutputs;

/// An output element: its array and index.
pub type Element = (String, u64);

/// What the equivalence branch established.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum EquivalenceVerdict {
    /// Every compared element was proved equivalent; `checked < total` when sampling.
    Equivalent { checked: u64, total: u64 },
    /// These elements differ at some numeric input (the f64 oracle separated them).
    Refuted { elements: Vec<Element> },
    /// These elements were neither proved equal nor separated: the decision procedure is
    /// incomplete over uninterpreted atoms, and the oracle found no counterexample.
    Unproven { elements: Vec<Element> },
    /// The branch did not decide anything.
    Failed { reason: String },
}

/// Compare `reference` and `optimized` on `arrays` with the decision procedure, then confirm
/// each claimed difference with the numeric oracle before it counts as a refutation.
pub fn check_equivalence(
    reference: &SymbolicOutputs,
    optimized: &SymbolicOutputs,
    arrays: &[String],
    options: &EquivCheckOptions,
) -> (EquivalenceVerdict, Option<EquivCheckReport>) {
    let report = match check_output_equivalence_with(reference, optimized, arrays, options) {
        Ok(report) => report,
        Err(e) => {
            return (
                EquivalenceVerdict::Failed {
                    reason: e.to_string(),
                },
                None,
            );
        }
    };
    let verdict = match &report.outcome {
        EquivOutcome::Equivalent => EquivalenceVerdict::Equivalent {
            checked: report.elements_checked,
            total: report.elements_total,
        },
        EquivOutcome::NotEquivalent { mismatches } => {
            let claimed: Vec<Element> = mismatches
                .iter()
                .map(|m| (m.array.clone(), m.index))
                .collect();
            let (refuted, unproven) = confirm_differences(reference, optimized, &claimed);
            if refuted.is_empty() {
                EquivalenceVerdict::Unproven { elements: unproven }
            } else {
                EquivalenceVerdict::Refuted { elements: refuted }
            }
        }
    };
    (verdict, Some(report))
}

/// Split elements some backend claimed different into those the numeric oracle separates
/// (refuted) and the rest (unproven).
pub fn confirm_differences(
    reference: &SymbolicOutputs,
    optimized: &SymbolicOutputs,
    elements: &[Element],
) -> (Vec<Element>, Vec<Element>) {
    let mut refuted = Vec::new();
    let mut unproven = Vec::new();
    for (array, index) in elements {
        let separated = match (
            reference.element(array, *index),
            optimized.element(array, *index),
        ) {
            (Some(a), Some(b)) => {
                verify_verdict(&reference.arena, a, &optimized.arena, b, false).is_ok()
            }
            _ => false,
        };
        if separated {
            refuted.push((array.clone(), *index));
        } else {
            unproven.push((array.clone(), *index));
        }
    }
    (refuted, unproven)
}
