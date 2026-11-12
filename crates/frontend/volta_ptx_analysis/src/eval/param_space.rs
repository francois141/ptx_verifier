//! Param space read by byte address: an aggregate parameter's bytes, or any
//! parameter through a register holding its address (`mov.b64 %rd, param`).
//! Like `LoadParam`, these reads are value lookups, not event-graph accesses:
//! kernel parameters are read-only, so nothing can race with them.

use crate::config::{
    AnalysisConfig, FieldValue, ParamValue, StructField, TensorMapMode, TensorMapValue,
};
use crate::eval::tensor_map_table::{TensorMapEntry, TensorMapTable};
use crate::ir::symbols::{ParamId, ParamSlot, SymbolTable};
use crate::ir::{InstrId, MemSpace};

use super::ThreadId;
use super::error::{EvalError, EvalResult};
use super::interp::Interpreter;
use super::value::Value;

/// What a parameter is bound to: a value (a scalar, or the legacy scalar
/// binding of an aggregate), or a struct's bytes, `None` where no field gave one.
pub(in crate::eval) enum ParamBinding {
    Value(Value),
    Bytes(Vec<Option<u8>>),
}

/// The bytes of a struct parameter bound to `slot`; a field past its end is a config error.
pub(in crate::eval) fn struct_bytes(
    index: usize,
    fields: &[StructField],
    slot: ParamSlot,
    config: &AnalysisConfig,
) -> EvalResult<Vec<Option<u8>>> {
    let mut bytes = vec![None; slot.size as usize];
    for field in fields {
        let width = field.value.width_bytes();
        // `validate()` established `offset + width` fits in u64.
        if field.offset + width > slot.size {
            let message = format!(
                "the field at byte {} ({width} bytes) is past the end of the {}-byte parameter",
                field.offset, slot.size
            );
            return Err(param_error(index, message));
        }

        let bits = match &field.value {
            FieldValue::Int { value, .. } => *value as u64,
            FieldValue::ArrayPtr(name) => {
                array_base(config, name).map_err(|message| param_error(index, message))?
            }
            // Its bytes stay opaque: only a TMA copy reads it, by its fields.
            FieldValue::TensorMap(_) => continue,
        };

        let start = field.offset as usize;
        let field_bytes = &mut bytes[start..start + width as usize];
        for (byte, value) in field_bytes.iter_mut().zip(bits.to_le_bytes()) {
            *byte = Some(value);
        }
    }

    Ok(bytes)
}

fn param_error(index: usize, message: String) -> EvalError {
    EvalError::Config {
        message: format!("parameter {index}: {message}"),
    }
}

fn array_base(config: &AnalysisConfig, name: &str) -> Result<u64, String> {
    config
        .array(name)
        .map(|array| array.base)
        .ok_or_else(|| format!("a field references unknown array '{name}'"))
}

/// Every tensor map a struct parameter holds, keyed by its param-space address.
pub(in crate::eval) fn param_tensor_maps(
    config: &AnalysisConfig,
    symbols: &SymbolTable,
) -> EvalResult<TensorMapTable> {
    let mut table = TensorMapTable::new();

    for (index, value) in config.params.iter().enumerate() {
        let ParamValue::Struct(fields) = value else {
            continue;
        };
        let slot = symbols.param_slot(ParamId(index as u32));

        for field in fields {
            let FieldValue::TensorMap(map) = &field.value else {
                continue;
            };
            let global_address =
                array_base(config, &map.array).map_err(|message| param_error(index, message))?;

            // `struct_bytes` checked that every field lies inside its slot.
            let addr = slot.offset + field.offset;
            *table.entry_mut(MemSpace::Param, addr) = tensor_map_entry(map, global_address);
        }
    }

    Ok(table)
}

/// A host-encoded map as the fields `tensormap.replace` would have written.
fn tensor_map_entry(map: &TensorMapValue, global_address: u64) -> TensorMapEntry {
    let mut entry = TensorMapEntry {
        global_address: Some(global_address),
        rank: Some(map.dims.len() as u32 - 1),
        elemtype: Some(map.elemtype),
        interleave_layout: Some(map.interleave),
        swizzle_mode: Some(map.swizzle),
        swizzle_atomicity: Some(map.swizzle_atomicity),
        fill_mode: Some(map.fill),
        ..TensorMapEntry::default()
    };

    for (i, &size) in map.dims.iter().enumerate() {
        let d = i as u32;
        entry.global_dim.insert(d, size);
        entry.element_stride.insert(d, map.element_strides[i]);
    }
    for (i, &stride) in map.strides.iter().enumerate() {
        entry.global_stride.insert(i as u32, stride);
    }

    match &map.mode {
        TensorMapMode::Tiled { box_dims } => {
            for (i, &size) in box_dims.iter().enumerate() {
                entry.box_dim.insert(i as u32, size);
            }
        }
        TensorMapMode::Im2col(im2col) => entry.im2col = Some(im2col.clone()),
    }

    entry
}

impl Interpreter<'_> {
    /// The parameter whose slot holds all of `[addr, addr + width)`, and the offset of `addr` in it.
    pub(in crate::eval) fn param_at(
        &self,
        t: ThreadId,
        pc: InstrId,
        addr: u64,
        width: u64,
    ) -> EvalResult<(&ParamBinding, u64)> {
        let end = addr.checked_add(width);

        for (id, binding) in self.params.iter() {
            let slot = self.program.symbols.param_slot(id);
            // `declare_param` established that every slot's end fits in u64.
            let slot_end = slot.offset + slot.size;
            if addr >= slot.offset && end.is_some_and(|end| end <= slot_end) {
                return Ok((binding, addr - slot.offset));
            }
        }

        Err(EvalError::OutOfBounds {
            thread: t,
            pc,
            space: MemSpace::Param,
            addr,
            width,
        })
    }

    /// Read `width` little-endian bytes of param space at `addr`.
    pub(in crate::eval) fn param_read(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        addr: u64,
        width: u64,
    ) -> EvalResult<Value> {
        let (binding, offset) = self.param_at(t, pc, addr, width)?;

        let bits = match binding {
            ParamBinding::Value(value) if offset == 0 => return Ok(*value),
            ParamBinding::Value(_) => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!("a {width}-byte read at byte {offset} of a scalar parameter"),
                });
            }
            ParamBinding::Bytes(bytes) => {
                little_endian(&bytes[offset as usize..(offset + width) as usize])
            }
        };

        let value = match bits {
            Some(bits) => self.arena.int(bits as i64),
            None => self.undefined,
        };

        Ok(Value::Scalar(value))
    }
}

/// The little-endian integer `bytes` (at most 8) spell, `None` if any byte is unset.
fn little_endian(bytes: &[Option<u8>]) -> Option<u64> {
    let mut le = [0u8; 8];

    for (dst, byte) in le.iter_mut().zip(bytes) {
        *dst = (*byte)?;
    }

    Some(u64::from_le_bytes(le))
}
