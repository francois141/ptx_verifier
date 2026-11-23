"""Compile cases for extend_attention, prefill_attention and lean_atten_paged: the args and
config each public wrapper passes on gfx950 for a small checkable shape."""
from case_types import T

CASES = {}
NUM_XCDS = 8  # get_num_xcds() default when chip_info is absent; 8 on gfx950


def pow2(x):
    return 1 << (x - 1).bit_length()


# configs/gfx950/triton/attention/extend_attention/DEFAULT.json
EXTEND_DEFAULT = dict(BLOCK_M=128, BLOCK_N=64, waves_per_eu=2, num_warps=4, num_ctas=1,
                      num_stages=1, matrix_instr_nonkdim=16)
EXTEND_LARGE = dict(BLOCK_M=32, BLOCK_N=32, waves_per_eu=2, num_warps=4, num_ctas=1,
                    num_stages=1, matrix_instr_nonkdim=16)


def split_config(config):
    cfg = dict(config)
    options = {k: cfg.pop(k) for k in ("num_warps", "num_stages", "waves_per_eu", "num_ctas",
                                        "matrix_instr_nonkdim") if k in cfg}
    return cfg, options


def extend(name, *, dtype="bf16", hq=1, hk=1, lq=64, lv=64, max_extend=100, causal=True,
           logit_cap=0.0, custom_mask=False, kv_index_dtype="i32", note=""):
    """attention/extend_attention.py::extend_attention_fwd's launch of _fwd_kernel, contiguous
    q/k/v/o [tokens, heads, dim] and k/v buffers [slots, kv_heads, dim]."""
    if lq == 576:
        dmodel, dpe = 512, 64
    elif lq == 288:
        dmodel, dpe = 256, 32
    elif lq == 192:
        dmodel, dpe = 128, 64
    else:
        dmodel, dpe = pow2(lq), 0
    config = EXTEND_LARGE if (lq > 192 or dtype == "fp32") else EXTEND_DEFAULT
    cfg, options = split_config(config)
    num_blocks = -(-max_extend // cfg["BLOCK_M"])
    args = dict(
        Q_Extend=T(dtype), K_Extend=T(dtype), V_Extend=T(dtype), O_Extend=T(dtype),
        K_Buffer=T(dtype), V_Buffer=T(dtype), qo_indptr=T("i32"), kv_indptr=T("i32"),
        kv_indices=T(kv_index_dtype), mask_ptr=T("i1") if custom_mask else None,
        mask_indptr=T("i32") if custom_mask else None, sm_scale=lq ** -0.5,
        kv_group_num=hq // hk,
        stride_qbs=hq * lq, stride_qh=lq, stride_kbs=hk * lq, stride_kh=lq,
        stride_vbs=hk * lv, stride_vh=lv, stride_obs=hq * lv, stride_oh=lv,
        stride_buf_kbs=hk * lq, stride_buf_kh=lq, stride_buf_vbs=hk * lv, stride_buf_vh=lv)
    constexprs = dict(logit_cap=logit_cap, Lq=lq, Lv=lv, BLOCK_DMODEL=dmodel, BLOCK_DPE=dpe,
                      BLOCK_DV=pow2(lv), USE_CUSTOM_MASK=custom_mask, IS_CAUSAL=causal,
                      SKIP_PREFIX_CUSTOM_MASK=True, STORE_TRANSPOSE=True, NUM_Q_HEADS=hq,
                      NUM_BLOCKS=num_blocks, NUM_XCDS=NUM_XCDS, **cfg)
    CASES[name] = dict(module="aiter.ops.triton._triton_kernels.attention.extend_attention",
                       kernel="_fwd_kernel", args=args, constexprs=constexprs, options=options,
                       note=note)


extend("ea_extend_bf16_d64", note="extend_attention_fwd bf16, 1 head, head dim 64, causal, "
       "max extend 100 (one 128-row block), default gfx950 config")
extend("ea_extend_bf16_d80", lq=80, lv=80, note="head dim 80, padded to 128 (mask_d/mask_dv)")
extend("ea_extend_bf16_gqa", hq=4, hk=2, note="GQA 4 q heads / 2 kv heads")
extend("ea_extend_bf16_d192", lq=192, lv=128, hq=2, hk=1,
       note="MLA-style 128+64 split (BLOCK_DPE=64), v head 128")
extend("ea_extend_bf16_d64_cap", logit_cap=30.0, note="logit cap 30 (tanh via sigmoid)")


def prefill(name, *, dtype="bf16", hq=1, hk=1, d=64, causal=True, note=""):
    """attention/prefill_attention.py::context_attention_fwd: BLOCK 128, warps 4 (d <= 64) else 8."""
    args = dict(Q=T(dtype), K=T(dtype), V=T(dtype), sm_scale=d ** -0.5, B_Start_Loc=T("i32"),
                B_Seqlen=T("i32"), Out=T(dtype), stride_qbs=hq * d, stride_qh=d,
                stride_kbs=hk * d, stride_kh=d, stride_vbs=hk * d, stride_vh=d,
                stride_obs=hq * d, stride_oh=d)
    constexprs = dict(kv_group_num=hq // hk, BLOCK_M=128, BLOCK_DMODEL=pow2(d), BLOCK_N=128,
                      IS_CAUSAL=causal, Lk=d)
    CASES[name] = dict(module="aiter.ops.triton._triton_kernels.attention.prefill_attention",
                       kernel="_fwd_kernel", args=args, constexprs=constexprs,
                       options=dict(num_warps=4 if d <= 64 else 8, num_stages=1), note=note)


prefill("ea_prefill_bf16_d64", note="context_attention_fwd bf16, causal, head dim 64")
prefill("ea_prefill_bf16_d80", d=80, note="head dim 80 padded to 128, 8 warps")
prefill("ea_prefill_bf16_d64_nc", causal=False, note="non-causal")


def lean(name, *, dtype="bf16", h=2, n_ctx=(64, 128), n_ctx_q=16, d=64, block_m=16,
         block_n=64, grid=1, waves_per_eu=2, note=""):
    """attention/lean_atten_paged.py::persistent_lean_attention_paged: q [H, B*NQ, D], k/v
    [H, sum(n_ctx), D], Mp/Lp [grid, NQ], Op [grid, NQ, D]; num_warps=waves_per_eu (as the wrapper)."""
    batch = len(n_ctx)
    nk = sum(n_ctx)
    num_m_blocks = -(-n_ctx_q // block_m)
    num_n_blocks = -(-nk // block_n)
    tiles_per_head = num_m_blocks * num_n_blocks
    total = tiles_per_head * h
    t = -(-total // grid)
    if total % grid == 0:
        splits = 1 + ((num_n_blocks + t - 2) // t)
    else:
        splits = 1 + ((num_n_blocks + t - 3) // (t - 1))
    high = total - (t - 1) * grid
    args = dict(Q=T(dtype), K=T(dtype), V=T(dtype), qk_scale=0.5 * 1.44269504, Mp=T("fp32"),
                Lp=T("fp32"), Op=T("fp32"), Out=T(dtype), kv_block_tables=T("i32"),
                batch_num_block_n=T("i32"), locks=T("i32"),
                stride_qh=batch * n_ctx_q * d, stride_qm=d, stride_qk=1,
                stride_kh=nk * d, stride_kn=d, stride_kk=1,
                stride_vh=nk * d, stride_vn=d, stride_vk=1,
                stride_oh=batch * n_ctx_q * d, stride_om=d, stride_on=1,
                stride_oph=n_ctx_q * d, stride_opm=d, stride_opn=1)
    constexprs = dict(HEAD_DIM=d, BLOCK_M=block_m, BLOCK_N=block_n, batch_size=batch,
                      num_m_blocks=num_m_blocks, high_load_wgs=high, max_tiles_per_wg=t,
                      tiles_per_head=tiles_per_head, num_splits=splits)
    CASES[name] = dict(module="aiter.ops.triton._triton_kernels.attention.lean_atten_paged",
                       kernel="la_persistent_paged", args=args, constexprs=constexprs,
                       options=dict(waves_per_eu=waves_per_eu, num_warps=waves_per_eu),
                       note=note, schedule=dict(T=t, high=high, splits=splits,
                                                tiles_per_head=tiles_per_head, total=total))


lean("ea_lean_bf16_g1", note="persistent_lean_attention_paged bf16, H=2, ragged n_ctx [64, 128], "
     "NQ=BLOCK_M=16, BLOCK_N=64, D=64, total_programs=1 (one CTA hosts and finishes every tile)")
lean("ea_lean_bf16_g4", grid=4, note="same, total_programs=4 (stream-K splits, partials, atomics)")
lean("ea_lean_bf16_test", h=64, n_ctx=(65536,), grid=912,
     note="the unit test's first case shape (fp16 there), 912 programs, 2 warps")

lean("ea_lean_bf16_b3_g1", n_ctx=(64, 64, 64),
     note="H=2, 3 requests of 64 keys (one page each), NQ=BLOCK_M=16, total_programs=1")
lean("ea_lean_bf16_b1_g1", n_ctx=(128,), note="H=2, 1 request of 128 keys, total_programs=1")
lean("ea_lean_bf16_b3_nq1", n_ctx=(64, 64, 64), n_ctx_q=1,
     note="decode shape: 1 query per request (NQ=1 < BLOCK_M=16), total_programs=1")
lean("ea_lean_bf16_b1_nq1", n_ctx=(128,), n_ctx_q=1,
     note="decode shape: 1 request, 1 query (NQ=1 < BLOCK_M=16), H=2, total_programs=1")
prefill("ea_prefill_bf16_d256", d=256, note="head dim 256, BLOCK 128, 8 warps")
prefill("ea_prefill_bf16_d512_mqa", d=512, hq=16, hk=1, note="MLA-absorb-like head dim 512, MQA")
extend("ea_extend_bf16_d576_mla", lq=576, lv=512, hq=16, hk=1,
       note="MLA absorbed: Lq 576 = 512 + 64 pe, Lv 512 -> large_head config 32x32")
