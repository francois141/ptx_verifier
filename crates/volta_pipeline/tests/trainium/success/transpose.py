import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a, out):
    assert a.shape == (2, 3)
    assert out.shape == (3, 2)

    x = nl.ndarray((2, 3), dtype=a.dtype, buffer=nl.sbuf)
    t = nl.ndarray((3, 2), dtype=a.dtype, buffer=nl.psum)
    y = nl.ndarray((3, 2), dtype=a.dtype, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a)

    nisa.nc_transpose(dst=t, data=x)

    nisa.tensor_copy(dst=y, src=t)
    nisa.dma_copy(dst=out, src=y)
