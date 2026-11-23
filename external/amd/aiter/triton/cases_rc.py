"""rope / kv_cache / fusions-activation / topk compile cases (prefix rc_), args as the public
wrappers pass them on gfx950 for small checkable shapes."""
from case_types import T

CASES = {}
ROPE = "aiter.ops.triton._triton_kernels.rope.rope"


def next_pow2(n):
    return 1 << (n - 1).bit_length()


def thd2c_mha_launch_params(t, h):
    """rope/rope.py::_rope_cached_thd_2c_fwd's h == kh branch (lines 926-950)."""
    block_t = 32
    split_t = (next_pow2(t) + block_t - 1) // block_t
    min_wg = 4096 if t >= 8192 else 1024 if t >= 1024 else 512
    if split_t < min_wg:
        size = h
        split_h = (next_pow2(h) + size - 1) // size
        while split_h * split_t < min_wg and size > 1:
            size //= 2
            split_h = (next_pow2(h) + size - 1) // size
    else:
        size = h
    split_h = (next_pow2(h) + size - 1) // size
    return dict(BLOCK_T=block_t, SPLIT_H_SIZE=size, grid=(split_h, split_t, 1),
                num_stages=2 if size > 1 else 1)


def rope_thd2c(name, *, t, h, kh, d, dtype="bf16", pos="i64", neox=True, reuse=True,
               kernel=None):
    """rope_cached_thd_positions_2c_fwd(x[t,h,d], y[t,kh,d], cos, sin, positions[t], ...), not
    inplace, contiguous inputs, cos/sin [max_pos, d/2] (reuse_freqs_front_part=True)."""
    half = d // 2
    common = dict(
        x_ptr=T(dtype), y_ptr=T(dtype), cos_ptr=T(dtype), sin_ptr=T(dtype), pos_ptr=T(pos),
        off_ptr=None, out_x_ptr=T(dtype), out_y_ptr=T(dtype),
        stride_x_t=h * d, stride_x_h=d, stride_x_d=1, stride_y_t=kh * d, stride_y_h=d,
        stride_y_d=1, stride_cos_t=half if reuse else d, stride_cos_d=1, stride_pos_t=1,
        stride_out_x_t=h * d, stride_out_x_h=d, stride_out_x_d=1, stride_out_y_t=kh * d,
        stride_out_y_h=d, stride_out_y_d=1, T=t)
    consts = dict(HAVE_NOPE=False, NOPE_FIRST=False, INPLACE=False, REUSE_FREQS_FRONT_PART=reuse,
                  IS_NEOX=neox, HAVE_POS=True, HAVE_OFFS=False, BLOCK_D=d, BLOCK_D_HALF=half)
    if h == kh:
        p = thd2c_mha_launch_params(t, h)
        consts.update(BLOCK_T=p["BLOCK_T"], SPLIT_H_SIZE=p["SPLIT_H_SIZE"],
                      num_stages=p["num_stages"])
        CASES[name] = dict(module=ROPE, kernel="_rope_kernel_thd_cached_2c_fwd", args=common,
                           constexprs=consts, options=dict(num_warps=4, waves_per_eu=0,
                                                           num_stages=p["num_stages"]),
                           grid=p["grid"], note=f"thd 2c MHA path h=kh={h}, t={t}: grid {p['grid']}")
    else:
        block_t = min(max(next_pow2(t), 16), 32)
        split_t = (next_pow2(t) + block_t - 1) // block_t
        consts.update(BLOCK_T=block_t, G=kh)
        CASES[name] = dict(module=ROPE, kernel="_rope_kernel_cached_thd_2c_gqa_onehead_fwd",
                           args=common, constexprs=consts,
                           options=dict(num_warps=4, waves_per_eu=0), grid=(split_t, h, 1),
                           note=f"thd 2c GQA onehead path h={h} kh={kh} t={t}")


