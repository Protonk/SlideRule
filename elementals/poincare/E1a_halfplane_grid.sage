"""
E1a_halfplane_grid.sage — The dyadic tiling of the Poincare half-plane.

Claim (TILING.md L16-L20):
    In the Poincare half-plane model, scaling (x, y) -> (lambda*x, lambda*y)
    is an isometry. A binary tiling is a family of rectangles related by
    dyadic scaling: moving up one level doubles Euclidean width and height
    while preserving hyperbolic shape and area.

Mathematical objects drawn:
    - A strip of the Poincare half-plane, x in [1, 2], y > 0
    - Geodesics (vertical lines) and horocycles (horizontal lines)
    - Tiling cells formed by their intersections
    - Scaling arrow showing (x, y) -> (2x, 2y) isometry

Output: elementals/poincare/results/E1a_halfplane_grid.png

Run:  ./sagew elementals/poincare/E1a_halfplane_grid.sage
"""

import os
from math import log2

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


OUT_PATH = pathing('elementals', 'poincare', 'results',
                    'E1a_halfplane_grid.png')

# -- Colors ----------------------------------------------------------------

C_GEO  = '#9467bd'   # geodesics (vertical)
C_HORO = '#1f77b4'   # horocycles (horizontal)
C_FILL = '#f3eef8'   # cell fill (light purple)
C_FILL_ALT = '#eef5fb'  # alternate cell fill
C_GRAY = '#999999'
C_ARROW = '#d62728'


# -- Grid ------------------------------------------------------------------

DEPTH = 3
N = 2 ** DEPTH

# Geodesic positions: geometric grid points on [1, 2]
geo_x = [2.0 ** (k / N) for k in range(N + 1)]

# Horocycle positions: dyadic heights (log-spaced for visual clarity)
# Use y = 2^(level/N) for a few levels to show the scaling structure
horo_y = [2.0 ** (j / N) for j in range(N + 1)]

# We show the strip x in [1, 2], y in [1, 2] in the half-plane.
# This is one "binade" — the fundamental domain under x -> 2x, y -> 2y.
# A second copy at [2, 4] x [2, 4] would be the scaled version.

Y_LO = 1.0
Y_HI = 2.0


# -- Figure ----------------------------------------------------------------

fig, ax = plt.subplots(figsize=(12, 7))

# Draw tiling cells as filled rectangles
for k in range(N):
    x_lo = geo_x[k]
    x_hi = geo_x[k + 1]
    fill = C_FILL if k % 2 == 0 else C_FILL_ALT
    rect = mpatches.Rectangle((x_lo, Y_LO), x_hi - x_lo, Y_HI - Y_LO,
                               facecolor=fill, edgecolor='none', zorder=0)
    ax.add_patch(rect)

# Geodesics (vertical lines)
for k in range(N + 1):
    x = geo_x[k]
    lw = 1.8 if k == 0 or k == N else 1.0
    alpha = 1.0 if k == 0 or k == N else 0.6
    ax.plot([x, x], [Y_LO, Y_HI], '-', color=C_GEO, linewidth=lw,
            alpha=alpha, zorder=2)

