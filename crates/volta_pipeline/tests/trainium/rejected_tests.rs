//! NKI kernels the analysis must reject: tile placements, access patterns, broadcasts and
//! gathers it does not define, each with its expected lowering or execution error.

use crate::common;

use volta_trainium_analysis::frontend::ast::{Operand, Statement, TensorName};
use volta_trainium_analysis::frontend::parse::{
    Constant, KernelCall, parse_kernel, parse_kernel_for_call,
};
use volta_trainium_analysis::{
    EvalError, Index, InstrId, LowerError, PatternProblem, StatementError, evaluate, lower_kernel,
};

/// Run `kernel` of `placement_errors.py` through lowering, for a call with `shapes`.
fn lowered_placement_error(
    kernel: &str,
    shapes: &[(&str, &[u64])],
) -> Result<volta_trainium_analysis::LoweredKernel, LowerError> {
    let parsed = parse_kernel(
        &common::trainium::source("execution_error/placement_errors"),
        kernel,
        shapes,
    )
    .unwrap();
    lower_kernel(&parsed)
}
#[test]
fn reading_bytes_another_placed_tile_wrote_is_an_error() {
    let lowered = lowered_placement_error("clobbered_read", &[("a", &[2, 1])]).unwrap();
    assert_eq!(
        evaluate(&lowered).unwrap_err(),
        EvalError::ClobberedRead {
            instr: InstrId(4),
            tensor: "acc".into(),
            index: Index(vec![0, 1]),
            by: InstrId(1),
            through: "half".into(),
        }
    );
}
#[test]
fn accumulating_into_unwritten_psum_is_an_error() {
    let shapes: [(&str, &[u64]); 2] = [("a_t", &[4, 2]), ("b", &[4, 3])];
    let lowered = lowered_placement_error("accumulate_uninitialized", &shapes).unwrap();
    assert_eq!(
        evaluate(&lowered).unwrap_err(),
        EvalError::UninitializedRead {
            instr: InstrId(2),
            tensor: "acc".into(),
            index: Index(vec![0, 0]),
        }
    );
}
#[test]
fn placing_some_tiles_but_not_others_is_an_error() {
    assert_eq!(
        lowered_placement_error("mixed_allocation", &[("a", &[2, 4])]).unwrap_err(),
        LowerError::MixedAllocation {
            placed: TensorName("x".into()),
            unplaced: TensorName("y".into()),
        }
    );
}
#[test]
fn a_placed_tile_past_the_end_of_its_buffer_is_an_error() {
    let error = parse_kernel(
        &common::trainium::source("execution_error/placement_errors"),
        "overflowing_psum",
        &[("a", &[2, 4])],
    )
    .unwrap_err();
    assert!(
        error.to_string().contains("does not fit in `nl.psum`"),
        "{error}"
    );
}
// The parser checks `nl.broadcast_to`'s shape, so the lowering's check is reached by
// widening the parsed copy's source to a shape `row` does not broadcast to.
#[test]
fn broadcasting_to_an_incompatible_shape_is_an_error() {
    let source = common::trainium::source("success/scan");
    let shapes: [(&str, &[u64]); 3] = [("a", &[2, 3]), ("b", &[1, 3]), ("c", &[2, 1])];
    let mut parsed = parse_kernel(&source, "kernel", &shapes).unwrap();
    let mut widened = 0;
    for statement in &mut parsed.body {
        if let Statement::Instruction(instruction) = statement {
            for operand in instruction.operands.values_mut() {
                if let Operand::Broadcast { shape, .. } = operand {
                    *shape = vec![2, 4];
                    widened += 1;
                }
            }
        }
    }
    assert_eq!(widened, 1);
    match lower_kernel(&parsed).unwrap_err() {
        LowerError::Statement {
            error: StatementError::BroadcastShape { tensor, .. },
            ..
        } => assert_eq!(tensor, TensorName("row".into())),
        other => panic!("expected a broadcast shape error, got {other}"),
    }
}
/// The error lowering `kernel` of `pattern_errors.py` gives, for `a` of `shape`.
fn pattern_error(kernel: &str, shape: &[u64]) -> StatementError {
    let source = common::trainium::source("execution_error/pattern_errors");
    let parsed = parse_kernel(&source, kernel, &[("a", shape)]).unwrap();
    match lower_kernel(&parsed).unwrap_err() {
        LowerError::Statement { error, .. } => error,
        other => panic!("{kernel}: expected a statement error, got {other}"),
    }
}
#[test]
fn access_patterns_outside_their_tensor_or_partition_are_errors() {
    let cases = [
        ("partition_step", PatternProblem::PartitionStep { free: 6 }),
        (
            "crossing_partitions",
            PatternProblem::CrossesPartition { free: 6 },
        ),
        ("out_of_bounds", PatternProblem::OutOfBounds),
    ];
    for (kernel, problem) in cases {
        let tensor = if kernel == "out_of_bounds" { "a" } else { "t" };
        assert_eq!(
            pattern_error(kernel, &[2, 6]),
            StatementError::AccessPattern {
                tensor: TensorName(tensor.into()),
                problem,
            },
            "{kernel}"
        );
    }
}
#[test]
fn reducing_other_than_trailing_axes_is_an_error() {
    assert!(matches!(
        pattern_error("leading_axis", &[2, 3, 2]),
        StatementError::UnsupportedAxis(_)
    ));
}
/// Run kernel `kernel` of `indirect_errors.py` for `call` through lowering.
fn lowered_indirect_error(
    kernel: &str,
    call: &KernelCall,
) -> Result<volta_trainium_analysis::LoweredKernel, LowerError> {
    let source = common::trainium::source("execution_error/indirect_errors");
    let parsed = parse_kernel_for_call(&source, &[], kernel, call).unwrap();
    lower_kernel(&parsed)
}
/// The error running `two_groups` gives with `first` and `second` as its groups' offsets.
fn two_groups_error(contents: &[(&str, &[u64])]) -> EvalError {
    let shapes: [(&str, &[u64]); 3] = [("a", &[32, 4]), ("first", &[16, 1]), ("second", &[16, 1])];
    let call = KernelCall {
        contents,
        ..KernelCall::new(&shapes)
    };
    evaluate(&lowered_indirect_error("two_groups", &call).unwrap()).unwrap_err()
}
// The docs read offset `i` from `index[i % 16, i // 16]`, the sample from the rows of
// each partition's 16-partition group; a gather is defined only where they agree.
#[test]
fn a_gather_whose_partition_groups_read_other_offsets_is_an_error() {
    let mut second = [0; 16];
    second[1] = 2;
    let first: [u64; 16] = std::array::from_fn(|row| row as u64 % 4);
    assert_eq!(
        two_groups_error(&[("first", &first), ("second", &second)]),
        EvalError::IndirectReadings {
            instr: InstrId(3),
            partition: 16,
            column: 1,
            offsets: [1, 2],
        }
    );
}
#[test]
fn a_gather_offset_outside_its_data_or_not_concrete_is_an_error() {
    let mut beyond = [0; 16];
    beyond[0] = 4;
    let expected = EvalError::IndirectOffset {
        instr: InstrId(3),
        tensor: "offsets".into(),
        index: Index(vec![0, 0]),
        extent: 4,
    };
    assert_eq!(
        two_groups_error(&[("first", &beyond), ("second", &beyond)]),
        expected
    );
    assert_eq!(two_groups_error(&[]), expected);
}
#[test]
fn contents_not_matching_their_tensor_are_an_error() {
    let source = common::trainium::source("execution_error/indirect_errors");
    let shapes: [(&str, &[u64]); 2] = [("a", &[16, 4]), ("idx", &[16, 1])];
    for (contents, message) in [
        (
            &[("idx", &[0u64; 15][..])][..],
            "gives 15 elements for `idx`",
        ),
        (
            &[("a", &[0u64; 64][..]), ("a", &[0u64; 64][..])][..],
            "given twice",
        ),
        (&[("out", &[0u64; 1][..])][..], "not a tensor parameter"),
    ] {
        let call = KernelCall {
            contents,
            ..KernelCall::new(&shapes)
        };
        let error = parse_kernel_for_call(&source, &[], "on_gpsimd", &call).unwrap_err();
        assert!(error.to_string().contains(message), "{error}");
    }
}
/// The statement error lowering `gather` gives for `a` and `idx` of `shapes`, `count` columns.
fn gather_error(shapes: [(&str, &[u64]); 2], count: i64) -> StatementError {
    let call = KernelCall {
        constants: &[("count", Constant::Int(count))],
        ..KernelCall::new(&shapes)
    };
    match lowered_indirect_error("gather", &call).unwrap_err() {
        LowerError::Statement { error, .. } => error,
        other => panic!("expected a statement error, got {other}"),
    }
}
#[test]
fn gathers_the_docs_do_not_define_are_errors() {
    let shapes: [(&str, &[u64]); 2] = [("a", &[16, 4]), ("idx", &[16, 1])];
    let statement_error =
        |kernel| match lowered_indirect_error(kernel, &KernelCall::new(&shapes)).unwrap_err() {
            LowerError::Statement { error, .. } => error,
            other => panic!("{kernel}: expected a statement error, got {other}"),
        };
    assert_eq!(
        statement_error("on_gpsimd"),
        StatementError::IndirectEngine(Operand::Member("nki.isa.engine.gpsimd".into()))
    );
    assert_eq!(
        statement_error("scatter"),
        StatementError::IndirectOperand { keyword: "dst" }
    );
    assert_eq!(
        gather_error(shapes, 17),
        StatementError::IndirectCount {
            count: 17,
            capacity: 16
        }
    );
    assert_eq!(
        gather_error([("a", &[8, 4]), ("idx", &[8, 1])], 2),
        StatementError::IndirectPartitions(8)
    );
    assert_eq!(
        gather_error([("a", &[16, 4]), ("idx", &[32, 1])], 2),
        StatementError::IndirectIndex {
            tensor: TensorName("offsets".into()),
            shape: volta_trainium_analysis::Shape(vec![32, 1]),
            partitions: 16,
        }
    );
}
