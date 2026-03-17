"""
radar_peaks.sage — Radar plot of per-cell peak errors for all sixteen partitions.

Each cell gets its own angular slice; the radius is E_peak.  Geometric gives a
perfect circle; uniform gives an egg; scrambled partitions give starbursts.

Run:  ./sagew experiments/zoo/radar_peaks.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from math import log, log2 as math_log2, sin, pi


# ── Configuration ────────────────────────────────────────────────────

N = 64
SIN_K = 3
SIN_ALPHA = 0.6


# ── Float partitions ────────────────────────────────────────────────

def uniform_partition(N):
    return [(1.0 + j / N, 1.0 + (j + 1) / N) for j in range(N)]


def geometric_partition(N):
    return [(2.0 ** (j / N), 2.0 ** ((j + 1) / N)) for j in range(N)]


def harmonic_partition(N):
    inv_lo_base = 1.0
    inv_hi_base = 0.5
    cells = []
    for j in range(N):
        inv_lo = inv_lo_base - (inv_lo_base - inv_hi_base) * j / N
        inv_hi = inv_lo_base - (inv_lo_base - inv_hi_base) * (j + 1) / N
        cells.append((1.0 / inv_lo, 1.0 / inv_hi))
    return cells


def mirror_harmonic_partition(N):
    mirror = 3.0
    cells = []
    for j in range(N):
        inv_lo = 1.0 - (1.0 - 0.5) * (N - j) / N
        inv_hi = 1.0 - (1.0 - 0.5) * (N - j - 1) / N
        cells.append((mirror - 1.0 / inv_lo, mirror - 1.0 / inv_hi))
    return cells


def ruler_partition(N):
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
    from math import cos
    bdry = [1.0 + (1.0 - cos(pi * j / N)) / 2.0 for j in range(N + 1)]
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def thuemorse_partition(N, tm_ratio=2.0):
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
    geo_widths = [2.0**((j + 1) / N) - 2.0**(j / N) for j in range(N)]
    rev_widths = list(reversed(geo_widths))
    cum = [1.0]
    s = 1.0
    for wj in rev_widths:
        s += wj
        cum.append(s)
    return [(cum[j], cum[j + 1]) for j in range(N)]


def random_partition(N, seed=42):
    import random as _rng
    _rng.seed(int(seed))
    pts = sorted([_rng.random() for _ in range(N - 1)])
    bdry = [1.0] + [1.0 + t for t in pts] + [2.0]
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def dyadic_partition(N):
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
    exp = 1.0 - p
    a_exp = 1.0**exp
    xe_exp = 2.0**exp
    bdry = []
    for j in range(N + 1):
        val = (a_exp + (j / N) * (xe_exp - a_exp))**(1.0 / exp)
        bdry.append(val)
    bdry[0] = 1.0
    bdry[N] = 2.0
    return [(bdry[j], bdry[j + 1]) for j in range(N)]


def golden_partition(N):
    from math import sqrt, fmod
    phi = float((1.0 + sqrt(5.0)) / 2.0)
    pts = sorted([fmod(float(j) * phi, 1.0) for j in range(1, int(N))])
    bdry = [1.0] + [1.0 + t for t in pts] + [2.0]
    return [(bdry[j], bdry[j + 1]) for j in range(int(N))]


def cantor_partition(N, levels=3):
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


def peak_E(a, b):
    """Return E_peak for a cell."""
    sigma = cell_chord_slope(a, b)
    m_pk = log_mean(a, b)
    return math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))


# ── Plot ─────────────────────────────────────────────────────────────

PARTITIONS = [
    ('uniform',           '#1f77b4', uniform_partition),
    ('geometric',         '#9467bd', geometric_partition),
    ('harmonic',          '#2ca02c', harmonic_partition),
    ('mirror harmonic',   '#d62728', mirror_harmonic_partition),
    ('ruler',             '#e67e22', ruler_partition),
    ('sinusoidal',        '#17becf', sinusoidal_partition),
    ('chebyshev',         '#8c564b', chebyshev_partition),
    ('thue-morse',        '#e377c2', thuemorse_partition),
    ('bitrev geometric',  '#7f7f7f', bitrev_geometric_partition),
    ('stern-brocot',      '#bcbd22', stern_brocot_partition),
    ('reverse geometric', '#ff7f0e', reverse_geometric_partition),
    ('random',            '#aec7e8', random_partition),
    ('dyadic',            '#98df8a', dyadic_partition),
    ('power-law',         '#ff9896', powerlaw_partition),
    ('golden ratio',      '#c5b0d5', golden_partition),
    ('cantor dust',       '#c49c94', cantor_partition),
]


def make_plot():
    fig, axes = plt.subplots(4, 4, figsize=(18, 18),
                             subplot_kw={'projection': 'polar'},
                             constrained_layout=True)

    for ax, (name, color, pfn) in zip(axes.flat, PARTITIONS):
        cells = pfn(N)
        peaks = np.array([peak_E(a, b) for a, b in cells])

        # One angular slice per cell, closed polygon
        theta = np.linspace(0, 2 * np.pi, N, endpoint=False)
        theta_closed = np.append(theta, theta[0])
        peaks_closed = np.append(peaks, peaks[0])

        ax.fill(theta_closed, peaks_closed, color=color, alpha=0.25)
        ax.plot(theta_closed, peaks_closed, '-', color=color, linewidth=1.2)

        # Reference circle at geometric peak level for comparison
        geo_peak = peak_E(2.0**(0.0 / N), 2.0**(1.0 / N))
        ax.plot(np.linspace(0, 2 * np.pi, 200), [geo_peak] * 200,
                '--', color='#999999', linewidth=0.7)

        ax.set_rlabel_position(0)
        ax.tick_params(labelsize=5)
        ax.set_thetagrids([0, 90, 180, 270],
                          ['cell 0', f'cell {N//4}',
                           f'cell {N//2}', f'cell {3*N//4}'],
                          fontsize=5, color='#666666')
        ax.yaxis.set_major_formatter(plt.NullFormatter())
        ax.grid(True, linewidth=0.3, alpha=0.5)

        ratio = peaks.max() / peaks.min() if peaks.min() > 0 else float('inf')
        ax.set_title(f'{name}: {ratio:.2f}:1',
                     fontsize=9, fontweight='bold', pad=12)

    fig.suptitle(
        f'Radar: per-cell peak error by cell index\n'
        f'$N = {N}$ cells on $[1,\\, 2)$, dashed circle = geometric reference',
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/zoo/radar_peaks.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Radar peaks diagnostics")
    print("=" * 60)
    print(f"  N = {N}")
    geo_peak = peak_E(2.0**(0.0 / N), 2.0**(1.0 / N))
    print(f"  geometric reference peak: {geo_peak:.6e}")
    for name, _, pfn in PARTITIONS:
        cells = pfn(N)
        peaks = [peak_E(a, b) for a, b in cells]
        ratio = max(peaks) / min(peaks) if min(peaks) > 0 else float('inf')
        print(f"  {name:18s}  range: {min(peaks):.4e} .. {max(peaks):.4e}  "
              f"ratio={ratio:.2f}:1")
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
