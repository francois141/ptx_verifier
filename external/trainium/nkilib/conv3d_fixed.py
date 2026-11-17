"""nkilib's conv3d as released (ad2f1b9), with the proposed fix of F9: see README.md."""

import importlib

import fixes

import nki.language as nl

# The docs name nl.tile_size.sbuf_min_align without a value; 32 bytes is assumed.
nl.tile_size.assumed["sbuf_min_align"] = 32

fixes.apply("nkilib.experimental.conv.conv3d_helpers")

kernel = importlib.import_module("nkilib.experimental.conv.conv3d").conv3d
