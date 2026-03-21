"""
damage_vs_wall.sage — Compare damage prediction to realized wall excess.

For each cell, computes:
- wall_excess: realized sharing cost (shared_err - free_err)
- best_donor_excess: minimum foreign-intercept excess from any other cell
- value_add: best_donor_excess - wall_excess (positive = optimizer wins)

Outputs per-cell CSV and a ribbon plot showing the three layers.

Run:  ./sagew experiments/wall/damage_vs_wall.sage
"""

import csv
import gc
import os
import sys
import time

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'wall', 'foreign_intercept_matrix.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

CASES = [
    # (kind, q, depth, p_num, q_den, layer_dependent)
    ('geometric_x',  3, 6, 1, 2, False),
    ('geometric_x',  3, 6, 1, 2, True),
    ('uniform_x',    3, 6, 1, 2, False),
    ('uniform_x',    3, 6, 1, 2, True),
]

RUN_TAG = 'exchange_rate'
OUT_DIR = pathing('experiments', 'wall', 'results', RUN_TAG)


# ── Per-case analysis ────────────────────────────────────────────────

def analyze_case(kind, q, depth, p_num, q_den, ld):
    """Run one case through the damage-vs-wall pipeline.

    Returns a list of per-cell dicts with all metrics.
    """
    t0 = time.time()

    # Compute the case (solver run)
    case = compute_case(q, depth, p_num, q_den,
                        partition_kind=kind, layer_dependent=ld)

    partition = case['partition']
    row_map = case['row_map']
    opt_pol = case['opt_pol']
    free_metrics = case['free_metrics']

    # Build the foreign-intercept excess matrix
    F, free_errs, free_intercepts = build_foreign_intercept_matrix(
        partition, free_metrics['rows'], p_num, q_den)

    N = len(partition)

    # Extract shared intercepts and errors per cell
    c0_rat = opt_pol['c0_rat']
    delta_rat = opt_pol['delta_rat']
    opt_metrics = opt_pol['metrics']

    # Build cell data lookup from optimizer output
    opt_cell_data = {}
    for entry in opt_metrics['cell_data']:
        bits = entry[0]
        cell_worst_err = entry[3]
        opt_cell_data[bits] = cell_worst_err

    # Per-cell analysis
    rows = []
    for idx, row in enumerate(partition):
        bits = row['bits']
        prow = row

        c_shared = float(path_intercept(bits, c0_rat, delta_rat, q))
        c_free = float(free_intercepts[idx])
        displacement = c_shared - c_free

        shared_err = opt_cell_data[bits]
        free_err = free_errs[idx]
        wall_excess = shared_err - free_err

        donor_idx, donor_excess = best_donor(F, idx)

        value_add = donor_excess - wall_excess

        rows.append({
            'cell_index': idx,
            'bits': str(bits),
            'x_lo': float(prow['x_lo']),
            'x_hi': float(prow['x_hi']),
            'x_mid': float((prow['x_lo'] + prow['x_hi']) / 2),
            'plog_mid': float((prow['plog_lo'] + prow['plog_hi']) / 2),
            'c_shared': c_shared,
            'c_free': c_free,
            'displacement': displacement,
            'shared_err': shared_err,
            'free_err': free_err,
            'wall_excess': wall_excess,
            'best_donor_index': donor_idx,
            'best_donor_excess': donor_excess,
            'value_add': value_add,
        })

    elapsed = time.time() - t0

    # Release heavy objects
    del case, F
    gc.collect()

    return rows, elapsed


def case_summary(rows):
    """Compute aggregate statistics from per-cell rows."""
    values = [r['value_add'] for r in rows]
    donor_excesses = [r['best_donor_excess'] for r in rows]

    n_positive = sum(1 for v in values if v > 0)
    total_donor = sum(donor_excesses)
    total_value = sum(values)

    return {
        'n_cells': len(rows),
        'mitigation_fraction': n_positive / len(rows) if rows else 0,
        'normalized_total_value': total_value / total_donor if total_donor > 0 else 0,
        'median_value': float(np.median(values)),
        'max_value': max(values),
        'min_value': min(values),
        'worst_cell_wall_excess': max(r['wall_excess'] for r in rows),
    }


# ── CSV output ───────────────────────────────────────────────────────

PERCELL_COLUMNS = [
    'partition_kind', 'q', 'depth', 'exponent', 'layer_dependent',
    'cell_index', 'bits', 'x_lo', 'x_hi', 'x_mid', 'plog_mid',
    'c_shared', 'c_free', 'displacement',
    'shared_err', 'free_err', 'wall_excess',
    'best_donor_index', 'best_donor_excess', 'value_add',
]

SUMMARY_COLUMNS = [
    'partition_kind', 'q', 'depth', 'exponent', 'layer_dependent',
    'n_cells', 'mitigation_fraction', 'normalized_total_value',
    'median_value', 'max_value', 'min_value', 'worst_cell_wall_excess',
    'time',
]


