"""
radar_peaks.sage — Radar plot of per-cell peak errors for all sixteen partitions.

Each cell gets its own angular slice; the radius is E_peak.  Geometric gives a
perfect circle; uniform gives an egg; scrambled partitions give starbursts.

Run:  ./sagew experiments/chord_error/zoo/radar_peaks.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 6   # N = 64


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

    _n_rows, _n_cols = zoo_grid_shape()
    fig, axes = plt.subplots(_n_rows, _n_cols,
                             figsize=(4.5 * _n_cols, 4.5 * _n_rows),
                             subplot_kw={'projection': 'polar'},
                             constrained_layout=True)

    for ax, (name, color, kind) in zip(axes.flat, PARTITION_ZOO):
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

    for ax in axes.flat[len(PARTITION_ZOO):]:
        ax.set_visible(False)

    fig.suptitle(
        'Radar: per-cell peak error by cell index\n'
        '$N = %d$ cells on $[1,\\, 2)$, dashed circle = geometric reference' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/chord_error/zoo/radar_peaks.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    N = 2**DEPTH
    print()
    print("Radar peaks diagnostics")
    print("=" * 60)
    print("  N = %d" % N)
    geo_peak = peak_E(2.0**(0.0 / N), 2.0**(1.0 / N))
    print("  geometric reference peak: %.6e" % geo_peak)
    for name, _, kind in PARTITION_ZOO:
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
