//! Python tokens with Python's NEWLINE/INDENT/DEDENT structure. Every file of
//! the NKI samples tokenizes, unsupported syntax included: what the subset does
//! not support becomes an `Unsupported` token, an error only where it is parsed.

use std::fmt;

use super::ast::Scalar;
use super::error::{ParseError, bail};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Keyword {
    Import,
    From,
    As,
    Def,
    Class,
    Assert,
    For,
    In,
    Return,
}

impl Keyword {
    fn from_word(word: &str) -> Option<Self> {
        match word {
            "import" => Some(Self::Import),
            "from" => Some(Self::From),
            "as" => Some(Self::As),
            "def" => Some(Self::Def),
            "class" => Some(Self::Class),
            "assert" => Some(Self::Assert),
            "for" => Some(Self::For),
            "in" => Some(Self::In),
            "return" => Some(Self::Return),
            _ => None,
        }
    }

    fn text(self) -> &'static str {
        match self {
            Self::Import => "import",
            Self::From => "from",
            Self::As => "as",
            Self::Def => "def",
            Self::Class => "class",
            Self::Assert => "assert",
            Self::For => "for",
            Self::In => "in",
            Self::Return => "return",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CmpOp {
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
}

impl CmpOp {
    pub fn text(self) -> &'static str {
        match self {
            Self::Eq => "==",
            Self::Ne => "!=",
            Self::Lt => "<",
            Self::Le => "<=",
            Self::Gt => ">",
            Self::Ge => ">=",
        }
    }
}

/// Python's other keywords, `Unsupported` tokens rather than names.
const UNSUPPORTED_KEYWORDS: [&str; 26] = [
    "False", "None", "True", "and", "async", "await", "break", "continue", "del", "elif", "else",
    "except", "finally", "global", "if", "is", "lambda", "nonlocal", "not", "or", "pass", "raise",
    "try", "while", "with", "yield",
];

/// The prefixes a string literal may carry, e.g. `f"..."` or `rb'...'`.
const STRING_PREFIXES: [&str; 8] = ["r", "b", "u", "f", "rb", "br", "fr", "rf"];

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TokenKind {
    Name(String),
    Keyword(Keyword),
    Int(u64),
    Float(Scalar),
    /// A string literal; its text is never read, so it is not kept.
    Str,
    LParen,
    RParen,
    LBracket,
    RBracket,
    Comma,
    Equals,
    /// A comparison operator: `==`, `!=`, `<`, `<=`, `>` or `>=`.
    Compare(CmpOp),
    Dot,
    Colon,
    At,
    Star,
    Plus,
    SlashSlash,
    /// Source the subset does not support: a keyword, number or operator, e.g. `if` or `-`.
    Unsupported(String),
    /// The end of a logical line.
    Newline,
    Indent,
    Dedent,
    Eof,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Token {
    pub kind: TokenKind,
    /// 1-based source line.
    pub line: usize,
}

impl Token {
    pub fn new(kind: TokenKind, line: usize) -> Self {
        Self { kind, line }
    }
}

impl fmt::Display for TokenKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Name(name) => write!(f, "`{name}`"),
            Self::Keyword(keyword) => write!(f, "`{}`", keyword.text()),
            Self::Int(value) => write!(f, "`{value}`"),
            Self::Float(value) => write!(f, "`{value}`"),
            Self::Str => f.write_str("a string"),
            Self::LParen => f.write_str("`(`"),
            Self::RParen => f.write_str("`)`"),
            Self::LBracket => f.write_str("`[`"),
            Self::RBracket => f.write_str("`]`"),
            Self::Comma => f.write_str("`,`"),
            Self::Equals => f.write_str("`=`"),
            Self::Compare(op) => write!(f, "`{}`", op.text()),
            Self::Dot => f.write_str("`.`"),
            Self::Colon => f.write_str("`:`"),
            Self::At => f.write_str("`@`"),
            Self::Star => f.write_str("`*`"),
            Self::Plus => f.write_str("`+`"),
            Self::SlashSlash => f.write_str("`//`"),
            Self::Unsupported(text) => write!(f, "the unsupported `{text}`"),
            Self::Newline => f.write_str("end of line"),
            Self::Indent => f.write_str("an indented block"),
            Self::Dedent => f.write_str("end of block"),
            Self::Eof => f.write_str("end of file"),
        }
    }
}

