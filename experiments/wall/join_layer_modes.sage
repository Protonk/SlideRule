"""
join_layer_modes.sage — Pair LI and LD rows for wall comparison.

Reads enriched_summary.csv and pairs rows by (kind, q, depth, exponent).
Outputs gap_li, gap_ld, gap_reduction, worst-cell positions, and shift.

Run:  ./sagew experiments/wall/join_layer_modes.sage
"""

import csv
import os

from helpers import pathing


# ── Configuration ────────────────────────────────────────────────────

IN_PATH = pathing('experiments', 'wall', 'results', 'enriched_summary.csv')
OUT_PATH = pathing('experiments', 'wall', 'results', 'joined_layer_modes.csv')

COLUMNS = [
    'partition_kind', 'exponent', 'q', 'depth',
    'gap_li', 'gap_ld', 'gap_reduction',
    'opt_err_li', 'opt_err_ld',
    'free_err',
    'worst_cell_x_mid_li', 'worst_cell_x_mid_ld', 'worst_cell_shift',
    'worst_cell_plog_mid_li', 'worst_cell_plog_mid_ld',
    'param_to_cell_ratio_li', 'param_to_cell_ratio_ld',
]


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Joining layer modes...")

rows = []
with open(IN_PATH, 'r', newline='') as f:
    rows = list(csv.DictReader(f))

# Index by case key
by_key = {}
for r in rows:
    key = (r['partition_kind'], r['exponent'], r['q'], r['depth'])
    ld = r['layer_dependent'] == 'True'
    by_key.setdefault(key, {})[ld] = r

joined = []
for key, modes in sorted(by_key.items()):
    if True not in modes or False not in modes:
        continue
    li = modes[False]
    ld = modes[True]

    gap_li = float(li['gap'])
    gap_ld = float(ld['gap'])

    if gap_li > 1e-12:
        gap_reduction = 1.0 - gap_ld / gap_li
    else:
        gap_reduction = ''

    def _safe_float(val):
        try:
            return float(val)
        except (ValueError, TypeError):
            return ''

    x_mid_li = _safe_float(li.get('worst_cell_x_mid', ''))
    x_mid_ld = _safe_float(ld.get('worst_cell_x_mid', ''))

    if isinstance(x_mid_li, float) and isinstance(x_mid_ld, float):
        shift = abs(x_mid_li - x_mid_ld)
    else:
        shift = ''

    joined.append({
        'partition_kind': key[0],
        'exponent': key[1],
        'q': key[2],
        'depth': key[3],
        'gap_li': gap_li,
        'gap_ld': gap_ld,
        'gap_reduction': gap_reduction,
        'opt_err_li': float(li['opt_err']),
        'opt_err_ld': float(ld['opt_err']),
        'free_err': float(li['free_err']),
        'worst_cell_x_mid_li': x_mid_li,
        'worst_cell_x_mid_ld': x_mid_ld,
        'worst_cell_shift': shift,
        'worst_cell_plog_mid_li': _safe_float(li.get('worst_cell_plog_mid', '')),
        'worst_cell_plog_mid_ld': _safe_float(ld.get('worst_cell_plog_mid', '')),
        'param_to_cell_ratio_li': _safe_float(li.get('param_to_cell_ratio', '')),
        'param_to_cell_ratio_ld': _safe_float(ld.get('param_to_cell_ratio', '')),
    })

with open(OUT_PATH, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(joined)

print("  Paired %d LI/LD cases" % len(joined))
print("  Wrote %s" % OUT_PATH)

# Quick summary
if joined:
    reductions = [float(j['gap_reduction']) for j in joined
                  if j['gap_reduction'] != '']
    if reductions:
        print("  Gap reduction range: %.1f%% to %.1f%% (median %.1f%%)"
              % (min(reductions) * 100, max(reductions) * 100,
                 sorted(reductions)[len(reductions) // 2] * 100))

    shifts = [float(j['worst_cell_shift']) for j in joined
              if j['worst_cell_shift'] != '']
    if shifts:
        print("  Worst-cell shift range: %.4f to %.4f" % (min(shifts), max(shifts)))

print("Done.")
