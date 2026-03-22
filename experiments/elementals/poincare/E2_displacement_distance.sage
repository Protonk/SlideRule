"""
E2_displacement_distance.sage — The displacement field as hyperbolic distance.

Claim (TILING.md L60-L71):
    In the half-plane model, place the geometric grid at heights
    y_k = 2^(k/2^d) and the binary grid at heights y_k = 1 + k/2^d.
    The hyperbolic distance between corresponding points along a common
    geodesic is d_hyp(k) = |log(b_k / g_k)|. This peaks at m* ~ 0.44
    and inherits the shape of the pseudo-log error epsilon.

    The scaling relation is d_hyp(m) = (ln 2) * eps(m) on [0, 1).

Mathematical objects drawn:
    Top panel: vertical geodesics with two points each (binary height,
    geometric height), connected by segments whose length is d_hyp.
    Bottom panel: d_hyp(m) as a curve, showing it has the epsilon shape.

Output: experiments/elementals/poincare/results/E2_displacement_distance.png

Run:  ./sagew experiments/elementals/poincare/E2_displacement_distance.sage
"""

import os
from math import log, log2

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


OUT_PATH = pathing('experiments', 'elementals', 'poincare', 'results',
                    'E2_displacement_distance.png')


# -- Colors ----------------------------------------------------------------

C_HORO = '#1f77b4'   # binary / horocyclic
C_GEO  = '#9467bd'   # geometric / geodesic
C_DISP = '#d62728'   # displacement segment
C_EPS  = '#2ca02c'   # epsilon curve
C_GRAY = '#999999'

LN2 = log(2.0)
M_STAR = 1.0 / LN2 - 1.0


# -- Grid ------------------------------------------------------------------

DEPTH = 4
N = 2 ** DEPTH


# -- Figure ----------------------------------------------------------------

fig, (ax_top, ax_bot) = plt.subplots(
    2, 1, figsize=(12, 8), height_ratios=[3, 2],
    gridspec_kw={'hspace': 0.30})


# ══════════════════════════════════════════════════════════════════════════
# Top panel: geodesics with two heights each
# ══════════════════════════════════════════════════════════════════════════

# Each index k gets one vertical geodesic at x = k.
# On that geodesic, place:
#   - binary point at height b_k = 1 + k/N   (blue dot)
#   - geometric point at height g_k = 2^(k/N) (purple dot)
# Connect them with a red segment.

# y-axis range
y_lo = 0.95
y_hi = 2.08

for k in range(N + 1):
    m = k / N
    b_k = 1.0 + m          # binary height
    g_k = 2.0 ** m         # geometric height

    # Vertical geodesic (thin gray line)
    ax_top.plot([k, k], [y_lo, y_hi], '-', color='#e0e0e0', linewidth=0.6,
                zorder=0)

    if k == 0 or k == N:
        # Endpoints coincide: b_k = g_k
        ax_top.plot(k, b_k, 'o', color=C_GRAY, markersize=5, zorder=4)
    else:
        # Displacement segment
        ax_top.plot([k, k], [g_k, b_k], '-', color=C_DISP, linewidth=2.5,
                    solid_capstyle='round', zorder=3)

        # Binary point (blue, top)
        ax_top.plot(k, b_k, 'o', color=C_HORO, markersize=5, zorder=5)
        # Geometric point (purple, bottom)
        ax_top.plot(k, g_k, 's', color=C_GEO, markersize=4, zorder=5)

# Reference horocycles (faint)
for y_ref in [1.0, 1.5, 2.0]:
    ax_top.axhline(y_ref, color='#f0f0f0', linewidth=0.5, zorder=0)

# Labels for one pair
k_lab = N // 2 + 2  # pick a point near the peak
m_lab = k_lab / N
b_lab = 1.0 + m_lab
g_lab = 2.0 ** m_lab
d_lab = abs(log(b_lab / g_lab))

ax_top.annotate('$b_k = 1 + k/2^d$',
                xy=(k_lab + 0.3, b_lab), fontsize=10, color=C_HORO,
                va='center')
ax_top.annotate('$g_k = 2^{k/2^d}$',
                xy=(k_lab + 0.3, g_lab), fontsize=10, color=C_GEO,
                va='center')

