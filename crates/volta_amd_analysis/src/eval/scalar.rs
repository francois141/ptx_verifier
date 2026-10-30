//! Scalar memory instructions and waits for a wave.

#[cfg(test)]
mod tests;

use volta_expr::ExprArena;

use crate::ir::LoweredInstr;

use super::{EvalError, WaveRegisters};

/// Read-only kernel argument bytes at a concrete device address.
pub(super) struct KernargBuffer<'a> {
    pub address: u64,
    pub bytes: &'a [u8],
}

impl KernargBuffer<'_> {
    fn load_dwordx4(&self, address: u64) -> Result<[u32; 4], EvalError> {
        // Require the entire read to lie inside the argument buffer.
        address.checked_add(15).ok_or(EvalError::AddressOverflow)?;
        let bytes = address
            .checked_sub(self.address)
            .and_then(|offset| usize::try_from(offset).ok())
            .and_then(|start| start.checked_add(16).map(|end| (start, end)))
            .and_then(|(start, end)| self.bytes.get(start..end))
            .ok_or(EvalError::KernargRead { address })?;
        Ok(std::array::from_fn(|i| {
            let start = i * 4;
            u32::from_le_bytes([
                bytes[start],
                bytes[start + 1],
                bytes[start + 2],
                bytes[start + 3],
            ])
        }))
    }
}

/// Execute a scalar instruction once for an XNACK-disabled wave.
/// Instructions must have passed lowering; register values belong to `arena`.
pub(super) fn execute_scalar(
    instruction: &LoweredInstr,
    registers: &mut WaveRegisters,
    kernarg: &KernargBuffer<'_>,
    arena: &mut ExprArena,
) -> Result<(), EvalError> {
    match instruction {
        LoweredInstr::ScalarLoadDwordx4 { dst, base, offset } => {
            // Read both address words before marking any overlapping destinations pending.
            let mut words = [0u32; 2];
            for (word, reg) in words.iter_mut().zip(base) {
                let value = registers.read_sgpr(*reg)?;
                *word = arena
                    .as_int_const(value)
                    .and_then(|value| u32::try_from(value).ok())
                    .ok_or(EvalError::InvalidAddressRegister(*reg))?;
            }
            let base_address = u64::from(words[0]) | (u64::from(words[1]) << 32);
            // Scalar loads ignore the low two bits of each address component (CDNA4 §8.2.1.1).
            let address = (base_address & !3)
                .checked_add(u64::from(offset & !3))
                .ok_or(EvalError::AddressOverflow)?;
            let values = kernarg
                .load_dwordx4(address)?
                .map(|word| arena.int(i64::from(word)));
            registers.start_scalar_load(*dst, values)
        }
        LoweredInstr::WaitCnt {
            vmcnt: None,
            lgkmcnt: Some(0),
        } => {
            // Scalar loads can finish out of order; only a zero count ensures all are ready.
            registers.finish_scalar_loads();
            Ok(())
        }
        _ => Err(EvalError::UnsupportedInstruction),
    }
}
