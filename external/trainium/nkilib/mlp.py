"""nkilib's mlp on one core, unquantized and unnormalized; the hidden tensor's sequence
length picks its token generation or context encoding path."""

import importlib

mlp = importlib.import_module("nkilib.core.mlp.mlp").mlp


def kernel(hidden, gate_w, up_w, down_w):
    out = mlp(hidden, gate_w, up_w, down_w)[0]
    return out
