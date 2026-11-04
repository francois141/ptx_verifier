//! Dynamic identities for aligned barriers in reducible control flow. A visit is the exact
//! enclosing-loop iteration vector, independent of predicates and acyclic branch paths.

use std::collections::{HashMap, HashSet, VecDeque};

use id_collections::IdVec;

use crate::eval::error::{EvalError, EvalResult};
use crate::ir::{BarrierAlignment, InstrId, LoweredInstr, LoweredProgram};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) struct BarrierVisit(usize);

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct LoopIteration {
    header: InstrId,
    iteration: u64,
}

#[derive(Debug, Default)]
pub(super) struct BarrierContext {
    last_pc: Option<InstrId>,
    loops: Vec<LoopIteration>,
}

#[derive(Debug, Default)]
pub(super) struct BarrierFlow {
    entry: Option<InstrId>,
    successors: IdVec<InstrId, Vec<InstrId>>,
    enclosing: IdVec<InstrId, Vec<InstrId>>,
    backedges: HashSet<(InstrId, InstrId)>,
    visits: HashMap<Vec<LoopIteration>, BarrierVisit>,
}

fn unsupported(pc: InstrId, reason: &str) -> EvalError {
    EvalError::Unsupported {
        pc,
        what: format!("aligned barrier loop context: {reason}"),
    }
}

impl BarrierFlow {
    pub(super) fn new(program: &LoweredProgram) -> EvalResult<Self> {
        let aligned = |pc| {
            matches!(
                program.instruction(pc),
                Some(
                    LoweredInstr::BarSync {
                        alignment: BarrierAlignment::Aligned,
                        ..
                    } | LoweredInstr::BarArrive {
                        alignment: BarrierAlignment::Aligned,
                        ..
                    }
                )
            )
        };
        if !program.instructions.iter().any(|(pc, _)| aligned(pc)) {
            return Ok(Self::default());
        }
        let mut successors = IdVec::new();
        for (pc, instr) in &program.instructions {
            let mut edges = Vec::new();
            if let LoweredInstr::Bra { target } = instr {
                edges.push(*target);
            }
            let falls_through = program.predicate(pc).is_some()
                || !matches!(
                    instr,
                    LoweredInstr::Bra { .. } | LoweredInstr::Ret | LoweredInstr::Exit
                );
            let next = InstrId(pc.0 + 1);
            if falls_through && program.instruction(next).is_some() && !edges.contains(&next) {
                edges.push(next);
            }
            let _ = successors.push(edges);
        }
        let order = reverse_postorder(&successors, program.entry_pc)?;
        if !order.iter().any(|&pc| aligned(pc)) {
            return Ok(Self::default());
        }
        Self::analyze(successors, program.entry_pc, order)
    }

