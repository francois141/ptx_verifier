//! Warpgroup-cooperative `wgmma.mma_async` (PTX ISA 9.7.17.5.2): always the
//! full mask-less 128-thread warpgroup, hence its own `Status::AtWarpgroupOp`;
//! A/B come from shared memory via descriptors.

use volta_frontend::ast::ScalarType;

use crate::eval::error::{EvalError, EvalResult};
use crate::eval::float_bits;
use volta_graph::{AsyncOpId, AsyncOpKind, Proxy};

use crate::eval::interp::Interpreter;
use crate::eval::record::AccessOrigin;
use crate::eval::tcgen05_mma::{self, Major, MatrixDescriptor};
use crate::eval::value::Value;
use crate::eval::wgmma::decode_wgmma_matrix_descriptor;
use crate::eval::{ThreadId, WARPGROUP_SIZE};
use crate::lowered::{InstrId, LoweredInstr, MemSpace};
use crate::tensor_core::wgmma_m64n_k16;
use volta_expr::{ExprId, Real};

/// One fired `wgmma.mma_async`, as each member's wgmma-groups record it.
#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, Hash)]
pub(in crate::eval) struct WgmmaOpId(u64);

impl Interpreter<'_> {
    /// Execute a complete warpgroup blocked at `pc`; `members` are the *live*
    /// threads, exited lanes arrive implicitly. Like `execute_warp_op`, but
    /// over a 128-wide mask-less group.
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

        self.stats.warp_syncs += 1; // reuses the existing "#Warp Sync" counter - see the plan's note
        let exit = self.record_warpgroup_op_entry(pc, members);

        match &instr {
            LoweredInstr::WgmmaMmaAsync { .. } => self.exec_wgmma_mma_async(pc, members, &instr)?,
            other => unreachable!("{:?} passed warpgroup-op dispatch", other),
        }

        self.record_collective_exit(exit, pc, members);
        self.advance_thread_group(members);
        Ok(())
    }

    /// `D = A*B (+D)`, `K = shape.k`; descriptors and `scale_d` are
    /// warpgroup-uniform. Exited lanes are allowed: the ISA has no "undefined
    /// if any thread has exited" clause here.
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

        let id = self.next_wgmma_op;
        self.next_wgmma_op = WgmmaOpId(id.0 + 1);
        let instance = self.next_wgmma_instance();
        for &t in members {
            let op = self.record_async_issue(t, pc, AsyncOpKind::WgmmaMma { instance });
            self.record_wgmma_part(id, t, op);
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
                    float_bits::decode_float_bits(&mut self.arena, pc, ScalarType::F32, e)?
                } else {
                    // A real (not integer) zero: `fma` folds only
                    // all-`RealConst` operands, so an `IntConst(0)` seed would
                    // break folding for the whole accumulation chain.
                    self.arena.real(Real::zero())
                };
                for k in 0..shape.k as u64 {
                    let a_e = self.read_wgmma_element(
                        t,
                        pc,
                        op,
                        (&a_md, a_major, *a_type),
                        elem.row as u64,
                        k,
                    )?;
                    let b_e = self.read_wgmma_element(
                        t,
                        pc,
                        op,
                        (&b_md, b_major, *b_type),
                        elem.col as u64,
                        k,
                    )?;
                    acc = self.arena.fma(a_e, b_e, acc);
                }
                self.write_reg_wgmma_accum(t, pc, reg, *shape, Value::Scalar(acc))?;
            }
        }
        for &t in members {
            self.threads[t].wgmma.record_wgmma_op(id);
        }
        Ok(())
    }

    /// Read `A`/`B` element `(mn_idx, k_idx)` (PTX ISA 9.7.17.5.1.2.1.3
    /// layouts) as an async-proxy effect of `op`. Concrete elements decode from
    /// f16/bf16/fp8 bits; symbolic ones are real values.
    #[allow(clippy::too_many_arguments)]
    fn read_wgmma_element(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: AsyncOpId,
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
        let origin = AccessOrigin::Async {
            op,
            proxy: Proxy::Async,
        };
        let Value::Scalar(e) =
            self.mem_read_from(t, pc, MemSpace::Shared, addr, elem_bytes, origin)?
        else {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "wgmma.mma_async A/B element is not a scalar",
            });
        };
        float_bits::decode_float_bits(&mut self.arena, pc, ty, e)
    }
}
