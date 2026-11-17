"""nkilib's max_pooling_3d as released (ad2f1b9), which has bug F7: see README.md."""

import importlib

kernel = importlib.import_module(
    "nkilib.experimental.pooling.max_pooling_3d"
).max_pooling_3d
