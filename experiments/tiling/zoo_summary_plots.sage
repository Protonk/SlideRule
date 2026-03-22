"""
zoo_summary_plots.sage — Zoo-wide summary figures from zoo_sweep output.

Produces four panels:
1. Depth-7 ranking (corr_inf and nrmse_inf side by side)
2. Kind x depth heatmaps (corr_inf and nrmse_inf)
3. Coupling scatter (rho_peak vs corr_inf)
4. Scramble control panel (geometric vs peak_swap vs peak_avoid)

Run:  ./sagew experiments/tiling/zoo_summary_plots.sage
"""

import csv
import os
from collections import defaultdict

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Load data ────────────────────────────────────────────────────────

ZOO_DIR = pathing('experiments', 'tiling', 'results', 'zoo')
OUT_DIR = ZOO_DIR

metrics = []
with open(os.path.join(ZOO_DIR, 'zoo_case_metrics.csv'), 'r') as f:
    for r in csv.DictReader(f):
        r['depth'] = int(r['depth'])
        r['corr_inf'] = float(r['corr_inf'])
        r['nrmse_inf'] = float(r['nrmse_inf'])
        r['rho_peak'] = float(r['rho_peak']) if r['rho_peak'] != 'nan' else float('nan')
        r['residual_norm_inf'] = float(r['residual_norm_inf'])
        metrics.append(r)

meta = {}
with open(os.path.join(ZOO_DIR, 'zoo_metadata.csv'), 'r') as f:
    for r in csv.DictReader(f):
        meta[r['case_id']] = r

# Group colors by category
CAT_COLORS = {
    'elementary_geometric': '#1f77b4',
    'number_theory': '#bcbd22',
    'fractal': '#e377c2',
    'symbolic_dynamics': '#984ea3',
    'approximation_parametric': '#ff9896',
    'curve_aware': '#a65628',
    'null_model': '#aec7e8',
    'tiling_adversary': '#636363',
}


def case_color(case_id):
    m = meta.get(case_id, {})
    return CAT_COLORS.get(m.get('category', ''), '#999999')


def case_label(case_id):
    m = meta.get(case_id, {})
    return m.get('display_name', case_id)


# ── Panel 1: Depth-7 ranking ────────────────────────────────────────

d7 = [r for r in metrics if r['depth'] == 7]
d7_corr = sorted(d7, key=lambda r: r['corr_inf'], reverse=True)
d7_nrmse = sorted(d7, key=lambda r: r['nrmse_inf'])

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7), constrained_layout=True)

# corr_inf ranking
labels = [case_label(r['case_id']) for r in d7_corr]
vals = [r['corr_inf'] for r in d7_corr]
colors = [case_color(r['case_id']) for r in d7_corr]
y_pos = range(len(labels))
ax1.barh(y_pos, vals, color=colors, height=0.7, edgecolor='none')
ax1.set_yticks(y_pos)
ax1.set_yticklabels(labels, fontsize=7)
ax1.set_xlabel('corr_inf', fontsize=10)
ax1.set_title('Stage A correlation (depth 7)', fontsize=11, fontweight='bold')
ax1.invert_yaxis()
ax1.grid(True, alpha=0.2, axis='x')
ax1.set_xlim(0, 1)

# nrmse_inf ranking
labels2 = [case_label(r['case_id']) for r in d7_nrmse]
vals2 = [r['nrmse_inf'] for r in d7_nrmse]
colors2 = [case_color(r['case_id']) for r in d7_nrmse]
ax2.barh(range(len(labels2)), vals2, color=colors2, height=0.7, edgecolor='none')
ax2.set_yticks(range(len(labels2)))
ax2.set_yticklabels(labels2, fontsize=7)
ax2.set_xlabel('nrmse_inf', fontsize=10)
ax2.set_title('Stage A NRMSE (depth 7)', fontsize=11, fontweight='bold')
ax2.invert_yaxis()
ax2.grid(True, alpha=0.2, axis='x')

