//! Warp-cooperative ops (`bar.warp.sync`, `shfl.sync`, `ldmatrix`, `mma.sync`, `wmma`, the
//! warp-scoped `tcgen05` ops, `tensormap.cp_fenceproxy`, `setmaxnreg`): run once all lanes
//! reach the same pc and mask, with each memory access attributed to its owning lane
//! (`fragments` tables).

use crate::frontend::ast::ScalarType;

use volta_graph::{AccessMode, AsyncOpKind, FenceKind, OperandRole};

use crate::eval::error::{EvalError, EvalResult};
use crate::eval::float_bits;
use crate::eval::fragments::{
    FragmentElement, m16n8k4_tf32, m16n8k8_tf32, m16n8k16_f16, m16n8k32_byte, m16n16k16_f16,
};
use crate::eval::interp::Interpreter;
use crate::eval::record::{AccessOrigin, Tcgen05Wait, point, tix};
use crate::eval::tensor_map_table::TENSOR_MAP_BYTES;
use crate::eval::value::Value;
use crate::eval::{ThreadId, WARP_SIZE};
use crate::ir::mma::{MmaLayout, MmaOperand, MmaShape};
use crate::ir::symbols::{RegId, shared_operand_addr};
use crate::ir::tcgen05::Tcgen05LdStShape;
use crate::ir::types::ScalarTypeExt;
use crate::ir::{InstrId, LoweredInstr, MemSpace, Operand, ShflMode};
use volta_expr::ExprId;

/// A dense matrix of expressions being assembled from lane fragments.
struct Grid {
    cols: usize,
    cells: Vec<Option<ExprId>>,
}

impl Grid {
    fn new(rows: usize, cols: usize) -> Self {
        Self {
            cols,
            cells: vec![None; rows * cols],
        }
    }

    fn set(&mut self, row: u32, col: u32, e: ExprId) {
        self.cells[row as usize * self.cols + col as usize] = Some(e);
    }

    fn get(&self, row: u32, col: u32, pc: InstrId) -> EvalResult<ExprId> {
        self.cells[row as usize * self.cols + col as usize].ok_or_else(|| EvalError::Unsupported {
            pc,
            what: format!("incomplete fragment mapping at ({}, {})", row, col),
        })
    }
}

/// Element offset (in elements) within a matrix laid out in memory.
fn elem_offset(layout: MmaLayout, row: u32, col: u32, stride: u64) -> u64 {
    match layout {
        MmaLayout::Row => row as u64 * stride + col as u64,
        MmaLayout::Col => col as u64 * stride + row as u64,
    }
}

/// The row and first column of the two adjacent `movmatrix` elements a lane
/// holds (`ldmatrix`'s fragment layout, PTX ISA 9.7.14.5.16).
fn movmatrix_position(t: ThreadId) -> (usize, usize) {
    let lane = (t.0 % WARP_SIZE) as usize;
    (lane / 4, 2 * (lane % 4))
}

/// `ldmatrix` row alignment: each 8x8 b16 row is one 16-byte access, so every
/// lane-supplied row address must be 16-aligned (PTX ISA 9.7.14.5.15).
const LDMATRIX_ROW_BYTES: u64 = 16;

/// `wmma` base-address alignment for m16n16k16 (the one supported shape): the
/// 32-byte fragment size, per PTX ISA 9.7.14.4.2 "Address Alignment" and the
/// CUDA API's "mptr must be a 256-bit aligned pointer".
const WMMA_BASE_ALIGN_BYTES: u64 = 32;

/// `wmma` stride granularity in bytes: the CUDA API's ldm contract (16 bytes),
/// not the ISA example's stricter 32, which would reject valid nvcc output
/// such as Conv2D-opt's bank-skewed 48-byte f16 pitch.
const WMMA_STRIDE_ALIGN_BYTES: u64 = 16;

/// Minimum legal `wmma.load`/`wmma.store` stride in elements: below the leading
/// dimension (16 for every m16n16k16 operand and layout) is UB, per PTX ISA
/// 9.7.14.4.3; larger strides are fine.
const WMMA_MIN_STRIDE_ELEMS: i64 = 16;

