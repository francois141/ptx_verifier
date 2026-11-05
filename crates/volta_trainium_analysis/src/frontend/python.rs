//! The Python subset NKI kernels are written in, as a syntax tree, and its
//! recursive-descent parser. Only Python's own rules are checked here; what
//! the names refer to is for `parse` to resolve.

use std::fmt;

use super::ast::Scalar;
use super::error::{ParseError, bail};
use super::lex::{CmpOp, Keyword, Token, TokenKind, tokenize};

/// A dotted name: `nl.add` has head `nl` and attributes `[add]`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Dotted {
    pub head: String,
    pub attributes: Vec<String>,
}

impl fmt::Display for Dotted {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.head)?;
        for attribute in &self.attributes {
            write!(f, ".{attribute}")?;
        }
        Ok(())
    }
}

pub enum Item {
    /// `import path [as alias]`.
    Import {
        line: usize,
        path: Dotted,
        alias: Option<String>,
    },
    Function(Function),
}

/// `@decorator` on `def name(params):` and its body.
pub struct Function {
    /// The decorator's line.
    pub line: usize,
    pub decorator: Dotted,
    pub name: String,
    pub params: Vec<String>,
    pub body: Vec<Stmt>,
}

#[derive(Clone)]
pub enum Stmt {
    /// `target = value`.
    Assign {
        line: usize,
        target: Target,
        value: Expr,
    },
    /// An expression evaluated for its effect, e.g. an `nki.isa` call.
    Expr { line: usize, value: Expr },
    /// `assert test`.
    Assert { line: usize, test: Expr },
    /// `for var in iterable:` and its indented body.
    For {
        line: usize,
        var: String,
        iterable: Expr,
        body: Vec<Stmt>,
    },
    /// `return value`.
    Return { line: usize, value: Expr },
}

/// What an assignment binds: one name, or each item of a tuple to a name.
#[derive(Clone)]
pub enum Target {
    Name(String),
    /// `a, b = value`.
    Unpack(Vec<String>),
}

#[derive(Clone)]
pub struct Call {
    pub callee: Dotted,
    pub args: Vec<Expr>,
    /// In source order, no keyword twice.
    pub kwargs: Vec<(String, Expr)>,
}

#[derive(Clone)]
pub enum Expr {
    Int(u64),
    Float(Scalar),
    Name(Dotted),
    Tuple(Vec<Expr>),
    /// `callee(args)`.
    Call(Call),
    /// `first op1 second op2 third ...`: each operand compared with the next.
    Compare {
        first: Box<Expr>,
        rest: Vec<(CmpOp, Expr)>,
    },
    /// `lhs op rhs`.
    Binary {
        op: BinOp,
        lhs: Box<Expr>,
        rhs: Box<Expr>,
    },
    /// `base[index, ...]`.
    Subscript {
        base: Box<Expr>,
        indices: Vec<Expr>,
    },
    /// `start:stop`, either bound omitted.
    Slice {
        start: Option<Box<Expr>>,
        stop: Option<Box<Expr>>,
    },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BinOp {
    Mul,
    FloorDiv,
    Add,
}

/// An assignment's left side as its target: a name, or a tuple of names.
fn target(expr: Expr, line: usize) -> Result<Target, ParseError> {
    let name = |expr: Expr| match expr {
        Expr::Name(Dotted { head, attributes }) if attributes.is_empty() => Ok(head),
        _ => bail!(line, "only names can be assigned to"),
    };

    match expr {
        Expr::Tuple(items) => Ok(Target::Unpack(
            items.into_iter().map(name).collect::<Result<_, _>>()?,
        )),
        expr => Ok(Target::Name(name(expr)?)),
    }
}

/// The module's top-level items in order.
pub fn parse(source: &str) -> Result<Vec<Item>, ParseError> {
    let tokens = tokenize(source)?;
    Parser { tokens, pos: 0 }.items()
}

struct Parser {
    /// Ends with `Eof`, which the parser never moves past.
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    fn items(mut self) -> Result<Vec<Item>, ParseError> {
        let mut items = Vec::new();
        loop {
            let Token { kind, line } = self.advance();
            let item = match kind {
                TokenKind::Eof => return Ok(items),
                TokenKind::Keyword(Keyword::Import) => self.import(line)?,
                TokenKind::At => Item::Function(self.function(line)?),
                other => bail!(
                    line,
                    "expected `import` or a decorated function, found {other}"
                ),
            };
            items.push(item);
        }
    }

    /// `path [as alias]` to the end of the line, after `import`.
    fn import(&mut self, line: usize) -> Result<Item, ParseError> {
        let path = self.dotted()?;
        let alias = if self.eat(&TokenKind::Keyword(Keyword::As)) {
            Some(self.name()?)
        } else {
            None
        };
        self.expect(TokenKind::Newline)?;

        Ok(Item::Import { line, path, alias })
    }

