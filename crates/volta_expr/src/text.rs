//! The `.vexpr` text format for [`SymbolicOutputs`]: one numbered node per
//! line, children first (sharing preserved), then `out "array" index nK`
//! lines. Reading rebuilds nodes exactly as written, with no constant folding.

use std::collections::HashMap;
use std::fmt;
use std::io::{self, Write};

use id_collections::Id;

use crate::outputs::SymbolicOutputs;
use crate::symbolic::{ExprArena, ExprId, ExprNode, Real, RealRepr, StringId, SymbolId};

const HEADER: &str = "volta-expr 1";

/// A malformed `.vexpr` input, located by 1-based line number.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TextError {
    pub line: usize,
    pub message: String,
}

impl fmt::Display for TextError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "line {}: {}", self.line, self.message)
    }
}

impl std::error::Error for TextError {}

type Unary = fn(ExprId) -> ExprNode;
type Binary = fn(ExprId, ExprId) -> ExprNode;
type Ternary = fn(ExprId, ExprId, ExprId) -> ExprNode;

const UNARY: &[(&str, Unary)] = &[
    ("neg", ExprNode::Neg),
    ("exp", ExprNode::Exp),
    ("log", ExprNode::Log),
    ("sqrt", ExprNode::Sqrt),
    ("rcp", ExprNode::Rcp),
    ("abs", ExprNode::Abs),
    ("sign", ExprNode::Sign),
    ("bitnot", ExprNode::BitNot),
    ("not", ExprNode::Not),
    ("tofloat", ExprNode::ToFloat),
];

const BINARY: &[(&str, Binary)] = &[
    ("add", ExprNode::Add),
    ("sub", ExprNode::Sub),
    ("mul", ExprNode::Mul),
    ("div", ExprNode::Div),
    ("rem", ExprNode::Rem),
    ("max", ExprNode::Max),
    ("min", ExprNode::Min),
    ("bitand", ExprNode::BitAnd),
    ("bitor", ExprNode::BitOr),
    ("bitxor", ExprNode::BitXor),
    ("shl", ExprNode::Shl),
    ("shr", ExprNode::Shr),
    ("lshr", ExprNode::LShr),
    ("eq", ExprNode::Eq),
    ("ne", ExprNode::Ne),
    ("lt", ExprNode::Lt),
    ("le", ExprNode::Le),
    ("gt", ExprNode::Gt),
    ("ge", ExprNode::Ge),
    ("and", ExprNode::And),
    ("or", ExprNode::Or),
];

const TERNARY: &[(&str, Ternary)] = &[("select", ExprNode::Select), ("fma", ExprNode::Fma)];

