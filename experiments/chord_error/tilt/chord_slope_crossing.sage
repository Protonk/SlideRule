"""
chord_slope_crossing.sage — Cell chord slope across the uniform partition.

Shows the per-cell chord slope sigma_j as a step function across [1, 2].
Cells on the left have steeper chords than the global chord (sigma > 1);
cells on the right have shallower chords (sigma < 1).  The crossover
happens at m* = 1/ln 2, the peak of the global approximation error.

Run:  ./sagew experiments/error/tilt/chord_slope_crossing.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

N = 8
M_PER_CELL = 20


# ── Partition ────────────────────────────────────────────────────────

def uniform_partition(N):
    return [(1.0 + j / N, 1.0 + (j + 1) / N) for j in range(N)]


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def build_profiles(cells):
    """Build the per-cell error sawtooth and tilt slope step function."""
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
    assert E_all.min() > -1e-14, f"negative E, min = {E_all.min():.2e}"
    for i, (a, b) in enumerate(cells):
        idx_lo = i * M_PER_CELL
        idx_hi = (i + 1) * M_PER_CELL - 1
        assert abs(E_all[idx_lo]) < 1e-13, f"cell {i}: E(a) != 0"
        assert abs(E_all[idx_hi]) < 1e-13, f"cell {i}: E(b) != 0"

    # Peak envelope must be monotonically decreasing (curvature falls with m).
    for i in range(len(peak_Es) - 1):
        assert peak_Es[i] >= peak_Es[i + 1], (
            f"peak envelope not decreasing: cell {i} ({peak_Es[i]:.4e}) "
            f"< cell {i+1} ({peak_Es[i+1]:.4e})")

    # Peak ratio should approach 4:1 from below.  At N=8 it's ~3.3.
    ratio = peak_Es.max() / peak_Es.min()
    assert 2.5 < ratio < 4.0, f"peak ratio {ratio:.4f} outside expected range (2.5, 4.0)"


# ── Plotting ─────────────────────────────────────────────────────────

def make_plot():
    cells = uniform_partition(N)
    m_all, E_all, midpoints, slopes, peak_ms, peak_Es = build_profiles(cells)
    verify(cells, m_all, E_all, peak_Es)

    fig, ax = plt.subplots(figsize=(9, 4), constrained_layout=True)

    # Continuous limit: 1/(m ln 2) - 1, the chord slope deviation in the
    # small-cell limit.
    ms_cont = np.linspace(1.0, 2.0, 300)
    ax.plot(ms_cont, 1.0 / (ms_cont * log(2.0)) - 1.0,
            '--', color='#cccccc', linewidth=1.2, zorder=1)

    # Step function via ax.step with vertical risers.
    # Build boundary x-values and slope values for a "post" step plot.
    step_x = [cells[0][0]]
    step_y = [slopes[0]]
    for i, (a, b) in enumerate(cells):
        step_x.append(b)
        step_y.append(slopes[i])
    ax.step(step_x, step_y, where='post', color='#e67e22', linewidth=1.8,
            zorder=2)

    ax.axhline(0, color='black', linewidth=0.8, linestyle='--', zorder=1)

    # m* = 1/ln 2 crossing
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
        f'Uniform partition, $N = {N}$ cells on $[1,\\, 2)$',
        fontsize=12, fontweight='bold',
    )

    out_path = 'experiments/error/tilt/chord_slope_crossing.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    cells = uniform_partition(N)
    m_all, E_all, midpoints, slopes, peak_ms, peak_Es = build_profiles(cells)
    verify(cells, m_all, E_all, peak_Es)

    ratio = peak_Es.max() / peak_Es.min()
    print()
    print("Tilt profile diagnostics  (uniform)")
    print("=" * 50)
    print(f"  N = {N}")
    print(f"  tilt slope range: [{slopes.min():+.4f}, {slopes.max():+.4f}]")
    print(f"  zero crossing:    m ~ {midpoints[np.argmin(np.abs(slopes))]:.4f}")
    print(f"  max peak E:       {peak_Es.max():.6e}")
    print(f"  min peak E:       {peak_Es.min():.6e}")
    print(f"  peak ratio:       {ratio:.2f}:1")
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
