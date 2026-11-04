//! The activation functions of `LoweredInstr::Activation`.

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
}

impl ActivationFunc {
    pub const ALL: [Self; 4] = [Self::Sigmoid, Self::Relu, Self::Square, Self::Rsqrt];

    /// Its `nki.language` member: `nl.sigmoid` is `sigmoid`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Sigmoid => "sigmoid",
            Self::Relu => "relu",
            Self::Square => "square",
            Self::Rsqrt => "rsqrt",
        }
    }
}
