# The workspace's recipes first, then one section per ISA: its volta_pipeline suites, then
# the external kernels in external/<isa>/. `just --list` shows only the comment line right
# above a recipe, so each recipe's one-line summary is its last comment line.

# The interpreter NKI kernels are traced with (`volta_trainium_analysis`'s `Tracer`).
export VOLTA_PYTHON := env("VOLTA_PYTHON", justfile_directory() / "target/volta-python/bin/python")

# List the recipes
help:
    @just --list --unsorted

# ===== Tests ==================================================================

# Run every Rust unit and integration test of the workspace
test: python-env nkilib
    cargo test --release --workspace --no-fail-fast -- --test-threads 16 --color always

# Run volta_pipeline's end-to-end tests of every ISA (PTX, AMD and Trainium kernels)
all: python-env nkilib
    cargo test --release -p volta_pipeline -- --test-threads 16 --color always

# Kernel modules import numpy, so tracing one needs a Python that has it.
# Create or update target/volta-python, the Python NKI kernels are traced with
python-env:
    uv venv -q --allow-existing --python ">=3.11" target/volta-python
    uv pip install -q --python target/volta-python/bin/python "numpy>=2"

# The nkilib suite traces nki-library's kernels at the commit external/trainium/nkilib/nki-library.commit names.
# Fetch that commit of nki-library into target/nkilib, unless it is already there
nkilib:
    #!/usr/bin/env sh
    set -eu
    commit=$(cat external/trainium/nkilib/nki-library.commit)
    if [ "$(git -C target/nkilib rev-parse HEAD 2>/dev/null)" != "$commit" ]; then
        rm -rf target/nkilib
        git init -q target/nkilib
        git -C target/nkilib fetch -q --depth 1 https://github.com/aws-neuron/nki-library.git "$commit"
        git -C target/nkilib -c advice.detachedHead=false checkout -q FETCH_HEAD
    fi

# ===== Static checks and formatting ===========================================

# Run the Rust and Python linters
check: check-rust check-python

# cargo check and clippy over the workspace
check-rust:
    cargo check --workspace
    cargo clippy --workspace

# Lint the Python bindings and the NKI tracer
check-python:
    uv run ruff check crates/volta_py crates/frontend/volta_trainium_analysis/tracer

# Format the Rust and Python sources in place
format: format-rust format-python

# rustfmt over the whole workspace
format-rust:
    cargo fmt --all

# Format the Python bindings and the NKI tracer
format-python:
    uv run ruff format crates/volta_py crates/frontend/volta_trainium_analysis/tracer

# ===== Tools ==================================================================

# A failing test does not stop the page: it still shows the runs the test recorded.
# Record the event graph of every volta_pipeline test run into one self-contained viewer page
viz out="target/volta-viz/volta-graphs.html": python-env
    rm -rf target/volta-viz/runs
    -VOLTA_VIZ_DIR="{{justfile_directory()}}/target/volta-viz/runs" cargo test --release --no-fail-fast -p volta_pipeline -- --test-threads 16
    cargo run --release -q -p volta_cli -- --no-log-file viz target/volta-viz/runs -o "{{out}}"

# Count the lines of code (Rust, Python, the viewer), per crate and per language
loc *args:
    python3 scripts/loc.py {{args}}

# `--sizes K...` and `--isa ptx amd trainium` narrow it, `--no-lean` skips Lean (else $VOLTA_LEAN_PROJECT is needed).
# Time Volta's canonical solver and Lean on external/benchmark's matmul tile at each K, writing external/benchmark/report.md
benchmark *args:
    cargo build --release -q -p volta_cli
    uv sync -q --reinstall-package volta
    python3 external/benchmark/benchmark.py {{args}}

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

# Check bitwise kernels; sample 32 outputs of the large LLM BitDelta and check full Triton tiles.
# The AMD builds (`*_amd.s`) print their error and do not stop the recipe
bitwise:
    #!/usr/bin/env bash
    set -eo pipefail
    cargo build --release -q -p volta_cli
    solve() { printf '%s: ' "$1"; ./target/release/volta --no-log-file solve "${@:2}" | sed -n 's/^VERDICT: //p'; }
    solve binary_gemm external/bitwise/binary_gemm.ptx --config external/bitwise/binary_gemm.launch.json
    solve cutlass_binary_gemm external/bitwise/cutlass_binary_gemm/kernel.ptx --config external/bitwise/cutlass_binary_gemm/kernel.launch.json --print-outputs 0
    solve triton_binary_gemm external/bitwise/triton_binary_gemm/kernel.ptx --config external/bitwise/triton_binary_gemm/kernel.launch.json --print-outputs 0
    solve bitdelta_llm external/bitwise/bitdelta_llm/kernel_tile.ptx --config external/bitwise/bitdelta_llm/kernel_tile.launch.json --recycle-terms 1000000 --sample 32
    solve bitdelta_triton_matmul external/bitwise/bitdelta_triton/binary_matmul_kernel.ptx --config external/bitwise/bitdelta_triton/binary_matmul_kernel.launch.json --recycle-terms 1000000 --print-outputs 0
    solve bitdelta_triton_bmm external/bitwise/bitdelta_triton/binary_bmm_kernel.ptx --config external/bitwise/bitdelta_triton/binary_bmm_kernel.launch.json --recycle-terms 1000000 --print-outputs 0
    solve simdjson_strings external/bitwise/simdjson/stage1.ptx --config external/bitwise/simdjson/stage1.launch.json
    solve simdjson_escape external/bitwise/simdjson/escape.ptx --config external/bitwise/simdjson/escape.launch.json
    solve simdjson_structural external/bitwise/simdjson/structural_start.ptx --config external/bitwise/simdjson/structural_start.launch.json
    solve simdjson_indexer external/bitwise/simdjson/indexer.ptx --config external/bitwise/simdjson/indexer.launch.json
    solve simdjson_digits external/bitwise/simdjson/digits.ptx --config external/bitwise/simdjson/digits.launch.json
    amd() { printf '%s: ' "$1"; ./target/release/volta --no-log-file solve "external/bitwise/$2.s" --config "external/bitwise/$2.launch.json" --print-outputs 0 2>&1 | sed -n 's/^VERDICT: //p; s/^error: /ERROR: /p' || true; }
    amd amd_triton_binary_gemm triton_binary_gemm/kernel_amd
    amd amd_bitdelta_triton_matmul bitdelta_triton/binary_matmul_kernel_amd
    amd amd_bitdelta_triton_bmm bitdelta_triton/binary_bmm_kernel_amd

