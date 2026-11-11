import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(a_t, b, out):
    """out = a_t.T @ b, its contraction in two chunks of rows accumulated in PSUM."""
    contraction, rows = a_t.shape
    chunk = contraction // 2
    acc = nl.zeros((rows, b.shape[1]), dtype=nl.float32, buffer=nl.psum)
    for i in range(2):
        x = nl.load(a_t[i * chunk:(i + 1) * chunk, :])
        y = nl.load(b[i * chunk:(i + 1) * chunk, :])
        nisa.nc_matmul(dst=acc, stationary=x, moving=y)

    # A list of tiles, as v4 allocates its PSUM tiles.
    copies = []
    for _ in range(2):
        copies.append(nl.ndarray(acc.shape, dtype=nl.float32, buffer=nl.sbuf))
    nisa.tensor_copy(dst=copies[0], src=acc)
    nisa.tensor_copy(dst=copies[1], src=copies[0])
    nl.store(out, copies[1])
