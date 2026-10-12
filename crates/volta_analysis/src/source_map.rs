//! Source map associating lowered program elements (instructions, registers,
//! parameters, labels) with their source spans, for error reporting.

use std::collections::HashMap;

use id_collections::IdVec;
use volta_common::Span;

use crate::lowered::InstrId;
use crate::symbols::{ParamId, RegId};

/// Maps lowered program elements back to their source locations. Built during
/// lowering and kept separate from `LoweredProgram` so the executable
/// representation stays clean.
#[derive(Debug, Clone, Default)]
pub struct SourceMap {
    /// Span of each instruction (indexed by InstrId)
    instruction_spans: IdVec<InstrId, Option<Span>>,

    /// Span of register declarations (name declaration site)
    register_decl_spans: HashMap<RegId, Span>,

    /// Span of label definitions (maps the instruction PC to the label's span)
    label_spans: HashMap<InstrId, Span>,

    /// Span of parameter declarations
    param_spans: IdVec<ParamId, Option<Span>>,
}

impl SourceMap {
    /// Create a new empty source map
    pub fn new() -> Self {
        Self::default()
    }

    /// Record the span for an instruction
    pub fn record_instruction(&mut self, id: InstrId, span: Option<Span>) {
        // Ensure the IdVec is large enough
        while self.instruction_spans.len() <= id.0 as usize {
            let _ = self.instruction_spans.push(None);
        }
        self.instruction_spans[id] = span;
    }

    /// Record the span for a register declaration
    pub fn record_register_decl(&mut self, id: RegId, span: Span) {
        self.register_decl_spans.insert(id, span);
    }

    /// Record the span for a label at a given PC
    pub fn record_label(&mut self, pc: InstrId, span: Span) {
        self.label_spans.insert(pc, span);
    }

    /// Record the span for a parameter declaration
    pub fn record_param(&mut self, id: ParamId, span: Option<Span>) {
        // Ensure the IdVec is large enough
        while self.param_spans.len() <= id.0 as usize {
            let _ = self.param_spans.push(None);
        }
        self.param_spans[id] = span;
    }

    /// Get the span for an instruction
    pub fn instruction_span(&self, id: InstrId) -> Option<Span> {
        self.instruction_spans.get(id).copied().flatten()
    }

    /// Get the span for a register declaration
    pub fn register_decl_span(&self, id: RegId) -> Option<Span> {
        self.register_decl_spans.get(&id).copied()
    }

    /// Get the span for a label at a given PC
    pub fn label_span(&self, pc: InstrId) -> Option<Span> {
        self.label_spans.get(&pc).copied()
    }

    /// Get the span for a parameter declaration
    pub fn param_span(&self, id: ParamId) -> Option<Span> {
        self.param_spans.get(id).copied().flatten()
    }

    /// Get the number of instruction spans recorded
    pub fn instruction_count(&self) -> usize {
        self.instruction_spans.len()
    }
}

/// Builder for constructing a SourceMap during lowering
#[derive(Debug, Default)]
pub struct SourceMapBuilder {
    map: SourceMap,
    /// Pending label spans to be associated with the next instruction
    pending_label_spans: Vec<Span>,
}

impl SourceMapBuilder {
    /// Create a new builder
    pub fn new() -> Self {
        Self::default()
    }

    /// Record that we're about to emit an instruction with the given span
    pub fn record_instruction(&mut self, id: InstrId, span: Option<Span>) {
        self.map.record_instruction(id, span);

        // Associate any pending labels with this instruction
        for label_span in self.pending_label_spans.drain(..) {
            self.map.record_label(id, label_span);
        }
    }

    /// Record a pending label (will be associated with the next instruction)
    pub fn record_pending_label(&mut self, span: Span) {
        self.pending_label_spans.push(span);
    }

    /// Record a register declaration span
    pub fn record_register_decl(&mut self, id: RegId, span: Span) {
        self.map.record_register_decl(id, span);
    }

    /// Record a parameter declaration span
    pub fn record_param(&mut self, id: ParamId, span: Option<Span>) {
        self.map.record_param(id, span);
    }

    /// Finish building and return the source map
    pub fn build(self) -> SourceMap {
        self.map
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::RegClass;
    use id_collections::Id;

    #[test]
    fn test_instruction_spans() {
        let mut map = SourceMap::new();

        let id0 = InstrId::from_index(0);
        let id1 = InstrId::from_index(1);

        map.record_instruction(id0, Some(Span(0, 10)));
        map.record_instruction(id1, None);

        assert_eq!(map.instruction_span(id0), Some(Span(0, 10)));
        assert_eq!(map.instruction_span(id1), None);
    }

    #[test]
    fn test_register_decl_spans() {
        let mut map = SourceMap::new();

        let r0 = RegId::new(RegClass::Bits32, 0);
        let r1 = RegId::new(RegClass::Bits64, 0);

        map.record_register_decl(r0, Span(100, 110));
        map.record_register_decl(r1, Span(200, 220));

        assert_eq!(map.register_decl_span(r0), Some(Span(100, 110)));
        assert_eq!(map.register_decl_span(r1), Some(Span(200, 220)));
    }

    #[test]
    fn test_label_spans() {
        let mut map = SourceMap::new();

        let pc = InstrId::from_index(5);
        map.record_label(pc, Span(50, 60));

        assert_eq!(map.label_span(pc), Some(Span(50, 60)));
        assert_eq!(map.label_span(InstrId::from_index(0)), None);
    }

    #[test]
    fn test_builder() {
        let mut builder = SourceMapBuilder::new();

        // Record a label, then an instruction
        builder.record_pending_label(Span(0, 5));
        builder.record_instruction(InstrId::from_index(0), Some(Span(10, 20)));

        let map = builder.build();

        // The label should be associated with instruction 0
        assert_eq!(map.label_span(InstrId::from_index(0)), Some(Span(0, 5)));
        assert_eq!(
            map.instruction_span(InstrId::from_index(0)),
            Some(Span(10, 20))
        );
    }
}
