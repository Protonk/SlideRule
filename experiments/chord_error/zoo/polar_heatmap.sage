"""
polar_heatmap.sage — Per-cell error heatmaps in polar coordinates.

Each panel wraps the heatmap around a circle: angle = rescaled coordinate
t in [0, 2*pi], radius = cell index j, color = E(t).  Geometric gives
uniform concentric rings; non-geometric partitions show asymmetric or
barcode-like ring patterns.

Run:  ./sagew experiments/zoo/polar_heatmap.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from math import log, log2 as math_log2, sin, pi


# ── Configuration ────────────────────────────────────────────────────

N = 64
M = 200  # angular resolution per arch
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


def rescaled_arch(a, b):
    """Return (t, E) arrays for the rescaled per-cell error on [0, 1]."""
    sigma = cell_chord_slope(a, b)
    t = np.linspace(0, 1, M)
    m = a + t * (b - a)
    chord = math_log2(a) + sigma * (m - a)
    E = np.log2(m) - chord
    return t, E


def build_heatmap(cells):
    """Return an (N, M) array: row j is the rescaled arch for cell j."""
    img = np.zeros((len(cells), M))
    for j, (a, b) in enumerate(cells):
        _, E = rescaled_arch(a, b)
        img[j, :] = E
    return img


# ── Plot ─────────────────────────────────────────────────────────────

PARTITIONS = [
    ('uniform',           uniform_partition),
    ('geometric',         geometric_partition),
    ('harmonic',          harmonic_partition),
    ('mirror harmonic',   mirror_harmonic_partition),
    ('ruler',             ruler_partition),
    ('sinusoidal',        sinusoidal_partition),
    ('chebyshev',         chebyshev_partition),
    ('thue-morse',        thuemorse_partition),
    ('bitrev geometric',  bitrev_geometric_partition),
    ('stern-brocot',      stern_brocot_partition),
    ('reverse geometric', reverse_geometric_partition),
    ('random',            random_partition),
    ('dyadic',            dyadic_partition),
    ('power-law',         powerlaw_partition),
    ('golden ratio',      golden_partition),
    ('cantor dust',       cantor_partition),
]


def make_plot():
    fig, axes = plt.subplots(4, 4, figsize=(18, 18),
                             subplot_kw={'projection': 'polar'},
                             constrained_layout=True)

    for ax, (name, pfn) in zip(axes.flat, PARTITIONS):
        cells = pfn(N)
        img = build_heatmap(cells)

        # Meshgrid: theta edges [0, 2pi] with M+1 edges for M cells,
        # plus one extra to close the circle.
        theta_edges = np.linspace(0, 2 * np.pi, M + 1)
        r_edges = np.arange(N + 1)
        Theta, R = np.meshgrid(theta_edges, r_edges)

        # Per-panel log norm
        pos = img[img > 0]
        if len(pos) > 0:
            vmax = pos.max()
            vmin = max(pos.min(), vmax * 1e-6)
            norm = mcolors.LogNorm(vmin=vmin, vmax=vmax)
        else:
            norm = None

        ax.pcolormesh(Theta, R, img, cmap='inferno', norm=norm,
                      shading='flat')

        ax.set_rlabel_position(0)
        ax.tick_params(labelsize=5)
        ax.set_thetagrids([0, 90, 180, 270],
                          ['$t{=}0$', '$0.25$', '$0.5$', '$0.75$'],
                          fontsize=5, color='#666666')
        ax.yaxis.set_major_formatter(plt.NullFormatter())
        ax.grid(True, linewidth=0.2, alpha=0.3)

        peak_vals = img.max(axis=1)
        ratio = peak_vals.max() / peak_vals.min() if peak_vals.min() > 0 else float('inf')
        ax.set_title(f'{name}: {ratio:.2f}:1',
                     fontsize=9, fontweight='bold', pad=12)

    fig.suptitle(
        f'Polar heatmaps: per-cell error wrapped around the circle\n'
        f'$N = {N}$, $\\theta = 2\\pi t$, $r =$ cell index, log color scale',
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/zoo/polar_heatmap.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"Saved: {out_path}")


# ── Main ─────────────────────────────────────────────────────────────

make_plot()
print("Done.")
