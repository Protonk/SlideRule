"""
zoo_worker.sage — Compute split sequence for a single partition kind.

Called by zoo_split_sequences.sage as a subprocess. Writes a small JSON
result file on completion. All heavy results are also written to the
compute_signs cache.

Usage:  ./sagew experiments/aft/alternation/refinement/zoo_worker.sage \
            <kind> <q> <p_num> <q_den> <layer_dependent> \
            <min_depth> <max_depth> <tol> <dyadic_bits> <result_path>
"""

import json
import sys
import time

from helpers import pathing
load(pathing('experiments', 'aft', 'alternation', 'refinement', 'compute_signs.sage'))


args = sys.argv[1:]
if len(args) != 10:
    print("Usage: zoo_worker.sage <kind> <q> <p_num> <q_den> <layer_dependent>"
          " <min_depth> <max_depth> <tol> <dyadic_bits> <result_path>",
          file=sys.stderr)
    sys.exit(1)

kind = args[0]
q = int(args[1])
p_num = int(args[2])
q_den = int(args[3])
layer_dependent = args[4].lower() in ('true', '1', 'yes')
min_depth = int(args[5])
max_depth = int(args[6])
tol = float(args[7])
dyadic_bits = int(args[8])
result_path = args[9]

t0 = time.time()

prev_signs = None
split_counts = []
last_n_runs = 0

for d in range(min_depth, max_depth + 1):
    result = compute_signs(q, d, p_num, q_den, kind=kind,
                           layer_dependent=layer_dependent,
                           tol=tol, dyadic_bits=dyadic_bits,
                           use_cache=True)
    signs = result['signs']

    if d == max_depth:
        last_n_runs = result['n_runs']

    if prev_signs is not None:
        n_splits = len(refinement_splits(prev_signs, signs))
        split_counts.append(n_splits)

    prev_signs = signs

elapsed = time.time() - t0
seq_str = ''.join(str(c) for c in split_counts)

out = {
    'kind': kind,
    'split_counts': split_counts,
    'sequence': '1.' + seq_str,
    'runs_at_max_depth': last_n_runs,
    'elapsed': elapsed,
}

import os
os.makedirs(os.path.dirname(result_path), exist_ok=True)
with open(result_path, 'w') as f:
    json.dump(out, f)

print("  %-22s  %s  %.1fs  %d runs" %
      (kind, '1.' + seq_str, elapsed, last_n_runs))
