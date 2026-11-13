//! Expressions printed as text, bounded for heavily shared DAGs.

use std::fmt;

use super::node::{ExprArena, ExprId, ExprNode};

impl ExprArena {
    /// Format an expression to the given formatter, using a stacker guard
    /// to handle deep recursion.
    pub fn fmt_expr(&self, id: ExprId, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        stacker::maybe_grow(64 * 1024, 8 * 1024 * 1024, || self.fmt_expr_inner(id, f))
    }

    fn fmt_expr_inner(&self, id: ExprId, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.node(id) {
            ExprNode::IntConst(v) => write!(f, "{}", v),
            ExprNode::RealConst(v) => write!(f, "{}", v),
            ExprNode::BoolConst(b) => write!(f, "{}", b),
            ExprNode::Symbol(sid) => write!(f, "{}", sid),
            ExprNode::ParamSymbol(sid) => write!(f, "{}", self.string(*sid)),
            ExprNode::InputElement { array, index } => {
                write!(f, "{}[{}]", self.string(*array), index)
            }
            ExprNode::Add(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " + ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Sub(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " - ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Mul(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " * ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Div(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " / ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Rem(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " % ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Neg(a) => {
                write!(f, "(-")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Exp(a) => {
                write!(f, "exp(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Log(a) => {
                write!(f, "log(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Sqrt(a) => {
                write!(f, "sqrt(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Rcp(a) => {
                write!(f, "rcp(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Max(a, b) => {
                write!(f, "max(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Min(a, b) => {
                write!(f, "min(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Abs(a) => {
                write!(f, "abs(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Sign(a) => {
                write!(f, "sign(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Erf(a) => {
                write!(f, "erf(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::RoundEven(a) => {
                write!(f, "rint(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Trunc(a) => {
                write!(f, "trunc(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::BitAnd(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " & ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::BitOr(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " | ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::BitXor(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " ^ ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::BitNot(a) => {
                write!(f, "(~")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Shl(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " << ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Shr(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " >> ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::LShr(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " >>> ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Eq(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " == ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Ne(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " != ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Lt(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " < ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Le(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " <= ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Gt(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " > ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Ge(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " >= ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::And(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " && ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Or(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " || ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Not(a) => {
                write!(f, "(!")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Select(c, t, e) => {
                write!(f, "(")?;
                self.fmt_expr(*c, f)?;
                write!(f, " ? ")?;
                self.fmt_expr(*t, f)?;
                write!(f, " : ")?;
                self.fmt_expr(*e, f)?;
                write!(f, ")")
            }
            ExprNode::ToFloat(a) => {
                write!(f, "float(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Fma(a, b, c) => {
                write!(f, "fma(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*c, f)?;
                write!(f, ")")
            }
            ExprNode::SymbolicRead { array, index } => {
                write!(f, "{}[", self.string(*array))?;
                self.fmt_expr(*index, f)?;
                write!(f, "]")
            }
            ExprNode::Discarded => write!(f, "discarded"),
            ExprNode::Undefined => write!(f, "undefined"),
        }
    }

    /// Format an expression to a `String`. `fmt_expr` re-walks shared subexpressions (no memo), so
    /// heavily shared DAGs can print exponentially large text (multi-GB for tensor-core chains);
    /// past `MAX_DISPLAY_BYTES` this returns a short placeholder instead.
    pub fn display_expr(&self, id: ExprId) -> String {
        const MAX_DISPLAY_BYTES: usize = 50 * 1024 * 1024;

        match self.display_bounded(id, MAX_DISPLAY_BYTES) {
            Ok(text) => text,
            Err(_) => format!(
                "<expression exceeds {}MB when printed - likely heavy internal \
                 sharing in this unmemoized display path; pass --print-outputs 0 \
                 to skip printing, or use 'volta verify'/'volta compare', which \
                 check equivalence without ever formatting raw expressions>",
                MAX_DISPLAY_BYTES / (1024 * 1024)
            ),
        }
    }

    /// At most the first `max_bytes` of the expression's text, ending in `…` when cut: unlike
    /// [`Self::display_expr`], a cut costs only the bytes kept.
    pub fn display_expr_prefix(&self, id: ExprId, max_bytes: usize) -> String {
        match self.display_bounded(id, max_bytes) {
            Ok(text) => text,
            Err(mut prefix) => {
                prefix.push('…');
                prefix
            }
        }
    }

    /// The expression's text, or the prefix that fit in `max_bytes` (cut at a char boundary).
    fn display_bounded(&self, id: ExprId, max_bytes: usize) -> Result<String, String> {
        use std::fmt::Write;

        struct ExprDisplay<'a> {
            arena: &'a ExprArena,
            id: ExprId,
        }
        impl fmt::Display for ExprDisplay<'_> {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                self.arena.fmt_expr(self.id, f)
            }
        }

        // A byte-budgeted `fmt::Write` sink: exceeding the budget mid-traversal
        // short-circuits `fmt_expr`'s whole walk via `?`, never materializing the full string.
        struct LimitedWriter {
            buf: String,
            remaining: usize,
        }
        impl fmt::Write for LimitedWriter {
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

        let mut writer = LimitedWriter {
            buf: String::new(),
            remaining: max_bytes,
        };
        match write!(writer, "{}", ExprDisplay { arena: self, id }) {
            Ok(()) => Ok(writer.buf),
            Err(_) => Err(writer.buf),
        }
    }
}
