import nki
import nki.language as nl
import nki.isa as nisa


@nki.jit
def kernel(x):
    """softmax.py's softmax through integer and partial subscripts and a 3-D tile, as
    v3 keeps its intermediates in HBM one tile per index of a leading dimension."""
    rows, cols = x.shape
    kernel_out = nl.ndarray((rows, cols), dtype=x.dtype, buffer=nl.shared_hbm)
    data = nl.load(x)

    # Column 0 holds each row's max, column 1 its sum and then the sum's reciprocal,
    # each read and written with the free dimension indexed away.
    stats = nl.ndarray((rows, 2), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_reduce(dst=stats[:, 0], op=nl.maximum, data=data, axis=(1,))

    norm = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar(dst=norm, data=data, op0=nl.subtract, operand0=stats[:, 0])
    norm_row = nl.ndarray((1, rows, cols), dtype=nl.float32, buffer=nl.shared_hbm)
    nl.store(norm_row[0], norm)
    norm_buf = nl.load(norm_row[0])

    exp_vals = nl.ndarray((rows, 1, cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.activation(dst=exp_vals[:, 0, :], op=nl.exp, data=norm_buf)
    nisa.tensor_reduce(dst=stats[:, 1], op=nl.add, data=exp_vals[:, 0, :], axis=(1,))
    nisa.reciprocal(dst=stats[:, 1], data=stats[:, 1])

    result = nl.ndarray((rows, cols), dtype=nl.float32, buffer=nl.sbuf)
    nisa.tensor_scalar(dst=result, data=exp_vals[:, 0, :], op0=nl.multiply,
                       operand0=stats[:, 1])
    nl.store(kernel_out, result)
    return kernel_out
