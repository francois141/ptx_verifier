//! PTX Lexer
//!
//! A lexer for NVIDIA's Parallel Thread Execution (PTX) assembly language, based on the PTX 9.1 ISA
//! specification.

use std::fmt;

use crate::ascii::{AsciiChar, AsciiSliceExt, AsciiString, ascii};
use crate::instr::{self, InstrKind};

// The PTX documentation is rather vague, but, by experimentation with ptxas, the PTX lexer appears
// to work as follows:
//
// 1. Dot-prefixed qualifiers (.foo, .foo::bar, .foo::bar::baz) are lexed as single tokens with no
// whitespace allowed internally
//
// 2. Instruction mnemonics have a set of known compound forms (st.async, cp.async.bulk, etc.) that
// are lexed as single tokens with no whitespace allowed internally
//
// 3. Regular qualifiers (.weak, .u32, .global, etc.) are tokens that can be preceded by whitespace
//
// 4. Register component selectors (.x, .y, .z, .w) are tokens that can be preceded by whitespace
//
// The tricky part for a lexer implementation is distinguishing:
// - st.async -> single instruction token which must be written without spaces
// - st.weak -> instruction token `st` followed by a qualifier token `.weak` (whitespace allowed)
//
// This means the lexer should have a list of known multi-part instruction names like:
//   - st.async
//   - cp.async
//   - cp.async.bulk
//   - etc.
// And it should interpret the longest match as a single token.
//
// One additonal complication is that variable names are permitted to alias instruction mnemonics,
// e.g., `bar` could be a variable name or the synchronization instruction `bar`. The difference is
// contextual so the lexer always returns an `Ident` token and the parser must determine whether to
// break it up into an instruction mnemonic and qualifiers.

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DottedIdent {
    /// A simple identifier like `.version` or `.x`
    Simple(AsciiString),
    /// A qualified identifier like `.im2col::w::128`
    Qualified(Vec<AsciiString>),
}

impl DottedIdent {
    pub fn to_ascii_string(&self) -> AsciiString {
        match self {
            DottedIdent::Simple(s) => s.clone(),
            DottedIdent::Qualified(components) => crate::ascii::join(components, ascii("::")),
        }
    }
}

impl fmt::Display for DottedIdent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.to_ascii_string())
    }
}

/// A variable name or an instruction mnemonic followed by selectors or qualifiers respectively.
/// E.g., `%tid.x` or `st.async.weak`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ident {
    name: AsciiString,
}

impl Ident {
    pub fn new(name: AsciiString) -> Self {
        Self { name }
    }

    pub fn raw(&self) -> &[AsciiChar] {
        &self.name
    }

    pub fn into_inner(self) -> AsciiString {
        self.name
    }

    /// Try to interpret this identifier as a variable name with component selectors. E.g.,
    /// `%tid.x` would return variable name `%tid` and selector `x`. Note that the lexer
    /// may return the selector for a variable as a separate token.
    pub fn as_variable(&self) -> (&[AsciiChar], impl Iterator<Item = &[AsciiChar]>) {
        let slice = self.name.as_slice();
        let selectors = slice.split(|c| *c == AsciiChar::FullStop);
        (slice, selectors)
    }

    /// Try to interpret this identifier as a variable name with no component selectors. E.g.,
    /// `%tid` would return variable name `%tid`, but `%tid.x` would return `None`.
    pub fn as_variable_name(&self) -> Option<&[AsciiChar]> {
        let (name, mut selectors) = self.as_variable();
        if selectors.next().is_some() {
            None
        } else {
            Some(name)
        }
    }

    /// Try to interpret this identifier as an instruction mnemonic with qualifiers. E.g.,
    /// `st.async` would return instruction mnemonic `st.async` and qualifier `weak`. Note that the
    /// lexer may return an `Ident` with some qualifiers, followed by additional qualifiers as
    /// separate tokens.
    pub fn as_instr(&self) -> Option<(InstrKind, impl Iterator<Item = &[AsciiChar]>)> {
        let slice = self.name.as_slice();
        instr::get_instr_trie().get_ancestor(slice).map(|kind| {
            let mnemonic_len = kind.mnemonic().len();
            // Qualifiers start with '.', so splitting by '.' yields an empty first element
            let qualifiers = slice[mnemonic_len..]
                .split(|c| *c == AsciiChar::FullStop)
                .filter(|s| !s.is_empty());
            (kind, qualifiers)
        })
    }
}

impl fmt::Display for Ident {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.name.as_str())
    }
}

#[derive(Debug, Clone)]
struct FloatLitDecimalInner {
    repr: AsciiString,
    c: Option<(usize, usize)>,
    m: Option<(usize, usize)>,
    e: Option<(usize, usize)>,
    value: f64,
}

impl PartialEq for FloatLitDecimalInner {
    fn eq(&self, other: &Self) -> bool {
        self.repr == other.repr
    }
}

impl Eq for FloatLitDecimalInner {}

/// A float literal of the form: `<characteristic>.<mantissa>[eE]<exponent>`
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FloatLitDec {
    inner: Box<FloatLitDecimalInner>,
}

impl FloatLitDec {
    fn new(
        repr: &[AsciiChar],
        characteristic: Option<(usize, usize)>,
        mantissa: Option<(usize, usize)>,
        exponent: Option<(usize, usize)>,
    ) -> Self {
        Self {
            inner: Box::new(FloatLitDecimalInner {
                repr: repr.to_owned_ascii(),
                c: characteristic,
                m: mantissa,
                e: exponent,
                value: repr.as_str().parse().unwrap(),
            }),
        }
    }

    pub fn characteristic(&self) -> Option<&[AsciiChar]> {
        self.inner.c.map(|(start, end)| &self.ascii()[start..end])
    }

    pub fn mantissa(&self) -> Option<&[AsciiChar]> {
        self.inner.m.map(|(start, end)| &self.ascii()[start..end])
    }

    pub fn exponent(&self) -> Option<&[AsciiChar]> {
        self.inner.e.map(|(start, end)| &self.ascii()[start..end])
    }

    pub fn value(&self) -> f64 {
        self.inner.value
    }

    pub fn ascii(&self) -> &[AsciiChar] {
        self.inner.repr.as_slice()
    }
}

#[derive(Debug, Clone)]
struct FloatLitHex32Inner {
    repr: AsciiString,
    bits: u32,
}

impl PartialEq for FloatLitHex32Inner {
    fn eq(&self, other: &Self) -> bool {
        self.repr == other.repr
    }
}

impl Eq for FloatLitHex32Inner {}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FloatLitHex32 {
    inner: Box<FloatLitHex32Inner>,
}

impl FloatLitHex32 {
    fn new(repr: &[AsciiChar], bits: u32) -> Self {
        Self {
            inner: Box::new(FloatLitHex32Inner {
                bits,
                repr: repr.to_owned_ascii(),
            }),
        }
    }

    pub fn bits(&self) -> u32 {
        self.inner.bits
    }

    pub fn value(&self) -> f32 {
        f32::from_bits(self.bits())
    }

    pub fn ascii(&self) -> &[AsciiChar] {
        self.inner.repr.as_slice()
    }
}

#[derive(Debug, Clone)]
struct FloatLitHex64Inner {
    repr: AsciiString,
    bits: u64,
}

