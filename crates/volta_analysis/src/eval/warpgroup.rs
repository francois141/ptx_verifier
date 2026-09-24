//! Warpgroup-cooperative operations: `wgmma.mma_async` (PTX ISA 9.7.17.5.2).
//!
//! Additive, parallel machinery to `eval::warp`'s 32-lane warp-cooperative
//! ops - not a generalization of it. `wgmma.mma_async` has no membermask
//! operand: it always involves the full, mask-less 128-thread warpgroup
//! (PTX ISA 9.7.17.1), so it gets its own `Status::AtWarpgroupOp` and
//! `find_ready_warpgroup_op`/`block_at_warpgroup_op` (`eval::interp`) rather
//! than widening `AtWarpOp`'s 32-bit mask, which is load-bearing for every
//! *other* warp-collective op. `sync_thread_group`/`advance_thread_group`
//! (`eval::interp`) are already generic over `&[ThreadId]` and are reused
//! unchanged.
//!
//! Unlike `mma.sync` (`eval::warp::exec_mma`), which gathers *other lanes'*
//! register fragments into a `Grid` to reconstruct A/B, `wgmma.mma_async`'s
//! A/B are always read directly from shared memory via their matrix
//! descriptors - the same descriptor-decode-then-swizzled-address pattern
//! `eval::interp::exec_tcgen05_mma` uses for `tcgen05.mma`, reusing
//! `eval::wgmma::decode_wgmma_matrix_descriptor` and
//! `tcgen05_mma::operand_element_addr`. Each thread computes its own D
//! slice independently with no cross-lane register dependency - unlike
//! `mma.sync`/`ldmatrix`/`wmma.*`/every `tcgen05.*` warp op, an exited lane
//! costs nothing but its own missing output (see `exec_wgmma_mma_async`'s
//! doc comment for why no `require_live_warp`-style rejection is needed).

use volta_frontend::ast::ScalarType;

use crate::eval::error::{EvalError, EvalResult};
use crate::eval::fp8;
use crate::eval::interp::Interpreter;
use crate::eval::tcgen05_mma::{self, Major, MatrixDescriptor};
use crate::eval::value::Value;
use crate::eval::wgmma::decode_wgmma_matrix_descriptor;
use crate::eval::{ThreadId, WARPGROUP_SIZE};
use crate::lowered::{InstrId, LoweredInstr, MemSpace};
use crate::symbolic::{ExprId, Real};
use crate::tensor_core::wgmma_m64n_k16;

