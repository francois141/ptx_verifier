import nki
import nki.language as nl
import nki.isa as nisa


# matmul.py's product with the operands nkilib passes that do not change it: DMAs with
# dge_mode=hwdge on the sync engine's queue, and a matmul placed with tile_position and
# tile_size.
@nki.jit
def kernel(a_t, b, out):
    assert a_t.shape == (4, 2)
    assert b.shape == (4, 3)
    assert out.shape == (2, 3)
    x = nl.ndarray((4, 2), dtype=a_t.dtype, buffer=nl.sbuf)
    y = nl.ndarray((4, 3), dtype=b.dtype, buffer=nl.sbuf)
    acc = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.psum)
    z = nl.ndarray((2, 3), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a_t, dge_mode=nisa.dge_mode.hwdge, engine=nisa.engine.sync)
    nisa.dma_copy(dst=y, src=b, dge_mode=nisa.dge_mode.hwdge)
    nisa.nc_matmul(dst=acc, stationary=x, moving=y, tile_position=(0, 0), tile_size=(4, 2))
    nisa.tensor_copy(dst=z, src=acc)
    nisa.dma_copy(dst=out, src=z, engine=nisa.engine.sync)
