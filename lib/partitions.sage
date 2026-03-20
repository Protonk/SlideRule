"""
lib/partitions.sage — Partition geometry for [x_start, x_start + x_width).

Twenty-three partition kinds:
    uniform_x            — equal additive width
    geometric_x          — equal log-width
    harmonic_x           — equal spacing in 1/x (finer near x_start)
    mirror_harmonic_x    — mirrored reciprocal (finer near x_start + x_width)
    ruler_x              — widths from 2-adic valuation (fractal, self-similar)
    sinusoidal_x         — density oscillates in log-space (periodic ripple)
    chebyshev_x          — Clenshaw-Curtis points (dense at both endpoints)
    thuemorse_x          — Thue-Morse binary sequence widths (anti-ruler)
    bitrev_geometric_x   — geometric widths scattered by bit-reversal
    stern_brocot_x       — boundaries from iterated mediant insertion
    reverse_geometric_x  — geometric backwards (dense at x_end)
    random_x             — sorted uniform random breakpoints (null model)
    dyadic_x             — geometric targets snapped to dyadic rationals
    powerlaw_x           — density ~ m^{-p}, aggressive left-packing
    golden_x             — golden-ratio Kronecker sequence breakpoints
    cantor_x             — Cantor dust: cells in surviving middle-third intervals
    farey_rank_x         — Farey sequence rank-subsampled boundaries
    radical_inverse_x    — van der Corput low-discrepancy sequence
    sturmian_x           — Sturmian word (irrational rotation) widths
    beta_x               — Beta distribution CDF-inverted breakpoints
    arc_length_x         — equal arc-length cells on 1/(x ln 2)
    minimax_chord_x      — minimax chord error equi-oscillation

Default domain is [1, 2) (x_start=1, x_width=1).

A partition is a list of row dicts ordered by cell index j = 0..2^depth-1.
Each row carries: index, bits, x_lo, x_hi, plog_lo, plog_hi, width_x,
width_log, kind, x_start, x_width.

Depends on: lib/day.sage must be loaded first (provides HiR, LN2).
"""


PARTITION_KINDS = ('uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x',
                   'ruler_x', 'sinusoidal_x', 'chebyshev_x', 'thuemorse_x',
                   'bitrev_geometric_x', 'stern_brocot_x', 'reverse_geometric_x',
                   'random_x', 'dyadic_x', 'powerlaw_x', 'golden_x', 'cantor_x',
                   'farey_rank_x', 'radical_inverse_x',
                   'sturmian_x', 'beta_x', 'arc_length_x', 'minimax_chord_x')
PARTITION_KIND_ALIASES = {
    'reciprocal_x': 'harmonic_x',
    'mirror_reciprocal_x': 'mirror_harmonic_x',
}


def normalize_partition_kind(kind):
    """Map legacy or descriptive aliases onto canonical partition names."""
    if kind in PARTITION_KIND_ALIASES:
        return PARTITION_KIND_ALIASES[kind]
    if kind in PARTITION_KINDS:
        return kind
    raise ValueError(
        f"unknown partition kind: {kind!r}; expected one of "
        f"{PARTITION_KINDS} or aliases {tuple(PARTITION_KIND_ALIASES)}"
    )


def _validate_finite(*args):
    """Raise ValueError if any argument is NaN or infinity."""
    import math as _m
    for v in args:
        fv = float(v)
        if not _m.isfinite(fv):
            raise ValueError(f"parameter must be finite, got {v}")


def _coerce_finite_int(name, value):
    """Return int(value), but fail cleanly on NaN/infinity."""
    _validate_finite(value)
    try:
        return int(value)
    except (TypeError, ValueError, OverflowError) as exc:
        raise ValueError(f"{name} must be integer-convertible, got {value}") from exc


def bits_to_index(bits):
    """Convert a bit-prefix tuple to an integer cell index."""
    m = len(bits)
    return sum(Integer(bits[i]) * 2^(m - 1 - i) for i in range(m))


def index_to_bits(index, depth):
    """Convert an integer cell index to a bit-prefix tuple."""
    return tuple((index >> (depth - 1 - i)) & 1 for i in range(depth))


