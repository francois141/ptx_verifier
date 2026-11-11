use std::fs;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use regex::RegexBuilder;

/// The Lean sources under some roots, read on the first search.
pub(crate) struct Library {
    roots: Vec<PathBuf>,
    files: OnceLock<Vec<SourceFile>>,
}

struct SourceFile {
    name: String,
    text: String,
}

impl Library {
    pub(crate) fn new(roots: Vec<PathBuf>) -> Library {
        Library {
            roots,
            files: OnceLock::new(),
        }
    }

    /// Every line matching `pattern` (multiline mode), as `root/path:line: text`, up to `limit`.
    pub(crate) fn search(&self, pattern: &str, limit: usize) -> Result<String, regex::Error> {
        let regex = RegexBuilder::new(pattern).multi_line(true).build()?;
        let mut hits = Vec::new();

        for file in self.files() {
            let (mut line, mut counted, mut previous) = (1, 0, 0);
            for found in regex.find_iter(&file.text) {
                line += file.text[counted..found.start()].matches('\n').count();
                counted = found.start();
                if line == previous {
                    continue;
                }
                previous = line;

                let start = file.text[..found.start()].rfind('\n').map_or(0, |i| i + 1);
                let end = file.text[found.start()..]
                    .find('\n')
                    .map_or(file.text.len(), |i| found.start() + i);
                hits.push(format!(
                    "{}:{line}: {}",
                    file.name,
                    file.text[start..end].trim()
                ));

                if hits.len() >= limit {
                    return Ok(format!("{}\n(stopped at {limit} matches)", hits.join("\n")));
                }
            }
        }

        Ok(if hits.is_empty() {
            "no matches".to_string()
        } else {
            hits.join("\n")
        })
    }

    fn files(&self) -> &[SourceFile] {
        self.files.get_or_init(|| {
            self.roots
                .iter()
                .flat_map(|root| lean_files(root))
                .collect()
        })
    }
}

fn lean_files(root: &Path) -> Vec<SourceFile> {
    let mut paths = Vec::new();
    collect(root, &mut paths);
    paths.sort();

    let prefix = root.file_name().unwrap_or_default().to_string_lossy();
    paths
        .into_iter()
        .filter_map(|path| {
            let bytes = fs::read(&path).ok()?;
            let relative = path.strip_prefix(root).ok()?;
            Some(SourceFile {
                name: format!("{prefix}/{}", relative.display()),
                text: String::from_utf8_lossy(&bytes).into_owned(),
            })
        })
        .collect()
}

/// The `.lean` files under `directory`, outside `.lake` build directories; symbolic links to
/// directories are not followed.
fn collect(directory: &Path, paths: &mut Vec<PathBuf>) {
    let Ok(entries) = fs::read_dir(directory) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        let Ok(kind) = entry.file_type() else {
            continue;
        };
        if kind.is_dir() {
            if entry.file_name() != ".lake" {
                collect(&path, paths);
            }
        } else if path.extension().is_some_and(|e| e == "lean") && path.is_file() {
            paths.push(path);
        }
    }
}
