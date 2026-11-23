"""Compile cases: the args and config each public wrapper passes for a small checkable shape."""
from case_types import T


BF16_MAX = 3.3895313892515355e38
FP32_MAX = 3.4028234663852886e38
CASES = {}


def mha(name, *, dtype="bf16", b=1, hq=2, hk=2, sq=128, sk=128, d=64, causal=False, window=0,
        config, varlen=False, note=""):
    """_attn_fwd as attention/mha.py::_flash_attn_forward launches it (bshd, contiguous)."""
    dpow2 = max(1 << (d - 1).bit_length(), 16)
    if varlen:
        tq, tk = b * sq, b * sk  # total tokens; thd layout [T, H, D]
        q = (0, d, hq * d, 1)
        k = (0, d, hk * d, 1)
        o = q
        lse = (0, 1, hq)  # softmax_lse [total_q, H]: stride_h = 1, stride_m = H
    else:
        q = (sq * hq * d, d, hq * d, 1)
        k = (sk * hk * d, d, hk * d, 1)
        o = q
        lse = (hq * sq, sq, 1)
    args = dict(
        q_ptr=T(dtype), k_ptr=T(dtype), v_ptr=T(dtype), descale_q_ptr=None, descale_k_ptr=None,
        descale_v_ptr=None, out_ptr=T(dtype), alibi_slopes_ptr=None, s_dmask_ptr=None,
        softmax_lse_ptr=T("fp32"), sink_ptr=None,
        stride_qz_in=q[0], stride_qh_in=q[1], stride_qm_in=q[2], stride_qk_in=q[3],
        stride_kz_in=k[0], stride_kh_in=k[1], stride_kn_in=k[2], stride_kk_in=k[3],
        stride_vz_in=k[0], stride_vh_in=k[1], stride_vn_in=k[2], stride_vk_in=k[3],
        stride_descale_q_z_in=0, stride_descale_k_z_in=0, stride_descale_v_z_in=0,
        stride_oz_in=o[0], stride_oh_in=o[1], stride_om_in=o[2], stride_on_in=o[3],
        stride_alibi_z_in=0, stride_alibi_h_in=0,
        stride_sd_z_in=hq * sq * sk, stride_sd_h_in=sq * sk, stride_sd_m_in=sk, stride_sd_n_in=1,
        stride_lse_z_in=lse[0], stride_lse_h_in=lse[1], stride_lse_m_in=lse[2],
        sm_scale=d ** -0.5, cu_seqlens_q=T("i32") if varlen else None,
        cu_seqlens_k=T("i32") if varlen else None, dropout_p=0.0, philox_seed=0,
        philox_offset_base_in=0, SEQLEN_Q=sq, SEQLEN_K=sk, BATCH=b)
    cfg = dict(config)
    options = {k: cfg.pop(k) for k in ("num_warps", "num_stages", "waves_per_eu", "num_ctas")
               if k in cfg}
    options["enable_fp_fusion"] = True
    constexprs = dict(
        IS_CAUSAL=causal, NUM_Q_HEADS=hq, NUM_K_HEADS=hk, BLOCK_DMODEL=d, BLOCK_DMODEL_POW2=dpow2,
        BLOCK_DMODEL_PE=0, RETURN_SCORES=False, ENABLE_DROPOUT=False, IS_FP8=False,
        FP8_MAX=BF16_MAX if dtype == "bf16" else FP32_MAX, VARLEN=varlen, NUM_XCD=8,
        SWIZZLE="default", USE_INT64_STRIDES=False, ENABLE_SINK=False, SLIDING_WINDOW=window,
        HEAD_STRIDE_ALIGNED_8=(d % 8 == 0), **cfg)
    CASES[name] = dict(module="aiter.ops.triton._triton_kernels.attention.mha", kernel="_attn_fwd",
                       args=args, constexprs=constexprs, options=options, note=note)


MHA_SMALL_HEAD = dict(BLOCK_M=128, BLOCK_N=64, PRELOAD_V=True, waves_per_eu=2, num_warps=4,
                      num_ctas=1, num_stages=3)
MHA_DEFAULT = dict(BLOCK_M=128, BLOCK_N=64, PRELOAD_V=True, waves_per_eu=2, num_warps=4,
                   num_ctas=1, num_stages=1)
MHA_MID_HEAD = dict(BLOCK_M=128, BLOCK_N=128, PRELOAD_V=False, waves_per_eu=0, num_warps=4,
                    num_ctas=1, num_stages=2)
MHA_FP32 = dict(BLOCK_M=32, BLOCK_N=32, PRELOAD_V=True, waves_per_eu=1, num_warps=2, num_ctas=1,
                num_stages=1)

mha("mha_bf16_d64", d=64, sq=128, sk=100, config=MHA_SMALL_HEAD,
    note="bf16, head 64 -> small_head config; seqlen_k 100 (padded tail)")
mha("mha_bf16_d64_causal", d=64, sq=128, sk=100, causal=True, config=MHA_SMALL_HEAD)
mha("mha_bf16_d16", d=16, sq=128, sk=100, config=MHA_DEFAULT,
    note="bf16, head 16 -> default config")
