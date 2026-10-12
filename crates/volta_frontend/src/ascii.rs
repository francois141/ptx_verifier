// A modified copy of std's unstable ASCII-character module, vendored to avoid building on
// nightly (original license below). Kept close to upstream: clippy findings are allowed, not
// fixed.
#![allow(
    clippy::missing_safety_doc,
    clippy::needless_lifetimes,
    clippy::new_without_default,
    clippy::len_without_is_empty,
    clippy::large_enum_variant,
    clippy::manual_ignore_case_cmp
)]
//
// ---------------------------------------------------------
//
// Copyright (c) The Rust Project Contributors
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the
// Software without restriction, including without
// limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice
// shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
// ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
// SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
// IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

use std::{borrow::Borrow, fmt};

/// One of the 128 Unicode characters from U+0000 through U+007F.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
#[repr(u8)]
pub enum AsciiChar {
    /// U+0000 (The default variant)
    Null = 0,
    /// U+0001
    StartOfHeading = 1,
    /// U+0002
    StartOfText = 2,
    /// U+0003
    EndOfText = 3,
    /// U+0004
    EndOfTransmission = 4,
    /// U+0005
    Enquiry = 5,
    /// U+0006
    Acknowledge = 6,
    /// U+0007
    Bell = 7,
    /// U+0008
    Backspace = 8,
    /// U+0009
    CharacterTabulation = 9,
    /// U+000A
    LineFeed = 10,
    /// U+000B
    LineTabulation = 11,
    /// U+000C
    FormFeed = 12,
    /// U+000D
    CarriageReturn = 13,
    /// U+000E
    ShiftOut = 14,
    /// U+000F
    ShiftIn = 15,
    /// U+0010
    DataLinkEscape = 16,
    /// U+0011
    DeviceControlOne = 17,
    /// U+0012
    DeviceControlTwo = 18,
    /// U+0013
    DeviceControlThree = 19,
    /// U+0014
    DeviceControlFour = 20,
    /// U+0015
    NegativeAcknowledge = 21,
    /// U+0016
    SynchronousIdle = 22,
    /// U+0017
    EndOfTransmissionBlock = 23,
    /// U+0018
    Cancel = 24,
    /// U+0019
    EndOfMedium = 25,
    /// U+001A
    Substitute = 26,
    /// U+001B
    Escape = 27,
    /// U+001C
    InformationSeparatorFour = 28,
    /// U+001D
    InformationSeparatorThree = 29,
    /// U+001E
    InformationSeparatorTwo = 30,
    /// U+001F
    InformationSeparatorOne = 31,
    /// U+0020
    Space = 32,
    /// U+0021
    ExclamationMark = 33,
    /// U+0022
    QuotationMark = 34,
    /// U+0023
    NumberSign = 35,
    /// U+0024
    DollarSign = 36,
    /// U+0025
    PercentSign = 37,
    /// U+0026
    Ampersand = 38,
    /// U+0027
    Apostrophe = 39,
    /// U+0028
    LeftParenthesis = 40,
    /// U+0029
    RightParenthesis = 41,
    /// U+002A
    Asterisk = 42,
    /// U+002B
    PlusSign = 43,
    /// U+002C
    Comma = 44,
    /// U+002D
    HyphenMinus = 45,
    /// U+002E
    FullStop = 46,
    /// U+002F
    Solidus = 47,
    /// U+0030
    Digit0 = 48,
    /// U+0031
    Digit1 = 49,
    /// U+0032
    Digit2 = 50,
    /// U+0033
    Digit3 = 51,
    /// U+0034
    Digit4 = 52,
    /// U+0035
    Digit5 = 53,
    /// U+0036
    Digit6 = 54,
    /// U+0037
    Digit7 = 55,
    /// U+0038
    Digit8 = 56,
    /// U+0039
    Digit9 = 57,
    /// U+003A
    Colon = 58,
    /// U+003B
    Semicolon = 59,
    /// U+003C
    LessThanSign = 60,
    /// U+003D
    EqualsSign = 61,
    /// U+003E
    GreaterThanSign = 62,
    /// U+003F
    QuestionMark = 63,
    /// U+0040
    CommercialAt = 64,
    /// U+0041
    CapitalA = 65,
    /// U+0042
    CapitalB = 66,
    /// U+0043
    CapitalC = 67,
    /// U+0044
    CapitalD = 68,
    /// U+0045
    CapitalE = 69,
    /// U+0046
    CapitalF = 70,
    /// U+0047
    CapitalG = 71,
    /// U+0048
    CapitalH = 72,
    /// U+0049
    CapitalI = 73,
    /// U+004A
    CapitalJ = 74,
    /// U+004B
    CapitalK = 75,
    /// U+004C
    CapitalL = 76,
    /// U+004D
    CapitalM = 77,
    /// U+004E
    CapitalN = 78,
    /// U+004F
    CapitalO = 79,
    /// U+0050
    CapitalP = 80,
    /// U+0051
    CapitalQ = 81,
    /// U+0052
    CapitalR = 82,
    /// U+0053
    CapitalS = 83,
    /// U+0054
    CapitalT = 84,
    /// U+0055
    CapitalU = 85,
    /// U+0056
    CapitalV = 86,
    /// U+0057
    CapitalW = 87,
    /// U+0058
    CapitalX = 88,
    /// U+0059
    CapitalY = 89,
    /// U+005A
    CapitalZ = 90,
    /// U+005B
    LeftSquareBracket = 91,
    /// U+005C
    ReverseSolidus = 92,
    /// U+005D
    RightSquareBracket = 93,
    /// U+005E
    CircumflexAccent = 94,
    /// U+005F
    LowLine = 95,
    /// U+0060
    GraveAccent = 96,
    /// U+0061
    SmallA = 97,
    /// U+0062
    SmallB = 98,
    /// U+0063
    SmallC = 99,
    /// U+0064
    SmallD = 100,
    /// U+0065
    SmallE = 101,
    /// U+0066
    SmallF = 102,
    /// U+0067
    SmallG = 103,
    /// U+0068
    SmallH = 104,
    /// U+0069
    SmallI = 105,
    /// U+006A
    SmallJ = 106,
    /// U+006B
    SmallK = 107,
    /// U+006C
    SmallL = 108,
    /// U+006D
    SmallM = 109,
    /// U+006E
    SmallN = 110,
    /// U+006F
    SmallO = 111,
    /// U+0070
    SmallP = 112,
    /// U+0071
    SmallQ = 113,
    /// U+0072
    SmallR = 114,
    /// U+0073
    SmallS = 115,
    /// U+0074
    SmallT = 116,
    /// U+0075
    SmallU = 117,
    /// U+0076
    SmallV = 118,
    /// U+0077
    SmallW = 119,
    /// U+0078
    SmallX = 120,
    /// U+0079
    SmallY = 121,
    /// U+007A
    SmallZ = 122,
    /// U+007B
    LeftCurlyBracket = 123,
    /// U+007C
    VerticalLine = 124,
    /// U+007D
    RightCurlyBracket = 125,
    /// U+007E
    Tilde = 126,
    /// U+007F
    Delete = 127,
}

