use volta_expr::SymbolicOutputs;
use volta_expr::symbolic::*;
use volta_expr::text::*;

/// One node of every `ExprNode` kind, each one an output element, so its round trip covers the
/// whole format.
const EVERY_NODE_KIND: &str = include_str!("every_node_kind.vexpr");

#[test]
fn every_node_kind_round_trips_node_for_node() {
    let exprs = read_text(EVERY_NODE_KIND).unwrap();
    let nodes = EVERY_NODE_KIND
        .lines()
        .filter(|l| l.starts_with('n'))
        .count();
    assert_eq!(exprs.arena.node_count(), nodes);
    assert_eq!(
        to_text(&exprs),
        EVERY_NODE_KIND,
        "a reread file rewrites byte for byte"
    );
}

#[test]
fn only_nodes_reachable_from_outputs_are_written() {
    let mut arena = ExprArena::new();
    let x = arena.param_symbol("x");
    let _dead = arena.param_symbol("unused");
    let one = arena.int(1);
    let sum = arena.add(x, one);
    let exprs = SymbolicOutputs {
        arena,
        outputs: vec![("out".to_string(), vec![(3, sum)])],
    };
    assert_eq!(
        to_text(&exprs),
        "volta-expr 1\nn0 = param \"x\"\nn1 = int 1\nn2 = add n0 n1\nout \"out\" 3 n2\n"
    );
}

#[test]
fn reals_are_written_exactly() {
    let mut arena = ExprArena::new();
    let third = arena.real(Real::from_rational(rug::Rational::from((-1, 3))));
    let exprs = SymbolicOutputs {
        arena,
        outputs: vec![("out".to_string(), vec![(0, third)])],
    };
    assert!(to_text(&exprs).contains("n0 = real -1/3\n"));
}

#[test]
fn comments_and_blank_lines_are_ignored() {
    let text = "# produced by hand\n\nvolta-expr 1\n  n0 = int 2  \n# done\nout \"o\" 0 n0\n";
    let exprs = read_text(text).unwrap();
    assert_eq!(
        exprs.arena.display_expr(exprs.element("o", 0).unwrap()),
        "2"
    );
}

fn rejects(text: &str, needle: &str) {
    let err = read_text(text).unwrap_err();
    assert!(
        err.to_string().contains(needle),
        "{text:?}: error {err} lacks {needle:?}"
    );
}

#[test]
fn malformed_input_is_rejected_with_its_line() {
    rejects("", "missing header");
    rejects("volta-expr 2\n", "expected header");
    rejects("volta-expr 1\nn1 = int 0\n", "expected node `n0`");
    rejects("volta-expr 1\nn0 = add n0 n0\n", "not defined yet");
    rejects(
        "volta-expr 1\nn0 = frobnicate\n",
        "unknown operation `frobnicate`",
    );
    rejects(
        "volta-expr 1\nn0 = int 1\nn1 = add n0\n",
        "wrong operands for `add`",
    );
    rejects("volta-expr 1\nn0 = int x\n", "invalid literal `x`");
    rejects("volta-expr 1\nn0 = param \"open\n", "unterminated string");
    rejects(
        "volta-expr 1\nn0 = int 1\nout \"o\" 1 n0\nout \"o\" 0 n0\n",
        "line 4: `o` elements must be listed in strictly ascending index order",
    );
    rejects("volta-expr 1\nout \"o\" 0 n0\n", "not defined yet");
}
