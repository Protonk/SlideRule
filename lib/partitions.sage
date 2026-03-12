"""
lib/partitions.sage — Partition geometry for [1,2).

Four partition kinds:
    uniform_x         — equal additive width:  x_j = 1 + j / 2^depth
    geometric_x       — equal log-width:       x_j = 2^(j / 2^depth)
    harmonic_x        — equal spacing in 1/x:  x_j = 2N / (2N - j)
                          finer near x=1, wider near x=2
    mirror_harmonic_x — mirrored reciprocal spacing:
                          x_j = 3 - 2N / (N + j)
                          wider near x=1, finer near x=2

A partition is a list of row dicts ordered by cell index j = 0..2^depth-1.
Each row carries: index, bits, x_lo, x_hi, plog_lo, plog_hi, width_x, width_log.

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


def build_partition(depth, kind='uniform_x'):
    """
    Build a partition of [1,2) into 2^depth cells.

    Parameters
    ----------
    depth : int — number of bisection levels
    kind  : str — canonical kind or descriptive alias

    Returns a list of row dicts sorted by cell index.
    Each row:
        index    — integer cell id
        bits     — tuple of 0/1
        x_lo     — HiR left endpoint
        x_hi     — HiR right endpoint
        plog_lo  — HiR pseudo-log of x_lo
        plog_hi  — HiR pseudo-log of x_hi
        width_x  — HiR additive width
        width_log — HiR log2-width
        kind     — str canonical partition kind
    """
    kind = normalize_partition_kind(kind)

    N = Integer(2^depth)
    rows = []

    for j in range(N):
        bits = index_to_bits(j, depth)

        if kind == 'uniform_x':
            x_lo = HiR(1) + HiR(j) / HiR(N)
            x_hi = HiR(1) + HiR(j + 1) / HiR(N)
            plog_lo = HiR(j) / HiR(N)
            plog_hi = HiR(j + 1) / HiR(N)
        elif kind == 'geometric_x':
            x_lo = HiR(2) ^ (HiR(j) / HiR(N))
            x_hi = HiR(2) ^ (HiR(j + 1) / HiR(N))
            plog_lo = x_lo - HiR(1)
            plog_hi = x_hi - HiR(1)
        elif kind == 'harmonic_x':
            # Reciprocal-spacing grid: finer near x=1, wider near x=2.
            x_lo = HiR(2 * N) / HiR(2 * N - j)
            x_hi = HiR(2 * N) / HiR(2 * N - j - 1)
            plog_lo = x_lo - HiR(1)
            plog_hi = x_hi - HiR(1)
        else:  # mirror_harmonic_x — reciprocal-spacing mirrored across x=3/2
            x_lo = HiR(3) - HiR(2 * N) / HiR(N + j)
            x_hi = HiR(3) - HiR(2 * N) / HiR(N + j + 1)
            plog_lo = x_lo - HiR(1)
            plog_hi = x_hi - HiR(1)

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
        })

    return rows


def partition_row_map(partition):
    """Build a dict from bits -> row for quick lookup."""
    return {row['bits']: row for row in partition}