# d_hyp annotation at the peak displacement
k_peak = max(range(1, N), key=lambda k: abs(log((1.0 + k/N) / 2.0**(k/N))))
b_peak = 1.0 + k_peak / N
g_peak = 2.0 ** (k_peak / N)
ax_top.annotate(
    '$d_{\\mathrm{hyp}} = |\\log(b_k / g_k)|$',
    xy=(k_peak - 0.3, (b_peak + g_peak) / 2),
    xytext=(k_peak - 3.5, (b_peak + g_peak) / 2 + 0.2),
    fontsize=11, color=C_DISP, ha='center',
    arrowprops=dict(arrowstyle='->', color=C_DISP, linewidth=1.0))

ax_top.set_xlim(-0.8, N + 0.8)
ax_top.set_ylim(y_lo, y_hi)
ax_top.set_ylabel('Height $y$ in half-plane', fontsize=11)
ax_top.set_xlabel('Grid index $k$', fontsize=11)
ax_top.tick_params(labelsize=9)
ax_top.set_xticks(range(0, N + 1, 2))

# Legend
ax_top.plot([], [], 'o', color=C_HORO, markersize=5, label='binary height $b_k$')
ax_top.plot([], [], 's', color=C_GEO, markersize=4, label='geometric height $g_k$')
ax_top.plot([], [], '-', color=C_DISP, linewidth=2.5, label='$d_{\\mathrm{hyp}}(k)$')
ax_top.legend(fontsize=9, loc='upper left')

ax_top.set_title(
    u'Hyperbolic distance between binary and geometric grid points\n'
    u'along vertical geodesics in the Poincar\u00e9 half-plane',
    fontsize=13, fontweight='bold', pad=10)


# ══════════════════════════════════════════════════════════════════════════
# Bottom panel: d_hyp(m) curve
# ══════════════════════════════════════════════════════════════════════════

ms = np.linspace(0.001, 0.999, 300)
d_hyp_curve = np.array([abs(log((1.0 + m) / 2.0**m)) for m in ms])
eps_scaled = np.array([LN2 * (log2(1.0 + m) - m) for m in ms])

ax_bot.fill_between(ms, 0, d_hyp_curve, alpha=0.10, color=C_DISP)
ax_bot.plot(ms, d_hyp_curve, '-', color=C_DISP, linewidth=2.5,
            label='$d_{\\mathrm{hyp}}(m) = |\\log((1{+}m)\\,/\\, 2^m)|$')
ax_bot.plot(ms, eps_scaled, '--', color=C_EPS, linewidth=1.5, alpha=0.8,
            label='$(\\ln 2)\\;\\varepsilon(m)$')

# Discrete samples from top panel
for k in range(N + 1):
    m = k / N
    b = 1.0 + m
    g = 2.0 ** m
    d = abs(log(b / g))
    ax_bot.plot(m, d, 'o', color=C_DISP, markersize=4, zorder=5, alpha=0.7)

# Peak
d_peak = abs(log((1.0 + M_STAR) / 2.0**M_STAR))
ax_bot.plot(M_STAR, d_peak, 'o', color=C_DISP, markersize=7, zorder=6)
ax_bot.axvline(M_STAR, color=C_GRAY, linewidth=0.5, linestyle=':')
ax_bot.text(M_STAR + 0.03, d_peak * 0.95, '$m^*$', fontsize=11,
            color=C_GRAY, va='top')

# Scaling relation
ax_bot.text(0.65, d_peak * 0.75,
            '$d_{\\mathrm{hyp}}(m) = (\\ln 2)\\;\\varepsilon(m)$',
            fontsize=12, color='#333333',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                      edgecolor='#cccccc', alpha=0.9))

ax_bot.set_xlabel('Mantissa $m = k / 2^d$', fontsize=11)
ax_bot.set_ylabel('$d_{\\mathrm{hyp}}$', fontsize=12)
ax_bot.set_xlim(-0.02, 1.02)
ax_bot.set_ylim(-0.003, d_peak * 1.25)
ax_bot.legend(fontsize=10, loc='upper right')
ax_bot.grid(True, alpha=0.2, linewidth=0.4)
ax_bot.tick_params(labelsize=9)
ax_bot.axhline(0, color='#cccccc', linewidth=0.3)


# -- Save -----------------------------------------------------------------

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight', facecolor='white')
print("Saved: %s" % OUT_PATH)
print("Done.")
