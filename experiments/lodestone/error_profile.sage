"""
error_profile.sage — Per-cell error profile across cell position.

For a single benchmark case (q, depth, alpha), plots cell_worst_err vs x_mid
for geometric_x and uniform_x under both layer-invariant and layer-dependent
sharing. Shows where the wall concentrates spatially.

Run:  ./sagew experiments/lodestone/error_profile.sage
"""

import os
import csv

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

Q = 3
DEPTH = 6
ALPHA = '1/2'
PERCELL_CSV = pathing('experiments', 'lodestone', 'results', 'lodestone_percell.csv')
OUT_PATH = pathing('experiments', 'lodestone', 'results', 'error_profile.png')


# ── Load and filter ──────────────────────────────────────────────────

def load_percell(filepath, q, depth, alpha):
    """Load percell CSV and filter to the target case."""
    with open(filepath, 'r', newline='') as f:
        reader = csv.DictReader(f)
        rows = [r for r in reader
                if r['q'] == str(q) and r['depth'] == str(depth)
                and r['alpha'] == alpha]
    return rows


def extract_profile(rows, kind, layer_dependent):
    """Extract (x_mid, cell_worst_err) sorted by x_mid."""
    ld_str = str(layer_dependent)
    cells = [(float(r['x_mid']), float(r['cell_worst_err']))
             for r in rows
             if r['partition_kind'] == kind
             and r['layer_dependent'] == ld_str]
    cells.sort()
    return [c[0] for c in cells], [c[1] for c in cells]


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(rows):
    fig, ax = plt.subplots(figsize=(11, 5.5), constrained_layout=True)

    configs = [
        ('uniform_x',    False, '#1f77b4', '-',  'o', 'uniform, layer-inv'),
        ('uniform_x',    True,  '#1f77b4', '--', 's', 'uniform, layer-dep'),
        ('geometric_x',  False, '#9467bd', '-',  'o', 'geometric, layer-inv'),
        ('geometric_x',  True,  '#9467bd', '--', 's', 'geometric, layer-dep'),
    ]

    for kind, ld, color, ls, marker, label in configs:
        xs, errs = extract_profile(rows, kind, ld)
        if not xs:
            print("  WARNING: no data for %s LD=%s" % (kind, ld))
            continue
        ax.plot(xs, errs, linestyle=ls, color=color, linewidth=1.0,
                marker=marker, markersize=2.5, alpha=0.8, label=label,
                zorder=3)

    # Mark m* = 1/ln(2), the curvature crossover
    from math import log
    m_star = 1.0 / log(2.0)
    ax.axvline(m_star, color='#888888', linewidth=0.8, linestyle=':',
               zorder=1)
    ax.text(m_star + 0.01, ax.get_ylim()[1] * 0.95, '$m^* = 1/\\ln 2$',
            fontsize=7, color='#666666', va='top')

    ax.set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=10)
    ax.set_ylabel('Per-cell worst error', fontsize=10)
    ax.set_xlim(1.0, 2.0)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)

    fig.suptitle(
        'Per-cell error profile: where does the wall concentrate?\n'
        '$q = %d$, depth $= %d$, $\\alpha = %s$, $N = %d$ cells'
        % (Q, DEPTH, ALPHA, 2**DEPTH),
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Loading percell data for q=%d, depth=%d, alpha=%s..." % (Q, DEPTH, ALPHA))
rows = load_percell(PERCELL_CSV, Q, DEPTH, ALPHA)
print("  %d rows loaded" % len(rows))
make_plot(rows)
print("Done.")
