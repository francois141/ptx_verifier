import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (2, 4)

    x = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    y = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a)

    nisa.activation(dst=y, op=nl.sigmoid, data=x)

    nisa.dma_copy(dst=out, src=y)
