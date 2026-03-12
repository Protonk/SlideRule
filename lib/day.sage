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

import math

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


def dyadic_rational(value, bits=20):
    """Round a scalar to the nearest dyadic rational with denominator 2^bits."""
    scale = 2**bits
    return QQ(round(float(value) * scale)) / QQ(scale)


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

def delta_value(delta, layer, state, bit):
    """
    Resolve a policy correction.

    Supported dictionary layouts:
      * delta[(state, bit)]         -- layer-invariant correction
      * delta[(layer, state, bit)]  -- layer-dependent correction

    Missing entries default to 0.
    """
    if delta is None:
        return QQ(0)
    if (layer, state, bit) in delta:
        return QQ(delta[(layer, state, bit)])
    if (state, bit) in delta:
        return QQ(delta[(state, bit)])
    return QQ(0)


def path_intercept(bits, c0, delta, q):
    """
    Walk the residue automaton, accumulating shared corrections.

    Parameters
    ----------
    bits  : tuple of 0/1
    c0    : QQ — base intercept
    delta : dict keyed by (state, bit) or (layer, state, bit)
    q     : int — automaton modulus

    Returns QQ intercept for this path.
    """
    c = QQ(c0)
    r = 0
    for t, b in enumerate(bits):
        c += delta_value(delta, t, r, b)
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


def breakpoint_label(x_plog, plog_lo, plog_hi, p_num, q_den, c_rat):
    """Label a breakpoint as a boundary or Day H-candidate."""
    alpha_q = QQ(p_num) / QQ(q_den)
    u = QQ(c_rat) - alpha_q * QQ(x_plog)
    if x_plog == plog_lo:
        return ('B', 'L', Integer(floor(u)))
    if x_plog == plog_hi:
        return ('B', 'R', Integer(floor(u)))
    return ('H', Integer(u))


def _token_key(token):
    """Deterministic ordering key for candidate labels."""
    return repr(token)


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


# ── Arbitrary-cell evaluator ──────────────────────────────────────────

def _d_candidate_valid(xp_D_plog, k, p_num, q_den, c_rat):
    """
    Verify that the D-candidate at plog=xp_D_plog actually lies on
    the segment where floor(u) = k.

    This is the mandatory second check from the plan: the stationary
    formula and the floor(u)=k verification must agree.
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)
    u = c - alpha_q * QQ(xp_D_plog)
    return Integer(floor(u)) == Integer(k)


def _assert_z_positive(log2_z_val, x_plog, context=""):
    """
    Assert that z(x) > 0 at an evaluated candidate.

    Under the current pexp, z > 0 holds on [1,2) because pexp(u) > 0
    and x > 0.  This guard catches future pexp changes.
    """
    if not (HiR(log2_z_val) > HiR(-1e30)):
        raise AssertionError(
            f"z(x) non-positive at plog={float(x_plog)}: "
            f"log2(z)={float(log2_z_val)} {context}"
        )


def cell_breakpoints_arb(plog_lo, plog_hi, p_num, q_den, c_rat):
    """
    H-grid breakpoints for a cell with arbitrary plog-domain bounds.

    Returns a sorted list of plog values.  Cell endpoints are HiR;
    interior H-candidates are QQ (exact).  All comparisons use HiR.
    """
    alpha = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)

    lo = HiR(plog_lo)
    hi = HiR(plog_hi)

    points = [lo, hi]

    if alpha == 0:
        return points

    u_at_lo = HiR(c) - HiR(alpha) * lo
    u_at_hi = HiR(c) - HiR(alpha) * hi

    for k in range(floor(u_at_hi), ceil(u_at_lo) + 1):
        xp = (c - QQ(k)) / alpha          # exact QQ
        if lo < HiR(xp) < hi:
            points.append(xp)

    return sorted(points, key=lambda p: HiR(p))


def cell_logerr_arb(plog_lo, plog_hi, p_num, q_den, c_rat):
    """
    Arbitrary-cell evaluator — same H/D candidate logic as the exact
    evaluator, with high-precision HiR evaluation.

    Parameters
    ----------
    plog_lo, plog_hi : plog-domain cell bounds (QQ or HiR)
    p_num, q_den     : alpha = p_num / q_den
    c_rat            : QQ intercept

    Returns (log2_zmin, log2_zmax, worst_abs, log2_ratio, meta)
    where meta carries candidate metadata.
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)

    breakpoints = cell_breakpoints_arb(plog_lo, plog_hi, p_num, q_den, c_rat)
    n_bp = len(breakpoints)

    # Build candidate set: breakpoints + D-candidates per segment
    candidates = []

    for idx, bp in enumerate(breakpoints):
        if idx == 0 or idx == n_bp - 1:
            candidates.append((bp, 'endpoint'))
        else:
            candidates.append((bp, 'H'))

    for i in range(n_bp - 1):
        seg_lo = breakpoints[i]
        seg_hi = breakpoints[i + 1]

        seg_mid_hi = (HiR(seg_lo) + HiR(seg_hi)) / 2
        u_mid = HiR(c) - HiR(alpha_q) * seg_mid_hi
        k = Integer(floor(u_mid))

        xp_D = (c - QQ(k)) / (1 + alpha_q)    # exact QQ

        # Check 1: strictly inside segment
        if not (HiR(seg_lo) < HiR(xp_D) < HiR(seg_hi)):
            continue

        # Check 2: floor(u(x_D)) = k  (mandatory validity check)
        if not _d_candidate_valid(xp_D, k, p_num, q_den, c_rat):
            continue

        candidates.append((xp_D, 'D'))

    # Evaluate at all candidates
    evaluated = []
    for plog_val, ctype in candidates:
        val = log2_z_at(plog_val, p_num, q_den, c_rat)
        _assert_z_positive(val, plog_val)
        evaluated.append((plog_val, val, ctype))

    # Concavity consistency check (alpha > 0)
    if alpha_q > 0:
        for i in range(n_bp - 1):
            _segment_concavity_check(i, breakpoints, evaluated)

    values = [v for _, v, _ in evaluated]
    log2_zmin = min(values)
    log2_zmax = max(values)
    worst = max(abs(log2_zmin), abs(log2_zmax))
    ratio = log2_zmax - log2_zmin

    worst_entry = max(evaluated, key=lambda e: abs(e[1]))

    meta = {
        'candidates': [(float(HiR(p)), float(v), t) for p, v, t in evaluated],
        'n_candidates': len(evaluated),
        'worst_type': worst_entry[2],
        'worst_plog': float(HiR(worst_entry[0])),
    }

    return float(log2_zmin), float(log2_zmax), float(worst), float(ratio), meta


