import nki
import nki.language as nl
import nki.isa as nisa


# The operations nkilib's foreach norms use: activations abs and sqrt, a tensor_reduce
# with keepdims=True under nl.max (an alias of nl.maximum), and a tensor_partition_reduce
# folding a [P, 1] column into one element.
@nki.jit
def kernel(a, out):
    assert a.shape == (2, 4)
    x = nl.ndarray((2, 4), dtype=a.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=x, src=a)
    nisa.activation(dst=x, op=nl.abs, data=x)
    m = nl.ndarray((2, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=m, op=nl.max, data=x, axis=1, keepdims=True)
    total = nl.ndarray((1, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_partition_reduce(dst=total, op=nl.add, data=m)
    root = nl.ndarray((1, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.activation(dst=root, op=nl.sqrt, data=total)
    nisa.dma_copy(dst=out, src=root)
