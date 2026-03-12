"""
lib/optimize.sage — Intercept optimization for the FSM coarse stage.

Per-cell optimal intercept (free-per-cell lower bound) and shared-delta
minimax optimization via bisection+LP (primary) or scipy Nelder-Mead (legacy).
The primary solver now uses a lexicographic second-stage LP to minimize
max |delta| at fixed tau, then repairs dyadic snapping if needed.

Partition-aware: when partition_kind is specified, uses the arbitrary-cell
evaluator with the given geometry.  When partition_kind is None (default),
uses the legacy exact evaluator for backward compatibility.

Depends on: lib/paths.sage, lib/day.sage, lib/partitions.sage (must be loaded first).
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


def _cell_worst_scalar_arb(c_val, plog_lo, plog_hi, p_num, q_den):
    """Objective: worst |log2(z)| for an arbitrary cell as a function of c."""
    _, _, worst, _, _ = cell_logerr_arb(plog_lo, plog_hi, p_num, q_den, QQ(c_val))
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


def optimal_cell_intercept_arb(plog_lo, plog_hi, p_num, q_den, c_init=None):
    """
    Find the intercept c minimizing worst |log2(z)| on an arbitrary cell.

    Returns (c_opt, worst_at_opt).
    """
    if c_init is None:
        c_init = float(QQ(1 - QQ(p_num) / QQ(q_den)) / 2)

    res = scipy_minimize_scalar(
        _cell_worst_scalar_arb,
        bounds=(c_init - 2.0, c_init + 2.0),
        method='bounded',
        args=(plog_lo, plog_hi, p_num, q_den),
        options={'xatol': 1e-15},
    )
    c_opt = dyadic_rational(res.x, bits=20)
    _, _, worst, _, _ = cell_logerr_arb(plog_lo, plog_hi, p_num, q_den, c_opt)
    return c_opt, worst


def free_per_cell_optimum(depth, p_num, q_den, partition_kind=None):
    """
    Optimize c independently per cell (no sharing constraint).

    This is the lower bound: no shared-delta scheme can beat this.
    Returns (global_worst, cell_list) where each entry is
    (bits, c_opt, cell_worst).
    """
    metrics = free_per_cell_metrics(depth, p_num, q_den, partition_kind=partition_kind)
    return metrics["worst_abs"], [
        (row["bits"], row["c_opt"], row["cell_worst"]) for row in metrics["rows"]
    ]


def free_per_cell_metrics(depth, p_num, q_den, partition_kind=None):
    """
    Per-cell optimum metrics under independent intercepts.

    When partition_kind is specified, uses the arbitrary-cell evaluator.
    When partition_kind is None, uses the legacy exact evaluator.
    """
    c_init = float(QQ(1 - QQ(p_num) / QQ(q_den)) / 2)

    rows = []
    worst_abs = 0.0
    union_log2_zmin = None
    union_log2_zmax = None

    if partition_kind is not None:
        partition = build_partition(depth, kind=partition_kind)
        for row in partition:
            c_opt, w = optimal_cell_intercept_arb(
                row['plog_lo'], row['plog_hi'], p_num, q_den, c_init=c_init)
            zmin, zmax, cell_worst, cell_ratio, _ = cell_logerr_arb(
                row['plog_lo'], row['plog_hi'], p_num, q_den, c_opt)
            rows.append({
                "bits": row['bits'],
                "index": row['index'],
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
    else:
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
        "partition_kind": partition_kind,
        "rows": rows,
    }


# ── Bisection + LP minimax solver ───────────────────────────────────────

def build_intercept_matrix(paths, q, depth=None, layer_dependent=False):
    """
    Build the matrix A mapping parameter vector to per-path intercepts.

    Layer-invariant (default): x = [c0, d_00, d_01, ..., d_{q-1,1}]
        Shape (len(paths), 1 + 2*q).  Column 1+2*r+b accumulates edge counts.

    Layer-dependent: x = [c0, d_0_0_0, d_0_0_1, ..., d_{depth-1,q-1,1}]
        Shape (len(paths), 1 + 2*q*depth).  Column 1+2*q*t+2*r+b is 0 or 1.
    """
    if layer_dependent:
        assert depth is not None, "depth required for layer-dependent mode"
        n_params = 1 + 2 * q * depth
    else:
        n_params = 1 + 2 * q
    n_paths = len(paths)
    A = np.zeros((n_paths, n_params), dtype=np.float64)
    for i, P in enumerate(paths):
        A[i, 0] = 1.0  # c0 coefficient
        r = 0
        for t, b in enumerate(P["bits"]):
            if layer_dependent:
                A[i, 1 + 2*q*t + 2*r + b] = 1.0
            else:
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

    return _bisect_feasible_interval(f, float(c_star), tau, tol)


def _cell_feasible_interval_arb(plog_lo, plog_hi, p_num, q_den,
                                c_star, f_star, tau, tol=1e-13):
    """Like _cell_feasible_interval but using the arb evaluator."""
    if tau < f_star - tol:
        return None

    def f(c_val):
        _, _, worst, _, _ = cell_logerr_arb(plog_lo, plog_hi, p_num, q_den, QQ(c_val))
        return worst

    return _bisect_feasible_interval(f, float(c_star), tau, tol)


def _bisect_feasible_interval(f, c_star_f, tau, tol=1e-13):
    """Shared bisection logic for feasible interval computation."""
    # Find left boundary
    step = 0.01
    search_lo = c_star_f - step
    for _ in range(50):
        if f(search_lo) > tau:
            break
        step *= 2
        search_lo = c_star_f - step

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

    # Find right boundary
    step = 0.01
    search_hi = c_star_f + step
    for _ in range(50):
        if f(search_hi) > tau:
            break
        step *= 2
        search_hi = c_star_f + step

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


def _lp_minimize_max_delta(A, lo_bounds, hi_bounds):
    """
    Minimize M subject to the interval constraints and |delta_j| <= M.

    The base intercept c0 is left free. Only the shared delta parameters are
    regularized.
    """
    n_rows, n_cols = A.shape
    c_obj = np.zeros(n_cols + 1)
    c_obj[-1] = 1.0

    interval_A = np.vstack([-A, A])
    interval_b = np.concatenate([-np.array(lo_bounds), np.array(hi_bounds)])
    interval_A = np.hstack([interval_A, np.zeros((2 * n_rows, 1))])

    delta_rows = []
    for j in range(1, n_cols):
        row_pos = np.zeros(n_cols + 1)
        row_pos[j] = 1.0
        row_pos[-1] = -1.0
        delta_rows.append(row_pos)

        row_neg = np.zeros(n_cols + 1)
        row_neg[j] = -1.0
        row_neg[-1] = -1.0
        delta_rows.append(row_neg)

    delta_A = np.array(delta_rows, dtype=np.float64)
    delta_b = np.zeros(len(delta_rows), dtype=np.float64)

    A_ub = np.vstack([interval_A, delta_A])
    b_ub = np.concatenate([interval_b, delta_b])
    bounds = [(None, None)] * n_cols + [(0.0, None)]

    res = scipy_linprog(c_obj, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if res.success and res.status == 0:
        return True, res.x[:-1], float(res.x[-1])
    return False, None, None


def _build_feasible_intervals(cell_optima, p_num, q_den, tau):
    """Build per-cell feasible intercept intervals at a fixed target tau."""
    lo_bounds = []
    hi_bounds = []
    for bits, c_star, f_star in cell_optima:
        interval = _cell_feasible_interval(bits, p_num, q_den, c_star, f_star, tau)
        if interval is None:
            return None
        lo_bounds.append(interval[0])
        hi_bounds.append(interval[1])
    return lo_bounds, hi_bounds


def _build_feasible_intervals_arb(cell_optima_arb, p_num, q_den, tau):
    """Build per-cell feasible intervals using the arb evaluator.

    cell_optima_arb entries: (plog_lo, plog_hi, c_star, f_star).
    """
    lo_bounds = []
    hi_bounds = []
    for plog_lo, plog_hi, c_star, f_star in cell_optima_arb:
        interval = _cell_feasible_interval_arb(
            plog_lo, plog_hi, p_num, q_den, c_star, f_star, tau)
        if interval is None:
            return None
        lo_bounds.append(interval[0])
        hi_bounds.append(interval[1])
    return lo_bounds, hi_bounds


def _snap_policy_vector(x_solution, q, dyadic_bits, depth=None, layer_dependent=False):
    """Snap a continuous LP solution to dyadic policy parameters."""
    c0_opt = dyadic_rational(x_solution[0], bits=dyadic_bits)
    delta_opt = {}
    if layer_dependent:
        assert depth is not None
        for t in range(depth):
            for r in range(q):
                for b in (0, 1):
                    delta_opt[(t, r, b)] = dyadic_rational(
                        x_solution[1 + 2*q*t + 2*r + b], bits=dyadic_bits)
    else:
        for r in range(q):
            for b in (0, 1):
                delta_opt[(r, b)] = dyadic_rational(x_solution[1 + 2*r + b], bits=dyadic_bits)
    return c0_opt, delta_opt


def _delta_linf_from_vector(x_solution):
    """Continuous max |delta| from an LP parameter vector."""
    if len(x_solution) <= 1:
        return 0.0
    return float(max(abs(float(value)) for value in x_solution[1:]))


def _delta_linf_from_policy(delta, q):
    """Snapped max |delta| from a policy table.  Handles both (r,b) and (t,r,b) keys."""
    if not delta:
        return 0.0
    return float(max(abs(float(v)) for v in delta.values()))


def _worst_cell_metadata(metrics, row_map):
    """Extract worst-cell info from metrics cell_data."""
    worst_bits = None
    worst_abs = 0.0
    for entry in metrics["cell_data"]:
        bits = entry[0]
        cell_worst = entry[3]
        if cell_worst > worst_abs:
            worst_abs = cell_worst
            worst_bits = bits
    if worst_bits is not None and row_map is not None:
        row = row_map[worst_bits]
        return {
            "worst_cell_bits": worst_bits,
            "worst_cell_index": row['index'],
            "worst_cell_x_lo": float(row['x_lo']),
            "worst_cell_x_hi": float(row['x_hi']),
        }
    elif worst_bits is not None:
        return {"worst_cell_bits": worst_bits}
    return {}


def optimize_minimax(q, depth, p_num, q_den, tol=1e-10, dyadic_bits=20,
                     layer_dependent=False, partition_kind=None):
    """
    Numerical minimax solver via bisection on target error + LP feasibility.

    For each candidate tau, checks whether a shared-delta policy can achieve
    worst-case error <= tau by computing per-cell feasible intercept intervals
    and solving an LP feasibility problem.

    When layer_dependent=True, uses per-layer delta parameters (1 + 2*q*depth
    parameters) instead of shared deltas (1 + 2*q parameters).

    When partition_kind is specified, uses the arbitrary-cell evaluator
    with the given partition geometry.

    Returns a policy dict compatible with optimize_shared_delta output.
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c_init = float(QQ(1 - alpha_q) / 2)
    use_arb = (partition_kind is not None)

    _, paths, _ = residue_paths(q, depth)
    n_cells = len(paths)

    if use_arb:
        partition = build_partition(depth, kind=partition_kind)
        row_map = partition_row_map(partition)
    else:
        row_map = None

    # Step 1: per-cell optima
    cell_optima = []        # legacy: (bits, c_star, f_star)
    cell_optima_arb = []    # arb:    (plog_lo, plog_hi, c_star, f_star)

    for P in paths:
        if use_arb:
            row = row_map[P["bits"]]
            c_opt, f_opt = optimal_cell_intercept_arb(
                row['plog_lo'], row['plog_hi'], p_num, q_den, c_init=c_init)
            cell_optima_arb.append((row['plog_lo'], row['plog_hi'], float(c_opt), f_opt))
        else:
            c_opt, f_opt = optimal_cell_intercept(P["bits"], p_num, q_den, c_init=c_init)
            cell_optima.append((P["bits"], float(c_opt), f_opt))

    # Step 2: bounds for binary search
    if use_arb:
        tau_lo = max(f for _, _, _, f in cell_optima_arb)
    else:
        tau_lo = max(f for _, _, f in cell_optima)

    zero_c0 = QQ(1 - alpha_q) / 2
    if layer_dependent:
        zero_delta = {(t, r, b): QQ(0) for t in range(depth) for r in range(q) for b in (0, 1)}
    else:
        zero_delta = {(r, b): QQ(0) for r in range(q) for b in (0, 1)}

    if use_arb:
        zero_metrics = global_arb_metrics(paths, p_num, q_den, zero_c0, zero_delta, q, row_map)
    else:
        zero_metrics = global_exact_metrics(paths, p_num, q_den, zero_c0, zero_delta, q)
    tau_hi = max(zero_metrics["worst_abs"], tau_lo + 0.1)

    # Step 3: build intercept matrix
    A = build_intercept_matrix(paths, q, depth=depth, layer_dependent=layer_dependent)

    # Step 4: binary search
    bisection_steps = 0
    x_solution = None
    fallback_used = False
    stage2_regularized = False
    repair_used = False
    repair_succeeded = False
    snap_tol = max(1e-8, 10.0 * tol)

    def _build_intervals(tau_val):
        if use_arb:
            return _build_feasible_intervals_arb(cell_optima_arb, p_num, q_den, tau_val)
        return _build_feasible_intervals(cell_optima, p_num, q_den, tau_val)

    def _eval_metrics(c0, delta):
        if use_arb:
            return global_arb_metrics(paths, p_num, q_den, c0, delta, q, row_map)
        return global_exact_metrics(paths, p_num, q_den, c0, delta, q)

    for _ in range(70):  # ~70 steps gives ~1e-21 precision
        if tau_hi - tau_lo < tol:
            break
        tau_mid = (tau_lo + tau_hi) / 2.0
        bisection_steps += 1

        intervals = _build_intervals(tau_mid)
        if intervals is None:
            tau_lo = tau_mid
            continue

        lp_ok, x_opt = _lp_feasibility(A, intervals[0], intervals[1])
        if lp_ok:
            tau_hi = tau_mid
            x_solution = x_opt
        else:
            tau_lo = tau_mid

    tau_continuous = float(tau_hi)
    intervals = _build_intervals(tau_hi)
    x_continuous = None
    m_opt = None

    if intervals is not None:
        lp_ok, x_opt, m_stage2 = _lp_minimize_max_delta(A, intervals[0], intervals[1])
        if lp_ok:
            x_continuous = x_opt
            m_opt = m_stage2
            stage2_regularized = True
        else:
            fallback_used = True
            lp_ok, x_opt = _lp_feasibility(A, intervals[0], intervals[1])
            if lp_ok:
                x_continuous = x_opt
                m_opt = _delta_linf_from_vector(x_opt)

    if x_continuous is None and x_solution is not None:
        fallback_used = True
        x_continuous = x_solution
        m_opt = _delta_linf_from_vector(x_solution)

    if x_continuous is not None:
        c0_opt, delta_opt = _snap_policy_vector(
            x_continuous, q, dyadic_bits, depth=depth, layer_dependent=layer_dependent)
    else:
        fallback_used = True
        c0_opt = QQ(1 - alpha_q) / 2
        if layer_dependent:
            delta_opt = {(t, r, b): QQ(0) for t in range(depth) for r in range(q) for b in (0, 1)}
        else:
            delta_opt = {(r, b): QQ(0) for r in range(q) for b in (0, 1)}
        m_opt = 0.0

    metrics = _eval_metrics(c0_opt, delta_opt)
    continuous_feasible = (x_continuous is not None)
    target_tau = tau_continuous
    tau_snapped = float(metrics["worst_abs"])
    matches_continuous_tau = continuous_feasible and (tau_snapped <= tau_continuous + snap_tol)
    within_target = continuous_feasible and (tau_snapped <= target_tau + snap_tol)

    if continuous_feasible and not matches_continuous_tau:
        repair_used = True
        repair_tau = tau_snapped + snap_tol
        repair_intervals = _build_intervals(repair_tau)
        if repair_intervals is not None:
            repair_ok, x_repair, m_repair = _lp_minimize_max_delta(
                A, repair_intervals[0], repair_intervals[1]
            )
            if repair_ok:
                stage2_regularized = True
            if not repair_ok:
                fallback_used = True
                repair_ok, x_repair = _lp_feasibility(A, repair_intervals[0], repair_intervals[1])
                m_repair = _delta_linf_from_vector(x_repair) if repair_ok else None
            if repair_ok:
                c0_repair, delta_repair = _snap_policy_vector(
                    x_repair, q, dyadic_bits, depth=depth, layer_dependent=layer_dependent)
                metrics_repair = _eval_metrics(c0_repair, delta_repair)
                tau_repair_snapped = float(metrics_repair["worst_abs"])
                if tau_repair_snapped <= repair_tau + snap_tol:
                    c0_opt = c0_repair
                    delta_opt = delta_repair
                    metrics = metrics_repair
                    tau_snapped = tau_repair_snapped
                    target_tau = repair_tau
                    within_target = True
                    repair_succeeded = True
                    if m_repair is not None:
                        m_opt = m_repair
        if not repair_succeeded:
            target_tau = tau_snapped
            within_target = True

    # Compute unique intercepts
    intercepts = set()
    for P in paths:
        intercepts.add(path_intercept(P["bits"], c0_opt, delta_opt, q))
    n_unique = len(intercepts)
    max_delta_abs = _delta_linf_from_policy(delta_opt, q)

    result = {
        "name": "optimized",
        "description": (f"numerical minimax bisection+LP (q={q}, d={depth}, "
                        f"layer_dep={layer_dependent}, "
                        f"partition={partition_kind}, "
                        f"{bisection_steps} bisection steps, "
                        f"dyadic_bits={dyadic_bits})"),
        "c0_rat": c0_opt,
        "delta_rat": delta_opt,
        "worst_err": metrics["worst_abs"],
        "union_log2_ratio": metrics["union_log2_ratio"],
        "max_cell_log2_ratio": metrics["max_cell_log2_ratio"],
        "m_opt": float(m_opt),
        "max_delta_abs": max_delta_abs,
        "n_evals": bisection_steps,
        "converged": continuous_feasible,
        "continuous_feasible": continuous_feasible,
        "stage2_regularized": stage2_regularized,
        "matches_continuous_tau": matches_continuous_tau,
        "within_target": within_target,
        "fallback_used": fallback_used,
        "repair_used": repair_used,
        "repair_succeeded": repair_succeeded,
        "tau_continuous": tau_continuous,
        "tau_snapped": tau_snapped,
        "dyadic_loss": tau_snapped - tau_continuous,
        "target_tau": target_tau,
        "unique_intercepts": n_unique,
        "layer_dependent": layer_dependent,
        "partition_kind": partition_kind,
        "metrics": metrics,
    }
    result.update(_worst_cell_metadata(metrics, row_map))
    return result


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
                          dyadic_bits=12, method='minimax', layer_dependent=False,
                          partition_kind=None):
    """
    Optimize c0 and delta to minimize worst-case error over all leaf cells.

    method='minimax' uses bisection+LP with dyadic snapping (default, numerical).
    method='nelder-mead' uses Nelder-Mead with multiple restarts (legacy).
    layer_dependent=True uses per-layer deltas (1+2*q*depth params).
    partition_kind selects cell geometry (None=legacy exact or any supported
    partition kind such as 'uniform_x', 'geometric_x', 'harmonic_x',
    'mirror_harmonic_x').
    Returns a policy dict compatible with build_intercept_policy.
    """
    if method == 'minimax':
        return optimize_minimax(q, depth, p_num, q_den, dyadic_bits=dyadic_bits,
                                layer_dependent=layer_dependent,
                                partition_kind=partition_kind)
    if partition_kind is not None:
        raise ValueError("partition_kind requires method='minimax'")
    if layer_dependent:
        raise ValueError("layer_dependent=True requires method='minimax'")
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
    max_delta_abs = _delta_linf_from_policy(delta_opt, q)

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
        "m_opt": max_delta_abs,
        "max_delta_abs": max_delta_abs,
        "n_evals": total_evals,
        "converged": best_result.success,
        "continuous_feasible": best_result.success,
        "stage2_regularized": False,
        "within_target": True,
        "fallback_used": False,
        "repair_used": False,
        "repair_succeeded": False,
        "tau_continuous": metrics["worst_abs"],
        "tau_snapped": metrics["worst_abs"],
        "dyadic_loss": 0.0,
        "target_tau": metrics["worst_abs"],
        "unique_intercepts": n_unique,
        "metrics": metrics,
    }
