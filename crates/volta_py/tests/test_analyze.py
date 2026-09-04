"""Tests for `volta.parse`/`volta.analyze`.

Run via `maturin develop && pytest` from `crates/volta_py/` (the module
must be built and installed into the active environment first - pytest
alone does not build the Rust extension).
"""

import pytest

import volta

HEADER = ".version 8.0\n.target sm_80\n.address_size 64\n\n"

# out[tid] = in[tid], 4 threads.
COPY_KERNEL = HEADER + """
.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<2>;
    .reg .b32 %r<3>;
    .reg .b64 %rd<6>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    mov.u32 %r1, %tid.x;
    mul.wide.u32 %rd3, %r1, 4;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4];
    add.s64 %rd5, %rd2, %rd3;
    st.global.f32 [%rd5], %f1;
    ret;
}
"""

# Two threads write the same shared address without synchronization.
RACE_KERNEL = HEADER + """
.visible .entry k()
{
    .reg .b32 %r<3>;
    .shared .align 4 .b8 sdata[8];

    mov.u32 %r1, %tid.x;
    mov.u32 %r2, sdata;
    st.shared.u32 [%r2], %r1;
    ret;
}
"""

# Thread 0 waits at bar.sync 1 while the rest wait at bar.sync 0: neither
# barrier ever gets its full participant set, so both stay blocked forever.
DEADLOCK_KERNEL = HEADER + """
.visible .entry k()
{
    .reg .pred %p<2>;
    .reg .b32 %r<2>;

    mov.u32 %r1, %tid.x;
    setp.eq.s32 %p1, %r1, 0;
    @%p1 bra $L1;
    bar.sync 0;
    bra $L2;
$L1:
    bar.sync 1;
$L2:
    ret;
}
"""

BAD_KERNEL = HEADER + ".visible .entry k( { ret; }"


def copy_config(threads: int = 4) -> "volta.Config":
    config = volta.Config(block=(threads, 1, 1))
    config.add_array(
        volta.ArrayDef("in", base=0x10000, elem_width=4, len=threads, kind=volta.ArrayKind.Input)
    )
    config.add_array(
        volta.ArrayDef("out", base=0x20000, elem_width=4, len=threads, kind=volta.ArrayKind.Output)
    )
    config.add_param(volta.Param.array_ptr("in"))
    config.add_param(volta.Param.array_ptr("out"))
    return config


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
