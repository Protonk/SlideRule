"""
displacement_field_test.sage — Test the tiling displacement field prediction.

Stages:
  A: Geometry-only — does R0(c*) track R0(Δ^L)?
  B: Layer-0 allocation — does c^(<=0) match Π0^∞(c*)?
  C: Cumulative absorption — how fast does c^(<=t) approach c*?
  D: Depth scaling — does the residual stabilize?

Run:  ./sagew experiments/tiling/displacement_field_test.sage
"""

import csv
import gc
import os
import sys
import time

from helpers import pathing
load(pathing('experiments', 'aft', 'keystone', 'keystone_runner.sage'))
load(pathing('lib', 'displacement.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

P_NUM, Q_DEN = 1, 2

STAGE_A_GRID = [
    (kind, depth)
    for kind in ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
    for depth in [4, 5, 6, 7, 8]
]

STAGE_BC_GRID = [
    (kind, q, depth, ld)
    for kind in ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
    for q in [3, 5]
    for depth in [4, 6, 8]
    for ld in [False, True]
]

OUT_DIR = pathing('experiments', 'tiling', 'results', 'displacement_field')


# ── Stage A: geometry-only ───────────────────────────────────────────

def run_stage_a(kind, depth):
    """Compute geometry-only metrics for one partition/depth."""
    partition = build_partition(depth, kind=kind)

    # Free intercept field
    free = free_per_cell_metrics(depth, P_NUM, Q_DEN, partition_kind=kind)
    free_by_bits = {fr['bits']: fr for fr in free['rows']}
    c_star = np.array([float(free_by_bits[row['bits']]['c_opt'])
                       for row in partition])
    metrics = stage_a_metrics(partition, c_star)

    # Representation displacement field
    dL = delta_L_field(partition)

    # Leading-bit halves
    left = leading_bit_halves(partition)

    # Residuals under L∞
    r0_cstar_inf = R0(c_star, left, 'inf')
    r0_dL_inf = R0(dL, left, 'inf')

    # Residuals under L2
    r0_cstar_l2 = R0(c_star, left, 'l2')
    r0_dL_l2 = R0(dL, left, 'l2')

    return {
        'kind': kind, 'depth': depth,
        'corr_inf': metrics['corr_inf'],
        'corr_l2': metrics['corr_l2'],
        'nrmse_inf': metrics['nrmse_inf'],
        'nrmse_l2': metrics['nrmse_l2'],
        'residual_norm_inf': metrics['residual_norm_inf'],
        'residual_norm_2': metrics['residual_norm_2'],
        # For plots
        '_r0_cstar': r0_cstar_l2,
        '_r0_dL': r0_dL_l2,
        '_x_mids': np.array([float((row['x_lo'] + row['x_hi']) / 2)
                             for row in partition]),
    }


# ── Stage B/C: solver-dependent ─────────────────────────────────────

def run_stage_bc(kind, q, depth, ld):
    """Run solver-dependent stages for one case."""
    t0 = time.time()

    case = compute_case(q, depth, P_NUM, Q_DEN,
                        partition_kind=kind, layer_dependent=ld)
    partition = case['partition']
    opt_pol = case['opt_pol']
    free_metrics = case['free_metrics']
    c0_rat = opt_pol['c0_rat']
    delta_rat = opt_pol['delta_rat']

    # Free intercepts
    free_by_bits = {fr['bits']: fr for fr in free_metrics['rows']}
    c_star = np.array([float(free_by_bits[row['bits']]['c_opt'])
                       for row in partition])

    # Full shared intercepts
    c_shared = np.array([float(path_intercept(row['bits'], c0_rat, delta_rat, q))
                         for row in partition])

    # Cumulative intercepts layer by layer
    cumulative = []
    for t in range(depth):
        c_t = np.array([cumulative_intercept(row['bits'], c0_rat, delta_rat, q, t)
                        for row in partition])
        cumulative.append(c_t)

    # Leading-bit halves
    left = leading_bit_halves(partition)

    # --- Stage B metrics ---
    c_layer0 = cumulative[0]  # c^(<=0)
    pi0_inf_cstar = pi0_inf(c_star, left)

    layer0_fit_gap_inf = float(np.max(np.abs(c_layer0 - pi0_inf_cstar)))
    layer0_fit_gap_2 = float(np.linalg.norm(c_layer0 - pi0_l2(c_star, left)))

    r0_cstar_inf_norm = float(np.max(np.abs(R0(c_star, left, 'inf'))))
    r0_cstar_2_norm = float(np.linalg.norm(R0(c_star, left, 'l2')))

    err_layer0_inf = float(np.max(np.abs(c_star - c_layer0)))
    err_layer0_2 = float(np.linalg.norm(c_star - c_layer0))

    layer0_excess_inf = err_layer0_inf - r0_cstar_inf_norm
    layer0_excess_2 = err_layer0_2 - r0_cstar_2_norm

    # --- Stage C metrics ---
    dL = delta_L_field(partition)
    r0_dL = R0(dL, left, 'inf')

    e_t_inf = []
    e_t_2 = []
    resid_corr_t = []
    for t in range(depth):
        diff = c_star - cumulative[t]
        e_t_inf.append(float(np.max(np.abs(diff))))
        e_t_2.append(float(np.linalg.norm(diff)))
        if np.std(diff) > 1e-15 and np.std(r0_dL) > 1e-15:
            resid_corr_t.append(float(np.corrcoef(diff, r0_dL)[0, 1]))
        else:
            resid_corr_t.append(0.0)

    elapsed = time.time() - t0

    del case
    gc.collect()

    return {
        'kind': kind, 'q': q, 'depth': depth,
        'layer_dependent': ld,
        'layer0_fit_gap_inf': layer0_fit_gap_inf,
        'layer0_fit_gap_2': layer0_fit_gap_2,
        'layer0_excess_inf': layer0_excess_inf,
        'layer0_excess_2': layer0_excess_2,
        'e_t_inf': e_t_inf,
        'e_t_2': e_t_2,
        'resid_corr_t': resid_corr_t,
        'time': elapsed,
        # For plots
        '_cumulative': cumulative,
        '_c_star': c_star,
        '_c_shared': c_shared,
        '_x_mids': np.array([float((row['x_lo'] + row['x_hi']) / 2)
                             for row in partition]),
    }


# ── CSV output ───────────────────────────────────────────────────────

def write_stage_a_csv(results, filepath):
    cols = ['kind', 'depth', 'corr_inf', 'corr_l2', 'nrmse_inf',
            'nrmse_l2', 'residual_norm_inf', 'residual_norm_2']
    with open(filepath, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction='ignore')
        w.writeheader()
        for r in results:
            w.writerow(r)
    print("  -> %s (%d rows)" % (filepath, len(results)))


def write_stage_bc_csv(results, filepath):
    cols = ['kind', 'q', 'depth', 'layer_dependent',
            'layer0_fit_gap_inf', 'layer0_fit_gap_2',
            'layer0_excess_inf', 'layer0_excess_2',
            'e_0_inf', 'e_final_inf', 'time']
    rows = []
    for r in results:
        row = dict(r)
        row['e_0_inf'] = r['e_t_inf'][0]
        row['e_final_inf'] = r['e_t_inf'][-1]
        rows.append(row)
    with open(filepath, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction='ignore')
        w.writeheader()
        for row in rows:
            w.writerow(row)
    print("  -> %s (%d rows)" % (filepath, len(rows)))


# ── Plots ────────────────────────────────────────────────────────────

def plot_stage_a(results, filepath):
    """Grid of R0(c*) vs R0(Δ^L) residuals."""
    kinds = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
    depths = sorted(set(r['depth'] for r in results))
    fig, axes = plt.subplots(len(kinds), len(depths),
                             figsize=(3 * len(depths), 2.8 * len(kinds)),
                             constrained_layout=True)

    by_key = {(r['kind'], r['depth']): r for r in results}

    for i, kind in enumerate(kinds):
        for j, depth in enumerate(depths):
            ax = axes[i, j]
            key = (kind, depth)
            if key not in by_key:
                ax.set_visible(False)
                continue
            r = by_key[key]
            xs = r['_x_mids']
            ax.plot(xs, r['_r0_cstar'], color='#e74c3c', linewidth=0.8,
                    label='R0(c*)')
            ax.plot(xs, r['_r0_dL'] * scale_fit(r['_r0_cstar'], r['_r0_dL']),
                    color='#3498db', linewidth=0.8, linestyle='--',
                    label='R0(Δ^L) scaled')
            ax.axhline(0, color='#999', linewidth=0.3)
            ax.tick_params(labelsize=5)
            ax.grid(True, alpha=0.2, linewidth=0.3)
            if i == 0:
                ax.set_title('d=%d' % depth, fontsize=8)
            if j == 0:
                short = kind.replace('_x', '').replace('_', '-')
                ax.set_ylabel(short, fontsize=8)
            if i == 0 and j == 0:
                ax.legend(fontsize=5)
            # Annotate correlation
            ax.text(0.97, 0.03, 'r=%.3f' % r['corr_l2'],
                    transform=ax.transAxes, fontsize=5, ha='right',
                    va='bottom')

    fig.suptitle('Stage A: R0(c*) vs R0(Δ^L)', fontsize=11, fontweight='bold')
    fig.savefig(filepath, dpi=180, bbox_inches='tight')
    print("  -> %s" % filepath)


def plot_stage_c(results, filepath):
    """Cumulative absorption curves E_t for select cases."""
    # Pick a few representative cases
    show = [(r['kind'], r['q'], r['depth'], r['layer_dependent'])
            for r in results
            if r['depth'] == 6]
    fig, axes = plt.subplots(1, 2, figsize=(12, 5), constrained_layout=True)

    for r in results:
        key = (r['kind'], r['q'], r['depth'], r['layer_dependent'])
        if key not in show:
            continue
        ld_tag = 'LD' if r['layer_dependent'] else 'LI'
        short = r['kind'].replace('_x', '')
        label = '%s q=%d %s' % (short, r['q'], ld_tag)
        layers = range(len(r['e_t_inf']))

        ax = axes[0]
        ax.plot(list(layers), r['e_t_inf'], marker='.', markersize=3,
                linewidth=1, label=label)

        ax = axes[1]
        ax.plot(list(layers), r['e_t_2'], marker='.', markersize=3,
                linewidth=1, label=label)

    axes[0].set_ylabel('||c* - c^(<=t)||∞', fontsize=9)
    axes[0].set_xlabel('Layer t', fontsize=9)
    axes[0].set_title('L∞ convergence', fontsize=10)
    axes[0].legend(fontsize=6)
    axes[0].grid(True, alpha=0.3)

    axes[1].set_ylabel('||c* - c^(<=t)||₂', fontsize=9)
    axes[1].set_xlabel('Layer t', fontsize=9)
    axes[1].set_title('L2 convergence', fontsize=10)
    axes[1].legend(fontsize=6)
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('Stage C: Cumulative layer absorption (depth=6)',
                 fontsize=11, fontweight='bold')
    fig.savefig(filepath, dpi=180, bbox_inches='tight')
    print("  -> %s" % filepath)


def plot_stage_d(a_results, bc_results, filepath):
    """Depth scaling: residual norms vs depth."""
    kinds = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
    colors = {'uniform_x': '#e74c3c', 'geometric_x': '#3498db',
              'harmonic_x': '#2ecc71', 'mirror_harmonic_x': '#9b59b6'}

    fig, axes = plt.subplots(1, 2, figsize=(11, 4.5), constrained_layout=True)

    # Left: geometry-only residual norm vs depth
    ax = axes[0]
    for kind in kinds:
        ds = sorted(r['depth'] for r in a_results if r['kind'] == kind)
        norms = [r['residual_norm_inf'] for r in a_results
                 if r['kind'] == kind]
        short = kind.replace('_x', '').replace('_', '-')
        ax.plot(ds, norms, marker='o', markersize=4, linewidth=1.2,
                color=colors[kind], label=short)
    ax.set_xlabel('Depth', fontsize=9)
    ax.set_ylabel('||R0(c*)||∞', fontsize=9)
    ax.set_title('Geometry-only residual vs depth', fontsize=10)
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    # Right: solver E_0 vs depth (LI, q=3)
    ax = axes[1]
    for kind in kinds:
        subset = [r for r in bc_results
                  if r['kind'] == kind and r['q'] == 3
                  and not r['layer_dependent']]
        if not subset:
            continue
        ds = [r['depth'] for r in subset]
        e0s = [r['e_t_inf'][0] for r in subset]
        short = kind.replace('_x', '').replace('_', '-')
        ax.plot(ds, e0s, marker='s', markersize=4, linewidth=1.2,
                color=colors[kind], label=short)
    ax.set_xlabel('Depth', fontsize=9)
    ax.set_ylabel('||c* - c^(<=0)||∞', fontsize=9)
    ax.set_title('Layer-0 error vs depth (LI, q=3)', fontsize=10)
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Stage D: Depth scaling', fontsize=11, fontweight='bold')
    fig.savefig(filepath, dpi=180, bbox_inches='tight')
    print("  -> %s" % filepath)


# ── Main ─────────────────────────────────────────────────────────────

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

print()
print("=" * 72)
print("Displacement field test")
print("=" * 72)

# ── Stage A ──────────────────────────────────────────────────────────
print()
print("Stage A: Geometry-only (20 cases)")
print("-" * 40)
sys.stdout.flush()

a_results = []
for kind, depth in STAGE_A_GRID:
    r = run_stage_a(kind, depth)
    short = kind.replace('_x', '').replace('_', '-')
    print("  %18s d=%d  corr_inf=%.4f  corr_l2=%.4f  nrmse=%.4f  ||R0||∞=%.6f"
          % (short, depth, r['corr_inf'], r['corr_l2'],
             r['nrmse_l2'], r['residual_norm_inf']))
    a_results.append(r)

write_stage_a_csv(a_results, os.path.join(OUT_DIR, 'stage_a.csv'))
plot_stage_a(a_results, os.path.join(OUT_DIR, 'geometry_residuals.png'))

# ── Stage B/C ────────────────────────────────────────────────────────
print()
print("Stage B/C: Solver-dependent (48 cases)")
print("-" * 40)
sys.stdout.flush()

bc_results = []
for kind, q, depth, ld in STAGE_BC_GRID:
    ld_tag = "LD" if ld else "LI"
    short = kind.replace('_x', '').replace('_', '-')
    r = run_stage_bc(kind, q, depth, ld)
    print("  %18s q=%d d=%d %s  fit_gap=%.6f  excess=%.6f  E0=%.6f  Efinal=%.6f  (%.1fs)"
          % (short, q, depth, ld_tag,
             r['layer0_fit_gap_inf'], r['layer0_excess_inf'],
             r['e_t_inf'][0], r['e_t_inf'][-1], r['time']))
    sys.stdout.flush()
    bc_results.append(r)

write_stage_bc_csv(bc_results, os.path.join(OUT_DIR, 'stage_bc.csv'))
plot_stage_c(bc_results, os.path.join(OUT_DIR, 'cumulative_absorption.png'))
plot_stage_d(a_results, bc_results, os.path.join(OUT_DIR, 'depth_scaling.png'))

# ── Summary ──────────────────────────────────────────────────────────
print()
print("=" * 72)
print("Stage A summary:")
for kind in ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']:
    subset = [r for r in a_results if r['kind'] == kind]
    corrs = [r['corr_inf'] for r in subset]
    short = kind.replace('_x', '').replace('_', '-')
    print("  %18s  corr_inf: min=%.4f  max=%.4f  mean=%.4f"
          % (short, min(corrs), max(corrs), np.mean(corrs)))

print()
print("Stage B summary (layer-0 fit gap, L∞):")
for kind in ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']:
    subset = [r for r in bc_results if r['kind'] == kind]
    gaps = [r['layer0_fit_gap_inf'] for r in subset]
    short = kind.replace('_x', '').replace('_', '-')
    print("  %18s  fit_gap: min=%.6f  max=%.6f  mean=%.6f"
          % (short, min(gaps), max(gaps), np.mean(gaps)))

print()
print("=" * 72)
print("Done. Output: %s" % OUT_DIR)
