"""nkilib's batch_norm_bwd without ReLU or residual, eps 1e-5, returning its output number
`output` (dx, dgamma, dbeta)."""

import importlib

import nki.language as nl

# The docs name nl.tile_size.sbuf_min_align without a value; 32 bytes is assumed.
nl.tile_size.assumed["sbuf_min_align"] = 32

module = importlib.import_module("nkilib.experimental.batch_norm.batch_norm_bwd")


def kernel(dy, x_in, means, variances, gamma, beta, output):
    dx, dgamma, dbeta = module.batch_norm_bwd(
        dy, x_in, means, variances, gamma, beta, eps=1e-5
    )
    return (dx, dgamma, dbeta)[output]
