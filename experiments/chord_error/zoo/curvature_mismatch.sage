"""
curvature_mismatch.sage — Cell width vs locally optimal width for all sixteen
partition kinds.

Sixteen panels (4x4 grid).  Each panel plots one dot per cell at
(m_peak, mismatch_ratio) where mismatch_ratio = actual_width / optimal_width.
The optimal width at position m is m * ln(2) / N (the geometric cell width).
Points above y=1 are under-resolved; points below are over-resolved.

Run:  ./sagew experiments/zoo/curvature_mismatch.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2, sin, pi


# ── Configuration ────────────────────────────────────────────────────

N = 512
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
    return [(float(bdry[j][0]) / bdry[j][1], float(bdry[j + 1][0]) / bdry[j + 1][1]) for j in range(N)]


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

def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def cell_mismatch(a, b):
    """Return (m_peak, mismatch_ratio) for a cell [a, b]."""
    m_pk = log_mean(a, b)
    actual_width = b - a
    optimal_width = m_pk * log(2) / N
    return m_pk, actual_width / optimal_width


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
    fig, axes = plt.subplots(4, 4, figsize=(18, 14),
                             sharey=False,
                             constrained_layout=True)

    for ax, (name, color, pfn) in zip(axes.flat, PARTITIONS):
        cells = pfn(N)
        m_peaks = []
        ratios = []

        for a, b in cells:
            m_pk, r = cell_mismatch(a, b)
            m_peaks.append(m_pk)
            ratios.append(r)

        ax.scatter(m_peaks, ratios, c=color, s=12, alpha=0.6,
                   edgecolors='none', zorder=3)

        ax.axhline(1.0, color='#999999', linewidth=0.8, linestyle='--',
                   zorder=1)
        ax.set_yscale('log')
        ax.set_xlim(1.0, 2.0)
        ax.tick_params(labelsize=6)

        ax.set_title(name, fontsize=9, fontweight='bold')

    for ax in axes[:, 0]:
        ax.set_ylabel('width / optimal width', fontsize=8)
    for ax in axes[3, :]:
        ax.set_xlabel('$m_{\\mathrm{peak}}$', fontsize=8)

    fig.suptitle(
        'Curvature mismatch: cell width / locally optimal width\n'
        '$N = %d$ cells on $[1,\\, 2)$, $y = 1$ is geometric (equioscillation)' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/zoo/curvature_mismatch.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Curvature mismatch diagnostics")
    print("=" * 60)
    print("  N = %d" % N)
    for name, _, pfn in PARTITIONS:
        cells = pfn(N)
        log2_ratios = []
        for a, b in cells:
            _, r = cell_mismatch(a, b)
            log2_ratios.append(math_log2(r))

        arr = np.array(log2_ratios)
        print("  %-18s  log2(ratio): [%+.4f, %+.4f]  std=%.4f" %
              (name, arr.min(), arr.max(), arr.std()))

    # Verification: geometric should be within 5% of 1.0
    print()
    geo_cells = geometric_partition(N)
    geo_max_dev = 0.0
    for a, b in geo_cells:
        _, r = cell_mismatch(a, b)
        geo_max_dev = max(geo_max_dev, abs(r - 1.0))
    print("  Geometric max deviation from 1.0: %.6f (%.2f%%)" %
          (geo_max_dev, 100 * geo_max_dev))
    assert geo_max_dev < 0.05, (
        "Geometric mismatch exceeds 5%%: %.4f" % geo_max_dev)
    print("  PASS: geometric within 5%% tolerance")
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
