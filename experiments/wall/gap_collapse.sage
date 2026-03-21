"""
gap_collapse.sage — Can the wall be organized by param-to-cell ratio?

Scatter plot: x = param_to_cell_ratio, y = gap or gap_over_free,
color = partition kind, marker = LI vs LD. If points collapse onto a
curve, that's a scaling law. If they don't, the wall depends on more
than the ratio.

Run:  ./sagew experiments/wall/gap_collapse.sage
"""

import csv
import os

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

IN_PATH = pathing('experiments', 'wall', 'results', 'enriched_summary.csv')
OUT_PATH = pathing('experiments', 'wall', 'results', 'gap_collapse.png')

KIND_COLORS = {
    'uniform_x': '#1f77b4',
    'geometric_x': '#9467bd',
    'harmonic_x': '#2ca02c',
    'mirror_harmonic_x': '#d62728',
}

SHORT = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    rows = []
    with open(IN_PATH, 'r', newline='') as f:
        rows = list(csv.DictReader(f))

    fig, axes = plt.subplots(1, 2, figsize=(13, 5.5), constrained_layout=True)

    for ax, y_col, y_label in [
        (axes[0], 'gap', 'gap (opt_err $-$ free_err)'),
        (axes[1], 'gap_over_free', 'gap / free_err'),
    ]:
        for kind, color in KIND_COLORS.items():
            for ld_val, marker, ms in [('False', 'o', 5), ('True', 's', 4)]:
                subset = [r for r in rows
                          if r['partition_kind'] == kind
                          and r['layer_dependent'] == ld_val
                          and r.get('param_to_cell_ratio', '') != ''
                          and r.get(y_col, '') != '']

                if not subset:
                    continue

                xs = [float(r['param_to_cell_ratio']) for r in subset]
                ys = [float(r[y_col]) for r in subset]

                ld_tag = 'LD' if ld_val == 'True' else 'LI'
                label = '%s %s' % (SHORT[kind], ld_tag)
                ax.scatter(xs, ys, color=color, marker=marker, s=ms * 8,
                           alpha=0.7, label=label, edgecolors='none')

        ax.set_xlabel('param-to-cell ratio ($n_{params} / 2^d$)', fontsize=9)
        ax.set_ylabel(y_label, fontsize=9)
        ax.set_xscale('log')
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=8)
        ax.legend(fontsize=6, ncol=2, loc='best')

    fig.suptitle(
        'Gap collapse: does the wall organize by parameter-to-cell ratio?',
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Gap collapse scatter...")
make_plot()
print("Done.")
