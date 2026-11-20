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
    /// `x`: a copy through the activation engine.
    Copy,
    /// `sqrt(x)`.
    Sqrt,
    /// `|x|`.
    Abs,
    /// `rcp(x)`: `nisa.reciprocal`'s, and `activation`'s though its docs do not list it, as
    /// nkilib's kernels pass it.
    Reciprocal,
    /// `x * sigmoid(x)`: SiLU, nkilib's mlp gate.
    Silu,
}

impl ActivationFunc {
    /// The functions `activation`'s `op` can name.
    pub const ALL: [Self; 10] = [
        Self::Sigmoid,
        Self::Relu,
        Self::Square,
        Self::Rsqrt,
        Self::Exp,
        Self::Copy,
        Self::Sqrt,
        Self::Abs,
        Self::Reciprocal,
        Self::Silu,
    ];

    /// Its `nki.language` member: `nl.sigmoid` is `sigmoid`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Sigmoid => "sigmoid",
            Self::Relu => "relu",
            Self::Square => "square",
            Self::Rsqrt => "rsqrt",
            Self::Exp => "exp",
            Self::Copy => "copy",
            Self::Sqrt => "sqrt",
            Self::Abs => "abs",
            Self::Reciprocal => "reciprocal",
            Self::Silu => "silu",
        }
    }
}
