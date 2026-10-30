//! Initial registers for a wave launched under the AMDHSA calling convention.

#[cfg(test)]
mod tests;

use volta_expr::ExprArena;

use crate::ir::{LoweredKernel, Sgpr, Vgpr};

use super::{EvalError, WaveRegisters};

/// Launch inputs for one full wave; coordinate tuples are ordered (X, Y, Z).
#[derive(Debug, Clone, Copy)]
pub(crate) struct WaveLaunch {
    /// Address of the buffer containing the kernel's arguments.
    pub kernarg_address: u64,
    /// Coordinates of this workgroup within the grid.
    pub workgroup_id: (u32, u32, u32),
    /// Number of work-items along X, Y, and Z in this workgroup.
    pub workgroup_size: (u32, u32, u32),
    /// Wave number within this workgroup, starting at zero.
    /// Each workgroup numbers its waves independently.
    pub wave_index: u32,
}

/// Initialize the requested launch registers, leaving other registers unwritten.
pub(crate) fn initialize_wave(
    kernel: &LoweredKernel,
    launch: &WaveLaunch,
    arena: &mut ExprArena,
) -> Result<WaveRegisters, EvalError> {
    if kernel.target.split(':').next() != Some("amdgcn-amd-amdhsa--gfx950") {
        return Err(EvalError::Launch {
            message: format!("unsupported target {:?}", kernel.target),
        });
    }
    // Validate the workgroup size and selected wave.
    let (size_x, size_y, size_z) = launch.workgroup_size;
    let workitems = size_x
        .checked_mul(size_y)
        .and_then(|xy| xy.checked_mul(size_z));
    let Some(workitems) =
        workitems.filter(|count| (64..=1024).contains(count) && count.is_multiple_of(64))
    else {
        return Err(EvalError::Launch {
            message: "expected a workgroup totaling 64 to 1024 work-items in full waves".into(),
        });
    };
    if launch.wave_index >= workitems / 64 {
        return Err(EvalError::Launch {
            message: "wave index is outside the workgroup".into(),
        });
    }

    // Reject enabled launch inputs that this initializer cannot provide.
    for (setting, value) in &kernel.descriptor {
        let unsupported_feature = (setting.starts_with("user_sgpr_")
            && !matches!(
                setting.as_str(),
                "user_sgpr_count"
                    | "user_sgpr_kernarg_segment_ptr"
                    // The offset alone loads nothing; a nonzero preload length is rejected.
                    | "user_sgpr_kernarg_preload_offset"
            ))
            || (setting.starts_with("system_sgpr_")
                && !matches!(
                    setting.as_str(),
                    "system_sgpr_workgroup_id_x"
                        | "system_sgpr_workgroup_id_y"
                        | "system_sgpr_workgroup_id_z"
                ))
            || matches!(
                setting.as_str(),
                "enable_private_segment" | "wavefront_size32"
            );
        // Allow unsupported features when explicitly disabled (by setting the value to 0).
        if unsupported_feature && *value != 0 {
            return Err(EvalError::Launch {
                message: format!("unsupported .amdhsa_{setting} {value}"),
            });
        }
    }
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
    let workgroup_ids = [
        (
            setting("system_sgpr_workgroup_id_x", 1)? != 0,
            launch.workgroup_id.0,
        ),
        (
            setting("system_sgpr_workgroup_id_y", 1)? != 0,
            launch.workgroup_id.1,
        ),
        (
            setting("system_sgpr_workgroup_id_z", 1)? != 0,
            launch.workgroup_id.2,
        ),
    ];
    let user_sgprs = setting("user_sgpr_count", 2)?;
    let workitem_id_mode = setting("system_vgpr_workitem_id", 2)?;
    // The argument pointer needs two user SGPRs when enabled, otherwise none.
    if user_sgprs != if kernarg_enabled { 2 } else { 0 } {
        return Err(EvalError::Launch {
            message: ".amdhsa_user_sgpr_count must match the enabled kernarg pointer".into(),
        });
    }

    if kernarg_enabled && !launch.kernarg_address.is_multiple_of(16) {
        return Err(EvalError::Launch {
            message: "kernarg address must be 16-byte aligned".into(),
        });
    }

    // Initialize scalar registers with the requested launch inputs.
    let mut registers = WaveRegisters::default();
    if kernarg_enabled {
        // Split the 64-bit address across s0 (low word) and s1 (high word).
        let low = arena.int((launch.kernarg_address & u64::from(u32::MAX)) as i64);
        let high = arena.int((launch.kernarg_address >> 32) as i64);
        registers.write_sgpr(Sgpr(0), low)?;
        registers.write_sgpr(Sgpr(1), high)?;
    }
    let mut next_sgpr = user_sgprs as u8;
    // Place workgroup coordinates after the user registers.
    for (enabled, coordinate) in workgroup_ids {
        // Disabled axes consume no register slots.
        if enabled {
            let id = arena.int(i64::from(coordinate));
            registers.write_sgpr(Sgpr(next_sgpr), id)?;
            next_sgpr += 1;
        }
    }

    let first_workitem = launch.wave_index * 64;
    // Initialize each lane's work-item coordinates in v0.
    for lane in 0..64 {
        // Convert the workgroup-local index to coordinates, with X advancing fastest.
        let linear_id = first_workitem + lane as u32;
        let x = linear_id % size_x;
        let y = (linear_id / size_x) % size_y;
        let z = linear_id / (size_x * size_y);

        // Pack requested X/Y/Z coordinates into ten-bit fields in v0.
        // Unrequested Y/Z fields remain zero.
        let mut packed = x;
        if workitem_id_mode > 0 {
            packed |= y << 10;
        }
        if workitem_id_mode > 1 {
            packed |= z << 20;
        }
        let id = arena.int(i64::from(packed));
        registers.write_vgpr(lane, Vgpr(0), id)?;
    }

    Ok(registers)
}
