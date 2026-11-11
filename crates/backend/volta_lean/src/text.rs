pub(crate) const MESSAGE_LIMIT: usize = 30_000;

/// `text` split after its first `limit` characters, or `None` when it has no more.
pub(crate) fn split_after_chars(text: &str, limit: usize) -> Option<(&str, &str)> {
    text.char_indices()
        .nth(limit)
        .map(|(byte, _)| text.split_at(byte))
}

/// `text`, or its first `MESSAGE_LIMIT` characters and how many more it has.
pub(crate) fn capped(text: &str) -> String {
    match split_after_chars(text, MESSAGE_LIMIT) {
        None => text.to_string(),
        Some((head, rest)) => format!("{head}\n... ({} more characters)", rest.chars().count()),
    }
}

/// The 1-based line of byte offset `at`.
pub(crate) fn line_of(text: &str, at: usize) -> usize {
    text[..at].matches('\n').count() + 1
}
