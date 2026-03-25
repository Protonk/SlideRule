"""
surrogacy_test.sage — Exhibit Keystone §2: the surrogacy claim.

The affine pseudo-log L(x) = x - 1 is not the best pointwise fit to log2(x)
on [1, 2). A vertically shifted linear fit (Chebyshev) has lower peak error.
But the pseudo-log is the surrogate whose residual eps(x) = log2(x) - (x - 1)
vanishes at the binade boundaries x = 1 and x = 2 — the coarsest geometric
cell boundaries. This means the correction task within each binade is
self-contained: no budget is wasted removing a constant offset.

This script shows three things:
  1. The residual curves of four surrogates, showing boundary alignment.
  2. The per-cell correction budget on geometric vs uniform partitions —
     after subtracting the best per-cell chord fit to the residual, what
     remains. Only the pseudo-log has zero residual at partition boundaries.
  3. The global residual magnitudes, confirming the pseudo-log is not the
     best raw fit but is the one aligned with the geometric grid structure.

Run:  ./sagew experiments/aft/keystone/surrogacy_test.sage
"""

import os
from math import log, log2

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 6
OUT_PATH = pathing('experiments', 'aft', 'keystone', 'results', 'surrogacy_test.png')
LN2 = log(2.0)


# ── Surrogates ───────────────────────────────────────────────────────

def pseudolog(x):
    """L(x) = x - 1. Chord of log2 connecting binade endpoints."""
    return x - 1.0


def chebyshev_surrogate(x):
    """Best minimax linear fit to log2(x) on [1, 2].

    Same slope as pseudo-log but shifted up by half the peak residual,
    so the error equioscillates between +peak/2 and -peak/2.
    """
    peak = log2(1.0 / LN2) - (1.0 / LN2 - 1.0)
    return (x - 1.0) + peak / 2.0


def taylor_surrogate(x):
    """First-order Taylor expansion of log2(x) around x = 1.5."""
    x0 = 1.5
    return log2(x0) + (x - x0) / (x0 * LN2)


def reciprocal_surrogate(x):
    """Linear in 1/x, interpolating log2 at x=1 and x=2.

    S(x) = 2 - 2/x. Matches log2 at endpoints but has the wrong
    concavity structure (convex vs concave).
    """
    return 2.0 - 2.0 / x


SURROGATES = [
    ('pseudo-log',  pseudolog,            '#9467bd', '-',  2.0),
    ('Chebyshev',   chebyshev_surrogate,  '#e74c3c', '--', 1.5),
    ('Taylor@1.5',  taylor_surrogate,     '#2ca02c', '-.', 1.2),
    ('reciprocal',  reciprocal_surrogate, '#1f77b4', ':',  1.5),
]


# ── Computations ─────────────────────────────────────────────────────

def residual_at(fn, x):
    """log2(x) - surrogate(x)"""
    return log2(x) - fn(x)


def boundary_residuals(fn):
    """Residual at binade boundaries x=1 and x=2."""
    return residual_at(fn, 1.0), residual_at(fn, 2.0)


def cell_residual_peak(fn, a, b, n_samples=500):
    """Peak |log2(x) - surrogate(x)| on [a, b] by dense sampling."""
    best = 0.0
    for i in range(n_samples + 1):
        x = a + (b - a) * i / n_samples
        err = abs(residual_at(fn, x))
        if err > best:
            best = err
    return best


