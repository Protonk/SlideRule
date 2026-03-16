"""
lib/partitions.sage — Partition geometry for [x_start, x_start + x_width).

Four partition kinds:
    uniform_x         — equal additive width
    geometric_x       — equal log-width
    harmonic_x        — equal spacing in 1/x (finer near x_start)
    mirror_harmonic_x — mirrored reciprocal (finer near x_start + x_width)

Default domain is [1, 2) (x_start=1, x_width=1).

A partition is a list of row dicts ordered by cell index j = 0..2^depth-1.
Each row carries: index, bits, x_lo, x_hi, plog_lo, plog_hi, width_x,
width_log, kind, x_start, x_width.

Depends on: lib/day.sage must be loaded first (provides HiR, LN2).
"""


PARTITION_KINDS = ('uniform_x', 'geometric_x', 'harmonic_x', 'mirror_harmonic_x')
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


def build_partition(depth, kind='uniform_x', x_start=1, x_width=1):
    """
    Build a partition of [x_start, x_start + x_width) into 2^depth cells.

    Parameters
    ----------
    depth   : int — number of bisection levels
    kind    : str — canonical kind or descriptive alias
    x_start : number — left endpoint of the domain (default 1)
    x_width : number — width of the domain (default 1)

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
            # Reciprocal values range from 1/a to 1/(a+w), evenly spaced.
            inv_lo = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(j) / HiR(N)
            inv_hi = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(j + 1) / HiR(N)
            x_lo = HiR(1) / inv_lo
            x_hi = HiR(1) / inv_hi
        else:  # mirror_harmonic_x — reciprocal-spacing mirrored about domain midpoint
            mirror = 2 * a + w   # = 2 * x_start + x_width
            # Use (N-j) and (N-j-1) to reverse the harmonic ordering.
            inv_lo = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(N - j) / HiR(N)
            inv_hi = HiR(1) / a - (HiR(1) / a - HiR(1) / x_end) * HiR(N - j - 1) / HiR(N)
            x_lo = HiR(mirror) - HiR(1) / inv_lo
            x_hi = HiR(mirror) - HiR(1) / inv_hi

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
