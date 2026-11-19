"""nkilib's depthwise_conv1d_implicit_gemm as released (ad2f1b9), found correct: see README.md."""

import importlib

depthwise = importlib.import_module(
    "nkilib.experimental.conv.depthwise_conv1d"
).depthwise_conv1d_implicit_gemm


def kernel(img_ref, filter_ref, padding, stride):
    """`padding` is `(W_pad_l, W_pad_r)` and `stride` the W stride: the call's nested tuples."""
    output = depthwise(
        img_ref,
        filter_ref,
        padding=((0, 0), tuple(padding)),
        stride=(1, stride),
        feature_group_count=img_ref.shape[1],
    )
    return output
