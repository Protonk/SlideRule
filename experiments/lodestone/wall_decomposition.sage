"""
wall_decomposition.sage — Grid of stacked bars showing where the error budget
goes as depth increases across partition geometries.

Rows = partition kinds (uniform, geometric, mirror-harmonic).
Columns = depths.
Each cell has two side-by-side bars (LI and LD), each decomposed into:
  - free_err (floor, green)
  - improve (captured by optimizer, blue)
  - gap / wall (red)

Read horizontally: watch the wall grow with depth for one partition.
Read vertically: compare wall shape across geometries at one depth.

Run:  ./sagew experiments/lodestone/wall_decomposition.sage
"""

import csv

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

RUN_TAGS = ['wall_surface_2026-03-18', 'partition_2026-03-18']
Q = 3
DEPTHS = [3, 4, 5, 6, 7, 8]
KINDS = ['uniform_x', 'geometric_x', 'mirror_harmonic_x']
EXPONENT = '1/2'
OUT_PATH = pathing('experiments', 'lodestone', 'results', 'wall_decomposition.png')

SHORT_NAME = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'mirror_harmonic_x': 'mirror-harmonic',
}


# ── Load ─────────────────────────────────────────────────────────────

def load_summary(run_tags):
    all_rows = []
    seen = set()
    for tag in run_tags:
        path = pathing('experiments', 'lodestone', 'results', tag, 'summary.csv')
        with open(path, 'r', newline='') as f:
            for r in csv.DictReader(f):
                key = (r['partition_kind'], r['q'], r['depth'],
                       r['exponent'], r['layer_dependent'])
                if key not in seen:
                    seen.add(key)
                    all_rows.append(r)
    return all_rows


def find_row(rows, kind, q, depth, exponent, ld):
    for r in rows:
        if (r['partition_kind'] == kind and r['q'] == str(q)
                and r['depth'] == str(depth)
                and r['exponent'] == exponent
                and r['layer_dependent'] == str(ld)):
            return r
    return None


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(rows):
    n_rows = len(KINDS)
    n_cols = len(DEPTHS)
    bar_width = 0.32

    fig, axes = plt.subplots(
        n_rows, n_cols,
        figsize=(2.8 * n_cols + 0.6, 3.0 * n_rows + 1.2),
        constrained_layout=True,
        sharey=True,
    )

    # Global y-max for consistent scale
    y_max = 0
    for kind in KINDS:
        for depth in DEPTHS:
            r = find_row(rows, kind, Q, depth, EXPONENT, False)
            if r:
                y_max = max(y_max, float(r['single_err']))
    y_max *= 1.08

    for ri, kind in enumerate(KINDS):
        for ci, depth in enumerate(DEPTHS):
            ax = axes[ri, ci]

            for j, (ld, ld_label, offset) in enumerate([
                (False, 'LI', -bar_width / 2 - 0.02),
                (True, 'LD', bar_width / 2 + 0.02),
            ]):
                r = find_row(rows, kind, Q, depth, EXPONENT, ld)
                if r is None:
                    continue

                free = float(r['free_err'])
                improve = float(r['improve'])
                gap = float(r['gap'])

                x = 0.5 + offset
                ax.bar(x, free, bar_width, color='#2ecc71',
                       edgecolor='white', linewidth=0.4,
                       label='floor' if ri == 0 and ci == 0 and j == 0 else '')
                ax.bar(x, improve, bar_width, bottom=free, color='#3498db',
                       edgecolor='white', linewidth=0.4,
                       label='captured' if ri == 0 and ci == 0 and j == 0 else '')
                ax.bar(x, gap, bar_width, bottom=free + improve, color='#e74c3c',
                       edgecolor='white', linewidth=0.4,
                       label='wall' if ri == 0 and ci == 0 and j == 0 else '')

                ax.text(x, -y_max * 0.04, ld_label,
                        ha='center', va='top', fontsize=6.5, fontweight='bold',
                        color='#555555')

            ax.set_ylim(0, y_max)
            ax.set_xlim(0, 1)
            ax.set_xticks([])
            ax.tick_params(axis='y', labelsize=7)
            ax.grid(axis='y', alpha=0.25, linewidth=0.4)

            if ri == 0:
                ax.set_title('d=%d  (N=%d)' % (depth, 2**depth),
                             fontsize=9, fontweight='bold')
            if ci == 0:
                ax.set_ylabel(SHORT_NAME.get(kind, kind), fontsize=9,
                              fontweight='bold')

    fig.legend(loc='lower center', ncol=3, fontsize=8,
               bbox_to_anchor=(0.5, -0.02))

    fig.suptitle(
        'Wall decomposition across depth and partition geometry\n'
        '$q = %d$, exponent $= %s$' % (Q, EXPONENT),
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

rows = load_summary(RUN_TAGS)
print("Loaded %d summary rows" % len(rows))
make_plot(rows)
print("Done.")
