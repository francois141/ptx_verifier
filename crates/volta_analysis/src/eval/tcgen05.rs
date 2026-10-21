//! `tcgen05.mma` evaluation: operands read through the descriptors
//! `tcgen05_mma` decodes (or from Tensor Memory), D computed at issue.

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::float_bits::{self};
use crate::eval::interp::Interpreter;
use crate::eval::record::AccessOrigin;
use crate::eval::tcgen05_mma::{self, KSelect, Major, OperandFormat};
use crate::eval::value::Value;
use crate::lowered::{
    InstrId, MemSpace, Operand, Tcgen05Collector, Tcgen05CollectorOp, Tcgen05MmaA, Tcgen05MmaKind,
};
use volta_expr::{ExprId, Real};
use volta_frontend::ast::ScalarType;
use volta_graph::{AccessMode, AsyncOpId, AsyncOpKind, OperandRole, Proxy};

impl<'p> Interpreter<'p> {
    /// `tcgen05.mma.cta_group::1.kind::{f16,f8f6f4}`: `D = A*B (+D)`, A/B via
    /// smem descriptors (or A from TMEM), D into TMEM. Computed at issue, in
    /// flight until a waiter observes a later commit.
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn exec_tcgen05_mma(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        (kind, collector): (Tcgen05MmaKind, Option<Tcgen05Collector>),
        d_tmem_base: &Operand,
        d_tmem_offset: i64,
        a: &Tcgen05MmaA,
        b_desc: &Operand,
        idesc: &Operand,
        disable_output_lane: &[Operand],
        enable_input_d: &Operand,
    ) -> EvalResult<()> {
        let unsupported = |what: String| EvalError::Unsupported { pc, what };
        let idesc_val = self.concrete_operand(t, pc, idesc, "tcgen05.mma idesc")? as u32;
        let id = tcgen05_mma::decode_instruction_descriptor(idesc_val).map_err(|bit| {
            EvalError::InvalidEncoding {
                pc,
                what: format!(
                    "tcgen05.mma idesc {idesc_val:#x} has reserved bit {} set (must be 0)",
                    bit.0
                ),
            }
        })?;

        if id.sparse {
            return Err(unsupported(
                "tcgen05.mma.sp (sparse A matrix) is not modeled".to_string(),
            ));
        }
        // `tcgen05_mma::k_dim` is the `KSelect::Base` K; a set K Dimension
        // bit must not silently run at it.
        if id.k_select != KSelect::Base {
            return Err(unsupported(format!(
                "tcgen05.mma {kind:?} with idesc's K Dimension bit (29) set is not \
                 modeled (only K = {}; .kind::f16/.kind::f8f6f4 define no other)",
                tcgen05_mma::k_dim(kind)
            )));
        }
        let invalid = |what: String| EvalError::InvalidEncoding { pc, what };
        let ws = collector.is_some();
        // PTX ISA Table 51: saturate is `0 (NA)` for both modeled kinds, the
        // B-reuse max shift only exists for `.ws`, and D is f16 (0) or f32
        // (1).
        if id.saturate {
            return Err(invalid(format!(
                "tcgen05.mma {kind:?} idesc {idesc_val:#x} sets the integer-only saturate bit (3)"
            )));
        }
        if !ws && id.max_shift != 0 {
            return Err(invalid(format!(
                "tcgen05.mma idesc {idesc_val:#x} sets the .ws-only B-reuse maximum shift \
                 (bits 30-31) without .ws"
            )));
        }
        if id.dtype > 1 {
            return Err(invalid(format!(
                "tcgen05.mma {kind:?} idesc {idesc_val:#x} has D type field {} \
                 (only f16 = 0 and f32 = 1 are defined)",
                id.dtype
            )));
        }
        // PTX ISA Table 48, `.cta_group::1` dense shapes: M = 64/128 with N
        // a multiple of 8 up to 256, or under `.ws` M = 32/64/128 with N =
        // 64/128/256 (N's field already encodes it in steps of 8).
        let valid_shape = if ws {
            matches!(id.m, 32 | 64 | 128) && matches!(id.n, 64 | 128 | 256)
        } else {
            matches!(id.m, 64 | 128) && (8..=256).contains(&id.n)
        };
        if !valid_shape {
            return Err(invalid(format!(
                "tcgen05.mma{} M = {}, N = {} is not a valid .cta_group::1 dense shape \
                 ({})",
                if ws { ".ws" } else { "" },
                id.m,
                id.n,
                if ws {
                    "M in {32, 64, 128}, N in {64, 128, 256}"
                } else {
                    "M in {64, 128}, N in 8..=256 in steps of 8"
                }
            )));
        }
        // Table 63: an 8-bit transposed B needs N in steps of 16.
        if kind == Tcgen05MmaKind::F8f6f4 && id.transpose_b && !id.n.is_multiple_of(16) {
            return Err(invalid(format!(
                "tcgen05.mma .kind::f8f6f4 with a transposed B needs N in steps of 16, \
                 got N = {}",
                id.n
            )));
        }
        if id.dtype != 1 {
            return Err(unsupported(
                "tcgen05.mma with a non-f32 accumulator is not modeled".to_string(),
            ));
        }
        let format = |field: u32, operand: &str| {
            OperandFormat::decode(kind, field).ok_or_else(|| {
                unsupported(format!(
                    "tcgen05.mma {kind:?} {operand} type field {field} is not modeled \
                     (bf16 and the 6/4-bit types are not; only f16 for .kind::f16 and \
                     e4m3/e5m2 for .kind::f8f6f4)"
                ))
            })
        };
        let a_format = format(id.atype, "A")?;
        let b_format = format(id.btype, "B")?;
        if id.negate_a || id.negate_b {
            return Err(unsupported(
                "tcgen05.mma's Negate A/B Matrix is not modeled".to_string(),
            ));
        }
        // `M = 64` would fall out of `tcgen05_mma::d_cell`'s formula too,
        // but nothing has pinned its Layout D down, and a silently wrong
        // placement is worse here than a loud refusal.
        if !matches!(id.m, 32 | 128) {
            return Err(unsupported(format!(
                "tcgen05.mma with M = {} is not modeled (only M = 32 and 128)",
                id.m
            )));
        }
        // An M < 128 result is folded across Tensor Memory's 128 lanes in
        // `128 / M` row-groups, so `N` must split evenly between them for
        // `tcgen05_mma::d_cell` to place it.
        let d_groups = 128 / id.m;
        if !id.n.is_multiple_of(d_groups) {
            return Err(unsupported(format!(
                "tcgen05.mma with M = {} and N = {} is not modeled (N must be a \
                 multiple of {d_groups} to fold across the 128 Tensor Memory lanes)",
                id.m, id.n
            )));
        }
        let d_num_cols = id.n / d_groups;

        let k_dim = tcgen05_mma::k_dim(kind) as usize;
        let major = |transpose: bool| if transpose { Major::Mn } else { Major::K };
        // Decode and validate B's descriptor up front, so a malformed one is
        // reported before any operand read.
        let b_md = self.mma_matrix_descriptor(t, pc, b_desc, "tcgen05.mma b-desc")?;
        check_mma_operand_layout(pc, &b_md, id.transpose_b, "B")?;
        let op = self.record_async_issue(t, pc, AsyncOpKind::Tcgen05Mma);
        let a = match a {
            Tcgen05MmaA::Desc(desc) => {
                let a_md = self.mma_matrix_descriptor(t, pc, desc, "tcgen05.mma a-desc")?;
                check_mma_operand_layout(pc, &a_md, id.transpose_a, "A")?;
                let a_operand = (&a_md, major(id.transpose_a), a_format);
                self.read_mma_operand(t, pc, (op, OperandRole::MmaA), a_operand, id.m, k_dim)?
            }
            Tcgen05MmaA::Tmem { base, offset } => {
                if a_format != OperandFormat::F16 {
                    return Err(unsupported(format!(
                        "tcgen05.mma [a-tmem] with {a_format:?} elements is not modeled \
                         (only .kind::f16's packed f16 pairs)"
                    )));
                }
                if id.transpose_a {
                    return Err(unsupported(
                        "tcgen05.mma [a-tmem] with Transpose A is not modeled (Tensor \
                         Memory holds A K-major already)"
                            .to_string(),
                    ));
                }
                self.read_mma_a_tmem(t, pc, op, (base, *offset), (id.m, k_dim))?
            }
        };
        let b_operand = (&b_md, major(id.transpose_b), b_format);
        let b = self.read_mma_operand(t, pc, (op, OperandRole::MmaB), b_operand, id.n, k_dim)?;
        if let Some(Tcgen05Collector { buffer, op }) = collector {
            let slot = &mut self.threads[t].tcgen05_collectors[buffer as usize];
            if matches!(op, Tcgen05CollectorOp::Use | Tcgen05CollectorOp::LastUse)
                && slot.as_deref() != Some(b.as_slice())
            {
                return Err(unsupported(format!(
                    "tcgen05.mma.ws .collector::b{buffer}::{op:?} without a live fill of \
                     the same B matrix (reading a stale or mismatched collector buffer is \
                     not modeled)"
                )));
            }
            match op {
                Tcgen05CollectorOp::Fill => *slot = Some(b.clone()),
                Tcgen05CollectorOp::Use => {}
                Tcgen05CollectorOp::LastUse | Tcgen05CollectorOp::Discard => *slot = None,
            }
        }

        let enable_input_d =
            self.concrete_operand(t, pc, enable_input_d, "tcgen05.mma enable-input-d")? != 0;
        let d_tmem = self.effective_addr(t, pc, d_tmem_base, d_tmem_offset)? as u32;
        // `D` spans all 128 lanes from lane 0 (`tcgen05_mma::d_cell`); any
        // other lane would shift its rows, and read as part of the column it
        // would be misreported as an access outside the allocation.
        if d_tmem >> 16 != 0 {
            return Err(unsupported(format!(
                "tcgen05.mma [d-tmem] at lane {} is not modeled (D must start at lane 0)",
                d_tmem >> 16
            )));
        }
        let d_col_base = d_tmem & 0xFFFF;
        self.tensor
            .check_range(d_col_base, d_num_cols)
            .map_err(|e| EvalError::from_tensor_mem(t, pc, e))?;

        // `disable-output-lane`: 4 elements form a 128-bit mask, least
        // significant bit of the first element = lane 0 (PTX ISA
        // 9.7.17.10.9.1). Resolved once up front rather than per-lane.
        let mut disable_mask = [0u32; 4];
        for (slot, op) in disable_mask.iter_mut().zip(disable_output_lane) {
            *slot = self.concrete_operand(t, pc, op, "tcgen05.mma disable-output-lane")? as u32;
        }
        let lane_enabled = |lane: u32| (disable_mask[(lane / 32) as usize] >> (lane % 32)) & 1 == 0;
        let d_lanes: Vec<u32> = (0..128).filter(|&lane| lane_enabled(lane)).collect();
        let d_cols = (d_col_base, d_num_cols);
        let accumulator = |mode| (mode, OperandRole::Accumulator);
        if enable_input_d {
            self.record_tmem_lanes(op, t, accumulator(AccessMode::Read), &d_lanes, d_cols);
        }
        self.record_tmem_lanes(op, t, accumulator(AccessMode::Write), &d_lanes, d_cols);

        for m in 0..id.m {
            for n in 0..id.n {
                let (lane, col) = tcgen05_mma::d_cell(m, n, (id.m, id.n));
                let col = d_col_base + col;
                if !lane_enabled(lane) {
                    continue;
                }
                let mut acc = if enable_input_d {
                    match self
                        .tensor
                        .read(lane, col)
                        .map_err(|e| EvalError::from_tensor_mem(t, pc, e))?
                    {
                        // A `tcgen05.st` of a `.b32` register leaves raw bits.
                        Some(Value::Scalar(e)) => {
                            float_bits::decode_float_bits(&mut self.arena, pc, ScalarType::F32, e)?
                        }
                        Some(_) => {
                            return Err(EvalError::ValueKindMismatch {
                                thread: t,
                                pc,
                                what: "tcgen05.mma accumulator cell is not an f32 scalar",
                            });
                        }
                        None => self.arena.undefined(),
                    }
                } else {
                    // A real (not integer) zero: `fma`'s eager fold needs every
                    // operand `RealConst`, so an `IntConst(0)` seed would break
                    // folding along the whole accumulation chain.
                    self.arena.real(Real::zero())
                };
                let a_row = &a[m as usize * k_dim..][..k_dim];
                let b_row = &b[n as usize * k_dim..][..k_dim];
                for (&a_e, &b_e) in a_row.iter().zip(b_row) {
                    acc = self.arena.fma(a_e, b_e, acc);
                }
                self.tensor
                    .write(lane, col, Value::Scalar(acc))
                    .map_err(|e| EvalError::from_tensor_mem(t, pc, e))?;
            }
        }
        self.record_mma_issued(t, op);
        Ok(())
    }

