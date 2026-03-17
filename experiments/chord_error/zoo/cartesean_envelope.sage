"""
partition_zoo.sage — Peak envelopes for all sixteen partition kinds.

Sixteen panels (4x4 grid) with independent y-scales showing per-cell chord
error sawtooths with peak envelopes.

Run:  ./sagew experiments/error/tilt/partition_zoo.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2, sin, pi


# ── Configuration ────────────────────────────────────────────────────

N = 64
M_PER_CELL = 40
SIN_K = 3
SIN_ALPHA = 0.6


# ── Float partitions ────────────────────────────────────────────────

def uniform_partition(N):
    return [(1.0 + j / N, 1.0 + (j + 1) / N) for j in range(N)]


def geometric_partition(N):
    return [(2.0 ** (j / N), 2.0 ** ((j + 1) / N)) for j in range(N)]


def harmonic_partition(N):
    # Equal spacing in 1/x on [1, 2).
    inv_lo_base = 1.0  # 1/1
    inv_hi_base = 0.5  # 1/2
    cells = []
    for j in range(N):
        inv_lo = inv_lo_base - (inv_lo_base - inv_hi_base) * j / N
        inv_hi = inv_lo_base - (inv_lo_base - inv_hi_base) * (j + 1) / N
        cells.append((1.0 / inv_lo, 1.0 / inv_hi))
    return cells


def mirror_harmonic_partition(N):
    mirror = 3.0  # 2 * 1 + 1
    cells = []
    for j in range(N):
        inv_lo = 1.0 - (1.0 - 0.5) * (N - j) / N
        inv_hi = 1.0 - (1.0 - 0.5) * (N - j - 1) / N
        cells.append((mirror - 1.0 / inv_lo, mirror - 1.0 / inv_hi))
    return cells


def ruler_partition(N):
    # Width of cell j proportional to 2^{-v2(j+1)}.
    def v2(n):
        if n == 0:
            return 0
        c = 0
        while n % 2 == 0:
            n //= 2
            c += 1
        return c
    raw = [2.0**(-v2(j + 1)) for j in range(N)]
    W = sum(raw)
    cum = [0.0]
    s = 0.0
    for wj in raw:
        s += wj
        cum.append(s)
    return [(1.0 + cum[j] / W, 1.0 + cum[j + 1] / W) for j in range(N)]


def sinusoidal_partition(N, k=SIN_K, alpha=SIN_ALPHA):
    twopik = 2.0 * pi * k
    coeff = alpha / twopik

    def F(t):
        return t - coeff * sin(twopik * t)

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

    return [(2.0**t_vals[j], 2.0**t_vals[j + 1]) for j in range(N)]


def chebyshev_partition(N):
    # Clenshaw-Curtis points mapped to [1, 2).
    from math import cos
    bdry = [1.0 + (1.0 - cos(pi * j / N)) / 2.0 for j in range(N + 1)]
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def thuemorse_partition(N, tm_ratio=2.0):
    # Thue-Morse bit = popcount(j) % 2.
    def popcount(n):
        c = 0
        while n:
            c += n & 1
            n >>= 1
        return c
    raw = [tm_ratio if popcount(j) % 2 == 0 else 1.0 for j in range(N)]
    W = sum(raw)
    cum = [0.0]
    s = 0.0
    for wj in raw:
        s += wj
        cum.append(s)
    return [(1.0 + cum[j] / W, 1.0 + cum[j + 1] / W) for j in range(N)]


def bitrev_geometric_partition(N):
    # Geometric widths permuted by bit-reversal.
    depth = 0
    tmp = N
    while tmp > 1:
        tmp >>= 1
        depth += 1

    def bitrev(j, n):
        result = 0
        for _ in range(n):
            result = (result << 1) | (j & 1)
            j >>= 1
        return result

    geo_widths = [2.0**((j + 1) / N) - 2.0**(j / N) for j in range(N)]
    perm_widths = [geo_widths[bitrev(j, depth)] for j in range(N)]
    cum = [1.0]
    s = 1.0
    for wj in perm_widths:
        s += wj
        cum.append(s)
    return [(cum[j], cum[j + 1]) for j in range(N)]


def stern_brocot_partition(N):
    # Iterated mediant insertion on [1, 2].
    # Store boundaries as (numerator, denominator) tuples to avoid Sage
    # interference with fractions.Fraction attribute access.
    depth = 0
    tmp = N
    while tmp > 1:
        tmp >>= 1
        depth += 1
    bdry = [(1, 1), (2, 1)]
    for _ in range(depth):
        new_bdry = [bdry[0]]
        for i in range(len(bdry) - 1):
            p1, q1 = bdry[i]
            p2, q2 = bdry[i + 1]
            new_bdry.append((p1 + p2, q1 + q2))
            new_bdry.append(bdry[i + 1])
        bdry = new_bdry
    return [(bdry[j][0] / bdry[j][1], bdry[j + 1][0] / bdry[j + 1][1]) for j in range(N)]


def reverse_geometric_partition(N):
    # Geometric widths in reverse order (dense at m=2, sparse at m=1).
    geo_widths = [2.0**((j + 1) / N) - 2.0**(j / N) for j in range(N)]
    rev_widths = list(reversed(geo_widths))
    cum = [1.0]
    s = 1.0
    for wj in rev_widths:
        s += wj
        cum.append(s)
    return [(cum[j], cum[j + 1]) for j in range(N)]


def random_partition(N, seed=42):
    # Sorted uniform random breakpoints.
    import random as _rng
    _rng.seed(int(seed))
    pts = sorted([_rng.random() for _ in range(N - 1)])
    bdry = [1.0] + [1.0 + t for t in pts] + [2.0]
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def dyadic_partition(N):
    # Geometric targets snapped to dyadic rationals.
    depth = 0
    tmp = N
    while tmp > 1:
        tmp >>= 1
        depth += 1
    R = depth + 4
    scale = 2**R
    bdry = [1.0]
    for j in range(1, N):
        target = 2.0**(j / N)
        bdry.append(round(target * scale) / scale)
    bdry.append(2.0)
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def powerlaw_partition(N, p=3.0):
    # Density ~ m^{-p}.  CDF inversion.
    exp = 1.0 - p
    a_exp = 1.0**exp  # = 1.0
    xe_exp = 2.0**exp
    bdry = []
    for j in range(N + 1):
        val = (a_exp + (j / N) * (xe_exp - a_exp))**(1.0 / exp)
        bdry.append(val)
    bdry[0] = 1.0
    bdry[N] = 2.0
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def golden_partition(N):
    # Kronecker sequence with golden ratio, sorted.
    # Use math.fmod to avoid Sage RealLiteral modulo semantics (centered at 0).
    from math import sqrt, fmod
    phi = float((1.0 + sqrt(5.0)) / 2.0)
    pts = sorted([fmod(float(j) * phi, 1.0) for j in range(1, int(N))])
    bdry = [1.0] + [1.0 + t for t in pts] + [2.0]
    return [(bdry[j], bdry[j + 1]) for j in range(int(N))]


def cantor_partition(N, levels=3):
    # Cantor dust: cells in surviving middle-third intervals.
    intervals = [(0.0, 1.0)]
    for _ in range(levels):
        new_intervals = []
        for lo, hi in intervals:
            third = (hi - lo) / 3.0
            new_intervals.append((lo, lo + third))
            new_intervals.append((hi - third, hi))
        intervals = new_intervals
    n_intervals = len(intervals)
    cells_per = N // n_intervals
    remainder = N - cells_per * n_intervals
    bdry = [1.0]
    for idx, (lo, hi) in enumerate(intervals):
        nc = cells_per + (1 if idx < remainder else 0)
        for k in range(nc):
            t = lo + (hi - lo) * (k + 1) / nc
            bdry.append(1.0 + t)
    bdry[-1] = 2.0
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def build_profiles(cells):
    m_segments = []
    E_segments = []
    peak_ms = []
    peak_Es = []

    for a, b in cells:
        sigma = cell_chord_slope(a, b)
        ms = np.linspace(a, b, M_PER_CELL)
        chord_vals = math_log2(a) + sigma * (ms - a)
        E_vals = np.log2(ms) - chord_vals

        m_segments.append(ms)
        E_segments.append(E_vals)

        m_pk = log_mean(a, b)
        E_pk = math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))
        peak_ms.append(m_pk)
        peak_Es.append(E_pk)

    m_all = np.concatenate(m_segments)
    E_all = np.concatenate(E_segments)
    return m_all, E_all, np.array(peak_ms), np.array(peak_Es)


# ── Plot ─────────────────────────────────────────────────────────────

PARTITIONS = [
    ('uniform',          '#1f77b4', uniform_partition),
    ('geometric',        '#9467bd', geometric_partition),
    ('harmonic',         '#2ca02c', harmonic_partition),
    ('mirror harmonic',  '#d62728', mirror_harmonic_partition),
    ('ruler',            '#e67e22', ruler_partition),
    ('sinusoidal',       '#17becf', sinusoidal_partition),
    ('chebyshev',        '#8c564b', chebyshev_partition),
    ('thue-morse',       '#e377c2', thuemorse_partition),
    ('bitrev geometric', '#7f7f7f', bitrev_geometric_partition),
    ('stern-brocot',     '#bcbd22', stern_brocot_partition),
    ('reverse geometric','#ff7f0e', reverse_geometric_partition),
    ('random',           '#aec7e8', random_partition),
    ('dyadic',           '#98df8a', dyadic_partition),
    ('power-law',        '#ff9896', powerlaw_partition),
    ('golden ratio',     '#c5b0d5', golden_partition),
    ('cantor dust',      '#c49c94', cantor_partition),
]


def make_plot():
    fig, axes = plt.subplots(4, 4, figsize=(18, 14),
                             sharey=False,
                             constrained_layout=True)

    for ax, (name, color, pfn) in zip(axes.flat, PARTITIONS):
        cells = pfn(N)
        m_all, E_all, pk_m, pk_E = build_profiles(cells)

        ax.fill_between(m_all, 0, E_all, color=color, alpha=0.35)
        ax.plot(m_all, E_all, '-', color=color, linewidth=0.2)
        ax.plot(pk_m, pk_E, '-', color='#333333', linewidth=1.2)

        ax.set_xlim(1.0, 2.0)
        ax.ticklabel_format(axis='y', style='scientific', scilimits=(0, 0),
                            useMathText=True)
        ax.yaxis.get_offset_text().set_visible(False)
        ax.tick_params(labelsize=6)

        ratio = pk_E.max() / pk_E.min() if pk_E.min() > 0 else float('inf')
        ax.set_title(f'{name}: {ratio:.4f} peak ratio',
                     fontsize=9, fontweight='bold')

    for ax in axes[:, 0]:
        ax.set_ylabel('per-cell error', fontsize=8)
    for ax in axes[3, :]:
        ax.set_xlabel('$m$', fontsize=8)

    fig.suptitle(
        f'Peak envelope shapes across sixteen partition geometries\n'
        f'$N = {N}$ cells on $[1,\\, 2)$',
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/zoo/partition_zoo.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Partition zoo diagnostics")
    print("=" * 60)
    print(f"  N = {N}")
    for name, _, pfn in PARTITIONS:
        cells = pfn(N)
        _, _, _, pk_E = build_profiles(cells)
        ratio = pk_E.max() / pk_E.min() if pk_E.min() > 0 else float('inf')
        print(f"  {name:18s}  peak range: {pk_E.min():.4e} .. {pk_E.max():.4e}  "
              f"ratio={ratio:.2f}:1")
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
