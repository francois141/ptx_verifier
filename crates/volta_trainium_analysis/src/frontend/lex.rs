//! Python tokens of the NKI subset: names, keywords, integers and punctuation,
//! with Python's NEWLINE/INDENT/DEDENT structure. Strings are not tokens, so
//! every `#` starts a comment.

use std::fmt;

use super::error::{ParseError, bail};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Keyword {
    Import,
    As,
    Def,
    Assert,
}

impl Keyword {
    fn from_word(word: &str) -> Option<Self> {
        match word {
            "import" => Some(Self::Import),
            "as" => Some(Self::As),
            "def" => Some(Self::Def),
            "assert" => Some(Self::Assert),
            _ => None,
        }
    }

    fn text(self) -> &'static str {
        match self {
            Self::Import => "import",
            Self::As => "as",
            Self::Def => "def",
            Self::Assert => "assert",
        }
    }
}

/// Python's other keywords, rejected rather than read as names.
const UNSUPPORTED_KEYWORDS: [&str; 31] = [
    "False", "None", "True", "and", "async", "await", "break", "class", "continue", "del", "elif",
    "else", "except", "finally", "for", "from", "global", "if", "in", "is", "lambda", "nonlocal",
    "not", "or", "pass", "raise", "return", "try", "while", "with", "yield",
];

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TokenKind {
    Name(String),
    Keyword(Keyword),
    Int(u64),
    LParen,
    RParen,
    Comma,
    Equals,
    EqualsEquals,
    Dot,
    Colon,
    At,
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
    fn new(kind: TokenKind, line: usize) -> Self {
        Self { kind, line }
    }
}

impl fmt::Display for TokenKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Name(name) => write!(f, "`{name}`"),
            Self::Keyword(keyword) => write!(f, "`{}`", keyword.text()),
            Self::Int(value) => write!(f, "`{value}`"),
            Self::LParen => f.write_str("`(`"),
            Self::RParen => f.write_str("`)`"),
            Self::Comma => f.write_str("`,`"),
            Self::Equals => f.write_str("`=`"),
            Self::EqualsEquals => f.write_str("`==`"),
            Self::Dot => f.write_str("`.`"),
            Self::Colon => f.write_str("`:`"),
            Self::At => f.write_str("`@`"),
            Self::Newline => f.write_str("end of line"),
            Self::Indent => f.write_str("an indented block"),
            Self::Dedent => f.write_str("end of block"),
            Self::Eof => f.write_str("end of file"),
        }
    }
}

/// The tokens of `source`, ending with `Eof`.
pub fn tokenize(source: &str) -> Result<Vec<Token>, ParseError> {
    let mut tokens = Vec::new();
    let mut indents = vec![0];
    // The line of each open `(`: until they close, physical lines join into one logical line.
    let mut open_parens = Vec::new();

    for (index, text) in source.lines().enumerate() {
        let line = index + 1;
        let code = text.split_once('#').map_or(text, |(code, _)| code);
        if code.trim().is_empty() {
            continue;
        }

        if open_parens.is_empty() {
            for kind in indentation(code, line, &mut indents)? {
                tokens.push(Token::new(kind, line));
            }
        }

        for kind in scan(code, line)? {
            if kind == TokenKind::LParen {
                open_parens.push(line);
            }
            if kind == TokenKind::RParen && open_parens.pop().is_none() {
                bail!(line, "unmatched `)`");
            }
            tokens.push(Token::new(kind, line));
        }

        if open_parens.is_empty() {
            tokens.push(Token::new(TokenKind::Newline, line));
        }
    }

    if let Some(&line) = open_parens.first() {
        bail!(line, "unclosed `(`");
    }

    let last = source.lines().count().max(1);
    for _ in 1..indents.len() {
        tokens.push(Token::new(TokenKind::Dedent, last));
    }
    tokens.push(Token::new(TokenKind::Eof, last));
    Ok(tokens)
}

/// The `Indent` or `Dedent`s that start a logical line. `indents` holds the
/// widths of the open blocks, increasing from the outermost 0, which never closes.
fn indentation(
    code: &str,
    line: usize,
    indents: &mut Vec<usize>,
) -> Result<Vec<TokenKind>, ParseError> {
    let body = code.trim_start_matches(' ');
    if body.starts_with(char::is_whitespace) {
        bail!(line, "indentation must use spaces only");
    }
    let width = code.len() - body.len();

    let innermost = indents.last().copied().unwrap_or(0);
    if width > innermost {
        indents.push(width);
        return Ok(vec![TokenKind::Indent]);
    }

    let Some(level) = indents.iter().position(|&open| open == width) else {
        bail!(line, "unindent does not match any outer indentation level");
    };
    let closed = indents.len() - 1 - level;
    indents.truncate(level + 1);
    Ok(vec![TokenKind::Dedent; closed])
}

/// The tokens of one physical line, its comment removed.
fn scan(code: &str, line: usize) -> Result<Vec<TokenKind>, ParseError> {
    let mut kinds = Vec::new();
    let mut rest = code.trim_start_matches([' ', '\t']);

    while let Some(c) = rest.chars().next() {
        let (kind, len) = match c {
            '(' => (TokenKind::LParen, 1),
            ')' => (TokenKind::RParen, 1),
            ',' => (TokenKind::Comma, 1),
            '=' if rest.starts_with("==") => (TokenKind::EqualsEquals, 2),
            '=' => (TokenKind::Equals, 1),
            '.' => (TokenKind::Dot, 1),
            ':' => (TokenKind::Colon, 1),
            '@' => (TokenKind::At, 1),
            _ if c == '_' || c.is_ascii_alphabetic() => {
                let len = run(rest, |c| c == '_' || c.is_ascii_alphanumeric());
                (word(&rest[..len], line)?, len)
            }
            // A number takes the letters and dots after it, so `1.0` is one unsupported number.
            _ if c.is_ascii_digit() => {
                let len = run(rest, |c| c == '_' || c == '.' || c.is_ascii_alphanumeric());
                (integer(&rest[..len], line)?, len)
            }
            _ => bail!(line, "unsupported character `{c}`"),
        };

        kinds.push(kind);
        rest = rest[len..].trim_start_matches([' ', '\t']);
    }

    Ok(kinds)
}

/// The length of `text`'s longest prefix whose characters satisfy `accept`.
fn run(text: &str, accept: impl Fn(char) -> bool) -> usize {
    text.find(|c| !accept(c)).unwrap_or(text.len())
}

fn word(text: &str, line: usize) -> Result<TokenKind, ParseError> {
    if let Some(keyword) = Keyword::from_word(text) {
        return Ok(TokenKind::Keyword(keyword));
    }
    if UNSUPPORTED_KEYWORDS.contains(&text) {
        bail!(line, "unsupported keyword `{text}`");
    }
    Ok(TokenKind::Name(text.into()))
}

/// A decimal integer; floats, other bases and digit separators are unsupported.
fn integer(literal: &str, line: usize) -> Result<TokenKind, ParseError> {
    let leading_zero = literal.len() > 1 && literal.starts_with('0');
    match literal.parse() {
        Ok(value) if !leading_zero => Ok(TokenKind::Int(value)),
        _ => bail!(line, "unsupported number `{literal}`"),
    }
}