impl AsciiChar {
    /// The character with the lowest ASCII code.
    pub const MIN: Self = Self::Null;

    /// The character with the highest ASCII code.
    pub const MAX: Self = Self::Delete;

    /// Creates an ASCII character from the byte `b`,
    /// or returns `None` if it's too large.
    #[inline]
    pub const fn from_u8(b: u8) -> Option<Self> {
        if b <= 127 {
            // SAFETY: Just checked that `b` is in-range
            Some(unsafe { Self::from_u8_unchecked(b) })
        } else {
            None
        }
    }

    /// Creates an ASCII character from the byte `b`, without checking whether it's valid.
    /// # Safety
    /// `b` must be in `0..=127`, or else this is UB.
    #[inline]
    pub const unsafe fn from_u8_unchecked(b: u8) -> Self {
        // SAFETY: Our safety precondition is that `b` is in-range.
        unsafe { std::mem::transmute(b) }
    }

    /// When passed the *number* `0`, `1`, …, `9`, returns the *character*
    /// `'0'`, `'1'`, …, `'9'` respectively. If `d >= 10`, returns `None`.
    #[inline]
    pub const fn digit(d: u8) -> Option<Self> {
        if d < 10 {
            // SAFETY: Just checked it's in-range.
            Some(unsafe { Self::digit_unchecked(d) })
        } else {
            None
        }
    }