/// The operation name and operands a node is written with. Exhaustive over
/// `ExprNode`, so a new variant cannot be added without a text form.
fn spell(node: &ExprNode) -> (&'static str, Vec<Operand>) {
    use ExprNode::*;
    use Operand::{Child, Name, Raw};
    match node {
        IntConst(v) => ("int", vec![Raw(v.to_string())]),
        RealConst(r) => ("real", vec![Raw(real_literal(r))]),
        BoolConst(b) => ("bool", vec![Raw(b.to_string())]),
        Symbol(s) => ("sym", vec![Raw(s.0.to_string())]),
        ParamSymbol(s) => ("param", vec![Name(*s)]),
        InputElement { array, index } => ("elem", vec![Name(*array), Raw(index.to_string())]),
        SymbolicRead { array, index } => ("read", vec![Name(*array), Child(*index)]),
        Discarded => ("discarded", vec![]),
        Undefined => ("undefined", vec![]),
        Neg(a) => ("neg", vec![Child(*a)]),
        Exp(a) => ("exp", vec![Child(*a)]),
        Log(a) => ("log", vec![Child(*a)]),
        Sqrt(a) => ("sqrt", vec![Child(*a)]),
        Rcp(a) => ("rcp", vec![Child(*a)]),
        Abs(a) => ("abs", vec![Child(*a)]),
        Sign(a) => ("sign", vec![Child(*a)]),
        BitNot(a) => ("bitnot", vec![Child(*a)]),
        Not(a) => ("not", vec![Child(*a)]),
        ToFloat(a) => ("tofloat", vec![Child(*a)]),
        Add(a, b) => ("add", vec![Child(*a), Child(*b)]),
        Sub(a, b) => ("sub", vec![Child(*a), Child(*b)]),
        Mul(a, b) => ("mul", vec![Child(*a), Child(*b)]),
        Div(a, b) => ("div", vec![Child(*a), Child(*b)]),
        Rem(a, b) => ("rem", vec![Child(*a), Child(*b)]),
        Max(a, b) => ("max", vec![Child(*a), Child(*b)]),
        Min(a, b) => ("min", vec![Child(*a), Child(*b)]),
        BitAnd(a, b) => ("bitand", vec![Child(*a), Child(*b)]),
        BitOr(a, b) => ("bitor", vec![Child(*a), Child(*b)]),
        BitXor(a, b) => ("bitxor", vec![Child(*a), Child(*b)]),
        Shl(a, b) => ("shl", vec![Child(*a), Child(*b)]),
        Shr(a, b) => ("shr", vec![Child(*a), Child(*b)]),
        LShr(a, b) => ("lshr", vec![Child(*a), Child(*b)]),
        Eq(a, b) => ("eq", vec![Child(*a), Child(*b)]),
        Ne(a, b) => ("ne", vec![Child(*a), Child(*b)]),
        Lt(a, b) => ("lt", vec![Child(*a), Child(*b)]),
        Le(a, b) => ("le", vec![Child(*a), Child(*b)]),
        Gt(a, b) => ("gt", vec![Child(*a), Child(*b)]),
        Ge(a, b) => ("ge", vec![Child(*a), Child(*b)]),
        And(a, b) => ("and", vec![Child(*a), Child(*b)]),
        Or(a, b) => ("or", vec![Child(*a), Child(*b)]),
        Select(c, t, e) => ("select", vec![Child(*c), Child(*t), Child(*e)]),
        Fma(a, b, c) => ("fma", vec![Child(*a), Child(*b), Child(*c)]),
    }
}

enum Operand {
    Child(ExprId),
    Name(StringId),
    Raw(String),
}

/// Exact: `p/q` (or `p`) for rationals, never a rounded decimal.
fn real_literal(r: &Real) -> String {
    match r.repr() {
        RealRepr::NegInf => "-inf".to_string(),
        RealRepr::PosInf => "inf".to_string(),
        RealRepr::Rational(q) => q.to_string(),
    }
}

fn quote(name: &str) -> String {
    let mut out = String::with_capacity(name.len() + 2);
    out.push('"');
    for c in name.chars() {
        if c == '"' || c == '\\' {
            out.push('\\');
        }
        out.push(c);
    }
    out.push('"');
    out
}

/// Write `exprs` as `.vexpr` text: the nodes reachable from its outputs, in
/// arena order (which is already children-before-parents), renumbered densely.
pub fn write_text(out: &mut impl Write, exprs: &SymbolicOutputs) -> io::Result<()> {
    let arena = &exprs.arena;
    let mut reachable = vec![false; arena.node_count()];
    let mut stack: Vec<ExprId> = exprs
        .outputs
        .iter()
        .flat_map(|(_, elems)| elems.iter().map(|&(_, root)| root))
        .collect();
    while let Some(id) = stack.pop() {
        let slot = &mut reachable[id.to_index() as usize];
        if !*slot {
            *slot = true;
            arena.node(id).for_each_child(|c| stack.push(c));
        }
    }

    writeln!(out, "{HEADER}")?;
    let mut renumbered: Vec<Option<usize>> = vec![None; arena.node_count()];
    let live = reachable.iter().enumerate().filter(|&(_, &r)| r);
    for (next, (index, _)) in live.enumerate() {
        let (op, operands) = spell(arena.node(ExprId(index as u32)));
        write!(out, "n{next} = {op}")?;
        for operand in operands {
            match operand {
                Operand::Child(c) => {
                    let n = renumbered[c.to_index() as usize]
                        .expect("arena order puts children before parents");
                    write!(out, " n{n}")?;
                }
                Operand::Name(s) => write!(out, " {}", quote(arena.string(s)))?,
                Operand::Raw(text) => write!(out, " {text}")?,
            }
        }
        writeln!(out)?;
        renumbered[index] = Some(next);
    }
    for (array, elems) in &exprs.outputs {
        for &(index, root) in elems {
            let n = renumbered[root.to_index() as usize].expect("roots are reachable");
            writeln!(out, "out {} {index} n{n}", quote(array))?;
        }
    }
    Ok(())
}