    fn analyze(
        successors: IdVec<InstrId, Vec<InstrId>>,
        entry: InstrId,
        order: Vec<InstrId>,
    ) -> EvalResult<Self> {
        let mut ranks = IdVec::from_vec(vec![usize::MAX; successors.len()]);
        for (rank, &pc) in order.iter().enumerate() {
            ranks[pc] = rank;
        }
        let mut predecessors = IdVec::from_vec(vec![Vec::new(); successors.len()]);
        for &pc in &order {
            for &next in &successors[pc] {
                predecessors[next].push(pc);
            }
        }
        let mut dominators = IdVec::from_vec(vec![None; successors.len()]);
        dominators[entry] = Some(entry);
        loop {
            let mut changed = false;
            for &pc in order.iter().skip(1) {
                let mut parent = None;
                for &pred in &predecessors[pc] {
                    if dominators[pred].is_some() {
                        parent = Some(match parent {
                            None => pred,
                            Some(other) => intersect(pred, other, &dominators, &ranks),
                        });
                    }
                }
                changed |= dominators[pc] != parent;
                dominators[pc] = parent;
            }
            if !changed {
                break;
            }
        }

        let mut backedges = HashSet::new();
        let mut loops: HashMap<InstrId, HashSet<InstrId>> = HashMap::new();
        for &pc in &order {
            for &header in &successors[pc] {
                if ranks[header] <= ranks[pc] && dominates(header, pc, &dominators) {
                    backedges.insert((pc, header));
                    let nodes = loops.entry(header).or_default();
                    nodes.insert(header);
                    let mut pending = vec![pc];
                    while let Some(node) = pending.pop() {
                        if nodes.insert(node) {
                            pending.extend(predecessors[node].iter().copied());
                        }
                    }
                }
            }
        }

        // Every cycle must close through a dominance backedge; otherwise a loop has no
        // unique entry and its iteration identity is outside this finite profile.
        let mut indegrees = IdVec::from_vec(vec![0usize; successors.len()]);
        for &pc in &order {
            for &next in &successors[pc] {
                if !backedges.contains(&(pc, next)) {
                    indegrees[next] += 1;
                }
            }
        }
        let mut ready: VecDeque<_> = order
            .iter()
            .copied()
            .filter(|&pc| indegrees[pc] == 0)
            .collect();
        let mut visited = 0;
        while let Some(pc) = ready.pop_front() {
            visited += 1;
            for &next in &successors[pc] {
                if !backedges.contains(&(pc, next)) {
                    indegrees[next] -= 1;
                    if indegrees[next] == 0 {
                        ready.push_back(next);
                    }
                }
            }
        }
        if visited != order.len() {
            return Err(unsupported(entry, "irreducible control flow"));
        }

        let mut loops: Vec<_> = loops.into_iter().collect();
        loops.sort_by_key(|(header, nodes)| (std::cmp::Reverse(nodes.len()), header.0));
        for (index, (header, nodes)) in loops.iter().enumerate() {
            for &node in nodes {
                if node != *header && predecessors[node].iter().any(|pred| !nodes.contains(pred)) {
                    return Err(unsupported(node, "loop has an entry other than its header"));
                }
            }
            for (_, other) in loops.iter().skip(index + 1) {
                if !nodes.is_disjoint(other) && !other.is_subset(nodes) {
                    return Err(unsupported(*header, "overlapping non-nested loops"));
                }
            }
        }
        let mut enclosing = IdVec::from_vec(vec![Vec::new(); successors.len()]);
        for (header, nodes) in loops {
            for node in nodes {
                enclosing[node].push(header);
            }
        }
        Ok(Self {
            entry: Some(entry),
            successors,
            enclosing,
            backedges,
            visits: HashMap::new(),
        })
    }

    // Called before every stepped instruction, so scheduler wakeups and predicate skips
    // pass through the same actual CFG-edge update as executed branches.
    pub(super) fn advance(&self, context: &mut BarrierContext, pc: InstrId) -> EvalResult<()> {
        let Some(entry) = self.entry else {
            return Ok(());
        };
        let enclosing = self
            .enclosing
            .get(pc)
            .ok_or_else(|| unsupported(pc, "PC outside the program"))?;
        if let Some(previous) = context.last_pc {
            if !self.successors[previous].contains(&pc) {
                return Err(unsupported(pc, "transition is not a CFG edge"));
            }
        } else if pc != entry {
            return Err(unsupported(pc, "execution did not start at the entry"));
        }
        let shared = context
            .loops
            .iter()
            .zip(enclosing)
            .take_while(|(old, header)| old.header == **header)
            .count();
        context.loops.truncate(shared);
        if context
            .last_pc
            .is_some_and(|previous| self.backedges.contains(&(previous, pc)))
        {
            let iteration = context
                .loops
                .last_mut()
                .filter(|current| current.header == pc)
                .ok_or_else(|| unsupported(pc, "backedge does not match the active loop"))?;
            iteration.iteration = iteration
                .iteration
                .checked_add(1)
                .ok_or_else(|| unsupported(pc, "loop iteration overflow"))?;
        }
        context
            .loops
            .extend(
                enclosing[context.loops.len()..]
                    .iter()
                    .map(|&header| LoopIteration {
                        header,
                        iteration: 0,
                    }),
            );
        context.last_pc = Some(pc);
        Ok(())
    }

