"""
integrate_coastline.sage — Area between the continuous slope curve and the
uniform step function at increasing N.

Bar chart: x-axis labeled by N = 4, 8, 16, 32, 64, 128; y-axis is the
integral of |1/(m ln 2) - 1 - step(m)| over [1, 2].

Run:  ./sagew experiments/stepstone/integrate_coastline.sage
"""

from helpers import pathing
load(pathing('experiments', 'ripple', 'coastline.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ── Configuration ────────────────────────────────────────────────────

DEPTHS = [2, 3, 4, 5, 6, 7]   # N = 4, 8, 16, 32, 64, 128


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    Ns = [2**d for d in DEPTHS]
    areas = [coastline_area(d, 'uniform_x') for d in DEPTHS]

    fig, ax = plt.subplots(figsize=(8, 4.5), constrained_layout=True)

    bars = ax.bar(range(len(Ns)), areas, color='#e67e22', alpha=0.8,
                  edgecolor='#c0392b', linewidth=0.8)

    ax.set_xticks(range(len(Ns)))
    ax.set_xticklabels(['$N = %d$' % n for n in Ns], fontsize=9)
    ax.set_ylabel(r'$\int_1^2 \left|\frac{1}{m\ln 2} - 1 - (\sigma_j - 1)\right|\, dm$',
                  fontsize=10)
    ax.tick_params(labelsize=8)

    for i, (bar, area) in enumerate(zip(bars, areas)):
        ax.text(bar.get_x() + bar.get_width() / 2.0, bar.get_height(),
                '%.4f' % area, ha='center', va='bottom', fontsize=7,
                color='#555555')

    fig.suptitle(
        'Coastline area: step function vs continuous slope curve\n'
        'Uniform partition on $[1,\\, 2)$',
        fontsize=12, fontweight='bold',
    )

    out_path = 'experiments/stepstone/integrate_coastline.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    print()
    print("Coastline area diagnostics")
    print("=" * 45)
    for d in DEPTHS:
        N = 2**d
        area = coastline_area(d, 'uniform_x')
        print("  N = %4d   area = %.6f" % (N, area))
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
