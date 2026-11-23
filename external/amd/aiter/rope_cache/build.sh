#!/bin/sh
# Usage: build.sh file.hip -> file.s (probe recipe flags; module_rope_* modules add no extra flags)
A=/Users/francoiscost/Desktop/volta/target/aiter/aiter
H=/Users/francoiscost/Desktop/volta/target/aiter/hip-7.0.2
src=$1; out=${src%.hip}.s
/opt/homebrew/opt/llvm@21/bin/clang++ -x hip -std=c++20 -w --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
    --hip-path=$H -DNDEBUG -O3 -g0 -fno-verbose-asm -fgpu-flush-denormals-to-zero -D__HIP_PLATFORM_AMD__=1 -DENABLE_CK=1 \
    -DUSE_ROCM=1 -D__HIP_PLATFORM_HCC__=1 -U__HIP_NO_HALF_CONVERSIONS__ -U__HIP_NO_HALF_OPERATORS__ -DENABLE_ROPE_POSITIONS_INT32=0 \
    -mllvm --amdgpu-kernarg-preload-count=32 -mllvm --lsr-drop-solution=1 -fno-offload-uniform-block -mllvm -enable-post-misched=0 \
    -mllvm -amdgpu-early-inline-all=true -mllvm -amdgpu-function-calls=false $EXTRA \
    -I/Users/francoiscost/Desktop/volta/target/aiter/probe -I$A/csrc/include -I$A/csrc/kernels -I$A/3rdparty/composable_kernel/include -S $src -o $out
