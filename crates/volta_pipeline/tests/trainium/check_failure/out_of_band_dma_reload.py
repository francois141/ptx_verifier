import nki
import nki.language as nl
import nki.isa as nisa


# A DMA whose descriptors are generated out of band (dge_mode.none) loads a row into a tile,
# and two more copy the tile out, as vllm-neuron's _permute_one_token_nki does. AWS's
# gpsimd_topk audit found nothing orders such a DMA against another touching the same memory:
# a race unless the policy orders out-of-band DMAs.
@nki.jit
def kernel(a, out):
    assert a.shape == (1, 4)
    assert out.shape == (2, 4)
    x = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a, dge_mode=nisa.dge_mode.none)
    nisa.dma_copy(dst=out[0:1, :], src=x, dge_mode=nisa.dge_mode.none)
    nisa.dma_copy(dst=out[1:2, :], src=x, dge_mode=nisa.dge_mode.none)
