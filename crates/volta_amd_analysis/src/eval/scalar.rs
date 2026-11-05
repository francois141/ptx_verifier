//! Scalar instructions (memory, moves, ALU operations, comparisons, no-ops and waits) for a
//! wave, as another `impl Interpreter`. The ALU operates on concrete words.

use crate::ir::{
    LoweredInstr, ScalarCmp64Op, ScalarCmpOp, ScalarDst64, ScalarLoadDst, ScalarOp32, ScalarOp64,
    ScalarShift64, ScalarSrc, ScalarSrc64, Sgpr,
};

use super::wave::{LgkmInFlight, WaveId, WaveRegisters};
use super::{EvalError, Interpreter};

/// Read-only kernel argument bytes at a concrete device address.
pub(super) struct KernargBuffer<'a> {
    pub address: u64,
    pub bytes: &'a [u8],
}

impl KernargBuffer<'_> {
    fn contains(&self, address: u64) -> bool {
        address
            .checked_sub(self.address)
            .is_some_and(|offset| offset < self.bytes.len() as u64)
    }

    fn load_dwords<const N: usize>(&self, address: u64) -> Result<[u32; N], EvalError> {
        // Require the entire read to lie inside the argument buffer.
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
                ScalarLoadDst::Dwordx16(regs) => self.scalar_load(wave, regs, *base, *offset),
            },
            LoweredInstr::MovScalar32 { dst, src } => {
                let registers = &mut self.waves[wave].registers;
                let value = match *src {
                    ScalarSrc::Sgpr(reg) => registers.read_sgpr(reg)?,
                    ScalarSrc::Const(bits) => self.arena.int(i64::from(bits)),
                };
                registers.write_sgpr(*dst, value)
            }
            LoweredInstr::MovScalar64 { dst, src } => {
                let value = self.read_scalar64(wave, *src)?;
                self.write_scalar64(wave, *dst, value)
            }
            LoweredInstr::AbsScalar32 { dst, src } => {
                let value = (self.read_scalar_word(wave, *src)? as i32).unsigned_abs();
                self.write_scalar_word(wave, *dst, value, Some(value != 0))
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
            LoweredInstr::ScalarOp64 {
                op,
                dst,
                src0,
                src1,
            } => {
                let a = self.read_scalar64(wave, *src0)?;
                let b = self.read_scalar64(wave, *src1)?;
                let registers = &mut self.waves[wave].registers;
                let value = match op {
                    ScalarOp64::AndB64 => a & b,
                    ScalarOp64::OrB64 => a | b,
                    ScalarOp64::XorB64 => a ^ b,
                    ScalarOp64::AndN2B64 => a & !b,
                    ScalarOp64::OrN2B64 => a | !b,
                    ScalarOp64::NandB64 => !(a & b),
                    ScalarOp64::NorB64 => !(a | b),
                    ScalarOp64::XnorB64 => !(a ^ b),
                    ScalarOp64::CSelectB64 => {
                        if registers.read_scc()? {
                            a
                        } else {
                            b
                        }
                    }
                };
                if *op != ScalarOp64::CSelectB64 {
                    registers.write_scc(value != 0);
                }
                self.write_scalar64(wave, *dst, value)
            }
            LoweredInstr::ShiftScalar64 {
                op,
                dst,
                src,
                shift,
            } => {
                let value = self.read_scalar64(wave, *src)?;
                let shift = self.read_scalar_word(wave, *shift)? & 63;
                let value = match op {
                    ScalarShift64::LShlB64 => value << shift,
                    ScalarShift64::LShrB64 => value >> shift,
                    ScalarShift64::AShrI64 => ((value as i64) >> shift) as u64,
                };
                let registers = &mut self.waves[wave].registers;
                registers.write_scc(value != 0);
                registers.write_sgpr_pair(&mut self.arena, *dst, value)
            }
            LoweredInstr::ScalarCmp { op, src0, src1 } => {
                let a = self.read_scalar_word(wave, *src0)?;
                let b = self.read_scalar_word(wave, *src1)?;
                let (signed_a, signed_b) = (a as i32, b as i32);
                let scc = match op {
                    ScalarCmpOp::LtI32 => signed_a < signed_b,
                    ScalarCmpOp::EqI32 | ScalarCmpOp::EqU32 => a == b,
                    ScalarCmpOp::LeI32 => signed_a <= signed_b,
                    ScalarCmpOp::GtI32 => signed_a > signed_b,
                    ScalarCmpOp::LgI32 | ScalarCmpOp::LgU32 => a != b,
                    ScalarCmpOp::GeI32 => signed_a >= signed_b,
                    ScalarCmpOp::LtU32 => a < b,
                    ScalarCmpOp::LeU32 => a <= b,
                    ScalarCmpOp::GtU32 => a > b,
                    ScalarCmpOp::GeU32 => a >= b,
                    ScalarCmpOp::BitCmp0B32 => (a >> (b & 31)) & 1 == 0,
                    ScalarCmpOp::BitCmp1B32 => (a >> (b & 31)) & 1 == 1,
                };
                self.waves[wave].registers.write_scc(scc);
                Ok(())
            }
            LoweredInstr::ScalarCmp64 { op, src0, src1 } => {
                let a = self.read_scalar64(wave, *src0)?;
                let b = self.read_scalar64(wave, *src1)?;
                let scc = match op {
                    ScalarCmp64Op::EqU64 => a == b,
                    ScalarCmp64Op::LgU64 => a != b,
                };
                self.waves[wave].registers.write_scc(scc);
                Ok(())
            }
            LoweredInstr::BitCmpScalar64 {
                src,
                index,
                expected,
            } => {
                let value = self.read_scalar64(wave, *src)?;
                let index = self.read_scalar_word(wave, *index)? & 63;
                let bit = (value >> index) & 1 == 1;
                self.waves[wave].registers.write_scc(bit == *expected);
                Ok(())
            }
            LoweredInstr::ReadFirstLane { dst, src } => {
                let registers = &mut self.waves[wave].registers;
                let value = registers.read_vgpr(0, *src)?;
                registers.write_sgpr(*dst, value)
            }
            LoweredInstr::Nop => Ok(()),
            LoweredInstr::WaitCnt { vmcnt, lgkmcnt } => {
                let scalar_load_in_flight = self.waves[wave]
                    .lgkm_in_flight
                    .iter()
                    .any(|instruction| matches!(instruction, LgkmInFlight::Scalar { .. }));
                // Scalar loads return out of order, so only lgkmcnt(0) says which are ready; a
                // partial wait with one in flight is not modeled (issue #19).
                if lgkmcnt.is_some_and(|n| n != 0) && scalar_load_in_flight {
                    return Err(EvalError::UnsupportedInstruction);
                }
                if let Some(outstanding) = vmcnt {
                    let registers = &mut self.waves[wave].registers;
                    registers.finish_vm_loads(usize::from(*outstanding));
                }
                if let Some(outstanding) = lgkmcnt {
                    let pc = self.waves[wave].pc;
                    self.wait_lgkm(wave, pc, usize::from(*outstanding));
                }
                Ok(())
            }
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }

    /// Load `N` words from kernel arguments or global inputs into `dst`, pending until a wait.
    fn scalar_load<const N: usize>(
        &mut self,
        wave: WaveId,
        dst: [Sgpr; N],
        base: [Sgpr; 2],
        offset: u32,
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;
        // Read both address words before marking any overlapping destinations pending.
        let base_address = registers.read_concrete_address(&self.arena, base)?;
        // Scalar loads ignore the low two bits of each address component (CDNA4 §8.2.1.1).
        let address = (base_address & !3)
            .checked_add(u64::from(offset & !3))
            .ok_or(EvalError::AddressOverflow)?;
        address
            .checked_add(4 * N as u64 - 1)
            .ok_or(EvalError::AddressOverflow)?;

        // Argument words are concrete; global inputs keep their symbolic array identities.
        let values = if self.kernarg.contains(address) {
            self.kernarg
                .load_dwords::<N>(address)?
                .map(|word| self.arena.int(i64::from(word)))
        } else {
            let first = self.global.load_dword(address, &mut self.arena)?;
            let mut values = [first; N];
            for (i, value) in values.iter_mut().enumerate().skip(1) {
                *value = self
                    .global
                    .load_dword(address + 4 * i as u64, &mut self.arena)?;
            }
            values
        };
        registers.start_scalar_load(dst, values)?;
        let dst = dst.to_vec();
        let scalar_load = LgkmInFlight::Scalar { dst };
        self.waves[wave].lgkm_in_flight.push_back(scalar_load);
        Ok(())
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

    /// EXEC holds every lane of the wave.
    fn read_scalar64(&self, wave: WaveId, src: ScalarSrc64) -> Result<u64, EvalError> {
        let registers = &self.waves[wave].registers;
        match src {
            ScalarSrc64::Sgprs(pair) => registers.read_sgpr_pair(&self.arena, pair),
            ScalarSrc64::Vcc => registers.read_vcc_mask(&self.arena),
            ScalarSrc64::Exec => Ok(u64::MAX),
            ScalarSrc64::Const(value) => Ok(value),
        }
    }

    fn write_scalar64(
        &mut self,
        wave: WaveId,
        dst: ScalarDst64,
        value: u64,
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;
        match dst {
            ScalarDst64::Sgprs(pair) => registers.write_sgpr_pair(&mut self.arena, pair, value),
            ScalarDst64::Vcc => registers.write_vcc_mask(&mut self.arena, value),
        }
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
        ScalarOp32::SubU32 => (a.wrapping_sub(b), Some(b > a)),
        ScalarOp32::SubbU32 => {
            let borrow = u32::from(registers.read_scc()?);
            let scc = u64::from(b) + u64::from(borrow) > u64::from(a);
            (a.wrapping_sub(b).wrapping_sub(borrow), Some(scc))
        }
        ScalarOp32::MulI32 => (a.wrapping_mul(b), None),
        ScalarOp32::MulHiU32 => (((u64::from(a) * u64::from(b)) >> 32) as u32, None),
        ScalarOp32::MulHiI32 => {
            let product = i64::from(a as i32) * i64::from(b as i32);
            ((product >> 32) as u32, None)
        }
        ScalarOp32::MinI32 => {
            let (a, b) = (a as i32, b as i32);
            (a.min(b) as u32, Some(a < b))
        }
        ScalarOp32::MinU32 => (a.min(b), Some(a < b)),
        ScalarOp32::MaxI32 => {
            let (a, b) = (a as i32, b as i32);
            (a.max(b) as u32, Some(a >= b))
        }
        ScalarOp32::MaxU32 => (a.max(b), Some(a >= b)),
        ScalarOp32::AndB32 => scc_if_nonzero(a & b),
        ScalarOp32::OrB32 => scc_if_nonzero(a | b),
        ScalarOp32::XorB32 => scc_if_nonzero(a ^ b),
        ScalarOp32::AndN2B32 => scc_if_nonzero(a & !b),
        ScalarOp32::OrN2B32 => scc_if_nonzero(a | !b),
        ScalarOp32::NandB32 => scc_if_nonzero(!(a & b)),
        ScalarOp32::NorB32 => scc_if_nonzero(!(a | b)),
        ScalarOp32::XnorB32 => scc_if_nonzero(!(a ^ b)),
        ScalarOp32::LShlB32 => scc_if_nonzero(a << (b & 31)),
        ScalarOp32::LShrB32 => scc_if_nonzero(a >> (b & 31)),
        ScalarOp32::AShrI32 => scc_if_nonzero(((a as i32) >> (b & 31)) as u32),
        ScalarOp32::CSelectB32 => (if registers.read_scc()? { a } else { b }, None),
    })
}
