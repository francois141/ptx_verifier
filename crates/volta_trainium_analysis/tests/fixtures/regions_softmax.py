import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(x):
    """softmax.py's softmax with its operands regions of wider tiles, one column at a
    time where v3 and v4 work one tile at a time."""
    rows, cols = x.shape
    kernel_out = nl.ndarray((rows, cols), dtype=x.dtype, buffer=nl.shared_hbm)
    # The input in columns 1 to cols of a wider tile; columns 0 and cols + 1 stay unused.
    scratch = nl.ndarray((rows, cols + 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.dma_copy(dst=scratch[:, 1:cols + 1], src=x)

    # v3's two-level max: each column's, then the max of those.
    col_max = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    for j in range(cols):
        nisa.tensor_reduce(dst=col_max[:, j:j + 1], op=nl.maximum,
                           data=scratch[:, j + 1:j + 2], axis=(1,))
    # Column 0 holds each row's max, column 1 its sum and then the sum's reciprocal.
    stats = nl.ndarray((rows, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=stats[:, 0:1], op=nl.maximum, data=col_max[:, :], axis=(1,))

    norm = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    for j in range(cols):
        nisa.tensor_tensor(dst=norm[:, j:j + 1], data1=scratch[:, j + 1:j + 2],
                           data2=stats[:, 0:1], op=nl.subtract)
    nisa.activation_reduce(dst=norm[:, :], op=nl.exp, data=norm,
                           reduce_op=nl.add, reduce_res=stats[:, 1:2])
    nisa.reciprocal(dst=stats[:, 1:2], data=stats[:, 1:2])

    nisa.tensor_scalar(dst=scratch[:, 1:cols + 1], data=norm,
                       op0=nl.multiply, operand0=stats[:, 1:2])
    nisa.dma_copy(dst=kernel_out, src=scratch[:, 1:cols + 1])
    return kernel_out
