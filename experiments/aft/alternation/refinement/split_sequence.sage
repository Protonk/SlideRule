"""
split_sequence.sage — Compute the refinement split count sequence for one
partition kind across increasing depth.

Prints the number of parent cells where children disagree in sign at each
depth transition d -> d+1. Uses compute_signs for efficient computation
with disk caching.

Run:  ./sagew experiments/aft/alternation/refinement/split_sequence.sage
"""

import sys
import time

from helpers import pathing
load(pathing('experiments', 'aft', 'alternation', 'refinement', 'compute_signs.sage'))


# ── Configuration ────────────────────────────────────────────────────

KIND = 'uniform_x'
Q = 3
P_NUM = 1
Q_DEN = 2
LAYER_DEPENDENT = False
MIN_DEPTH = 3
MAX_DEPTH = 13   # need depths 3..13 for 10 transitions
TOL = 1e-10
DYADIC_BITS = 20
USE_CACHE = True


# ── Main ─────────────────────────────────────────────────────────────

ld_tag = 'LD' if LAYER_DEPENDENT else 'LI'
print()
print("Split sequence: %s, q=%d, exponent=%d/%d, %s"
      % (KIND, Q, P_NUM, Q_DEN, ld_tag))
print("  Depths %d to %d (%d transitions)"
      % (MIN_DEPTH, MAX_DEPTH, MAX_DEPTH - MIN_DEPTH))
if USE_CACHE:
    print("  Cache: enabled (tol=%.0e, dyadic_bits=%d)" % (TOL, DYADIC_BITS))
print()
sys.stdout.flush()

sign_cache = {}  # depth -> sign list
split_counts = []

t_total = time.time()

for d in range(MIN_DEPTH, MAX_DEPTH + 1):
    result = compute_signs(Q, d, P_NUM, Q_DEN, kind=KIND,
                           layer_dependent=LAYER_DEPENDENT,
                           tol=TOL, dyadic_bits=DYADIC_BITS,
                           use_cache=USE_CACHE)
    signs = result['signs']
    sign_cache[d] = signs

    tag = '(cached)' if result['cached'] else '%.1fs' % result['elapsed']
    print("  d=%2d  N=%5d  %2d runs  %s" % (d, 2**d, result['n_runs'], tag))

    if d > MIN_DEPTH:
        prev_signs = sign_cache[d - 1]
        n_splits = len(refinement_splits(prev_signs, signs))
        split_counts.append(n_splits)

        seq_str = ''.join(str(c) for c in split_counts)
        print("         split counts so far: [%s]" % ', '.join(str(c) for c in split_counts))
        print("         1.%s" % seq_str)

    sys.stdout.flush()

    # Free memory for depths we no longer need
    if d - 2 >= MIN_DEPTH and d - 2 in sign_cache:
        del sign_cache[d - 2]

print()
print("=" * 60)
seq_str = ''.join(str(c) for c in split_counts)
print("Final: 1.%s" % seq_str)
print("  Split counts: %s" % split_counts)
print("  Total time: %.1fs" % (time.time() - t_total))
print("=" * 60)
