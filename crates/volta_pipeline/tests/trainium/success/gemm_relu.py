import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a_t, b, out):
    assert a_t.shape == (8, 4)
    assert b.shape == (8, 4)
    assert out.shape == (4, 4)

    x = nl.ndarray((8, 4), dtype=a_t.dtype, buffer=nl.sbuf)
    y = nl.ndarray((8, 4), dtype=b.dtype, buffer=nl.sbuf)
    acc = nl.ndarray((4, 4), dtype=nl.float32, buffer=nl.psum)
    z = nl.ndarray((4, 4), dtype=nl.float32, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a_t)
    nisa.dma_copy(dst=y, src=b)

    # out = relu(a_t.T @ b): the activation reads the matmul's PSUM tile directly, fusing the
    # evacuation to SBUF with the relu instead of a separate tensor_copy.
    nisa.nc_matmul(dst=acc, stationary=x, moving=y)
    nisa.activation(dst=z, op=nl.relu, data=acc)

    nisa.dma_copy(dst=out, src=z)
