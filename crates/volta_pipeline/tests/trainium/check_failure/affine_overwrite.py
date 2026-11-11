import nki
import nki.language as nl
import nki.isa as nisa


# R1: each iteration of an affine_range overwrites one tile declared outside the loop, a
# write-after-write between iterations the loop promises do not depend on each other: a
# race. Program order leaves the last row; sequential_overwrite is its twin.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    for i in nl.affine_range(2):
        nisa.dma_copy(dst=x, src=a[i:i + 1, :])
    nisa.dma_copy(dst=out, src=x)
