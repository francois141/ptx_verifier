//! One run's symbolic outputs: the hand-off between whatever produced the
//! expressions (the interpreter, a spec) and whatever consumes them.

use id_collections::Id;

use crate::symbolic::{ExprArena, ExprId};

/// The expression arena plus, per output array, the written elements as
/// `(index, root expression)` sorted by index. Only written elements appear.
#[derive(Debug, Clone, Default, serde::Serialize, serde::Deserialize)]
pub struct SymbolicOutputs {
    pub arena: ExprArena,
    pub outputs: Vec<(String, Vec<(u64, ExprId)>)>,
}

impl SymbolicOutputs {
    /// Check that every id points inside the arena. Run on outputs rebuilt
    /// from external data, so a corrupt input errors instead of panicking
    /// deep inside a consumer.
    pub fn validate(&self) -> Result<(), String> {
        self.arena.validate()?;
        let n_nodes = self.arena.node_count();
        for (name, elems) in &self.outputs {
            for &(index, root) in elems {
                if root.to_index() as usize >= n_nodes {
                    return Err(format!(
                        "output '{}' element {} references expression {} but the arena has {} nodes",
                        name,
                        index,
                        root.to_index(),
                        n_nodes
                    ));
                }
            }
        }
        Ok(())
    }

    /// The root expression of `array[index]`, if the run wrote it.
    pub fn element(&self, array: &str, index: u64) -> Option<ExprId> {
        let (_, elems) = self.outputs.iter().find(|(name, _)| name == array)?;
        elems
            .binary_search_by_key(&index, |&(i, _)| i)
            .ok()
            .map(|slot| elems[slot].1)
    }
}
