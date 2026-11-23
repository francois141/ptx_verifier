//! Raw buffer loads and stores for a single lane.
//! A buffer resource defines the base address and bounds of each access to global memory.

use crate::ir::{BufferAddress, BufferLdsWidth, LaneReg, ScalarSrc, Sgpr, Vgpr};

use volta_expr::symbolic_full::{ExprArena, Real};

use super::global::GlobalMemory;
use super::wave::{LoadCounter, WaveId, concrete_word};
use super::word::Word;
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
        self.buffer_byte_range(wave, lane, address, 4 * word_count)
    }

    /// `buffer_range` for an access of `access_size` bytes.
    fn buffer_byte_range(
        &self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        access_size: u64,
    ) -> Result<BufferRange, EvalError> {
        let resource = self.buffer_resource(wave, address.rsrc)?;
        let registers = &self.waves[wave].registers;
        let vgpr_offset = match address.vgpr_offset {
            Some(reg) => registers.read_concrete_address_vgpr(&self.arena, lane, reg)?,
            None => 0,
        };
        let soffset = match address.soffset {
            ScalarSrc::Sgpr(reg) => registers.read_sgpr_word(&self.arena, reg)?,
            ScalarSrc::Const(bits) => bits,
        };
        let buffer_offset =
            u64::from(vgpr_offset) + u64::from(soffset) + address.imm_offset.bytes();
        let buffer_end = buffer_offset + access_size;

        if buffer_end <= resource.size {
            let start = resource
                .base
                .checked_add(buffer_offset)
                .ok_or(EvalError::AddressOverflow)?;
            Ok(BufferRange::Inside(start))
        } else if buffer_offset >= resource.size || access_size <= 4 {
            // One word past the end is out of range under either check.
            Ok(BufferRange::Outside)
        } else {
            Err(EvalError::PartialBufferAccess { buffer_offset })
        }
    }

    /// Load 16 bits zero-extended: a bf16 element as the low half of a word whose high half is
    /// +0, or the 16 bits of a concrete word; zero outside the buffer.
    pub(super) fn buffer_load_ushort(
        &mut self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        dst: Vgpr,
    ) -> Result<(), EvalError> {
        let value = match self.buffer_byte_range(wave, lane, address, 2)? {
            BufferRange::Outside => Word::Value(self.arena.int(0)),
            BufferRange::Inside(start) => load_ushort(&self.global, &mut self.arena, lane, start)?,
        };
        self.waves[wave]
            .registers
            .start_vector_load(lane, &[dst], &[value], LoadCounter::Vm)
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
        let values = self.buffer_words(wave, lane, address, dst.len() as u64)?;
        self.waves[wave]
            .registers
            .start_vector_load(lane, dst, &values, LoadCounter::Vm)
    }

    /// `lane`'s `word_count` words of a buffer load, zero outside the buffer.
    fn buffer_words(
        &mut self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        word_count: u64,
    ) -> Result<Vec<Word>, EvalError> {
        match self.buffer_range(wave, lane, address, word_count)? {
            BufferRange::Inside(start) => (0..word_count)
                .map(|word_index| {
                    self.global
                        .load_dword(start + 4 * word_index, &mut self.arena)
                })
                .collect(),
            BufferRange::Outside => Ok(vec![Word::Value(self.arena.int(0)); word_count as usize]),
        }
    }

    /// The LDS byte address of `lane`'s words in a load to LDS: `M0[17:0]` plus the lane's share
    /// (CDNA4 ISA §9.1.9).
    pub(super) fn lds_load_address(
        &self,
        wave: WaveId,
        lane: usize,
        width: BufferLdsWidth,
    ) -> Result<u64, EvalError> {
        let m0 = self.waves[wave]
            .registers
            .read_sgpr_word(&self.arena, Sgpr::M0)?;
        let lane_bytes = match width {
            BufferLdsWidth::Dword => 4,
            BufferLdsWidth::Dwordx4 => 16,
        };
        Ok(u64::from(m0 & 0x3ffff) + lane_bytes * lane as u64)
    }

    /// Write `lane`'s words of a load to LDS, which lands at issue; the event graph orders its
    /// readers after the `vmcnt` wait that completes it.
    pub(super) fn buffer_load_lds(
        &mut self,
        wave: WaveId,
        lane: usize,
        width: BufferLdsWidth,
        address: BufferAddress,
    ) -> Result<(), EvalError> {
        let words = self.buffer_words(wave, lane, address, u64::from(width.words()))?;
        let lds_address = self.lds_load_address(wave, lane, width)?;
        self.lds.write(lds_address, &words)
    }

    /// Store the low bf16 half of `src` as one element of a bf16 output; nothing outside the
    /// buffer.
    pub(super) fn buffer_store_short(
        &mut self,
        wave: WaveId,
        lane: usize,
        address: BufferAddress,
        src: LaneReg,
    ) -> Result<(), EvalError> {
        let BufferRange::Inside(start) = self.buffer_byte_range(wave, lane, address, 2)? else {
            return Ok(());
        };
        let word = self.waves[wave].registers.read_lane_word(lane, src)?;
        let [low, _] = word
            .bf16_halves(&mut self.arena)
            .ok_or(EvalError::InvalidBf16Output { address: start })?;
        self.global.store_bf16(start, low)
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
            let value = self.waves[wave].registers.read_lane_word(lane, reg)?;
            self.global
                .store_dword(word_address, value, &mut self.arena)?;
        }
        Ok(())
    }
}

/// The 16 bits at the 2-byte aligned `start`, zero-extended: a bf16 element as the low half of
/// a word whose high half is +0, or the 16 bits of a concrete word.
pub(super) fn load_ushort(
    global: &GlobalMemory,
    arena: &mut ExprArena,
    lane: usize,
    start: u64,
) -> Result<Word, EvalError> {
    let high_half = start % 4 == 2;
    Ok(match global.load_dword(start - start % 4, arena)? {
        Word::Bf16 { low, high } => Word::Bf16 {
            low: if high_half { high } else { low },
            high: arena.real(Real::zero()),
        },
        Word::Value(value) => {
            let bits = concrete_word(arena, value).ok_or(EvalError::NotBf16 { lane })?;
            let half = if high_half { bits >> 16 } else { bits & 0xffff };
            Word::Value(arena.int(i64::from(half)))
        }
    })
}
