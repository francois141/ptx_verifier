//! Lexer for the spec language: `dim`/`array` declarations and
//! `NAME[vars] = expr;` output equations. ASCII-only, matching PTX's own
//! source-file convention in this codebase.

use std::fmt;

use volta_common::Span;
use volta_common::report::Locate;

#[derive(Debug, Clone, PartialEq)]
pub enum TokenKind {
    Ident(String),
    Int(u64),
    Float(f64),
    LBracket,
    RBracket,
    LParen,
    RParen,
    Comma,
    Semicolon,
    Equals,
    Plus,
    Minus,
    Star,
    Slash,
    DotDot,
    Eof,
}

impl fmt::Display for TokenKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TokenKind::Ident(s) => write!(f, "identifier '{}'", s),
            TokenKind::Int(v) => write!(f, "integer '{}'", v),
            TokenKind::Float(v) => write!(f, "float '{}'", v),
            TokenKind::LBracket => write!(f, "'['"),
            TokenKind::RBracket => write!(f, "']'"),
            TokenKind::LParen => write!(f, "'('"),
            TokenKind::RParen => write!(f, "')'"),
            TokenKind::Comma => write!(f, "','"),
            TokenKind::Semicolon => write!(f, "';'"),
            TokenKind::Equals => write!(f, "'='"),
            TokenKind::Plus => write!(f, "'+'"),
            TokenKind::Minus => write!(f, "'-'"),
            TokenKind::Star => write!(f, "'*'"),
            TokenKind::Slash => write!(f, "'/'"),
            TokenKind::DotDot => write!(f, "'..'"),
            TokenKind::Eof => write!(f, "end of file"),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Token {
    pub kind: TokenKind,
    pub span: Span,
}

#[derive(Debug)]
pub enum LexErrorKind {
    UnexpectedChar(char),
    InvalidNumber(String),
}

impl fmt::Display for LexErrorKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            LexErrorKind::UnexpectedChar(c) => write!(f, "unexpected character '{}'", c),
            LexErrorKind::InvalidNumber(s) => write!(f, "invalid number literal '{}'", s),
        }
    }
}

impl std::error::Error for LexErrorKind {}

pub struct Lexer<'a> {
    src: &'a str,
    bytes: &'a [u8],
    pos: usize,
}

impl<'a> Lexer<'a> {
    pub fn new(src: &'a str) -> Self {
        Lexer {
            src,
            bytes: src.as_bytes(),
            pos: 0,
        }
    }

    fn peek_byte(&self) -> Option<u8> {
        self.bytes.get(self.pos).copied()
    }

    fn peek_byte_at(&self, offset: usize) -> Option<u8> {
        self.bytes.get(self.pos + offset).copied()
    }

    fn skip_trivia(&mut self) {
        loop {
            match self.peek_byte() {
                Some(b' ') | Some(b'\t') | Some(b'\r') | Some(b'\n') => self.pos += 1,
                Some(b'/') if self.peek_byte_at(1) == Some(b'/') => {
                    while !matches!(self.peek_byte(), None | Some(b'\n')) {
                        self.pos += 1;
                    }
                }
                _ => break,
            }
        }
    }

    fn lex_number(&mut self) -> Result<TokenKind, LexErrorKind> {
        let start = self.pos;
        while matches!(self.peek_byte(), Some(b'0'..=b'9')) {
            self.pos += 1;
        }
        let mut is_float = false;
        // A '.' starts a fractional part only when followed by a digit -
        // otherwise it's the start of a separate ".." range token.
        if self.peek_byte() == Some(b'.') && matches!(self.peek_byte_at(1), Some(b'0'..=b'9')) {
            is_float = true;
            self.pos += 1;
            while matches!(self.peek_byte(), Some(b'0'..=b'9')) {
                self.pos += 1;
            }
        }
        let text = &self.src[start..self.pos];
        if is_float {
            text.parse::<f64>()
                .map(TokenKind::Float)
                .map_err(|_| LexErrorKind::InvalidNumber(text.to_string()))
        } else {
            text.parse::<u64>()
                .map(TokenKind::Int)
                .map_err(|_| LexErrorKind::InvalidNumber(text.to_string()))
        }
    }

    fn lex_ident(&mut self) -> TokenKind {
        let start = self.pos;
        while matches!(
            self.peek_byte(),
            Some(b'a'..=b'z' | b'A'..=b'Z' | b'0'..=b'9' | b'_')
        ) {
            self.pos += 1;
        }
        TokenKind::Ident(self.src[start..self.pos].to_string())
    }

    /// Tokenize the whole input, ending with one `Eof` token.
    pub fn tokenize(mut self) -> Result<Vec<Token>, Locate<LexErrorKind>> {
        let mut tokens = Vec::new();
        loop {
            self.skip_trivia();
            let start = self.pos;
            let Some(b) = self.peek_byte() else {
                tokens.push(Token {
                    kind: TokenKind::Eof,
                    span: Span(start, start),
                });
                break;
            };
            let kind = match b {
                b'0'..=b'9' => self.lex_number().map_err(|e| Locate {
                    path: None,
                    span: Some(Span(start, self.pos)),
                    error: e,
                })?,
                b'a'..=b'z' | b'A'..=b'Z' | b'_' => self.lex_ident(),
                b'[' => {
                    self.pos += 1;
                    TokenKind::LBracket
                }
                b']' => {
                    self.pos += 1;
                    TokenKind::RBracket
                }
                b'(' => {
                    self.pos += 1;
                    TokenKind::LParen
                }
                b')' => {
                    self.pos += 1;
                    TokenKind::RParen
                }
                b',' => {
                    self.pos += 1;
                    TokenKind::Comma
                }
                b';' => {
                    self.pos += 1;
                    TokenKind::Semicolon
                }
                b'=' => {
                    self.pos += 1;
                    TokenKind::Equals
                }
                b'+' => {
                    self.pos += 1;
                    TokenKind::Plus
                }
                b'-' => {
                    self.pos += 1;
                    TokenKind::Minus
                }
                b'*' => {
                    self.pos += 1;
                    TokenKind::Star
                }
                b'/' => {
                    self.pos += 1;
                    TokenKind::Slash
                }
                b'.' if self.peek_byte_at(1) == Some(b'.') => {
                    self.pos += 2;
                    TokenKind::DotDot
                }
                other => {
                    return Err(Locate {
                        path: None,
                        span: Some(Span(start, start + 1)),
                        error: LexErrorKind::UnexpectedChar(other as char),
                    });
                }
            };
            tokens.push(Token {
                kind,
                span: Span(start, self.pos),
            });
        }
        Ok(tokens)
    }
}