def _segment_concavity_check(seg_idx, breakpoints, evaluated):
    """
    On a fixed-k segment with alpha > 0, f = log2(z) is strictly concave.
    A valid D point must be the segment maximizer; the minimum must be
    at a boundary.  Raises AssertionError on violation.
    """
    seg_lo = HiR(breakpoints[seg_idx])
    seg_hi = HiR(breakpoints[seg_idx + 1])
    eps = HiR(10)^(-50)

    d_vals = []
    boundary_vals = []

    for plog_val, val, ctype in evaluated:
        p = HiR(plog_val)
        if p < seg_lo - eps or p > seg_hi + eps:
            continue
        if ctype == 'D':
            d_vals.append(val)
        else:
            boundary_vals.append(val)

    if d_vals and boundary_vals:
        d_max = max(d_vals)
        b_max = max(boundary_vals)
        if d_max < b_max - 1e-10:
            raise AssertionError(
                f"concavity violation on segment {seg_idx}: "
                f"D value {d_max:.15e} < boundary max {b_max:.15e}"
            )


def validate_arb_against_exact(depth, p_num, q_den, c_rat, tol=1e-12, hard_tol=1e-8):
    """
    Validate the arbitrary-cell evaluator against the exact evaluator
    on all uniform_x cells at the given depth.

    Returns (max_discrepancy, n_cells_checked, rows).
    Raises AssertionError if any cell exceeds hard_tol.
    """
    partition = build_partition(depth, kind='uniform_x')
    max_disc = 0.0
    rows = []

    for row in partition:
        exact_zmin, exact_zmax, exact_worst, exact_ratio = cell_exact_logerr(
            row['bits'], p_num, q_den, c_rat
        )
        arb_zmin, arb_zmax, arb_worst, arb_ratio, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], p_num, q_den, c_rat
        )

        disc_worst = abs(exact_worst - arb_worst)
        disc_ratio = abs(exact_ratio - arb_ratio)
        disc = max(disc_worst, disc_ratio)

        if disc > hard_tol:
            raise AssertionError(
                f"arb-cell evaluator disagrees with exact on cell {row['index']} "
                f"(bits={row['bits']}): disc_worst={disc_worst:.2e}, "
                f"disc_ratio={disc_ratio:.2e}, hard_tol={hard_tol}"
            )

        rows.append({
            'index': row['index'],
            'bits': row['bits'],
            'exact_worst': exact_worst,
            'arb_worst': arb_worst,
            'disc_worst': disc_worst,
            'disc_ratio': disc_ratio,
            'n_candidates': meta['n_candidates'],
        })

        if disc > max_disc:
            max_disc = disc

    return max_disc, len(partition), rows


