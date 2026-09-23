//! Byte-addressed granule memory.
//!
//! Memory is a map from byte address to *granule*: a value tagged with the
//! width (in bytes) it was written at. Reads normally match a granule
//! exactly, with sanctioned exceptions that arise from how nvcc handles
//! packed data (f16 pairs in 32 bits, f32 pairs in 64 bits on sm_100+, and
//! byte-granular fp8 arrays combined into wider vector-load lanes):
//!
//! - a double-width read (2, 4, or 8 bytes) over two adjacent same-width
//!   scalar granules yields a packed `Value::Pair`,
//! - similarly, a 4-byte read over two adjacent 2-byte `Pair` granules
//!   yields a packed `Value::Quad` (the fp8 case: each `Pair` already
//!   holds two independent byte-valued lanes, `Quad` holds four),
//! - a half-width read of either half of a 2-, 4-, or 8-byte `Pair`
//!   granule yields that half (writes split such granules on demand), and
//! - a half-width (2-byte) read of either half of a 4-byte `Quad` granule
//!   yields that half as a `Pair` (writes split on demand, same as above),
//!   and a 1-byte read of any of its four lanes yields that lane as a
//!   `Scalar`.
//!
//! Any other reinterpretation (e.g. reading half of an f32) is an error, as
//! is reading bytes that were never written. Bounds are *not* checked here;
//! the interpreter validates accesses against declared regions first.

use std::collections::HashMap;

use crate::eval::value::{MbarrierId, Value};
use crate::symbolic::ExprId;

/// What kind of granule a `Reinterpret` error's colliding access found -
/// used only to describe the collision in an error message.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GranuleKind {
    Scalar,
    Pair,
    Quad,
}

/// Widest granule we ever store (8 bytes); bounds the overlap scans.
const MAX_WIDTH: u64 = 8;

/// A single granule: `width` bytes holding `value`.
///
/// `dirty` distinguishes values the program stored from values placed by
/// analysis setup (initial inputs, lazily materialized input symbols); the
/// dirty cells of an output array are the kernel's output footprint.
#[derive(Debug, Clone, Copy)]
struct Cell {
    width: u64,
    value: Value,
    dirty: bool,
}

/// Why a memory access failed. The interpreter attaches thread/pc/space.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MemAccessError {
    /// Read of bytes never written (address of the first missing byte).
    Uninitialized { addr: u64 },
    /// Access at a width incompatible with the granule(s) present.
    /// `found` describes the colliding granule: its start, width, and kind.
    Reinterpret {
        addr: u64,
        width: u64,
        found: Option<(u64, u64, GranuleKind)>,
    },
    /// An ordinary (non-`Mbarrier`) write exactly covered a granule holding
    /// an `mbarrier` object, at the given granule start. Ordinary program
    /// data must never silently clobber a live barrier - `mbarrier.inval`
    /// must run first (whatever replaces the granule afterward is then
    /// ordinary data, not this error).
    MbarrierOverwrite { addr: u64 },
    /// An `mbarrier` operation other than `init` targeted an address with
    /// no live `mbarrier` object (never initialized, already invalidated,
    /// or holding ordinary data) - PTX ISA 9.7.14.16: undefined behavior.
    NoLiveMbarrier { addr: u64 },
}

/// One memory space (global, shared, or one thread's local).
#[derive(Debug, Clone, Default)]
pub struct Memory {
    cells: HashMap<u64, Cell>,
}

impl Memory {
    pub fn new() -> Self {
        Self::default()
    }

