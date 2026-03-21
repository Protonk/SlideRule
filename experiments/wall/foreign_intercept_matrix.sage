"""
foreign_intercept_matrix.sage — Foreign-intercept excess matrix F[j][k].

F[j][k] = err_on_cell_k(c_free_j) - err_on_cell_k(c_free_k)

This measures the excess error on cell k when forced to use cell j's
free-optimal intercept instead of its own.  Both sides are evaluated
via cell_logerr_arb for exact worst-case computation.

The diagonal is zero by construction: F[k][k] = 0.

Not intended to be run directly.  Loaded by exchange-rate scripts.
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))


def build_foreign_intercept_matrix(partition, free_rows, p_num, q_den):
    """Build F[j][k] = excess error on cell k using cell j's free intercept.

    Parameters
    ----------
    partition : list of row dicts from build_partition
    free_rows : list of row dicts from free_per_cell_metrics()["rows"]
    p_num, q_den : int — target exponent numerator/denominator

    Returns
    -------
    F : list of lists (N x N), F[j][k] = excess error
    free_errs : list of floats, free_errs[k] = cell k's free error
    free_intercepts : list of QQ, free_intercepts[k] = cell k's c_opt
    """
    N = len(partition)

    # Build lookup from bits -> free row
    free_by_bits = {}
    for fr in free_rows:
        free_by_bits[fr['bits']] = fr

    # Collect cell geometry and free intercepts in partition order
    cells = []
    for row in partition:
        fr = free_by_bits[row['bits']]
        cells.append({
            'plog_lo': QQ(row['plog_lo']),
            'plog_hi': QQ(row['plog_hi']),
            'c_free': QQ(fr['c_opt']),
            'free_err': float(fr['cell_worst']),
        })

    free_errs = [c['free_err'] for c in cells]
    free_intercepts = [c['c_free'] for c in cells]

    # Build F matrix
    F = [[0.0] * N for _ in range(N)]
    for j in range(N):
        c_j = cells[j]['c_free']
        for k in range(N):
            if j == k:
                continue  # F[k][k] = 0 by construction
            _, _, worst_abs, _, _ = cell_logerr_arb(
                cells[k]['plog_lo'], cells[k]['plog_hi'],
                p_num, q_den, c_j)
            F[j][k] = float(worst_abs) - cells[k]['free_err']

    return F, free_errs, free_intercepts


def best_donor(F, j):
    """Find the best non-self donor for cell j.

    Returns (donor_index, donor_excess).  Ties broken by lowest index.
    """
    N = len(F)
    best_k = None
    best_excess = float('inf')
    for k in range(N):
        if k == j:
            continue
        if F[k][j] < best_excess:
            best_excess = F[k][j]
            best_k = k
    return best_k, best_excess
