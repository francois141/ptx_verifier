//! Recursive-descent parser for the spec language.
//!
//! Grammar (ASCII, agreed with the user):
//!
//! ```text
//! spec        := item*
//! item        := dim_decl | array_decl | output_decl
//! dim_decl    := "dim" IDENT ";"
//! array_decl  := "array" IDENT "[" IDENT ("," IDENT)* "]" ";"
//! output_decl := IDENT "[" IDENT ("," IDENT)* "]" "=" expr ";"
//!
//! expr        := add
//! add         := mul (("+" | "-") mul)*
//! mul         := unary (("*" | "/") unary)*
//! unary       := "-" unary | postfix
//! postfix     := IDENT "[" index_expr ("," index_expr)* "]"   ; tensor index
//!              | IDENT "(" args ")"                            ; call or reduction
//!              | IDENT                                         ; bound variable
//!              | NUMBER
//!              | "(" expr ")"
//! args        := reduction | expr ("," expr)*
//! reduction   := IDENT "in" expr ".." expr "," expr            ; sum(k in 0..K, body)
//!                                                               ; max(k in 0..K, body)
//!
//! index_expr  := index_mul (("+") index_mul)*
//! index_mul   := index_primary (("*") index_primary)*
//! index_primary := IDENT | NUMBER | "(" index_expr ")"
//! ```
//!
//! `index_expr` is deliberately the small affine sublanguage
//! `volta_analysis::spec::IndexExpr` already supports (no `-`/`/`/calls
//! inside subscripts) - enforced by parsing subscripts with a separate,
//! more restrictive production instead of the general `expr`, so a
//! disallowed construct is a clear parse error at the exact span, not a
//! deferred lowering error.
//!
//! Builtin calls, dispatched by name in `parse_call`: `exp`, `log`,
//! `sqrt`, `abs` (direct `SpecExpr` unary ops), `min` (binary op only),
//! `pow(x, N)` (desugars to repeated multiplication - `N` must be a
//! non-negative integer literal), `tanh(x)` (desugars to
//! `(exp(2x)-1)/(exp(2x)+1)`; no native `Tanh` node exists), and `sum`/
//! `max` (both the binary op and the reduction form above - `max(a, b)`
//! vs. `max(k in 0..K, body)` are disambiguated by a 2-token lookahead
//! for the `IDENT "in"` reduction head, since both start with an
//! expression that may itself begin with a bare identifier).

use std::fmt;

use volta_analysis::spec::{Bound, IndexExpr, ReduceOp, SpecExpr};
use volta_common::Span;
use volta_common::report::Locate;

use crate::ast::{ArrayDecl, DimDecl, OutputDecl, ParsedSpec};
use crate::lex::{Lexer, Token, TokenKind};

#[derive(Debug)]
pub enum ParseErrorKind {
    UnexpectedToken {
        expected: String,
        found: TokenKind,
    },
    UnknownFunction(String),
    /// A reduction's (`sum`/`max`) range must start at the literal `0` -
    /// `Reduce` in `volta_analysis::spec` only expresses `0..bound`, no
    /// arbitrary start (see that module's docs).
    ReductionRangeMustStartAtZero,
    /// A `sum` bound (or an array dim reference) must be an integer
    /// literal or a bare `dim` name - anything else can't become a
    /// `Bound` (`Const`/`Named` only).
    InvalidBound,
    /// `pow`'s exponent must be a non-negative integer literal - there is
    /// no general power node to lower an arbitrary exponent to.
    InvalidPowExponent,
    Lex(crate::lex::LexErrorKind),
}

impl fmt::Display for ParseErrorKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ParseErrorKind::UnexpectedToken { expected, found } => {
                write!(f, "expected {}, found {}", expected, found)
            }
            ParseErrorKind::UnknownFunction(name) => write!(f, "unknown function '{}'", name),
            ParseErrorKind::ReductionRangeMustStartAtZero => {
                write!(
                    f,
                    "a reduction's range must start at 0, e.g. 'sum(k in 0..K, ...)' or 'max(k in 0..K, ...)'"
                )
            }
            ParseErrorKind::InvalidBound => write!(
                f,
                "expected an integer literal or a dim name here, e.g. '0..K' or '0..16'"
            ),
            ParseErrorKind::InvalidPowExponent => {
                write!(
                    f,
                    "pow's second argument must be a non-negative integer literal"
                )
            }
            ParseErrorKind::Lex(e) => write!(f, "{}", e),
        }
    }
}

