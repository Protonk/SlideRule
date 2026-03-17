"""
counter_factual.sage — Damage ribbon across sixteen partition geometries.

For each cell in a partition of [1, 2], the ribbon spans from -incoming
(bottom) to exported (top).  A flat ribbon hugging zero means balanced
damage exchange; asymmetry reveals which cells are net exporters or
importers of chord error.

This is a gestural comparison — the shape and symmetry of the ribbon
matter more than any single value.

Run:  ./sagew experiments/error/counter_factual.sage
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2, sin, pi, cos, sqrt, fmod


# ── Partition builders ───────────────────────────────────────────────

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


def sinusoidal_partition(N, k=3, alpha=0.6):
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
    return [(float(bdry[j][0]) / bdry[j][1],
             float(bdry[j + 1][0]) / bdry[j + 1][1]) for j in range(N)]


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


# ── Foreign error matrix ─────────────────────────────────────────────

def cell_chord(a, b):
    la, lb = log2(a), log2(b)
    sigma = (lb - la) / (b - a)
    return sigma, la


def chord_eval(sigma, intercept, a, m):
    return intercept + sigma * (m - a)


def _foreign_peak_error(sigma_j, intercept_j, a_j, a_k, b_k):
    f_at_a = log2(a_k) - chord_eval(sigma_j, intercept_j, a_j, a_k)
    f_at_b = log2(b_k) - chord_eval(sigma_j, intercept_j, a_j, b_k)
    best = max(abs(f_at_a), abs(f_at_b))

    if sigma_j > 0:
        m_star_j = 1.0 / (sigma_j * log(2.0))
        if a_k < m_star_j < b_k:
            f_at_star = log2(m_star_j) - chord_eval(
                sigma_j, intercept_j, a_j, m_star_j
            )
            best = max(best, abs(f_at_star))

    return best


def build_error_matrix(cells):
    N = len(cells)
    E = [[0.0] * N for _ in range(N)]
    chords = [cell_chord(a, b) for a, b in cells]

    for j in range(N):
        sigma_j, intercept_j = chords[j]
        a_j = cells[j][0]
        for k in range(N):
            a_k, b_k = cells[k]
            E[j][k] = _foreign_peak_error(sigma_j, intercept_j, a_j, a_k, b_k)

    return E


def _lower_median(vals):
    return vals[(len(vals) - 1) // 2]


def exported_damage(E):
    N = len(E)
    result = []
    for j in range(N):
        row = sorted(E[j][k] for k in range(N) if k != j)
        result.append(_lower_median(row))
    return result


def incoming_damage(E):
    N = len(E)
    result = []
    for k in range(N):
        col = sorted(E[j][k] for j in range(N) if j != k)
        result.append(_lower_median(col))
    return result


# ── Compute ribbon arrays ────────────────────────────────────────────

def compute_ribbon(cells):
    N = len(cells)
    x_pos = [(a + b) / 2.0 for a, b in cells]

    E = build_error_matrix(cells)
    exp = exported_damage(E)
    inc = incoming_damage(E)

    return np.array(x_pos), np.array(exp), np.array(inc)


# ── Plotting ─────────────────────────────────────────────────────────

THE_N = 128
PARTITION_BUILDERS = [
    ('uniform',           '#1f77b4', uniform_partition),
    ('geometric',         '#9467bd', geometric_partition),
    ('harmonic',          '#2ca02c', harmonic_partition),
    ('mirror-harmonic',   '#d62728', mirror_harmonic_partition),
    ('ruler',             '#e67e22', ruler_partition),
    ('sinusoidal',        '#17becf', sinusoidal_partition),
    ('chebyshev',         '#8c564b', chebyshev_partition),
    ('thue-morse',        '#e377c2', thuemorse_partition),
    ('bitrev-geometric',  '#7f7f7f', bitrev_geometric_partition),
    ('stern-brocot',      '#bcbd22', stern_brocot_partition),
    ('reverse-geometric', '#ff7f0e', reverse_geometric_partition),
    ('random',            '#aec7e8', random_partition),
    ('dyadic',            '#98df8a', dyadic_partition),
    ('power-law',         '#ff9896', powerlaw_partition),
    ('golden',            '#c5b0d5', golden_partition),
    ('cantor',            '#c49c94', cantor_partition),
]


def plot_ribbons(all_data):
    fig, axes = plt.subplots(
        4, 4,
        figsize=(18, 12),
        sharex=True,
        squeeze=False,
    )

    for idx, (kind, color, builder) in enumerate(PARTITION_BUILDERS):
        row, col = divmod(idx, 4)
        ax = axes[row][col]
        x_pos, exp, inc = all_data[kind]

        ax.fill_between(x_pos, -inc, exp, color=color, alpha=0.4)
        ax.axhline(0, color='#333333', linewidth=0.4)
        ax.plot(x_pos, exp, '-', color=color, linewidth=0.6, alpha=0.8)
        ax.plot(x_pos, -inc, '-', color=color, linewidth=0.6, alpha=0.8)

        ax.set_xlim(0.98, 2.02)
        ax.set_title(kind, fontsize=9, fontweight='bold')

        # Gestural: hide numeric ticks, just show zero line
        ax.set_yticks([0])
        ax.set_yticklabels(['0'], fontsize=6, color='#666666')
        ax.tick_params(axis='y', length=0)
        ax.tick_params(axis='x', labelsize=6)

        if row == 3:
            ax.set_xlabel('$m$', fontsize=9)

    # Left-side labels: top half = exported, bottom half = incoming
    for ax in axes[:, 0]:
        ax.annotate('exp', xy=(0, 1), xycoords='axes fraction',
                    xytext=(-4, -6), textcoords='offset points',
                    fontsize=6, color='#999999', ha='right', va='top')
        ax.annotate('inc', xy=(0, 0), xycoords='axes fraction',
                    xytext=(-4, 6), textcoords='offset points',
                    fontsize=6, color='#999999', ha='right', va='bottom')

    fig.suptitle(
        'Counterfactual damage ribbons across partition geometries',
        fontsize=13, fontweight='bold', y=0.99,
    )
    fig.text(0.5, 0.965,
             'ribbon width = damage asymmetry per cell  |  '
             'flat at zero = balanced exchange  |  N=%d' % THE_N,
             ha='center', fontsize=9, color='#666666')
    fig.tight_layout(rect=[0, 0, 1, 0.955])

    out_path = 'experiments/error/counter_factual.png'
    fig.savefig(out_path, dpi=180)
    print("Saved: %s" % out_path)


# ── Precompute ────────────────────────────────────────────────────────

def precompute_all():
    import sys
    all_data = {}
    total = len(PARTITION_BUILDERS)
    count = 0

    for kind, color, builder in PARTITION_BUILDERS:
        count += 1
        sys.stdout.write("  [%2d/%d] %-20s ... " % (count, total, kind))
        sys.stdout.flush()
        cells = builder(THE_N)
        x_pos, exp, inc = compute_ribbon(cells)
        all_data[kind] = (x_pos, exp, inc)
        sys.stdout.write("done\n")
        sys.stdout.flush()

    return all_data


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics(all_data):
    print()
    print("Counterfactual diagnostics  (N=%d)" % THE_N)
    print("=" * 70)
    print("  %-20s  max(exp)  max(inc)  exporters" % "partition")
    print("  " + "-" * 60)

    for kind, color, builder in PARTITION_BUILDERS:
        x_pos, exp, inc = all_data[kind]
        N = len(x_pos)
        exporters = sum(1 for j in range(N) if exp[j] > inc[j] + 1e-14)
        print("  %-20s  %8.6f  %8.6f  %4d/%d" %
              (kind, exp.max(), inc.max(), exporters, N))

    print()


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Counterfactual damage ribbons  (N=%d)" % THE_N)
print("=" * 60)
print()

all_data = precompute_all()
print_diagnostics(all_data)
plot_ribbons(all_data)
print("Done.")
