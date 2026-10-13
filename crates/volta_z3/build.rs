use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

fn contains_z3(dir: &Path) -> bool {
    ["libz3.dylib", "libz3.so", "libz3.a"]
        .iter()
        .any(|name| dir.join(name).is_file())
}

fn homebrew_z3_lib_dir() -> Option<PathBuf> {
    let output = Command::new("brew")
        .args(["--prefix", "z3"])
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }

    let prefix = String::from_utf8(output.stdout).ok()?;
    Some(PathBuf::from(prefix.trim()).join("lib"))
}

fn main() {
    println!("cargo:rerun-if-env-changed=Z3_LIB_DIR");

    if let Some(dir) = env::var_os("Z3_LIB_DIR").map(PathBuf::from) {
        if !contains_z3(&dir) {
            panic!(
                "Z3_LIB_DIR={} does not contain libz3; point it at Z3's library directory",
                dir.display()
            );
        }
        println!("cargo:rustc-link-search=native={}", dir.display());
        return;
    }

    // Homebrew keeps Z3 keg-only, so its library directory is not in the
    // macOS linker's default search path. Linux package installs use a
    // standard linker path and need no extra configuration.
    if env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("macos") {
        let mut candidates = Vec::new();
        if let Some(prefix) = env::var_os("HOMEBREW_PREFIX") {
            candidates.push(PathBuf::from(prefix).join("opt/z3/lib"));
        }
        candidates.extend([
            PathBuf::from("/opt/homebrew/opt/z3/lib"),
            PathBuf::from("/usr/local/opt/z3/lib"),
        ]);
        let dir = candidates
            .into_iter()
            .find(|dir| contains_z3(dir))
            .or_else(homebrew_z3_lib_dir)
            .filter(|dir| contains_z3(dir));
        if let Some(dir) = dir {
            println!("cargo:rustc-link-search=native={}", dir.display());
        }
    }
}
