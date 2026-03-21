"""
curvature_mismatch.sage — Cell width vs locally optimal width for a curated
set of representative partition families.

Sixteen panels (4x4 grid). Each panel plots one dot per cell at
(m_peak, mismatch_ratio) where mismatch_ratio = actual_width / optimal_width.
The optimal width at position m is m * ln(2) / N (the geometric cell width).
Points above y=1 are under-resolved; points below are over-resolved.

Run:  ./sagew experiments/stepstone/profiles/curvature_mismatch.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 10   # N = 1024

CURATED_KINDS = [
    'bitrev_geometric_x',
    'dyadic_x',
    'uniform_x',
    'harmonic_x',
    'mirror_harmonic_x',
    'reverse_geometric_x',
    'powerlaw_x',
    'beta_x',
    'chebyshev_x',
    'sinusoidal_x',
    'ruler_x',
    'thuemorse_x',
    'golden_x',
    'stern_brocot_x',
    'arc_length_x',
    'minimax_chord_x',
]

_zoo_by_kind = {kind: (name, color, kind) for name, color, kind in PARTITION_ZOO}
CURATED_ZOO = [_zoo_by_kind[kind] for kind in CURATED_KINDS]


# ── Math ─────────────────────────────────────────────────────────────

def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def cell_mismatch(a, b, N):
    m_pk = log_mean(a, b)
    actual_width = b - a
    optimal_width = m_pk * log(2) / N
    return m_pk, actual_width / optimal_width


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    N = 2**DEPTH
    n_rows, n_cols = zoo_grid_shape(CURATED_ZOO)
    fig, axes = plt.subplots(
        n_rows,
        n_cols,
        figsize=(n_cols * 4.6, n_rows * 3.6),
        constrained_layout=True,
        sharey=False,
    )

    for ax, (name, color, kind) in zip(axes.flat, CURATED_ZOO):
        cells = float_cells(DEPTH, kind)
        m_peaks = []
        ratios = []

        for a, b in cells:
            m_pk, r = cell_mismatch(a, b, N)
            m_peaks.append(m_pk)
            ratios.append(r)

        ax.scatter(m_peaks, ratios, c=color, s=10, alpha=0.65,
                   edgecolors='none', zorder=3)

        ax.axhline(1.0, color='#999999', linewidth=0.8, linestyle='--',
                   zorder=1)
        ax.set_yscale('log')
        ax.set_xlim(1.0, 2.0)
        ax.tick_params(labelsize=6)

        ax.set_title(name, fontsize=9, fontweight='bold')

    zoo_label_edges(axes, ylabel='width / optimal width',
                    xlabel='$m_{\\mathrm{peak}}$')

    fig.suptitle(
        'Curvature mismatch for representative partition families\n'
        '$N = %d$ cells on $[1,\\, 2)$, $y = 1$ is the geometric local optimum' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/stepstone/profiles/results/curvature_mismatch.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    N = 2**DEPTH
    print()
    print("Curvature mismatch diagnostics (curated set)")
    print("=" * 60)
    print("  N = %d" % N)
    for name, _, kind in CURATED_ZOO:
        cells = float_cells(DEPTH, kind)
        log2_ratios = []
        for a, b in cells:
            _, r = cell_mismatch(a, b, N)
            log2_ratios.append(math_log2(r))

        arr = np.array(log2_ratios)
        print("  %-18s  log2(ratio): [%+.4f, %+.4f]  std=%.4f" %
              (name, arr.min(), arr.max(), arr.std()))

    # Verification: geometric should be within 5% of 1.0
    print()
    geo_cells = float_cells(DEPTH, 'geometric_x')
    geo_max_dev = 0.0
    for a, b in geo_cells:
        _, r = cell_mismatch(a, b, N)
        geo_max_dev = max(geo_max_dev, abs(r - 1.0))
    print("  Geometric max deviation from 1.0: %.6f (%.2f%%)" %
          (geo_max_dev, 100 * geo_max_dev))
    assert geo_max_dev < 0.05, (
        "Geometric mismatch exceeds 5%%: %.4f" % geo_max_dev)
    print("  PASS: geometric within 5%% tolerance")
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