# Extend a few geodesics below and above to suggest they continue
for k in [0, N // 2, N]:
    x = geo_x[k]
    ax.plot([x, x], [Y_LO * 0.85, Y_LO], ':', color=C_GEO, linewidth=0.6,
            alpha=0.4, zorder=1)
    ax.plot([x, x], [Y_HI, Y_HI * 1.15], ':', color=C_GEO, linewidth=0.6,
            alpha=0.4, zorder=1)

# Horocycles (horizontal lines)
# Show Y_LO and Y_HI as the main horocycles, plus one in between
horo_main = [Y_LO, (Y_LO + Y_HI) / 2, Y_HI]
for y in horo_main:
    lw = 1.8 if y == Y_LO or y == Y_HI else 0.8
    alpha = 1.0 if y == Y_LO or y == Y_HI else 0.4
    ax.plot([geo_x[0], geo_x[-1]], [y, y], '-', color=C_HORO,
            linewidth=lw, alpha=alpha, zorder=2)

# Extend horocycles slightly beyond the strip
for y in [Y_LO, Y_HI]:
    ax.plot([geo_x[0] * 0.92, geo_x[0]], [y, y], ':', color=C_HORO,
            linewidth=0.6, alpha=0.4)
    ax.plot([geo_x[-1], geo_x[-1] * 1.05], [y, y], ':', color=C_HORO,
            linewidth=0.6, alpha=0.4)

# -- Labels ----------------------------------------------------------------

# Label one geodesic
ax.annotate('geodesic\n$x = \\mathrm{const}$',
            xy=(geo_x[3], Y_HI * 1.02),
            xytext=(geo_x[3] + 0.05, Y_HI * 1.12),
            fontsize=11, color=C_GEO, ha='left', va='bottom',
            arrowprops=dict(arrowstyle='->', color=C_GEO, linewidth=1.0))

# Label one horocycle
ax.annotate('horocycle\n$y = \\mathrm{const}$',
            xy=(geo_x[-1] * 1.01, Y_LO),
            xytext=(geo_x[-1] * 1.06, Y_LO + 0.15),
            fontsize=11, color=C_HORO, ha='left',
            arrowprops=dict(arrowstyle='->', color=C_HORO, linewidth=1.0))

# -- Scaling arrow ---------------------------------------------------------

# Show that the cell [geo_x[0], geo_x[1]] x [Y_LO, Y_HI] maps to
# [2*geo_x[0], 2*geo_x[1]] x [2*Y_LO, 2*Y_HI] under (x,y) -> (2x, 2y).
# Since the scaled copy lives outside our strip, we indicate it schematically.
# Mark one cell and annotate the scaling.

# Highlight one cell
k_ref = 1
x0, x1 = geo_x[k_ref], geo_x[k_ref + 1]
rect_ref = mpatches.Rectangle((x0, Y_LO), x1 - x0, Y_HI - Y_LO,
                               facecolor='none', edgecolor=C_ARROW,
                               linewidth=2.0, linestyle='-', zorder=5)
ax.add_patch(rect_ref)

# Mark the cell that is its 2x scaled neighbor within the strip
# Under (x,y) -> (2x, 2y), cell k maps to a cell at 2x.
# Within [1,2], the cell [geo_x[2k], geo_x[2k+1]] at depth d+1
# is one half of the original cell. Show the parent-child relationship instead:
# cell k at depth 3 is contained in cell k//2 at depth 2.
# Let's highlight the parent cell at depth 2.
k_parent = k_ref // 2
x0_p = 2.0 ** (k_parent / (N // 2))
x1_p = 2.0 ** ((k_parent + 1) / (N // 2))
rect_parent = mpatches.Rectangle((x0_p, Y_LO), x1_p - x0_p, Y_HI - Y_LO,
                                  facecolor='none', edgecolor=C_ARROW,
                                  linewidth=1.5, linestyle='--', zorder=4,
                                  alpha=0.5)
ax.add_patch(rect_parent)

# Scaling annotation between them
ax.annotate('$(x,y) \\to (2x, 2y)$\nhyperbolic isometry',
            xy=((x0 + x1) / 2, Y_HI * 0.98),
            xytext=(1.65, Y_HI * 0.92),
            fontsize=10, color=C_ARROW, ha='center', va='top',
            arrowprops=dict(arrowstyle='->', color=C_ARROW, linewidth=1.2,
                            connectionstyle='arc3,rad=-0.2'))

# Same-shape annotation
ax.text(1.65, Y_LO + 0.12,
        'All cells are hyperbolically\ncongruent under dilation',
        fontsize=10, color=C_GRAY, ha='center', style='italic')

# -- Axis labels -----------------------------------------------------------

ax.set_xlabel('$x$', fontsize=13)
ax.set_ylabel('$y$', fontsize=13)
ax.set_xlim(0.9, 2.12)
ax.set_ylim(Y_LO * 0.8, Y_HI * 1.2)
ax.tick_params(labelsize=10)
ax.set_aspect('equal')
ax.grid(False)

# Light background
ax.set_facecolor('#fafafa')

# Title
ax.set_title(
    u'The dyadic tiling of the Poincar\u00e9 half-plane\n'
    '$ds^2 = (dx^2 + dy^2)\\, /\\, y^2$',
    fontsize=14, fontweight='bold', pad=15)

# -- Save -----------------------------------------------------------------

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight', facecolor='white')
print("Saved: %s" % OUT_PATH)
print("Done.")
