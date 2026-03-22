"""
leading_bit_projection.sage — Leading-bit projection, displacement field,
and ε helpers.

Provides:
- delta_L(m): representation displacement field Δ^L = m - log₂(1+m)
- eps_val(m), eps_prime(m), eps_pp(m): ε and its derivatives
- eps_antideriv(m), mean_cell_eps(a, b): cell-average of ε
- cell_eps_moment1(a, b), cell_eps_moment2(a, b): centered moments
- pi0_inf(f, halves): best piecewise-constant fit under L∞
- pi0_l2(f, halves): best piecewise-constant fit under L2
- R0(f, halves, norm): residual f - Π0(f)
- scale_fit(a, b): best α minimizing ||a - α*b||₂
- nrmse(a, b): normalized RMS error after best scale fit

Not intended to be run directly.
"""

from math import log, log2
import numpy as np

LN2 = log(2.0)
MSTAR = 1.0 / LN2 - 1.0  # ≈ 0.4427


# ── ε and its derivatives ────────────────────────────────────────────

def eps_val(m):
    """Pseudo-log error: ε(m) = log₂(1+m) − m."""
    if m <= 0: return 0.0
    if m >= 1: return 0.0
    return log2(1.0 + m) - m

def eps_prime(m):
    """ε'(m) = 1/((1+m) ln 2) − 1."""
    return 1.0 / ((1.0 + m) * LN2) - 1.0

def eps_pp(m):
    """ε''(m) = −1/((1+m)² ln 2)."""
    return -1.0 / ((1.0 + m)**2 * LN2)

def eps_antideriv(m):
    """Antiderivative of ε(m). ∫₀¹ ε dm = 3/2 − 1/ln2 ≈ 0.0573."""
    if m <= 0: return -1.0 / LN2
    return (1.0 / LN2) * ((1.0 + m) * log(1.0 + m) - (1.0 + m)) - m * m / 2.0

def mean_cell_eps(a, b):
    """Cell-average of ε over [a, b] in mantissa coordinates."""
    if b - a < 1e-15: return eps_val((a + b) / 2.0)
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
        total += (m - mid)**2 * eps_val(m)
    return total * h / (b - a)


def delta_L(m):
    """Representation displacement field: Δ^L(m) = m - log₂(1+m) = -ε(m)."""
    return m - log2(1.0 + m)


def delta_L_field(partition):
    """Evaluate Δ^L at cell midpoints for a partition."""
    result = []
    for row in partition:
        x_mid = float((row['x_lo'] + row['x_hi']) / 2)
        m = x_mid - 1.0  # mantissa
        result.append(delta_L(m))
    return np.array(result)


def leading_bit_halves(partition):
    """Return boolean mask: True for left half (leading bit 0)."""
    N = len(partition)
    return np.array([partition[j]['bits'][0] == 0 for j in range(N)])


def pi0_inf(f, left_mask):
    """Best piecewise-constant fit under L∞ on two leading-bit halves.

    For each half, the L∞-optimal constant is (max + min) / 2.
    Returns the fitted field (same length as f).
    """
    f = np.asarray(f, dtype=float)
    result = np.empty_like(f)
    for mask in [left_mask, ~left_mask]:
        vals = f[mask]
        c = (np.max(vals) + np.min(vals)) / 2.0
        result[mask] = c
    return result


def pi0_l2(f, left_mask):
    """Best piecewise-constant fit under L2 on two leading-bit halves.

    For each half, the L2-optimal constant is the mean.
    Returns the fitted field.
    """
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
    else:
        return f - pi0_l2(f, left_mask)


def scale_fit(a, b):
    """Best scalar α minimizing ||a - α*b||₂."""
    a, b = np.asarray(a, dtype=float), np.asarray(b, dtype=float)
    denom = np.dot(b, b)
    if denom < 1e-30:
        return 0.0
    return np.dot(a, b) / denom


def nrmse(a, b):
    """Normalized RMS error after best scale fit: ||a - α*b||₂ / ||a||₂."""
    a, b = np.asarray(a, dtype=float), np.asarray(b, dtype=float)
    norm_a = np.linalg.norm(a)
    if norm_a < 1e-30:
        return 0.0
    alpha = scale_fit(a, b)
    return np.linalg.norm(a - alpha * b) / norm_a


def cumulative_intercept(bits, c0_rat, delta_rat, q, up_to_layer):
    """Intercept using only layers 0..up_to_layer."""
    from helpers import pathing
    r = 0
    c = float(c0_rat)
    for t in range(up_to_layer + 1):
        b = bits[t]
        # Try layer-dependent key first
        ld_key = (t, r, b)
        li_key = (r, b)
        if ld_key in delta_rat:
            c += float(delta_rat[ld_key])
        elif li_key in delta_rat:
            c += float(delta_rat[li_key])
        r = (2 * r + b) % q
    return c
