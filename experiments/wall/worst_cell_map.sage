"""
worst_cell_map.sage — Where does the wall live? Worst-cell position heatmap.

Panel grid: one panel per (kind, layer_mode). Within each panel, x-axis = q,
y-axis = depth, color = worst-cell plog midpoint. Shows whether the wall
stays pinned or migrates.

Run:  ./sagew experiments/wall/worst_cell_map.sage
"""

import csv
import os

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

IN_PATH = pathing('experiments', 'wall', 'results', 'enriched_summary.csv')
OUT_PATH = pathing('experiments', 'wall', 'results', 'worst_cell_map.png')

KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
SHORT = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}


# ── Load ─────────────────────────────────────────────────────────────

def load_enriched():
    with open(IN_PATH, 'r', newline='') as f:
        return list(csv.DictReader(f))


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(rows):
    fig, axes = plt.subplots(len(KINDS), 2, figsize=(10, 3.0 * len(KINDS)),
                              constrained_layout=True)

    for ki, kind in enumerate(KINDS):
        for col, (ld_val, ld_label) in enumerate([('False', 'LI'), ('True', 'LD')]):
            ax = axes[ki, col]

            subset = [r for r in rows
                      if r['partition_kind'] == kind
                      and r['layer_dependent'] == ld_val
                      and r['worst_cell_plog_mid'] != '']

            if not subset:
                ax.text(0.5, 0.5, 'no data', ha='center', va='center',
                        transform=ax.transAxes)
                continue

            qs = sorted(set(int(r['q']) for r in subset))
            depths = sorted(set(int(r['depth']) for r in subset))

            grid = np.full((len(depths), len(qs)), np.nan)
            q_idx = {q: i for i, q in enumerate(qs)}
            d_idx = {d: i for i, d in enumerate(depths)}

            for r in subset:
                qi = q_idx[int(r['q'])]
                di = d_idx[int(r['depth'])]
                grid[di, qi] = float(r['worst_cell_plog_mid'])

            im = ax.imshow(grid, aspect='auto', origin='lower',
                           cmap='RdYlBu_r', vmin=0.0, vmax=1.0)

            ax.set_xticks(range(len(qs)))
            ax.set_xticklabels(qs, fontsize=7)
            ax.set_yticks(range(len(depths)))
            ax.set_yticklabels(depths, fontsize=7)

            # Annotate cells with plog value
            for di in range(len(depths)):
                for qi in range(len(qs)):
                    val = grid[di, qi]
                    if not np.isnan(val):
                        ax.text(qi, di, '%.2f' % val, ha='center', va='center',
                                fontsize=6, fontweight='bold',
                                color='white' if val > 0.5 else 'black')

            if ki == 0:
                ax.set_title(ld_label, fontsize=10, fontweight='bold')
            if col == 0:
                ax.set_ylabel(SHORT[kind], fontsize=9, fontweight='bold')
            if ki == len(KINDS) - 1:
                ax.set_xlabel('$q$', fontsize=9)

    fig.colorbar(im, ax=axes, label='Worst-cell $\\log_2$ midpoint',
                 shrink=0.6, pad=0.02)

    fig.suptitle(
        'Worst-cell position map\n'
        'exponent $= 1/2$',
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Worst-cell map...")
rows = load_enriched()
make_plot(rows)
print("Done.")
