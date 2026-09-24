//! Tensor core types and lane-to-element fragment mappings.
//!
//! The PTX ISA defines how matrix elements are distributed across warp lanes
//! for each MMA shape. This module encodes those mappings so the evaluator
//! can compute per-thread results for tensor core instructions.

use std::fmt;

/// Matrix shape (M, N, K) for MMA operations.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct MmaShape {
    pub m: u32,
    pub n: u32,
    pub k: u32,
}

impl MmaShape {
    pub const fn new(m: u32, n: u32, k: u32) -> Self {
        Self { m, n, k }
    }

    /// Parse a shape string like "m16n8k16" or "m8n8".
    pub fn parse(s: &str) -> Option<Self> {
        let s = s.strip_prefix('m')?;
        let (m_str, rest) = s.split_once('n')?;
        let m: u32 = m_str.parse().ok()?;
        if let Some((n_str, k_str)) = rest.split_once('k') {
            let n: u32 = n_str.parse().ok()?;
            let k: u32 = k_str.parse().ok()?;
            Some(Self { m, n, k })
        } else {
            // Shape like "m8n8" (no k), used by ldmatrix
            let n: u32 = rest.parse().ok()?;
            Some(Self { m, n, k: 0 })
        }
    }
}

impl fmt::Display for MmaShape {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.k > 0 {
            write!(f, "m{}n{}k{}", self.m, self.n, self.k)
        } else {
            write!(f, "m{}n{}", self.m, self.n)
        }
    }
}

/// Row or column major layout.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MmaLayout {
    Row,
    Col,
}

impl MmaLayout {
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "row" => Some(Self::Row),
            "col" => Some(Self::Col),
            _ => None,
        }
    }
}

/// Which matrix operand for WMMA load/store.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MmaOperand {
    A,
    B,
    C,
    D,
}

impl MmaOperand {
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "a" => Some(Self::A),
            "b" => Some(Self::B),
            "c" => Some(Self::C),
            "d" => Some(Self::D),
            _ => None,
        }
    }
}

/// A single element in a thread's fragment: which matrix (row, col) it maps to,
/// and where in the register it lives.
#[derive(Debug, Clone, Copy)]
pub struct FragmentElement {
    /// Index of the register in the fragment vector (e.g., 0..3 for 4-reg fragment)
    pub reg_idx: usize,
    /// Matrix row this element corresponds to
    pub row: u32,
    /// Matrix column this element corresponds to
    pub col: u32,
    /// For packed types (f16 in b32): which half of the register (false=low, true=high).
    /// None for unpacked types (f32).
    pub high_half: Option<bool>,
    /// For four-way packed types (fp8 in b32): which of the four byte lanes
    /// (0 = lowest address/least-significant byte, .. 3 = highest), matching
    /// `Value::Quad`'s tuple order. `None` for every other packing.
    pub quad_lane: Option<u8>,
}

/// Compute the fragment-to-matrix-element mapping for mma.m16n8k16 with f16 types.
///
/// PTX ISA Section 9.7.14.5.8.
/// Returns the list of (reg_idx, row, col, high_half) for each element in the fragment.
pub mod m16n8k16_f16 {
    use super::FragmentElement;

    /// Matrix A fragment: 4 registers, each packing 2 f16 = 8 elements total.
    /// A is m16 x k16.
    pub fn matrix_a(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(8);
        for i in 0u32..8 {
            let row = if i < 2 || (4..6).contains(&i) {
                group_id
            } else {
                group_id + 8
            };
            let col = if i < 4 {
                thread_in_group * 2 + (i & 1)
            } else {
                thread_in_group * 2 + (i & 1) + 8
            };
            elements.push(FragmentElement {
                reg_idx: (i / 2) as usize,
                row,
                col,
                high_half: Some(i % 2 != 0),
                quad_lane: None,
            });
        }
        elements
    }

    /// Matrix B fragment: 2 registers, each packing 2 f16 = 4 elements total.
    /// B is k16 x n8.
    pub fn matrix_b(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(4);
        for i in 0u32..4 {
            let row = if i < 2 {
                thread_in_group * 2 + (i & 1)
            } else {
                thread_in_group * 2 + (i & 1) + 8
            };
            let col = group_id;
            elements.push(FragmentElement {
                reg_idx: (i / 2) as usize,
                row,
                col,
                high_half: Some(i % 2 != 0),
                quad_lane: None,
            });
        }
        elements
    }

