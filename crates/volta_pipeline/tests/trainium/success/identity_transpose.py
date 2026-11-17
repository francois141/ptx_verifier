import nki
import nki.language as nl
import nki.isa as nisa


# `a` transposed by a matmul against `nl.shared_identity_matrix`, as nkilib's kernels
# transpose through the Tensor Engine.
@nki.jit
def kernel(a, out):
    x = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    ident = nl.shared_identity_matrix(2, dtype=nl.float32)
    acc = nl.ndarray((3, 2), dtype=nl.float32, buffer=nl.psum)
    nisa.nc_matmul(dst=acc, stationary=x, moving=ident)
    t = nl.ndarray((3, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=t, src=acc)
    nisa.dma_copy(dst=out, src=t)