    /// `decorator`, then `def name(params):` and its indented body, after `@`.
    fn function(&mut self, line: usize) -> Result<Function, ParseError> {
        let decorator = self.dotted()?;
        self.expect(TokenKind::Newline)?;

        self.expect(TokenKind::Keyword(Keyword::Def))?;
        let name = self.name()?;
        self.expect(TokenKind::LParen)?;
        let params = self.comma_list(TokenKind::RParen, Self::name)?;
        self.expect(TokenKind::Colon)?;
        self.expect(TokenKind::Newline)?;

        self.expect(TokenKind::Indent)?;
        let mut body = Vec::new();
        while !self.eat(&TokenKind::Dedent) {
            body.push(self.statement()?);
        }

        Ok(Function {
            line,
            decorator,
            name,
            params,
            body,
        })
    }

    fn statement(&mut self) -> Result<Stmt, ParseError> {
        let line = self.line();

        if self.eat(&TokenKind::Keyword(Keyword::Assert)) {
            let test = self.expr()?;
            self.expect(TokenKind::Newline)?;
            return Ok(Stmt::Assert { line, test });
        }

        if self.eat(&TokenKind::Keyword(Keyword::For)) {
            let var = self.name()?;
            self.expect(TokenKind::Keyword(Keyword::In))?;
            let iterable = self.expr()?;
            self.expect(TokenKind::Colon)?;
            self.expect(TokenKind::Newline)?;

            self.expect(TokenKind::Indent)?;
            let mut body = Vec::new();
            while !self.eat(&TokenKind::Dedent) {
                body.push(self.statement()?);
            }
            return Ok(Stmt::For {
                line,
                var,
                iterable,
                body,
            });
        }

        if self.eat(&TokenKind::Keyword(Keyword::Return)) {
            let value = self.expr()?;
            self.expect(TokenKind::Newline)?;
            return Ok(Stmt::Return { line, value });
        }

        let value = self.expr_list()?;
        if !self.eat(&TokenKind::Equals) {
            self.expect(TokenKind::Newline)?;
            return Ok(Stmt::Expr { line, value });
        }

        let target = target(value, line)?;
        let value = self.expr_list()?;
        self.expect(TokenKind::Newline)?;
        Ok(Stmt::Assign {
            line,
            target,
            value,
        })
    }

    /// An expression, or the tuple `e, ...` of several without parentheses.
    fn expr_list(&mut self) -> Result<Expr, ParseError> {
        let first = self.expr()?;
        if !self.eat(&TokenKind::Comma) {
            return Ok(first);
        }

        let mut items = vec![first];
        while !matches!(self.peek(), TokenKind::Equals | TokenKind::Newline) {
            items.push(self.expr()?);
            if !self.eat(&TokenKind::Comma) {
                break;
            }
        }
        Ok(Expr::Tuple(items))
    }

    /// The arguments of `callee(args)`, after `(`: positional ones, then keyword ones.
    fn call(&mut self, callee: Dotted, line: usize) -> Result<Call, ParseError> {
        let mut args = Vec::new();
        let mut kwargs: Vec<(String, Expr)> = Vec::new();
        for (keyword, expr) in self.comma_list(TokenKind::RParen, Self::argument)? {
            match keyword {
                None => {
                    if !kwargs.is_empty() {
                        bail!(line, "positional argument follows keyword argument");
                    }
                    args.push(expr);
                }
                Some(keyword) => {
                    if kwargs.iter().any(|(given, _)| *given == keyword) {
                        bail!(line, "keyword argument `{keyword}` repeated");
                    }
                    kwargs.push((keyword, expr));
                }
            }
        }

        Ok(Call {
            callee,
            args,
            kwargs,
        })
    }

    /// `[keyword =] expr`.
    fn argument(&mut self) -> Result<(Option<String>, Expr), ParseError> {
        let keyword = self.binding();
        let expr = self.expr()?;
        Ok((keyword, expr))
    }

    /// An expression: comparisons over `+` over `*` and `//` over a primary.
    fn expr(&mut self) -> Result<Expr, ParseError> {
        let first = self.sum()?;
        let mut rest = Vec::new();
        while let &TokenKind::Compare(op) = self.peek() {
            self.advance();
            rest.push((op, self.sum()?));
        }

        if rest.is_empty() {
            return Ok(first);
        }
        Ok(Expr::Compare {
            first: Box::new(first),
            rest,
        })
    }

    /// A sum of terms.
    fn sum(&mut self) -> Result<Expr, ParseError> {
        let mut lhs = self.term()?;
        while self.eat(&TokenKind::Plus) {
            let rhs = self.term()?;
            lhs = Expr::Binary {
                op: BinOp::Add,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
            };
        }
        Ok(lhs)
    }

    /// Primaries multiplied or floor-divided, left to right.
    fn term(&mut self) -> Result<Expr, ParseError> {
        let mut lhs = self.primary()?;
        loop {
            let op = match self.peek() {
                TokenKind::Star => BinOp::Mul,
                TokenKind::SlashSlash => BinOp::FloorDiv,
                _ => return Ok(lhs),
            };
            self.advance();
            let rhs = self.primary()?;
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
            };
        }
    }

