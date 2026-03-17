"""
curvature_mismatch.sage — Cell width vs locally optimal width for all sixteen
partition kinds.

Sixteen panels (4x4 grid).  Each panel plots one dot per cell at
(m_peak, mismatch_ratio) where mismatch_ratio = actual_width / optimal_width.
The optimal width at position m is m * ln(2) / N (the geometric cell width).
Points above y=1 are under-resolved; points below are over-resolved.

Run:  ./sagew experiments/chord_error/zoo/curvature_mismatch.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 9   # N = 512


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
    fig, axes = plt.subplots(4, 4, figsize=(18, 14),
                             sharey=False,
                             constrained_layout=True)

    for ax, (name, color, kind) in zip(axes.flat, PARTITION_ZOO):
        cells = float_cells(DEPTH, kind)
        m_peaks = []
        ratios = []

        for a, b in cells:
            m_pk, r = cell_mismatch(a, b, N)
            m_peaks.append(m_pk)
            ratios.append(r)

        ax.scatter(m_peaks, ratios, c=color, s=12, alpha=0.6,
                   edgecolors='none', zorder=3)

        ax.axhline(1.0, color='#999999', linewidth=0.8, linestyle='--',
                   zorder=1)
        ax.set_yscale('log')
        ax.set_xlim(1.0, 2.0)
        ax.tick_params(labelsize=6)

        ax.set_title(name, fontsize=9, fontweight='bold')

    for ax in axes[:, 0]:
        ax.set_ylabel('width / optimal width', fontsize=8)
    for ax in axes[3, :]:
        ax.set_xlabel('$m_{\\mathrm{peak}}$', fontsize=8)

    fig.suptitle(
        'Curvature mismatch: cell width / locally optimal width\n'
        '$N = %d$ cells on $[1,\\, 2)$, $y = 1$ is geometric (equioscillation)' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/chord_error/zoo/curvature_mismatch.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    N = 2**DEPTH
    print()
    print("Curvature mismatch diagnostics")
    print("=" * 60)
    print("  N = %d" % N)
    for name, _, kind in PARTITION_ZOO:
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