    /// Read one `tcgen05.mma` operand (`rows x k_dim`, row-major) from shared
    /// memory as an async-proxy effect of `op`. Concrete elements are decoded
    /// from f16/fp8 bits; symbolic ones are real values.
    fn read_mma_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        (op, role): (AsyncOpId, OperandRole),
        (desc, major, format): (&tcgen05_mma::MatrixDescriptor, Major, OperandFormat),
        rows: u32,
        k_dim: usize,
    ) -> EvalResult<Vec<ExprId>> {
        let origin = AccessOrigin::Async {
            op,
            proxy: Proxy::Async,
            role,
        };
        let elem_bytes = format.bytes();
        let mut elems = Vec::with_capacity(rows as usize * k_dim);
        for row in 0..rows as u64 {
            for k in 0..k_dim as u64 {
                let addr = tcgen05_mma::operand_element_addr(desc, major, row, k, elem_bytes)
                    .ok_or_else(|| EvalError::Unsupported {
                        pc,
                        what: "tcgen05.mma MN-major operand without swizzling is not modeled"
                            .to_string(),
                    })?;
                let Value::Scalar(e) =
                    self.mem_read_from(t, pc, MemSpace::Shared, addr, elem_bytes, origin)?
                else {
                    return Err(EvalError::ValueKindMismatch {
                        thread: t,
                        pc,
                        what: "tcgen05.mma operand element is not a scalar",
                    });
                };
                let ty = match format {
                    OperandFormat::F16 => ScalarType::F16,
                    OperandFormat::E4m3 => ScalarType::E4m3,
                    OperandFormat::E5m2 => ScalarType::E5m2,
                };
                let e = float_bits::decode_float_bits(&mut self.arena, pc, ty, e)?;
                elems.push(e);
            }
        }
        Ok(elems)
    }

    /// Resolve and decode one `tcgen05.mma` smem matrix descriptor, rejecting
    /// the unmodeled modes: `sm_103a`'s absolute leading-dimension stride and a
    /// nonzero base offset.
    fn mma_matrix_descriptor(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        desc: &Operand,
        what: &'static str,
    ) -> EvalResult<tcgen05_mma::MatrixDescriptor> {
        let unsupported = |reason: String| EvalError::Unsupported { pc, what: reason };
        let raw = self.concrete_operand(t, pc, desc, what)? as u64;
        let md =
            tcgen05_mma::decode_matrix_descriptor(raw).map_err(|e| EvalError::InvalidEncoding {
                pc,
                what: format!("{what} {raw:#x}: {e}"),
            })?;
        if md.lut_b_offset {
            return Err(unsupported(format!(
                "{what}'s lut::b K-segment offset bit (53) is set, but \
                 .decompress::lut::b is not modeled"
            )));
        }
        if md.absolute_leading_stride {
            return Err(unsupported(format!(
                "{what}'s absolute leading-dimension stride mode (sm_103a only) is not modeled"
            )));
        }
        if md.base_offset != 0 {
            return Err(unsupported(format!(
                "{what} has a nonzero matrix-descriptor base offset, which is not modeled"
            )));
        }
        Ok(md)
    }

    /// Read `tcgen05.mma`'s `[a-tmem]` `A`: `rows x k_dim` f16s, row `m` in
    /// lane `m`, element `k` in half `k % 2` of column `col_base + k / 2`.
    fn read_mma_a_tmem(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: AsyncOpId,
        (base, offset): (&Operand, i64),
        (rows, k_dim): (u32, usize),
    ) -> EvalResult<Vec<ExprId>> {
        let packed = self.effective_addr(t, pc, base, offset)? as u32;
        // `A` shares `D`'s layout, row `m` in lane `m` from lane 0; any other
        // lane would silently shift `A`'s rows.
        if packed >> 16 != 0 {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "tcgen05.mma [a-tmem] at lane {} is not modeled (A must start at lane 0)",
                    packed >> 16
                ),
            });
        }
        let start_col = packed & 0xFFFF;
        // Two f16 elements ride in each 32-bit column.
        let num_cols = (k_dim / 2) as u32;
        self.tensor
            .check_range(start_col, num_cols)
            .map_err(|e| EvalError::from_tensor_mem(t, pc, e))?;
        let a = (AccessMode::Read, OperandRole::MmaA);
        self.record_tmem_effect(op, t, a, 0, rows, start_col, num_cols);
        let mut elems = Vec::with_capacity(rows as usize * k_dim);
        for lane in 0..rows {
            for c in 0..num_cols {
                let col = start_col + c;
                let cell = self
                    .tensor
                    .read(lane, col)
                    .map_err(|e| EvalError::from_tensor_mem(t, pc, e))?;
                let (lo, hi) = match cell {
                    Some(Value::Pair(lo, hi)) => (lo, hi),
                    Some(_) => {
                        return Err(EvalError::ValueKindMismatch {
                            thread: t,
                            pc,
                            what: "tcgen05.mma [a-tmem] cell does not hold a packed f16 pair",
                        });
                    }
                    None => {
                        let undefined = self.arena.undefined();
                        (undefined, undefined)
                    }
                };
                elems.push(lo);
                elems.push(hi);
            }
        }
        Ok(elems)
    }
}

/// PTX ISA Table 65 (and note under Table 62): for
/// `.kind::f16`/`.kind::f8f6f4`, a transposed (MN-major) operand supports every
/// swizzle mode except 128B with 32B atomicity.
fn check_mma_operand_layout(
    pc: InstrId,
    md: &tcgen05_mma::MatrixDescriptor,
    transposed: bool,
    operand: &str,
) -> EvalResult<()> {
    if transposed && md.swizzle_mode == tcgen05_mma::SwizzleMode::Swizzle128BWith32BAtomicity {
        return Err(EvalError::InvalidEncoding {
            pc,
            what: format!(
                "tcgen05.mma transposed {operand} with 128B swizzling with 32B atomicity \
                 (only valid for .kind::tf32)"
            ),
        });
    }
    Ok(())
}
