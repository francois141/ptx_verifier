"""nkilib's cumsum, its tile sizes (128 rows, 2048 columns) given by the call."""

import importlib

module = importlib.import_module("nkilib.core.cumsum.cumsum")


def kernel(x, p_max=module.P_MAX, f_tile_size=module.F_TILE_SIZE):
    module.P_MAX = p_max
    module.F_TILE_SIZE = f_tile_size
    y = module.cumsum(x)
    return y
