# volta_amd_analysis

AMD assembly analysis, parallel to `volta_ptx_analysis`.

The directories mirror the existing PTX analysis stages:

- `src/frontend/`: assembly lexing and parsing.
- `src/ir/`: the instruction representation used by execution.
- `src/lower/`: conversion from parsed instructions to that representation.
- `src/eval/`: symbolic execution.

The frontend is public; the other stages are private.
