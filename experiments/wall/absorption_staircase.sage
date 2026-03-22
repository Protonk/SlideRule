"""
absorption_staircase.sage — G6+G7: Absorption staircase and binding-cell
migration.

DISTANT-SHORES Step 5 predicts a staircase: as parameter budget q grows,
the wall drops in discrete steps. The binding (worst) cell migrates from
domain boundaries toward the epsilon peak at m* as q increases.

This script sweeps q at fixed depth for geometric and uniform (LI and LD),
plots the (q, gap) staircase and the binding-cell migration overlaid on
epsilon(m).

Expected runtime: ~5-15 minutes (multiple optimize_minimax calls).
Uses h1a_gap_vs_q.csv for uniform LI if available, recomputes otherwise.

Run:  ./sagew experiments/wall/absorption_staircase.sage
"""

import csv
import os
import time

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# -- Configuration --------------------------------------------------------

DEPTH = 6
P_NUM = 1
Q_DEN = 2
Q_VALUES = [1, 3, 5, 7, 9, 11]

CASES = [
    ('geometric_x', False, '#9467bd', 'o',  'geometric LI'),
    ('geometric_x', True,  '#9467bd', 's',  'geometric LD'),
    ('uniform_x',   False, '#1f77b4', 'o',  'uniform LI'),
    ('uniform_x',   True,  '#1f77b4', 's',  'uniform LD'),
]

OUT_DIR = pathing('experiments', 'wall', 'results')
OUT_STAIRCASE = os.path.join(OUT_DIR, 'absorption_staircase.png')
OUT_MIGRATION = os.path.join(OUT_DIR, 'binding_cell_migration.png')

LN2 = float(log(2.0))
M_STAR = 1.0 / LN2 - 1.0


# -- Sweep -----------------------------------------------------------------

def run_sweep():
    """Run q-sweep and collect results."""
    results = []

    for kind, ld, color, marker, label in CASES:
        print("  Sweep: %s (LD=%s)" % (kind, ld))
        for q in Q_VALUES:
            t0 = time.time()
            case = compute_case(q, DEPTH, P_NUM, Q_DEN,
                                partition_kind=kind, layer_dependent=ld)
            elapsed = time.time() - t0

            # Extract per-cell errors for binding-cell analysis
            opt_pol = case['opt_pol']
            cell_data = opt_pol['metrics']['cell_data']
            cell_errors = []
            for entry in cell_data:
                bits = entry[0]
                prow = case['row_map'][bits]
                x_mid = float((prow['x_lo'] + prow['x_hi']) / 2)
                m_mid = x_mid - 1.0
                cell_worst = entry[3]
                cell_errors.append((m_mid, cell_worst))
            cell_errors.sort()

            # Find worst cell
            worst_idx = max(range(len(cell_errors)),
                            key=lambda i: cell_errors[i][1])
            worst_m = cell_errors[worst_idx][0]

            results.append({
                'kind': kind, 'ld': ld, 'q': q,
                'color': color, 'marker': marker, 'label': label,
                'opt_err': case['opt_err'],
                'free_err': case['free_err'],
                'gap': case['gap'],
                'worst_m': worst_m,
                'cell_errors': cell_errors,
            })
            print("    q=%2d: gap=%.6f worst_m=%.4f (%.1fs)"
                  % (q, case['gap'], worst_m, elapsed))

    return results


# -- Plot G6: Staircase ---------------------------------------------------

