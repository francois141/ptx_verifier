//! PTX kernels end to end, one module per suite, over the kernels in this directory's
//! outcome folders (`success/`, `check_failure/`, `execution_error/`, ...).

#[macro_use]
#[path = "../common/mod.rs"]
mod common;

mod accepted_tests;
mod aggregation_tests;
mod allocation_order_tests;
mod allocation_permit_tests;
mod graph_tests;
mod mbarrier_epoch_tests;
mod mbarrier_ordering_tests;
mod mbarrier_release_order_tests;
mod memory_conflict_tests;
mod negative_equivalence_tests;
mod proxy_order_tests;
mod rejected_tests;
mod resource_lifetime_tests;
mod soundness_tests;
mod tensor_order_tests;