rope_thd2c("rc_rope_thd2c_mha12", t=4, h=12, kh=12, d=64)
rope_thd2c("rc_rope_thd2c_mha12_f32", t=4, h=12, kh=12, d=64, dtype="fp32", pos="i32")
rope_thd2c("rc_rope_thd2c_mha8_f32", t=4, h=8, kh=8, d=64, dtype="fp32", pos="i32")
rope_thd2c("rc_rope_thd2c_gqa_f32", t=4, h=8, kh=2, d=64, dtype="fp32", pos="i32")
rope_thd2c("rc_rope_thd2c_gqa_gptj_f32", t=4, h=8, kh=2, d=64, dtype="fp32", pos="i32",
           neox=False)


def rope3d(name, *, s, n, c, maxf, sp_size=1, sp_rank=0):
    """rope/rope.py::rope_fwd_3d(x[1, s, n, c] fp32, grid_sizes[1, 3], freqs[maxf, c/2])."""
    c_total = c // 2
    CASES[name] = dict(
        module=ROPE, kernel="_rope_fwd_3d",
        args=dict(x_ptr=T("fp32"), freqs_real_ptr=T("fp32"), freqs_imag_ptr=T("fp32"),
                  grid_sizes_ptr=T("i32"), out_ptr=T("fp32"),
                  stride_x_b=s * n * c, stride_x_l=n * c, stride_x_n=c, stride_x_c=1,
                  stride_freqs_s=c_total, stride_freqs_c=1, stride_grid_b=3, stride_grid_d=1,
                  stride_out_b=s * n * c, stride_out_l=n * c, stride_out_n=c, stride_out_c=1),
        constexprs=dict(L=s, N_HEADS=n, C=c, c_total=c_total, sp_size=sp_size, sp_rank=sp_rank,
                        max_freq_seq_len=maxf, s_per_rank=s, pad_freq_val_r=1.0,
                        pad_freq_val_i=0.0, BLOCK_L=32, BLOCK_N=4, BLOCK_C=64,
                        C1=c_total - 2 * (c_total // 3), C2=c_total // 3),
        options=dict(num_warps=4, waves_per_eu=1), grid=(1, n, (s + 31) // 32))


rope3d("rc_rope3d_c128", s=40, n=1, c=128, maxf=8)
rope3d("rc_rope3d_c256", s=32, n=1, c=256, maxf=8)


def silu_mul(name, *, rows, d, dtype="bf16"):
    """fusions/activation.py::fused_silu_mul's tile picks (lines 233-292)."""
    upper, p = min(d, 1024), 1
    while p * 2 <= upper:
        p *= 2
    block_n = 512 if d == 512 and rows > 4096 else 256 if d == 512 else max(32, p)
    block_m = min(32, max(4, next_pow2(rows))) if rows <= 64 else 16
    warps = 8 if rows <= 128 and block_m >= 16 and block_n >= 128 else 2
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.fusions.activation",
        kernel="fused_silu_mul_kernel",
        args=dict(inp_ptr=T(dtype), out_ptr=T(dtype), n_rows=rows, n_cols=d,
                  row_stride_in=2 * d, col_stride_in=1, row_stride_out=d, col_stride_out=1),
        constexprs=dict(BLOCK_M=block_m, BLOCK_N=block_n),
        options=dict(num_warps=warps, waves_per_eu=0),
        grid=((rows + block_m - 1) // block_m, (d + block_n - 1) // block_n),
        note=f"fused_silu_mul rows={rows} d={d}: BLOCK_M={block_m} BLOCK_N={block_n} warps={warps}")


silu_mul("rc_silu_mul_bf16", rows=3, d=24)
silu_mul("rc_silu_mul_f32", rows=3, d=24, dtype="fp32")


def silu_mul_bwd(name, *, rows, d, dtype="fp32"):
    """fusions/activation.py::silu_and_mul_backward with gfx950 SILU-AND-MUL-BACKWARD config."""
    cfg = ({"BLOCK_M": 32, "BLOCK_N": 64} if d <= 64 else {"BLOCK_M": 32, "BLOCK_N": 128}
           if d <= 128 else {"BLOCK_M": 16, "BLOCK_N": 256})
    bm = min(cfg["BLOCK_M"], next_pow2(rows))
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.fusions.activation",
        kernel="_silu_and_mul_backward_kernel",
        args=dict(grad_output_ptr=T(dtype), input_ptr=T(dtype), grad_input_ptr=T(dtype),
                  n_rows=rows, n_cols=d, grad_output_row_stride=d, grad_output_col_stride=1,
                  input_row_stride=2 * d, input_col_stride=1, grad_input_row_stride=2 * d,
                  grad_input_col_stride=1),
        constexprs=dict(BLOCK_M=bm, BLOCK_N=cfg["BLOCK_N"]),
        options=dict(num_warps=4, num_stages=1), grid=((rows + bm - 1) // bm,
                                                       (d + cfg["BLOCK_N"] - 1) // cfg["BLOCK_N"]))


silu_mul_bwd("rc_silu_mul_bwd_f32", rows=3, d=40)


def kv_cache(name, *, b, kh, d_nope, d_pe, slots, dtype="bf16"):
    """kv_cache.py::cat_and_cache_mla, bf16 non-shuffled cache [slots, kh, d_nope + d_pe]."""
    d = d_nope + d_pe
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.kv_cache", kernel="_cat_and_cache_mla_kernel",
        args=dict(k_nope_ptr=T(dtype), k_pe_ptr=T(dtype), kv_cache_ptr=T(dtype),
                  slot_mapping_ptr=T("i64"), k_nope_stride_b=kh * d_nope,
                  k_nope_stride_h=d_nope, k_nope_stride_d=1, k_pe_stride_b=kh * d_pe,
                  k_pe_stride_h=d_pe, k_pe_stride_d=1, kv_cache_stride_b=kh * d,
                  kv_cache_stride_h=d, kv_cache_stride_d=1, k_scale_ptr=T("fp32")),
        constexprs=dict(KH=kh, BLOCK_D_nope=d_nope, BLOCK_D_pe=d_pe, BLOCK_SIZE=1,
                        SHUFFLED_KV_CACHE=False, SCALE_K_WIDTH_NOPE=4, SCALE_K_WIDTH_ROPE=4,
                        HAVE_K_SCALE=True),
        options=dict(num_warps=1), grid=(b * kh, 1, 1))


kv_cache("rc_kv_cache_mla_bf16", b=2, kh=1, d_nope=32, d_pe=16, slots=8)


def topk1(name, *, b, m, k, dtype="fp32"):
    blk = max(128, k)
    while blk < m and blk < 1024:
        blk <<= 1
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.topk", kernel="_topk_kernel",
        args=dict(X=T(dtype), OUT_V=T(dtype), OUT_I=T("i64"), stride_xm=m, stride_ovm=k,
                  stride_oim=k),
        constexprs=dict(M=m, K=k, BLOCK=blk, FILL_VALUE=float("-inf"), USE_TDM=False),
        options=dict(num_warps=4, num_stages=2), grid=(b, 1, 1))


topk1("rc_topk1_f32", b=2, m=100, k=4)


rope_thd2c("rc_rope_thd2c_mha1_f32", t=4, h=1, kh=1, d=64, dtype="fp32", pos="i32")
rope_thd2c("rc_rope_thd2c_gqa_t1_f32", t=1, h=8, kh=2, d=64, dtype="fp32", pos="i32")
rope_thd2c("rc_rope_thd2c_gqa_gptj_t1_f32", t=1, h=8, kh=2, d=64, dtype="fp32", pos="i32",
           neox=False)
rope_thd2c("rc_rope_thd2c_mha12_i64", t=4, h=12, kh=12, d=64, dtype="fp32", pos="i64")


def _qkv_view_case():
    """vLLM-style q/k: views of a fused qkv projection [t, (h + 2 kh) * d] (q = qkv[:, :h*d],
    k = qkv[:, h*d:(h+kh)*d]), so x and y have token stride (h + 2 kh) * d; out_x/out_y are the
    wrapper's contiguous torch.empty(x.shape)."""
    rope_thd2c("rc_rope_thd2c_mha12_qkv_f32", t=4, h=12, kh=12, d=64, dtype="fp32", pos="i32")
    args = CASES["rc_rope_thd2c_mha12_qkv_f32"]["args"]
    args.update(stride_x_t=3 * 12 * 64, stride_y_t=3 * 12 * 64)


_qkv_view_case()
