//! Local rewrites of an expression graph into equal nodes both sides of an equivalence check
//! reach: PyTorch's tanh GELU into one [`crate::ExprNode::Gelu`], the selects of PyTorch's
//! piecewise activations into the `max` and `min` forms their specs state, LLVM's denormal
//! guard of `exp` into the `exp` it guards, and CUDA's accurate `expf` into `exp`, one module per pattern. `volta_pipeline` applies them to both sides of an equivalence check.

mod accurate_exp;
mod denormal_exp;
mod elu;
pub mod gelu;
mod hardtanh;
mod leaky_relu;
mod node;
mod patterns;
mod softshrink;

use std::borrow::Cow;
use std::collections::HashMap;

use id_collections::{Count, IdVec};

use crate::{ExprArena, ExprId, SymbolicOutputs};

/// Whether an equivalence check first applies [`rewrite_activations`] to both sides.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum Rewrites {
    #[default]
    Activations,
    Disabled,
}

/// `outputs` with the first applicable rewrite applied to each node reachable from an output,
/// children first; `None` when none applies, so the arena is copied only for a match.
pub fn rewrite_activations(outputs: &SymbolicOutputs) -> Option<SymbolicOutputs> {
    let mut nodes = Nodes::mark_reachable(outputs);
    let mut arena = Cow::Borrowed(&outputs.arena);

    for id in nodes.marks.count() {
        if nodes.marks[id] == Mark::Unreached {
            continue;
        }

        let updated = with_latest_children(&mut arena, id, |c| nodes.latest(c));
        let target = replacement(&mut arena, updated).unwrap_or(updated);

        if target != id {
            nodes.record_replacement(id, target);
        }
    }

    let Cow::Owned(arena) = arena else {
        return None;
    };

    let outputs = nodes.redirect_outputs(outputs);
    Some(SymbolicOutputs { arena, outputs })
}

/// The node an activation rewrite builds in place of `id`, when one applies to it.
fn replacement(arena: &mut Cow<'_, ExprArena>, id: ExprId) -> Option<ExprId> {
    if let Some(x) = gelu::torch_gelu(arena, id) {
        return Some(arena.to_mut().gelu(x));
    }
    if let Some(found) = hardtanh::hardtanh(arena, id) {
        return Some(found.build(arena.to_mut()));
    }
    if let Some(found) = leaky_relu::leaky_relu(arena, id) {
        return Some(found.build(arena.to_mut()));
    }
    if let Some(found) = softshrink::softshrink(arena, id) {
        return Some(found.build(arena.to_mut()));
    }
    if let Some(found) = elu::elu(arena, id) {
        return Some(found.build(arena.to_mut()));
    }
    if let Some(found) = denormal_exp::denormal_exp(arena, id) {
        return Some(found.build(arena.to_mut()));
    }
    if let Some(found) = accurate_exp::accurate_exp(arena, id) {
        return Some(found.build(arena.to_mut()));
    }
    None
}

/// `id` with each child `c` replaced by `latest(c)`, rebuilt only when one of them changed.
fn with_latest_children(
    arena: &mut Cow<'_, ExprArena>,
    id: ExprId,
    latest: impl Fn(ExprId) -> ExprId,
) -> ExprId {
    let mut changed = false;
    arena.node(id).for_each_child(|c| changed |= latest(c) != c);

    if changed {
        arena.to_mut().rebuild(id, latest)
    } else {
        id
    }
}

/// What [`rewrite_activations`] knows of an original node: one byte each, so a pass over a
/// many-million-node arena hashes only the nodes it replaces.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Mark {
    Unreached,
    Reached,
    Replaced,
}

/// The original arena's nodes: which are reachable from an output, and what replaced them.
struct Nodes {
    marks: IdVec<ExprId, Mark>,
    replacements: HashMap<ExprId, ExprId>,
}

impl Nodes {
    /// Marks every node reachable from an output in one descending sweep: an arena's children
    /// precede their parents, so a node is marked before its children are visited.
    fn mark_reachable(outputs: &SymbolicOutputs) -> Self {
        let count = u32::try_from(outputs.arena.node_count()).expect("an arena's ids are u32");
        let mut marks = IdVec::from_count_with(Count::from_value(count), |_| Mark::Unreached);

        for &(_, root) in outputs.outputs.iter().flat_map(|(_, elems)| elems) {
            marks[root] = Mark::Reached;
        }

        for id in marks.count().into_iter().rev() {
            if marks[id] == Mark::Reached {
                outputs
                    .arena
                    .node(id)
                    .for_each_child(|c| marks[c] = Mark::Reached);
            }
        }

        Self {
            marks,
            replacements: HashMap::new(),
        }
    }

    /// The node standing for original node `id` now: its replacement, else `id` itself.
    fn latest(&self, id: ExprId) -> ExprId {
        match self.marks[id] {
            Mark::Replaced => self.replacements[&id],
            Mark::Unreached | Mark::Reached => id,
        }
    }

    /// Each output array of `outputs`, its elements' roots redirected to their latest nodes.
    fn redirect_outputs(&self, outputs: &SymbolicOutputs) -> Vec<(String, Vec<(u64, ExprId)>)> {
        outputs
            .outputs
            .iter()
            .map(|(array, elements)| (array.clone(), self.redirect_elements(elements)))
            .collect()
    }

    /// `elements` (index, root) with each root redirected to its latest node.
    fn redirect_elements(&self, elements: &[(u64, ExprId)]) -> Vec<(u64, ExprId)> {
        elements
            .iter()
            .map(|&(index, root)| (index, self.latest(root)))
            .collect()
    }

    fn record_replacement(&mut self, id: ExprId, target: ExprId) {
        self.marks[id] = Mark::Replaced;
        self.replacements.insert(id, target);
    }
}
