"""
exponent_robustness_sweep.sage — Non-1/2 exponent robustness check.

Tests whether the wall decomposition survives at exponents 1/3 and 2/3.
This is a robustness check, not a scaling pass.

Run:  ./sagew experiments/wall/exponent_robustness_sweep.sage
"""

import os
import sys
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


# ── Main ─────────────────────────────────────────────────────────────

run_dir = pathing('experiments', 'wall', 'results', RUN_TAG)
if not os.path.exists(run_dir):
    os.makedirs(run_dir)

cases = [(q, d, p, qd, kind, ld)
         for p, qd in EXPONENTS
         for q, d in GRID
         for ld in LAYER_MODES
         for kind in KINDS]

total = len(cases)
print()
print("=" * 80)
print("Exponent robustness sweep: %d cases" % total)
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

summary_rows = []
percell_rows = []

for idx, (q, depth, p_num, q_den, kind, ld) in enumerate(cases):
    case = compute_case(q, depth, p_num, q_den, partition_kind=kind,
                        layer_dependent=ld)
    summary_rows.append(build_summary_row(case, RUN_TAG))
    percell_rows.extend(build_percell_rows(case, RUN_TAG))

    ld_tag = "Y" if ld else "N"
    print("  %3d  %18s  %3s  %d/%d  %3d  %2d  %10.6f  %10.6f  %10.6f  %5.1fs"
          % (idx + 1, kind, ld_tag, p_num, q_den, q, depth,
             case['opt_err'], case['free_err'], case['gap'], case['elapsed']))
    sys.stdout.flush()

print()
write_csv(summary_rows, os.path.join(run_dir, 'summary.csv'), SUMMARY_COLUMNS)
write_csv(percell_rows, os.path.join(run_dir, 'percell.csv'), PERCELL_COLUMNS)

print()
print("=" * 80)
print("Sweep complete: %d summary rows, %d per-cell rows" %
      (len(summary_rows), len(percell_rows)))
print("=" * 80)