def _ruler_boundaries(N, a_qq, w_qq):
    """Compute N+1 boundary points for the ruler partition in QQ."""
    # Raw width of cell j is 2^{-v2(j+1)}.
    raw = [QQ(2)**(-Integer(j + 1).valuation(2)) for j in range(N)]
    W = sum(raw)
    cum = [QQ(0)]
    s = QQ(0)
    for wj in raw:
        s += wj
        cum.append(s)
    return [a_qq + w_qq * c / W for c in cum]


def _sinusoidal_boundaries(N, a_hir, x_end_hir, sin_k, sin_alpha):
    """Compute N+1 boundary points for the sinusoidal partition via bisection."""
    import math
    k = int(sin_k)
    alpha = float(sin_alpha)
    twopik = 2.0 * math.pi * k
    coeff = alpha / twopik

    def F(t):
        return t - coeff * math.sin(twopik * t)

    # Invert F at targets j/N for j = 0..N.
    t_vals = [0.0]
    for j in range(1, N):
        target = j / N
        lo, hi = 0.0, 1.0
        for _ in range(60):
            mid = (lo + hi) / 2.0
            if F(mid) < target:
                lo = mid
            else:
                hi = mid
        t_vals.append((lo + hi) / 2.0)
    t_vals.append(1.0)

    # Map from log-space t to x-space: x = a * (x_end/a)^t
    a_f = float(a_hir)
    r = float(x_end_hir) / a_f
    return [HiR(a_f * r**t) for t in t_vals]


def _chebyshev_boundaries(N, a_hir, w_hir):
    """Compute N+1 Clenshaw-Curtis boundary points mapped to [a, a+w]."""
    # Chebyshev extrema: t_j = cos(j*pi/N) for j=0..N, mapped from [-1,1].
    # x_j = a + w * (1 - cos(j*pi/N)) / 2.
    import sage.all
    bdry = []
    for j in range(N + 1):
        cos_val = sage.all.cos(sage.all.pi * j / N)
        bdry.append(a_hir + w_hir * (HiR(1) - HiR(cos_val)) / HiR(2))
    return bdry


def _thuemorse_boundaries(N, a_qq, w_qq, tm_ratio):
    """Compute N+1 boundary points for Thue-Morse weighted widths in QQ."""
    tm_ratio_qq = QQ(tm_ratio)
    raw = []
    for j in range(N):
        # Thue-Morse bit: parity of popcount(j).
        pc = Integer(j).popcount()
        raw.append(tm_ratio_qq if pc % 2 == 0 else QQ(1))
    W = sum(raw)
    cum = [QQ(0)]
    s = QQ(0)
    for wj in raw:
        s += wj
        cum.append(s)
    return [a_qq + w_qq * c / W for c in cum]


def _bitrev(j, depth):
    """Reverse the depth-bit binary representation of j."""
    result = 0
    for _ in range(depth):
        result = (result << 1) | (j & 1)
        j >>= 1
    return result


def _bitrev_geometric_boundaries(N, depth, a_hir, x_end_hir):
    """Compute N+1 boundary points: geometric widths permuted by bit-reversal."""
    # Geometric widths in natural order.
    r = x_end_hir / a_hir
    geo_widths = []
    for j in range(N):
        x_lo = a_hir * r ^ (HiR(j) / HiR(N))
        x_hi = a_hir * r ^ (HiR(j + 1) / HiR(N))
        geo_widths.append(x_hi - x_lo)
    # Permute: cell at position j gets width from geometric cell bitrev(j).
    perm_widths = [geo_widths[_bitrev(j, depth)] for j in range(N)]
    # Cumulative sum for boundaries.
    bdry = [a_hir]
    s = a_hir
    for wj in perm_widths:
        s = s + wj
        bdry.append(s)
    return bdry


