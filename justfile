# Print the list of commands
help:
    @just --list --unsorted

# Run the Rust and Python tests
test: test-rust test-python

# Rust unit + integration tests
test-rust:
    cargo test --release --workspace -- --test-threads 16 --color always

# volta_bench's PTX-driven tests (kernels through the analysis stage and graph branch)
all:
    cargo test --release -p volta_bench -- --test-threads 16 --color always

# Python bindings tests (rebuilding the extension, so they never test a stale build)
test-python:
    uv run --reinstall-package volta pytest crates/volta_py

# Static checks
check: check-rust check-python

# cargo check + clippy
check-rust:
    cargo check --workspace
    cargo clippy --workspace

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
