"""nkilib's layernorm_tkg on one core, with beta."""

import importlib

layernorm_tkg = importlib.import_module(
    "nkilib.core.subkernels.layernorm_tkg"
).layernorm_tkg


def kernel(input, gamma, beta, output):
    layernorm_tkg(input, gamma, output, beta=beta)
