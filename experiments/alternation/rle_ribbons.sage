"""
rle_ribbons.sage — RLE ribbon chart of alternation patterns.

For each (kind, depth, layer_mode), draws a horizontal ribbon divided into
contiguous sign runs over the spatial domain [1, 2). Segment width shows the
run's spatial extent, while the overlaid integer shows the run length in
cells. Transition tick marks show sign boundaries.

Run:  ./sagew experiments/alternation/rle_ribbons.sage
"""

from math import log

from helpers import pathing
load(pathing('experiments', 'alternation', 'sign_sequences.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
Q = 3
DEPTHS = [3, 4, 5, 6, 7]
EXPONENT = '1/2'
OUT_PATH = pathing('experiments', 'alternation', 'results', 'rle_ribbons.png')

SHORT_NAME = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}

SIGN_COLORS = {-1: '#e74c3c', 0: '#aaaaaa', 1: '#3498db'}
SIGN_TEXT = {-1: '#ffffff', 0: '#333333', 1: '#ffffff'}
M_STAR = 1.0 / log(2.0)


# ── Plot ─────────────────────────────────────────────────────────────

def spatial_runs(sign_entries):
    """Return contiguous sign runs as (sign, x_lo, x_hi, run_len)."""
    if not sign_entries:
        return []

    runs = []
    cur_sign = sign_entries[0][3]
    cur_x_lo = sign_entries[0][0]
    cur_x_hi = sign_entries[0][1]
    cur_len = 1

    for x_lo, x_hi, x_mid, sign in sign_entries[1:]:
        if sign == cur_sign:
            cur_x_hi = x_hi
            cur_len += 1
        else:
            runs.append((cur_sign, cur_x_lo, cur_x_hi, cur_len))
            cur_sign = sign
            cur_x_lo = x_lo
            cur_x_hi = x_hi
            cur_len = 1

    runs.append((cur_sign, cur_x_lo, cur_x_hi, cur_len))
    return runs


def draw_ribbon(ax, runs, y_base, ribbon_h):
    """Draw one ribbon in spatial coordinates; labels show cell counts."""
    for sign, x_lo, x_hi, run_len in runs:
        w = x_hi - x_lo
        rect = Rectangle((x_lo, y_base), w, ribbon_h,
                         facecolor=SIGN_COLORS[sign], edgecolor='white',
                         linewidth=0.5)
        ax.add_patch(rect)

        # Annotate with run length if the spatial segment is wide enough.
        if w > 0.04:
            ax.text((x_lo + x_hi) / 2, y_base + ribbon_h / 2, str(run_len),
                    fontsize=5.5, ha='center', va='center',
                    color=SIGN_TEXT[sign], fontweight='bold')


def draw_transition_ticks(ax, transitions, y_top, tick_h=0.02):
    """Draw small tick marks at transition positions."""
    for t in transitions:
        ax.plot([t, t], [y_top, y_top + tick_h],
                color='#333333', linewidth=0.6, clip_on=False)


def make_plot(rows):
    n_kinds = len(KINDS)
    n_depths = len(DEPTHS)
    ribbon_h = 0.12
    pair_gap = 0.02      # between LI and LD for same depth
    depth_gap = 0.06     # between depth groups
    kind_gap = 0.20      # between kind groups

    # Compute total height
    pair_h = 2 * ribbon_h + pair_gap
    kind_h = n_depths * pair_h + (n_depths - 1) * depth_gap
    total_h = n_kinds * kind_h + (n_kinds - 1) * kind_gap

    fig, ax = plt.subplots(figsize=(12, total_h * 2.5 + 2.0),
                           constrained_layout=True)

    y_labels = []  # (y_center, label) for kind labels
    depth_labels = []  # (y_center, label)

    y = total_h  # start from top

    for ki, kind in enumerate(KINDS):
        kind_y_top = y
        for di, depth in enumerate(DEPTHS):
            # LI ribbon (top of pair)
            entries_li = extract_signs(rows, kind, Q, depth, EXPONENT, False)
            runs_li = spatial_runs(entries_li)
            trans_li = transition_positions(entries_li)

            y -= ribbon_h
            draw_ribbon(ax, runs_li, y, ribbon_h)
            draw_transition_ticks(ax, trans_li, y + ribbon_h, 0.015)

            # LI label
            ax.text(-0.02, y + ribbon_h / 2, 'LI', fontsize=5.5,
                    ha='right', va='center', color='#888888',
                    transform=ax.get_yaxis_transform())

            y -= pair_gap

            # LD ribbon (bottom of pair)
            entries_ld = extract_signs(rows, kind, Q, depth, EXPONENT, True)
            runs_ld = spatial_runs(entries_ld)
            trans_ld = transition_positions(entries_ld)

            y -= ribbon_h
            draw_ribbon(ax, runs_ld, y, ribbon_h)
            draw_transition_ticks(ax, trans_ld, y + ribbon_h, 0.015)

            # LD label
            ax.text(-0.02, y + ribbon_h / 2, 'LD', fontsize=5.5,
                    ha='right', va='center', color='#888888',
                    transform=ax.get_yaxis_transform())

            # Depth label on right
            pair_center = y + ribbon_h + pair_gap / 2
            ax.text(1.02, pair_center, 'd=%d' % depth,
                    fontsize=6.5, ha='left', va='center', color='#555555',
                    transform=ax.get_yaxis_transform())

            if di < n_depths - 1:
                y -= depth_gap

        # Kind label on far left
        kind_y_bottom = y
        kind_center = (kind_y_top + kind_y_bottom) / 2
        y_labels.append((kind_center, SHORT_NAME.get(kind, kind)))

        if ki < n_kinds - 1:
            y -= kind_gap

    # m* line in the shared spatial coordinate system.
    ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':',
               zorder=0)
    ax.text(M_STAR, total_h + 0.05, '$m^*$', fontsize=7,
            ha='center', va='bottom', color='#666666')

    # Kind labels
    for yc, label in y_labels:
        ax.text(-0.08, yc, label, fontsize=9, fontweight='bold',
                ha='right', va='center', rotation=90,
                transform=ax.get_yaxis_transform())

    ax.set_xlim(1.0, 2.0)
    ax.set_ylim(y - 0.05, total_h + 0.1)
    ax.set_xticks([1.0, 1.25, 1.5, 1.75, 2.0])
    ax.set_xticklabels(['1.0', '1.25', '1.5', '1.75', '2.0'], fontsize=7)
    ax.set_yticks([])
    ax.set_xlabel('$m \\in [1,\\, 2)$', fontsize=9)

    # Legend
    from matplotlib.patches import Patch
    legend_patches = [
        Patch(facecolor=SIGN_COLORS[1], label='$+$ (pushed up)'),
        Patch(facecolor=SIGN_COLORS[-1], label='$-$ (pushed down)'),
    ]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=7,
              framealpha=0.8)

    fig.suptitle(
        'RLE ribbons: spatial run structure of alternation patterns\n'
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
