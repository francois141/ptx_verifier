"""nkilib's mlp on one core, unquantized and unnormalized; the hidden tensor's sequence
length picks its token generation or context encoding path, unless `force_cte_mode` forces
the latter. Where it returns a view of its
output, the wrapper returns the tensor viewed."""

import importlib

mlp = importlib.import_module("nkilib.core.mlp.mlp").mlp


def viewed(output):
    return getattr(output, "tensor", output)


def kernel(hidden, gate_w, up_w, down_w, force_cte_mode=False):
    out = viewed(
        mlp(hidden, gate_w, up_w, down_w, force_cte_mode=force_cte_mode)[0]
    )
    return out
