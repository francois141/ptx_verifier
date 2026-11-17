import nki
import nki.language as nl
import nki.isa as nisa


# The Tensor Engine's transpose mode with a moving operand that is not the identity.
@nki.jit
def moving_not_identity(a, out):
    x = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    ones = nl.ndarray((2, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.memset(dst=ones, value=1.0)
    acc = nl.ndarray((3, 2), dtype=nl.float32, buffer=nl.psum)
    nisa.nc_matmul(dst=acc, stationary=x, moving=ones, is_transpose=True)
    t = nl.ndarray((3, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=t, src=acc)
    nisa.dma_copy(dst=out, src=t)
