import nki
import nki.language as nl
import nki.isa as nisa


# affine_carried with a sequential_range: each iteration reads what the one before it
# wrote, in order, so this is meant to be race free.
@nki.jit
def kernel(a, out):
    assert a.shape == (3, 4)
    assert out.shape == (2, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[0:1, :])
    for i in nl.sequential_range(2):
        nisa.dma_copy(dst=out[i:i + 1, :], src=x)
        nisa.dma_copy(dst=x, src=a[i + 1:i + 2, :])
