import nki
import nki.language as nl
import nki.isa as nisa


# A PSUM tile evicted whole though its last two columns were never written; only its
# written columns reach the output, the others coming from a zeroed tile.
@nki.jit
def kernel(a_t, b, out):
    x = nl.ndarray((4, 2), dtype=nl.float32, buffer=nl.sbuf)
    y = nl.ndarray((4, 2), dtype=nl.float32, buffer=nl.sbuf)
    acc = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.psum)
    z = nl.ndarray((2, 4), dtype=nl.float32, buffer=nl.sbuf)
    zeros = nl.ndarray((2, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a_t)
    nisa.dma_copy(dst=y, src=b)
    nisa.nc_matmul(dst=acc[:, 0:2], stationary=x, moving=y)
    nisa.tensor_copy(dst=z, src=acc)
    nisa.memset(dst=zeros, value=0.0)
    nisa.dma_copy(dst=out[:, 0:2], src=z[:, 0:2])
    nisa.dma_copy(dst=out[:, 2:4], src=zeros)