impl Interpreter<'_> {
    /// Execute a complete warp group blocked at `pc` with lane mask `mask`.
    /// `members` holds the *live* lanes (converged at `pc`); exited mask
    /// lanes arrive implicitly (see `find_ready_warp_group`).
    pub(in crate::eval) fn execute_warp_op(
        &mut self,
        pc: InstrId,
        mask: u32,
        members: &[ThreadId],
    ) -> EvalResult<()> {
        let instr = self
            .program
            .instruction(pc)
            .expect("warp group blocked at a valid pc")
            .clone();

        // Only live members (nonempty, all within the CTA) execute and advance.
        // Preconditions run before the stats bump below, so a rejected op
        // provably mutates nothing.
        self.check_warp_op_preconditions(pc, &instr, members)?;
        self.stats.warp_syncs += 1;
        let exit = self.record_warp_op_entry(pc, mask, members);

        match &instr {
            LoweredInstr::BarWarpSync { .. } => {}
            LoweredInstr::ElectSync { dst, dst_pred, .. } => {
                self.exec_elect_sync(members, *dst, *dst_pred);
            }
            LoweredInstr::ShflSync {
                mode,
                dst,
                dst_pred,
                src,
                offset_or_lane,
                clamp,
                ..
            } => {
                self.exec_shfl_sync(
                    pc,
                    mask,
                    members,
                    *mode,
                    *dst,
                    *dst_pred,
                    src,
                    offset_or_lane,
                    clamp,
                )?;
            }
            LoweredInstr::Ldmatrix {
                dst,
                addr,
                addr_offset,
                num,
                trans,
            } => {
                self.exec_ldmatrix(pc, members, dst, addr, *addr_offset, *num, *trans)?;
            }
            LoweredInstr::Stmatrix {
                addr,
                addr_offset,
                src,
                num,
                trans,
            } => {
                self.exec_stmatrix(pc, members, addr, *addr_offset, src, *num, *trans)?;
            }
            LoweredInstr::Movmatrix { dst, src } => self.exec_movmatrix(pc, members, *dst, src)?,
            LoweredInstr::Mma { .. } => self.exec_mma(pc, members, &instr)?,
            LoweredInstr::WmmaLoad { .. } => self.exec_wmma_load(pc, members, &instr)?,
            LoweredInstr::WmmaStore { .. } => self.exec_wmma_store(pc, members, &instr)?,
            LoweredInstr::WmmaMma { .. } => self.exec_wmma_mma(pc, members, &instr)?,
            LoweredInstr::Tcgen05Alloc {
                dst_base,
                dst_offset,
                num_cols,
            } => {
                self.exec_tcgen05_alloc(pc, members, dst_base, *dst_offset, num_cols)?;
            }
            LoweredInstr::Tcgen05Dealloc { taddr, num_cols } => {
                self.exec_tcgen05_dealloc(pc, members, taddr, num_cols)?;
            }
            LoweredInstr::Tcgen05RelinquishAllocPermit => {
                self.tensor.relinquish_alloc_permit();
                self.graph.tmem_relinquish(tix(members[0]), point(pc));
            }
            LoweredInstr::Setmaxnreg => {}
            LoweredInstr::Tcgen05Ld {
                shape,
                dst,
                taddr_base,
                taddr_offset,
            } => {
                self.exec_tcgen05_ld(pc, members, *shape, dst, (taddr_base, *taddr_offset))?;
            }
            LoweredInstr::Tcgen05St {
                shape,
                taddr_base,
                taddr_offset,
                src,
            } => {
                self.exec_tcgen05_st(pc, members, *shape, (taddr_base, *taddr_offset), src)?;
            }
            LoweredInstr::Tcgen05Wait { is_st } => {
                let wait = if *is_st {
                    Tcgen05Wait::St
                } else {
                    Tcgen05Wait::Ld
                };
                self.record_tcgen05_wait(members[0].0 / WARP_SIZE, wait, exit);
            }
            LoweredInstr::TensormapCpFenceproxy {
                dst_base,
                dst_offset,
                src_base,
                src_offset,
            } => {
                self.exec_tensormap_cp_fenceproxy(
                    pc,
                    members,
                    (dst_base, *dst_offset),
                    (src_base, *src_offset),
                )?;
            }
            other => unreachable!("{:?} passed warp-op preconditions", other),
        }

        self.record_collective_exit(exit, pc, members);
        self.advance_thread_group(members);
        Ok(())
    }

    /// Every precondition that rejects a warp op outright (unknown op, unsupported
    /// form, tensor-core full-warp rule), run before any state mutation;
    /// mid-execution errors rely on every `EvalError` aborting the analysis.
    fn check_warp_op_preconditions(
        &self,
        pc: InstrId,
        instr: &LoweredInstr,
        members: &[ThreadId],
    ) -> EvalResult<()> {
        match instr {
            // All three handle exited lanes per-op (Undefined data, arrived-at-sync),
            // and the ISA states no exited-lane UB for them, so a partial warp is fine.
            LoweredInstr::BarWarpSync { .. }
            | LoweredInstr::ShflSync { .. }
            | LoweredInstr::ElectSync { .. } => Ok(()),
            LoweredInstr::Ldmatrix { dst, num, .. } => {
                // In particular an exited address-supplying lane (`i*8 + r`) leaves
                // row r's footprint unknowable.
                self.require_live_warp(pc, members, "ldmatrix")?;
                if dst.len() != *num as usize {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("ldmatrix x{} with {} destination registers", num, dst.len()),
                    });
                }
                Ok(())
            }
            // `.aligned`: every lane supplies one register of the matrix.
            LoweredInstr::Movmatrix { .. } => self.require_live_warp(pc, members, "movmatrix"),
            LoweredInstr::Stmatrix { src, num, .. } => {
                // Same rationale as `Ldmatrix` above (its store-direction
                // mirror): the address-supplying lanes' registers must be
                // observable to compute each row's address.
                self.require_live_warp(pc, members, "stmatrix")?;
                if src.len() != *num as usize {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("stmatrix x{} with {} source operands", num, src.len()),
                    });
                }
                Ok(())
            }
            LoweredInstr::Mma {
                shape,
                a_layout,
                b_layout,
                a_type,
                ..
            } => {
                let supported = match a_type {
                    ScalarType::F16 | ScalarType::Bf16 => *shape == MmaShape::new(16, 8, 16),
                    ScalarType::Tf32 => {
                        *shape == MmaShape::new(16, 8, 8) || *shape == MmaShape::new(16, 8, 4)
                    }
                    ScalarType::E4m3 | ScalarType::S8 => *shape == MmaShape::new(16, 8, 32),
                    _ => false,
                };
                if !supported {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("mma shape {} with {:?} multiplicands", shape, a_type),
                    });
                }
                if (*a_layout, *b_layout) != (MmaLayout::Row, MmaLayout::Col) {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: "mma with non-row.col layouts".to_string(),
                    });
                }
                // Every lane owns a/b/c fragment elements the product needs.
                self.require_live_warp(pc, members, "mma.sync")
            }
            LoweredInstr::WmmaLoad { shape, .. }
            | LoweredInstr::WmmaStore { shape, .. }
            | LoweredInstr::WmmaMma { shape, .. } => self.check_wmma_shape(pc, members, *shape),
            // The behavior of the instruction is undefined if any thread in the warp has exited.
            LoweredInstr::Tcgen05Alloc { .. } => {
                self.require_live_warp(pc, members, "tcgen05.alloc")
            }
            LoweredInstr::Tcgen05Dealloc { .. } => {
                self.require_live_warp(pc, members, "tcgen05.dealloc")
            }
            LoweredInstr::Tcgen05RelinquishAllocPermit => {
                self.require_live_warp(pc, members, "tcgen05.relinquish_alloc_permit")
            }
            LoweredInstr::Tcgen05Ld { .. } => self.require_live_warp(pc, members, "tcgen05.ld"),
            LoweredInstr::Tcgen05St { .. } => self.require_live_warp(pc, members, "tcgen05.st"),
            // The ISA states no exited-lane UB for `tcgen05.wait::ld`/`::st`
            // (unlike `.alloc`/`.ld`/...), so a partial warp is accepted.
            LoweredInstr::Tcgen05Wait { .. } => Ok(()),
            // `.aligned`: every lane of the warp must execute this very instruction, so a lane
            // that exited instead is UB.
            LoweredInstr::TensormapCpFenceproxy { .. } if members.len() != WARP_SIZE as usize => {
                Err(EvalError::WarpMismatch {
                    pc,
                    reason: format!(
                        "tensormap.cp_fenceproxy is .aligned, so all 32 warp lanes must \
                         execute it, but only {} are live",
                        members.len()
                    ),
                })
            }
            LoweredInstr::TensormapCpFenceproxy { .. } => Ok(()),
            // `.aligned`: every thread of the warpgroup must execute the same `setmaxnreg`.
            LoweredInstr::Setmaxnreg if members.len() != WARP_SIZE as usize => {
                Err(EvalError::WarpMismatch {
                    pc,
                    reason: format!(
                        "setmaxnreg is .aligned, so all 32 warp lanes must execute it, but only \
                         {} are live",
                        members.len()
                    ),
                })
            }
            LoweredInstr::Setmaxnreg => Ok(()),
            other => Err(EvalError::Unsupported {
                pc,
                what: format!("warp-op dispatch for {:?}", other),
            }),
        }
    }

    /// Reject a tensor-core op (`ldmatrix`, `mma`, `wmma.*`) whose warp has exited
    /// lanes, UB "if any thread in the warp has exited" (PTX ISA 9.1): such lanes'
    /// addresses and fragments are unknowable. Fewer than 32 live members means exits.
    fn require_live_warp(&self, pc: InstrId, members: &[ThreadId], what: &str) -> EvalResult<()> {
        if members.len() != WARP_SIZE as usize {
            return Err(EvalError::WarpMismatch {
                pc,
                reason: format!(
                    "{} requires all 32 warp lanes live, but only {} are \
                     (the PTX ISA defines the instruction as undefined if \
                     any thread in the warp has exited)",
                    what,
                    members.len()
                ),
            });
        }
        Ok(())
    }

    /// `shfl.sync`: exchange register values within the mask group,
    /// following the PTX ISA source-lane computation.
    #[allow(clippy::too_many_arguments)]
    fn exec_shfl_sync(
        &mut self,
        pc: InstrId,
        mask: u32,
        members: &[ThreadId],
        mode: ShflMode,
        dst: RegId,
        dst_pred: Option<RegId>,
        src: &Operand,
        offset_or_lane: &Operand,
        clamp: &Operand,
    ) -> EvalResult<()> {
        // Gather every lane's source value first.
        let mut lane_src: [Option<Value>; WARP_SIZE as usize] = [None; WARP_SIZE as usize];
        for &m in members {
            let lane = (m.0 % WARP_SIZE) as usize;
            lane_src[lane] = Some(self.operand_value(m, pc, src)?);
        }

        // Compute each lane's source lane per the PTX ISA pseudocode.
        let mut results: Vec<(ThreadId, bool, Value)> = Vec::with_capacity(members.len());
        for &m in members {
            let lane = (m.0 % WARP_SIZE) as i64;
            let b = self.concrete_operand(m, pc, offset_or_lane, "shfl.sync lane operand")?;
            let c = self.concrete_operand(m, pc, clamp, "shfl.sync clamp operand")?;
            let bval = b & 0x1f;
            let cval = c & 0x1f;
            let segmask = (c >> 8) & 0x1f;
            let max_lane = (lane & segmask) | (cval & !segmask);
            let min_lane = lane & segmask;
            let (j0, pval) = match mode {
                ShflMode::Up => {
                    let j = lane - bval;
                    (j, j >= max_lane)
                }
                ShflMode::Down => {
                    let j = lane + bval;
                    (j, j <= max_lane)
                }
                ShflMode::Bfly => {
                    let j = lane ^ bval;
                    (j, j <= max_lane)
                }
                ShflMode::Idx => {
                    let j = min_lane | (bval & !segmask);
                    (j, j <= max_lane)
                }
            };
            let j = if pval { j0 } else { lane };
            debug_assert!((0..WARP_SIZE as i64).contains(&j));
            if mask & (1u32 << j) == 0 {
                return Err(EvalError::WarpMismatch {
                    pc,
                    reason: format!(
                        "lane {} reads lane {} which is outside mask {:#010x}",
                        lane, j, mask
                    ),
                });
            }
            let value = match lane_src[j as usize] {
                Some(v) => v,
                // Exited source lane: data is undefined per the shfl.sync ISA text
                // (lazy `Undefined`), but the predicate keeps its lane-arithmetic
                // value, so it is *true* for an in-range exited source.
                None => Value::Scalar(self.arena.undefined()),
            };
            results.push((m, pval, value));
        }

        for (m, pval, value) in results {
            self.write_reg(m, dst, value);
            if let Some(p) = dst_pred {
                let b = self.arena.bool_val(pval);
                self.write_reg(m, p, Value::Scalar(b));
            }
        }
        Ok(())
    }

    /// `elect.sync d|p, membermask`: the lowest-numbered live lane (`members[0]`,
    /// ascending) leads, deterministic per the ISA. Only the leader's `dst` is
    /// defined (its lane id); other live lanes get `Undefined`.
    fn exec_elect_sync(&mut self, members: &[ThreadId], dst: Option<RegId>, dst_pred: RegId) {
        let leader = members[0];
        for &m in members {
            let is_leader = m == leader;
            let p = self.arena.bool_val(is_leader);
            self.write_reg(m, dst_pred, Value::Scalar(p));
            if let Some(reg) = dst {
                let lane = m.0 % WARP_SIZE;
                let v = if is_leader {
                    self.arena.int(lane as i64)
                } else {
                    self.arena.undefined()
                };
                self.write_reg(m, reg, Value::Scalar(v));
            }
        }
    }

    /// `ldmatrix...xN.m8n8{.trans}.shared.b16`: lane `i*8 + r` supplies row `r` of
    /// matrix `i`; lane `l` gets (row `l/4`, cols `(l%4)*2`, `+1`) as one 4-byte read,
    /// or under `.trans` the transpose as two 2-byte reads. Preconditions already checked.
    #[allow(clippy::too_many_arguments)]
    fn exec_ldmatrix(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        dst: &[RegId],
        addr: &Operand,
        addr_offset: i64,
        num: u32,
        trans: bool,
    ) -> EvalResult<()> {
        // Row addresses come from the first num*8 lanes, each 16-byte aligned
        // (`LDMATRIX_ROW_BYTES`) regardless of `.trans`.
        let mut row_addr = vec![[0u64; 8]; num as usize];
        for i in 0..num as usize {
            for r in 0..8 {
                let m = members[i * 8 + r];
                let a = self.effective_addr(m, pc, addr, addr_offset)?;
                self.check_alignment(m, pc, MemSpace::Shared, a, LDMATRIX_ROW_BYTES)?;
                row_addr[i][r] = a;
            }
        }

        for &m in members {
            let lane = m.0 % WARP_SIZE;
            for (i, reg) in dst.iter().enumerate() {
                let v = if trans {
                    // Column `lane/4`, rows `2*(lane%4)` (lo half) and
                    // `2*(lane%4)+1` (hi half) - two independent 2-byte
                    // reads, since the elements are not adjacent in memory.
                    let col_byte = (lane / 4) as u64 * 2;
                    let lo_row = 2 * (lane % 4) as usize;
                    let lo =
                        self.mem_read(m, pc, MemSpace::Shared, row_addr[i][lo_row] + col_byte, 2)?;
                    let hi = self.mem_read(
                        m,
                        pc,
                        MemSpace::Shared,
                        row_addr[i][lo_row + 1] + col_byte,
                        2,
                    )?;
                    match (lo, hi) {
                        // f16/bf16 data: each 2-byte read is one plain
                        // scalar element.
                        (Value::Scalar(lo), Value::Scalar(hi)) => Value::Pair(lo, hi),
                        // Byte-granular (fp8) data: each 2-byte read is a `Pair`
                        // half of a `Quad` granule; the halves recombine.
                        (Value::Pair(b0, b1), Value::Pair(b2, b3)) => Value::Quad(b0, b1, b2, b3),
                        _ => {
                            return Err(EvalError::ValueKindMismatch {
                                thread: m,
                                pc,
                                what: "ldmatrix.trans read a value that is neither \
                                       an f16 scalar nor an fp8 byte pair",
                            });
                        }
                    }
                } else {
                    // Wrap-free in every profile: the row address passed
                    // the 16-byte alignment check above, so it is at most
                    // `u64::MAX - 15`, and the lane offset is at most 12.
                    let byte = row_addr[i][(lane / 4) as usize] + (lane % 4) as u64 * 4;
                    self.mem_read(m, pc, MemSpace::Shared, byte, 4)?
                };
                self.write_reg(m, *reg, v);
            }
        }
        Ok(())
    }

    /// `movmatrix.sync.aligned.m8n8.trans.b16`: the warp holds an 8x8 matrix,
    /// two elements per lane, and each lane receives the elements at the same
    /// position of the transposed matrix.
    fn exec_movmatrix(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        dst: RegId,
        src: &Operand,
    ) -> EvalResult<()> {
        let mut matrix = [[self.undefined; 8]; 8];
        for &m in members {
            let (row, col) = movmatrix_position(m);
            let value = self.operand_value(m, pc, src)?;
            let (lo, hi) = self.b16_halves(m, pc, value)?;
            matrix[row][col] = lo;
            matrix[row][col + 1] = hi;
        }
        for &m in members {
            let (row, col) = movmatrix_position(m);
            let transposed = Value::Pair(matrix[col][row], matrix[col + 1][row]);
            self.write_reg(m, dst, transposed);
        }
        Ok(())
    }

    /// The two b16 elements packed in a 32-bit register. A plain scalar is
    /// rejected: decoding its bits needs f16 or bf16, which `.b16` leaves open.
    fn b16_halves(&self, t: ThreadId, pc: InstrId, v: Value) -> EvalResult<(ExprId, ExprId)> {
        match v {
            Value::Pair(lo, hi) => Ok((lo, hi)),
            Value::Scalar(e) if e == self.undefined => Ok((e, e)),
            _ => Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "movmatrix source that is not a packed pair of b16 elements",
            }),
        }
    }

    /// `ldmatrix`'s store-direction mirror: same row-address computation, but
    /// writes each lane's source operand to shared memory.
    #[allow(clippy::too_many_arguments)]
    fn exec_stmatrix(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        addr: &Operand,
        addr_offset: i64,
        src: &[Operand],
        num: u32,
        trans: bool,
    ) -> EvalResult<()> {
        let mut row_addr = vec![[0u64; 8]; num as usize];
        for i in 0..num as usize {
            for r in 0..8 {
                let m = members[i * 8 + r];
                let a = self.effective_addr(m, pc, addr, addr_offset)?;
                self.check_alignment(m, pc, MemSpace::Shared, a, LDMATRIX_ROW_BYTES)?;
                row_addr[i][r] = a;
            }
        }

        for &m in members {
            let lane = m.0 % WARP_SIZE;
            for (i, op) in src.iter().enumerate() {
                let v = self.operand_value(m, pc, op)?;
                if trans {
                    let col_byte = (lane / 4) as u64 * 2;
                    let lo_row = 2 * (lane % 4) as usize;
                    let Value::Pair(lo, hi) = v else {
                        return Err(EvalError::ValueKindMismatch {
                            thread: m,
                            pc,
                            what: "stmatrix.trans source must be a packed pair (two 2-byte halves)",
                        });
                    };
                    self.mem_write(
                        m,
                        pc,
                        MemSpace::Shared,
                        row_addr[i][lo_row] + col_byte,
                        2,
                        Value::Scalar(lo),
                    )?;
                    self.mem_write(
                        m,
                        pc,
                        MemSpace::Shared,
                        row_addr[i][lo_row + 1] + col_byte,
                        2,
                        Value::Scalar(hi),
                    )?;
                } else {
                    // Wrap-free for the same reason `exec_ldmatrix`'s
                    // non-trans read is: the row address passed the
                    // 16-byte alignment check above.
                    let byte = row_addr[i][(lane / 4) as usize] + (lane % 4) as u64 * 4;
                    self.mem_write(m, pc, MemSpace::Shared, byte, 4, v)?;
                }
            }
        }
        Ok(())
    }

    /// `mma.sync.aligned` m16n8k16 f16, m16n8k8/k4 tf32 (one real per register,
    /// gathered like f32 accumulators), and m16n8k32 e4m3 (`Value::Quad` byte
    /// lanes); shape, layout, and full-warp liveness are already checked.
    fn exec_mma(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        instr: &LoweredInstr,
    ) -> EvalResult<()> {
        let LoweredInstr::Mma {
            shape,
            dst,
            src_a,
            src_b,
            src_c,
            a_type,
            b_type,
            d_type,
            ..
        } = instr
        else {
            unreachable!()
        };

        // An `.f16` accumulator holds the same four C/D elements packed
        // two to a register; every other modeled accumulator (f32, s32)
        // is one unpacked element per register.
        let packed_accumulator = *d_type == ScalarType::F16;
        let accumulator = |lane: u32| {
            if packed_accumulator {
                m16n8k16_f16::matrix_cd_f16(lane)
            } else {
                m16n8k16_f16::matrix_cd(lane)
            }
        };
        let (m_dim, n_dim, k_dim) = (shape.m, shape.n, shape.k);
        let mut a = Grid::new(m_dim as usize, k_dim as usize);
        let mut b = Grid::new(k_dim as usize, n_dim as usize);
        let mut c = Grid::new(m_dim as usize, n_dim as usize);
        for &m in members {
            let lane = m.0 % WARP_SIZE;
            match (a_type, k_dim) {
                (ScalarType::Tf32, 8) => {
                    self.gather_scalar_fragment(
                        pc,
                        m,
                        src_a,
                        &m16n8k8_tf32::matrix_a(lane),
                        &mut a,
                    )?;
                    self.gather_scalar_fragment(
                        pc,
                        m,
                        src_b,
                        &m16n8k8_tf32::matrix_b(lane),
                        &mut b,
                    )?;
                }
                (ScalarType::Tf32, 4) => {
                    self.gather_scalar_fragment(
                        pc,
                        m,
                        src_a,
                        &m16n8k4_tf32::matrix_a(lane),
                        &mut a,
                    )?;
                    self.gather_scalar_fragment(
                        pc,
                        m,
                        src_b,
                        &m16n8k4_tf32::matrix_b(lane),
                        &mut b,
                    )?;
                }
                (ScalarType::E4m3 | ScalarType::S8, 32) => {
                    let elems = m16n8k32_byte::matrix_a(lane);
                    self.gather_byte_fragment(pc, m, (src_a, *a_type), &elems, &mut a)?;
                    let elems = m16n8k32_byte::matrix_b(lane);
                    self.gather_byte_fragment(pc, m, (src_b, *b_type), &elems, &mut b)?;
                }
                _ => {
                    self.gather_f16_fragment(pc, m, src_a, &m16n8k16_f16::matrix_a(lane), &mut a)?;
                    self.gather_f16_fragment(pc, m, src_b, &m16n8k16_f16::matrix_b(lane), &mut b)?;
                }
            }
            let elems = accumulator(lane);
            if packed_accumulator {
                self.gather_packed_accumulator(pc, m, src_c, &elems, &mut c)?;
            } else {
                self.gather_f32_fragment(pc, m, src_c, &elems, &mut c)?;
            }
        }

        let d = self.matmul_acc(pc, &a, &b, &c, m_dim, n_dim, k_dim)?;

        for &m in members {
            let lane = m.0 % WARP_SIZE;
            let elems = accumulator(lane);
            if packed_accumulator {
                // `matrix_cd_f16` lists each register's low half then its
                // high half, so consecutive pairs repack one register.
                for [lo, hi] in elems.as_chunks::<2>().0 {
                    let value = Value::Pair(d.get(lo.row, lo.col, pc)?, d.get(hi.row, hi.col, pc)?);
                    self.threads[m].regs.write(dst[lo.reg_idx], value);
                }
            } else {
                for elem in elems {
                    let e = d.get(elem.row, elem.col, pc)?;
                    self.threads[m]
                        .regs
                        .write(dst[elem.reg_idx], Value::Scalar(e));
                }
            }
        }
        Ok(())
    }

    /// `wmma.load.{a,b,c}.sync.aligned.{row,col}.m16n16k16{.shared}.{f16,f32}`;
    /// shape and full-warp liveness are already checked.
    fn exec_wmma_load(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        instr: &LoweredInstr,
    ) -> EvalResult<()> {
        let LoweredInstr::WmmaLoad {
            operand,
            layout,
            dst,
            addr,
            addr_offset,
            stride,
            elem_type,
            space,
            ..
        } = instr
        else {
            unreachable!()
        };

        let base = (self.uniform_concrete(pc, members, addr, "wmma.load address")? as u64)
            .wrapping_add(*addr_offset as u64);
        let stride = self.uniform_concrete(pc, members, stride, "wmma.load stride")?;
        let stride =
            self.check_wmma_addressing(pc, members[0], *space, base, stride, *elem_type)?;

        match operand {
            MmaOperand::A | MmaOperand::B => {
                if !matches!(elem_type, ScalarType::F16 | ScalarType::B16) {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("wmma.load a/b with element type {:?}", elem_type),
                    });
                }
                for &m in members {
                    let lane = m.0 % WARP_SIZE;
                    let elems = match operand {
                        MmaOperand::A => m16n16k16_f16::matrix_a_row(lane),
                        _ => m16n16k16_f16::matrix_b_row(lane),
                    };
                    let mut lo: Vec<Option<ExprId>> = vec![None; dst.len()];
                    let mut hi: Vec<Option<ExprId>> = vec![None; dst.len()];
                    for elem in &elems {
                        let off = elem_offset(*layout, elem.row, elem.col, stride);
                        let byte = base + off * 2;
                        let v = self.mem_read(m, pc, *space, byte, 2)?;
                        let Value::Scalar(e) = v else {
                            return Err(EvalError::ValueKindMismatch {
                                thread: m,
                                pc,
                                what: "wmma.load f16 element is not a scalar",
                            });
                        };
                        if elem.high_half == Some(true) {
                            hi[elem.reg_idx] = Some(e);
                        } else {
                            lo[elem.reg_idx] = Some(e);
                        }
                    }
                    for (r, reg) in dst.iter().enumerate() {
                        let (Some(l), Some(h)) = (lo[r], hi[r]) else {
                            return Err(EvalError::Unsupported {
                                pc,
                                what: "incomplete wmma fragment".to_string(),
                            });
                        };
                        self.write_reg(m, *reg, Value::Pair(l, h));
                    }
                }
            }
            MmaOperand::C => {
                for &m in members {
                    let lane = m.0 % WARP_SIZE;
                    for elem in m16n16k16_f16::matrix_cd_f32(lane) {
                        let off = elem_offset(*layout, elem.row, elem.col, stride);
                        let byte = base + off * 4;
                        let v = self.mem_read(m, pc, *space, byte, 4)?;
                        let Value::Scalar(e) = v else {
                            return Err(EvalError::ValueKindMismatch {
                                thread: m,
                                pc,
                                what: "wmma.load f32 element is not a scalar",
                            });
                        };
                        self.threads[m]
                            .regs
                            .write(dst[elem.reg_idx], Value::Scalar(e));
                    }
                }
            }
            MmaOperand::D => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: "wmma.load.d".to_string(),
                });
            }
        }
        Ok(())
    }

    /// `wmma.store.d.sync.aligned.{row,col}.m16n16k16{.shared}.f32`; shape and
    /// full-warp liveness are already checked.
    fn exec_wmma_store(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        instr: &LoweredInstr,
    ) -> EvalResult<()> {
        let LoweredInstr::WmmaStore {
            layout,
            src,
            addr,
            addr_offset,
            stride,
            elem_type,
            space,
            ..
        } = instr
        else {
            unreachable!()
        };

        let base = (self.uniform_concrete(pc, members, addr, "wmma.store address")? as u64)
            .wrapping_add(*addr_offset as u64);
        let stride = self.uniform_concrete(pc, members, stride, "wmma.store stride")?;
        let stride =
            self.check_wmma_addressing(pc, members[0], *space, base, stride, *elem_type)?;

        for &m in members {
            let lane = m.0 % WARP_SIZE;
            for elem in m16n16k16_f16::matrix_cd_f32(lane) {
                let v = self.read_reg(m, src[elem.reg_idx]);
                let off = elem_offset(*layout, elem.row, elem.col, stride);
                let byte = base + off * 4;
                self.mem_write(m, pc, *space, byte, 4, v)?;
            }
        }
        Ok(())
    }

    /// `wmma.mma.sync.aligned.{row,col}.{row,col}.m16n16k16.f32.f32`. Layouts only
    /// describe how A/B were loaded, so the compute needs just the fragment
    /// position maps; shape and full-warp liveness are already checked.
    fn exec_wmma_mma(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        instr: &LoweredInstr,
    ) -> EvalResult<()> {
        let LoweredInstr::WmmaMma {
            dst,
            src_a,
            src_b,
            src_c,
            ..
        } = instr
        else {
            unreachable!()
        };

        // `wmma.mma`'s C is always a register, but `gather_f32_fragment` takes
        // operands (to serve `Mma`'s immediates too), so lift them.
        let src_c_ops: Vec<Operand> = src_c.iter().copied().map(Operand::Reg).collect();

        let mut a = Grid::new(16, 16);
        let mut b = Grid::new(16, 16);
        let mut c = Grid::new(16, 16);
        for &m in members {
            let lane = m.0 % WARP_SIZE;
            self.gather_f16_fragment(pc, m, src_a, &m16n16k16_f16::matrix_a_row(lane), &mut a)?;
            self.gather_f16_fragment(pc, m, src_b, &m16n16k16_f16::matrix_b_row(lane), &mut b)?;
            self.gather_f32_fragment(
                pc,
                m,
                &src_c_ops,
                &m16n16k16_f16::matrix_cd_f32(lane),
                &mut c,
            )?;
        }

        let d = self.matmul_acc(pc, &a, &b, &c, 16, 16, 16)?;

        for &m in members {
            let lane = m.0 % WARP_SIZE;
            for elem in m16n16k16_f16::matrix_cd_f32(lane) {
                let e = d.get(elem.row, elem.col, pc)?;
                self.threads[m]
                    .regs
                    .write(dst[elem.reg_idx], Value::Scalar(e));
            }
        }
        Ok(())
    }

    // =====================================================================
    // Shared helpers
    // =====================================================================

    /// Precondition of every wmma op (called from
    /// `check_warp_op_preconditions`, before any state changes): the one
    /// supported m16n16k16 shape, with all 32 lanes live.
    fn check_wmma_shape(
        &self,
        pc: InstrId,
        members: &[ThreadId],
        shape: MmaShape,
    ) -> EvalResult<()> {
        if shape != MmaShape::new(16, 16, 16) {
            return Err(EvalError::Unsupported {
                pc,
                what: format!("wmma shape {}", shape),
            });
        }
        // Every lane owns fragment elements (and the loads/stores need the
        // whole warp's footprint).
        self.require_live_warp(pc, members, "wmma")?;
        Ok(())
    }

    /// Validate a `wmma.load`/`.store` base and stride against the m16n16k16
    /// storage rules (`WMMA_BASE_ALIGN_BYTES`, `WMMA_STRIDE_ALIGN_BYTES`,
    /// `WMMA_MIN_STRIDE_ELEMS`), returning the stride.
    fn check_wmma_addressing(
        &self,
        pc: InstrId,
        lead: ThreadId,
        space: MemSpace,
        base: u64,
        stride: i64,
        elem_type: ScalarType,
    ) -> EvalResult<u64> {
        if stride < WMMA_MIN_STRIDE_ELEMS {
            return Err(EvalError::WmmaStrideTooSmall {
                pc,
                stride,
                minimum: WMMA_MIN_STRIDE_ELEMS as u64,
            });
        }
        let stride = stride as u64;
        self.check_alignment(lead, pc, space, base, WMMA_BASE_ALIGN_BYTES)?;
        // The 16x16 footprint must fit in u64 (checked in u128, release-active),
        // making the per-element address sums below provably wrap-free so no
        // wrapped value reaches the bounds checker as a small address.
        let elem_bytes = elem_type.size_bytes() as u128;
        let max_off = 15u128 * stride as u128 + 15;
        if base as u128 + max_off * elem_bytes > u64::MAX as u128 {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "wmma footprint from base {:#x} with stride {} overflows the address space",
                    base, stride
                ),
            });
        }
        let row_bytes = elem_type.size_bytes() as u64 * stride;
        if !row_bytes.is_multiple_of(WMMA_STRIDE_ALIGN_BYTES) {
            // With `base` aligned, the first misaligned leading-dimension
            // instance is the second one, at `base + row_bytes`.
            return Err(EvalError::Misaligned {
                thread: lead,
                pc,
                space,
                addr: base + row_bytes,
                required: WMMA_STRIDE_ALIGN_BYTES,
            });
        }
        Ok(stride)
    }

    /// Resolve an operand that must be concrete and identical on every lane.
    pub(in crate::eval) fn uniform_concrete(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        op: &Operand,
        what: &'static str,
    ) -> EvalResult<i64> {
        let mut result: Option<i64> = None;
        for &m in members {
            let v = self.concrete_operand(m, pc, op, what)?;
            match result {
                None => result = Some(v),
                Some(prev) if prev == v => {}
                Some(prev) => {
                    return Err(EvalError::WarpMismatch {
                        pc,
                        reason: format!("{} differs across lanes ({} vs {})", what, prev, v),
                    });
                }
            }
        }
        result.ok_or(EvalError::WarpMismatch {
            pc,
            reason: "empty warp group".to_string(),
        })
    }

    /// `tcgen05.alloc`: allocate `num_cols` Tensor Memory columns, writing the
    /// address to shared `dst` once per firing (warp-uniform operands, PTX ISA
    /// 9.7.17.7), attributed to the leader lane.
    fn exec_tcgen05_alloc(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        dst_base: &Operand,
        dst_offset: i64,
        num_cols: &Operand,
    ) -> EvalResult<()> {
        let base = self.uniform_concrete(pc, members, dst_base, "tcgen05.alloc dst address")?;
        let num_cols = self.uniform_concrete(pc, members, num_cols, "tcgen05.alloc nCols")? as u32;
        let dst_addr = shared_operand_addr((base as u64).wrapping_add(dst_offset as u64));
        let leader = members[0];
        let taddr = self
            .tensor
            .alloc(num_cols)
            .map_err(|e| EvalError::from_tensor_mem(leader, pc, e))?;
        self.graph
            .tmem_alloc(tix(leader), point(pc), taddr as u16, num_cols as u16);
        let value = Value::Scalar(self.arena.int(taddr as i64));
        self.mem_write(leader, pc, MemSpace::Shared, dst_addr, 4, value)
    }

    /// `tensormap.cp_fenceproxy`: copy the tensor map at shared `src` to global `dst` once per
    /// firing (warp-uniform operands), then release it, attributed to the leader lane.
    fn exec_tensormap_cp_fenceproxy(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        (dst_base, dst_offset): (&Operand, i64),
        (src_base, src_offset): (&Operand, i64),
    ) -> EvalResult<()> {
        let dst = self.uniform_concrete(pc, members, dst_base, "tensormap.cp_fenceproxy dst")?;
        let src = self.uniform_concrete(pc, members, src_base, "tensormap.cp_fenceproxy src")?;
        let dst = (dst as u64).wrapping_add(dst_offset as u64);
        let src = (src as u64).wrapping_add(src_offset as u64);
        let leader = members[0];
        self.check_bounds(leader, pc, MemSpace::Shared, src, TENSOR_MAP_BYTES)?;
        self.check_bounds(leader, pc, MemSpace::Global, dst, TENSOR_MAP_BYTES)?;
        if self
            .tensor_maps
            .copy_entry(MemSpace::Global, dst, MemSpace::Shared, src)
            .is_none()
        {
            return Err(EvalError::TensorMapNotFound {
                thread: leader,
                pc,
                space: MemSpace::Shared,
                addr: src,
            });
        }
        self.record_mem_access(
            leader,
            pc,
            MemSpace::Shared,
            src,
            TENSOR_MAP_BYTES,
            None,
            AccessOrigin::Thread,
        );
        self.record_opaque_write(leader, pc, MemSpace::Global, dst, TENSOR_MAP_BYTES);
        self.graph
            .fence(tix(leader), point(pc), FenceKind::TensormapRelease);
        Ok(())
    }

    /// `tcgen05.dealloc`: free the warp-uniform range at `taddr`.
    fn exec_tcgen05_dealloc(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        taddr: &Operand,
        num_cols: &Operand,
    ) -> EvalResult<()> {
        let taddr = self.uniform_concrete(pc, members, taddr, "tcgen05.dealloc taddr")? as u32;
        let num_cols =
            self.uniform_concrete(pc, members, num_cols, "tcgen05.dealloc nCols")? as u32;
        self.tensor
            .dealloc(taddr, num_cols)
            .map_err(|e| EvalError::from_tensor_mem(members[0], pc, e))?;
        self.graph
            .tmem_dealloc(tix(members[0]), point(pc), taddr as u16, num_cols as u16);
        Ok(())
    }

    /// The Tensor Memory lane quadrant (32 of 128 lanes) a thread's warp may access:
    /// its warpgroup-relative warp id (PTX ISA 9.7.17.8.1). Used only to validate the
    /// quadrant `taddr` encodes, never to derive the lane.
    fn tcgen05_lane(t: ThreadId) -> u32 {
        t.0 % 128
    }

    /// Decode a `tcgen05.ld`/`.st` `taddr` as `[31:16] = lane, [15:0] = column`
    /// (PTX ISA 9.7.17.1.1), requiring the `num_lanes` span to lie in the warp's own
    /// quadrant (9.7.17.8.1); a wrong quadrant is UB, so a hard error, never corrected.
    fn tcgen05_decode_taddr(
        pc: InstrId,
        members: &[ThreadId],
        raw: i64,
        num_lanes: u32,
    ) -> EvalResult<(u32, u32)> {
        let packed = raw as u32;
        let lane_base = packed >> 16;
        let col = packed & 0xFFFF;
        let expected = (Self::tcgen05_lane(members[0]) / WARP_SIZE) * WARP_SIZE;
        if lane_base < expected || lane_base + num_lanes > expected + WARP_SIZE {
            return Err(EvalError::Tcgen05LaneRestrictionViolation {
                thread: members[0],
                pc,
                lane_base,
                expected_quadrant_base: expected,
            });
        }
        Ok((lane_base, col))
    }

    /// `tcgen05.ld`: load `dst.len()` Tensor Memory columns from `taddr`, one per
    /// register, each thread its own lane.
    fn exec_tcgen05_ld(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        shape: Tcgen05LdStShape,
        dst: &[RegId],
        (taddr_base, taddr_offset): (&Operand, i64),
    ) -> EvalResult<()> {
        let base = self.uniform_concrete(pc, members, taddr_base, "tcgen05.ld taddr")?;
        let (lane_base, base_col) =
            Self::tcgen05_decode_taddr(pc, members, base + taddr_offset, shape.num_lanes())?;
        let num_cols = shape.num_cols(dst.len());
        self.tensor
            .check_range(base_col, num_cols)
            .map_err(|e| EvalError::from_tensor_mem(members[0], pc, e))?;
        let op = self.record_async_issue(members[0], pc, AsyncOpKind::Tcgen05Ld);
        for &m in members {
            let cells = (0..dst.len() as u32).map(|k| shape.cell(m.0 % WARP_SIZE, k));
            let effect = (AccessMode::Read, OperandRole::TmemData);
            self.record_tmem_cells(op, m, effect, lane_base, base_col, cells);
        }
        self.record_tcgen05_pending(members[0].0 / WARP_SIZE, Tcgen05Wait::Ld, op);
        for &m in members {
            for (k, &reg) in dst.iter().enumerate() {
                let (lane, col) = shape.cell(m.0 % WARP_SIZE, k as u32);
                let (lane, col) = (lane_base + lane, base_col + col);
                let v = match self.tmem_read(m, pc, lane, col)? {
                    Some(v) => v,
                    None => Value::Scalar(self.arena.undefined()),
                };
                self.write_reg(m, reg, v);
            }
        }
        Ok(())
    }

    /// `tcgen05.st`: the mirror of `exec_tcgen05_ld`, each thread evaluating `src`
    /// against its own registers. The whole [`Value`] lands in the cell, packed
    /// halves included (`f16x2` operands for a later `tcgen05.mma [a-tmem]`).
    fn exec_tcgen05_st(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        shape: Tcgen05LdStShape,
        (taddr_base, taddr_offset): (&Operand, i64),
        src: &[Operand],
    ) -> EvalResult<()> {
        let base = self.uniform_concrete(pc, members, taddr_base, "tcgen05.st taddr")?;
        let (lane_base, base_col) =
            Self::tcgen05_decode_taddr(pc, members, base + taddr_offset, shape.num_lanes())?;
        let num_cols = shape.num_cols(src.len());
        self.tensor
            .check_range(base_col, num_cols)
            .map_err(|e| EvalError::from_tensor_mem(members[0], pc, e))?;
        let op = self.record_async_issue(members[0], pc, AsyncOpKind::Tcgen05St);
        for &m in members {
            let cells = (0..src.len() as u32).map(|k| shape.cell(m.0 % WARP_SIZE, k));
            let effect = (AccessMode::Write, OperandRole::TmemData);
            self.record_tmem_cells(op, m, effect, lane_base, base_col, cells);
        }
        self.record_tcgen05_pending(members[0].0 / WARP_SIZE, Tcgen05Wait::St, op);
        for &m in members {
            for (k, op) in src.iter().enumerate() {
                let (lane, col) = shape.cell(m.0 % WARP_SIZE, k as u32);
                let (lane, col) = (lane_base + lane, base_col + col);
                let v = self.operand_value(m, pc, op)?;
                if let Value::Mbarrier(_) = v {
                    return Err(EvalError::ValueKindMismatch {
                        thread: m,
                        pc,
                        what: "mbarrier handle stored to Tensor Memory",
                    });
                }
                self.tensor
                    .write(lane, col, v)
                    .map_err(|e| EvalError::from_tensor_mem(m, pc, e))?;
            }
        }
        Ok(())
    }

    /// Place one lane's packed-f16 fragment registers into a matrix grid.
    fn gather_f16_fragment(
        &mut self,
        pc: InstrId,
        m: ThreadId,
        regs: &[RegId],
        elems: &[FragmentElement],
        grid: &mut Grid,
    ) -> EvalResult<()> {
        for elem in elems {
            let v = self.read_reg(m, regs[elem.reg_idx]);
            let Value::Pair(lo, hi) = v else {
                return Err(EvalError::ValueKindMismatch {
                    thread: m,
                    pc,
                    what: "matrix fragment register does not hold a packed f16 pair",
                });
            };
            let e = if elem.high_half == Some(true) { hi } else { lo };
            grid.set(elem.row, elem.col, e);
        }
        Ok(())
    }

    /// Place one lane's byte-packed (fp8 or 8-bit integer, `m16n8k32` layout)
    /// fragment registers into a grid: symbolic `Value::Quad` lanes are already
    /// element values, while a concrete `e4m3` lane is a raw byte, decoded here.
    fn gather_byte_fragment(
        &mut self,
        pc: InstrId,
        m: ThreadId,
        (regs, ty): (&[RegId], ScalarType),
        elems: &[FragmentElement],
        grid: &mut Grid,
    ) -> EvalResult<()> {
        for elem in elems {
            let v = self.read_reg(m, regs[elem.reg_idx]);
            let Value::Quad(b0, b1, b2, b3) = v else {
                return Err(EvalError::ValueKindMismatch {
                    thread: m,
                    pc,
                    what: "matrix fragment register does not hold packed byte lanes",
                });
            };
            let e = match elem.quad_lane {
                Some(0) => b0,
                Some(1) => b1,
                Some(2) => b2,
                Some(3) => b3,
                _ => unreachable!("byte-packed fragment elements always carry a quad_lane"),
            };
            let e = float_bits::decode_float_bits(&mut self.arena, pc, ty, e)?;
            grid.set(elem.row, elem.col, e);
        }
        Ok(())
    }

    /// Place one lane's fragment of unpacked 32-bit registers (tf32
    /// multiplicands) into a matrix grid.
    fn gather_scalar_fragment(
        &mut self,
        pc: InstrId,
        m: ThreadId,
        regs: &[RegId],
        elems: &[FragmentElement],
        grid: &mut Grid,
    ) -> EvalResult<()> {
        for elem in elems {
            let v = self.read_reg(m, regs[elem.reg_idx]);
            let Value::Scalar(e) = v else {
                return Err(EvalError::ValueKindMismatch {
                    thread: m,
                    pc,
                    what: "tf32 fragment register holds a packed pair",
                });
            };
            let e = float_bits::decode_float_bits(&mut self.arena, pc, ScalarType::Tf32, e)?;
            grid.set(elem.row, elem.col, e);
        }
        Ok(())
    }

    /// Place one lane's f32 accumulator fragment into a grid. Takes operands,
    /// not registers: an `mma.sync` accumulator may be an immediate (nvcc's
    /// "first tile has no accumulator yet" idiom).
    fn gather_f32_fragment(
        &mut self,
        pc: InstrId,
        m: ThreadId,
        ops: &[Operand],
        elems: &[FragmentElement],
        grid: &mut Grid,
    ) -> EvalResult<()> {
        for elem in elems {
            let v = self.operand_value(m, pc, &ops[elem.reg_idx])?;
            let Value::Scalar(e) = v else {
                return Err(EvalError::ValueKindMismatch {
                    thread: m,
                    pc,
                    what: "accumulator fragment register holds a packed pair",
                });
            };
            let e = float_bits::decode_float_bits(&mut self.arena, pc, ScalarType::F32, e)?;
            grid.set(elem.row, elem.col, e);
        }
        Ok(())
    }

    /// Place one lane's `.f16` accumulator fragment into a grid: the elements
    /// [`Self::gather_f32_fragment`] reads, two per register, via `pair_operand`
    /// (which also decodes a first tile's zeroed `mov.b32` into two halves).
    fn gather_packed_accumulator(
        &mut self,
        pc: InstrId,
        m: ThreadId,
        ops: &[Operand],
        elems: &[FragmentElement],
        grid: &mut Grid,
    ) -> EvalResult<()> {
        for elem in elems {
            let (lo, hi) = self.pair_operand(m, pc, &ops[elem.reg_idx], ScalarType::F16)?;
            let e = if elem.high_half == Some(true) { hi } else { lo };
            grid.set(elem.row, elem.col, e);
        }
        Ok(())
    }

    /// `D = A * B + C` over the arena, as an fma chain per element.
    #[allow(clippy::too_many_arguments)] // internal helper; the args are the mma shape
    fn matmul_acc(
        &mut self,
        pc: InstrId,
        a: &Grid,
        b: &Grid,
        c: &Grid,
        m: u32,
        n: u32,
        k: u32,
    ) -> EvalResult<Grid> {
        let mut d = Grid::new(m as usize, n as usize);
        for i in 0..m {
            for j in 0..n {
                let mut acc = c.get(i, j, pc)?;
                for kk in 0..k {
                    let av = a.get(i, kk, pc)?;
                    let bv = b.get(kk, j, pc)?;
                    acc = self.arena.fma(av, bv, acc);
                }
                d.set(i, j, acc);
            }
        }
        Ok(d)
    }
}

