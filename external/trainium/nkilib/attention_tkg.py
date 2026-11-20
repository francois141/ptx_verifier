"""nkilib's attention_tkg on one core, without fused RoPE, which it supports only with
`q` and `k` in SBUF: the wrapper copies them there from `[d, B * H * s_active]` and
`[d, B * s_active]` HBM tensors."""

import importlib

import nki.isa as nisa
import nki.language as nl

attention_tkg = importlib.import_module(
    "nkilib.core.attention.attention_tkg"
).attention_tkg
AttnTKGConfig = importlib.import_module(
    "nkilib.core.attention.attention_tkg_utils"
).AttnTKGConfig
allocator = importlib.import_module("nkilib.core.utils.allocator")


def kernel(q, k_active, v_active, k_prior, v_prior, mask, out, heads=1):
    d, bhs = q.shape
    batch, _, s_prior, _ = v_prior.shape
    q_sb = nl.ndarray(q.shape, dtype=q.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=q_sb, src=q)
    k_sb = nl.ndarray(k_active.shape, dtype=k_active.dtype, buffer=nl.sbuf)
    nisa.dma_copy(dst=k_sb, src=k_active)
    cfg = AttnTKGConfig(
        bs=batch,
        q_head=heads,
        s_active=bhs // (batch * heads),
        curr_sprior=s_prior,
        full_sprior=s_prior,
        d_head=d,
        qk_in_sb=True,
    )
    sbm = allocator.create_auto_alloc_manager()
    sbm.open_scope()
    attention_tkg(q_sb, k_sb, v_active, k_prior, v_prior, mask, out, cfg, sbm)
    sbm.close_scope()
