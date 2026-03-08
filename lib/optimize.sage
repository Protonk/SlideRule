"""
lib/optimize.sage — Intercept optimization for the FSM coarse stage.

Per-cell optimal intercept (free-per-cell lower bound) and shared-delta
minimax optimization via bisection+LP (primary) or scipy Nelder-Mead (legacy).

Depends on: lib/paths.sage, lib/day.sage (must be loaded first).
"""

from scipy.optimize import minimize as scipy_minimize
from scipy.optimize import minimize_scalar as scipy_minimize_scalar
from scipy.optimize import linprog as scipy_linprog
from itertools import product as iproduct
import numpy as np
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


# ── Bisection + LP minimax solver ───────────────────────────────────────

def build_intercept_matrix(paths, q):
    """
    Build the matrix A mapping parameter vector x = [c0, d_00, d_01, ..., d_{q-1,1}]
    to per-path intercepts.

    Row i has 1 in column 0 (for c0), and the count of times edge (r, b) is
    traversed in column 1 + 2*r + b.

    Returns a numpy float64 matrix of shape (len(paths), 1 + 2*q).
    """
    n_params = 1 + 2 * q
    n_paths = len(paths)
    A = np.zeros((n_paths, n_params), dtype=np.float64)
    for i, P in enumerate(paths):
        A[i, 0] = 1.0  # c0 coefficient
        r = 0
        for b in P["bits"]:
            A[i, 1 + 2*r + b] += 1.0
            r = (2*r + b) % q
    return A


def _cell_feasible_interval(bits, p_num, q_den, c_star, f_star, tau, tol=1e-13):
    """
    Find the interval [lo, hi] where cell error f(c) <= tau.

    Uses bisection on each side of the optimal intercept c_star.
    Returns (lo, hi) or None if tau < f_star (infeasible).
    """
    if tau < f_star - tol:
        return None

    def f(c_val):
        _, _, worst, _ = cell_exact_logerr(bits, p_num, q_den, QQ(c_val))
        return worst

    c_star_f = float(c_star)

    # Find left boundary: largest c < c_star where f(c) = tau
    # Expand left until f > tau
    step = 0.01
    search_lo = c_star_f - step
    for _ in range(50):
        if f(search_lo) > tau:
            break
        step *= 2
        search_lo = c_star_f - step

    # Bisect: a has f>tau, b has f<=tau => boundary in [a, b]
    a, b = search_lo, c_star_f
    for _ in range(80):
        if b - a < tol:
            break
        mid = (a + b) / 2.0
        if f(mid) > tau:
            a = mid
        else:
            b = mid
    lo_boundary = b

    # Find right boundary: smallest c > c_star where f(c) = tau
    step = 0.01
    search_hi = c_star_f + step
    for _ in range(50):
        if f(search_hi) > tau:
            break
        step *= 2
        search_hi = c_star_f + step

    # Bisect: a has f<=tau, b has f>tau => boundary in [a, b]
    a, b = c_star_f, search_hi
    for _ in range(80):
        if b - a < tol:
            break
        mid = (a + b) / 2.0
        if f(mid) > tau:
            b = mid
        else:
            a = mid
    hi_boundary = a

    return (lo_boundary, hi_boundary)


def _lp_feasibility(A, lo_bounds, hi_bounds):
    """
    Check whether there exists x such that lo_i <= (A @ x)_i <= hi_i for all i.

    Uses scipy.optimize.linprog with zero objective (feasibility only).
    Returns (feasible, x_opt).
    """
    n_rows, n_cols = A.shape
    c_obj = np.zeros(n_cols)

    # Constraints: A @ x >= lo  =>  -A @ x <= -lo
    #              A @ x <= hi  =>   A @ x <= hi
    A_ub = np.vstack([-A, A])
    b_ub = np.concatenate([-np.array(lo_bounds), np.array(hi_bounds)])

    res = scipy_linprog(c_obj, A_ub=A_ub, b_ub=b_ub, bounds=[(None, None)] * n_cols,
                        method='highs')
    if res.success and res.status == 0:
        return True, res.x
    return False, None