/// `write_text` into a `String`.
pub fn to_text(exprs: &SymbolicOutputs) -> String {
    let mut bytes = Vec::new();
    write_text(&mut bytes, exprs).expect("writing to a Vec cannot fail");
    String::from_utf8(bytes).expect("the writer emits UTF-8")
}

/// Parse `.vexpr` text. Blank lines and `#` comments are ignored; the result
/// is validated, and each array's elements must be listed in ascending order.
pub fn read_text(src: &str) -> Result<SymbolicOutputs, TextError> {
    let mut reader = Reader {
        arena: ExprArena::new(),
        strings: HashMap::new(),
        outputs: Vec::new(),
        line: 0,
    };
    let mut saw_header = false;
    for (number, raw) in src.lines().enumerate() {
        reader.line = number + 1;
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        if !saw_header {
            if line != HEADER {
                return Err(reader.error(format!("expected header `{HEADER}`, found `{line}`")));
            }
            saw_header = true;
            continue;
        }
        let tokens = tokenize(line).map_err(|m| reader.error(m))?;
        reader.statement(&tokens)?;
    }
    if !saw_header {
        return Err(TextError {
            line: 0,
            message: format!("empty input (missing header `{HEADER}`)"),
        });
    }
    let exprs = SymbolicOutputs {
        arena: reader.arena,
        outputs: reader.outputs,
    };
    exprs
        .validate()
        .map_err(|message| TextError { line: 0, message })?;
    Ok(exprs)
}

#[derive(Debug, PartialEq)]
enum Token {
    Word(String),
    Quoted(String),
}

fn tokenize(line: &str) -> Result<Vec<Token>, String> {
    let mut tokens = Vec::new();
    let mut chars = line.chars().peekable();
    while let Some(&c) = chars.peek() {
        if c.is_whitespace() {
            chars.next();
        } else if c == '"' {
            chars.next();
            let mut text = String::new();
            loop {
                match chars.next() {
                    Some('"') => break,
                    Some('\\') => text.push(chars.next().ok_or("unterminated escape")?),
                    Some(c) => text.push(c),
                    None => return Err("unterminated string".to_string()),
                }
            }
            tokens.push(Token::Quoted(text));
        } else {
            let mut word = String::new();
            while let Some(&c) = chars.peek() {
                if c.is_whitespace() || c == '"' {
                    break;
                }
                word.push(c);
                chars.next();
            }
            tokens.push(Token::Word(word));
        }
    }
    Ok(tokens)
}

struct Reader {
    arena: ExprArena,
    strings: HashMap<String, StringId>,
    outputs: Vec<(String, Vec<(u64, ExprId)>)>,
    line: usize,
}

impl Reader {
    fn error(&self, message: impl Into<String>) -> TextError {
        TextError {
            line: self.line,
            message: message.into(),
        }
    }

