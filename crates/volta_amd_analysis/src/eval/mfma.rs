//! Matrix core instructions, which read their operands from every lane of a wave and write
//! their result to every lane.

use volta_expr::{ExprArena, ExprId};

use crate::ir::{LaneReg, LaneRegs, MfmaSrcC};

use super::EvalError;
use super::wave::{WaveRegisters, as_f32, f32_from_bits};

/// `v_mfma_f32_16x16x4_f32`:
/// D[i][j] = C[i][j] + sum_k A[i][k] * B[k][j].
///
/// Every source is read before `dst` is written, as `dst` may
/// also be the accumulator.
pub(super) fn execute_mfma_16x16x4_f32(
    arena: &mut ExprArena,
    registers: &mut WaveRegisters,
    dst: LaneRegs<4>,
    src_a: LaneReg,
    src_b: LaneReg,
    src_c: MfmaSrcC,
) -> Result<(), EvalError> {
    const N: usize = 16;
    const K: usize = 4;
    const LANES: usize = 64;

    // Lane holding A[x][k] or B[k][x].
    let operand_lane = |x: usize, k: usize| x + N * k;

    // Lane and accumulator register holding C[i][j] or D[i][j].
    let accumulator_location = |i: usize, j: usize| {
        let lane = (i / K) * N + j;
        let reg = i % K;
        (lane, reg)
    };

    // Read all source operands before writing any destination.
    let a = read_wave(arena, registers, src_a, LANES)?;
    let b = read_wave(arena, registers, src_b, LANES)?;

    let c = match src_c {
        MfmaSrcC::Regs(regs) => regs
            .regs()
            .into_iter()
            .map(|reg| read_wave(arena, registers, reg, LANES))
            .collect::<Result<Vec<_>, _>>()?,

        MfmaSrcC::Inline(bits) => {
            let value = f32_from_bits(arena, bits)
                .ok_or(EvalError::InvalidFloatConstant(bits))?;
            vec![vec![value; LANES]; K]
        }
    };

    // Compute D as a logical 16x16 matrix.
    let mut d = [[c[0][0]; N]; N];

    for i in 0..N {
        for j in 0..N {
            let (lane, reg) = accumulator_location(i, j);
            let mut sum = c[reg][lane];

            for k in 0..K {
                sum = arena.fma(
                    a[operand_lane(i, k)],
                    b[operand_lane(j, k)],
                    sum,
                );
            }

            d[i][j] = sum;
        }
    }

    // Write results back using the MFMA accumulator layout.
    let dst_regs = dst.regs();

    for i in 0..N {
        for j in 0..N {
            let (lane, reg) = accumulator_location(i, j);
            registers.write_lane_reg(lane, dst_regs[reg], d[i][j])?;
        }
    }

    Ok(())
}

/// Read `reg` as an f32 operand across the first `lanes` lanes.
/// AGPRs are interpreted as f32, just like VGPRs.
fn read_wave(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    reg: LaneReg,
    lanes: usize,
) -> Result<Vec<ExprId>, EvalError> {
    let mut values = Vec::with_capacity(lanes);

    for lane in 0..lanes {
        let value = match reg {
            LaneReg::Vgpr(reg) => registers.read_f32(arena, lane, reg)?,
            LaneReg::Agpr(reg) => {
                let value = registers.read_agpr(lane, reg)?;
                as_f32(arena, value)
                    .ok_or(EvalError::InvalidFloatAgpr { lane, reg })?
            }
        };

        values.push(value);
    }

    Ok(values)
}