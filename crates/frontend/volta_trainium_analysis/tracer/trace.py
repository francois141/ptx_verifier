"""Trace one NKI kernel call under the stand-in `nki` package.

Reads a request as JSON on stdin and writes the traced kernel, or the error that stopped
it, as JSON on stdout, in the wire form `frontend::trace` reads. Run it with `python -I`
so no environment variable or user site directory changes what it imports."""

import contextlib
import importlib
import importlib.abc
import importlib.util
import inspect
import json
import sys
import traceback
import types
from pathlib import Path

TRACER = Path(__file__).resolve().parent


class HostStub(types.ModuleType):
    """A host-only module the kernel's module imports but no traced code may use: every
    attribute, call and subclass of it is another stub, and none is a valid operand."""

    def __getattr__(self, name):
        if name.startswith("__"):
            raise AttributeError(name)
        return HostStub(f"{self.__name__}.{name}")

    def __call__(self, *args, **kwargs):
        return HostStub(f"{self.__name__}()")

    def __mro_entries__(self, bases):
        return (object,)

    def __contains__(self, item):
        return False

    def __iter__(self):
        return iter(())


class HostStubs(importlib.abc.MetaPathFinder, importlib.abc.Loader):
    def __init__(self, roots):
        self.roots = set(roots)

    def find_spec(self, name, path, target=None):
        if name.split(".")[0] in self.roots:
            return importlib.util.spec_from_loader(name, self, is_package=True)
        return None

    def create_module(self, spec):
        module = HostStub(spec.name)
        module.__path__ = []
        return module

    def exec_module(self, module):
        pass


def main():
    request = json.load(sys.stdin)
    sys.path[:0] = [str(TRACER), *request["search_path"]]
    sys.meta_path.insert(0, HostStubs(request["host_stubs"]))
    from nki import _trace

    try:
        with contextlib.redirect_stdout(sys.stderr):
            kernel = trace(request, _trace)
        result = {"kernel": kernel}
    except Exception as error:
        result = {"error": describe(error, _trace)}
    json.dump(result, sys.stdout)


def trace(request, _trace):
    trace = _trace.reset(
        _trace.TileSizes(**request["tile_sizes"]), request["nc_version"]
    )
    module = load_module(Path(request["file"]).resolve(), request["search_path"])
    function = getattr(module, request["kernel"], None)
    if not callable(function):
        raise _trace.KernelError(
            f"no kernel `{request['kernel']}` in {request['file']}"
        )
    function = inspect.unwrap(function)

    params, arguments = bind(function, request, _trace)
    trace.kernel_code = function.__code__
    returned, binding = call_kernel(function, arguments)
    if returned is not None and not isinstance(returned, _trace.Tensor):
        raise _trace.Unsupported(
            f"a kernel returning `{type(returned).__name__}` is not supported"
        )
    body = trace.body
    if returned is not None and binding is not None and binding not in trace.names:
        body = renamed(body, returned.name, binding)
        returned.name = binding
    return {
        "name": request["kernel"],
        "params": params,
        "body": body,
        "returned": None if returned is None else returned.name,
    }


def call_kernel(function, arguments):
    """The kernel's return value, and the name of the kernel's own variable bound to it when
    it returns: the output array's name when a helper declared the tensor, as the parser
    names a tensor a helper returns after its caller's binding."""
    seen = {}

    def profile(frame, event, arg):
        if event == "return" and frame.f_code is function.__code__:
            seen["locals"] = dict(frame.f_locals)

    previous = sys.getprofile()
    sys.setprofile(profile)
    try:
        returned = function(**arguments)
    finally:
        sys.setprofile(previous)
    names = [
        name for name, value in seen.get("locals", {}).items() if value is returned
    ]
    return returned, (names[0] if len(names) == 1 else None)


def renamed(value, old, new):
    """`value`, a trace's JSON, with every string equal to tensor name `old` replaced by `new`."""
    if isinstance(value, str):
        return new if value == old else value
    if isinstance(value, list):
        return [renamed(item, old, new) for item in value]
    if isinstance(value, dict):
        return {key: renamed(item, old, new) for key, item in value.items()}
    return value


def load_module(file, search_path):
    """`file` imported by its dotted name under the search path root holding it, so its
    relative imports resolve, else as a top-level module beside its own directory."""
    for root in map(Path, search_path):
        root = root.resolve()
        if file.is_relative_to(root):
            parts = list(file.relative_to(root).with_suffix("").parts)
            if parts[-1] == "__init__":
                parts.pop()
            return importlib.import_module(".".join(parts))
    sys.path.insert(1, str(file.parent))
    spec = importlib.util.spec_from_file_location(file.stem, file)
    module = importlib.util.module_from_spec(spec)
    sys.modules[file.stem] = module
    spec.loader.exec_module(module)
    return module


def bind(function, request, _trace):
    """The kernel's tensor parameters and every argument of the call: a tensor for each
    parameter with a shape, the call's constants, else the parameter's default."""
    signature = inspect.signature(function)
    for given in ("shapes", "dtypes", "constants", "contents"):
        for name in request[given]:
            if name not in signature.parameters:
                raise _trace.KernelError(
                    f"`{request['kernel']}` has no parameter `{name}`"
                )

    params, arguments = [], {}
    for name, parameter in signature.parameters.items():
        if parameter.kind in (parameter.VAR_POSITIONAL, parameter.VAR_KEYWORD):
            continue
        if name in request["shapes"]:
            shape = _trace.extents(request["shapes"][name], f"parameter `{name}`")
            dtype = request["dtypes"].get(name)
            arguments[name] = _trace.Tensor(name, shape, "hbm", None, dtype)
            _trace.TRACE.names.add(name)
            params.append(
                {
                    "name": name,
                    "shape": shape,
                    "contents": request["contents"].get(name),
                }
            )
        elif name in request["constants"]:
            value = request["constants"][name]
            arguments[name] = tuple(value) if isinstance(value, list) else value
        elif parameter.default is parameter.empty:
            raise _trace.KernelError(
                f"the call gives parameter `{name}` no shape or value"
            )
    return params, arguments


def describe(error, _trace):
    """The error's kind, message, and the innermost line of kernel code it was raised in."""
    kinds = {
        _trace.Unsupported: "unsupported",
        _trace.KernelError: "kernel",
        AssertionError: "assertion",
    }
    kind = next(
        (kind for cls, kind in kinds.items() if isinstance(error, cls)), "python"
    )
    location = None
    for frame in traceback.extract_tb(error.__traceback__):
        if not Path(frame.filename).resolve().is_relative_to(TRACER):
            location = {"file": frame.filename, "line": frame.lineno}
    message = str(error) if kind != "python" else f"{type(error).__name__}: {error}"
    return {"kind": kind, "message": message, "location": location}


if __name__ == "__main__":
    main()
