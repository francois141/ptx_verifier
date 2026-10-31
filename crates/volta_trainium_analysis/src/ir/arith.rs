//! The elementwise arithmetic operations of `LoweredInstr::Arith`.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ArithOp {
    Add,
}

impl ArithOp {
    pub const ALL: [Self; 1] = [Self::Add];

    /// Its `nki.language` member: `nl.add` is `add`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Add => "add",
        }
    }
}
