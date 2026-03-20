"""
curated.sage — Slope deviation for six hand-picked partition geometries.

2x3 grid: uniform (baseline), geometric (thesis winner), harmonic (same
aggressiveness, different direction), mirror-harmonic (wrong end), ruler
(fractal), random (null model).

Run:  ./sagew experiments/stepstone/hazards/curated.sage
"""

import os
_here = os.path.dirname(os.path.abspath(__file__))
load(os.path.join(_here, '_slope_deviation.sage'))


# ── Configuration ────────────────────────────────────────────────────

SELECTION = [
    ('uniform',         'uniform_x'),
    ('geometric',       'geometric_x'),
    ('harmonic',        'harmonic_x'),
    ('mirror-harmonic', 'mirror_harmonic_x'),
    ('ruler',           'ruler_x'),
    ('random',          'random_x'),
]


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, axes = plt.subplots(2, 3, figsize=(15, 7), constrained_layout=True)

    for ax, (name, kind) in zip(axes.flat, SELECTION):
        render_panel(ax, kind, show_legend=(name == 'uniform'))
        ax.set_title(name, fontsize=10, fontweight='bold')

    for ax in axes[:, 0]:
        ax.set_ylabel(r'$\sigma_j - 1$', fontsize=9)
    for ax in axes[1, :]:
        ax.set_xlabel('$m$', fontsize=9)

    ns = ', '.join('$%d$' % (2**d) for d in DEFAULT_DEPTHS)
    fig.suptitle(
        'Slope deviation step functions across partition geometries\n'
        '$N \\in \\{%s\\}$ on $[1,\\, 2)$' % ns.replace('$, $', ',\\, '),
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/stepstone/hazards/results/curated.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

make_plot()
print("Done.")
