"""nkilib's output_projection_tkg on one core, unquantized."""

import importlib

output_projection_tkg = importlib.import_module(
    "nkilib.core.output_projection.output_projection_tkg"
).output_projection_tkg


def kernel(attention, weight):
    return output_projection_tkg(attention, weight)
