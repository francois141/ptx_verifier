//! `mbarrier` state (PTX ISA 9.7.13.15): per-phase arrival and pending-tx
//! counts; a parity bit flips on completion. Only the corpus forms are modeled;
//! `Value::Mbarrier(MbarrierId)` granules are handles into this table.

use id_collections::IdVec;

use crate::eval::value::MbarrierId;

/// One `mbarrier` object's state.
#[derive(Debug, Clone)]
struct MbarrierState {
    /// Arrivals needed to complete the current phase.
    expected_arrivals: u64,
    /// Arrivals seen so far this phase.
    arrived: u64,
    /// Net outstanding async-transaction bytes this phase (`expect_tx` adds,
    /// `complete_tx` subtracts); 0 at completion in correct programs, but
    /// nothing relies on it staying non-negative.
    pending_tx: i64,
    /// Current phase's parity; flips every time a phase completes.
    parity: bool,
    /// Phases completed so far - also the index of the forming phase.
    completed_phases: u64,
}

impl MbarrierState {
    fn new(expected_arrivals: u64) -> Self {
        Self {
            expected_arrivals,
            arrived: 0,
            pending_tx: 0,
            parity: false,
            completed_phases: 0,
        }
    }

    fn phase_complete(&self) -> bool {
        self.arrived >= self.expected_arrivals && self.pending_tx <= 0
    }

    fn maybe_complete_phase(&mut self) {
        if self.phase_complete() {
            self.parity = !self.parity;
            self.completed_phases += 1;
            self.arrived = 0;
        }
    }

    fn arrive(&mut self, count: u64) {
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
#[derive(Debug, Clone, Default)]
pub struct MbarrierTable {
    states: IdVec<MbarrierId, MbarrierState>,
}

impl MbarrierTable {
    /// `mbarrier.init`: create a fresh object, returning its handle.
    pub fn init(&mut self, expected_arrivals: u64) -> MbarrierId {
        self.states.push(MbarrierState::new(expected_arrivals))
    }

    /// `mbarrier.arrive[.expect_tx]`: signal `count` arrivals, optionally also
    /// bumping the expected transaction count by `expect_tx`.
    pub fn arrive(&mut self, id: MbarrierId, count: u64, expect_tx: Option<u64>) {
        if let Some(tx) = expect_tx {
            self.states[id].expect_tx(tx);
        }
        self.states[id].arrive(count);
    }

    /// `mbarrier.expect_tx`: announce `tx_count` more bytes; never completes a phase.
    pub fn expect_tx(&mut self, id: MbarrierId, tx_count: u64) {
        self.states[id].expect_tx(tx_count);
    }

    /// `mbarrier.complete_tx`.
    pub fn complete_tx(&mut self, id: MbarrierId, tx_count: u64) {
        self.states[id].complete_tx(tx_count);
    }

    /// `mbarrier.test_wait.parity`/`try_wait.parity`'s completion check.
    pub fn parity_complete(&self, id: MbarrierId, phase_parity: bool) -> bool {
        self.states[id].parity_complete(phase_parity)
    }

    /// How many phases of `id` have completed: the phase an arrival now joins,
    /// and one past the phase a waiter woken now observes.
    pub fn completed_phases(&self, id: MbarrierId) -> u64 {
        self.states[id].completed_phases
    }

    /// Net outstanding transaction bytes of `id` (what a just-completed phase left).
    pub fn pending_tx(&self, id: MbarrierId) -> i64 {
        self.states[id].pending_tx
    }

    /// `(completed phases, arrivals, expected arrivals, pending tx)` of `id`'s forming phase.
    pub fn forming_state(&self, id: MbarrierId) -> (u64, u64, u64, i64) {
        let s = &self.states[id];
        (
            s.completed_phases,
            s.arrived,
            s.expected_arrivals,
            s.pending_tx,
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use id_collections::Id;

    fn id(i: u32) -> MbarrierId {
        MbarrierId::from_index(i)
    }

    #[test]
    fn test_init_starts_incomplete() {
        let mut table = MbarrierTable::default();
        let mid = table.init(2);
        assert_eq!(mid, id(0));
        assert!(!table.parity_complete(mid, false));
    }

    #[test]
    fn test_arrive_completes_phase_and_flips_parity() {
        let mut table = MbarrierTable::default();
        let mid = table.init(2);
        table.arrive(mid, 1, None);
        assert!(!table.parity_complete(mid, false));
        table.arrive(mid, 1, None);
        // Phase 0 completed: parity flipped to true, so a wait for parity
        // 0 (the phase that just completed) now sees it complete.
        assert!(table.parity_complete(mid, false));
        assert!(!table.parity_complete(mid, true));
    }

    #[test]
    fn test_arrive_alone_does_not_complete_a_pending_expect_tx() {
        let mut table = MbarrierTable::default();
        let mid = table.init(1);
        table.arrive(mid, 1, Some(16));
        // The arrival count is satisfied, but 16 bytes are still pending.
        assert!(!table.parity_complete(mid, false));
    }

    #[test]
    fn test_complete_tx_finishes_the_phase() {
        let mut table = MbarrierTable::default();
        let mid = table.init(1);
        table.arrive(mid, 1, Some(16));
        table.complete_tx(mid, 16);
        assert!(table.parity_complete(mid, false));
    }

    #[test]
    fn test_second_phase_uses_the_same_expected_arrivals() {
        let mut table = MbarrierTable::default();
        let mid = table.init(1);
        table.arrive(mid, 1, None);
        assert!(table.parity_complete(mid, false));
        // A second phase starts; one more arrival should complete it too.
        table.arrive(mid, 1, None);
        assert!(table.parity_complete(mid, true));
    }

    #[test]
    fn test_two_objects_are_independent() {
        let mut table = MbarrierTable::default();
        let a = table.init(1);
        let b = table.init(1);
        table.arrive(a, 1, None);
        assert!(table.parity_complete(a, false));
        assert!(!table.parity_complete(b, false));
    }
}
