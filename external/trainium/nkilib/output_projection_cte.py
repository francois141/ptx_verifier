"""nkilib's output_projection_cte on one core, unquantized."""

import importlib

output_projection_cte = importlib.import_module(
    "nkilib.core.output_projection.output_projection_cte.output_projection_cte"
).output_projection_cte


def kernel(attention, weight):
    return output_projection_cte(attention, weight)