    /// Read `width` bytes at `addr`.
    pub fn read(&self, addr: u64, width: u64) -> Result<Value, MemAccessError> {
        // Exact granule match.
        if let Some(cell) = self.cells.get(&addr)
            && cell.width == width
        {
            return Ok(cell.value);
        }

        // Double-width read (2, 4, or 8 bytes) combining two adjacent
        // half-width scalars into a pair. (A plain 2-byte read of an
        // ordinary 2-byte-granule array - e.g. f16 - already hit the exact
        // match above, so this only fires when no such granule exists:
        // precisely the byte-granular-array case.)
        if matches!(width, 2 | 4 | 8) {
            let half = width / 2;
            if let (Some(lo), Some(hi)) = (self.cells.get(&addr), self.cells.get(&(addr + half)))
                && let (
                    Cell {
                        width: lo_width,
                        value: Value::Scalar(l),
                        ..
                    },
                    Cell {
                        width: hi_width,
                        value: Value::Scalar(h),
                        ..
                    },
                ) = (lo, hi)
                && *lo_width == half
                && *hi_width == half
            {
                return Ok(Value::Pair(*l, *h));
            }
        }

        // 4-byte read combining four adjacent 1-byte scalars directly into
        // a `Quad` - the case `materialize_input` actually produces
        // (byte-granular arrays materialize one independent 1-byte
        // `Scalar` per element, never pre-combined), and so the one that
        // matters for `ld.global.v2.b32`'s per-lane 4-byte read over a
        // fresh fp8 array.
        if width == 4
            && let (Some(c0), Some(c1), Some(c2), Some(c3)) = (
                self.cells.get(&addr),
                self.cells.get(&(addr + 1)),
                self.cells.get(&(addr + 2)),
                self.cells.get(&(addr + 3)),
            )
            && let (
                Cell {
                    width: 1,
                    value: Value::Scalar(b0),
                    ..
                },
                Cell {
                    width: 1,
                    value: Value::Scalar(b1),
                    ..
                },
                Cell {
                    width: 1,
                    value: Value::Scalar(b2),
                    ..
                },
                Cell {
                    width: 1,
                    value: Value::Scalar(b3),
                    ..
                },
            ) = (c0, c1, c2, c3)
        {
            return Ok(Value::Quad(*b0, *b1, *b2, *b3));
        }

        // 4-byte read combining two adjacent 2-byte `Pair` granules (each
        // already two independent byte lanes) into a `Quad` - the case
        // that arises after a write has split a `Quad` down to two
        // `Pair`s (`split_pair`) and a later read reassembles the full
        // 4 bytes.
        if width == 4
            && let (Some(lo), Some(hi)) = (self.cells.get(&addr), self.cells.get(&(addr + 2)))
            && let (
                Cell {
                    width: 2,
                    value: Value::Pair(b0, b1),
                    ..
                },
                Cell {
                    width: 2,
                    value: Value::Pair(b2, b3),
                    ..
                },
            ) = (lo, hi)
        {
            return Ok(Value::Quad(*b0, *b1, *b2, *b3));
        }

        // Half-width read (1, 2, or 4 bytes) of one half of a pair granule.
        if matches!(width, 1 | 2 | 4) {
            let pair_width = width * 2;
            if let Some(Cell {
                width: cell_width,
                value: Value::Pair(lo, _),
                ..
            }) = self.cells.get(&addr)
                && *cell_width == pair_width
            {
                return Ok(Value::Scalar(*lo));
            }
            if addr >= width
                && let Some(Cell {
                    width: cell_width,
                    value: Value::Pair(_, hi),
                    ..
                }) = self.cells.get(&(addr - width))
                && *cell_width == pair_width
            {
                return Ok(Value::Scalar(*hi));
            }
        }

        // 2-byte read of one half of a 4-byte `Quad` granule, yielding that
        // half as a `Pair` (the reverse of the combine above - `mov.b32
        // {h0,h1}, r` splitting a byte-granular 4-byte load back down).
        if width == 2 {
            if let Some(Cell {
                width: 4,
                value: Value::Quad(b0, b1, _, _),
                ..
            }) = self.cells.get(&addr)
            {
                return Ok(Value::Pair(*b0, *b1));
            }
            if addr >= 2
                && let Some(Cell {
                    width: 4,
                    value: Value::Quad(_, _, b2, b3),
                    ..
                }) = self.cells.get(&(addr - 2))
            {
                return Ok(Value::Pair(*b2, *b3));
            }
        }

        // 1-byte read of a single lane of a 4-byte `Quad` granule, yielding
        // that lane as a `Scalar`. This is the finest-grained reverse of the
        // combine above: `ld.shared.u8` picking one fp8 element back out of
        // a word a 16-byte `cp.async` deposited as four packed byte lanes.
        if width == 1 {
            for lane in 0..4 {
                let Some(start) = addr.checked_sub(lane) else {
                    break;
                };
                if let Some(Cell {
                    width: 4,
                    value: Value::Quad(b0, b1, b2, b3),
                    ..
                }) = self.cells.get(&start)
                {
                    let lanes = [b0, b1, b2, b3];
                    return Ok(Value::Scalar(*lanes[lane as usize]));
                }
            }
        }

        // Failed: distinguish "bytes present at another width" from "missing".
        for byte in addr..addr + width {
            if let Some(start) = self.covering_cell(byte) {
                return Err(MemAccessError::Reinterpret {
                    addr,
                    width,
                    found: self.describe_cell(start),
                });
            }
        }
        Err(MemAccessError::Uninitialized { addr })
    }