impl PartialEq for FloatLitHex64Inner {
    fn eq(&self, other: &Self) -> bool {
        self.repr == other.repr
    }
}

impl Eq for FloatLitHex64Inner {}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FloatLitHex64 {
    inner: Box<FloatLitHex64Inner>,
}

impl FloatLitHex64 {
    fn new(repr: &[AsciiChar], bits: u64) -> Self {
        Self {
            inner: Box::new(FloatLitHex64Inner {
                bits,
                repr: repr.to_owned_ascii(),
            }),
        }
    }

    pub fn bits(&self) -> u64 {
        self.inner.bits
    }

    pub fn value(&self) -> f64 {
        f64::from_bits(self.bits())
    }

    pub fn ascii(&self) -> &[AsciiChar] {
        self.inner.repr.as_slice()
    }
}

#[derive(Debug, Clone)]
struct IntLitSInner {
    value: i64,
    repr: AsciiString,
}

impl PartialEq for IntLitSInner {
    fn eq(&self, other: &Self) -> bool {
        self.repr == other.repr
    }
}

impl Eq for IntLitSInner {}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SIntLit {
    inner: Box<IntLitSInner>,
}

impl SIntLit {
    fn new(repr: &[AsciiChar], value: i64) -> Self {
        Self {
            inner: Box::new(IntLitSInner {
                value,
                repr: repr.to_owned_ascii(),
            }),
        }
    }

    pub fn value(&self) -> i64 {
        self.inner.value
    }

    pub fn ascii(&self) -> &[AsciiChar] {
        self.inner.repr.as_slice()
    }
}

#[derive(Debug, Clone)]
struct IntLitUInner {
    value: u64,
    repr: AsciiString,
}

impl PartialEq for IntLitUInner {
    fn eq(&self, other: &Self) -> bool {
        self.repr == other.repr
    }
}

impl Eq for IntLitUInner {}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UIntLit {
    inner: Box<IntLitUInner>,
}

impl UIntLit {
    fn new(repr: &[AsciiChar], value: u64) -> Self {
        Self {
            inner: Box::new(IntLitUInner {
                value,
                repr: repr.to_owned_ascii(),
            }),
        }
    }

    pub fn value(&self) -> u64 {
        self.inner.value
    }

    pub fn ascii(&self) -> &[AsciiChar] {
        self.inner.repr.as_slice()
    }
}

/// A float literal. We keep around the original representation of decimal floats because what might
/// appear a float to the context-insensitive lexer might appear something else to the parser.
/// Notably the version number in `.version x.y`
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FloatLit {
    Dec(FloatLitDec),
    Hex32(FloatLitHex32),
    Hex64(FloatLitHex64),
}

impl FloatLit {
    pub fn value(&self) -> f64 {
        match self {
            FloatLit::Dec(lit) => lit.value(),
            FloatLit::Hex32(lit) => lit.value() as f64,
            FloatLit::Hex64(lit) => lit.value(),
        }
    }

    pub fn ascii(&self) -> &[AsciiChar] {
        match self {
            FloatLit::Dec(lit) => lit.ascii(),
            FloatLit::Hex32(lit) => lit.ascii(),
            FloatLit::Hex64(lit) => lit.ascii(),
        }
    }
}

/// Token types for PTX
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Token {
    /// A user-defined identifier or instruction mnemonic (determined by parser)
    Ident(Ident),

    /// A directive (`.version`, `.target`, etc.), a component selector (`.x`, `.y`, `.z`, or `.w`),
    /// or an instruction modifier (`.weak`, `.u32`, etc.)
    DottedIdent(DottedIdent),

    /// Not a string literal; used in certain directives (currently `.file` and `.pragma`)
    String(AsciiString),

    // Literals
    SIntLit(SIntLit),
    UIntLit(UIntLit),
    FloatLit(FloatLit),

    // Punctuation
    Semicolon,
    Colon,
    Comma,
    At,

    // Delimiters
    LeftParen,
    RightParen,
    LeftBracket,
    RightBracket,
    LeftBrace,
    RightBrace,

    // Operators
    Plus,
    Minus,
    Bang,
    Tilde,
    Star,
    Slash,
    Percent,
    LeftShift,
    RightShift,
    Less,
    LessEquals,
    Greater,
    GreaterEquals,
    Equals,
    EqualsEquals,
    BangEquals,
    Ampersand,
    AmpersandAmpersand,
    Pipe,
    PipePipe,
    Caret,
    Question,
}

impl Token {
    /// Convert token to an ASCII string representation
    pub fn to_ascii_string(&self) -> AsciiString {
        let slice = match self {
            Token::SIntLit(v) => v.ascii(),
            Token::UIntLit(v) => v.ascii(),
            Token::FloatLit(v) => v.ascii(),
            Token::String(s) => {
                let mut result = AsciiString::new();
                result.push(AsciiChar::QuotationMark);
                result.push_slice(s);
                result.push(AsciiChar::QuotationMark);
                return result;
            }

            Token::Ident(s) => s.raw(),
            Token::DottedIdent(s) => {
                let mut result = AsciiString::new();
                result.push(AsciiChar::FullStop);
                result.push_slice(&s.to_ascii_string());
                return result;
            }

            Token::Semicolon => ascii(";"),
            Token::Colon => ascii(":"),
            Token::Comma => ascii(","),
            Token::At => ascii("@"),

            Token::LeftParen => ascii("("),
            Token::RightParen => ascii(")"),
            Token::LeftBracket => ascii("["),
            Token::RightBracket => ascii("]"),
            Token::LeftBrace => ascii("{"),
            Token::RightBrace => ascii("}"),

            Token::Plus => ascii("+"),
            Token::Minus => ascii("-"),
            Token::Bang => ascii("!"),
            Token::Tilde => ascii("~"),
            Token::Star => ascii("*"),
            Token::Slash => ascii("/"),
            Token::Percent => ascii("%"),
            Token::LeftShift => ascii("<<"),
            Token::RightShift => ascii(">>"),
            Token::Less => ascii("<"),
            Token::LessEquals => ascii("<="),
            Token::Greater => ascii(">"),
            Token::GreaterEquals => ascii(">="),
            Token::Equals => ascii("="),
            Token::EqualsEquals => ascii("=="),
            Token::BangEquals => ascii("!="),
            Token::Ampersand => ascii("&"),
            Token::AmpersandAmpersand => ascii("&&"),
            Token::Pipe => ascii("|"),
            Token::PipePipe => ascii("||"),
            Token::Caret => ascii("^"),
            Token::Question => ascii("?"),
        };
        slice.to_owned_ascii()
    }
}

impl fmt::Display for Token {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.to_ascii_string())
    }
}

fn consume_exact(pos: usize, src: &[AsciiChar], target: &[AsciiChar]) -> Option<usize> {
    if src[pos..].starts_with(target) {
        Some(pos + target.len())
    } else {
        None
    }
}

fn consume_one_of<'a, T>(
    pos: usize,
    src: &[AsciiChar],
    cases: &'a [(&[AsciiChar], T)],
) -> Option<(usize, &'a T)> {
    cases
        .iter()
        .filter_map(|(target, result)| consume_exact(pos, src, target).map(|end| (end, result)))
        .max_by_key(|&(end, _)| end)
}

