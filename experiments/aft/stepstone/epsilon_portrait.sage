"""
epsilon_portrait.sage — G1: Standalone portrait of the pseudo-log error.

The pseudo-log error eps(m) = log2(1+m) - m is the central forcing
function of the entire project. This script renders its shape, first
derivative (showing the sign change at m*), and second derivative
(uniform concavity), with key features annotated.

Run:  ./sagew experiments/aft/stepstone/epsilon_portrait.sage
"""

import os
from math import log, log2

from helpers import pathing
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# -- Configuration --------------------------------------------------------

OUT_PATH = pathing('experiments', 'aft', 'stepstone', 'results',
                    'epsilon_portrait.png')

N_PTS = 500
LN2 = log(2.0)
M_STAR = 1.0 / LN2 - 1.0   # ~ 0.4427


# -- Compute --------------------------------------------------------------

ms = np.linspace(1e-6, 1.0 - 1e-6, N_PTS)

eps_curve    = np.array([eps_val(m) for m in ms])
eps_p_curve  = np.array([eps_prime(m) for m in ms])
eps_pp_curve = np.array([eps_pp(m) for m in ms])

eps_peak = eps_val(M_STAR)


# -- Plot ------------------------------------------------------------------

fig, axes = plt.subplots(3, 1, figsize=(9, 10), constrained_layout=True,
                         sharex=True)

# Panel 1: epsilon(m)
ax = axes[0]
ax.fill_between(ms, 0, eps_curve, alpha=0.15, color='#9467bd')
ax.plot(ms, eps_curve, color='#9467bd', linewidth=2.0)
ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':', zorder=1)
ax.plot(M_STAR, eps_peak, 'o', color='#9467bd', markersize=6, zorder=5)
ax.annotate(
    '$m^* = 1/\\ln 2 - 1 \\approx %.4f$\n$\\varepsilon(m^*) \\approx %.6f$'
    % (M_STAR, eps_peak),
    xy=(M_STAR, eps_peak), xytext=(M_STAR + 0.15, eps_peak - 0.005),
    fontsize=8, arrowprops=dict(arrowstyle='->', color='#666666'),
    color='#666666',
)
ax.set_ylabel('$\\varepsilon(m) = \\log_2(1{+}m) - m$', fontsize=10)
ax.set_title('Pseudo-log error: shape and key features', fontsize=11,
             fontweight='bold')
ax.grid(True, alpha=0.3, linewidth=0.5)
ax.tick_params(labelsize=8)
# Mark zero endpoints
ax.plot([0, 1], [0, 0], 'x', color='#888888', markersize=5, zorder=4)
ax.text(0.02, -0.003, '$\\varepsilon(0)=0$', fontsize=7, color='#888888')
ax.text(0.92, -0.003, '$\\varepsilon(1)=0$', fontsize=7, color='#888888')

# Panel 2: epsilon'(m)
ax = axes[1]
ax.plot(ms, eps_p_curve, color='#2ca02c', linewidth=2.0)
ax.axhline(0, color='#cccccc', linewidth=0.5, zorder=0)
ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':', zorder=1)
ax.plot(M_STAR, 0, 'o', color='#2ca02c', markersize=6, zorder=5)
ax.fill_between(ms, 0, eps_p_curve, where=eps_p_curve > 0,
                alpha=0.12, color='#2ca02c')
ax.fill_between(ms, 0, eps_p_curve, where=eps_p_curve < 0,
                alpha=0.12, color='#d62728')
ax.annotate('$\\varepsilon\'(m^*)=0$', xy=(M_STAR, 0),
            xytext=(M_STAR + 0.12, 0.15), fontsize=8,
            arrowprops=dict(arrowstyle='->', color='#666666'),
            color='#666666')
ax.set_ylabel("$\\varepsilon'(m) = \\frac{1}{(1{+}m)\\ln 2} - 1$",
              fontsize=10)
ax.grid(True, alpha=0.3, linewidth=0.5)
ax.tick_params(labelsize=8)

# Panel 3: epsilon''(m)
ax = axes[2]
ax.plot(ms, eps_pp_curve, color='#d62728', linewidth=2.0)
ax.fill_between(ms, 0, eps_pp_curve, alpha=0.12, color='#d62728')
ax.axvline(M_STAR, color='#888888', linewidth=0.7, linestyle=':', zorder=1)
ax.axhline(0, color='#cccccc', linewidth=0.5, zorder=0)
ax.set_ylabel("$\\varepsilon''(m) = \\frac{-1}{(1{+}m)^2 \\ln 2}$",
              fontsize=10)
ax.set_xlabel('Mantissa $m$ in $[0,\\, 1)$', fontsize=10)
ax.grid(True, alpha=0.3, linewidth=0.5)
ax.tick_params(labelsize=8)
ax.text(0.5, ax.get_ylim()[0] * 0.35,
        'Uniformly concave: all curvature\npoints the same way',
        fontsize=8, color='#888888', ha='center')

fig.suptitle(
    '$\\varepsilon(m) = \\log_2(1{+}m) - m$: the forcing function',
    fontsize=13, fontweight='bold', y=1.01,
)

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
print("Saved: %s" % OUT_PATH)
print("  eps peak at m*=%.6f: eps=%.8f" % (M_STAR, eps_peak))
print("Done.")