impl std::error::Error for ParseErrorKind {}

impl From<crate::lex::LexErrorKind> for ParseErrorKind {
    fn from(e: crate::lex::LexErrorKind) -> Self {
        ParseErrorKind::Lex(e)
    }
}

pub type ParseError = Locate<ParseErrorKind>;

fn err_at(span: Span, kind: ParseErrorKind) -> ParseError {
    Locate {
        path: None,
        span: Some(span),
        error: kind,
    }
}

/// Parse a whole spec source string into a [`ParsedSpec`].
pub fn parse_spec(src: &str) -> Result<ParsedSpec, ParseError> {
    let tokens = Lexer::new(src)
        .tokenize()
        .map_err(|e| e.map(ParseErrorKind::from))?;
    Parser { tokens, pos: 0 }.parse_spec()
}

struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    fn peek(&self) -> &Token {
        // `tokenize` always ends with one `Eof`, and `bump` never advances
        // past it, so this index is always in bounds.
        &self.tokens[self.pos]
    }

    fn bump(&mut self) -> Token {
        let tok = self.tokens[self.pos].clone();
        if self.pos + 1 < self.tokens.len() {
            self.pos += 1;
        }
        tok
    }

    fn unexpected(&self, expected: impl Into<String>) -> ParseError {
        err_at(
            self.peek().span,
            ParseErrorKind::UnexpectedToken {
                expected: expected.into(),
                found: self.peek().kind.clone(),
            },
        )
    }

    fn expect(&mut self, kind: TokenKind, expected: &str) -> Result<Token, ParseError> {
        if self.peek().kind == kind {
            Ok(self.bump())
        } else {
            Err(self.unexpected(expected))
        }
    }

    /// Consume an identifier token (any identifier - keywords like `dim`,
    /// `array`, `in`, `sum` are just identifiers the caller checks
    /// contextually, matching this codebase's PTX lexer/parser split).
    fn eat_ident(&mut self) -> Result<(String, Span), ParseError> {
        match self.peek().kind.clone() {
            TokenKind::Ident(name) => {
                let span = self.peek().span;
                self.bump();
                Ok((name, span))
            }
            _ => Err(self.unexpected("an identifier")),
        }
    }

    /// Consume an identifier token whose text must be exactly `word`
    /// (e.g. the `in` in `sum(k in 0..K, ...)`).
    fn eat_keyword(&mut self, word: &str) -> Result<(), ParseError> {
        let (name, span) = self.eat_ident()?;
        if name == word {
            Ok(())
        } else {
            Err(err_at(
                span,
                ParseErrorKind::UnexpectedToken {
                    expected: format!("'{}'", word),
                    found: TokenKind::Ident(name),
                },
            ))
        }
    }

    fn parse_spec(&mut self) -> Result<ParsedSpec, ParseError> {
        let mut spec = ParsedSpec::default();
        while self.peek().kind != TokenKind::Eof {
            match self.peek().kind.clone() {
                TokenKind::Ident(name) if name == "dim" => {
                    self.bump();
                    let (dim_name, span) = self.eat_ident()?;
                    self.expect(TokenKind::Semicolon, "';'")?;
                    spec.dims.push(DimDecl {
                        name: dim_name,
                        span,
                    });
                }
                TokenKind::Ident(name) if name == "array" => {
                    self.bump();
                    spec.arrays.push(self.parse_array_decl()?);
                }
                TokenKind::Ident(_) => {
                    spec.outputs.push(self.parse_output_decl()?);
                }
                _ => return Err(self.unexpected("'dim', 'array', or an output equation")),
            }
        }
        Ok(spec)
    }

    fn parse_ident_list(&mut self) -> Result<Vec<String>, ParseError> {
        let mut idents = Vec::new();
        loop {
            let (name, _) = self.eat_ident()?;
            idents.push(name);
            if self.peek().kind == TokenKind::Comma {
                self.bump();
            } else {
                break;
            }
        }
        Ok(idents)
    }

    fn parse_array_decl(&mut self) -> Result<ArrayDecl, ParseError> {
        let (name, span) = self.eat_ident()?;
        self.expect(TokenKind::LBracket, "'['")?;
        let dims = self.parse_ident_list()?;
        self.expect(TokenKind::RBracket, "']'")?;
        self.expect(TokenKind::Semicolon, "';'")?;
        Ok(ArrayDecl { name, dims, span })
    }

    fn parse_output_decl(&mut self) -> Result<OutputDecl, ParseError> {
        let (array, span) = self.eat_ident()?;
        self.expect(TokenKind::LBracket, "'['")?;
        let vars = self.parse_ident_list()?;
        self.expect(TokenKind::RBracket, "']'")?;
        self.expect(TokenKind::Equals, "'='")?;
        let body = self.parse_expr()?;
        self.expect(TokenKind::Semicolon, "';'")?;
        Ok(OutputDecl {
            array,
            vars,
            body,
            span,
        })
    }

    // -----------------------------------------------------------------
    // General expressions -> SpecExpr
    // -----------------------------------------------------------------

    fn parse_expr(&mut self) -> Result<SpecExpr, ParseError> {
        self.parse_add()
    }

    fn parse_add(&mut self) -> Result<SpecExpr, ParseError> {
        let mut lhs = self.parse_mul()?;
        loop {
            match self.peek().kind {
                TokenKind::Plus => {
                    self.bump();
                    lhs = lhs + self.parse_mul()?;
                }
                TokenKind::Minus => {
                    self.bump();
                    lhs = lhs - self.parse_mul()?;
                }
                _ => break,
            }
        }
        Ok(lhs)
    }

    fn parse_mul(&mut self) -> Result<SpecExpr, ParseError> {
        let mut lhs = self.parse_unary()?;
        loop {
            match self.peek().kind {
                TokenKind::Star => {
                    self.bump();
                    lhs = lhs * self.parse_unary()?;
                }
                TokenKind::Slash => {
                    self.bump();
                    lhs = lhs / self.parse_unary()?;
                }
                _ => break,
            }
        }
        Ok(lhs)
    }

    fn parse_unary(&mut self) -> Result<SpecExpr, ParseError> {
        if self.peek().kind == TokenKind::Minus {
            self.bump();
            return Ok(-self.parse_unary()?);
        }
        self.parse_postfix()
    }

    fn parse_postfix(&mut self) -> Result<SpecExpr, ParseError> {
        match self.peek().kind.clone() {
            TokenKind::Int(v) => {
                self.bump();
                Ok(SpecExpr::int(v as i64))
            }
            TokenKind::Float(v) => {
                self.bump();
                Ok(SpecExpr::real(v))
            }
            TokenKind::LParen => {
                self.bump();
                let e = self.parse_expr()?;
                self.expect(TokenKind::RParen, "')'")?;
                Ok(e)
            }
            TokenKind::Ident(name) => {
                self.bump();
                match self.peek().kind {
                    TokenKind::LBracket => {
                        self.bump();
                        let mut indices = vec![self.parse_index_expr()?];
                        while self.peek().kind == TokenKind::Comma {
                            self.bump();
                            indices.push(self.parse_index_expr()?);
                        }
                        self.expect(TokenKind::RBracket, "']'")?;
                        Ok(SpecExpr::index(name, indices))
                    }
                    TokenKind::LParen => {
                        self.bump();
                        self.parse_call(&name)
                    }
                    _ => Ok(SpecExpr::var(name)),
                }
            }
            _ => Err(self.unexpected("a number, identifier, or '('")),
        }
    }

    /// Parse a call's arguments and dispatch by `name`; `(` already
    /// consumed by the caller.
    fn parse_call(&mut self, name: &str) -> Result<SpecExpr, ParseError> {
        match name {
            "sum" => {
                let (var, bound, body) = self.parse_reduction()?;
                Ok(SpecExpr::reduce(ReduceOp::Sum, var, bound, body))
            }
            "exp" => Ok(self.parse_unary_call()?.exp()),
            "log" => Ok(self.parse_unary_call()?.log()),
            "sqrt" => Ok(self.parse_unary_call()?.sqrt()),
            "abs" => Ok(self.parse_unary_call()?.abs()),
            "tanh" => Ok(desugar_tanh(self.parse_unary_call()?)),
            "min" => {
                let (a, b) = self.parse_binary_call()?;
                Ok(a.min(b))
            }
            "max" => {
                if self.at_reduction_head() {
                    let (var, bound, body) = self.parse_reduction()?;
                    Ok(SpecExpr::reduce(ReduceOp::Max, var, bound, body))
                } else {
                    let (a, b) = self.parse_binary_call()?;
                    Ok(a.max(b))
                }
            }
            "pow" => {
                let exp_span_start = self.pos;
                let (base, exp) = self.parse_binary_call()?;
                desugar_pow(base, &exp).ok_or_else(|| {
                    // Best-effort span: the whole call's argument list.
                    let span = Span(self.tokens[exp_span_start].span.0, self.peek().span.0);
                    err_at(span, ParseErrorKind::InvalidPowExponent)
                })
            }
            other => Err(err_at(
                self.peek().span,
                ParseErrorKind::UnknownFunction(other.to_string()),
            )),
        }
    }

    /// True if the tokens right after a call's `(` are `IDENT "in"` - the
    /// unambiguous head of a reduction's argument list, as opposed to a
    /// bare expression that happens to start with an identifier (e.g. the
    /// `A` in `max(A[i], 0)`).
    fn at_reduction_head(&self) -> bool {
        matches!(self.peek().kind, TokenKind::Ident(_))
            && matches!(
                self.tokens.get(self.pos + 1).map(|t| &t.kind),
                Some(TokenKind::Ident(w)) if w == "in"
            )
    }

    /// Parse a reduction's argument list - `IDENT "in" expr ".." expr ","
    /// expr ")"` - shared by `sum` and `max`; `(` and the call name are
    /// already consumed by the caller.
    fn parse_reduction(&mut self) -> Result<(String, Bound, SpecExpr), ParseError> {
        let (var, _) = self.eat_ident()?;
        self.eat_keyword("in")?;
        let lo = self.parse_expr()?;
        self.expect(TokenKind::DotDot, "'..'")?;
        let hi_span = self.peek().span;
        let hi = self.parse_expr()?;
        self.expect(TokenKind::Comma, "','")?;
        let body = self.parse_expr()?;
        let close = self.expect(TokenKind::RParen, "')'")?;
        if !matches!(lo, SpecExpr::Int(0)) {
            return Err(err_at(
                close.span,
                ParseErrorKind::ReductionRangeMustStartAtZero,
            ));
        }
        let bound =
            expr_to_bound(&hi).ok_or_else(|| err_at(hi_span, ParseErrorKind::InvalidBound))?;
        Ok((var, bound, body))
    }

    fn parse_unary_call(&mut self) -> Result<SpecExpr, ParseError> {
        let a = self.parse_expr()?;
        self.expect(TokenKind::RParen, "')'")?;
        Ok(a)
    }

    fn parse_binary_call(&mut self) -> Result<(SpecExpr, SpecExpr), ParseError> {
        let a = self.parse_expr()?;
        self.expect(TokenKind::Comma, "','")?;
        let b = self.parse_expr()?;
        self.expect(TokenKind::RParen, "')'")?;
        Ok((a, b))
    }

    // -----------------------------------------------------------------
    // Index expressions -> IndexExpr (the restricted affine sublanguage)
    // -----------------------------------------------------------------

    fn parse_index_expr(&mut self) -> Result<IndexExpr, ParseError> {
        let mut lhs = self.parse_index_mul()?;
        while self.peek().kind == TokenKind::Plus {
            self.bump();
            lhs = lhs + self.parse_index_mul()?;
        }
        Ok(lhs)
    }

    fn parse_index_mul(&mut self) -> Result<IndexExpr, ParseError> {
        let mut lhs = self.parse_index_primary()?;
        while self.peek().kind == TokenKind::Star {
            self.bump();
            lhs = lhs * self.parse_index_primary()?;
        }
        Ok(lhs)
    }

    fn parse_index_primary(&mut self) -> Result<IndexExpr, ParseError> {
        match self.peek().kind.clone() {
            TokenKind::Int(v) => {
                self.bump();
                Ok(IndexExpr::int(v))
            }
            TokenKind::Ident(name) => {
                self.bump();
                Ok(IndexExpr::var(name))
            }
            TokenKind::LParen => {
                self.bump();
                let e = self.parse_index_expr()?;
                self.expect(TokenKind::RParen, "')'")?;
                Ok(e)
            }
            _ => Err(self.unexpected(
                "an integer, a variable, or '(' (index expressions only allow +, *, and parens)",
            )),
        }
    }
}