    /// Accumulator C/D fragment for an `.f16` accumulator: the same four
    /// elements [`matrix_cd`] places, packed two to a register instead of
    /// occupying one f32 register each (PTX ISA 9.7.14.5.8). The order is
    /// register 0's low half, its high half, register 1's low half, its
    /// high half - `exec_mma` repacks the result by walking it in pairs.
    pub fn matrix_cd_f16(lane_id: u32) -> Vec<FragmentElement> {
        matrix_cd(lane_id)
            .into_iter()
            .enumerate()
            .map(|(i, elem)| FragmentElement {
                reg_idx: i / 2,
                high_half: Some(i % 2 != 0),
                ..elem
            })
            .collect()
    }

    /// Accumulator C/D fragment: 4 f32 registers = 4 elements.
    /// C/D is m16 x n8.
    pub fn matrix_cd(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(4);
        for i in 0u32..4 {
            let row = if i < 2 { group_id } else { group_id + 8 };
            let col = thread_in_group * 2 + (i & 1);
            elements.push(FragmentElement {
                reg_idx: i as usize,
                row,
                col,
                high_half: None, // f32, not packed
                quad_lane: None,
            });
        }
        elements
    }
}

/// Fragment mappings for `mma.m16n8k8` with `.tf32` multiplicands (PTX ISA
/// "Matrix Fragments for mma.m16n8k8", .tf32 rows). Each 32-bit register
/// holds one tf32 element, so `high_half` is always `None`.
pub mod m16n8k8_tf32 {
    use super::FragmentElement;

    /// Matrix A fragment: 4 registers, one tf32 each. A is m16 x k8.
    /// a0: (groupID, tig), a1: (groupID+8, tig), a2: (groupID, tig+4),
    /// a3: (groupID+8, tig+4).
    pub fn matrix_a(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        (0u32..4)
            .map(|i| FragmentElement {
                reg_idx: i as usize,
                row: if i % 2 == 0 { group_id } else { group_id + 8 },
                col: if i < 2 {
                    thread_in_group
                } else {
                    thread_in_group + 4
                },
                high_half: None,
                quad_lane: None,
            })
            .collect()
    }

    /// Matrix B fragment: 2 registers, one tf32 each. B is k8 x n8.
    /// b0: (k = tig, n = groupID), b1: (k = tig+4, n = groupID).
    pub fn matrix_b(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        (0u32..2)
            .map(|i| FragmentElement {
                reg_idx: i as usize,
                row: thread_in_group + 4 * i,
                col: group_id,
                high_half: None,
                quad_lane: None,
            })
            .collect()
    }

    /// Accumulator C/D fragment: identical to the m16n8k16 f16 shape.
    pub fn matrix_cd(lane_id: u32) -> Vec<FragmentElement> {
        super::m16n8k16_f16::matrix_cd(lane_id)
    }
}

/// Fragment mappings for `mma.m16n8k4` with `.tf32` multiplicands (PTX ISA
/// "Matrix Fragments for mma.m16n8k4", .tf32 rows).
pub mod m16n8k4_tf32 {
    use super::FragmentElement;

    /// Matrix A fragment: 2 registers, one tf32 each. A is m16 x k4.
    /// a0: (groupID, tig), a1: (groupID+8, tig).
    pub fn matrix_a(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        (0u32..2)
            .map(|i| FragmentElement {
                reg_idx: i as usize,
                row: group_id + 8 * i,
                col: thread_in_group,
                high_half: None,
                quad_lane: None,
            })
            .collect()
    }

    /// Matrix B fragment: 1 register. B is k4 x n8. b0: (k = tig, n = groupID).
    pub fn matrix_b(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        vec![FragmentElement {
            reg_idx: 0,
            row: thread_in_group,
            col: group_id,
            high_half: None,
            quad_lane: None,
        }]
    }

    /// Accumulator C/D fragment: identical to the m16n8k16 f16 shape.
    pub fn matrix_cd(lane_id: u32) -> Vec<FragmentElement> {
        super::m16n8k16_f16::matrix_cd(lane_id)
    }
}

