# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Fetch the PTX frameworks of `external/ptx/sources/frameworks.txt`, each at its commit.

    uv run external/ptx/extraction/fetch_sources.py                     # every framework
    uv run external/ptx/extraction/fetch_sources.py vllm flashinfer     # some of them
    uv run external/ptx/extraction/fetch_sources.py --no-submodules

Each framework is a shallow clone of its one commit in `target/ptx-sources/<name>`, its
submodules (CUTLASS, mostly) shallow too, at the commits it records; Git LFS files stay
pointers. A checkout already at its commit is kept, any other is replaced. The extraction
scripts compile from these checkouts, so a fresh repository rebuilds every kernel from them.
"""

import argparse
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

EXTERNAL_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = EXTERNAL_ROOT.parent.parent
MANIFEST = EXTERNAL_ROOT / "sources" / "frameworks.txt"
SOURCES_DIR = REPO_ROOT / "target" / "ptx-sources"


@dataclass(frozen=True)
class Framework:
    name: str
    url: str
    commit: str


def read_manifest() -> list[Framework]:
    frameworks = []
    for line in MANIFEST.read_text().splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        name, url, commit, *_ = line.split()
        frameworks.append(Framework(name, url, commit))
    return frameworks


def git(*args: str, cwd: Path) -> str:
    env = {**os.environ, "GIT_LFS_SKIP_SMUDGE": "1", "GIT_TERMINAL_PROMPT": "0"}
    result = subprocess.run(["git", *args], cwd=cwd, env=env, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} in {cwd}:\n{result.stderr.strip()}")
    return result.stdout.strip()


def head(checkout: Path) -> str | None:
    try:
        return git("rev-parse", "HEAD", cwd=checkout)
    except (RuntimeError, FileNotFoundError):
        return None


def fetch(framework: Framework, submodules: bool) -> str:
    checkout = SOURCES_DIR / framework.name
    if head(checkout) == framework.commit:
        return "kept"
    shutil.rmtree(checkout, ignore_errors=True)
    checkout.mkdir(parents=True)
    git("init", "-q", cwd=checkout)
    git("fetch", "-q", "--depth", "1", framework.url, framework.commit, cwd=checkout)
    git("-c", "advice.detachedHead=false", "checkout", "-q", "FETCH_HEAD", cwd=checkout)
    if submodules:
        git("submodule", "update", "-q", "--init", "--recursive", "--depth", "1", cwd=checkout)
    return "fetched"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="frameworks to fetch (default: every one)")
    parser.add_argument("--no-submodules", action="store_true", help="skip the frameworks' submodules")
    args = parser.parse_args()

    frameworks = read_manifest()
    known = {f.name for f in frameworks}
    if unknown := [n for n in args.names if n not in known]:
        sys.exit(f"unknown frameworks {unknown}: pick among {sorted(known)}")
    failed = False
    for framework in frameworks:
        if args.names and framework.name not in args.names:
            continue
        try:
            print(f"{framework.name}: {fetch(framework, not args.no_submodules)} {framework.commit[:12]}", flush=True)
        except RuntimeError as error:
            failed = True
            print(f"{framework.name}: FAILED\n{error}", file=sys.stderr, flush=True)
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
