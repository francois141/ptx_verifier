//! `cp.async.bulk{.tensor}` evaluation (TMA tensor and plain bulk copies,
//! global to shared, mbarrier-completed) and the in-flight locks held until a
//! waiter observes the copy's mbarrier phase.

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::Interpreter;
use crate::eval::tcgen05_mma;
use crate::eval::tensor_map_table;
use crate::eval::value::{MbarrierId, Value};
use crate::lowered::{InstrId, MemSpace, Operand};
use crate::tensor_map::TensorFillMode;

/// A bulk copy whose completion no waiter has observed yet. Its data lands
/// eagerly, but its destination stays locked until then: an observed mbarrier
/// phase is its only completion signal (9.7.9.25.2).
#[derive(Debug)]
pub(in crate::eval) struct InflightBulkCopy {
    issuer: ThreadId,
    /// The issuing instruction, for lock diagnostics and as the `pc` the
    /// destination locks were taken under.
    pc: InstrId,
    /// Locked destination ranges as `(addr, width)` - `.tensor`'s swizzled
    /// box is written element by element, not as one contiguous range.
    dst: Vec<(u64, u64)>,
    mbar: MbarrierId,
    /// `MbarrierTable::completed_phases` at issue: the copy's own
    /// complete-tx belongs to the phase forming then, so the copy has
    /// completed once `mbar` has moved past it.
    phase: u64,
}

