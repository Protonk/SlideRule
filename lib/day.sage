"""
Layer 2 — Day-style coarse-stage evaluator.

Pseudolog / pseudo-exp maps, dyadic cell addressing, and both a
sampled evaluator and an exact H/V/D evaluator adapted from
trajectory_experiment.py (see lib/trajectory.py for the original).

Within one octave [1,2), plog(x) = x - 1 is smooth.  The only
breakpoints in the error factor come from the output pseudolog
u = c - alpha * plog(x) crossing an integer (Day's H-grid).
Between consecutive breakpoints, the unique interior extremum is
Day's D-candidate (stationary point).  V-grid crossings (octave
boundaries) do not appear inside a single octave.

Error factor:
    z(x) = pexp(c - alpha * plog(x)) * x^alpha
    log2(z) = floor(u) + log2(1 + frac(u)) + alpha * log2(x)

D-candidate on a segment where floor(u) = k:
    x_plog_D = (c - k) / (1 + alpha)
"""

# High-precision reals — used for transcendental evaluation.
# Breakpoint locations are computed in exact QQ arithmetic.
HiR = RealField(200)
LN2 = HiR(2).log()


# ── plog / pexp ──────────────────────────────────────────────────────────

def plog(x):
    """Pseudologarithm: piecewise-linear approx to log2."""
    x = HiR(x)
    e = floor(log(x, 2))
    return HiR(e) + x / HiR(2)**e - 1


def pexp(t):
    """Pseudo-exponential: piecewise-linear approx to 2^t."""
    t = HiR(t)
    e = floor(t)
    return HiR(2)**e * (1 + (t - e))


# ── Dyadic cells ────────────────────────────────────────────────────────

def dyadic_cell_bounds(bits):
    """
    Map a bit-prefix to a sub-interval of [1,2).

    bits = (b1,...,bm) selects [1 + j/2^m, 1 + (j+1)/2^m)
    where j = sum_i b_i * 2^{m-1-i}.

    Returns (lo, hi) as HiR values.
    """
    m = len(bits)
    j = sum(Integer(bits[i]) * 2^(m - 1 - i) for i in range(m))
    lo = HiR(1) + HiR(j) / HiR(2)**m
    hi = HiR(1) + HiR(j + 1) / HiR(2)**m
    return lo, hi


def dyadic_cell_plog(bits):
    """
    Plog-domain bounds for a dyadic cell: [j/2^m, (j+1)/2^m) in QQ.
    """
    m = len(bits)
    j = sum(Integer(bits[i]) * 2^(m - 1 - i) for i in range(m))
    return QQ(j) / QQ(2^m), QQ(j + 1) / QQ(2^m)


# ── FSM intercept ───────────────────────────────────────────────────────

def path_intercept(bits, c0, delta, q):
    """
    Walk the residue automaton, accumulating shared corrections.

    Parameters
    ----------
    bits  : tuple of 0/1
    c0    : QQ — base intercept
    delta : dict (state, bit) -> QQ correction
    q     : int — automaton modulus

    Returns QQ intercept for this path.
    """
    c = QQ(c0)
    r = 0
    for b in bits:
        c += QQ(delta[(r, b)])
        r = (2*r + b) % q
    return c


# ── Sampled evaluator (kept for validation) ─────────────────────────────

def cell_logerr_sampled(bits, alpha, c, nsamp=256):
    """Sampled worst-case |log2(z)| on a dyadic cell."""
    lo, hi = dyadic_cell_bounds(bits)
    alpha = HiR(alpha)
    c = HiR(c)
    worst = HiR(0)
    for k in range(nsamp + 1):
        x = lo + (hi - lo) * HiR(k) / nsamp
        target = x**(-alpha)
        approx = pexp(c - alpha * plog(x))
        if approx <= 0:
            return HiR(999)
        err = abs(log(abs(target / approx), 2))
        if err > worst:
            worst = err
    return worst


# ── Exact H/V/D evaluator ──────────────────────────────────────────────

def cell_breakpoints(bits, p_num, q_den, c_rat):
    """
    Plog-domain points where the error function has a slope
    discontinuity (output pseudolog u crosses an integer).

    Returns sorted list of QQ values in [plog_lo, plog_hi].
    """
    alpha = QQ(p_num) / QQ(q_den)
    plog_lo, plog_hi = dyadic_cell_plog(bits)
    c = QQ(c_rat)

    points = [plog_lo, plog_hi]

    if alpha == 0:
        return points

    u_at_lo = c - alpha * plog_lo
    u_at_hi = c - alpha * plog_hi

    for k in range(floor(u_at_hi), ceil(u_at_lo) + 1):
        xp = (c - QQ(k)) / alpha
        if plog_lo < xp < plog_hi:
            points.append(xp)

    return sorted(set(points))


def log2_z_at(x_plog, p_num, q_den, c_rat):
    """
    Evaluate log2(z) at a single plog-domain point.

    Uses exact QQ for breakpoint structure, HiR for the
    transcendental part (log2(1 + f) and log2(x)).
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)
    u = c - alpha_q * x_plog

    s = floor(u)
    f = u - s

    x_hi = HiR(1) + HiR(x_plog)
    alpha_hi = HiR(alpha_q)

    log2_pexp = HiR(s) + (HiR(1) + HiR(f)).log() / LN2
    log2_x = x_hi.log() / LN2

    return log2_pexp + alpha_hi * log2_x


def cell_exact_logerr(bits, p_num, q_den, c_rat):
    """
    Exact worst-case error on a dyadic cell using Day's H/V/D
    candidate set.

    Returns (log2_zmin, log2_zmax, worst_abs, log2_ratio)
    where log2_ratio = log2(zmax/zmin).
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)

    breakpoints = cell_breakpoints(bits, p_num, q_den, c_rat)
    candidates = list(breakpoints)

    for i in range(len(breakpoints) - 1):
        seg_lo = breakpoints[i]
        seg_hi = breakpoints[i + 1]

        seg_mid = (seg_lo + seg_hi) / 2
        u_mid = c - alpha_q * seg_mid
        k = floor(u_mid)

        xp_D = (c - QQ(k)) / (1 + alpha_q)
        if seg_lo < xp_D < seg_hi:
            candidates.append(xp_D)

    candidates = sorted(set(candidates))
    values = [log2_z_at(xp, p_num, q_den, c_rat) for xp in candidates]

    log2_zmin = min(values)
    log2_zmax = max(values)
    worst = max(abs(log2_zmin), abs(log2_zmax))
    ratio = log2_zmax - log2_zmin

    return float(log2_zmin), float(log2_zmax), float(worst), float(ratio)


def global_exact_error(paths, p_num, q_den, c0_rat, delta_rat, q):
    """
    Exact worst-case error and zmax/zmin ratio over all leaf cells.

    Returns (worst_abs, worst_ratio, cell_data).
    """
    worst_abs = 0.0
    worst_ratio = 0.0
    cell_data = []

    for P in paths:
        c = path_intercept(P["bits"], c0_rat, delta_rat, q)
        zmin, zmax, cell_worst, cell_ratio = cell_exact_logerr(
            P["bits"], p_num, q_den, c
        )
        cell_data.append((P["bits"], zmin, zmax, cell_worst, cell_ratio))
        if cell_worst > worst_abs:
            worst_abs = cell_worst
        if cell_ratio > worst_ratio:
            worst_ratio = cell_ratio

    return worst_abs, worst_ratio, cell_data
