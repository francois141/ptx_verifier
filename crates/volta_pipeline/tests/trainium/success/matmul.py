import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(a_t, b, out):
    assert a_t.shape == (4, 2)
    assert b.shape == (4, 3)
    assert out.shape == (2, 3)

    x = nl.ndarray((4, 2), dtype=a_t.dtype, buffer=nl.sbuf)
    y = nl.ndarray((4, 3), dtype=b.dtype, buffer=nl.sbuf)
    acc = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.psum)
    z = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)

    nisa.dma_copy(dst=x, src=a_t)
    nisa.dma_copy(dst=y, src=b)

    # nc_matmul computes stationary.T @ moving, contracting over the partition axis, so the
    # kernel receives A transposed: a_t is [K, M] = [4, 2], b is [K, N] = [4, 3], and
    # out = A @ b = a_t.T @ b is [M, N] = [2, 3]. No nki.isa matmul skips the transpose.
    nisa.nc_matmul(dst=acc, stationary=x, moving=y)

    nisa.tensor_copy(dst=z, src=acc)
    nisa.dma_copy(dst=out, src=z)
