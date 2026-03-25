"""
coordinate_uniqueness.sage — Exhibit Keystone §1: the coordinate claim.

The logarithm is the unique coordinate on R_{>0} that turns scaling into
translation. A direct consequence: the chord error of log2(x) on a
geometric cell [a, a*r] depends only on the ratio r, not on the position a.
Equal-log-width cells have equal chord error. No other partition achieves
this without the log coordinate.

This script computes the peak chord error of log2(x) on each cell for
several partition kinds and plots the per-cell difficulty profile. Geometric
produces a flat line; everything else is position-dependent.

Run:  ./sagew experiments/aft/keystone/coordinate_uniqueness.sage
"""

import os
from math import log, log2

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 6
KINDS = [
    ('uniform_x',    '#1f77b4', 'uniform',    1.2),
    ('geometric_x',  '#9467bd', 'geometric',  2.5),
    ('harmonic_x',   '#2ca02c', 'harmonic',   1.0),
    ('chebyshev_x',  '#8c564b', 'chebyshev',  1.0),
    ('ruler_x',      '#e67e22', 'ruler',       1.0),
    ('powerlaw_x',   '#ff9896', 'power-law',  1.0),
]

OUT_PATH = pathing('experiments', 'aft', 'keystone', 'results',
                    'coordinate_uniqueness.png')

LN2 = log(2.0)
M_STAR = 1.0 / LN2


# ── Chord error of log2 ─────────────────────────────────────────────

def chord_peak_error(a, b):
    """Peak |log2(x) - chord(x)| on [a, b] with optimal chord.

    The chord of log2 on [a, b] has slope sigma = (log2(b) - log2(a))/(b-a).
    The error e(x) = log2(x) - chord(x) has e''(x) = -1/(x^2 ln 2) < 0,
    so e is concave with a unique interior maximum at x* = 1/(sigma * ln 2).
    The peak error is max(|e(x*)|, |e(a)|, |e(b)|).  Since the chord
    interpolates at a and b, e(a) = e(b) = 0, so the peak is |e(x*)|.
    """
    la = log2(a)
    lb = log2(b)
    sigma = (lb - la) / (b - a)

    if sigma <= 0:
        return 0.0

    # Interior maximum of log2(x) - chord(x)
    x_star = 1.0 / (sigma * LN2)

    if x_star <= a or x_star >= b:
        # No interior extremum — peak is at endpoints (which are zero for
        # an interpolating chord). This shouldn't happen for valid cells.
        return 0.0

    chord_at_star = la + sigma * (x_star - a)
    error = log2(x_star) - chord_at_star
    return abs(error)


def cell_chord_errors(depth, kind):
    """Return list of (x_mid, peak_chord_error) for each cell."""
    partition = build_partition(depth, kind=kind)
    cells = []
    for row in partition:
        a = float(row['x_lo'])
        b = float(row['x_hi'])
        x_mid = (a + b) / 2.0
        err = chord_peak_error(a, b)
        cells.append((x_mid, err))
    cells.sort()
    return cells


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, ax = plt.subplots(figsize=(11, 5.5), constrained_layout=True)

    for kind, color, label, lw in KINDS:
        cells = cell_chord_errors(DEPTH, kind)
        xs = [c[0] for c in cells]
        errs = [c[1] for c in cells]

        if kind == 'geometric_x':
            ax.plot(xs, errs, color=color, linewidth=lw, label=label,
                    zorder=5, marker='o', markersize=2)
        else:
            ax.plot(xs, errs, color=color, linewidth=lw, alpha=0.8,
                    label=label, zorder=3)

    # m* line
    ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':',
               zorder=1)
    ax.text(M_STAR + 0.01, ax.get_ylim()[1] * 0.95, '$m^* = 1/\\ln 2$',
            fontsize=7, color='#666666', va='top')

    ax.set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=10)
    ax.set_ylabel('Peak chord error of $\\log_2(x)$', fontsize=10)
    ax.set_xlim(1.0, 2.0)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3, linewidth=0.5)
    ax.tick_params(labelsize=8)

    fig.suptitle(
        'Coordinate uniqueness: only geometric equalizes chord difficulty\n'
        'Peak $|\\log_2(x) - \\mathrm{chord}(x)|$ per cell, '
        'depth $= %d$ ($N = %d$)' % (DEPTH, 2**DEPTH),
        fontsize=12, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Coordinate uniqueness: depth=%d, %d partition kinds"
      % (DEPTH, len(KINDS)))

make_plot()

# Flatness check for geometric
cells = cell_chord_errors(DEPTH, 'geometric_x')
errs = [c[1] for c in cells]
ratio = max(errs) / min(errs) if min(errs) > 0 else float('inf')
print("  geometric max/min ratio: %.10f" % ratio)
print("  geometric peak range: [%.10e, %.10e]" % (min(errs), max(errs)))
print("Done.")
