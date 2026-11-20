"""nkilib's rmsnorm_quant on one core: RMSNorm, then row or static FP8 quantization."""

import importlib

module = importlib.import_module("nkilib.core.rmsnorm.rmsnorm_quant")
QuantizationType = importlib.import_module(
    "nkilib.core.utils.common_types"
).QuantizationType


def kernel(hidden, ln_w, input_dequant_scale=None):
    quantization = (
        QuantizationType.ROW
        if input_dequant_scale is None
        else QuantizationType.STATIC
    )
    args = module.RmsNormQuantKernelArgs(quantization_type=quantization)
    return module.rmsnorm_quant_kernel(
        hidden, ln_w, args, input_dequant_scale=input_dequant_scale
    )
