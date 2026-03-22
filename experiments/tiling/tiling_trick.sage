"""
tiling_trick.sage — LEGACY COMPOSITE, partially overlaps elementals/poincare/.

Four-panel overview of the tiling trick's logical chain:
  1. Two grids on [1, 2)         → superseded by E1a + E1b
  2. Displacement IS epsilon     → superseded by E2
  3. Triangle inequality         → not yet in elementals (future candidate)
  4. R0 tracks the forcing       → mixes didactic and data-adjacent content

Panels 1-2 are now covered by canonical elemental figures. Panels 3-4
may migrate later or may stay here as a composite overview. Kept for
reference during tiling/ cleanup.

Run:  ./sagew experiments/tiling/tiling_trick.sage
"""

import os
from math import log, log2, exp

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# -- Configuration --------------------------------------------------------

OUT_PATH = pathing('experiments', 'tiling', 'results', 'tiling_trick.png')

LN2 = log(2.0)
M_STAR_M = 1.0 / LN2 - 1.0   # mantissa ~ 0.4427
M_STAR_X = 1.0 + M_STAR_M     # x-coordinate ~ 1.4427

DEPTH = 4
N = 2 ** DEPTH


# -- Mathematical objects --------------------------------------------------

def eps(m):
    if m <= 0 or m >= 1:
        return 0.0
    return log2(1.0 + m) - m

def delta_L(m):
    return m - log2(1.0 + m)

# Grid points
binary_pts  = [1.0 + k / N for k in range(N + 1)]       # uniform on [1,2]
geo_pts     = [2.0 ** (k / N) for k in range(N + 1)]     # geometric on [1,2]

# Continuous curves
ms = np.linspace(0.001, 0.999, 400)
eps_curve = np.array([eps(m) for m in ms])
xs_cont = 1.0 + ms


# -- Colors ----------------------------------------------------------------

C_BIN  = '#1f77b4'   # binary / uniform
C_GEO  = '#9467bd'   # geometric
C_EPS  = '#2ca02c'   # epsilon
C_DISP = '#d62728'   # displacement arrows
C_GRAY = '#999999'
C_FREE = '#e67e22'   # free cost
C_CORR = '#1f77b4'   # correction cost


# -- Figure ----------------------------------------------------------------

fig = plt.figure(figsize=(14, 16))
gs = fig.add_gridspec(4, 1, hspace=0.32,
                      left=0.08, right=0.92, top=0.95, bottom=0.04)


# ═══════════════════════════════════════════════════════════════════════════
# Panel 1: The two grids
# ═══════════════════════════════════════════════════════════════════════════

ax = fig.add_subplot(gs[0])

# Draw the interval [1, 2]
y_bin = 0.7
y_geo = 0.3
y_mid = 0.5

ax.plot([1, 2], [y_bin, y_bin], '-', color=C_BIN, linewidth=1.5, alpha=0.3)
ax.plot([1, 2], [y_geo, y_geo], '-', color=C_GEO, linewidth=1.5, alpha=0.3)

# Grid points as ticks
for k in range(N + 1):
    bx = binary_pts[k]
    gx = geo_pts[k]

    # Binary ticks (top)
    ax.plot([bx, bx], [y_bin - 0.04, y_bin + 0.04], '-', color=C_BIN,
            linewidth=1.5)
    # Geometric ticks (bottom)
    ax.plot([gx, gx], [y_geo - 0.04, y_geo + 0.04], '-', color=C_GEO,
            linewidth=1.5)

    # Displacement arrows (skip endpoints where they coincide)
    if 0 < k < N:
        disp = abs(bx - gx)
        alpha = 0.3 + 0.7 * (disp / max(abs(b - g)
                              for b, g in zip(binary_pts[1:-1], geo_pts[1:-1])))
        ax.annotate('', xy=(gx, y_geo + 0.06), xytext=(bx, y_bin - 0.06),
                    arrowprops=dict(arrowstyle='->', color=C_DISP,
                                   alpha=alpha, linewidth=0.8,
                                   connectionstyle='arc3,rad=0.1'))

# Labels
ax.text(0.98, y_bin + 0.08, 'binary (uniform)', color=C_BIN,
        fontsize=11, ha='left', va='bottom', transform=ax.get_yaxis_transform())
ax.text(0.98, y_geo - 0.08, 'geometric (equal log-width)', color=C_GEO,
        fontsize=11, ha='left', va='top', transform=ax.get_yaxis_transform())

# Mark m* displacement
k_star = int(round(M_STAR_M * N))
bx_star = binary_pts[k_star]
gx_star = geo_pts[k_star]
ax.annotate('max displacement\nnear $m^*$', xy=((bx_star + gx_star) / 2, y_mid),
            xytext=(1.75, y_mid + 0.12), fontsize=9, color=C_DISP, ha='center',
            arrowprops=dict(arrowstyle='->', color=C_DISP, linewidth=1.2))

