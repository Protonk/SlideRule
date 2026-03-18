"""
stability_heatmap.sage — Normalized coastline area stability across partitions.

For each partition at each N, compares the normalized area (area*N / geo_area*N)
to the previous N.  Red = stable (<5% change), Black = shifted.  Rows sorted
by proportion of black (most unstable at top), geometric excluded (it is the
normalization baseline).

Run:  ./sagew experiments/chord_error/stepstones/hazards/stability_heatmap.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2
from scipy import integrate
from matplotlib.colors import ListedColormap
import sys


# ── Configuration ────────────────────────────────────────────────────

DEPTHS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]   # N = 2 .. 1024
THRESHOLD = 0.005


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def continuous_slope(m):
    return 1.0 / (m * log(2.0)) - 1.0


def coastline_area(depth, kind):
    cells = float_cells(depth, kind)
    total = 0.0
    for a, b in cells:
        sigma_dev = cell_chord_slope(a, b) - 1.0
        area, _ = integrate.quad(
            lambda m: abs(continuous_slope(m) - sigma_dev), a, b)
        total += area
    return total


# ── Precompute ───────────────────────────────────────────────────────

def precompute():
    Ns = [2**d for d in DEPTHS]
    all_areas = {}
    total = len(PARTITION_ZOO)
    for idx, (name, color, kind) in enumerate(PARTITION_ZOO):
        sys.stdout.write("  [%2d/%d] %-20s ... " % (idx + 1, total, name))
        sys.stdout.flush()
        all_areas[kind] = [coastline_area(d, kind) for d in DEPTHS]
        sys.stdout.write("done\n")
        sys.stdout.flush()

    geo_areaN = [all_areas['geometric_x'][i] * Ns[i] for i in range(len(DEPTHS))]

    all_ratios = {}
    for name, color, kind in PARTITION_ZOO:
        areas = all_areas[kind]
        all_ratios[kind] = [(areas[i] * Ns[i]) / geo_areaN[i]
                            for i in range(len(DEPTHS))]

    return Ns, all_ratios


# ── Build grid ───────────────────────────────────────────────────────

def build_grid(Ns, all_ratios):
    # Exclude geometric (it's the baseline)
    entries = [(name, kind) for name, _, kind in PARTITION_ZOO
               if kind != 'geometric_x']

    display_Ns = Ns[1:]  # N = 4 .. 256
    n_cols = len(display_Ns)

    rows = []
    for name, kind in entries:
        ratios = all_ratios[kind]
        row_vals = []
        for col in range(n_cols):
            prev = ratios[col]
            curr = ratios[col + 1]
            rel_change = abs(curr - prev) / abs(prev) if prev != 0 else 1.0
            row_vals.append(1.0 if rel_change < THRESHOLD else 0.0)
        black_frac = 1.0 - sum(row_vals) / n_cols
        rows.append((black_frac, name, row_vals))

    # Sort: most black (unstable) at top
    rows.sort(key=lambda r: -r[0])

    names = [r[1] for r in rows]
    grid = np.array([r[2] for r in rows])
    return display_Ns, names, grid


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(display_Ns, names, grid):
    n_rows, n_cols = grid.shape
    from matplotlib.patches import Rectangle

    plt.rcParams['hatch.linewidth'] = 2.0
    fig, ax = plt.subplots(figsize=(9, 6.5), constrained_layout=True)

    # Draw cells: red solid for stable, black crosshatched for unstable
    for row in range(n_rows):
        for col in range(n_cols):
            x0 = col - 0.5
            y0 = row - 0.5
            if grid[row, col] == 1.0:
                rect = Rectangle((x0, y0), 1, 1,
                                 facecolor='#3a6ea5', edgecolor='none')
            else:
                rect = Rectangle((x0, y0), 1, 1,
                                 facecolor='#111111', edgecolor='#777777',
                                 linewidth=0.3, hatch='XX')
            ax.add_patch(rect)

    ax.set_xlim(-0.5, n_cols - 0.5)
    ax.set_ylim(n_rows - 0.5, -0.5)

    ax.set_xticks(range(n_cols))
    ax.set_xticklabels(['N=%d' % n for n in display_Ns], fontsize=9)
    ax.set_yticks(range(n_rows))
    ax.set_yticklabels(names, fontsize=8)

    for x in range(n_cols + 1):
        ax.axvline(x - 0.5, color='#ffffff', linewidth=0.5)
    for y in range(n_rows + 1):
        ax.axhline(y - 0.5, color='#ffffff', linewidth=0.5)

    ax.set_xlabel('Hatched cells are unstable (>0.5% change) over increase in N',
                  fontsize=9)

    fig.suptitle(
        'Normalized coastline area stabilizes at different rates across partitions',
        fontsize=12, fontweight='bold',
    )

    out_path = 'experiments/chord_error/stepstones/hazards/stability_heatmap.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Computing coastline areas...")
Ns, all_ratios = precompute()
display_Ns, names, grid = build_grid(Ns, all_ratios)
make_plot(display_Ns, names, grid)
print("Done.")
