//! Local data share (LDS) memory shared by the workgroup's waves.
//! DS instructions read and write this memory one lane at a time.

use std::collections::BTreeMap;

use volta_expr::ExprId;

use super::EvalError;

/// The workgroup's `size` bytes of LDS as 32-bit words keyed by byte address. A write takes
/// effect at once, so a wave that reads after a barrier observes every write before it.
#[derive(Debug)]
pub(super) struct Lds {
    size: u32,
    words: BTreeMap<u32, ExprId>,
}

impl Lds {
    pub fn new(size: u32) -> Self {
        Self {
            size,
            words: BTreeMap::new(),
        }
    }

    /// Check alignment and bounds, then return the byte address of each 32-bit word.
    fn word_addresses(&self, address: u64, word_count: u32) -> Result<Vec<u32>, EvalError> {
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
            let value =
                self.words
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
            self.words.insert(word_address, value);
        }
        Ok(())
    }
}
