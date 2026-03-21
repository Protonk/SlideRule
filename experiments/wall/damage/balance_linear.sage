"""
balance_linear.sage — Balance ratio across partition geometries (linear).

For each cell, plots exp / (exp + inc) where exp and inc are median excess
amplification factors.  The reference line at 0.5 means balanced; above 0.5
is a net exporter, below is a net importer.

4x5 grid excluding chebyshev, ruler, and random.

Run:  ./sagew experiments/wall/damage/balance_linear.sage
"""

from helpers import pathing
load(pathing('experiments', 'damage', '_foreign_error.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 7   # N = 128
EXCLUDE = {'ruler', 'chebyshev', 'random'}
N_ROWS, N_COLS = 4, 5


# ── Amplification ───────────────────────────────────────────────────

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

    return x_pos, balance


# ── Plotting ────────────────────────────────────────────────────────

def plot_balance(zoo_entries, all_data):
    fig, axes = plt.subplots(N_ROWS, N_COLS,
                             figsize=(N_COLS * 3.6, N_ROWS * 2.4),
                             sharex=True, sharey=True, squeeze=False)

    for idx, (name, color, kind) in enumerate(zoo_entries):
        row, col = divmod(idx, N_COLS)
        ax = axes[row][col]
        x_pos, balance = all_data[kind]

        ax.fill_between(x_pos, 0.5, balance, color=color, alpha=0.4)
        ax.plot(x_pos, balance, '-', color=color, linewidth=0.7, alpha=0.9)
        ax.axhline(0.5, color='#333333', linewidth=0.4)

        ax.set_xlim(0.98, 2.02)
        ax.set_ylim(0.0, 1.0)
        ax.set_title(name, fontsize=9, fontweight='bold')

        ax.set_yticks([0.0, 0.5, 1.0])
        ax.set_yticklabels(['0', '.5', '1'], fontsize=6, color='#666666')
        ax.tick_params(axis='y', length=2)
        ax.tick_params(axis='x', labelsize=6)

        if row == N_ROWS - 1:
            ax.set_xlabel('$m$', fontsize=9)

    N = 2**DEPTH
    fig.suptitle(
        'Balance ratio across partition geometries',
        fontsize=13, fontweight='bold', y=0.99,
    )
    fig.text(0.5, 0.965,
             'exp / (exp + inc)  |  '
             'line at 0.5 = balanced  |  '
             'above = net exporter  |  N=%d' % N,
             ha='center', fontsize=9, color='#666666')
    fig.tight_layout(rect=[0, 0, 1, 0.955])

    out_path = 'experiments/wall/damage/results/balance_ratio_linear.png'
    fig.savefig(out_path, dpi=180)
    print("Saved: %s" % out_path)


# ── Precompute ──────────────────────────────────────────────────────

def precompute_all(zoo_entries):
    import sys
    all_data = {}
    total = len(zoo_entries)
    count = 0

    for name, color, kind in zoo_entries:
        count += 1
        sys.stdout.write("  [%2d/%d] %-20s ... " % (count, total, name))
        sys.stdout.flush()
        cells = float_cells(DEPTH, kind)
        x_pos, balance = compute_balance(cells)
        all_data[kind] = (x_pos, balance)
        sys.stdout.write("done\n")
        sys.stdout.flush()

    return all_data


# ── Main ────────────────────────────────────────────────────────────

zoo_entries = [(n, c, k) for n, c, k in PARTITION_ZOO if n not in EXCLUDE]
assert len(zoo_entries) == N_ROWS * N_COLS

N = 2**DEPTH
print()
print("Balance ratio (linear)  (N=%d, %d partitions)" % (N, len(zoo_entries)))
print("=" * 60)
print()

all_data = precompute_all(zoo_entries)
plot_balance(zoo_entries, all_data)
print("Done.")
