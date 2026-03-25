"""
balance_summary.sage — Five-scalar summary of the balance ratio curve.

For each partition, computes:
  crossings    — sign changes of (balance - 0.5) between adjacent cells
  area_above   — trapezoidal integral of max(balance - 0.5, 0) over [1,2]
  area_below   — trapezoidal integral of max(0.5 - balance, 0) over [1,2]
  share_above  — fraction of domain where balance > 0.5 (net exporter)
  share_below  — fraction of domain where balance < 0.5 (net importer)

Run:  ./sagew experiments/fore/counterfactual/balance_summary.sage
"""

from helpers import pathing
load(pathing('experiments', 'fore', 'counterfactual', '_foreign_error.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import numpy as np
import csv


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 7   # N = 128


# ── Amplification & balance ─────────────────────────────────────────

def build_amplification_matrix(E):
    N = len(E)
    diag = [E[k][k] for k in range(N)]
    R = [[0.0] * N for _ in range(N)]
    for j in range(N):
        for k in range(N):
            R[j][k] = E[j][k] / diag[k] if diag[k] > 0 else 1.0
    return R


def compute_balance(cells):
    N = len(cells)
    x_pos = np.array([(a + b) / 2.0 for a, b in cells])
    widths = np.array([b - a for a, b in cells])

    E = build_error_matrix(cells)
    R = build_amplification_matrix(E)

    exp = []
    for j in range(N):
        row = sorted(R[j][k] - 1.0 for k in range(N) if k != j)
        exp.append(_lower_median(row))

    inc = []
    for k in range(N):
        col = sorted(R[j][k] - 1.0 for j in range(N) if j != k)
        inc.append(_lower_median(col))

    exp = np.array(exp)
    inc = np.array(inc)

    total = exp + inc
    total_safe = np.where(total > 1e-30, total, 1e-30)
    balance = exp / total_safe

    return x_pos, widths, balance


# ── Five scalars ────────────────────────────────────────────────────

def summarize(x_pos, widths, balance):
    dev = balance - 0.5
    N = len(dev)

    # Crossings
    crossings = 0
    for i in range(N - 1):
        if dev[i] * dev[i + 1] < 0:
            crossings += 1

    # Area above and below (trapezoidal)
    dev_above = np.clip(dev, 0, None)
    dev_below = np.clip(-dev, 0, None)
    area_above = float(np.trapz(dev_above, x_pos))
    area_below = float(np.trapz(dev_below, x_pos))

    # Domain share
    total_width = float(widths.sum())
    share_above = float(widths[dev > 0].sum()) / total_width
    share_below = float(widths[dev < 0].sum()) / total_width

    return crossings, area_above, area_below, share_above, share_below


# ── Main ────────────────────────────────────────────────────────────

import sys

N = 2**DEPTH
print()
print("Balance summary  (N=%d)" % N)
print("=" * 90)
print("  %-20s  cross  area_above  area_below  share_above  share_below" %
      "partition")
print("  " + "-" * 80)

rows = []
for name, color, kind in PARTITION_ZOO:
    sys.stdout.write("  computing %-20s ... " % name)
    sys.stdout.flush()
    cells = float_cells(DEPTH, kind)
    x_pos, widths, balance = compute_balance(cells)
    crossings, area_above, area_below, share_above, share_below = \
        summarize(x_pos, widths, balance)
    rows.append({
        'kind': kind,
        'name': name,
        'crossings': crossings,
        'area_above': area_above,
        'area_below': area_below,
        'share_above': share_above,
        'share_below': share_below,
    })
    print("done")

print()
for r in rows:
    print("  %-20s  %5d  %10.6f  %10.6f  %11.4f  %11.4f" % (
        r['name'], r['crossings'], r['area_above'], r['area_below'],
        r['share_above'], r['share_below']))
print()

# Write CSV
out_path = 'experiments/fore/counterfactual/results/balance_summary.csv'
fieldnames = ['kind', 'name', 'crossings', 'area_above', 'area_below',
              'share_above', 'share_below']
with open(out_path, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
print("Saved: %s" % out_path)
print("Done.")