    pub(super) fn visit(&mut self, context: &BarrierContext) -> BarrierVisit {
        let next = BarrierVisit(self.visits.len());
        *self.visits.entry(context.loops.clone()).or_insert(next)
    }
}

fn reverse_postorder(
    successors: &IdVec<InstrId, Vec<InstrId>>,
    entry: InstrId,
) -> EvalResult<Vec<InstrId>> {
    if successors.get(entry).is_none() {
        return Err(unsupported(entry, "entry is outside the program"));
    }
    let mut seen = IdVec::from_vec(vec![false; successors.len()]);
    let mut pending = vec![(entry, false)];
    let mut order = Vec::new();
    while let Some((pc, finish)) = pending.pop() {
        if finish {
            order.push(pc);
        } else if !seen[pc] {
            if successors[pc]
                .iter()
                .any(|&next| successors.get(next).is_none())
            {
                return Err(unsupported(pc, "branch target is outside the program"));
            }
            seen[pc] = true;
            pending.push((pc, true));
            pending.extend(successors[pc].iter().rev().map(|&next| (next, false)));
        }
    }
    order.reverse();
    Ok(order)
}

fn intersect(
    mut left: InstrId,
    mut right: InstrId,
    parents: &IdVec<InstrId, Option<InstrId>>,
    ranks: &IdVec<InstrId, usize>,
) -> InstrId {
    while left != right {
        while ranks[left] > ranks[right] {
            left = parents[left].expect("known dominator");
        }
        while ranks[right] > ranks[left] {
            right = parents[right].expect("known dominator");
        }
    }
    left
}

fn dominates(
    header: InstrId,
    mut node: InstrId,
    parents: &IdVec<InstrId, Option<InstrId>>,
) -> bool {
    while node != header {
        let parent = parents[node].expect("reachable node has a dominator");
        if node == parent {
            return false;
        }
        node = parent;
    }
    true
}

#[cfg(test)]
mod tests {
    use super::*;

    fn flow(edges: &[&[u32]]) -> EvalResult<BarrierFlow> {
        let edges = IdVec::from_vec(
            edges
                .iter()
                .map(|row| row.iter().map(|&n| InstrId(n)).collect())
                .collect(),
        );
        let order = reverse_postorder(&edges, InstrId(0))?;
        BarrierFlow::analyze(edges, InstrId(0), order)
    }

    fn walk(flow: &BarrierFlow, context: &mut BarrierContext, path: &[u32]) {
        for &pc in path {
            flow.advance(context, InstrId(pc)).unwrap();
        }
    }

    fn iterations(context: &BarrierContext) -> Vec<(u32, u64)> {
        context
            .loops
            .iter()
            .map(|step| (step.header.0, step.iteration))
            .collect()
    }

    #[test]
    fn acyclic_reconvergence_does_not_remember_divergent_paths() {
        let mut flow = flow(&[&[1, 2], &[3], &[3], &[]]).unwrap();
        let mut left = BarrierContext::default();
        let mut right = BarrierContext::default();
        walk(&flow, &mut left, &[0, 1, 3]);
        walk(&flow, &mut right, &[0, 2, 3]);
        assert!(iterations(&left).is_empty());
        assert_eq!(flow.visit(&left), flow.visit(&right));
    }

    #[test]
    fn bypassed_barrier_still_changes_the_loop_iteration() {
        let mut flow = flow(&[&[1], &[2, 3], &[3], &[1, 4], &[]]).unwrap();
        let mut first = BarrierContext::default();
        let mut second = BarrierContext::default();
        walk(&flow, &mut first, &[0, 1, 2]);
        walk(&flow, &mut second, &[0, 1, 3, 1, 2]);
        assert_eq!(iterations(&first), vec![(1, 0)]);
        assert_eq!(iterations(&second), vec![(1, 1)]);
        assert_ne!(flow.visit(&first), flow.visit(&second));
    }

