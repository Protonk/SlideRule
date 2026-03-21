"""
balance_bars.sage — Diagonal residual bar chart for damage balance.

Partitions ranked by projection onto the y=x line in (share_above,
intensity_share) space.  Bar height is the signed perpendicular distance
from that line: positive = intense exporters on small territory,
negative = diffuse exporters on large territory.

Run:  ./sagew experiments/wall/damage/balance_bars.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import csv
from math import sqrt


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
        total_area = r['area_above'] + r['area_below']
        r['intensity_share'] = r['area_above'] / total_area if total_area > 0 else 0.5
        rows.append(r)

INV_SQRT2 = 1.0 / sqrt(2.0)

for r in rows:
    x = r['share_above']
    y = r['intensity_share']
    r['diag_proj'] = (x + y) * INV_SQRT2
    r['diag_resid'] = (y - x) * INV_SQRT2

rows.sort(key=lambda r: r['diag_proj'])


# ── Plot ────────────────────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(14, 5))

n = len(rows)
x_positions = np.arange(n)
bar_width = 0.7

for i, r in enumerate(rows):
    kind = r['kind']
    color = zoo_colors.get(kind, '#999999')
    ax.bar(i, r['diag_resid'], width=bar_width, color=color,
           edgecolor='#333333', linewidth=0.4, alpha=0.85)

ax.axhline(0, color='#333333', linewidth=0.6)

names = [zoo_names.get(r['kind'], r['kind']) for r in rows]
ax.set_xticks(x_positions)
ax.set_xticklabels(names, rotation=55, ha='right', fontsize=8)
ax.tick_params(axis='y', labelsize=9)

ax.set_ylabel('Perpendicular distance from $y = x$', fontsize=11)
ax.set_xlabel('Partitions ranked by diagonal projection  '
              '(quiet $\\rightarrow$ loud)', fontsize=11)

# Annotations for bar direction
y_lo, y_hi = ax.get_ylim()
ax.text(n - 0.5, y_hi * 0.85,
        'intense exporters\nsmall territory',
        fontsize=8, color='#999999', ha='right', va='top', style='italic')
ax.text(n - 0.5, y_lo * 0.85,
        'diffuse exporters\nlarge territory',
        fontsize=8, color='#999999', ha='right', va='bottom', style='italic')

fig.suptitle('Damage balance: diagonal residual',
             fontsize=14, fontweight='bold')
fig.text(0.5, 0.93,
         'bar height = signed distance from territory-equals-intensity line  |  '
         'sorted by overall magnitude',
         ha='center', fontsize=9, color='#666666')

fig.tight_layout(rect=[0, 0, 1, 0.92])

out_path = 'experiments/wall/damage/results/balance_bars.png'
fig.savefig(out_path, dpi=200)
print("Saved: %s" % out_path)
print("Done.")