def _stern_brocot_boundaries(depth, a_qq, x_end_qq):
    """Compute 2^depth + 1 boundary points by mediants on [0,1], then scale."""
    # The Stern-Brocot refinement lives naturally on [0,1].  Building it there
    # and then affinely scaling preserves the claimed Minkowski equivalence on
    # arbitrary domains, rather than only on [1,2).
    unit = [QQ(0), QQ(1)]
    for _ in range(depth):
        new_unit = [unit[0]]
        for i in range(len(unit) - 1):
            # Mediant of p1/q1 and p2/q2 = (p1+p2)/(q1+q2).
            p1, q1 = unit[i].numerator(), unit[i].denominator()
            p2, q2 = unit[i + 1].numerator(), unit[i + 1].denominator()
            med = QQ(p1 + p2) / QQ(q1 + q2)
            new_unit.append(med)
            new_unit.append(unit[i + 1])
        unit = new_unit
    a = QQ(a_qq)
    w = QQ(x_end_qq) - a
    return [a + w * t for t in unit]


def _reverse_geometric_boundaries(N, depth, a_hir, x_end_hir):
    """Compute N+1 boundary points: geometric widths in reverse order."""
    r = x_end_hir / a_hir
    geo_widths = []
    for j in range(N):
        x_lo = a_hir * r ^ (HiR(j) / HiR(N))
        x_hi = a_hir * r ^ (HiR(j + 1) / HiR(N))
        geo_widths.append(x_hi - x_lo)
    rev_widths = list(reversed(geo_widths))
    bdry = [a_hir]
    s = a_hir
    for wj in rev_widths:
        s = s + wj
        bdry.append(s)
    return bdry


def _random_boundaries(N, a_hir, w_hir, seed):
    """Compute N+1 boundary points from sorted uniform random breakpoints."""
    import random as _rng
    _rng.seed(int(seed))
    pts = sorted([_rng.random() for _ in range(N - 1)])
    a_f = float(a_hir)
    w_f = float(w_hir)
    return [a_hir] + [HiR(a_f + w_f * t) for t in pts] + [a_hir + w_hir]


def _dyadic_boundaries(N, a_hir, x_end_hir, dyadic_res):
    """Compute N+1 boundary points: geometric targets snapped to dyadic rationals."""
    R = int(dyadic_res)
    scale = QQ(2)**R
    a_f = float(a_hir)
    r = float(x_end_hir) / a_f
    bdry = [a_hir]
    for j in range(1, N):
        target = a_f * r**(j / N)
        snapped_qq = QQ(round(target * float(scale))) / scale
        bdry.append(HiR(snapped_qq))
    bdry.append(x_end_hir)
    return bdry


def _powerlaw_boundaries(N, a_hir, x_end_hir, pl_exponent):
    """Compute N+1 boundary points for density ~ m^{-p}."""
    import math
    p = float(pl_exponent)
    a_f = float(a_hir)
    xe_f = float(x_end_hir)
    # CDF inversion: x_j = (a^{1-p} + (j/N)*(x_end^{1-p} - a^{1-p}))^{1/(1-p)}
    exp = 1.0 - p
    a_exp = a_f**exp
    xe_exp = xe_f**exp
    bdry = []
    for j in range(N + 1):
        val = (a_exp + (j / N) * (xe_exp - a_exp))**(1.0 / exp)
        bdry.append(HiR(val))
    # Force exact endpoints.
    bdry[0] = a_hir
    bdry[N] = x_end_hir
    return bdry


def _golden_boundaries(N, a_hir, w_hir):
    """Compute N+1 boundary points from sorted golden-ratio Kronecker sequence."""
    import math
    # Use math.fmod to avoid Sage RealLiteral modulo semantics (centered at 0).
    phi = float((1.0 + math.sqrt(5.0)) / 2.0)
    pts = sorted([math.fmod(float(j) * phi, 1.0) for j in range(1, int(N))])
    a_f = float(a_hir)
    w_f = float(w_hir)
    return [a_hir] + [HiR(a_f + w_f * t) for t in pts] + [a_hir + w_hir]


