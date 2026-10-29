//! `cp.async.bulk{.tensor}` evaluation: TMA loads and bulk copies (global to shared,
//! completed on an mbarrier) and TMA stores (shared to global, completed by bulk
//! async-group waits). The data lands eagerly at issue; the graph orders it (9.7.9.25.2).

use std::collections::VecDeque;

use volta_graph::{AsyncOpId, AsyncOpKind, OperandRole, Proxy};

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::Interpreter;
use crate::eval::record::AccessOrigin;
use crate::eval::tcgen05_mma;
use crate::eval::tensor_map_table;
use crate::eval::value::{MbarrierId, Value};
use crate::ir::symbols::{PARAM_GENERIC_BASE, SHARED_GENERIC_BASE};
use crate::ir::tensor_map::{TensorFillMode, TensorLoadMode};
use crate::ir::{BulkWaitScope, InstrId, MemSpace, Operand};

/// Where a TMA's generic tensor-map address points: a kernel parameter's map in
/// the param window (`cvta.param`), else a `.global` object (where
/// `tensormap.cp_fenceproxy` puts one); `.const` maps are unmodeled.
fn locate_tensor_map(addr: u64) -> (MemSpace, u64) {
    let in_param_window = (PARAM_GENERIC_BASE..SHARED_GENERIC_BASE).contains(&addr);
    if in_param_window {
        (MemSpace::Param, addr - PARAM_GENERIC_BASE)
    } else {
        (MemSpace::Global, addr)
    }
}

/// A TMA load's or store's box: each element's global byte address (`None` when
/// out of bounds) and its swizzled shared address, in box order (dimension 0
/// fastest); `float_elements` picks the zero a load fills out-of-bounds ones with.
struct TmaBox {
    elem_bytes: u64,
    float_elements: bool,
    elements: Vec<(Option<u64>, u64)>,
}

/// One TMA store's two async ops, each `None` once a bulk wait completed it.
#[derive(Debug)]
pub(in crate::eval) struct BulkStore {
    pub reads: Option<AsyncOpId>,
    pub writes: Option<AsyncOpId>,
}

impl BulkStore {
    fn is_complete(&self) -> bool {
        self.reads.is_none() && self.writes.is_none()
    }
}

/// Complete every bulk group but the newest `keep`: its stores' reads, and with
/// `Complete` their writes too. Dropping the complete groups at the front never
/// changes which groups a later wait completes.
pub(in crate::eval) fn complete_bulk_groups(
    groups: &mut VecDeque<Vec<BulkStore>>,
    keep: u32,
    scope: BulkWaitScope,
) -> Vec<AsyncOpId> {
    let older = groups.len().saturating_sub(keep as usize);

    let mut ops = Vec::new();
    for group in groups.iter_mut().take(older) {
        for store in group {
            ops.extend(store.reads.take());
            if scope == BulkWaitScope::Complete {
                ops.extend(store.writes.take());
            }
        }
    }

    while let Some(group) = groups.front() {
        if !group.iter().all(BulkStore::is_complete) {
            break;
        }
        groups.pop_front();
    }

    ops
}

impl<'p> Interpreter<'p> {
    /// `.tile` TMA tensor copy, global to shared (ISA 9.7.9.26.5.2, 5.5.3):
    /// out-of-bounds indices zero-fill and the box is swizzled per 5.5.7. A box
    /// wider than one atom and the `.im2col` load mode (5.5.4) are unsupported.
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn exec_cp_async_bulk_tensor_load(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        dst_base: &Operand,
        dst_offset: i64,
        tensormap_base: &Operand,
        tensormap_offset: i64,
        coords: &[Operand],
        mode: &TensorLoadMode,
        mbar_base: &Operand,
        mbar_offset: i64,
    ) -> EvalResult<()> {
        if let TensorLoadMode::Im2col { .. } = mode {
            return Err(EvalError::Unsupported {
                pc,
                what: "cp.async.bulk.tensor: the .im2col load mode is not modeled".to_string(),
            });
        }

        let dst_addr = self.effective_addr(t, pc, dst_base, dst_offset)?;
        let tm_addr = self.effective_addr(t, pc, tensormap_base, tensormap_offset)?;
        let (tensormap_space, tm_addr) = locate_tensor_map(tm_addr);
        let mbar_addr = self.effective_addr(t, pc, mbar_base, mbar_offset)?;
        let tma = self.tma_box(t, pc, tensormap_space, tm_addr, dst_addr, coords)?;

        let op = self.record_async_issue(t, pc, AsyncOpKind::TensorCopy);
        self.record_tensor_map_read(t, pc, op, tensormap_space, tm_addr);
        let (source, destination) = copy_origins(op);

        for &(global, shared) in &tma.elements {
            // Out of bounds: the zero fill (the only modeled OOB fill mode), a real
            // or an integer zero like the tensor's in-bounds elements.
            let value = match global {
                Some(addr) => {
                    self.mem_read_from(t, pc, MemSpace::Global, addr, tma.elem_bytes, source)?
                }
                None if tma.float_elements => Value::Scalar(
                    self.arena
                        .float_from_f64(0.0)
                        .expect("0.0 is always representable"),
                ),
                None => Value::Scalar(self.arena.int(0)),
            };

            self.mem_write_from(
                t,
                pc,
                MemSpace::Shared,
                shared,
                tma.elem_bytes,
                value,
                destination,
            )?;
        }

        // The transaction count covers the whole box, zero-filled elements included.
        let bytes = tma.elements.len() as u64 * tma.elem_bytes;
        self.mbarrier_complete_tx(t, pc, mbar_addr, bytes, op)
    }

