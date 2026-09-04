"""Tests for `volta.verify` (a PTX kernel checked against a math spec)."""

import pytest

import volta
from kernels import COPY_KERNEL, copy_config

# out[i] = in[i], matching COPY_KERNEL exactly.
COPY_SPEC = "dim N; array in[N]; array out[N]; out[i] = in[i];"

# Deliberately wrong: the kernel doesn't add anything.
WRONG_SPEC = "dim N; array in[N]; array out[N]; out[i] = in[i] + 1.0;"

BAD_SPEC = "dim N array in[N];"  # missing semicolon after N


def test_verify_matching_spec_is_equivalent():
    result = volta.verify(COPY_KERNEL, COPY_SPEC, copy_config(), dims={"N": 4})

    assert result.equivalent
    assert result.mismatches == []
    assert result.elements_checked == 4
    assert result.elements_total == 4
    assert result.stats.instructions == 4 * 11


def test_verify_wrong_spec_reports_mismatches():
    result = volta.verify(COPY_KERNEL, WRONG_SPEC, copy_config(), dims={"N": 4})

    assert not result.equivalent
    assert result.mismatches == [("out", 0), ("out", 1), ("out", 2), ("out", 3)]


def test_verify_sample_limits_checked_elements():
    result = volta.verify(
        COPY_KERNEL, COPY_SPEC, copy_config(), dims={"N": 4}, sample=2
    )

    assert result.equivalent
    assert result.elements_checked == 2
    assert result.elements_total == 2


def test_verify_spec_syntax_error_raises_volta_error():
    with pytest.raises(volta.VoltaError, match="spec parse error"):
        volta.verify(COPY_KERNEL, BAD_SPEC, copy_config(), dims={"N": 4})


def test_verify_missing_dim_value_raises_volta_error():
    with pytest.raises(volta.VoltaError, match="no value given for dim 'N'"):
        volta.verify(COPY_KERNEL, COPY_SPEC, copy_config(), dims={})


def test_verify_requires_declared_output_array():
    spec = "dim N; array in[N]; array missing[N]; missing[i] = in[i];"
    with pytest.raises(volta.VoltaError, match="declared output array named 'missing'"):
        volta.verify(COPY_KERNEL, spec, copy_config(), dims={"N": 4})
