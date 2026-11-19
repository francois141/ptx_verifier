"""nkilib's fused_adam without AMSGrad: `adamw_kernel` if `adamw`, else `adam_kernel`, with
beta1 0.9, beta2 0.999 and eps 1e-8, over float32 free tiles of `f_size` elements, returning
its output number `output` (weights, first_moment, second_moment)."""

import importlib

module = importlib.import_module("nkilib.experimental.optimizer.fused_adam")


def kernel(p, g, m, v, step_size, inv_bc2_sqrt, wd_factor, adamw, output, f_size=2048):
    module._F_SIZE_F32 = f_size
    numel = 1
    for extent in p.shape:
        numel *= extent
    step = module.adamw_kernel if adamw else module.adam_kernel
    weights, first_moment, second_moment = step(
        p, g, m, v, None, step_size, inv_bc2_sqrt, wd_factor, numel, 0.9, 0.999, 1e-8
    )
    return (weights, first_moment, second_moment)[output]