    fn statement(&mut self, tokens: &[Token]) -> Result<(), TextError> {
        match tokens {
            [
                Token::Word(kw),
                Token::Quoted(array),
                Token::Word(index),
                Token::Word(root),
            ] if kw == "out" => {
                let index = self.number(index)?;
                let root = self.child(root)?;
                self.output(array, index, root)
            }
            [
                Token::Word(id),
                Token::Word(eq),
                Token::Word(op),
                operands @ ..,
            ] if eq == "=" => {
                let expected = format!("n{}", self.arena.node_count());
                if *id != expected {
                    return Err(self.error(format!("expected node `{expected}`, found `{id}`")));
                }
                let node = self.node(op, operands)?;
                self.arena.push(node);
                Ok(())
            }
            _ => Err(self.error("expected `nK = op operands...` or `out \"array\" index nK`")),
        }
    }

    fn output(&mut self, array: &str, index: u64, root: ExprId) -> Result<(), TextError> {
        let slot = match self.outputs.iter().position(|(name, _)| name == array) {
            Some(slot) => slot,
            None => {
                self.outputs.push((array.to_string(), Vec::new()));
                self.outputs.len() - 1
            }
        };
        let elems = &mut self.outputs[slot].1;
        if elems.last().is_some_and(|&(last, _)| last >= index) {
            return Err(self.error(format!(
                "`{array}` elements must be listed in strictly ascending index order"
            )));
        }
        elems.push((index, root));
        Ok(())
    }

    fn node(&mut self, op: &str, operands: &[Token]) -> Result<ExprNode, TextError> {
        let arity_error = |r: &Self| r.error(format!("wrong operands for `{op}`"));
        let node = match (op, operands) {
            ("int", [Token::Word(v)]) => ExprNode::IntConst(self.parse(v)?),
            ("real", [Token::Word(v)]) => ExprNode::RealConst(self.real(v)?),
            ("bool", [Token::Word(v)]) => ExprNode::BoolConst(self.parse(v)?),
            ("sym", [Token::Word(v)]) => ExprNode::Symbol(SymbolId(self.parse(v)?)),
            ("param", [Token::Quoted(name)]) => ExprNode::ParamSymbol(self.intern(name)),
            ("elem", [Token::Quoted(array), Token::Word(index)]) => ExprNode::InputElement {
                array: self.intern(array),
                index: self.number(index)?,
            },
            ("read", [Token::Quoted(array), Token::Word(index)]) => ExprNode::SymbolicRead {
                array: self.intern(array),
                index: self.child(index)?,
            },
            ("discarded", []) => ExprNode::Discarded,
            ("undefined", []) => ExprNode::Undefined,
            _ => {
                let children = operands
                    .iter()
                    .map(|t| match t {
                        Token::Word(w) => self.child(w),
                        Token::Quoted(_) => Err(arity_error(self)),
                    })
                    .collect::<Result<Vec<_>, _>>()?;
                let unary = UNARY.iter().find(|(n, _)| *n == op).map(|e| e.1);
                let binary = BINARY.iter().find(|(n, _)| *n == op).map(|e| e.1);
                let ternary = TERNARY.iter().find(|(n, _)| *n == op).map(|e| e.1);
                match (children.as_slice(), unary, binary, ternary) {
                    (&[a], Some(f), _, _) => f(a),
                    (&[a, b], _, Some(f), _) => f(a, b),
                    (&[a, b, c], _, _, Some(f)) => f(a, b, c),
                    (_, None, None, None) => {
                        return Err(self.error(format!("unknown operation `{op}`")));
                    }
                    _ => return Err(arity_error(self)),
                }
            }
        };
        Ok(node)
    }

    fn intern(&mut self, name: &str) -> StringId {
        if let Some(&id) = self.strings.get(name) {
            return id;
        }
        let id = self.arena.intern_string(name);
        self.strings.insert(name.to_string(), id);
        id
    }