#[cfg(test)]
mod tcgen05_taddr_tests {
    use super::*;

    #[test]
    fn accepts_the_issuing_warps_own_quadrant() {
        // Warp 1 within its warpgroup (threads 32..63) -> quadrant base 32,
        // packed at bits [31:16] per PTX ISA 9.7.17.1.1.
        let members: Vec<ThreadId> = (32..64).map(ThreadId).collect();
        let raw = (32i64 << 16) | 7; // lane_base=32, col=7
        let (lane_base, col) =
            Interpreter::tcgen05_decode_taddr(InstrId(0), &members, raw, 32).unwrap();
        assert_eq!(lane_base, 32);
        assert_eq!(col, 7);
    }

    #[test]
    fn rejects_an_address_missing_the_issuing_warps_quadrant() {
        // Warp 1 (quadrant base 32) issuing a bare column with no lane field
        // (lane_base=0): a real kernel bug, not to be papered over.
        let members: Vec<ThreadId> = (32..64).map(ThreadId).collect();
        let raw = 7i64;
        let err = Interpreter::tcgen05_decode_taddr(InstrId(0), &members, raw, 32).unwrap_err();
        assert!(matches!(
            err,
            EvalError::Tcgen05LaneRestrictionViolation {
                lane_base: 0,
                expected_quadrant_base: 32,
                ..
            }
        ));
    }