    /// Write `width` bytes at `addr` on behalf of the program (marks the
    /// granule dirty).
    pub fn write(&mut self, addr: u64, width: u64, value: Value) -> Result<(), MemAccessError> {
        self.put(addr, width, value, true)
    }

    /// Place an analysis-setup value (initial input or module global);
    /// the granule is not part of the program's output footprint.
    pub fn init(&mut self, addr: u64, width: u64, value: Value) -> Result<(), MemAccessError> {
        self.put(addr, width, value, false)
    }

    /// Whether any granule starts at `addr` (used to avoid re-materializing
    /// lazily-created input symbols).
    pub fn has_cell_at(&self, addr: u64) -> bool {
        self.cells.contains_key(&addr)
    }

    /// Read the `mbarrier` handle at `addr`, erroring if there isn't a
    /// live one there (PTX ISA 9.7.14.16: every `mbarrier` op but `init`
    /// on an uninitialized object is undefined behavior).
    pub fn read_mbarrier(&self, addr: u64) -> Result<MbarrierId, MemAccessError> {
        match self.cells.get(&addr) {
            Some(Cell {
                width: 8,
                value: Value::Mbarrier(id),
                ..
            }) => Ok(*id),
            _ => Err(MemAccessError::NoLiveMbarrier { addr }),
        }
    }

    /// `mbarrier.inval`: the sanctioned way to retire a live `mbarrier`
    /// object, removing the granule outright (not replacing it with
    /// another value) so its bytes can later be repurposed - by an
    /// ordinary write or a fresh `mbarrier.init` - without `put`'s
    /// overwrite guard refusing it.
    pub fn invalidate_mbarrier(&mut self, addr: u64) -> Result<(), MemAccessError> {
        self.read_mbarrier(addr)?;
        self.cells.remove(&addr);
        Ok(())
    }

