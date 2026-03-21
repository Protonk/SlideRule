"""
balance_scatter.sage — Territory vs intensity scatter for balance ratio.

x-axis:  share_above  (fraction of domain that is net-exporting)
y-axis:  area_above / (area_above + area_below)  (intensity share)
size:    log2(crossings + 1)  (structural complexity)
color:   zoo palette

The diagonal y=x is where territory equals intensity.  Points above have
concentrated intense exporters on small territory; points below have
diffuse exporters spread across large territory.

Run:  ./sagew experiments/wall/damage/balance_scatter.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import csv
from math import log2


# ── Load summary CSV ────────────────────────────────────────────────

CSV_PATH = 'experiments/wall/damage/results/balance_summary.csv'

zoo_colors = {kind: color for _name, color, kind in PARTITION_ZOO}
zoo_names = {kind: name for name, _color, kind in PARTITION_ZOO}

rows = []
with open(CSV_PATH) as f:
    for r in csv.DictReader(f):
        r['crossings'] = int(r['crossings'])
        r['area_above'] = float(r['area_above'])
        r['area_below'] = float(r['area_below'])
        r['share_above'] = float(r['share_above'])
        r['share_below'] = float(r['share_below'])
        rows.append(r)


# ── Derived quantities ──────────────────────────────────────────────

for r in rows:
    total_area = r['area_above'] + r['area_below']
    r['intensity_share'] = r['area_above'] / total_area if total_area > 0 else 0.5


# ── Plot ────────────────────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(10, 9))

# Diagonal: territory = intensity
ax.plot([0, 1], [0, 1], '--', color='#bbbbbb', linewidth=1.0, zorder=1)

# Reference lines at 0.5
ax.axhline(0.5, color='#dddddd', linewidth=0.5, zorder=1)
ax.axvline(0.5, color='#dddddd', linewidth=0.5, zorder=1)

# Scatter
for r in rows:
    kind = r['kind']
    x = r['share_above']
    y = r['intensity_share']
    c = zoo_colors.get(kind, '#999999')
    crossings = r['crossings']
    size = (log2(crossings + 1) + 1) ** 2 * 18

    ax.scatter(x, y, s=size, color=c, edgecolors='#333333',
               linewidths=0.5, alpha=0.85, zorder=3)

# Labels — offset to avoid overlap
nudges = {
    'uniform_x':           (-0.130, -0.010),
    'geometric_x':         (-0.130,  0.000),
    'harmonic_x':          (-0.120,  0.015),
    'mirror_harmonic_x':   (-0.140, -0.010),
    'ruler_x':             ( 0.020, -0.025),
    'sinusoidal_x':        ( 0.020,  0.018),
    'chebyshev_x':         (-0.120,  0.018),
    'thuemorse_x':         ( 0.025, -0.018),
    'bitrev_geometric_x':  (-0.140, -0.010),
    'stern_brocot_x':      ( 0.025,  0.015),
    'reverse_geometric_x': (-0.150,  0.010),
    'random_x':            ( 0.025,  0.015),
    'dyadic_x':            (-0.100, -0.020),
    'powerlaw_x':          (-0.120,  0.015),
    'golden_x':            (-0.100, -0.022),
    'cantor_x':            (-0.080, -0.025),
    'farey_rank_x':        ( 0.025, -0.022),
    'radical_inverse_x':   (-0.150, -0.015),
    'sturmian_x':          (-0.110, -0.020),
    'beta_x':              (-0.060,  0.022),
    'arc_length_x':        ( 0.025,  0.015),
    'minimax_chord_x':     (-0.150,  0.000),
}

for r in rows:
    kind = r['kind']
    x = r['share_above']
    y = r['intensity_share']
    c = zoo_colors.get(kind, '#999999')
    dx, dy = nudges.get(kind, (0.015, 0.0))
    ax.annotate(
        zoo_names.get(kind, kind),
        xy=(x, y), xytext=(x + dx, y + dy),
        fontsize=7.5, color='#333333',
        arrowprops=dict(arrowstyle='-', color='#aaaaaa', linewidth=0.4)
            if (abs(dx) > 0.05 or abs(dy) > 0.05) else None,
        ha='left' if dx >= 0 else 'right',
        va='center',
        zorder=4,
    )

# Quadrant annotations
ax.text(0.22, 0.88, 'intense exporters\nsmall territory',
        fontsize=8, color='#999999', ha='center', va='center',
        style='italic')
ax.text(0.82, 0.88, 'intense exporters\nlarge territory',
        fontsize=8, color='#999999', ha='center', va='center',
        style='italic')
ax.text(0.22, 0.15, 'intense importers\nsmall exporter territory',
        fontsize=8, color='#999999', ha='center', va='center',
        style='italic')
ax.text(0.82, 0.15, 'intense importers\nlarge exporter territory',
        fontsize=8, color='#999999', ha='center', va='center',
        style='italic')

ax.set_xlabel('Share above 0.5  (fraction of domain that is net-exporting)',
              fontsize=11)
ax.set_ylabel('Intensity share  (fraction of total imbalance carried by exporters)',
              fontsize=11)
ax.set_xlim(0.15, 0.90)
ax.set_ylim(0.10, 0.95)
ax.set_aspect('equal')
ax.tick_params(labelsize=9)

fig.suptitle('Territory vs intensity of damage balance',
             fontsize=14, fontweight='bold')
fig.text(0.5, 0.94,
         'marker size $\\propto$ $\\log_2$(crossings + 1)  |  '
         'diagonal = territory equals intensity',
         ha='center', fontsize=9, color='#666666')

fig.tight_layout(rect=[0, 0, 1, 0.935])

out_path = 'experiments/wall/damage/results/balance_scatter.png'
fig.savefig(out_path, dpi=200)
print("Saved: %s" % out_path)
print("Done.")
