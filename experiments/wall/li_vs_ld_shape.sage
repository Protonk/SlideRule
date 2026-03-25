"""
li_vs_ld_shape.sage — G9: LI vs LD delta shape comparison.

Visualizes the structural difference between layer-invariant and
layer-dependent optima. H1d observes "LI concentrated, LD diffuse" —
this script makes that visible.

Uses existing joined_layer_modes.csv for gap reduction data, plus
h1a_gap_vs_q.csv for sparsity trends.

Run:  ./sagew experiments/wall/li_vs_ld_shape.sage
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

JOINED_PATH = pathing('experiments', 'wall', 'results',
                      'joined_layer_modes.csv')
H1A_PATH = pathing('experiments', 'aft', 'keystone', 'results', 'h1a_gap_vs_q.csv')
H1C_PATH = pathing('experiments', 'aft', 'keystone', 'results',
                    'h1c_layer_dependent.csv')

OUT_PATH = pathing('experiments', 'wall', 'results', 'li_vs_ld_shape.png')

KIND_COLORS = {
    'uniform_x':          '#1f77b4',
    'geometric_x':        '#9467bd',
    'harmonic_x':         '#2ca02c',
    'mirror_harmonic_x':  '#d62728',
}
KIND_SHORT = {
    'uniform_x':         'uniform',
    'geometric_x':       'geometric',
    'harmonic_x':        'harmonic',
    'mirror_harmonic_x': 'mirror-harm',
}


# -- Load ------------------------------------------------------------------

def load_csv(path):
    if not os.path.exists(path):
        print("  WARNING: %s not found" % path)
        return []
    with open(path, 'r', newline='') as f:
        return list(csv.DictReader(f))


# -- Plot ------------------------------------------------------------------

def make_plot():
    joined = load_csv(JOINED_PATH)
    h1a = load_csv(H1A_PATH)
    h1c = load_csv(H1C_PATH)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5.5), constrained_layout=True)

    # ---- Panel 1: Gap reduction (LD over LI) by kind and depth ----
    ax = axes[0]
    for kind, color in KIND_COLORS.items():
        subset = [r for r in joined if r['partition_kind'] == kind]
        if not subset:
            continue
        subset.sort(key=lambda r: int(r['depth']))
        depths = [int(r['depth']) for r in subset]
        reductions = [float(r['gap_reduction']) for r in subset]
        ax.plot(depths, reductions, 'o-', color=color, markersize=5,
                linewidth=1.5, label=KIND_SHORT[kind])

    ax.set_xlabel('Depth $d$', fontsize=9)
    ax.set_ylabel('Gap reduction: $1 - gap_{LD}/gap_{LI}$', fontsize=9)
    ax.set_title('LD advantage over LI', fontsize=11, fontweight='bold')
    ax.axhline(0, color='#cccccc', linewidth=0.5)
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.legend(fontsize=7)
    ax.tick_params(labelsize=8)

    # ---- Panel 2: LI gap vs q (from h1a) ----
    ax = axes[1]
    if h1a:
        qs = []
        gaps = []
        frees = []
        for r in h1a:
            qs.append(int(r['q']))
            gaps.append(float(r['gap']))
            frees.append(float(r['free_err']))
        qs = np.array(qs)
        gaps = np.array(gaps)
        frees = np.array(frees)

        ax.bar(range(len(qs)), gaps / frees, color='#1f77b4', alpha=0.7,
               edgecolor='#1f77b4')
        ax.set_xticks(range(len(qs)))
        ax.set_xticklabels(['q=%d' % q for q in qs], fontsize=7, rotation=45)
        ax.set_ylabel('gap / free_err', fontsize=9)
        ax.set_title('Wall fraction vs q (uniform LI)', fontsize=11,
                      fontweight='bold')
        ax.grid(True, alpha=0.3, linewidth=0.5, axis='y')
        ax.tick_params(labelsize=8)
    else:
        ax.text(0.5, 0.5, 'h1a_gap_vs_q.csv\nnot found', transform=ax.transAxes,
                ha='center', fontsize=10)

    # ---- Panel 3: Sparsity comparison from h1c ----
    ax = axes[2]
    if h1c:
        li_rows = [r for r in h1c if r['layer_dependent'] == 'False']
        ld_rows = [r for r in h1c if r['layer_dependent'] == 'True']

        labels = ['opt_err', 'gap']
        x_pos = np.arange(len(labels))
        width = 0.3

        if li_rows and ld_rows:
            li_vals = [float(li_rows[0]['opt_err']), float(li_rows[0]['gap'])]
            ld_vals = [float(ld_rows[0]['opt_err']), float(ld_rows[0]['gap'])]

            ax.bar(x_pos - width / 2, li_vals, width, label='LI',
                   color='#1f77b4', alpha=0.7)
            ax.bar(x_pos + width / 2, ld_vals, width, label='LD',
                   color='#ff7f0e', alpha=0.7)
            ax.set_xticks(x_pos)
            ax.set_xticklabels(labels, fontsize=9)
            ax.legend(fontsize=8)
        ax.set_title('LI vs LD at benchmark', fontsize=11, fontweight='bold')
        ax.set_ylabel('Error', fontsize=9)
        ax.grid(True, alpha=0.3, linewidth=0.5, axis='y')
        ax.tick_params(labelsize=8)
    else:
        ax.text(0.5, 0.5, 'h1c_layer_dependent.csv\nnot found',
                transform=ax.transAxes, ha='center', fontsize=10)

    fig.suptitle(
        'LI vs LD: structural comparison of shared-delta parameterizations',
        fontsize=13, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# -- Main ------------------------------------------------------------------

print()
print("LI vs LD shape comparison...")
make_plot()
print("Done.")
