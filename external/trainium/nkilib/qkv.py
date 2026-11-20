"""nkilib's qkv on one core, unfused; the input's sequence length picks its token
generation or context encoding path. Where it returns a view of its output, the wrapper
returns the tensor viewed."""

import importlib

qkv = importlib.import_module("nkilib.core.qkv.qkv").qkv


def kernel(input, fused_qkv_weights, d_head=128, num_q_heads=2, num_kv_heads=1):
    output = qkv(
        input,
        fused_qkv_weights,
        d_head=d_head,
        num_q_heads=num_q_heads,
        num_kv_heads=num_kv_heads,
    )
    out = getattr(output, "tensor", output)
    return out
