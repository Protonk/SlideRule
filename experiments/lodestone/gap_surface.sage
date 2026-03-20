"""
gap_surface.sage — How does the wall respond to (q, depth)?

Heatmap of gap (opt_err - free_err) with q on x-axis, depth on y-axis,
one panel per (kind, layer_mode). Shows whether the wall has a ridge,
whether it's monotone, and whether geometric's wall surface differs from
uniform's.

Run:  ./sagew experiments/lodestone/gap_surface.sage
"""

import csv

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

RUN_TAG = 'wall_surface_2026-03-18'
EXPONENT = '1/2'
KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
OUT_PATH = pathing('experiments', 'lodestone', 'results', 'gap_surface.png')


# ── Load ─────────────────────────────────────────────────────────────

def load_summary(run_tag):
    path = pathing('experiments', 'lodestone', 'results', run_tag, 'summary.csv')
    with open(path, 'r', newline='') as f:
        return list(csv.DictReader(f))


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(rows):
    exponent_rows = [r for r in rows if r['exponent'] == EXPONENT]

    qs = sorted(set(int(r['q']) for r in exponent_rows))
    depths = sorted(set(int(r['depth']) for r in exponent_rows))

    short_name = {
        'uniform_x': 'uniform',
        'geometric_x': 'geometric',
        'harmonic_x': 'harmonic',
        'mirror_harmonic_x': 'mirror-harmonic',
    }

    panels = [(kind, ld_str, ld_label)
              for kind in KINDS
              for ld_str, ld_label in [('False', 'layer-inv'), ('True', 'layer-dep')]]

    n_panels = len(panels)
    n_cols = 4
    n_rows = (n_panels + n_cols - 1) // n_cols

    fig, axes = plt.subplots(n_rows, n_cols, figsize=(4.2 * n_cols, 3.8 * n_rows),
                              constrained_layout=True)
    if n_rows == 1:
        axes = axes[np.newaxis, :]

    # Compute global color scale
    all_gaps = []
    for r in exponent_rows:
        all_gaps.append(float(r['gap']))
    vmin = 0.0
    vmax = max(all_gaps) if all_gaps else 0.05

    for panel_idx, (kind, ld_str, ld_label) in enumerate(panels):
        row_idx, col_idx = divmod(panel_idx, n_cols)
        ax = axes[row_idx, col_idx]

        grid = np.full((len(depths), len(qs)), np.nan)
        for r in exponent_rows:
            if r['partition_kind'] != kind or r['layer_dependent'] != ld_str:
                continue
            qi = qs.index(int(r['q']))
            di = depths.index(int(r['depth']))
            grid[di, qi] = float(r['gap'])

        im = ax.imshow(grid, aspect='auto', origin='lower',
                       cmap='YlOrRd', vmin=vmin, vmax=vmax,
                       interpolation='nearest')

        ax.set_xticks(range(len(qs)))
        ax.set_xticklabels([str(q) for q in qs], fontsize=7)
        ax.set_yticks(range(len(depths)))
        ax.set_yticklabels([str(d) for d in depths], fontsize=7)

        if row_idx == n_rows - 1:
            ax.set_xlabel('q', fontsize=9)
        if col_idx == 0:
            ax.set_ylabel('depth', fontsize=9)

        name = short_name.get(kind, kind)
        ax.set_title(f'{name}, {ld_label}', fontsize=9, fontweight='bold')

        # Annotate each cell with the gap value
        for di in range(len(depths)):
            for qi in range(len(qs)):
                val = grid[di, qi]
                if not np.isnan(val):
                    color = 'white' if val > vmax * 0.6 else 'black'
                    ax.text(qi, di, '%.3f' % val, ha='center', va='center',
                            fontsize=5, color=color)

    # Hide unused axes
    for panel_idx in range(n_panels, n_rows * n_cols):
        row_idx, col_idx = divmod(panel_idx, n_cols)
        axes[row_idx, col_idx].set_visible(False)

    fig.colorbar(im, ax=axes, label='gap (opt_err − free_err)',
                 shrink=0.8, pad=0.02)

    fig.suptitle(
        'Gap scaling surface: wall size across (q, depth)\n'
        'exponent $= %s$' % EXPONENT,
        fontsize=13, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

rows = load_summary(RUN_TAG)
print("Loaded %d summary rows from %s" % (len(rows), RUN_TAG))
make_plot(rows)
print("Done.")
