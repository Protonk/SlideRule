"""
superimposed_arches_vis.sage — All per-cell error arches rescaled to [0, 1].

Two panels: uniform (fan of arches) vs geometric (complete overlap).
Each arch is the per-cell chord error E_j(t) where t = (m - a)/(b - a).
Colored by cell position: dark = near m=1, bright = near m=2.

Run:  ./sagew experiments/error/superimposed_arches_vis.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

N = 32
M = 200  # points per arch


# ── Partitions ───────────────────────────────────────────────────────

def uniform_partition(N):
    return [(1.0 + j / N, 1.0 + (j + 1) / N) for j in range(N)]


def geometric_partition(N):
    return [(2.0 ** (j / N), 2.0 ** ((j + 1) / N)) for j in range(N)]


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def rescaled_arch(a, b):
    """Return (t, E) arrays for the rescaled per-cell error on [0, 1]."""
    sigma = cell_chord_slope(a, b)
    t = np.linspace(0, 1, M)
    m = a + t * (b - a)
    chord = math_log2(a) + sigma * (m - a)
    E = np.log2(m) - chord
    return t, E


def peak_info(a, b):
    """Return (t_peak, E_peak) in rescaled coordinates."""
    sigma = cell_chord_slope(a, b)
    m_pk = log_mean(a, b)
    t_pk = (m_pk - a) / (b - a)
    E_pk = math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))
    return t_pk, E_pk


# ── Plotting ─────────────────────────────────────────────────────────

def make_plot():
    fig, (ax_u, ax_g) = plt.subplots(1, 2, figsize=(11, 5), sharey=True)
    cmap = cm.viridis

    for ax, kind, builder in [
        (ax_u, 'uniform', uniform_partition),
        (ax_g, 'geometric', geometric_partition),
    ]:
        cells = builder(N)
        peak_Es = []

        lw = 0.6 if kind == 'uniform' else 0.9
        for j, (a, b) in enumerate(cells):
            color = cmap(j / (N - 1))
            t, E = rescaled_arch(a, b)
            ax.plot(t, E, '-', color=color, linewidth=lw, alpha=0.8)
            _, E_pk = peak_info(a, b)
            peak_Es.append(E_pk)

        ratio = max(peak_Es) / min(peak_Es)
        ax.set_title(f'{kind}  (peak ratio {ratio:.2f}:1)',
                     fontsize=10, fontweight='bold')
        ax.tick_params(labelsize=8)
        ax.axhline(0, color='black', linewidth=0.4)

    ax_u.set_ylabel('per-cell error $E(t)$', fontsize=10)

    fig.supxlabel('t = (m − a) / (b − a)', fontsize=10)

    fig.suptitle(
        f'Per-cell error arches rescaled to [0, 1]   (N = {N})',
        fontsize=12, fontweight='bold',
    )
    fig.tight_layout(rect=[0, 0.04, 1, 0.95])

    out_path = 'experiments/error/superimposed_arches.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Superimposed arches diagnostics")
    print("=" * 50)

    for kind, builder in [('uniform', uniform_partition),
                           ('geometric', geometric_partition)]:
        cells = builder(N)
        peaks = [peak_info(a, b)[1] for a, b in cells]
        ratio = max(peaks) / min(peaks)
        print(f"\n  {kind}  (N = {N})")
        print(f"    max peak: {max(peaks):.6e}")
        print(f"    min peak: {min(peaks):.6e}")
        print(f"    ratio:    {ratio:.4f}:1")

    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
