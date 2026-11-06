//! A tensor during execution: its lowered form and the elements written to it so far.

use std::collections::BTreeMap;

use volta_expr::{ExprArena, ExprId, StringId};

use crate::ir::{Index, Initial, InstrId, Tensor};

use super::EvalError;

pub(super) struct TensorState<'a> {
    tensor: &'a Tensor,
    /// Its name, interned for the symbols of its input elements.
    symbol: StringId,
    /// Its written elements by index.
    written: BTreeMap<Index, ExprId>,
}

impl<'a> TensorState<'a> {
    pub(super) fn new(tensor: &'a Tensor, arena: &mut ExprArena) -> Self {
        Self {
            tensor,
            symbol: arena.intern_string(tensor.name.clone()),
            written: BTreeMap::new(),
        }
    }

    pub(super) fn name(&self) -> &str {
        &self.tensor.name
    }

    /// The element at `index`: its last written value, else an argument's input symbol.
    /// Any other tensor's unwritten element is uninitialized.
    pub(super) fn read(
        &self,
        arena: &mut ExprArena,
        instr: InstrId,
        index: &Index,
    ) -> Result<ExprId, EvalError> {
        if let Some(&value) = self.written.get(index) {
            return Ok(value);
        }
        match self.tensor.initial {
            Initial::Argument => {
                let offset = self.tensor.shape.offset(index);
                Ok(arena.input_element(self.symbol, offset))
            }
            Initial::Uninitialized => Err(EvalError::UninitializedRead {
                instr,
                tensor: self.tensor.name.clone(),
                index: index.clone(),
            }),
        }
    }

    /// The value last written at `index`, if any.
    pub(super) fn written(&self, index: &Index) -> Option<ExprId> {
        self.written.get(index).copied()
    }

    pub(super) fn write(&mut self, index: Index, value: ExprId) {
        self.written.insert(index, value);
    }

    /// The written elements by offset, sorted: row-major index order is offset order.
    pub(super) fn written_by_offset(&self) -> Vec<(u64, ExprId)> {
        self.written
            .iter()
            .map(|(index, &value)| (self.tensor.shape.offset(index), value))
            .collect()
    }
}
