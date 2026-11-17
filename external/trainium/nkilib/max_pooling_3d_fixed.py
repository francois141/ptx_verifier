"""nkilib's max_pooling_3d as released (ad2f1b9), with the proposed fix of F7: see README.md."""

import importlib

import fixes

fixes.apply("nkilib.experimental.pooling.max_pooling_3d")

kernel = importlib.import_module(
    "nkilib.experimental.pooling.max_pooling_3d"
).max_pooling_3d
