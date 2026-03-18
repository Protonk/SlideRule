"""
multiplexer.sage — Configuration, layout, and rendering for fractal crossings.

Three render modes:
  make_single()  — one full-bleed panel  → art/crossings.png
  make_zoo()     — 4x4 grid, all 16 kinds → art/zoo.png
  make_params()  — 4x4 grid, one kind, varying params → art/params.png

Uncomment the desired call(s) at the bottom of this file.

Run:  ./sagew experiments/stepstone/art/multiplexer.sage
"""

import os
from helpers import pathing

_here = os.path.dirname(os.path.abspath(
    pathing('experiments', 'stepstone', 'art', 'multiplexer.sage')))
load(pathing('experiments', 'stepstone', 'art', 'raster.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap


# ── COLOR SCHEME — uncomment exactly one ─────────────────────────────

# Black & white (binary parity)
SCHEME = 'bw'

# 2-color: green / gold
# SCHEME = '2c'

# 4-color: teal / red / orange / steel-blue
# SCHEME = '4c'

# Depth-color: one hue per curve (needs DEPTHS to be set first)
# SCHEME = 'depths'


# ── Single-panel config ──────────────────────────────────────────────

KIND = 'stern_brocot_x'
DEPTHS = list(range(1, 21))
X_RES = 3000
Y_RES = 2250
CLIP = True


# ── Zoo config ───────────────────────────────────────────────────────

ZOO_DEPTHS = list(range(1, 15))
ZOO_X_RES = 1200
ZOO_Y_RES = 900


# ── Param-sweep config ──────────────────────────────────────────────

PARAM_KIND = 'geometric_x'
PARAM_DEPTHS_GRID = [
    list(range(1, 11)),
    list(range(1, 13)),
    list(range(1, 15)),
    list(range(1, 17)),
]
PARAM_KINDS_GRID = [
    'geometric_x',
    'stern_brocot_x',
    'harmonic_x',
    'ruler_x',
]
PARAM_X_RES = 1200
PARAM_Y_RES = 900


# ── Build colormap from SCHEME ───────────────────────────────────────

def _build_cmap(scheme, n_depths=None):
    """Return (N_COLORS, CMAP) for the given scheme name."""
    if scheme == 'bw':
        return 2, ListedColormap(['#000000', '#ffffff'])
    elif scheme == '2c':
        return 2, ListedColormap(['#2a9d8f', '#f0b429'])
    elif scheme == '4c':
        return 4, ListedColormap(['#e63946', '#457b9d', '#f4a261', '#2a9d8f'])
    elif scheme == 'depths':
        nc = (n_depths or 20) + 1
        return nc, plt.cm.get_cmap('turbo', nc)
    else:
        raise ValueError("Unknown SCHEME: %r" % scheme)


# ── Shared rendering ────────────────────────────────────────────────

def render_panel(ax, raw_counts, n_colors, cmap, title=None):
    """Draw a raster of raw crossing counts onto an axes."""
    img = raw_counts % n_colors
    ax.axis('off')
    ax.imshow(img, cmap=cmap, aspect='auto',
              interpolation='nearest', vmin=0, vmax=n_colors - 1)
    if title:
        ax.set_title(title, fontsize=8, fontweight='bold', pad=2)


# ── Mode: single panel ──────────────────────────────────────────────

def make_single():
    import sys
    n_colors, cmap = _build_cmap(SCHEME, n_depths=len(DEPTHS))

    sys.stdout.write("Building single raster (%d x %d, %d curves) ... " % (
        X_RES, Y_RES, len(DEPTHS) + 1))
    sys.stdout.flush()

    if CLIP:
        raw = build_raster_clipped(KIND, DEPTHS, X_RES, Y_RES)
    else:
        raw = build_raster(KIND, DEPTHS, X_RES, Y_RES)

    sys.stdout.write("done\n")
    sys.stdout.flush()

    fig = plt.figure(frameon=False)
    fig.set_size_inches(10, 7.5)
    ax = fig.add_axes([0, 0, 1, 1])
    render_panel(ax, raw, n_colors, cmap)

    out_path = os.path.join(_here, 'crossings.png')
    fig.savefig(out_path, dpi=300, pad_inches=0)
    print("Saved: %s" % out_path)


# ── Mode: zoo (all partition kinds) ──────────────────────────────────

def make_zoo():
    import sys
    n_colors, cmap = _build_cmap(SCHEME, n_depths=len(ZOO_DEPTHS))

    fig, axes, _n_rows, _n_cols = zoo_subplots(figsize_per_cell=(4.0, 3.0))
    fig.set_facecolor('#111111')

    total = len(PARTITION_ZOO)
    for idx, (name, color, kind) in enumerate(PARTITION_ZOO):
        row, col = divmod(idx, _n_cols)
        ax = axes[row, col]

        sys.stdout.write("  [%2d/%d] %-20s ... " % (idx + 1, total, name))
        sys.stdout.flush()

        raw = build_raster_clipped(kind, ZOO_DEPTHS, ZOO_X_RES, ZOO_Y_RES)
        render_panel(ax, raw, n_colors, cmap, title=name)
        ax.title.set_color('#dddddd')

        sys.stdout.write("done\n")
        sys.stdout.flush()

    zoo_hide_unused(axes.flat)

    out_path = os.path.join(_here, 'zoo.png')
    fig.savefig(out_path, dpi=200, bbox_inches='tight',
                facecolor=fig.get_facecolor())
    print("Saved: %s" % out_path)


# ── Mode: param sweep ───────────────────────────────────────────────

def make_params():
    import sys

    fig, axes = plt.subplots(4, 4, figsize=(16, 12), constrained_layout=True)
    fig.set_facecolor('#111111')

    # Rows = DEPTHS_GRID entries, Cols = PARAM_KINDS_GRID entries
    total = len(PARAM_DEPTHS_GRID) * len(PARAM_KINDS_GRID)
    panel = 0
    for row, depths in enumerate(PARAM_DEPTHS_GRID):
        n_colors, cmap = _build_cmap(SCHEME, n_depths=len(depths))
        for col, kind in enumerate(PARAM_KINDS_GRID):
            ax = axes[row, col]
            panel += 1

            # Short display name
            short = kind.replace('_x', '')
            label = "%s D=%d" % (short, len(depths))

            sys.stdout.write("  [%2d/%d] %-30s ... " % (panel, total, label))
            sys.stdout.flush()

            raw = build_raster_clipped(kind, depths, PARAM_X_RES, PARAM_Y_RES)
            render_panel(ax, raw, n_colors, cmap, title=label)
            ax.title.set_color('#dddddd')

            sys.stdout.write("done\n")
            sys.stdout.flush()

    out_path = os.path.join(_here, 'params.png')
    fig.savefig(out_path, dpi=200, bbox_inches='tight',
                facecolor=fig.get_facecolor())
    print("Saved: %s" % out_path)


# ── Main — uncomment the mode(s) you want ───────────────────────────

make_single()
# make_zoo()
# make_params()

print("Done.")
