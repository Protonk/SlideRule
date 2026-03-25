"""
adversary_sweep.sage — Adversary partition sweep for the Test of Charybdis.

Runs the rotation check on 6 adversary partitions × depths 7,8 × q=3 × LI.
12 configurations, 300 draws each.

Also extracts baseline rows from the main sweep CSV for comparison.

Output: experiments/aft/rotation/results/adversary_sweep.csv

Run:  ./sagew experiments/aft/rotation/adversary_sweep.sage
"""

import csv
import os
import sys
import time

_CHARYBDIS_NO_SELFTEST = True
_SWEEP_NO_RUN = True

from helpers import pathing
load(pathing('experiments', 'aft', 'rotation', 'charybdis_check.sage'))
load(pathing('experiments', 'aft', 'rotation', 'charybdis_sweep.sage'))

import numpy as np


# ── Configuration ─────────────────────────────────────────────────────

N_DRAWS = 300
RNG_SEED = 2026
XI_TIE_SEED = 7777

DEPTHS = [7, 8]
Q_VAL = 3
LAYER_DEPENDENT = False  # LI only

ADVERSARY_KINDS = [
    'farey_rank_x',
    'bitrev_geometric_x',
    'stern_brocot_x',
    'scramble_x',       # default = peak_swap
    'random_x',
    'cantor_x',
]

RESULTS_DIR = pathing('experiments', 'aft', 'rotation', 'results')
MAIN_SWEEP_CSV = os.path.join(RESULTS_DIR, 'charybdis_sweep.csv')


# ── Baseline extraction ──────────────────────────────────────────────

def extract_baselines():
    """Pull d=7,8 q=3 LI rows from the main sweep CSV."""
    baselines = []
    with open(MAIN_SWEEP_CSV) as f:
        for row in csv.DictReader(f):
            if (int(row['depth']) in DEPTHS
                    and int(row['q']) == Q_VAL
                    and row['layer_mode'] == 'LI'):
                baselines.append(row)
    return baselines


# ── Reporting (extends charybdis_sweep's reporter) ────────────────────

def adversary_report(cfg, ensemble_result, depth):
    """Build report dict with saturation-resistant wall metric."""
    report = charybdis_report(cfg, ensemble_result, depth)

    # Saturation-resistant metrics
    e_walls = ensemble_result["ensemble_walls"]
    wall_fsm = ensemble_result["fsm_stats"]["wall"]
    median_wall = float(np.median(e_walls))
    min_wall = float(np.min(e_walls))

    report["wall_ratio"] = wall_fsm / median_wall if median_wall > 0 else float('nan')
    report["wall_gap_to_min"] = wall_fsm - min_wall

    return report


def build_adversary_columns(max_depth):
    """Column list for adversary CSV."""
    cols = build_csv_columns(max_depth)
    cols.append("wall_ratio")
    cols.append("wall_gap_to_min")
    return cols


# ── Main ──────────────────────────────────────────────────────────────

print("=" * 70)
print("Adversary sweep — Test of Charybdis")
print(f"q={Q_VAL}  LI  n_draws={N_DRAWS}  "
      f"rng_seed={RNG_SEED}  xi_tie_seed={XI_TIE_SEED}")
print("=" * 70)

# Print baselines first
print()
print("Baseline rows from main sweep (d=7,8 q=3 LI):")
print(f"  {'kind':>22}  {'d':>2}  {'wall_fsm':>10}  {'wall_z':>9}  "
      f"{'xi_fsm':>8}  {'xi_z':>9}")
print("  " + "-" * 65)
baselines = extract_baselines()
for b in baselines:
    print(f"  {b['kind']:>22}  {b['depth']:>2}  "
          f"{float(b['wall_fsm']):>10.6f}  {float(b['wall_zscore']):>9.1f}  "
          f"{float(b['xi_fsm']):>8.4f}  {float(b['xi_zscore']):>9.2f}")
print()

# Build config list
configs = [
    (depth, kind)
    for depth in DEPTHS
    for kind in ADVERSARY_KINDS
]
n_configs = len(configs)
print(f"{n_configs} adversary configurations")
print()

max_depth = max(DEPTHS)
columns = build_adversary_columns(max_depth)
csv_path = os.path.join(RESULTS_DIR, 'adversary_sweep.csv')

rows = []
t_total = time.time()

for ci, (depth, kind) in enumerate(configs):
    label = f"[{ci+1}/{n_configs}] d={depth} q={Q_VAL} {kind} LI"
    t0 = time.time()

    try:
        cfg = extract_charybdis_config(Q_VAL, int(depth), kind,
                                        LAYER_DEPENDENT)
        result = charybdis_ensemble(
            cfg["delta_star"], cfg["Q_fsm"], cfg["eps_vec"],
            cfg["p"], n_draws=int(N_DRAWS), seed=int(RNG_SEED),
            xi_tie_seed=int(XI_TIE_SEED))
        report = adversary_report(cfg, result, depth)

        # Pad Walsh columns for d < max_depth
        for k in range(depth + 1, max_depth + 1):
            for prefix in ['W', 'P']:
                report[f"{prefix}{k}_raw" if prefix == 'W' else f"{prefix}{k}_norm"] = ""
                report[f"{prefix}{k}_quantile"] = ""
            report[f"W{k}_raw"] = ""
            report[f"P{k}_norm"] = ""
            report[f"W{k}_quantile"] = ""
            report[f"P{k}_quantile"] = ""

        rows.append(report)
        elapsed = time.time() - t0
        print(f"    wall_ratio={report['wall_ratio']:.4f}  "
              f"gap_to_min={report['wall_gap_to_min']:.6f}")
        print(f"    ({elapsed:.1f}s)")
        print()

    except Exception as e:
        print(f"  FAILED: {label}  {e}")
        import traceback
        traceback.print_exc()
        print()

# Write CSV
with open(csv_path, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=columns)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)

total_elapsed = time.time() - t_total
print("=" * 70)
print(f"Done. {len(rows)}/{n_configs} configurations completed "
      f"in {total_elapsed:.0f}s")
print(f"Output: {csv_path}")

total_fallbacks = sum(r.get("n_fallbacks_ensemble", 0) for r in rows)
fsm_fallbacks = sum(r.get("n_fallbacks_fsm", 0) for r in rows)
if total_fallbacks > 0 or fsm_fallbacks > 0:
    print(f"Fallbacks: {fsm_fallbacks} FSM, "
          f"{total_fallbacks} ensemble draws")

# Print comparison table
print()
print("=" * 70)
print("Comparison: adversary vs baseline")
print("=" * 70)
print()
print(f"  {'kind':>22}  {'d':>2}  {'wall_z':>9}  {'xi_z':>9}  "
      f"{'wall_ratio':>10}  {'gap_to_min':>10}")
print("  " + "-" * 70)
print("  --- baselines ---")
for b in baselines:
    print(f"  {b['kind']:>22}  {b['depth']:>2}  "
          f"{float(b['wall_zscore']):>9.1f}  "
          f"{float(b['xi_zscore']):>9.2f}  "
          f"{'n/a':>10}  {'n/a':>10}")
print("  --- adversaries ---")
for r in rows:
    print(f"  {r['kind']:>22}  {r['depth']:>2}  "
          f"{float(r['wall_zscore']):>9.1f}  "
          f"{float(r['xi_zscore']):>9.2f}  "
          f"{float(r['wall_ratio']):>10.4f}  "
          f"{float(r['wall_gap_to_min']):>10.6f}")
