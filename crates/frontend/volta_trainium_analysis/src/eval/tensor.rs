//! A tensor during execution: its lowered form, the elements written to it so far, and
//! those a write through a tile placed over them clobbered since.

use std::collections::BTreeMap;

use volta_expr::symbolic_full::{ExprArena, ExprId, Real, StringId};

use crate::ir::{Index, Initial, InstrId, Tensor};

use super::EvalError;

pub(super) struct TensorState<'a> {
    tensor: &'a Tensor,
    /// Its name, interned for the symbols of its input elements.
    symbol: StringId,
    /// Its written elements by index.
    written: BTreeMap<Index, ExprId>,
    /// Its clobbered elements by index, each with the write that clobbered it.
    clobbered: BTreeMap<Index, Clobber>,
}

/// A write through one tile over an element of another.
#[derive(Debug, Clone)]
pub(super) struct Clobber {
    pub(super) instr: InstrId,
    pub(super) through: String,
    /// Whether the element held a value of its own tensor's writes before.
    lost_write: bool,
}

impl<'a> TensorState<'a> {
    pub(super) fn new(tensor: &'a Tensor, arena: &mut ExprArena) -> Self {
        Self {
            tensor,
            symbol: arena.intern_string(tensor.name.clone()),
            written: BTreeMap::new(),
            clobbered: BTreeMap::new(),
        }
    }

    pub(super) fn name(&self) -> &str {
        &self.tensor.name
    }

    pub(super) fn tensor(&self) -> &'a Tensor {
        self.tensor
    }

    /// The element at `index`: its last written value, else an argument's input symbol.
    /// Any other tensor's unwritten element is uninitialized, and a clobbered one an error.
    pub(super) fn read(
        &self,
        arena: &mut ExprArena,
        instr: InstrId,
        index: &Index,
    ) -> Result<ExprId, EvalError> {
        self.unclobbered(instr, index)?;
        if let Some(&value) = self.written.get(index) {
            return Ok(value);
        }
        match &self.tensor.initial {
            Initial::Argument => {
                let offset = self.tensor.shape.offset(index);
                Ok(arena.input_element(self.symbol, offset))
            }
            Initial::Integers(contents) => {
                let value = contents[self.tensor.shape.offset(index) as usize];
                let value = i64::try_from(value).expect("the parser bounds an index's contents");
                Ok(arena.real(Real::from_i64(value)))
            }
            Initial::Uninitialized => Err(EvalError::UninitializedRead {
                instr,
                tensor: self.tensor.name.clone(),
                index: index.clone(),
            }),
        }
    }

    /// The value this tensor last wrote at `index`, if any, as a matmul's `accumulate=None`
    /// asks: an element clobbered before any write of its own is unwritten, one clobbered
    /// after is an error.
    pub(super) fn written(
        &self,
        instr: InstrId,
        index: &Index,
    ) -> Result<Option<ExprId>, EvalError> {
        if self
            .clobbered
            .get(index)
            .is_some_and(|clobber| clobber.lost_write)
        {
            self.unclobbered(instr, index)?;
        }
        Ok(self.written.get(index).copied())
    }

    pub(super) fn write(&mut self, index: Index, value: ExprId) {
        self.clobbered.remove(&index);
        self.written.insert(index, value);
    }

    pub(super) fn clobber(&mut self, index: Index, instr: InstrId, through: String) {
        let lost_write = self.written.remove(&index).is_some()
            || self
                .clobbered
                .get(&index)
                .is_some_and(|clobber| clobber.lost_write);
        let clobber = Clobber {
            instr,
            through,
            lost_write,
        };
        self.clobbered.insert(index, clobber);
    }

    fn unclobbered(&self, instr: InstrId, index: &Index) -> Result<(), EvalError> {
        match self.clobbered.get(index) {
            Some(Clobber {
                instr: by, through, ..
            }) => Err(EvalError::ClobberedRead {
                instr,
                tensor: self.tensor.name.clone(),
                index: index.clone(),
                by: *by,
                through: through.clone(),
            }),
            None => Ok(()),
        }
    }

    /// The written elements by offset, sorted: row-major index order is offset order.
    pub(super) fn written_by_offset(&self) -> Vec<(u64, ExprId)> {
        self.written
            .iter()
            .map(|(index, &value)| (self.tensor.shape.offset(index), value))
            .collect()
    }
}
