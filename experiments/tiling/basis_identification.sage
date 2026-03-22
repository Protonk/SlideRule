"""
basis_identification.sage — Basis-family comparison for the intercept
organisation claim.

Fits candidate basis families to the transported residual g = R0(c*)
in native cell coordinates and scores them with training/holdout splits.

Run:  ./sagew experiments/tiling/basis_identification.sage
"""

import csv
import os
import sys
from math import log

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('lib', 'displacement.sage'))

import numpy as np
from numpy.linalg import lstsq


# ── Configuration ────────────────────────────────────────────────────

P_NUM, Q_DEN = 1, 2

BASELINE_KINDS = ['uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x']
ADVERSARY_KINDS = ['half_geometric_x', 'eps_density_x', 'midpoint_dense_x']
ALL_KINDS = BASELINE_KINDS + ADVERSARY_KINDS
DEPTHS = [4, 5, 6, 7, 8]

TRAIN_KINDS = BASELINE_KINDS
TRAIN_DEPTHS = [5, 6, 7]
DEPTH_TRAIN = [5, 6]
DEPTH_TEST = [7, 8]

OUT_DIR = pathing('experiments', 'tiling', 'results', 'basis_identification')


# ── Build observable table ───────────────────────────────────────────

def build_observables(kind, depth):
    """Build per-cell observable table for one case."""
    partition = build_partition(depth, kind=kind)
    free = free_per_cell_metrics(depth, P_NUM, Q_DEN, partition_kind=kind)
    free_by_bits = {fr['bits']: fr for fr in free['rows']}
    x_start = float(partition[0]['x_lo'])
    x_width = float(partition[-1]['x_hi']) - x_start

    c_star = np.array([float(free_by_bits[row['bits']]['c_opt'])
                       for row in partition])
    left = leading_bit_halves(partition)
    g = R0(c_star, left, 'inf')

    # Affine detrend for geometric diagnostic
    x_mids = np.array([float((row['x_lo'] + row['x_hi']) / 2)
                        for row in partition])
    m_mids = (x_mids - x_start) / x_width

    rows = []
    for j, row in enumerate(partition):
        a_m = (float(row['x_lo']) - x_start) / x_width
        b_m = (float(row['x_hi']) - x_start) / x_width
        m_mid = m_mids[j]
        w_x = float(row['x_hi'] - row['x_lo'])
        w_log = float(log(float(row['x_hi'])) - log(float(row['x_lo'])))

        rows.append({
            'kind': kind,
            'depth': depth,
            'cell_index': j,
            'half': 'L' if left[j] else 'R',
            'm_mid': m_mid,
            'width_x': w_x,
            'width_log': w_log,
            'c_star': float(c_star[j]),
            'g': float(g[j]),
            'eps_mid': eps_val(m_mid),
            'eps_prime_mid': eps_prime(m_mid),
            'eps_pp_mid': eps_pp(m_mid),
            'mean_cell_eps': mean_cell_eps(a_m, b_m),
            'cell_moment1': cell_eps_moment1(a_m, b_m),
            'cell_moment2': cell_eps_moment2(a_m, b_m),
            'eps_a': eps_val(a_m),
            'eps_b': eps_val(b_m),
            'contains_mstar': 1 if a_m <= MSTAR <= b_m else 0,
            'dist_to_mstar': m_mid - MSTAR,
        })

    return rows


def add_affine_detrended(rows, kind, depth):
    """Add affine-detrended rows for geometric partitions."""
    subset = [r for r in rows if r['kind'] == kind and r['depth'] == depth]
    if not subset:
        return []

    ms = np.array([r['m_mid'] for r in subset])
    cs = np.array([r['c_star'] for r in subset])

    # Fit affine: c* ≈ α + β*m
    A = np.column_stack([np.ones(len(ms)), ms])
    coeffs, _, _, _ = lstsq(A, cs, rcond=None)
    residual = cs - A @ coeffs

    new_rows = []
    for j, r in enumerate(subset):
        nr = dict(r)
        nr['kind'] = kind + '_affdetrend'
        nr['g'] = float(residual[j])
        new_rows.append(nr)
    return new_rows


