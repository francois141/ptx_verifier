//! Symbolic execution of AMD instructions.

mod launch;
mod scalar;
#[cfg(test)]
mod tests;
mod value;

use volta_expr::ExprArena;

use crate::ir::LoweredInstr;

pub(crate) use crate::error::EvalError;
pub(crate) use value::WaveRegisters;

/// Execute one instruction for an active lane selected by the caller.
/// Register values must be integer expressions from `arena`.
pub(crate) fn execute_lane(
    instruction: &LoweredInstr,
    lane: usize,
    registers: &mut WaveRegisters,
    arena: &mut ExprArena,
) -> Result<(), EvalError> {
    match instruction {
        LoweredInstr::Shl32 { dst, src, shift } => {
            // Read before writing because the source and destination may be the same register.
            let value = registers.read_vgpr(lane, *src)?;

            // AMD uses only the low five bits of the shift count: 34 becomes 2, and 32 becomes 0.
            let amount = arena.int(i64::from(shift & 31));
            let shifted = arena.shl(value, amount);

            // For a known numeric value, keep only the low 32 bits of the result.
            // For symbolic values, follow PTX's model and keep the shift expression without truncation.
            // TODO: Should this be handled differently?
            let result = if arena.as_int_const(value).is_some() {
                let mask = arena.int(i64::from(u32::MAX));
                arena.bit_and(shifted, mask)
            } else {
                shifted
            };
            registers.write_vgpr(lane, *dst, result)
        }
        _ => Err(EvalError::UnsupportedInstruction),
    }
}
