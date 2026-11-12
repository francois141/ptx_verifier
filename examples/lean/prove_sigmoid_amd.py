import volta

spec = "dim N; array a[N]; array out[N]; out[i] = 1 / (1 + exp(-a[i]));"
size = 4096
config = volta.Config(block=(1024, 1, 1))  # One workgroup; each work-item computes four outputs.
for name, base, kind in (
    ("a", 0x10000, volta.ArrayKind.Input),
    ("out", 0x20000, volta.ArrayKind.Output),
):
    config.add_array(volta.ArrayDef(name, base, 4, size, kind))
    config.add_param(volta.Param.array_ptr(name))

result = volta.prove_lean(
    "examples/lean/sigmoid_4096.s",
    config,
    spec=spec,
    dims={"N": size},
    tolerance="1/1000",
    output_dir="target/lean/sigmoid_amd_4096",
    verbose=True,  # Print each step, then the time and cost.
)

print(f"{result.isa}: {result.proved_statements} of {result.statements} statements proved")
print(f"Proof: {result.proof}")
