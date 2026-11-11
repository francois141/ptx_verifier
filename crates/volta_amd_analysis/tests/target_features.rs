//! Target-ID validation at the public lowering boundary.

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{LowerError, lower_kernel};

const COPY: &str = include_str!("fixtures/copy.s");

#[test]
fn accepts_and_preserves_target_feature_selections() {
    for suffix in [
        "",
        ":xnack+",
        ":xnack-",
        ":sramecc+",
        ":sramecc-",
        ":xnack+:sramecc+",
        ":xnack+:sramecc-",
        ":xnack-:sramecc+",
        ":xnack-:sramecc-",
        ":sramecc+:xnack+",
        ":sramecc+:xnack-",
        ":sramecc-:xnack+",
        ":sramecc-:xnack-",
    ] {
        let mut kernel = parse_kernel(COPY, "copy").unwrap();
        kernel.target = format!("amdgcn-amd-amdhsa--gfx950{suffix}");
        assert_eq!(lower_kernel(&kernel).unwrap().target, kernel.target);
    }
}

#[test]
fn rejects_invalid_target_feature_selections() {
    for suffix in [
        ":",
        "::xnack-",
        ":banana",
        ":xnack",
        ":sramecc",
        ":xnack+:xnack-",
        ":xnack-:xnack-",
        ":sramecc+:sramecc-",
        ":sramecc+:sramecc+",
        ":xnack-:",
    ] {
        let mut kernel = parse_kernel(COPY, "copy").unwrap();
        kernel.target = format!("amdgcn-amd-amdhsa--gfx950{suffix}");
        assert_eq!(
            lower_kernel(&kernel).unwrap_err(),
            LowerError::UnsupportedTarget {
                target: kernel.target.clone(),
            }
        );
    }
}
