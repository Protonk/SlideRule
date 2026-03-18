"""
many_steps_miss.sage — Chord slope step functions at multiple resolutions.

Overlays the uniform-partition step function sigma_j - 1 for
N = 8, 16, 32, 64 on a single plot.  The continuous limit curve
1/(m ln 2) - 1 and the m* = 1/ln 2 crossing are shown for reference.
As N grows the steps get finer but they all miss the exact crossing
in the same way — the step edges never land on m*.

Run:  ./sagew experiments/chord_error/tilt/many_steps_miss.sage
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

DEPTHS = [3, 4, 5, 6]   # N = 8, 16, 32, 64


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def build_steps(depth):
    cells = float_cells(depth, 'uniform_x')
    slopes = []
    for a, b in cells:
        slopes.append(cell_chord_slope(a, b) - 1.0)

    step_x = [cells[0][0]]
    step_y = [slopes[0]]
    for i, (a, b) in enumerate(cells):
        step_x.append(b)
        step_y.append(slopes[i])

    return np.array(step_x), np.array(step_y)


# ── Plot ─────────────────────────────────────────────────────────────

COLORS = ['#e67e22', '#e74c3c', '#3498db', '#2ecc71']
ALPHAS = [1.0, 0.6, 0.4, 0.3]
WIDTHS = [2.0, 1.4, 1.0, 0.7]


def make_plot():
    fig, ax = plt.subplots(figsize=(9, 4), constrained_layout=True)

    m_star = 1.0 / log(2.0)

    # Continuous limit
    ms_cont = np.linspace(1.0, 2.0, 400)
    ax.plot(ms_cont, 1.0 / (ms_cont * log(2.0)) - 1.0,
            '--', color='#cccccc', linewidth=1.4, zorder=1,
            label=r'$1/(m \ln 2) - 1$')

    # Step functions, coarsest on top
    for i, depth in enumerate(DEPTHS):
        N = 2**depth
        sx, sy = build_steps(depth)
        ax.step(sx, sy, where='post',
                color=COLORS[i], linewidth=WIDTHS[i], alpha=ALPHAS[i],
                zorder=10 - i, label='$N = %d$' % N)

    # Vertical crossing line
    ax.axvline(m_star, color='#888888', linewidth=1.0, linestyle=':',
               zorder=1)

    ax.annotate(
        r'$m^* = 1/\ln 2$',
        xy=(m_star, 0),
        xytext=(m_star - 0.30, -0.18),
        fontsize=9, color='#555555',
        arrowprops=dict(arrowstyle='->', color='#888888', lw=0.8),
    )

    ax.set_ylabel(r'chord slope deviation  $\sigma_j - 1$', fontsize=10)
    ax.set_xlabel('$m$', fontsize=10)
    ax.tick_params(labelsize=8)
    ax.legend(fontsize=8, loc='upper right')

    fig.suptitle(
        'Uniform step functions converge to the continuous slope '
        r'but all miss $m^*$' '\n'
        '$N \\in \\{8,\\, 16,\\, 32,\\, 64\\}$ on $[1,\\, 2)$',
        fontsize=12, fontweight='bold',
    )

    out_path = 'experiments/chord_error/tilt/many_steps_miss.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

make_plot()
print("Done.")
