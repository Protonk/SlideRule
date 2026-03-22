"""
lib/displacement.sage — Displacement-field and leading-bit projection helpers.

This module is intentionally standalone: it depends only on `math` and
`numpy`, and it works with partition rows that expose `x_lo`, `x_hi`, and
`bits`.
"""

from math import log, log2
import numpy as np

LN2 = log(2.0)
MSTAR = 1.0 / LN2 - 1.0  # ≈ 0.4427


def _partition_domain(partition):
    """Infer the x-domain from a partition."""
    if not partition:
        raise ValueError("partition must be non-empty")
    x_start = float(partition[0]['x_lo'])
    x_end = float(partition[-1]['x_hi'])
    x_width = x_end - x_start
    if x_width <= 0:
        raise ValueError("partition must have positive width")
    return x_start, x_width


def _normalized_midpoints(partition):
    """Return cell midpoints in normalized mantissa coordinates."""
    x_start, x_width = _partition_domain(partition)
    return np.array([
        (float((row['x_lo'] + row['x_hi']) / 2) - x_start) / x_width
        for row in partition
    ], dtype=float)


def _safe_corr(a, b):
    """Return correlation or NaN when either input is effectively constant."""
    if np.std(a) < 1e-15 or np.std(b) < 1e-15:
        return float('nan')
    return float(np.corrcoef(a, b)[0, 1])


# ── ε and its derivatives ────────────────────────────────────────────

def eps_val(m):
    """Pseudo-log error: ε(m) = log₂(1+m) − m on normalized mantissa m ∈ [0,1)."""
    if m <= 0:
        return 0.0
    if m >= 1:
        return 0.0
    return log2(1.0 + m) - m


def eps_prime(m):
    """ε'(m) = 1/((1+m) ln 2) − 1."""
    return 1.0 / ((1.0 + m) * LN2) - 1.0


def eps_pp(m):
    """ε''(m) = −1/((1+m)² ln 2)."""
    return -1.0 / ((1.0 + m) ** 2 * LN2)


def eps_antideriv(m):
    """Antiderivative of ε(m)."""
    if m <= 0:
        return -1.0 / LN2
    return (1.0 / LN2) * ((1.0 + m) * log(1.0 + m) - (1.0 + m)) - m * m / 2.0


def mean_cell_eps(a, b):
    """Cell-average of ε over [a, b] in normalized mantissa coordinates."""
    if b - a < 1e-15:
        return eps_val((a + b) / 2.0)
    return (eps_antideriv(b) - eps_antideriv(a)) / (b - a)


def cell_eps_moment1(a, b):
    """Centered first moment: ∫(m − m_mid)·ε(m)dm / (b−a), numerical."""
    mid = (a + b) / 2.0
    n = 32
    h = (b - a) / n
    total = 0.0
    for i in range(n):
        m = a + (i + 0.5) * h
        total += (m - mid) * eps_val(m)
    return total * h / (b - a)


def cell_eps_moment2(a, b):
    """Centered second moment: ∫(m − m_mid)²·ε(m)dm / (b−a), numerical."""
    mid = (a + b) / 2.0
    n = 32
    h = (b - a) / n
    total = 0.0
    for i in range(n):
        m = a + (i + 0.5) * h
        total += (m - mid) ** 2 * eps_val(m)
    return total * h / (b - a)


def delta_L(m):
    """Representation displacement field: Δ^L(m) = m - log₂(1+m) = -ε(m)."""
    return m - log2(1.0 + m)


def delta_L_field(partition):
    """Evaluate Δ^L at normalized cell midpoints for a partition."""
    return np.array([delta_L(m) for m in _normalized_midpoints(partition)], dtype=float)


def leading_bit_halves(partition):
    """Return boolean mask: True for left half (leading bit 0)."""
    return np.array([row['bits'][0] == 0 for row in partition], dtype=bool)


def pi0_inf(f, left_mask):
    """Best piecewise-constant fit under L∞ on the two leading-bit halves."""
    f = np.asarray(f, dtype=float)
    result = np.empty_like(f)
    for mask in [left_mask, ~left_mask]:
        vals = f[mask]
        c = (np.max(vals) + np.min(vals)) / 2.0
        result[mask] = c
    return result


def pi0_l2(f, left_mask):
    """Best piecewise-constant fit under L2 on the two leading-bit halves."""
    f = np.asarray(f, dtype=float)
    result = np.empty_like(f)
    for mask in [left_mask, ~left_mask]:
        result[mask] = np.mean(f[mask])
    return result


def R0(f, left_mask, norm='inf'):
    """Residual after leading-bit projection: f - Π0(f)."""
    f = np.asarray(f, dtype=float)
    if norm == 'inf':
        return f - pi0_inf(f, left_mask)
    return f - pi0_l2(f, left_mask)


def scale_fit(a, b):
    """Best scalar α minimizing ||a - α*b||₂."""
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    denom = np.dot(b, b)
    if denom < 1e-30:
        return 0.0
    return np.dot(a, b) / denom


def nrmse(a, b):
    """Normalized RMS error after best scale fit: ||a - α*b||₂ / ||a||₂."""
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    norm_a = np.linalg.norm(a)
    if norm_a < 1e-30:
        return 0.0
    alpha = scale_fit(a, b)
    return np.linalg.norm(a - alpha * b) / norm_a


def stage_a_metrics(partition, c_star):
    """Compute the Stage A metric bundle for one partition/intercept field."""
    c_star = np.asarray(c_star, dtype=float)
    left = leading_bit_halves(partition)
    dL = delta_L_field(partition)

    g_inf = R0(c_star, left, 'inf')
    g_l2 = R0(c_star, left, 'l2')
    r0_dL_inf = R0(dL, left, 'inf')
    r0_dL_l2 = R0(dL, left, 'l2')

    return {
        'corr_inf': _safe_corr(g_inf, r0_dL_inf),
        'corr_l2': _safe_corr(g_l2, r0_dL_l2),
        'nrmse_inf': nrmse(g_inf, r0_dL_inf),
        'nrmse_l2': nrmse(g_l2, r0_dL_l2),
        'residual_norm_inf': float(np.max(np.abs(g_inf))),
        'residual_norm_2': float(np.linalg.norm(g_inf)),
    }


def coupling_diagnostics(partition):
    """Compute width/peak coupling diagnostics for one partition."""
    widths = np.array([
        float(row['x_hi'] - row['x_lo'])
        for row in partition
    ], dtype=float)
    m_mids = _normalized_midpoints(partition)
    peak_dists = np.array([-abs(m - MSTAR) for m in m_mids], dtype=float)

    if np.std(widths) > 1e-15 and np.std(peak_dists) > 1e-15:
        rho_peak = float(np.corrcoef(widths, peak_dists)[0, 1])
    else:
        rho_peak = float('nan')

    eps_at_mids = np.array([eps_val(m) for m in m_mids], dtype=float)
    eps_sum = np.sum(eps_at_mids)
    if eps_sum > 1e-15:
        mean_width_eps = float(np.sum(widths * eps_at_mids) / eps_sum)
    else:
        mean_width_eps = float('nan')

    return {
        'rho_peak': rho_peak,
        'mean_width_eps': mean_width_eps,
    }
