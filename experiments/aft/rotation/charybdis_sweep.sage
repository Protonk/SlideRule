"""
charybdis_sweep.sage — Ensemble sweep for the Test of Charybdis.

Runs the rotation check across 72 configurations:
  depths 5, 6, 7, 8  ×  q 2, 3, 4  ×  3 partition kinds  ×  LI/LD

For each configuration:
  1. Extract (delta_star, Q_fsm, p, eps_vec) via charybdis_check
  2. Generate jittered ε once per configuration
  3. Compute FSM statistics
  4. Compute statistics for n_draws random subspaces (same jittered ε)
  5. Report quantiles and z-scores

Output: experiments/aft/rotation/results/charybdis_sweep.csv

Run:  ./sagew experiments/aft/rotation/charybdis_sweep.sage
"""

import csv
import os
import sys
import time

_CHARYBDIS_NO_SELFTEST = True

from helpers import pathing
load(pathing('experiments', 'aft', 'rotation', 'charybdis_check.sage'))

import numpy as np


# ── Configuration ─────────────────────────────────────────────────────

N_DRAWS = 300
RNG_SEED = 2026
XI_TIE_SEED = 7777

DEPTHS = [5, 6, 7, 8]
QS = [2, 3, 4]
KINDS = ['geometric_x', 'uniform_x', 'harmonic_x']
LAYER_MODES = [False, True]  # False=LI, True=LD

RESULTS_DIR = pathing('experiments', 'aft', 'rotation', 'results')


# ── Ensemble driver ───────────────────────────────────────────────────

def charybdis_ensemble(delta_star, Q_fsm, eps_vec, p,
                       n_draws=N_DRAWS, seed=RNG_SEED,
                       xi_tie_seed=XI_TIE_SEED):
    """
    Run the rotation check ensemble for one configuration.

    Parameters
    ----------
    delta_star  : ndarray (n,)
    Q_fsm       : ndarray (n, p)
    eps_vec     : ndarray (n,) — raw ε(m_mid)
    p           : int — subspace dimension
    n_draws     : int — number of random subspaces
    seed        : int — RNG seed for random subspaces
    xi_tie_seed : int — RNG seed for ε jitter

    Returns
    -------
    dict with keys:
        fsm_stats      : dict from charybdis_stats
        ensemble_walls : ndarray (n_draws,)
        ensemble_xis   : ndarray (n_draws,)
        ensemble_W_raw : ndarray (n_draws, d+1)
        ensemble_P_norm: ndarray (n_draws, d+1)
        n_fallbacks    : int — number of draws that used LP fallback
        eps_jittered   : ndarray (n,)
    """
    n = len(delta_star)
    depth = int(np.log2(n))

    # 1. Generate jittered ε once
    jitter_rng = np.random.default_rng(int(xi_tie_seed))
    eps_max = float(np.max(eps_vec))
    jitter = jitter_rng.uniform(-1e-12 * eps_max, 1e-12 * eps_max, size=n)
    eps_jittered = eps_vec + jitter

    # 2. FSM statistics
    fsm_stats = charybdis_stats(delta_star, Q_fsm, eps_jittered)

    # 3. Random subspace ensemble
    draw_rng = np.random.default_rng(int(seed))
    ensemble_walls = np.zeros(n_draws)
    ensemble_xis = np.zeros(n_draws)
    ensemble_W_raw = np.zeros((n_draws, depth + 1))
    ensemble_P_norm = np.zeros((n_draws, depth + 1))
    n_fallbacks = 0

    for i in range(n_draws):
        Q_rand = random_subspace(int(n), int(p), draw_rng)
        stats_i = charybdis_stats(delta_star, Q_rand, eps_jittered)
        ensemble_walls[i] = stats_i["wall"]
        ensemble_xis[i] = stats_i["xi"]
        ensemble_W_raw[i] = stats_i["W_raw"]
        ensemble_P_norm[i] = stats_i["P_norm"]
        if stats_i["used_fallback"]:
            n_fallbacks += 1

    return {
        "fsm_stats": fsm_stats,
        "ensemble_walls": ensemble_walls,
        "ensemble_xis": ensemble_xis,
        "ensemble_W_raw": ensemble_W_raw,
        "ensemble_P_norm": ensemble_P_norm,
        "n_fallbacks": n_fallbacks,
        "eps_jittered": eps_jittered,
    }


# ── Reporting ─────────────────────────────────────────────────────────

def _quantile(value, ensemble):
    """Fraction of ensemble values <= value."""
    return float(np.mean(ensemble <= value))


def _zscore(value, ensemble):
    """Z-score of value relative to ensemble. NaN if std = 0."""
    std = float(np.std(ensemble))
    if std == 0:
        return float('nan')
    return float((value - np.mean(ensemble)) / std)


