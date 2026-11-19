"""nkilib's rmsnorm_tkg on one core, with its layout and padding options."""

import importlib

rmsnorm_tkg = importlib.import_module("nkilib.core.subkernels.rmsnorm_tkg").rmsnorm_tkg


def kernel(input, gamma, output, hidden_dim_tp=False, hidden_actual=None):
    rmsnorm_tkg(
        input, gamma, output, hidden_actual=hidden_actual, hidden_dim_tp=hidden_dim_tp
    )