    /// Returns the *character* `'0'`..`'9'` for the *number* `d`, without a range check.
    /// # Safety
    /// UB if `d > 64`; for `10 <= d <= 64` it may return any value (not hex digits) or panic.
    #[inline]
    #[track_caller]
    pub const unsafe fn digit_unchecked(d: u8) -> Self {
        debug_assert!(
            d < 10,
            "`AsciiChar::digit_unchecked` input cannot exceed 9.",
        );

        // SAFETY: `'0'` through `'9'` are U+00030 through U+0039,
        // so because `d` must be 64 or less the addition can return at most
        // 112 (0x70), which doesn't overflow and is within the ASCII range.
        unsafe {
            let byte = b'0'.unchecked_add(d);
            Self::from_u8_unchecked(byte)
        }
    }

    /// Gets this ASCII character as a byte.
    #[inline]
    pub const fn to_u8(self) -> u8 {
        self as u8
    }

    /// Gets this ASCII character as a `char` Unicode Scalar Value.
    #[inline]
    pub const fn to_char(self) -> char {
        self as u8 as char
    }

    /// Views this ASCII character as a one-code-unit UTF-8 `str`.
    #[inline]
    pub const fn as_str(&self) -> &str {
        ascii_as_str(std::slice::from_ref(self))
    }

    /// Makes a copy of the value in its upper case equivalent ('a'..='z' map to 'A'..='Z').
    /// To uppercase the value in-place, use [`Self::make_uppercase`].
    #[must_use = "to uppercase the value in-place, use `make_uppercase()`"]
    #[inline]
    pub const fn to_uppercase(self) -> Self {
        let uppercase_byte = self.to_u8().to_ascii_uppercase();
        // SAFETY: Toggling the 6th bit won't convert ASCII to non-ASCII.
        unsafe { Self::from_u8_unchecked(uppercase_byte) }
    }

    /// Makes a copy of the value in its lower case equivalent ('A'..='Z' map to 'a'..='z').
    /// To lowercase the value in-place, use [`Self::make_lowercase`].
    #[must_use = "to lowercase the value in-place, use `make_lowercase()`"]
    #[inline]
    pub const fn to_lowercase(self) -> Self {
        let lowercase_byte = self.to_u8().to_ascii_lowercase();
        // SAFETY: Setting the 6th bit won't convert ASCII to non-ASCII.
        unsafe { Self::from_u8_unchecked(lowercase_byte) }
    }

    /// Checks that two values are a case-insensitive match.
    ///
    /// This is equivalent to `to_lowercase(a) == to_lowercase(b)`.
    #[inline]
    pub const fn eq_ignore_case(self, other: Self) -> bool {
        // FIXME(const-hack) `arg.to_u8().to_ascii_lowercase()` -> `arg.to_lowercase()`
        // once `PartialEq` is const for `Self`.
        self.to_u8().to_ascii_lowercase() == other.to_u8().to_ascii_lowercase()
    }

    /// Converts this value to its upper case equivalent in-place ('a'..='z' map to 'A'..='Z').
    /// To return a new uppercased value instead, use [`Self::to_uppercase`].
    #[inline]
    pub const fn make_uppercase(&mut self) {
        *self = self.to_uppercase();
    }

    /// Converts this value to its lower case equivalent in-place ('A'..='Z' map to 'a'..='z').
    /// To return a new lowercased value instead, use [`Self::to_lowercase`].
    #[inline]
    pub const fn make_lowercase(&mut self) {
        *self = self.to_lowercase();
    }

    /// Checks if the value is an alphabetic character: 0x41 'A' ..= 0x5A 'Z', or
    /// 0x61 'a' ..= 0x7A 'z'.
    #[must_use]
    #[inline]
    pub const fn is_alphabetic(self) -> bool {
        self.to_u8().is_ascii_alphabetic()
    }

    /// Checks if the value is an uppercase character:
    /// 0x41 'A' ..= 0x5A 'Z'.
    #[must_use]
    #[inline]
    pub const fn is_uppercase(self) -> bool {
        self.to_u8().is_ascii_uppercase()
    }

    /// Checks if the value is a lowercase character:
    /// 0x61 'a' ..= 0x7A 'z'.
    #[must_use]
    #[inline]
    pub const fn is_lowercase(self) -> bool {
        self.to_u8().is_ascii_lowercase()
    }

    /// Checks if the value is an alphanumeric character: 0x41 'A' ..= 0x5A 'Z',
    /// 0x61 'a' ..= 0x7A 'z', or 0x30 '0' ..= 0x39 '9'.
    #[must_use]
    #[inline]
    pub const fn is_alphanumeric(self) -> bool {
        self.to_u8().is_ascii_alphanumeric()
    }

