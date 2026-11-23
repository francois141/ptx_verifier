"""Import Aiter's Triton kernel modules without aiter/__init__.py (C++ extensions).

Registers stub packages `aiter`, `aiter.ops` and `aiter.ops.triton` whose __path__ points at the
read-only checkout, so `aiter.ops.triton._triton_kernels.<module>` imports only the Triton code,
and pins the arch probe to gfx950 (there is no GPU in the container)."""
import sys
import types

AITER = "/work/aiter/aiter"


def install():
    for name, path in [("aiter", AITER), ("aiter.ops", f"{AITER}/ops"),
                       ("aiter.ops.triton", f"{AITER}/ops/triton")]:
        module = types.ModuleType(name)
        module.__path__ = [path]
        module.__file__ = f"{path}/__init__.py"
        sys.modules[name] = module
    sys.modules["aiter"].ops = sys.modules["aiter.ops"]
    sys.modules["aiter.ops"].triton = sys.modules["aiter.ops.triton"]
    from aiter.ops.triton.utils._triton import arch_info
    arch_info._CACHED_ARCH = "gfx950"
