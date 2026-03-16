"""
octave_cell_profile.sage — Per-cell error profiles across octaves.

For fixed-width windows [s, s+1) at different starting points, shows
how the per-cell free error varies across the partition.

Two panels:
  Left (uniform):  a "fan" of lines that narrows at higher x_start —
                   curvature variation across the interval shrinks.
  Right (geometric): flat profiles that drop in level — all cells are
                     equal by log-space self-similarity, but easier at
                     higher x_start.

Run:  ./sagew experiments/stitching/octave_cell_profile.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'partitions.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 4
P_NUM = 1
Q_DEN = 2
N = 2^DEPTH

X_STARTS = [1, 2, 4, 8]
X_WIDTH = 1

KINDS = ['uniform_x', 'geometric_x']


# ── Compute ──────────────────────────────────────────────────────────

def get_cell_errors(kind, x_start):
    """Return sorted list of (cell_index, cell_worst) from free-per-cell."""
    metrics = free_per_cell_metrics(
        DEPTH, P_NUM, Q_DEN,
        partition_kind=kind, x_start=x_start, x_width=X_WIDTH)
    return [(row['index'], row['cell_worst']) for row in metrics['rows']]


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, (ax_u, ax_g) = plt.subplots(1, 2, figsize=(12, 5), sharey=True)
    cmap = cm.viridis

    for ax, kind, title in [
        (ax_u, 'uniform_x', 'uniform'),
        (ax_g, 'geometric_x', 'geometric'),
    ]:
        for i, xs in enumerate(X_STARTS):
            color = cmap(i / max(1, len(X_STARTS) - 1))
            cells = get_cell_errors(kind, xs)
            indices = [c[0] for c in cells]
            errors = [c[1] for c in cells]

            ax.plot(indices, errors, '-o', color=color,
                    linewidth=1.5, markersize=4,
                    label=f'$x_{{\\mathrm{{start}}}}={xs}$')

        ax.set_xlabel('cell index $j$', fontsize=10)
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.legend(fontsize=8, loc='upper right')
        ax.tick_params(labelsize=8)
        ax.set_xticks(range(0, N, max(1, N // 8)))

    ax_u.set_ylabel('per-cell free error', fontsize=10)

    fig.suptitle(
        f'Per-cell error profile — fixed-width $[s,\\, s{{+}}1)$,  '
        f'd={DEPTH}, $\\alpha$={P_NUM}/{Q_DEN}',
        fontsize=13, fontweight='bold',
    )
    fig.tight_layout(rect=[0, 0, 1, 0.94])

    out_path = 'experiments/stitching/octave_cell_profile.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"\nSaved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Per-cell error profile diagnostics")
    print("=" * 72)
    print(f"  depth={DEPTH}, alpha={P_NUM}/{Q_DEN}, width={X_WIDTH}")

    for kind in KINDS:
        print(f"\n  {kind}:")
        for xs in X_STARTS:
            cells = get_cell_errors(kind, xs)
            errors = [c[1] for c in cells]
            ratio = max(errors) / min(errors) if min(errors) > 0 else float('inf')
            print(f"    x_start={xs:2d}  "
                  f"min={min(errors):.6e}  max={max(errors):.6e}  "
                  f"ratio={ratio:.4f}")


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
