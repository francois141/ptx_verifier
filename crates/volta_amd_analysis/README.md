# volta_amd_analysis

Experimental AMD frontend. This is not a supported verifier backend; the
notes below are for development.

The module layout parallels `volta_ptx_analysis`: parsing (`frontend`), lowering
(`lower`, `ir`), and symbolic execution (`eval`). The frontend is public; the
other stages are private.

`frontend::parse::parse_kernel(source, name)` extracts a kernel's target,
instructions, and numeric launch settings from Clang assembly. Instructions
keep their opcode names and represent operands as `ast::Operand`: registers or
ranges (`v0`, `s[0:3]`), unsigned decimal or hex literals, and wait counters
(`vmcnt(0)`, `lgkmcnt(0)`). Other operand forms are rejected; opcode validity
and instruction-specific operand constraints are not checked.

The parser strips `;` comments and accepts straight-line bodies. Unsupported
body labels or directives and incomplete descriptors produce string errors.

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
