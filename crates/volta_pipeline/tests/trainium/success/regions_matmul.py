import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(a_t, b, out):
    """out = a_t.T @ b, as matmul.py, with its operands regions of wider tiles."""
    contraction, rows = a_t.shape
    cols = b.shape[1]
    chunk = contraction // 2

    # Both operands side by side in one SBUF tile.
    ab = nl.ndarray((contraction, rows + cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=ab[:, 0:rows], src=a_t)
    nisa.dma_copy(dst=ab[:, rows:rows + cols], src=b)

    # The product in columns 1 to cols of a wider PSUM tile, the contraction in two
    # chunks of partitions accumulated onto zeros.
    acc = nl.ndarray((rows, cols + 2), dtype=nl.float32, buffer=nl.psum)
    nisa.memset(dst=acc[:, 1:cols + 1], value=0)
    for i in range(2):
        nisa.nc_matmul(dst=acc[:, 1:cols + 1],
                       stationary=ab[i * chunk:(i + 1) * chunk, 0:rows],
                       moving=ab[i * chunk:(i + 1) * chunk, rows:rows + cols])
    z = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=z, src=acc[:, 1:cols + 1])

    # Transposed and back, through regions of wider tiles.
    z_t = nl.ndarray((cols, rows + 1), dtype=nl.float32, buffer=nl.psum)
    nisa.nc_transpose(dst=z_t[:, 1:rows + 1], data=z)
    w = nl.ndarray((cols, rows + 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_copy(dst=w[:, 1:rows + 1], src=z_t[:, 1:rows + 1])
    back = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.psum)
    nisa.nc_transpose(dst=back, data=w[:, 1:rows + 1])
    nisa.tensor_copy(dst=z, src=back)
    nisa.dma_copy(dst=out, src=z)
