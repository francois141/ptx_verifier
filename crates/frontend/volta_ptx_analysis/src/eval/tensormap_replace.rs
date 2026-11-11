//! `tensormap.replace` evaluation: one named field of the tensor-map object
//! at a concrete address (see `tensor_map_table`).

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::Interpreter;
use crate::eval::tensor_map_table::TENSOR_MAP_BYTES;
use crate::ir::tensor_map::TensormapFieldWrite;
use crate::ir::{InstrId, MemSpace, Operand};

impl<'p> Interpreter<'p> {
    /// `tensormap.replace`: write one field of the tensor map at `addr_base +
    /// addr_offset`. `new_val` must be concrete (see `eval::tensor_map_table`);
    /// `.field3` enums were decoded at lowering. The field's bytes are opaque, so
    /// the event graph records a write of the whole object.
    pub(in crate::eval) fn exec_tensormap_replace(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr_base: &Operand,
        addr_offset: i64,
        field: &TensormapFieldWrite,
    ) -> EvalResult<()> {
        let addr = self.effective_addr(t, pc, addr_base, addr_offset)?;
        self.check_bounds(t, pc, space, addr, TENSOR_MAP_BYTES)?;
        self.record_opaque_write(t, pc, space, addr, TENSOR_MAP_BYTES);
        match field {
            TensormapFieldWrite::GlobalAddress(v) => {
                let val = self.concrete_operand(t, pc, v, "tensormap .global_address")?;
                self.tensor_maps.entry_mut(space, addr).global_address = Some(val as u64);
            }
            TensormapFieldWrite::Rank(v) => {
                let val = self.concrete_operand(t, pc, v, "tensormap .rank")?;
                let val = u32::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .rank value {val} out of range"),
                })?;
                self.tensor_maps.entry_mut(space, addr).rank = Some(val);
            }
            TensormapFieldWrite::BoxDim { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .box_dim")?;
                let val = u32::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .box_dim value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .box_dim
                    .insert(*ord, val);
            }
            TensormapFieldWrite::GlobalDim { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .global_dim")?;
                let val = u64::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .global_dim value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .global_dim
                    .insert(*ord, val);
            }
            TensormapFieldWrite::GlobalStride { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .global_stride")?;
                let val = u64::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .global_stride value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .global_stride
                    .insert(*ord, val);
            }
            TensormapFieldWrite::ElementStride { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .element_stride")?;
                let val = u32::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .element_stride value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .element_stride
                    .insert(*ord, val);
            }
            TensormapFieldWrite::Elemtype(v) => {
                self.tensor_maps.entry_mut(space, addr).elemtype = Some(*v);
            }
            TensormapFieldWrite::InterleaveLayout(v) => {
                self.tensor_maps.entry_mut(space, addr).interleave_layout = Some(*v);
            }
            TensormapFieldWrite::SwizzleMode(v) => {
                self.tensor_maps.entry_mut(space, addr).swizzle_mode = Some(*v);
            }
            TensormapFieldWrite::SwizzleAtomicity(v) => {
                self.tensor_maps.entry_mut(space, addr).swizzle_atomicity = Some(*v);
            }
            TensormapFieldWrite::FillMode(v) => {
                self.tensor_maps.entry_mut(space, addr).fill_mode = Some(*v);
            }
        }
        Ok(())
    }
}
