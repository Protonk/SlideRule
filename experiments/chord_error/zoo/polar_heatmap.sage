"""
polar_heatmap.sage — Per-cell error heatmaps in polar coordinates.

Each panel wraps the heatmap around a circle: angle = rescaled coordinate
t in [0, 2*pi], radius = cell index j, color = E(t).  Geometric gives
uniform concentric rings; non-geometric partitions show asymmetric or
barcode-like ring patterns.

Run:  ./sagew experiments/chord_error/zoo/polar_heatmap.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from math import log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 6   # N = 64
M = 200     # angular resolution per arch


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def rescaled_arch(a, b):
    sigma = cell_chord_slope(a, b)
    t = np.linspace(0, 1, M)
    m = a + t * (b - a)
    chord = math_log2(a) + sigma * (m - a)
    E = np.log2(m) - chord
    return t, E


def build_heatmap(cells):
    img = np.zeros((len(cells), M))
    for j, (a, b) in enumerate(cells):
        _, E = rescaled_arch(a, b)
        img[j, :] = E
    return img


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    N = 2**DEPTH
    fig, axes = plt.subplots(4, 4, figsize=(18, 18),
                             subplot_kw={'projection': 'polar'},
                             constrained_layout=True)

    for ax, (name, _, kind) in zip(axes.flat, PARTITION_ZOO):
        cells = float_cells(DEPTH, kind)
        img = build_heatmap(cells)

        theta_edges = np.linspace(0, 2 * np.pi, M + 1)
        r_edges = np.arange(N + 1)
        Theta, R = np.meshgrid(theta_edges, r_edges)

        pos = img[img > 0]
        if len(pos) > 0:
            vmax = pos.max()
            vmin = max(pos.min(), vmax * 1e-6)
            norm = mcolors.LogNorm(vmin=vmin, vmax=vmax)
        else:
            norm = None

        ax.pcolormesh(Theta, R, img, cmap='inferno', norm=norm,
                      shading='flat')

        ax.set_rlabel_position(0)
        ax.tick_params(labelsize=5)
        ax.set_thetagrids([0, 90, 180, 270],
                          ['$t{=}0$', '$0.25$', '$0.5$', '$0.75$'],
                          fontsize=5, color='#666666')
        ax.yaxis.set_major_formatter(plt.NullFormatter())
        ax.grid(True, linewidth=0.2, alpha=0.3)

        peak_vals = img.max(axis=1)
        ratio = peak_vals.max() / peak_vals.min() if peak_vals.min() > 0 else float('inf')
        ax.set_title('%s: %.2f:1' % (name, ratio),
                     fontsize=9, fontweight='bold', pad=12)

    fig.suptitle(
        'Polar heatmaps: per-cell error wrapped around the circle\n'
        '$N = %d$, $\\theta = 2\\pi t$, $r =$ cell index, log color scale' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/chord_error/zoo/polar_heatmap.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

make_plot()
print("Done.")
