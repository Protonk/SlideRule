"""
lib/partitions.sage — Partition geometry for [x_start, x_start + x_width).

Sixteen partition kinds:
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

Default domain is [1, 2) (x_start=1, x_width=1).

A partition is a list of row dicts ordered by cell index j = 0..2^depth-1.
Each row carries: index, bits, x_lo, x_hi, plog_lo, plog_hi, width_x,
width_log, kind, x_start, x_width.

Depends on: lib/day.sage must be loaded first (provides HiR, LN2).
"""


PARTITION_KINDS = ('uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x',
                   'ruler_x', 'sinusoidal_x', 'chebyshev_x', 'thuemorse_x',
                   'bitrev_geometric_x', 'stern_brocot_x', 'reverse_geometric_x',
                   'random_x', 'dyadic_x', 'powerlaw_x', 'golden_x', 'cantor_x')
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
    """Compute 2^depth + 1 boundary points by iterated mediant insertion in QQ."""
    # Represent each boundary as a QQ value.  At each round, insert the
    # mediant (p1+p2)/(q1+q2) between every adjacent pair.
    # We store as fractions: QQ handles this natively.
    bdry = [QQ(a_qq), QQ(x_end_qq)]
    for _ in range(depth):
        new_bdry = [bdry[0]]
        for i in range(len(bdry) - 1):
            # Mediant of p1/q1 and p2/q2 = (p1+p2)/(q1+q2).
            p1, q1 = bdry[i].numerator(), bdry[i].denominator()
            p2, q2 = bdry[i + 1].numerator(), bdry[i + 1].denominator()
            med = QQ(p1 + p2) / QQ(q1 + q2)
            new_bdry.append(med)
            new_bdry.append(bdry[i + 1])
        bdry = new_bdry
    return bdry


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

    N = Integer(2^depth)
    a = HiR(x_start)
    w = HiR(x_width)
    x_end = a + w      # right endpoint of the domain

    # Precompute boundary arrays for kinds that need them.
    if kind == 'ruler_x':
        bdry = _ruler_boundaries(N, QQ(x_start), QQ(x_width))
    elif kind == 'sinusoidal_x':
        sin_k = kwargs.get('sin_k', 3)
        sin_alpha = kwargs.get('sin_alpha', 0.6)
        bdry = _sinusoidal_boundaries(N, a, x_end, sin_k, sin_alpha)
    elif kind == 'chebyshev_x':
        bdry = _chebyshev_boundaries(N, a, w)
    elif kind == 'thuemorse_x':
        tm_ratio = kwargs.get('tm_ratio', 2)
        bdry = _thuemorse_boundaries(N, QQ(x_start), QQ(x_width), tm_ratio)
    elif kind == 'bitrev_geometric_x':
        bdry = _bitrev_geometric_boundaries(N, depth, a, x_end)
    elif kind == 'stern_brocot_x':
        bdry = _stern_brocot_boundaries(depth, QQ(x_start), QQ(x_start + x_width))
    elif kind == 'reverse_geometric_x':
        bdry = _reverse_geometric_boundaries(N, depth, a, x_end)
    elif kind == 'random_x':
        random_seed = kwargs.get('random_seed', 42)
        bdry = _random_boundaries(N, a, w, random_seed)
    elif kind == 'dyadic_x':
        dyadic_res = kwargs.get('dyadic_res', depth + 4)
        bdry = _dyadic_boundaries(N, a, x_end, dyadic_res)
    elif kind == 'powerlaw_x':
        pl_exponent = kwargs.get('pl_exponent', 3)
        bdry = _powerlaw_boundaries(N, a, x_end, pl_exponent)
    elif kind == 'golden_x':
        bdry = _golden_boundaries(N, a, w)
    elif kind == 'cantor_x':
        cantor_levels = kwargs.get('cantor_levels', 3)
        bdry = _cantor_boundaries(N, a, w, cantor_levels)

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
        elif kind in ('reverse_geometric_x', 'random_x', 'dyadic_x',
                       'powerlaw_x', 'golden_x', 'cantor_x'):
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


# Canonical ordering, display names, and colors for all sixteen partitions.
# Used by visualization scripts to iterate the 4x4 zoo grid.
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
]
