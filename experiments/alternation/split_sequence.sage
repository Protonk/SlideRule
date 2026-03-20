"""
split_sequence.sage — Compute the refinement split count sequence for one
partition kind across increasing depth.

Prints the number of parent cells where children disagree in sign at each
depth transition d -> d+1.

Run:  ./sagew experiments/alternation/split_sequence.sage
"""

import time

from helpers import pathing
load(pathing('experiments', 'lodestone', 'lodestone_runner.sage'))
load(pathing('experiments', 'alternation', 'sign_sequences.sage'))


# ── Configuration ────────────────────────────────────────────────────

KIND = 'uniform_x'
Q = 3
P_NUM = 1
Q_DEN = 2
LAYER_DEPENDENT = False
MIN_DEPTH = 3
MAX_DEPTH = 13   # need depths 3..13 for 10 transitions


# ── Compute ──────────────────────────────────────────────────────────

def signs_from_case(case):
    """Extract sign list from a compute_case result."""
    percell_rows = build_percell_rows(case, 'split_seq')
    entries = []
    for r in percell_rows:
        fc = r['free_cell_intercept']
        if fc == '':
            continue
        delta = float(r['path_intercept']) - float(fc)
        if delta > EPS_SIGN:
            s = 1
        elif delta < -EPS_SIGN:
            s = -1
        else:
            s = 0
        entries.append((float(r['x_lo']), float(r['x_hi']),
                        float(r['x_mid']), s))
    entries.sort()
    return [e[3] for e in entries]


# ── Main ─────────────────────────────────────────────────────────────

import sys

ld_tag = 'LD' if LAYER_DEPENDENT else 'LI'
print()
print("Split sequence: %s, q=%d, exponent=%d/%d, %s"
      % (KIND, Q, P_NUM, Q_DEN, ld_tag))
print("  Depths %d to %d (%d transitions)"
      % (MIN_DEPTH, MAX_DEPTH, MAX_DEPTH - MIN_DEPTH))
print()
sys.stdout.flush()

sign_cache = {}  # depth -> sign list
split_counts = []

t_total = time.time()

for d in range(MIN_DEPTH, MAX_DEPTH + 1):
    t0 = time.time()
    case = compute_case(Q, d, P_NUM, Q_DEN,
                        partition_kind=KIND,
                        layer_dependent=LAYER_DEPENDENT)
    signs = signs_from_case(case)
    sign_cache[d] = signs
    elapsed = time.time() - t0

    rle = sign_rle(signs)
    print("  d=%2d  N=%5d  %2d runs  %.1fs" % (d, 2**d, len(rle), elapsed))

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
