//! Raw buffer loads and stores in one lane, as another `impl Interpreter`: global memory
//! accessed through a buffer resource, which bounds it.

use volta_expr::ExprId;

use crate::ir::{BufferAddress, LaneReg, Sgpr, Vgpr};

use super::wave::{LoadCounter, WaveId};
use super::{EvalError, Interpreter};

/// The fields of a buffer resource that an untyped raw access uses: the 48-bit base address
/// and the buffer's size in bytes, its `num_records` when the stride is 0.
struct BufferResource {
    base: u64,
    size: u64,
}

/// Where a lane's access lies relative to the buffer.
enum BufferRange {
    /// The global address of its first byte.
    Inside(u64),
    Outside,
}

impl Interpreter<'_> {
    /// Decode the resource in four SGPRs, rejecting a strided, swizzled or thread-indexed one,
    /// whose addressing this model does not cover.
    fn buffer_resource(&self, wave: WaveId, rsrc: [Sgpr; 4]) -> Result<BufferResource, EvalError> {
        let registers = &self.waves[wave].registers;
        let [base_low, word1, num_records, word3] =
            rsrc.map(|reg| registers.read_sgpr_word(&self.arena, reg));
        let (base_low, word1, num_records, word3) = (base_low?, word1?, num_records?, word3?);

        if (word1 >> 16) & 0x3fff != 0 {
            return Err(EvalError::UnsupportedBufferResource {
                reason: "a nonzero stride",
            });
        }

        if word1 >> 31 != 0 {
            return Err(EvalError::UnsupportedBufferResource {
                reason: "swizzling enabled",
            });
        }

        if (word3 >> 23) & 1 != 0 {
            return Err(EvalError::UnsupportedBufferResource {
                reason: "ADD_TID_ENABLE set",
            });
        }

        Ok(BufferResource {
            base: u64::from(base_low) | (u64::from(word1 & 0xffff) << 32),
            size: u64::from(num_records),
        })
    }

    /// Where `lane`'s `words`-word access lies. A partial overlap is an error: hardware checks
    /// it per access or per word depending on the generation, which this model avoids relying on.
    fn buffer_range(
        &self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        words: u64,
    ) -> Result<BufferRange, EvalError> {
        let resource = self.buffer_resource(wave, address.rsrc)?;

        let vgpr_offset =
            self.waves[wave]
                .registers
                .read_address_vgpr(&self.arena, lane, address.vgpr_offset)?;
        let buffer_offset = u64::from(vgpr_offset) + address.imm_offset.bytes();

        if buffer_offset + 4 * words <= resource.size {
            let start = resource
                .base
                .checked_add(buffer_offset)
                .ok_or(EvalError::AddressOverflow)?;
            Ok(BufferRange::Inside(start))
        } else if buffer_offset >= resource.size {
            Ok(BufferRange::Outside)
        } else {
            Err(EvalError::PartialBufferAccess { buffer_offset })
        }
    }

    /// Load one word per register of `dst`, zero outside the buffer, pending until `vmcnt`
    /// establishes the load's completion.
    pub(super) fn buffer_load(
        &mut self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        dst: &[Vgpr],
    ) -> Result<(), EvalError> {
        let values: Vec<ExprId> = match self.buffer_range(wave, lane, address, dst.len() as u64)? {
            BufferRange::Inside(start) => (0..dst.len() as u64)
                .map(|i| self.global.load_dword(start + 4 * i, &mut self.arena))
                .collect::<Result<_, _>>()?,
            BufferRange::Outside => vec![self.arena.int(0); dst.len()],
        };

        self.waves[wave]
            .registers
            .start_vector_load(lane, dst, &values, LoadCounter::Vm)
    }

    /// Store the word of each register of `src`, dropped outside the buffer.
    pub(super) fn buffer_store(
        &mut self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        src: &[LaneReg],
    ) -> Result<(), EvalError> {
        let start = match self.buffer_range(wave, lane, address, src.len() as u64)? {
            BufferRange::Inside(start) => start,
            BufferRange::Outside => return Ok(()),
        };

        for (i, &reg) in (0..).zip(src) {
            let value = self.waves[wave].registers.read_lane_reg(lane, reg)?;
            self.global.store_dword(start + 4 * i, value)?;
        }

        Ok(())
    }
}