def cell_active_pattern(bits, p_num, q_den, c_rat):
    """
    Extract an exact Day-induced signature for one leaf cell.

    The signature records:
      * indexed breakpoint labels
      * indexed segment min/max active-candidate pairs
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)
    plog_lo, plog_hi = dyadic_cell_plog(bits)
    breakpoints = cell_breakpoints(bits, p_num, q_den, c_rat)

    breakpoint_coords = []
    segment_coords = []
    segment_data = []

    for idx, bp in enumerate(breakpoints):
        breakpoint_coords.append(('BP', idx, breakpoint_label(
            bp, plog_lo, plog_hi, p_num, q_den, c_rat
        )))

    for idx in range(len(breakpoints) - 1):
        seg_lo = breakpoints[idx]
        seg_hi = breakpoints[idx + 1]
        seg_mid = (seg_lo + seg_hi) / 2

        left_label = breakpoint_label(seg_lo, plog_lo, plog_hi, p_num, q_den, c_rat)
        right_label = breakpoint_label(seg_hi, plog_lo, plog_hi, p_num, q_den, c_rat)

        values = [
            (left_label, float(log2_z_at(seg_lo, p_num, q_den, c_rat))),
            (right_label, float(log2_z_at(seg_hi, p_num, q_den, c_rat))),
        ]

        u_mid = c - alpha_q * seg_mid
        k = floor(u_mid)
        xp_D = (c - QQ(k)) / (1 + alpha_q)
        if seg_lo < xp_D < seg_hi:
            d_label = ('D', Integer(k))
            values.append((d_label, float(log2_z_at(xp_D, p_num, q_den, c_rat))))

        min_label, min_value = min(values, key=lambda item: (item[1], _token_key(item[0])))
        max_label, max_value = max(values, key=lambda item: (item[1], _token_key(item[0])))

        segment_token = ('SEG', idx, min_label, max_label)
        segment_coords.append(segment_token)
        segment_data.append({
            "index": idx,
            "segment": (seg_lo, seg_hi),
            "min_label": min_label,
            "max_label": max_label,
            "min_value": min_value,
            "max_value": max_value,
        })

    coords = tuple(breakpoint_coords + segment_coords)

    return {
        "breakpoints": tuple(breakpoints),
        "breakpoint_coords": tuple(breakpoint_coords),
        "segment_coords": tuple(segment_coords),
        "coords": coords,
        "segments": tuple(segment_data),
    }


def active_pattern_vector(bits, p_num, q_den, c_rat, coordinate_index):
    """Encode the exact active-pattern signature as a 0-1 vector."""
    pattern = cell_active_pattern(bits, p_num, q_den, c_rat)
    vec = [0] * len(coordinate_index)
    for coord in pattern["coords"]:
        vec[coordinate_index[coord]] = 1
    return vector(ZZ, vec)


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


def global_exact_metrics(paths, p_num, q_den, c0_rat, delta_rat, q):
    """
    Global metrics across the union of all leaf cells.

    Returns a dict containing:
      * worst_abs              -- sup norm of |log2(z)| over all leaves
      * max_cell_log2_ratio    -- max cellwise log2(zmax/zmin)
      * union_log2_zmin        -- global min over the union of leaves
      * union_log2_zmax        -- global max over the union of leaves
      * union_log2_ratio       -- true global log2(zmax/zmin)
      * cell_data              -- per-cell tuples
    """
    worst_abs = 0.0
    max_cell_ratio = 0.0
    union_log2_zmin = None
    union_log2_zmax = None
    cell_data = []

    for P in paths:
        c = path_intercept(P["bits"], c0_rat, delta_rat, q)
        zmin, zmax, cell_worst, cell_ratio = cell_exact_logerr(
            P["bits"], p_num, q_den, c
        )
        cell_data.append((P["bits"], zmin, zmax, cell_worst, cell_ratio))

        if cell_worst > worst_abs:
            worst_abs = cell_worst
        if cell_ratio > max_cell_ratio:
            max_cell_ratio = cell_ratio
        if union_log2_zmin is None or zmin < union_log2_zmin:
            union_log2_zmin = zmin
        if union_log2_zmax is None or zmax > union_log2_zmax:
            union_log2_zmax = zmax

    return {
        "worst_abs": float(worst_abs),
        "max_cell_log2_ratio": float(max_cell_ratio),
        "union_log2_zmin": float(union_log2_zmin),
        "union_log2_zmax": float(union_log2_zmax),
        "union_log2_ratio": float(union_log2_zmax - union_log2_zmin),
        "cell_data": cell_data,
    }


def build_active_pattern_family(paths, p_num, q_den, c0_rat, delta_rat, q):
    """
    Build the Day-induced vector family from exact active-pattern signatures.

    Returns a dict with coordinates, per-path pattern data, and the deduplicated
    0-1 vector family used for additive diagnostics.
    """
    pattern_rows = []
    all_coords = []

    for P in paths:
        c = path_intercept(P["bits"], c0_rat, delta_rat, q)
        pattern = cell_active_pattern(P["bits"], p_num, q_den, c)
        pattern_rows.append({
            "bits": P["bits"],
            "intercept": c,
            "pattern": pattern,
        })
        all_coords.extend(pattern["coords"])

    coordinate_keys = sorted(set(all_coords), key=repr)
    coordinate_index = {coord: idx for idx, coord in enumerate(coordinate_keys)}

    unique_vectors = []
    unique_index = {}
    unique_rows = []
    multiplicities = []

    for row in pattern_rows:
        vec = active_pattern_vector(row["bits"], p_num, q_den, row["intercept"], coordinate_index)
        key = tuple(vec)
        if key in unique_index:
            multiplicities[unique_index[key]] += 1
            continue
        unique_index[key] = len(unique_vectors)
        unique_vectors.append(vec)
        multiplicities.append(1)
        unique_rows.append({
            "bits": row["bits"],
            "intercept": row["intercept"],
            "pattern": row["pattern"],
            "vector": vec,
        })

    return {
        "coordinate_keys": tuple(coordinate_keys),
        "coordinate_index": coordinate_index,
        "rows": tuple(pattern_rows),
        "unique_rows": tuple(unique_rows),
        "unique_vectors": tuple(unique_vectors),
        "multiplicities": tuple(multiplicities),
    }


def _golden_section_minimize(func, lo, hi, tol=1e-12, maxiter=200):
    """Simple bounded scalar minimization without external dependencies."""
    phi = (math.sqrt(5.0) - 1.0) / 2.0
    a = float(lo)
    b = float(hi)
    c = b - phi * (b - a)
    d = a + phi * (b - a)
    fc = func(c)
    fd = func(d)

    for _ in range(maxiter):
        if abs(b - a) <= tol:
            break
        if fc <= fd:
            b = d
            d = c
            fd = fc
            c = b - phi * (b - a)
            fc = func(c)
        else:
            a = c
            c = d
            fc = fd
            d = a + phi * (b - a)
            fd = func(d)

    x_opt = (a + b) / 2.0
    return x_opt, func(x_opt)


def best_single_intercept(paths, p_num, q_den, c_init=None, span=2.0, dyadic_bits=20):
    """
    Optimize a single global intercept c with delta = 0.

    This is the correct baseline against which shared-delta FSM policies
    should be compared.
    """
    alpha_q = QQ(p_num) / QQ(q_den)
    if c_init is None:
        c_init = float(QQ(1 - alpha_q) / 2)

    def objective(c_val):
        metrics = global_exact_metrics(
            paths, p_num, q_den, dyadic_rational(c_val, dyadic_bits), None, 1
        )
        return metrics["worst_abs"]

    c_float, _ = _golden_section_minimize(
        objective,
        c_init - span,
        c_init + span,
        tol=1e-12,
        maxiter=250,
    )
    c_opt = dyadic_rational(c_float, dyadic_bits)
    metrics = global_exact_metrics(paths, p_num, q_den, c_opt, None, 1)

    return {
        "c0_rat": c_opt,
        "worst_abs": metrics["worst_abs"],
        "union_log2_ratio": metrics["union_log2_ratio"],
        "max_cell_log2_ratio": metrics["max_cell_log2_ratio"],
        "metrics": metrics,
    }