/// Fragment mappings for `mma.m16n8k32` with `.e4m3` (fp8) multiplicands
/// (PTX ISA "Matrix Fragments for mma.m16n8k32", the `.s8`/`.u8`/`.e4m3`/
/// `.e5m2`/... row - four elements packed per 32-bit register, `quad_lane`
/// 0..3 low to high matching `Value::Quad`'s tuple order).
pub mod m16n8k32_e4m3 {
    use super::FragmentElement;

    /// Matrix A fragment: 4 registers, each packing 4 e4m3 = 16 elements
    /// total. A is m16 x k32.
    pub fn matrix_a(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(16);
        for i in 0u32..16 {
            let row = if (0..4).contains(&i) || (8..12).contains(&i) {
                group_id
            } else {
                group_id + 8
            };
            let col = if i < 8 {
                thread_in_group * 4 + (i & 0x3)
            } else {
                thread_in_group * 4 + (i & 0x3) + 16
            };
            elements.push(FragmentElement {
                reg_idx: (i / 4) as usize,
                row,
                col,
                high_half: None,
                quad_lane: Some((i % 4) as u8),
            });
        }
        elements
    }

    /// Matrix B fragment: 2 registers, each packing 4 e4m3 = 8 elements
    /// total. B is k32 x n8.
    pub fn matrix_b(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(8);
        for i in 0u32..8 {
            let row = if i < 4 {
                thread_in_group * 4 + (i & 0x3)
            } else {
                thread_in_group * 4 + (i & 0x3) + 16
            };
            let col = group_id;
            elements.push(FragmentElement {
                reg_idx: (i / 4) as usize,
                row,
                col,
                high_half: None,
                quad_lane: Some((i % 4) as u8),
            });
        }
        elements
    }

    /// Accumulator C/D fragment: identical to the m16n8k16 f16 shape.
    pub fn matrix_cd(lane_id: u32) -> Vec<FragmentElement> {
        super::m16n8k16_f16::matrix_cd(lane_id)
    }
}

/// Compute fragment mappings for wmma m16n16k16 with f16 inputs and f32 accumulators.
///
/// The WMMA API uses a different fragment layout than the MMA API.
/// PTX ISA Section 9.7.14.4.
///
/// For wmma.m16n16k16 with f16:
///   A: 8 registers (each f16x2), 16 elements
///   B: 8 registers (each f16x2), 16 elements
///   C/D (f32): 8 registers, 8 elements
///
/// The mapping follows the same groupID/threadID_in_group pattern.
pub mod m16n16k16_f16 {
    use super::FragmentElement;

    /// Matrix A fragment for wmma.load.a.sync with row layout.
    /// A is m16 x k16, thread gets 8 regs = 16 f16 elements.
    ///
    /// The wmma API with m16n16k16 distributes A's 16x16 elements
    /// across 32 threads. Each thread gets 16 elements (8 regs x 2 f16).
    /// groupID = laneid >> 2, threadID_in_group = laneid % 4
    pub fn matrix_a_row(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(16);
        for reg in 0u32..8 {
            for half in 0u32..2 {
                let i = reg * 2 + half;
                // Rows: first 8 elements in rows 0-7, next 8 in rows 8-15
                let row = if i < 8 { group_id } else { group_id + 8 };
                // Columns: distributed across 4 threads covering all 16 k-columns
                let col = thread_in_group + (i % 4) * 4;
                elements.push(FragmentElement {
                    reg_idx: reg as usize,
                    row,
                    col,
                    high_half: Some(half != 0),
                    quad_lane: None,
                });
            }
        }
        elements
    }

    /// Matrix B fragment for wmma.load.b.sync with row layout.
    /// B is k16 x n16.
    pub fn matrix_b_row(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(16);
        for reg in 0u32..8 {
            for half in 0u32..2 {
                let i = reg * 2 + half;
                let row = thread_in_group + (i % 4) * 4;
                let col = if i < 8 { group_id } else { group_id + 8 };
                elements.push(FragmentElement {
                    reg_idx: reg as usize,
                    row,
                    col,
                    high_half: Some(half != 0),
                    quad_lane: None,
                });
            }
        }
        elements
    }

