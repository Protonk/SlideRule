"""
coastline.sage — Shared coastline-area computations and normalization measures.

Not intended to be run directly. Loaded by ripple and stepstone scripts that
study how the slope-deviation coastline behaves across depth.
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

from math import log, log2 as math_log2
import sys

_LN2 = log(2.0)


def cell_chord_slope(a, b):
    """Chord slope of log2 on [a, b]."""
    return (math_log2(b) - math_log2(a)) / (b - a)


def continuous_slope(m):
    """Continuous slope deviation c(m) = 1 / (m ln 2) - 1."""
    return 1.0 / (m * _LN2) - 1.0


def _cell_coastline_area(a, b):
    """Closed-form area of |1/(m ln 2) - sigma_j| on [a, b].

    The antiderivative of (1/(m ln 2) - sigma_j) is
        F(m) = log2(m) - sigma_j * m
    The integrand changes sign at most once, at m_cross = 1/(sigma_j * ln 2).
    """
    sigma = cell_chord_slope(a, b)
    if sigma <= 0:
        # Degenerate cell — should not happen for valid partitions on [1, 2].
        return 0.0

    def _F(m):
        return math_log2(m) - sigma * m

    m_cross = 1.0 / (sigma * _LN2)

    if m_cross <= a or m_cross >= b:
        # No sign change in [a, b].
        return abs(_F(b) - _F(a))

    # Sign change at m_cross: split into two pieces.
    return abs(_F(m_cross) - _F(a)) + abs(_F(b) - _F(m_cross))


def coastline_area(depth, kind):
    """Sum of |continuous_slope - step_slope_deviation| across all cells.

    Uses a closed-form antiderivative (no quadrature).
    """
    cells = float_cells(depth, kind)
    return sum(_cell_coastline_area(a, b) for a, b in cells)


def coastline_series(kinds, depths, progress=False):
    """Return dict: kind -> list of raw coastline areas across depths."""
    name_by_kind = {kind: name for name, _, kind in PARTITION_ZOO}
    series = {}
    total = len(kinds)
    for idx, kind in enumerate(kinds):
        if progress:
            label = name_by_kind.get(kind, kind)
            sys.stdout.write("  [%2d/%d] %-20s ... " % (idx + 1, total, label))
            sys.stdout.flush()
        series[kind] = [coastline_area(depth, kind) for depth in depths]
        if progress:
            sys.stdout.write("done\n")
            sys.stdout.flush()
    return series


def scaled_series(raw_series, depths):
    """Return dict: kind -> [2^depth * area(depth, kind)]."""
    scales = [2**depth for depth in depths]
    return {
        kind: [areas[i] * scales[i] for i in range(len(depths))]
        for kind, areas in raw_series.items()
    }


def geometric_relative_series(series_map, geometric_kind='geometric_x'):
    """Return dict: kind -> series / geometric_series pointwise."""
    geo = series_map[geometric_kind]
    return {
        kind: [
            series[i] / geo[i] if geo[i] != 0 else float('inf')
            for i in range(len(geo))
        ]
        for kind, series in series_map.items()
    }


def _measure_log_ratio(series, idx, _ctx):
    return log(series[idx] / series[idx - 1])


def _measure_difference(series, idx, _ctx):
    return series[idx] - series[idx - 1]


def _measure_rel_change(series, idx, _ctx):
    prev = series[idx - 1]
    return abs(series[idx] - prev) / abs(prev) if prev != 0 else float('inf')


def _measure_geo_ratio(series, idx, ctx):
    geo = ctx['geo']
    return series[idx] / geo[idx] if geo[idx] != 0 else float('inf')


def _measure_geo_change(series, idx, ctx):
    geo = ctx['geo']
    curr = series[idx] / geo[idx]
    prev = series[idx - 1] / geo[idx - 1]
    return log(curr / prev)


MEASURES = {
    'log_ratio': {
        'fn': _measure_log_ratio,
        'start_index': 1,
        'signed': True,
        'label': r'$\log(B_d / B_{d-1})$',
    },
    'difference': {
        'fn': _measure_difference,
        'start_index': 1,
        'signed': True,
        'label': r'$B_d - B_{d-1}$',
    },
    'rel_change': {
        'fn': _measure_rel_change,
        'start_index': 1,
        'signed': False,
        'label': r'$|B_d - B_{d-1}| / |B_{d-1}|$',
    },
    'geo_ratio': {
        'fn': _measure_geo_ratio,
        'start_index': 0,
        'signed': False,
        'label': r'$B_d / B_d^{(\mathrm{geo})}$',
    },
    'geo_change': {
        'fn': _measure_geo_change,
        'start_index': 1,
        'signed': True,
        'label': r'$\log\!\left(\frac{B_d / B_d^{(\mathrm{geo})}}{B_{d-1} / B_{d-1}^{(\mathrm{geo})}}\right)$',
    },
}


def measure_series(series_map, measure_name, geometric_kind='geometric_x'):
    """Return (indices, measured_map, meta) for the chosen measure."""
    meta = MEASURES[measure_name]
    indices = list(range(meta['start_index'], len(next(iter(series_map.values())))))
    ctx = {'geo': series_map[geometric_kind]}
    measured = {
        kind: [meta['fn'](series, idx, ctx) for idx in indices]
        for kind, series in series_map.items()
    }
    return indices, measured, meta