def cell_peaks(depth, kind, fn):
    """Return (x_mids, peaks) for each cell."""
    partition = build_partition(depth, kind=kind)
    xs, peaks = [], []
    for row in partition:
        a, b = float(row['x_lo']), float(row['x_hi'])
        xs.append((a + b) / 2.0)
        peaks.append(cell_residual_peak(fn, a, b))
    return xs, peaks


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5), constrained_layout=True)

    # Panel 1: residual curves on [1, 2]
    ax = axes[0]
    ms = np.linspace(1.0, 2.0, 500)
    for label, fn, color, ls, lw in SURROGATES:
        residuals = [residual_at(fn, float(m)) for m in ms]
        ax.plot(ms, residuals, color=color, linewidth=lw, linestyle=ls,
                label=label)

    ax.axhline(0, color='#999999', linewidth=0.5)
    ax.axvline(1.0, color='#cccccc', linewidth=0.8, linestyle='--')
    ax.axvline(2.0, color='#cccccc', linewidth=0.8, linestyle='--')
    ax.set_xlabel('$x$', fontsize=9)
    ax.set_ylabel('$\\log_2(x) - S(x)$', fontsize=9)
    ax.set_title('Residual curves', fontsize=10, fontweight='bold')
    ax.legend(fontsize=7, loc='best')
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1.0, 2.0)

    # Annotate boundary alignment
    for label, fn, color, ls, lw in SURROGATES:
        r1, r2 = boundary_residuals(fn)
        if abs(r1) < 1e-10 and abs(r2) < 1e-10:
            ax.text(1.02, 0.005, 'zero at\nboundaries',
                    fontsize=6, color=color, va='bottom')

    # Panel 2: per-cell peak on geometric partition
    ax = axes[1]
    for label, fn, color, ls, lw in SURROGATES:
        xs, peaks = cell_peaks(DEPTH, 'geometric_x', fn)
        ax.plot(xs, peaks, color=color, linewidth=lw, linestyle=ls,
                label=label, alpha=0.9)

    ax.set_xlabel('Cell midpoint $m$', fontsize=9)
    ax.set_ylabel('Peak $|\\log_2(x) - S(x)|$ per cell', fontsize=9)
    ax.set_title('Per-cell residual: geometric', fontsize=10,
                  fontweight='bold')
    ax.legend(fontsize=7, loc='best')
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1.0, 2.0)

    # Panel 3: per-cell peak on uniform partition
    ax = axes[2]
    for label, fn, color, ls, lw in SURROGATES:
        xs, peaks = cell_peaks(DEPTH, 'uniform_x', fn)
        ax.plot(xs, peaks, color=color, linewidth=lw, linestyle=ls,
                label=label, alpha=0.9)

    ax.set_xlabel('Cell midpoint $m$', fontsize=9)
    ax.set_ylabel('Peak $|\\log_2(x) - S(x)|$ per cell', fontsize=9)
    ax.set_title('Per-cell residual: uniform', fontsize=10,
                  fontweight='bold')
    ax.legend(fontsize=7, loc='best')
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)
    ax.set_xlim(1.0, 2.0)

    fig.suptitle(
        'Surrogacy: boundary alignment distinguishes the pseudo-log\n'
        'depth $= %d$ ($N = %d$)' % (DEPTH, 2**DEPTH),
        fontsize=12, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Surrogacy test: depth=%d, %d surrogates" % (DEPTH, len(SURROGATES)))

make_plot()

print()
print("  Boundary residuals (binade endpoints x=1, x=2):")
for label, fn, color, ls, lw in SURROGATES:
    r1, r2 = boundary_residuals(fn)
    print("    %-14s  R(1) = %+.6f   R(2) = %+.6f" % (label, r1, r2))

print()
print("  Global peak |residual| on [1, 2):")
for label, fn, color, ls, lw in SURROGATES:
    peak = cell_residual_peak(fn, 1.0, 2.0, n_samples=10000)
    print("    %-14s  %.6f" % (label, peak))

print()
print("  Geometric max/min ratios (per-cell residual peak):")
for label, fn, color, ls, lw in SURROGATES:
    xs, peaks = cell_peaks(DEPTH, 'geometric_x', fn)
    ratio = max(peaks) / min(peaks) if min(peaks) > 0 else float('inf')
    print("    %-14s  %.4f" % (label, ratio))

print()
print("Done.")
