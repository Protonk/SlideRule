"""
amplification_polar.sage — Polar chord-amplification ribbons.

Same amplification data as amplification.sage but wrapped to polar
coordinates (m in [1,2] -> theta in [0, 2pi]) and trimmed to a 4x5 grid,
excluding chebyshev, ruler, and random whose isolated narrow cells produce
extreme spikes that dominate the radial scale.

Each partition's ribbon is independently normalized so that its peak
deviation fills a fixed fraction of the base radius.  The shape — not the
absolute scale — is what is comparable across panels.

Run:  ./sagew experiments/wall/damage/amplification_polar.sage
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
BASE_RADIUS = 1.0
MAX_RIBBON = 0.35


# ── Amplification ───────────────────────────────────────────────────

def build_amplification_matrix(E):
    N = len(E)
    diag = [E[k][k] for k in range(N)]
    R = [[0.0] * N for _ in range(N)]
    for j in range(N):
        for k in range(N):
            R[j][k] = E[j][k] / diag[k] if diag[k] > 0 else 1.0
    return R


def exported_amp(R):
    N = len(R)
    result = []
    for j in range(N):
        row = sorted(R[j][k] - 1.0 for k in range(N) if k != j)
        result.append(_lower_median(row))
    return result


def incoming_amp(R):
    N = len(R)
    result = []
    for k in range(N):
        col = sorted(R[j][k] - 1.0 for j in range(N) if j != k)
        result.append(_lower_median(col))
    return result


def compute_ribbon(cells):
    N = len(cells)
    x_pos = [(a + b) / 2.0 for a, b in cells]
    E = build_error_matrix(cells)
    R = build_amplification_matrix(E)
    exp = exported_amp(R)
    inc = incoming_amp(R)
    return np.array(x_pos), np.array(exp), np.array(inc)


# ── Plotting ────────────────────────────────────────────────────────

def plot_polar_ribbons(zoo_entries, all_data):
    fig = plt.figure(figsize=(N_COLS * 3.2, N_ROWS * 3.2))

    for idx, (name, color, kind) in enumerate(zoo_entries):
        ax = fig.add_subplot(N_ROWS, N_COLS, idx + 1, projection='polar')
        x_pos, exp, inc = all_data[kind]

        theta = 2.0 * np.pi * (x_pos - 1.0)

        peak = max(exp.max(), inc.max(), 1e-10)
        exp_n = exp / peak * MAX_RIBBON
        inc_n = inc / peak * MAX_RIBBON

        r_upper = BASE_RADIUS + exp_n
        r_lower = BASE_RADIUS - inc_n

        # Close the loop
        theta_c = np.append(theta, theta[0] + 2.0 * np.pi)
        r_upper_c = np.append(r_upper, r_upper[0])
        r_lower_c = np.append(r_lower, r_lower[0])

        ax.fill_between(theta_c, r_lower_c, r_upper_c,
                        color=color, alpha=0.45)
        ax.plot(theta_c, r_upper_c, '-', color=color,
                linewidth=0.5, alpha=0.8)
        ax.plot(theta_c, r_lower_c, '-', color=color,
                linewidth=0.5, alpha=0.8)

        # Reference circle
        ref = np.linspace(0, 2.0 * np.pi, 300)
        ax.plot(ref, np.full_like(ref, BASE_RADIUS),
                color='#333333', linewidth=0.3, alpha=0.5)

        ax.set_title(name, fontsize=8, fontweight='bold', pad=10)
        ax.set_rticks([])
        ax.set_thetagrids([])
        ax.set_ylim(BASE_RADIUS - MAX_RIBBON - 0.1,
                     BASE_RADIUS + MAX_RIBBON + 0.1)
        ax.grid(False)
        ax.spines['polar'].set_visible(False)

    N = 2**DEPTH
    fig.suptitle(
        'Chord amplification ribbons (polar)',
        fontsize=14, fontweight='bold', y=0.99,
    )
    fig.text(0.5, 0.965,
             'ribbon width $\\propto$ median sharing multiplier $-$ 1  |  '
             'circle = no penalty  |  N=%d' % N,
             ha='center', fontsize=9, color='#666666')

    fig.tight_layout(rect=[0, 0, 1, 0.955])

    out_path = 'experiments/wall/damage/results/amplification_polar.png'
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
        x_pos, exp, inc = compute_ribbon(cells)
        all_data[kind] = (x_pos, exp, inc)
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
print("Polar amplification ribbons  (N=%d, %d partitions)" % (N, len(zoo_entries)))
print("=" * 60)
print()

all_data = precompute_all(zoo_entries)
plot_polar_ribbons(zoo_entries, all_data)
print("Done.")
