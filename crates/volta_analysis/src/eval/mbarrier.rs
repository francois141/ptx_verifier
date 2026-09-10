//! `mbarrier` object state: phased arrive/wait barriers used for
//! producer/consumer pipelining across threads (PTX ISA 9.7.13.15).
//!
//! Each object tracks an arrival count and a pending async-transaction
//! count for its current *phase*; when both are satisfied the phase
//! completes and a parity bit flips. Scoped to what the corpus actually
//! uses (`sm100a_support_plan.md`): `init`/`inval`/`arrive[.expect_tx]`/
//! `complete_tx`/`test_wait`/`try_wait[.parity]`. The non-`.parity`,
//! opaque-state-token wait form and `arrive_drop`/`pending_count` are not
//! modeled.
//!
//! State lives here, not in `Memory`: a `Value::Mbarrier(MbarrierId)`
//! granule (see `eval::value`) is just a stable handle into this table,
//! the same size as `Value::Scalar`'s `ExprId`, so granules never grow to
//! fit it.

use fixedbitset::FixedBitSet;
use id_collections::IdVec;

use crate::eval::ThreadId;
use crate::eval::value::MbarrierId;

/// One `mbarrier` object's state.
#[derive(Debug, Clone)]
struct MbarrierState {
    /// Arrivals needed to complete the current phase.
    expected_arrivals: u64,
    /// Arrivals seen so far this phase.
    arrived: u64,
    /// Net outstanding async-transaction bytes for this phase:
    /// `expect_tx`/`arrive.expect_tx` add, `complete_tx` subtracts. A
    /// correctly-paired program always brings this back to exactly 0 when
    /// the phase completes; it never needs to go negative in practice, but
    /// nothing here relies on that not happening.
    pending_tx: i64,
    /// Current phase's parity; flips every time a phase completes.
    parity: bool,
    /// Threads that have called `mbarrier.arrive[.expect_tx]` during the
    /// forming phase. `complete_tx` does not contribute: per ISA
    /// 9.7.14.16.15, it "does not involve any asynchronous memory
    /// operations and only simulates the completion of an asynchronous
    /// memory operation" - it has no access of its own to make visible.
    /// Consumed at phase completion to seed `prior_participants` - see its
    /// doc comment for why this set itself is the wrong thing to sync a
    /// waiter against.
    participants: FixedBitSet,
    /// `participants` as of the last completed phase: the set a waiter
    /// observing that (now-preceding) phase's completion should establish a
    /// happens-before edge with (PTX ISA 9.7.14.16.19, ordering guarantee
    /// items 1-3 - accesses by "the participating threads of the CTA"
    /// prior to a release-semantics `arrive` become visible to a thread
    /// whose acquire-semantics wait observes completion).
    ///
    /// Kept as a frozen snapshot rather than reading `participants`
    /// directly, because by the time a waiter is actually processed (which
    /// can lag arbitrarily under round-robin scheduling) `participants` may
    /// already be accumulating the *next* phase. This single snapshot is
    /// sufficient for the common case - every waiter for a phase processed
    /// before the next phase completes, which is what Volta's scheduler
    /// does since it reevaluates every blocked thread after each step - but
    /// not for the pathological case of a waiter straggling behind an
    /// entire subsequent phase's completion; the ISA's own phase-advance
    /// rule (9.7.14.16.5.1) only guarantees *one* observer per phase before
    /// the next phase's arrivals, not that every waiter is drained in time.
    /// That residual gap is strictly a missed sync (a possible
    /// false-positive race report, the same conservative direction as
    /// before this fix), never an unsound one: `prior_participants` is
    /// always some phase's real arriver set, never a thread the waiter
    /// didn't actually need to sync with... except it could wrongly pull in
    /// a later phase's unrelated arrivers, which *would* be unsound; this is
    /// flagged as a known limitation rather than solved, since it requires
    /// per-phase history this table doesn't keep.
    prior_participants: FixedBitSet,
}

impl MbarrierState {
    fn new(expected_arrivals: u64, n_threads: usize) -> Self {
        Self {
            expected_arrivals,
            arrived: 0,
            pending_tx: 0,
            parity: false,
            participants: FixedBitSet::with_capacity(n_threads),
            prior_participants: FixedBitSet::with_capacity(n_threads),
        }
    }

    fn phase_complete(&self) -> bool {
        self.arrived >= self.expected_arrivals && self.pending_tx <= 0
    }

    fn maybe_complete_phase(&mut self) {
        if self.phase_complete() {
            self.parity = !self.parity;
            self.arrived = 0;
            self.prior_participants.clone_from(&self.participants);
            self.participants.clear();
        }
    }

    fn arrive(&mut self, thread: ThreadId, count: u64) {
        self.participants.insert(thread.0 as usize);
        self.arrived += count;
        self.maybe_complete_phase();
    }

    fn expect_tx(&mut self, tx_count: u64) {
        self.pending_tx += tx_count as i64;
    }

    fn complete_tx(&mut self, tx_count: u64) {
        self.pending_tx -= tx_count as i64;
        self.maybe_complete_phase();
    }

    /// Whether the phase identified by `phase_parity` (the parity the
    /// caller was waiting to see flip past) has completed.
    fn parity_complete(&self, phase_parity: bool) -> bool {
        self.parity != phase_parity
    }
}

