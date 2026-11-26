"""Run a command, killing its whole process tree once the tree's resident memory passes a cap.

    python3 external/ptx/memcap.py --gb 6 -- target/release/volta solve ...
    python3 external/ptx/memcap.py --gb 12 --timeout 1800 -- cargo test --release ...

macOS enforces no address-space or RSS rlimit, so a runaway Volta run (symbolic expressions
growing without bound) can exhaust the machine. This polls the tree's summed RSS every 0.2 s
and SIGKILLs it past `--gb`, exiting 137 with a `memcap:` line on stderr; `--timeout` likewise
exits 124. Otherwise the command's own exit status is returned.
"""

import argparse
import os
import signal
import subprocess
import sys
import time

KILLED_FOR_MEMORY = 137
KILLED_FOR_TIME = 124


def tree_rss_bytes(root: int) -> int:
    """The summed RSS of `root` and all its descendants."""
    table = subprocess.run(["ps", "-A", "-o", "pid=,ppid=,rss="], capture_output=True,
                           text=True).stdout
    children: dict[int, list[int]] = {}
    rss: dict[int, int] = {}
    for line in table.splitlines():
        parts = line.split()
        if len(parts) != 3:
            continue
        pid, ppid, kb = map(int, parts)
        children.setdefault(ppid, []).append(pid)
        rss[pid] = kb * 1024
    total, stack = 0, [root]
    while stack:
        pid = stack.pop()
        total += rss.get(pid, 0)
        stack.extend(children.get(pid, ()))
    return total


def kill_tree(process: subprocess.Popen) -> None:
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    process.wait()


def run(command: list[str], gb: float, timeout: float | None, **popen) -> tuple[int, str]:
    """Run `command` under the cap; its exit status and a note when memcap killed it."""
    limit = int(gb * 2**30)
    start = time.time()
    process = subprocess.Popen(command, start_new_session=True, **popen)
    peak = 0
    while process.poll() is None:
        used = tree_rss_bytes(process.pid)
        peak = max(peak, used)
        if used > limit:
            kill_tree(process)
            return KILLED_FOR_MEMORY, f"memcap: killed at {used / 2**30:.1f} GB (cap {gb} GB)"
        if timeout is not None and time.time() - start > timeout:
            kill_tree(process)
            return KILLED_FOR_TIME, f"memcap: killed after {timeout:.0f} s"
        time.sleep(0.2)
    return process.returncode, ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--gb", type=float, default=6.0, help="resident memory cap (GiB)")
    parser.add_argument("--timeout", type=float, help="wall-clock cap (seconds)")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command:
        parser.error("no command given")
    status, note = run(command, args.gb, args.timeout)
    if note:
        print(note, file=sys.stderr)
    return status


if __name__ == "__main__":
    sys.exit(main())