    /// The dirty granules (program-written), as `(addr, width, value)`.
    pub fn dirty_cells(&self) -> impl Iterator<Item = (u64, u64, Value)> + '_ {
        self.cells
            .iter()
            .filter(|(_, c)| c.dirty)
            .map(|(&addr, c)| (addr, c.width, c.value))
    }

    /// Store a granule, replacing fully-covered granules and splitting
    /// partially-covered `Pair` granules. A partial overlap with any other
    /// granule is a reinterpretation error.
    fn put(
        &mut self,
        addr: u64,
        width: u64,
        value: Value,
        dirty: bool,
    ) -> Result<(), MemAccessError> {
        let end = addr + width;
        loop {
            let mut covered: Vec<u64> = Vec::new();
            let mut partial: Option<u64> = None;

            let scan_start = addr.saturating_sub(MAX_WIDTH - 1);
            for start in scan_start..end {
                let Some(cell) = self.cells.get(&start) else {
                    continue;
                };
                let cell_end = start + cell.width;
                if cell_end <= addr || start >= end {
                    continue; // no overlap
                }
                if start >= addr && cell_end <= end {
                    if matches!(cell.value, Value::Mbarrier(_))
                        && !matches!(value, Value::Mbarrier(_))
                    {
                        return Err(MemAccessError::MbarrierOverwrite { addr: start });
                    }
                    covered.push(start);
                } else {
                    partial = Some(start);
                    break;
                }
            }

            if let Some(start) = partial {
                // Only a pair granule can be split to resolve a partial
                // overlap; anything else is a reinterpretation.
                self.split_pair(start, addr, width)?;
                continue; // re-scan with the split applied
            }

            for start in covered {
                self.cells.remove(&start);
            }
            self.cells.insert(
                addr,
                Cell {
                    width,
                    value,
                    dirty,
                },
            );
            return Ok(());
        }
    }

    /// Split the granule at `start` to resolve a partial overlap:
    /// a 2-, 4-, or 8-byte `Pair` splits into two half-width scalars, and a
    /// 4-byte `Quad` splits into two 2-byte `Pair`s (each still two
    /// independent byte lanes - a further partial overlap into `put`'s
    /// caller loop re-scans and, if needed, splits one of those `Pair`s
    /// again via the first arm). `(addr, width)` identify the offending
    /// access for error reporting.
    fn split_pair(&mut self, start: u64, addr: u64, width: u64) -> Result<(), MemAccessError> {
        match self.cells.get(&start) {
            Some(Cell {
                width: pair_width @ (2 | 4 | 8),
                value: Value::Pair(lo, hi),
                dirty,
            }) => {
                let half = *pair_width / 2;
                let (lo, hi, dirty) = (*lo, *hi, *dirty);
                self.cells.remove(&start);
                self.cells.insert(
                    start,
                    Cell {
                        width: half,
                        value: Value::Scalar(lo),
                        dirty,
                    },
                );
                self.cells.insert(
                    start + half,
                    Cell {
                        width: half,
                        value: Value::Scalar(hi),
                        dirty,
                    },
                );
                Ok(())
            }
            Some(Cell {
                width: 4,
                value: Value::Quad(b0, b1, b2, b3),
                dirty,
            }) => {
                let (b0, b1, b2, b3, dirty) = (*b0, *b1, *b2, *b3, *dirty);
                self.cells.remove(&start);
                self.cells.insert(
                    start,
                    Cell {
                        width: 2,
                        value: Value::Pair(b0, b1),
                        dirty,
                    },
                );
                self.cells.insert(
                    start + 2,
                    Cell {
                        width: 2,
                        value: Value::Pair(b2, b3),
                        dirty,
                    },
                );
                Ok(())
            }
            _ => Err(MemAccessError::Reinterpret {
                addr,
                width,
                found: self.describe_cell(start),
            }),
        }
    }

    /// Find the granule covering `byte`, if any.
    /// The scalar granule starting at `start`, as `(width, value, dirty)`.
    pub fn scalar_cell(&self, start: u64) -> Option<(u64, ExprId, bool)> {
        match self.cells.get(&start) {
            Some(Cell {
                width,
                value: Value::Scalar(e),
                dirty,
            }) => Some((*width, *e, *dirty)),
            _ => None,
        }
    }

    /// Replace the granule at `start` by two half-width scalars holding
    /// `lo` and `hi`, preserving its dirtiness. Used by the interpreter to
    /// split a *concrete* scalar (whose halves it can compute exactly) that
    /// a half-width access would otherwise reinterpret, e.g. the zero word
    /// a `cp.async` zero-fill left where an epilogue then stores 16-bit
    /// results.
    pub fn split_scalar(&mut self, start: u64, lo: ExprId, hi: ExprId) {
        let Some(cell) = self.cells.remove(&start) else {
            return;
        };
        let half = cell.width / 2;
        self.cells.insert(
            start,
            Cell {
                width: half,
                value: Value::Scalar(lo),
                dirty: cell.dirty,
            },
        );
        self.cells.insert(
            start + half,
            Cell {
                width: half,
                value: Value::Scalar(hi),
                dirty: cell.dirty,
            },
        );
    }

    /// `(start, width, kind)` of the granule starting at `start`.
    fn describe_cell(&self, start: u64) -> Option<(u64, u64, GranuleKind)> {
        self.cells.get(&start).map(|cell| {
            let kind = match cell.value {
                Value::Pair(_, _) => GranuleKind::Pair,
                Value::Quad(..) => GranuleKind::Quad,
                _ => GranuleKind::Scalar,
            };
            (start, cell.width, kind)
        })
    }

    fn covering_cell(&self, byte: u64) -> Option<u64> {
        let scan_start = byte.saturating_sub(MAX_WIDTH - 1);
        for start in scan_start..=byte {
            if let Some(cell) = self.cells.get(&start)
                && start + cell.width > byte
            {
                return Some(start);
            }
        }
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::eval::value::MbarrierId;
    use crate::symbolic::ExprArena;

    fn scalars(arena: &mut ExprArena, n: i64) -> Value {
        Value::Scalar(arena.int(n))
    }

    #[test]
    fn test_mbarrier_roundtrip() {
        let mut mem = Memory::new();
        let v = Value::Mbarrier(MbarrierId(0));
        mem.write(0x200, 8, v).unwrap();
        assert_eq!(mem.read(0x200, 8).unwrap(), v);
    }

    #[test]
    fn test_ordinary_write_cannot_overwrite_a_live_mbarrier() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        mem.write(0x200, 8, Value::Mbarrier(MbarrierId(0))).unwrap();
        assert_eq!(
            mem.write(0x200, 8, scalars(&mut arena, 1)),
            Err(MemAccessError::MbarrierOverwrite { addr: 0x200 })
        );
        // The mbarrier must still be intact: the rejected write didn't land.
        assert_eq!(mem.read(0x200, 8).unwrap(), Value::Mbarrier(MbarrierId(0)));
    }

    #[test]
    fn test_mbarrier_init_can_claim_ordinary_memory() {
        // The reverse direction is unguarded: claiming a fresh (or
        // previously-ordinary) region for a new mbarrier is legitimate.
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        mem.write(0x200, 8, scalars(&mut arena, 1)).unwrap();
        let v = Value::Mbarrier(MbarrierId(1));
        mem.write(0x200, 8, v).unwrap();
        assert_eq!(mem.read(0x200, 8).unwrap(), v);
    }

    #[test]
    fn test_exact_roundtrip() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let v = scalars(&mut arena, 42);
        mem.write(0x100, 4, v).unwrap();
        assert_eq!(mem.read(0x100, 4).unwrap(), v);
    }

    #[test]
    fn test_uninitialized_read() {
        let mem = Memory::new();
        assert_eq!(
            mem.read(0x100, 4),
            Err(MemAccessError::Uninitialized { addr: 0x100 })
        );
    }

    #[test]
    fn test_overwrite() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        mem.write(0x100, 4, scalars(&mut arena, 1)).unwrap();
        let v2 = scalars(&mut arena, 2);
        mem.write(0x100, 4, v2).unwrap();
        assert_eq!(mem.read(0x100, 4).unwrap(), v2);
    }

    #[test]
    fn test_combine_halves_into_pair() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lo = arena.param_symbol("lo");
        let hi = arena.param_symbol("hi");
        mem.write(0x10, 2, Value::Scalar(lo)).unwrap();
        mem.write(0x12, 2, Value::Scalar(hi)).unwrap();
        assert_eq!(mem.read(0x10, 4).unwrap(), Value::Pair(lo, hi));
    }

    #[test]
    fn test_split_pair_on_half_read() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lo = arena.param_symbol("lo");
        let hi = arena.param_symbol("hi");
        mem.write(0x10, 4, Value::Pair(lo, hi)).unwrap();
        assert_eq!(mem.read(0x10, 2).unwrap(), Value::Scalar(lo));
        assert_eq!(mem.read(0x12, 2).unwrap(), Value::Scalar(hi));
    }

    #[test]
    fn test_combine_words_into_wide_pair() {
        // Two adjacent f32 granules read as one 8-byte f32x2 pair.
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lo = arena.param_symbol("lo");
        let hi = arena.param_symbol("hi");
        mem.write(0x10, 4, Value::Scalar(lo)).unwrap();
        mem.write(0x14, 4, Value::Scalar(hi)).unwrap();
        assert_eq!(mem.read(0x10, 8).unwrap(), Value::Pair(lo, hi));
        // A 2-byte read of an f32 granule is still a reinterpretation.
        assert!(matches!(
            mem.read(0x10, 2),
            Err(MemAccessError::Reinterpret { .. })
        ));
    }

    #[test]
    fn test_split_wide_pair_on_word_read_and_write() {
        // An 8-byte f32x2 pair granule read and overwritten one f32 at a time.
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lo = arena.param_symbol("lo");
        let hi = arena.param_symbol("hi");
        mem.write(0x10, 8, Value::Pair(lo, hi)).unwrap();
        assert_eq!(mem.read(0x10, 4).unwrap(), Value::Scalar(lo));
        assert_eq!(mem.read(0x14, 4).unwrap(), Value::Scalar(hi));
        let new_hi = arena.param_symbol("new_hi");
        mem.write(0x14, 4, Value::Scalar(new_hi)).unwrap();
        assert_eq!(mem.read(0x10, 4).unwrap(), Value::Scalar(lo));
        assert_eq!(mem.read(0x14, 4).unwrap(), Value::Scalar(new_hi));
        assert_eq!(mem.read(0x10, 8).unwrap(), Value::Pair(lo, new_hi));
    }

    #[test]
    fn test_split_pair_on_half_write() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lo = arena.param_symbol("lo");
        let hi = arena.param_symbol("hi");
        mem.write(0x10, 4, Value::Pair(lo, hi)).unwrap();
        // Overwrite just the low half; the high half must survive.
        let new_lo = arena.param_symbol("new_lo");
        mem.write(0x10, 2, Value::Scalar(new_lo)).unwrap();
        assert_eq!(mem.read(0x10, 2).unwrap(), Value::Scalar(new_lo));
        assert_eq!(mem.read(0x12, 2).unwrap(), Value::Scalar(hi));
    }

    #[test]
    fn test_scalar_half_read_is_reinterpretation() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        mem.write(0x10, 4, scalars(&mut arena, 5)).unwrap();
        assert!(matches!(
            mem.read(0x10, 2),
            Err(MemAccessError::Reinterpret {
                addr: 0x10,
                width: 2,
                ..
            })
        ));
    }

    #[test]
    fn test_wide_write_replaces_halves() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        mem.write(0x10, 2, scalars(&mut arena, 1)).unwrap();
        mem.write(0x12, 2, scalars(&mut arena, 2)).unwrap();
        let v = scalars(&mut arena, 3);
        mem.write(0x10, 4, v).unwrap();
        assert_eq!(mem.read(0x10, 4).unwrap(), v);
        // Old halves are gone.
        assert!(matches!(
            mem.read(0x10, 2),
            Err(MemAccessError::Reinterpret {
                addr: 0x10,
                width: 2,
                ..
            })
        ));
    }

    #[test]
    fn test_partial_scalar_overlap_is_error() {
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        mem.write(0x10, 4, scalars(&mut arena, 1)).unwrap();
        // A 4-byte write overlapping half of the previous scalar granule.
        let v = scalars(&mut arena, 2);
        assert!(matches!(
            mem.write(0x12, 4, v),
            Err(MemAccessError::Reinterpret {
                addr: 0x12,
                width: 4,
                ..
            })
        ));
    }

    #[test]
    fn test_byte_read_of_each_quad_lane() {
        // The fp8 case: a 16-byte `cp.async` leaves 4-byte `Quad` granules
        // of four independent byte lanes, and `ld.shared.u8` then reads a
        // single lane back out.
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lanes = [arena.int(1), arena.int(2), arena.int(3), arena.int(4)];
        mem.write(0x10, 4, Value::Quad(lanes[0], lanes[1], lanes[2], lanes[3]))
            .unwrap();
        for (offset, lane) in lanes.iter().enumerate() {
            assert_eq!(
                mem.read(0x10 + offset as u64, 1).unwrap(),
                Value::Scalar(*lane)
            );
        }
    }

    #[test]
    fn test_byte_read_does_not_reach_past_a_quad() {
        // The lane scan walks back at most 3 bytes, so the byte just after
        // a `Quad` is uninitialized rather than a fifth lane.
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let v = Value::Quad(arena.int(1), arena.int(2), arena.int(3), arena.int(4));
        mem.write(0x10, 4, v).unwrap();
        assert_eq!(
            mem.read(0x14, 1),
            Err(MemAccessError::Uninitialized { addr: 0x14 })
        );
    }

    #[test]
    fn test_byte_write_into_a_quad_splits_to_lanes() {
        // The write side resolves the same partial overlap by splitting the
        // `Quad` into two `Pair`s and then one of those into two scalars;
        // the three untouched lanes survive.
        let mut arena = ExprArena::new();
        let mut mem = Memory::new();
        let lanes = [arena.int(1), arena.int(2), arena.int(3), arena.int(4)];
        mem.write(0x10, 4, Value::Quad(lanes[0], lanes[1], lanes[2], lanes[3]))
            .unwrap();
        let replacement = scalars(&mut arena, 9);
        mem.write(0x12, 1, replacement).unwrap();
        assert_eq!(mem.read(0x10, 1).unwrap(), Value::Scalar(lanes[0]));
        assert_eq!(mem.read(0x11, 1).unwrap(), Value::Scalar(lanes[1]));
        assert_eq!(mem.read(0x12, 1).unwrap(), replacement);
        assert_eq!(mem.read(0x13, 1).unwrap(), Value::Scalar(lanes[3]));
    }
}