# Boundary annotations
ax.text(1.0, y_bin + 0.10, '$1$', fontsize=10, ha='center', color=C_GRAY)
ax.text(2.0, y_bin + 0.10, '$2$', fontsize=10, ha='center', color=C_GRAY)
ax.text(1.5, y_bin + 0.16, 'agree at endpoints, diverge in the interior',
        fontsize=9, ha='center', color=C_GRAY, style='italic')

ax.set_xlim(0.95, 2.05)
ax.set_ylim(0.05, 0.95)
ax.axis('off')
ax.set_title('1.  Two grids on $[1,\\, 2)$: the binary representation '
             'vs the natural coordinate',
             fontsize=13, fontweight='bold', loc='left', pad=10)


# ═══════════════════════════════════════════════════════════════════════════
# Panel 2: The displacement IS epsilon
# ═══════════════════════════════════════════════════════════════════════════

ax = fig.add_subplot(gs[1])

# epsilon curve
ax.fill_between(ms, 0, eps_curve, alpha=0.12, color=C_EPS)
ax.plot(ms, eps_curve, '-', color=C_EPS, linewidth=2.5)

# Displacement samples from panel 1
for k in range(1, N):
    m = k / N
    d = eps(m)
    ax.plot(m, d, 'o', color=C_DISP, markersize=5, zorder=5, alpha=0.7)

# Peak
ax.plot(M_STAR_M, eps(M_STAR_M), 'o', color=C_EPS, markersize=8, zorder=6)
ax.annotate('$m^* = 1/\\ln 2 - 1$\n$\\varepsilon_{\\max} \\approx 0.086$',
            xy=(M_STAR_M, eps(M_STAR_M)),
            xytext=(M_STAR_M + 0.2, eps(M_STAR_M) + 0.01),
            fontsize=10, color=C_EPS,
            arrowprops=dict(arrowstyle='->', color=C_EPS, linewidth=1.2))

# Zero endpoints
ax.plot([0, 1], [0, 0], 'x', color=C_GRAY, markersize=7, zorder=4)

# The key equation
ax.text(0.70, 0.065,
        '$\\Delta^L(m) = m - \\log_2(1{+}m) = -\\varepsilon(m)$',
        fontsize=13, color='#333333',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='white',
                  edgecolor=C_EPS, alpha=0.9))

# Annotations
ax.text(0.03, 0.055, 'closed form\narchitecture-free\nbounded',
        fontsize=10, color=C_GRAY, va='top', style='italic')

ax.set_xlabel('Mantissa $m$', fontsize=11)
ax.set_ylabel('$\\varepsilon(m)$', fontsize=12)
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.008, 0.10)
ax.grid(True, alpha=0.2, linewidth=0.4)
ax.tick_params(labelsize=9)
ax.axhline(0, color='#cccccc', linewidth=0.4)
ax.set_title('2.  The displacement between the grids IS the pseudo-log error',
             fontsize=13, fontweight='bold', loc='left', pad=10)


# ═══════════════════════════════════════════════════════════════════════════
# Panel 3: The triangle decomposition
# ═══════════════════════════════════════════════════════════════════════════

ax = fig.add_subplot(gs[2])

# Continuous curves
log2_curve = np.array([log2(x) for x in xs_cont])      # truth
L_curve = ms.copy()                                      # pseudo-log L(x) = x-1 on [1,2]

# A simple piecewise-linear approximation for illustration
# Use 4 cells (depth 2) for clarity
n_approx = 4
approx_xs = [1.0 + i / n_approx for i in range(n_approx + 1)]
approx_ys = [log2(x) for x in approx_xs]
approx_curve = np.interp(xs_cont, approx_xs, approx_ys)

# Plot truth and surrogate
ax.plot(xs_cont, log2_curve, '-', color='#333333', linewidth=2.0,
        label='$\\log_2(x)$  (truth)')
ax.plot(xs_cont, L_curve, '--', color=C_GEO, linewidth=1.8, alpha=0.8,
        label='$L(x) = x - 1$  (pseudo-log surrogate)')
ax.plot(xs_cont, approx_curve, '-', color=C_BIN, linewidth=1.5, alpha=0.7,
        label='APPROX  (piecewise chord)')

# Fill the two components of the triangle inequality
# |APPROX - log2| <= |APPROX - L| + |L - log2|

# The free cost: |L - log2| = epsilon
ax.fill_between(xs_cont, log2_curve, L_curve, alpha=0.12, color=C_FREE,
                label='$|L - \\log_2| = \\varepsilon$  (free cost)')

# The correction cost: |APPROX - L|
ax.fill_between(xs_cont, approx_curve, L_curve, alpha=0.10, color=C_CORR,
                label='$|\\mathrm{APPROX} - L|$  (correction cost)')