    /// Accumulator C/D fragment (f32): 8 registers, 8 f32 elements.
    /// C/D is m16 x n16.
    pub fn matrix_cd_f32(lane_id: u32) -> Vec<FragmentElement> {
        let group_id = lane_id >> 2;
        let thread_in_group = lane_id % 4;
        let mut elements = Vec::with_capacity(8);
        for i in 0u32..8 {
            let row = if i < 4 { group_id } else { group_id + 8 };
            let col = thread_in_group * 4 + (i % 4);
            elements.push(FragmentElement {
                reg_idx: i as usize,
                row,
                col,
                high_half: None,
                quad_lane: None,
            });
        }
        elements
    }
}

/// Fragment mapping for `wgmma.mma_async.m64nNk16`'s accumulator matrix D
/// (PTX ISA 9.7.17.5.1.1.1, Figure 152). Unlike the fixed-`N` `mma.sync`/
/// `wmma` modules above, this is parameterized by a runtime `n`: the same
/// per-lane law holds for every `.m64n{8,16,...,256}k16` shape (confirmed
/// identical across the k8/k16/k32/k256 sibling figures - the accumulator
/// distribution depends only on the m64xN output shape, not k or dtype).
///
/// No textual formula exists in the PTX ISA for this - only the figure, no
/// `groupID`/`threadID_in_group`-style prose the way the older `mma.sync`
/// sections give (grepped the whole ISA doc for `wgmma` + `groupID`: zero
/// hits). The mapping below was transcribed by downloading and visually
/// inspecting the actual referenced image
/// (`https://docs.nvidia.com/cuda/parallel-thread-execution/_images/wgmma-64N16-D.png`)
/// rather than guessed - the same bar `eval::tcgen05_mma`'s swizzle tables
/// hold themselves to, for the same reason ("guessing here would risk
/// silently wrong tensor-core math") - and cross-checked two independent
/// ways: (1) the image's own `T0:{d0,d1}`/`T0:{d2,d3}` and `T32:{d0,d1}`
/// cells, and (2) the ISA text's footnote for the shape's last column
/// block (`X=N/2-4, Y=N/2-3, Z=N/2-2, W=N/2-1`) - both agree exactly with
/// the formula below, and it is a clean bijection (every `(row,col)`
/// covered by exactly one `(lane_id,reg_idx)`, verified by the
/// completeness test).
///
/// `.f32` accumulator only (one register per element, `n/2` registers per
/// thread) - the `.f16` accumulator (`n/4` packed `.f16x2` registers) is a
/// distinct, unimplemented layout, not needed by the real target kernel.
pub mod wgmma_m64n_k16 {
    use super::FragmentElement;