    /// A literal, a dotted name, a call, or a parenthesized expression or tuple, then any `[...]`.
    fn primary(&mut self) -> Result<Expr, ParseError> {
        let Token { kind, line } = self.advance();
        let mut base = match kind {
            TokenKind::Int(value) => Expr::Int(value),
            TokenKind::Float(value) => Expr::Float(value),
            TokenKind::Name(head) => {
                let name = self.attributes(head)?;
                if self.eat(&TokenKind::LParen) {
                    Expr::Call(self.call(name, line)?)
                } else {
                    Expr::Name(name)
                }
            }
            TokenKind::LParen => self.parenthesized()?,
            other => bail!(line, "expected an expression, found {other}"),
        };

        while self.eat(&TokenKind::LBracket) {
            let indices = self.comma_list(TokenKind::RBracket, Self::subscript_item)?;
            base = Expr::Subscript {
                base: Box::new(base),
                indices,
            };
        }
        Ok(base)
    }

    /// One subscript index: an expression, or the slice `start:stop`.
    fn subscript_item(&mut self) -> Result<Expr, ParseError> {
        if self.eat(&TokenKind::Colon) {
            let stop = self.slice_bound()?;
            return Ok(Expr::Slice { start: None, stop });
        }

        let start = self.expr()?;
        if !self.eat(&TokenKind::Colon) {
            return Ok(start);
        }
        let stop = self.slice_bound()?;
        Ok(Expr::Slice {
            start: Some(Box::new(start)),
            stop,
        })
    }

    /// A slice's upper bound, absent at the end of its index.
    fn slice_bound(&mut self) -> Result<Option<Box<Expr>>, ParseError> {
        if matches!(self.peek(), TokenKind::Comma | TokenKind::RBracket) {
            return Ok(None);
        }
        Ok(Some(Box::new(self.expr()?)))
    }

    /// `()`, `(e)` or the tuple `(e, ...)`, after `(`: only a comma makes a tuple.
    fn parenthesized(&mut self) -> Result<Expr, ParseError> {
        if self.eat(&TokenKind::RParen) {
            return Ok(Expr::Tuple(Vec::new()));
        }

        let first = self.expr()?;
        if self.eat(&TokenKind::RParen) {
            return Ok(first);
        }

        self.expect(TokenKind::Comma)?;
        let mut items = vec![first];
        items.extend(self.comma_list(TokenKind::RParen, Self::expr)?);
        Ok(Expr::Tuple(items))
    }

    /// `item, ...` up to `close`, with an optional trailing comma, after the opening bracket.
    fn comma_list<T>(
        &mut self,
        close: TokenKind,
        mut item: impl FnMut(&mut Self) -> Result<T, ParseError>,
    ) -> Result<Vec<T>, ParseError> {
        let mut items = Vec::new();
        while !self.eat(&close) {
            items.push(item(self)?);
            if !self.eat(&TokenKind::Comma) {
                self.expect(close.clone())?;
                break;
            }
        }
        Ok(items)
    }

    fn dotted(&mut self) -> Result<Dotted, ParseError> {
        let head = self.name()?;
        self.attributes(head)
    }

    /// The `.attribute`s after `head`.
    fn attributes(&mut self, head: String) -> Result<Dotted, ParseError> {
        let mut attributes = Vec::new();
        while self.eat(&TokenKind::Dot) {
            attributes.push(self.name()?);
        }
        Ok(Dotted { head, attributes })
    }

    /// Consumes `name =` if it comes next: a keyword argument's keyword.
    fn binding(&mut self) -> Option<String> {
        let TokenKind::Name(name) = self.peek() else {
            return None;
        };
        if self.tokens[self.pos + 1].kind != TokenKind::Equals {
            return None;
        }

        let name = name.clone();
        self.pos += 2;
        Some(name)
    }

    fn name(&mut self) -> Result<String, ParseError> {
        let Token { kind, line } = self.advance();
        match kind {
            TokenKind::Name(name) => Ok(name),
            other => bail!(line, "expected a name, found {other}"),
        }
    }

    fn expect(&mut self, expected: TokenKind) -> Result<(), ParseError> {
        let Token { kind, line } = self.advance();
        if kind != expected {
            bail!(line, "expected {expected}, found {kind}");
        }
        Ok(())
    }

    fn eat(&mut self, kind: &TokenKind) -> bool {
        let found = self.peek() == kind;
        if found {
            self.advance();
        }
        found
    }

    fn advance(&mut self) -> Token {
        let token = self.tokens[self.pos].clone();
        if token.kind != TokenKind::Eof {
            self.pos += 1;
        }
        token
    }

    fn peek(&self) -> &TokenKind {
        &self.tokens[self.pos].kind
    }

    fn line(&self) -> usize {
        self.tokens[self.pos].line
    }
}
