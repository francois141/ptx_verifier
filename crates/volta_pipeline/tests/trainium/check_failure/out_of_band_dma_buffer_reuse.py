import nki
import nki.language as nl
import nki.isa as nisa


# One tile is reused for each row: a dge_mode.none DMA loads a row into it and another stores
# it out, then the next row's load overwrites it, as nkilib's _rmsnorm_tkg_dloc does per
# 128-token tile. Nothing orders the store still reading the tile before the next load
# (AWS's gpsimd_topk audit): a race unless the policy orders out-of-band DMAs.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (2, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a[0:1, :], dge_mode=nisa.dge_mode.none)
    nisa.dma_copy(dst=out[0:1, :], src=x, dge_mode=nisa.dge_mode.none)
    nisa.dma_copy(dst=x, src=a[1:2, :], dge_mode=nisa.dge_mode.none)
    nisa.dma_copy(dst=out[1:2, :], src=x, dge_mode=nisa.dge_mode.none)
