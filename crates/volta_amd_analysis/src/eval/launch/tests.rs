//! Tests for mapping launch inputs to AMD registers.

use std::collections::BTreeMap;

use volta_expr::ExprArena;

use crate::frontend::parse::parse_kernel;
use crate::ir::{LoweredKernel, Sgpr, Vgpr};
use crate::lower_kernel;

use super::super::EvalError;
use super::{WaveLaunch, initialize_wave};

fn kernel() -> LoweredKernel {
    LoweredKernel {
        name: "launch_test".into(),
        target: "amdgcn-amd-amdhsa--gfx950".into(),
        instructions: Vec::new(),
        descriptor: BTreeMap::from([
            ("user_sgpr_kernarg_segment_ptr".into(), 1),
            ("user_sgpr_count".into(), 2),
            ("system_sgpr_workgroup_id_x".into(), 1),
            ("system_sgpr_workgroup_id_y".into(), 0),
            ("system_sgpr_workgroup_id_z".into(), 0),
            ("system_vgpr_workitem_id".into(), 0),
        ]),
    }
}

fn launch() -> WaveLaunch {
    WaveLaunch {
        kernarg_address: 0x0000_1234_abcd_0000,
        workgroup_id: (7, 11, 13),
        workgroup_size: (128, 1, 1),
        wave_index: 0,
    }
}

// Test that a compiled kernel initializes the registers its descriptor requests.
#[test]
fn initializes_compiled_kernel_launch_registers() {
    let source = include_str!("../../../tests/fixtures/copy.s");
    let kernel = lower_kernel(&parse_kernel(source, "copy").unwrap()).unwrap();
    let mut arena = ExprArena::new();
    let registers = initialize_wave(&kernel, &launch(), &mut arena).unwrap();

    // Check the argument-pointer words in s0/s1 and the workgroup X ID in s2.
    for (reg, expected) in [(0, 0xabcd_0000), (1, 0x1234), (2, 7)] {
        let value = registers.read_sgpr(Sgpr(reg)).unwrap();
        assert_eq!(arena.as_int_const(value), Some(expected));
    }
    for lane in [0, 63] {
        let value = registers.read_vgpr(lane, Vgpr(0)).unwrap();
        assert_eq!(arena.as_int_const(value), Some(lane as i64));
    }

    // Registers not assigned by the launch must still report uninitialized reads.
    assert_eq!(
        registers.read_sgpr(Sgpr(3)),
        Err(EvalError::UninitializedSgpr(Sgpr(3)))
    );
    assert_eq!(
        registers.read_vgpr(0, Vgpr(1)),
        Err(EvalError::UninitializedVgpr {
            lane: 0,
            reg: Vgpr(1)
        })
    );
}

// Test that disabled workgroup coordinates do not leave unused register slots.
#[test]
fn initializes_enabled_workgroup_coordinates_in_order() {
    // Each case lists enabled X/Y/Z inputs and the expected register values in order.
    let cases: [((u64, u64, u64), &[i64]); 6] = [
        ((1, 1, 1), &[7, 11, 13]),
        ((0, 1, 1), &[11, 13]),
        ((1, 0, 1), &[7, 13]),
        ((0, 0, 1), &[13]),
        ((1, 0, 0), &[7]),
        ((0, 0, 0), &[]),
    ];
    // Test both absent and present argument pointers.
    for user_sgprs in [0, 2] {
        for (enabled, expected) in cases {
            let mut kernel = kernel();
            for (name, value) in [
                ("user_sgpr_count", user_sgprs),
                ("user_sgpr_kernarg_segment_ptr", user_sgprs / 2),
                ("system_sgpr_workgroup_id_x", enabled.0),
                ("system_sgpr_workgroup_id_y", enabled.1),
                ("system_sgpr_workgroup_id_z", enabled.2),
            ] {
                kernel.descriptor.insert(name.into(), value);
            }
            let mut arena = ExprArena::new();
            let registers = initialize_wave(&kernel, &launch(), &mut arena).unwrap();

            // Check enabled coordinates appear consecutively after any user registers.
            for (index, value) in expected.iter().enumerate() {
                let reg = Sgpr(user_sgprs as u8 + index as u8);
                let actual = registers.read_sgpr(reg).unwrap();
                assert_eq!(arena.as_int_const(actual), Some(*value));
            }
            let next = Sgpr(user_sgprs as u8 + expected.len() as u8);
            assert_eq!(
                registers.read_sgpr(next),
                Err(EvalError::UninitializedSgpr(next))
            );
        }
    }
}

