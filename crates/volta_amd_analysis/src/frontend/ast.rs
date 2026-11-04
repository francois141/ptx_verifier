//! The parsed form of one compiled AMD kernel.

use std::collections::BTreeMap;

/// One kernel extracted from assembly produced by Clang.
#[derive(Debug, Clone)]
pub struct Kernel {
    pub name: String,
    /// The `.amdgcn_target` string.
    pub target: String,
    /// The kernel body in order.
    pub instructions: Vec<Instruction>,
    /// Each label of the body and the index of the instruction it precedes.
    pub labels: BTreeMap<String, usize>,
    /// The numeric `.amdhsa_*` settings of the kernel descriptor, keyed without the prefix.
    pub descriptor: BTreeMap<String, u64>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Instruction {
    pub opcode: String,
    pub operands: Vec<Operand>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RegFile {
    Scalar,
    Vector,
    Accumulator,
}

/// An `s_waitcnt` counter supported by this frontend.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Counter {
    Vm,
    Lgkm,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Operand {
    /// Inclusive register range; a single register has `first == last`.
    Reg {
        file: RegFile,
        first: u32,
        last: u32,
    },
    /// An integer literal; the negative inline constants -1 to -16 are written signed.
    Imm(i64),
    /// One of the inline float constants ±0.5, ±1.0, ±2.0 and ±4.0, as its f32 bits.
    InlineFloat(u32),
    /// A floating-point source with its sign negated.
    Neg(Box<Operand>),
    /// The vector condition code, one bit per lane.
    Vcc,
    /// The mask of the wave's active lanes.
    Exec,
    /// A branch target.
    Label(String),
    /// A buffer instruction's `offen` flag: its address VGPR is a byte offset.
    Offen,
    /// The `offset0:n` and `offset1:n` of a two-address LDS instruction, in units of its size.
    Offset0(u64),
    Offset1(u64),
    /// The truth table of `v_bitop3_b32`.
    BitOp3(u8),
    /// Source-word selectors for the high result of a packed instruction.
    OpSelHi([bool; 2]),
    /// `vmcnt(n)` or `lgkmcnt(n)`.
    Wait {
        counter: Counter,
        value: u64,
    },
    /// A memory instruction's `offset:n` byte offset, which may be negative.
    Offset(i64),
}
