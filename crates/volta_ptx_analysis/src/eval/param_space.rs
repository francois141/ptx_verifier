//! Param space read by byte address: an aggregate parameter's bytes, or any
//! parameter through a register holding its address (`mov.b64 %rd, param`).
//! Like `LoadParam`, these reads are value lookups, not event-graph accesses:
//! kernel parameters are read-only, so nothing can race with them.

use crate::config::{AnalysisConfig, FieldValue, StructField};
use crate::ir::symbols::ParamSlot;
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
    let config_error = |message: String| EvalError::Config {
        message: format!("parameter {index}: {message}"),
    };

    let mut bytes = vec![None; slot.size as usize];
    for field in fields {
        let width = field.value.width_bytes();
        // `validate()` established `offset + width` fits in u64.
        if field.offset + width > slot.size {
            return Err(config_error(format!(
                "the field at byte {} ({width} bytes) is past the end of the {}-byte parameter",
                field.offset, slot.size
            )));
        }

        let bits = match &field.value {
            FieldValue::Int { value, .. } => *value as u64,
            FieldValue::ArrayPtr(name) => array_base(config, name).map_err(config_error)?,
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

fn array_base(config: &AnalysisConfig, name: &str) -> Result<u64, String> {
    config
        .array(name)
        .map(|array| array.base)
        .ok_or_else(|| format!("a field references unknown array '{name}'"))
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