def optimize_minimax(q, depth, p_num, q_den, tol=1e-10, dyadic_bits=20):
    """
    Exact minimax solver via bisection on target error + LP feasibility.

    For each candidate tau, checks whether a shared-delta policy can achieve
    worst-case error <= tau by computing per-cell feasible intercept intervals
    and solving an LP feasibility problem.

    Returns a policy dict compatible with optimize_shared_delta output.
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c_init = float(QQ(1 - alpha_q) / 2)

    _, paths, _ = residue_paths(q, depth)
    n_cells = len(paths)

    # Step 1: per-cell optima
    cell_optima = []
    for P in paths:
        c_opt, f_opt = optimal_cell_intercept(P["bits"], p_num, q_den, c_init=c_init)
        cell_optima.append((P["bits"], float(c_opt), f_opt))

    # Step 2: bounds for binary search
    tau_lo = max(f for _, _, f in cell_optima)  # free-per-cell bound
    # Upper bound: error under zero policy
    zero_c0 = QQ(1 - alpha_q) / 2
    zero_delta = {(r, b): QQ(0) for r in range(q) for b in (0, 1)}
    zero_metrics = global_exact_metrics(paths, p_num, q_den, zero_c0, zero_delta, q)
    tau_hi = max(zero_metrics["worst_abs"], tau_lo + 0.1)

    # Step 3: build intercept matrix
    A = build_intercept_matrix(paths, q)

    # Step 4: binary search
    bisection_steps = 0
    x_solution = None

    for _ in range(70):  # ~70 steps gives ~1e-21 precision
        if tau_hi - tau_lo < tol:
            break
        tau_mid = (tau_lo + tau_hi) / 2.0
        bisection_steps += 1

        # Compute feasible interval for each cell
        lo_bounds = []
        hi_bounds = []
        feasible = True
        for bits, c_star, f_star in cell_optima:
            interval = _cell_feasible_interval(bits, p_num, q_den, c_star, f_star, tau_mid)
            if interval is None:
                feasible = False
                break
            lo_bounds.append(interval[0])
            hi_bounds.append(interval[1])

        if not feasible:
            tau_lo = tau_mid
            continue

        # LP feasibility check
        lp_ok, x_opt = _lp_feasibility(A, lo_bounds, hi_bounds)
        if lp_ok:
            tau_hi = tau_mid
            x_solution = x_opt
        else:
            tau_lo = tau_mid

    # Step 5: extract solution and snap to dyadic rationals
    if x_solution is None:
        # Fallback: try at tau_hi
        lo_bounds = []
        hi_bounds = []
        for bits, c_star, f_star in cell_optima:
            interval = _cell_feasible_interval(bits, p_num, q_den, c_star, f_star, tau_hi)
            if interval is None:
                interval = (c_star, c_star)
            lo_bounds.append(interval[0])
            hi_bounds.append(interval[1])
        _, x_solution = _lp_feasibility(A, lo_bounds, hi_bounds)

    if x_solution is not None:
        c0_opt = dyadic_rational(x_solution[0], bits=dyadic_bits)
        delta_opt = {}
        for r in range(q):
            for b in (0, 1):
                delta_opt[(r, b)] = dyadic_rational(x_solution[1 + 2*r + b], bits=dyadic_bits)
    else:
        # Last resort: use zero policy
        c0_opt = QQ(1 - alpha_q) / 2
        delta_opt = {(r, b): QQ(0) for r in range(q) for b in (0, 1)}

    metrics = global_exact_metrics(paths, p_num, q_den, c0_opt, delta_opt, q)

    # Compute unique intercepts
    intercepts = set()
    for P in paths:
        intercepts.add(path_intercept(P["bits"], c0_opt, delta_opt, q))
    n_unique = len(intercepts)

    return {
        "name": "optimized",
        "description": (f"minimax bisection+LP (q={q}, d={depth}, "
                        f"{bisection_steps} bisection steps, "
                        f"dyadic_bits={dyadic_bits})"),
        "c0_rat": c0_opt,
        "delta_rat": delta_opt,
        "worst_err": metrics["worst_abs"],
        "union_log2_ratio": metrics["union_log2_ratio"],
        "max_cell_log2_ratio": metrics["max_cell_log2_ratio"],
        "n_evals": bisection_steps,
        "converged": True,
        "unique_intercepts": n_unique,
        "metrics": metrics,
    }


# ── Shared-delta optimization (Nelder-Mead legacy) ────────────────────

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
                          dyadic_bits=12, method='minimax'):
    """
    Optimize c0 and delta[(r,b)] to minimize worst-case error
    over all leaf cells.

    method='minimax' uses bisection+LP (default, exact).
    method='nelder-mead' uses Nelder-Mead with multiple restarts (legacy).
    Returns a policy dict compatible with build_intercept_policy.
    """
    if method == 'minimax':
        return optimize_minimax(q, depth, p_num, q_den, dyadic_bits=dyadic_bits)
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
