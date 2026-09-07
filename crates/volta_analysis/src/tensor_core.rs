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
            });
        }
        elements
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
        }]
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
            });
        }
        elements
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
}
