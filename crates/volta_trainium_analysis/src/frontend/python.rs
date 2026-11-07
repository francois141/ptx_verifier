//! The Python subset NKI kernels are written in, as a syntax tree, and its
//! recursive-descent parser. A module's items are read eagerly but a function
//! only when `FunctionSource::parse` is called, so code no kernel reaches may use
//! any Python. Only Python's own rules are checked here; names are `parse`'s.

use std::fmt;

use super::ast::Scalar;
use super::error::{ParseError, bail};
pub use super::lex::BinOp;
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
    /// `from module import name [as alias], ...`.
    FromImport {
        line: usize,
        module: Dotted,
        names: Vec<(String, Option<String>)>,
    },
    Function(FunctionSource),
    Class(ClassSource),
}

/// A `def`, decorators included, as tokens: parsed only by `parse`.
#[derive(Clone)]
pub struct FunctionSource {
    pub line: usize,
    pub name: String,
    /// From the first decorator or `def` through the body's end, then `Eof`.
    tokens: Vec<Token>,
}

impl FunctionSource {
    pub fn parse(&self) -> Result<Function, ParseError> {
        Parser {
            tokens: self.tokens.clone(),
            pos: 0,
        }
        .function()
    }
}

/// A `class`, as tokens: parsed only by `parse`.
#[derive(Clone)]
pub struct ClassSource {
    pub line: usize,
    pub name: String,
    /// From `class` through the body's end, then `Eof`.
    tokens: Vec<Token>,
}

impl ClassSource {
    pub fn parse(&self) -> Result<Class, ParseError> {
        Parser {
            tokens: self.tokens.clone(),
            pos: 0,
        }
        .class()
    }
}

/// `class name(bases):` and its body: attributes assigned and methods, in order.
pub struct Class {
    pub bases: Vec<Dotted>,
    /// `name = value` of the class body, with its line.
    pub attributes: Vec<(usize, String, Expr)>,
    pub methods: Vec<FunctionSource>,
}

/// `@decorator ... def name(params):` and its body, docstring dropped.
pub struct Function {
    /// The first decorator's line, else the `def`'s.
    pub line: usize,
    pub decorators: Vec<Dotted>,
    pub name: String,
    pub params: Vec<Param>,
    pub body: Vec<Stmt>,
}

/// A parameter, and its default value if it has one: `axis=(1,)`.
#[derive(Clone)]
pub struct Param {
    pub name: String,
    pub default: Option<Expr>,
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
    /// `assert test` or `assert test, message`; the message is never read.
    Assert { line: usize, test: Expr },
    /// `for var in iterable:` and its indented body.
    For {
        line: usize,
        var: String,
        iterable: Expr,
        body: Vec<Stmt>,
    },
    /// `return value`, or `return`.
    Return { line: usize, value: Option<Expr> },
    /// `if test:` and its body, then the `elif`s and `else` as `orelse`, an `elif` being
    /// an `If` alone in it.
    If {
        line: usize,
        test: Expr,
        body: Vec<Stmt>,
        orelse: Vec<Stmt>,
    },
    /// `with context:` and its body.
    With {
        line: usize,
        context: Expr,
        body: Vec<Stmt>,
    },
}

