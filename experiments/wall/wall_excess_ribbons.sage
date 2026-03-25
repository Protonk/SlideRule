"""
wall_excess_ribbons.sage — Per-cell wall excess visualization.

Shows free error, shared error, and wall excess (shared - free) per cell
for a single case. LI and LD as separate rows. Anchored to the keystone
compatibility benchmark case.

Run:  ./sagew experiments/wall/wall_excess_ribbons.sage
"""

import csv
import os
from math import log2

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

RUN_TAG = 'wall_surface_2026-03-18'
KIND = 'geometric_x'
Q = 3
DEPTH = 6
EXPONENT = '1/2'
P_NUM = 1
Q_DEN = 2

PERCELL_PATH = pathing('experiments', 'aft', 'keystone', 'results', RUN_TAG, 'percell.csv')
OUT_PATH = pathing('experiments', 'wall', 'results', 'wall_excess_ribbons.png')

SHORT = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}


# ── Load and compute ─────────────────────────────────────────────────

def load_case(filepath, kind, q, depth, exponent, layer_dependent):
    """Load percell rows and compute wall excess per cell."""
    ld_str = str(layer_dependent)
    cells = []

    with open(filepath, 'r', newline='') as f:
        for r in csv.DictReader(f):
            if (r['partition_kind'] == kind
                    and r['q'] == str(q) and r['depth'] == str(depth)
                    and r['exponent'] == exponent
                    and r['layer_dependent'] == ld_str
                    and r['free_cell_intercept'] != ''):

                x_mid = float(r['x_mid'])
                shared_err = float(r['cell_worst_err'])

                # Recompute free-cell error from the free intercept
                plog_lo = QQ(RealNumber(r['plog_lo']))
                plog_hi = QQ(RealNumber(r['plog_hi']))
                free_c = QQ(RealNumber(r['free_cell_intercept']))
                _, _, free_err, _, _ = cell_logerr_arb(
                    plog_lo, plog_hi, P_NUM, Q_DEN, free_c)

                wall_excess = shared_err - float(free_err)
                cells.append({
                    'x_mid': x_mid,
                    'plog_mid': log2(x_mid),
                    'shared_err': shared_err,
                    'free_err': float(free_err),
                    'wall_excess': wall_excess,
                })

    cells.sort(key=lambda c: c['x_mid'])
    return cells


def excess_stats(cells):
    """Compute wall excess summary statistics."""
    excess = [c['wall_excess'] for c in cells]
    if not excess:
        return {}
    excess_sorted = sorted(excess)
    n = len(excess_sorted)
    total = sum(excess)
    median_val = excess_sorted[n // 2]

    # Top quartile share
    top_q = sorted(excess, reverse=True)[:max(1, n // 4)]
    top_q_share = sum(top_q) / total if total > 0 else 0.0

    # Max over median
    max_over_med = max(excess) / median_val if median_val > 0 else float('inf')

    return {
        'max_excess': max(excess),
        'top_quartile_share': top_q_share,
        'max_over_median': max_over_med,
    }


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, axes = plt.subplots(2, 3, figsize=(15, 7), constrained_layout=True)

    for row, (ld, ld_label, accent) in enumerate([
        (False, 'Layer-invariant (LI)', '#e74c3c'),
        (True, 'Layer-dependent (LD)', '#3498db'),
    ]):
        cells = load_case(PERCELL_PATH, KIND, Q, DEPTH, EXPONENT, ld)
        if not cells:
            print("  WARNING: no data for LD=%s" % ld)
            continue

        xs = [c['x_mid'] for c in cells]
        free = [c['free_err'] for c in cells]
        shared = [c['shared_err'] for c in cells]
        excess = [c['wall_excess'] for c in cells]
        stats = excess_stats(cells)

        # Panel 1: free and shared error
        ax = axes[row, 0]
        ax.plot(xs, free, color='#2ecc71', linewidth=1.2, label='free')
        ax.plot(xs, shared, color=accent, linewidth=1.2, label='shared')
        ax.fill_between(xs, free, shared, color=accent, alpha=0.15)
        ax.set_ylabel('Peak error', fontsize=9)
        ax.legend(fontsize=7, loc='upper right')
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)
        ax.set_title(ld_label, fontsize=9, fontweight='bold')

        # Panel 2: wall excess
        ax = axes[row, 1]
        ax.fill_between(xs, 0, excess, color=accent, alpha=0.4)
        ax.plot(xs, excess, color=accent, linewidth=1.0)
        ax.axhline(0, color='#999999', linewidth=0.5)
        ax.set_ylabel('Wall excess', fontsize=9)
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)

        # Annotate stats
        ax.text(0.98, 0.95,
                'max=%.4f\ntop-Q share=%.1f%%\nmax/med=%.1f'
                % (stats['max_excess'],
                   stats['top_quartile_share'] * 100,
                   stats['max_over_median']),
                transform=ax.transAxes, fontsize=7, va='top', ha='right',
                fontweight='bold', color=accent,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                          alpha=0.8))

        # Panel 3: normalized (excess / max_excess)
        ax = axes[row, 2]
        max_ex = stats['max_excess']
        if max_ex > 0:
            norm_excess = [e / max_ex for e in excess]
        else:
            norm_excess = excess
        ax.fill_between(xs, 0, norm_excess, color=accent, alpha=0.4)
        ax.plot(xs, norm_excess, color=accent, linewidth=1.0)
        ax.axhline(0, color='#999999', linewidth=0.5)
        ax.set_ylabel('Normalized excess', fontsize=9)
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)
        ax.set_ylim(-0.05, 1.1)

    for ax in axes[1, :]:
        ax.set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=9)

    kind_short = SHORT.get(KIND, KIND)
    fig.suptitle(
        'Wall excess ribbons: %s, $q = %d$, depth $= %d$, exponent $= %s$'
        % (kind_short, Q, DEPTH, EXPONENT),
        fontsize=12, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Wall excess ribbons: %s, q=%d, depth=%d, exponent=%s"
      % (KIND, Q, DEPTH, EXPONENT))

make_plot()
print("Done.")
