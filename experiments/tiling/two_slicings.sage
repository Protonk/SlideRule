"""
two_slicings.sage — PROTOTYPE, superseded by elementals/poincare/E1a + E1b.

Original purpose: visualize TILING.md L16-25 (binary and geometric
partitions as two slicings of the same tiling). This was a first draft
that combined the half-plane grid and the two projections into one busy
figure. The canonical versions are now:

  - elementals/poincare/E1a_halfplane_grid.sage  (the tiling itself)
  - elementals/poincare/E1b_two_projections.sage  (the two number lines)

This script is kept for reference during tiling/ cleanup. It can be
deleted once the cleanup is complete.

Run:  ./sagew experiments/tiling/two_slicings.sage
"""

import os
from math import log, log2, sqrt

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# -- Configuration --------------------------------------------------------

OUT_PATH = pathing('experiments', 'tiling', 'results', 'two_slicings.png')

C_GEO  = '#9467bd'
C_BIN  = '#1f77b4'
C_TILE = '#e8e0f0'
C_DISP = '#d62728'
C_GRAY = '#aaaaaa'

DEPTH = 3
N = 2 ** DEPTH


# -- Grid points -----------------------------------------------------------

geo_pts = [2.0 ** (k / N) for k in range(N + 1)]
bin_pts = [1.0 + k / N for k in range(N + 1)]


# -- Figure ----------------------------------------------------------------

fig, ax = plt.subplots(figsize=(14, 8))

# The half-plane strip: x in [1, 2], y represents scale.
# We draw depth levels as horizontal bands.
# Level 0 (top, coarsest): one cell spanning [1, 2]
# Level d (bottom, finest): 2^d cells
#
# y-axis: depth level, with 0 at top and DEPTH at bottom.
# Within each level, draw the geometric cells as rectangles.

y_top = -0.5
y_bot = DEPTH + 0.5

# Draw the dyadic hierarchy: at each depth t, 2^t cells with
# geometric (geodesic) boundaries.
for t in range(DEPTH + 1):
    n_cells = 2 ** t
    y_lo = t - 0.4
    y_hi = t + 0.4

    for k in range(n_cells):
        x_lo = 2.0 ** (k / n_cells)
        x_hi = 2.0 ** ((k + 1) / n_cells)

        # Tiling rectangle (filled)
        shade = 0.92 - 0.06 * (k % 2)
        rect = mpatches.FancyBboxPatch(
            (x_lo, y_lo), x_hi - x_lo, y_hi - y_lo,
            boxstyle='round,pad=0.003',
            facecolor=(shade, shade - 0.03, shade + 0.02),
            edgecolor=C_GEO, linewidth=1.2, alpha=0.8)
        ax.add_patch(rect)

    # Depth label
    ax.text(0.96, t, 'd = %d' % t, fontsize=10, ha='right', va='center',
            color=C_GRAY)
    ax.text(2.04, t, '%d cell%s' % (n_cells, '' if n_cells == 1 else 's'),
            fontsize=9, ha='left', va='center', color=C_GRAY)

# Geodesic boundaries: vertical lines at geometric positions (finest level)
for k in range(N + 1):
    gx = geo_pts[k]
    ax.plot([gx, gx], [-0.5, DEPTH + 0.5], '-', color=C_GEO,
            linewidth=0.6, alpha=0.4, zorder=1)

# Horocyclic measurement: uniform tick marks along a horocycle at the finest level.
# Draw a horizontal line (horocycle) and mark uniform positions on it.
y_horo = DEPTH + 0.8
ax.plot([1.0, 2.0], [y_horo, y_horo], '-', color=C_BIN, linewidth=2.0,
        alpha=0.6)
for k in range(N + 1):
    bx = bin_pts[k]
    ax.plot([bx, bx], [y_horo - 0.12, y_horo + 0.12], '-', color=C_BIN,
            linewidth=2.0)

# Geodesic ticks for comparison (below the tiling)
y_geod = -0.8
ax.plot([1.0, 2.0], [y_geod, y_geod], '-', color=C_GEO, linewidth=2.0,
        alpha=0.6)
for k in range(N + 1):
    gx = geo_pts[k]
    ax.plot([gx, gx], [y_geod - 0.12, y_geod + 0.12], '-', color=C_GEO,
            linewidth=2.0)

# Displacement arrows between the two number lines at the finest level
for k in range(1, N):
    bx = bin_pts[k]
    gx = geo_pts[k]
    disp = abs(bx - gx)
    max_disp = max(abs(bin_pts[j] - geo_pts[j]) for j in range(1, N))
    alpha = 0.3 + 0.7 * (disp / max_disp)

    # Draw curved arrow from uniform tick to geometric tick
    ax.annotate('', xy=(gx, y_geod + 0.18), xytext=(bx, y_horo - 0.18),
                arrowprops=dict(arrowstyle='->', color=C_DISP,
                                alpha=alpha * 0.5, linewidth=0.7,
                                connectionstyle='arc3,rad=0.15'))

# Labels
ax.text(2.04, y_horo, 'horocyclic\n(uniform)', fontsize=11, ha='left',
        va='center', color=C_BIN, fontweight='bold')
ax.text(2.04, y_geod, 'geodesic\n(geometric)', fontsize=11, ha='left',
        va='center', color=C_GEO, fontweight='bold')

# Central annotation
ax.text(1.5, DEPTH + 1.4,
        'Same tiling, two slicings.',
        fontsize=14, ha='center', va='center', color='#333333',
        fontweight='bold')
ax.text(1.5, DEPTH + 1.7,
        'Equal additive width (blue) vs equal log-width (purple) '
        'on $[1,\\, 2)$',
        fontsize=10, ha='center', va='center', color=C_GRAY)

# Displacement annotation
k_max = max(range(1, N), key=lambda k: abs(bin_pts[k] - geo_pts[k]))
bx_max = bin_pts[k_max]
gx_max = geo_pts[k_max]
mid_x = (bx_max + gx_max) / 2
ax.annotate('$\\Delta^L = -\\varepsilon$',
            xy=(mid_x, (y_horo + y_geod) / 2),
            xytext=(1.82, (y_horo + y_geod) / 2),
            fontsize=11, color=C_DISP, ha='center', va='center',
            arrowprops=dict(arrowstyle='->', color=C_DISP, linewidth=1.0))

# Scaling annotation: show that doubling preserves hyperbolic shape
ax.annotate('', xy=(geo_pts[4], 0.4), xytext=(geo_pts[2], 1.4),
            arrowprops=dict(arrowstyle='->', color=C_GRAY, linewidth=1.5,
                            connectionstyle='arc3,rad=-0.3'))
ax.text(1.55, 0.85, '$\\times 2$\nscaling\n= isometry',
        fontsize=8, ha='center', va='center', color=C_GRAY, style='italic')

# Axes
ax.set_xlim(0.92, 2.15)
ax.set_ylim(y_geod - 0.5, DEPTH + 2.0)
ax.invert_yaxis()
ax.set_aspect('auto')
ax.axis('off')


# -- Save -----------------------------------------------------------------

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight')
print("Saved: %s" % OUT_PATH)
print("Done.")
