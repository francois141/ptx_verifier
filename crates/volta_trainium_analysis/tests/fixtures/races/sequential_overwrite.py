import nki
import nki.language as nl
import nki.isa as nisa


# affine_overwrite with a sequential_range: its iterations run in order, so this is meant
# to be race free.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    for i in nl.sequential_range(2):
        nisa.dma_copy(dst=x, src=a[i:i + 1, :])
    nisa.dma_copy(dst=out, src=x)
