//! Expressions printed as text, bounded for heavily shared DAGs.

use std::fmt::{self, Write};

use super::node::{ExprArena, ExprId, ExprNode};

/// How an operation prints around its operands.
enum Notation {
    Infix(&'static str),
    Prefix(&'static str),
    Call(&'static str),
}

fn notation(node: &ExprNode) -> Option<Notation> {
    use ExprNode::*;
    use Notation::*;
    Some(match node {
        Add(..) => Infix("+"),
        Sub(..) => Infix("-"),
        Mul(..) => Infix("*"),
        Div(..) => Infix("/"),
        Rem(..) => Infix("%"),
        BitAnd(..) => Infix("&"),
        BitOr(..) => Infix("|"),
        BitXor(..) => Infix("^"),
        Shl(..) => Infix("<<"),
        Shr(..) => Infix(">>"),
        LShr(..) => Infix(">>>"),
        Eq(..) => Infix("=="),
        Ne(..) => Infix("!="),
        Lt(..) => Infix("<"),
        Le(..) => Infix("<="),
        Gt(..) => Infix(">"),
        Ge(..) => Infix(">="),
        And(..) => Infix("&&"),
        Or(..) => Infix("||"),
        Neg(_) => Prefix("-"),
        BitNot(_) => Prefix("~"),
        Popc(_) => Call("popc"),
        Not(_) => Prefix("!"),
        Exp(_) => Call("exp"),
        Exp2(_) => Call("exp2"),
        Log(_) => Call("log"),
        Log2(_) => Call("log2"),
        Sqrt(_) => Call("sqrt"),
        Rcp(_) => Call("rcp"),
        Erf(_) => Call("erf"),
        Gelu(_) => Call("gelu"),
        Tanh(_) => Call("tanh"),
        Rsqrt(_) => Call("rsqrt"),
        Sigmoid(_) => Call("sigmoid"),
        Median3(..) => Call("med3"),
        Copysign(..) => Call("copysign"),
        Max(..) => Call("max"),
        Min(..) => Call("min"),
        Abs(_) => Call("abs"),
        Sign(_) => Call("sign"),
        RoundEven(_) => Call("rint"),
        Trunc(_) => Call("trunc"),
        Floor(_) => Call("floor"),
        ToFloat(_) => Call("float"),
        Fma(..) => Call("fma"),
        IntConst(_)
        | RealConst(_)
        | BoolConst(_)
        | Symbol(_)
        | ParamSymbol(_)
        | InputElement { .. }
        | Select(..)
        | SymbolicRead { .. }
        | Prmt { .. }
        | Discarded
        | Undefined => {
            return None;
        }
    })
}

impl ExprArena {
    /// Format an expression as built, growing the stack for deep ones.
    pub fn fmt_expr(&self, id: ExprId, f: &mut impl Write) -> fmt::Result {
        stacker::maybe_grow(64 * 1024, 8 * 1024 * 1024, || self.fmt_expr_inner(id, f))
    }

    fn fmt_expr_inner(&self, id: ExprId, f: &mut impl Write) -> fmt::Result {
        let node = self.node(id);
        match node {
            ExprNode::IntConst(v) => return write!(f, "{v}"),
            ExprNode::RealConst(v) => return write!(f, "{v}"),
            ExprNode::BoolConst(b) => return write!(f, "{b}"),
            ExprNode::Symbol(sid) => return write!(f, "{sid}"),
            ExprNode::ParamSymbol(sid) => return write!(f, "{}", self.string(*sid)),
            ExprNode::InputElement { array, index } => {
                return write!(f, "{}[{index}]", self.string(*array));
            }
            ExprNode::Discarded => return write!(f, "discarded"),
            ExprNode::Undefined => return write!(f, "undefined"),
            ExprNode::SymbolicRead { array, index } => {
                write!(f, "{}[", self.string(*array))?;
                self.fmt_expr(*index, f)?;
                return write!(f, "]");
            }
            ExprNode::Prmt { a, b, selector } => {
                write!(f, "prmt(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                return write!(f, ", {:#06x})", selector.0);
            }
            ExprNode::Select(c, t, e) => {
                write!(f, "(")?;
                self.fmt_expr(*c, f)?;
                write!(f, " ? ")?;
                self.fmt_expr(*t, f)?;
                write!(f, " : ")?;
                self.fmt_expr(*e, f)?;
                return write!(f, ")");
            }
            _ => {}
        }

        let mut children = Vec::with_capacity(3);
        node.for_each_child(|c| children.push(c));
        match notation(node).expect("every operation has a notation") {
            Notation::Infix(op) => {
                write!(f, "(")?;
                self.fmt_expr(children[0], f)?;
                write!(f, " {op} ")?;
                self.fmt_expr(children[1], f)?;
                write!(f, ")")
            }
            Notation::Prefix(op) => {
                write!(f, "({op}")?;
                self.fmt_expr(children[0], f)?;
                write!(f, ")")
            }
            Notation::Call(name) => {
                write!(f, "{name}(")?;
                for (position, &child) in children.iter().enumerate() {
                    if position > 0 {
                        write!(f, ", ")?;
                    }
                    self.fmt_expr(child, f)?;
                }
                write!(f, ")")
            }
        }
    }

    /// At most the first `max_bytes` of the expression's text, ending in `…` when cut: shared
    /// subexpressions print once per use, so a cut costs only the bytes kept.
    pub fn display_expr_prefix(&self, id: ExprId, max_bytes: usize) -> String {
        let mut writer = LimitedWriter {
            buf: String::new(),
            remaining: max_bytes,
        };
        if self.fmt_expr(id, &mut writer).is_err() {
            writer.buf.push('…');
        }
        writer.buf
    }

    /// The expression's text, cut at 50 MB.
    pub fn display_expr(&self, id: ExprId) -> String {
        self.display_expr_prefix(id, 50 * 1024 * 1024)
    }
}

/// A byte-budgeted sink: exceeding the budget short-circuits the whole walk.
struct LimitedWriter {
    buf: String,
    remaining: usize,
}

impl Write for LimitedWriter {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        if s.len() > self.remaining {
            let mut cut = self.remaining;
            while !s.is_char_boundary(cut) {
                cut -= 1;
            }
            self.buf.push_str(&s[..cut]);
            self.remaining = 0;
            return Err(fmt::Error);
        }
        self.remaining -= s.len();
        self.buf.push_str(s);
        Ok(())
    }
}
