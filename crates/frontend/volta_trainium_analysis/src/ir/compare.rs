//! The comparisons of `nki.language` an instruction may name (`range_select`'s `comp_op0`).

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Comparison {
    Equal,
    NotEqual,
    Less,
    LessEqual,
    Greater,
    GreaterEqual,
}

impl Comparison {
    pub const ALL: [Self; 6] = [
        Self::Equal,
        Self::NotEqual,
        Self::Less,
        Self::LessEqual,
        Self::Greater,
        Self::GreaterEqual,
    ];

    /// Its `nki.language` member: `nl.greater_equal` is `greater_equal`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Equal => "equal",
            Self::NotEqual => "not_equal",
            Self::Less => "less",
            Self::LessEqual => "less_equal",
            Self::Greater => "greater",
            Self::GreaterEqual => "greater_equal",
        }
    }

    /// `a op b`.
    pub fn holds(self, a: f64, b: f64) -> bool {
        match self {
            Self::Equal => a == b,
            Self::NotEqual => a != b,
            Self::Less => a < b,
            Self::LessEqual => a <= b,
            Self::Greater => a > b,
            Self::GreaterEqual => a >= b,
        }
    }
}
