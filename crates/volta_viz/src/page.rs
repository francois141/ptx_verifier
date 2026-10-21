//! The viewer as one self-contained HTML page: its stylesheet and script inlined, and every
//! stored run embedded as an inert JSON block that the page parses only when the run is
//! opened, so the page loads quickly however many runs it holds.

use std::fmt::Write as _;
use std::io;
use std::path::Path;

use crate::store::stored_runs;

const TEMPLATE: &str = include_str!("../viewer/page.html");
const STYLE: &str = include_str!("../viewer/style.css");
const SCRIPT: &str = include_str!("../viewer/app.js");

/// Write the page over every run stored in `dir` to `out`; returns how many runs it holds.
pub fn write_page(dir: &Path, out: &Path) -> io::Result<usize> {
    let runs = stored_runs(dir)?;
    let summaries: Vec<&str> = runs.iter().map(|r| r.summary.as_str()).collect();
    let mut data = format!(
        "<script type=\"application/json\" id=\"volta-index\">[{}]</script>\n",
        inert(&summaries.join(","))
    );
    for (i, run) in runs.iter().enumerate() {
        writeln!(
            data,
            "<script type=\"application/json\" id=\"run-{i}\">{}</script>",
            inert(&run.document)
        )
        .expect("writing to a String cannot fail");
    }
    // The data goes in last, so no marker is ever searched for inside it.
    let page = TEMPLATE
        .replacen("/*{{style}}*/", STYLE, 1)
        .replacen("/*{{script}}*/", SCRIPT, 1)
        .replacen("<!--{{runs}}-->", &data, 1);
    if let Some(parent) = out.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(out, page)?;
    Ok(runs.len())
}

/// JSON text safe inside a `<script>` element: `<` only occurs inside JSON strings, where its
/// `<` escape decodes to the same text, so no `</script>` can end the element early.
fn inert(json: &str) -> String {
    json.replace('<', "\\u003c")
}

#[cfg(test)]
mod tests {
    use super::inert;

    #[test]
    fn embedded_json_cannot_close_its_script_element() {
        let escaped = inert(r#"{"s":"</script>"}"#);
        assert!(!escaped.contains('<'), "{escaped}");
        assert_eq!(escaped, "{\"s\":\"\\u003c/script>\"}");
    }
}
