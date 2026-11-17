import nki
import nki.language as nl
import nki.isa as nisa


# Two float32 tiles placed over the same bytes: a write through one is what a read
# through the other sees, as the hardware's memory is shared, so out is a.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    x = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf, address=(0, 0))
    y = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf, address=(0, 0))
    nisa.dma_copy(dst=x, src=a)
    nisa.dma_copy(dst=out, src=y)
