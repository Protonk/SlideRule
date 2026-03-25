"""
spectral_sweep.sage — Walsh spectral experiment for the Test of Charybdis.

Computes Walsh spectra for ε, δ*, r_FSM, and ensemble r_rand.
Primary shape statistic: Jensen-Shannon divergence (leave-one-out null).
Secondary: cosine similarity.

Phases:
  A: Main Walsh sweep (d=9, q=2..6, LI, 6 partitions, 500 draws)
  B: Ensemble tightening (d=9, q=2..6, LI, 3 partitions, 1000 draws)
  C: Sharing contrast (d=9, q=3,4, LI+LD, 6 partitions, 500 draws)

Run:  ./sagew experiments/aft/rotation/spectral/spectral_sweep.sage
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


# ── Spectral helpers (Step 1) ─────────────────────────────────────────

JSD_FLOOR = 1e-15


def spectral_summaries(P_norm):
    """Compute centroid, entropy, tail mass from a normalised Walsh profile."""
    d_plus_1 = len(P_norm)
    ks = np.arange(d_plus_1, dtype=np.float64)
    centroid = float(np.dot(ks, P_norm))

    # Entropy: -Σ P^k log₂ P^k  (0 log 0 = 0)
    with np.errstate(divide='ignore', invalid='ignore'):
        logP = np.where(P_norm > 0, np.log2(P_norm), 0.0)
    entropy = float(-np.dot(P_norm, logP))

    tail_mass = float(np.sum(P_norm[4:])) if d_plus_1 > 4 else 0.0

    return centroid, entropy, tail_mass


def _floor_and_normalize(P, floor=JSD_FLOOR):
    """Add floor to zero entries and renormalize."""
    P_floored = np.maximum(P, floor)
    return P_floored / P_floored.sum()


# ── Shape statistics (Step 2) ─────────────────────────────────────────

def _kl_div(p, q):
    """KL(p || q) for positive arrays."""
    return float(np.sum(p * np.log(p / q)))


def jsd(p, q):
    """Jensen-Shannon divergence (base e, symmetric)."""
    p_f = _floor_and_normalize(p)
    q_f = _floor_and_normalize(q)
    m = 0.5 * (p_f + q_f)
    return 0.5 * _kl_div(p_f, m) + 0.5 * _kl_div(q_f, m)


def cosine_sim(a, b):
    """Cosine similarity between two vectors."""
    dot = np.dot(a, b)
    na = np.linalg.norm(a)
    nb = np.linalg.norm(b)
    if na == 0 or nb == 0:
        return 0.0
    return float(dot / (na * nb))


def build_shape_null(P_fsm, ensemble_P, n_draws):
    """
    Compute JSD leave-one-out null and FSM shape distance.

    P_bar = mean of ensemble profiles.
    d_FSM = JSD(P_FSM, P_bar).
    d_i = JSD(P_rand_i, P_bar^{(-i)}).
    """
    P_bar = np.mean(ensemble_P, axis=0)

    d_fsm = jsd(P_fsm, P_bar)

    # Leave-one-out null
    shape_null = np.zeros(n_draws)
    for i in range(n_draws):
        P_bar_loo = (n_draws * P_bar - ensemble_P[i]) / (n_draws - 1)
        shape_null[i] = jsd(ensemble_P[i], P_bar_loo)

    return d_fsm, shape_null, P_bar


# ── Configuration ─────────────────────────────────────────────────────

RNG_SEED = 2026
XI_TIE_SEED = 7777
P_NUM, Q_DEN = 1, 2

RESULTS_DIR = pathing('experiments', 'aft', 'rotation', 'spectral', 'results')

PHASE_A_KINDS = [
    'geometric_x', 'uniform_x', 'harmonic_x',
    'reverse_geometric_x', 'bitrev_geometric_x', 'stern_brocot_x',
]

PHASE_A = [
    (9, q, kind, False, 500)
    for q in [2, 3, 4, 5, 6]
    for kind in PHASE_A_KINDS
]

PHASE_B = [
    (9, q, kind, False, 1000)
    for q in [2, 3, 4, 5, 6]
    for kind in ['geometric_x', 'reverse_geometric_x', 'bitrev_geometric_x']
]

PHASE_C_NEW = [
    (9, q, kind, True, 500)  # LD only; LI already in Phase A
    for q in [3, 4]
    for kind in PHASE_A_KINDS
]


# ── Per-config runner ─────────────────────────────────────────────────

def run_spectral_config(depth, q, kind, layer_dependent, n_draws):
    """Run one spectral configuration. Returns (report_dict, sidecar_dict)."""
    n = 2**depth

    # Extract
    cfg = extract_charybdis_config(q, int(depth), kind, layer_dependent)
    delta_star = cfg["delta_star"]
    Q_fsm = cfg["Q_fsm"]
    eps_vec = cfg["eps_vec"]
    p = cfg["p"]

    # Walsh spectra of ε and δ*
    W_eps, P_eps = walsh_spectrum(eps_vec, int(depth))
    W_dstar, P_dstar = walsh_spectrum(delta_star, int(depth))

    # Jittered ε
    jitter_rng = np.random.default_rng(int(XI_TIE_SEED))
    eps_max = float(np.max(eps_vec))
    jitter = jitter_rng.uniform(-1e-12 * eps_max, 1e-12 * eps_max, size=n)
    eps_jittered = eps_vec + jitter

    # FSM stats
    fsm_stats = charybdis_stats(delta_star, Q_fsm, eps_jittered)
    W_fsm = fsm_stats["W_raw"]
    P_fsm = fsm_stats["P_norm"]

    # Ensemble
    draw_rng = np.random.default_rng(int(RNG_SEED))
    ensemble_P = np.zeros((n_draws, depth + 1))
    ensemble_W = np.zeros((n_draws, depth + 1))
    ensemble_walls = np.zeros(n_draws)
    ensemble_xis = np.zeros(n_draws)
    n_fallbacks = 0

    for i in range(n_draws):
        Q_rand = random_subspace(int(n), int(p), draw_rng)
        stats_i = charybdis_stats(delta_star, Q_rand, eps_jittered)
        ensemble_P[i] = stats_i["P_norm"]
        ensemble_W[i] = stats_i["W_raw"]
        ensemble_walls[i] = stats_i["wall"]
        ensemble_xis[i] = stats_i["xi"]
        if stats_i["used_fallback"]:
            n_fallbacks += 1

    # Shape statistics
    d_fsm_jsd, shape_null, P_bar = build_shape_null(P_fsm, ensemble_P, n_draws)
    cos_fsm = cosine_sim(P_fsm, P_bar)
    cos_null = np.array([cosine_sim(ensemble_P[i],
                          (n_draws * P_bar - ensemble_P[i]) / (n_draws - 1))
                         for i in range(n_draws)])

    # Spectral summaries
    c_fsm, h_fsm, t_fsm = spectral_summaries(P_fsm)
    c_eps, h_eps, t_eps = spectral_summaries(P_eps)
    c_dstar, h_dstar, t_dstar = spectral_summaries(P_dstar)

    # Ensemble summaries
    ens_centroids = np.array([spectral_summaries(ensemble_P[i])[0] for i in range(n_draws)])
    ens_entropies = np.array([spectral_summaries(ensemble_P[i])[1] for i in range(n_draws)])
    ens_tailmass = np.array([spectral_summaries(ensemble_P[i])[2] for i in range(n_draws)])

    # Quantiles and z-scores
    def _q(val, arr):
        return float(np.mean(arr <= val))
    def _z(val, arr):
        s = float(np.std(arr))
        return float((val - np.mean(arr)) / s) if s > 0 else float('nan')

    mode_str = "LD" if layer_dependent else "LI"

    report = {
        "depth": depth, "q": q, "kind": kind, "layer_mode": mode_str,
        "n_draws": n_draws, "rank_tol": cfg["rank_tol"],
        "rng_seed": RNG_SEED, "xi_tie_seed": XI_TIE_SEED,
        "p": p, "jsd_floor": JSD_FLOOR,
        # Wall/xi metadata
        "wall_fsm": fsm_stats["wall"],
        "wall_quantile": _q(fsm_stats["wall"], ensemble_walls),
        "wall_zscore": _z(fsm_stats["wall"], ensemble_walls),
        "xi_fsm": fsm_stats["xi"],
        "xi_quantile": _q(fsm_stats["xi"], ensemble_xis),
        "xi_zscore": _z(fsm_stats["xi"], ensemble_xis),
        "n_fallbacks_fsm": 1 if fsm_stats["used_fallback"] else 0,
        "n_fallbacks_ensemble": n_fallbacks,
        # Upstream spectra summaries
        "centroid_eps": c_eps, "entropy_eps": h_eps, "tailmass_eps": t_eps,
        "centroid_dstar": c_dstar, "entropy_dstar": h_dstar, "tailmass_dstar": t_dstar,
        # FSM spectral summaries
        "centroid_fsm": c_fsm, "entropy_fsm": h_fsm, "tailmass_fsm": t_fsm,
        "centroid_quantile": _q(c_fsm, ens_centroids),
        "centroid_zscore": _z(c_fsm, ens_centroids),
        "entropy_quantile": _q(h_fsm, ens_entropies),
        "entropy_zscore": _z(h_fsm, ens_entropies),
        "tailmass_quantile": _q(t_fsm, ens_tailmass),
        "tailmass_zscore": _z(t_fsm, ens_tailmass),
        # Shape statistics
        "jsd_fsm": d_fsm_jsd,
        "jsd_quantile": _q(d_fsm_jsd, shape_null),
        "jsd_zscore": _z(d_fsm_jsd, shape_null),
        "cosine_fsm": cos_fsm,
        "cosine_quantile": _q(cos_fsm, cos_null),
        "cosine_zscore": _z(cos_fsm, cos_null),
    }

    sidecar = {
        "P_eps": P_eps, "W_eps": W_eps,
        "P_delta_star": P_dstar, "W_delta_star": W_dstar,
        "P_fsm": P_fsm, "W_fsm": W_fsm,
        "ensemble_P_norm": ensemble_P,
        "ensemble_W_raw": ensemble_W,
        "shape_null": shape_null,
        "cosine_null": cos_null,
        "wall_rand": ensemble_walls,
        "xi_rand": ensemble_xis,
    }

    return report, sidecar


# ── CSV columns ───────────────────────────────────────────────────────

SUMMARY_COLUMNS = [
    "depth", "q", "kind", "layer_mode",
    "n_draws", "rank_tol", "rng_seed", "xi_tie_seed", "p", "jsd_floor",
    "wall_fsm", "wall_quantile", "wall_zscore",
    "xi_fsm", "xi_quantile", "xi_zscore",
    "n_fallbacks_fsm", "n_fallbacks_ensemble",
    "centroid_eps", "entropy_eps", "tailmass_eps",
    "centroid_dstar", "entropy_dstar", "tailmass_dstar",
    "centroid_fsm", "entropy_fsm", "tailmass_fsm",
    "centroid_quantile", "centroid_zscore",
    "entropy_quantile", "entropy_zscore",
    "tailmass_quantile", "tailmass_zscore",
    "jsd_fsm", "jsd_quantile", "jsd_zscore",
    "cosine_fsm", "cosine_quantile", "cosine_zscore",
]


# ── Phase runner ──────────────────────────────────────────────────────

def run_phase(phase_name, configs, csv_path):
    """Run a phase and write CSV + npz sidecars."""
    print(f"\n{'=' * 70}")
    print(f"Phase {phase_name}: {len(configs)} configurations")
    print(f"{'=' * 70}\n")

    rows = []
    t_total = time.time()

    for ci, (depth, q, kind, ld, n_draws) in enumerate(configs):
        mode_str = "LD" if ld else "LI"
        label = f"[{ci+1}/{len(configs)}] d={depth} q={q} {kind} {mode_str} n={n_draws}"
        t0 = time.time()

        try:
            report, sidecar = run_spectral_config(depth, q, kind, ld, n_draws)
            rows.append(report)
            elapsed = time.time() - t0

            # Save sidecar
            npz_name = f"spectral_{depth}_{q}_{kind}_{mode_str}.npz"
            npz_path = os.path.join(RESULTS_DIR, npz_name)
            np.savez_compressed(npz_path, **sidecar)

            # Print summary
            print(f"  {label}")
            print(f"    wall_z={report['wall_zscore']:.0f}  "
                  f"xi_z={report['xi_zscore']:.1f}  "
                  f"centroid={report['centroid_fsm']:.2f}  "
                  f"entropy={report['entropy_fsm']:.2f}  "
                  f"tail={report['tailmass_fsm']:.4f}")
            print(f"    JSD={report['jsd_fsm']:.4f} q={report['jsd_quantile']:.3f} "
                  f"z={report['jsd_zscore']:.2f}  "
                  f"cos={report['cosine_fsm']:.4f} q={report['cosine_quantile']:.3f} "
                  f"z={report['cosine_zscore']:.2f}")
            print(f"    ({elapsed:.1f}s)")

        except Exception as e:
            print(f"  FAILED: {label}  {e}")
            import traceback
            traceback.print_exc()

    # Write CSV
    with open(csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=SUMMARY_COLUMNS)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)

    total_elapsed = time.time() - t_total
    print(f"\nPhase {phase_name} done: {len(rows)}/{len(configs)} in "
          f"{total_elapsed:.0f}s")
    print(f"Output: {csv_path}")
    return rows


# ── Main ──────────────────────────────────────────────────────────────

if not globals().get('_SPECTRAL_NO_RUN', False):

    phase_arg = sys.argv[1] if len(sys.argv) > 1 else 'A'

    if phase_arg.upper() == 'A':
        run_phase('A', PHASE_A,
                  os.path.join(RESULTS_DIR, 'spectral_phase_a.csv'))

    elif phase_arg.upper() == 'B':
        run_phase('B', PHASE_B,
                  os.path.join(RESULTS_DIR, 'spectral_phase_b.csv'))

    elif phase_arg.upper() == 'C':
        run_phase('C', PHASE_C_NEW,
                  os.path.join(RESULTS_DIR, 'spectral_phase_c.csv'))

    elif phase_arg.upper() == 'ALL':
        run_phase('A', PHASE_A,
                  os.path.join(RESULTS_DIR, 'spectral_phase_a.csv'))
        run_phase('B', PHASE_B,
                  os.path.join(RESULTS_DIR, 'spectral_phase_b.csv'))
        run_phase('C', PHASE_C_NEW,
                  os.path.join(RESULTS_DIR, 'spectral_phase_c.csv'))

    else:
        print(f"Usage: ./sagew spectral_sweep.sage [A|B|C|ALL]")
        sys.exit(1)