    /// `.tile` TMA tensor store, shared to global (ISA 9.7.9.26.5.2): the
    /// load's box read back from shared memory; out-of-bounds elements are not
    /// written. Its reads and its writes are separate async ops, since a
    /// `cp.async.bulk.wait_group.read` completes only the former.
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn exec_cp_async_bulk_tensor_store(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        tensormap_base: &Operand,
        tensormap_offset: i64,
        coords: &[Operand],
        src_base: &Operand,
        src_offset: i64,
    ) -> EvalResult<BulkStore> {
        let src_addr = self.effective_addr(t, pc, src_base, src_offset)?;
        let tm_addr = self.effective_addr(t, pc, tensormap_base, tensormap_offset)?;
        let (tensormap_space, tm_addr) = locate_tensor_map(tm_addr);
        let tma = self.tma_box(t, pc, tensormap_space, tm_addr, src_addr, coords)?;

        let reads = self.record_async_issue(t, pc, AsyncOpKind::TensorStoreRead);
        let writes = self.record_async_issue(t, pc, AsyncOpKind::TensorStoreWrite);

        // The tensor-map read belongs to the reads, so a `.read` wait completes it.
        self.record_tensor_map_read(t, pc, reads, tensormap_space, tm_addr);
        let (source, _) = copy_origins(reads);
        let (_, destination) = copy_origins(writes);

        for &(global, shared) in &tma.elements {
            // A store never fills: an out-of-bounds element is not written at all.
            let Some(global) = global else {
                continue;
            };

            let value =
                self.mem_read_from(t, pc, MemSpace::Shared, shared, tma.elem_bytes, source)?;
            self.mem_write_from(
                t,
                pc,
                MemSpace::Global,
                global,
                tma.elem_bytes,
                value,
                destination,
            )?;
        }

        Ok(BulkStore {
            reads: Some(reads),
            writes: Some(writes),
        })
    }

    /// The copy's read of its 128-byte tensor map through the tensor-map proxy.
    fn record_tensor_map_read(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: AsyncOpId,
        space: MemSpace,
        addr: u64,
    ) {
        let descriptor = AccessOrigin::Async {
            op,
            proxy: Proxy::TensorMap,
            role: OperandRole::TensorMap,
        };
        self.record_mem_access(
            t,
            pc,
            space,
            addr,
            tensor_map_table::TENSOR_MAP_BYTES,
            None,
            descriptor,
        );
    }

