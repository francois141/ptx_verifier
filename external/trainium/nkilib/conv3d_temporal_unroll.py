"""nkilib's conv3d_temporal_unroll as released (ad2f1b9), which has bug F12: see README.md."""

import importlib

import nki.language as nl

# The docs name nl.tile_size.sbuf_min_align without a value; 32 bytes is assumed.
nl.tile_size.assumed["sbuf_min_align"] = 32

kernel = importlib.import_module(
    "nkilib.experimental.conv.conv3d_temporal_unroll"
).conv3d_temporal_unroll
