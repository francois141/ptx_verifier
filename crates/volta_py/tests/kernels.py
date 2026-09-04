"""PTX fixtures shared across test modules (not itself a test module)."""

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

# Two entries, each writing a distinct constant to out[tid] - lets tests
# tell which one actually ran. kernel_a is declared first in source order.
MULTI_ENTRY_KERNEL = HEADER + """
.visible .entry kernel_a(
    .param .u64 kernel_a_param_0
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;

    ld.param.u64 %rd1, [kernel_a_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, %tid.x;
    mul.wide.u32 %rd2, %r1, 4;
    add.s64 %rd3, %rd1, %rd2;
    mov.u32 %r2, 111;
    st.global.u32 [%rd3], %r2;
    ret;
}

.visible .entry kernel_b(
    .param .u64 kernel_b_param_0
)
{
    .reg .b32 %r<4>;
    .reg .b64 %rd<4>;

    ld.param.u64 %rd1, [kernel_b_param_0];
    cvta.to.global.u64 %rd1, %rd1;
    mov.u32 %r1, %tid.x;
    mul.wide.u32 %rd2, %r1, 4;
    add.s64 %rd3, %rd1, %rd2;
    mov.u32 %r2, 222;
    st.global.u32 [%rd3], %r2;
    ret;
}
"""


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


def single_output_config(threads: int = 2) -> "volta.Config":
    config = volta.Config(block=(threads, 1, 1))
    config.add_array(
        volta.ArrayDef("out", base=0x20000, elem_width=4, len=threads, kind=volta.ArrayKind.Output)
    )
    config.add_param(volta.Param.array_ptr("out"))
    return config