    fn child(&self, word: &str) -> Result<ExprId, TextError> {
        let index: u32 = word
            .strip_prefix('n')
            .and_then(|n| n.parse().ok())
            .ok_or_else(|| self.error(format!("expected a node reference `nK`, found `{word}`")))?;
        if index as usize >= self.arena.node_count() {
            return Err(self.error(format!("`{word}` is not defined yet")));
        }
        Ok(ExprId(index))
    }

    fn number(&self, word: &str) -> Result<u64, TextError> {
        self.parse(word)
    }

    fn parse<T: std::str::FromStr>(&self, word: &str) -> Result<T, TextError> {
        word.parse()
            .map_err(|_| self.error(format!("invalid literal `{word}`")))
    }

    fn real(&self, word: &str) -> Result<Real, TextError> {
        let infinity = |v: f64| Real::from_f64(v).expect("infinities are not NaN");
        match word {
            "inf" => Ok(infinity(f64::INFINITY)),
            "-inf" => Ok(infinity(f64::NEG_INFINITY)),
            _ => Ok(Real::from_rational(self.parse::<rug::Rational>(word)?)),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A node's operation and operands with names resolved, so nodes from
    /// two arenas compare independently of string-table order.
    fn spelled(arena: &ExprArena, id: ExprId) -> (&'static str, Vec<String>) {
        let (op, operands) = spell(arena.node(id));
        let operands = operands
            .into_iter()
            .map(|operand| match operand {
                Operand::Child(c) => format!("n{}", c.0),
                Operand::Name(s) => quote(arena.string(s)),
                Operand::Raw(text) => text,
            })
            .collect();
        (op, operands)
    }

    /// One node of every `ExprNode` kind, each one an output element, so the
    /// round trip below covers the whole format.
    fn every_node_kind() -> SymbolicOutputs {
        let mut arena = ExprArena::new();
        let array = arena.intern_string("in \"quoted\" \\ name");
        let param = arena.intern_string("N");
        let third = Real::from_rational(rug::Rational::from((1, 3)));
        let a = arena.push(ExprNode::InputElement { array, index: 7 });
        let b = arena.push(ExprNode::ParamSymbol(param));
        let c = arena.push(ExprNode::IntConst(-5));
        let mut roots = vec![
            a,
            b,
            c,
            arena.push(ExprNode::RealConst(third)),
            arena.push(ExprNode::RealConst(Real::from_f64(f64::INFINITY).unwrap())),
            arena.push(ExprNode::RealConst(
                Real::from_f64(f64::NEG_INFINITY).unwrap(),
            )),
            arena.push(ExprNode::RealConst(
                Real::from_f64(f64::from_bits(1)).unwrap(),
            )),
            arena.push(ExprNode::BoolConst(true)),
            arena.push(ExprNode::Symbol(SymbolId(42))),
            arena.push(ExprNode::SymbolicRead { array, index: c }),
            arena.push(ExprNode::Discarded),
            arena.push(ExprNode::Undefined),
        ];
        for (_, f) in UNARY {
            roots.push(arena.push(f(a)));
        }
        for (_, f) in BINARY {
            roots.push(arena.push(f(a, b)));
        }
        for (_, f) in TERNARY {
            roots.push(arena.push(f(a, b, c)));
        }
        let elems = roots
            .into_iter()
            .enumerate()
            .map(|(i, r)| (i as u64, r))
            .collect();
        SymbolicOutputs {
            arena,
            outputs: vec![("out".to_string(), elems)],
        }
    }

    #[test]
    fn every_node_kind_round_trips_node_for_node() {
        let original = every_node_kind();
        let text = to_text(&original);
        let reread = read_text(&text).unwrap();

        assert_eq!(reread.outputs, original.outputs);
        assert_eq!(reread.arena.node_count(), original.arena.node_count());
        for i in 0..original.arena.node_count() {
            let id = ExprId(i as u32);
            assert_eq!(
                spelled(&reread.arena, id),
                spelled(&original.arena, id),
                "node {i} changed"
            );
        }
        assert_eq!(
            to_text(&reread),
            text,
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
}
