//! The initial waves of a workgroup launched under the AMDHSA calling convention.

use std::collections::BTreeMap;

use id_collections::IdVec;
use volta_expr::ExprArena;

use crate::ir::{LoweredKernel, Sgpr, Vgpr};

use super::EvalError;
use super::wave::{WaveId, WaveRegisters, WaveState};

/// Launch inputs of workgroup 0, the workgroup Volta analyzes.
#[derive(Debug, Clone, Copy)]
pub struct WorkgroupLaunch {
    /// Address of the buffer containing the kernel's arguments.
    pub kernarg_address: u64,
    /// Number of work-items along X, Y, and Z in this workgroup.
    pub workgroup_size: (u32, u32, u32),
}

/// Create every wave of the workgroup at the kernel's first instruction, with the requested
/// launch registers written and other registers unwritten.
pub(crate) fn initialize_waves(
    kernel: &LoweredKernel,
    launch: &WorkgroupLaunch,
    arena: &mut ExprArena,
) -> Result<IdVec<WaveId, WaveState>, EvalError> {
    if kernel.target.split(':').next() != Some("amdgcn-amd-amdhsa--gfx950") {
        return Err(EvalError::Launch {
            message: format!("unsupported target {:?}", kernel.target),
        });
    }
    // Validate the workgroup size.
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
    let workgroup_ids = ["x", "y", "z"]
        .into_iter()
        .map(|axis| setting(&format!("system_sgpr_workgroup_id_{axis}"), 1))
        .sum::<Result<u64, _>>()?;

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

    let mut waves = Vec::new();
    for wave in (0..workitems / 64).map(WaveId) {
        // Initialize scalar registers with the requested launch inputs.
        let mut registers = WaveRegisters::default();
        if kernarg_enabled {
            // Split the 64-bit address across s0 (low word) and s1 (high word).
            let low = arena.int((launch.kernarg_address & u64::from(u32::MAX)) as i64);
            let high = arena.int((launch.kernarg_address >> 32) as i64);
            registers.write_sgpr(Sgpr(0), low)?;
            registers.write_sgpr(Sgpr(1), high)?;
        }

        // Each enabled workgroup ID follows the user registers; disabled axes take no register.
        for reg in user_sgprs..user_sgprs + workgroup_ids {
            let id = arena.int(0);
            registers.write_sgpr(Sgpr(reg as u8), id)?;
        }

        // Initialize each lane's work-item coordinates in v0.
        for lane in 0..64 {
            let packed = packed_workitem_id(launch, wave, lane as u32, workitem_id_mode);
            let id = arena.int(i64::from(packed));
            registers.write_vgpr(lane, Vgpr(0), id)?;
        }

        waves.push(WaveState::new(registers));
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
            | "user_sgpr_kernarg_segment_ptr"
            | "system_sgpr_workgroup_id_x"
            | "system_sgpr_workgroup_id_y"
            | "system_sgpr_workgroup_id_z" => false,
            // Loads nothing without a preload length, which the last arm rejects.
            "user_sgpr_kernarg_preload_offset" => false,
            "enable_private_segment" | "wavefront_size32" => true,
            // Every other SGPR input, such as the dispatch pointer or workgroup info.
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
