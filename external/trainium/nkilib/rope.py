"""nkilib's RoPE on one core, in its contiguous layout."""

import importlib

RoPE = importlib.import_module("nkilib.core.embeddings.rope").RoPE


def kernel(x_in, cos, sin):
    return RoPE(x_in, cos, sin)
