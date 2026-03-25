"""
stability_heatmap.sage — Normalized coastline area stability across partitions.

For each partition at each N, compares the normalized area (area*N / geo_area*N)
to the previous N.  Red = stable (<5% change), Black = shifted.  Rows sorted
by proportion of black (most unstable at top), geometric excluded (it is the
normalization baseline).

Run:  ./sagew experiments/aft/stepstone/ripple/stability_heatmap.sage
"""

from helpers import pathing
load(pathing('experiments', 'coastline_series.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

DEPTHS = list(range(1, 13))   # N = 2 .. 4096
THRESHOLD = 0.005


# ── Precompute ───────────────────────────────────────────────────────

def precompute():
    Ns = [2**d for d in DEPTHS]
    kinds = [kind for _, _, kind in PARTITION_ZOO]
    raw = coastline_series(kinds, DEPTHS, progress=True)
    scaled = scaled_series(raw, DEPTHS)
    all_ratios = geometric_relative_series(scaled)
    return Ns, all_ratios


# ── Build grid ───────────────────────────────────────────────────────

def build_grid(Ns, all_ratios):
    # Exclude geometric (it's the baseline)
    entries = [(name, kind) for name, _, kind in PARTITION_ZOO
               if kind != 'geometric_x']

    display_Ns = Ns[1:]  # Current N in each depth-to-depth comparison
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

    out_path = pathing('experiments', 'aft', 'stepstone', 'ripple', 'results', 'stability_heatmap.png')
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Computing coastline areas...")
Ns, all_ratios = precompute()
display_Ns, names, grid = build_grid(Ns, all_ratios)
make_plot(display_Ns, names, grid)
print("Done.")
