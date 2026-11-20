"""nkilib's rope_hf on one core, from `cos` and `sin` tables."""

import importlib

rope_hf = importlib.import_module("nkilib.core.embeddings.rope_hf").rope_hf


def kernel(q, k, q_out, k_out, cos, sin):
    rope_hf(q, k, q_out, k_out, cos=cos, sin=sin)