fig.savefig(os.path.join(OUT_DIR, 'zoo_ranking_d7.png'), dpi=180, bbox_inches='tight')
print("-> zoo_ranking_d7.png")


# ── Panel 2: Kind x depth heatmaps ──────────────────────────────────

case_ids = sorted(set(r['case_id'] for r in metrics),
                  key=lambda c: min(r['corr_inf'] for r in metrics
                                    if r['case_id'] == c and r['depth'] == 7),
                  reverse=True)
depths = sorted(set(r['depth'] for r in metrics))

by_key = {(r['case_id'], r['depth']): r for r in metrics}

corr_matrix = np.full((len(case_ids), len(depths)), np.nan)
nrmse_matrix = np.full((len(case_ids), len(depths)), np.nan)
for i, cid in enumerate(case_ids):
    for j, d in enumerate(depths):
        r = by_key.get((cid, d))
        if r:
            corr_matrix[i, j] = r['corr_inf']
            nrmse_matrix[i, j] = r['nrmse_inf']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 9), constrained_layout=True)

im1 = ax1.imshow(corr_matrix, aspect='auto', cmap='RdYlGn', vmin=0.2, vmax=1.0)
ax1.set_xticks(range(len(depths)))
ax1.set_xticklabels(depths, fontsize=8)
ax1.set_yticks(range(len(case_ids)))
ax1.set_yticklabels([case_label(c) for c in case_ids], fontsize=6)
ax1.set_xlabel('Depth', fontsize=9)
ax1.set_title('corr_inf', fontsize=11, fontweight='bold')
fig.colorbar(im1, ax=ax1, shrink=0.6)

im2 = ax2.imshow(nrmse_matrix, aspect='auto', cmap='RdYlGn_r', vmin=0.3, vmax=1.0)
ax2.set_xticks(range(len(depths)))
ax2.set_xticklabels(depths, fontsize=8)
ax2.set_yticks(range(len(case_ids)))
ax2.set_yticklabels([case_label(c) for c in case_ids], fontsize=6)
ax2.set_xlabel('Depth', fontsize=9)
ax2.set_title('nrmse_inf', fontsize=11, fontweight='bold')
fig.colorbar(im2, ax=ax2, shrink=0.6)

fig.suptitle('Zoo heatmaps: Stage A metrics across partitions and depths',
             fontsize=12, fontweight='bold')
fig.savefig(os.path.join(OUT_DIR, 'zoo_heatmaps.png'), dpi=180, bbox_inches='tight')
print("-> zoo_heatmaps.png")


# ── Panel 3: Coupling scatter ────────────────────────────────────────

d7_valid = [r for r in d7 if not np.isnan(r['rho_peak'])]

fig, ax = plt.subplots(figsize=(9, 6), constrained_layout=True)

for r in d7_valid:
    cid = r['case_id']
    m = meta.get(cid, {})
    cat = m.get('category', '')
    color = CAT_COLORS.get(cat, '#999')
    size = max(20, min(200, r['residual_norm_inf'] * 3000))
    ax.scatter(r['rho_peak'], r['corr_inf'], c=color, s=size,
               alpha=0.7, edgecolors='white', linewidths=0.5)
    ax.annotate(case_label(cid), (r['rho_peak'], r['corr_inf']),
                fontsize=5, ha='center', va='bottom',
                xytext=(0, 4), textcoords='offset points')

ax.set_xlabel('rho_peak (width-to-peak coupling)', fontsize=10)
ax.set_ylabel('corr_inf (Stage A correlation)', fontsize=10)
ax.set_title('Coupling scatter (depth 7)', fontsize=11, fontweight='bold')
ax.grid(True, alpha=0.2)
ax.axvline(0, color='#999', linewidth=0.5, linestyle=':')

