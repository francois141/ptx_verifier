//! The elementwise functions of `LoweredInstr::Activation`.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ActivationFunc {
    /// `1 / (1 + e^-x)`.
    Sigmoid,
    /// `max(x, 0)`.
    Relu,
    /// `x * x`.
    Square,
    /// `rcp(sqrt(x))`.
    Rsqrt,
    /// `e^x`.
    Exp,
    /// `rcp(x)`: `nisa.reciprocal`'s, not an `activation` function, so not in `ALL`.
    Reciprocal,
}

impl ActivationFunc {
    /// The functions `activation`'s `op` can name.
    pub const ALL: [Self; 5] = [
        Self::Sigmoid,
        Self::Relu,
        Self::Square,
        Self::Rsqrt,
        Self::Exp,
    ];

    /// Its `nki.language` member: `nl.sigmoid` is `sigmoid`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Sigmoid => "sigmoid",
            Self::Relu => "relu",
            Self::Square => "square",
            Self::Rsqrt => "rsqrt",
            Self::Exp => "exp",
            Self::Reciprocal => "reciprocal",
        }
    }
}
