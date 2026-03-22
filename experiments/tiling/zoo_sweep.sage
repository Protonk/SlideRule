"""
zoo_sweep.sage — Zoo-wide geometry-only observable pipeline.

Computes the displacement-field diagnostic bundle for every executable
case in the partition zoo, including scramble modes.

Run:  ./sagew experiments/tiling/zoo_sweep.sage
"""

import csv
import os
import sys
import time

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))
load(pathing('lib', 'policies.sage'))
load(pathing('lib', 'optimize.sage'))
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import numpy as np


# ── Configuration ────────────────────────────────────────────────────

P_NUM, Q_DEN = 1, 2
DEPTHS = [5, 6, 7, 8]
OUT_DIR = pathing('experiments', 'tiling', 'results', 'zoo')


# ── Observable computation ───────────────────────────────────────────

def compute_case_observables(case, depth):
    """Compute the full diagnostic bundle for one case at one depth."""
    t0 = time.time()

    # Build partition
    partition = build_partition(depth, kind=case['kind'], **case['kwargs'])
    N = len(partition)

    # Free intercepts
    free = free_intercepts_from_partition(partition, P_NUM, Q_DEN)
    c_star = np.array(free['c_star'])

    # Leading-bit projection
    left = leading_bit_halves(partition)
    g_inf = R0(c_star, left, 'inf')
    g_l2 = R0(c_star, left, 'l2')

    # Displacement field
    dL = delta_L_field(partition)
    r0_dL_inf = R0(dL, left, 'inf')
    r0_dL_l2 = R0(dL, left, 'l2')

    # Stage A metrics
    def safe_corr(a, b):
        if np.std(a) < 1e-15 or np.std(b) < 1e-15:
            return float('nan')
        return float(np.corrcoef(a, b)[0, 1])

    corr_inf = safe_corr(g_inf, r0_dL_inf)
    corr_l2 = safe_corr(g_l2, r0_dL_l2)
    nrmse_inf = nrmse(g_inf, r0_dL_inf)
    nrmse_l2 = nrmse(g_l2, r0_dL_l2)
    residual_norm_inf = float(np.max(np.abs(g_inf)))
    residual_norm_2 = float(np.linalg.norm(g_inf))

    # Coupling diagnostics
    widths = np.array([float(partition[j]['x_hi'] - partition[j]['x_lo'])
                       for j in range(N)])
    m_mids = np.array([float((partition[j]['x_lo'] + partition[j]['x_hi']) / 2) - 1.0
                        for j in range(N)])
    peak_dists = np.array([-abs(m - MSTAR) for m in m_mids])

    if np.std(widths) > 1e-15 and np.std(peak_dists) > 1e-15:
        rho_peak = float(np.corrcoef(widths, peak_dists)[0, 1])
    else:
        rho_peak = float('nan')

    eps_at_mids = np.array([eps_val(m) for m in m_mids])
    eps_sum = np.sum(eps_at_mids)
    if eps_sum > 1e-15:
        mean_width_eps = float(np.sum(widths * eps_at_mids) / eps_sum)
    else:
        mean_width_eps = float('nan')

    # Per-cell rows
    cell_rows = []
    for j in range(N):
        a_m = float(partition[j]['x_lo']) - 1.0
        b_m = float(partition[j]['x_hi']) - 1.0
        m_mid = m_mids[j]

        cell_rows.append({
            'case_id': case['case_id'],
            'depth': depth,
            'cell_index': j,
            'half': 'L' if left[j] else 'R',
            'm_mid': m_mid,
            'width_x': float(widths[j]),
            'width_log': float(np.log(float(partition[j]['x_hi']))
                               - np.log(float(partition[j]['x_lo']))),
            'c_star': float(c_star[j]),
            'g_inf': float(g_inf[j]),
            'delta_L': float(dL[j]),
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

    elapsed = time.time() - t0

    # Case-level metrics
    case_metrics = {
        'case_id': case['case_id'],
        'kind': case['kind'],
        'scramble_mode': case['scramble_mode'],
        'depth': depth,
        'n_cells': N,
        'corr_inf': corr_inf,
        'corr_l2': corr_l2,
        'nrmse_inf': nrmse_inf,
        'nrmse_l2': nrmse_l2,
        'residual_norm_inf': residual_norm_inf,
        'residual_norm_2': residual_norm_2,
        'rho_peak': rho_peak,
        'mean_width_eps': mean_width_eps,
        'worst_abs': free['worst_abs'],
        'time': elapsed,
    }

    return cell_rows, case_metrics


# ── CSV helpers ──────────────────────────────────────────────────────

OBS_COLUMNS = [
    'case_id', 'depth', 'cell_index', 'half', 'm_mid',
    'width_x', 'width_log', 'c_star', 'g_inf', 'delta_L',
    'eps_mid', 'eps_prime_mid', 'eps_pp_mid',
    'mean_cell_eps', 'cell_moment1', 'cell_moment2',
    'eps_a', 'eps_b', 'contains_mstar', 'dist_to_mstar',
]

METRICS_COLUMNS = [
    'case_id', 'kind', 'scramble_mode', 'depth', 'n_cells',
    'corr_inf', 'corr_l2', 'nrmse_inf', 'nrmse_l2',
    'residual_norm_inf', 'residual_norm_2',
    'rho_peak', 'mean_width_eps', 'worst_abs', 'time',
]


def append_csv(filepath, columns, rows):
    write_header = not os.path.exists(filepath) or os.path.getsize(filepath) == 0
    with open(filepath, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns, extrasaction='ignore')
        if write_header:
            writer.writeheader()
        for r in rows:
            writer.writerow(r)


# ── Main ─────────────────────────────────────────────────────────────

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

obs_path = os.path.join(OUT_DIR, 'zoo_observables.csv')
metrics_path = os.path.join(OUT_DIR, 'zoo_case_metrics.csv')

# Clear previous output
for p in [obs_path, metrics_path]:
    if os.path.exists(p):
        os.remove(p)

cases = build_case_table()
total = len(cases) * len(DEPTHS)

# ── Step 5: emit metadata ────────────────────────────────────────────

META_COLUMNS = [
    'case_id', 'kind', 'scramble_mode', 'source_kind',
    'display_name', 'color', 'category', 'group',
    'density', 'symmetry', 'arithmetic', 'curve_aware',
]
meta_path = os.path.join(OUT_DIR, 'zoo_metadata.csv')
with open(meta_path, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=META_COLUMNS, extrasaction='ignore')
    writer.writeheader()
    for c in cases:
        writer.writerow(c)
print("  -> %s (%d cases)" % (meta_path, len(cases)))

print()
print("=" * 76)
print("Zoo sweep: %d cases x %d depths = %d case-depth pairs"
      % (len(cases), len(DEPTHS), total))
print("  output: %s" % OUT_DIR)
print("=" * 76)
print()
print("  %3s  %-28s  %3s  %7s  %7s  %7s  %6s" %
      ('#', 'case_id', 'd', 'corr', 'nrmse', 'rho_pk', 'time'))
print("  " + "-" * 72)
sys.stdout.flush()

done = 0
for case in cases:
    for depth in DEPTHS:
        cell_rows, case_metrics = compute_case_observables(case, depth)

        append_csv(obs_path, OBS_COLUMNS, cell_rows)
        append_csv(metrics_path, METRICS_COLUMNS, [case_metrics])

        done += 1
        print("  %3d  %-28s  %3d  %7.4f  %7.4f  %+7.4f  %5.1fs"
              % (done, case['case_id'][:28], depth,
                 case_metrics['corr_inf'],
                 case_metrics['nrmse_inf'],
                 case_metrics['rho_peak'],
                 case_metrics['time']))
        sys.stdout.flush()

# ── Step 6: scramble validation ───────────────────────────────────────

validation_path = os.path.join(OUT_DIR, 'scramble_validation.csv')
VAL_COLUMNS = ['scramble_mode', 'depth', 'width_max_diff',
               'boundaries_ok', 'endpoint_lo_ok', 'endpoint_hi_ok',
               'rho_peak', 'pass']

val_rows = []
for mode in ['peak_swap', 'peak_avoid']:
    for depth in DEPTHS:
        geo = build_partition(depth, kind='geometric_x')
        scr = build_partition(depth, kind='scramble_x', scramble_mode=mode)
        N = len(scr)

        geo_widths = sorted([float(geo[j]['x_hi'] - geo[j]['x_lo'])
                             for j in range(N)])
        scr_widths = sorted([float(scr[j]['x_hi'] - scr[j]['x_lo'])
                             for j in range(N)])
        width_max_diff = max(abs(a - b) for a, b in zip(geo_widths, scr_widths))

        boundaries_ok = all(
            float(scr[j]['x_hi']) <= float(scr[j+1]['x_lo']) + 1e-14
            and float(scr[j]['x_hi']) < float(scr[j+1]['x_hi'])
            for j in range(N - 1))
        endpoint_lo_ok = abs(float(scr[0]['x_lo']) - 1.0) < 1e-14
        endpoint_hi_ok = abs(float(scr[-1]['x_hi']) - 2.0) < 1e-14

        widths = [float(scr[j]['x_hi'] - scr[j]['x_lo']) for j in range(N)]
        mids = [float((scr[j]['x_lo'] + scr[j]['x_hi']) / 2) - 1.0
                for j in range(N)]
        peak_dists = [-abs(m - MSTAR) for m in mids]
        rho = float(np.corrcoef(widths, peak_dists)[0, 1])

        ok = (width_max_diff < 1e-12 and boundaries_ok
              and endpoint_lo_ok and endpoint_hi_ok)

        val_rows.append({
            'scramble_mode': mode, 'depth': depth,
            'width_max_diff': width_max_diff,
            'boundaries_ok': boundaries_ok,
            'endpoint_lo_ok': endpoint_lo_ok,
            'endpoint_hi_ok': endpoint_hi_ok,
            'rho_peak': rho,
            'pass': ok,
        })

with open(validation_path, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=VAL_COLUMNS)
    writer.writeheader()
    for r in val_rows:
        writer.writerow(r)

all_pass = all(r['pass'] for r in val_rows)
print()
print("Scramble validation: %d/%d pass -> %s"
      % (sum(r['pass'] for r in val_rows), len(val_rows),
         validation_path))
if not all_pass:
    print("  WARNING: some scramble validations failed!")

print()
print("=" * 76)
print("Zoo sweep complete: %d case-depth pairs" % done)
print("  observables: %s" % obs_path)
print("  metrics:     %s" % metrics_path)
print("=" * 76)
