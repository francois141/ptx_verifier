# volta_cli

The `volta` binary (`src/main.rs`). It parses command-line flags into an
`AnalysisConfig`, drives `volta_pipeline`, and prints results with exit codes.
It holds no verification logic of its own.

| command | does | exit |
|---------|------|------|
| `volta parse <file>` | syntax check | 0 / 1 |
| `volta analyze <file> -k K ...` | analysis + the ten graph checks: prints the symbolic outputs, a per-instruction-kind profile (`--no-profile`), each check's verdict, any deadlock and the first failure; `GRAPH VERIFICATION: VERIFIED \| REJECTED \| UNKNOWN` | 0 / 1 / 2 |
| `volta compare <ref> <opt> --kernel1 .. --kernel2 .. --check-array A` | both kernels through both branches, then `decide`: `VERDICT: ACCEPT \| REJECT \| UNKNOWN` | 0 / 1 / 2 |
| `volta verify <file> <spec> -k K --dim N=..` | one kernel against a `.spec` (file or inline string), through both branches and `decide` | 0 / 1 / 2 |
| `volta viz <store> -o page.html` | the `volta_viz` page over a run store | |

## Flow of a command

```
clap args ──► LaunchArgs (shared, flattened) ──► AnalysisConfig
                                                      │
       analyze: volta_pipeline::verify_kernel ────────┤
       compare: verify_kernel x2 + check_equivalence ─┤──► decide ──► print + exit code
       verify:  verify_kernel + volta_spec unfold ────┘
                + check_equivalence
```

- **Launch flags** (shared by `analyze`/`compare`/`verify` via the flattened
  `LaunchArgs`): `-b/--block`, `-g/--grid`,
  `--array name:base:elem_width:len:in|out|inout|index`,
  `--param int:N|float:X|sym:name|ptr:array` (in declaration order), globals,
  dynamic shared size. `compare` adds `--block2/--grid2` for the optimized
  kernel.
- **Equivalence flags**: `--sample N`, `--verify-numeric`,
  `--recycle-terms N`, `--iterations N`.
- **Artifacts**: `analyze --emit-exprs FILE` (`.vexpr`) and `--dump-graph FILE`
  (`volta-graph 1`). `compare --exprs a.vexpr b.vexpr` or
  `--dump-vcs`/`--from-dump` skip symbolic execution and run the equivalence
  branch only.
- **Logs**: every run writes a `volta_common::run_log` file (`--log-dir`,
  `--no-log-file`). Build with `--features logging` and pass
  `--log-level info` to narrate the stages.

```sh
cargo run --release -p volta_cli -- analyze relu.ptx -k relu -b 128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out
```

See the top-level `README.md` for the full flag reference.
