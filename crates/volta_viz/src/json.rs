//! A minimal JSON value and its compact serialization (the crate's only wire format).

use std::fmt::{self, Display, Write};

#[derive(Debug, Clone, PartialEq)]
pub enum Json {
    Null,
    Int(i64),
    Str(String),
    Arr(Vec<Json>),
    Obj(Vec<(&'static str, Json)>),
}

impl Json {
    pub fn str(s: impl Into<String>) -> Json {
        Json::Str(s.into())
    }

    pub fn uint(n: impl Into<u64>) -> Json {
        Json::Int(i64::try_from(n.into()).unwrap_or(i64::MAX))
    }

    pub fn opt<T>(value: Option<T>, f: impl FnOnce(T) -> Json) -> Json {
        value.map_or(Json::Null, f)
    }
}

impl Display for Json {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Json::Null => f.write_str("null"),
            Json::Int(n) => write!(f, "{n}"),
            Json::Str(s) => write_string(f, s),
            Json::Arr(items) => {
                f.write_char('[')?;
                for (i, item) in items.iter().enumerate() {
                    if i > 0 {
                        f.write_char(',')?;
                    }
                    write!(f, "{item}")?;
                }
                f.write_char(']')
            }
            Json::Obj(fields) => {
                f.write_char('{')?;
                for (i, (key, value)) in fields.iter().enumerate() {
                    if i > 0 {
                        f.write_char(',')?;
                    }
                    write_string(f, key)?;
                    write!(f, ":{value}")?;
                }
                f.write_char('}')
            }
        }
    }
}

fn write_string(f: &mut fmt::Formatter<'_>, s: &str) -> fmt::Result {
    f.write_char('"')?;
    for c in s.chars() {
        match c {
            '"' => f.write_str("\\\"")?,
            '\\' => f.write_str("\\\\")?,
            '\n' => f.write_str("\\n")?,
            '\r' => f.write_str("\\r")?,
            '\t' => f.write_str("\\t")?,
            c if u32::from(c) < 0x20 => write!(f, "\\u{:04x}", u32::from(c))?,
            c => f.write_char(c)?,
        }
    }
    f.write_char('"')
}

#[cfg(test)]
mod tests {
    use super::Json;

    #[test]
    fn strings_escape_quotes_and_control_characters() {
        let value = Json::Obj(vec![
            ("a", Json::str("x\"y\\z\n\u{1}")),
            ("b", Json::Arr(vec![Json::Int(-3), Json::Null])),
        ]);
        assert_eq!(
            value.to_string(),
            r#"{"a":"x\"y\\z\n\u0001","b":[-3,null]}"#
        );
    }
}
