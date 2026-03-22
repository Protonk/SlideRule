"""
t3_summary_plot.sage — T3 summary figure: transported R0(c*) for all
partitions overlaid with the ε template.

Shows that the representation displacement field organises c* across
baselines, adversaries, and width-scrambles.

Run:  ./sagew experiments/tiling/t3_summary_plot.sage
"""

import os
from math import log, log2

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

P_NUM, Q_DEN = 1, 2
DEPTHS = [6, 8]
GRID_N = 300

OUT_DIR = pathing('experiments', 'tiling', 'results')

PARTITIONS = [
    # (label, kind, kwargs, group, style)
    ('uniform',          'uniform_x',          {},                            'baseline', '-'),
    ('geometric',        'geometric_x',        {},                            'baseline', '-'),
    ('harmonic',         'harmonic_x',         {},                            'baseline', '-'),
    ('mirror-harmonic',  'mirror_harmonic_x',  {},                            'baseline', '-'),
    ('half-geometric',   'half_geometric_x',   {},                            'adversary', '--'),
    ('eps-density',      'eps_density_x',      {},                            'adversary', '--'),
    ('midpoint-dense',   'midpoint_dense_x',   {},                            'adversary', '--'),
    ('peak-swap',        'scramble_x',         {'scramble_mode': 'peak_swap'},  'scramble', ':'),
    ('peak-avoid',       'scramble_x',         {'scramble_mode': 'peak_avoid'}, 'scramble', ':'),
]

COLORS = {
    'uniform':         '#1f77b4',
    'geometric':       '#9467bd',
    'harmonic':        '#2ca02c',
    'mirror-harmonic': '#d62728',
    'half-geometric':  '#636363',
    'eps-density':     '#252525',
    'midpoint-dense':  '#969696',
    'peak-swap':       '#e67e22',
    'peak-avoid':      '#17becf',
}


# ── Compute ──────────────────────────────────────────────────────────

def compute_transported_residual(kind, depth, grid, **kwargs):
    """Compute R0(c*) and transport to common grid."""
    partition = build_partition(depth, kind=kind, **kwargs)

    # Free intercepts — use optimal_cell_intercept_arb directly
    # to handle scramble_x which free_per_cell_metrics can't
    c_star = []
    for row in partition:
        plog_lo = QQ(row['plog_lo'])
        plog_hi = QQ(row['plog_hi'])
        c_opt, _ = optimal_cell_intercept_arb(plog_lo, plog_hi, P_NUM, Q_DEN)
        c_star.append(float(c_opt))
    c_star = np.array(c_star)

    left = leading_bit_halves(partition)
    g = R0(c_star, left, 'inf')

    m_mids = np.array([float((row['x_lo'] + row['x_hi']) / 2) - 1.0
                        for row in partition])

    # Transport to common grid
    g_transported = np.interp(grid, m_mids, g)
    return g_transported


def eps_template(grid):
    """Compute R0(Δ^L) on the common grid, then scale by best fit."""
    dL = np.array([delta_L(m) for m in grid])
    # Leading-bit projection on the grid
    left = grid < 0.5
    result = np.copy(dL)
    for mask in [left, ~left]:
        c = (np.max(dL[mask]) + np.min(dL[mask])) / 2.0
        result[mask] = dL[mask] - c
    return result


# ── Plot ─────────────────────────────────────────────────────────────

grid = np.linspace(0.002, 0.998, GRID_N)
template = eps_template(grid)

fig, axes = plt.subplots(1, len(DEPTHS), figsize=(7 * len(DEPTHS), 5.5),
                         constrained_layout=True)

for di, depth in enumerate(DEPTHS):
    ax = axes[di]

    # Collect all transported residuals for scale fitting
    all_transported = []

    for label, kind, kwargs, group, ls in PARTITIONS:
        g_t = compute_transported_residual(kind, depth, grid, **kwargs)
        all_transported.append(g_t)

        lw = 1.6 if group == 'baseline' else 1.2
        alpha = 0.85 if group == 'baseline' else 0.7

        ax.plot(grid, g_t, color=COLORS[label], linewidth=lw,
                linestyle=ls, label=label, alpha=alpha)

    # Scale template to best fit the mean of all transported residuals
    mean_transported = np.mean(all_transported, axis=0)
    alpha_fit = scale_fit(mean_transported, template)
    scaled_template = alpha_fit * template

    ax.plot(grid, scaled_template, color='black', linewidth=2.5,
            linestyle='-', label='ε template', alpha=0.9, zorder=0)

    ax.axhline(0, color='#999', linewidth=0.3)
    ax.axvline(0.5, color='#999', linewidth=0.3, linestyle=':')

    ax.set_xlabel('Mantissa $m$', fontsize=11)
    ax.set_ylabel('$R_0(c^*)$ transported', fontsize=11)
    ax.set_title('Depth %d  ($N = %d$ cells)' % (depth, 2**depth),
                 fontsize=12, fontweight='bold')
    ax.tick_params(labelsize=9)
    ax.grid(True, alpha=0.15, linewidth=0.3)

    # Legend with group headers
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles, labels, fontsize=7, ncol=2, loc='lower right',
              framealpha=0.9)

fig.suptitle(
    'T3: the representation displacement field organises $c^*$\n'
    'across baselines (solid), adversaries (dashed), and scrambles (dotted)',
    fontsize=13, fontweight='bold')

out_path = os.path.join(OUT_DIR, 't3_summary.png')
fig.savefig(out_path, dpi=200, bbox_inches='tight')
print("Saved: %s" % out_path)
