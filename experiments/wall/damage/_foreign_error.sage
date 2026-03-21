"""
_foreign_error.sage — Foreign-chord error matrix construction.

Builds E[j][k] = peak |log2(m) - chord_j(m)| on cell k, where chord_j is
the affine approximation to log2 anchored at cell j.  The diagonal E[j][j]
is the native chord error.

Not intended to be run directly.  Loaded by damage visualization scripts.
"""

from math import log, log2


def cell_chord(a, b):
    """Chord slope and intercept of log2 on [a, b]."""
    la, lb = log2(a), log2(b)
    sigma = (lb - la) / (b - a)
    return sigma, la


def chord_eval(sigma, intercept, a, m):
    """Evaluate the chord anchored at (a, intercept) with slope sigma."""
    return intercept + sigma * (m - a)


def _foreign_peak_error(sigma_j, intercept_j, a_j, a_k, b_k):
    """Peak |log2(m) - chord_j(m)| on [a_k, b_k]."""
    f_at_a = log2(a_k) - chord_eval(sigma_j, intercept_j, a_j, a_k)
    f_at_b = log2(b_k) - chord_eval(sigma_j, intercept_j, a_j, b_k)
    best = max(abs(f_at_a), abs(f_at_b))

    if sigma_j > 0:
        m_star_j = 1.0 / (sigma_j * log(2.0))
        if a_k < m_star_j < b_k:
            f_at_star = log2(m_star_j) - chord_eval(
                sigma_j, intercept_j, a_j, m_star_j
            )
            best = max(best, abs(f_at_star))

    return best


def build_error_matrix(cells):
    """E[j][k] = peak |log2 - chord_j| on cell k."""
    N = len(cells)
    E = [[0.0] * N for _ in range(N)]
    chords = [cell_chord(a, b) for a, b in cells]

    for j in range(N):
        sigma_j, intercept_j = chords[j]
        a_j = cells[j][0]
        for k in range(N):
            a_k, b_k = cells[k]
            E[j][k] = _foreign_peak_error(sigma_j, intercept_j, a_j, a_k, b_k)

    return E


def _lower_median(vals):
    """Median biased low for even-length lists."""
    return vals[(len(vals) - 1) // 2]
