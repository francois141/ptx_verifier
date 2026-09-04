
# Run the Rust and Python tests (excludes volta_z3/volta_bench - see test-all)
test: test-rust test-python

# Rust unit + integration tests, minus the crates that unconditionally link libz3
test-rust:
    cargo test --workspace --exclude volta_z3 --exclude volta_bench

# Python bindings tests (crates/volta_py)
test-python:
    uv run pytest crates/volta_py

