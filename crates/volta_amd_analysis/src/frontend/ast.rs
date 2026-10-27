//! The parsed form of one compiled AMD kernel.

use std::collections::BTreeMap;

/// One kernel extracted from assembly produced by Clang.
#[derive(Debug, Clone)]
pub struct Kernel {
    pub name: String,
    /// The `.amdgcn_target` string, e.g. `amdgcn-amd-amdhsa--gfx950:xnack-`.
    pub target: String,
    /// The kernel body in order. Operands are kept as text.
    pub instructions: Vec<Instruction>,
    /// The numeric `.amdhsa_*` settings of the kernel descriptor, keyed without the prefix.
    pub descriptor: BTreeMap<String, u64>,
}

#[derive(Debug, Clone)]
pub struct Instruction {
    pub opcode: String,
    pub operands: String,
}
