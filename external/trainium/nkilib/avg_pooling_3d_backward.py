"""nkilib's avg_pooling_3d_backward as released (ad2f1b9), NCDHW in and out."""

import importlib

module = importlib.import_module("nkilib.experimental.pooling.avg_pooling_3d_backward")


def kernel(grad_output, input_tensor, kernel_size, stride, padding):
    grad_input = module.avg_pooling_3d_backward(
        grad_output, input_tensor, kernel_size, stride, padding
    )
    return grad_input
