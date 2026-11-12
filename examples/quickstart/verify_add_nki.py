import volta

spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"

# Trainium reads the 16 x 16 tensor shapes from the kernel, so no config is needed.
result = volta.solve(
    "crates/volta_pipeline/tests/trainium/success/add.py",
    spec=spec,
    dims={"N": 256},
)

print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
