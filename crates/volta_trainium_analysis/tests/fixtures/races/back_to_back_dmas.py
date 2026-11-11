import nki
import nki.language as nl
import nki.isa as nisa


# R0: two DMAs write one tile back to back, then a third reads it. The compiler sees the
# write-after-write on `x` and orders the DMAs, so this is meant to be race free; without
# that ordering every kernel reusing a tile would race.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[0:1, :])
    nisa.dma_copy(dst=x, src=a[1:2, :])
    nisa.dma_copy(dst=out, src=x)
