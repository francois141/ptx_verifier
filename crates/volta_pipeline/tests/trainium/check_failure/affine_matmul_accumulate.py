import nki
import nki.language as nl
import nki.isa as nisa


# R1 and D3: an affine_range accumulates matmuls into one PSUM tile, the reduction the NKI
# docs name as allowed across affine_range iterations. A race under any ordering policy,
# accumulation being ordinary reads and writes. out = a_t.T @ b in two contraction chunks.
@nki.jit
def kernel(a_t, b, out):
    contraction, rows = a_t.shape
    chunk = contraction // 2
    acc = nl.zeros((rows, b.shape[1]), dtype=nl.float32, buffer=nl.psum)
    for i in nl.affine_range(2):
        x = nl.load(a_t[i * chunk:(i + 1) * chunk, :])
        y = nl.load(b[i * chunk:(i + 1) * chunk, :])
        nisa.nc_matmul(dst=acc, stationary=x, moving=y)
    result = nl.ndarray(acc.shape, dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=result, src=acc)
    nl.store(out, result)
