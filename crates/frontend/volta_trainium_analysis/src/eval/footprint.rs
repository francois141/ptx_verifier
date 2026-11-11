//! The memory each instruction reads and writes, as runs of consecutive locations: the
//! footprints an event graph's accesses carry. They are static, so a gather reads its
//! whole `data` and `index` regions, a superset of the elements its offsets select.

use std::ops::Range;

use id_collections::IdVec;

use crate::ir::{
    Accumulation, Index, InstrId, LoweredInstr, LoweredKernel, Memory, Reduction, ScalarOperand,
    ScalarStep, TensorId, TensorRegion,
};

use super::alias;

/// The bytes between consecutive partitions of a placed tile's location: more than any
/// partition holds, so `partition * PARTITION_STRIDE + byte` never wraps into the next.
pub const PARTITION_STRIDE: u64 = 1 << 32;

/// The address space an access's runs are in. Only placed tiles share one, since only
/// `address=` can put two tensors over the same storage.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Location {
    /// A placed tile's memory, by byte: `partition * PARTITION_STRIDE + byte`.
    Placed(Memory),
    /// An unplaced tile or an HBM tensor of its own, by row-major element offset.
    Elements(TensorId),
}

/// How an access touches its locations.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    Read,
    Write,
    /// `nc_matmul`'s `dst` unless `accumulate=False`: it adds its product to each element
    /// (an element's first write overwrites under `accumulate=None`).
    Accumulate,
}

/// One operand's footprint.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Access {
    pub mode: Mode,
    pub tensor: TensorId,
    pub location: Location,
    /// Disjoint, non-adjacent and ascending.
    pub runs: Vec<Range<u64>>,
}

/// Each instruction's accesses: its reads in operand order, then its writes.
pub fn footprints(kernel: &LoweredKernel) -> IdVec<InstrId, Vec<Access>> {
    kernel
        .instructions
        .map_refs(|_, instruction| accesses(kernel, instruction))
}

fn accesses(kernel: &LoweredKernel, instruction: &LoweredInstr) -> Vec<Access> {
    let access = |mode, region: &TensorRegion| footprint(kernel, mode, region);
    let scalars = |operands: &[Option<&ScalarOperand>]| -> Vec<Access> {
        operands
            .iter()
            .flatten()
            .filter_map(|operand| match operand {
                ScalarOperand::Constant(_) => None,
                ScalarOperand::Broadcast(tile) => Some(access(Mode::Read, tile)),
            })
            .collect()
    };
    let reduced = |reduce: &Option<Reduction>| {
        reduce
            .iter()
            .map(|Reduction { res, .. }| access(Mode::Write, res))
            .collect::<Vec<_>>()
    };
    match instruction {
        LoweredInstr::Mov { dst, src, .. } => {
            vec![access(Mode::Read, src), access(Mode::Write, dst)]
        }
        LoweredInstr::Memset { dst, .. } => vec![access(Mode::Write, dst)],
        LoweredInstr::Gather { dst, data, index } => vec![
            access(Mode::Read, data),
            access(Mode::Read, index),
            access(Mode::Write, dst),
        ],
        LoweredInstr::Arith { dst, lhs, rhs, .. } => vec![
            access(Mode::Read, lhs),
            access(Mode::Read, rhs),
            access(Mode::Write, dst),
        ],
        LoweredInstr::Activation {
            dst,
            data,
            scale,
            bias,
            reduce,
            ..
        } => [
            vec![access(Mode::Read, data)],
            scalars(&[scale.as_ref(), bias.as_ref()]),
            vec![access(Mode::Write, dst)],
            reduced(reduce),
        ]
        .concat(),
        LoweredInstr::Reduce { dst, data, .. } => {
            vec![access(Mode::Read, data), access(Mode::Write, dst)]
        }
        LoweredInstr::TensorScalar {
            dst,
            data,
            first,
            second,
            reduce,
        } => [
            vec![access(Mode::Read, data)],
            scalars(&[
                Some(&first.operand),
                second.as_ref().map(|step: &ScalarStep| &step.operand),
            ]),
            vec![access(Mode::Write, dst)],
            reduced(reduce),
        ]
        .concat(),
        LoweredInstr::Scan {
            dst,
            data0,
            data1,
            initial,
            ..
        } => [
            vec![access(Mode::Read, data0), access(Mode::Read, data1)],
            scalars(&[Some(initial)]),
            vec![access(Mode::Write, dst)],
        ]
        .concat(),
        LoweredInstr::Matmul {
            dst,
            stationary,
            moving,
            accumulation,
        } => {
            let mode = match accumulation {
                Accumulation::Overwrite => Mode::Write,
                Accumulation::FirstOverwrites | Accumulation::Accumulate => Mode::Accumulate,
            };
            vec![
                access(Mode::Read, stationary),
                access(Mode::Read, moving),
                access(mode, dst),
            ]
        }
        LoweredInstr::Transpose { dst, data, .. } => {
            vec![access(Mode::Read, data), access(Mode::Write, dst)]
        }
    }
}

fn footprint(kernel: &LoweredKernel, mode: Mode, region: &TensorRegion) -> Access {
    let tensor = &kernel.tensors[region.tensor];
    let (location, mut starts): (Location, Vec<Range<u64>>) = match tensor.address {
        Some(address) => (
            Location::Placed(tensor.memory),
            elements(region)
                .map(|index| {
                    let (partition, bytes) = alias::element_bytes(tensor, &index)
                        .expect("a placed tensor's element covers bytes");
                    let base = partition * PARTITION_STRIDE;
                    base + bytes.start..base + bytes.start + address.element_bytes
                })
                .collect(),
        ),
        None => (
            Location::Elements(region.tensor),
            elements(region)
                .map(|index| {
                    let offset = tensor.shape.offset(&index);
                    offset..offset + 1
                })
                .collect(),
        ),
    };
    starts.sort_by_key(|run| run.start);
    let mut runs: Vec<Range<u64>> = Vec::new();
    for run in starts {
        match runs.last_mut() {
            Some(last) if run.start <= last.end => last.end = last.end.max(run.end),
            _ => runs.push(run),
        }
    }
    Access {
        mode,
        tensor: region.tensor,
        location,
        runs,
    }
}

fn elements(region: &TensorRegion) -> impl Iterator<Item = Index> + '_ {
    region.shape.indices().map(|local| region.element(&local))
}
