import nki
import nki.language as nl
import nki.isa as nisa

@nki.jit
def kernel(x):
    # Softmax along each partition as attn_fwd_v8 computes it, over two chunks of
    # columns: tensor_scalar_reduce for the chunk maxima, tensor_reduce with negate,
    # and activation with a bias and a reset_reduce sum.
    rows, cols = x.shape
    chunk = cols // 2
    kernel_out = nl.ndarray((rows, cols), dtype=x.dtype, buffer=nl.shared_hbm)
    data = nl.ndarray(x.shape, dtype=x.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=data, src=x)

    copy = nl.ndarray((rows, 2, chunk), dtype=nl.float32, buffer=nl.sbuf)
    chunk_max = nl.ndarray((rows, 2), dtype=nl.float32, buffer=nl.sbuf)
    for i in range(2):
        nisa.tensor_scalar_reduce(dst=copy[:, i, :], data=data[:, i*chunk:i*chunk+chunk],
                                  op0=nl.multiply, operand0=1.0,
                                  reduce_op=nl.maximum, reduce_res=chunk_max[:, i:i+1])
    neg_max = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=neg_max, op=nl.maximum, data=chunk_max, axis=(1,), negate=True)

    exp_vals = nl.ndarray((rows, cols), dtype=nl.bfloat16, buffer=nl.sbuf)
    chunk_sum = nl.ndarray((rows, 2), dtype=nl.float32, buffer=nl.sbuf)
    for i in range(2):
        nisa.activation(dst=exp_vals[:, i*chunk:i*chunk+chunk], op=nl.exp,
                        data=copy[:, i, :], bias=neg_max,
                        reduce_op=nl.add, reduce_res=chunk_sum[:, i:i+1],
                        reduce_cmd=nisa.reduce_cmd.reset_reduce)
    row_sum = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=row_sum, op=nl.add, data=chunk_sum, axis=(1,))

    inv_sum = nl.ndarray((rows, 1), dtype=nl.float32, buffer=nl.sbuf)
    nisa.reciprocal(dst=inv_sum, data=row_sum)
    result = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar(dst=result, data=exp_vals, op0=nl.multiply, operand0=inv_sum)

    nisa.dma_copy(dst=kernel_out, src=result)
    return kernel_out
