import nki
import nki.language as nl
import nki.isa as nisa


# nc_stream_shuffle as nkilib uses it: `y` is `a`'s first row broadcast by an all-zero mask;
# `z` takes rows of `a` by a permuting mask whose 255s leave rows 1 and 3 unwritten, so
# `out` takes rows 0 and 2 from `z` and rows 1 and 3 from `y`.
@nki.jit
def kernel(a, out):
    x = nl.ndarray((3, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    y = nl.ndarray((4, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.nc_stream_shuffle(src=x[0:1, :], dst=y, shuffle_mask=[0] * 32)
    z = nl.ndarray((4, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.nc_stream_shuffle(src=x, dst=z, shuffle_mask=[2, 255, 1, 255] + [255] * 28)
    for row in (0, 2):
        nisa.dma_copy(dst=out[row : row + 1, :], src=z[row : row + 1, :])
    for row in (1, 3):
        nisa.dma_copy(dst=out[row : row + 1, :], src=y[row : row + 1, :])