def charybdis_report(cfg, ensemble_result, depth):
    """
    Build a report dict and print summary for one configuration.

    Returns a flat dict suitable for CSV output.
    """
    fsm = ensemble_result["fsm_stats"]
    e_walls = ensemble_result["ensemble_walls"]
    e_xis = ensemble_result["ensemble_xis"]
    e_W = ensemble_result["ensemble_W_raw"]
    e_P = ensemble_result["ensemble_P_norm"]

    report = {
        "depth": cfg["depth"],
        "q": cfg["q"],
        "kind": cfg["partition_kind"],
        "layer_mode": "LD" if cfg["layer_dependent"] else "LI",
        "rank_tol": cfg["rank_tol"],
        "p": cfg["p"],
        "rng_seed": RNG_SEED,
        "xi_tie_policy": "jitter_1e-12",
        "xi_tie_seed": XI_TIE_SEED,
        "n_draws": N_DRAWS,
        "n_fallbacks_fsm": 1 if fsm["used_fallback"] else 0,
        "n_fallbacks_ensemble": ensemble_result["n_fallbacks"],
        "wall_fsm": fsm["wall"],
        "wall_quantile": _quantile(fsm["wall"], e_walls),
        "wall_zscore": _zscore(fsm["wall"], e_walls),
        "xi_fsm": fsm["xi"],
        "xi_quantile": _quantile(fsm["xi"], e_xis),
        "xi_zscore": _zscore(fsm["xi"], e_xis),
    }

    # Walsh raw and normalized, per level
    for k in range(depth + 1):
        report[f"W{k}_raw"] = fsm["W_raw"][k]
        report[f"P{k}_norm"] = fsm["P_norm"][k]
    for k in range(depth + 1):
        report[f"W{k}_quantile"] = _quantile(fsm["W_raw"][k], e_W[:, k])
        report[f"P{k}_quantile"] = _quantile(fsm["P_norm"][k], e_P[:, k])

    # Print summary
    label = (f"d={cfg['depth']} q={cfg['q']} {cfg['partition_kind']} "
             f"{'LD' if cfg['layer_dependent'] else 'LI'}")
    print(f"  {label}  p={cfg['p']}")
    print(f"    wall={fsm['wall']:.6f}  q={report['wall_quantile']:.3f}  "
          f"z={report['wall_zscore']:.2f}")
    print(f"    xi={fsm['xi']:.4f}  q={report['xi_quantile']:.3f}  "
          f"z={report['xi_zscore']:.2f}")
    P_str = " ".join(f"{fsm['P_norm'][k]:.3f}" for k in range(depth + 1))
    print(f"    P_norm=[{P_str}]")
    if ensemble_result["n_fallbacks"] > 0:
        print(f"    *** {ensemble_result['n_fallbacks']} fallbacks ***")

    return report


def build_csv_columns(max_depth):
    """Build the ordered column list for the CSV."""
    cols = [
        "depth", "q", "kind", "layer_mode",
        "rank_tol", "p", "rng_seed", "xi_tie_policy", "xi_tie_seed",
        "n_draws", "n_fallbacks_fsm", "n_fallbacks_ensemble",
        "wall_fsm", "wall_quantile", "wall_zscore",
        "xi_fsm", "xi_quantile", "xi_zscore",
    ]
    for k in range(max_depth + 1):
        cols.append(f"W{k}_raw")
    for k in range(max_depth + 1):
        cols.append(f"P{k}_norm")
    for k in range(max_depth + 1):
        cols.append(f"W{k}_quantile")
    for k in range(max_depth + 1):
        cols.append(f"P{k}_quantile")
    return cols


# ── Main sweep ────────────────────────────────────────────────────────

if not globals().get('_SWEEP_NO_RUN', False):

    print("=" * 70)
    print("Charybdis sweep — Test of Charybdis rotation check")
    print(f"n_draws={N_DRAWS}  rng_seed={RNG_SEED}  "
          f"xi_tie_seed={XI_TIE_SEED}")
    print("=" * 70)

    max_depth = max(DEPTHS)
    columns = build_csv_columns(max_depth)
    csv_path = os.path.join(RESULTS_DIR, 'charybdis_sweep.csv')

    configs = [
        (depth, q, kind, ld)
        for depth in DEPTHS
        for q in QS
        for kind in KINDS
        for ld in LAYER_MODES
    ]
    n_configs = len(configs)
    print(f"{n_configs} configurations\n")

    rows = []
    t_total = time.time()

    for ci, (depth, q, kind, ld) in enumerate(configs):
        label = (f"[{ci+1}/{n_configs}] d={depth} q={q} {kind} "
                 f"{'LD' if ld else 'LI'}")
        t0 = time.time()

        try:
            cfg = extract_charybdis_config(q, depth, kind, ld)
            result = charybdis_ensemble(
                cfg["delta_star"], cfg["Q_fsm"], cfg["eps_vec"],
                cfg["p"], n_draws=N_DRAWS, seed=RNG_SEED,
                xi_tie_seed=XI_TIE_SEED)
            report = charybdis_report(cfg, result, depth)

            # Pad Walsh columns for depths < max_depth
            for k in range(depth + 1, max_depth + 1):
                report[f"W{k}_raw"] = ""
                report[f"P{k}_norm"] = ""
                report[f"W{k}_quantile"] = ""
                report[f"P{k}_quantile"] = ""

            rows.append(report)
            elapsed = time.time() - t0
            print(f"    ({elapsed:.1f}s)\n")

        except Exception as e:
            print(f"  FAILED: {label}  {e}\n")
            import traceback
            traceback.print_exc()

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
