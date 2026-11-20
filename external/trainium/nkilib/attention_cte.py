"""nkilib's attention_cte on one core, causal, without a prior KV cache."""

import importlib

attention_cte = importlib.import_module(
    "nkilib.core.attention.attention_cte"
).attention_cte


def kernel(q, k, v):
    return attention_cte(q, k, v)
