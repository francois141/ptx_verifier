import nki
import nki.language as nl
import nki.isa as nisa


# What nkilib's mlp adds: a dma_transpose with the default axes swapping the ends of a
# [3, 2, 4] view of `a` around its middle dimension (t[c, m, r] = a[r, 4m + c]), nl.silu
# over the 3-D tile, and an nc_transpose into a tile with an extent-1 free dimension.
@nki.jit
def kernel(a, out, a_t):
    assert a.shape == (3, 8)
    assert out.shape == (4, 2, 3)
    assert a_t.shape == (4, 1, 3)
    t = nl.ndarray((4, 2, 3), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_transpose(dst=t, src=a.ap([[8, 3], [4, 2], [1, 4]], offset=0))
    s = nl.ndarray((4, 2, 3), dtype=a.dtype, buffer=nl.sbuf)
    nisa.activation(dst=s, op=nl.silu, data=t)
    nisa.dma_copy(dst=out, src=s)

    x = nl.ndarray((3, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[:, 0:4])
    p = nl.ndarray((4, 1, 3), dtype=nl.float32, buffer=nl.psum)
    nisa.nc_transpose(dst=p, data=x)
    y = nl.ndarray((4, 1, 3), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(dst=y, src=p)
    nisa.dma_copy(dst=a_t, src=y)
