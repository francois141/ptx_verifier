//! `let(name, value, body)`: the value is built once, so every read of `name` is one node.

use std::collections::HashMap;

use volta_expr::symbolic_full::ExprNode;
use volta_spec::extract_expressions_from_spec;

#[test]
fn a_let_value_is_one_node_however_often_it_is_read() {
    let source = "dim N; array x[N]; array out[N]; out[i] = let(t, x[i] + 1, t * t);";
    let dims = HashMap::from([("N".to_string(), 2)]);
    let outputs = extract_expressions_from_spec(source, &dims).expect("the spec unfolds");
    for (_, root) in &outputs.outputs[0].1 {
        let ExprNode::Mul(a, b) = *outputs.arena.node(*root) else {
            panic!("out is t * t");
        };
        assert_eq!(a, b);
        assert!(matches!(outputs.arena.node(a), ExprNode::Add(..)));
    }
}