/// `SpecExpr::Int(n)` (n >= 0) or `SpecExpr::Var(name)` -> `Bound`;
/// anything else can't become one (`Bound` is `Const`/`Named` only).
fn expr_to_bound(e: &SpecExpr) -> Option<Bound> {
    match e {
        SpecExpr::Int(n) if *n >= 0 => Some(Bound::Const(*n as u64)),
        SpecExpr::Var(name) => Some(Bound::Named(name.clone())),
        _ => None,
    }
}

/// `tanh(x) = (exp(2x) - 1) / (exp(2x) + 1)` - no native `Tanh` node
/// exists in the arena, so this is pure syntax sugar over `Exp`.
fn desugar_tanh(x: SpecExpr) -> SpecExpr {
    let e2x = (SpecExpr::int(2) * x).exp();
    (e2x.clone() - SpecExpr::int(1)) / (e2x + SpecExpr::int(1))
}

/// `pow(x, n)` for a non-negative integer literal `n` -> repeated
/// multiplication (`n == 0` -> `1`). There is no general power node to
/// lower a symbolic or fractional exponent to.
fn desugar_pow(base: SpecExpr, exp: &SpecExpr) -> Option<SpecExpr> {
    let SpecExpr::Int(n) = exp else { return None };
    if *n < 0 {
        return None;
    }
    let n = *n as u64;
    if n == 0 {
        return Some(SpecExpr::int(1));
    }
    let mut acc = base.clone();
    for _ in 1..n {
        acc = acc * base.clone();
    }
    Some(acc)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn output_body(src: &str) -> SpecExpr {
        parse_spec(src).unwrap().outputs.remove(0).body
    }

    #[test]
    fn dim_array_and_output_decls_parse() {
        let spec = parse_spec(
            "dim M; dim N; dim K;
             array A[M, K]; array B[K, N]; array C[M, N];
             C[i, j] = sum(k in 0..K, A[i, k] * B[k, j]);",
        )
        .unwrap();
        assert_eq!(spec.dims.len(), 3);
        assert_eq!(spec.arrays.len(), 3);
        assert_eq!(spec.outputs.len(), 1);
        assert_eq!(spec.outputs[0].array, "C");
        assert_eq!(spec.outputs[0].vars, vec!["i", "j"]);
        assert!(matches!(
            spec.outputs[0].body,
            SpecExpr::Reduce {
                op: ReduceOp::Sum,
                ..
            }
        ));
    }

    #[test]
    fn line_comments_are_skipped() {
        let spec =
            parse_spec("// a comment\ndim M; // trailing\narray A[M];\nC[i] = A[i];").unwrap();
        assert_eq!(spec.dims.len(), 1);
    }

    #[test]
    fn unary_builtins_map_to_the_matching_node() {
        let src = "dim N; array A[N];\nC[i] = FN(A[i]);";
        assert!(matches!(
            output_body(&src.replace("FN", "exp")),
            SpecExpr::Exp(_)
        ));
        assert!(matches!(
            output_body(&src.replace("FN", "log")),
            SpecExpr::Log(_)
        ));
        assert!(matches!(
            output_body(&src.replace("FN", "sqrt")),
            SpecExpr::Sqrt(_)
        ));
        assert!(matches!(
            output_body(&src.replace("FN", "abs")),
            SpecExpr::Abs(_)
        ));
    }

    #[test]
    fn min_and_max_are_binary_builtins() {
        let body = output_body("dim N; array A[N];\nC[i] = min(A[i], 0);");
        assert!(matches!(body, SpecExpr::Min(_, _)));
        let body = output_body("dim N; array A[N];\nC[i] = max(A[i], 0);");
        assert!(matches!(body, SpecExpr::Max(_, _)));
    }

    #[test]
    fn max_as_reduction_parses_like_sum() {
        let body = output_body("dim N; array A[N];\nC[i] = max(k in 0..N, A[k]);");
        assert!(matches!(
            body,
            SpecExpr::Reduce {
                op: ReduceOp::Max,
                ..
            }
        ));
    }

    #[test]
    fn max_reduction_does_not_shadow_a_var_named_max_used_as_a_plain_ident() {
        // `max(A[i], 0)`'s first token is an identifier (`A`) but not
        // followed by `in`, so it must fall back to the binary form
        // rather than erroring as a malformed reduction head.
        let body = output_body("dim N; array A[N];\nC[i] = max(A[i], 0);");
        assert!(matches!(body, SpecExpr::Max(_, _)));
    }

    #[test]
    fn tanh_desugars_to_a_fraction_over_exp() {
        // (exp(2x) - 1) / (exp(2x) + 1): top node is Div, both sides
        // built from Exp - a shallow structural check, the actual
        // identity is exercised numerically by the matmul/pow
        // equivalence tests.
        let body = output_body("dim N; array A[N];\nC[i] = tanh(A[i]);");
        let SpecExpr::Div(num, den) = body else {
            panic!("expected tanh to desugar to a Div, got {:?}", body);
        };
        assert!(matches!(*num, SpecExpr::Sub(box_a, _) if matches!(*box_a, SpecExpr::Exp(_))));
        assert!(matches!(*den, SpecExpr::Add(box_a, _) if matches!(*box_a, SpecExpr::Exp(_))));
    }

    #[test]
    fn pow_desugars_to_repeated_multiplication() {
        // pow(x, 3) -> (x * x) * x: two Mul nodes.
        let body = output_body("dim N; array A[N];\nC[i] = pow(A[i], 3);");
        let SpecExpr::Mul(lhs, _) = body else {
            panic!("expected pow(_, 3) to desugar to Mul, got {:?}", body);
        };
        assert!(matches!(*lhs, SpecExpr::Mul(_, _)));
    }

    #[test]
    fn pow_zero_desugars_to_one() {
        let body = output_body("dim N; array A[N];\nC[i] = pow(A[i], 0);");
        assert!(matches!(body, SpecExpr::Int(1)));
    }

    #[test]
    fn index_expressions_reject_subtraction() {
        let err = parse_spec("dim N; array A[N];\nC[i] = A[i - 1];").unwrap_err();
        assert!(matches!(err.error, ParseErrorKind::UnexpectedToken { .. }));
    }

    #[test]
    fn sum_range_must_start_at_zero() {
        let err = parse_spec("dim N; array A[N];\nC[i] = sum(k in 1..N, A[k]);").unwrap_err();
        assert!(matches!(
            err.error,
            ParseErrorKind::ReductionRangeMustStartAtZero
        ));
    }

    #[test]
    fn max_reduction_range_must_start_at_zero() {
        let err = parse_spec("dim N; array A[N];\nC[i] = max(k in 1..N, A[k]);").unwrap_err();
        assert!(matches!(
            err.error,
            ParseErrorKind::ReductionRangeMustStartAtZero
        ));
    }

    #[test]
    fn pow_rejects_a_non_literal_exponent() {
        let err = parse_spec("dim N; array A[N];\nC[i] = pow(A[i], A[i]);").unwrap_err();
        assert!(matches!(err.error, ParseErrorKind::InvalidPowExponent));
    }

    #[test]
    fn unknown_function_is_a_clean_error() {
        let err = parse_spec("dim N; array A[N];\nC[i] = frobnicate(A[i]);").unwrap_err();
        assert!(matches!(err.error, ParseErrorKind::UnknownFunction(name) if name == "frobnicate"));
    }

    #[test]
    fn missing_semicolon_is_reported() {
        let err = parse_spec("dim N array A[N];").unwrap_err();
        assert!(matches!(err.error, ParseErrorKind::UnexpectedToken { .. }));
    }
}
