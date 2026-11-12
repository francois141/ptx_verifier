# The workspace's recipes first, then one section per ISA: its volta_pipeline suites, then
# the external kernels in external/<isa>/. `just --list` shows only the comment line right
# above a recipe, so each recipe's one-line summary is its last comment line.

# List the recipes
help:
    @just --list --unsorted

# ===== Tests ==================================================================

# Run every Rust unit and integration test of the workspace
test:
    cargo test --release --workspace --no-fail-fast -- --test-threads 16 --color always

# Run volta_pipeline's end-to-end tests of every ISA (PTX, AMD and Trainium kernels)
all:
    cargo test --release -p volta_pipeline -- --test-threads 16 --color always

# ===== Static checks and formatting ===========================================

# Run the Rust and Python linters
check: check-rust check-python

# cargo check and clippy over the workspace
check-rust:
    cargo check --workspace
    cargo clippy --workspace

# Lint the Python bindings
check-python:
    uv run ruff check crates/volta_py

# Format the Rust and Python sources in place
format: format-rust format-python

# rustfmt over the whole workspace
format-rust:
    cargo fmt --all

# Format the Python bindings
format-python:
    uv run ruff format crates/volta_py

# ===== Tools ==================================================================

# A failing test does not stop the page: it still shows the runs the test recorded.
# Record the event graph of every volta_pipeline test run into one self-contained viewer page
viz out="target/volta-viz/volta-graphs.html":
    rm -rf target/volta-viz/runs
    -VOLTA_VIZ_DIR="{{justfile_directory()}}/target/volta-viz/runs" cargo test --release --no-fail-fast -p volta_pipeline -- --test-threads 16
    cargo run --release -q -p volta_cli -- --no-log-file viz target/volta-viz/runs -o "{{out}}"

# Count the lines of code (Rust, Python, the viewer), per crate and per language
loc *args:
    python3 scripts/loc.py {{args}}

# ===== PTX ====================================================================

# Run volta_pipeline's PTX kernel suites
ptx:
    cargo test --release -p volta_pipeline --test ptx_tests -- --test-threads 16 --color always

# Most TileLang kernels are downloaded and the AI compiler's copied; the rest compile in Docker on macOS.
# Compile the external PTX kernels again from external/ptx/sources
setup:
    uv run external/ptx/extraction/tritonbench.py
    uv run external/ptx/extraction/thunderkittens.py
    uv run external/ptx/extraction/gluon.py
    uv run external/ptx/extraction/tilelang_kernels.py
    uv run external/ptx/extraction/ai_compiler.py

# Each race recipe writes external/ptx/output/<framework>.csv; `-k NAME` and `--timeout SECONDS` narrow it.
# Check every external PTX framework for data races
external *args:
    python3 external/ptx/races.py {{args}}

# Check the TritonBench kernels for data races
tritonbench *args:
    python3 external/ptx/races.py --framework tritonbench {{args}}

# Check the ThunderKittens kernels for data races
kittens *args:
    python3 external/ptx/races.py --framework thunderkittens {{args}}

# Check the Gluon tutorials' kernels for data races
gluon *args:
    python3 external/ptx/races.py --framework gluon {{args}}

# Check the TileLang examples' kernels for data races
tilelang *args:
    python3 external/ptx/races.py --framework tilelang {{args}}

# Check the AI compiler's PTX for PTX Gym's operators for data races (the largest GEMMs take minutes)
ai_compiler *args:
    python3 external/ptx/races.py --framework ai_compiler {{args}}

# Analyze TileLang's warp-specialized copy-GEMM kernel, printing volta's full report
tilelang-ws-gemm *args:
    cargo run --release -q -p volta_cli -- analyze external/ptx/tilelang/warp_specialize/matmul_warp_specialize_copy_gemm_0_1_kernel.ptx --config external/ptx/tilelang/warp_specialize/matmul_warp_specialize_copy_gemm_0_1_kernel.m128n128k64.launch.json --no-profile {{args}}

# ===== AMD ====================================================================

# Check the AMD kernels' outputs, expected rejections and functional equivalence
amd:
    @cargo test -q -p volta_pipeline --test amd_tests -- --test-threads=1 accepted_tests:: rejected_tests:: >/dev/null
    @cargo test -q -p volta_pipeline --test amd_tests -- --test-threads=1 equivalence_tests::

# Write the AMD sigmoid kernel's Lean challenge to target/lean/sigmoid.lean
extract-lean:
    @cargo test -q -p volta_pipeline --test amd_tests -- lean_tests:: >/dev/null
    @echo "Wrote target/lean/sigmoid.lean"

# The fused GEMM-sigmoid is verified in Lean instead of solved; it needs $VOLTA_LEAN_PROJECT and Claude Code.
# `--verbose` prints each case's log.
# Check the Composable Kernel examples in external/amd against their specs
composable *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py {{args}}

# `--verbose` prints each case's log.
# Check CK's activation ops, compiled with and without -ffast-math, against their specs
amd_activations *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py --checker solver {{args}} activations

# `--verbose` prints each case's log.
# Prove in Lean the activation ops the canonical solver cannot decide; needs $VOLTA_LEAN_PROJECT and Claude Code
activation_lean *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py --checker lean {{args}} activations

# ===== Trainium ===============================================================

# Release, since attention v2 against its spec takes a minute in debug; VOLTA_BLESS=1 rewrites the snapshots.
# Check the Trainium kernels' .ast, .ir and .out snapshots, expected rejections and spec equivalence
trainium:
    cargo test -q -p volta_pipeline --test trainium_tests -- accepted_tests:: rejected_tests::
    cargo test -q --release -p volta_pipeline --test trainium_tests -- equivalence_tests::
