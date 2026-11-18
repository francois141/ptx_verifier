//! The input bits a bit of a 32-bit word is built from. Shifts and byte permutes move bits,
//! masks keep or clear them, and xors combine them, so each bit these operations compute is a
//! constant xor some input bits.

use std::collections::{BTreeSet, HashMap};

use super::is_word32;
use crate::symbolic_full::{self as full, ByteTake};

const WORD_BITS: u32 = 32;

/// Bit `index` of the input element `word`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub(super) struct InputBit {
    pub(super) word: full::ExprId,
    pub(super) index: u32,
}

/// `constant` xor every bit of `inputs`; a set, since a bit xored twice cancels.
#[derive(Debug, Clone)]
pub(super) struct Bit {
    pub(super) constant: bool,
    pub(super) inputs: BTreeSet<InputBit>,
}

impl Bit {
    fn constant(constant: bool) -> Bit {
        Bit {
            constant,
            inputs: BTreeSet::new(),
        }
    }

    fn xor(self, other: Bit) -> Bit {
        Bit {
            constant: self.constant ^ other.constant,
            inputs: &self.inputs ^ &other.inputs,
        }
    }
}

/// Reads the bits of one arena's words, remembering each: a word reaches the same bit of an
/// operand along several paths.
pub(super) struct BitReader<'a> {
    arena: &'a full::ExprArena,
    read: HashMap<(full::ExprId, u32), Option<Bit>>,
}

impl<'a> BitReader<'a> {
    pub(super) fn new(arena: &'a full::ExprArena) -> Self {
        BitReader {
            arena,
            read: HashMap::new(),
        }
    }

    /// Bit `index` of the word `id`; `None` when another operation than those above, or one
    /// not on 32-bit words, computes it.
    pub(super) fn bit(&mut self, id: full::ExprId, index: u32) -> Option<Bit> {
        let key = (self.arena.value(id), index);
        if let Some(bit) = self.read.get(&key) {
            return bit.clone();
        }
        let bit = stacker::maybe_grow(64 * 1024, 8 * 1024 * 1024, || self.compute(key.0, index));
        self.read.insert(key, bit.clone());
        bit
    }

    fn compute(&mut self, id: full::ExprId, index: u32) -> Option<Bit> {
        use full::ExprNode::*;
        let arena = self.arena;
        match *arena.node(id) {
            IntConst(word) => Some(Bit::constant(word >> index & 1 == 1)),
            // An input element that a 32-bit operation reads is a 32-bit word.
            InputElement { .. } => Some(Bit {
                constant: false,
                inputs: BTreeSet::from([InputBit { word: id, index }]),
            }),
            _ if !arena.ty(id).is_some_and(is_word32) => None,

            BitXor(a, b) => Some(self.bit(a, index)?.xor(self.bit(b, index)?)),
            BitAnd(a, b) => self.masked(a, b, index),
            Shl(a, amount) => self.shifted(a, index.checked_sub(self.amount(amount)?)),
            LShr(a, amount) => self.shifted(a, index.checked_add(self.amount(amount)?)),
            Prmt { a, b, selector } => {
                let from = selector.bytes()[(index / 8) as usize];
                let bit = match from.take {
                    ByteTake::Value => index % 8,
                    ByteTake::Sign => 7,
                };
                self.bit(from.operand.of(a, b), 8 * from.byte + bit)
            }
            _ => None,
        }
    }

    /// Bit `index` of `a & b`, where one side's bit is constant: 1 keeps the other side's bit,
    /// 0 clears it. The mask is usually `b`, so it is read first and a cleared bit skips `a`.
    fn masked(&mut self, a: full::ExprId, b: full::ExprId, index: u32) -> Option<Bit> {
        let mask = self.bit(b, index)?;
        let (mask, other) = match mask.inputs.is_empty() {
            true => (mask, a),
            false => (self.bit(a, index)?, b),
        };
        match (mask.inputs.is_empty(), mask.constant) {
            (true, true) => self.bit(other, index),
            (true, false) => Some(Bit::constant(false)),
            (false, _) => None,
        }
    }

    /// Bit `index` of the shifted word `id`, or 0 when the shift brings it from outside the word.
    fn shifted(&mut self, id: full::ExprId, index: Option<u32>) -> Option<Bit> {
        match index.filter(|&index| index < WORD_BITS) {
            Some(index) => self.bit(id, index),
            None => Some(Bit::constant(false)),
        }
    }

    /// A shift's constant amount.
    fn amount(&self, amount: full::ExprId) -> Option<u32> {
        u32::try_from(self.arena.as_int_const(amount)?).ok()
    }
}
