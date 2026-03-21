"""
exponent_robustness_sweep.sage — Non-1/2 exponent robustness check.

Tests whether the wall decomposition survives at exponents 1/3 and 2/3.
This is a robustness check, not a scaling pass.

Improvements over the original version:
- Incremental CSV writes: each case is appended immediately, so an
  interruption loses only the in-progress case, not the entire run.
- Resume support: a completion log tracks finished case keys; re-running
  the script skips them automatically.
- Memory: the full case dict is discarded after row extraction.

Run:  ./sagew experiments/wall/exponent_robustness_sweep.sage
"""

import os
import sys
import csv
import gc
import time

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))


# ── Configuration ────────────────────────────────────────────────────

KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
GRID = [(3, 4), (3, 5), (3, 6), (3, 7), (3, 8),
        (5, 4), (5, 5), (5, 6), (5, 7), (5, 8)]
EXPONENTS = [(1, 3), (2, 3)]  # 1/2 already in seed data
LAYER_MODES = [False, True]
RUN_TAG = 'exponent_robustness_2026-03-20'


# ── Helpers ──────────────────────────────────────────────────────────

def case_key(kind, q, depth, p_num, q_den, ld):
    """Stable string key for one case, used in the completion log."""
    return f"{kind}|{q}|{depth}|{p_num}/{q_den}|{'LD' if ld else 'LI'}"


def load_completed(log_path):
    """Load the set of already-completed case keys from the log."""
    done = set()
    if os.path.exists(log_path):
        with open(log_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    done.add(line)
    return done


def append_csv_rows(filepath, columns, rows):
    """Append rows to a CSV, writing the header if the file is new/empty."""
    write_header = not os.path.exists(filepath) or os.path.getsize(filepath) == 0
    with open(filepath, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns, extrasaction='ignore')
        if write_header:
            writer.writeheader()
        for r in rows:
            writer.writerow(r)


# ── Main ─────────────────────────────────────────────────────────────

run_dir = pathing('experiments', 'wall', 'results', RUN_TAG)
if not os.path.exists(run_dir):
    os.makedirs(run_dir)

summary_path = os.path.join(run_dir, 'summary.csv')
percell_path = os.path.join(run_dir, 'percell.csv')
done_log = os.path.join(run_dir, 'completed.log')

cases = [(q, d, p, qd, kind, ld)
         for p, qd in EXPONENTS
         for q, d in GRID
         for ld in LAYER_MODES
         for kind in KINDS]

completed = load_completed(done_log)

total = len(cases)
already_done = sum(1 for q, d, p, qd, kind, ld in cases
                   if case_key(kind, q, d, p, qd, ld) in completed)

print()
print("=" * 80)
print("Exponent robustness sweep: %d cases (%d already done, %d remaining)"
      % (total, already_done, total - already_done))
print("  kinds: %s" % KINDS)
print("  grid: %s" % GRID)
print("  exponents: %s" % EXPONENTS)
print("  layer modes: %s" % LAYER_MODES)
print("  output: %s" % run_dir)
print("=" * 80)
print()

print("  %3s  %18s  %3s  %5s  %3s  %2s  %10s  %10s  %10s  %6s" %
      ('#', 'kind', 'LD', 'exp', 'q', 'd', 'opt_err', 'free_err', 'gap', 'time'))
print("  " + "-" * 92)
sys.stdout.flush()

n_done = already_done
for idx, (q, depth, p_num, q_den, kind, ld) in enumerate(cases):
    key = case_key(kind, q, depth, p_num, q_den, ld)
    if key in completed:
        continue

    case = compute_case(q, depth, p_num, q_den, partition_kind=kind,
                        layer_dependent=ld)

    # Extract CSV rows immediately
    s_row = build_summary_row(case, RUN_TAG)
    p_rows = build_percell_rows(case, RUN_TAG)

    # Capture values for the log line before discarding case
    opt_err = case['opt_err']
    free_err = case['free_err']
    gap = case['gap']
    elapsed = case['elapsed']

    # Release the heavy case dict
    del case
    gc.collect()

    # Flush rows to disk
    append_csv_rows(summary_path, SUMMARY_COLUMNS, [s_row])
    append_csv_rows(percell_path, PERCELL_COLUMNS, p_rows)

    # Mark this case as done
    with open(done_log, 'a') as f:
        f.write(key + '\n')

    n_done += 1
    ld_tag = "Y" if ld else "N"
    print("  %3d  %18s  %3s  %d/%d  %3d  %2d  %10.6f  %10.6f  %10.6f  %5.1fs"
          % (n_done, kind, ld_tag, p_num, q_den, q, depth,
             opt_err, free_err, gap, elapsed))
    sys.stdout.flush()

print()
print("=" * 80)
print("Sweep complete: %d / %d cases done" % (n_done, total))
print("  summary: %s" % summary_path)
print("  percell: %s" % percell_path)
print("=" * 80)
