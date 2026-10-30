//! `.kind::mxf8f6f4` block scaling (PTX ISA 9.7.18.10.7): the instruction
//! descriptor's layout (Table 54) and the UE8M0 factors, read from Tensor
//! Memory, that scale each 32-element block of an `A` row and a `B` column.

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::Interpreter;
use crate::eval::tcgen05_mma::{InstructionDescriptor, KSelect, ReservedIdescBit, bits};
use crate::eval::value::Value;
use crate::ir::{InstrId, Operand};
use volta_expr::ExprId;
use volta_graph::{AccessMode, AsyncOpId, OperandRole};

/// Where `scale_A`'s factors sit in Tensor Memory (`idesc` bit 26).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScaleALayout {
    /// 32 lanes, duplicated in each 32-lane partition (PTX ISA Figure 237).
    Lanes32,
    /// One lane per row of `A` (Figure 238), `sm_107f` only.
    Lanes128,
}

/// A decoded `.kind::mxf8f6f4` instruction descriptor (PTX ISA Table 54):
/// `common` holds the fields Table 51 shares (D is always f32), the rest
/// picks the scale factors.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct BlockScaledDescriptor {
    pub common: InstructionDescriptor,
    /// Bit 23: the scale matrices are UE8M0, the only type the kind defines.
    pub ue8m0_scales: bool,
    pub scale_a_layout: ScaleALayout,
    /// The byte of each scale word `scale_A` reads (bits 29-30).
    pub scale_a_id: u32,
    /// The byte of each scale word `scale_B` reads (bits 4-5).
    pub scale_b_id: u32,
}

/// Decode a `.kind::mxf8f6f4` instruction descriptor, failing only on a set
/// reserved bit (0, 1, 3, 6, 24 or 25); validity is the caller's.
pub fn decode_block_scaled_descriptor(
    idesc: u32,
) -> Result<BlockScaledDescriptor, ReservedIdescBit> {
    if let Some(bit) = [0, 1, 3, 6, 24, 25]
        .into_iter()
        .find(|&b| bits(idesc, b, 1) != 0)
    {
        return Err(ReservedIdescBit(bit));
    }

    let common = InstructionDescriptor {
        sparse: bits(idesc, 2, 1) != 0,
        dtype: 1,
        atype: bits(idesc, 7, 3),
        btype: bits(idesc, 10, 3),
        negate_a: bits(idesc, 13, 1) != 0,
        negate_b: bits(idesc, 14, 1) != 0,
        transpose_a: bits(idesc, 15, 1) != 0,
        transpose_b: bits(idesc, 16, 1) != 0,
        n: bits(idesc, 17, 6) << 3,
        m: bits(idesc, 27, 2) << 7,
        k_select: if bits(idesc, 31, 1) == 0 {
            KSelect::Base
        } else {
            KSelect::Wide
        },
        saturate: false,
        max_shift: 0,
    };
    Ok(BlockScaledDescriptor {
        common,
        ue8m0_scales: bits(idesc, 23, 1) != 0,
        scale_a_layout: if bits(idesc, 26, 1) == 0 {
            ScaleALayout::Lanes32
        } else {
            ScaleALayout::Lanes128
        },
        scale_a_id: bits(idesc, 29, 2),
        scale_b_id: bits(idesc, 4, 2),
    })
}

/// `.kind::mxf8f6f4`'s own `idesc` fields (PTX ISA Table 54): UE8M0 scales,
/// the only type it defines, with `scale_A` in the 32-lane layout.
pub(in crate::eval) fn check_block_scaled_descriptor(
    pc: InstrId,
    idesc: u32,
    bs: &BlockScaledDescriptor,
) -> EvalResult<()> {
    if !bs.ue8m0_scales {
        return Err(EvalError::InvalidEncoding {
            pc,
            what: format!(
                "tcgen05.mma .kind::mxf8f6f4 idesc {idesc:#x} clears the Scale Matrix Type bit \
                 (23), but UE8M0 = 1 is the only scale type the kind defines"
            ),
        });
    }
    if bs.scale_a_layout == ScaleALayout::Lanes128 {
        return Err(EvalError::Unsupported {
            pc,
            what: format!(
                "tcgen05.mma idesc {idesc:#x} selects the 128-lane scale_A layout (bit 26), \
                 an sm_107f layout that is not modeled"
            ),
        });
    }
    Ok(())
}

