//! Scalar memory instructions and waits for a wave, as another `impl Interpreter`.

use crate::ir::{LoweredInstr, Sgpr};

use super::wave::WaveId;
use super::{EvalError, Interpreter};

/// Read-only kernel argument bytes at a concrete device address.
pub(super) struct KernargBuffer<'a> {
    pub address: u64,
    pub bytes: &'a [u8],
}

impl KernargBuffer<'_> {
    fn load_dwords<const N: usize>(&self, address: u64) -> Result<[u32; N], EvalError> {
        // Require the entire read to lie inside the argument buffer.
        address
            .checked_add(4 * N as u64 - 1)
            .ok_or(EvalError::AddressOverflow)?;
        let bytes = address
            .checked_sub(self.address)
            .and_then(|offset| usize::try_from(offset).ok())
            .and_then(|start| start.checked_add(4 * N).map(|end| (start, end)))
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

impl Interpreter<'_> {
    /// Execute a scalar instruction once for `wave`, which must be XNACK-disabled.
    /// Instructions must have passed lowering.
    pub(crate) fn execute_scalar(
        &mut self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        match instruction {
            LoweredInstr::ScalarLoadDwordx2 { dst, base, offset } => {
                self.scalar_load(wave, *dst, *base, *offset)
            }
            LoweredInstr::ScalarLoadDwordx4 { dst, base, offset } => {
                self.scalar_load(wave, *dst, *base, *offset)
            }
            LoweredInstr::WaitCnt { vmcnt, lgkmcnt } => {
                let registers = &mut self.waves[wave].registers;
                // Scalar loads can finish out of order, so only lgkmcnt(0) says which are ready.
                // Vector loads return in issue order, but only vmcnt(0) is modeled.
                if [vmcnt, lgkmcnt]
                    .iter()
                    .any(|count| count.is_some_and(|n| n != 0))
                {
                    return Err(EvalError::UnsupportedInstruction);
                }
                if vmcnt.is_some() {
                    registers.finish_vector_loads();
                }
                if lgkmcnt.is_some() {
                    registers.finish_scalar_loads();
                }
                Ok(())
            }
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }

    /// Load `N` argument words at `base` plus `offset` into `dst`, pending until a wait.
    fn scalar_load<const N: usize>(
        &mut self,
        wave: WaveId,
        dst: [Sgpr; N],
        base: [Sgpr; 2],
        offset: u32,
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;
        // Read both address words before marking any overlapping destinations pending.
        let base_address = registers.read_address(&self.arena, base)?;
        // Scalar loads ignore the low two bits of each address component (CDNA4 §8.2.1.1).
        let address = (base_address & !3)
            .checked_add(u64::from(offset & !3))
            .ok_or(EvalError::AddressOverflow)?;
        let values = self
            .kernarg
            .load_dwords::<N>(address)?
            .map(|word| self.arena.int(i64::from(word)));
        registers.start_scalar_load(dst, values)
    }
}
