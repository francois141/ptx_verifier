import nki
import nki.language as nl
import nki.isa as nisa


# R8: affine_matmul_accumulate, but each iteration also copies the PSUM tile out right after
# its own matmul. The accumulations commute, but a read of a partial sum does not: the other
# iteration's matmul may land before or after it, a race under every ordering policy.
# Program order stores the first chunk's product, then the whole of a_t.T @ b.
@nki.jit
def kernel(a_t, b, out):
    assert a_t.shape == (4, 2)
    assert b.shape == (4, 3)
    assert out.shape == (4, 3)
    acc = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.psum)
    for i in nl.affine_range(2):
        x = nl.load(a_t[i * 2:(i + 1) * 2, :])
        y = nl.load(b[i * 2:(i + 1) * 2, :])
        nisa.nc_matmul(dst=acc, stationary=x, moving=y)
        partial = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
        nisa.tensor_copy(dst=partial, src=acc)
        nl.store(out[i * 2:(i + 1) * 2, :], partial)
