"""
zoo_figure.sage — Shared zoo-grid plotting utilities.

Provides helper functions for creating PARTITION_ZOO subplot grids,
iterating over them, and handling edge labels and unused axes.

Not intended to be run directly.
"""

from helpers import pathing
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def zoo_subplots(figsize_per_cell=(4.5, 3.5), constrained=True, **subplot_kw):
    """Create fig + axes grid matching PARTITION_ZOO.

    Returns (fig, axes, n_rows, n_cols) where axes is the raw 2D array.
    Use axes.flat to iterate linearly.
    """
    n_rows, n_cols = zoo_grid_shape()
    kw = dict(figsize=(n_cols * figsize_per_cell[0], n_rows * figsize_per_cell[1]))
    if constrained:
        kw['constrained_layout'] = True
    kw.update(subplot_kw)
    fig, axes = plt.subplots(n_rows, n_cols, **kw)
    return fig, axes, n_rows, n_cols


def zoo_iter(axes_flat):
    """Yield (name, color, kind, ax) for each zoo entry."""
    for ax, (name, color, kind) in zip(axes_flat, PARTITION_ZOO):
        yield name, color, kind, ax


def zoo_hide_unused(axes_flat):
    """Hide axes beyond len(PARTITION_ZOO)."""
    for ax in axes_flat[len(PARTITION_ZOO):]:
        ax.set_visible(False)


def zoo_label_edges(axes, ylabel='', xlabel=''):
    """Set ylabel on left column, xlabel on bottom row."""
    for ax in axes[:, 0]:
        ax.set_ylabel(ylabel, fontsize=8)
    for ax in axes[-1, :]:
        ax.set_xlabel(xlabel, fontsize=8)
