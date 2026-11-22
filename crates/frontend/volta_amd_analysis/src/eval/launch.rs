//! The initial waves of a workgroup launched under the AMDHSA calling convention.

use std::collections::BTreeMap;

use id_collections::IdVec;
use volta_expr::symbolic_full::{ExprArena, ExprId};

use crate::ir::{LoweredKernel, Sgpr, Vgpr};

use super::EvalError;
use super::wave::{WaveId, WaveRegisters, WaveState};

/// Launch inputs of the workgroup Volta analyzes.
#[derive(Debug, Clone, Copy)]
pub struct WorkgroupLaunch {
    /// Address of the buffer containing the kernel's arguments.
    pub kernarg_address: u64,
    /// Number of work-items along X, Y, and Z in this workgroup.
    pub workgroup_size: (u32, u32, u32),
    /// This workgroup's X, Y, and Z coordinates in the grid.
    pub workgroup_id: (u32, u32, u32),
    /// Number of workgroups along X, Y, and Z in the grid.
    pub grid_size: (u32, u32, u32),
    /// LDS bytes the dispatch allocates past the descriptor's fixed group segment, as
    /// Triton's launcher allocates its kernels' shared memory.
    pub dynamic_lds_bytes: u32,
}

/// How many workgroups `grid` launches.
pub(crate) fn grid_workgroups(grid: (u32, u32, u32)) -> Result<usize, EvalError> {
    let (x, y, z) = grid;
    u64::from(x)
        .checked_mul(u64::from(y))
        .and_then(|xy| xy.checked_mul(u64::from(z)))
        .and_then(|count| usize::try_from(count).ok())
        .filter(|&count| count > 0)
        .ok_or_else(|| EvalError::Launch {
            message: "launch grid dimensions must be nonzero and their product must fit in usize"
                .into(),
        })
}

/// The coordinates of workgroup `index` of `grid`, numbering X fastest, then Y, then Z.
pub(crate) fn workgroup_coordinates(grid: (u32, u32, u32), index: usize) -> (u32, u32, u32) {
    let (x, y, _) = grid;
    let index = index as u64;
    let x = u64::from(x.max(1));
    let y = u64::from(y.max(1));
    (
        (index % x) as u32,
        (index / x % y) as u32,
        (index / (x * y)) as u32,
    )
}

/// Give each enabled workgroup-ID register of every wave its value in each workgroup of
/// `grid`. An axis along which the grid has one workgroup keeps its single coordinate.
pub(crate) fn vary_workgroup_ids(
    kernel: &LoweredKernel,
    grid: (u32, u32, u32),
    waves: &mut IdVec<WaveId, WaveState>,
    arena: &mut ExprArena,
) -> Result<(), EvalError> {
    let workgroups = grid_workgroups(grid)?;
    let enabled = |axis: &str| {
        kernel
            .descriptor
            .get(&format!("system_sgpr_workgroup_id_{axis}"))
            .is_some_and(|&value| value != 0)
    };
    // Enabled IDs follow the user registers in X, Y, Z order, as `initialize_waves` writes them.
    let mut next = kernel
        .descriptor
        .get("user_sgpr_count")
        .copied()
        .unwrap_or(0);
    for (axis, name) in ["x", "y", "z"].into_iter().enumerate() {
        if !enabled(name) {
            continue;
        }
        let reg = Sgpr(u8::try_from(next).map_err(|_| EvalError::Launch {
            message: "workgroup ID register is outside the scalar registers".into(),
        })?);
        next += 1;
        let coordinates: Vec<u32> = (0..workgroups)
            .map(|index| {
                let (x, y, z) = workgroup_coordinates(grid, index);
                [x, y, z][axis]
            })
            .collect();
        let Some(&first) = coordinates.first() else {
            continue;
        };
        if coordinates.iter().all(|&coordinate| coordinate == first) {
            continue;
        }
        let words: Vec<ExprId> = coordinates
            .into_iter()
            .map(|coordinate| arena.int(i64::from(coordinate)))
            .collect();
        for state in waves.values_mut() {
            state.registers.set_varying_sgpr(reg, &words);
        }
    }
    Ok(())
}