    /// Checks if the value is a decimal digit:
    /// 0x30 '0' ..= 0x39 '9'.
    #[must_use]
    #[inline]
    pub const fn is_digit(self) -> bool {
        self.to_u8().is_ascii_digit()
    }

    /// Checks if the value is a binary digit:
    /// 0x30 '0' or 0x31 '1'.
    #[must_use]
    #[inline]
    pub const fn is_bindigit(self) -> bool {
        matches!(self.to_u8(), b'0' | b'1')
    }

    /// Checks if the value is an octal digit:
    /// 0x30 '0' ..= 0x37 '7'.
    #[must_use]
    #[inline]
    pub const fn is_octdigit(self) -> bool {
        matches!(self.to_u8(), b'0'..=b'7')
    }

    /// Checks if the value is a hexadecimal digit: 0x30 '0' ..= 0x39 '9',
    /// 0x41 'A' ..= 0x46 'F', or 0x61 'a' ..= 0x66 'f'.
    #[must_use]
    #[inline]
    pub const fn is_hexdigit(self) -> bool {
        self.to_u8().is_ascii_hexdigit()
    }

    /// Checks if the value is a punctuation character:
    /// 0x21 ..= 0x2F `! " # $ % & ' ( ) * + , - . /`, 0x3A ..= 0x40 `: ; < = > ? @`,
    /// 0x5B ..= 0x60 `` [ \ ] ^ _ ` ``, or 0x7B ..= 0x7E `{ | } ~`.
    #[must_use]
    #[inline]
    pub const fn is_punctuation(self) -> bool {
        self.to_u8().is_ascii_punctuation()
    }

    /// Checks if the value is a graphic character:
    /// 0x21 '!' ..= 0x7E '~'.
    #[must_use]
    #[inline]
    pub const fn is_graphic(self) -> bool {
        self.to_u8().is_ascii_graphic()
    }

    /// Checks if the value is a whitespace character per the WhatWG Infra Standard: 0x20 SPACE,
    /// 0x09 HORIZONTAL TAB, 0x0A LINE FEED, 0x0C FORM FEED, or 0x0D CARRIAGE RETURN (not 0x0B
    /// VERTICAL TAB). Other formats (POSIX, shells) define whitespace differently.
    #[must_use]
    #[inline]
    pub const fn is_whitespace(self) -> bool {
        self.to_u8().is_ascii_whitespace()
    }

    /// Checks if the value is a control character: 0x00 NUL ..= 0x1F UNIT SEPARATOR, or
    /// 0x7F DELETE. Note that most whitespace characters are control characters, but SPACE is not.
    #[must_use]
    #[inline]
    pub const fn is_control(self) -> bool {
        self.to_u8().is_ascii_control()
    }

    /// Returns an iterator that produces an escaped version of a character, identical to
    /// [`ascii::escape_default`](crate::ascii::escape_default).
    #[must_use = "this returns the escaped character as an iterator, \
                  without modifying the original"]
    #[inline]
    pub fn escape_ascii(self) -> std::ascii::EscapeDefault {
        std::ascii::escape_default(self.to_u8())
    }
}

macro_rules! into_int_impl {
    ($($ty:ty)*) => {
        $(
            impl From<AsciiChar> for $ty {
                #[inline]
                fn from(chr: AsciiChar) -> $ty {
                    chr as u8 as $ty
                }
            }
        )*
    }
}

into_int_impl!(u8 u16 u32 u64 u128 char);

impl fmt::Display for AsciiChar {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        <str as fmt::Display>::fmt(self.as_str(), f)
    }
}

impl fmt::Debug for AsciiChar {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use AsciiChar::{Apostrophe, Null, ReverseSolidus as Backslash};

        fn backslash(a: AsciiChar) -> ([AsciiChar; 6], usize) {
            ([Apostrophe, Backslash, a, Apostrophe, Null, Null], 4)
        }