    /// The box of a TMA load (global to shared) or store (shared to global):
    /// each element's global address and its address in the swizzled tile at
    /// `smem_addr`, per the tensor map at `(tensormap_space, tm_addr)` and `coords`.
    fn tma_box(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        tensormap_space: MemSpace,
        tm_addr: u64,
        smem_addr: u64,
        coords: &[Operand],
    ) -> EvalResult<TmaBox> {
        let entry = self
            .tensor_maps
            .get(tensormap_space, tm_addr)
            .cloned()
            .ok_or(EvalError::TensorMapNotFound {
                thread: t,
                pc,
                space: tensormap_space,
                addr: tm_addr,
            })?;
        if entry.im2col.is_some() {
            return Err(EvalError::Unsupported {
                pc,
                what: "cp.async.bulk.tensor: a copy through an im2col tensor map is not modeled"
                    .to_string(),
            });
        }

        let missing = |field: &str| EvalError::TensorMapFieldMissing {
            thread: t,
            pc,
            field: field.to_string(),
        };

        let rank0 = entry.rank.ok_or_else(|| missing("rank"))?;
        let real_rank = rank0 as usize + 1;
        if real_rank != coords.len() {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "cp.async.bulk.tensor: tensor-map rank {} does not match {} tensorCoords operand(s)",
                    real_rank,
                    coords.len()
                ),
            });
        }
        let elemtype = entry.elemtype.ok_or_else(|| missing("elemtype"))?;
        let fill_mode = entry.fill_mode.ok_or_else(|| missing("fill_mode"))?;
        if fill_mode != TensorFillMode::Zero {
            return Err(EvalError::Unsupported {
                pc,
                what: "cp.async.bulk.tensor: OOB-NaN fill mode not modeled (Volta's expression \
                       arena cannot represent a literal NaN constant)"
                    .to_string(),
            });
        }
        let swizzle_mode = entry.swizzle_mode.ok_or_else(|| missing("swizzle_mode"))?;
        let swizzle_atomicity = entry
            .swizzle_atomicity
            .ok_or_else(|| missing("swizzle_atomicity"))?;
        let mma_swizzle = tensor_map_table::to_mma_swizzle_mode(swizzle_mode, swizzle_atomicity)
            .ok_or_else(|| EvalError::Unsupported {
                pc,
                what: format!(
                    "cp.async.bulk.tensor: swizzle mode {:?} / atomicity {:?} combination not modeled",
                    swizzle_mode, swizzle_atomicity
                ),
            })?;
        let global_address = entry
            .global_address
            .ok_or_else(|| missing("global_address"))?;

        let mut box_dims = Vec::with_capacity(real_rank);
        let mut global_dims = Vec::with_capacity(real_rank);
        let mut element_strides = Vec::with_capacity(real_rank);
        for d in 0..real_rank as u32 {
            box_dims.push(*entry.box_dim.get(&d).ok_or_else(|| missing("box_dim"))?);
            global_dims.push(
                *entry
                    .global_dim
                    .get(&d)
                    .ok_or_else(|| missing("global_dim"))?,
            );
            element_strides.push(
                *entry
                    .element_stride
                    .get(&d)
                    .ok_or_else(|| missing("element_stride"))?,
            );
        }
        let mut global_strides = Vec::with_capacity(real_rank.saturating_sub(1));
        for d in 0..(real_rank as u32).saturating_sub(1) {
            global_strides.push(
                *entry
                    .global_stride
                    .get(&d)
                    .ok_or_else(|| missing("global_stride"))?,
            );
        }

        let elem_bytes = elemtype.byte_width();
        let row_bytes = box_dims[0] as u64 * elem_bytes;

        // For a swizzled mode, `stride_dim_byte_offset` is the atom footprint
        // `r * w * CELL_BYTES` (ISA 5.5.7: 256/512/1024 bytes), not the box
        // row width; it matches the corpus kernel's real MMA descriptors.
        let stride_dim_byte_offset = if mma_swizzle == tcgen05_mma::SwizzleMode::None {
            row_bytes
        } else {
            const CELL_BYTES: u64 = 16;
            if !row_bytes.is_multiple_of(CELL_BYTES) {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: box_dim[0] ({} elements, {} bytes) is not a whole \
                         number of 16-byte swizzle cells",
                        box_dims[0], row_bytes
                    ),
                });
            }
            let cell_count = row_bytes / CELL_BYTES;
            let (_, w) = tcgen05_mma::atom_shape(mma_swizzle);
            if cell_count > w {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: box_dim[0] spans {} swizzle cells, more than one \
                         {:?} atom ({} cells) - crossing a leading-dimension atom boundary is not modeled",
                        cell_count, mma_swizzle, w
                    ),
                });
            }
            // `Swizzle128BWith32BAtomicity`'s `atom_shape` gives 512 bytes,
            // contradicting ISA 5.5.7's 1024-byte boundary for every 128B
            // mode, so it is rejected rather than trusted.
            let atom_bytes = match mma_swizzle {
                tcgen05_mma::SwizzleMode::Swizzle32B => 256,
                tcgen05_mma::SwizzleMode::Swizzle64B => 512,
                tcgen05_mma::SwizzleMode::Swizzle128B => 1024,
                tcgen05_mma::SwizzleMode::None
                | tcgen05_mma::SwizzleMode::Swizzle128BWith32BAtomicity => {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "cp.async.bulk.tensor: swizzle mode {:?} not modeled",
                            mma_swizzle
                        ),
                    });
                }
            };
            if !smem_addr.is_multiple_of(atom_bytes) {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: shared address {:#x} is not aligned to the {:?} \
                         swizzle pattern's {}-byte boundary (nonzero swizzle base offset not modeled)",
                        smem_addr, mma_swizzle, atom_bytes
                    ),
                });
            }
            atom_bytes
        };

        let desc = tcgen05_mma::MatrixDescriptor {
            start_addr: smem_addr,
            leading_dim_byte_offset: 0,
            stride_dim_byte_offset,
            base_offset: 0,
            absolute_leading_stride: false,
            lut_b_offset: false,
            swizzle_mode: mma_swizzle,
        };

        let mut coord_vals = Vec::with_capacity(real_rank);
        for c in coords {
            coord_vals.push(self.concrete_operand(
                t,
                pc,
                c,
                "cp.async.bulk.tensor tensorCoords",
            )?);
        }

        let total_elems: u64 = box_dims.iter().map(|&d| d as u64).product();
        let mut elements = Vec::with_capacity(total_elems as usize);
        let mut idx = vec![0u32; real_rank];
        let mut global_idx = vec![0i64; real_rank];
        for linear in 0..total_elems {
            let mut rem = linear;
            for (d, dim) in idx.iter_mut().enumerate() {
                *dim = (rem % box_dims[d] as u64) as u32;
                rem /= box_dims[d] as u64;
            }

            // TMA coordinates are signed: a box may start before the tensor or
            // run past its end, in any dimension.
            let mut in_bounds = true;
            for d in 0..real_rank {
                let gi = coord_vals[d] + idx[d] as i64 * element_strides[d] as i64;
                global_idx[d] = gi;
                if gi < 0 || gi as u64 >= global_dims[d] {
                    in_bounds = false;
                }
            }

            let global = in_bounds.then(|| {
                let mut byte_addr = global_address + global_idx[0] as u64 * elem_bytes;
                for d in 1..real_rank {
                    byte_addr += global_idx[d] as u64 * global_strides[d - 1];
                }
                byte_addr
            });

            let mut stride_idx = 0u64;
            let mut mult = 1u64;
            for d in 1..real_rank {
                stride_idx += idx[d] as u64 * mult;
                mult *= box_dims[d] as u64;
            }
            let leading_idx = idx[0] as u64;
            let shared =
                tcgen05_mma::swizzled_element_addr(&desc, stride_idx, leading_idx, elem_bytes);

            elements.push((global, shared));
        }

        Ok(TmaBox {
            elem_bytes,
            float_elements: elemtype.is_float(),
            elements,
        })
    }

    /// `cp.async.bulk` global -> shared of `size` bytes, completing `size`
    /// tx-bytes on the mbarrier; the write lands immediately in 4-byte words.
    pub(in crate::eval) fn exec_cp_async_bulk_load(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        dst_addr: u64,
        src_addr: u64,
        size: &Operand,
        mbar_addr: u64,
    ) -> EvalResult<()> {
        const WORD_BYTES: u64 = 4;
        let size = self.non_negative_operand(t, pc, size, "cp.async.bulk size")?;
        if !size.is_multiple_of(16) {
            return Err(EvalError::Unsupported {
                pc,
                what: format!("cp.async.bulk size {size} is not a multiple of 16 bytes"),
            });
        }
        self.check_bounds(t, pc, MemSpace::Global, src_addr, size)?;
        self.check_bounds(t, pc, MemSpace::Shared, dst_addr, size)?;
        self.check_alignment(t, pc, MemSpace::Global, src_addr, 16)?;
        self.check_alignment(t, pc, MemSpace::Shared, dst_addr, 16)?;

        let op = self.record_async_issue(t, pc, AsyncOpKind::BulkCopy);
        let (source, destination) = copy_origins(op);
        for byte in (0..size).step_by(WORD_BYTES as usize) {
            let src = src_addr + byte;
            let value = self.mem_read_from(t, pc, MemSpace::Global, src, WORD_BYTES, source)?;
            let dst = dst_addr + byte;
            self.mem_write_from(t, pc, MemSpace::Shared, dst, WORD_BYTES, value, destination)?;
        }

        self.mbarrier_complete_tx(t, pc, mbar_addr, size, op)
    }

    /// Resolve the mbarrier object living at shared address `addr`.
    fn mbarrier_handle(&mut self, t: ThreadId, pc: InstrId, addr: u64) -> EvalResult<MbarrierId> {
        self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
        self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
        self.shared
            .read_mbarrier(addr)
            .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))
    }

    /// `op`'s completion performs a complete-tx of `bytes` on the mbarrier
    /// object at shared address `addr`.
    pub(in crate::eval) fn mbarrier_complete_tx(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        addr: u64,
        bytes: u64,
        op: AsyncOpId,
    ) -> EvalResult<()> {
        let id = self.mbarrier_handle(t, pc, addr)?;
        self.record_tracked_by_mbarrier(op, id, bytes);
        let before = self.mbarriers.completed_phases(id);
        self.mbarriers.complete_tx(id, bytes);
        self.record_mbarrier_progress(id, before);
        self.check_mbarrier_tx_count(t, pc, id)
    }
}

/// A bulk copy's source and destination effects, both through the async proxy.
fn copy_origins(op: AsyncOpId) -> (AccessOrigin, AccessOrigin) {
    let origin = |role| AccessOrigin::Async {
        op,
        proxy: Proxy::Async,
        role,
    };
    (
        origin(OperandRole::Source),
        origin(OperandRole::Destination),
    )
}
