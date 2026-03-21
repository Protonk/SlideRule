"""
balance_bars_anti.sage — Anti-diagonal residual bar chart for damage balance.

Partitions ranked by projection onto the anti-diagonal (0,1)->(1,0) in
(share_above, intensity_share) space.  Bar length is the signed
perpendicular distance from that line: positive = loud damage economy
(both territory and intensity large), negative = quiet (both small).

Bars are horizontal, arranged vertically, so the chart can be read as a
marginal strip alongside the main scatter.

Run:  ./sagew experiments/wall/damage/balance_bars_anti.sage
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
        r['area_above'] = float(r['area_above'])
        r['area_below'] = float(r['area_below'])
        r['share_above'] = float(r['share_above'])
        total_area = r['area_above'] + r['area_below']
        r['intensity_share'] = r['area_above'] / total_area if total_area > 0 else 0.5
        rows.append(r)

INV_SQRT2 = 1.0 / sqrt(2.0)

for r in rows:
    x = r['share_above']
    y = r['intensity_share']
    # Projection along (1,-1)/sqrt(2) — ranks from upper-left to lower-right
    r['anti_proj'] = (x - y) * INV_SQRT2
    # Perpendicular distance from anti-diagonal x + y = 1
    r['anti_resid'] = (x + y - 1.0) * INV_SQRT2

# Sort by anti-diagonal projection: upper-left (intense/small territory) at top
rows.sort(key=lambda r: r['anti_proj'])


# ── Plot ────────────────────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(7, 12))

n = len(rows)
y_positions = np.arange(n - 1, -1, -1)  # top to bottom
bar_height = 0.7

for i, r in enumerate(rows):
    kind = r['kind']
    color = zoo_colors.get(kind, '#999999')
    ax.barh(y_positions[i], r['anti_resid'], height=bar_height, color=color,
            edgecolor='#333333', linewidth=0.4, alpha=0.85)

ax.axvline(0, color='#333333', linewidth=0.6)

names = [zoo_names.get(r['kind'], r['kind']) for r in rows]
ax.set_yticks(y_positions)
ax.set_yticklabels(names, fontsize=9)
ax.tick_params(axis='x', labelsize=9)

ax.set_xlabel('Perpendicular distance from anti-diagonal', fontsize=11)
ax.set_ylabel('Partitions ranked along anti-diagonal\n'
              '(intense exporters / small territory  $\\rightarrow$  '
              'diffuse exporters / large territory)',
              fontsize=9)

# Direction annotations
x_lo, x_hi = ax.get_xlim()
ax.text(x_hi * 0.9, 0.5, 'loud\n(both large)',
        fontsize=8, color='#999999', ha='right', va='center', style='italic')
ax.text(x_lo * 0.9, 0.5, 'quiet\n(both small)',
        fontsize=8, color='#999999', ha='left', va='center', style='italic')

fig.suptitle('Damage balance: anti-diagonal residual',
             fontsize=14, fontweight='bold')
fig.text(0.5, 0.95,
         'bar length = signed distance from anti-diagonal  |  '
         'sorted by lean direction',
         ha='center', fontsize=9, color='#666666')

fig.tight_layout(rect=[0, 0, 1, 0.945])

out_path = 'experiments/wall/damage/results/balance_bars_anti.png'
fig.savefig(out_path, dpi=200)
print("Saved: %s" % out_path)
print("Done.")
