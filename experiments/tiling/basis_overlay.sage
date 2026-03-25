"""
basis_overlay.sage — Transported residual overlay for visual comparison.

Transports each partition's R0(c*) to a common regular grid in mantissa
coordinates via linear interpolation. For visualisation only — never
used as a fitting surface.

Run:  ./sagew experiments/tiling/basis_overlay.sage
"""

import csv
import os

from helpers import pathing
load(pathing('experiments', 'aft', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

P_NUM, Q_DEN = 1, 2
KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x',
         'half_geometric_x', 'eps_density_x', 'midpoint_dense_x']
DEPTHS = [6, 7, 8]
GRID_N = 200  # common grid resolution per half

OUT_DIR = pathing('experiments', 'tiling', 'results', 'basis_identification')

COLORS = {
    'uniform_x': '#1f77b4', 'geometric_x': '#9467bd',
    'harmonic_x': '#2ca02c', 'mirror_harmonic_x': '#d62728',
    'half_geometric_x': '#636363', 'eps_density_x': '#252525',
    'midpoint_dense_x': '#969696',
}
SHORTS = {k: k.replace('_x', '').replace('_', '-') for k in KINDS}


# ── Transport ────────────────────────────────────────────────────────

def transport_to_grid(m_mids, g_vals, grid):
    """Linear interpolation of g onto a regular grid."""
    return np.interp(grid, m_mids, g_vals)


def compute_residual(kind, depth):
    """Compute R0(c*) for one case, return (m_mids, g_vals)."""
    partition = build_partition(depth, kind=kind)
    free = free_per_cell_metrics(depth, P_NUM, Q_DEN, partition_kind=kind)
    free_by_bits = {fr['bits']: fr for fr in free['rows']}
    c_star = np.array([float(free_by_bits[row['bits']]['c_opt'])
                       for row in partition])
    left = leading_bit_halves(partition)
    g = R0(c_star, left, 'inf')
    m_mids = np.array([float((row['x_lo'] + row['x_hi']) / 2) - 1.0
                        for row in partition])
    return m_mids, g


# ── PCA template extraction ─────────────────────────────────────────

def extract_pc_template(baseline_kinds, depth, grid):
    """Extract first PC of transported residuals across baseline kinds."""
    transported = []
    for kind in baseline_kinds:
        m_mids, g = compute_residual(kind, depth)
        g_t = transport_to_grid(m_mids, g, grid)
        transported.append(g_t)

    matrix = np.array(transported)  # (n_kinds, n_grid)
    # Center
    mean_vec = np.mean(matrix, axis=0)
    centered = matrix - mean_vec

    # SVD
    U, S, Vt = np.linalg.svd(centered, full_matrices=False)
    pc1 = Vt[0]  # first principal component direction
    # Orient consistently (positive at left boundary)
    if pc1[0] < 0:
        pc1 = -pc1

    return pc1, mean_vec, S


# ── Main ─────────────────────────────────────────────────────────────

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

# Common grid: left half [0, 0.5), right half [0.5, 1.0)
grid = np.linspace(0.001, 0.999, GRID_N)

baseline_kinds = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']

print()
print("=" * 72)
print("Basis overlay: transported residuals + PCA template")
print("=" * 72)

# ── Overlay plot ─────────────────────────────────────────────────────

fig, axes = plt.subplots(len(DEPTHS), 2, figsize=(13, 3.5 * len(DEPTHS)),
                         constrained_layout=True)

for di, depth in enumerate(DEPTHS):
    # Extract PC template at this depth
    pc1, mean_vec, svals = extract_pc_template(baseline_kinds, depth, grid)

    print()
    print("Depth %d: PC1 explains %.1f%% of baseline variance"
          % (depth, 100.0 * svals[0]**2 / np.sum(svals**2) if np.sum(svals**2) > 0 else 0))

    # Left panel: all partitions' transported residuals
    ax = axes[di, 0]
    for kind in KINDS:
        m_mids, g = compute_residual(kind, depth)
        g_t = transport_to_grid(m_mids, g, grid)
        lw = 1.5 if kind in baseline_kinds else 1.0
        ls = '-' if kind in baseline_kinds else '--'
        ax.plot(grid, g_t, color=COLORS[kind], linewidth=lw,
                linestyle=ls, label=SHORTS[kind], alpha=0.8)

    ax.axhline(0, color='#999', linewidth=0.3)
    ax.axvline(0.5, color='#999', linewidth=0.3, linestyle=':')
    ax.set_ylabel('R0(c*) transported', fontsize=9)
    ax.set_title('Depth %d: all partitions' % depth, fontsize=10)
    ax.legend(fontsize=6, ncol=2, loc='upper right')
    ax.grid(True, alpha=0.2)
    ax.tick_params(labelsize=7)

    # Right panel: PC1 template + scaled overlay
    ax = axes[di, 1]
    ax.plot(grid, pc1, color='black', linewidth=2.0, label='PC1 template')

    # Check PC shape stability: overlay each baseline's projection
    for kind in baseline_kinds:
        m_mids, g = compute_residual(kind, depth)
        g_t = transport_to_grid(m_mids, g, grid)
        # Scale fit: best α for g_t ≈ α*pc1 + β
        centered = g_t - np.mean(g_t)
        alpha = np.dot(centered, pc1) / np.dot(pc1, pc1)
        ax.plot(grid, alpha * pc1, color=COLORS[kind], linewidth=0.8,
                linestyle='--', alpha=0.6, label='%s scaled' % SHORTS[kind])

    ax.axhline(0, color='#999', linewidth=0.3)
    ax.axvline(0.5, color='#999', linewidth=0.3, linestyle=':')
    ax.set_ylabel('PC1 template', fontsize=9)
    ax.set_title('Depth %d: PC1 (%.0f%% var)' %
                 (depth, 100.0 * svals[0]**2 / np.sum(svals**2)), fontsize=10)
    ax.legend(fontsize=6, ncol=2, loc='upper right')
    ax.grid(True, alpha=0.2)
    ax.tick_params(labelsize=7)

for ax in axes[-1, :]:
    ax.set_xlabel('Mantissa m', fontsize=9)

fig.suptitle('Transported residual overlays + PCA template',
             fontsize=12, fontweight='bold')

out_path = os.path.join(OUT_DIR, 'basis_template_overlays.png')
fig.savefig(out_path, dpi=180, bbox_inches='tight')
print()
print("  -> %s" % out_path)

# ── PC stability across depths ───────────────────────────────────────

print()
print("PC1 shape stability across depths:")
pc_templates = {}
for depth in DEPTHS:
    pc1, _, _ = extract_pc_template(baseline_kinds, depth, grid)
    pc_templates[depth] = pc1

for i, d1 in enumerate(DEPTHS):
    for d2 in DEPTHS[i+1:]:
        corr = float(np.corrcoef(pc_templates[d1], pc_templates[d2])[0, 1])
        print("  d=%d vs d=%d: corr=%.6f" % (d1, d2, corr))

print()
print("Done.")