        let (buf, len) = match self {
            AsciiChar::Null => backslash(AsciiChar::Digit0),
            AsciiChar::CharacterTabulation => backslash(AsciiChar::SmallT),
            AsciiChar::CarriageReturn => backslash(AsciiChar::SmallR),
            AsciiChar::LineFeed => backslash(AsciiChar::SmallN),
            AsciiChar::ReverseSolidus => backslash(AsciiChar::ReverseSolidus),
            AsciiChar::Apostrophe => backslash(AsciiChar::Apostrophe),
            _ if self.to_u8().is_ascii_control() => {
                const HEX_DIGITS: [AsciiChar; 16] = [
                    AsciiChar::Digit0,
                    AsciiChar::Digit1,
                    AsciiChar::Digit2,
                    AsciiChar::Digit3,
                    AsciiChar::Digit4,
                    AsciiChar::Digit5,
                    AsciiChar::Digit6,
                    AsciiChar::Digit7,
                    AsciiChar::Digit8,
                    AsciiChar::Digit9,
                    AsciiChar::SmallA,
                    AsciiChar::SmallB,
                    AsciiChar::SmallC,
                    AsciiChar::SmallD,
                    AsciiChar::SmallE,
                    AsciiChar::SmallF,
                ];

                let byte = self.to_u8();
                let hi = HEX_DIGITS[usize::from(byte >> 4)];
                let lo = HEX_DIGITS[usize::from(byte & 0xf)];
                (
                    [Apostrophe, Backslash, AsciiChar::SmallX, hi, lo, Apostrophe],
                    6,
                )
            }
            _ => ([Apostrophe, *self, Apostrophe, Null, Null, Null], 3),
        };

        f.write_str(buf[..len].as_str())
    }
}

/// Views this slice of ASCII characters as a UTF-8 `str`.
///
/// Callable in a `const` context, unlike the trait method [AsciiSliceExt::as_str].
#[inline]
pub const fn ascii_as_str(slice: &[AsciiChar]) -> &str {
    let ascii_ptr: *const [AsciiChar] = slice;
    let str_ptr = ascii_ptr as *const str;
    // SAFETY: Each ASCII codepoint in UTF-8 is encoded as one single-byte
    // code unit having the same value as the ASCII byte.
    unsafe { &*str_ptr }
}

/// Views this slice of ASCII characters as a slice of `u8` bytes.
///
/// Callable in a `const` context, unlike the trait method [AsciiSliceExt::as_bytes].
#[inline]
pub const fn ascii_as_bytes(slice: &[AsciiChar]) -> &[u8] {
    ascii_as_str(slice).as_bytes()
}

pub trait AsciiSliceExt {
    /// See [`ascii_as_str`].
    fn as_str(&self) -> &str;

    /// See [`ascii_as_bytes`].
    fn as_bytes(&self) -> &[u8];

    /// Converts this slice of ASCII characters into an owned ASCII string.
    fn to_owned_ascii(&self) -> AsciiString;
}

impl AsciiSliceExt for [AsciiChar] {
    #[inline]
    fn as_str(&self) -> &str {
        ascii_as_str(self)
    }

    #[inline]
    fn as_bytes(&self) -> &[u8] {
        ascii_as_bytes(self)
    }

    #[inline]
    fn to_owned_ascii(&self) -> AsciiString {
        AsciiString {
            data: self.to_vec(),
        }
    }
}

/// Unchecked bytes-to-ASCII conversion; `const`, unlike [AsAscii::as_ascii_slice_unchecked].
/// # Safety
/// Every byte in the array must be in `0..=127`, or else this is UB.
pub const unsafe fn bytes_as_ascii_unchecked(bytes: &[u8]) -> &[AsciiChar] {
    let byte_ptr: *const [u8] = bytes;
    let ascii_ptr = byte_ptr as *const [AsciiChar];
    // SAFETY: The caller promised all the bytes are ASCII
    unsafe { &*ascii_ptr }
}

/// If this slice `is_ascii`, returns it as a slice of [ASCII characters](`AsciiChar`),
/// otherwise `None`. Callable in a `const` context, unlike [AsAscii::as_ascii_slice].
pub const fn bytes_as_ascii(bytes: &[u8]) -> Option<&[AsciiChar]> {
    if bytes.is_ascii() {
        // SAFETY: Just checked that it's ASCII
        Some(unsafe { bytes_as_ascii_unchecked(bytes) })
    } else {
        None
    }
}

pub trait AsAscii {
    /// See [`bytes_as_ascii_unchecked`].
    #[must_use]
    unsafe fn as_ascii_slice_unchecked(&self) -> &[AsciiChar];

    /// See [`bytes_as_ascii`].
    #[must_use]
    fn as_ascii_slice(&self) -> Option<&[AsciiChar]>;
}

