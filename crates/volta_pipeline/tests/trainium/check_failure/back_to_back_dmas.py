import nki
import nki.language as nl
import nki.isa as nisa


# R0: two DMAs write one tile back to back, then a third reads it. Ordered only if the
# compiler orders write-after-write, which the docs do not state: a race under
# DataFlowOnly, where only the second DMA is the read's data-flow source.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[0:1, :])
    nisa.dma_copy(dst=x, src=a[1:2, :])
    nisa.dma_copy(dst=out, src=x)
