from pathlib import Path

import volta

epsilon = "1/1000"  # Maximum absolute error per output: 0.001.

result = volta.extract_lean(
    "crates/volta_pipeline/tests/trainium/success/sigmoid.py",
    spec="dim N; array a[N]; array out[N]; out[i] = 1 / (1 + exp(-a[i]));",
    dims={"N": 8},
    tolerance=epsilon,
)

output = Path("target/lean/sigmoid_nki.lean")
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(result.lean, encoding="utf-8")
print(f"Wrote {output}")
