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
    /// An unsigned integer literal.
    Imm(u64),
    /// One of the inline float constants ±0.5, ±1.0, ±2.0 and ±4.0, as its f32 bits.
    InlineFloat(u32),
    /// `vmcnt(n)` or `lgkmcnt(n)`.
    Wait { counter: Counter, value: u64 },
    /// A memory instruction's `offset:n` byte offset, which may be negative.
    Offset(i64),
}
