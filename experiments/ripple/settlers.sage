"""
settlers.sage — Sparklines for partitions that converge to a finite
scaled coastline constant, showing the range of convergence speeds.

geometric and arc-length are flat by depth 3. uniform/harmonic take until
depth 7. thue-morse overshoots then recovers. ruler undershoots slightly.
bitrev-geometric is the slowest settler — still visibly moving at depth 12.

Run:  ./sagew experiments/ripple/settlers.sage
"""

from helpers import pathing
load(pathing('experiments', 'ripple', 'coastline.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ── Configuration ────────────────────────────────────────────────────

DEPTHS = list(range(1, 13))   # N = 2 .. 4096
MEASURE = 'log_ratio'

KINDS = [
    'geometric_x',
    'arc_length_x',
    'minimax_chord_x',
    'uniform_x',
    'harmonic_x',
    'thuemorse_x',
    'ruler_x',
    'bitrev_geometric_x',
]

OUT_PATH = pathing('experiments', 'ripple', 'results', 'settlers.png')


# ── Resolve display entries from PARTITION_ZOO ───────────────────────

_zoo_by_kind = {kind: (name, color, kind) for name, color, kind in PARTITION_ZOO}
ENTRIES = [_zoo_by_kind[k] for k in KINDS]


# ── Compute ──────────────────────────────────────────────────────────

def precompute():
    kinds = [kind for _, _, kind in ENTRIES]
    print()
    print("Computing coastline series...")
    raw = coastline_series(kinds, DEPTHS, progress=True)
    scaled = scaled_series(raw, DEPTHS)
    indices, measured, meta = measure_series(scaled, MEASURE)
    plot_Ns = [2**DEPTHS[i] for i in indices]
    return plot_Ns, measured, meta


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot(plot_Ns, measured, meta):
    n_rows = len(ENTRIES)
    fig, axes = plt.subplots(
        n_rows, 1,
        figsize=(10.5, 0.55 * n_rows + 1.8),
        constrained_layout=True,
        sharex=True,
    )

    all_values = [v for _, _, kind in ENTRIES for v in measured[kind]]
    y_max = max(abs(v) for v in all_values) if all_values else 1.0
    y_max = max(y_max * 1.1, 1e-6)

    xs = list(range(len(plot_Ns)))

    for ax, (name, color, kind) in zip(axes, ENTRIES):
        values = measured[kind]
        ax.axhline(0.0, color='#999999', linewidth=0.6, linestyle='--', zorder=1)
        ax.plot(xs, values, color=color, linewidth=1.2, zorder=3)
        ax.scatter(xs, values, color=color, s=12, zorder=4)
        if meta['signed']:
            ax.set_ylim(-y_max, y_max)
        else:
            ax.set_ylim(0.0, y_max)
        ax.set_yticks([])
        ax.tick_params(axis='x', labelsize=8)
        for spine in ('top', 'right', 'left'):
            ax.spines[spine].set_visible(False)
        ax.spines['bottom'].set_color('#cccccc')
        ax.text(-0.02, 0.5, name, transform=ax.transAxes,
                ha='right', va='center', fontsize=8, fontweight='bold')

    axes[-1].set_xticks(xs)
    axes[-1].set_xticklabels(['N=%d' % n for n in plot_Ns], fontsize=8)
    axes[-1].set_xlabel('Depth scale', fontsize=9)

    fig.suptitle(
        'The settlers: convergence of scaled coastline area\n'
        '%s with $B_d = 2^d \\cdot A_d$' % meta['label'],
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

plot_Ns, measured, meta = precompute()
make_plot(plot_Ns, measured, meta)
print("Done.")
