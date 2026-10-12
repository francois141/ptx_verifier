//! Hand-written FFI over libz3's C API (no bindgen), each query run in a
//! re-invoked worker process the parent SIGKILLs on deadline, since z3's soft
//! timeout is advisory. Binaries must call [`init_worker`] first in `main`.

use std::ffi::{CStr, CString, c_char, c_int, c_uint, c_void};
use std::io::{Read, Write};
use std::process::{Command, Stdio};
use std::time::{Duration, Instant};

type Z3Config = *mut c_void;
type Z3Context = *mut c_void;

#[link(name = "z3")]
unsafe extern "C" {
    fn Z3_mk_config() -> Z3Config;
    fn Z3_del_config(cfg: Z3Config);
    fn Z3_mk_context(cfg: Z3Config) -> Z3Context;
    fn Z3_del_context(ctx: Z3Context);
    fn Z3_set_error_handler(
        ctx: Z3Context,
        handler: Option<unsafe extern "C" fn(Z3Context, c_int)>,
    );
    fn Z3_eval_smtlib2_string(ctx: Z3Context, s: *const c_char) -> *const c_char;
    fn Z3_global_param_set(param_id: *const c_char, param_value: *const c_char);
    fn Z3_get_version(major: *mut c_uint, minor: *mut c_uint, build: *mut c_uint, rev: *mut c_uint);
}

/// z3's default error handler aborts the process; errors must instead
/// surface as `(error ...)` lines in the eval output.
unsafe extern "C" fn ignore_errors(_ctx: Z3Context, _code: c_int) {}

/// The linked z3 library version, e.g. "4.8.12".
pub fn z3_version() -> String {
    let (mut major, mut minor, mut build, mut rev) = (0, 0, 0, 0);
    unsafe { Z3_get_version(&mut major, &mut minor, &mut build, &mut rev) };
    format!("{}.{}.{}", major, minor, build)
}

const WORKER_ENV: &str = "VOLTA_Z3_WORKER";
const TIMEOUT_ENV: &str = "VOLTA_Z3_TIMEOUT_MS";
/// First line a worker writes; its absence means the spawned binary ran
/// its normal `main` instead - i.e. the host forgot `init_worker`.
const HANDSHAKE: &str = "volta-z3-worker-1";

/// If this process was spawned as a solver worker, run the query and exit;
/// otherwise return. Must be the FIRST statement of `main` in every binary
/// that evaluates queries through this crate (a missing hook fails loudly).
pub fn init_worker() {
    if std::env::var_os(WORKER_ENV).is_none() {
        return;
    }
    if let Ok(ms) = std::env::var(TIMEOUT_ENV) {
        let param = CString::new("timeout").unwrap();
        let value = CString::new(ms).expect("timeout env var contained NUL");
        unsafe { Z3_global_param_set(param.as_ptr(), value.as_ptr()) };
    }
    let mut query = String::new();
    if std::io::stdin().read_to_string(&mut query).is_err() {
        std::process::exit(2);
    }
    let (result, solve) = eval_in_process(&query);
    // Handshake only after stdin was fully consumed: the parent writes
    // the whole query before reading, so neither side blocks on a full
    // pipe while the other isn't draining it.
    let mut stdout = std::io::stdout();
    let ok = writeln!(stdout, "{}", HANDSHAKE)
        .and_then(|_| writeln!(stdout, "t:{}", solve.as_nanos()))
        .and_then(|_| stdout.write_all(result.as_bytes()))
        .and_then(|_| stdout.flush())
        .is_ok();
    std::process::exit(if ok { 0 } else { 2 });
}

/// In-process evaluation with a fresh context, inside the worker. The timed
/// span is libz3's evaluation of the query only: an empty warmup eval first
/// flushes z3's lazy frontend setup, which dwarfs small queries.
fn eval_in_process(query: &str) -> (String, Duration) {
    let c_query = match CString::new(query) {
        Ok(c) => c,
        Err(_) => {
            return (
                "(error \"query contained a NUL byte\")".to_string(),
                Duration::ZERO,
            );
        }
    };
    unsafe {
        let cfg = Z3_mk_config();
        let ctx = Z3_mk_context(cfg);
        Z3_set_error_handler(ctx, Some(ignore_errors));
        let warmup = CString::new("").expect("empty string contains no NUL");
        let _ = Z3_eval_smtlib2_string(ctx, warmup.as_ptr());
        let started = Instant::now();
        let out = Z3_eval_smtlib2_string(ctx, c_query.as_ptr());
        let solve = started.elapsed();
        let result = if out.is_null() {
            String::new()
        } else {
            CStr::from_ptr(out).to_string_lossy().into_owned()
        };
        Z3_del_context(ctx);
        Z3_del_config(cfg);
        (result, solve)
    }
}

/// One query's fate, as observed by the parent.
pub enum EvalOutcome {
    /// The worker finished: the solver's output plus the solve time measured
    /// inside the worker (see [`eval_in_process`]), excluding process and
    /// context setup; this is the number to report as solver time.
    Output { text: String, solve: Duration },
    /// The deadline expired and the worker was killed - the definitive
    /// timeout signal (z3's own soft timeout is unreliable, see module
    /// docs).
    HardTimeout,
    /// The worker died without completing the protocol (z3 crash, spawn
    /// failure, or a host binary missing `init_worker`); the payload
    /// describes how.
    ChildDied(String),
}

