//! A tensor during execution: its lowered form and the elements written to it so far.

use std::collections::BTreeMap;

use volta_expr::{ExprArena, ExprId, StringId};

use crate::ir::{Index, InstrId, Memory, Tensor};

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

    /// The tensor's indices, whose offsets must fit in a `u64`.
    pub(super) fn indices(
        &self,
        instr: InstrId,
    ) -> Result<impl Iterator<Item = Index> + use<'a>, EvalError> {
        let tensor = self.tensor;
        if tensor.shape.element_count().is_none() {
            return Err(EvalError::ElementCountOverflow {
                instr,
                tensor: tensor.name.clone(),
            });
        }
        Ok(tensor.shape.indices())
    }

    /// The element at `index`: its last written value, else an argument's input symbol.
    pub(super) fn read(
        &self,
        arena: &mut ExprArena,
        instr: InstrId,
        index: &Index,
    ) -> Result<ExprId, EvalError> {
        if let Some(&value) = self.written.get(index) {
            return Ok(value);
        }
        match self.tensor.memory {
            Memory::Hbm => {
                let offset = self.tensor.shape.offset(index);
                Ok(arena.input_element(self.symbol, offset))
            }
            Memory::Sbuf | Memory::Psum => Err(EvalError::UninitializedRead {
                instr,
                tensor: self.tensor.name.clone(),
                index: index.clone(),
            }),
        }
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
