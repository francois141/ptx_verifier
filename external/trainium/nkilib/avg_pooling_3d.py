"""nkilib's avg_pooling_3d as released (ad2f1b9), NCDHW in and out."""

import importlib

kernel = importlib.import_module(
    "nkilib.experimental.pooling.avg_pooling_3d"
).avg_pooling_3d
