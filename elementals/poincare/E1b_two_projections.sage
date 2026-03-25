"""
E1b_two_projections.sage — Two slicings of one tiling.

Claim (TILING.md L22-L25):
    The binary partition of [1, 2) and the geometric partition of [1, 2)
    are two coordinate views of the same structure. Uniform-width cells
    (additive subdivision) and equal-log-width cells (geometric
    subdivision) are the horocyclic and geodesic slicings of the same
    tiling.

Mathematical objects drawn:
    - Two number lines spanning [1, 2)
    - Top: equally spaced ticks (horocyclic / uniform partition)
    - Bottom: ticks at 2^(k/N) (geodesic / geometric partition)
    - Connecting lines between corresponding ticks showing they come
      from the same grid read in two coordinate systems

No displacement magnitude, no epsilon overlay. Just the two readings
of one grid.

Output: elementals/poincare/results/E1b_two_projections.png

Run:  ./sagew elementals/poincare/E1b_two_projections.sage
"""

import os
from math import log2

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


OUT_PATH = pathing('elementals', 'poincare', 'results',
                    'E1b_two_projections.png')


# -- Colors ----------------------------------------------------------------

C_HORO = '#1f77b4'   # horocyclic / uniform
C_GEO  = '#9467bd'   # geodesic / geometric
C_CONN = '#cccccc'   # connecting lines
C_GRAY = '#999999'


# -- Grid ------------------------------------------------------------------

DEPTH = 3
N = 2 ** DEPTH

bin_pts = [1.0 + k / N for k in range(N + 1)]
geo_pts = [2.0 ** (k / N) for k in range(N + 1)]


# -- Figure ----------------------------------------------------------------

fig, ax = plt.subplots(figsize=(12, 4.5))

y_top = 0.7    # horocyclic line
y_bot = 0.3    # geodesic line

# Connecting lines (draw first, behind everything)
for k in range(N + 1):
    bx = bin_pts[k]
    gx = geo_pts[k]
    ax.plot([bx, gx], [y_top - 0.04, y_bot + 0.04], '-', color=C_CONN,
            linewidth=0.8, zorder=1)

# -- Top line: horocyclic (uniform) ----------------------------------------

ax.plot([1.0, 2.0], [y_top, y_top], '-', color=C_HORO, linewidth=2.5,
        zorder=2)

for k in range(N + 1):
    bx = bin_pts[k]
    ax.plot([bx, bx], [y_top - 0.035, y_top + 0.035], '-', color=C_HORO,
            linewidth=2.5, zorder=3)

# Cell shading (alternating)
for k in range(N):
    if k % 2 == 0:
        ax.fill_between([bin_pts[k], bin_pts[k + 1]],
                        y_top - 0.025, y_top + 0.025,
                        color=C_HORO, alpha=0.08, zorder=1)

# Label
ax.text(2.03, y_top, 'horocyclic (uniform)', fontsize=13, color=C_HORO,
        ha='left', va='center', fontweight='bold')
ax.text(2.03, y_top - 0.06, 'equal additive width', fontsize=10,
        color=C_HORO, ha='left', va='top', alpha=0.7)

# -- Bottom line: geodesic (geometric) ------------------------------------

ax.plot([1.0, 2.0], [y_bot, y_bot], '-', color=C_GEO, linewidth=2.5,
        zorder=2)

for k in range(N + 1):
    gx = geo_pts[k]
    ax.plot([gx, gx], [y_bot - 0.035, y_bot + 0.035], '-', color=C_GEO,
            linewidth=2.5, zorder=3)

# Cell shading (alternating)
for k in range(N):
    if k % 2 == 0:
        ax.fill_between([geo_pts[k], geo_pts[k + 1]],
                        y_bot - 0.025, y_bot + 0.025,
                        color=C_GEO, alpha=0.08, zorder=1)

# Label
ax.text(2.03, y_bot, 'geodesic (geometric)', fontsize=13, color=C_GEO,
        ha='left', va='center', fontweight='bold')
ax.text(2.03, y_bot - 0.06, 'equal log-width', fontsize=10,
        color=C_GEO, ha='left', va='top', alpha=0.7)

# -- Endpoint labels -------------------------------------------------------

ax.text(1.0, y_top + 0.07, '$1$', fontsize=11, ha='center', color=C_GRAY)
ax.text(2.0, y_top + 0.07, '$2$', fontsize=11, ha='center', color=C_GRAY)

# -- Caption ---------------------------------------------------------------

ax.text(1.5, 0.12,
        'The uniform and geometric partitions arise as\n'
        'horocyclic and geodesic slicings of the same tiling.',
        fontsize=12, ha='center', va='center', color='#333333',
        style='italic')

# -- Axes ------------------------------------------------------------------

ax.set_xlim(0.95, 2.45)
ax.set_ylim(0.02, 0.88)
ax.axis('off')

# -- Save ------------------------------------------------------------------

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight', facecolor='white')
print("Saved: %s" % OUT_PATH)
print("Done.")
