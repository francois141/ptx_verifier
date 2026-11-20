import nki
import nki.language as nl
import nki.isa as nisa


# nkilib attention_cte's causal mask: an iota giving each partition its own index, and a
# range_select keeping `a` where its column lies in [0, partition], else -3, with its row
# maxima; an iota over two free dimensions (1 + 10p + 3i + j); and a range_select from
# column 1 whose upper bound is a symbolic tile.
@nki.jit
def kernel(a, bound, out, row_max, idx, banded):
    assert a.shape == (4, 4)
    assert bound.shape == (4, 1)
    assert out.shape == (4, 4)
    assert row_max.shape == (4, 1)
    assert idx.shape == (4, 6)
    assert banded.shape == (4, 4)
    x = nl.ndarray((4, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    zero = nl.ndarray((4, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.memset(dst=zero, value=0.0)
    upper = nl.ndarray((4, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.iota(dst=upper, pattern=[[1, 1]], channel_multiplier=1)

    y = nl.ndarray((4, 4), dtype=a.dtype, buffer=nl.sbuf)
    r = nl.ndarray((4, 1), dtype=a.dtype, buffer=nl.sbuf)
    nisa.range_select(
        dst=y,
        on_true_tile=x,
        comp_op0=nl.greater_equal,
        comp_op1=nl.less_equal,
        bound0=zero,
        bound1=upper,
        reduce_op=nl.maximum,
        reduce_res=r,
        reduce_cmd=nisa.reduce_cmd.reset_reduce,
        range_start=0,
        on_false_value=-3.0,
    )
    nisa.dma_copy(dst=out, src=y)
    nisa.dma_copy(dst=row_max, src=r)

    i = nl.ndarray((4, 6), dtype=nl.float32, buffer=nl.sbuf)
    nisa.iota(dst=i, pattern=[[3, 2], [1, 3]], offset=1, channel_multiplier=10)
    nisa.dma_copy(dst=idx, src=i)

    b = nl.ndarray((4, 1), dtype=bound.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=b, src=bound)
    w = nl.ndarray((4, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.range_select(
        dst=w,
        on_true_tile=x,
        comp_op0=nl.greater,
        comp_op1=nl.less,
        bound0=zero,
        bound1=b,
        range_start=1,
        on_false_value=0.0,
    )
    nisa.dma_copy(dst=banded, src=w)
