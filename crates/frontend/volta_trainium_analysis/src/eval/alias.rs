//! Tiles that `address=` places over each other's bytes. Each element of a placed tile
//! covers `element_bytes` bytes of one partition, from its tile's offset in row-major
//! order of the free dimensions; a write through one tile clobbers what overlaps it.

use std::ops::Range;

use id_collections::IdVec;

use crate::ir::{Address, Index, Shape, Tensor, TensorId};

/// For each tensor, the other tensors of its memory whose bytes overlap its own.
pub(super) fn aliases(tensors: &IdVec<TensorId, Tensor>) -> IdVec<TensorId, Vec<TensorId>> {
    tensors.map_refs(|id, tensor| {
        tensors
            .iter()
            .filter(|&(other, other_tensor)| {
                other != id
                    && other_tensor.memory == tensor.memory
                    && match (footprint(tensor), footprint(other_tensor)) {
                        (Some([a_parts, a_bytes]), Some([b_parts, b_bytes])) => {
                            intersect(&a_parts, &b_parts) && intersect(&a_bytes, &b_bytes)
                        }
                        _ => false,
                    }
            })
            .map(|(other, _)| other)
            .collect()
    })
}

/// The partition and the bytes of it that `tensor`'s element at `index` covers.
pub(super) fn element_bytes(tensor: &Tensor, index: &Index) -> Option<(u64, Range<u64>)> {
    let address = tensor.address?;
    let [partition, free @ ..] = &index.0[..] else {
        unreachable!("a tile index has a partition coordinate");
    };
    let start = address.offset
        + free_shape(&tensor.shape).offset(&Index(free.to_vec())) * address.element_bytes;
    Some((
        address.partition + partition,
        start..start + address.element_bytes,
    ))
}

/// The indices of `tensor`'s elements that cover any of `bytes` of `partition`.
pub(super) fn overlapping(tensor: &Tensor, partition: u64, bytes: &Range<u64>) -> Vec<Index> {
    let Some([partitions, own]) = footprint(tensor) else {
        return Vec::new();
    };
    if !partitions.contains(&partition) || !intersect(&own, bytes) {
        return Vec::new();
    }
    let Address {
        offset,
        element_bytes,
        ..
    } = tensor.address.expect("a tensor with a footprint is placed");
    let first = (bytes.start.max(own.start) - offset) / element_bytes;
    let last = (bytes.end.min(own.end) - 1 - offset) / element_bytes;
    let free = free_shape(&tensor.shape);
    (first..=last)
        .map(|element| {
            let mut index = vec![partition - partitions.start];
            index.extend(free.index_at(element).0);
            Index(index)
        })
        .collect()
}

/// A placed tile's partitions and the bytes of each that it covers.
fn footprint(tensor: &Tensor) -> Option<[Range<u64>; 2]> {
    let address = tensor.address?;
    let free = free_shape(&tensor.shape);
    let count = free
        .element_count()
        .expect("lowering bounds a tile's element count");
    let partition = address.partition;
    Some([
        partition..partition + tensor.shape.0[0],
        address.offset..address.offset + count * address.element_bytes,
    ])
}

fn free_shape(shape: &Shape) -> Shape {
    Shape(shape.0[1..].to_vec())
}

fn intersect(a: &Range<u64>, b: &Range<u64>) -> bool {
    a.start < b.end && b.start < a.end
}
