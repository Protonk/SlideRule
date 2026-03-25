"""
compatibility_matrix.sage — Exhibit Keystone §4: the joint compatibility claim.

The coordinate, surrogate, and discretization are mutually adapted. This
script shows how geometric and uniform grids produce different error
structures at three levels:

  1. Free per-cell: geometric equalizes difficulty (§1), uniform does not.
  2. Shared-delta: the optimizer's spatial compromise differs on the two grids.
  3. Wall excess: where the sharing penalty concentrates per cell.

The compatibility claim: on geometric, the free error is flat and the wall
excess is distributed. On uniform, the free error is position-dependent and
the wall excess concentrates on the cells that were already hardest.

Run:  ./sagew experiments/aft/keystone/compatibility_matrix.sage
"""

import os
import sys
import time
from math import log, log2

from helpers import pathing
load(pathing('lib', 'paths.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))
load(pathing('lib', 'policies.sage'))
load(pathing('lib', 'optimize.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ── Configuration ────────────────────────────────────────────────────

Q = 3
DEPTH = 6
P_NUM = 1
Q_DEN = 2
OUT_PATH = pathing('experiments', 'aft', 'keystone', 'results',
                    'compatibility_matrix.png')

GRIDS = [
    ('geometric_x', 'geometric', '#9467bd'),
    ('uniform_x',   'uniform',   '#1f77b4'),
]


# ── Compute ──────────────────────────────────────────────────────────

def compute_grid_case(q, depth, kind):
    """Compute free-per-cell and shared-delta errors for one grid."""
    partition = build_partition(depth, kind=kind)
    row_map = partition_row_map(partition)
    _, paths, _ = residue_paths(q, depth)

    # Free per-cell
    free = free_per_cell_metrics(depth, P_NUM, Q_DEN, partition_kind=kind)
    free_by_bits = {}
    for fr in free['rows']:
        free_by_bits[fr['bits']] = float(fr['cell_worst'])

    # Shared-delta (layer-invariant)
    opt = optimize_minimax(q, depth, P_NUM, Q_DEN, partition_kind=kind,
                           layer_dependent=False)

    # Per-cell data
    cells = []
    for entry in opt['metrics']['cell_data']:
        bits = entry[0]
        shared_err = float(entry[3])
        free_err = free_by_bits.get(bits, 0.0)
        wall_excess = shared_err - free_err
        prow = row_map[bits]
        x_mid = float((prow['x_lo'] + prow['x_hi']) / 2)
        cells.append({
            'x_mid': x_mid,
            'free_err': free_err,
            'shared_err': shared_err,
            'wall_excess': wall_excess,
        })
    cells.sort(key=lambda c: c['x_mid'])

    return {
        'free_worst': float(free['worst_abs']),
        'opt_err': float(opt['worst_err']),
        'gap': float(opt['worst_err']) - float(free['worst_abs']),
        'cells': cells,
    }


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(results):
    fig, axes = plt.subplots(2, 2, figsize=(13, 9), constrained_layout=True)

    # Panel 1: free per-cell error
    ax = axes[0, 0]
    for kind, label, color in GRIDS:
        cells = results[kind]['cells']
        xs = [c['x_mid'] for c in cells]
        errs = [c['free_err'] for c in cells]
        ax.plot(xs, errs, color=color, linewidth=1.5, label=label)

    ax.set_title('Free per-cell error', fontsize=10, fontweight='bold')
    ax.set_xlabel('Cell midpoint $m$', fontsize=9)
    ax.set_ylabel('Peak error', fontsize=9)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1.0, 2.0)

    # Panel 2: shared-delta per-cell error
    ax = axes[0, 1]
    for kind, label, color in GRIDS:
        cells = results[kind]['cells']
        xs = [c['x_mid'] for c in cells]
        errs = [c['shared_err'] for c in cells]
        ax.plot(xs, errs, color=color, linewidth=1.5, label=label)

    ax.set_title('Shared-delta per-cell error (LI)', fontsize=10,
                  fontweight='bold')
    ax.set_xlabel('Cell midpoint $m$', fontsize=9)
    ax.set_ylabel('Peak error', fontsize=9)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1.0, 2.0)

    # Panel 3: wall excess per cell
    ax = axes[1, 0]
    for kind, label, color in GRIDS:
        cells = results[kind]['cells']
        xs = [c['x_mid'] for c in cells]
        excess = [c['wall_excess'] for c in cells]
        ax.plot(xs, excess, color=color, linewidth=1.5, label=label)

    ax.axhline(0, color='#999999', linewidth=0.5)
    ax.set_title('Wall excess per cell (shared $-$ free)', fontsize=10,
                  fontweight='bold')
    ax.set_xlabel('Cell midpoint $m$', fontsize=9)
    ax.set_ylabel('Wall excess', fontsize=9)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1.0, 2.0)

    # Panel 4: summary
    ax = axes[1, 1]
    labels = []
    free_vals = []
    gap_vals = []
    bar_colors = []
    for kind, label, color in GRIDS:
        r = results[kind]
        labels.append(label)
        free_vals.append(r['free_worst'])
        gap_vals.append(r['gap'])
        bar_colors.append(color)

    x_pos = range(len(labels))
    bars_free = ax.bar(x_pos, free_vals, color=bar_colors, alpha=0.7,
                        label='free floor')
    bars_wall = ax.bar(x_pos, gap_vals, bottom=free_vals, color=bar_colors,
                        alpha=0.3, hatch='//', label='wall')

    for i in range(len(labels)):
        total = free_vals[i] + gap_vals[i]
        ax.text(i, total + 0.001,
                'free=%.4f\nwall=%.4f\ntotal=%.4f'
                % (free_vals[i], gap_vals[i], total),
                ha='center', fontsize=7, fontweight='bold',
                color=bar_colors[i])

    ax.set_xticks(x_pos)
    ax.set_xticklabels(labels, fontsize=9, fontweight='bold')
    ax.set_ylabel('Worst-case error', fontsize=9)
    ax.set_title('Summary: free + wall', fontsize=10, fontweight='bold')
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3, linewidth=0.5, axis='y')
    ax.tick_params(labelsize=8)

    fig.suptitle(
        'Compatibility: how discretization interacts with sharing\n'
        '$q = %d$, depth $= %d$ ($N = %d$), exponent $= %d/%d$, '
        'layer-invariant'
        % (Q, DEPTH, 2**DEPTH, P_NUM, Q_DEN),
        fontsize=12, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Compatibility matrix: q=%d, depth=%d, exponent=%d/%d"
      % (Q, DEPTH, P_NUM, Q_DEN))
sys.stdout.flush()

results = {}
for kind, label, color in GRIDS:
    t0 = time.time()
    results[kind] = compute_grid_case(Q, DEPTH, kind)
    r = results[kind]
    print("  %s: free=%.6f opt=%.6f gap=%.6f (%.1fs)"
          % (label, r['free_worst'], r['opt_err'], r['gap'],
             time.time() - t0))
    sys.stdout.flush()

make_plot(results)

# Concentration analysis
print()
print("  Wall excess concentration:")
for kind, label, color in GRIDS:
    cells = results[kind]['cells']
    excess = [c['wall_excess'] for c in cells]
    total_excess = sum(excess)
    max_excess = max(excess)
    min_excess = min(excess)
    ratio = max_excess / min_excess if min_excess > 0 else float('inf')
    print("    %s: max/min=%.2f  max=%.6f  min=%.6f"
          % (label, ratio, max_excess, min_excess))

print()
print("Done.")
