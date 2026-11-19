"""nkilib's foreach norm kernels, one per `norm` (an index into `NORMS`)."""

import importlib

module = importlib.import_module("nkilib.experimental.foreach.foreach_norm")

# 4 free elements, so with `pmax` 4 a tile holds 16 and small inputs cross tiles.
module._F_SIZE_F32 = 4

NORMS = ("l2", "l1", "linf")


def kernel(norm, data, numel):
    out = getattr(module, f"{NORMS[norm]}_norm_kernel")(data, numel)
    return out
