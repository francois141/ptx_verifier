import nki
import nki.language as nl
import nki.isa as nisa


# Columns `idx[0]`, `idx[1]` and `idx[2]` of each of `a`'s 32 rows, gathered through an
# index tile holding `idx` in each of its two 16-partition groups.
@nki.jit
def kernel(a, idx):
    out = nl.ndarray((32, 3), dtype=a.dtype, buffer=nl.shared_hbm)
    t = nl.load(a)
    offsets = nl.ndarray((32, 1), dtype=nl.uint16, buffer=nl.sbuf)
    for g in nl.static_range(2):
        nisa.dma_copy(dst=offsets[16 * g:16 * (g + 1), :], src=idx)
    gathered = nl.ndarray((32, 3), dtype=a.dtype, buffer=nl.sbuf)
    nisa.tensor_copy(gathered, t.indirect(offsets, num_elem=3), engine=nisa.engine.scalar)
    nl.store(out, value=gathered)
    return out