def append_csv(filepath, columns, rows):
    """Append rows to a CSV, writing header if new."""
    write_header = not os.path.exists(filepath) or os.path.getsize(filepath) == 0
    with open(filepath, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns, extrasaction='ignore')
        if write_header:
            writer.writeheader()
        for r in rows:
            writer.writerow(r)


# ── Ribbon plot ──────────────────────────────────────────────────────

def make_ribbon_plot(all_results):
    """Per-cell ribbon: free err, +donor excess, +wall excess, value-add."""
    n_cases = len(all_results)
    fig, axes = plt.subplots(n_cases, 2, figsize=(13, 3.2 * n_cases),
                             constrained_layout=True)
    if n_cases == 1:
        axes = axes.reshape(1, -1)

    for i, (label, rows, stats) in enumerate(all_results):
        xs = [r['x_mid'] for r in rows]
        free = [r['free_err'] for r in rows]
        donor_line = [r['free_err'] + r['best_donor_excess'] for r in rows]
        shared = [r['shared_err'] for r in rows]
        value = [r['value_add'] for r in rows]

        # Left panel: three-layer ribbon
        ax = axes[i, 0]
        ax.plot(xs, free, color='#2ecc71', linewidth=1.2, label='free err')
        ax.plot(xs, donor_line, color='#e67e22', linewidth=1.0,
                linestyle='--', label='free + donor excess')
        ax.plot(xs, shared, color='#e74c3c', linewidth=1.2,
                label='free + wall excess')
        ax.fill_between(xs, free, donor_line, color='#e67e22', alpha=0.12)
        ax.fill_between(xs, donor_line, shared, color='#e74c3c', alpha=0.12,
                        where=[s > d for s, d in zip(shared, donor_line)])
        ax.fill_between(xs, shared, donor_line, color='#2ecc71', alpha=0.12,
                        where=[d > s for s, d in zip(shared, donor_line)])
        ax.set_ylabel('Peak error', fontsize=9)
        ax.legend(fontsize=7, loc='upper right')
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)
        ax.set_title(label, fontsize=9, fontweight='bold')

        # Right panel: value-add per cell
        ax = axes[i, 1]
        colors = ['#2ecc71' if v > 0 else '#e74c3c' for v in value]
        ax.bar(xs, value, width=(xs[1] - xs[0]) * 0.8, color=colors,
               alpha=0.7, edgecolor='none')
        ax.axhline(0, color='#999999', linewidth=0.5)
        ax.set_ylabel('Value-add (donor excess - wall excess)', fontsize=9)
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)

        # Annotate summary
        ax.text(0.02, 0.95,
                'mitigation=%.0f%%  norm_total=%.3f'
                % (stats['mitigation_fraction'] * 100,
                   stats['normalized_total_value']),
                transform=ax.transAxes, fontsize=7, va='top',
                fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                          alpha=0.8))

    for ax in axes[-1, :]:
        ax.set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=9)

    fig.suptitle('Damage vs Wall: optimizer value-add per cell',
                 fontsize=12, fontweight='bold')

    out_path = os.path.join(OUT_DIR, 'damage_vs_wall.png')
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("  Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

summary_path = os.path.join(OUT_DIR, 'summary.csv')
percell_path = os.path.join(OUT_DIR, 'percell.csv')

print()
print("=" * 72)
print("Damage vs Wall analysis: %d cases" % len(CASES))
print("  output: %s" % OUT_DIR)
print("=" * 72)
print()

all_results = []

for kind, q, depth, p_num, q_den, ld in CASES:
    ld_tag = "LD" if ld else "LI"
    exp_str = "%d/%d" % (p_num, q_den)
    label = "%s %s q=%d d=%d exp=%s" % (kind, ld_tag, q, depth, exp_str)
    print("  Running: %s ..." % label)
    sys.stdout.flush()

    rows, elapsed = analyze_case(kind, q, depth, p_num, q_den, ld)
    stats = case_summary(rows)

    # Tag rows with case identifiers
    for r in rows:
        r['partition_kind'] = kind
        r['q'] = q
        r['depth'] = depth
        r['exponent'] = exp_str
        r['layer_dependent'] = ld

    # Write CSVs incrementally
    append_csv(percell_path, PERCELL_COLUMNS, rows)

    summary_row = dict(stats)
    summary_row.update({
        'partition_kind': kind,
        'q': q,
        'depth': depth,
        'exponent': exp_str,
        'layer_dependent': ld,
        'time': elapsed,
    })
    append_csv(summary_path, SUMMARY_COLUMNS, [summary_row])

    print("    mitigation=%.1f%%  norm_total_value=%.4f  (%.1fs)"
          % (stats['mitigation_fraction'] * 100,
             stats['normalized_total_value'], elapsed))

    all_results.append((label, rows, stats))

print()
print("Making ribbon plot...")
make_ribbon_plot(all_results)

print()
print("=" * 72)
print("Done: %d cases" % len(CASES))
print("  summary: %s" % summary_path)
print("  percell: %s" % percell_path)
print("=" * 72)