def plot_staircase(results):
    fig, (ax_top, ax_bot) = plt.subplots(
        2, 1, figsize=(10, 8), constrained_layout=True, sharex=True)

    seen_labels = set()
    for kind, ld, color, marker, label in CASES:
        subset = [r for r in results
                  if r['kind'] == kind and r['ld'] == ld]
        subset.sort(key=lambda r: r['q'])
        qs = [r['q'] for r in subset]
        gaps = [r['gap'] for r in subset]
        worst_ms = [r['worst_m'] for r in subset]

        ls = '-' if not ld else '--'
        lbl = label if label not in seen_labels else None
        seen_labels.add(label)

        ax_top.plot(qs, gaps, marker + ls, color=color, markersize=6,
                    linewidth=1.5, label=lbl)
        ax_bot.plot(qs, worst_ms, marker + ls, color=color, markersize=6,
                    linewidth=1.5, label=lbl)

    ax_top.set_ylabel('Gap (opt_err $-$ free_err)', fontsize=10)
    ax_top.set_title('Absorption staircase: wall vs parameter budget',
                     fontsize=11, fontweight='bold')
    ax_top.grid(True, alpha=0.3, linewidth=0.5)
    ax_top.legend(fontsize=8)
    ax_top.tick_params(labelsize=8)

    # Bottom: worst-cell position with epsilon background
    ms_bg = np.linspace(0, 1, 200)
    eps_bg = np.array([eps_val(m) for m in ms_bg])
    eps_max = eps_bg.max()

    ax_bot_twin = ax_bot.twinx()
    ax_bot_twin.fill_between([], [], [], alpha=0.1, color='#9467bd')
    # We can't put eps on the q-axis directly; instead annotate with
    # horizontal reference lines at key m values.
    ax_bot.axhline(M_STAR, color='#888888', linewidth=0.7, linestyle=':')
    ax_bot.text(Q_VALUES[-1] + 0.3, M_STAR, '$m^*$', fontsize=8,
                color='#888888', va='center')
    ax_bot.axhline(0, color='#cccccc', linewidth=0.3)
    ax_bot.axhline(1, color='#cccccc', linewidth=0.3)

    ax_bot.set_xlabel('Parameter budget $q$ (FSM states)', fontsize=10)
    ax_bot.set_ylabel('Worst-cell mantissa $m$', fontsize=10)
    ax_bot.set_ylim(-0.05, 1.05)
    ax_bot.set_title('Binding cell migration: should approach $m^*$ as $q$ grows',
                     fontsize=11, fontweight='bold')
    ax_bot.grid(True, alpha=0.3, linewidth=0.5)
    ax_bot.legend(fontsize=8)
    ax_bot.tick_params(labelsize=8)
    ax_bot_twin.set_yticks([])

    fig.suptitle(
        'DISTANT-SHORES Step 5: absorption rate at depth=%d, exponent=%d/%d'
        % (DEPTH, P_NUM, Q_DEN),
        fontsize=13, fontweight='bold', y=1.01,
    )

    os.makedirs(OUT_DIR, exist_ok=True)
    fig.savefig(OUT_STAIRCASE, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_STAIRCASE)


# -- Plot G7: Binding cell migration profiles ------------------------------

def plot_migration(results):
    """Multi-panel: per-cell error at each q, showing worst cell migrating."""

    # Use geometric LI as the primary case
    geo_li = [r for r in results
              if r['kind'] == 'geometric_x' and not r['ld']]
    geo_li.sort(key=lambda r: r['q'])

    n_panels = len(geo_li)
    if n_panels == 0:
        print("  No geometric LI results for migration plot")
        return

    fig, axes = plt.subplots(1, n_panels, figsize=(3 * n_panels, 4),
                             constrained_layout=True, sharey=True)
    if n_panels == 1:
        axes = [axes]

    # Epsilon background
    ms_bg = np.linspace(0, 1, 200)
    eps_bg = np.array([eps_val(m) for m in ms_bg])
    eps_scale = None

    for i, r in enumerate(geo_li):
        ax = axes[i]
        cell_ms = [c[0] for c in r['cell_errors']]
        cell_es = [c[1] for c in r['cell_errors']]

        if eps_scale is None:
            eps_scale = max(cell_es) / eps_bg.max() if eps_bg.max() > 0 else 1.0

        ax.fill_between(ms_bg, 0, eps_bg * eps_scale, alpha=0.08,
                        color='#9467bd')
        ax.plot(cell_ms, cell_es, '-', color='#1f77b4', linewidth=1.0,
                alpha=0.7)

        # Mark worst cell
        worst_idx = max(range(len(cell_es)), key=lambda j: cell_es[j])
        ax.plot(cell_ms[worst_idx], cell_es[worst_idx], 'v', color='#d62728',
                markersize=8, zorder=5)

        ax.axvline(M_STAR, color='#888888', linewidth=0.5, linestyle=':')
        ax.set_xlabel('$m$', fontsize=8)
        ax.set_title('q=%d' % r['q'], fontsize=9, fontweight='bold')
        ax.tick_params(labelsize=7)
        ax.grid(True, alpha=0.2, linewidth=0.4)

    axes[0].set_ylabel('Per-cell worst error', fontsize=9)

    fig.suptitle(
        'Binding-cell migration: geometric LI, d=%d\n'
        'Red marker = worst cell; gray fill = $\\varepsilon(m)$ (scaled)'
        % DEPTH,
        fontsize=11, fontweight='bold',
    )

    fig.savefig(OUT_MIGRATION, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_MIGRATION)


# -- Main ------------------------------------------------------------------

print()
print("Absorption staircase + binding-cell migration")
print("  depth=%d, q values=%s" % (DEPTH, Q_VALUES))
print()

results = run_sweep()
plot_staircase(results)
plot_migration(results)
print("Done.")
