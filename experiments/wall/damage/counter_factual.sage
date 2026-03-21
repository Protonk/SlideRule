"""
counter_factual.sage — Damage ribbon across sixteen partition geometries.

For each cell in a partition of [1, 2], the ribbon spans from -incoming
(bottom) to exported (top).  A flat ribbon hugging zero means balanced
damage exchange; asymmetry reveals which cells are net exporters or
importers of chord error.

This is a gestural comparison — the shape and symmetry of the ribbon
matter more than any single value.

Run:  ./sagew experiments/wall/damage/counter_factual.sage
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


def exported_damage(E):
    N = len(E)
    result = []
    for j in range(N):
        row = sorted(E[j][k] for k in range(N) if k != j)
        result.append(_lower_median(row))
    return result


def incoming_damage(E):
    N = len(E)
    result = []
    for k in range(N):
        col = sorted(E[j][k] for j in range(N) if j != k)
        result.append(_lower_median(col))
    return result


# ── Compute ribbon arrays ────────────────────────────────────────────

def compute_ribbon(cells):
    N = len(cells)
    x_pos = [(a + b) / 2.0 for a, b in cells]

    E = build_error_matrix(cells)
    exp = exported_damage(E)
    inc = incoming_damage(E)

    return np.array(x_pos), np.array(exp), np.array(inc)


# ── Plotting ─────────────────────────────────────────────────────────

def plot_ribbons(all_data):
    N = 2**DEPTH
    fig, axes, _n_rows, _n_cols = zoo_subplots(
        figsize_per_cell=(4.5, 3.0), constrained=False,
        sharex=True, squeeze=False)

    for idx, (name, color, kind) in enumerate(PARTITION_ZOO):
        row, col = divmod(idx, _n_cols)
        ax = axes[row][col]
        x_pos, exp, inc = all_data[kind]

        ax.fill_between(x_pos, -inc, exp, color=color, alpha=0.4)
        ax.axhline(0, color='#333333', linewidth=0.4)
        ax.plot(x_pos, exp, '-', color=color, linewidth=0.6, alpha=0.8)
        ax.plot(x_pos, -inc, '-', color=color, linewidth=0.6, alpha=0.8)

        ax.set_xlim(0.98, 2.02)
        ax.set_title(name, fontsize=9, fontweight='bold')

        # Gestural: hide numeric ticks, just show zero line
        ax.set_yticks([0])
        ax.set_yticklabels(['0'], fontsize=6, color='#666666')
        ax.tick_params(axis='y', length=0)
        ax.tick_params(axis='x', labelsize=6)

        if row == _n_rows - 1:
            ax.set_xlabel('$m$', fontsize=9)

    zoo_hide_unused(axes.flat)

    # Left-side labels: top half = exported, bottom half = incoming
    for ax in axes[:, 0]:
        ax.annotate('exp', xy=(0, 1), xycoords='axes fraction',
                    xytext=(-4, -6), textcoords='offset points',
                    fontsize=6, color='#999999', ha='right', va='top')
        ax.annotate('inc', xy=(0, 0), xycoords='axes fraction',
                    xytext=(-4, 6), textcoords='offset points',
                    fontsize=6, color='#999999', ha='right', va='bottom')

    fig.suptitle(
        'Counterfactual damage ribbons across partition geometries',
        fontsize=13, fontweight='bold', y=0.99,
    )
    fig.text(0.5, 0.965,
             'ribbon width = damage asymmetry per cell  |  '
             'flat at zero = balanced exchange  |  N=%d' % N,
             ha='center', fontsize=9, color='#666666')
    fig.tight_layout(rect=[0, 0, 1, 0.955])

    out_path = 'experiments/wall/damage/results/counter_factual.png'
    fig.savefig(out_path, dpi=180)
    print("Saved: %s" % out_path)


# ── Precompute ────────────────────────────────────────────────────────

def precompute_all():
    import sys
    all_data = {}
    total = len(PARTITION_ZOO)
    count = 0

    for name, color, kind in PARTITION_ZOO:
        count += 1
        sys.stdout.write("  [%2d/%d] %-20s ... " % (count, total, name))
        sys.stdout.flush()
        cells = float_cells(DEPTH, kind)
        x_pos, exp, inc = compute_ribbon(cells)
        all_data[kind] = (x_pos, exp, inc)
        sys.stdout.write("done\n")
        sys.stdout.flush()

    return all_data


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics(all_data):
    N = 2**DEPTH
    print()
    print("Counterfactual diagnostics  (N=%d)" % N)
    print("=" * 70)
    print("  %-20s  max(exp)  max(inc)  exporters" % "partition")
    print("  " + "-" * 60)

    for name, color, kind in PARTITION_ZOO:
        x_pos, exp, inc = all_data[kind]
        n = len(x_pos)
        exporters = sum(1 for j in range(n) if exp[j] > inc[j] + 1e-14)
        print("  %-20s  %8.6f  %8.6f  %4d/%d" %
              (name, exp.max(), inc.max(), exporters, n))

    print()


# ── Main ─────────────────────────────────────────────────────────────

N = 2**DEPTH
print()
print("Counterfactual damage ribbons  (N=%d)" % N)
print("=" * 60)
print()

all_data = precompute_all()
print_diagnostics(all_data)
plot_ribbons(all_data)
print("Done.")