fn consume_single_line_comment(mut pos: usize, src: &[AsciiChar]) -> Option<usize> {
    pos = consume_exact(pos, src, ascii("//"))?;

    while let Some(&c) = src.get(pos) {
        pos += 1;
        if c == AsciiChar::LineFeed {
            break;
        }
    }

    Some(pos)
}

fn consume_multi_line_comment(mut pos: usize, src: &[AsciiChar]) -> Option<usize> {
    pos = consume_exact(pos, src, ascii("/*"))?;

    while pos < src.len() {
        if let Some(new_pos) = consume_exact(pos, src, ascii("*/")) {
            return Some(new_pos);
        } else {
            pos += 1;
        }
    }

    Some(pos)
}

fn consume_whitespace(mut pos: usize, src: &[AsciiChar]) -> Option<usize> {
    if !src.get(pos)?.is_whitespace() {
        return None;
    }

    while let Some(&c) = src.get(pos) {
        if c.is_whitespace() {
            pos += 1;
        } else {
            break;
        }
    }

    Some(pos)
}

fn consume_trivia(mut pos: usize, src: &[AsciiChar]) -> usize {
    loop {
        if let Some(new_pos) = consume_whitespace(pos, src) {
            pos = new_pos;
            continue;
        }

        if let Some(new_pos) = consume_single_line_comment(pos, src) {
            pos = new_pos;
            continue;
        }

        if let Some(new_pos) = consume_multi_line_comment(pos, src) {
            pos = new_pos;
            continue;
        }

        return pos;
    }
}

fn hex_digit_value(c: AsciiChar) -> u64 {
    let b = c.to_u8();
    match b {
        b'0'..=b'9' => (b - b'0') as u64,
        b'a'..=b'f' => (b - b'a' + 10) as u64,
        b'A'..=b'F' => (b - b'A' + 10) as u64,
        _ => unreachable!(),
    }
}

/// Consume a decimal integer: [0-9]+U?
///
/// Note: This will also match numbers starting with 0 that should be octal.
fn consume_decimal_integer(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if !src.get(start).is_some_and(|c| c.is_digit()) {
        return None;
    }

    let mut pos = start + 1;
    while src.get(pos).is_some_and(|c| c.is_digit()) {
        pos += 1;
    }

    let mut value: u64 = 0;
    for &c in &src[start..pos] {
        value = value
            .wrapping_mul(10)
            .wrapping_add((c.to_u8() - b'0') as u64);
    }

    let token = if src.get(pos) == Some(&AsciiChar::CapitalU) {
        pos += 1;
        Token::UIntLit(UIntLit::new(&src[start..pos], value))
    } else {
        Token::SIntLit(SIntLit::new(&src[start..pos], value as i64))
    };

    Some((pos, token))
}

/// Consume a hexadecimal integer: 0[xX][0-9a-fA-F]+U?
fn consume_hexadecimal_integer(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if src.get(start) != Some(&AsciiChar::Digit0) {
        return None;
    }

    let next = *src.get(start + 1)?;
    if next != AsciiChar::SmallX && next != AsciiChar::CapitalX {
        return None;
    }

    let mut pos = start + 2;
    let digit_start = pos;

    if !src.get(pos).is_some_and(|c| c.is_hexdigit()) {
        // No hex digits after 0x
        return None;
    }

    pos += 1;

    while src.get(pos).is_some_and(|c| c.is_hexdigit()) {
        pos += 1;
    }

    let mut value: u64 = 0;
    for &c in &src[digit_start..pos] {
        value = value.wrapping_mul(16).wrapping_add(hex_digit_value(c));
    }

    let token = if src.get(pos) == Some(&AsciiChar::CapitalU) {
        pos += 1;
        Token::UIntLit(UIntLit::new(&src[start..pos], value))
    } else {
        Token::SIntLit(SIntLit::new(&src[start..pos], value as i64))
    };

    Some((pos, token))
}

/// Consume an octal integer: 0[0-7]*U?
//
/// Note: This will also match a standalone 0.
fn consume_octal_integer(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if src.get(start) != Some(&AsciiChar::Digit0) {
        return None;
    }

    let mut pos = start + 1;
    let digit_start = pos;

    while src.get(pos).is_some_and(|c| c.is_octdigit()) {
        pos += 1;
    }

    let mut value: u64 = 0;
    for &c in &src[digit_start..pos] {
        value = value
            .wrapping_mul(8)
            .wrapping_add((c.to_u8() - b'0') as u64);
    }

    let token = if src.get(pos) == Some(&AsciiChar::CapitalU) {
        pos += 1;
        Token::UIntLit(UIntLit::new(&src[start..pos], value))
    } else {
        Token::SIntLit(SIntLit::new(&src[start..pos], value as i64))
    };

    Some((pos, token))
}

/// Consume a binary integer: 0[bB][01]+U?
fn consume_binary_integer(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if src.get(start) != Some(&AsciiChar::Digit0) {
        return None;
    }

    let next = *src.get(start + 1)?;
    if next != AsciiChar::SmallB && next != AsciiChar::CapitalB {
        return None;
    }

    let mut pos = start + 2;
    let digit_start = pos;

    if !src.get(pos).is_some_and(|c| c.is_bindigit()) {
        // No binary digits after 0b
        return None;
    }

    pos += 1;

    while src.get(pos).is_some_and(|c| c.is_bindigit()) {
        pos += 1;
    }

    let mut value: u64 = 0;
    for &c in &src[digit_start..pos] {
        value = value
            .wrapping_mul(2)
            .wrapping_add((c.to_u8() - b'0') as u64);
    }

    let token = if src.get(pos) == Some(&AsciiChar::CapitalU) {
        pos += 1;
        Token::UIntLit(UIntLit::new(&src[start..pos], value))
    } else {
        Token::SIntLit(SIntLit::new(&src[start..pos], value as i64))
    };

    Some((pos, token))
}

/// Consume an integer literal in any format.
fn consume_integer(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    // Try hexadecimal first (0x...)
    if let Some(result) = consume_hexadecimal_integer(start, src) {
        return Some(result);
    }

    // Try binary (0b...)
    if let Some(result) = consume_binary_integer(start, src) {
        return Some(result);
    }

    // Try octal (0[0-7]...) -- note: this will match a standalone "0"
    if let Some(result) = consume_octal_integer(start, src) {
        return Some(result);
    }

    // Try decimal
    consume_decimal_integer(start, src)
}

/// Consume an exponent: [eE][+-]?[0-9]+
fn consume_exponent(mut pos: usize, src: &[AsciiChar]) -> Option<usize> {
    let c = *src.get(pos)?;
    if c != AsciiChar::SmallE && c != AsciiChar::CapitalE {
        return None;
    }

    pos += 1;

    if src.get(pos) == Some(&AsciiChar::PlusSign) || src.get(pos) == Some(&AsciiChar::HyphenMinus) {
        pos += 1;
    }

    // Must have at least one digit
    if !src.get(pos).is_some_and(|c| c.is_digit()) {
        return None;
    }

    while src.get(pos).is_some_and(|c| c.is_digit()) {
        pos += 1;
    }

    Some(pos)
}

