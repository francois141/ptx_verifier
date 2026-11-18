//! The selector of PTX's `prmt.b32 d, a, b, selector` (default mode), decoded in one place:
//! its nibble `i`, lowest first, names the byte of `a` or `b` that result byte `i` takes.

/// The operand a result byte comes from.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PrmtOperand {
    A,
    B,
}

impl PrmtOperand {
    /// `a` or `b`, whichever this operand is.
    pub fn of<T>(self, a: T, b: T) -> T {
        match self {
            PrmtOperand::A => a,
            PrmtOperand::B => b,
        }
    }
}

/// What a result byte takes of its source byte: its value, or its sign bit in all eight bits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ByteTake {
    Value,
    Sign,
}

/// The source of one result byte: byte `byte` of `operand`, 0 the lowest and 3 the highest.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SourceByte {
    pub operand: PrmtOperand,
    pub byte: u32,
    pub take: ByteTake,
}

/// A `prmt` selector. A nibble's bits 0 and 1 are the source byte, its bit 2 the operand (`b`
/// when set) and its bit 3 the sign fill.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PrmtSelector(pub u16);

impl PrmtSelector {
    /// The source of each result byte, lowest first.
    pub fn bytes(self) -> [SourceByte; 4] {
        [0, 1, 2, 3].map(|result| {
            let nibble = self.0 >> (4 * result);
            SourceByte {
                operand: match nibble & 4 {
                    0 => PrmtOperand::A,
                    _ => PrmtOperand::B,
                },
                byte: u32::from(nibble & 3),
                take: match nibble & 8 {
                    0 => ByteTake::Value,
                    _ => ByteTake::Sign,
                },
            }
        })
    }
}
