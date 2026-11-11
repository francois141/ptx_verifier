import nki
import nki.language as nl
import nki.isa as nisa


# R1: each iteration of an affine_range stores the tile the previous one loaded, a
# read-after-write (and write-after-read) carried between iterations the loop promises
# independent, so this is meant to race. sequential_carried is its ordered twin.
@nki.jit
def kernel(a, out):
    assert a.shape == (3, 4)
    assert out.shape == (2, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[0:1, :])
    for i in nl.affine_range(2):
        nisa.dma_copy(dst=out[i:i + 1, :], src=x)
        nisa.dma_copy(dst=x, src=a[i + 1:i + 2, :])
