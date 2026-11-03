//! Raw buffer loads and stores for a single lane.
//! A buffer resource defines the base address and bounds of each access to global memory.

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
        let base_low = registers.read_sgpr_word(&self.arena, rsrc[0])?;
        let word1 = registers.read_sgpr_word(&self.arena, rsrc[1])?;
        let num_records = registers.read_sgpr_word(&self.arena, rsrc[2])?;
        let word3 = registers.read_sgpr_word(&self.arena, rsrc[3])?;

        // Word 1 contains the upper address bits, stride, and swizzle flag.
        let base_high = word1 & 0xffff;
        let stride = (word1 >> 16) & 0x3fff;
        let swizzle_enabled = (word1 >> 31) != 0;
        let add_tid_enabled = ((word3 >> 23) & 1) != 0;

        if stride != 0 {
            return Err(EvalError::UnsupportedBufferResource {
                reason: "a nonzero stride",
            });
        }
        if swizzle_enabled {
            return Err(EvalError::UnsupportedBufferResource {
                reason: "swizzling enabled",
            });
        }
        if add_tid_enabled {
            return Err(EvalError::UnsupportedBufferResource {
                reason: "ADD_TID_ENABLE set",
            });
        }

        Ok(BufferResource {
            base: u64::from(base_low) | (u64::from(base_high) << 32),
            size: u64::from(num_records),
        })
    }

    /// Locate an access of `word_count` words for `lane`. A partial overlap is an error: hardware checks
    /// it per access or per word depending on the generation, which this model avoids relying on.
    fn buffer_range(
        &self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        word_count: u64,
    ) -> Result<BufferRange, EvalError> {
        let resource = self.buffer_resource(wave, address.rsrc)?;
        let registers = &self.waves[wave].registers;
        let vgpr_offset =
            registers.read_concrete_address_vgpr(&self.arena, lane, address.vgpr_offset)?;
        let buffer_offset = u64::from(vgpr_offset) + address.imm_offset.bytes();
        let access_size = 4 * word_count;
        let buffer_end = buffer_offset + access_size;

        if buffer_end <= resource.size {
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
        let word_count = dst.len() as u64;
        let range = self.buffer_range(wave, lane, address, word_count)?;
        let values = match range {
            BufferRange::Inside(start) => {
                let mut values = Vec::with_capacity(dst.len());
                for word_index in 0..word_count {
                    let word_address = start + 4 * word_index;
                    let value = self.global.load_dword(word_address, &mut self.arena)?;
                    values.push(value);
                }
                values
            }
            BufferRange::Outside => vec![self.arena.int(0); dst.len()],
        };
        self.waves[wave]
            .registers
            .start_vector_load(lane, dst, &values, LoadCounter::Vm)
    }

    /// Store the word of each register of `src`; a store outside the buffer is dropped.
    pub(super) fn buffer_store(
        &mut self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        src: &[LaneReg],
    ) -> Result<(), EvalError> {
        let word_count = src.len() as u64;
        let range = self.buffer_range(wave, lane, address, word_count)?;
        let start = match range {
            BufferRange::Inside(start) => start,
            BufferRange::Outside => return Ok(()),
        };

        for (word_index, &reg) in src.iter().enumerate() {
            let word_address = start + 4 * word_index as u64;
            let value = self.waves[wave].registers.read_lane_reg(lane, reg)?;
            self.global.store_dword(word_address, value)?;
        }
        Ok(())
    }
}
