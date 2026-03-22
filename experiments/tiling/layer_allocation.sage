"""
layer_allocation.sage — G8: Per-layer contribution heatmap.

Shows which cells each layer's delta corrects. The displacement field
theory (T2) predicts layer 0 is the coarse absorber and layers 1+
perform repair. This script makes the per-cell per-layer structure visible.

Runs compute_case() once for LD at one benchmark point.
Expected runtime: ~15-30 seconds.

Run:  ./sagew experiments/tiling/layer_allocation.sage
"""

import os

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# -- Configuration --------------------------------------------------------

Q = 5
DEPTH = 6
P_NUM = 1
Q_DEN = 2
KIND = 'geometric_x'

OUT_PATH = pathing('experiments', 'tiling', 'results', 'layer_allocation.png')

LN2 = float(log(2.0))
M_STAR = 1.0 / LN2 - 1.0


# -- Compute ---------------------------------------------------------------

def compute_layer_contributions(case):
    """For each cell, compute the delta contribution at each layer."""
    opt_pol = case['opt_pol']
    c0 = opt_pol['c0_rat']
    delta = opt_pol['delta_rat']
    q = case['q']
    depth = case['depth']
    paths = case['paths']
    row_map = case['row_map']
    partition = case['partition']

    N = 2 ** depth

    # Per-cell per-layer delta contribution
    contributions = np.zeros((depth, N))
    cell_mids = np.zeros(N)
    free_intercepts = np.zeros(N)

    # Get free intercepts
    for fr in case['free_metrics']['rows']:
        idx = fr['index'] if 'index' in fr else bits_to_index(fr['bits'])
        free_intercepts[idx] = float(fr['c_opt'])

    for p in paths:
        bits = p['bits']
        idx = bits_to_index(bits)
        prow = row_map[bits]
        cell_mids[idx] = float((prow['x_lo'] + prow['x_hi']) / 2) - 1.0

        r = 0
        for t in range(depth):
            b = bits[t]
            # Try LD key, then LI key
            ld_key = (t, r, b)
            li_key = (r, b)
            if ld_key in delta:
                contributions[t, idx] = float(delta[ld_key])
            elif li_key in delta:
                contributions[t, idx] = float(delta[li_key])
            r = (2 * r + b) % q

    return contributions, cell_mids, free_intercepts


# -- Plot ------------------------------------------------------------------

def make_plot():
    print("  Computing LD case: %s q=%d d=%d..." % (KIND, Q, DEPTH))
    case = compute_case(Q, DEPTH, P_NUM, Q_DEN, partition_kind=KIND,
                        layer_dependent=True)
    print("    opt_err=%.6f  gap=%.6f  (%.1fs)"
          % (case['opt_err'], case['gap'], case['elapsed']))

    contribs, cell_mids, free_c = compute_layer_contributions(case)
    N = 2 ** DEPTH

    # Sort by cell midpoint
    sort_idx = np.argsort(cell_mids)
    contribs_sorted = contribs[:, sort_idx]
    mids_sorted = cell_mids[sort_idx]
    free_sorted = free_c[sort_idx]

    vmax = np.abs(contribs_sorted).max() * 1.05
    vmin = -vmax

    fig = plt.figure(figsize=(14, 7), constrained_layout=True)
    gs = fig.add_gridspec(3, 2, width_ratios=[20, 1], height_ratios=[1, 4, 1])

    # Main heatmap
    ax_heat = fig.add_subplot(gs[1, 0])
    im = ax_heat.imshow(contribs_sorted, cmap='RdBu_r', vmin=vmin, vmax=vmax,
                        aspect='auto', interpolation='nearest')
    ax_heat.set_ylabel('Layer $t$', fontsize=10)
    ax_heat.set_yticks(range(DEPTH))
    ax_heat.set_yticklabels(['layer %d' % t for t in range(DEPTH)], fontsize=8)
    ax_heat.set_xticks([])

    # Top strip: free intercept profile
    ax_free = fig.add_subplot(gs[0, 0], sharex=ax_heat)
    ax_free.plot(range(N), free_sorted, '-', color='#2ca02c', linewidth=1.0)
    ax_free.fill_between(range(N), free_sorted, alpha=0.2, color='#2ca02c')
    ax_free.set_ylabel('$c^*$', fontsize=8)
    ax_free.tick_params(labelsize=6, labelbottom=False)
    ax_free.grid(True, alpha=0.2, linewidth=0.3)

    # Bottom strip: total displacement and epsilon overlay
    ax_total = fig.add_subplot(gs[2, 0], sharex=ax_heat)
    total_displacement = contribs_sorted.sum(axis=0)
    ax_total.bar(range(N), total_displacement, width=1.0, color='#1f77b4',
                 alpha=0.6, edgecolor='none')

    # Epsilon overlay
    eps_vals = np.array([eps_val(m) for m in mids_sorted])
    eps_scale = np.abs(total_displacement).max() / eps_vals.max() if eps_vals.max() > 0 else 1
    ax_total.plot(range(N), -eps_vals * eps_scale, ':', color='#9467bd',
                  linewidth=1.0, alpha=0.6, label='$-\\varepsilon$ (scaled)')

    ax_total.set_xlabel('Cell index (sorted by mantissa midpoint)', fontsize=9)
    ax_total.set_ylabel('$\\sum_t \\delta_t$', fontsize=8)
    ax_total.tick_params(labelsize=6)
    ax_total.grid(True, alpha=0.2, linewidth=0.3)
    ax_total.legend(fontsize=6)

    # Side panel: L-inf norm per layer
    ax_side = fig.add_subplot(gs[1, 1])
    layer_norms = np.max(np.abs(contribs_sorted), axis=1)
    ax_side.barh(range(DEPTH), layer_norms, color='#e67e22', alpha=0.7)
    ax_side.set_yticks(range(DEPTH))
    ax_side.set_yticklabels([])
    ax_side.set_xlabel('$L^\\infty$', fontsize=7)
    ax_side.tick_params(labelsize=6)
    ax_side.invert_yaxis()
    ax_side.grid(True, alpha=0.2, linewidth=0.3)

    # Colorbar
    ax_cbar = fig.add_subplot(gs[0, 1])
    cbar = fig.colorbar(im, cax=ax_cbar)
    cbar.set_label('$\\delta_t$ contribution', fontsize=8)

    fig.suptitle(
        'Layer allocation: per-cell per-layer delta contributions\n'
        '%s LD, q=%d, d=%d, exponent=%d/%d'
        % (KIND.replace('_x', ''), Q, DEPTH, P_NUM, Q_DEN),
        fontsize=12, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)

    # Diagnostics
    layer_norms = np.max(np.abs(contribs_sorted), axis=1)
    print("  Layer L-inf norms:")
    for t in range(DEPTH):
        print("    layer %d: %.6f" % (t, layer_norms[t]))
    print("  Layer 0 share of total L-inf: %.1f%%"
          % (layer_norms[0] / layer_norms.sum() * 100))


# -- Main ------------------------------------------------------------------

print()
print("Layer allocation heatmap: %s LD q=%d d=%d" % (KIND, Q, DEPTH))
make_plot()
print("Done.")
