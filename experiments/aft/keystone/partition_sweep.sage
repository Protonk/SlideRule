"""
partition_sweep.sage — General-purpose partition comparison sweep.

Iterates the cartesian product of KINDS x GRID x EXPONENTS x LAYER_MODES,
runs compute_case for each, and writes summary + percell CSVs.

Run:  ./sagew experiments/aft/keystone/partition_sweep.sage
"""

import os
import sys

from helpers import pathing
load(pathing('experiments', 'aft', 'keystone', 'keystone_runner.sage'))


# ── Configuration ────────────────────────────────────────────────────

KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
GRID = [(3, 4), (5, 4), (5, 6), (3, 8)]
EXPONENTS = [(1, 2)]
LAYER_MODES = [False, True]
RUN_TAG = 'partition_2026-03-18'


# ── Main ─────────────────────────────────────────────────────────────

def main():
    run_dir = pathing('experiments', 'aft', 'keystone', 'results', RUN_TAG)
    if not os.path.exists(run_dir):
        os.makedirs(run_dir)

    summary_rows = []
    percell_rows = []

    cases = [(q, d, p, qd, kind, ld)
             for p, qd in EXPONENTS
             for q, d in GRID
             for ld in LAYER_MODES
             for kind in KINDS]

    total = len(cases)
    print("=" * 80)
    print(f"Partition sweep: {total} cases")
    print(f"  kinds: {KINDS}")
    print(f"  grid: {GRID}")
    print(f"  exponents: {EXPONENTS}")
    print(f"  layer modes: {LAYER_MODES}")
    print(f"  output: {run_dir}")
    print("=" * 80)
    print()

    print(f"  {'#':>3}  {'kind':>18}  {'LD':>3}  {'exp':>5}  {'q':>3}  {'d':>2}  "
          f"{'opt_err':>10}  {'free_err':>10}  {'gap':>10}  {'time':>6}")
    print("  " + "-" * 92)

    for idx, (q, depth, p_num, q_den, kind, ld) in enumerate(cases):
        case = compute_case(q, depth, p_num, q_den, partition_kind=kind,
                            layer_dependent=ld)
        summary_rows.append(build_summary_row(case, RUN_TAG))
        percell_rows.extend(build_percell_rows(case, RUN_TAG))

        ld_tag = "Y" if ld else "N"
        print(f"  {idx+1:>3}  {kind:>18}  {ld_tag:>3}  {p_num}/{q_den:>3}  "
              f"{q:>3}  {depth:>2}  "
              f"{case['opt_err']:>10.6f}  {case['free_err']:>10.6f}  "
              f"{case['gap']:>10.6f}  {case['elapsed']:>5.1f}s")

    print()
    write_csv(summary_rows, os.path.join(run_dir, 'summary.csv'),
              SUMMARY_COLUMNS)
    write_csv(percell_rows, os.path.join(run_dir, 'percell.csv'),
              PERCELL_COLUMNS)

    print()
    print("=" * 80)
    print(f"Partition sweep complete: {len(summary_rows)} summary rows, "
          f"{len(percell_rows)} per-cell rows")
    print("=" * 80)


main()
