"""Lean extraction across ISAs, including the graph checks that must gate it."""

from pathlib import Path

import pytest

import volta
from kernels import COPY_KERNEL, DEADLOCK_KERNEL, copy_config

ROOT = Path(__file__).resolve().parents[3]
ADD_SPEC = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"
COPY_SPEC = "dim N; array in[N]; array out[N]; out[i] = in[i];"


def add_config(size):
    config = volta.Config(block=(size, 1, 1))
    for name, base, kind in (
        ("a", 0x10000, volta.ArrayKind.Input),
        ("b", 0x20000, volta.ArrayKind.Input),
        ("out", 0x30000, volta.ArrayKind.Output),
    ):
        config.add_array(volta.ArrayDef(name, base, 4, size, kind))
        config.add_param(volta.Param.array_ptr(name))
    return config


@pytest.mark.parametrize(
    "path,size,isa,race_verified",
    [
        ("examples/quickstart/add.ptx", 128, "NVIDIA PTX", True),
        ("crates/volta_amd_analysis/tests/fixtures/add.s", 64, "AMD gfx950", True),
        (
            "crates/volta_trainium_analysis/tests/fixtures/add.py",
            256,
            "AWS Trainium NKI",
            None,
        ),
    ],
)
@pytest.mark.parametrize("tolerance", [None, "1/1000"])
def test_extracts_every_output(path, size, isa, race_verified, tolerance):
    config = None if path.endswith(".py") else add_config(size)
    result = volta.extract_lean(
        ROOT / path,
        config,
        spec=ADD_SPEC,
        dims={"N": size},
        tolerance=tolerance,
    )
    assert isinstance(result, volta.LeanExtraction)
    assert result.isa == isa
    assert result.race_verified is race_verified
    assert result.statements == size
    assert result.lean.startswith("import Mathlib\n")
    assert result.lean.count(" : Prop :=") == size
    assert f"def out_{size - 1} : Prop :=" in result.lean
    if tolerance:
        assert "≤ (0.001 : ℝ)" in result.lean
    else:
        assert " = " in result.lean


def test_race_raises_before_returning_a_lean_module(tmp_path):
    # Distinct input values race to the same output address. The run has symbolic outputs,
    # so the graph check must reject it even though the exporter could state propositions.
    path = tmp_path / "race.ptx"
    path.write_text(
        COPY_KERNEL.replace("add.s64 %rd5, %rd2, %rd3;", "mov.b64 %rd5, %rd2;")
    )
    with pytest.raises(volta.DataRaceError, match="memory-conflict freedom failed"):
        volta.extract_lean(path, copy_config(), spec=COPY_SPEC, dims={"N": 1})


def test_deadlock_raises_before_returning_a_lean_module(tmp_path):
    path = tmp_path / "deadlock.ptx"
    path.write_text(DEADLOCK_KERNEL)
    with pytest.raises(volta.DeadlockError, match="deadlocked"):
        volta.extract_lean(
            path,
            volta.Config(block=(2, 1, 1)),
            spec=COPY_SPEC,
            dims={"N": 4},
        )


def test_incomplete_trace_cannot_produce_a_lean_module():
    config = volta.Config(block=(128, 1, 1), max_instructions=1)
    for name, base, kind in (
        ("a", 0x10000, volta.ArrayKind.Input),
        ("b", 0x20000, volta.ArrayKind.Input),
        ("out", 0x30000, volta.ArrayKind.Output),
    ):
        config.add_array(volta.ArrayDef(name, base, 4, 128, kind))
        config.add_param(volta.Param.array_ptr(name))
    with pytest.raises(volta.VoltaError, match="graph verification is UNKNOWN"):
        volta.extract_lean(
            ROOT / "examples/quickstart/add.ptx", config, spec=ADD_SPEC, dims={"N": 128}
        )


def test_missing_output_indices_fail_extraction():
    with pytest.raises(volta.VoltaError, match="same set of indices"):
        volta.extract_lean(
            ROOT / "examples/quickstart/add.ptx",
            add_config(128),
            spec=ADD_SPEC,
            dims={"N": 129},
        )


@pytest.mark.parametrize("tolerance", ["not-a-rational", "-1/1000"])
def test_invalid_tolerance_fails_extraction(tolerance):
    with pytest.raises(volta.VoltaError, match="tolerance"):
        volta.extract_lean(
            ROOT / "crates/volta_trainium_analysis/tests/fixtures/add.py",
            spec=ADD_SPEC,
            dims={"N": 256},
            tolerance=tolerance,
        )


def test_solve_no_longer_selects_the_lean_exporter():
    with pytest.raises(TypeError, match="solver"):
        volta.solve(
            ROOT / "crates/volta_trainium_analysis/tests/fixtures/add.py",
            spec=ADD_SPEC,
            dims={"N": 256},
            solver="lean",
        )
