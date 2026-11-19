"""nkilib's foreach elementwise kernels, one per `op` (an index into `OPS`).

Each tensor parameter is the one of that name the chosen kernel takes; the others stay `None`.
"""

import importlib

module = importlib.import_module("nkilib.experimental.foreach.foreach_elementwise")

# 4 free elements, so with `pmax` 4 a tile holds 16 and small inputs cross tiles.
module._F_SIZE_F32 = 4

OPS = (
    "add_scalar",
    "add_tensor",
    "sub_tensor",
    "mul_tensor",
    "div_tensor",
    "addcdiv",
    "addcmul",
    "lerp",
)


def kernel(
    op,
    numel,
    data=None,
    data1=None,
    data2=None,
    end=None,
    scalar_tensor=None,
    alpha_tensor=None,
    value_tensor=None,
    weight_tensor=None,
):
    given = {
        "data": data,
        "data1": data1,
        "data2": data2,
        "end": end,
        "scalar_tensor": scalar_tensor,
        "alpha_tensor": alpha_tensor,
        "value_tensor": value_tensor,
        "weight_tensor": weight_tensor,
    }
    tensors = {name: tensor for name, tensor in given.items() if tensor is not None}
    out_hbm = getattr(module, f"{OPS[op]}_kernel")(**tensors, numel=numel)
    return out_hbm