    /// `lane_id`: the thread's position within its 128-thread warpgroup
    /// (`t.0 % 128` - PTX ISA 9.7.17.1 defines a warpgroup as four
    /// contiguous warps starting at a warp-rank multiple of 4). `n`: the
    /// shape's N (8..=256, step 8). Returns exactly `n/2` elements,
    /// `reg_idx` 0..n/2-1.
    pub fn matrix_d(lane_id: u32, n: u32) -> Vec<FragmentElement> {
        let band = lane_id / 32; // which 16-row band (0..4) - one per warp
        let local = lane_id % 32;
        let s = local / 4; // row offset within an 8-row half-band (0..8)
        let t4 = local % 4; // column-pair selector within an 8-col block (0..4)
        (0..n / 2)
            .map(|reg_idx| {
                let k = reg_idx / 4; // column-block index (0..n/8)
                let rem = reg_idx % 4;
                let rh = rem / 2; // row-half: 0 = upper 8 rows of the band, 1 = lower 8
                let p = rem % 2; // column parity within the thread's 2-col pair
                FragmentElement {
                    reg_idx: reg_idx as usize,
                    row: 16 * band + 8 * rh + s,
                    col: 8 * k + 2 * t4 + p,
                    high_half: None,
                    quad_lane: None,
                }
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_shape_parse() {
        assert_eq!(MmaShape::parse("m16n8k16"), Some(MmaShape::new(16, 8, 16)));
        assert_eq!(
            MmaShape::parse("m16n16k16"),
            Some(MmaShape::new(16, 16, 16))
        );
        assert_eq!(MmaShape::parse("m8n8"), Some(MmaShape::new(8, 8, 0)));
        assert_eq!(MmaShape::parse("invalid"), None);
    }

    #[test]
    fn test_m16n8k16_cd_mapping() {
        // Thread 0: groupID=0, threadID_in_group=0
        let cd = m16n8k16_f16::matrix_cd(0);
        assert_eq!(cd.len(), 4);
        // c0: row=0, col=0
        assert_eq!((cd[0].row, cd[0].col), (0, 0));
        // c1: row=0, col=1
        assert_eq!((cd[1].row, cd[1].col), (0, 1));
        // c2: row=8, col=0
        assert_eq!((cd[2].row, cd[2].col), (8, 0));
        // c3: row=8, col=1
        assert_eq!((cd[3].row, cd[3].col), (8, 1));
    }

    #[test]
    fn test_m16n8k16_cd_thread4() {
        // Thread 4: groupID=1, threadID_in_group=0
        let cd = m16n8k16_f16::matrix_cd(4);
        assert_eq!((cd[0].row, cd[0].col), (1, 0));
        assert_eq!((cd[1].row, cd[1].col), (1, 1));
        assert_eq!((cd[2].row, cd[2].col), (9, 0));
        assert_eq!((cd[3].row, cd[3].col), (9, 1));
    }

    #[test]
    fn test_m16n8k16_a_thread0() {
        // Thread 0: groupID=0, threadID_in_group=0
        let a = m16n8k16_f16::matrix_a(0);
        assert_eq!(a.len(), 8);
        // a0: row=0, col=0 (i=0: i<2, col = 0*2+0 = 0)
        assert_eq!((a[0].row, a[0].col), (0, 0));
        // a1: row=0, col=1 (i=1: i<2, col = 0*2+1 = 1)
        assert_eq!((a[1].row, a[1].col), (0, 1));
        // a2: row=8, col=0 (i=2: not (i<2 || 4<=i<6), col = 0*2+0 = 0)
        assert_eq!((a[2].row, a[2].col), (8, 0));
        // a3: row=8, col=1
        assert_eq!((a[3].row, a[3].col), (8, 1));
        // a4: row=0, col=8 (i=4: 4<=i<6, col = 0*2+0+8 = 8)
        assert_eq!((a[4].row, a[4].col), (0, 8));
        // a5: row=0, col=9
        assert_eq!((a[5].row, a[5].col), (0, 9));
        // a6: row=8, col=8
        assert_eq!((a[6].row, a[6].col), (8, 8));
        // a7: row=8, col=9
        assert_eq!((a[7].row, a[7].col), (8, 9));
    }

    #[test]
    fn test_m16n8k8_tf32_thread5_covers_the_isa_table() {
        // lane 5: groupID 1, threadID_in_group 1
        let a = m16n8k8_tf32::matrix_a(5);
        let a_cells: Vec<(usize, u32, u32)> = a.iter().map(|e| (e.reg_idx, e.row, e.col)).collect();
        assert_eq!(a_cells, vec![(0, 1, 1), (1, 9, 1), (2, 1, 5), (3, 9, 5)]);
        let b = m16n8k8_tf32::matrix_b(5);
        let b_cells: Vec<(usize, u32, u32)> = b.iter().map(|e| (e.reg_idx, e.row, e.col)).collect();
        assert_eq!(b_cells, vec![(0, 1, 1), (1, 5, 1)]);
        assert!(a.iter().chain(b.iter()).all(|e| e.high_half.is_none()));
        // Every A element is owned by exactly one lane.
        let mut seen = std::collections::HashSet::new();
        for lane in 0..32 {
            for e in m16n8k8_tf32::matrix_a(lane) {
                assert!(seen.insert((e.row, e.col)), "duplicate A element");
            }
        }
        assert_eq!(seen.len(), 16 * 8);
    }

    #[test]
    fn test_m16n8k4_tf32_thread5() {
        let a = m16n8k4_tf32::matrix_a(5);
        let a_cells: Vec<(usize, u32, u32)> = a.iter().map(|e| (e.reg_idx, e.row, e.col)).collect();
        assert_eq!(a_cells, vec![(0, 1, 1), (1, 9, 1)]);
        let b = m16n8k4_tf32::matrix_b(5);
        assert_eq!((b[0].reg_idx, b[0].row, b[0].col), (0, 1, 1));
        let mut seen = std::collections::HashSet::new();
        for lane in 0..32 {
            for e in m16n8k4_tf32::matrix_b(lane) {
                assert!(seen.insert((e.row, e.col)), "duplicate B element");
            }
        }
        assert_eq!(seen.len(), 4 * 8);
    }

    #[test]
    fn test_m16n8k16_b_thread0() {
        // Thread 0: groupID=0, threadID_in_group=0
        let b = m16n8k16_f16::matrix_b(0);
        assert_eq!(b.len(), 4);
        // b0: row=0, col=0 (i=0: i<2, row=0*2+0=0, col=0)
        assert_eq!((b[0].row, b[0].col), (0, 0));
        // b1: row=1, col=0
        assert_eq!((b[1].row, b[1].col), (1, 0));
        // b2: row=8, col=0 (i=2: i>=2, row=0*2+0+8=8)
        assert_eq!((b[2].row, b[2].col), (8, 0));
        // b3: row=9, col=0
        assert_eq!((b[3].row, b[3].col), (9, 0));
    }

    /// Lane 0, n=16: figure's `T0:{d0,d1}` (row 0, cols 0-1), `T0:{d2,d3}`
    /// (row 8, cols 0-1), `T0:{d4,d5}` (row 0, cols 8-9), `T0:{d6,d7}` (row
    /// 8, cols 8-9) - transcribed directly from Figure 152.
    #[test]
    fn test_wgmma_matrix_d_lane0_n16() {
        let d = wgmma_m64n_k16::matrix_d(0, 16);
        assert_eq!(d.len(), 8);
        let cells: Vec<(usize, u32, u32)> = d.iter().map(|e| (e.reg_idx, e.row, e.col)).collect();
        assert_eq!(
            cells,
            vec![
                (0, 0, 0),
                (1, 0, 1),
                (2, 8, 0),
                (3, 8, 1),
                (4, 0, 8),
                (5, 0, 9),
                (6, 8, 8),
                (7, 8, 9),
            ]
        );
    }

    /// Lane 32 (band 1 - the second warp of the warpgroup), n=16: same
    /// intra-band pattern as lane 0, shifted to rows 16/24 - figure's
    /// `T32:{d0,d1}` at row 16.
    #[test]
    fn test_wgmma_matrix_d_lane32_n16() {
        let d = wgmma_m64n_k16::matrix_d(32, 16);
        assert_eq!((d[0].row, d[0].col), (16, 0));
        assert_eq!((d[1].row, d[1].col), (16, 1));
        assert_eq!((d[2].row, d[2].col), (24, 0));
        assert_eq!((d[3].row, d[3].col), (24, 1));
    }

    /// Every `(row, col)` of the m64xN output tile is covered by exactly
    /// one `(lane_id, reg_idx)` pair, for every shape the real corpus
    /// kernel's `.m64n{8,...,256}k16` family can use - a clean bijection,
    /// no gaps or overlaps.
    #[test]
    fn test_wgmma_matrix_d_covers_grid_with_no_overlap() {
        for n in [8u32, 16, 256] {
            let mut seen = std::collections::HashSet::new();
            for lane in 0..128 {
                for e in wgmma_m64n_k16::matrix_d(lane, n) {
                    assert!(e.row < 64, "row {} out of range for n={n}", e.row);
                    assert!(e.col < n, "col {} out of range for n={n}", e.col);
                    assert!(
                        seen.insert((e.row, e.col)),
                        "duplicate (row={}, col={}) for n={n}",
                        e.row,
                        e.col
                    );
                }
            }
            assert_eq!(seen.len(), (64 * n) as usize, "incomplete coverage for n={n}");
        }
    }

    /// Independent cross-check against the ISA text's own footnote for the
    /// shape's last column block: "`X=N/2-4, Y=N/2-3, Z=N/2-2, W=N/2-1`" -
    /// thread 0's last four registers, at n=256, land at columns 248-249
    /// (rows 0 and 8), matching the figure's tail-block naming exactly.
    #[test]
    fn test_wgmma_matrix_d_n256_last_registers_match_isa_footnote() {
        let d = wgmma_m64n_k16::matrix_d(0, 256);
        assert_eq!(d.len(), 128);
        let (x, y, z, w) = (&d[124], &d[125], &d[126], &d[127]);
        assert_eq!((x.row, x.col), (0, 248));
        assert_eq!((y.row, y.col), (0, 249));
        assert_eq!((z.row, z.col), (8, 248));
        assert_eq!((w.row, w.col), (8, 249));
    }
}