    #[test]
    fn inner_iterations_reset_on_outer_reactivation_and_disappear_on_exit() {
        let mut flow = flow(&[&[1], &[2], &[3, 4], &[2], &[1, 5], &[6], &[]]).unwrap();
        let mut longer = BarrierContext::default();
        let mut shorter = BarrierContext::default();
        walk(&flow, &mut longer, &[0, 1, 2, 3, 2, 3, 2, 4, 1, 2, 3]);
        walk(&flow, &mut shorter, &[0, 1, 2, 4, 1, 2, 3]);
        assert_eq!(iterations(&longer), vec![(1, 1), (2, 0)]);
        assert_eq!(iterations(&shorter), vec![(1, 1), (2, 0)]);
        assert_eq!(flow.visit(&longer), flow.visit(&shorter));
        walk(&flow, &mut longer, &[2, 4, 5, 6]);
        assert!(iterations(&longer).is_empty());
    }

    #[test]
    fn multiple_latches_share_one_header_iteration() {
        let mut flow = flow(&[&[1], &[2, 3, 4], &[1], &[1], &[]]).unwrap();
        let mut left = BarrierContext::default();
        let mut right = BarrierContext::default();
        walk(&flow, &mut left, &[0, 1, 2, 1]);
        walk(&flow, &mut right, &[0, 1, 3, 1]);
        assert_eq!(iterations(&left), vec![(1, 1)]);
        assert_eq!(iterations(&right), vec![(1, 1)]);
        assert_eq!(flow.visit(&left), flow.visit(&right));
    }

    #[test]
    fn entry_self_loop_advances_and_refuses_counter_overflow() {
        let flow = flow(&[&[0, 1], &[]]).unwrap();
        let mut context = BarrierContext::default();
        walk(&flow, &mut context, &[0, 0]);
        assert_eq!(iterations(&context), vec![(0, 1)]);
        context.loops[0].iteration = u64::MAX;
        assert!(
            matches!(flow.advance(&mut context, InstrId(0)), Err(EvalError::Unsupported { what, .. }) if what.contains("overflow"))
        );
        assert_eq!(iterations(&context), vec![(0, u64::MAX)]);
        walk(&flow, &mut context, &[1]);
        assert!(iterations(&context).is_empty());
    }

    #[test]
    fn irreducible_control_flow_refuses_but_unreachable_cycles_do_not() {
        assert!(
            matches!(flow(&[&[1, 2], &[2, 3], &[1, 3], &[]]), Err(EvalError::Unsupported { what, .. }) if what.contains("irreducible"))
        );
        let flow = flow(&[&[3], &[2], &[1], &[]]).unwrap();
        let mut context = BarrierContext::default();
        walk(&flow, &mut context, &[0, 3]);
        assert!(iterations(&context).is_empty());
    }

    #[test]
    fn only_reachable_branch_targets_are_required_to_exist() {
        let valid = flow(&[&[3], &[99], &[1], &[]]).unwrap();
        let mut context = BarrierContext::default();
        walk(&valid, &mut context, &[0, 3]);
        assert!(
            matches!(flow(&[&[99]]), Err(EvalError::Unsupported { what, .. }) if what.contains("outside the program"))
        );
    }

    #[test]
    fn a_non_cfg_transition_is_not_given_a_visit_identity() {
        let flow = flow(&[&[1], &[2], &[]]).unwrap();
        let mut context = BarrierContext::default();
        walk(&flow, &mut context, &[0]);
        assert!(
            matches!(flow.advance(&mut context, InstrId(2)), Err(EvalError::Unsupported { what, .. }) if what.contains("CFG edge"))
        );
    }
}
