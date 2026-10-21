//! A directory of recorded runs: `<suite>/<test>[~<run>].json` documents, each beside its
//! `.meta.json` summary, so the page's index is assembled from the summaries without parsing
//! any document.

use std::io;
use std::num::NonZeroU32;
use std::path::Path;

use crate::export::{Run, document, summary};

const DOCUMENT_EXTENSION: &str = ".json";
const SUMMARY_EXTENSION: &str = ".meta.json";

/// Which run a document records: the n-th kernel run (`ordinal`, from 1) of `test` in `suite`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RunId {
    pub suite: String,
    pub test: String,
    pub ordinal: NonZeroU32,
}

impl RunId {
    /// `<suite>/<test>[~<run>]`, with path-unsafe characters replaced: the document's path
    /// under the store, without its extension.
    pub fn key(&self) -> String {
        let test = slug(&self.test);
        match self.ordinal.get() {
            1 => format!("{}/{test}", slug(&self.suite)),
            n => format!("{}/{test}~{n}", slug(&self.suite)),
        }
    }
}

fn slug(name: &str) -> String {
    name.chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || c == '_' || c == '-' {
                c
            } else {
                '_'
            }
        })
        .collect()
}

/// Write the run's document, then its summary (an indexed run's document always exists).
pub fn write_run(dir: &Path, run: &Run) -> io::Result<()> {
    let key = run.id.key();
    let document_path = dir.join(format!("{key}{DOCUMENT_EXTENSION}"));
    if let Some(parent) = document_path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    write_atomically(&document_path, &document(run).to_string())?;
    write_atomically(
        &dir.join(format!("{key}{SUMMARY_EXTENSION}")),
        &summary(run).to_string(),
    )
}

/// A test rerun may rewrite a file while a page is being built: the builder sees either the
/// old file or the new one.
fn write_atomically(path: &Path, text: &str) -> io::Result<()> {
    let mut temp = path.as_os_str().to_owned();
    temp.push(".tmp");
    std::fs::write(&temp, text)?;
    std::fs::rename(&temp, path)
}

/// One recorded run's JSON texts.
pub struct StoredRun {
    pub summary: String,
    pub document: String,
}

/// Every run recorded in `dir`, sorted by key.
pub fn stored_runs(dir: &Path) -> io::Result<Vec<StoredRun>> {
    let mut summaries = Vec::new();
    for suite in std::fs::read_dir(dir)? {
        let suite = suite?.path();
        if !suite.is_dir() {
            continue;
        }
        for file in std::fs::read_dir(&suite)? {
            let path = file?.path();
            let name = path.to_string_lossy();
            if let Some(stem) = name.strip_suffix(SUMMARY_EXTENSION) {
                summaries.push((stem.to_string(), path.clone()));
            }
        }
    }
    summaries.sort();
    summaries
        .into_iter()
        .map(|(stem, summary)| {
            Ok(StoredRun {
                summary: std::fs::read_to_string(summary)?,
                document: std::fs::read_to_string(format!("{stem}{DOCUMENT_EXTENSION}"))?,
            })
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn keys_number_every_run_after_the_first() {
        let id = |test: &str, ordinal| RunId {
            suite: "accepted_tests".to_string(),
            test: test.to_string(),
            ordinal: NonZeroU32::new(ordinal).unwrap(),
        };
        assert_eq!(id("t", 1).key(), "accepted_tests/t");
        assert_eq!(id("m::t", 3).key(), "accepted_tests/m__t~3");
    }
}
