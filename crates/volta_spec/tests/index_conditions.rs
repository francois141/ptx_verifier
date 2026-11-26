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
