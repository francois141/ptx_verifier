#!/bin/sh
# Compile cases in the Triton 3.9 container: run.sh [--global] CASE...
# Mounts the Aiter checkout read-only at /work/aiter and this directory at /work/review.
R=/Users/francoiscost/Desktop/volta/target/aiter/review/triton
A=/Users/francoiscost/Desktop/volta/target/aiter/aiter
exec docker run --rm -e PYTHONDONTWRITEBYTECODE=1 -e TRITON_CACHE_DIR=/tmp/triton-cache -e CASES="${CASES:-cases}" \
  -v "$A":/work/aiter:ro -v "$R":/work/review -w /work/review \
  "${IMAGE:-volta-gluon:triton-3.9.0-torch-2.15.0}" python compile_case.py "$@"