impl Interpreter<'_> {
    /// Execute a complete warpgroup blocked at `pc`. `members` holds the
    /// *live* threads (converged at `pc`); exited lanes in
    /// `[group_base, group_base + WARPGROUP_SIZE)` arrive implicitly (see
    /// `find_ready_warpgroup_op`). Mirrors `execute_warp_op`'s shape
    /// exactly (chi-sync before and after, advance only the live members),
    /// just over a 128-wide, mask-less group instead of a 32-wide masked
    /// one.
    pub(in crate::eval) fn execute_warpgroup_op(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
    ) -> EvalResult<()> {
        let instr = self
            .program
            .instruction(pc)
            .expect("warpgroup op blocked at a valid pc")
            .clone();

        // Every mask-less warpgroup op's group is the full contiguous
        // 128-thread range - `find_ready_warpgroup_op` already rejected
        // out-of-CTA-range groups, and the leader is always a live member,
        // so `members` is nonempty.
        let group_base = (members[0].0 / WARPGROUP_SIZE) * WARPGROUP_SIZE;
        let group: Vec<ThreadId> = (0..WARPGROUP_SIZE)
            .map(|lane| ThreadId(group_base + lane))
            .collect();

        self.stats.warp_syncs += 1; // reuses the existing "#Warp Sync" counter - see the plan's note
        self.sync_thread_group(&group);

        match &instr {
            LoweredInstr::WgmmaMmaAsync { .. } => self.exec_wgmma_mma_async(pc, members, &instr)?,
            other => unreachable!("{:?} passed warpgroup-op dispatch", other),
        }

        self.sync_thread_group(&group);
        self.advance_thread_group(members);
        Ok(())
    }

    /// `wgmma.mma_async.sync.aligned.m64nNk{16,32}.f32.atype.btype`: `D =
    /// A*B (+D)`, warpgroup-wide, `K = shape.k` (16 for `.f16`, 32 for
    /// `.e4m3`/`.e5m2`). `a_desc`/`b_desc`/`scale_d` must be warpgroup-uniform
    /// (PTX ISA: "the contents of a matrix descriptor must be same across
    /// all the warps in the warpgroup"), read once via `uniform_concrete`.
    ///
    /// No `require_live_warp`-style full-group-liveness rejection: the PTX
    /// ISA's Description for `wgmma.mma_async` states no "undefined if any
    /// thread has exited" clause (unlike `mma.sync`/`ldmatrix`/`wmma.*`,
    /// which all state it explicitly), and the per-lane computation below
    /// has no cross-lane data dependency (unlike `mma.sync`'s `Grid`-gather
    /// from other lanes' registers) - a partial post-exit warpgroup is both
    /// ISA-permitted and implementation-safe here. A deliberate judgment
    /// call - revisit if a future kernel's behavior suggests otherwise.
    fn exec_wgmma_mma_async(
        &mut self,
        pc: InstrId,
        members: &[ThreadId],
        instr: &LoweredInstr,
    ) -> EvalResult<()> {
        let LoweredInstr::WgmmaMmaAsync {
            shape,
            dst,
            a_desc,
            b_desc,
            scale_d,
            a_type,
            b_type,
            transpose_a,
            transpose_b,
        } = instr
        else {
            unreachable!()
        };
        let n = shape.n;

        let a_desc_val =
            self.uniform_concrete(pc, members, a_desc, "wgmma.mma_async a-desc")? as u64;
        let b_desc_val =
            self.uniform_concrete(pc, members, b_desc, "wgmma.mma_async b-desc")? as u64;
        let scale_d = self.uniform_concrete(pc, members, scale_d, "wgmma.mma_async scale-d")? != 0;

        let a_md = decode_wgmma_matrix_descriptor(a_desc_val);
        let b_md = decode_wgmma_matrix_descriptor(b_desc_val);
        if a_md.base_offset != 0 || b_md.base_offset != 0 {
            return Err(EvalError::Unsupported {
                pc,
                what: "wgmma.mma_async with a nonzero matrix-descriptor base offset is not modeled"
                    .to_string(),
            });
        }

        // K-major (leading = K) unless transposed - the same rule as
        // `tcgen05.mma` (PTX ISA 9.7.17.5.1.2.1).
        let major = |transpose: bool| if transpose { Major::Mn } else { Major::K };
        let (a_major, b_major) = (major(*transpose_a), major(*transpose_b));

        for &t in members {
            let lane = t.0 % WARPGROUP_SIZE;
            for elem in wgmma_m64n_k16::matrix_d(lane, n) {
                let reg = dst[elem.reg_idx];
                let mut acc = if scale_d {
                    let Value::Scalar(e) = self.read_reg_wgmma_accum(t, pc, reg, *shape)? else {
                        return Err(EvalError::ValueKindMismatch {
                            thread: t,
                            pc,
                            what: "wgmma.mma_async accumulator register holds a packed pair",
                        });
                    };
                    e
                } else {
                    // A real (not integer) zero: same subtlety
                    // `exec_tcgen05_mma` already documents - `fma`'s eager
                    // fold only fires when every operand is `RealConst`, so
                    // an `IntConst(0)` seed would silently break the fold
                    // for the whole accumulation chain.
                    self.arena.real(Real::zero())
                };
                for k in 0..shape.k as u64 {
                    let a_e = self.read_wgmma_element(
                        t,
                        pc,
                        (&a_md, a_major, *a_type),
                        elem.row as u64,
                        k,
                    )?;
                    let b_e = self.read_wgmma_element(
                        t,
                        pc,
                        (&b_md, b_major, *b_type),
                        elem.col as u64,
                        k,
                    )?;
                    acc = self.arena.fma(a_e, b_e, acc);
                }
                self.write_reg_wgmma_accum(t, pc, reg, *shape, Value::Scalar(acc))?;
            }
        }
        Ok(())
    }

    /// Read `A`/`B` element `(mn_idx, k_idx)` of type `ty` under the ISA's
    /// canonical layouts (`tcgen05_mma::operand_element_addr` - wgmma's
    /// table in PTX ISA 9.7.17.5.1.2.1.3 is the same).
    /// A concrete fp8 byte (never an input element: e.g. zero padding a
    /// kernel stored itself) is decoded from its bit encoding; a symbolic
    /// element already is its real value (see `eval::fp8`'s module doc).
    fn read_wgmma_element(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        (desc, major, ty): (&MatrixDescriptor, Major, ScalarType),
        mn_idx: u64,
        k_idx: u64,
    ) -> EvalResult<ExprId> {
        let elem_bytes = u64::from(ty.bits() / 8);
        let addr = tcgen05_mma::operand_element_addr(desc, major, mn_idx, k_idx, elem_bytes)
            .ok_or_else(|| EvalError::Unsupported {
                pc,
                what: "wgmma.mma_async MN-major operand without swizzling is not modeled"
                    .to_string(),
            })?;
        let Value::Scalar(e) = self.mem_read(t, pc, MemSpace::Shared, addr, elem_bytes)?
        else {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "wgmma.mma_async A/B element is not a scalar",
            });
        };
        let (what, decode): (_, fn(u8) -> Option<f64>) = match ty {
            ScalarType::E4m3 => ("wgmma.mma_async e4m3", fp8::decode_e4m3_byte),
            ScalarType::E5m2 => ("wgmma.mma_async e5m2", fp8::decode_e5m2_byte),
            _ => return Ok(e),
        };
        match self.arena.as_i64(e) {
            Some(raw) => self.decode_fp8_byte(pc, what, raw as u8, decode),
            None => Ok(e),
        }
    }
}