def _cantor_boundaries(N, a_hir, w_hir, cantor_levels):
    """Compute N+1 boundary points: cells distributed in Cantor-dust intervals."""
    # Build surviving intervals in [0, 1] after L rounds of middle-third removal.
    L = int(cantor_levels)
    intervals = [(0.0, 1.0)]
    for _ in range(L):
        new_intervals = []
        for lo, hi in intervals:
            third = (hi - lo) / 3.0
            new_intervals.append((lo, lo + third))
            new_intervals.append((hi - third, hi))
        intervals = new_intervals
    # We have 2^L surviving intervals.  Distribute N cells among them.
    n_intervals = len(intervals)  # = 2^L
    cells_per = N // n_intervals
    remainder = N - cells_per * n_intervals
    # Assign cells_per to each interval, +1 to the first 'remainder' intervals.
    a_f = float(a_hir)
    w_f = float(w_hir)
    bdry = [a_hir]
    for idx, (lo, hi) in enumerate(intervals):
        nc = cells_per + (1 if idx < remainder else 0)
        for k in range(nc):
            t = lo + (hi - lo) * (k + 1) / nc
            bdry.append(HiR(a_f + w_f * t))
    # Force exact endpoint.
    bdry[-1] = a_hir + w_hir
    return bdry


def _farey_rank_boundaries(N, a_qq, w_qq, farey_order=None):
    """Compute N+1 boundary points by rank-subsampling a Farey sequence (QQ).

    Build F_Q in [0,1] and subsample at equally-spaced ranks.
    If farey_order is None, find minimal Q with |F_Q| >= N+1.
    """
    def build_farey(Q):
        """Return sorted Farey sequence F_Q in [0,1] as list of QQ."""
        seq = set()
        for q in range(1, Q + 1):
            for p in range(0, q + 1):
                seq.add(QQ(p) / QQ(q))
        return sorted(seq)

    if farey_order is not None:
        Q = int(farey_order)
        if Q < 1:
            raise ValueError(f"farey_order must be >= 1, got {farey_order}")
        fseq = build_farey(Q)
        if len(fseq) < N + 1:
            raise ValueError(
                f"farey_order={Q} is too small for {N} cells: "
                f"|F_Q|={len(fseq)} < {N + 1}"
            )
    else:
        Q = 1
        while True:
            fseq = build_farey(Q)
            if len(fseq) >= N + 1:
                break
            Q += 1
        return _farey_subsample(fseq, N, a_qq, w_qq)

    fseq = build_farey(Q)
    return _farey_subsample(fseq, N, a_qq, w_qq)


def _farey_subsample(fseq, N, a_qq, w_qq):
    """Subsample a Farey sequence to N+1 boundary points."""
    M = len(fseq) - 1  # last index
    bdry = []
    for j in range(N + 1):
        idx = int(j * M) // int(N)
        bdry.append(a_qq + w_qq * fseq[idx])
    # Force exact endpoints.
    bdry[0] = a_qq
    bdry[N] = a_qq + w_qq
    return bdry


def _radical_inverse_boundaries(N, a_hir, w_hir, vdc_base):
    """Compute N+1 boundary points from sorted van der Corput sequence (HiR)."""
    base = int(vdc_base)

    def van_der_corput(k, b):
        """Radical inverse of k in base b."""
        result = 0.0
        denom = 1.0
        n = k
        while n > 0:
            denom *= b
            n, remainder = divmod(n, b)
            result += remainder / denom
        return result

    pts = sorted([van_der_corput(k, base) for k in range(1, int(N))])
    a_f = float(a_hir)
    w_f = float(w_hir)
    return [a_hir] + [HiR(a_f + w_f * t) for t in pts] + [a_hir + w_hir]


def _sturmian_binary_boundaries(N, a_qq, w_qq, st_alpha, st_phase, st_ratio):
    """Compute N+1 boundary points from binary Sturmian word widths (QQ).

    s_j = floor((j+1)*alpha + phase) - floor(j*alpha + phase).
    Width is st_ratio if s_j=1, else 1.  Cumsum, normalize, scale.
    Reduce alpha modulo 1 so the default slope lives in the standard
    binary Sturmian range 0 < alpha < 1.
    """
    # Avoid Sage coercion: bare 1.0 is a Sage RealNumber whose __rmod__
    # can return a negative value for positive floats.  Use int divisor.
    _alpha_raw = float(st_alpha)
    alpha_f = _alpha_raw - int(_alpha_raw)          # fractional part, >= 0
    if alpha_f == 0.0:
        raise ValueError("st_alpha must have a nonzero fractional part")
    phase_f = float(st_phase)
    st_ratio_qq = QQ(st_ratio)
    import math
    raw = []
    for j in range(int(N)):
        s_j = int(math.floor((j + 1) * alpha_f + phase_f)) - int(math.floor(j * alpha_f + phase_f))
        if s_j:
            raw.append(st_ratio_qq)
        else:
            raw.append(QQ(1))
    W = sum(raw)
    cum = [QQ(0)]
    s = QQ(0)
    for wj in raw:
        s += wj
        cum.append(s)
    return [a_qq + w_qq * c / W for c in cum]


