"""nkilib's conv3d_bwd_dx as released (ad2f1b9), which has bug F11: see README.md."""

import importlib

import nki.language as nl

# The docs name nl.tile_size.sbuf_min_align without a value; 32 bytes is assumed.
nl.tile_size.assumed["sbuf_min_align"] = 32

conv3d_bwd = importlib.import_module("nkilib.experimental.conv.conv3d_bwd").conv3d_bwd


def kernel(dy, x_in, filters, stride, padding, dilation):
    dx = conv3d_bwd(
        dy,
        x_in,
        filters,
        stride=stride,
        padding=padding,
        dilation=dilation,
        compute_dx=True,
        compute_dw=False,
        compute_db=False,
    )
    return dx
