//! Source map associating lowered instructions with their source spans, for
//! error reporting.

use id_collections::IdVec;
use volta_common::Span;

use crate::ir::InstrId;

/// Maps lowered instructions back to their source locations. Built during
/// lowering and kept separate from `LoweredProgram` so the executable
/// representation stays clean.
#[derive(Debug, Clone, Default)]
pub struct SourceMap {
    /// Span of each instruction (indexed by InstrId)
    instruction_spans: IdVec<InstrId, Option<Span>>,
}

impl SourceMap {
    /// Record the span for an instruction
    pub fn record_instruction(&mut self, id: InstrId, span: Option<Span>) {
        // Ensure the IdVec is large enough
        while self.instruction_spans.len() <= id.0 as usize {
            let _ = self.instruction_spans.push(None);
        }
        self.instruction_spans[id] = span;
    }

    /// Get the span for an instruction
    pub fn instruction_span(&self, id: InstrId) -> Option<Span> {
        self.instruction_spans.get(id).copied().flatten()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use id_collections::Id;

    #[test]
    fn test_instruction_spans() {
        let mut map = SourceMap::default();

        let id0 = InstrId::from_index(0);
        let id1 = InstrId::from_index(1);

        map.record_instruction(id0, Some(Span(0, 10)));
        map.record_instruction(id1, None);

        assert_eq!(map.instruction_span(id0), Some(Span(0, 10)));
        assert_eq!(map.instruction_span(id1), None);
    }
}