/// The tokens of `source`, ending with `Eof`.
pub fn tokenize(source: &str) -> Result<Vec<Token>, ParseError> {
    let mut lexer = Lexer {
        rest: source,
        line: 1,
        tokens: Vec::new(),
        indents: vec![0],
        brackets: Vec::new(),
    };
    lexer.run()?;
    Ok(lexer.tokens)
}

struct Lexer<'a> {
    /// The source not yet scanned.
    rest: &'a str,
    line: usize,
    tokens: Vec<Token>,
    /// The widths of the open blocks, increasing from the outermost 0, which never closes.
    indents: Vec<usize>,
    /// Each open `(`, `[` or `{` and its line: until they close, lines join into one.
    brackets: Vec<(char, usize)>,
}

impl Lexer<'_> {
    fn run(&mut self) -> Result<(), ParseError> {
        while !self.rest.is_empty() {
            self.logical_line()?;
        }
        if let Some(&(open, line)) = self.brackets.first() {
            bail!(line, "unclosed `{open}`");
        }
        for _ in 1..self.indents.len() {
            self.push(TokenKind::Dedent);
        }
        self.push(TokenKind::Eof);
        Ok(())
    }

    /// One logical line from its indentation through its end, joining physical lines
    /// inside brackets and strings and after a `\`. A blank or comment-only line yields nothing.
    fn logical_line(&mut self) -> Result<(), ParseError> {
        let body = self.rest.trim_start_matches(' ');
        let width = self.rest.len() - body.len();
        self.rest = body.trim_start_matches(['\t', '\x0c', ' ']);
        if self.at_line_end() {
            self.end_physical_line();
            return Ok(());
        }
        if self.rest.len() != body.len() {
            bail!(self.line, "indentation must use spaces only");
        }
        self.indentation(width)?;

        loop {
            self.rest = self.rest.trim_start_matches([' ', '\t', '\x0c']);
            if let Some(after) = self.rest.strip_prefix("\\\n") {
                self.rest = after;
                self.line += 1;
                continue;
            }
            if !self.at_line_end() {
                self.token()?;
                continue;
            }
            if self.brackets.is_empty() {
                self.push(TokenKind::Newline);
                self.end_physical_line();
                return Ok(());
            }
            self.end_physical_line();
            if self.rest.is_empty() {
                return Ok(());
            }
        }
    }

    /// Whether only a comment, if anything, is left on the physical line.
    fn at_line_end(&self) -> bool {
        self.rest.is_empty() || self.rest.starts_with(['#', '\n', '\r'])
    }

    /// Skip the rest of the physical line, comment included, and its line break.
    fn end_physical_line(&mut self) {
        let end = self.rest.find('\n').map_or(self.rest.len(), |at| at + 1);
        self.rest = &self.rest[end..];
        self.line += 1;
    }

    /// The `Indent` or `Dedent`s a logical line of indentation `width` opens with.
    fn indentation(&mut self, width: usize) -> Result<(), ParseError> {
        let innermost = self.indents.last().copied().unwrap_or(0);
        if width > innermost {
            self.indents.push(width);
            self.push(TokenKind::Indent);
            return Ok(());
        }

        let Some(level) = self.indents.iter().position(|&open| open == width) else {
            bail!(
                self.line,
                "unindent does not match any outer indentation level"
            );
        };
        for _ in level + 1..self.indents.len() {
            self.push(TokenKind::Dedent);
        }
        self.indents.truncate(level + 1);
        Ok(())
    }

    fn token(&mut self) -> Result<(), ParseError> {
        let c = self.rest.chars().next().expect("not at the line's end");
        let (kind, len) = match c {
            '(' | '[' | '{' => {
                self.brackets.push((c, self.line));
                let kind = match c {
                    '(' => TokenKind::LParen,
                    '[' => TokenKind::LBracket,
                    _ => TokenKind::Unsupported("{".into()),
                };
                (kind, 1)
            }
            ')' | ']' | '}' => {
                let (open, kind) = match c {
                    ')' => ('(', TokenKind::RParen),
                    ']' => ('[', TokenKind::RBracket),
                    _ => ('{', TokenKind::Unsupported("}".into())),
                };
                if self.brackets.pop().map(|(bracket, _)| bracket) != Some(open) {
                    bail!(self.line, "unmatched `{c}`");
                }
                (kind, 1)
            }
            '\'' | '"' => return self.string(0),
            ',' => (TokenKind::Comma, 1),
            '=' if self.rest.starts_with("==") => (TokenKind::Compare(CmpOp::Eq), 2),
            '=' => (TokenKind::Equals, 1),
            '!' if self.rest.starts_with("!=") => (TokenKind::Compare(CmpOp::Ne), 2),
            '<' if self.rest.starts_with("<=") => (TokenKind::Compare(CmpOp::Le), 2),
            '<' => (TokenKind::Compare(CmpOp::Lt), 1),
            '>' if self.rest.starts_with(">=") => (TokenKind::Compare(CmpOp::Ge), 2),
            '>' => (TokenKind::Compare(CmpOp::Gt), 1),
            ':' => (TokenKind::Colon, 1),
            '@' => (TokenKind::At, 1),
            '*' => (TokenKind::Star, 1),
            '+' => (TokenKind::Plus, 1),
            '/' if self.rest.starts_with("//") => (TokenKind::SlashSlash, 2),
            // A number takes the letters and dots after it, so `1.0` is one token.
            _ if c.is_ascii_digit() || (c == '.' && self.rest[1..].starts_with(is_digit)) => {
                let len = run(self.rest, |c| {
                    c == '_' || c == '.' || c.is_ascii_alphanumeric()
                });
                (number(&self.rest[..len]), len)
            }
            '.' => (TokenKind::Dot, 1),
            _ if c == '_' || c.is_alphabetic() => {
                let len = run(self.rest, |c| c == '_' || c.is_alphanumeric());
                let word = &self.rest[..len];
                let prefix = STRING_PREFIXES.contains(&word.to_ascii_lowercase().as_str());
                if prefix && self.rest[len..].starts_with(['\'', '"']) {
                    return self.string(len);
                }
                (self::word(word), len)
            }
            _ => (TokenKind::Unsupported(c.into()), c.len_utf8()),
        };
        self.push(kind);
        self.rest = &self.rest[len..];
        Ok(())
    }

    /// A string literal after its `prefix_len`-byte prefix, quoted singly or by a triple
    /// quote; only a triple-quoted one may span lines. Its text is skipped, not read.
    fn string(&mut self, prefix_len: usize) -> Result<(), ParseError> {
        let line = self.line;
        let body = &self.rest[prefix_len..];
        let quote = if body.starts_with("\"\"\"") || body.starts_with("'''") {
            &body[..3]
        } else {
            &body[..1]
        };

        let text = &body[quote.len()..];
        let mut chars = text.char_indices();
        let end = loop {
            let Some((at, c)) = chars.next() else {
                bail!(line, "unterminated string");
            };
            match c {
                // An escaped character, raw strings included, never closes the string.
                '\\' => {
                    if let Some((_, '\n')) = chars.next() {
                        self.line += 1;
                    }
                }
                '\n' if quote.len() == 1 => bail!(line, "unterminated string"),
                '\n' => self.line += 1,
                _ if text[at..].starts_with(quote) => break at,
                _ => {}
            }
        };

        self.tokens.push(Token::new(TokenKind::Str, line));
        self.rest = &text[end + quote.len()..];
        Ok(())
    }

    fn push(&mut self, kind: TokenKind) {
        self.tokens.push(Token::new(kind, self.line));
    }
}

fn is_digit(c: char) -> bool {
    c.is_ascii_digit()
}

/// The length of `text`'s longest prefix whose characters satisfy `accept`.
fn run(text: &str, accept: impl Fn(char) -> bool) -> usize {
    text.find(|c| !accept(c)).unwrap_or(text.len())
}

fn word(text: &str) -> TokenKind {
    if let Some(keyword) = Keyword::from_word(text) {
        return TokenKind::Keyword(keyword);
    }
    if UNSUPPORTED_KEYWORDS.contains(&text) {
        return TokenKind::Unsupported(text.into());
    }
    TokenKind::Name(text.into())
}

/// A decimal integer or float; other bases, exponents and digit separators are unsupported.
fn number(literal: &str) -> TokenKind {
    if literal.contains('.') {
        if let Some(value) = literal.parse().ok().and_then(Scalar::new) {
            return TokenKind::Float(value);
        }
    } else {
        let leading_zero = literal.len() > 1 && literal.starts_with('0');
        if let (Ok(value), false) = (literal.parse(), leading_zero) {
            return TokenKind::Int(value);
        }
    }
    TokenKind::Unsupported(literal.into())
}