/// Every live `mbarrier` object in one kernel run.
#[derive(Debug, Clone)]
pub struct MbarrierTable {
    states: IdVec<MbarrierId, MbarrierState>,
    n_threads: usize,
}

impl MbarrierTable {
    pub fn new(n_threads: usize) -> Self {
        Self {
            states: IdVec::new(),
            n_threads,
        }
    }

    /// `mbarrier.init`: create a fresh object, returning its handle.
    pub fn init(&mut self, expected_arrivals: u64) -> MbarrierId {
        self.states
            .push(MbarrierState::new(expected_arrivals, self.n_threads))
    }

    /// `mbarrier.arrive[.expect_tx]`: signal `count` arrivals by `thread`,
    /// optionally also bumping the expected transaction count by
    /// `expect_tx`.
    pub fn arrive(&mut self, id: MbarrierId, thread: ThreadId, count: u64, expect_tx: Option<u64>) {
        if let Some(tx) = expect_tx {
            self.states[id].expect_tx(tx);
        }
        self.states[id].arrive(thread, count);
    }

    /// `mbarrier.complete_tx`.
    pub fn complete_tx(&mut self, id: MbarrierId, tx_count: u64) {
        self.states[id].complete_tx(tx_count);
    }

    /// `mbarrier.test_wait.parity`/`try_wait.parity`'s completion check.
    pub fn parity_complete(&self, id: MbarrierId, phase_parity: bool) -> bool {
        self.states[id].parity_complete(phase_parity)
    }

    /// The arriving threads a waiter observing this mbarrier's last
    /// completed phase should establish a happens-before edge with - see
    /// [`MbarrierState::prior_participants`].
    pub fn prior_participants(&self, id: MbarrierId) -> &FixedBitSet {
        &self.states[id].prior_participants
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use id_collections::Id;

    fn id(i: u32) -> MbarrierId {
        MbarrierId::from_index(i)
    }

    const N: usize = 8;

    #[test]
    fn test_init_starts_incomplete() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(2);
        assert_eq!(mid, id(0));
        assert!(!table.parity_complete(mid, false));
    }

    #[test]
    fn test_arrive_completes_phase_and_flips_parity() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(2);
        table.arrive(mid, ThreadId(0), 1, None);
        assert!(!table.parity_complete(mid, false));
        table.arrive(mid, ThreadId(1), 1, None);
        // Phase 0 completed: parity flipped to true, so a wait for parity
        // 0 (the phase that just completed) now sees it complete.
        assert!(table.parity_complete(mid, false));
        assert!(!table.parity_complete(mid, true));
    }

    #[test]
    fn test_arrive_alone_does_not_complete_a_pending_expect_tx() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(1);
        table.arrive(mid, ThreadId(0), 1, Some(16));
        // The arrival count is satisfied, but 16 bytes are still pending.
        assert!(!table.parity_complete(mid, false));
    }

    #[test]
    fn test_complete_tx_finishes_the_phase() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(1);
        table.arrive(mid, ThreadId(0), 1, Some(16));
        table.complete_tx(mid, 16);
        assert!(table.parity_complete(mid, false));
    }

    #[test]
    fn test_second_phase_uses_the_same_expected_arrivals() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(1);
        table.arrive(mid, ThreadId(0), 1, None);
        assert!(table.parity_complete(mid, false));
        // A second phase starts; one more arrival should complete it too.
        table.arrive(mid, ThreadId(1), 1, None);
        assert!(table.parity_complete(mid, true));
    }

    #[test]
    fn test_two_objects_are_independent() {
        let mut table = MbarrierTable::new(N);
        let a = table.init(1);
        let b = table.init(1);
        table.arrive(a, ThreadId(0), 1, None);
        assert!(table.parity_complete(a, false));
        assert!(!table.parity_complete(b, false));
    }

    #[test]
    fn test_prior_participants_tracks_the_arriving_threads() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(2);
        table.arrive(mid, ThreadId(3), 1, None);
        table.arrive(mid, ThreadId(5), 1, None);
        assert!(table.parity_complete(mid, false));
        let participants = table.prior_participants(mid);
        assert!(participants.contains(3));
        assert!(participants.contains(5));
        assert!(!participants.contains(0));
    }

    #[test]
    fn test_complete_tx_caller_is_not_a_participant() {
        // complete_tx "does not involve any asynchronous memory operations"
        // (ISA 9.7.14.16.15) - only arrive contributes to the happens-before
        // set.
        let mut table = MbarrierTable::new(N);
        let mid = table.init(1);
        table.arrive(mid, ThreadId(1), 1, Some(16));
        table.complete_tx(mid, 16);
        assert!(table.parity_complete(mid, false));
        let participants = table.prior_participants(mid);
        assert!(participants.contains(1));
        assert!(!participants.contains(2));
    }

    #[test]
    fn test_participants_reset_for_the_next_phase() {
        let mut table = MbarrierTable::new(N);
        let mid = table.init(1);
        table.arrive(mid, ThreadId(0), 1, None);
        assert_eq!(table.prior_participants(mid).count_ones(..), 1);
        assert!(table.prior_participants(mid).contains(0));
        // Second phase completes via a different thread alone: thread 0
        // must not linger in the new snapshot.
        table.arrive(mid, ThreadId(1), 1, None);
        let participants = table.prior_participants(mid);
        assert!(participants.contains(1));
        assert!(!participants.contains(0));
    }
}
