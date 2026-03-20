"""
zoo_barcode.sage — Full partition zoo barcode at a single depth.

Stacks all 23 partition kinds in a single column, one barcode strip per kind,
showing the sign of displacement (path_intercept - free_cell_intercept) for
every cell. Runs compute_case() on the fly for each kind.

Run:  ./sagew experiments/alternation/zoo_barcode.sage
"""

import os
import time
from math import log

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'alternation', 'sign_sequences.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Patch


# ── Configuration ────────────────────────────────────────────────────

Q = 3
DEPTH = 6
P_NUM = 1
Q_DEN = 2
LAYER_DEPENDENT = False
OUT_PATH = pathing('experiments', 'alternation', 'results', 'zoo_barcode.png')

SIGN_COLORS = {-1: '#e74c3c', 0: '#aaaaaa', 1: '#3498db'}
M_STAR = 1.0 / log(2.0)


# ── Compute ──────────────────────────────────────────────────────────

def signs_from_case(case):
    """Extract sign entries directly from a compute_case result."""
    percell_rows = build_percell_rows(case, 'zoo')
    entries = []
    for r in percell_rows:
        fc = r['free_cell_intercept']
        if fc == '':
            continue
        delta = float(r['path_intercept']) - float(fc)
        if delta > EPS_SIGN:
            s = 1
        elif delta < -EPS_SIGN:
            s = -1
        else:
            s = 0
        entries.append((float(r['x_lo']), float(r['x_hi']),
                        float(r['x_mid']), s))
    entries.sort()
    return entries


# ── Plot ─────────────────────────────────────────────────────────────

def draw_barcode(ax, sign_entries, row_y, row_height):
    """Draw one barcode strip."""
    for x_lo, x_hi, x_mid, s in sign_entries:
        rect = Rectangle((x_lo, row_y), x_hi - x_lo, row_height,
                          facecolor=SIGN_COLORS[s], edgecolor='none')
        ax.add_patch(rect)


def make_plot(zoo_signs):
    """zoo_signs is [(display_name, color, kind, sign_entries), ...]"""
    n = len(zoo_signs)
    strip_h = 0.22
    gap_h = 0.04

    fig, ax = plt.subplots(
        figsize=(11, 0.35 * n + 1.5),
    )
    fig.subplots_adjust(left=0.18, right=0.92, top=0.91, bottom=0.06)

    total_h = n * strip_h + (n - 1) * gap_h
    y = total_h

    ytick_positions = []
    ytick_labels = []
    ytick_colors = []

    for name, color, kind, entries in zoo_signs:
        y -= strip_h
        draw_barcode(ax, entries, y, strip_h)

        # Collect label info for y-axis
        center_y = y + strip_h / 2
        ytick_positions.append(center_y)

        signs = signs_only(entries)
        rle = sign_rle(signs)
        ytick_labels.append(name)
        ytick_colors.append(color)

        # Run count on right side, outside the plot
        ax.text(2.015, center_y, '%d' % len(rle),
                fontsize=6.5, va='center', ha='left', color='#555555')

        y -= gap_h

    # m* line
    ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':',
               zorder=5)
    ax.text(M_STAR, total_h + 0.03, '$m^* = 1/\\ln 2$', fontsize=7,
            ha='center', va='bottom', color='#666666')

    ax.set_xlim(1.0, 2.0)
    ax.set_ylim(y, total_h + 0.08)
    ax.set_yticks(ytick_positions)
    ax.set_yticklabels(ytick_labels, fontsize=7, fontweight='bold')
    for tick_label, color in zip(ax.get_yticklabels(), ytick_colors):
        tick_label.set_color(color)
    ax.tick_params(axis='y', length=0, pad=4)
    ax.tick_params(axis='x', labelsize=8)
    ax.set_xlabel('$m \\in [1,\\, 2)$', fontsize=9)

    # "runs" header on the right
    ax.text(2.015, total_h + 0.03, 'runs', fontsize=6.5,
            ha='left', va='bottom', color='#555555', fontstyle='italic')

    # Legend
    legend_patches = [
        Patch(facecolor=SIGN_COLORS[1], label='$\\delta > 0$ (pushed up)'),
        Patch(facecolor=SIGN_COLORS[-1], label='$\\delta < 0$ (pushed down)'),
    ]
    ax.legend(handles=legend_patches, loc='upper right', fontsize=7,
              framealpha=0.8)

    ld_label = 'LD' if LAYER_DEPENDENT else 'LI'
    fig.suptitle(
        'Alternation barcode: all 23 partition kinds\n'
        '$q = %d$, depth $= %d$ ($N = %d$), exponent $= %d/%d$, %s'
        % (Q, DEPTH, 2**DEPTH, P_NUM, Q_DEN, ld_label),
        fontsize=11, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)

print()
ld_label = 'LD' if LAYER_DEPENDENT else 'LI'
print("Zoo barcode: q=%d, depth=%d, exponent=%d/%d, %s"
      % (Q, DEPTH, P_NUM, Q_DEN, ld_label))
print("  Computing %d partition kinds..." % len(PARTITION_ZOO))
print()

zoo_signs = []
t0 = time.time()

for i, (name, color, kind) in enumerate(PARTITION_ZOO):
    t1 = time.time()
    case = compute_case(Q, DEPTH, P_NUM, Q_DEN,
                        partition_kind=kind,
                        layer_dependent=LAYER_DEPENDENT)
    entries = signs_from_case(case)
    zoo_signs.append((name, color, kind, entries))

    signs = signs_only(entries)
    rle = sign_rle(signs)
    print("  %2d/23  %-20s  %2d runs  %.1fs"
          % (i + 1, name, len(rle), time.time() - t1))

print()
print("Total compute: %.1fs" % (time.time() - t0))
make_plot(zoo_signs)
print("Done.")