/// Evaluate one SMT-LIB2 script in a worker subprocess, enforcing `timeout`
/// (`None` = no limit) with SIGKILL; z3's soft timeout is also set, so the
/// output may report `canceled` first. Thread-safe (`std::process::Command`).
pub fn eval_smtlib2(query: &str, timeout: Option<Duration>) -> EvalOutcome {
    let exe = match std::env::current_exe() {
        Ok(p) => p,
        Err(e) => return EvalOutcome::ChildDied(format!("current_exe() failed: {}", e)),
    };
    let timeout_ms = match timeout {
        // Millisecond granularity, minimum 1ms; u32::MAX is z3's default
        // "effectively unlimited" value.
        Some(t) => (t.as_millis().min(u64::from(u32::MAX - 1) as u128) as u32).max(1),
        None => u32::MAX,
    };

    let mut child = match Command::new(exe)
        .env(WORKER_ENV, "1")
        .env(TIMEOUT_ENV, timeout_ms.to_string())
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
    {
        Ok(c) => c,
        Err(e) => return EvalOutcome::ChildDied(format!("failed to spawn worker: {}", e)),
    };

    // Write the query, then drop stdin so the worker sees EOF. The
    // worker does not write until it has read everything, so this cannot
    // deadlock on pipe capacity.
    if let Some(mut stdin) = child.stdin.take()
        && stdin.write_all(query.as_bytes()).is_err()
    {
        let _ = child.kill();
        let _ = child.wait();
        return EvalOutcome::ChildDied("failed to write query to worker".to_string());
    }

    // Read the worker's output on a helper thread so the parent can
    // enforce the hard deadline; on expiry the worker is killed and the
    // reader unblocks at EOF.
    let mut stdout = child.stdout.take().expect("stdout was piped");
    let (tx, rx) = std::sync::mpsc::channel();
    let reader = std::thread::spawn(move || {
        let mut out = String::new();
        let _ = stdout.read_to_string(&mut out);
        let _ = tx.send(out);
    });

    let deadline = timeout.map(|t| {
        // Grace on top of z3's soft timeout so a clean in-band `canceled`
        // result wins when the solver does honor cancellation.
        t + Duration::from_millis(500).max(t / 10)
    });
    let received = match deadline {
        None => rx.recv().ok(),
        Some(d) => match rx.recv_timeout(d) {
            Ok(out) => Some(out),
            Err(std::sync::mpsc::RecvTimeoutError::Timeout) => None,
            Err(std::sync::mpsc::RecvTimeoutError::Disconnected) => Some(String::new()),
        },
    };
    let outcome = match received {
        None => {
            let _ = child.kill();
            let _ = child.wait();
            EvalOutcome::HardTimeout
        }
        Some(text) => match child.wait() {
            Ok(status) if status.success() => match text.strip_prefix(HANDSHAKE) {
                Some(rest) => parse_worker_payload(rest),
                None => EvalOutcome::ChildDied(
                    "worker handshake missing - the host binary must call \
                     volta_z3::init_worker() as the first statement of main()"
                        .to_string(),
                ),
            },
            Ok(status) => EvalOutcome::ChildDied(format!("worker exited with {}", status)),
            Err(e) => EvalOutcome::ChildDied(format!("failed to reap worker: {}", e)),
        },
    };
    let _ = reader.join();
    outcome
}

/// Parse what follows a worker's handshake: the `t:<nanoseconds>` solve time,
/// then the solver's output. Parent and worker are the same binary, so a
/// malformed payload is a protocol violation (reported loudly).
fn parse_worker_payload(rest: &str) -> EvalOutcome {
    let payload = rest.strip_prefix('\n').unwrap_or(rest);
    let Some((nanos, output)) = payload
        .strip_prefix("t:")
        .and_then(|timed| timed.split_once('\n'))
    else {
        return EvalOutcome::ChildDied(
            "worker protocol error: missing solve-time line".to_string(),
        );
    };
    match nanos.trim().parse::<u64>() {
        Ok(ns) => EvalOutcome::Output {
            text: output.to_string(),
            solve: Duration::from_nanos(ns),
        },
        Err(_) => EvalOutcome::ChildDied(format!(
            "worker protocol error: unparseable solve-time line {:?}",
            nanos
        )),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Diagnostic (run alone with `--ignored --nocapture`, so libz3 is fresh):
    /// prints per-phase in-process timings for two rounds, showing context
    /// creation and the lazy frontend setup that the warmup eval flushes.
    #[test]
    #[ignore = "diagnostic: prints in-process phase timings"]
    fn in_process_phase_timings() {
        let query = CString::new("(assert false)(check-sat)\n").unwrap();
        for round in 0..2 {
            let t0 = Instant::now();
            let (cfg, ctx) = unsafe {
                let cfg = Z3_mk_config();
                let ctx = Z3_mk_context(cfg);
                Z3_set_error_handler(ctx, Some(ignore_errors));
                (cfg, ctx)
            };
            let t_ctx = t0.elapsed();
            // An empty first eval separates the per-context SMT-LIB
            // frontend setup from the per-script cost (this is the
            // warmup `eval_in_process` performs before its timed span).
            let empty = CString::new("").unwrap();
            let t1 = Instant::now();
            let _ = unsafe { Z3_eval_smtlib2_string(ctx, empty.as_ptr()) };
            let t_warmup = t1.elapsed();
            let t2 = Instant::now();
            let out = unsafe { Z3_eval_smtlib2_string(ctx, query.as_ptr()) };
            let t_eval = t2.elapsed();
            assert!(!out.is_null());
            let t3 = Instant::now();
            unsafe {
                Z3_del_context(ctx);
                Z3_del_config(cfg);
            }
            let t_del = t3.elapsed();
            println!(
                "round {}: ctx create {:?}, empty warmup eval {:?}, query eval {:?}, \
                 ctx destroy {:?}",
                round, t_ctx, t_warmup, t_eval, t_del
            );
        }
    }
}