impl AsAscii for [u8] {
    #[inline]
    unsafe fn as_ascii_slice_unchecked(&self) -> &[AsciiChar] {
        unsafe { bytes_as_ascii_unchecked(self) }
    }

    #[inline]
    fn as_ascii_slice(&self) -> Option<&[AsciiChar]> {
        bytes_as_ascii(self)
    }
}

/// A convenience function for constructing ASCII constants.
///
/// Panics if the string contains non-ASCII characters.
pub const fn ascii<'a>(s: &'a str) -> &'a [AsciiChar] {
    crate::ascii::bytes_as_ascii(s.as_bytes()).unwrap()
}

/// An error in attempting to convert bytes to ASCII characters.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InvalidAsciiError;

impl fmt::Display for InvalidAsciiError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "input contains non-ASCII characters")
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AsciiString {
    data: Vec<AsciiChar>,
}

impl AsciiString {
    pub const fn new() -> Self {
        Self { data: Vec::new() }
    }

    pub fn with_capacity(capacity: usize) -> Self {
        Self {
            data: Vec::with_capacity(capacity),
        }
    }
}

impl AsciiString {
    #[inline]
    pub fn len(&self) -> usize {
        self.data.len()
    }

    #[inline]
    pub fn as_slice(&self) -> &[AsciiChar] {
        &self.data
    }

    #[inline]
    pub fn as_mut_slice(&mut self) -> &mut [AsciiChar] {
        &mut self.data
    }

    #[inline]
    pub fn as_str(&self) -> &str {
        self.data.as_str()
    }

    #[inline]
    pub fn into_inner(self) -> Vec<AsciiChar> {
        self.data
    }

    #[inline]
    pub fn push(&mut self, chr: AsciiChar) {
        self.data.push(chr);
    }

    #[inline]
    pub fn push_slice(&mut self, s: &[AsciiChar]) {
        self.data.extend_from_slice(s);
    }
}

impl fmt::Display for AsciiString {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        <str as fmt::Display>::fmt(self.as_str(), f)
    }
}

pub fn join<S: Borrow<[AsciiChar]>>(slice: &[AsciiString], sep: S) -> AsciiString {
    let sep = sep.borrow();
    let mut iter = slice.iter();
    let first = match iter.next() {
        Some(first) => first,
        None => return AsciiString { data: vec![] },
    };
    let size = slice.iter().map(|v| v.len()).sum::<usize>() + (slice.len() - 1) * sep.len();
    let mut result = Vec::with_capacity(size);
    result.extend_from_slice(first);

    for v in iter {
        result.extend_from_slice(sep);
        result.extend_from_slice(v)
    }
    AsciiString { data: result }
}

impl From<AsciiString> for String {
    fn from(value: AsciiString) -> Self {
        let mut data = value.data;
        let ptr = data.as_mut_ptr() as *mut u8;
        let len = data.len();
        let cap = data.capacity();
        std::mem::forget(data);
        // SAFETY: AsciiChar is repr(u8) and all ASCII bytes are valid UTF-8.
        // We also forgot the original Vec to avoid double-free.
        unsafe { String::from_raw_parts(ptr, len, cap) }
    }
}

impl From<Vec<AsciiChar>> for AsciiString {
    fn from(value: Vec<AsciiChar>) -> Self {
        Self { data: value }
    }
}

impl TryFrom<String> for AsciiString {
    type Error = InvalidAsciiError;

    fn try_from(value: String) -> Result<Self, Self::Error> {
        let mut value = value.into_bytes();
        if !value.is_ascii() {
            return Err(InvalidAsciiError);
        }
        let ptr = value.as_mut_ptr() as *mut AsciiChar;
        let len = value.len();
        let cap = value.capacity();
        std::mem::forget(value);
        // SAFETY: We verified all bytes are ASCII, and Vec<u8> and Vec<AsciiChar>
        // have the same layout since AsciiChar is repr(u8). We also forgot the
        // original Vec to avoid double-free.
        let data = unsafe { Vec::from_raw_parts(ptr, len, cap) };
        Ok(Self { data })
    }
}

impl std::ops::Deref for AsciiString {
    type Target = [AsciiChar];

    fn deref(&self) -> &Self::Target {
        &self.data
    }
}

impl std::ops::DerefMut for AsciiString {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.data
    }
}
