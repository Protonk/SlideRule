"""
depth_staircase.sage — TRAVERSE Step 2d: depth-indexed absorption staircase.

Sweeps q at multiple depths on geometric_x LI to test whether the
absorption staircase shape and binding-cell ordering stabilize with depth.

Two diagnostics:
  1. Staircase stability: gap vs q curves across depths.
  2. Binding-cell ordering: worst-cell mantissa vs q across depths.

If both stabilize, Step 2d (scaling characterization) can close.

Output:
  results/depth_staircase.csv     — 30-row data table
  results/depth_staircase.png     — two-panel diagnostic plot

Run:  ./sagew experiments/wall/depth_staircase.sage
"""

import csv
import os
import time

from helpers import pathing
load(pathing('experiments', 'aft', 'keystone', 'keystone_runner.sage'))
load(pathing('lib', 'displacement.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# -- Configuration --------------------------------------------------------

DEPTHS = [4, 5, 6, 7, 8]
Q_VALUES = [1, 3, 5, 7, 9, 11]
KIND = 'geometric_x'
LAYER_DEPENDENT = False
P_NUM = 1
Q_DEN = 2

OUT_DIR = pathing('experiments', 'wall', 'results')
OUT_CSV = os.path.join(OUT_DIR, 'depth_staircase.csv')
OUT_PNG = os.path.join(OUT_DIR, 'depth_staircase.png')

LN2 = float(log(2.0))
M_STAR = 1.0 / LN2 - 1.0


# -- Sweep ----------------------------------------------------------------

def run_sweep():
    """Sweep (q, depth) grid and collect gap + binding-cell data."""
    rows = []

    for depth in DEPTHS:
        print("  depth=%d" % depth)
        for q in Q_VALUES:
            t0 = time.time()
            case = compute_case(q, depth, P_NUM, Q_DEN,
                                partition_kind=KIND, layer_dependent=LAYER_DEPENDENT)
            elapsed = time.time() - t0

            # Find binding cell (worst-case under shared policy)
            cell_data = case['opt_pol']['metrics']['cell_data']
            worst_m = None
            worst_err = -1
            for entry in cell_data:
                bits = entry[0]
                prow = case['row_map'][bits]
                m_mid = float((prow['x_lo'] + prow['x_hi']) / 2) - 1.0
                cell_worst = entry[3]
                if cell_worst > worst_err:
                    worst_err = cell_worst
                    worst_m = m_mid

            row = {
                'depth': depth,
                'q': q,
                'n_cells': 2**depth,
                'n_params': 1 + 2 * q,
                'opt_err': float(case['opt_err']),
                'free_err': float(case['free_err']),
                'gap': float(case['gap']),
                'binding_m': worst_m,
            }
            rows.append(row)
            print("    q=%2d: gap=%.6f  binding_m=%.4f  (%.1fs)"
                  % (q, row['gap'], worst_m, elapsed))

    return rows


# -- CSV output -----------------------------------------------------------

def write_csv(rows):
    os.makedirs(OUT_DIR, exist_ok=True)
    fields = ['depth', 'q', 'n_cells', 'n_params',
              'opt_err', 'free_err', 'gap', 'binding_m']
    with open(OUT_CSV, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for row in rows:
            w.writerow(row)
    print("Saved: %s" % OUT_CSV)


# -- Plot -----------------------------------------------------------------

DEPTH_COLORS = {
    4: '#2ca02c',
    5: '#1f77b4',
    6: '#9467bd',
    7: '#d62728',
    8: '#ff7f0e',
}

def plot_diagnostics(rows):
    fig, (ax_gap, ax_bind) = plt.subplots(
        2, 1, figsize=(8, 9), sharex=True)
    fig.subplots_adjust(top=0.92, hspace=0.28)

    for depth in DEPTHS:
        subset = sorted([r for r in rows if r['depth'] == depth],
                        key=lambda r: r['q'])
        qs = [r['q'] for r in subset]
        gaps = [r['gap'] for r in subset]
        bind_ms = [r['binding_m'] for r in subset]
        color = DEPTH_COLORS.get(depth, '#333333')
        label = 'd=%d (n=%d)' % (depth, 2**depth)

        ax_gap.plot(qs, gaps, 'o-', color=color, markersize=5,
                    linewidth=1.5, label=label)
        ax_bind.plot(qs, bind_ms, 'o-', color=color, markersize=5,
                     linewidth=1.5, label=label)

    # Top panel: gap vs q
    ax_gap.set_ylabel('Gap (opt_err $-$ free_err)', fontsize=10)
    ax_gap.set_title('Diagnostic 1: staircase stability across depths',
                     fontsize=11, fontweight='bold')
    ax_gap.grid(True, alpha=0.3, linewidth=0.5)
    ax_gap.legend(fontsize=8, loc='upper right')
    ax_gap.tick_params(labelsize=8)

    # Bottom panel: binding cell vs q
    ax_bind.axhline(M_STAR, color='#888888', linewidth=0.8, linestyle=':')
    ax_bind.text(Q_VALUES[-1] + 0.3, M_STAR, '$m^*$', fontsize=9,
                 color='#888888', va='center')
    ax_bind.axhline(0, color='#cccccc', linewidth=0.3)
    ax_bind.axhline(1, color='#cccccc', linewidth=0.3)
    ax_bind.set_ylim(-0.05, 1.05)
    ax_bind.set_xlabel('Parameter budget $q$ (FSM states)', fontsize=10)
    ax_bind.set_ylabel('Binding-cell mantissa $m$', fontsize=10)
    ax_bind.set_title('Diagnostic 2: binding-cell ordering across depths',
                      fontsize=11, fontweight='bold')
    ax_bind.grid(True, alpha=0.3, linewidth=0.5)
    ax_bind.legend(fontsize=8, loc='upper right')
    ax_bind.tick_params(labelsize=8)

    fig.suptitle(
        'Depth-indexed absorption staircase  '
        '(geometric_x, LI, exponent %d/%d)' % (P_NUM, Q_DEN),
        fontsize=11, fontweight='bold')

    os.makedirs(OUT_DIR, exist_ok=True)
    fig.savefig(OUT_PNG, dpi=180)
    print("Saved: %s" % OUT_PNG)


# -- Main -----------------------------------------------------------------

print()
print("Depth-indexed absorption staircase")
print("  kind=%s  LI  exponent=%d/%d" % (KIND, P_NUM, Q_DEN))
print("  depths=%s  q_values=%s" % (DEPTHS, Q_VALUES))
print()

rows = run_sweep()
write_csv(rows)
plot_diagnostics(rows)
print("Done.")
