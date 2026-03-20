"""
chord_slope_crossing.sage — Cell chord slope across the uniform partition.

Shows the per-cell chord slope sigma_j as a step function across [1, 2].
Cells on the left have steeper chords than the global chord (sigma > 1);
cells on the right have shallower chords (sigma < 1).  The crossover
happens at m* = 1/ln 2, the peak of the global approximation error.

Run:  ./sagew experiments/stepstone/chord_slope_crossing.sage
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

DEPTH = 3       # N = 8
M_PER_CELL = 20


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def build_profiles(cells):
    m_segments = []
    E_segments = []
    midpoints = []
    slopes = []
    peak_ms = []
    peak_Es = []

    for a, b in cells:
        sigma = cell_chord_slope(a, b)
        ms = np.linspace(a, b, M_PER_CELL)
        chord_vals = math_log2(a) + sigma * (ms - a)
        E_vals = np.log2(ms) - chord_vals

        m_segments.append(ms)
        E_segments.append(E_vals)
        midpoints.append((a + b) / 2.0)
        slopes.append(sigma - 1.0)

        m_pk = log_mean(a, b)
        E_pk = math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))
        peak_ms.append(m_pk)
        peak_Es.append(E_pk)

    m_all = np.concatenate(m_segments)
    E_all = np.concatenate(E_segments)

    return (m_all, E_all,
            np.array(midpoints), np.array(slopes),
            np.array(peak_ms), np.array(peak_Es))


# ── Verification ─────────────────────────────────────────────────────

def verify(cells, m_all, E_all, peak_Es):
    assert E_all.min() > -1e-14, "negative E, min = %.2e" % E_all.min()
    for i, (a, b) in enumerate(cells):
        idx_lo = i * M_PER_CELL
        idx_hi = (i + 1) * M_PER_CELL - 1
        assert abs(E_all[idx_lo]) < 1e-13, "cell %d: E(a) != 0" % i
        assert abs(E_all[idx_hi]) < 1e-13, "cell %d: E(b) != 0" % i

    for i in range(len(peak_Es) - 1):
        assert peak_Es[i] >= peak_Es[i + 1], (
            "peak envelope not decreasing: cell %d (%.4e) < cell %d (%.4e)" %
            (i, peak_Es[i], i + 1, peak_Es[i + 1]))

    ratio = peak_Es.max() / peak_Es.min()
    assert 2.5 < ratio < 4.0, "peak ratio %.4f outside expected range (2.5, 4.0)" % ratio


# ── Plotting ─────────────────────────────────────────────────────────

def make_plot():
    N = 2**DEPTH
    cells = float_cells(DEPTH, 'uniform_x')
    m_all, E_all, midpoints, slopes, peak_ms, peak_Es = build_profiles(cells)
    verify(cells, m_all, E_all, peak_Es)

    fig, ax = plt.subplots(figsize=(9, 4), constrained_layout=True)

    ms_cont = np.linspace(1.0, 2.0, 300)
    ax.plot(ms_cont, 1.0 / (ms_cont * log(2.0)) - 1.0,
            '--', color='#cccccc', linewidth=1.2, zorder=1)

    step_x = [cells[0][0]]
    step_y = [slopes[0]]
    for i, (a, b) in enumerate(cells):
        step_x.append(b)
        step_y.append(slopes[i])
    ax.step(step_x, step_y, where='post', color='#e67e22', linewidth=1.8,
            zorder=2)

    ax.axhline(0, color='black', linewidth=0.8, linestyle='--', zorder=1)

    m_star = 1.0 / log(2.0)
    ax.axvline(m_star, color='#888888', linewidth=1.0, linestyle=':',
               zorder=1)
    ax.annotate(
        r'$m^* = 1/\ln 2$',
        xy=(m_star, 0),
        xytext=(m_star + 0.25, slopes.max() * 0.6),
        fontsize=9, color='#555555',
        arrowprops=dict(arrowstyle='->', color='#888888', lw=0.8),
    )

    ax.set_ylabel(r'chord slope deviation  $\sigma_j - 1$', fontsize=10)
    ax.set_xlabel('$m$', fontsize=10)
    ax.tick_params(labelsize=8)

    fig.suptitle(
        'Cell chord slopes cross the global slope at $m^* = 1/\\ln 2$\n'
        'Uniform partition, $N = %d$ cells on $[1,\\, 2)$' % N,
        fontsize=12, fontweight='bold',
    )

    out_path = 'experiments/stepstone/results/chord_slope_crossing.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    N = 2**DEPTH
    cells = float_cells(DEPTH, 'uniform_x')
    m_all, E_all, midpoints, slopes, peak_ms, peak_Es = build_profiles(cells)
    verify(cells, m_all, E_all, peak_Es)

    ratio = peak_Es.max() / peak_Es.min()
    print()
    print("Tilt profile diagnostics  (uniform)")
    print("=" * 50)
    print("  N = %d" % N)
    print("  tilt slope range: [%+.4f, %+.4f]" % (slopes.min(), slopes.max()))
    print("  zero crossing:    m ~ %.4f" % midpoints[np.argmin(np.abs(slopes))])
    print("  max peak E:       %.6e" % peak_Es.max())
    print("  min peak E:       %.6e" % peak_Es.min())
    print("  peak ratio:       %.2f:1" % ratio)
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
