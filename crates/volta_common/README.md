# volta_common

Base utilities shared by Volta's crates. It depends on no other Volta crate.

- **`Span`** (`span.rs`): a source location, the byte offsets `start..end`.
- **`Locate<E>`** (`report.rs`): an error wrapper that adds an optional span and
  file path to an error kind `E`. Each crate defines an error kind enum and
  aliases `Locate<Kind>` as its error type. As an error travels up,
  `locate_span` and `locate_path` attach a span or path if none is set yet, so
  the innermost (most precise) location wins.
- **`FileCache`** (`file_cache.rs`): reads each file once and serves that copy
  afterwards, so error reports always quote the same version of the source the
  parser saw.
- **`report_error`** (`report.rs`): renders an error as a titled message with
  the source snippet at its span, colored with ANSI escapes and wrapped to the
  terminal.
- **`position`** (`report.rs`): where a byte offset falls, as a 1-based line
  and column (in characters) and that line's text. `report_error`'s
  `path:line:column` header and `volta_py`'s error messages both use it.
- **`logging`** (`logging.rs`): the `debug`, `info`, `trace` and `warn` macros
  the other crates log through. With the `logging` feature they are `log`'s
  own; without it, a stand-in compiles its arguments in a branch that never
  runs, so a value computed only for a log still counts as used. Each crate's
  own `logging` feature turns on this one.
- **`run_log::RunLog`** (`run_log.rs`): the per-invocation log file the
  `volta` binary writes (`<unix-seconds>-<pid>-<command>.log` under
  `--log-dir`, default `volta-logs/`). With the `logging` feature, `tee`
  mirrors an `env_logger` target into it.
