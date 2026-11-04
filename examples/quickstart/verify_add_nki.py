import volta

spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"

# Trainium reads the 16 x 16 tensor shapes from the kernel, so no config is needed.
result = volta.solve(
    "crates/volta_trainium_analysis/tests/fixtures/add.py",
    spec=spec,
    dims={"N": 256},
)
assert result.verdict == "ACCEPT", result.evidence
assert result.race_verified is None
print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
