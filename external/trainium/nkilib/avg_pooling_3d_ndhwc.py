"""nkilib's avg_pooling_3d as released (ad2f1b9), NDHWC in and out."""

import importlib

module = importlib.import_module("nkilib.experimental.pooling.avg_pooling_3d")


def kernel(src_tensor, kernel_size, stride, padding):
    out = module.avg_pooling_3d(
        src_tensor, kernel_size, stride, padding, data_format="NDHWC"
    )
    return out