# ── Basis families ───────────────────────────────────────────────────

def build_design_matrix(rows, basis_name):
    """Build the design matrix for a basis family."""
    n = len(rows)

    if basis_name == 'H_width':
        X = np.column_stack([
            [r['width_x'] for r in rows],
            [r['width_log'] for r in rows],
            [r['width_x']**2 for r in rows],
            [r['width_log']**2 for r in rows],
            [1.0 if r['half'] == 'L' else 0.0 for r in rows],
        ])
    elif basis_name == 'H_value':
        X = np.column_stack([
            [r['eps_mid'] for r in rows],
        ])
    elif basis_name == 'H_peak':
        X = np.column_stack([
            [r['dist_to_mstar'] for r in rows],
            [abs(r['dist_to_mstar']) for r in rows],
            [r['dist_to_mstar']**2 for r in rows],
        ])
    elif basis_name == 'H_jet':
        X = np.column_stack([
            [r['eps_mid'] for r in rows],
            [r['width_x'] * r['eps_prime_mid'] for r in rows],
            [r['width_x']**2 * r['eps_pp_mid'] for r in rows],
        ])
    elif basis_name == 'H_moment':
        X = np.column_stack([
            [r['mean_cell_eps'] for r in rows],
            [r['cell_moment1'] for r in rows],
            [r['cell_moment2'] for r in rows],
        ])
    elif basis_name == 'H_balance':
        X = np.column_stack([
            [r['eps_a'] for r in rows],
            [r['eps_b'] for r in rows],
            [r['eps_a'] - r['eps_b'] for r in rows],
            [float(r['contains_mstar']) for r in rows],
            [r['dist_to_mstar'] for r in rows],
        ])
    elif basis_name == 'H_jet_mc':
        X = np.column_stack([
            [r['mean_cell_eps'] for r in rows],
            [r['width_x'] * r['eps_prime_mid'] for r in rows],
            [r['width_x']**2 * r['eps_pp_mid'] for r in rows],
        ])
    else:
        raise ValueError("Unknown basis: %s" % basis_name)

    # Add intercept column
    X = np.column_stack([np.ones(n), X])
    return X


BASIS_NAMES = ['H_width', 'H_value', 'H_peak', 'H_jet',
               'H_moment', 'H_balance', 'H_jet_mc']


# ── Fitting and scoring ─────────────────────────────────────────────

def fit_and_score(train_rows, test_rows, basis_name):
    """Fit on train, score on both train and test."""
    X_train = build_design_matrix(train_rows, basis_name)
    y_train = np.array([r['g'] for r in train_rows])

    coeffs, _, _, _ = lstsq(X_train, y_train, rcond=None)

    y_pred_train = X_train @ coeffs
    resid_train = y_train - y_pred_train

    result = {
        'basis': basis_name,
        'n_train': len(train_rows),
        'n_test': len(test_rows),
        'n_features': X_train.shape[1] - 1,
    }

    # Train metrics
    norm_y = np.linalg.norm(y_train)
    if norm_y > 1e-15:
        result['train_nrmse'] = float(np.linalg.norm(resid_train) / norm_y)
        std_y = np.std(y_train)
        std_p = np.std(y_pred_train)
        if std_y > 1e-15 and std_p > 1e-15:
            result['train_corr'] = float(np.corrcoef(y_train, y_pred_train)[0, 1])
        else:
            result['train_corr'] = float('nan')
    else:
        result['train_nrmse'] = float('nan')
        result['train_corr'] = float('nan')

    # Test metrics
    if test_rows:
        X_test = build_design_matrix(test_rows, basis_name)
        y_test = np.array([r['g'] for r in test_rows])
        y_pred_test = X_test @ coeffs
        resid_test = y_test - y_pred_test

        norm_yt = np.linalg.norm(y_test)
        if norm_yt > 1e-15:
            result['test_nrmse'] = float(np.linalg.norm(resid_test) / norm_yt)
            std_yt = np.std(y_test)
            std_pt = np.std(y_pred_test)
            if std_yt > 1e-15 and std_pt > 1e-15:
                result['test_corr'] = float(np.corrcoef(y_test, y_pred_test)[0, 1])
            else:
                result['test_corr'] = float('nan')
        else:
            result['test_nrmse'] = float('nan')
            result['test_corr'] = float('nan')
    else:
        result['test_nrmse'] = float('nan')
        result['test_corr'] = float('nan')

    result['coeffs'] = coeffs.tolist()
    return result


