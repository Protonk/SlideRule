"""
charybdis_check.sage — Extraction layer and statistics for the Test of Charybdis.

Provides:
  extract_charybdis_config  — extraction layer (Step 2)
  linf_project              — L∞ projection with L2 tie-break (Step 3)
  random_subspace           — Grassmannian draw (Step 3)
  charybdis_stats           — wall + ξ_n + Walsh spectrum (Step 3)

All vectors are in canonical bits order: cell j corresponds to
index_to_bits(j, depth), MSB first.

Run:  ./sagew experiments/aft/rotation/charybdis_check.sage
"""

import os
import sys
import time

from helpers import pathing
load(pathing('lib', 'paths.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))
load(pathing('lib', 'policies.sage'))
load(pathing('lib', 'optimize.sage'))
load(pathing('lib', 'displacement.sage'))

import numpy as np
from scipy.optimize import linprog as scipy_linprog
from scipy.stats import chatterjeexi


# ── Design constants ──────────────────────────────────────────────────

RANK_TOL = 1e-10     # SVD relative cutoff for rank detection
P_NUM, Q_DEN = 1, 2  # target exponent x^{-1/2}


# ── Extraction layer ─────────────────────────────────────────────────

def extract_charybdis_config(q, depth, partition_kind, layer_dependent,
                             rank_tol=RANK_TOL):
    """
    Extract the objects needed by the rotation check.

    Parameters
    ----------
    q               : int  — FSM state count
    depth           : int  — binary depth
    partition_kind  : str  — partition kind (e.g. 'geometric_x')
    layer_dependent : bool — True for LD, False for LI
    rank_tol        : float — SVD relative cutoff for rank detection

    Returns
    -------
    dict with keys:
        delta_star : ndarray (n,)    — free intercept field c*
        Q_fsm      : ndarray (n, p)  — orthonormal basis for im(B_fsm)
        p          : int             — rank of B_fsm
        eps_vec    : ndarray (n,)    — ε(m_mid) per cell
        partition  : list            — partition row dicts
        B_fsm      : ndarray (n, k)  — raw intercept matrix
        rank_tol   : float           — cutoff used
    where n = 2^depth.
    """
    n = 2**depth

    # 1. Build paths and intercept matrix
    edges, paths, edge_index = residue_paths(q, depth)
    assert len(paths) == n, f"Expected {n} paths, got {len(paths)}"

    B_fsm = build_intercept_matrix(paths, q, depth=depth,
                                   layer_dependent=layer_dependent)
    assert B_fsm.shape[0] == n

    # 2. Orthonormal basis for im(B_fsm) via SVD with rank detection
    U, sigma, Vt = np.linalg.svd(B_fsm, full_matrices=False)
    sigma_max = sigma[0]
    p = int(np.sum(sigma > rank_tol * sigma_max))
    Q_fsm = U[:, :p]  # orthonormal basis for im(B_fsm)

    # 3. Build partition (single source of truth for both δ* and ε)
    partition = build_partition(depth, kind=partition_kind)
    row_map = partition_row_map(partition)
    x_start = float(partition[0]['x_start'])
    x_width = float(partition[0]['x_width'])

    # 4. Extract δ* = c* from free_per_cell_metrics
    #    Note: free_per_cell_metrics builds its own partition internally
    #    with the same (depth, partition_kind) arguments. Verify consistency.
    free_metrics = free_per_cell_metrics(depth, P_NUM, Q_DEN,
                                         partition_kind=partition_kind)

    # Build delta_star in canonical bits order (cell index order)
    delta_star = np.zeros(n)
    for row in free_metrics["rows"]:
        idx = bits_to_index(row["bits"])
        delta_star[idx] = float(row["c_opt"])
        # Cross-check: bits from free_metrics must exist in our partition
        assert row["bits"] in row_map, (
            f"bits {row['bits']} from free_per_cell_metrics "
            f"not in partition")

    # 5. Build ε(m_mid) vector in the same order, domain-agnostic
    eps_vec = np.zeros(n)
    for j in range(n):
        bits = index_to_bits(j, depth)
        row = row_map[bits]
        x_lo = float(row['x_lo'])
        x_hi = float(row['x_hi'])
        m_mid = ((x_lo + x_hi) / 2.0 - x_start) / x_width
        eps_vec[j] = eps_val(m_mid)

    # 6. Verify lengths
    assert delta_star.shape == (n,)
    assert Q_fsm.shape == (n, p)
    assert eps_vec.shape == (n,)

    return {
        "delta_star": delta_star,
        "Q_fsm": Q_fsm,
        "p": p,
        "eps_vec": eps_vec,
        "partition": partition,
        "B_fsm": B_fsm,
        "rank_tol": rank_tol,
        "q": q,
        "depth": depth,
        "partition_kind": partition_kind,
        "layer_dependent": layer_dependent,
    }


# ── L∞ projection with L2 tie-break ──────────────────────────────────

def linf_project(delta_star, B):
    """
    L∞ best approximation of delta_star from im(B), with L2 tie-break.

    Stage 1: LP for optimal L∞ distance t*.
    Stage 2: unconstrained least-squares. If the LS solution satisfies
             the L∞ constraint, use it (it is the L2 tie-break). If not,
             fall back to the LP solution.

    Parameters
    ----------
    delta_star : ndarray (n,)
    B          : ndarray (n, p)

    Returns
    -------
    wall         : float        — L∞ distance
    residual     : ndarray (n,) — tie-broken residual delta_star - B @ alpha*
    used_fallback: bool         — True if LS solution violated L∞ and LP was used
    """
    n, p = B.shape

    # Stage 1: LP for L∞ distance
    # Variables: [alpha (p), t (1)]
    # Objective: min t
    c_obj = np.zeros(p + 1)
    c_obj[p] = 1.0

    A_upper = np.hstack([-B, -np.ones((n, 1))])
    b_upper = -delta_star
    A_lower = np.hstack([B, -np.ones((n, 1))])
    b_lower = delta_star

    A_ub = np.vstack([A_upper, A_lower])
    b_ub = np.concatenate([b_upper, b_lower])

    bounds = [(None, None)] * p + [(0.0, None)]
    res = scipy_linprog(c_obj, A_ub=A_ub, b_ub=b_ub, bounds=bounds,
                        method='highs')
    assert res.success, f"LP failed: {res.message}"
    t_star = float(res.x[p])
    alpha_lp = res.x[:p]

    # Stage 2: L2 tie-break
    # Try unconstrained least-squares first (fast).
    # If it's within the L∞ ball, it's the optimal L2 tie-break.
    alpha_ls, _, _, _ = np.linalg.lstsq(B, delta_star, rcond=None)
    resid_ls = delta_star - B @ alpha_ls
    linf_ls = float(np.max(np.abs(resid_ls)))

    if linf_ls <= t_star * (1.0 + 1e-9):
        # LS solution is within the L∞ ball — use it
        return linf_ls, resid_ls, False

    # LS solution violates L∞ constraint — use LP solution
    resid_lp = delta_star - B @ alpha_lp
    wall = float(np.max(np.abs(resid_lp)))
    return wall, resid_lp, True


# ── Random subspace from Grassmannian ────────────────────────────────

def random_subspace(n, p, rng):
    """
    Draw a Haar-uniform random n×p orthonormal matrix.

    Uses QR of a Gaussian matrix with diagonal-sign correction:
    np.linalg.qr chooses R with non-negative diagonal, which biases Q.
    Multiplying Q by sign(diag(R)) restores Haar uniformity.

    Parameters
    ----------
    n   : int — ambient dimension
    p   : int — subspace dimension
    rng : numpy.random.Generator

    Returns
    -------
    Q : ndarray (n, p) — orthonormal columns, Haar-uniform on Grassmannian
    """
    G = rng.standard_normal((n, p))
    Q, R = np.linalg.qr(G)
    # Sign correction: flip columns of Q by sign of diag(R)
    d = np.sign(np.diag(R))
    d[d == 0] = 1.0  # zero diagonal shouldn't happen with Gaussian input
    Q = Q * d[np.newaxis, :]
    return Q


# ── Walsh-Hadamard transform and spectral profile ───────────────────

def _fast_walsh_hadamard(x):
    """In-place fast Walsh-Hadamard transform (unnormalized)."""
    a = x.copy().astype(np.float64)
    n = len(a)
    h = 1
    while h < n:
        for i in range(0, n, h * 2):
            for j in range(i, i + h):
                u = a[j]
                v = a[j + h]
                a[j] = u + v
                a[j + h] = u - v
        h *= 2
    return a


def walsh_spectrum(residual, depth):
    """
    Compute Walsh level weights and normalized profile.

    Parameters
    ----------
    residual : ndarray (2^d,) — residual vector in bits-order
    depth    : int

    Returns
    -------
    W_raw  : ndarray (d+1,) — level-k weight W^k = Σ_{|S|=k} r̂(S)²
    P_norm : ndarray (d+1,) — normalized profile P^k = W^k / Σ W^j
    """
    n = 2**depth
    assert len(residual) == n

    # Normalized Walsh-Hadamard coefficients: r̂(S) = 2^{-d} Σ_x r(x) χ_S(x)
    rhat = _fast_walsh_hadamard(residual) / n

    # Level weights: W^k = Σ_{|S|=k} r̂(S)²
    W_raw = np.zeros(depth + 1)
    for s in range(n):
        k = bin(s).count('1')  # |S| = number of 1-bits in index
        W_raw[k] += rhat[s] ** 2

    total = W_raw.sum()
    if total > 0:
        P_norm = W_raw / total
    else:
        P_norm = np.zeros(depth + 1)

    return W_raw, P_norm


# ── Charybdis statistics ─────────────────────────────────────────────

def charybdis_stats(delta_star, B, eps_jittered):
    """
    Compute wall, ξ_n, and Walsh spectrum for a single subspace.

    Parameters
    ----------
    delta_star   : ndarray (n,)
    B            : ndarray (n, p) — basis for the subspace
    eps_jittered : ndarray (n,) — jittered ε vector (shared across ensemble)

    Returns
    -------
    dict with keys: wall, xi, W_raw, P_norm
    """
    n = len(delta_star)
    depth = int(np.log2(n))
    assert 2**depth == n

    wall, residual, used_fallback = linf_project(delta_star, B)

    xi_result = chatterjeexi(eps_jittered, np.abs(residual))
    xi = float(xi_result.statistic)

    W_raw, P_norm = walsh_spectrum(residual, depth)

    return {
        "wall": wall,
        "xi": xi,
        "W_raw": W_raw,
        "P_norm": P_norm,
        "residual": residual,
        "used_fallback": used_fallback,
    }


# ── Self-test ─────────────────────────────────────────────────────────

if not globals().get('_CHARYBDIS_NO_SELFTEST', False):

    all_pass = True
    def _check(label, cond, msg=""):
        global all_pass
        if cond:
            print(f"  PASS  {label}  {msg}")
        else:
            print(f"  FAIL  {label}  {msg}")
            all_pass = False

    # ── Part A: Extraction layer tests ────────────────────────────────

    print("=" * 60)
    print("Part A: Extraction layer")
    print("=" * 60)

    EXTRACT_CASES = [
        (3, 5, 'geometric_x', False),
        (3, 5, 'geometric_x', True),
        (3, 5, 'uniform_x', False),
        (3, 5, 'harmonic_x', False),
        (2, 6, 'geometric_x', False),
    ]

    for q, depth, kind, ld in EXTRACT_CASES:
        label = f"q={q} d={depth} {kind} {'LD' if ld else 'LI'}"
        t0 = time.time()
        try:
            cfg = extract_charybdis_config(q, depth, kind, ld)
            n = 2**depth
            elapsed = time.time() - t0
            assert cfg["delta_star"].shape == (n,)
            assert cfg["Q_fsm"].shape == (n, cfg["p"])
            assert cfg["eps_vec"].shape == (n,)
            QtQ = cfg["Q_fsm"].T @ cfg["Q_fsm"]
            ortho_err = np.max(np.abs(QtQ - np.eye(cfg["p"])))
            assert ortho_err < 1e-12
            B = cfg["B_fsm"]
            proj = cfg["Q_fsm"] @ (cfg["Q_fsm"].T @ B)
            resid = np.max(np.abs(B - proj))
            assert resid < 1e-8
            assert np.all(cfg["eps_vec"] >= -1e-15)
            assert np.all(np.isfinite(cfg["delta_star"]))
            _check(label, True,
                   f"p={cfg['p']} n={n} ortho={ortho_err:.1e} "
                   f"sub_resid={resid:.1e} {elapsed:.2f}s")
        except Exception as e:
            _check(label, False, str(e))

    # ── Part B: Step 4 validation tests ───────────────────────────────

    print()
    print("=" * 60)
    print("Part B: Step 4 validation (projection + statistics)")
    print("=" * 60)

    rng_val = np.random.default_rng(int(12345))

    # V1. LP correctness — 1-d subspace, known answer
    print()
    print("  V1. LP correctness (1-d subspace, hand-computed)")
    d_star_v1 = np.array([1.0, 3.0, 2.0, 0.0])
    B_v1 = np.array([[1.0], [1.0], [1.0], [1.0]])  # span of ones vector
    # Best L∞ fit: alpha = median-like value minimizing max|d_i - alpha|
    # Chebyshev center: alpha = (max + min) / 2 = (3 + 0) / 2 = 1.5
    # wall = (3 - 0) / 2 = 1.5
    wall_v1, resid_v1, fb_v1 = linf_project(d_star_v1, B_v1)
    expected_wall = 1.5
    _check("V1 wall", abs(wall_v1 - expected_wall) < 1e-8,
           f"wall={wall_v1:.6f} expected={expected_wall}")
    expected_resid = d_star_v1 - 1.5
    resid_err_v1 = np.max(np.abs(resid_v1 - expected_resid))
    _check("V1 residual", resid_err_v1 < 1e-8,
           f"max_resid_err={resid_err_v1:.1e}")

    # V1b. 2-d subspace, known answer
    print()
    print("  V1b. LP correctness (2-d subspace)")
    d_star_v1b = np.array([1.0, 3.0, 5.0, 7.0])
    # B = [ones, (0,1,2,3)] => can fit any affine function
    B_v1b = np.array([[1.0, 0.0], [1.0, 1.0], [1.0, 2.0], [1.0, 3.0]])
    wall_v1b, resid_v1b, fb_v1b = linf_project(d_star_v1b, B_v1b)
    # d_star is exactly affine: 1 + 2*j, so wall should be 0
    _check("V1b wall=0", wall_v1b < 1e-8,
           f"wall={wall_v1b:.2e}")

    # V2. Rank stability — redundant columns
    print()
    print("  V2. Rank stability (redundant columns)")
    n_v2 = 16
    p_true = 3
    B_base = rng_val.standard_normal((n_v2, p_true))
    # Add two redundant columns (linear combos)
    col_extra1 = B_base[:, 0] + 2.0 * B_base[:, 1]
    col_extra2 = -B_base[:, 2]
    B_redundant = np.column_stack([B_base, col_extra1, col_extra2])
    U_r, sig_r, _ = np.linalg.svd(B_redundant, full_matrices=False)
    p_detected = int(np.sum(sig_r > RANK_TOL * sig_r[0]))
    _check("V2 rank", p_detected == p_true,
           f"detected={p_detected} expected={p_true}")

    # V2b. Haar uniformity — sign balance of random_subspace
    print()
    print("  V2b. Haar uniformity (sign balance, n=2 p=1)")
    n_draws_haar = 2000
    signs = []
    for seed in range(n_draws_haar):
        Q_h = random_subspace(int(2), int(1),
                               np.random.default_rng(int(seed + 50000)))
        signs.append(float(np.sign(Q_h[0, 0])))
    frac_pos = float(sum(1 for s in signs if s > 0)) / float(n_draws_haar)
    # Expect ~0.5; 3σ interval for Bernoulli(0.5, n=2000) is ~0.467..0.533
    _check("V2b Haar sign balance", 0.45 < frac_pos < 0.55,
           f"frac_positive={frac_pos:.3f} (expect ~0.5)")

    # V3. Basis invariance — wall and residual match under rotation
    print()
    print("  V3. Basis invariance (wall under random rotation of B)")
    n_v3 = 32
    p_v3 = 5
    B_v3 = rng_val.standard_normal((n_v3, p_v3))
    d_star_v3 = rng_val.standard_normal(n_v3)
    wall_orig, resid_orig, fb_orig = linf_project(d_star_v3, B_v3)
    # Random orthogonal rotation of the parameter space
    R_orth = np.linalg.qr(rng_val.standard_normal((p_v3, p_v3)))[0]
    B_rot = B_v3 @ R_orth
    wall_rot, resid_rot, fb_rot = linf_project(d_star_v3, B_rot)
    wall_diff = abs(wall_orig - wall_rot)
    resid_diff = np.max(np.abs(resid_orig - resid_rot))
    _check("V3 wall match", wall_diff < 1e-6,
           f"wall_diff={wall_diff:.2e}")
    _check("V3 residual match", resid_diff < 1e-5,
           f"resid_diff={resid_diff:.2e}")

    # V4. Parseval — Walsh level weights sum to mean squared residual
    print()
    print("  V4. Parseval check")
    depth_v4 = 5
    n_v4 = 2**depth_v4
    r_v4 = rng_val.standard_normal(n_v4)
    W_raw_v4, P_norm_v4 = walsh_spectrum(r_v4, depth_v4)
    msr = np.mean(r_v4 ** 2)
    parseval_err = abs(W_raw_v4.sum() - msr)
    _check("V4 Parseval sum", parseval_err < 1e-12,
           f"Σ W^k={W_raw_v4.sum():.12f}  mean(r²)={msr:.12f}  "
           f"err={parseval_err:.2e}")
    pnorm_sum = P_norm_v4.sum()
    _check("V4 P_norm sums to 1", abs(pnorm_sum - 1.0) < 1e-12,
           f"Σ P^k={pnorm_sum:.15f}")

    # V5. ξ_n stability — jitter is inert when ε values are distinct
    print()
    print("  V5. ξ_n jitter stability")
    n_v5 = 64
    eps_distinct = np.linspace(0.01, 0.08, n_v5)  # all distinct
    r_v5 = rng_val.standard_normal(n_v5)
    abs_r_v5 = np.abs(r_v5)
    # V5a: with all-distinct ε, jitter should not change ξ_n at all
    xi_vals_a = []
    for seed in range(100, 110):
        jitter_rng = np.random.default_rng(int(seed))
        eps_max = np.max(eps_distinct)
        jitter = jitter_rng.uniform(-1e-12 * eps_max, 1e-12 * eps_max,
                                     size=n_v5)
        eps_j = eps_distinct + jitter
        xi_result = chatterjeexi(eps_j, abs_r_v5)
        xi_vals_a.append(float(xi_result.statistic))
    xi_vals_a = np.array(xi_vals_a)
    range_a = xi_vals_a.max() - xi_vals_a.min()
    _check("V5a distinct ε: jitter inert", range_a < 1e-10,
           f"range={range_a:.2e}")
    # V5b: with a real extraction, ε(m_mid) are distinct → jitter inert
    cfg_v5 = extract_charybdis_config(3, 5, 'uniform_x', False)
    n_ties = len(cfg_v5["eps_vec"]) - len(np.unique(cfg_v5["eps_vec"]))
    _check("V5b real ε has no ties", n_ties == 0,
           f"n_ties={n_ties} out of {len(cfg_v5['eps_vec'])}")

    # V6. End-to-end: charybdis_stats on a real config
    print()
    print("  V6. End-to-end charybdis_stats")
    cfg_v6 = extract_charybdis_config(3, 5, 'geometric_x', False)
    eps_jit_rng = np.random.default_rng(int(42))
    eps_max_v6 = np.max(cfg_v6["eps_vec"])
    eps_jittered_v6 = cfg_v6["eps_vec"] + eps_jit_rng.uniform(
        -1e-12 * eps_max_v6, 1e-12 * eps_max_v6, size=len(cfg_v6["eps_vec"]))
    stats_fsm = charybdis_stats(cfg_v6["delta_star"], cfg_v6["Q_fsm"],
                                eps_jittered_v6)
    _check("V6 wall > 0", stats_fsm["wall"] > 0,
           f"wall={stats_fsm['wall']:.6f}")
    _check("V6 xi finite", np.isfinite(stats_fsm["xi"]),
           f"xi={stats_fsm['xi']:.4f}")
    _check("V6 Parseval",
           abs(stats_fsm["W_raw"].sum() -
               np.mean(stats_fsm["residual"]**2)) < 1e-12,
           f"Σ W^k={stats_fsm['W_raw'].sum():.8f}")
    _check("V6 P_norm sums to 1",
           abs(stats_fsm["P_norm"].sum() - 1.0) < 1e-12,
           f"Σ P^k={stats_fsm['P_norm'].sum():.15f}")

    # Also test on a random subspace
    Q_rand = random_subspace(int(32), cfg_v6["p"],
                              np.random.default_rng(int(999)))
    stats_rand = charybdis_stats(cfg_v6["delta_star"], Q_rand,
                                  eps_jittered_v6)
    _check("V6 random wall > 0", stats_rand["wall"] > 0,
           f"wall={stats_rand['wall']:.6f}")
    _check("V6 random Parseval",
           abs(stats_rand["W_raw"].sum() -
               np.mean(stats_rand["residual"]**2)) < 1e-12)

    # ── Summary ───────────────────────────────────────────────────────

    print()
    print("=" * 60)
    if all_pass:
        print("All tests passed.")
    else:
        print("SOME TESTS FAILED.")
        sys.exit(1)
