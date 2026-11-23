"""MIOpen's OpenCL kernels for gfx950 (MI355X) checked by Volta: what each case compiles, launches
and checks.

`extract.py` compiles each case and writes its assembly and launch file; `external/amd/verify.py`
runs them. Importable without MIOpen or a compiler.

A case's kernel is a `.cl` file of MIOpen's `src/kernels` (ROCm/rocm-libraries, tag rocm-7.2.4),
compiled with the `-D` build parameters its solver passes for the case's problem (each case names
the solver whose `GetSolution` it follows) and launched with the solver's work sizes and kernel
arguments. The case dataclasses are `../opencl_common.py`'s.
"""

import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from opencl_common import Array, Case, Fix, Pointer, Scalar  # noqa: E402


@dataclass(frozen=True)
class MIOpen:
    """`kernel` of MIOpen's `src/kernels/<file>`, compiled with `defines` (the solver's build
    parameters, in its order); `solver` names the source file and function choosing them."""

    file: str
    kernel: str
    defines: tuple
    solver: str
    library: str = "MIOpen"

    def origin(self) -> str:
        return f"src/kernels/{self.file} ({self.kernel}), {self.solver}"


def next_pow2(v: int) -> int:
    """MIOpen's softmax `nextPow2`, which takes 1 to 2."""
    return 2 if v == 1 else 1 << (v - 1).bit_length()


# ===== Softmax (src/kernels/MIOpenSoftmax.cl, src/solver/softmax/softmax.cpp) =====

SOFTMAX_SOLVER = "src/solver/softmax/softmax.cpp:Softmax::GetSolution"


