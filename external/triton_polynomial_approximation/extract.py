#!/usr/bin/env python3
"""Compile kernel.py once per activation to PTX for Ampere, 64 elements over 64 threads.

Run with triton==3.5.1 on Linux (the volta-tritonbench:triton-3.5.1-torch-2.9.0 image; no GPU):
    python extract.py [CASE...]
writes <case>.ptx and <case>.launch.json (its spec beside it in this folder).
"""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
BLOCK = 64
OPTIONS = {"num_warps": 2, "num_stages": 1}
TARGET = ("cuda", 80, 32)
# Each case's spec and description.
CASES = {
    "gelu_erf": ("gelu_erf", "exact GELU with libdevice's erf"),
    "tanh": ("tanh", "libdevice's tanh"),
    "softplus": ("softplus", "log(1 + e^x) with libdevice's logf"),
    "gelu_erf_as": ("gelu_erf", "exact GELU with Abramowitz and Stegun's 7.1.26 erf"),
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cases", nargs="*", help="cases to build (default: all)")
    args = parser.parse_args()

    import triton
    from triton.backends.compiler import GPUTarget
    from triton.compiler import ASTSource

    if triton.__version__ != "3.5.1":
        raise RuntimeError("Reproduction requires triton==3.5.1")
    spec = importlib.util.spec_from_file_location("activation", ROOT / "kernel.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    fn = module.activation_kernel

    for name in args.cases or list(CASES):
        spec_name, description = CASES[name]
        signature = {"x_ptr": "*fp32", "y_ptr": "*fp32", "BLOCK": "constexpr", "ACTIVATION": "constexpr"}
        constants = {"BLOCK": BLOCK, "ACTIVATION": name}
        kernel = triton.compile(
            ASTSource(fn, signature, constexprs=constants), target=GPUTarget(*TARGET), options=OPTIONS
        )
        (ROOT / f"{name}.ptx").write_text(kernel.asm["ptx"])
        params = [{"name": "x_ptr", "ptr": "x"}, {"name": "y_ptr", "ptr": "y"}]
        params += [{"name": extra, "int": 0} for extra in ("global_scratch", "profile_scratch")]
        launch = {
            "description": f"Triton 3.5.1, {description}, over {BLOCK} f32 elements",
            "kernel": kernel.metadata.name,
            "block": [32 * OPTIONS["num_warps"], 1, 1],
            "grid": [1, 1, 1],
            "dynamic_shared_bytes": kernel.metadata.shared,
            "arrays": [
                {"name": "x", "kind": "in", "dtype": "f32", "shape": [BLOCK]},
                {"name": "y", "kind": "out", "dtype": "f32", "shape": [BLOCK]},
            ],
            "params": params,
            "spec": f"{spec_name}.spec",
            "dims": {"N": BLOCK},
        }
        (ROOT / f"{name}.launch.json").write_text(json.dumps(launch, indent=2) + "\n")
        print(f"wrote {name}.ptx")
    return 0


if __name__ == "__main__":
    sys.exit(main())
