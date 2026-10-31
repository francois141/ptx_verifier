//! The Python subset NKI kernels are written in, as a syntax tree, and its
//! recursive-descent parser. Only Python's own rules are checked here; what
//! the names refer to is for `parse` to resolve.

use std::fmt;

use super::error::{ParseError, bail};
use super::lex::{Keyword, Token, TokenKind, tokenize};

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

pub enum Stmt {
    /// `[target =] call`.
    Call {
        line: usize,
        target: Option<String>,
        call: Call,
    },
    /// `assert left == right`.
    AssertEq {
        line: usize,
        left: Expr,
        right: Expr,
    },
}

pub struct Call {
    pub callee: Dotted,
    pub args: Vec<Expr>,
    /// In source order, no keyword twice.
    pub kwargs: Vec<(String, Expr)>,
}

pub enum Expr {
    Int(u64),
    Name(Dotted),
    Tuple(Vec<Expr>),
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
        let params = self.comma_list(Self::name)?;
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
            let left = self.expr()?;
            self.expect(TokenKind::EqualsEquals)?;
            let right = self.expr()?;
            self.expect(TokenKind::Newline)?;
            return Ok(Stmt::AssertEq { line, left, right });
        }

        let target = self.binding();
        let call = self.call()?;
        self.expect(TokenKind::Newline)?;

        Ok(Stmt::Call { line, target, call })
    }

    /// `callee(args)`: positional arguments, then keyword ones.
    fn call(&mut self) -> Result<Call, ParseError> {
        let line = self.line();
        let callee = self.dotted()?;
        self.expect(TokenKind::LParen)?;

        let mut args = Vec::new();
        let mut kwargs: Vec<(String, Expr)> = Vec::new();
        for (keyword, expr) in self.comma_list(Self::argument)? {
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

    /// An integer, a dotted name, or a parenthesized expression or tuple.
    fn expr(&mut self) -> Result<Expr, ParseError> {
        let Token { kind, line } = self.advance();
        match kind {
            TokenKind::Int(value) => Ok(Expr::Int(value)),
            TokenKind::Name(head) => Ok(Expr::Name(self.attributes(head)?)),
            TokenKind::LParen => self.parenthesized(),
            other => bail!(line, "expected an expression, found {other}"),
        }
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
        items.extend(self.comma_list(Self::expr)?);
        Ok(Expr::Tuple(items))
    }

    /// `item, ...)` with an optional trailing comma, after `(`.
    fn comma_list<T>(
        &mut self,
        mut item: impl FnMut(&mut Self) -> Result<T, ParseError>,
    ) -> Result<Vec<T>, ParseError> {
        let mut items = Vec::new();
        while !self.eat(&TokenKind::RParen) {
            items.push(item(self)?);
            if !self.eat(&TokenKind::Comma) {
                self.expect(TokenKind::RParen)?;
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

    /// Consumes `name =` if it comes next: an assignment's target or an argument's keyword.
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