// Test that v0 contains the requested work-item coordinates for 1D, 2D, and 3D groups.
#[test]
fn packs_requested_workitem_coordinates() {
    // Each row gives (workgroup size, wave, lane, expected X/Y/Z).
    let cases = [
        ((128, 1, 1), 1, 0, (64, 0, 0)),
        ((1024, 1, 1), 15, 63, (1023, 0, 0)),
        // Moving past the last X coordinate advances Y.
        ((16, 8, 1), 0, 15, (15, 0, 0)),
        ((16, 8, 1), 0, 16, (0, 1, 0)),
        // Moving past the last X/Y coordinate advances Z, even within a wave.
        ((10, 8, 4), 1, 15, (9, 7, 0)),
        ((10, 8, 4), 1, 16, (0, 0, 1)),
        ((4, 8, 4), 1, 63, (3, 7, 3)),
        ((1, 1024, 1), 15, 63, (0, 1023, 0)),
        ((1, 1, 1024), 15, 63, (0, 0, 1023)),
    ];
    // Check each descriptor mode: X only, X/Y, and X/Y/Z.
    for mode in 0..=2 {
        for (workgroup_size, wave_index, lane, (x, y, z)) in cases {
            let mut kernel = kernel();
            kernel
                .descriptor
                .insert("system_vgpr_workitem_id".into(), mode);
            let mut arena = ExprArena::new();
            let launch = WaveLaunch {
                workgroup_size,
                wave_index,
                ..launch()
            };
            let registers = initialize_wave(&kernel, &launch, &mut arena).unwrap();

            // Extract the ten-bit coordinate fields from v0.
            let id = registers.read_vgpr(lane, Vgpr(0)).unwrap();
            let packed = arena.as_int_const(id).unwrap();
            assert_eq!(packed & 0x3ff, x);
            // Unrequested Y/Z fields must be zero even when those coordinates are nonzero.
            assert_eq!((packed >> 10) & 0x3ff, if mode > 0 { y } else { 0 });
            assert_eq!((packed >> 20) & 0x3ff, if mode > 1 { z } else { 0 });
            assert_eq!(packed >> 30, 0);
        }
    }
}

// Test that unsupported or missing descriptor settings produce errors naming the setting.
#[test]
fn rejects_unsupported_descriptor_layouts() {
    for (name, value) in [
        ("user_sgpr_dispatch_ptr", 1),
        ("user_sgpr_kernarg_preload_length", 1),
        ("system_sgpr_workgroup_id_y", 2),
        ("system_sgpr_workgroup_id_z", 2),
        ("system_sgpr_workgroup_info", 1),
        ("enable_private_segment", 1),
        ("wavefront_size32", 1),
        ("system_vgpr_workitem_id", 3),
        ("user_sgpr_count", 1),
        ("user_sgpr_count", 3),
        ("user_sgpr_kernarg_segment_ptr", 2),
        ("system_sgpr_workgroup_id_x", 2),
    ] {
        let mut kernel = kernel();
        kernel.descriptor.insert(name.into(), value);
        let mut arena = ExprArena::new();
        let error = initialize_wave(&kernel, &launch(), &mut arena).unwrap_err();
        assert!(error.to_string().contains(name), "{error}");
    }

    // Remove each required setting and check that its absence is reported.
    for name in kernel().descriptor.keys() {
        let mut kernel = kernel();
        kernel.descriptor.remove(name);
        let mut arena = ExprArena::new();
        let error = initialize_wave(&kernel, &launch(), &mut arena).unwrap_err();
        assert!(
            error
                .to_string()
                .contains(&format!("missing .amdhsa_{name}")),
            "{error}"
        );
    }
}

// Test that unsupported launches fail before creating register values.
#[test]
fn rejects_unsupported_launches() {
    let kernel = kernel();
    for (workgroup_size, wave_index) in [
        ((0, 1, 1), 0),
        ((64, 0, 1), 0),
        ((64, 1, 0), 0),
        // Only full 64-thread waves are supported.
        ((63, 1, 1), 0),
        ((5, 13, 1), 0),
        // Reject totals above 1024 and dimensions whose product would overflow.
        ((64, 2, 9), 0),
        ((u32::MAX, u32::MAX, 1), 0),
        ((64, 1, u32::MAX), 0),
        ((8, 8, 1), 1),
        ((4, 8, 4), u32::MAX),
    ] {
        let launch = WaveLaunch {
            workgroup_size,
            wave_index,
            ..launch()
        };
        let mut arena = ExprArena::new();
        let nodes = arena.node_count();
        assert!(matches!(
            initialize_wave(&kernel, &launch, &mut arena),
            Err(EvalError::Launch { .. })
        ));
        assert_eq!(arena.node_count(), nodes);
    }

    let mut other_target = kernel;
    other_target.target = "amdgcn-amd-amdhsa--gfx942".into();
    let mut arena = ExprArena::new();
    assert!(matches!(
        initialize_wave(&other_target, &launch(), &mut arena),
        Err(EvalError::Launch { .. })
    ));
}

// Test that a misaligned kernel argument buffer is rejected.
#[test]
fn rejects_misaligned_kernarg_address() {
    let launch = WaveLaunch {
        kernarg_address: launch().kernarg_address + 8,
        ..launch()
    };
    let mut arena = ExprArena::new();
    assert_eq!(
        initialize_wave(&kernel(), &launch, &mut arena).unwrap_err(),
        EvalError::Launch {
            message: "kernarg address must be 16-byte aligned".into()
        }
    );
}
