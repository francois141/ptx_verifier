# volta_amd_analysis

AMD assembly analysis, parallel to `volta_ptx_analysis`: parsing (`frontend`),
lowering (`lower`, `ir`), and symbolic execution (`eval`). The frontend is
public; the other stages are private.

`frontend::parse::parse_kernel(source, name)` extracts one kernel from assembly
produced by Clang: its `.amdgcn_target` string, its instructions as opcode and
operand text, and the numeric `.amdhsa_*` settings of its kernel descriptor.
`;` comments are stripped. The body must be straight-line instructions; a label
or directive inside it is an error, as is a descriptor without its
`.end_amdhsa_kernel`. Errors are plain strings.

`tests/fixtures/copy.cl` is `out[i] = in[i]`, one element per workitem, and
`copy.s` is the assembly Homebrew clang 21.1.8 produced for it for gfx950
(MI355X). Apple's clang lacks the AMDGPU target; use LLVM's clang (Homebrew
`llvm@21` on macOS). Regenerate it from `tests/fixtures/` with:

```sh
clang -x cl -cl-std=CL1.2 --target=amdgcn-amd-amdhsa -mcpu=gfx950 -nogpulib \
  -O2 -g0 -fno-verbose-asm -Xclang -target-feature -Xclang -xnack \
  -S copy.cl -o copy.s
```

The tests parse the checked-in `copy.s` and need no compiler or GPU:

```sh
cargo test -p volta_amd_analysis --lib
```
