//! AMD assembly analysis: parsing (`frontend`), lowering (`lower`, `ir`),
//! and symbolic execution (`eval`).

pub mod frontend;

mod eval;
mod ir;
mod lower;
