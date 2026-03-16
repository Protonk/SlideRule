"""
error_trident_vis.sage — The error trident visualization.

For each cell in a partition of [1, 2], three bars show:
  Gray:   global chord error (the single chord m - 1, evaluated locally)
  Red:    exported damage (median peak error of this cell's chord on all
          other cells)
  Blue:   incoming damage (median peak error of all other cells' chords
          on this cell)

The red and blue bars aggregate the same matrix e_{j->k} along different
axes.  Red is the row median (how bad is cell j for others); blue is the
column median (how bad are others for cell k).

Displays a vertical stack of panels for increasing N, with uniform and
geometric partitions side by side.

See visualizations/ERROR-TRIDENT-PLAN.md for the mathematical framework.

Run:  ./sagew experiments/error/error_trident_vis.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2


# ── Partition builders ───────────────────────────────────────────────

def uniform_partition(N):
    """Return list of (a_j, b_j) for uniform partition of [1, 2]."""
    return [(1.0 + j / N, 1.0 + (j + 1) / N) for j in range(N)]


def geometric_partition(N):
    """Return list of (a_j, b_j) for geometric partition of [1, 2]."""
    return [(2.0 ** (j / N), 2.0 ** ((j + 1) / N)) for j in range(N)]


# ── Per-cell chord ───────────────────────────────────────────────────

def cell_chord(a, b):
    """Return (sigma, intercept, a) for the chord of log2 on [a, b].

    chord(m) = intercept + sigma * (m - a)  =  log2(a) + sigma * (m - a)
    """
    la, lb = log2(a), log2(b)
    sigma = (lb - la) / (b - a)
    return sigma, la


def chord_eval(sigma, intercept, a, m):
    """Evaluate chord at m.  chord(m) = intercept + sigma * (m - a)."""
    return intercept + sigma * (m - a)


# ── Gray bar: global chord error ─────────────────────────────────────

def _global_eps(m):
    """Global chord error: log2(m) - (m - 1)."""
    return log2(m) - (m - 1.0)

_M_STAR = 1.0 / log(2.0)


def gray_bar(a, b):
    """Peak of |log2(m) - (m-1)| on [a, b]."""
    if a <= _M_STAR <= b:
        return _global_eps(_M_STAR)
    elif _M_STAR < a:
        return _global_eps(a)
    else:
        return _global_eps(b)


# ── Foreign error matrix ─────────────────────────────────────────────

def _foreign_peak_error(sigma_j, intercept_j, a_j, a_k, b_k):
    """Peak of |log2(m) - chord_j(m)| on cell [a_k, b_k].

    f(m) = log2(m) - chord_j(m) is concave with stationary point at
    m*_j = 1 / (sigma_j * ln 2).  On a foreign cell f may change sign,
    so we take the sup-norm over three candidates.
    """
    f_at_a = log2(a_k) - chord_eval(sigma_j, intercept_j, a_j, a_k)
    f_at_b = log2(b_k) - chord_eval(sigma_j, intercept_j, a_j, b_k)
    best = max(abs(f_at_a), abs(f_at_b))

    if sigma_j > 0:
        m_star_j = 1.0 / (sigma_j * log(2.0))
        if a_k < m_star_j < b_k:
            f_at_star = log2(m_star_j) - chord_eval(
                sigma_j, intercept_j, a_j, m_star_j
            )
            best = max(best, abs(f_at_star))

    return best


def build_error_matrix(cells):
    """Build the N x N matrix E where E[j][k] = peak |log2 - chord_j| on cell k.

    Diagonal entries E[j][j] are the per-cell errors (not used in the
    trident, but included for completeness).
    """
    N = len(cells)
    E = [[0.0] * N for _ in range(N)]
    chords = [cell_chord(a, b) for a, b in cells]

    for j in range(N):
        sigma_j, intercept_j = chords[j]
        a_j = cells[j][0]
        for k in range(N):
            a_k, b_k = cells[k]
            E[j][k] = _foreign_peak_error(sigma_j, intercept_j, a_j, a_k, b_k)

    return E


def _lower_median(vals):
    """Lower-median of a sorted list."""
    return vals[(len(vals) - 1) // 2]


def red_bars(E):
    """Row medians: for each j, median of {E[j][k] : k != j}."""
    N = len(E)
    result = []
    for j in range(N):
        row = sorted(E[j][k] for k in range(N) if k != j)
        result.append(_lower_median(row))
    return result


def blue_bars(E):
    """Column medians: for each k, median of {E[j][k] : j != k}."""
    N = len(E)
    result = []
    for k in range(N):
        col = sorted(E[j][k] for j in range(N) if j != k)
        result.append(_lower_median(col))
    return result


# ── Compute trident arrays ──────────────────────────────────────────

def compute_trident(cells):
    """Return (x_pos, grays, reds, blues) arrays for a partition."""
    N = len(cells)
    x_pos = [(a + b) / 2.0 for a, b in cells]
    grays = [gray_bar(a, b) for a, b in cells]

    E = build_error_matrix(cells)
    reds = red_bars(E)
    blues = blue_bars(E)

    return np.array(x_pos), np.array(grays), np.array(reds), np.array(blues)


# ── Plotting ─────────────────────────────────────────────────────────

N_LIST = [4, 8, 16, 32, 64]
PARTITION_BUILDERS = {
    'uniform': uniform_partition,
    'geometric': geometric_partition,
}

COLORS = {
    'gray': '#888888',
    'red':  '#d62728',
    'blue': '#1f77b4',
}


def plot_tridents():
    n_rows = len(N_LIST)
    n_cols = len(PARTITION_BUILDERS)

    fig, axes = plt.subplots(
        n_rows, n_cols,
        figsize=(7 * n_cols, 2.2 * n_rows),
        sharex=True,
        squeeze=False,
    )

    for col, (kind, builder) in enumerate(PARTITION_BUILDERS.items()):
        for row, N in enumerate(N_LIST):
            ax = axes[row][col]
            cells = builder(N)
            x_pos, grays, reds, blues = compute_trident(cells)

            # Bar width: fraction of the smallest cell gap.
            gaps = np.diff(x_pos)
            min_gap = gaps.min() if len(gaps) > 0 else 0.5
            w = min_gap * 0.25

            ax.bar(x_pos - w, grays, width=w, color=COLORS['gray'],
                   align='center', label='global' if row == 0 else None)
            ax.bar(x_pos,     reds,  width=w, color=COLORS['red'],
                   align='center', label='exported' if row == 0 else None)
            ax.bar(x_pos + w, blues, width=w, color=COLORS['blue'],
                   align='center', label='incoming' if row == 0 else None)

            ax.set_xlim(0.98, 2.02)
            ax.set_ylabel(f'N={N}', fontsize=9)
            ax.tick_params(labelsize=7)

            if row == 0:
                ax.set_title(kind, fontsize=11, fontweight='bold')
                ax.legend(fontsize=7, loc='upper right')
            if row == n_rows - 1:
                ax.set_xlabel('m', fontsize=9)

    fig.suptitle(
        'Error trident: global vs exported vs incoming chord error on [1, 2]',
        fontsize=12, fontweight='bold', y=0.995,
    )
    fig.tight_layout(rect=[0, 0, 1, 0.97])

    out_path = 'experiments/error/error_trident.png'
    fig.savefig(out_path, dpi=180)
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Error trident diagnostics")
    print("=" * 72)

    for kind, builder in PARTITION_BUILDERS.items():
        print(f"\n{'─' * 72}")
        print(f"  {kind}")
        print(f"{'─' * 72}")
        for N in N_LIST:
            cells = builder(N)
            x_pos, grays, reds, blues = compute_trident(cells)

            # Cells where exported > incoming (net exporters).
            exporters = sum(1 for j in range(N) if reds[j] > blues[j] + 1e-14)
            # Cells where red > gray (exported damage exceeds global error).
            crossovers = sum(1 for j in range(N) if reds[j] > grays[j] + 1e-14)

            print(f"\n  N={N:3d}"
                  f"  max(gray)={grays.max():.6f}"
                  f"  max(red)={reds.max():.6f}"
                  f"  max(blue)={blues.max():.6f}"
                  f"  exporters={exporters}/{N}"
                  f"  red>gray={crossovers}/{N}")

    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
plot_tridents()
print("\nDone.")
