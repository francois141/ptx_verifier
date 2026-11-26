# PTX frameworks

Volta's checks of the PTX frameworks' kernels (`sources/frameworks.txt` pins each one).

- `extraction/`: fetch the sources (`just ptx-sources`), compile them to sm_100a PTX in Docker
  (`survey.py`) and extract the Python-DSL frameworks' PTX.
- `<framework>/cases.py`: each framework's cases (launch, spec, expected verdict);
  `verify.py` runs them (`python3 external/ptx/verify.py vllm -k rms_norm`) and writes
  `output/ptx_table.md`.
- `memcap.py`: runs a command, killing its whole process tree past a resident-memory cap
  (macOS enforces no memory rlimit, and a runaway Volta run can exhaust the machine). Every
  `verify.py` run goes through it (`--mem-gb`, default 6; a killed case's verdict is MEMORY),
  with `--jobs` lowered so that jobs x cap stays within half of physical memory. Run ad-hoc
  Volta or `cargo test` commands under it too:
  `python3 external/ptx/memcap.py --gb 6 -- target/release/volta solve ...`.
