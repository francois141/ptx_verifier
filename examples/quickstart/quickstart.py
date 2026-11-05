from pathlib import Path

import volta

# Every add kernel below must compute this formula.
add_spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"

# NVIDIA PTX: 128 threads, each adding one f32 element.
ptx = volta.Config(block=(128, 1, 1))
ptx.add_array(volta.ArrayDef("a", base=0x10000, elem_width=4, len=128, kind=volta.ArrayKind.Input))
ptx.add_array(volta.ArrayDef("b", base=0x20000, elem_width=4, len=128, kind=volta.ArrayKind.Input))
ptx.add_array(volta.ArrayDef("out", base=0x30000, elem_width=4, len=128, kind=volta.ArrayKind.Output))
ptx.add_param(volta.Param.array_ptr("a"))
ptx.add_param(volta.Param.array_ptr("b"))
ptx.add_param(volta.Param.array_ptr("out"))

result = volta.solve("examples/quickstart/add.ptx", ptx, spec=add_spec, dims={"N": 128})
print("PTX add:", result.verdict)

# AMD gfx950: one wave of 64 work-items, each adding one f32 element.
amd = volta.Config(block=(64, 1, 1))
amd.add_array(volta.ArrayDef("a", base=0x10000, elem_width=4, len=64, kind=volta.ArrayKind.Input))
amd.add_array(volta.ArrayDef("b", base=0x20000, elem_width=4, len=64, kind=volta.ArrayKind.Input))
amd.add_array(volta.ArrayDef("out", base=0x30000, elem_width=4, len=64, kind=volta.ArrayKind.Output))
amd.add_param(volta.Param.array_ptr("a"))
amd.add_param(volta.Param.array_ptr("b"))
amd.add_param(volta.Param.array_ptr("out"))

result = volta.solve("crates/volta_amd_analysis/tests/fixtures/add.s", amd, spec=add_spec, dims={"N": 64})
print("AMD add:", result.verdict)

# AWS Trainium NKI: the kernel's asserts give its 16 x 16 shapes, so it needs no config.
result = volta.solve("crates/volta_trainium_analysis/tests/fixtures/add.py", spec=add_spec, dims={"N": 256})
print("NKI add:", result.verdict)

# AMD sigmoid: each output within 1/1000 of the formula, as Lean propositions to prove.
sigmoid_spec = "dim N; array a[N]; array out[N]; out[i] = 1 / (1 + exp(-a[i]));"

sigmoid = volta.Config(block=(64, 1, 1))
sigmoid.add_array(volta.ArrayDef("a", base=0x10000, elem_width=4, len=64, kind=volta.ArrayKind.Input))
sigmoid.add_array(volta.ArrayDef("out", base=0x20000, elem_width=4, len=64, kind=volta.ArrayKind.Output))
sigmoid.add_param(volta.Param.array_ptr("a"))
sigmoid.add_param(volta.Param.array_ptr("out"))

result = volta.extract_lean(
    "crates/volta_amd_analysis/tests/fixtures/sigmoid.s",
    sigmoid,
    spec=sigmoid_spec,
    dims={"N": 64},
    tolerance="1/1000",
)
lean_file = Path("sigmoid.lean")
lean_file.write_text(result.lean)
print(f"AMD sigmoid: wrote {result.statements} proof obligations to {lean_file.resolve()}")
