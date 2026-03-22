"""
scaling_summary.sage — G15: Scaling law summary across core partitions.

Combined plot of free_err, opt_err, and wall vs depth for the three core
partitions (geometric, uniform, harmonic), under both LI and LD
parameterisation. The single most-asked question about the project.

Run:  ./sagew experiments/keystone/scaling_summary.sage
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

SUMMARY_PATHS = [
    pathing('experiments', 'keystone', 'results',
            'wall_surface_2026-03-18', 'summary.csv'),
    pathing('experiments', 'wall', 'results', 'enriched_summary.csv'),
]

OUT_PATH = pathing('experiments', 'keystone', 'results',
                    'scaling_summary.png')

CORE_KINDS = ['uniform_x', 'geometric_x', 'harmonic_x']
EXPONENT = '1/2'

KIND_COLORS = {
    'uniform_x':   '#1f77b4',
    'geometric_x': '#9467bd',
    'harmonic_x':  '#2ca02c',
}
KIND_SHORT = {
    'uniform_x':   'uniform',
    'geometric_x': 'geometric',
    'harmonic_x':  'harmonic',
}


# -- Load data ------------------------------------------------------------

def load_rows():
    """Load and deduplicate summary rows from available CSVs."""
    all_rows = []
    for path in SUMMARY_PATHS:
        if not os.path.exists(path):
            continue
        with open(path, 'r', newline='') as f:
            all_rows.extend(csv.DictReader(f))

    # Deduplicate by (kind, q, depth, exponent, ld)
    seen = {}
    for r in all_rows:
        key = (r['partition_kind'], r['q'], r['depth'],
               r['exponent'], r['layer_dependent'])
        seen[key] = r
    return list(seen.values())


def filter_rows(rows, kind, ld_str):
    """Filter to one (kind, exponent, layer_mode), sort by depth."""
    subset = [r for r in rows
              if r['partition_kind'] == kind
              and r['exponent'] == EXPONENT
              and r['layer_dependent'] == ld_str
              and r.get('free_err', '') != '']
    subset.sort(key=lambda r: int(r['depth']))
    return subset


# -- Plot ------------------------------------------------------------------

def make_plot():
    rows = load_rows()

    fig, axes = plt.subplots(2, 2, figsize=(13, 9), constrained_layout=True)

    for col, (ld_str, ld_label) in enumerate([('False', 'LI'), ('True', 'LD')]):
        ax_err = axes[0, col]
        ax_wall = axes[1, col]

        for kind in CORE_KINDS:
            subset = filter_rows(rows, kind, ld_str)
            if not subset:
                continue

            depths = np.array([int(r['depth']) for r in subset])
            free  = np.array([float(r['free_err']) for r in subset])
            opt   = np.array([float(r['opt_err']) for r in subset])
            single = np.array([float(r['single_err']) for r in subset])
            gap   = opt - free

            color = KIND_COLORS[kind]
            label = KIND_SHORT[kind]

            # Top: log-scale error vs depth
            ax_err.semilogy(depths, single, 's--', color=color, alpha=0.4,
                            markersize=3, linewidth=0.8)
            ax_err.semilogy(depths, opt, 'o-', color=color, alpha=0.9,
                            markersize=4, linewidth=1.5, label=label + ' opt')
            ax_err.semilogy(depths, free, '^:', color=color, alpha=0.5,
                            markersize=3, linewidth=0.8, label=label + ' free')

            # Bottom: wall fraction vs depth
            wall_frac = gap / free
            ax_wall.plot(depths, wall_frac, 'o-', color=color,
                         markersize=4, linewidth=1.5, label=label)

        ax_err.set_title('%s: error vs depth' % ld_label, fontsize=11,
                         fontweight='bold')
        ax_err.set_ylabel('Worst-case error (log scale)', fontsize=9)
        ax_err.grid(True, alpha=0.3, linewidth=0.5)
        ax_err.legend(fontsize=7, ncol=2)
        ax_err.tick_params(labelsize=8)

        ax_wall.set_title('%s: wall fraction vs depth' % ld_label, fontsize=11,
                          fontweight='bold')
        ax_wall.set_xlabel('Depth $d$', fontsize=9)
        ax_wall.set_ylabel('gap / free_err', fontsize=9)
        ax_wall.grid(True, alpha=0.3, linewidth=0.5)
        ax_wall.legend(fontsize=7)
        ax_wall.tick_params(labelsize=8)

    fig.suptitle(
        'Scaling summary: error and wall fraction across depth\n'
        'exponent = %s, core partitions' % EXPONENT,
        fontsize=13, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# -- Main ------------------------------------------------------------------

print()
print("Scaling summary: loading data and plotting...")
make_plot()
print("Done.")