def _sturmian_boundaries(N, a_qq, w_qq, st_alpha, st_phase, st_ratio):
    """Backward-compatible wrapper for the binary Sturmian implementation."""
    return _sturmian_binary_boundaries(N, a_qq, w_qq, st_alpha, st_phase, st_ratio)


def _beta_boundaries(N, a_hir, w_hir, beta_alpha, beta_beta):
    """Compute N+1 boundary points via SciPy's inverse Beta CDF (HiR)."""
    from scipy.special import betaincinv
    ba = float(beta_alpha)
    bb = float(beta_beta)

    a_f = float(a_hir)
    w_f = float(w_hir)
    bdry = [a_hir]
    for j in range(1, int(N)):
        t = float(betaincinv(ba, bb, j / int(N)))
        bdry.append(HiR(a_f + w_f * t))
    bdry.append(a_hir + w_hir)
    return bdry


def _arc_length_boundaries(N, a_hir, x_end_hir):
    """Compute N+1 boundary points with equal arc-length cells on 1/(x ln 2) (HiR).

    Integrand for arc length: sqrt(1 + (d/dx[1/(x ln 2)])^2) = sqrt(1 + 1/(x^4 ln(2)^2)).
    Bisect on x for each target fraction of total arc length.
    """
    import math
    from sage.all import numerical_integral
    ln2 = math.log(2.0)
    ln2sq = ln2 * ln2

    def ds(x):
        return math.sqrt(1.0 + 1.0 / (x**4 * ln2sq))

    a_f = float(a_hir)
    xe_f = float(x_end_hir)
    total_S, _ = numerical_integral(ds, a_f, xe_f)

    bdry = [a_hir]
    for j in range(1, int(N)):
        target = j * total_S / int(N)
        lo, hi = a_f, xe_f
        for _ in range(60):
            mid = (lo + hi) / 2.0
            val, _ = numerical_integral(ds, a_f, mid)
            if val < target:
                lo = mid
            else:
                hi = mid
        bdry.append(HiR((lo + hi) / 2.0))
    bdry.append(x_end_hir)
    return bdry


def _minimax_chord_boundaries(N, a_hir, x_end_hir, minimax_tol):
    """Compute the closed-form minimax partition for 1/(x ln 2) - 1 (HiR).

    For c(x) = 1/(x ln 2) - 1, the maximum chord-to-curve gap on [a,b] is
    proportional to (a^(-1/2) - b^(-1/2))^2.  The minimax partition therefore
    has equal spacing in u = x^(-1/2).  minimax_tol is retained only for API
    compatibility with the old iterative solver.
    """
    _ = minimax_tol
    u_start = HiR(1) / a_hir.sqrt()
    u_end = HiR(1) / x_end_hir.sqrt()
    bdry = []
    for j in range(int(N) + 1):
        u_j = u_start + (u_end - u_start) * HiR(j) / HiR(N)
        bdry.append(HiR(1) / (u_j ^ 2))
    bdry[0] = a_hir
    bdry[-1] = x_end_hir
    return bdry


