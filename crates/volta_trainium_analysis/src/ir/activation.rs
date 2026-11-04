//! The activation functions of `LoweredInstr::Activation`.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ActivationFunc {
    /// `1 / (1 + e^-x)`.
    Sigmoid,
    /// `max(x, 0)`.
    Relu,
}

impl ActivationFunc {
    pub const ALL: [Self; 2] = [Self::Sigmoid, Self::Relu];

    /// Its `nki.language` member: `nl.sigmoid` is `sigmoid`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Sigmoid => "sigmoid",
            Self::Relu => "relu",
        }
    }
}
