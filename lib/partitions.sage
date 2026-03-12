"""
lib/partitions.sage — Partition geometry for [1,2).

Two partition kinds:
    uniform_x   — equal additive width:  x_j = 1 + j / 2^depth
    geometric_x — equal log-width:       x_j = 2^(j / 2^depth)

A partition is a list of row dicts ordered by cell index j = 0..2^depth-1.
Each row carries: index, bits, x_lo, x_hi, plog_lo, plog_hi, width_x, width_log.

Depends on: lib/day.sage must be loaded first (provides HiR, LN2).
"""


PARTITION_KINDS = ('uniform_x', 'geometric_x')


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
    kind  : str — 'uniform_x' or 'geometric_x'

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
        kind     — str partition kind
    """
    if kind not in PARTITION_KINDS:
        raise ValueError(f"unknown partition kind: {kind!r}; expected one of {PARTITION_KINDS}")

    N = Integer(2^depth)
    rows = []

    for j in range(N):
        bits = index_to_bits(j, depth)

        if kind == 'uniform_x':
            x_lo = HiR(1) + HiR(j) / HiR(N)
            x_hi = HiR(1) + HiR(j + 1) / HiR(N)
            plog_lo = HiR(j) / HiR(N)
            plog_hi = HiR(j + 1) / HiR(N)
        else:  # geometric_x
            x_lo = HiR(2) ^ (HiR(j) / HiR(N))
            x_hi = HiR(2) ^ (HiR(j + 1) / HiR(N))
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
