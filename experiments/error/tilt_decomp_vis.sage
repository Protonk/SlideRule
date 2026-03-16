"""
tilt_decomp_vis.sage — Tilt profile across the full domain (uniform only).

Top panel: per-cell error E(m) as a 100-tooth sawtooth with peak envelope.
Teeth are taller on the left (front-loaded curvature).

Bottom panel: tilt slope (sigma_j - 1) step function showing each cell's
chord slope deviation from the global chord.

Run:  ./sagew experiments/error/tilt_decomp_vis.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

N = 100
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

def verify(cells, m_all, E_all):
    assert E_all.min() > -1e-14, f"negative E, min = {E_all.min():.2e}"
    for i, (a, b) in enumerate(cells):
        idx_lo = i * M_PER_CELL
        idx_hi = (i + 1) * M_PER_CELL - 1
        assert abs(E_all[idx_lo]) < 1e-13, f"cell {i}: E(a) != 0"
        assert abs(E_all[idx_hi]) < 1e-13, f"cell {i}: E(b) != 0"


# ── Plotting ─────────────────────────────────────────────────────────

def make_plot():
    cells = uniform_partition(N)
    m_all, E_all, midpoints, slopes, peak_ms, peak_Es = build_profiles(cells)
    verify(cells, m_all, E_all)

    fig, (ax_top, ax_bot) = plt.subplots(
        2, 1,
        figsize=(8, 6),
        gridspec_kw={'height_ratios': [2, 1]},
        sharex=True,
    )

    # ── Top: E(m) sawtooth ───────────────────────────────────────────

    ax_top.fill_between(m_all, 0, E_all, color='#1f77b4', alpha=0.4)
    ax_top.plot(m_all, E_all, '-', color='#1f77b4', linewidth=0.3)
    ax_top.plot(peak_ms, peak_Es, '-', color='#d62728', linewidth=1.5,
                label='peak envelope')

    ax_top.set_ylim(0, peak_Es.max() * 1.15)
    ax_top.set_ylabel('per-cell error $E(m)$', fontsize=10)
    ax_top.tick_params(labelsize=8)
    ax_top.legend(fontsize=8, loc='upper right')

    ratio = peak_Es.max() / peak_Es.min()
    ax_top.text(
        0.03, 0.88,
        f'peak ratio: {ratio:.2f}:1',
        transform=ax_top.transAxes, fontsize=9,
        bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                  edgecolor='#888888', alpha=0.8),
    )

    # ── Bottom: tilt slope ───────────────────────────────────────────

    for i, (a, b) in enumerate(cells):
        ax_bot.plot([a, b], [slopes[i], slopes[i]], '-',
                    color='#e67e22', linewidth=1.2)

    ax_bot.axhline(0, color='black', linewidth=0.8, linestyle='--')
    ax_bot.set_ylabel(r'tilt slope ($\sigma - 1$)', fontsize=10)
    ax_bot.set_xlabel('m', fontsize=10)
    ax_bot.tick_params(labelsize=8)

    zero_idx = np.argmin(np.abs(slopes))
    ax_bot.annotate(
        f'$\\sigma = 1$ near m = {midpoints[zero_idx]:.2f}',
        xy=(midpoints[zero_idx], 0),
        xytext=(midpoints[zero_idx] + 0.15, slopes.max() * 0.5),
        fontsize=8, color='#e67e22',
        arrowprops=dict(arrowstyle='->', color='#e67e22', lw=0.8),
    )

    fig.suptitle(
        f'Tilt decomposition — uniform partition, N = {N}',
        fontsize=12, fontweight='bold',
    )
    fig.tight_layout(rect=[0, 0, 1, 0.96])

    out_path = 'experiments/error/tilt_decomp.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    cells = uniform_partition(N)
    m_all, E_all, midpoints, slopes, peak_ms, peak_Es = build_profiles(cells)
    verify(cells, m_all, E_all)

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
