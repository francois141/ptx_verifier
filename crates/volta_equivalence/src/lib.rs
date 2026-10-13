//! Equivalence checking of symbolic-execution outputs: the canonicalizer
//! (`canon`, wrapped by `equiv`), the f64 oracle (`numeric`), per-element
//! output checking (`check`) and the `.vcdump` format (`vc_dump`).

mod logging;

pub mod canon;
pub mod check;
pub mod equiv;
pub mod numeric;
pub mod vc_dump;

pub use check::{
    EquivCheckError, EquivCheckOptions, EquivCheckReport, EquivOutcome, check_output_equivalence,
    check_output_equivalence_with,
};
pub use equiv::{CanonValueEquality, EquivSession};
pub use vc_dump::VcDump;