def depth_stratified_score(all_rows, basis_name, train_kinds, train_depths):
    """Score separately for d<=5 and d>=6."""
    train = [r for r in all_rows
             if r['kind'] in train_kinds and r['depth'] in train_depths]
    if not train:
        return {}

    X_train = build_design_matrix(train, basis_name)
    y_train = np.array([r['g'] for r in train])
    coeffs, _, _, _ = lstsq(X_train, y_train, rcond=None)

    results = {}
    for label, depth_set in [('d4_5', [4, 5]), ('d6_plus', [6, 7, 8])]:
        subset = [r for r in all_rows if r['depth'] in depth_set]
        if not subset:
            continue
        X = build_design_matrix(subset, basis_name)
        y = np.array([r['g'] for r in subset])
        y_pred = X @ coeffs
        resid = y - y_pred
        norm_y = np.linalg.norm(y)
        if norm_y > 1e-15:
            results['%s_nrmse' % label] = float(np.linalg.norm(resid) / norm_y)
            if np.std(y) > 1e-15 and np.std(y_pred) > 1e-15:
                results['%s_corr' % label] = float(np.corrcoef(y, y_pred)[0, 1])
            else:
                results['%s_corr' % label] = float('nan')
        else:
            results['%s_nrmse' % label] = float('nan')
            results['%s_corr' % label] = float('nan')

    return results


# ── Main ─────────────────────────────────────────────────────────────

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

print()
print("=" * 72)
print("Basis identification: %d kinds x %d depths = %d cases"
      % (len(ALL_KINDS), len(DEPTHS), len(ALL_KINDS) * len(DEPTHS)))
print("=" * 72)
print()

# Build observable table
print("Building observable table...")
sys.stdout.flush()
all_rows = []
for kind in ALL_KINDS:
    for depth in DEPTHS:
        rows = build_observables(kind, depth)
        all_rows.extend(rows)
        print("  %18s d=%d: %d cells" %
              (kind.replace('_x', ''), depth, len(rows)))

# Add affine-detrended geometric diagnostic
for depth in DEPTHS:
    aff_rows = add_affine_detrended(all_rows, 'geometric_x', depth)
    all_rows.extend(aff_rows)
    if aff_rows:
        print("  %18s d=%d: %d cells (diagnostic)" %
              ('geo_affdetrend', depth, len(aff_rows)))

sys.stdout.flush()

# Write observable table
obs_path = os.path.join(OUT_DIR, 'basis_observables.csv')
obs_cols = ['kind', 'depth', 'cell_index', 'half', 'm_mid',
            'width_x', 'width_log', 'c_star', 'g',
            'eps_mid', 'eps_prime_mid', 'eps_pp_mid',
            'mean_cell_eps', 'cell_moment1', 'cell_moment2',
            'eps_a', 'eps_b', 'contains_mstar', 'dist_to_mstar']
with open(obs_path, 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=obs_cols, extrasaction='ignore')
    w.writeheader()
    for r in all_rows:
        w.writerow(r)
print()
print("  -> %s (%d rows)" % (obs_path, len(all_rows)))

# ── Partition holdout ────────────────────────────────────────────────

print()
print("Partition holdout (train: baselines d=5,6,7; test: adversaries)")
print("-" * 72)