# Legend for categories
from matplotlib.patches import Patch
legend_handles = [Patch(facecolor=CAT_COLORS[cat], label=cat.replace('_', ' '))
                  for cat in sorted(CAT_COLORS.keys())]
ax.legend(handles=legend_handles, fontsize=6, loc='lower left')

fig.savefig(os.path.join(OUT_DIR, 'zoo_coupling_scatter.png'), dpi=180, bbox_inches='tight')
print("-> zoo_coupling_scatter.png")


# ── Panel 4: Scramble control panel ──────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(14, 4.5), constrained_layout=True)

scr_cases = ['geometric_x', 'scramble_x__peak_swap', 'scramble_x__peak_avoid']
scr_labels = ['geometric', 'peak-swap', 'peak-avoid']
scr_colors = ['#9467bd', '#d4a017', '#20b2aa']

# Panel 4a: corr_inf across depths
ax = axes[0]
for cid, label, color in zip(scr_cases, scr_labels, scr_colors):
    ds = [r['depth'] for r in metrics if r['case_id'] == cid]
    cs = [r['corr_inf'] for r in metrics if r['case_id'] == cid]
    ax.plot(ds, cs, marker='o', markersize=5, linewidth=1.5,
            color=color, label=label)
ax.set_xlabel('Depth', fontsize=9)
ax.set_ylabel('corr_inf', fontsize=9)
ax.set_title('Stage A correlation', fontsize=10, fontweight='bold')
ax.legend(fontsize=7)
ax.grid(True, alpha=0.2)

# Panel 4b: rho_peak across depths
ax = axes[1]
for cid, label, color in zip(scr_cases, scr_labels, scr_colors):
    ds = [r['depth'] for r in metrics if r['case_id'] == cid]
    rhos = [r['rho_peak'] for r in metrics if r['case_id'] == cid]
    ax.plot(ds, rhos, marker='s', markersize=5, linewidth=1.5,
            color=color, label=label)
ax.set_xlabel('Depth', fontsize=9)
ax.set_ylabel('rho_peak', fontsize=9)
ax.set_title('Width-peak coupling', fontsize=10, fontweight='bold')
ax.legend(fontsize=7)
ax.grid(True, alpha=0.2)
ax.axhline(0, color='#999', linewidth=0.5, linestyle=':')

# Panel 4c: width profile at depth 7
ax = axes[2]
for cid, label, color, kwargs in [
    ('geometric_x', 'geometric', '#9467bd', {}),
    ('scramble_x__peak_swap', 'peak-swap', '#d4a017', {'scramble_mode': 'peak_swap'}),
    ('scramble_x__peak_avoid', 'peak-avoid', '#20b2aa', {'scramble_mode': 'peak_avoid'}),
]:
    kind = 'scramble_x' if 'scramble' in cid else cid
    p = build_partition(7, kind=kind, **kwargs)
    mids = [float((p[j]['x_lo'] + p[j]['x_hi']) / 2) - 1.0 for j in range(len(p))]
    widths = [float(p[j]['x_hi'] - p[j]['x_lo']) for j in range(len(p))]
    ax.plot(mids, widths, linewidth=0.8, color=color, label=label, alpha=0.8)

ax.axvline(1.0 / float(log(2.0)) - 1.0, color='red', linewidth=0.5,
           linestyle='--', label='m*')
ax.set_xlabel('Mantissa m', fontsize=9)
ax.set_ylabel('Cell width', fontsize=9)
ax.set_title('Width profile (depth 7)', fontsize=10, fontweight='bold')
ax.legend(fontsize=6)
ax.grid(True, alpha=0.2)

fig.suptitle('Scramble control panel', fontsize=12, fontweight='bold')
fig.savefig(os.path.join(OUT_DIR, 'zoo_scramble_control.png'), dpi=180, bbox_inches='tight')
print("-> zoo_scramble_control.png")

print()
print("All summary figures saved to %s" % OUT_DIR)
