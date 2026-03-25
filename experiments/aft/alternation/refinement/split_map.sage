"""
split_map.sage — Where does refinement introduce new sign boundaries?

Single-partition focus. For each adjacent depth pair d -> d+1, draws a wide
horizontal strip over [1, 2] divided into 2^d parent cells. Dark cells =
children disagree in sign (new boundary born). Pale cells = children agree.

Each row has side-by-side LI and LD strips. Depth transitions increase
downward.

Run:  ./sagew experiments/aft/alternation/refinement/split_map.sage
"""

from math import log

from helpers import pathing
load(pathing('experiments', 'aft', 'alternation', 'sign_sequences.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Patch


# ── Configuration ────────────────────────────────────────────────────

KIND = 'uniform_x'
Q = 3
DEPTH_PAIRS = [(3, 4), (4, 5), (5, 6), (6, 7)]
EXPONENT = '1/2'
OUT_PATH = pathing('experiments', 'aft', 'alternation', 'refinement', 'results', 'split_map.png')

SHORT_NAME = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}

# Colors
SPLIT_COLOR = '#2c3e50'    # dark: children disagree
PERSIST_COLOR = '#ecf0f1'  # pale: children agree
LI_ACCENT = '#e74c3c'
LD_ACCENT = '#3498db'
M_STAR = 1.0 / log(2.0)


# ── Plot ─────────────────────────────────────────────────────────────

def draw_split_strip(ax, parent_entries, split_indices, x_offset, width_scale,
                     y_base, strip_h):
    """Draw one refinement strip with optional x offset and scaling."""
    split_set = set(split_indices)
    for i, (x_lo, x_hi, x_mid, s) in enumerate(parent_entries):
        x0 = x_offset + (x_lo - 1.0) * width_scale
        w = (x_hi - x_lo) * width_scale
        color = SPLIT_COLOR if i in split_set else PERSIST_COLOR
        rect = Rectangle((x0, y_base), w, strip_h,
                          facecolor=color, edgecolor='#cccccc',
                          linewidth=0.3)
        ax.add_patch(rect)


def make_plot(rows):
    n_pairs = len(DEPTH_PAIRS)
    strip_h = 0.30
    row_gap = 0.12
    pair_gap = 0.06   # gap between LI and LD within a row
    half_w = 0.46     # each strip spans 46% of width
    li_x0 = 0.0
    ld_x0 = half_w + pair_gap

    total_h = n_pairs * strip_h + (n_pairs - 1) * row_gap
    total_w = 2 * half_w + pair_gap

    fig, ax = plt.subplots(figsize=(13, 1.6 * n_pairs + 2.0))
    fig.subplots_adjust(left=0.10, right=0.88, top=0.88, bottom=0.07)

    kind_short = SHORT_NAME.get(KIND, KIND)

    for pi, (d_lo, d_hi) in enumerate(DEPTH_PAIRS):
        y_base = (n_pairs - 1 - pi) * (strip_h + row_gap)

        for ld, ld_label, x0, accent in [
            (False, 'LI', li_x0, LI_ACCENT),
            (True, 'LD', ld_x0, LD_ACCENT),
        ]:
            entries_lo = extract_signs(rows, KIND, Q, d_lo, EXPONENT, ld)
            entries_hi = extract_signs(rows, KIND, Q, d_hi, EXPONENT, ld)

            if not entries_lo or not entries_hi:
                print("  WARNING: no data for %s LD=%s d=%d->%d"
                      % (KIND, ld, d_lo, d_hi))
                continue

            signs_lo = signs_only(entries_lo)
            signs_hi = signs_only(entries_hi)
            splits = refinement_splits(signs_lo, signs_hi)

            draw_split_strip(ax, entries_lo, splits, x0, half_w,
                             y_base, strip_h)

            # m* line within this strip
            m_star_x = x0 + (M_STAR - 1.0) * half_w
            ax.plot([m_star_x, m_star_x],
                    [y_base - 0.01, y_base + strip_h + 0.01],
                    color='#e67e22', linewidth=0.7, linestyle=':', zorder=5)

            # Strip border
            border = Rectangle((x0, y_base), half_w, strip_h,
                                facecolor='none', edgecolor='#999999',
                                linewidth=0.6)
            ax.add_patch(border)

            # Split count annotation to the right of each strip
            n_splits = len(splits)
            ax.text(x0 + half_w + 0.005, y_base + strip_h / 2,
                    '%d' % n_splits,
                    fontsize=8, va='center', ha='left',
                    color=accent, fontweight='bold')

            # LI/LD header on first row
            if pi == 0:
                ax.text(x0 + half_w / 2, total_h + 0.06, ld_label,
                        fontsize=11, ha='center', va='bottom',
                        fontweight='bold', color=accent)

        # Depth transition label on the left
        ax.text(-0.02, y_base + strip_h / 2,
                'd=%d \u2192 %d' % (d_lo, d_hi),
                fontsize=9, va='center', ha='right',
                fontweight='bold', color='#444444')

        # N parent cells label
        ax.text(-0.02, y_base + strip_h / 2 - 0.06,
                '($N_{parent}=%d$)' % (2**d_lo),
                fontsize=7, va='center', ha='right', color='#888888')

    # Legend
    legend_patches = [
        Patch(facecolor=SPLIT_COLOR, label='split (children disagree)'),
        Patch(facecolor=PERSIST_COLOR, edgecolor='#cccccc',
              label='no split (children agree)'),
    ]
    ax.legend(handles=legend_patches, loc='lower right', fontsize=8,
              framealpha=0.9)

    ax.set_xlim(-0.04, total_w + 0.04)
    ax.set_ylim(-row_gap, total_h + 0.12)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_frame_on(False)

    # Spatial tick labels under both strips (bottom row only)
    bottom_y = -row_gap - 0.02
    for x_val in [1.0, 1.25, 1.5, 1.75, 2.0]:
        for x0 in [li_x0, ld_x0]:
            xp = x0 + (x_val - 1.0) * half_w
            ax.text(xp, bottom_y, '%.2g' % x_val,
                    fontsize=6.5, ha='center', va='top', color='#666666')

    fig.suptitle(
        'Refinement split map: %s\n'
        '$q = %d$, exponent $= %s$' % (kind_short, Q, EXPONENT),
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