train_rows = [r for r in all_rows
              if r['kind'] in TRAIN_KINDS
              and r['depth'] in TRAIN_DEPTHS]
test_adv = [r for r in all_rows
            if r['kind'] in ADVERSARY_KINDS]

part_results = []
for basis in BASIS_NAMES:
    result = fit_and_score(train_rows, test_adv, basis)
    strat = depth_stratified_score(all_rows, basis, TRAIN_KINDS, TRAIN_DEPTHS)
    result.update(strat)
    part_results.append(result)
    print("  %-12s  train: corr=%.4f nrmse=%.4f  test: corr=%.4f nrmse=%.4f  d6+: nrmse=%.4f"
          % (basis, result['train_corr'], result['train_nrmse'],
             result['test_corr'], result['test_nrmse'],
             result.get('d6_plus_nrmse', float('nan'))))

# ── Depth holdout ────────────────────────────────────────────────────

print()
print("Depth holdout (train: baselines d=5,6; test: baselines d=7,8)")
print("-" * 72)

train_depth = [r for r in all_rows
               if r['kind'] in TRAIN_KINDS
               and r['depth'] in DEPTH_TRAIN]
test_depth = [r for r in all_rows
              if r['kind'] in TRAIN_KINDS
              and r['depth'] in DEPTH_TEST]

depth_results = []
for basis in BASIS_NAMES:
    result = fit_and_score(train_depth, test_depth, basis)
    depth_results.append(result)
    print("  %-12s  train: corr=%.4f nrmse=%.4f  test: corr=%.4f nrmse=%.4f"
          % (basis, result['train_corr'], result['train_nrmse'],
             result['test_corr'], result['test_nrmse']))

# ── Affine-detrended geometric diagnostic ────────────────────────────

print()
print("Affine-detrended geometric diagnostic")
print("-" * 72)

geo_aff = [r for r in all_rows if r['kind'] == 'geometric_x_affdetrend']
if geo_aff:
    geo_train = [r for r in geo_aff if r['depth'] in TRAIN_DEPTHS]
    geo_test = [r for r in geo_aff if r['depth'] in DEPTH_TEST]
    for basis in BASIS_NAMES:
        result = fit_and_score(geo_train, geo_test, basis)
        print("  %-12s  train: corr=%.4f nrmse=%.4f  test: corr=%.4f nrmse=%.4f"
              % (basis, result['train_corr'], result['train_nrmse'],
                 result['test_corr'], result['test_nrmse']))

# ── Write summary CSV ────────────────────────────────────────────────

summary_path = os.path.join(OUT_DIR, 'basis_fit_summary.csv')
summary_cols = ['holdout_type', 'basis', 'n_features', 'n_train', 'n_test',
                'train_corr', 'train_nrmse', 'test_corr', 'test_nrmse',
                'd4_5_nrmse', 'd4_5_corr', 'd6_plus_nrmse', 'd6_plus_corr']
with open(summary_path, 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=summary_cols, extrasaction='ignore')
    w.writeheader()
    for r in part_results:
        row = dict(r)
        row['holdout_type'] = 'partition'
        w.writerow(row)
    for r in depth_results:
        row = dict(r)
        row['holdout_type'] = 'depth'
        w.writerow(row)
print()
print("  -> %s" % summary_path)

# ── Ranking ──────────────────────────────────────────────────────────

print()
print("=" * 72)
print("RANKING (by held-out NRMSE at d6+, partition holdout)")
print("-" * 72)

ranked = sorted(part_results,
                key=lambda r: r.get('d6_plus_nrmse', float('inf')))
for i, r in enumerate(ranked):
    print("  %d. %-12s  d6+ nrmse=%.4f  test_corr=%.4f  test_nrmse=%.4f"
          % (i + 1, r['basis'],
             r.get('d6_plus_nrmse', float('nan')),
             r['test_corr'], r['test_nrmse']))

print()
print("=" * 72)
print("Done. Output: %s" % OUT_DIR)
