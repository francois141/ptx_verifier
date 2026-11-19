"""nkilib's linear_scan, its free tile size (2048) given by the call, returning `result` or
`final_state`."""

import importlib

module = importlib.import_module("nkilib.experimental.scan.linear_scan")


def kernel(decay, data, initial, f_tile_size=module.F_TILE_SIZE, final=False):
    module.F_TILE_SIZE = f_tile_size
    result, final_state = module.linear_scan(decay, data, initial)
    if final:
        return final_state
    return result
