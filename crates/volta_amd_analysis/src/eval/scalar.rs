//! Scalar instructions (memory, moves, ALU operations, no-ops and waits) for a wave, as another
//! `impl Interpreter`. The ALU operates on concrete words.

use crate::ir::{LoweredInstr, ScalarLoadDst, ScalarOp32, ScalarSrc, Sgpr};

use super::wave::{WaveId, WaveRegisters};
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
            LoweredInstr::ScalarLoad { dst, base, offset } => match *dst {
                ScalarLoadDst::Dword(reg) => self.scalar_load(wave, [reg], *base, *offset),
                ScalarLoadDst::Dwordx2(regs) => self.scalar_load(wave, regs, *base, *offset),
                ScalarLoadDst::Dwordx4(regs) => self.scalar_load(wave, regs, *base, *offset),
                ScalarLoadDst::Dwordx8(regs) => self.scalar_load(wave, regs, *base, *offset),
            },
            LoweredInstr::MovScalar32 { dst, src } => {
                let registers = &mut self.waves[wave].registers;
                let value = match *src {
                    ScalarSrc::Sgpr(reg) => registers.read_sgpr(reg)?,
                    ScalarSrc::Const(bits) => self.arena.int(i64::from(bits)),
                };
                registers.write_sgpr(*dst, value)
            }
            LoweredInstr::ScalarOp32 {
                op,
                dst,
                src0,
                src1,
            } => {
                let a = self.read_scalar_word(wave, *src0)?;
                let b = self.read_scalar_word(wave, *src1)?;
                let (value, scc) = scalar_op32(&self.waves[wave].registers, *op, a, b)?;
                self.write_scalar_word(wave, *dst, value, scc)
            }
            LoweredInstr::ReadFirstLane { dst, src } => {
                let registers = &mut self.waves[wave].registers;
                let value = registers.read_vgpr(0, *src)?;
                registers.write_sgpr(*dst, value)
            }
            LoweredInstr::Nop => Ok(()),
            LoweredInstr::WaitCnt { vmcnt, lgkmcnt } => {
                let registers = &mut self.waves[wave].registers;
                // Scalar loads can finish out of order, so only lgkmcnt(0) says which are ready.
                if lgkmcnt.is_some_and(|n| n != 0) {
                    return Err(EvalError::UnsupportedInstruction);
                }
                if let Some(outstanding) = vmcnt {
                    registers.finish_vector_loads(usize::from(*outstanding));
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

impl Interpreter<'_> {
    fn read_scalar_word(&self, wave: WaveId, src: ScalarSrc) -> Result<u32, EvalError> {
        match src {
            ScalarSrc::Sgpr(reg) => self.waves[wave].registers.read_sgpr_word(&self.arena, reg),
            ScalarSrc::Const(bits) => Ok(bits),
        }
    }

    /// Write `value` to `dst`, and `scc` to SCC unless the operation leaves it unchanged.
    fn write_scalar_word(
        &mut self,
        wave: WaveId,
        dst: Sgpr,
        value: u32,
        scc: Option<bool>,
    ) -> Result<(), EvalError> {
        let value = self.arena.int(i64::from(value));
        let registers = &mut self.waves[wave].registers;
        registers.write_sgpr(dst, value)?;
        if let Some(scc) = scc {
            registers.write_scc(scc);
        }
        Ok(())
    }
}

/// `a op b` and the SCC it writes, `None` when the operation leaves SCC unchanged.
fn scalar_op32(
    registers: &WaveRegisters,
    op: ScalarOp32,
    a: u32,
    b: u32,
) -> Result<(u32, Option<bool>), EvalError> {
    let scc_if_nonzero = |value: u32| (value, Some(value != 0));
    Ok(match op {
        ScalarOp32::AddU32 => {
            let (sum, carry) = a.overflowing_add(b);
            (sum, Some(carry))
        }
        ScalarOp32::AddcU32 => {
            let sum = u64::from(a) + u64::from(b) + u64::from(registers.read_scc()?);
            (sum as u32, Some(sum >> 32 != 0))
        }
        ScalarOp32::AddI32 => {
            let (sum, overflow) = (a as i32).overflowing_add(b as i32);
            (sum as u32, Some(overflow))
        }
        ScalarOp32::SubI32 => {
            let (difference, overflow) = (a as i32).overflowing_sub(b as i32);
            (difference as u32, Some(overflow))
        }
        ScalarOp32::MulI32 => (a.wrapping_mul(b), None),
        ScalarOp32::MulHiU32 => (((u64::from(a) * u64::from(b)) >> 32) as u32, None),
        ScalarOp32::AndB32 => scc_if_nonzero(a & b),
        ScalarOp32::XorB32 => scc_if_nonzero(a ^ b),
        ScalarOp32::LShlB32 => scc_if_nonzero(a << (b & 31)),
        ScalarOp32::LShrB32 => scc_if_nonzero(a >> (b & 31)),
        ScalarOp32::AShrI32 => scc_if_nonzero(((a as i32) >> (b & 31)) as u32),
        ScalarOp32::CSelectB32 => (if registers.read_scc()? { a } else { b }, None),
    })
}
