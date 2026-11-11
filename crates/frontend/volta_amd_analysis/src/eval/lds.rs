//! Local data share (LDS) memory shared by the workgroup's waves.
//! DS instructions read and write this memory one lane at a time.

use std::collections::BTreeMap;
use std::fmt;

use volta_expr::ExprId;

use crate::ir::InstrId;

use super::EvalError;
use super::wave::WaveId;

/// One lane's access of an LDS word: the wave and lane that issued it, at instruction `pc`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct LdsLaneAccess {
    pub wave: WaveId,
    pub lane: usize,
    pub pc: InstrId,
}

/// Two lanes of one wave writing the LDS word at byte `address` in one instruction, whose
/// stores land in no specified order.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct LdsRace {
    pub address: u32,
    pub earlier: LdsLaneAccess,
    pub later: LdsLaneAccess,
}

impl fmt::Display for LdsRace {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let (earlier, later) = (self.earlier, self.later);
        write!(
            f,
            "LDS race at {:#x}: wave {} lanes {} and {} both write it at instruction {}, in no \
             specified order",
            self.address, earlier.wave.0, earlier.lane, later.lane, later.pc.0
        )
    }
}

/// Each workgroup's `size` bytes of LDS as words keyed by byte address. Transfers preserve
/// concrete words and symbolic expressions; only the consuming arithmetic interprets them.
/// Writes take effect at issue, while the event graph checks their ordering.
#[derive(Debug)]
pub(super) struct Lds {
    size: u32,
    words: Vec<BTreeMap<u32, ExprId>>,
    selected: usize,
}

impl Lds {
    pub fn new(size: u32, workgroups: usize) -> Self {
        Self {
            size,
            words: vec![BTreeMap::new(); workgroups],
            selected: 0,
        }
    }

    /// Select the workgroup whose private LDS a data transfer reads or writes.
    pub(super) fn select(&mut self, workgroup: usize) {
        self.selected = workgroup;
    }

    /// Check alignment and bounds, then return the byte address of each 32-bit word.
    pub(super) fn word_addresses(
        &self,
        address: u64,
        word_count: u32,
    ) -> Result<Vec<u32>, EvalError> {
        let access_size = 4 * u64::from(word_count);
        let end_address = address + access_size;
        let is_aligned = address.is_multiple_of(4);
        let fits_in_lds = end_address <= u64::from(self.size);

        if !is_aligned || !fits_in_lds {
            return Err(EvalError::LdsAccess {
                address,
                size: self.size,
            });
        }

        let mut addresses = Vec::with_capacity(word_count as usize);
        for word_index in 0..word_count {
            let word_address = address as u32 + 4 * word_index;
            addresses.push(word_address);
        }

        Ok(addresses)
    }

    pub(super) fn read(&self, address: u64, word_count: u32) -> Result<Vec<ExprId>, EvalError> {
        let addresses = self.word_addresses(address, word_count)?;
        let mut values = Vec::with_capacity(addresses.len());

        for word_address in addresses {
            let value = self.words[self.selected]
                .get(&word_address)
                .copied()
                .ok_or(EvalError::UninitializedLds {
                    address: word_address,
                })?;
            values.push(value);
        }
        Ok(values)
    }

    pub(super) fn write(&mut self, address: u64, values: &[ExprId]) -> Result<(), EvalError> {
        let addresses = self.word_addresses(address, values.len() as u32)?;
        for (word_address, &value) in addresses.into_iter().zip(values) {
            self.words[self.selected].insert(word_address, value);
        }
        Ok(())
    }
}
