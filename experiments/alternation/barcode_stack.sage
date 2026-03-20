"""
barcode_stack.sage — Depth-stacked barcode of sign patterns.

For each partition kind, shows a vertical stack of horizontal barcode strips
(one per depth). Each strip has N = 2^depth cells colored by sign: blue (+),
red (-), gray (0). Two columns: LI on the left, LD on the right.

Vertical line at m* = 1/ln(2) marks the curvature crossover.

Run:  ./sagew experiments/alternation/barcode_stack.sage
"""

from math import log

from helpers import pathing
load(pathing('experiments', 'alternation', 'sign_sequences.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.colors import ListedColormap
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
Q = 3
DEPTHS = [3, 4, 5, 6, 7]
EXPONENT = '1/2'
OUT_PATH = pathing('experiments', 'alternation', 'results', 'barcode_stack.png')

SHORT_NAME = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}

# Colors: -1 -> red, 0 -> gray, +1 -> blue
SIGN_COLORS = {-1: '#e74c3c', 0: '#aaaaaa', 1: '#3498db'}
M_STAR = 1.0 / log(2.0)


# ── Plot ─────────────────────────────────────────────────────────────

def draw_barcode(ax, sign_entries, row_y, row_height):
    """Draw one barcode strip on the given axes."""
    for x_lo, x_hi, x_mid, s in sign_entries:
        color = SIGN_COLORS[s]
        rect = Rectangle((x_lo, row_y), x_hi - x_lo, row_height,
                          facecolor=color, edgecolor='none')
        ax.add_patch(rect)


def make_plot(rows):
    n_kinds = len(KINDS)
    n_depths = len(DEPTHS)
    strip_h = 0.15
    gap_h = 0.04
    panel_h = n_depths * strip_h + (n_depths - 1) * gap_h

    fig, axes = plt.subplots(
        n_kinds, 2,
        figsize=(13, 1.8 * n_kinds + 1.0),
        constrained_layout=True,
    )

    for ki, kind in enumerate(KINDS):
        for col, (ld, ld_label) in enumerate([(False, 'LI'), (True, 'LD')]):
            ax = axes[ki, col]

            for di, depth in enumerate(DEPTHS):
                entries = extract_signs(rows, kind, Q, depth, EXPONENT, ld)
                if not entries:
                    print("  WARNING: no data for %s LD=%s d=%d" % (kind, ld, depth))
                    continue

                y_base = (n_depths - 1 - di) * (strip_h + gap_h)
                draw_barcode(ax, entries, y_base, strip_h)

                # Depth label on left edge
                ax.text(0.995, y_base + strip_h / 2, 'd=%d' % depth,
                        fontsize=6, va='center', ha='left',
                        transform=ax.get_yaxis_transform(),
                        color='#555555')

            # m* line
            ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':',
                       zorder=5)

            ax.set_xlim(1.0, 2.0)
            ax.set_ylim(-gap_h, panel_h + gap_h)
            ax.set_yticks([])
            ax.tick_params(axis='x', labelsize=7)

            if ki == 0:
                ax.set_title(ld_label, fontsize=10, fontweight='bold')
            if col == 0:
                ax.set_ylabel(SHORT_NAME.get(kind, kind), fontsize=9,
                              fontweight='bold')
            if ki == n_kinds - 1:
                ax.set_xlabel('$m \\in [1,\\, 2)$', fontsize=8)

    # Legend
    from matplotlib.patches import Patch
    legend_patches = [
        Patch(facecolor=SIGN_COLORS[1], label='$\\delta > 0$ (pushed up)'),
        Patch(facecolor=SIGN_COLORS[-1], label='$\\delta < 0$ (pushed down)'),
        Patch(facecolor=SIGN_COLORS[0], label='neutral'),
    ]
    fig.legend(handles=legend_patches, loc='lower center', ncol=3,
               fontsize=8, bbox_to_anchor=(0.5, -0.02))

    fig.suptitle(
        'Alternation barcode: sign of displacement across cells\n'
        '$q = %d$, exponent $= %s$' % (Q, EXPONENT),
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

import os
os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)

print()
print("Loading percell data...")
rows = load_percell()
print("  %d rows loaded" % len(rows))
make_plot(rows)
print("Done.")
