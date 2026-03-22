"""
exponent_robustness.sage — G10: Cross-exponent wall figures.

Visualizes how wall structure changes across target exponents 1/3, 1/2, 2/3.
Data from exponent_robustness_2026-03-20 sweep (160 cases) and the original
wall_surface_2026-03-18 sweep (exponent 1/2).

Run:  ./sagew experiments/wall/exponent_robustness.sage
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

ROBUSTNESS_PATH = pathing('experiments', 'wall', 'results',
                          'exponent_robustness_2026-03-20', 'summary.csv')
ENRICHED_PATH = pathing('experiments', 'wall', 'results',
                        'enriched_summary.csv')

OUT_PATH = pathing('experiments', 'wall', 'results',
                    'exponent_robustness.png')

EXPONENTS = ['1/3', '1/2', '2/3']
EXP_LABELS = {'1/3': '$x^{-1/3}$', '1/2': '$x^{-1/2}$',
              '2/3': '$x^{-2/3}$'}

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

def load_all():
    """Load from both CSVs, dedup by case key."""
    all_rows = []
    for path in [ENRICHED_PATH, ROBUSTNESS_PATH]:
        if not os.path.exists(path):
            print("  WARNING: %s not found" % path)
            continue
        with open(path, 'r', newline='') as f:
            all_rows.extend(csv.DictReader(f))

    seen = {}
    for r in all_rows:
        key = (r['partition_kind'], r['q'], r['depth'],
               r['exponent'], r['layer_dependent'])
        seen[key] = r
    return list(seen.values())


# -- Plot ------------------------------------------------------------------

def make_plot():
    rows = load_all()
    print("  Loaded %d unique cases" % len(rows))

    fig, axes = plt.subplots(1, 3, figsize=(16, 5.5), constrained_layout=True,
                             sharey=True)

    for col, exp in enumerate(EXPONENTS):
        ax = axes[col]

        for kind, color in KIND_COLORS.items():
            for ld_val, marker, ms_sz in [('False', 'o', 5), ('True', 's', 4)]:
                subset = [r for r in rows
                          if r['partition_kind'] == kind
                          and r['exponent'] == exp
                          and r['layer_dependent'] == ld_val
                          and r.get('free_err', '') != ''
                          and float(r.get('free_err', '0')) > 0]

                if not subset:
                    continue

                xs = []
                ys = []
                for r in subset:
                    free = float(r['free_err'])
                    gap = float(r.get('gap', '0'))
                    # Compute ratio if not in enriched
                    n_cells = 2 ** int(r['depth'])
                    q = int(r['q'])
                    d = int(r['depth'])
                    ld = ld_val == 'True'
                    n_params = 1 + 2 * q * d if ld else 1 + 2 * q
                    ratio = n_params / n_cells
                    xs.append(ratio)
                    ys.append(gap / free if free > 0 else 0)

                ld_tag = 'LD' if ld_val == 'True' else 'LI'
                label = '%s %s' % (KIND_SHORT[kind], ld_tag)
                ax.scatter(xs, ys, color=color, marker=marker,
                           s=ms_sz * 8, alpha=0.7, label=label,
                           edgecolors='none')

        ax.set_title(EXP_LABELS[exp], fontsize=12, fontweight='bold')
        ax.set_xlabel('param-to-cell ratio', fontsize=9)
        ax.set_xscale('log')
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=8)

        if col == 0:
            ax.set_ylabel('gap / free_err', fontsize=9)
        if col == 2:
            ax.legend(fontsize=5.5, ncol=2, loc='best')

    fig.suptitle(
        'Cross-exponent wall structure: gap/free vs parameter ratio\n'
        '4 partition kinds, LI and LD, across exponents 1/3, 1/2, 2/3',
        fontsize=13, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# -- Main ------------------------------------------------------------------

print()
print("Exponent robustness visualization...")
make_plot()
print("Done.")
