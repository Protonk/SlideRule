"""
E3_binary_tiling_dual.sage — Binary tiling of the half-plane with dual overlay.

Claim (TILING.md L14-25):
    The binary tiling of the Poincare half-plane consists of rectangles
    related by dyadic scaling. Its dual has curved faces (petals) whose
    boundaries are hyperbolic geodesics connecting adjacent cell centers.

Mathematical objects drawn:
    - Rectangular tiling cells in the Poincare half-plane (red grid)
    - Dual faces around each tiling vertex (colored petals)
    - Geodesic arcs (semicircles centered on the x-axis) forming
      the dual cell boundaries

Output: elementals/poincare/results/E3_binary_tiling_dual.png

Run:  ./sagew elementals/poincare/E3_binary_tiling_dual.sage
"""

import os
from math import sqrt, atan2, pi, log2

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import numpy as np


OUT_PATH = pathing('elementals', 'poincare', 'results',
                    'E3_binary_tiling_dual.png')

# -- Configuration --------------------------------------------------------

X_TOTAL = 2.0       # show 2 coarse-level cells
MAX_DEPTH = 4        # levels 0..MAX_DEPTH (finest cells have width 2^-MAX_DEPTH)

# Colors matching the Wikipedia SVG
C_YELLOW = '#ffe07f'
C_GREEN  = '#7fc8a2'
C_BLUE   = '#7fc0e6'
C_GRID   = '#bc1e46'


# -- Cell geometry ---------------------------------------------------------

def build_cells():
    """Build all tiling cells.

    Level d has 2^(d+1) cells of width X_TOTAL / 2^(d+1) = 2^(-d).
    y range: [2^(-d), 2^(-d+1)].
    Include level -1 (1 parent cell above) for top dual faces.
    """
    cells = {}
    for d in range(-1, MAX_DEPTH + 1):
        if d == -1:
            n = 1
            w = X_TOTAL
            y_lo, y_hi = 2.0, 4.0
        else:
            n = 2 ** (d + 1)
            w = X_TOTAL / n
            y_lo = 2.0 ** (-d)
            y_hi = 2.0 ** (-d + 1)

        y_c = sqrt(y_lo * y_hi)
        for k in range(n):
            x_lo = k * w
            cells[(d, k)] = {
                'x_lo': x_lo, 'x_hi': x_lo + w,
                'y_lo': y_lo, 'y_hi': y_hi,
                'x_c': x_lo + w / 2.0,
                'y_c': y_c,
            }
    return cells


def build_vertices(cells):
    """Find all interior tiling vertices and their adjacent cells.

    At each horocyclic boundary y = 2^(-d), vertices sit at the
    finer-level cell boundaries. Split vertices (valence 3) are
    T-junctions; continuing vertices (valence 4) persist from the
    coarser level.
    """
    verts = []

    for d in range(-1, MAX_DEPTH):
        y_b = 2.0 ** (-d) if d >= 0 else 2.0
        n_fine = 2 ** (d + 2) if d >= 0 else 2
        fine_w = X_TOTAL / n_fine

        for k in range(1, n_fine):
            x = k * fine_w
            is_continuing = (k % 2 == 0)

            if d == -1:
                # Top boundary: only split vertices (one parent)
                adj = [(-1, 0), (0, k - 1), (0, k)]
            elif is_continuing:
                kc = k // 2
                adj = [(d, kc - 1), (d, kc), (d + 1, k - 1), (d + 1, k)]
            else:
                kc = k // 2
                adj = [(d, kc), (d + 1, k - 1), (d + 1, k)]

            adj = [c for c in adj if c in cells]
            if len(adj) < 3:
                continue

            verts.append({
                'x': x, 'y': y_b,
                'adj': adj,
                'depth': d,
            })

    return verts


# -- Geodesic arcs ---------------------------------------------------------

