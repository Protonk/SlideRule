"""
charybdis_plots.sage — Visualizations for the Test of Charybdis results.

1. Wall z-score scaling with depth (log scale, per q, LI/LD facets)
2. ξ_n sign map at depth 8 (heatmap, kind × q, LI/LD panels)

Run:  ./sagew experiments/rotation/charybdis_plots.sage
"""

import csv
import os

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np

RESULTS_DIR = pathing('experiments', 'rotation', 'results')
CSV_PATH = os.path.join(RESULTS_DIR, 'charybdis_sweep.csv')

# Load data
with open(CSV_PATH) as f:
    rows = list(csv.DictReader(f))

# ── Plot 1: Wall z-score scaling ─────────────────────────────────────

def plot_wall_scaling():
    fig, axes = plt.subplots(1, 2, figsize=(9, 4), sharey=True)

    for ax, mode_label, mode_val in [(axes[0], 'LI', 'LI'),
                                      (axes[1], 'LD', 'LD')]:
        for q_val, marker, color in [(2, 'o', '#2166ac'),
                                      (3, 's', '#b2182b'),
                                      (4, '^', '#4dac26')]:
            depths = []
            log_z = []
            for d in [5, 6, 7, 8]:
                # Average |wall_zscore| across 3 partition kinds
                zscores = [
                    abs(float(r['wall_zscore']))
                    for r in rows
                    if int(r['depth']) == d
                    and int(r['q']) == q_val
                    and r['layer_mode'] == mode_val
                ]
                if zscores:
                    depths.append(d)
                    log_z.append(np.log10(np.mean(zscores)))

            ax.plot(depths, log_z, marker=marker, color=color,
                    linewidth=1.8, markersize=6, label=f'q = {q_val}')

        ax.set_title(mode_label, fontsize=13, fontweight='bold')
        ax.set_xlabel('depth d', fontsize=11)
        ax.set_xticks([5, 6, 7, 8])
        ax.grid(True, alpha=0.3)

    axes[0].set_ylabel(r'$\log_{10}|\,z_{\mathrm{wall}}\,|$'
                        '  (averaged over partition kinds)',
                        fontsize=11)
    axes[1].legend(fontsize=10, loc='upper left')

    fig.suptitle('Wall z-score scaling with depth',
                 fontsize=14, fontweight='bold', y=1.01)
    fig.tight_layout()
    out = os.path.join(RESULTS_DIR, 'wall_zscore_scaling.png')
    fig.savefig(out, dpi=180, bbox_inches='tight')
    plt.close(fig)
    print(f'  Saved {out}')


# ── Plot 2: ξ_n sign map at depth 8 ─────────────────────────────────

def plot_xi_signmap():
    kinds = ['geometric_x', 'uniform_x', 'harmonic_x']
    kind_labels = ['geometric', 'uniform', 'harmonic']
    qs = [2, 3, 4]
    modes = ['LI', 'LD']

    # Build lookup
    lookup = {}
    for r in rows:
        key = (int(r['depth']), int(r['q']), r['kind'], r['layer_mode'])
        lookup[key] = r

    fig, axes = plt.subplots(1, 2, figsize=(8, 3.5))

    vmax = 0
    for mode in modes:
        for ki, kind in enumerate(kinds):
            for qi, q_val in enumerate(qs):
                r = lookup.get((8, q_val, kind, mode))
                if r:
                    vmax = max(vmax, abs(float(r['xi_zscore'])))
    # Cap at a reasonable value for color contrast
    vmax = min(vmax, 200)

    cmap = plt.cm.RdBu_r
    norm = mcolors.TwoSlopeNorm(vmin=-vmax, vcenter=0, vmax=vmax)

    for ax, mode in zip(axes, modes):
        mat = np.zeros((len(kinds), len(qs)))
        for ki, kind in enumerate(kinds):
            for qi, q_val in enumerate(qs):
                r = lookup.get((8, q_val, kind, mode))
                if r:
                    mat[ki, qi] = float(r['xi_zscore'])

        im = ax.imshow(mat, cmap=cmap, norm=norm, aspect='auto')

        # Annotate cells
        for ki in range(len(kinds)):
            for qi in range(len(qs)):
                z = mat[ki, qi]
                text_color = 'white' if abs(z) > vmax * 0.6 else 'black'
                ax.text(qi, ki, f'{z:.0f}', ha='center', va='center',
                        fontsize=11, fontweight='bold', color=text_color)

        ax.set_xticks(range(len(qs)))
        ax.set_xticklabels([f'q = {q}' for q in qs], fontsize=10)
        ax.set_yticks(range(len(kinds)))
        ax.set_yticklabels(kind_labels if mode == 'LI' else [''] * 3,
                           fontsize=10)
        ax.set_title(mode, fontsize=13, fontweight='bold')

    fig.suptitle(r'$\xi_n$ z-score at depth 8'
                 '  (blue = FSM less $\\varepsilon$-structured,'
                 '  red = more)',
                 fontsize=11.5, fontweight='bold', y=1.04)

    cbar = fig.colorbar(im, ax=axes, shrink=0.85, pad=0.04)
    cbar.set_label('z-score', fontsize=10)

    fig.tight_layout()
    out = os.path.join(RESULTS_DIR, 'xi_signmap_d8.png')
    fig.savefig(out, dpi=180, bbox_inches='tight')
    plt.close(fig)
    print(f'  Saved {out}')


# ── Run ──────────────────────────────────────────────────────────────

print('Charybdis plots')
print()
plot_wall_scaling()
plot_xi_signmap()
print()
print('Done.')