/// What an assignment binds: one name, each item of a tuple to a name, or an item.
#[derive(Clone)]
pub enum Target {
    Name(String),
    /// `a, b = value`.
    Unpack(Vec<String>),
    /// `name[index] = value`.
    Item {
        name: String,
        index: Expr,
    },
    /// `object.attribute = value`, `object` itself a dotted name.
    Attribute {
        object: Dotted,
        attribute: String,
    },
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
    None,
    Int(u64),
    Float(Scalar),
    Bool(bool),
    Name(Dotted),
    Tuple(Vec<Expr>),
    /// `[item, ...]`.
    List(Vec<Expr>),
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
    /// `op operand`.
    Unary {
        op: UnaryOp,
        operand: Box<Expr>,
    },
    /// `lhs and rhs` or `lhs or rhs`, `rhs` evaluated only if `lhs` does not decide it.
    Logical {
        op: LogicalOp,
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
pub enum UnaryOp {
    /// `-`.
    Neg,
    /// `~`.
    Invert,
    Not,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LogicalOp {
    And,
    Or,
}

/// An assignment's left side as its target: a name, a tuple of names, `name[index]` or
/// `object.attribute`.
fn target(expr: Expr, line: usize) -> Result<Target, ParseError> {
    let name = |expr: Expr| match expr {
        Expr::Name(Dotted { head, attributes }) if attributes.is_empty() => Ok(head),
        _ => bail!(
            line,
            "only names, `name[index]` and `object.attribute` can be assigned to"
        ),
    };

    match expr {
        Expr::Tuple(items) => Ok(Target::Unpack(
            items.into_iter().map(name).collect::<Result<_, _>>()?,
        )),
        Expr::Subscript { base, mut indices } if indices.len() == 1 => {
            let index = indices.pop().expect("one index");
            if matches!(index, Expr::Slice { .. }) {
                bail!(line, "only one item, not a slice, can be assigned to");
            }
            Ok(Target::Item {
                name: name(*base)?,
                index,
            })
        }
        Expr::Name(Dotted {
            head,
            mut attributes,
        }) if !attributes.is_empty() => {
            let attribute = attributes.pop().expect("an attribute");
            Ok(Target::Attribute {
                object: Dotted { head, attributes },
                attribute,
            })
        }
        expr => Ok(Target::Name(name(expr)?)),
    }
}

/// `target op= value` as the assignment `target = target op value`.
fn augmented(target: Target, op: BinOp, value: Expr, line: usize) -> Result<Stmt, ParseError> {
    let current = match &target {
        Target::Name(name) => Dotted {
            head: name.clone(),
            attributes: Vec::new(),
        },
        Target::Attribute { object, attribute } => {
            let mut object = object.clone();
            object.attributes.push(attribute.clone());
            object
        }
        Target::Unpack(_) | Target::Item { .. } => bail!(
            line,
            "only a name or an attribute can be the target of `{}=`",
            op.text()
        ),
    };
    Ok(Stmt::Assign {
        line,
        target,
        value: Expr::Binary {
            op,
            lhs: Box::new(Expr::Name(current)),
            rhs: Box::new(value),
        },
    })
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
            if self.docstring() {
                continue;
            }
            let Token { kind, line } = self.tokens[self.pos].clone();
            let item = match kind {
                TokenKind::Eof => return Ok(items),
                TokenKind::Keyword(Keyword::Import) => {
                    self.advance();
                    self.import(line)?
                }
                TokenKind::Keyword(Keyword::From) => {
                    self.advance();
                    self.import_from(line)?
                }
                TokenKind::At | TokenKind::Keyword(Keyword::Def | Keyword::Class) => {
                    self.definition(line)?
                }
                other => bail!(
                    line,
                    "expected an import, a function or a class, found {other}"
                ),
            };
            items.push(item);
        }
    }

    /// Skips a statement of only a string, such as a docstring, if one comes next.
    fn docstring(&mut self) -> bool {
        let is_string = self.tokens[self.pos].kind == TokenKind::Str
            && self.tokens[self.pos + 1].kind == TokenKind::Newline;
        if is_string {
            self.pos += 2;
        }
        is_string
    }

    /// `module import name [as alias], ...` to the end of the line, after `from`.
    fn import_from(&mut self, line: usize) -> Result<Item, ParseError> {
        let module = self.dotted()?;
        self.expect(TokenKind::Keyword(Keyword::Import))?;
        let mut names = Vec::new();
        loop {
            let name = self.name()?;
            let alias = if self.eat(&TokenKind::Keyword(Keyword::As)) {
                Some(self.name()?)
            } else {
                None
            };
            names.push((name, alias));
            if !self.eat(&TokenKind::Comma) {
                break;
            }
        }
        self.expect(TokenKind::Newline)?;

        Ok(Item::FromImport {
            line,
            module,
            names,
        })
    }

    /// A `def` or `class` and any decorators, read only far enough to name it: its
    /// tokens run to its header line's end and then through its indented block.
    fn definition(&mut self, line: usize) -> Result<Item, ParseError> {
        let start = self.pos;
        while self.eat(&TokenKind::At) {
            self.skip_line();
        }

        let Token { kind, .. } = self.advance();
        let name = self.name()?;
        self.skip_line();
        if self.eat(&TokenKind::Indent) {
            let mut depth = 1;
            while depth > 0 {
                match self.advance().kind {
                    TokenKind::Indent => depth += 1,
                    TokenKind::Dedent => depth -= 1,
                    TokenKind::Eof => bail!(line, "unterminated block"),
                    _ => {}
                }
            }
        }

        match kind {
            TokenKind::Keyword(Keyword::Def) => {
                let mut tokens = self.tokens[start..self.pos].to_vec();
                tokens.push(Token::new(TokenKind::Eof, self.tokens[self.pos - 1].line));
                Ok(Item::Function(FunctionSource { line, name, tokens }))
            }
            TokenKind::Keyword(Keyword::Class) => {
                let mut tokens = self.tokens[start..self.pos].to_vec();
                tokens.push(Token::new(TokenKind::Eof, self.tokens[self.pos - 1].line));
                Ok(Item::Class(ClassSource { line, name, tokens }))
            }
            other => bail!(
                line,
                "expected `def` or `class` after a decorator, found {other}"
            ),
        }
    }

    /// Advances past the end of the current logical line.
    fn skip_line(&mut self) {
        while !matches!(self.advance().kind, TokenKind::Newline | TokenKind::Eof) {}
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

    /// `@decorator`s, then `def name(params):` and its indented body.
    fn function(&mut self) -> Result<Function, ParseError> {
        let line = self.line();
        let mut decorators = Vec::new();
        while self.eat(&TokenKind::At) {
            decorators.push(self.dotted()?);
            self.expect(TokenKind::Newline)?;
        }

        self.expect(TokenKind::Keyword(Keyword::Def))?;
        let name = self.name()?;
        self.expect(TokenKind::LParen)?;
        let params = self.comma_list(TokenKind::RParen, Self::param)?;
        self.expect(TokenKind::Colon)?;
        self.expect(TokenKind::Newline)?;
        let body = self.block()?;

        Ok(Function {
            line,
            decorators,
            name,
            params,
            body,
        })
    }

    /// `class name[(bases)]:` and its indented body of docstrings, attributes
    /// assigned and methods.
    fn class(&mut self) -> Result<Class, ParseError> {
        self.expect(TokenKind::Keyword(Keyword::Class))?;
        self.name()?;
        let bases = if self.eat(&TokenKind::LParen) {
            self.comma_list(TokenKind::RParen, Self::dotted)?
        } else {
            Vec::new()
        };
        self.expect(TokenKind::Colon)?;
        self.expect(TokenKind::Newline)?;
        self.expect(TokenKind::Indent)?;

        let mut class = Class {
            bases,
            attributes: Vec::new(),
            methods: Vec::new(),
        };
        while !self.eat(&TokenKind::Dedent) {
            if self.docstring() {
                continue;
            }
            let line = self.line();
            if matches!(
                self.peek(),
                TokenKind::At | TokenKind::Keyword(Keyword::Def)
            ) {
                let Item::Function(method) = self.definition(line)? else {
                    bail!(line, "expected a method");
                };
                class.methods.push(method);
                continue;
            }
            match self.statement()? {
                Stmt::Assign {
                    line,
                    target: Target::Name(name),
                    value,
                } => class.attributes.push((line, name, value)),
                _ => bail!(
                    line,
                    "a class body may only assign names and define methods"
                ),
            }
        }
        Ok(class)
    }

    /// `name [= default]`.
    fn param(&mut self) -> Result<Param, ParseError> {
        let name = self.name()?;
        let default = if self.eat(&TokenKind::Equals) {
            Some(self.expr()?)
        } else {
            None
        };
        Ok(Param { name, default })
    }

    /// An indented block's statements; a statement of only a string, such as a
    /// docstring, does nothing and is dropped.
    fn block(&mut self) -> Result<Vec<Stmt>, ParseError> {
        self.expect(TokenKind::Indent)?;
        let mut body = Vec::new();
        while !self.eat(&TokenKind::Dedent) {
            if !self.docstring() {
                body.push(self.statement()?);
            }
        }
        Ok(body)
    }

    fn statement(&mut self) -> Result<Stmt, ParseError> {
        let line = self.line();

        if self.eat(&TokenKind::Keyword(Keyword::Assert)) {
            let test = self.expr()?;
            if self.eat(&TokenKind::Comma) {
                self.expect(TokenKind::Str)?;
                while self.eat(&TokenKind::Str) {}
            }
            self.expect(TokenKind::Newline)?;
            return Ok(Stmt::Assert { line, test });
        }

        if self.eat(&TokenKind::Keyword(Keyword::If)) {
            return self.if_statement(line);
        }

        if self.eat(&TokenKind::Keyword(Keyword::With)) {
            let context = self.expr()?;
            self.expect(TokenKind::Colon)?;
            self.expect(TokenKind::Newline)?;
            let body = self.block()?;
            return Ok(Stmt::With {
                line,
                context,
                body,
            });
        }

        if self.eat(&TokenKind::Keyword(Keyword::For)) {
            let var = self.name()?;
            self.expect(TokenKind::Keyword(Keyword::In))?;
            let iterable = self.expr()?;
            self.expect(TokenKind::Colon)?;
            self.expect(TokenKind::Newline)?;
            let body = self.block()?;
            return Ok(Stmt::For {
                line,
                var,
                iterable,
                body,
            });
        }

        if self.eat(&TokenKind::Keyword(Keyword::Return)) {
            if self.eat(&TokenKind::Newline) {
                return Ok(Stmt::Return { line, value: None });
            }
            let value = self.expr()?;
            self.expect(TokenKind::Newline)?;
            return Ok(Stmt::Return {
                line,
                value: Some(value),
            });
        }

        let value = self.expr_list()?;
        if let &TokenKind::AugAssign(op) = self.peek() {
            self.advance();
            let target = target(value, line)?;
            let value = self.expr()?;
            self.expect(TokenKind::Newline)?;
            return augmented(target, op, value, line);
        }
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

    /// `test:` and its block after `if` or `elif`, then any `elif` or `else`.
    fn if_statement(&mut self, line: usize) -> Result<Stmt, ParseError> {
        let test = self.expr()?;
        self.expect(TokenKind::Colon)?;
        self.expect(TokenKind::Newline)?;
        let body = self.block()?;

        let elif_line = self.line();
        let orelse = if self.eat(&TokenKind::Keyword(Keyword::Elif)) {
            vec![self.if_statement(elif_line)?]
        } else if self.eat(&TokenKind::Keyword(Keyword::Else)) {
            self.expect(TokenKind::Colon)?;
            self.expect(TokenKind::Newline)?;
            self.block()?
        } else {
            Vec::new()
        };
        Ok(Stmt::If {
            line,
            test,
            body,
            orelse,
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

    /// An expression, by Python's precedence: `or`, `and`, `not`, comparisons, `&`,
    /// `+` and `-`, `*`, `//` and `%`, unary `-` and `~`, then a primary.
    fn expr(&mut self) -> Result<Expr, ParseError> {
        let mut lhs = self.conjunction()?;
        while self.eat(&TokenKind::Keyword(Keyword::Or)) {
            let rhs = self.conjunction()?;
            lhs = Expr::Logical {
                op: LogicalOp::Or,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
            };
        }
        Ok(lhs)
    }

    fn conjunction(&mut self) -> Result<Expr, ParseError> {
        let mut lhs = self.negation()?;
        while self.eat(&TokenKind::Keyword(Keyword::And)) {
            let rhs = self.negation()?;
            lhs = Expr::Logical {
                op: LogicalOp::And,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
            };
        }
        Ok(lhs)
    }

    fn negation(&mut self) -> Result<Expr, ParseError> {
        if self.eat(&TokenKind::Keyword(Keyword::Not)) {
            let operand = self.negation()?;
            return Ok(Expr::Unary {
                op: UnaryOp::Not,
                operand: Box::new(operand),
            });
        }
        self.comparison()
    }

    fn comparison(&mut self) -> Result<Expr, ParseError> {
        let first = self.bit_and()?;
        let mut rest = Vec::new();
        while let &TokenKind::Compare(op) = self.peek() {
            self.advance();
            rest.push((op, self.bit_and()?));
        }

        if rest.is_empty() {
            return Ok(first);
        }
        Ok(Expr::Compare {
            first: Box::new(first),
            rest,
        })
    }

    fn bit_and(&mut self) -> Result<Expr, ParseError> {
        self.binary(&[BinOp::BitAnd], Self::sum)
    }

    fn sum(&mut self) -> Result<Expr, ParseError> {
        self.binary(&[BinOp::Add, BinOp::Sub], Self::term)
    }

    fn term(&mut self) -> Result<Expr, ParseError> {
        self.binary(&[BinOp::Mul, BinOp::FloorDiv, BinOp::Mod], Self::factor)
    }

    /// `operand op operand ...` for the `ops` of one precedence level, left to right.
    fn binary(
        &mut self,
        ops: &[BinOp],
        operand: fn(&mut Self) -> Result<Expr, ParseError>,
    ) -> Result<Expr, ParseError> {
        let mut lhs = operand(self)?;
        loop {
            let op = match self.peek() {
                &TokenKind::Operator(op) if ops.contains(&op) => op,
                _ => return Ok(lhs),
            };
            self.advance();
            let rhs = operand(self)?;
            lhs = Expr::Binary {
                op,
                lhs: Box::new(lhs),
                rhs: Box::new(rhs),
            };
        }
    }

    /// A primary, or `-` or `~` before a factor.
    fn factor(&mut self) -> Result<Expr, ParseError> {
        let op = match self.peek() {
            TokenKind::Operator(BinOp::Sub) => UnaryOp::Neg,
            TokenKind::Tilde => UnaryOp::Invert,
            _ => return self.primary(),
        };
        self.advance();
        let operand = self.factor()?;
        Ok(Expr::Unary {
            op,
            operand: Box::new(operand),
        })
    }

    /// A literal, a dotted name, a call, or a parenthesized expression or tuple, then any `[...]`.
    fn primary(&mut self) -> Result<Expr, ParseError> {
        let Token { kind, line } = self.advance();
        let mut base = match kind {
            TokenKind::Int(value) => Expr::Int(value),
            TokenKind::Float(value) => Expr::Float(value),
            TokenKind::Bool(value) => Expr::Bool(value),
            TokenKind::Keyword(Keyword::None) => Expr::None,
            TokenKind::Name(head) => {
                let name = self.attributes(head)?;
                if self.eat(&TokenKind::LParen) {
                    Expr::Call(self.call(name, line)?)
                } else {
                    Expr::Name(name)
                }
            }
            TokenKind::LParen => self.parenthesized()?,
            TokenKind::LBracket => Expr::List(self.comma_list(TokenKind::RBracket, Self::expr)?),
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