# Analyze TileLang's warp-specialized copy-GEMM kernel, printing volta's full report
tilelang-ws-gemm *args:
    cargo run --release -q -p volta_cli -- analyze external/ptx/tilelang/warp_specialize/matmul_warp_specialize_copy_gemm_0_1_kernel.ptx --config external/ptx/tilelang/warp_specialize/matmul_warp_specialize_copy_gemm_0_1_kernel.m128n128k64.launch.json --no-profile {{args}}

# `--sample N` checks N outputs per kernel, `--filter TEXT` the cases naming it, `--markdown` prints the README's table.
# Check the fused GEMM + activation kernels of CUTLASS, Triton, Composable Kernel and OpenCL in external/approximations
approximations *args:
    cargo build --release -q -p volta_cli
    python3 external/approximations/verify.py --report external/approximations/REPORT.md {{args}}

# `--no-lean` skips the agent, `--force` measures again, COLUMN... narrows it; Lean needs $VOLTA_LEAN_PROJECT and Claude Code.
# Fill the paper's GEMM + activation table (rewrites and Lean on the 64 x 256 tile) in external/approximations/table
approximations-table *args:
    cargo build --release -q -p volta_cli
    uv run --reinstall-package volta --package volta python external/approximations/table/table.py {{args}}

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

# `--extract-only` writes the Lean challenges without proving them; CASE... narrows the run.
# Check the OpenCL activations in external/approximations/opencl: the canonical solver, else a Lean proof
opencl_lean *args:
    uv run --reinstall-package volta --package volta python external/approximations/opencl/prove.py {{args}}

# `--verbose` prints each case's log.
# Check PyTorch's piecewise activations in external/activation against their specs
piecewise *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py --checker solver {{args}} activation/

# `--verbose` prints each case's log; `python3 external/amd/hipkittens/compile.py` recompiles them.
# Check HipKittens' kernels in external/amd/hipkittens against their specs (bugs in bug.txt)
hipkittens *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py {{args}} hipkittens/

# `--verbose` prints each case's log.
# Check Triton's tutorial kernels in external/amd/triton against their specs
triton *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py --checker solver {{args}} triton/

# `--verbose` prints each case's log; `python3 external/amd/aiter/build.py [CASE...]` recompiles them.
# Check Aiter's kernels in external/amd/aiter, the bugs Volta found and their fixes
aiter *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py {{args}} aiter/

# `--verbose` prints each case's log; `python3 external/amd/aklr/build.py [CASE...]` recompiles them.
# Check AKLR's kernels in external/amd/aklr, the bugs Volta found and their fixes
aklr *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py {{args}} aklr/

# `--verbose` prints each case's log; `python3 external/amd/opencl/{miopen,clblast}/extract.py [CASE...]` recompiles them.
# Check MIOpen's and CLBlast's OpenCL kernels for gfx950 in external/amd/opencl, the bugs Volta found and their fixes
opencl *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py {{args}} opencl/

# `--verbose` prints each case's log; `python3 external/amd/flydsl/extract.py [CASE...]` recompiles them.
# Check FlyDSL's kernels in external/amd/flydsl, the bugs Volta found and their fixes
flydsl *args:
    uv run --reinstall-package volta --package volta python external/amd/verify.py {{args}} flydsl/

# ===== Trainium ===============================================================

# Release, since attention v2 against its spec takes a minute in debug; VOLTA_BLESS=1 rewrites the snapshots.
# Check the Trainium kernels' .ast, .ir and .out snapshots, expected rejections and spec equivalence,
# and nkilib's bugs and their fixes (external/trainium/nkilib)
trainium: python-env nkilib
    cargo test -q -p volta_pipeline --test trainium_tests -- accepted_tests:: rejected_tests::
    cargo test -q --release -p volta_pipeline --test trainium_tests -- equivalence_tests:: nkilib_tests::