/// Create every wave of the workgroup at the kernel's first instruction, with the requested
/// launch registers written and other registers unwritten.
pub(crate) fn initialize_waves(
    kernel: &LoweredKernel,
    launch: &WorkgroupLaunch,
    arena: &mut ExprArena,
) -> Result<IdVec<WaveId, WaveState>, EvalError> {
    if !crate::lower::targets_gfx950(&kernel.target) {
        return Err(EvalError::Launch {
            message: format!("unsupported target {:?}", kernel.target),
        });
    }
    // Validate the workgroup size.
    let (size_x, size_y, size_z) = launch.workgroup_size;
    let workitems = size_x
        .checked_mul(size_y)
        .and_then(|xy| xy.checked_mul(size_z));

    // A workgroup of fewer than 64 work-items is one wave whose other lanes start inactive.
    let Some(workitems) = workitems.filter(|count| {
        (1..64).contains(count) || ((64..=1024).contains(count) && count.is_multiple_of(64))
    }) else {
        return Err(EvalError::Launch {
            message: "expected a workgroup of 1 to 63 work-items, or of 64 to 1024 in full waves"
                .into(),
        });
    };

    // Validate that the selected workgroup is located inside a nonempty grid.
    let (x, y, z) = launch.workgroup_id;
    let (grid_x, grid_y, grid_z) = launch.grid_size;
    if x >= grid_x || y >= grid_y || z >= grid_z {
        return Err(EvalError::Launch {
            message: "expected a workgroup ID inside a grid with nonzero dimensions".into(),
        });
    }

    reject_unsupported_inputs(&kernel.descriptor)?;

    // Read a required setting and check its supported range.
    let setting = |name: &str, max: u64| -> Result<u64, EvalError> {
        match kernel.descriptor.get(name).copied() {
            Some(value) if value <= max => Ok(value),
            Some(value) => Err(EvalError::Launch {
                message: format!("unsupported .amdhsa_{name} {value}"),
            }),
            // Required settings need to be explicitly provided in the kernel descriptor.
            None => Err(EvalError::Launch {
                message: format!("missing .amdhsa_{name}"),
            }),
        }
    };

    // Read which launch inputs and register counts the descriptor requests.
    let kernarg_enabled = setting("user_sgpr_kernarg_segment_ptr", 1)? != 0;
    let workgroup_ids = [("x", x), ("y", y), ("z", z)]
        .into_iter()
        .map(|(axis, id)| {
            setting(&format!("system_sgpr_workgroup_id_{axis}"), 1)
                .map(|enabled| (enabled != 0).then_some(id))
        })
        .collect::<Result<Vec<_>, _>>()?;

    let user_sgprs = setting("user_sgpr_count", 16)?;
    let workitem_id_mode = setting("system_vgpr_workitem_id", 2)?;

    // The ABI's user SGPRs before the argument pointer, then those after it, two each. The
    // dispatch and queue pointers and the dispatch ID are left unwritten: reading one fails.
    let enabled = |name: &str| match kernel.descriptor.get(name).copied() {
        None | Some(0) => Ok(0),
        Some(1) => Ok(2),
        Some(value) => Err(EvalError::Launch {
            message: format!("unsupported .amdhsa_{name} {value}"),
        }),
    };
    let before_kernarg = enabled("user_sgpr_dispatch_ptr")? + enabled("user_sgpr_queue_ptr")?;
    let after_kernarg = enabled("user_sgpr_dispatch_id")?;
    let kernarg_sgprs = if kernarg_enabled { 2 } else { 0 };
    if user_sgprs != before_kernarg + kernarg_sgprs + after_kernarg {
        return Err(EvalError::Launch {
            message: ".amdhsa_user_sgpr_count must match the enabled user SGPRs".into(),
        });
    }
    let kernarg_sgpr = before_kernarg as u8;

    if kernarg_enabled && !launch.kernarg_address.is_multiple_of(16) {
        return Err(EvalError::Launch {
            message: "kernarg address must be 16-byte aligned".into(),
        });
    }

    let mut waves = Vec::new();
    for wave in (0..workitems.div_ceil(64)).map(WaveId) {
        // Initialize scalar registers with the requested launch inputs.
        let mut registers = WaveRegisters::default();
        if kernarg_enabled {
            // Split the 64-bit address across two SGPRs, the low word first.
            let low = arena.int((launch.kernarg_address & u64::from(u32::MAX)) as i64);
            let high = arena.int((launch.kernarg_address >> 32) as i64);
            registers.write_sgpr(Sgpr(kernarg_sgpr), low)?;
            registers.write_sgpr(Sgpr(kernarg_sgpr + 1), high)?;
        }

        // Each enabled workgroup ID follows the user registers; disabled axes take no register.
        for (offset, &id) in workgroup_ids.iter().flatten().enumerate() {
            let id = arena.int(i64::from(id));
            registers.write_sgpr(Sgpr(user_sgprs as u8 + offset as u8), id)?;
        }

        // Initialize each lane's work-item coordinates in v0.
        for lane in 0..64 {
            let packed = packed_workitem_id(launch, wave, lane as u32, workitem_id_mode);
            let id = arena.int(i64::from(packed));
            registers.write_vgpr(lane, Vgpr(0), id)?;
        }

        let mut state = WaveState::new(registers);
        if workitems < 64 {
            state.exec = (1 << workitems) - 1;
        }
        waves.push(state);
    }
    Ok(IdVec::from_vec(waves))
}

