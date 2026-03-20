"""
area_comparison.sage — Raw coastline area comparison: geometric vs golden.

Plots the non-normalized coastline area A_d for both partitions on the same
axes, plus the difference A_d(golden) - A_d(geometric), to show how the
golden ratio's three-distance wobble persists at every depth while geometric
converges monotonically.

Run:  ./sagew experiments/ripple/area_comparison.sage
"""

from helpers import pathing
load(pathing('experiments', 'coastline_series.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

DEPTHS = list(range(1, 13))   # N = 2 .. 4096
KIND_A = 'geometric_x'
KIND_B = 'golden_x'
OUT_PATH = pathing('experiments', 'ripple', 'results', 'area_comparison.png')


# ── Compute ──────────────────────────────────────────────────────────

print()
print("Computing coastline areas...")
raw = coastline_series([KIND_A, KIND_B], DEPTHS, progress=True)

A = raw[KIND_A]
B = raw[KIND_B]
diff = [B[i] - A[i] for i in range(len(DEPTHS))]
Ns = [2**d for d in DEPTHS]

name_a = next(name for name, _, kind in PARTITION_ZOO if kind == KIND_A)
name_b = next(name for name, _, kind in PARTITION_ZOO if kind == KIND_B)
color_a = next(color for _, color, kind in PARTITION_ZOO if kind == KIND_A)
color_b = next(color for _, color, kind in PARTITION_ZOO if kind == KIND_B)


# ── Plot ─────────────────────────────────────────────────────────────

fig, (ax_top, ax_bot) = plt.subplots(
    2, 1, figsize=(10, 6.5), constrained_layout=True,
    gridspec_kw={'height_ratios': [2, 1]}, sharex=True,
)

xs = list(range(len(Ns)))

# Top panel: both raw areas
ax_top.plot(xs, A, 'o-', color=color_a, linewidth=1.4, markersize=5,
            label=name_a, zorder=3)
ax_top.plot(xs, B, 's-', color=color_b, linewidth=1.4, markersize=5,
            label=name_b, zorder=3)
ax_top.set_ylabel('Coastline area $A_d$', fontsize=10)
ax_top.set_yscale('log')
ax_top.legend(fontsize=9, loc='upper right')
ax_top.grid(True, alpha=0.3, linewidth=0.5)
ax_top.tick_params(labelsize=8)

# Bottom panel: difference
ax_bot.bar(xs, diff, color=color_b, alpha=0.7, edgecolor=color_b,
           linewidth=0.6)
ax_bot.axhline(0.0, color='#999999', linewidth=0.6, linestyle='--')
ax_bot.set_ylabel('$A_d^{\\mathrm{%s}} - A_d^{\\mathrm{%s}}$' % (
    name_b.replace('-', '\\text{-}'), name_a.replace('-', '\\text{-}')),
    fontsize=10)
ax_bot.grid(True, alpha=0.3, linewidth=0.5)
ax_bot.tick_params(labelsize=8)

ax_bot.set_xticks(xs)
ax_bot.set_xticklabels(['N=%d' % n for n in Ns], fontsize=8)
ax_bot.set_xlabel('Partition resolution', fontsize=9)

fig.suptitle(
    'Raw coastline area: %s vs %s' % (name_a, name_b),
    fontsize=13, fontweight='bold',
)

fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
print("Saved: %s" % OUT_PATH)
print("Done.")
