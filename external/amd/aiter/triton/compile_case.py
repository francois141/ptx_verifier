"""Compile Aiter Triton kernels offline for gfx950: [CASES=module] python compile_case.py [--global] CASE...
Each case in cases.py names a module, a kernel, its runtime args (T("bf16") for a tensor, ints,
floats, None) and constexprs. Args are specialized as Triton's JIT does at launch: an int 1 is a
constexpr, a multiple of 16 gets tt.divisibility, a tensor gets divisibility and (unless --global)
tt.pointer_range=32, so loads become buffer ops as on a real launch of a < 2 GB tensor."""
import hashlib, importlib, json, os, re, sys, traceback
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import aiter_stub
aiter_stub.install()

import triton
from triton.backends.amd.compiler import HIPBackend
from triton.backends.compiler import GPUTarget
from triton.compiler import ASTSource
from case_types import T
cases = importlib.import_module(os.environ.get("CASES", "cases"))

OUT = Path(__file__).resolve().parent / "out"


def unwrap(fn):
    while not isinstance(fn, triton.runtime.jit.JITFunction):
        fn = fn.fn
    return fn


def specialize(fn, args, constexprs, buffer_ops):
    signature, consts, attrs = {}, {}, {}
    for index, arg in enumerate(fn.arg_names):
        param = fn.params[index]
        if param.is_constexpr:
            if arg in constexprs:
                consts[arg] = constexprs[arg]
            elif param.has_default:
                consts[arg] = param.default
            else:
                raise RuntimeError(f"no value for constexpr {arg}")
            signature[arg] = "constexpr"
            continue
        if arg not in args:
            if param.has_default:
                value = param.default
            else:
                raise RuntimeError(f"no value for runtime arg {arg}")
        else:
            value = args[arg]
        if isinstance(value, T):
            signature[arg] = f"*{value.dtype}"
            attrs[(index,)] = HIPBackend.parse_attr("DS" if buffer_ops else "D")
        elif value is None or isinstance(value, bool):
            signature[arg] = "constexpr"
            consts[arg] = value
        elif isinstance(value, int):
            if value == 1:
                signature[arg] = "constexpr"
                consts[arg] = 1
            else:
                signature[arg] = "i32" if -2**31 <= value < 2**31 else "i64"
                if value % 16 == 0:
                    attrs[(index,)] = HIPBackend.parse_attr("D")
        elif isinstance(value, float):
            signature[arg] = "fp32"
        else:
            raise RuntimeError(f"unsupported arg {arg}={value!r}")
    return signature, consts, attrs


def compile_case(name, buffer_ops):
    case = cases.CASES[name]
    module = importlib.import_module(case["module"])
    fn = unwrap(getattr(module, case["kernel"]))
    signature, consts, attrs = specialize(fn, case["args"], case.get("constexprs", {}), buffer_ops)
    kernel = triton.compile(ASTSource(fn, signature, constexprs=consts, attrs=attrs),
                            target=GPUTarget("hip", "gfx950", 64), options=case["options"])
    asm = kernel.asm["amdgcn"]
    tag = name if buffer_ops else f"{name}.global"
    if not triton.__version__.startswith("3.9"):
        tag = f"{tag}.t{triton.__version__}"
    (OUT / f"{tag}.orig.s").write_text(asm)
    # Triton 3.9's LLVM spells the target triple amdgpu9.50-...; Volta reads the classic one.
    asm = asm.replace("amdgpu9.50-amd-amdhsa-unknown-gfx950", "amdgcn-amd-amdhsa--gfx950")
    (OUT / f"{tag}.s").write_text(asm)
    kernarg = next(int(l.split()[-1]) for l in asm.splitlines()
                   if l.strip().startswith(".amdhsa_kernarg_size"))
    mfma = sorted(set(re.findall(r"\bv_mfma_\w+", asm)))
    lds_ops = sorted(set(re.findall(r"\bds_\w+", asm)))
    mem = sorted(set(re.findall(r"\b(?:buffer|global|flat|s_load|s_buffer_load)_\w+", asm)))
    notable = sorted(set(re.findall(r"\b(?:v_exp_f32|v_log_f32|v_rcp_f32|v_rsq_f32|v_sqrt_f32|v_div_\w+|v_permlane\w+|v_readlane\w*|v_readfirstlane\w*|s_swappc\w*|\w*atomic\w*|v_cvt_\w+|v_pk_\w+|v_dot\w+|s_barrier|v_cndmask\w*|v_ldexp\w*|v_fma\w*|v_mad\w*|v_bfe\w*|v_alignbit\w*|v_perm_b32|v_lshl_add_u64|v_mov_b64|s_sleep|s_setprio|v_med3\w*|v_max3\w*|v_min3\w*)\b", asm)))
    dpp = sorted(set(re.findall(r"(?:row_\w+|quad_perm|row_bcast\w*|wave_\w+)(?=[:\s])", asm)))
    meta = dict(case=name, buffer_ops=buffer_ops, module=case["module"], kernel=case["kernel"],
                symbol=kernel.metadata.name, shared=kernel.metadata.shared, kernarg_size=kernarg,
                options=case["options"], signature=signature,
                constexprs={k: repr(v) for k, v in consts.items()},
                attrs={str(k): v for k, v in attrs.items()}, mfma=mfma, lds_ops=lds_ops,
                memory_ops=mem, notable_ops=notable, dpp=dpp,
                vgprs=next((l.split()[-1] for l in asm.splitlines() if ".vgpr_count:" in l), None),
                sgprs=next((l.split()[-1] for l in asm.splitlines() if ".sgpr_count:" in l), None),
                asm_sha256=hashlib.sha256(asm.encode()).hexdigest(), triton=triton.__version__,
                note=case.get("note", ""))
    (OUT / f"{tag}.json").write_text(json.dumps(meta, indent=2) + "\n")
    print(f"OK {tag}: {kernel.metadata.name} shared={kernel.metadata.shared} kernarg={kernarg} "
          f"mfma={mfma} ds={lds_ops} mem={mem}")


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    argv = sys.argv[1:]
    buffer_ops = "--global" not in argv
    names = [a for a in argv if not a.startswith("--")] or list(cases.CASES)
    status = 0
    for name in names:
        try:
            compile_case(name, buffer_ops)
        except Exception:
            status = 1
            print(f"FAIL {name}")
            traceback.print_exc()
    sys.exit(status)
