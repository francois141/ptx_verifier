#!/usr/bin/env python3
"""Compile the pinned CUTLASS binary GEMM offline, locally or through Docker."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import uuid

ROOT = Path(__file__).resolve().parent
COMMIT = "ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e"
IMAGE = "nvidia/cuda:12.9.1-devel-ubuntu24.04"


def run(*command, cwd=None):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"{command[0]} failed:\n{result.stdout}{result.stderr}")
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cutlass", type=Path, help="clean checkout of the pinned commit; otherwise download v3.9.2")
    parser.add_argument("--backend", choices=["auto", "local", "docker"], default="auto")
    args = parser.parse_args()
    backend = args.backend
    if backend == "auto":
        backend = "local" if shutil.which("nvcc") else "docker"
    with tempfile.TemporaryDirectory(prefix="volta-cutlass-compile-") as temporary:
        work = Path(temporary)
        source = args.cutlass.resolve() if args.cutlass else work / "cutlass"
        if args.cutlass is None:
            run("git", "clone", "--depth", "1", "--branch", "v3.9.2",
                "https://github.com/NVIDIA/cutlass.git", str(source))
        if run("git", "-C", str(source), "rev-parse", "HEAD") != COMMIT:
            raise RuntimeError(f"CUTLASS checkout must be at {COMMIT}")
        if run("git", "-C", str(source), "status", "--porcelain", "--", "include"):
            raise RuntimeError("CUTLASS include tree has local changes")
        shutil.copy2(ROOT / "kernel.cu", work / "kernel.cu")
        flags = ["-std=c++17", "-O3", "-arch=sm_80", "-ptx", "kernel.cu", "-o", "kernel.ptx"]
        if backend == "local":
            run("nvcc", *flags, f"-I{source / 'include'}", cwd=work)
        else:
            container = f"volta-cutlass-binary-{uuid.uuid4().hex[:10]}"
            run("docker", "create", "--name", container, "--workdir", "/work",
                IMAGE, "nvcc", *flags, "-I/work/include")
            try:
                run("docker", "cp", str(source / "include"), f"{container}:/work/include")
                run("docker", "cp", str(work / "kernel.cu"), f"{container}:/work/kernel.cu")
                run("docker", "start", "--attach", container)
                run("docker", "cp", f"{container}:/work/kernel.ptx", str(work / "kernel.ptx"))
            finally:
                run("docker", "rm", "--force", container)
        ptx = (work / "kernel.ptx").read_text()
        assert "mma.sync.aligned.m16n8k256.row.col.s32.b1.b1.s32.xor.popc" in ptx
        shared = int(re.search(r"cutlass_shared_bytes = (\d+);", ptx)[1])
        threads = int(re.search(r"cutlass_threads = (\d+);", ptx)[1])
        launch = json.loads((ROOT / "kernel.launch.json").read_text())
        assert shared == launch["dynamic_shared_bytes"]
        assert threads == launch["block"][0]
        (ROOT / "kernel.ptx").write_text(ptx)
        metadata = dict(
            repository="https://github.com/NVIDIA/cutlass", tag="v3.9.2", commit=COMMIT,
            cuda=re.search(r"Cuda compilation tools, (.+)", ptx)[1], target="sm_80",
            backend=backend, docker_image=IMAGE if backend == "docker" else None,
            flags=flags, M=256, N=256, K=256,
            threadblock_shape=[64, 256, 512], warp_shape=[64, 64, 512],
            instruction_shape=[16, 8, 256], stages=3,
            grid=launch["grid"], block=launch["block"], shared_bytes=shared,
            source_sha256=hashlib.sha256((ROOT / "kernel.cu").read_bytes()).hexdigest(),
            ptx_sha256=hashlib.sha256(ptx.encode()).hexdigest(),
        )
        (ROOT / "kernel.json").write_text(json.dumps(metadata, indent=2) + "\n")
        print(f"Compiled {len(ptx)} PTX bytes; {threads} threads, {shared} shared bytes")


if __name__ == "__main__":
    main()
