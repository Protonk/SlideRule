"""
zoo_split_sequences.sage — Compute split sequences for all partition kinds.

Launches one subprocess per partition kind (via zoo_worker.sage), up to
MAX_WORKERS at a time. Each worker computes sign sequences at each depth
via compute_signs (with caching) and writes a small JSON result file.
This script gathers the results and writes a summary CSV.

Run:  ./sagew experiments/alternation/refinement/zoo_split_sequences.sage
"""

import csv
import json
import os
import subprocess
import sys
import time

from helpers import pathing
load(pathing('lib', 'partitions.sage'))


# ── Configuration ────────────────────────────────────────────────────

Q = 3
P_NUM = 1
Q_DEN = 2
LAYER_DEPENDENT = False
MIN_DEPTH = 3
MAX_DEPTH = 7
TOL = 1e-10
DYADIC_BITS = 20
MAX_WORKERS = 4

RESULTS_DIR = pathing('experiments', 'alternation', 'refinement', 'results')
CSV_PATH = os.path.join(RESULTS_DIR, 'zoo_split_sequences.csv')
WORKER_SCRIPT = pathing('experiments', 'alternation', 'refinement',
                         'zoo_worker.sage')
SAGEW = pathing('sagew')


# ── Launch ───────────────────────────────────────────────────────────

ld_tag = 'LD' if LAYER_DEPENDENT else 'LI'
ld_str = str(LAYER_DEPENDENT)
n_digits = MAX_DEPTH - MIN_DEPTH

print()
print("Zoo split sequences: q=%d, exponent=%d/%d, %s"
      % (Q, P_NUM, Q_DEN, ld_tag))
print("  Depths %d to %d (%d digits)" % (MIN_DEPTH, MAX_DEPTH, n_digits))
print("  %d partition kinds, %d workers" % (len(PARTITION_ZOO), MAX_WORKERS))
print()
sys.stdout.flush()

os.makedirs(RESULTS_DIR, exist_ok=True)

# Build work items: (name, color, kind, result_path)
work = []
for name, color, kind in PARTITION_ZOO:
    result_path = os.path.join(RESULTS_DIR, 'worker_%s.json' % kind)
    work.append((name, color, kind, result_path))

# Launch workers in batches of MAX_WORKERS
t_total = time.time()
active = {}   # kind -> (Popen, name, result_path)
finished = [] # (name, kind, result_dict)
work_idx = 0

while work_idx < len(work) or active:
    # Fill up to MAX_WORKERS
    while work_idx < len(work) and len(active) < MAX_WORKERS:
        name, color, kind, result_path = work[work_idx]
        cmd = [
            SAGEW, WORKER_SCRIPT,
            kind, str(Q), str(P_NUM), str(Q_DEN), ld_str,
            str(MIN_DEPTH), str(MAX_DEPTH), str(TOL), str(DYADIC_BITS),
            result_path,
        ]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)
        active[kind] = (proc, name, result_path)
        work_idx += 1

    # Poll for completions
    done_kinds = []
    for kind, (proc, name, result_path) in active.items():
        ret = proc.poll()
        if ret is not None:
            stdout = proc.stdout.read().decode('utf-8', errors='replace').strip()
            if stdout:
                print(stdout)
                sys.stdout.flush()

            if ret != 0:
                print("  ERROR: %s exited with code %d" % (kind, ret))
                sys.stdout.flush()
                finished.append((name, kind, None))
            elif os.path.exists(result_path):
                with open(result_path, 'r') as f:
                    result = json.load(f)
                finished.append((name, kind, result))
            else:
                print("  ERROR: %s produced no result file" % kind)
                sys.stdout.flush()
                finished.append((name, kind, None))

            done_kinds.append(kind)

    for k in done_kinds:
        del active[k]

    # Brief sleep to avoid busy-waiting
    if active and not done_kinds:
        time.sleep(float(0.5))

elapsed_total = time.time() - t_total

# Clean up worker result files
for _, _, _, result_path in work:
    if os.path.exists(result_path):
        os.remove(result_path)


# ── Gather and write CSV ─────────────────────────────────────────────

# Sort by zoo order
zoo_order = {kind: i for i, (_, _, kind) in enumerate(PARTITION_ZOO)}
finished.sort(key=lambda x: zoo_order.get(x[1], 999))

csv_rows = []
for name, kind, result in finished:
    if result is None:
        continue
    seq = result.get('sequence', '1.')
    split_counts = result.get('split_counts', [])
    csv_rows.append({
        'kind': kind,
        'display_name': name,
        'q': int(Q),
        'p_num': int(P_NUM),
        'q_den': int(Q_DEN),
        'layer_dependent': bool(LAYER_DEPENDENT),
        'min_depth': int(MIN_DEPTH),
        'max_depth': int(MAX_DEPTH),
        'tol': float(TOL),
        'dyadic_bits': int(DYADIC_BITS),
        'n_digits': int(n_digits),
        'split_counts': str(split_counts),
        'sequence': seq,
        'runs_at_max_depth': result.get('runs_at_max_depth', 0),
        'elapsed': result.get('elapsed', 0),
    })

if csv_rows:
    columns = list(csv_rows[0].keys())
    with open(CSV_PATH, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns)
        writer.writeheader()
        writer.writerows(csv_rows)
    print()
    print("Saved: %s" % CSV_PATH)

# Summary table
print()
print("=" * 70)
print("  %-22s  %12s  %8s  %s" % ('kind', 'sequence', 'time', 'runs'))
print("  " + "-" * 66)
for row in csv_rows:
    print("  %-22s  %12s  %7.1fs  %d" %
          (row['display_name'], row['sequence'],
           row['elapsed'], row['runs_at_max_depth']))
print("  " + "-" * 66)
cpu_total = sum(r['elapsed'] for r in csv_rows)
print("  CPU total: %.1fs   Wall clock: %.1fs   Parallelism: %.1fx" %
      (cpu_total, elapsed_total, cpu_total / elapsed_total if elapsed_total > 0 else 0))
print("=" * 70)