/// Consume a decimal floating-point literal.
///
/// Formats:
/// - `.[0-9]+<exp>?`
/// - `[0-9]+.[0-9]*<exp>`
/// - `[0-9]+<exp>`
///
/// where
/// - `<exp> ::= [eE][+-]?[0-9]+`
fn consume_decimal_float(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    let c = *src.get(start)?;
    let starts_with_dot = c == AsciiChar::FullStop;

    if !starts_with_dot && !c.is_digit() {
        return None;
    }

    let mut characteristic = None;
    let mut mantissa = None;
    let mut exponent = None;

    let mut pos = start;

    if starts_with_dot {
        // Format: .[0-9]+<exp>?

        // Consume '.'
        pos += 1;

        let mantissa_start = pos;

        // Must have at least one digit after the dot
        if !src.get(pos).is_some_and(|c| c.is_digit()) {
            return None;
        }

        pos += 1;

        // Consume remaining digits
        while src.get(pos).is_some_and(|c| c.is_digit()) {
            pos += 1;
        }

        mantissa = Some((mantissa_start - start, pos - start));

        // Optional exponent
        if let Some(new_pos) = consume_exponent(pos, src) {
            // +1 to skip the 'e' or 'E'
            exponent = Some((pos + 1 - start, new_pos - start));
            pos = new_pos;
        }
    } else {
        // Starts with a digit. Possible formats:
        // - [0-9]+.[0-9]*<exp>
        // - [0-9]+<exp>

        // Consume leading digit
        pos += 1;

        // Consume remaining digits
        while src.get(pos).is_some_and(|c| c.is_digit()) {
            pos += 1;
        }

        characteristic = Some((0, pos - start));

        let next = src.get(pos).copied();
        let has_dot = next == Some(AsciiChar::FullStop);
        let has_exp = next == Some(AsciiChar::SmallE) || next == Some(AsciiChar::CapitalE);

        if !has_dot && !has_exp {
            return None;
        }

        if has_dot {
            // Consume '.'
            pos += 1;

            let mantissa_start = pos;

            // Optional digits after the dot
            while src.get(pos).is_some_and(|c| c.is_digit()) {
                pos += 1;
            }

            if pos > mantissa_start {
                mantissa = Some((mantissa_start - start, pos - start));
            }

            // Optional exponent
            if let Some(new_pos) = consume_exponent(pos, src) {
                // +1 to skip the 'e' or 'E'
                exponent = Some((pos + 1 - start, new_pos - start));
                pos = new_pos;
            }
        } else {
            // Must have exponent (`has_exp` is true), but it may be invalid (e.g., "1e" or "1e+")
            if let Some(new_pos) = consume_exponent(pos, src) {
                // +1 to skip the 'e' or 'E'
                exponent = Some((pos + 1 - start, new_pos - start));
                pos = new_pos;
            } else {
                return None;
            }
        }
    }

    Some((
        pos,
        Token::FloatLit(FloatLit::Dec(FloatLitDec::new(
            &src[start..pos],
            characteristic,
            mantissa,
            exponent,
        ))),
    ))
}

/// Consume a hex single-precision float: 0[fF][0-9a-fA-F]{8}
fn consume_hex_float_single(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if src.get(start) != Some(&AsciiChar::Digit0) {
        return None;
    }

    let next = *src.get(start + 1)?;
    if next != AsciiChar::SmallF && next != AsciiChar::CapitalF {
        return None;
    }

    let mut pos = start + 2;
    let digit_start = pos;

    // Count hex digits
    let mut count = 0;
    while pos < src.len() && src[pos].is_hexdigit() {
        count += 1;
        pos += 1;
    }

    // Must have exactly 8 hex digits
    if count != 8 {
        return None;
    }

    let mut bits: u32 = 0;
    for &c in &src[digit_start..pos] {
        bits = bits
            .wrapping_mul(16)
            .wrapping_add(hex_digit_value(c) as u32);
    }

    let lit = Token::FloatLit(FloatLit::Hex32(FloatLitHex32::new(&src[start..pos], bits)));
    Some((pos, lit))
}

/// Consume a hex double-precision float: 0[dD][0-9a-fA-F]{16}
fn consume_hex_float_double(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if src.get(start) != Some(&AsciiChar::Digit0) {
        return None;
    }

    let next = *src.get(start + 1)?;
    if next != AsciiChar::SmallD && next != AsciiChar::CapitalD {
        return None;
    }

    let mut pos = start + 2;
    let digit_start = pos;

    // Count hex digits
    let mut count = 0;
    while pos < src.len() && src[pos].is_hexdigit() {
        count += 1;
        pos += 1;
    }

    // Must have exactly 16 hex digits
    if count != 16 {
        return None;
    }

    let mut bits: u64 = 0;
    for &c in &src[digit_start..pos] {
        bits = bits.wrapping_mul(16).wrapping_add(hex_digit_value(c));
    }

    let lit = Token::FloatLit(FloatLit::Hex64(FloatLitHex64::new(&src[start..pos], bits)));
    Some((pos, lit))
}

/// Consume a floating-point literal in any format.
fn consume_float(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    // Try hex single-precision first (0f...)
    if let Some(result) = consume_hex_float_single(start, src) {
        return Some(result);
    }

    // Try hex double-precision (0d...)
    if let Some(result) = consume_hex_float_double(start, src) {
        return Some(result);
    }

    // Try decimal float
    consume_decimal_float(start, src)
}

/// Consume a numeric literal (integer or floating-point).
///
/// Integer formats:
/// - Hexadecimal: 0[xX][0-9a-fA-F]+U?
/// - Binary: 0[bB][01]+U?
/// - Octal: 0[0-7]*U?
/// - Decimal: [0-9]+U?
///
/// Floating-point formats:
/// - Decimal: .[0-9]+([eE][+-]?[0-9]+)?
/// - Decimal: [0-9]+.[0-9]*([eE][+-]?[0-9]+)?
/// - Decimal: [0-9]+[eE][+-]?[0-9]+
/// - Hex single (32-bit): 0[fF][0-9a-fA-F]{8}
/// - Hex double (64-bit): 0[dD][0-9a-fA-F]{16}
fn consume_number(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    // Try float first since the prefix of a float can be an integer but not vice versa
    if let Some(result) = consume_float(start, src) {
        return Some(result);
    }

    consume_integer(start, src)
}

/// Consume a string.
///
/// Strings are enclosed in double quotes. Escape sequences are not interpreted; the string is
/// stored verbatim.
///
/// Since the PTX documentation says it follows C syntax for comments and integers, one might
/// initially assume that PTX strings follow C-style escape conventions. However, experimentation
/// reveals that PTX does not interpret escape sequences in strings.
///
/// Strings are used in two notable places in PTX, the `.file` and `.pragma` directives.
///
/// - The pragma `"nounroll"` is valid, but `"noun\x72oll"` (where `\x72` = 'r') produces the
///   warning `Pragma 'noun\x72oll' unsupported`. If escapes were interpreted, this would become the
///   valid pragma `"nounroll"`. Furthermore, `"noun\\roll"` yields the warning
///   `Pragma 'noun\\roll' unsupported` (not `'noun\roll'`)
///
/// - `.file` directives ultimately affect the DWARF debug info. Experimentation shows that
///   backslashes are treated as path separators by `.file` (like forward slashes), not as escapes.
///
/// Finally, untermined strings result in a syntax error in ptxas, so we return `None` in that case.
fn consume_string(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    if src.get(start) != Some(&AsciiChar::QuotationMark) {
        return None;
    }

    let mut pos = start + 1;
    let mut result = AsciiString::new();

    while pos < src.len() {
        let c = src[pos];
        if c == AsciiChar::QuotationMark {
            pos += 1;
            return Some((pos, Token::String(result)));
        }

        result.push(c);
        pos += 1;
    }

    // Unterminated string
    None
}