def build_partition(depth, kind='uniform_x', x_start=1, x_width=1, **kwargs):
    """
    Build a partition of [x_start, x_start + x_width) into 2^depth cells.

    Parameters
    ----------
    depth   : int — number of bisection levels
    kind    : str — canonical kind or descriptive alias
    x_start : number — left endpoint of the domain (default 1)
    x_width : number — width of the domain (default 1)
    **kwargs : extra parameters for specific partition kinds:
        sin_k        : int    — frequency for sinusoidal_x (default 3)
        sin_alpha    : float  — amplitude for sinusoidal_x (default 0.6)
        tm_ratio     : number — w0/w1 ratio for thuemorse_x (default 2)
        random_seed  : int    — RNG seed for random_x (default 42)
        dyadic_res   : int    — bit resolution for dyadic_x (default depth+4)
        pl_exponent  : float  — power-law exponent for powerlaw_x (default 3)
        cantor_levels: int    — recursion depth for cantor_x (default 3)
        farey_order  : int    — Farey sequence order Q for farey_rank_x (default auto)
        vdc_base     : int    — base for radical_inverse_x (default 2)
        st_alpha     : float  — irrational slope for sturmian_x (default 1/phi, reduced mod 1)
        st_phase     : float  — phase offset for sturmian_x (default 0)
        st_ratio     : number — width ratio for sturmian_x (default 2)
        beta_alpha   : float  — alpha param for beta_x (default 5)
        beta_beta    : float  — beta param for beta_x (default 2)
        minimax_tol  : float  — compatibility knob for minimax_chord_x (default 1e-12)

    Returns a list of row dicts sorted by cell index.
    Each row:
        index    — integer cell id
        bits     — tuple of 0/1
        x_lo     — HiR left endpoint
        x_hi     — HiR right endpoint
        plog_lo  — HiR pseudo-log of x_lo  (= x_lo - x_start)
        plog_hi  — HiR pseudo-log of x_hi  (= x_hi - x_start)
        width_x  — HiR additive width
        width_log — HiR log2-width
        kind     — str canonical partition kind
        x_start  — HiR domain left endpoint
        x_width  — HiR domain width
    """
    kind = normalize_partition_kind(kind)

    depth = _coerce_finite_int("depth", depth)
    if depth < 0:
        raise ValueError(f"depth must be non-negative, got {depth}")
    _validate_finite(x_start, x_width)
    if float(x_width) <= 0:
        raise ValueError(f"x_width must be positive, got {x_width}")

    N = Integer(2^depth)
    a = HiR(x_start)
    w = HiR(x_width)
    x_end = a + w      # right endpoint of the domain

    # Precompute boundary arrays for kinds that need them.
    if kind == 'ruler_x':
        bdry = _ruler_boundaries(N, QQ(x_start), QQ(x_width))
    elif kind == 'sinusoidal_x':
        sin_k = _coerce_finite_int("sin_k", kwargs.get('sin_k', 3))
        sin_alpha = kwargs.get('sin_alpha', 0.6)
        _validate_finite(sin_k, sin_alpha)
        if float(sin_alpha) >= 1.0:
            raise ValueError(
                f"sin_alpha must be < 1.0 for F(t) to be monotone, got {sin_alpha}")
        bdry = _sinusoidal_boundaries(N, a, x_end, sin_k, sin_alpha)
    elif kind == 'chebyshev_x':
        bdry = _chebyshev_boundaries(N, a, w)
    elif kind == 'thuemorse_x':
        tm_ratio = kwargs.get('tm_ratio', 2)
        _validate_finite(tm_ratio)
        bdry = _thuemorse_boundaries(N, QQ(x_start), QQ(x_width), tm_ratio)
    elif kind == 'bitrev_geometric_x':
        bdry = _bitrev_geometric_boundaries(N, depth, a, x_end)
    elif kind == 'stern_brocot_x':
        bdry = _stern_brocot_boundaries(depth, QQ(x_start), QQ(x_start + x_width))
    elif kind == 'reverse_geometric_x':
        bdry = _reverse_geometric_boundaries(N, depth, a, x_end)
    elif kind == 'random_x':
        random_seed = _coerce_finite_int("random_seed", kwargs.get('random_seed', 42))
        bdry = _random_boundaries(N, a, w, random_seed)
    elif kind == 'dyadic_x':
        dyadic_res = _coerce_finite_int("dyadic_res", kwargs.get('dyadic_res', depth + 4))
        bdry = _dyadic_boundaries(N, a, x_end, dyadic_res)
    elif kind == 'powerlaw_x':
        pl_exponent = kwargs.get('pl_exponent', 3)
        _validate_finite(pl_exponent)
        if float(pl_exponent) == 1.0:
            raise ValueError(
                "pl_exponent must not be 1.0 (division by zero in CDF inversion)")
        bdry = _powerlaw_boundaries(N, a, x_end, pl_exponent)
    elif kind == 'golden_x':
        bdry = _golden_boundaries(N, a, w)
    elif kind == 'cantor_x':
        cantor_levels = _coerce_finite_int("cantor_levels", kwargs.get('cantor_levels', 3))
        bdry = _cantor_boundaries(N, a, w, cantor_levels)
    elif kind == 'farey_rank_x':
        farey_order = kwargs.get('farey_order', None)
        if farey_order is not None:
            farey_order = _coerce_finite_int("farey_order", farey_order)
        bdry = _farey_rank_boundaries(N, QQ(x_start), QQ(x_width), farey_order)
    elif kind == 'radical_inverse_x':
        vdc_base = _coerce_finite_int("vdc_base", kwargs.get('vdc_base', 2))
        if vdc_base < 2:
            raise ValueError(f"vdc_base must be >= 2, got {vdc_base}")
        bdry = _radical_inverse_boundaries(N, a, w, vdc_base)
    elif kind == 'sturmian_x':
        import math as _math
        st_alpha = kwargs.get('st_alpha', (_math.sqrt(5.0) - 1.0) / 2.0)
        st_phase = kwargs.get('st_phase', 0.0)
        st_ratio = kwargs.get('st_ratio', 2)
        _validate_finite(st_alpha, st_phase, st_ratio)
        if float(st_ratio) <= 0:
            raise ValueError(f"st_ratio must be positive, got {st_ratio}")
        bdry = _sturmian_binary_boundaries(N, QQ(x_start), QQ(x_width), st_alpha, st_phase, st_ratio)
    elif kind == 'beta_x':
        beta_alpha = kwargs.get('beta_alpha', 5.0)
        beta_beta = kwargs.get('beta_beta', 2.0)
        _validate_finite(beta_alpha, beta_beta)
        if float(beta_alpha) <= 0 or float(beta_beta) <= 0:
            raise ValueError(
                f"beta_alpha and beta_beta must be positive, got ({beta_alpha}, {beta_beta})")
        bdry = _beta_boundaries(N, a, w, beta_alpha, beta_beta)
    elif kind == 'arc_length_x':
        bdry = _arc_length_boundaries(N, a, x_end)
    elif kind == 'minimax_chord_x':
        minimax_tol = kwargs.get('minimax_tol', 1e-12)
        _validate_finite(minimax_tol)
        if float(minimax_tol) <= 0:
            raise ValueError(f"minimax_tol must be positive, got {minimax_tol}")
        bdry = _minimax_chord_boundaries(N, a, x_end, minimax_tol)

    rows = []

    for j in range(N):
        bits = index_to_bits(j, depth)

        if kind == 'uniform_x':
            x_lo = a + w * HiR(j) / HiR(N)
            x_hi = a + w * HiR(j + 1) / HiR(N)
        elif kind == 'geometric_x':
            # Equal log-width.  Ratio r = x_end / a replaces hardcoded 2.
            r = x_end / a
            x_lo = a * r ^ (HiR(j) / HiR(N))
            x_hi = a * r ^ (HiR(j + 1) / HiR(N))
        elif kind == 'harmonic_x':
            # Equal spacing in 1/x on [a, a+w): finer near x_start.
            inv_lo = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(j) / HiR(N)
            inv_hi = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(j + 1) / HiR(N)
            x_lo = HiR(1) / inv_lo
            x_hi = HiR(1) / inv_hi
        elif kind == 'mirror_harmonic_x':
            mirror = 2 * a + w
            inv_lo = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(N - j) / HiR(N)
            inv_hi = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(N - j - 1) / HiR(N)
            x_lo = HiR(mirror) - HiR(1) / inv_lo
            x_hi = HiR(mirror) - HiR(1) / inv_hi
        elif kind == 'ruler_x':
            x_lo = HiR(bdry[j])
            x_hi = HiR(bdry[j + 1])
        elif kind == 'sinusoidal_x':
            x_lo = bdry[j]
            x_hi = bdry[j + 1]
        elif kind == 'chebyshev_x':
            x_lo = bdry[j]
            x_hi = bdry[j + 1]
        elif kind == 'thuemorse_x':
            x_lo = HiR(bdry[j])
            x_hi = HiR(bdry[j + 1])
        elif kind == 'bitrev_geometric_x':
            x_lo = bdry[j]
            x_hi = bdry[j + 1]
        elif kind == 'stern_brocot_x':
            x_lo = HiR(bdry[j])
            x_hi = HiR(bdry[j + 1])
        elif kind == 'farey_rank_x':
            x_lo = HiR(bdry[j])
            x_hi = HiR(bdry[j + 1])
        elif kind == 'sturmian_x':
            x_lo = HiR(bdry[j])
            x_hi = HiR(bdry[j + 1])
        elif kind in ('reverse_geometric_x', 'random_x', 'dyadic_x',
                       'powerlaw_x', 'golden_x', 'cantor_x',
                       'radical_inverse_x', 'beta_x', 'arc_length_x',
                       'minimax_chord_x'):
            x_lo = bdry[j]
            x_hi = bdry[j + 1]

        plog_lo = x_lo - a
        plog_hi = x_hi - a

        width_x = x_hi - x_lo
        width_log = x_hi.log() / LN2 - x_lo.log() / LN2

        rows.append({
            'index': j,
            'bits': bits,
            'x_lo': x_lo,
            'x_hi': x_hi,
            'plog_lo': plog_lo,
            'plog_hi': plog_hi,
            'width_x': width_x,
            'width_log': width_log,
            'kind': kind,
            'x_start': a,
            'x_width': w,
        })

    return rows


