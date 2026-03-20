"""
balance_polar.sage — Polar balance-ratio and log-ratio ribbons.

Two rows of panels per partition would defeat the purpose, so this produces
two separate PNGs from the same amplification data:

  balance_ratio.png  — exp / (exp + inc), reference circle at 0.5
  log_ratio.png      — log(exp / inc), reference circle at 0

Both use the same 4x5 polar grid (excluding chebyshev, ruler, random).

Run:  ./sagew experiments/stepstone/damage/balance_polar.sage
"""

from helpers import pathing
load(pathing('experiments', 'stepstone', 'damage', '_foreign_error.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('experiments', 'zoo_figure.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log as math_log


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 7   # N = 128
EXCLUDE = {'ruler', 'chebyshev', 'random'}
N_ROWS, N_COLS = 4, 5
MAX_DEV = 0.35


# ── Amplification ───────────────────────────────────────────────────

def build_amplification_matrix(E):
    N = len(E)
    diag = [E[k][k] for k in range(N)]
    R = [[0.0] * N for _ in range(N)]
    for j in range(N):
        for k in range(N):
            R[j][k] = E[j][k] / diag[k] if diag[k] > 0 else 1.0
    return R


def _row_col_medians(R):
    """Return (exported, incoming) arrays of median excess amplification."""
    N = len(R)
    exp = []
    for j in range(N):
        row = sorted(R[j][k] - 1.0 for k in range(N) if k != j)
        exp.append(_lower_median(row))
    inc = []
    for k in range(N):
        col = sorted(R[j][k] - 1.0 for j in range(N) if j != k)
        inc.append(_lower_median(col))
    return np.array(exp), np.array(inc)


def compute_scalars(cells):
    x_pos = np.array([(a + b) / 2.0 for a, b in cells])
    E = build_error_matrix(cells)
    R = build_amplification_matrix(E)
    exp, inc = _row_col_medians(R)

    # Guard against division by zero
    total = exp + inc
    total_safe = np.where(total > 1e-30, total, 1e-30)
    ratio_safe = np.where(inc > 1e-30, exp / inc, 1.0)

    balance = exp / total_safe                              # in [0, 1]
    log_rat = np.array([math_log(r) if r > 0 else 0.0
                        for r in ratio_safe])               # signed

    return x_pos, balance, log_rat


# ── Polar grid helper ───────────────────────────────────────────────

def _polar_grid(zoo_entries, all_data, value_key, base, title, subtitle,
                out_path):
    fig = plt.figure(figsize=(N_COLS * 3.2, N_ROWS * 3.2))

    for idx, (name, color, kind) in enumerate(zoo_entries):
        ax = fig.add_subplot(N_ROWS, N_COLS, idx + 1, projection='polar')
        x_pos, vals = all_data[kind][0], all_data[kind][value_key]

        theta = 2.0 * np.pi * (x_pos - 1.0)

        # Centre on `base`, normalize peak deviation to MAX_DEV
        dev = vals - base
        peak = max(abs(dev).max(), 1e-30)
        dev_n = dev / peak * MAX_DEV
        r = base + dev_n

        # Close the loop
        theta_c = np.append(theta, theta[0] + 2.0 * np.pi)
        r_c = np.append(r, r[0])

        # Reference circle
        ref = np.linspace(0, 2.0 * np.pi, 300)
        ax.plot(ref, np.full_like(ref, base),
                color='#333333', linewidth=0.3, alpha=0.5)

        ax.fill_between(theta_c,
                        np.full_like(theta_c, base), r_c,
                        color=color, alpha=0.4)
        ax.plot(theta_c, r_c, '-', color=color,
                linewidth=0.6, alpha=0.8)

        ax.set_title(name, fontsize=8, fontweight='bold', pad=10)
        ax.set_rticks([])
        ax.set_thetagrids([])
        ax.set_ylim(base - MAX_DEV - 0.1, base + MAX_DEV + 0.1)
        ax.grid(False)
        ax.spines['polar'].set_visible(False)

    N = 2**DEPTH
    fig.suptitle(title, fontsize=14, fontweight='bold', y=0.99)
    fig.text(0.5, 0.965, subtitle + '  |  N=%d' % N,
             ha='center', fontsize=9, color='#666666')
    fig.tight_layout(rect=[0, 0, 1, 0.955])
    fig.savefig(out_path, dpi=200)
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
        x_pos, balance, log_rat = compute_scalars(cells)
        all_data[kind] = (x_pos, balance, log_rat)
        sys.stdout.write("done\n")
        sys.stdout.flush()

    return all_data


# ── Main ────────────────────────────────────────────────────────────

zoo_entries = [(n, c, k) for n, c, k in PARTITION_ZOO if n not in EXCLUDE]
assert len(zoo_entries) == N_ROWS * N_COLS, \
    "Expected %d entries after exclusion, got %d" % (
        N_ROWS * N_COLS, len(zoo_entries))

N = 2**DEPTH
print()
print("Balance & log-ratio polar ribbons  (N=%d, %d partitions)" % (
    N, len(zoo_entries)))
print("=" * 60)
print()

all_data = precompute_all(zoo_entries)

RESULTS = 'experiments/stepstone/damage/results'

_polar_grid(
    zoo_entries, all_data, value_key=1, base=0.5,
    title='Balance ratio (polar)',
    subtitle='outward = net exporter  |  inward = net importer  |  '
             'circle = balanced',
    out_path=RESULTS + '/balance_ratio.png',
)

_polar_grid(
    zoo_entries, all_data, value_key=2, base=0.0,
    title='Log damage ratio (polar)',
    subtitle='outward = net exporter  |  inward = net importer  |  '
             'circle = balanced',
    out_path=RESULTS + '/log_ratio.png',
)

print("Done.")
