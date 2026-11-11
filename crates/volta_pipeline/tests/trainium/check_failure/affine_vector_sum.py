import nki
import nki.language as nl
import nki.isa as nisa


# R1 and D3: an affine_range sums rows into one SBUF tile with a vector-engine add, as
# mamba accumulates scanC_accum. Its iterations are unordered, so it races unless NKI's
# reduction exemption covers an associative tensor_tensor (a race under DataFlowOnly).
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    assert out.shape == (1, 4)
    acc = nl.zeros((1, 4), dtype=nl.float32, buffer=nl.sbuf)
    for i in nl.affine_range(2):
        row = nl.ndarray((1, 4), dtype=a.dtype, buffer=nl.sbuf)
        nisa.dma_copy(dst=row, src=a[i:i + 1, :])
        nisa.tensor_tensor(dst=acc, data1=acc, data2=row, op=nl.add)
    nisa.dma_copy(dst=out, src=acc)