    #[test]
    fn accepts_the_upper_half_of_the_quadrant_for_a_16_lane_shape() {
        // `.16x256b` reaches a quadrant's lanes 16..31 with a lane field
        // of quadrant base + 16 - how a kernel covers all 32 of its lanes
        // with two such accesses.
        let members: Vec<ThreadId> = (32..64).map(ThreadId).collect();
        let raw = (48i64 << 16) | 5;
        let (lane_base, col) =
            Interpreter::tcgen05_decode_taddr(InstrId(0), &members, raw, 16).unwrap();
        assert_eq!(lane_base, 48);
        assert_eq!(col, 5);
    }

    #[test]
    fn rejects_a_16_lane_shape_running_past_the_quadrant() {
        // Lane base 48 is warp 1's own, but a 32-lane shape from there
        // would spill into warp 2's quadrant.
        let members: Vec<ThreadId> = (32..64).map(ThreadId).collect();
        let raw = (48i64 << 16) | 5;
        let err = Interpreter::tcgen05_decode_taddr(InstrId(0), &members, raw, 32).unwrap_err();
        assert!(matches!(
            err,
            EvalError::Tcgen05LaneRestrictionViolation {
                lane_base: 48,
                expected_quadrant_base: 32,
                ..
            }
        ));
    }

    #[test]
    fn rejects_an_address_encoding_a_different_warps_quadrant() {
        // Warp 0 (threads 0..31, quadrant base 0) issuing with an address
        // that packs warp 1's quadrant (32) - cross-quadrant addressing,
        // explicitly restricted by PTX ISA 9.7.17.8.1.
        let members: Vec<ThreadId> = (0..32).map(ThreadId).collect();
        let raw = (32i64 << 16) | 3;
        let err = Interpreter::tcgen05_decode_taddr(InstrId(0), &members, raw, 32).unwrap_err();
        assert!(matches!(
            err,
            EvalError::Tcgen05LaneRestrictionViolation {
                lane_base: 32,
                expected_quadrant_base: 0,
                ..
            }
        ));
    }
}
