"""
raster.sage — Pure raster engine for fractal crossing-count images.

Scans vertically through slope-deviation step functions at many depth layers
(plus optionally the continuous limit).  At each pixel (x, y), counts how many
curves lie above y.  Returns the raw count as a uint16 array — no coloring,
no modular arithmetic, no matplotlib.

Not intended to be run directly.  Loaded by multiplexer.sage.

Depends on: lib/day.sage, lib/partitions.sage (loaded here via pathing).
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import numpy as np
from math import log, log2 as math_log2


# ── Math (vectorized) ───────────────────────────────────────────────

def cell_chord_slope(a, b):
    """Chord slope of log2 on [a, b]."""
    return (math_log2(b) - math_log2(a)) / (b - a)


def step_values_vec(depth, kind, xs):
    """Return slope deviation at each x, vectorized via searchsorted."""
    cells = float_cells(depth, kind)
    boundaries = np.array([a for a, _ in cells] + [cells[-1][1]])
    deviations = np.array([cell_chord_slope(a, b) - 1.0 for a, b in cells])
    indices = np.clip(
        np.searchsorted(boundaries, xs, side='right') - 1,
        0, len(deviations) - 1)
    return deviations[indices]


def continuous_slope_vec(xs):
    """1/(x ln 2) - 1 evaluated at each x."""
    return 1.0 / (xs * log(2.0)) - 1.0


# ── Raster builders ─────────────────────────────────────────────────

def build_raster(kind, depths, x_res, y_res, x_chunk=500):
    """Build a y_res x x_res uint16 array of raw crossing counts.

    Counts how many curves (step layers + continuous limit) are >= each y.
    Chunks along X to keep memory bounded.
    """
    xs = np.linspace(1.0, 2.0, x_res)

    n_curves = len(depths) + 1
    values = np.zeros((n_curves, x_res))
    for i, d in enumerate(depths):
        values[i, :] = step_values_vec(d, kind, xs)
    values[n_curves - 1, :] = continuous_slope_vec(xs)

    y_min = values.min() - 0.02 * abs(values.min())
    y_max = values.max() + 0.02 * abs(values.max())
    ys = np.linspace(y_max, y_min, y_res)

    img = np.zeros((y_res, x_res), dtype=np.uint16)

    for x0 in range(0, x_res, x_chunk):
        x1 = min(x0 + x_chunk, x_res)
        chunk = values[:, x0:x1]
        count = (chunk[:, np.newaxis, :] >= ys[np.newaxis, :, np.newaxis]).sum(axis=0)
        img[:, x0:x1] = count

    return img


def build_raster_clipped(kind, depths, x_res, y_res, x_chunk=500):
    """Build a y_res x x_res uint16 array of raw crossing counts,
    hard-clipped by the continuous limit curve.

    Only step layers contribute to the parity count; the continuous curve
    acts as a mask (y >= c(m)).
    """
    xs = np.linspace(1.0, 2.0, x_res)

    step_vals = np.zeros((len(depths), x_res))
    for i, d in enumerate(depths):
        step_vals[i, :] = step_values_vec(d, kind, xs)

    cap = continuous_slope_vec(xs)

    y_min = min(step_vals.min(), cap.min())
    y_max = max(step_vals.max(), cap.max())
    ys = np.linspace(y_max, y_min, y_res)

    img = np.zeros((y_res, x_res), dtype=np.uint16)

    for x0 in range(0, x_res, x_chunk):
        x1 = min(x0 + x_chunk, x_res)
        chunk = step_vals[:, x0:x1]
        count = (chunk[:, np.newaxis, :] >= ys[np.newaxis, :, np.newaxis]).sum(axis=0)
        mask = ys[:, np.newaxis] >= cap[np.newaxis, x0:x1]
        img[:, x0:x1] = count * mask

    return img
