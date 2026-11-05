import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(x):
    # attention_kernel_utils.softmax_isa's body, inline: softmax along each partition.
    rows, cols = x.shape
    kernel_out = nl.ndarray((rows, cols), dtype=x.dtype, buffer=nl.shared_hbm)
    data = nl.ndarray(x.shape, dtype=x.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=data, src=x)

    row_max = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=row_max, data=data, op=nl.maximum, axis=(1,))

    norm = nl.ndarray(data.shape, dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar(dst=norm, data=data, op0=nl.subtract, operand0=row_max)

    exp_vals = nl.ndarray(data.shape, dtype=nl.float32, buffer=nl.sbuf)
    nisa.activation(dst=exp_vals, op=nl.exp, data=norm)

    row_sum = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=row_sum, data=exp_vals, op=nl.add, axis=(1,))

    inv_sum = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.reciprocal(dst=inv_sum, data=row_sum)

    result = nl.ndarray(data.shape, dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar(dst=result, data=exp_vals, op0=nl.multiply, operand0=inv_sum)

    nisa.dma_copy(dst=kernel_out, src=result)
    return kernel_out