impl<'p> Interpreter<'p> {
    /// `.tile` TMA tensor copy, global to shared (ISA 9.7.9.26.5.2, 5.5.3):
    /// out-of-bounds indices zero-fill and the box is swizzled per 5.5.7; a
    /// box wider than one atom is rejected.
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn exec_cp_async_bulk_tensor_load(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        dst_base: &Operand,
        dst_offset: i64,
        tensormap_space: MemSpace,
        tensormap_base: &Operand,
        tensormap_offset: i64,
        coords: &[Operand],
        mbar_base: &Operand,
        mbar_offset: i64,
    ) -> EvalResult<()> {
        let dst_addr = self.effective_addr(t, pc, dst_base, dst_offset)?;
        let tm_addr = self.effective_addr(t, pc, tensormap_base, tensormap_offset)?;
        let mbar_addr = self.effective_addr(t, pc, mbar_base, mbar_offset)?;

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
            if !dst_addr.is_multiple_of(atom_bytes) {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: destination {:#x} is not aligned to the {:?} \
                         swizzle pattern's {}-byte boundary (nonzero swizzle base offset not modeled)",
                        dst_addr, mma_swizzle, atom_bytes
                    ),
                });
            }
            atom_bytes
        };

        let desc = tcgen05_mma::MatrixDescriptor {
            start_addr: dst_addr,
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
        let mut dst_ranges = Vec::with_capacity(total_elems as usize);
        let mut idx = vec![0u32; real_rank];
        let mut global_idx = vec![0i64; real_rank];
        for linear in 0..total_elems {
            let mut rem = linear;
            for (d, dim) in idx.iter_mut().enumerate() {
                *dim = (rem % box_dims[d] as u64) as u32;
                rem /= box_dims[d] as u64;
            }

            let mut in_bounds = true;
            for d in 0..real_rank {
                let gi = coord_vals[d] + idx[d] as i64 * element_strides[d] as i64;
                global_idx[d] = gi;
                if gi < 0 || gi as u64 >= global_dims[d] {
                    in_bounds = false;
                }
            }

            let value = if in_bounds {
                let mut byte_addr = global_address + global_idx[0] as u64 * elem_bytes;
                for d in 1..real_rank {
                    byte_addr += global_idx[d] as u64 * global_strides[d - 1];
                }
                self.mem_read(t, pc, MemSpace::Global, byte_addr, elem_bytes)?
            } else if elemtype.is_float() {
                Value::Scalar(
                    self.arena
                        .float_from_f64(0.0)
                        .expect("0.0 is always representable"),
                )
            } else {
                Value::Scalar(self.arena.int(0))
            };

            let mut stride_idx = 0u64;
            let mut mult = 1u64;
            for d in 1..real_rank {
                stride_idx += idx[d] as u64 * mult;
                mult *= box_dims[d] as u64;
            }
            let leading_idx = idx[0] as u64;
            let dst_elem_addr =
                tcgen05_mma::swizzled_element_addr(&desc, stride_idx, leading_idx, elem_bytes);
            self.mem_write(t, pc, MemSpace::Shared, dst_elem_addr, elem_bytes, value)?;
            // A TMA write goes through the async proxy, not the generic one
            // `mem_write` just marked these bytes as written through.
            self.race.clear_generic_unfenced(dst_elem_addr, elem_bytes);
            dst_ranges.push((dst_elem_addr, elem_bytes));
        }

        self.begin_inflight_bulk_copy(t, pc, mbar_addr, dst_ranges)?;
        self.mbarrier_complete_tx(t, pc, mbar_addr, total_elems * elem_bytes)
    }

    /// `cp.async.bulk` global -> shared of `size` bytes, completing `size`
    /// tx-bytes on the mbarrier; the write lands immediately in 4-byte words
    /// and the destination stays locked in flight.
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

        for byte in (0..size).step_by(WORD_BYTES as usize) {
            let value = self.mem_read(t, pc, MemSpace::Global, src_addr + byte, WORD_BYTES)?;
            self.mem_write(t, pc, MemSpace::Shared, dst_addr + byte, WORD_BYTES, value)?;
        }
        self.race.clear_generic_unfenced(dst_addr, size);

        self.begin_inflight_bulk_copy(t, pc, mbar_addr, vec![(dst_addr, size)])?;
        self.mbarrier_complete_tx(t, pc, mbar_addr, size)
    }

    /// Resolve the mbarrier object living at shared address `addr`.
    fn mbarrier_handle(&mut self, t: ThreadId, pc: InstrId, addr: u64) -> EvalResult<MbarrierId> {
        self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
        self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
        self.shared
            .read_mbarrier(addr)
            .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))
    }

    /// Perform a complete-tx of `bytes` on the mbarrier object at shared
    /// address `addr`.
    fn mbarrier_complete_tx(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        addr: u64,
        bytes: u64,
    ) -> EvalResult<()> {
        let id = self.mbarrier_handle(t, pc, addr)?;
        self.mbarriers.complete_tx(id, bytes);
        Ok(())
    }

    /// Lock a just-landed copy's destination until the mbarrier at
    /// `mbar_addr` moves past the current phase. Called after the write so it
    /// doesn't trip its own lock; unwaited accesses are reported.
    fn begin_inflight_bulk_copy(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        mbar_addr: u64,
        dst: Vec<(u64, u64)>,
    ) -> EvalResult<()> {
        let mbar = self.mbarrier_handle(t, pc, mbar_addr)?;
        let phase = self.mbarriers.completed_phases(mbar);
        for &(addr, width) in &dst {
            self.race
                .lock_dst(MemSpace::Shared, addr, width, t, pc)
                .map_err(EvalError::from)?;
        }
        self.bulk_inflight.push(InflightBulkCopy {
            issuer: t,
            pc,
            dst,
            mbar,
            phase,
        });
        Ok(())
    }

    /// A waiter observes `mbar`'s completed phase: drop its copies' locks
    /// (the implicit proxy fence, 9.7.9.25.2) and record their writes in χ
    /// afresh, since the copy only completed now.
    pub(in crate::eval) fn release_observed_bulk_copies(
        &mut self,
        mbar: MbarrierId,
    ) -> EvalResult<()> {
        let observed = self.mbarriers.completed_phases(mbar);
        let (done, in_flight): (Vec<_>, Vec<_>) = std::mem::take(&mut self.bulk_inflight)
            .into_iter()
            .partition(|copy| copy.mbar == mbar && copy.phase < observed);
        self.bulk_inflight = in_flight;
        for copy in &done {
            for &(addr, width) in &copy.dst {
                self.race
                    .release_dst(MemSpace::Shared, addr, width, copy.issuer, copy.pc);
                self.race
                    .write(MemSpace::Shared, addr, width, copy.issuer, copy.pc)
                    .map_err(EvalError::from)?;
            }
        }
        Ok(())
    }
}