def partition_row_map(partition):
    """Build a dict from bits -> row for quick lookup."""
    return {row['bits']: row for row in partition}


# ── Float interface for visualizations ───────────────────────────────

def float_cells(depth, kind='geometric_x', x_start=1, x_width=1, **kwargs):
    """Return partition as [(a_float, b_float), ...] for lightweight use.

    Thin wrapper around build_partition — same arguments, but returns
    simple float tuples instead of rich row dicts.
    """
    rows = build_partition(depth, kind=kind, x_start=x_start,
                           x_width=x_width, **kwargs)
    return [(float(r['x_lo']), float(r['x_hi'])) for r in rows]


def depth_for_N(N):
    """Return depth such that 2^depth == N, or raise ValueError."""
    d = 0
    tmp = int(N)
    while tmp > 1:
        if tmp % 2 != 0:
            raise ValueError("N=%d is not a power of 2" % N)
        tmp //= 2
        d += 1
    return d


# Canonical ordering, display names, and colors for all partitions.
# Used by visualization scripts to iterate zoo grids.
PARTITION_ZOO = [
    ('uniform',           '#1f77b4', 'uniform_x'),
    ('geometric',         '#9467bd', 'geometric_x'),
    ('harmonic',          '#2ca02c', 'harmonic_x'),
    ('mirror-harmonic',   '#d62728', 'mirror_harmonic_x'),
    ('ruler',             '#e67e22', 'ruler_x'),
    ('sinusoidal',        '#17becf', 'sinusoidal_x'),
    ('chebyshev',         '#8c564b', 'chebyshev_x'),
    ('thue-morse',        '#e377c2', 'thuemorse_x'),
    ('bitrev-geometric',  '#7f7f7f', 'bitrev_geometric_x'),
    ('stern-brocot',      '#bcbd22', 'stern_brocot_x'),
    ('reverse-geometric', '#ff7f0e', 'reverse_geometric_x'),
    ('random',            '#aec7e8', 'random_x'),
    ('dyadic',            '#98df8a', 'dyadic_x'),
    ('power-law',         '#ff9896', 'powerlaw_x'),
    ('golden',            '#c5b0d5', 'golden_x'),
    ('cantor',            '#c49c94', 'cantor_x'),
    ('farey-rank',        '#377eb8', 'farey_rank_x'),
    ('radical-inverse',   '#4daf4a', 'radical_inverse_x'),
    ('sturmian',          '#984ea3', 'sturmian_x'),
    ('beta',              '#ff7f00', 'beta_x'),
    ('arc-length',        '#a65628', 'arc_length_x'),
    ('minimax-chord',     '#f781bf', 'minimax_chord_x'),
]


def zoo_grid_shape(zoo=None):
    """Return (n_rows, n_cols) for a compact grid layout of a zoo list."""
    n = len(zoo) if zoo is not None else len(PARTITION_ZOO)
    c = int(n ** 0.5)
    if c * c < n:
        c += 1
    r = (n + c - 1) // c
    return r, c
