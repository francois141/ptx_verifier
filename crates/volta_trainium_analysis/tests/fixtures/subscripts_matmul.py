import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(a_t, b, out):
    """out = a_t.T @ b, as matmul.py, staged as v3 and v4 stage their tiles: through HBM
    tensors indexed by chunk and a three-dimensional SBUF tile."""
    contraction, rows = a_t.shape
    cols = b.shape[1]
    chunk = contraction // 2

    # Chunk i of both operands, side by side, at staged[i].
    staged = nl.ndarray((2, chunk, rows + cols), dtype=nl.float32, buffer=nl.shared_hbm)
    for i in range(2):
        nisa.dma_copy(dst=staged[i, :, 0:rows], src=a_t[i * chunk:(i + 1) * chunk, :])
        nisa.dma_copy(dst=staged[i, :, rows:rows + cols], src=b[i * chunk:(i + 1) * chunk, :])

    sb = nl.ndarray((chunk, 2, rows + cols), dtype=nl.float32, buffer=nl.sbuf)
    acc = nl.zeros((rows, cols), dtype=nl.float32, buffer=nl.psum)
    for i in range(2):
        nisa.dma_copy(dst=sb[:, i, :], src=staged[i])
        nisa.nc_matmul(dst=acc, stationary=sb[:, i, 0:rows], moving=sb[:, i, rows:rows + cols])
    z = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=z, src=acc)

    # Out through a four-dimensional HBM tensor, as v3's qk.
    blocks = nl.ndarray((1, 1, rows, cols), dtype=nl.float32, buffer=nl.shared_hbm)
    nl.store(blocks[0, 0, :, :], z)
    w = nl.load(blocks[0, 0])
    nl.store(out, w)
