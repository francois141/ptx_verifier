"""Write the DeepGEMM PTX's quadrant twin: every tcgen05.ld/.st address offset by its warp's
lane quadrant, `(warp % 4) << 21`.

    python3 external/ptx/deepgemm/quadrant.py     # sm100_bf16_gemm.ptx -> sm100_bf16_gemm_quadrant.ptx

DeepGEMM's epilogue warps pass taddr lane 0 whatever their quadrant (sm100_bf16_gemm.cuh:355,
"the hardware will ignore the warp index bits"), while the PTX ISA (9.7.16.8.1) lets warp w of
a warpgroup access only lanes 32 (w % 4) .. +31 and requires taddr to be the access's base
address, so Volta stops at the first such load. The twin addresses each warp's own quadrant, as
the hardware is said to, so Volta can check the rest of the kernel.
"""

import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ACCESS = re.compile(r"(\s*)(tcgen05\.(?:ld|st)\.\S+.*?)\[(%r\d+)\](.*)$")


def main() -> None:
    source = HERE.parent / "survey" / "DeepGEMM" / "sm100_bf16_gemm.m128n128k256_bf16_bf16out.ptx"
    out, patched, entered = [], 0, False
    for line in source.read_text().split("\n"):
        if m := ACCESS.match(line):
            indent, head, reg, tail = m.groups()
            out += [f"{indent}add.u32 %rquad_addr, {reg}, %rquad;", f"{indent}{head}[%rquad_addr]{tail}"]
            patched += 1
            continue
        out.append(line)
        if not entered and line.strip() == "{" and any(".entry" in l for l in out[-40:]):
            entered = True
            out += ["\t.reg .b32 %rquad, %rquad_addr;", "\tmov.u32 %rquad, %tid.x;",
                    "\tshr.u32 %rquad, %rquad, 5;", "\tand.b32 %rquad, %rquad, 3;",
                    "\tshl.b32 %rquad, %rquad, 21;"]
    (HERE / "sm100_bf16_gemm.ptx").write_text(source.read_text())
    (HERE / "sm100_bf16_gemm_quadrant.ptx").write_text("\n".join(out))
    print(f"{patched} tcgen05.ld/.st addresses offset by their warp's quadrant")


if __name__ == "__main__":
    main()
