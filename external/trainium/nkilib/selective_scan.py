"""nkilib's selective_scan without the D skip, its free tile size (512) given by the call,
returning `y` or `final_state`."""

import importlib

module = importlib.import_module("nkilib.experimental.scan.selective_scan")


def kernel(x, dt, A, B, C, initial_state, f_tile_size=module.F_TILE_SIZE, final=False):
    module.F_TILE_SIZE = f_tile_size
    y, final_state = module.selective_scan(x, dt, A, B, C, initial_state=initial_state)
    if final:
        return final_state
    return y
