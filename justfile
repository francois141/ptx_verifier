# Print the list of commands
help:
    @just --list --unsorted

# Run the Rust and Python tests
test: test-rust test-python

# Rust unit + integration tests
test-rust:
    cargo test --release --workspace -- --test-threads 16 --color always

# volta_pipeline's tests (PTX kernels through the analysis stage and graph branch)
all:
    cargo test --release -p volta_pipeline -- --test-threads 16 --color always

# Record the event graph of every volta_pipeline test run and build the viewer page
# (one self-contained .html file). Test failures do not stop the page: a failing
# test still shows the runs it recorded.
viz out="target/volta-viz/volta-graphs.html":
    rm -rf target/volta-viz/runs
    -VOLTA_VIZ_DIR="{{justfile_directory()}}/target/volta-viz/runs" cargo test --release --no-fail-fast -p volta_pipeline -- --test-threads 16
    cargo run --release -q -p volta_cli -- --no-log-file viz target/volta-viz/runs -o "{{out}}"

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

# Count the lines of code (Rust, Python, the viewer), per crate and per language
loc *args:
    python3 scripts/loc.py {{args}}