def softmax_params(vector: int, grid_size: int) -> tuple:
    """`getParams`: the CSR-Vector (`NUM_BATCH` 1) or CSR-Stream build parameters and the
    workgroup count."""
    num_batch = next_pow2(256 // vector) if vector < 256 else 1
    if num_batch == 1:
        return (("NUM_BATCH", 1),), min(grid_size, 64 * 40 * 8)
    batch_size = 256 // num_batch
    u_batch = next_pow2(vector // batch_size) if vector > batch_size else 1
    defines = (("NUM_BATCH", num_batch), ("BATCH_SIZE", batch_size), ("U_BATCH_SIZE", u_batch))
    return defines, -(-grid_size // num_batch)


def softmax(name, n, c, h, w, direction="forward", mode="channel", check="ACCEPT", spec=True,
            fixes=(), assembly=None, note=""):
    """`miopenSoftmaxForward_V2` / `miopenSoftmaxBackward_V2`, accurate algorithm, on packed fp32
    NCHW, alpha 1, beta 0: softmax over C at every (n, h, w) (`channel` mode) or over C*H*W of
    each image (`instance`)."""
    if mode == "channel":
        grid_size, spatial, vector = n * h * w, h * w, c
    else:
        grid_size, spatial, vector = n, 1, c * h * w
    batch, workgroups = softmax_params(vector, grid_size)
    forward = direction == "forward"
    packed = (("IS_INPUT_PACKED", 1), ("IS_OUTPUT_PACKED", 1)) if forward else \
        (("IS_OUTPUT_PACKED", 1), ("IS_DOUTPUT_PACKED", 1), ("IS_DINPUT_PACKED", 1))
    defines = (*batch, ("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1),
               ("USE_SOFTMAX_ACCURATE", 1), (f"USE_SOFTMAX_MODE_{mode.upper()}", 1),
               ("RUN_FORWARD", int(forward)), *packed)
    strides = tuple(Scalar(s) for s in (c * h * w, h * w, w))
    shape = (n, c, h, w)
    if forward:
        args = (Pointer("x"), Pointer("y"), Scalar(vector, "vector_size"),
                Scalar(grid_size, "grid_size"), Scalar(spatial, "spatial_dim"), Scalar(h, "h"),
                Scalar(w, "w"), *strides, *strides, Scalar(0, "x_offset"), Scalar(0, "y_offset"),
                Scalar(1.0, "alpha", "f32"), Scalar(0.0, "beta", "f32"))
        arrays = (Array("x", "in", "f32", shape), Array("y", "out", "f32", shape))
    else:
        args = (Pointer("y"), Pointer("dy"), Pointer("dx"), Scalar(vector, "vector_size"),
                Scalar(grid_size, "grid_size"), Scalar(spatial, "spatial_dim"), Scalar(h, "h"),
                Scalar(w, "w"), *strides, *strides, *strides, Scalar(0, "y_offset"),
                Scalar(0, "dy_offset"), Scalar(0, "dx_offset"), Scalar(1.0, "alpha", "f32"),
                Scalar(0.0, "beta", "f32"))
        arrays = (Array("y", "in", "f32", shape), Array("dy", "in", "f32", shape),
                  Array("dx", "out", "f32", shape))
    return Case(
        name=name,
        description=f"softmax {direction}, {mode} mode, fp32 [{n}, {c}, {h}, {w}], "
                    f"NUM_BATCH={batch[0][1]}, {workgroups} workgroup(s){note}",
        source=MIOpen("MIOpenSoftmax.cl", "SoftmaxForward" if forward else "SoftmaxBackward",
                      defines, SOFTMAX_SOLVER),
        args=args,
        arrays=arrays,
        grid=workgroups,
        block=256,
        check=check,
        spec=f"softmax_{mode}_{direction}.spec" if spec else None,
        dims={"N": n, "C": c, "H": h, "W": w} if spec else {},
        fixes=fixes,
        assembly=assembly,
    )


# The CSR-Vector loop's fix: a barrier closing each iteration, so no wave writes `l_helper` for
# the next row while another still reads the last row's sum (README.md, Bugs).
SOFTMAX_FORWARD_FIX = Fix("            y[y_gidx] = value;\n        }\n        (void)s;",
                          "            y[y_gidx] = value;\n        }\n"
                          "        barrier(CLK_LOCAL_MEM_FENCE);\n        (void)s;")
SOFTMAX_BACKWARD_FIX = Fix("            dx[dx_gidx] = value;\n        }\n        (void)s;",
                           "            dx[dx_gidx] = value;\n        }\n"
                           "        barrier(CLK_LOCAL_MEM_FENCE);\n        (void)s;")
# More softmax vectors than the 20480 workgroups `getParams` launches, so workgroup 0 computes
# vectors 0 and 20480: in channel mode the pixels of a 144 x 144 map (forward softmax in instance
# mode goes to AttnSoftmax, a HIP kernel, first), in instance mode rows (backward has no HIP solver).
RACE_SIDE = 144
RACE_ROWS = 64 * 40 * 8 + 1


# ===== Batch normalization (src/kernels/MIOpenBatchNorm*.cl, src/solver/batchnorm/) =====

BN_EPSILON = 1e-5  # passed as a double; the kernels convert it to f32
BN_INFER_SOLVER = "src/solver/batchnorm/forward_inference.cpp:BnFwdInference::GetSolution"


def bn_vector_size(hw: int) -> int:
    return 4 if hw % 4 == 0 else 2 if hw % 2 == 0 else 1


def bn_inference(name, mode, n, c, h, w, check="ACCEPT"):
    """`miopenBatchNormalizationForwardInference` on packed fp32 NCHW, no fused activation
    (PASTHRU): `y = scale (x - mean) / sqrt(|var + eps|) + bias`, per channel (`spatial`) or per
    activation. The grid's x dimension walks the channels, so workgroup 0 computes channel 0."""
    hw = h * w
    vector = bn_vector_size(hw)
    local_y = 256
    grid_y = -(-(hw // vector) // local_y)
    defines = (("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_FPMIX", 0),
               ("MIOPEN_USE_BFPMIX", 0), ("MIO_BN_GRP0", 1), ("MIO_BN_GRP1", local_y),
               ("MIO_BN_GRP2", 1), ("MIO_BN_GFX103X", 0), ("MIO_BN_GFX110X", 0),
               ("MIO_BN_GFX120X", 0), ("MIO_BN_GFX115X", 0), ("MIO_LAYOUT_NHWC", 0),
               ("MIO_BN_VECTORIZE", int(vector > 1)), ("MIO_BN_VEC_SIZE", vector),
               ("MIOPEN_NRN_OP_ID", 0))
    spatial = mode == "spatial"
    file, kernel = (("MIOpenBatchNormFwdInferSpatial.cl", "MIOpenBatchNormFwdInferSpatialEst")
                    if spatial else
                    ("MIOpenBatchNormFwdInferPerAct.cl", "MIOpenBatchNormFwdInferPerActivationEst"))
    stats = (c,) if spatial else (c, h, w)
    activation = (Scalar(1.0, "alpha_activ", "f32"), Scalar(0.0, "beta_activ", "f32")) if spatial else ()
    return Case(
        name=name,
        description=f"batch norm forward inference, {mode}, fp32 [{n}, {c}, {h}, {w}], "
                    f"vector size {vector}, eps {BN_EPSILON}",
        source=MIOpen(file, kernel, defines, BN_INFER_SOLVER),
        args=(Pointer("x"), Pointer("y"), Pointer("mean"), Pointer("variance"), Pointer("scale"),
              Pointer("bias"), Scalar(BN_EPSILON, "epsilon", "f64"), Scalar(c, "c", "u32"),
              Scalar(hw, "hw", "u32"), Scalar(n, "batch", "u32"), Scalar(hw, "cStride", "u32"),
              Scalar(1, "hwStride", "u32"), Scalar(c * hw, "batchStride", "u32"), *activation),
        arrays=(Array("x", "in", "f32", (n, c, h, w)), Array("mean", "in", "f32", stats),
                Array("variance", "in", "f32", stats), Array("scale", "in", "f32", stats),
                Array("bias", "in", "f32", stats), Array("y", "out", "f32", (n, c, h, w))),
        grid=(c, grid_y),
        block=(1, local_y),
        check=check,
        spec=f"bn_inference_{mode}.spec",
        dims={"N": n, "C": c, "H": h, "W": w},
    )


BN_TRAIN_SOLVER = "src/solver/batchnorm/forward_spatial.cpp:BnFwdTrainingSpatial::GetSolution"


def bn_train_spatial(name, n, c, h, w, check="ACCEPT"):
    """`miopenBatchNormalizationForwardTraining`, spatial, packed fp32 NCHW, saving the batch mean
    and inverse variance, no running averages (null pointers), no fused activation: variant 0,
    MIOpen's default for H*W <= 512 (`DefaultConfigSpatialSingle`), one workgroup per channel
    reducing sum(x) and sum(x^2) through DPP and LDS."""
    hw, nhw = h * w, n * h * w
    local = 256 if (hw < 256 and n < 256) or (hw < 100 and n <= 256) else 1024
    defines = (("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_FPMIX", 0),
               ("MIOPEN_USE_BFPMIX", 0), ("MIO_SAVE_MEAN_VARIANCE", 1), ("MIO_RUNNING_RESULT", 0),
               ("MIO_BN_VARIANT", 0), ("MIO_BN_LDS_SIZE", local),
               ("MIO_BN_LDSGCN_SIZE", local // 64), ("MIO_BN_N", n), ("MIO_BN_NGRPS", 1),
               ("MIO_BN_NGRPS2", 1), ("MIO_BN_N_ELEMENTS", 1), ("MIO_BN_GRP0", local),
               ("MIO_BN_GRP1", 1), ("MIO_BN_GRP2", 1), ("MIO_BN_GRP0_FINAL", local),
               ("MIO_BN_GRP1_FINAL", 1), ("MIO_BN_GRP2_FINAL", 1), ("MIO_BN_GFX103X", 0),
               ("MIO_BN_GFX110X", 0), ("MIO_BN_GFX120X", 0), ("MIO_BN_GFX115X", 0),
               ("MIO_LAYOUT_NHWC", 0), ("MIO_BN_VECTORIZE", 0), ("MIO_BN_VEC_SIZE", 1),
               ("MIO_BN_STASH_METHOD", 0), ("MIOPEN_NRN_OP_ID", 0), ("MIO_BN_C", c),
               ("MIO_BN_HW", hw), ("MIO_BN_NHW", nhw), ("MIO_BN_CHW", c * hw),
               ("MIO_BN_NCHW", n * c * hw))
    return Case(
        name=name,
        description=f"batch norm forward training, spatial, fp32 [{n}, {c}, {h}, {w}], variant 0, "
                    f"{local} work-items per channel, saving mean and inverse variance",
        source=MIOpen("MIOpenBatchNormFwdTrainSpatial.cl", "MIOpenBatchNormFwdTrainSpatial",
                      defines, BN_TRAIN_SOLVER),
        args=(Pointer("x"), Pointer("y"), Pointer("scale"), Pointer("bias"),
              Scalar(1.0 / nhw, "inhw", "f32"), Scalar(BN_EPSILON, "epsilon", "f64"),
              Pointer("save_mean"), Pointer("save_inv_variance"),
              Scalar(1.0, "alpha_activ", "f32"), Scalar(0.0, "beta_activ", "f32")),
        arrays=(Array("x", "in", "f32", (n, c, h, w)), Array("scale", "in", "f32", (c,)),
                Array("bias", "in", "f32", (c,)), Array("y", "out", "f32", (n, c, h, w)),
                Array("save_mean", "out", "f32", (c,)),
                Array("save_inv_variance", "out", "f32", (c,))),
        grid=c,
        block=local,
        check=check,
        spec="bn_train_spatial.spec",
        dims={"N": n, "C": c, "H": h, "W": w},
    )


BN_BWD_SOLVER = "src/solver/batchnorm/backward_spatial.cpp:BnBwdTrainingSpatial::GetSolution"


def bn_bwd_spatial(name, n, c, h, w, check="ACCEPT"):
    """`miopenBatchNormalizationBackward`, spatial, packed fp32 NCHW, from the forward pass's
    saved mean and inverse variance (`MIO_BN_USESAVED` 1), no fused activation: variant 0 (H*W
    <= 512 and not both N > 64 and H*W > 160), 1024 work-items per channel, which reduce
    sum(dy) and sum(x_hat dy) through DPP and LDS."""
    hw, nhw, local = h * w, n * h * w, 1024
    defines = (("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_FPMIX", 0),
               ("MIOPEN_USE_BFPMIX", 0), ("MIO_BN_USESAVED", 1), ("MIO_BN_N", n),
               ("MIO_BN_C", c), ("MIO_BN_HW", hw), ("MIO_BN_NHW", nhw), ("MIO_BN_CHW", c * hw),
               ("MIO_BN_NCHW", n * c * hw), ("MIO_BN_NGRPS", 1), ("MIO_BN_NGRPS2", 1),
               ("MIO_BN_N_ELEMENTS", 1), ("MIO_BN_LDS_SIZE", local),
               ("MIO_BN_LDSGCN_SIZE", local // 64), ("MIO_BN_VARIANT", 0), ("MIO_WAVESIZE", 64),
               ("MIO_BN_GRP0", local), ("MIO_BN_GRP1", 1), ("MIO_BN_GRP2", 1),
               ("MIO_BN_GRP0_FINAL", local), ("MIO_BN_GRP1_FINAL", 1), ("MIO_BN_GRP2_FINAL", 1),
               ("MIO_LAYOUT_NHWC", 0), ("MIO_BN_VECTORIZE", 0), ("MIO_BN_VEC_SIZE", 1),
               ("MIO_BN_STASH_METHOD", 0), ("MIOPEN_NRN_OP_ID", 0), ("MIO_BN_GFX103X", 0),
               ("MIO_BN_GFX110X", 0), ("MIO_BN_GFX120X", 0), ("MIO_BN_GFX115X", 0))
    return Case(
        name=name,
        description=f"batch norm backward, spatial, fp32 [{n}, {c}, {h}, {w}], variant 0, "
                    f"{local} work-items per channel, from the saved mean and inverse variance",
        source=MIOpen("MIOpenBatchNormBwdSpatial.cl", "MIOpenBatchNormBwdSpatial", defines,
                      BN_BWD_SOLVER),
        args=(Pointer("x"), Pointer("dy"), Pointer("dx"), Pointer("scale"), Pointer("bias"),
              Pointer("dscale"), Pointer("dbias"), Pointer("saved_mean"),
              Pointer("saved_inv_variance"), Scalar(1.0 / nhw, "inhw", "f32"),
              Scalar(1.0, "alpha_activ", "f32"), Scalar(0.0, "beta_activ", "f32")),
        arrays=(Array("x", "in", "f32", (n, c, h, w)), Array("dy", "in", "f32", (n, c, h, w)),
                Array("scale", "in", "f32", (c,)), Array("bias", "in", "f32", (c,)),
                Array("saved_mean", "in", "f32", (c,)),
                Array("saved_inv_variance", "in", "f32", (c,)),
                Array("dx", "out", "f32", (n, c, h, w)), Array("dscale", "out", "f32", (c,)),
                Array("dbias", "out", "f32", (c,))),
        grid=c,
        block=local,
        check=check,
        spec="bn_bwd_spatial.spec",
        dims={"N": n, "C": c, "H": h, "W": w},
    )


def bn_bwd_per_activation(name, n, c, h, w, check="ACCEPT"):
    """`miopenBatchNormalizationBackward`, per activation, packed fp32 NCHW, from the saved mean
    and inverse variance: each work-item computes one (c, h, w)'s gradients over the N images.
    Workgroup (0, 0) covers channel 0's first 64 (H*W <= 64) or 256 activations."""
    hw = h * w
    local = 64 if hw <= 64 else 256
    defines = (("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_FPMIX", 0),
               ("MIOPEN_USE_BFPMIX", 0), ("MIO_BN_N", n), ("MIO_BN_C", c), ("MIO_BN_HW", hw),
               ("MIO_BN_NHW", n * hw), ("MIO_BN_CHW", c * hw), ("MIO_BN_NCHW", n * c * hw),
               ("MIO_BN_NGRPS", -(-hw // local)), ("MIO_BN_GRP0", 1), ("MIO_BN_GRP1", local),
               ("MIO_BN_GRP2", 1), ("MIO_BN_GFX103X", 0), ("MIO_BN_GFX110X", 0),
               ("MIO_BN_GFX120X", 0), ("MIO_BN_GFX115X", 0))
    return Case(
        name=name,
        description=f"batch norm backward, per activation, fp32 [{n}, {c}, {h}, {w}], from the "
                    f"saved mean and inverse variance",
        source=MIOpen("MIOpenBatchNormBwdPerAct.cl", "MIOpenBatchNormBwdPerActivationSaved",
                      defines, "src/solver/batchnorm/backward_per_activation.cpp:"
                               "BnBwdTrainingPerActivation::GetSolution"),
        args=(Pointer("x"), Pointer("dy"), Scalar(n, "N", "u32"), Scalar(c * hw, "in_nstride", "u32"),
              Scalar(hw, "in_cstride", "u32"), Pointer("dx"), Pointer("scale"), Pointer("dscale"),
              Pointer("dbias"), Pointer("saved_mean"), Pointer("saved_inv_variance")),
        arrays=(Array("x", "in", "f32", (n, c, h, w)), Array("dy", "in", "f32", (n, c, h, w)),
                Array("scale", "in", "f32", (c, h, w)), Array("saved_mean", "in", "f32", (c, h, w)),
                Array("saved_inv_variance", "in", "f32", (c, h, w)),
                Array("dx", "out", "f32", (n, c, h, w)), Array("dscale", "out", "f32", (c, h, w)),
                Array("dbias", "out", "f32", (c, h, w))),
        grid=(c, -(-hw // local)),
        block=(1, local),
        check=check,
        spec="bn_bwd_per_activation.spec",
        dims={"N": n, "C": c, "H": h, "W": w},
    )


# ===== Convolution bias gradient (src/kernels/MIOpenConvBwdBias.cl, src/ocl/convolutionocl.cpp) =====

def conv_bwd_bias(name, n, k, h, w, check="ACCEPT", assembly=None):
    """`miopenConvolutionBackwardBias` on a packed fp32 dy [N, K, H, W]: db[k] = sum of dy over N,
    H and W. Workgroups (0, g) for g < 256 each reduce channels g, g + 256, ... in 4-element
    units, the last unit of each map `off_pix` = H*W % 4 elements; workgroup (0, 0)'s outputs are
    db[0], db[256], ...: the first output when K <= 256."""
    hw = h * w
    units = -(-hw // 4)
    defines = (("MLO_CONVBWD_GROUP_SZ0", 256), ("MLO_CONVBWD_GROUP_SZ1", 1),
               ("MLO_CONVBWDB_LCL_MEMSZ", 256), ("MLO_CONVBWDB_UNITSIZE", 4),
               ("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_INT8", 0),
               ("MIOPEN_USE_BFP16", 0), ("MIOPEN_USE_INT32", 0), ("MIOPEN_USE_FP8", 0),
               ("MIOPEN_USE_BFP8", 0))
    spec = k <= 256
    return Case(
        name=name,
        description=f"convolution backward bias, fp32 dy [{n}, {k}, {h}, {w}], {units} units of 4 "
                    f"per map, off_pix {hw % 4}",
        source=MIOpen("MIOpenConvBwdBias.cl", "MIOpenConvBwdB", defines,
                      "src/ocl/convolutionocl.cpp:ConvolutionBackwardBias"),
        args=(Pointer("dy"), Pointer("db"), Scalar(k, "bias_c", "u32"), Scalar(hw, "top_str_c", "u32"),
              Scalar(k * hw, "top_str_b", "u32"), Scalar(units, "num_spatial_work", "u32"),
              Scalar(hw % 4, "off_pix", "u32"), Scalar(units * n, "total_work", "u32")),
        arrays=(Array("dy", "in", "f32", (n, k, h, w)),
                Array("db", "out", "f32", (1,) if spec else (k,))),
        grid=(1, 256),
        block=256,
        check=check,
        spec="conv_bwd_bias.spec" if spec else None,
        dims={"N": n, "K": k, "H": h, "W": w, "R": 1} if spec else {},
        assembly=assembly,
    )


# ===== Layout transposition (src/kernels/UniversalTranspose.cl) =====

def universal_transpose(name, n, c, h, w, check="ACCEPT", local=None, note="", assembly=None):
    """`UniversalTransposeSolver` (include/miopen/utility/transposing_solver.hpp) taking an NHWC
    fp32 tensor to NCHW, as the transposing pooling solvers do for every NHWC pooling forward: one
    workgroup of 16 * min(N*C*H*W, compute units) work-items, which on an MI355X (256 CUs) fits
    the kernel's 256 only up to 16 elements and the hardware's 1024 up to 64 (README.md, Bugs). `local`
    replaces that size, as the fix does."""
    elements = n * c * h * w
    local = local or 16 * min(elements, 256)
    lens = (n, c, 1, h, w)
    nhwc = (h * w * c, 1, 0, w * c, c)
    nchw = (c * h * w, h * w, 0, w, 1)
    defines = (("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_INT8", 0),
               ("MIOPEN_USE_BFP16", 0), ("MIOPEN_USE_INT32", 0), ("MIOPEN_USE_FP8", 0),
               ("MIOPEN_USE_BFP8", 0))
    return Case(
        name=name,
        description=f"NHWC to NCHW transpose, fp32 [{n}, {c}, {h}, {w}], one workgroup of "
                    f"{local}{note}",
        source=MIOpen("UniversalTranspose.cl", "UniversalTranspose", defines,
                      "include/miopen/utility/transposing_solver.hpp:UniversalTransposeSolver"),
        args=(Pointer("x"), Pointer("y"), *(Scalar(v, kind="u64") for v in lens),
              *(Scalar(v, kind="u64") for v in nhwc), *(Scalar(v, kind="u64") for v in nchw)),
        arrays=(Array("x", "in", "f32", (n, h, w, c)), Array("y", "out", "f32", (n, c, h, w))),
        grid=1,
        block=local,
        check=check,
        spec="transpose_nhwc_nchw.spec",
        dims={"N": n, "C": c, "H": h, "W": w},
        assembly=assembly,
    )


# ===== Activations (src/kernels/MIOpenNeuron.cl, src/solver/activ/) =====

ACTIVATION_MODES = {"logistic": 1, "clipped_relu": 7}


def activation(name, mode, direction, elements, alpha=0.0, beta=0.0, gamma=0.0, check="ACCEPT"):
    """`miopenActivationForward` / `Backward` on a packed fp32 tensor of `elements`: one float4
    per work-item (MIOPEN_READ_UNIT 4), 256 per workgroup, `elements / 4` work-items."""
    read_unit = 4 if elements % 4 == 0 else 2 if elements % 2 == 0 else 1
    work_items = elements // read_unit
    defines = (("LITE", ""), ("MIOPEN_READ_UNIT", read_unit),
               ("MIOPEN_READ_TYPE", "_FLOAT" if read_unit == 1 else f"_FLOAT{read_unit}"),
               ("MIOPEN_NRN_OP_ID", ACTIVATION_MODES[mode]), ("MIOPEN_USE_FP16", 0),
               ("MIOPEN_USE_FP32", 1))
    forward = direction == "forward"
    if forward:
        source = MIOpen("MIOpenNeuron.cl", "MIOpenActiveFwdLite", defines,
                        "src/solver/activ/fwd_0.cpp:ActivFwdSolver0::GetSolution")
        args = (Pointer("x"), Pointer("y"), Scalar(gamma, "gamma", "f32"),
                Scalar(beta, "beta", "f32"), Scalar(alpha, "alpha", "f32"),
                Scalar(0, "x_offset", "i64"), Scalar(0, "y_offset", "i64"))
        arrays = (Array("x", "in", "f32", (elements,)), Array("y", "out", "f32", (elements,)))
    else:
        source = MIOpen("MIOpenNeuron.cl", "MIOpenActiveBwdLite", defines,
                        "src/solver/activ/bwd_0.cpp:ActivBwdSolver0::GetSolution")
        args = (Pointer("dx"), Pointer("dy"), Pointer("x"), Pointer("y"),
                Scalar(beta * gamma, "diff_scale", "f32"), Scalar(gamma, "gamma", "f32"),
                Scalar(beta, "beta", "f32"), Scalar(alpha, "alpha", "f32"),
                Scalar(0, "dx_offset", "i64"), Scalar(0, "dy_offset", "i64"),
                Scalar(0, "x_offset", "i64"), Scalar(0, "y_offset", "i64"))
        arrays = (Array("dy", "in", "f32", (elements,)), Array("x", "in", "f32", (elements,)),
                  Array("y", "in", "f32", (elements,)), Array("dx", "out", "f32", (elements,)))
    return Case(
        name=name,
        description=f"activation {direction}, {mode} (alpha {alpha}), fp32, {elements} elements, "
                    f"{work_items} work-items",
        source=source,
        args=args,
        arrays=arrays,
        grid=-(-work_items // 256),
        block=min(256, work_items),
        check=check,
        spec=f"activation_{mode}_{direction}.spec",
        dims={"N": elements},
    )


# ===== Tensor operations (src/kernels/MIOpenTensorKernels.cl, src/solver/tensorOp/) =====

def bias_add(name, n, c, h, w, check="ACCEPT"):
    """`miopenOpTensor(miopenTensorOpAdd)` with A [N, C, H, W], B [1, C, 1, 1] and alpha0 =
    alpha1 = 1, beta = 0, a convolution's bias: `OpTensorFwdBias`. With fewer than 640 channels
    and more than 256 elements per channel, `Get4dParams` splits each channel's work over N
    (`incr_wg`), so workgroup 0 computes image 0's channel 0: the first H*W outputs."""
    work, groups, incr = n * h * w, c, 0
    if groups < 640 and work > 256:
        work, groups, incr = work // n, groups * n, 1
    defines = (("MIOPEN_TYPE", "float"), ("MIOPEN_TENSOR_OP", "miopenAdd"),
               ("DIM_TYPE", "uint64_t"), ("MAX_NUM_WG", 4096), ("USE_FWD_BIAS", ""))
    rows = 1 if incr else n
    return Case(
        name=name,
        description=f"OpTensor add (convolution bias), fp32 A [{n}, {c}, {h}, {w}] + B [1, {c}, 1, 1], "
                    f"{groups} workgroups of {work} outputs, workgroup 0's checked",
        source=MIOpen("MIOpenTensorKernels.cl", "OpTensorFwdBias", defines,
                      "src/solver/tensorOp/OpTensorFwdBias.cpp:OpTensorFwdBias::GetSolution"),
        args=(Pointer("a"), Pointer("b"), Scalar(c, "b_c"), Pointer("c"), Scalar(n, "c_n"),
              Scalar(c * h * w, "c_nstride"), Scalar(h * w, "c_cstride"),
              Scalar(work, "work_per_wg"), Scalar(1.0, "alpha0", "f32"),
              Scalar(1.0, "alpha1", "f32"), Scalar(0.0, "beta", "f32"), Scalar(0, "Aoffset", "i64"),
              Scalar(0, "Boffset", "i64"), Scalar(0, "Coffset", "i64"), Scalar(groups, "num_wg"),
              Scalar(incr, "incr_wg")),
        arrays=(Array("a", "in", "f32", (n, c, h, w)), Array("b", "in", "f32", (c,)),
                Array("c", "out", "f32", (rows, h, w))),
        grid=groups,
        block=256,
        check=check,
        spec="bias_add.spec",
        dims={"N": n, "C": c, "H": h, "W": w, "R": rows},
    )


def leading_ones_mul(name, n, c, h, w, check="ACCEPT"):
    """`miopenOpTensor(miopenTensorOpMul)` with A [N, C, H, W], B [N, 1, 1, 1] (a per-image
    scale), alpha0 = alpha1 = 1, beta = 0: `OpTensorLeadingOnes`, one workgroup per image."""
    work = c * h * w
    defines = (("MIOPEN_TYPE", "float"), ("MIOPEN_TENSOR_OP", "miopenMul"),
               ("DIM_TYPE", "uint64_t"), ("MAX_NUM_WG", 4096), ("USE_LEADING_ONES", ""))
    return Case(
        name=name,
        description=f"OpTensor multiply, fp32 A [{n}, {c}, {h}, {w}] * B [{n}, 1, 1, 1], "
                    f"workgroup 0 computing image 0",
        source=MIOpen("MIOpenTensorKernels.cl", "OpTensorLeadingOnes", defines,
                      "src/solver/tensorOp/OpTensorLeadingOnes.cpp:OpTensorLeadingOnes::GetSolution"),
        args=(Pointer("a"), Pointer("b"), Pointer("c"), Scalar(c, "c_c"), Scalar(h, "c_h"),
              Scalar(w, "c_w"), Scalar(c * h * w, "c_nstride"), Scalar(h * w, "c_cstride"),
              Scalar(work, "work_per_wg"), Scalar(1.0, "alpha0", "f32"),
              Scalar(1.0, "alpha1", "f32"), Scalar(0.0, "beta", "f32"), Scalar(0, "Aoffset", "i64"),
              Scalar(0, "Boffset", "i64"), Scalar(0, "Coffset", "i64"), Scalar(n, "num_wg"),
              Scalar(8, "bitmap", "u32")),
        arrays=(Array("a", "in", "f32", (n, c, h, w)), Array("b", "in", "f32", (n,)),
                Array("c", "out", "f32", (1, c, h, w))),
        grid=n,
        block=64 if work < 64 else 256,
        check=check,
        spec="leading_ones_mul.spec",
        dims={"N": n, "C": c, "H": h, "W": w, "R": 1},
    )


# ===== Tensor transforms (src/kernels/MIOpenSubTensorOp*.cl, src/tensor.cpp) =====

def worker_sizes(lens) -> tuple:
    """`get_worker_sizes` below 65536 work-items: each length rounded up to a power of two."""
    return tuple(1 << (length - 1).bit_length() for length in lens)


def subtensor_2d(name, op, rows, cols, src_cols, alpha=1.0, check="ACCEPT"):
    """`miopenCopyTensor` (`copy`) or `miopenTransformTensor` with beta 0 (`transform`, y =
    alpha x) from a [rows, cols] view of a [rows, src_cols] fp32 buffer into a packed tensor: the
    2-d `SubTensorOp` kernel, which loops each work-item over the elements congruent to it modulo
    the power-of-two worker grid."""
    workers = worker_sizes((rows, cols))
    total = workers[0] * workers[1]
    lengths = tuple((f"WORK_LENGTH_{i}", v) for i, v in enumerate(workers))
    types = (("MIOPEN_USE_FP16", 0), ("MIOPEN_USE_FP32", 1), ("MIOPEN_USE_INT8", 0),
             ("MIOPEN_USE_BFP16", 0), ("MIOPEN_USE_INT32", 0), ("MIOPEN_USE_FP8", 0),
             ("MIOPEN_USE_BFP8", 0))
    if op == "copy":
        source = MIOpen("MIOpenSubTensorOpWithSubTensorKernel.cl", "SubTensorOpWithSubTensor2d",
                        (("SUBTENSOR_OP_WITH_SUBTENSOR", "SUBTENSOR_OP_WITH_SUBTENSOR_COPY"),
                         *types, *lengths), "src/tensor.cpp:CopyTensor")
        args = (Pointer("x"), Scalar(0, "srcOffset"), Scalar(src_cols, "srcStride0"),
                Scalar(1, "srcStride1"), Scalar(rows, "srcLen0"), Scalar(cols, "srcLen1"),
                Pointer("y"), Scalar(0, "dstOffset"), Scalar(cols, "dstStride0"),
                Scalar(1, "dstStride1"))
        spec, dims = "copy_2d.spec", {"R": rows, "C": cols, "S": src_cols}
    else:
        source = MIOpen("MIOpenSubTensorOpWithTransformKernel.cl", "SubTensorOpWithTransform2d",
                        (*types, ("MIOPEN_BETA_IS_ZERO", 1),
                         ("MIOPEN_ALPHA_IS_ONE", int(alpha == 1.0)), *lengths),
                        "src/tensor.cpp:TransformTensor")
        args = (Pointer("x"), Scalar(alpha, "alpha", "f32"), Pointer("y"),
                Scalar(0.0, "beta", "f32"), Scalar(0, "src_offset", "u32"),
                Scalar(0, "dst_offset", "u32"), Scalar(src_cols, "src_stride0", "u32"),
                Scalar(1, "src_stride1", "u32"), Scalar(cols, "dst_stride0", "u32"),
                Scalar(1, "dst_stride1", "u32"), Scalar(rows, "len0", "u32"),
                Scalar(cols, "len1", "u32"))
        spec, dims = "transform_2d.spec", {"R": rows, "C": cols, "S": src_cols}
    return Case(
        name=name,
        description=f"{'CopyTensor' if op == 'copy' else f'TransformTensor (alpha {alpha}, beta 0)'}, "
                    f"fp32 [{rows}, {cols}] view of [{rows}, {src_cols}] into a packed tensor, "
                    f"{total} work-items",
        source=source,
        args=args,
        arrays=(Array("x", "in", "f32", (rows, src_cols)), Array("y", "out", "f32", (rows, cols))),
        grid=-(-total // 256),
        block=min(256, total),
        check=check,
        spec=spec,
        dims=dims,
    )




CASES = (
    softmax("softmax_c1000", 1, 1000, 1, 1),
    softmax("softmax_c64", 1, 64, 2, 2),
    softmax("softmax_bwd_c1000", 1, 1000, 1, 1, "backward"),
    softmax("softmax_bwd_c64", 1, 64, 2, 2, "backward"),
    softmax("softmax_pixels_race", 1, 256, RACE_SIDE, RACE_SIDE, check="REJECTED", spec=False,
            note=", two pixels per workgroup"),
    softmax("softmax_pixels_race_fixed", 1, 256, RACE_SIDE, RACE_SIDE, check="VERIFIED",
            spec=False, fixes=(SOFTMAX_FORWARD_FIX,), note=", two pixels per workgroup, fixed"),
    softmax("softmax_bwd_rows_race", RACE_ROWS, 256, 1, 1, "backward", mode="instance",
            check="REJECTED", spec=False, note=", two rows per workgroup"),
    softmax("softmax_bwd_rows_race_fixed", RACE_ROWS, 256, 1, 1, "backward", mode="instance",
            check="VERIFIED", spec=False, fixes=(SOFTMAX_BACKWARD_FIX,),
            note=", two rows per workgroup, fixed"),
    bn_inference("bn_infer_spatial", "spatial", 2, 1, 16, 16),
    bn_inference("bn_infer_peract", "per_activation", 2, 1, 16, 16),
    bn_train_spatial("bn_train_spatial", 8, 1, 8, 8),
    bn_bwd_spatial("bn_bwd_spatial", 8, 1, 8, 8),
    bn_bwd_per_activation("bn_bwd_peract", 4, 1, 8, 8),
    conv_bwd_bias("conv_bwd_bias", 2, 4, 7, 7),
    conv_bwd_bias("conv_bwd_bias_k257", 2, 257, 3, 3, check="VERIFIED", assembly="conv_bwd_bias"),
    universal_transpose("transpose_nhwc_nchw", 1, 4, 2, 2),
    universal_transpose("transpose_nhwc_nchw_256", 2, 8, 4, 4, check="ABORT",
                        note=" (16 x 256 compute units)", assembly="transpose_nhwc_nchw"),
    universal_transpose("transpose_nhwc_nchw_256_fixed", 2, 8, 4, 4, local=256,
                        note=", the kernel's maximum", assembly="transpose_nhwc_nchw"),
    activation("sigmoid_fwd", "logistic", "forward", 1024),
    activation("sigmoid_bwd", "logistic", "backward", 1024),
    activation("relu6_fwd", "clipped_relu", "forward", 1024, alpha=6.0),
    bias_add("bias_add", 2, 4, 16, 16),
    leading_ones_mul("leading_ones_mul", 2, 3, 8, 8),
    subtensor_2d("copy_tensor", "copy", 6, 10, 16),
    subtensor_2d("transform_tensor", "transform", 6, 10, 16, alpha=0.5),
)
