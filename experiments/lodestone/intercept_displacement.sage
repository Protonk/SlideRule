"""
intercept_displacement.sage — How far does sharing push each cell from its optimum?

Plots (path_intercept - free_cell_intercept) vs cell position x_mid for a
single partition kind, comparing layer-invariant (broad swings) against
layer-dependent (tight oscillation).

Run:  ./sagew experiments/lodestone/intercept_displacement.sage
"""

import csv

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

RUN_TAG = 'partition_2026-03-18'
Q = 5
DEPTH = 6
ALPHA = '1/2'
KIND = 'geometric_x'
OUT_PATH = pathing('experiments', 'lodestone', 'results', 'intercept_displacement.png')


# ── Load ─────────────────────────────────────────────────────────────

def load_percell(run_tag):
    path = pathing('experiments', 'lodestone', 'results', run_tag, 'percell.csv')
    with open(path, 'r', newline='') as f:
        return list(csv.DictReader(f))


def extract_displacement(rows, kind, q, depth, alpha, layer_dependent):
    ld_str = str(layer_dependent)
    cells = [(float(r['x_mid']),
              float(r['path_intercept']) - float(r['free_cell_intercept']))
             for r in rows
             if r['partition_kind'] == kind
             and r['q'] == str(q) and r['depth'] == str(depth)
             and r['alpha'] == alpha
             and r['layer_dependent'] == ld_str
             and r['free_cell_intercept'] != '']
    cells.sort()
    return [c[0] for c in cells], [c[1] for c in cells]


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(rows):
    from math import log
    m_star = 1.0 / log(2.0)

    fig, (ax_li, ax_ld) = plt.subplots(
        2, 1, figsize=(11, 6), constrained_layout=True, sharex=True)

    for ax, ld, label, color in [
        (ax_li, False, 'Layer-invariant', '#e74c3c'),
        (ax_ld, True, 'Layer-dependent', '#3498db'),
    ]:
        xs, disps = extract_displacement(rows, KIND, Q, DEPTH, ALPHA, ld)
        if not xs:
            print("  WARNING: no data for LD=%s" % ld)
            continue

        ax.axhline(0.0, color='#999999', linewidth=0.6, linestyle='--', zorder=1)
        ax.axvline(m_star, color='#888888', linewidth=0.8, linestyle=':',
                   zorder=1)
        ax.fill_between(xs, 0, disps, color=color, alpha=0.3, zorder=2)
        ax.plot(xs, disps, color=color, linewidth=0.8, zorder=3)
        ax.scatter(xs, disps, color=color, s=6, zorder=4)

        ax.set_ylabel('shared $-$ free intercept', fontsize=9)
        ax.set_xlim(1.0, 2.0)
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=8)

        rng = max(abs(d) for d in disps)
        ax.set_ylim(-rng * 1.15, rng * 1.15)

        sign_changes = sum(1 for i in range(len(disps) - 1)
                          if disps[i] * disps[i + 1] < 0)
        ax.text(0.02, 0.92, f'{label}: range={2*rng:.4f}, sign changes={sign_changes}',
                transform=ax.transAxes, fontsize=8, fontweight='bold',
                va='top', color=color)

    ax_ld.set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=10)

    short = KIND.replace('_x', '')
    fig.suptitle(
        'Intercept displacement: how far does sharing push each cell?\n'
        '%s, $q = %d$, depth $= %d$, $\\alpha = %s$' % (short, Q, DEPTH, ALPHA),
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

rows = load_percell(RUN_TAG)
print("Loaded %d percell rows" % len(rows))
make_plot(rows)
print("Done.")