/// Reject a descriptor that enables a launch input or mode this initializer cannot provide.
/// Such a setting is accepted only when it is 0, i.e. explicitly disabled.
fn reject_unsupported_inputs(descriptor: &BTreeMap<String, u64>) -> Result<(), EvalError> {
    for (setting, &value) in descriptor {
        let unsupported = match setting.as_str() {
            // Read and checked by `initialize_waves`.
            "user_sgpr_count"
            | "user_sgpr_dispatch_ptr"
            | "user_sgpr_queue_ptr"
            | "user_sgpr_dispatch_id"
            | "user_sgpr_kernarg_segment_ptr"
            | "system_sgpr_workgroup_id_x"
            | "system_sgpr_workgroup_id_y"
            | "system_sgpr_workgroup_id_z" => false,
            // Loads nothing without a preload length, which the last arm rejects.
            "user_sgpr_kernarg_preload_offset" => false,
            "enable_private_segment" | "wavefront_size32" => true,
            // Every other SGPR input, such as the private segment buffer or workgroup info.
            other => other.starts_with("user_sgpr_") || other.starts_with("system_sgpr_"),
        };
        if unsupported && value != 0 {
            return Err(EvalError::Launch {
                message: format!("unsupported .amdhsa_{setting} {value}"),
            });
        }
    }
    Ok(())
}

/// The v0 value of `lane` of `wave` in a launch `initialize_waves` validated: its X/Y/Z
/// coordinates in ten-bit fields, with Y and Z zero unless `workitem_id_mode` requests them.
fn packed_workitem_id(
    launch: &WorkgroupLaunch,
    wave: WaveId,
    lane: u32,
    workitem_id_mode: u64,
) -> u32 {
    let (size_x, size_y, _) = launch.workgroup_size;

    // Convert the workgroup-local index to coordinates, with X advancing fastest.
    let linear_id = wave.0 * 64 + lane;
    let x = linear_id % size_x;
    let y = (linear_id / size_x) % size_y;
    let z = linear_id / (size_x * size_y);

    let mut packed = x;
    if workitem_id_mode > 0 {
        packed |= y << 10;
    }
    if workitem_id_mode > 1 {
        packed |= z << 20;
    }
    packed
}