// [a-zA-Z0-9_$]
fn is_followsym(c: AsciiChar) -> bool {
    c.is_alphanumeric() || c == AsciiChar::LowLine || c == AsciiChar::DollarSign
}

/// [a-zA-Z0-9_$]+
fn consume_followsyms(mut pos: usize, src: &[AsciiChar]) -> Option<(usize, AsciiString)> {
    let start = pos;

    if is_followsym(*src.get(pos)?) {
        pos += 1;
    } else {
        return None;
    }

    while let Some(&c) = src.get(pos) {
        if is_followsym(c) {
            pos += 1;
        } else {
            break;
        }
    }

    let ident = src[start..pos].to_owned().into();
    Some((pos, ident))
}

/// Attempt to consume an `Ident` or `DottedIdent` token.
fn consume_name(start: usize, src: &[AsciiChar]) -> Option<(usize, Token)> {
    let c = *src.get(start)?;

    // An identifier "[a-zA-Z]{followsym}*" or an instruction mnemonic
    if c.is_alphabetic() {
        let mut pos = start + 1;
        let mut seen_dot = false;
        while let Some(&c) = src.get(pos) {
            if c == AsciiChar::FullStop {
                seen_dot = true;
                pos += 1;
            } else if is_followsym(c) {
                pos += 1;
            } else if seen_dot
                && let Some(comp_start) = consume_exact(pos, src, ascii("::"))
                && let Some((comp_end, _)) = consume_followsyms(comp_start, src)
            {
                // A `::`-qualified component inside a dot-prefixed segment
                // of an instruction mnemonic, e.g. the `.L2::128B` of
                // `ld.global.L2::128B.f32`. Consumed only when another
                // component follows, mirroring the dotted-qualifier path
                // below (ptxas cases 3 and 4); a `::` before any dot is
                // not consumed (ptxas case 1: `s::t.async` is a syntax
                // error near ':').
                pos = comp_end;
            } else {
                break;
            }
        }

        return Some((
            pos,
            Token::Ident(Ident::new(src[start..pos].to_owned_ascii())),
        ));
    }

    // An identifier "{[_$%]{followsym}+"
    if c == AsciiChar::LowLine || c == AsciiChar::DollarSign || c == AsciiChar::PercentSign {
        let (end, rest) = consume_followsyms(start + 1, src)?;
        let mut ident = AsciiString::with_capacity(1 + rest.len());
        ident.push(c);
        ident.push_slice(&rest);
        return Some((end, Token::Ident(Ident::new(ident))));
    }

    // A directive, selector, or modifier (dotted identifier).
    //
    // Though all dotted identifiers that appear in the PTX spec are ".[a-zA-Z0-9_]", experimenting
    // with ptxas it appears that the lexer is tokenizing ".[a-zA-Z0-9_$]" as one thing. E.g.,
    // "st.we$ak" yields error "unknown modifier '.we$ak'".
    //
    // Some interesting cases:
    // 1. `s::t.async` yields "parsing error near ':': syntax error"
    // 2. `st.asy::nc` yields "unknown modifier '.asy::nc'"
    // 3. `st.async::` yields "parsing error near ':': syntax error"
    // 4. `st.async::$` yields "parsing error near ':': syntax error"
    // 5. `st.asy:nc` yields "parsing error near ':': syntax error"
    //
    // So it appears that if we see a dot (and only if we see a dot), we should try to consume a
    // series of "[a-zA-Z0-9_$]" separated by "::".
    if c == AsciiChar::FullStop {
        let (mut pos, comp) = consume_followsyms(start + 1, src)?;
        let mut comps = vec![comp];
        while let Some(comp_start) = consume_exact(pos, src, ascii("::")) {
            // Don't set `pos` until we find another component, per case (3) and (4) above.

            if let Some((comp_end, comp)) = consume_followsyms(comp_start, src) {
                pos = comp_end;
                comps.push(comp);
            } else {
                break;
            }
        }

        if comps.len() == 1 {
            let comp = comps.pop().unwrap();
            let ident = Token::DottedIdent(DottedIdent::Simple(comp));
            return Some((pos, ident));
        } else {
            let ident = Token::DottedIdent(DottedIdent::Qualified(comps));
            return Some((pos, ident));
        }
    }

    None
}

pub struct Lexer<'a> {
    src: &'a [AsciiChar],
    pos: usize,
}

