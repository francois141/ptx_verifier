//! Index arrays: integers the caller gives, read inside subscripts (a gather's offsets).

use std::collections::HashMap;

use volta_expr::{ExprNode, SymbolicOutputs};
use volta_spec::{
    ExtractError, InstantiateErrorKind, SpecError, extract_expressions_from_spec_with_indices,
};

fn extract(
    source: &str,
    dims: &[(&str, u64)],
    indices: &[(&str, &[i64])],
) -> Result<SymbolicOutputs, ExtractError> {
    let dims = dims.iter().map(|&(d, v)| (d.to_string(), v)).collect();
    let indices = indices
        .iter()
        .map(|&(a, v)| (a.to_string(), v.to_vec()))
        .collect::<HashMap<_, _>>();
    extract_expressions_from_spec_with_indices(source, &dims, &indices)
}

/// The input elements each output reads, by offset, in output order.
fn reads(outputs: &SymbolicOutputs) -> Vec<Vec<u64>> {
    fn collect(outputs: &SymbolicOutputs, id: volta_expr::ExprId, out: &mut Vec<u64>) {
        match outputs.arena.node(id) {
            ExprNode::InputElement { index, .. } => out.push(*index),
            ExprNode::Add(a, b) => {
                collect(outputs, *a, out);
                collect(outputs, *b, out);
            }
            _ => {}
        }
    }
    outputs.outputs[0]
        .1
        .iter()
        .map(|&(_, id)| {
            let mut out = Vec::new();
            collect(outputs, id, &mut out);
            out
        })
        .collect()
}

const GATHER: &str = "dim P; dim F; dim K;
array data[P, F]; array index[K] index; array out[P, K];
out[p, i] = data[p, index[i]];";

#[test]
fn a_subscript_reads_an_index_arrays_integers() {
    let outputs = extract(
        GATHER,
        &[("P", 2), ("F", 3), ("K", 2)],
        &[("index", &[2, 0])],
    )
    .unwrap();
    assert_eq!(reads(&outputs), [[2], [0], [5], [3]]);
}

/// The memo keys a reduction on the variables its range reads through an index array.
#[test]
fn a_range_may_end_at_an_index_arrays_integer() {
    let source = "dim N; dim K; array A[N]; array ends[K] index; array out[K];
                  out[i] = sum(k in 0..ends[i], A[k]);";
    let outputs = extract(source, &[("N", 3), ("K", 2)], &[("ends", &[1, 3])]).unwrap();
    assert_eq!(reads(&outputs), [vec![0], vec![0, 1, 2]]);
}

#[test]
fn reads_outside_either_array_are_errors() {
    let dims = [("P", 1), ("F", 3), ("K", 2)];
    let error = extract(GATHER, &dims, &[("index", &[0, 3])]).unwrap_err();
    assert!(
        matches!(&error, ExtractError::Unfold(SpecError::IndexOutOfBounds { array, index, .. })
            if array == "data" && index[..] == [0, 3]),
        "{error}"
    );
    let shifted = GATHER.replace("index[i]", "index[i + 1]");
    let error = extract(&shifted, &dims, &[("index", &[0, 1])]).unwrap_err();
    assert!(
        matches!(&error, ExtractError::Unfold(SpecError::IndexOutOfBounds { array, .. })
            if array == "index"),
        "{error}"
    );
}

#[test]
fn an_index_array_is_read_only_inside_subscripts() {
    let dims = [("P", 1), ("F", 3), ("K", 2)];
    let as_value = GATHER.replace("data[p, index[i]]", "index[i]");
    assert!(matches!(
        extract(&as_value, &dims, &[("index", &[0, 1])]),
        Err(ExtractError::Unfold(SpecError::IndexArrayAsValue(array))) if array == "index"
    ));
    let not_index = GATHER.replace("data[p, index[i]]", "data[p, data[0, i]]");
    assert!(matches!(
        extract(&not_index, &dims, &[("index", &[0, 1])]),
        Err(ExtractError::Unfold(SpecError::NotAnIndexArray(array))) if array == "data"
    ));
    let defined = format!("{GATHER}\nindex[i] = data[0, i];");
    assert!(matches!(
        extract(&defined, &dims, &[("index", &[0, 1])]),
        Err(ExtractError::Instantiate(InstantiateErrorKind::IndexArrayOutput(array)))
            if array == "index"
    ));
}

#[test]
fn an_index_arrays_integers_must_be_given_one_per_element() {
    let dims = [("P", 1), ("F", 3), ("K", 2)];
    let instantiate_error = |indices: &[(&str, &[i64])]| match extract(GATHER, &dims, indices) {
        Err(ExtractError::Instantiate(error)) => error,
        other => panic!("expected an instantiation error, got {other:?}"),
    };
    assert!(matches!(
        instantiate_error(&[]),
        InstantiateErrorKind::MissingIndices(array) if array == "index"
    ));
    assert!(matches!(
        instantiate_error(&[("index", &[0])]),
        InstantiateErrorKind::IndicesLength {
            expected: 2,
            found: 1,
            ..
        }
    ));
    assert!(matches!(
        instantiate_error(&[("index", &[0, 1]), ("data", &[0, 0, 0])]),
        InstantiateErrorKind::NotAnIndexArray(array) if array == "data"
    ));
}
