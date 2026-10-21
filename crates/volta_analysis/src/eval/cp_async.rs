//! Non-bulk `cp.async` copies: the value is captured at issue, the
//! shared-memory write deferred until a completion point lands it.

use crate::eval::ThreadId;
use crate::eval::error::EvalResult;
use crate::eval::interp::Interpreter;
use crate::eval::record::AccessOrigin;
use crate::eval::value::Value;
use crate::lowered::{InstrId, MemSpace};
use volta_graph::AsyncOpId;

/// One `cp.async` copy issued but not yet completed: its value is captured
/// eagerly at issue time, but the write into `shared` is deferred until
/// `cp.async.wait_group` releases the group it's committed into.
#[derive(Debug, Clone)]
pub(in crate::eval) struct PendingCopy {
    pub(in crate::eval) op: AsyncOpId,
    pub(in crate::eval) dst_addr: u64,
    /// One resolved value per 4-byte word (`cp_size / 4` entries), already
    /// zero-filled where the source's real-byte prefix didn't cover it.
    pub(in crate::eval) words: Vec<Value>,
    /// The issuing `cp.async` instruction, the attributed pc of the deferred
    /// write.
    pub(in crate::eval) pc: InstrId,
}

impl<'p> Interpreter<'p> {
    /// Land one deferred `cp.async` copy: perform its shared-memory write.
    /// Shared by `cp.async.wait_group` and `cp.async.mbarrier.arrive`, the two
    /// completion points.
    pub(in crate::eval) fn complete_cp_async_copy(
        &mut self,
        t: ThreadId,
        copy: PendingCopy,
    ) -> EvalResult<()> {
        for (i, v) in copy.words.into_iter().enumerate() {
            self.mem_write_from(
                t,
                copy.pc,
                MemSpace::Shared,
                copy.dst_addr + i as u64 * 4,
                4,
                v,
                AccessOrigin::Applied,
            )?;
        }
        Ok(())
    }
}