impl<'a> Lexer<'a> {
    /// Create a new lexer for the given source code
    pub fn new(src: &'a [AsciiChar]) -> Self {
        Self { src, pos: 0 }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Error(pub usize);

impl<'a> Iterator for Lexer<'a> {
    type Item = Result<(usize, Token, usize), Error>;

    fn next(&mut self) -> Option<Self::Item> {
        self.pos = consume_trivia(self.pos, self.src);

        if self.pos == self.src.len() {
            return None;
        }

        if let Some((end, tok)) = consume_number(self.pos, self.src) {
            let start = self.pos;
            self.pos = end;
            return Some(Ok((start, tok, self.pos)));
        }

        if let Some((end, tok)) = consume_name(self.pos, self.src) {
            let start = self.pos;
            self.pos = end;
            return Some(Ok((start, tok, self.pos)));
        }

        if let Some((end, tok)) = consume_string(self.pos, self.src) {
            let start = self.pos;
            self.pos = end;
            return Some(Ok((start, tok, self.pos)));
        }

        if let Some((end, sym)) = consume_one_of(
            self.pos,
            self.src,
            &[
                // Punctuation
                (ascii(";"), Token::Semicolon),
                (ascii(":"), Token::Colon),
                (ascii(","), Token::Comma),
                (ascii("@"), Token::At),
                // Delimiters
                (ascii("("), Token::LeftParen),
                (ascii(")"), Token::RightParen),
                (ascii("["), Token::LeftBracket),
                (ascii("]"), Token::RightBracket),
                (ascii("{"), Token::LeftBrace),
                (ascii("}"), Token::RightBrace),
                // Operators
                (ascii("+"), Token::Plus),
                (ascii("-"), Token::Minus),
                (ascii("!"), Token::Bang),
                (ascii("~"), Token::Tilde),
                (ascii("*"), Token::Star),
                (ascii("/"), Token::Slash),
                (ascii("%"), Token::Percent),
                (ascii("<<"), Token::LeftShift),
                (ascii(">>"), Token::RightShift),
                (ascii("<"), Token::Less),
                (ascii("<="), Token::LessEquals),
                (ascii(">"), Token::Greater),
                (ascii(">="), Token::GreaterEquals),
                (ascii("="), Token::Equals),
                (ascii("=="), Token::EqualsEquals),
                (ascii("!="), Token::BangEquals),
                (ascii("&"), Token::Ampersand),
                (ascii("&&"), Token::AmpersandAmpersand),
                (ascii("|"), Token::Pipe),
                (ascii("||"), Token::PipePipe),
                (ascii("^"), Token::Caret),
                (ascii("?"), Token::Question),
            ],
        ) {
            let start = self.pos;
            self.pos = end;
            return Some(Ok((start, sym.clone(), self.pos)));
        }

        Some(Err(Error(self.pos)))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ascii::AsAscii;

    fn lex(src: &str) -> Result<Vec<Token>, Error> {
        let ascii_src = src
            .as_bytes()
            .as_ascii_slice()
            .expect("test input must be ASCII");
        Lexer::new(ascii_src)
            .map(|result| result.map(|(_, tok, _)| tok))
            .collect()
    }

    fn ident(s: &str) -> Token {
        Token::Ident(Ident::new(ascii(s).to_owned_ascii()))
    }

    fn dotted(s: &str) -> Token {
        Token::DottedIdent(DottedIdent::Simple(ascii(s).to_owned_ascii()))
    }

    fn string(s: &str) -> Token {
        Token::String(ascii(s).to_owned_ascii())
    }

    fn uint(repr: &str, value: u64) -> Token {
        Token::UIntLit(UIntLit::new(
            repr.as_bytes().as_ascii_slice().unwrap(),
            value,
        ))
    }

    fn sint(repr: &str, value: i64) -> Token {
        Token::SIntLit(SIntLit::new(
            repr.as_bytes().as_ascii_slice().unwrap(),
            value,
        ))
    }

    fn f32lit(repr: &str, value: f32) -> Token {
        Token::FloatLit(FloatLit::Hex32(FloatLitHex32::new(
            repr.as_bytes().as_ascii_slice().unwrap(),
            value.to_bits(),
        )))
    }

    fn f64lit(repr: &str, value: f64) -> Token {
        Token::FloatLit(FloatLit::Hex64(FloatLitHex64::new(
            repr.as_bytes().as_ascii_slice().unwrap(),
            value.to_bits(),
        )))
    }

    /// Helper for decimal float literals. Indices are set to None since
    /// FloatLitDec equality only compares repr, not the parsed components.
    fn f64lit_dec(repr: &str) -> Token {
        Token::FloatLit(FloatLit::Dec(FloatLitDec::new(
            repr.as_bytes().as_ascii_slice().unwrap(),
            None,
            None,
            None,
        )))
    }

    #[test]
    fn test_valid_binary_literals() {
        // Valid binary literals should parse correctly
        assert_eq!(lex("0b0"), Ok(vec![sint("0b0", 0)]));
        assert_eq!(lex("0b1"), Ok(vec![sint("0b1", 1)]));
        assert_eq!(lex("0b10"), Ok(vec![sint("0b10", 2)]));
        assert_eq!(lex("0b11"), Ok(vec![sint("0b11", 3)]));
        assert_eq!(lex("0b101"), Ok(vec![sint("0b101", 5)]));
        assert_eq!(lex("0b1111"), Ok(vec![sint("0b1111", 15)]));
        assert_eq!(lex("0B101"), Ok(vec![sint("0B101", 5)])); // uppercase B
    }

    #[test]
    fn test_binary_literals_with_unsigned_suffix() {
        assert_eq!(lex("0b101U"), Ok(vec![uint("0b101U", 5)]));
        assert_eq!(lex("0b0U"), Ok(vec![uint("0b0U", 0)]));
    }

    #[test]
    fn test_binary_literal_invalid_digit_splits_token() {
        // ptxas behavior: 0b101201 -> parses 0b101 (=5), then 201 is a separate token
        // This causes a syntax error in ptxas because 201 is unexpected after a literal
        //
        // Our lexer should match: 0b101 is consumed as binary, 201 remains as decimal
        assert_eq!(
            lex("0b101201"),
            Ok(vec![sint("0b101", 5), sint("201", 201)])
        );

        // 0b1129 -> 0b11 (=3) followed by 29
        assert_eq!(lex("0b1129"), Ok(vec![sint("0b11", 3), sint("29", 29)]));

        // 0b112 -> 0b11 (=3) followed by 2
        assert_eq!(lex("0b112"), Ok(vec![sint("0b11", 3), sint("2", 2)]));

        // 0b0201010 -> 0b0 (=0) followed by 201010
        assert_eq!(
            lex("0b0201010"),
            Ok(vec![sint("0b0", 0), sint("201010", 201010)])
        );
    }

    #[test]
    fn test_binary_no_valid_digits_falls_back_to_octal() {
        // 0b7: no valid binary digit after 0b, so binary parse fails
        // Falls back to octal: consumes just "0", leaving "b7" as identifier
        // This matches ptxas: error at 'b7' (not '7')
        assert_eq!(lex("0b7"), Ok(vec![sint("0", 0), ident("b7")]));

        // 0b9 similarly
        assert_eq!(lex("0b9"), Ok(vec![sint("0", 0), ident("b9")]));

        // 0b+5: "0" then "" (identifier) then "+" then "5"
        assert_eq!(
            lex("0b+5"),
            Ok(vec![sint("0", 0), ident("b"), Token::Plus, sint("5", 5)])
        );
    }

    #[test]
    fn test_binary_with_operator_is_expression() {
        // 0b11+2 should tokenize as: 0b11 (=3), +, 2
        // This is valid and evaluates to 5 in ptxas constant expressions
        assert_eq!(
            lex("0b11+2"),
            Ok(vec![sint("0b11", 3), Token::Plus, sint("2", 2)])
        );
    }

    #[test]
    fn test_hexadecimal_literals() {
        assert_eq!(lex("0x0"), Ok(vec![sint("0x0", 0)]));
        assert_eq!(lex("0x10"), Ok(vec![sint("0x10", 16)]));
        assert_eq!(lex("0xABCD"), Ok(vec![sint("0xABCD", 0xABCD)]));
        assert_eq!(lex("0xabcd"), Ok(vec![sint("0xabcd", 0xABCD)]));
        assert_eq!(lex("0X10"), Ok(vec![sint("0X10", 16)])); // uppercase X
    }

    #[test]
    fn test_octal_literals() {
        assert_eq!(lex("0"), Ok(vec![sint("0", 0)]));
        assert_eq!(lex("07"), Ok(vec![sint("07", 7)]));
        assert_eq!(lex("010"), Ok(vec![sint("010", 8)]));
        assert_eq!(lex("0777"), Ok(vec![sint("0777", 511)]));
    }

    #[test]
    fn test_decimal_literals() {
        assert_eq!(lex("1"), Ok(vec![sint("1", 1)]));
        assert_eq!(lex("123"), Ok(vec![sint("123", 123)]));
        assert_eq!(lex("999"), Ok(vec![sint("999", 999)]));
    }

    #[test]
    fn test_unsigned_suffix_hex_octal() {
        assert_eq!(lex("0xFFU"), Ok(vec![uint("0xFFU", 255)]));
        assert_eq!(lex("077U"), Ok(vec![uint("077U", 63)]));
    }

    #[test]
    fn test_integer_overflow_wraps() {
        // u64::MAX + 1 wraps to 0
        assert_eq!(
            lex("18446744073709551616"),
            Ok(vec![sint("18446744073709551616", 0)])
        );
    }

    #[test]
    fn test_decimal_float_literals() {
        // Standard float with integer and fractional parts
        assert_eq!(lex("1.0"), Ok(vec![f64lit_dec("1.0")]));
        assert_eq!(lex("3.14"), Ok(vec![f64lit_dec("3.14")]));
        assert_eq!(lex("123.456"), Ok(vec![f64lit_dec("123.456")]));

        // Float with no fractional digits
        assert_eq!(lex("1."), Ok(vec![f64lit_dec("1.")]));
        assert_eq!(lex("42."), Ok(vec![f64lit_dec("42.")]));

        // Float with no leading digit (the bug fix)
        assert_eq!(lex(".8"), Ok(vec![f64lit_dec(".8")]));
        assert_eq!(lex(".5"), Ok(vec![f64lit_dec(".5")]));
        assert_eq!(lex(".123"), Ok(vec![f64lit_dec(".123")]));

        // Exponent notation
        assert_eq!(lex("1e10"), Ok(vec![f64lit_dec("1e10")]));
        assert_eq!(lex("1E10"), Ok(vec![f64lit_dec("1E10")]));
        assert_eq!(lex("1e+10"), Ok(vec![f64lit_dec("1e+10")]));
        assert_eq!(lex("1e-10"), Ok(vec![f64lit_dec("1e-10")]));
        assert_eq!(lex("1.5e10"), Ok(vec![f64lit_dec("1.5e10")]));

        // Exponent with no leading digit
        assert_eq!(lex(".5e10"), Ok(vec![f64lit_dec(".5e10")]));
        assert_eq!(lex(".5e-2"), Ok(vec![f64lit_dec(".5e-2")]));
    }

    #[test]
    fn test_invalid_exponent_not_float() {
        // 1e with no digits -> integer 1 + ident "e"
        assert_eq!(lex("1e"), Ok(vec![sint("1", 1), ident("e")]));
        assert_eq!(lex("1e+"), Ok(vec![sint("1", 1), ident("e"), Token::Plus]));
    }

    #[test]
    fn test_dotted_ident_vs_float() {
        // .x should be a dotted identifier, not a float
        assert_eq!(lex(".x"), Ok(vec![dotted("x")]));
        assert_eq!(lex(".version"), Ok(vec![dotted("version")]));

        // .8 should be a float
        assert_eq!(lex(".8"), Ok(vec![f64lit_dec(".8")]));
    }

    // =========================================================================
    // Comments
    // =========================================================================

    #[test]
    fn test_single_line_comments() {
        // Comment and newline are both trivia
        assert_eq!(lex("// comment\n42"), Ok(vec![sint("42", 42)]));
        assert_eq!(lex("42// comment"), Ok(vec![sint("42", 42)]));
        // Comment at EOF
        assert_eq!(lex("42 // comment"), Ok(vec![sint("42", 42)]));
    }

    #[test]
    fn test_multi_line_comments() {
        assert_eq!(lex("/* comment */42"), Ok(vec![sint("42", 42)]));
        // Not nested - first */ ends the comment
        assert_eq!(lex("/* /* */42"), Ok(vec![sint("42", 42)]));
        // Unterminated - consumes to EOF
        assert_eq!(lex("42/* unterminated"), Ok(vec![sint("42", 42)]));
        // Multi-line
        assert_eq!(lex("/*\n\n*/42"), Ok(vec![sint("42", 42)]));
    }

    // =========================================================================
    // Hex Floats
    // =========================================================================

    #[test]
    fn test_hex_float_single() {
        // 0f + exactly 8 hex digits
        assert_eq!(lex("0f3f800000"), Ok(vec![f32lit("0f3f800000", 1.0)]));
        assert_eq!(lex("0F3f800000"), Ok(vec![f32lit("0F3f800000", 1.0)])); // uppercase F
        assert_eq!(lex("0f00000000"), Ok(vec![f32lit("0f00000000", 0.0)]));
        assert_eq!(lex("0fbf800000"), Ok(vec![f32lit("0fbf800000", -1.0)]));
    }

    #[test]
    fn test_hex_float_single_wrong_digit_count() {
        // 7 digits - fails hex float, falls back to octal 0 + ident
        assert_eq!(lex("0f3f80000"), Ok(vec![sint("0", 0), ident("f3f80000")]));
        // 9 digits - fails (requires exactly 8), falls back to octal 0 + ident
        assert_eq!(
            lex("0f3f8000001"),
            Ok(vec![sint("0", 0), ident("f3f8000001")])
        );
    }

    #[test]
    fn test_hex_float_double() {
        // 0d + exactly 16 hex digits
        assert_eq!(
            lex("0d3ff0000000000000"),
            Ok(vec![f64lit("0d3ff0000000000000", 1.0)])
        );
        assert_eq!(
            lex("0D3ff0000000000000"),
            Ok(vec![f64lit("0D3ff0000000000000", 1.0)])
        ); // uppercase D
        assert_eq!(
            lex("0d0000000000000000"),
            Ok(vec![f64lit("0d0000000000000000", 0.0)])
        );
    }

    #[test]
    fn test_hex_float_double_wrong_digit_count() {
        // 15 digits - fails, falls back to octal 0 + ident
        assert_eq!(
            lex("0d3ff000000000000"),
            Ok(vec![sint("0", 0), ident("d3ff000000000000")])
        );
    }

    // =========================================================================
    // Strings
    // =========================================================================

    #[test]
    fn test_strings() {
        assert_eq!(lex("\"hello\""), Ok(vec![string("hello")]));
        assert_eq!(lex("\"\""), Ok(vec![string("")]));
        // Backslashes are literal (not escape sequences)
        assert_eq!(lex("\"a\\nb\""), Ok(vec![string("a\\nb")]));
        assert_eq!(
            lex("\"path\\to\\file\""),
            Ok(vec![string("path\\to\\file")])
        );
    }

    #[test]
    fn test_unterminated_string() {
        // Unterminated string returns None from consume_string, falls through to Error
        assert!(lex("\"abc").is_err());
    }

    // =========================================================================
    // Identifiers
    // =========================================================================

    #[test]
    fn test_identifiers_letter_start() {
        assert_eq!(lex("foo"), Ok(vec![ident("foo")]));
        assert_eq!(lex("Foo123"), Ok(vec![ident("Foo123")]));
        assert_eq!(lex("foo_bar"), Ok(vec![ident("foo_bar")]));
        assert_eq!(lex("foo$bar"), Ok(vec![ident("foo$bar")]));
    }

    #[test]
    fn test_identifiers_special_start() {
        assert_eq!(lex("_foo"), Ok(vec![ident("_foo")]));
        assert_eq!(lex("$foo"), Ok(vec![ident("$foo")]));
        assert_eq!(lex("%r0"), Ok(vec![ident("%r0")]));
        assert_eq!(lex("_1"), Ok(vec![ident("_1")]));
    }

    #[test]
    fn test_identifier_followed_by_dot() {
        // v.x is lexed as a single Ident token; use as_variable() to extract components
        assert_eq!(lex("v.x"), Ok(vec![ident("v.x")]));

        // Verify as_variable() can extract the variable name and selector
        let id = Ident::new(ascii("v.x").to_owned_ascii());
        let (full, mut parts) = id.as_variable();
        assert_eq!(full, ascii("v.x"));
        assert_eq!(parts.next(), Some(ascii("v")));
        assert_eq!(parts.next(), Some(ascii("x")));
        assert_eq!(parts.next(), None);
    }

    // =========================================================================
    // Qualified Dotted Identifiers
    // =========================================================================

    #[test]
    fn test_qualified_dotted_identifiers() {
        assert_eq!(
            lex(".im2col::w::128"),
            Ok(vec![Token::DottedIdent(DottedIdent::Qualified(vec![
                ascii("im2col").to_owned_ascii(),
                ascii("w").to_owned_ascii(),
                ascii("128").to_owned_ascii(),
            ]))])
        );
        assert_eq!(
            lex(".foo::bar"),
            Ok(vec![Token::DottedIdent(DottedIdent::Qualified(vec![
                ascii("foo").to_owned_ascii(),
                ascii("bar").to_owned_ascii(),
            ]))])
        );
        // Trailing :: not consumed
        assert_eq!(
            lex(".foo::"),
            Ok(vec![dotted("foo"), Token::Colon, Token::Colon])
        );

        // The thing after the :: must be a valid qualified ident component
        let input = ascii(".foo::.");
        let mut lexer = Lexer::new(input).map(|result| result.map(|(_, tok, _)| tok));
        assert_eq!(lexer.next(), Some(Ok(dotted("foo"))));
        assert_eq!(lexer.next(), Some(Ok(Token::Colon)));
        assert_eq!(lexer.next(), Some(Ok(Token::Colon)));
        assert!(lexer.next().unwrap().is_err());
    }

    #[test]
    fn test_qualified_components_in_instruction_idents() {
        // A `::`-qualified component inside a dotted segment stays part of
        // the instruction token (ptxas lexes `.L2::128B` as one modifier).
        assert_eq!(
            lex("ld.global.L2::128B.f32"),
            Ok(vec![Token::Ident(Ident::new(
                ascii("ld.global.L2::128B.f32").to_owned_ascii()
            ))])
        );
        // A `::` before any dot is not consumed (ptxas case 1: `s::t` is a
        // syntax error near ':').
        assert_eq!(
            lex("s::t"),
            Ok(vec![
                Token::Ident(Ident::new(ascii("s").to_owned_ascii())),
                Token::Colon,
                Token::Colon,
                Token::Ident(Ident::new(ascii("t").to_owned_ascii())),
            ])
        );
        // A `::` not followed by a component is not consumed (ptxas cases
        // 3 and 4).
        assert_eq!(
            lex("st.async::"),
            Ok(vec![
                Token::Ident(Ident::new(ascii("st.async").to_owned_ascii())),
                Token::Colon,
                Token::Colon,
            ])
        );
    }

    // =========================================================================
    // Instructions (now lexed as Idents, recognized by parser)
    // =========================================================================

    #[test]
    fn test_instruction_simple() {
        // Instructions are lexed as Idents
        assert_eq!(lex("add"), Ok(vec![ident("add")]));
        assert_eq!(lex("mov"), Ok(vec![ident("mov")]));

        // They can be recognized as instructions via as_instr()
        let add_ident = Ident::new(ascii("add").to_owned_ascii());
        let (kind, mut suffix) = add_ident.as_instr().unwrap();
        assert_eq!(kind, InstrKind::Add);
        assert_eq!(suffix.next(), None);
    }

    #[test]
    fn test_instruction_compound() {
        // Compound instructions like st.async are lexed as single Idents
        assert_eq!(lex("st.async"), Ok(vec![ident("st.async")]));
        assert_eq!(lex("cp.async"), Ok(vec![ident("cp.async")]));

        // They can be recognized via as_instr()
        let st_async = Ident::new(ascii("st.async").to_owned_ascii());
        let (kind, mut suffix) = st_async.as_instr().unwrap();
        assert_eq!(kind, InstrKind::StAsync);
        assert_eq!(suffix.next(), None);
    }

    #[test]
    fn test_instruction_plus_modifier() {
        // st.async.weak is now lexed as a single Ident
        assert_eq!(lex("st.async.weak"), Ok(vec![ident("st.async.weak")]));

        // as_instr() returns the mnemonic and qualifiers (without leading dots)
        let st_async_weak = Ident::new(ascii("st.async.weak").to_owned_ascii());
        let (kind, mut suffix) = st_async_weak.as_instr().unwrap();
        assert_eq!(kind, InstrKind::StAsync);
        assert_eq!(suffix.next(), Some(ascii("weak")));
        assert_eq!(suffix.next(), None);
    }

    #[test]
    fn test_identifier_with_instruction_prefix() {
        // These are all Idents now
        assert_eq!(lex("mov"), Ok(vec![ident("mov")]));
        assert_eq!(lex("mov32"), Ok(vec![ident("mov32")]));
        assert_eq!(lex("add"), Ok(vec![ident("add")]));
        assert_eq!(lex("addr"), Ok(vec![ident("addr")]));

        // mov32 is not an instruction
        let mov32 = Ident::new(ascii("mov32").to_owned_ascii());
        assert!(mov32.as_instr().is_none());

        // addr is not an instruction
        let addr = Ident::new(ascii("addr").to_owned_ascii());
        assert!(addr.as_instr().is_none());
    }

    // =========================================================================
    // Operators and Punctuation
    // =========================================================================

    #[test]
    fn test_operators_multi_char() {
        assert_eq!(lex("<<"), Ok(vec![Token::LeftShift]));
        assert_eq!(lex(">>"), Ok(vec![Token::RightShift]));
        assert_eq!(lex("<="), Ok(vec![Token::LessEquals]));
        assert_eq!(lex(">="), Ok(vec![Token::GreaterEquals]));
        assert_eq!(lex("=="), Ok(vec![Token::EqualsEquals]));
        assert_eq!(lex("!="), Ok(vec![Token::BangEquals]));
        assert_eq!(lex("&&"), Ok(vec![Token::AmpersandAmpersand]));
        assert_eq!(lex("||"), Ok(vec![Token::PipePipe]));
    }

    #[test]
    fn test_delimiters_and_punctuation() {
        assert_eq!(
            lex("();,:@{}[]"),
            Ok(vec![
                Token::LeftParen,
                Token::RightParen,
                Token::Semicolon,
                Token::Comma,
                Token::Colon,
                Token::At,
                Token::LeftBrace,
                Token::RightBrace,
                Token::LeftBracket,
                Token::RightBracket
            ])
        );
    }

    // =========================================================================
    // Error Tokens
    // =========================================================================

    #[test]
    fn test_error_tokens() {
        assert!(lex("`").is_err());
        assert!(lex("\\").is_err());
        // # is an error (preprocessor directives should be handled externally by cpp)
        assert!(lex("#").is_err());
    }

    // =========================================================================
    // Whitespace
    // =========================================================================

    #[test]
    fn test_empty_and_whitespace() {
        assert_eq!(lex(""), Ok(vec![]));
        assert_eq!(lex("   "), Ok(vec![]));
        assert_eq!(lex("\t\t"), Ok(vec![]));
        assert_eq!(lex("\n"), Ok(vec![]));
        assert_eq!(lex("\n\n"), Ok(vec![]));
        assert_eq!(lex("\r\n"), Ok(vec![]));
        assert_eq!(lex("// \n42// "), Ok(vec![sint("42", 42)]));
    }
}
