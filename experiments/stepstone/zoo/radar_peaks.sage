"""
radar_peaks.sage — Radar plot of per-cell peak errors for a curated set of
sixteen visually distinct partition families.

Each cell gets its own angular slice; the radius is E_peak. Geometric gives a
perfect circle; smooth monotone families give eggs and commas; scrambled
families give starbursts.

Run:  ./sagew experiments/stepstone/zoo/radar_peaks.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 6   # N = 64

CURATED_KINDS = [
    'geometric_x',
    'mirror_harmonic_x',
    'random_x',
    'chebyshev_x',

    'harmonic_x',
    'golden_x',
    'dyadic_x',
    'ruler_x',

    'sturmian_x',
    'bitrev_geometric_x',
    'powerlaw_x',
    'minimax_chord_x',

    'uniform_x',
    'beta_x',
    'thuemorse_x',
    'sinusoidal_x',
]

_zoo_by_kind = {kind: (name, color, kind) for name, color, kind in PARTITION_ZOO}
CURATED_ZOO = [_zoo_by_kind[kind] for kind in CURATED_KINDS]


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def peak_E(a, b):
    sigma = cell_chord_slope(a, b)
    m_pk = log_mean(a, b)
    return math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    N = 2**DEPTH
    q1 = N // 4
    q2 = N // 2
    q3 = 3 * N // 4

    n_rows, n_cols = zoo_grid_shape(CURATED_ZOO)
    fig, axes = plt.subplots(
        n_rows,
        n_cols,
        figsize=(n_cols * 4.5, n_rows * 4.5),
        constrained_layout=True,
        subplot_kw={'projection': 'polar'},
    )

    for ax, (name, color, kind) in zip(axes.flat, CURATED_ZOO):
        cells = float_cells(DEPTH, kind)
        peaks = np.array([peak_E(a, b) for a, b in cells])

        theta = np.linspace(0, 2 * np.pi, N, endpoint=False)
        theta_closed = np.append(theta, theta[0])
        peaks_closed = np.append(peaks, peaks[0])

        ax.fill(theta_closed, peaks_closed, color=color, alpha=0.25)
        ax.plot(theta_closed, peaks_closed, '-', color=color, linewidth=1.2)

        geo_peak = peak_E(2.0**(0.0 / N), 2.0**(1.0 / N))
        ax.plot(np.linspace(0, 2 * np.pi, 200), [geo_peak] * 200,
                '--', color='#999999', linewidth=0.7)

        ax.set_rlabel_position(0)
        ax.tick_params(labelsize=5)
        ax.set_thetagrids([0, 90, 180, 270],
                          ['cell 0', 'cell %d' % q1,
                           'cell %d' % q2, 'cell %d' % q3],
                          fontsize=5, color='#666666')
        ax.yaxis.set_major_formatter(plt.NullFormatter())
        ax.grid(True, linewidth=0.3, alpha=0.5)

        ratio = peaks.max() / peaks.min() if peaks.min() > 0 else float('inf')
        ax.set_title('%s: %.2f:1' % (name, ratio),
                     fontsize=9, fontweight='bold', pad=12)

    fig.suptitle(
        'Radar: per-cell peak error by cell index for representative families\n'
        '$N = %d$ cells on $[1,\\, 2)$, dashed circle = geometric reference' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/stepstone/zoo/radar_peaks.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    N = 2**DEPTH
    print()
    print("Radar peaks diagnostics (curated set)")
    print("=" * 60)
    print("  N = %d" % N)
    geo_peak = peak_E(2.0**(0.0 / N), 2.0**(1.0 / N))
    print("  geometric reference peak: %.6e" % geo_peak)
    for name, _, kind in CURATED_ZOO:
        cells = float_cells(DEPTH, kind)
        peaks = [peak_E(a, b) for a, b in cells]
        ratio = max(peaks) / min(peaks) if min(peaks) > 0 else float('inf')
        print("  %-18s  range: %.4e .. %.4e  ratio=%.2f:1" %
              (name, min(peaks), max(peaks), ratio))
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
