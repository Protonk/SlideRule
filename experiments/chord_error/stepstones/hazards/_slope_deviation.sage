"""
_slope_deviation.sage — Shared math and rendering for slope deviation panels.

Provides build_steps(depth, kind) and render_panel(ax, kind, ...) for use
by curated.sage and zoo.sage.

Math (cell_chord_slope) imported from art/raster.sage to avoid duplication.

Not intended to be run directly.
"""

from helpers import pathing
load(pathing('experiments', 'chord_error', 'stepstones', 'art', 'raster.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# cell_chord_slope is now provided by art/raster.sage


# ── Defaults ─────────────────────────────────────────────────────────

DEFAULT_DEPTHS = [3, 4, 5, 6]   # N = 8, 16, 32, 64

DEFAULT_COLORS = ['#e67e22', '#e74c3c', '#3498db', '#2ecc71']
DEFAULT_ALPHAS = [1.0, 0.6, 0.4, 0.3]
DEFAULT_WIDTHS = [2.0, 1.4, 1.0, 0.7]

M_STAR = 1.0 / log(2.0)


def build_steps(depth, kind='uniform_x'):
    """Return (step_x, step_y) arrays for the slope deviation step function."""
    cells = float_cells(depth, kind)
    slopes = [cell_chord_slope(a, b) - 1.0 for a, b in cells]

    step_x = [cells[0][0]]
    step_y = [slopes[0]]
    for i, (a, b) in enumerate(cells):
        step_x.append(b)
        step_y.append(slopes[i])

    return np.array(step_x), np.array(step_y)


# ── Rendering ────────────────────────────────────────────────────────

def render_panel(ax, kind, depths=None, colors=None, alphas=None, widths=None,
                 show_legend=False, annotate_mstar=True, minimal=False):
    """Draw slope deviation step functions onto an axes object."""
    if depths is None:
        depths = DEFAULT_DEPTHS
    if colors is None:
        colors = DEFAULT_COLORS
    if alphas is None:
        alphas = DEFAULT_ALPHAS
    if widths is None:
        widths = DEFAULT_WIDTHS

    # Continuous limit
    ms_cont = np.linspace(1.0, 2.0, 400)
    ax.plot(ms_cont, 1.0 / (ms_cont * log(2.0)) - 1.0,
            '--', color='#cccccc', linewidth=1.4, zorder=1)

    # Step functions, coarsest on top
    for i, depth in enumerate(depths):
        N = 2**depth
        sx, sy = build_steps(depth, kind)
        ax.step(sx, sy, where='post',
                color=colors[i], linewidth=widths[i], alpha=alphas[i],
                zorder=10 - i, label='$N = %d$' % N)

    ax.set_xlim(1.0, 2.0)

    if minimal:
        ax.set_xticks([])
        ax.set_yticks([])
    else:
        # Vertical crossing line
        ax.axvline(M_STAR, color='#888888', linewidth=1.0, linestyle=':',
                   zorder=1)
        ax.tick_params(labelsize=6)

    if annotate_mstar:
        ax.annotate(
            r'$m^* = 1/\ln 2$',
            xy=(M_STAR, 0),
            xytext=(M_STAR - 0.30, -0.18),
            fontsize=7, color='#555555',
            arrowprops=dict(arrowstyle='->', color='#888888', lw=0.8),
        )

    if show_legend:
        ax.legend(fontsize=6, loc='upper right')
