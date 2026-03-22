"""
zoo_field_summary.sage — G16: Zoo-wide displacement field metrics.

Visualizes T1-T3 diagnostic metrics across all 27 zoo cases (from
zoo_case_metrics.csv). Shows which partition kinds conform to the
displacement field theory and which deviate.

Run:  ./sagew experiments/tiling/zoo_field_summary.sage
"""

import csv
import os

from helpers import pathing
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# -- Configuration --------------------------------------------------------

IN_PATH = pathing('experiments', 'tiling', 'results', 'zoo',
                  'zoo_case_metrics.csv')
OUT_PATH = pathing('experiments', 'tiling', 'results',
                    'zoo_field_summary.png')

# Category colors from PARTITION_REGISTRY
CATEGORY_COLORS = {
    'elementary_geometric':   '#9467bd',
    'elementary_arithmetic':  '#1f77b4',
    'number_theory':          '#2ca02c',
    'fractal':                '#e67e22',
    'oscillating':            '#8c564b',
    'distribution':           '#ff7f0e',
    'adversarial':            '#d62728',
    'synthetic':              '#7f7f7f',
}


# -- Load ------------------------------------------------------------------

def load_metrics():
    rows = []
    with open(IN_PATH, 'r', newline='') as f:
        for r in csv.DictReader(f):
            rows.append(r)
    return rows


def category_for_kind(kind):
    if kind in PARTITION_REGISTRY:
        return PARTITION_REGISTRY[kind].get('category', 'unknown')
    return 'synthetic'


# -- Plot ------------------------------------------------------------------

def make_plot():
    rows = load_metrics()
    print("  Loaded %d case-depth rows" % len(rows))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6),
                                    constrained_layout=True)

    # ---- Panel 1: scatter of corr vs NRMSE ---
    for r in rows:
        corr = float(r['corr_inf'])
        nrmse_val = float(r['nrmse_inf'])
        worst = float(r['worst_abs'])
        kind = r['kind']
        cat = category_for_kind(kind)
        color = CATEGORY_COLORS.get(cat, '#aaaaaa')

        size = max(8, min(80, worst * 8000))
        ax1.scatter(corr, nrmse_val, s=size, color=color, alpha=0.6,
                    edgecolors='white', linewidth=0.3)

    # Label adversaries
    adversaries = [r for r in rows if category_for_kind(r['kind']) == 'adversarial']
    for r in adversaries:
        corr = float(r['corr_inf'])
        nrmse_val = float(r['nrmse_inf'])
        short = r['kind'].replace('_x', '')
        ax1.annotate(short, (corr, nrmse_val), fontsize=5, color='#666666',
                     xytext=(3, 3), textcoords='offset points')

    ax1.set_xlabel('Correlation $r(R_0(c^*),\\, R_0(\\Delta^L))$', fontsize=9)
    ax1.set_ylabel('NRMSE after scale fit', fontsize=9)
    ax1.set_title('Displacement field conformity', fontsize=11, fontweight='bold')
    ax1.grid(True, alpha=0.3, linewidth=0.5)
    ax1.tick_params(labelsize=8)

    # Legend for categories
    for cat, color in CATEGORY_COLORS.items():
        if any(category_for_kind(r['kind']) == cat for r in rows):
            ax1.scatter([], [], s=30, color=color, label=cat.replace('_', ' '),
                        edgecolors='white', linewidth=0.3)
    ax1.legend(fontsize=6, loc='upper left')

    # ---- Panel 2: heatmap of corr by kind x depth ---
    kinds_seen = []
    for r in rows:
        k = r['kind']
        if k not in kinds_seen:
            kinds_seen.append(k)
    depths_seen = sorted(set(int(r['depth']) for r in rows))

    grid = np.full((len(kinds_seen), len(depths_seen)), np.nan)
    for r in rows:
        ki = kinds_seen.index(r['kind'])
        di = depths_seen.index(int(r['depth']))
        grid[ki, di] = float(r['corr_inf'])

    # Sort kinds by mean correlation (descending)
    mean_corr = np.nanmean(grid, axis=1)
    sort_idx = np.argsort(-mean_corr)
    grid = grid[sort_idx]
    kinds_sorted = [kinds_seen[i] for i in sort_idx]
    kind_labels = [k.replace('_x', '') for k in kinds_sorted]

    im = ax2.imshow(grid, aspect='auto', cmap='RdYlGn', vmin=0.3, vmax=1.0)
    ax2.set_xticks(range(len(depths_seen)))
    ax2.set_xticklabels(['d=%d' % d for d in depths_seen], fontsize=7)
    ax2.set_yticks(range(len(kind_labels)))
    ax2.set_yticklabels(kind_labels, fontsize=6)
    ax2.set_title('Correlation by kind and depth', fontsize=11, fontweight='bold')
    ax2.set_xlabel('Depth', fontsize=9)

    # Annotate cells
    for i in range(grid.shape[0]):
        for j in range(grid.shape[1]):
            v = grid[i, j]
            if not np.isnan(v):
                ax2.text(j, i, '%.2f' % v, ha='center', va='center',
                         fontsize=5, color='black' if v > 0.6 else 'white')

    cbar = fig.colorbar(im, ax=ax2, shrink=0.8)
    cbar.set_label('$r(R_0(c^*), R_0(\\Delta^L))$', fontsize=8)

    fig.suptitle(
        'Zoo-wide displacement field diagnostics (T1-T3)\n'
        '%d cases across %d partition kinds' % (len(rows), len(kinds_seen)),
        fontsize=13, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# -- Main ------------------------------------------------------------------

print()
print("Zoo displacement field summary...")
make_plot()
print("Done.")
