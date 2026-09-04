# Print the list of commands
help:
    @just --list --unsorted

# Run the Rust and Python tests
test: test-rust test-python

# Rust unit + integration tests
test-rust:
    cargo test --workspace --exclude volta_z3 --exclude volta_bench

# Python bindings tests
test-python:
    uv run pytest crates/volta_py

# Static checks
check: check-rust check-python

# cargo check + clippy
check-rust:
    cargo check --workspace --exclude volta_z3 --exclude volta_bench
    cargo clippy --workspace --exclude volta_z3 --exclude volta_bench

# Lint the Python bindings
check-python:
    uv run ruff check crates/volta_py

# Format Rust and Python sources in place
format: format-rust format-python

# rustfmt over the whole workspace
format-rust:
    cargo fmt --all

# Format the Python bindings
format-python:
    uv run ruff format crates/volta_py