# Triangle inequality text (no \underbrace — matplotlib mathtext doesn't support it)
ax.text(1.5, 0.55,
        '$|\\mathrm{APPROX} - \\log_2|'
        ' \\;\\leq\\; |\\mathrm{APPROX} - L|'
        ' \\;+\\; |L - \\log_2|$',
        fontsize=12, ha='center', color='#333333',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='white',
                  edgecolor='#cccccc', alpha=0.95))
ax.text(1.30, 0.44, 'computable', fontsize=9, ha='center',
        color=C_CORR, style='italic')
ax.text(1.72, 0.44, 'known $= \\varepsilon$', fontsize=9, ha='center',
        color=C_FREE, style='italic')

ax.set_xlabel('$x$ in $[1,\\, 2)$', fontsize=11)
ax.set_ylabel('value', fontsize=11)
ax.set_xlim(1.0, 2.0)
ax.set_ylim(-0.02, 1.05)
ax.legend(fontsize=8.5, loc='upper left')
ax.grid(True, alpha=0.2, linewidth=0.4)
ax.tick_params(labelsize=9)
ax.set_title('3.  The triangle inequality separates free cost from correction cost',
             fontsize=13, fontweight='bold', loc='left', pad=10)


# ═══════════════════════════════════════════════════════════════════════════
# Panel 4: R0 — what the corrector actually faces
# ═══════════════════════════════════════════════════════════════════════════

ax = fig.add_subplot(gs[3])

# Simulate a schematic c* field and its R0
# For geometric_x at depth 6, c* is nearly affine + epsilon curvature.
# Draw a schematic version: affine ramp + scaled epsilon perturbation.
ms_fine = np.linspace(0.001, 0.999, 200)
eps_fine = np.array([eps(m) for m in ms_fine])

# Schematic c*: affine ramp + perturbation from epsilon
c_star_schematic = -0.06 * ms_fine + 0.03 * eps_fine - 0.04

# Leading-bit projection (best 2-level fit)
left = ms_fine < 0.5
pi0 = np.empty_like(c_star_schematic)
for mask in [left, ~left]:
    vals = c_star_schematic[mask]
    pi0[mask] = (np.max(vals) + np.min(vals)) / 2.0

R0_cstar = c_star_schematic - pi0

# Scaled Delta^L residual
dL_fine = np.array([delta_L(m) for m in ms_fine])
dL_left = ms_fine < 0.5
pi0_dL = np.empty_like(dL_fine)
for mask in [dL_left, ~dL_left]:
    vals = dL_fine[mask]
    pi0_dL[mask] = (np.max(vals) + np.min(vals)) / 2.0
R0_dL = dL_fine - pi0_dL

# Scale R0(Delta^L) to match R0(c*)
dot_ab = np.dot(R0_cstar, R0_dL)
dot_bb = np.dot(R0_dL, R0_dL)
alpha = dot_ab / dot_bb if dot_bb > 0 else 1.0

ax.plot(ms_fine, R0_cstar, '-', color=C_BIN, linewidth=2.0,
        label='$R_0(c^*)$  (what layers 1+ must fix)')
ax.plot(ms_fine, R0_dL * alpha, '--', color=C_EPS, linewidth=1.8,
        alpha=0.8, label='$\\alpha\\, R_0(\\Delta^L)$  (forcing prediction)')

ax.fill_between(ms_fine, R0_cstar, R0_dL * alpha, alpha=0.10, color=C_DISP)

ax.axhline(0, color='#cccccc', linewidth=0.4)
ax.axvline(0.5, color=C_GRAY, linewidth=0.6, linestyle=':')
ax.text(0.505, ax.get_ylim()[0] * 0.1, 'leading-bit\nboundary', fontsize=8,
        color=C_GRAY, va='bottom')

ax.axvline(M_STAR_M, color=C_EPS, linewidth=0.6, linestyle=':')
ax.text(M_STAR_M + 0.02, ax.get_ylim()[0] * 0.1, '$m^*$', fontsize=9,
        color=C_EPS, va='bottom')

# Annotation: what this means
ax.text(0.75, R0_cstar.max() * 0.85,
        'The residual tracks the forcing.\n'
        'The corrector responds to the\n'
        'representation, not inventing\n'
        'an arbitrary distortion.',
        fontsize=10, color='#444444', va='top',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='white',
                  edgecolor='#cccccc', alpha=0.9))

ax.set_xlabel('Mantissa $m$', fontsize=11)
ax.set_ylabel('$R_0$', fontsize=11)
ax.set_xlim(-0.02, 1.02)
ax.legend(fontsize=9.5, loc='lower left')
ax.grid(True, alpha=0.2, linewidth=0.4)
ax.tick_params(labelsize=9)
ax.set_title('4.  After removing the leading-bit split, the residual '
             'tracks the displacement field',
             fontsize=13, fontweight='bold', loc='left', pad=10)


# -- Save -----------------------------------------------------------------

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight')
print("Saved: %s" % OUT_PATH)
print("Done.")
