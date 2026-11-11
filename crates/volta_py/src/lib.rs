//! Python bindings for the Volta analysis engine (v0: `parse`, `analyze` and `verify` over
//! PTX source, and `solve` / `extract_lean` over a kernel file of any ISA - see `crates/volta_cli` for the
//! full command set this will grow towards, notably `compare`).

use pyo3::prelude::*;

mod analyze;
mod config;
mod error;
mod extract;
mod logging;
mod solve;
mod verify;

use config::{ArrayDefPy, ArrayKindPy, ConfigPy, ParamPy};
use error::{DataRaceError, DeadlockError, VoltaError};

#[pymodule]
fn volta(py: Python<'_>, m: &Bound<'_, PyModule>) -> PyResult<()> {
    logging::install();

    m.add_class::<ConfigPy>()?;
    m.add_class::<ArrayDefPy>()?;
    m.add_class::<ArrayKindPy>()?;
    m.add_class::<ParamPy>()?;
    m.add_class::<analyze::StatsPy>()?;
    m.add_class::<analyze::AnalyzeResultPy>()?;
    m.add_class::<verify::VerifyResultPy>()?;
    m.add_class::<solve::SolveResultPy>()?;
    m.add_class::<extract::LeanExtractionPy>()?;

    m.add_function(wrap_pyfunction!(analyze::parse, m)?)?;
    m.add_function(wrap_pyfunction!(analyze::analyze, m)?)?;
    m.add_function(wrap_pyfunction!(verify::verify, m)?)?;
    m.add_function(wrap_pyfunction!(solve::solve, m)?)?;
    m.add_function(wrap_pyfunction!(extract::extract_lean, m)?)?;

    m.add("VoltaError", py.get_type::<VoltaError>())?;
    m.add("DataRaceError", py.get_type::<DataRaceError>())?;
    m.add("DeadlockError", py.get_type::<DeadlockError>())?;

    Ok(())
}
