import volta

spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"
size = 64
config = volta.Config(block=(size, 1, 1))
for name, base, kind in (
    ("a", 0x10000, volta.ArrayKind.Input),
    ("b", 0x20000, volta.ArrayKind.Input),
    ("out", 0x30000, volta.ArrayKind.Output),
):
    config.add_array(volta.ArrayDef(name, base, 4, size, kind))
    config.add_param(volta.Param.array_ptr(name))

result = volta.solve(
    "crates/volta_amd_analysis/tests/fixtures/add.s",
    config,
    spec=spec,
    dims={"N": size},
)
assert result.verdict == "ACCEPT", result.evidence
assert result.race_verified is None
print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
