"""Fork ng: layernorm, fused-add layernorm/rmsnorm, large-M rmsnorm, softmax and gemm_a16w16
cases, each with the args and config its public wrapper passes on gfx950."""
from case_types import T

CASES = {}
LN = "aiter.ops.triton._triton_kernels.normalization.norm"
RMS = "aiter.ops.triton._triton_kernels.normalization.rmsnorm"
GEMM = "aiter.ops.triton._triton_kernels.gemm.basic.gemm_a16w16"
REDUCE = "aiter.ops.triton._triton_kernels.common.splitk_reduce"


def pow2(n):
    return 1 << (n - 1).bit_length()


def layernorm(name, *, dtype="fp32", rows=4, cols=100, block=None, note=""):
    elem = 4 if dtype == "fp32" else 2
    block = block or min(65536 // elem, pow2(cols))  # norm.py::_layernorm_forward
    CASES[name] = dict(
        module=LN, kernel="_layernorm_kernel",
        args=dict(x_ptr=T(dtype), y_ptr=T(dtype), w_ptr=T(dtype), b_ptr=T(dtype),
                  mean_ptr=T("fp32"), rstd_ptr=T("fp32"), x_row_stride=cols,
                  y_row_stride=cols, n_rows=rows, n_cols=cols, eps=1e-5),
        constexprs=dict(BLOCK_SIZE=block), options={}, note=note)


def add_layernorm(name, *, dtype="fp32", rows=4, cols=100, block=None, x_stride=None, note=""):
    elem = 4 if dtype == "fp32" else 2
    block = block or min(65536 // elem, pow2(cols))
    CASES[name] = dict(
        module=LN, kernel="_fused_add_layernorm_kernel",
        args=dict(x_ptr=T(dtype), y_ptr=T(dtype), res_in_ptr=T(dtype), res_out_ptr=T(dtype),
                  w_ptr=T(dtype), b_ptr=T(dtype), mean_ptr=T("fp32"), rstd_ptr=T("fp32"),
                  x_row_stride=x_stride or cols, y_row_stride=cols, n_rows=rows, n_cols=cols,
                  eps=1e-5),
        constexprs=dict(BLOCK_SIZE=block), options={}, note=note)


def gfx950_rms_block(cols, elem):
    """rmsnorm.py::block_size and use_blocked on gfx950."""
    n_pow2 = pow2(cols)
    block = 8192 if n_pow2 > 65536 // elem else n_pow2
    return block, cols > block


def add_rmsnorm(name, *, dtype="fp32", rows=4, cols=100, x_stride=None, out_stride=None,
                block=None, blocked=None, note=""):
    elem = 4 if dtype == "fp32" else 2
    b, u = gfx950_rms_block(cols, elem)
    CASES[name] = dict(
        module=RMS, kernel="_fused_add_rmsnorm_kernel",
        args=dict(input_ptr=T(dtype), output_ptr=T(dtype), res_in_ptr=T(dtype),
                  res_out_ptr=T(dtype), g_ptr=T(dtype), rsigma_ptr=T("fp32"),
                  input_row_stride=x_stride or cols, output_row_stride=out_stride or cols,
                  n_rows=rows, n_cols=cols, epsilon=1e-6),
        constexprs=dict(BLOCK_SIZE=block or b, USE_BLOCKED=u if blocked is None else blocked),
        options={}, note=note)


def rms_large_m(name, *, dtype="fp32", rows=8193, cols=100, rsigma=False, note=""):
    block_n = pow2(cols)
    block_m = max(min(16384 // block_n, 32), 8)
    CASES[name] = dict(
        module=RMS, kernel="_rmsnorm_kernel_large_m_small_n",
        args=dict(X=T(dtype), Y=T(dtype), W=T(dtype), RSIGMA=T("fp32") if rsigma else None,
                  M=rows, N=cols, eps=1e-6, stride_xm=cols, stride_xn=1, stride_ym=cols,
                  stride_yn=1),
        constexprs=dict(BLOCK_M=block_m, BLOCK_N=block_n, NUM_WARPS=8, NUM_STAGES=2),
        options=dict(num_warps=8, num_stages=2), note=note)


def rms(name, *, dtype="fp32", rows=4, cols=100, x_stride=None, note=""):
    elem = 4 if dtype == "fp32" else 2
    b, u = gfx950_rms_block(cols, elem)
    CASES[name] = dict(
        module=RMS, kernel="_rms_norm_kernel",
        args=dict(input_ptr=T(dtype), output_ptr=T(dtype), g_ptr=T(dtype), rsigma_ptr=T("fp32"),
                  input_row_stride=x_stride or cols, output_row_stride=cols, n_rows=rows,
                  n_cols=cols, epsilon=1e-6),
        constexprs=dict(BLOCK_SIZE=b, USE_BLOCKED=u), options={}, note=note)


def softmax(name, *, dtype="fp32", rows=4, cols=100, in_stride=None, out_stride=None, note=""):
    elem = 4 if dtype == "fp32" else 2
    CASES[name] = dict(
        module="aiter.ops.triton._triton_kernels.softmax", kernel="_softmax_kernel_online",
        args=dict(output_ptr=T(dtype), input_ptr=T(dtype), input_row_stride=in_stride or cols,
                  output_row_stride=out_stride or cols, n_cols=cols),
        constexprs=dict(BLOCK_SIZE=min(65536 // elem, pow2(cols))),
        options=dict(waves_per_eu=2, num_warps=8, num_stages=2), note=note)


def splitk_params(cfg, K):
    """gemm_config_utils.compute_splitk_params."""
    cfg = dict(cfg)
    cfg["SPLITK_BLOCK_SIZE"] = -(-K // cfg["NUM_KSPLIT"])
    while cfg["NUM_KSPLIT"] > 1 and cfg["BLOCK_SIZE_K"] > cfg["SPLITK_BLOCK_SIZE"]:
        cfg["NUM_KSPLIT"] = max(cfg["NUM_KSPLIT"] // 2, 1)
        cfg["SPLITK_BLOCK_SIZE"] = -(-K // cfg["NUM_KSPLIT"])
    if cfg["BLOCK_SIZE_K"] > cfg["SPLITK_BLOCK_SIZE"]:
        cfg["BLOCK_SIZE_K"] = pow2(cfg["SPLITK_BLOCK_SIZE"])
        if cfg["BLOCK_SIZE_K"] > cfg["SPLITK_BLOCK_SIZE"]:
            cfg["BLOCK_SIZE_K"] //= 2
    cfg["BLOCK_SIZE_K"] = max(cfg["BLOCK_SIZE_K"], 16)
    if cfg["NUM_KSPLIT"] > 1 and cfg["SPLITK_BLOCK_SIZE"] % cfg["BLOCK_SIZE_K"]:
        cfg["SPLITK_BLOCK_SIZE"] = -(-cfg["SPLITK_BLOCK_SIZE"] // cfg["BLOCK_SIZE_K"]) * cfg["BLOCK_SIZE_K"]
        cfg["NUM_KSPLIT"] = -(-K // cfg["SPLITK_BLOCK_SIZE"])
    return cfg


def gemm(name, *, M, N, K, cfg, bias=False, activation=None, skip_reduce=False, note=""):
    """gemm/basic/gemm_a16w16.py::_gemm_a16w16_native's triton path: x (M, K), w (N, K) both
    contiguous bf16, w.T passed, y (M, N) bf16 or y_pp (NUM_KSPLIT, M, N) fp32."""
    from aiter.ops.triton._triton_kernels.common.activation import _get_activation_from_str
    cfg = splitk_params(cfg, K)
    split = cfg["NUM_KSPLIT"] > 1
    options = {k: cfg.pop(k) for k in ("num_warps", "num_stages", "waves_per_eu",
                                       "matrix_instr_nonkdim")}
    even_k = K % cfg["SPLITK_BLOCK_SIZE"] == 0 and cfg["SPLITK_BLOCK_SIZE"] % cfg["BLOCK_SIZE_K"] == 0
    even_mn = M % cfg["BLOCK_SIZE_M"] == 0 and N % cfg["BLOCK_SIZE_N"] == 0
    CASES[name] = dict(
        module=GEMM, kernel="_gemm_a16_w16_kernel",
        args=dict(a_ptr=T("bf16"), b_ptr=T("bf16"), bias_ptr=T("bf16") if bias else None,
                  c_ptr=T("fp32") if split else T("bf16"), M=M, N=N, K=K, stride_am=K,
                  stride_ak=1, stride_bk=1, stride_bn=K, stride_ck=M * N if split else 0,
                  stride_cm=N, stride_cn=1),
        constexprs=dict(EVEN_K=even_k, EVEN_MN=even_mn,
                        activation=_get_activation_from_str(activation) if activation else "",
                        use_activation=activation is not None, ADD_BIAS=bias,
                        SKIP_REDUCE=skip_reduce, NUM_XCDS=8, **cfg),
        options=options, note=note, dims=dict(M=M, N=N, K=K), config=cfg)


def splitk_reduce(name, *, M, N, ksplit, actual, bias=False, activation=None, note=""):
    from aiter.ops.triton._triton_kernels.common.activation import _get_activation_from_str
    CASES[name] = dict(
        module=REDUCE, kernel="_gemm_splitk_reduce_kernel",
        args=dict(c_in_ptr=T("fp32"), c_out_ptr=T("bf16"), bias_ptr=T("bf16") if bias else None,
                  M=M, N=N, stride_c_in_k=M * N, stride_c_in_m=N, stride_c_in_n=1,
                  stride_c_out_m=N, stride_c_out_n=1),
        constexprs=dict(BLOCK_SIZE_M=32, BLOCK_SIZE_N=32, ACTUAL_KSPLIT=actual,
                        MAX_KSPLIT=pow2(ksplit), ADD_BIAS=bias,
                        activation=_get_activation_from_str(activation) if activation else "",
                        use_activation=activation is not None,
                        KERNEL_NAME="_gemm_a16w16_reduce_kernel"),
        options={}, note=note)


# --- layernorm ---------------------------------------------------------------------------------
layernorm("ng_ln_fp32_100", note="layer_norm fp32 4x100: BLOCK 128 (wrapper), grid 4")
layernorm("ng_ln_fp32_64", cols=64, note="layer_norm fp32 4x64: BLOCK 64, grid 4")
layernorm("ng_ln_fp32_tail", cols=200, block=64,
          note="layer_norm loop path (wrapper uses it only for N > 16384 fp32) at BLOCK 64, N 200")
add_layernorm("ng_addln_fp32_100", note="layernorm2d_fwd_with_add fp32 4x100, grid 4")
add_layernorm("ng_addln_fp32_tail", cols=200, block=64,
              note="fused add layernorm loop path at BLOCK 64, N 200")
# --- rmsnorm -----------------------------------------------------------------------------------
add_rmsnorm("ng_addrms_fp32_64", cols=64, note="rmsnorm2d_fwd_with_add fp32 4x64, grid 4")
add_rmsnorm("ng_addrms_fp32_100", cols=100, note="rmsnorm2d_fwd_with_add fp32 4x100, grid 4")
add_rmsnorm("ng_addrms_fp32_blocked", rows=2, cols=20000,
            note="rmsnorm2d_fwd_with_add fp32 2x20000: gfx950 blocked path, BLOCK 8192")
add_rmsnorm("ng_addrms_stride", rows=1025, cols=64, x_stride=128,
            note="rmsnorm2d_fwd_with_add, input a [1025, 64] view of a [1025, 128] buffer "
                 "(row stride 128), residual_in/out contiguous; grid 1024, workgroup 0 does "
                 "rows 0 and 1024")
rms_large_m("ng_rms_lmsn", note="rms_norm fp32 8193x100 -> _rmsnorm_kernel_large_m_small_n, "
            "BLOCK_M 32, BLOCK_N 128, 8 warps")
rms("ng_rms_colstride", cols=64, x_stride=128,
    note="rms_norm of x = A[:, ::2], A [4, 128]: the wrapper passes x.stride(0)=128 only")
# --- softmax -----------------------------------------------------------------------------------
softmax("ng_softmax_colstride", cols=100, in_stride=200,
        note="softmax of x = A[:, ::2], A [4, 200]: x.stride() = (200, 2), y contiguous")
# --- gemm_a16w16 -------------------------------------------------------------------------------
DEFAULT_M16 = dict(BLOCK_SIZE_M=16, BLOCK_SIZE_N=16, BLOCK_SIZE_K=256, GROUP_SIZE_M=1,
                   num_warps=4, num_stages=3, waves_per_eu=6, matrix_instr_nonkdim=16,
                   cache_modifier=".cg", NUM_KSPLIT=1)
DEFAULT_M32 = dict(BLOCK_SIZE_M=32, BLOCK_SIZE_N=32, BLOCK_SIZE_K=256, GROUP_SIZE_M=1,
                   num_warps=8, num_stages=3, waves_per_eu=8, matrix_instr_nonkdim=16,
                   cache_modifier=".cg", NUM_KSPLIT=1)
N128_K4096_M16 = dict(BLOCK_SIZE_M=8, BLOCK_SIZE_N=16, BLOCK_SIZE_K=128, GROUP_SIZE_M=1,
                      num_warps=1, num_stages=3, waves_per_eu=1, matrix_instr_nonkdim=16,
                      cache_modifier=None, NUM_KSPLIT=16)
gemm("ng_gemm_m16", M=16, N=64, K=512, cfg=DEFAULT_M16,
     note="gemm_a16w16 bf16 M=16 N=64 K=512: DEFAULT M_LEQ_16, EVEN_K, EVEN_MN")
gemm("ng_gemm_tail", M=20, N=40, K=200, cfg=DEFAULT_M32, bias=True, activation="relu",
     note="gemm_a16w16 bf16 M=20 N=40 K=200 + bias + relu: DEFAULT M_LEQ_32 (BK -> 128), "
          "M/N/K tails")
gemm("ng_gemm_splitk", M=16, N=128, K=4096, cfg=N128_K4096_M16, bias=True,
     note="gemm_a16w16 bf16 M=16 N=128 K=4096: tuned N=128-K=4096 M_LEQ_16, NUM_KSPLIT 16, "
          "8x16x128 tiles, 1 warp; workgroup 0's partial")
splitk_reduce("ng_reduce", M=16, N=128, ksplit=16, actual=16, bias=True, activation="silu",
              note="_gemm_splitk_reduce_kernel for the split-K case, + bias + silu")
# --- loop-path tests at a small BLOCK (the wrappers use these loops only past 16384 fp32 columns)
softmax("ng_softmax_multi", cols=300, note="online softmax, 3 blocks of 128 (code path of N > 16384)")
CASES["ng_softmax_multi"]["constexprs"]["BLOCK_SIZE"] = 128
add_rmsnorm("ng_addrms_tail", cols=200, block=64, blocked=True,
            note="fused add rmsnorm USE_BLOCKED path at BLOCK 64, N 200")
rms("ng_rms_tail", cols=200, note="rms_norm USE_BLOCKED path at BLOCK 64, N 200")
CASES["ng_rms_tail"]["constexprs"].update(BLOCK_SIZE=64, USE_BLOCKED=True)
