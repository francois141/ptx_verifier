# Print the list of commands
help:
    @just --list --unsorted

# Check the B200 AI-compiler FP16 GEMM kernel for races/deadlocks
check_ai_compiler_gemm:
    cargo run --release -p volta_cli -- analyze crates/volta_bench/kernels/B200_ai_compiler/gemm_f16_4096.ptx \
        -b 256 -g 16,16 --dyn-shared 196448 --print-outputs 10 \
        --array "A:0x100000000:2:16777216:in" \
        --array "B:0x200000000:2:16777216:in" \
        --array "C:0x300000000:2:16777216:out" \
        --param ptr:A --param ptr:B --param ptr:C --param int:0 --param int:0

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
