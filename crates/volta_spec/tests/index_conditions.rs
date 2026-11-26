//! `where` on index values is decided while unfolding: only the taken branch is built, so the
//! other may read past an array, as a partial rotation's partner does.

use std::collections::HashMap;

use volta_expr::symbolic_full::ExprNode;
use volta_spec::extract_expressions_from_spec;

#[test]
fn an_index_condition_builds_only_its_taken_branch() {
    // out[i] reads x[i + 2] only for i < 2; for i = 2, 3 that read would be past x.
    let source = "dim N; array x[N]; array out[N]; out[i] = where(i < 2, x[i + 2], x[i]);";
    let dims = HashMap::from([("N".to_string(), 4)]);
    let outputs = extract_expressions_from_spec(source, &dims).expect("the spec unfolds");
    for (index, root) in &outputs.outputs[0].1 {
        let ExprNode::InputElement { index: read, .. } = *outputs.arena.node(*root) else {
            panic!("out[{index}] is one element of x, not a select");
        };
        assert_eq!(read, if *index < 2 { index + 2 } else { *index });
    }
}

#[test]
fn unwritten_elements_leave_the_footprint() {
    let source = "dim N; array x[N]; array out[N]; out[i] = where(i < 2, x[i], unwritten);";
    let parsed = volta_spec::parse_spec(source).expect("parses");
    let dims = HashMap::from([("N".to_string(), 4)]);
    let (env, outputs) = volta_spec::instantiate(&parsed, &dims).expect("instantiates");
    let footprint = volta_spec::footprint(&outputs, &env).expect("decided");
    assert_eq!(footprint, vec![("out".to_string(), vec![0, 1])]);
    let unfolded = volta_spec::unfold(&outputs, &env, 0).expect("unfolds");
    let indices: Vec<u64> = unfolded.outputs[0].1.iter().map(|&(i, _)| i).collect();
    assert_eq!(indices, vec![0, 1]);
}

#[test]
fn unwritten_inside_an_expression_is_an_error() {
    let source = "dim N; array x[N]; array out[N]; out[i] = x[i] + unwritten;";
    let dims = HashMap::from([("N".to_string(), 2)]);
    let error = extract_expressions_from_spec(source, &dims).expect_err("unwritten is no value");
    assert!(
        format!("{error:?}").contains("UnwrittenInExpression"),
        "{error:?}"
    );
}