mha("mha_bf16_d72", d=72, sq=128, sk=100, config=MHA_MID_HEAD,
    note="bf16, head 72 (padded to 128) -> mid_head config")
mha("mha_fp32_d64", dtype="fp32", d=64, sq=32, sk=40, config=MHA_FP32,
    note="fp32 -> dropout_or_fp32 config (32x32 tiles, 2 warps)")
mha("mha_fp32_d16", dtype="fp32", d=16, sq=32, sk=40, config=MHA_FP32)


def rmsnorm(name, *, dtype="bf16", rows=4, cols=100, block=None, blocked=False, warps=None):
    block = block or 1 << (cols - 1).bit_length()
    options = {} if warps is None else {"num_warps": warps}
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.normalization.rmsnorm", kernel="_rms_norm_kernel",
        args=dict(input_ptr=T(dtype), output_ptr=T(dtype), g_ptr=T(dtype), rsigma_ptr=T("fp32"),
                  input_row_stride=cols, output_row_stride=cols, n_rows=rows, n_cols=cols,
                  epsilon=1e-6),
        constexprs=dict(BLOCK_SIZE=block, USE_BLOCKED=blocked), options=options)


rmsnorm("rmsnorm_bf16_100", cols=100)
rmsnorm("rmsnorm_fp32_100", dtype="fp32", cols=100)
rmsnorm("rmsnorm_fp32_64", dtype="fp32", cols=64)
rmsnorm("rmsnorm_fp32_blocked", dtype="fp32", rows=2, cols=20000, block=8192, blocked=True)


def softmax(name, *, dtype="fp32", rows=4, cols=100):
    elem = 4 if dtype == "fp32" else 2
    block = min(65536 // elem, 1 << (cols - 1).bit_length())
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.softmax", kernel="_softmax_kernel_online",
        args=dict(output_ptr=T(dtype), input_ptr=T(dtype), input_row_stride=cols,
                  output_row_stride=cols, n_cols=cols),
        constexprs=dict(BLOCK_SIZE=block),
        options=dict(waves_per_eu=2, num_warps=8, num_stages=2))


softmax("softmax_fp32_100", cols=100)
softmax("softmax_bf16_100", dtype="bf16", cols=100)

# One head, one query block: workgroup 0 writes the whole output (Volta checks it against a spec).
mha("mha_bf16_d64_h1", hq=1, hk=1, d=64, sq=128, sk=100, config=MHA_SMALL_HEAD,
    note="bf16, 1 head, head 64 (small_head config), seqlen_q 128, seqlen_k 100 (padded K tail)")
mha("mha_bf16_d64_h1_causal", hq=1, hk=1, d=64, sq=100, sk=100, causal=True, config=MHA_SMALL_HEAD,
    note="bf16, 1 head, head 64, causal, seqlen 100: what flash_attn_func(causal=True, "
         "window_size=(0, -1)) launches (sliding_window = max(0, 0) = 0, window disabled)")

# The same kernels without the LSE store (softmax_lse_ptr=None, which the wrapper never passes):
# its slice-layout -> blocked conversion writes each row's LSE from every lane holding a copy.
for _base in ("mha_bf16_d64_h1", "mha_bf16_d64_h1_causal"):
    _case = dict(CASES[_base])
    _case["args"] = dict(_case["args"], softmax_lse_ptr=None)
    _case["note"] = _case["note"] + "; no LSE (softmax_lse_ptr=None)"
    CASES[_base + "_nolse"] = _case


def pa_v1_wo_dot(name, *, dtype="bf16", h=1, d=64, blk=16, max_blocks=4, num_blks=5):
    """paged_attn_decode_v1's MHA branch (query_grp_sz == 1): grid (num_q_heads, num_seqs, 1),
    no gfx950 v1_wo_dot launch entry, so Triton's default num_warps/num_stages."""
    try:
        import triton.language as tl
        compute_type = tl.bfloat16 if dtype == "bf16" else tl.float32
    except ImportError:  # building launch files outside the container
        compute_type = dtype
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.attention.pa_decode",
        kernel="_paged_attn_decode_v1_wo_dot_kernel",
        args=dict(out=T(dtype), q_ptr=T(dtype), k_cache_ptr=T(dtype), v_cache_ptr=T(dtype),
                  blk_tables_ptr=T("i32"), seq_lens_ptr=T("i32"), alibi_slopes_ptr=None,
                  scale=d ** -0.5, k_scale=1.0, v_scale=1.0, stride_q_s=h * d, stride_q_h=d,
                  stride_o_s=h * d, stride_o_nh=d, stride_k_b=h * blk * d, stride_k_nh=blk * d,
                  stride_k_kb=d, stride_bt_s=max_blocks),
        constexprs=dict(compute_type=compute_type,
                        KV_BLK_SZ=blk, KV_BLK_SZ_POW2=blk, HEAD_SZ=d, HEAD_SZ_POW2=d,
                        QUERY_GRP_SZ=1),
        options={}, note=f"pa_decode v1 wo_dot {dtype} 1 head, head {d}, page {blk}")


pa_v1_wo_dot("pa_v1_wo_dot_bf16", dtype="bf16")
pa_v1_wo_dot("pa_v1_wo_dot_fp32", dtype="fp32")