def geodesic_arc(p1, p2, n_pts=40):
    """Points along the hyperbolic geodesic from p1 to p2."""
    x1, y1 = p1
    x2, y2 = p2

    if abs(x1 - x2) < 1e-12:
        ts = np.linspace(0, 1, n_pts)
        return np.column_stack([np.full(n_pts, x1),
                                y1 + ts * (y2 - y1)])

    cx = ((x1**2 + y1**2) - (x2**2 + y2**2)) / (2.0 * (x1 - x2))
    r = sqrt((x1 - cx)**2 + y1**2)

    t1 = atan2(y1, x1 - cx)
    t2 = atan2(y2, x2 - cx)

    # Always go the short way around (both angles in (0, pi))
    if t1 < 0: t1 += 2 * pi
    if t2 < 0: t2 += 2 * pi

    ts = np.linspace(t1, t2, n_pts)
    xs = cx + r * np.cos(ts)
    ys = r * np.sin(ts)
    return np.column_stack([xs, ys])


def dual_face_polygon(vertex, cells):
    """Build the polygon for the dual face around a tiling vertex."""
    centers = [(cells[c]['x_c'], cells[c]['y_c']) for c in vertex['adj']]
    vx, vy = vertex['x'], vertex['y']

    # Sort centers counter-clockwise around the vertex
    def angle(c):
        return atan2(c[1] - vy, c[0] - vx)
    centers.sort(key=angle)

    # Connect consecutive centers with geodesic arcs
    pts = []
    n = len(centers)
    for i in range(n):
        arc = geodesic_arc(centers[i], centers[(i + 1) % n], n_pts=30)
        pts.extend(arc[:-1].tolist())

    return np.array(pts)


# -- Coloring --------------------------------------------------------------

def face_color(vertex):
    """Assign color based on valence and depth."""
    v = len(vertex['adj'])
    d = vertex['depth']
    if v == 3:
        return C_YELLOW
    elif d % 2 == 0:
        return C_GREEN
    else:
        return C_BLUE


# -- Render ----------------------------------------------------------------

def make_figure():
    cells = build_cells()
    verts = build_vertices(cells)
    print("  %d cells, %d vertices" % (len(cells), len(verts)))

    fig, ax = plt.subplots(figsize=(14, 10))

    # Clip to visible region
    y_min = 2.0 ** (-MAX_DEPTH) * 0.7
    y_max = 3.2

    # Draw dual faces
    for v in verts:
        poly_pts = dual_face_polygon(v, cells)
        color = face_color(v)
        patch = Polygon(poly_pts, closed=True,
                        facecolor=color, edgecolor='#000000',
                        linewidth=0.4, zorder=2)
        ax.add_patch(patch)

    # Draw tiling grid (red)
    for (d, k), cell in cells.items():
        if d < 0:
            continue
        y_lo = cell['y_lo']
        y_hi = cell['y_hi']
        x_lo = cell['x_lo']
        x_hi = cell['x_hi']

        # Horizontal edges
        ax.plot([x_lo, x_hi], [y_lo, y_lo], '-', color=C_GRID,
                linewidth=1.2, zorder=3)
        ax.plot([x_lo, x_hi], [y_hi, y_hi], '-', color=C_GRID,
                linewidth=1.2, zorder=3)
        # Vertical edges
        ax.plot([x_lo, x_lo], [y_lo, y_hi], '-', color=C_GRID,
                linewidth=1.2, zorder=3)
        ax.plot([x_hi, x_hi], [y_lo, y_hi], '-', color=C_GRID,
                linewidth=1.2, zorder=3)

    ax.set_xlim(-0.05, X_TOTAL + 0.05)
    ax.set_ylim(y_min, y_max)
    ax.set_aspect('equal')
    ax.axis('off')

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight', facecolor='white')
    print("Saved: %s" % OUT_PATH)


# -- Main ------------------------------------------------------------------

print()
print("Binary tiling dual...")
make_figure()
print("Done.")
