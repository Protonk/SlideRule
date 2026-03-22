"""
delta_tables.sage — G4: Delta table heatmaps (LI vs LD).

Visualizes the optimizer's actual product: the delta[state, bit] tables.
Shows LI (single shared table) vs LD (per-layer tables), demonstrating
H1d's observation that LI is concentrated and LD is diffuse.

Runs compute_case() twice (LI and LD) at one benchmark point.
Expected runtime: ~30-60 seconds.

Run:  ./sagew experiments/keystone/delta_tables.sage
"""

import os

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# -- Configuration --------------------------------------------------------

Q = 5
DEPTH = 6
P_NUM = 1
Q_DEN = 2
KIND = 'geometric_x'

OUT_PATH = pathing('experiments', 'keystone', 'results', 'delta_tables.png')


# -- Compute ---------------------------------------------------------------

def extract_delta_matrix_li(delta_rat, q):
    """Extract LI delta as q x 2 matrix (rows=states, cols=bits)."""
    mat = np.zeros((q, 2))
    for (r, b), val in delta_rat.items():
        if isinstance(r, int) and isinstance(b, int):
            mat[r, b] = float(val)
    return mat


def extract_delta_matrix_ld(delta_rat, q, depth):
    """Extract LD delta as depth x q x 2 array."""
    arr = np.zeros((depth, q, 2))
    for key, val in delta_rat.items():
        if len(key) == 3:
            t, r, b = key
            arr[t, r, b] = float(val)
    return arr


def delta_stats(delta_rat):
    """Compute l1, l2, nnz, top2_mass."""
    vals = np.array([float(v) for v in delta_rat.values()])
    abs_vals = np.abs(vals)
    l1 = np.sum(abs_vals)
    l2 = np.linalg.norm(vals)
    nnz = np.sum(abs_vals > 1e-10)
    sorted_abs = np.sort(abs_vals)[::-1]
    top2 = np.sum(sorted_abs[:2]) / l1 if l1 > 0 else 0
    return {'l1': l1, 'l2': l2, 'nnz': int(nnz), 'top2_mass': top2}


# -- Plot ------------------------------------------------------------------

def make_plot():
    print("  Computing LI case...")
    case_li = compute_case(Q, DEPTH, P_NUM, Q_DEN, partition_kind=KIND,
                           layer_dependent=False)
    print("    LI opt_err=%.6f  gap=%.6f  (%.1fs)"
          % (case_li['opt_err'], case_li['gap'], case_li['elapsed']))

    print("  Computing LD case...")
    case_ld = compute_case(Q, DEPTH, P_NUM, Q_DEN, partition_kind=KIND,
                           layer_dependent=True)
    print("    LD opt_err=%.6f  gap=%.6f  (%.1fs)"
          % (case_ld['opt_err'], case_ld['gap'], case_ld['elapsed']))

    delta_li = case_li['opt_pol']['delta_rat']
    delta_ld = case_ld['opt_pol']['delta_rat']

    mat_li = extract_delta_matrix_li(delta_li, Q)
    arr_ld = extract_delta_matrix_ld(delta_ld, Q, DEPTH)

    stats_li = delta_stats(delta_li)
    stats_ld = delta_stats(delta_ld)

    # Figure: LI panel + LD panels (one per layer) + stats bar
    n_panels = 1 + DEPTH
    fig, axes = plt.subplots(1, n_panels, figsize=(2.5 * n_panels, 4.5),
                             constrained_layout=True)

    # Global colorbar range
    vmax = max(np.abs(mat_li).max(),
               np.abs(arr_ld).max()) * 1.05
    vmin = -vmax

    # LI panel
    ax = axes[0]
    im = ax.imshow(mat_li, cmap='RdBu_r', vmin=vmin, vmax=vmax, aspect='auto')
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['bit=0', 'bit=1'], fontsize=7)
    ax.set_yticks(range(Q))
    ax.set_yticklabels(['r=%d' % r for r in range(Q)], fontsize=7)
    ax.set_title('LI (shared)', fontsize=9, fontweight='bold')
    for i in range(Q):
        for j in range(2):
            v = mat_li[i, j]
            ax.text(j, i, '%.4f' % v, ha='center', va='center', fontsize=5,
                    color='white' if abs(v) > vmax * 0.5 else 'black')

    # LD panels (one per layer)
    for t in range(DEPTH):
        ax = axes[1 + t]
        layer_mat = arr_ld[t]
        ax.imshow(layer_mat, cmap='RdBu_r', vmin=vmin, vmax=vmax, aspect='auto')
        ax.set_xticks([0, 1])
        ax.set_xticklabels(['0', '1'], fontsize=7)
        ax.set_yticks(range(Q))
        ax.set_yticklabels([] if t > 0 else ['r=%d' % r for r in range(Q)],
                           fontsize=7)
        ax.set_title('LD layer %d' % t, fontsize=8)
        for i in range(Q):
            for j in range(2):
                v = layer_mat[i, j]
                ax.text(j, i, '%.3f' % v, ha='center', va='center', fontsize=4,
                        color='white' if abs(v) > vmax * 0.5 else 'black')

    # Colorbar
    cbar = fig.colorbar(im, ax=axes.tolist(), shrink=0.6, pad=0.02)
    cbar.set_label('$\\delta$ value', fontsize=8)

    fig.suptitle(
        'Delta tables: %s, q=%d, d=%d, exponent=%d/%d\n'
        'LI: $\\ell_1$=%.4f, nnz=%d, top2=%.1f%%    '
        'LD: $\\ell_1$=%.4f, nnz=%d, top2=%.1f%%'
        % (KIND.replace('_x', ''), Q, DEPTH, P_NUM, Q_DEN,
           stats_li['l1'], stats_li['nnz'], stats_li['top2_mass'] * 100,
           stats_ld['l1'], stats_ld['nnz'], stats_ld['top2_mass'] * 100),
        fontsize=10, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# -- Main ------------------------------------------------------------------

print()
print("Delta table heatmaps: %s q=%d d=%d" % (KIND, Q, DEPTH))
make_plot()
print("Done.")
