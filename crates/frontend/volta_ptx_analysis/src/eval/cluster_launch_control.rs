//! `clusterlaunchcontrol` evaluation (PTX ISA 9.7.19) under Volta's
//! never-steal assumption: no cancel request ever succeeds, so every
//! `try_cancel` response is the declined one and work stealing never happens.

use crate::eval::ThreadId;
use crate::eval::error::{ClcMisuse, EvalError, EvalResult};
use volta_graph::{AsyncOpKind, OperandRole, Proxy};

use crate::eval::interp::Interpreter;
use crate::eval::record::AccessOrigin;
use crate::eval::value::Value;
use crate::ir::symbols::RegId;
use crate::ir::{InstrId, MemSpace};

/// Size of a `try_cancel` response, which is also its tx-byte count.
const RESPONSE_BYTES: u64 = 16;
const WORD_BYTES: u64 = 4;

/// The `query_cancel` that first decoded a declined response. Issuing another
/// `try_cancel` after observing a failed one is undefined behavior.
#[derive(Debug, Clone, Copy)]
pub(in crate::eval) struct ObservedDecline {
    thread: ThreadId,
    pc: InstrId,
}

impl<'p> Interpreter<'p> {
    /// The response is written like a `cp.async.bulk` destination: through
    /// the async proxy, complete once a waiter observes `mbar`'s phase.
    /// Volta encodes the opaque declined response as 16 zero bytes.
    pub(in crate::eval) fn exec_clc_try_cancel(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        addr: u64,
        mbar_addr: u64,
    ) -> EvalResult<()> {
        if let Some(seen) = self.clc_observed_decline {
            return Err(EvalError::ClusterLaunchControlMisuse {
                thread: t,
                pc,
                misuse: ClcMisuse::RequestAfterObservedDecline {
                    observer: seen.thread,
                    observed_at: seen.pc,
                },
            });
        }
        self.check_bounds(t, pc, MemSpace::Shared, addr, RESPONSE_BYTES)?;
        self.check_alignment(t, pc, MemSpace::Shared, addr, RESPONSE_BYTES)?;
        let op = self.record_async_issue(t, pc, AsyncOpKind::ClcResponse);
        let origin = AccessOrigin::Async {
            op,
            proxy: Proxy::Async,
            role: OperandRole::Destination,
        };
        for word in (0..RESPONSE_BYTES).step_by(WORD_BYTES as usize) {
            let zero = Value::Scalar(self.arena.int(0));
            self.mem_write_from(
                t,
                pc,
                MemSpace::Shared,
                addr + word,
                WORD_BYTES,
                zero,
                origin,
            )?;
        }
        self.mbarrier_complete_tx(t, pc, mbar_addr, RESPONSE_BYTES, op)
    }

    pub(in crate::eval) fn exec_clc_query_is_canceled(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        dst: RegId,
        response: RegId,
    ) -> EvalResult<()> {
        self.check_declined_response(t, pc, response)?;
        self.clc_observed_decline
            .get_or_insert(ObservedDecline { thread: t, pc });
        let canceled = self.arena.bool_val(false);
        self.write_reg(t, dst, Value::Scalar(canceled));
        Ok(())
    }

    /// Every response is declined, and decoding a ctaid out of a declined
    /// response is undefined behavior, so reaching this is always an error.
    pub(in crate::eval) fn exec_clc_query_get_first_ctaid(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        response: RegId,
    ) -> EvalResult<()> {
        self.check_declined_response(t, pc, response)?;
        Err(EvalError::ClusterLaunchControlMisuse {
            thread: t,
            pc,
            misuse: ClcMisuse::CtaidOfDeclinedResponse,
        })
    }

    /// The declined response is 16 zero bytes, however the register packs them
    /// (`ld.shared.b128` gives four words, Gluon's `ld.shared.v2.b64` then
    /// `mov.b128 {lo, hi}` two halves); anything else is a canceled response.
    fn check_declined_response(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        response: RegId,
    ) -> EvalResult<()> {
        let lanes = match self.read_reg(t, response) {
            Value::Scalar(e) => vec![e],
            Value::Pair(lo, hi) => vec![lo, hi],
            Value::Quad(w0, w1, w2, w3) => vec![w0, w1, w2, w3],
            Value::Mbarrier(_) => Vec::new(),
        };

        let declined = !lanes.is_empty()
            && lanes
                .iter()
                .all(|&lane| self.arena.as_int_const(lane) == Some(0));
        if declined {
            return Ok(());
        }

        Err(EvalError::ClusterLaunchControlUndeclinedResponse { thread: t, pc })
    }
}
