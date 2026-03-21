"""
leading_bit_projection.sage — Leading-bit projection and displacement field.

Provides:
- delta_L(m): representation displacement field Δ^L = m - log₂(1+m)
- pi0_inf(f, halves): best piecewise-constant fit under L∞
- pi0_l2(f, halves): best piecewise-constant fit under L2
- R0(f, halves, norm): residual f - Π0(f)
- scale_fit(a, b): best α minimizing ||a - α*b||₂
- nrmse(a, b): normalized RMS error after best scale fit

Not intended to be run directly.
"""

from math import log2
import numpy as np


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
