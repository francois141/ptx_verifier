//! The binary arithmetic operations of `nki.language`: elementwise in `Arith` and
//! `TensorScalar` (`lhs op rhs`, so `subtract` is `lhs - rhs`), folded in reductions.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ArithOp {
    Add,
    Subtract,
    Multiply,
    Maximum,
}

impl ArithOp {
    pub const ALL: [Self; 4] = [Self::Add, Self::Subtract, Self::Multiply, Self::Maximum];

    /// Its `nki.language` member: `nl.add` is `add`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Add => "add",
            Self::Subtract => "subtract",
            Self::Multiply => "multiply",
            Self::Maximum => "maximum",
        }
    }
}
