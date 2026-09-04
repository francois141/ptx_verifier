"""Tests for `volta.parse`/`volta.analyze`.

Run via `uv run pytest crates/volta_py` (or `maturin develop && pytest`
from `crates/volta_py/`) - the module must be built and installed into
the active environment first, since pytest alone does not build the
Rust extension.
"""

import pytest

import volta
from kernels import (
    BAD_KERNEL,
    COPY_KERNEL,
    DEADLOCK_KERNEL,
    MULTI_ENTRY_KERNEL,
    RACE_KERNEL,
    copy_config,
    single_output_config,
)


def test_parse_valid_source():
    volta.parse(COPY_KERNEL)  # must not raise


def test_parse_syntax_error_raises_volta_error():
    with pytest.raises(volta.VoltaError) as exc_info:
        volta.parse(BAD_KERNEL)
    message = str(exc_info.value)
    assert "line 5" in message
    assert "column" in message


def test_analyze_copy_kernel_outputs():
    result = volta.analyze(COPY_KERNEL, copy_config())

    assert len(result.outputs) == 1
    array_name, elements = result.outputs[0]
    assert array_name == "out"
    assert elements == [(0, "in[0]"), (1, "in[1]"), (2, "in[2]"), (3, "in[3]")]


def test_analyze_copy_kernel_stats_and_op_counts():
    result = volta.analyze(COPY_KERNEL, copy_config())

    assert result.stats.instructions == 4 * 11  # 11 instructions * 4 threads
    assert result.stats.block_syncs == 0
    assert result.stats.warp_syncs == 0

    assert result.op_counts["Load"] == 4
    assert result.op_counts["Store"] == 4


def test_analyze_data_race_raises_data_race_error():
    with pytest.raises(volta.DataRaceError) as exc_info:
        volta.analyze(RACE_KERNEL, volta.Config(block=(2, 1, 1)))
    assert "data race" in str(exc_info.value)
    # DataRaceError must stay catchable as the base exception too.
    assert isinstance(exc_info.value, volta.VoltaError)


def test_analyze_deadlock_raises_deadlock_error():
    with pytest.raises(volta.DeadlockError):
        volta.analyze(DEADLOCK_KERNEL, volta.Config(block=(2, 1, 1)))


def test_analyze_unknown_kernel_raises_volta_error():
    with pytest.raises(volta.VoltaError, match="no kernel named"):
        volta.analyze(COPY_KERNEL, copy_config(), kernel="does_not_exist")


def test_analyze_kernel_none_picks_first_entry_in_source_order():
    # kernel_a is declared before kernel_b in MULTI_ENTRY_KERNEL; kernel=None
    # has no notion of a "default" or "unique" entry, it just takes the
    # first `.entry` the parser encountered, regardless of name.
    result = volta.analyze(MULTI_ENTRY_KERNEL, single_output_config())
    _, elements = result.outputs[0]
    assert elements == [(0, "111"), (1, "111")]


def test_analyze_explicit_kernel_name_selects_named_entry():
    result = volta.analyze(MULTI_ENTRY_KERNEL, single_output_config(), kernel="kernel_b")
    _, elements = result.outputs[0]
    assert elements == [(0, "222"), (1, "222")]
