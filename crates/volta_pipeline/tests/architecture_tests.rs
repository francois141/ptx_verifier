//! The pipeline's boundaries, checked on the sources and manifests: the analysis runs no
//! checker and no equivalence, its frontend knows nothing of the stages after it, and the
//! two branches never depend on each other.

use std::path::{Path, PathBuf};

fn crates_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .to_path_buf()
}

/// The `[dependencies]` of a crate's manifest (dev-dependencies excluded).
fn dependencies(krate: &str) -> Vec<String> {
    let manifest = std::fs::read_to_string(crates_dir().join(krate).join("Cargo.toml")).unwrap();
    let mut in_deps = false;
    let mut deps = Vec::new();
    for line in manifest.lines() {
        let line = line.trim();
        if line.starts_with('[') {
            in_deps = line == "[dependencies]";
        } else if in_deps && let Some((name, _)) = line.split_once(['=', '.']) {
            deps.push(name.trim().to_string());
        }
    }
    deps
}

fn rust_sources(dir: &Path, out: &mut Vec<PathBuf>) {
    for entry in std::fs::read_dir(dir).unwrap() {
        let path = entry.unwrap().path();
        if path.is_dir() {
            rust_sources(&path, out);
        } else if path.extension().is_some_and(|e| e == "rs") {
            out.push(path);
        }
    }
}

#[test]
fn the_analysis_runs_no_checker_and_no_equivalence() {
    let mut files = Vec::new();
    rust_sources(&crates_dir().join("volta_analysis/src"), &mut files);
    for file in &files {
        let text = std::fs::read_to_string(file).unwrap();
        let code: Vec<&str> = text
            .lines()
            .filter(|l| !l.trim_start().starts_with("//"))
            .collect();
        for forbidden in ["volta_graph_check", "volta_equivalence", "volta_pipeline"] {
            assert!(
                !code.iter().any(|l| l.contains(forbidden)),
                "{} (analysis stage) references {forbidden}",
                file.display()
            );
        }
    }
    let deps = dependencies("volta_analysis");
    for forbidden in ["volta_graph_check", "volta_equivalence", "volta_pipeline"] {
        assert!(
            !deps.iter().any(|d| d == forbidden),
            "the analysis depends on {forbidden}"
        );
    }
}

#[test]
fn the_frontend_imports_nothing_of_the_analysis_after_it() {
    let mut files = Vec::new();
    rust_sources(
        &crates_dir().join("volta_analysis/src/frontend"),
        &mut files,
    );
    for file in &files {
        let text = std::fs::read_to_string(file).unwrap();
        let code: Vec<&str> = text
            .lines()
            .filter(|l| !l.trim_start().starts_with("//"))
            .collect();
        for forbidden in [
            "crate::analysis",
            "crate::config",
            "crate::eval",
            "crate::ir",
            "crate::lower",
            "volta_expr",
            "volta_graph",
        ] {
            assert!(
                !code.iter().any(|l| l.contains(forbidden)),
                "{} (frontend) references {forbidden}",
                file.display()
            );
        }
    }
}

#[test]
fn the_branches_never_depend_on_each_other_or_on_the_stage() {
    let graph_branch = dependencies("volta_graph_check");
    let equivalence_branch = dependencies("volta_equivalence");
    for forbidden in ["volta_equivalence", "volta_analysis", "volta_pipeline"] {
        assert!(
            !graph_branch.iter().any(|d| d == forbidden),
            "the graph branch depends on {forbidden}"
        );
    }
    for forbidden in [
        "volta_graph",
        "volta_graph_check",
        "volta_analysis",
        "volta_pipeline",
    ] {
        assert!(
            !equivalence_branch.iter().any(|d| d == forbidden),
            "the equivalence branch depends on {forbidden}"
        );
    }
    let graph = dependencies("volta_graph");
    for forbidden in ["volta_graph_check", "volta_equivalence", "volta_analysis"] {
        assert!(
            !graph.iter().any(|d| d == forbidden),
            "the graph model depends on {forbidden}"
        );
    }
}
