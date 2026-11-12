//! Tensor core types of the IR: an MMA's shape (M, N, K), an operand's row/col
//! layout, and which matrix (A, B, C, D) a WMMA load or store names.

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
}
