"""
lib/optimize.sage — Intercept optimization for the FSM coarse stage.

Per-cell optimal intercept (free-per-cell lower bound) and shared-delta
minimax optimization via scipy Nelder-Mead.

Depends on: lib/paths.sage, lib/day.sage (must be loaded first).
"""

from scipy.optimize import minimize as scipy_minimize
from scipy.optimize import minimize_scalar as scipy_minimize_scalar
from itertools import product as iproduct
import random


# ── Per-cell optimization ───────────────────────────────────────────────

def _cell_worst_scalar(c_val, bits, p_num, q_den):
    """Objective: worst |log2(z)| for one cell as a function of c."""
    _, _, worst, _ = cell_exact_logerr(bits, p_num, q_den, QQ(c_val))
    return worst


def optimal_cell_intercept(bits, p_num, q_den, c_init=None):
    """
    Find the intercept c minimizing worst |log2(z)| on one dyadic cell.

    Returns (c_opt, worst_at_opt).
    """
    if c_init is None:
        c_init = float(QQ(1 - QQ(p_num) / QQ(q_den)) / 2)

    res = scipy_minimize_scalar(
        _cell_worst_scalar,
        bounds=(c_init - 2.0, c_init + 2.0),
        method='bounded',
        args=(bits, p_num, q_den),
        options={'xatol': 1e-15},
    )
    c_opt = dyadic_rational(res.x, bits=20)
    _, _, worst, _ = cell_exact_logerr(bits, p_num, q_den, c_opt)
    return c_opt, worst


def free_per_cell_optimum(depth, p_num, q_den):
    """
    Optimize c independently per dyadic cell (no sharing constraint).

    This is the lower bound: no shared-delta scheme can beat this.
    Returns (global_worst, cell_list) where each entry is
    (bits, c_opt, cell_worst).
    """
    c_init = float(QQ(1 - QQ(p_num) / QQ(q_den)) / 2)

    metrics = free_per_cell_metrics(depth, p_num, q_den)
    return metrics["worst_abs"], [
        (row["bits"], row["c_opt"], row["cell_worst"]) for row in metrics["rows"]
    ]


def free_per_cell_metrics(depth, p_num, q_den):
    """
    Per-cell optimum metrics under independent intercepts.

    Returns a dict with the global sup norm, the induced union-level ratio,
    and per-cell optimized rows.
    """
    c_init = float(QQ(1 - QQ(p_num) / QQ(q_den)) / 2)

    rows = []
    worst_abs = 0.0
    union_log2_zmin = None
    union_log2_zmax = None

    for bits in iproduct((0, 1), repeat=depth):
        c_opt, w = optimal_cell_intercept(bits, p_num, q_den, c_init=c_init)
        zmin, zmax, cell_worst, cell_ratio = cell_exact_logerr(bits, p_num, q_den, c_opt)
        rows.append({
            "bits": bits,
            "c_opt": c_opt,
            "zmin": zmin,
            "zmax": zmax,
            "cell_worst": cell_worst,
            "cell_ratio": cell_ratio,
        })
        if cell_worst > worst_abs:
            worst_abs = cell_worst
        if union_log2_zmin is None or zmin < union_log2_zmin:
            union_log2_zmin = zmin
        if union_log2_zmax is None or zmax > union_log2_zmax:
            union_log2_zmax = zmax

    return {
        "worst_abs": worst_abs,
        "union_log2_zmin": union_log2_zmin,
        "union_log2_zmax": union_log2_zmax,
        "union_log2_ratio": union_log2_zmax - union_log2_zmin,
        "rows": rows,
    }


# ── Shared-delta optimization ───────────────────────────────────────────

def _unpack_params(params, q, dyadic_bits=12):
    """Unpack flat float vector -> (c0 as QQ, delta dict of QQ)."""
    c0 = dyadic_rational(params[0], bits=dyadic_bits)
    delta = {}
    for r in range(q):
        for b in (0, 1):
            delta[(r, b)] = dyadic_rational(params[1 + 2*r + b], bits=dyadic_bits)
    return c0, delta


def _shared_objective(params, paths, p_num, q_den, q, dyadic_bits):
    """Minimax: max over cells of cell worst |log2(z)|."""
    c0, delta = _unpack_params(params, q, dyadic_bits=dyadic_bits)
    metrics = global_exact_metrics(paths, p_num, q_den, c0, delta, q)
    return metrics["worst_abs"]


def optimize_shared_delta(q, depth, p_num, q_den, c0_init=None,
                          maxiter=5000, n_restarts=3, seed=42,
                          dyadic_bits=12):
    """
    Optimize c0 and delta[(r,b)] to minimize worst-case error
    over all leaf cells.

    Uses Nelder-Mead with multiple restarts.
    Returns a policy dict compatible with build_intercept_policy.
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    if c0_init is None:
        c0_init = float(QQ(1 - alpha_q) / 2)

    _, paths, _ = residue_paths(q, depth)
    n_params = 1 + 2 * q

    best_result = None
    best_fun = float('inf')
    total_evals = 0

    rng = random.Random(int(seed))

    for restart in range(n_restarts):
        if restart == 0:
            x0 = [c0_init] + [0.0] * (2 * q)
        else:
            x0 = [c0_init + rng.gauss(0, 0.1)]
            for _ in range(2 * q):
                x0.append(rng.gauss(0, 0.01))

        res = scipy_minimize(
            _shared_objective,
            x0,
            args=(paths, p_num, q_den, q, dyadic_bits),
            method='Nelder-Mead',
            options={'maxiter': maxiter, 'xatol': 1e-12, 'fatol': 1e-10,
                     'adaptive': True},
        )
        total_evals += res.nfev

        if res.fun < best_fun:
            best_fun = res.fun
            best_result = res

    c0_opt, delta_opt = _unpack_params(best_result.x, q, dyadic_bits=dyadic_bits)
    metrics = global_exact_metrics(paths, p_num, q_den, c0_opt, delta_opt, q)

    # Compute unique intercepts under the optimized policy
    intercepts = set()
    for P in paths:
        intercepts.add(path_intercept(P["bits"], c0_opt, delta_opt, q))
    n_unique = len(intercepts)

    return {
        "name": "optimized",
        "description": (f"minimax optimized (q={q}, d={depth}, "
                        f"{total_evals} evals, {n_restarts} restarts, "
                        f"dyadic_bits={dyadic_bits})"),
        "c0_rat": c0_opt,
        "delta_rat": delta_opt,
        "worst_err": metrics["worst_abs"],
        "union_log2_ratio": metrics["union_log2_ratio"],
        "max_cell_log2_ratio": metrics["max_cell_log2_ratio"],
        "n_evals": total_evals,
        "converged": best_result.success,
        "unique_intercepts": n_unique,
        "metrics": metrics,
    }
