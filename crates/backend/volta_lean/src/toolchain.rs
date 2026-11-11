use std::collections::HashMap;
use std::env;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::process::Command;

use serde::{Deserialize, Serialize};

use crate::Error;
use crate::process;

/// The Lean binaries of a Lake project with Mathlib built, where its modules are built, and
/// the library sources an agent may search.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Toolchain {
    pub lean: PathBuf,
    pub leanchecker: PathBuf,
    pub lean_path: Vec<PathBuf>,
    pub sources: Vec<PathBuf>,
}

/// The directory of `project`, else of `$VOLTA_LEAN_PROJECT`, which must exist: a check cheap
/// enough to run before the work that needs the toolchain.
pub fn lean_project(project: Option<&Path>) -> Result<PathBuf, Error> {
    let project = match project {
        Some(project) => project.to_path_buf(),
        None => env::var_os("VOLTA_LEAN_PROJECT")
            .filter(|value| !value.is_empty())
            .map(PathBuf::from)
            .ok_or(Error::NoProject)?,
    };

    let project = expand_home(&project);
    fs::canonicalize(&project).map_err(|error| match error.kind() {
        io::ErrorKind::NotFound => Error::ProjectNotFound(project),
        _ => Error::Io {
            path: project,
            error,
        },
    })
}

impl Toolchain {
    /// The toolchain of `project`, else of `$VOLTA_LEAN_PROJECT`, as `lake env` reports it.
    pub fn of(project: Option<&Path>) -> Result<Toolchain, Error> {
        let root = lean_project(project)?;

        let printed = process::run(
            Command::new("lake")
                .args(["env", "printenv"])
                .current_dir(&root),
        )
        .map_err(|error| match error {
            Error::Process { error, .. } if error.kind() == io::ErrorKind::NotFound => {
                Error::LakeNotFound
            }
            error => error,
        })?;

        if !printed.succeeded() {
            return Err(Error::LakeEnv {
                project: root,
                stderr: printed.stderr().to_string(),
            });
        }

        let variables: HashMap<&str, &str> = printed
            .stdout()
            .lines()
            .filter_map(|line| line.split_once('='))
            .collect();

        let variable = |name: &'static str| {
            variables
                .get(name)
                .map(|value| env::split_paths(value).filter(|p| !p.as_os_str().is_empty()))
                .ok_or(Error::LakeVariable(name))
        };
        
        let sysroot = PathBuf::from(
            variables
                .get("LEAN_SYSROOT")
                .ok_or(Error::LakeVariable("LEAN_SYSROOT"))?,
        );

        // The project's own sources (an earlier proof, say) are not part of the library.
        let mut sources: Vec<PathBuf> = Vec::new();
        let listed = variable("LEAN_SRC_PATH").into_iter().flatten();
        for source in listed
            .filter_map(|path| fs::canonicalize(path).ok())
            .chain([sysroot.join("src/lean/Init")])
        {
            if source != root && source.is_dir() && !sources.contains(&source) {
                sources.push(source);
            }
        }

        Ok(Toolchain {
            lean: sysroot.join("bin/lean"),
            leanchecker: sysroot.join("bin/leanchecker"),
            lean_path: variable("LEAN_PATH")?.collect(),
            sources,
        })
    }
}

fn expand_home(path: &Path) -> PathBuf {
    match (path.strip_prefix("~"), env::var_os("HOME")) {
        (Ok(rest), Some(home)) => PathBuf::from(home).join(rest),
        _ => path.to_path_buf(),
    }
}