impl<'p> Interpreter<'p> {
    /// Read `count` UE8M0 factors of `scale_A` or `scale_B` from Tensor Memory
    /// as values: factor `i` is byte `byte` of the word at lane `i % 32`,
    /// column `i / 32` (PTX ISA Figures 237, 257) of each 32-lane partition.
    pub(in crate::eval) fn read_mma_scales(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: AsyncOpId,
        (base, offset): (Operand, i64),
        (role, byte): (OperandRole, u32),
        count: u32,
    ) -> EvalResult<Vec<ExprId>> {
        let address = self.effective_addr(t, pc, &base, offset)? as u32;
        if address >> 16 != 0 {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "tcgen05.mma {role:?} at lane {} is not modeled (its 32-lane layout \
                     starts at lane 0)",
                    address >> 16
                ),
            });
        }
        let start_col = address & 0xFFFF;
        let num_cols = count.div_ceil(32);
        self.tensor
            .check_range(start_col, num_cols)
            .map_err(|e| EvalError::from_tensor_mem(t, pc, e))?;

        // Each partition holds a copy, and which one the hardware reads for a
        // row is unspecified, so all four are read and must agree.
        for partition in 0..4 {
            for c in 0..num_cols {
                let lanes = (count - 32 * c).min(32);
                let read = (AccessMode::Read, role);
                self.record_tmem_effect(op, t, read, 32 * partition, lanes, start_col + c, 1);
            }
        }

        let mut factors = Vec::with_capacity(count as usize);
        for i in 0..count {
            let (lane, col) = (i % 32, start_col + i / 32);
            let mut copies = Vec::with_capacity(4);
            for partition in 0..4 {
                let cell = self.tmem_read(t, pc, 32 * partition + lane, col)?;
                copies.push(self.scale_byte(t, pc, cell, byte)?);
            }

            // A never-written copy already ends the run with `tmem_read`'s error.
            let Some(bytes) = copies.into_iter().collect::<Option<Vec<_>>>() else {
                factors.push(self.arena.undefined());
                continue;
            };
            let same = |x: ExprId, y: ExprId| {
                let value = self.arena.as_int_const(x);
                x == y || (value.is_some() && value == self.arena.as_int_const(y))
            };
            if !bytes.iter().all(|&copy| same(copy, bytes[0])) {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "tcgen05.mma {role:?} factor {i} differs between Tensor Memory's four \
                         32-lane partitions, which the PTX ISA requires to hold copies of it"
                    ),
                });
            }
            factors.push(self.ue8m0_value(pc, bytes[0])?);
        }
        Ok(factors)
    }

    /// Byte `byte` of a scale word read from Tensor Memory; `None` for a
    /// never-written cell.
    fn scale_byte(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        cell: Option<Value>,
        byte: u32,
    ) -> EvalResult<Option<ExprId>> {
        match cell {
            None => Ok(None),
            Some(Value::Quad(b0, b1, b2, b3)) => Ok(Some([b0, b1, b2, b3][byte as usize])),
            Some(Value::Scalar(word)) => match self.arena.as_int_const(word) {
                Some(bits) => Ok(Some(self.arena.int((bits >> (8 * byte)) & 0xFF))),
                None => Err(EvalError::Unsupported {
                    pc,
                    what: "tcgen05.mma scale word is a symbolic 32-bit value, whose bytes are \
                           not modeled"
                        .to_string(),
                }),
            },
            Some(Value::Pair(..) | Value::Mbarrier(_)) => Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "tcgen05.mma scale cell holds neither a word nor four packed bytes",
            }),
        }
    }

    /// The value `2^(e - 127)` of UE8M0 byte `e`: exact when `e` is concrete,
    /// else Volta's `ex2`. `0xFF` encodes NaN, which it cannot represent.
    fn ue8m0_value(&mut self, pc: InstrId, e: ExprId) -> EvalResult<ExprId> {
        let unsupported = |what: String| EvalError::Unsupported { pc, what };
        let Some(bits) = self.arena.as_int_const(e) else {
            let bias = self.arena.int(127);
            let exponent = self.arena.sub(e, bias);
            return self.ex2(pc, exponent);
        };
        if bits == 0xFF {
            return Err(unsupported(
                "tcgen05.mma UE8M0 scale 0xFF encodes NaN, which Volta's real-valued model \
                 cannot represent"
                    .to_string(),
            ));
        }
        self.arena
            .float_from_f64(2f64.powi(bits as i32 - 127))
            .map_err(|e| unsupported(format!("tcgen05.mma UE8M0 scale {bits:#x}: {e}")))
    }

    /// Multiply each `k_dim`-element row of `elems` by its factor in `scales`.
    pub(in crate::eval) fn scale_rows(
        &mut self,
        elems: &mut [ExprId],
        scales: &[ExprId],
        k_dim: usize,
    ) {
        for (row, &scale) in elems.chunks_mut(k_dim).zip(scales) {
            for e in row {
                *e = self.arena.mul(*e, scale);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::eval::tcgen05_mma::k_dim;
    use crate::ir::tcgen05::Tcgen05MmaKind;
    /// Gluon 11-tcgen05-mma-scaled's first two `.kind::mxf8f6f4` idescs: M =
    /// N = 128, e4m3 operands, UE8M0 scales in the 32-lane layout, and scale
    /// IDs 0, then 1 for the next K block.
    #[test]
    fn test_decode_real_block_scaled_kernel_idesc() {
        let first = decode_block_scaled_descriptor(0x08A0_0000).unwrap();
        assert_eq!(
            (first.common.m, first.common.n, first.common.dtype),
            (128, 128, 1)
        );
        assert_eq!((first.common.atype, first.common.btype), (0, 0));
        assert_eq!(first.common.k_select, KSelect::Base);
        assert!(first.ue8m0_scales && first.scale_a_layout == ScaleALayout::Lanes32);
        assert_eq!((first.scale_a_id, first.scale_b_id), (0, 0));

        let second = decode_block_scaled_descriptor(0x28A0_0010).unwrap();
        assert_eq!((second.scale_a_id, second.scale_b_id), (1, 1));
        assert_eq!(k_dim(Tcgen05MmaKind::Mxf8f6f4), 32);
    }

    /// Table 54 moves the fields Table 51 has at bits 4-5 (D type), 23
    /// (reserved), 24-28 (M) and 29-31: M is `M >> 7` at 27-28, 26 picks
    /// `scale_A`'s layout, 31 the K dimension, and 24-25 are reserved.
    #[test]
    fn test_decode_block_scaled_idesc_fields() {
        let wide = decode_block_scaled_descriptor(0x8000_0000 | 0x0880_0000).unwrap();
        assert_eq!(wide.common.k_select, KSelect::Wide);
        let lanes = decode_block_scaled_descriptor(0x0C80_0000).unwrap();
        assert_eq!(lanes.scale_a_layout, ScaleALayout::Lanes128);
        assert!(
            !decode_block_scaled_descriptor(0x0800_0000)
                .unwrap()
                .ue8m0_scales
        );
        assert_eq!(
            decode_block_scaled_descriptor(0x0980_0000),
            Err(ReservedIdescBit(24))
        );
    }
}
