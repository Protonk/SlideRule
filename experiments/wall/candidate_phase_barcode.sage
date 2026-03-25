"""
candidate_phase_barcode.sage — Per-cell worst-candidate type barcode.

Strips colored by worst_candidate_type (endpoint, H, D) for a single case.
Shows whether the wall concentrates at endpoints or at interior competition
points, and whether the phase changes between LI and LD.

Run:  ./sagew experiments/wall/candidate_phase_barcode.sage
"""

import csv
import os

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Patch


# ── Configuration ────────────────────────────────────────────────────

RUN_TAG = 'wall_surface_2026-03-18'
KIND = 'geometric_x'
Q = 3
DEPTH = 6
EXPONENT = '1/2'
PERCELL_PATH = pathing('experiments', 'aft', 'keystone', 'results', RUN_TAG, 'percell.csv')
OUT_PATH = pathing('experiments', 'wall', 'results', 'candidate_phase_barcode.png')

TYPE_COLORS = {
    'endpoint': '#e74c3c',
    'H': '#3498db',
    'D': '#2ecc71',
    '': '#cccccc',
}

TYPE_LABELS = {
    'endpoint': 'endpoint',
    'H': 'H-grid crossing',
    'D': 'D-candidate (interior)',
    '': 'unknown',
}

SHORT = {
    'uniform_x': 'uniform',
    'geometric_x': 'geometric',
    'harmonic_x': 'harmonic',
    'mirror_harmonic_x': 'mirror-harmonic',
}


# ── Load ─────────────────────────────────────────────────────────────

def load_cells(filepath, kind, q, depth, exponent, layer_dependent):
    ld_str = str(layer_dependent)
    cells = []
    with open(filepath, 'r', newline='') as f:
        for r in csv.DictReader(f):
            if (r['partition_kind'] == kind
                    and r['q'] == str(q) and r['depth'] == str(depth)
                    and r['exponent'] == exponent
                    and r['layer_dependent'] == ld_str):
                cells.append({
                    'x_lo': float(r['x_lo']),
                    'x_hi': float(r['x_hi']),
                    'x_mid': float(r['x_mid']),
                    'type': r.get('worst_candidate_type', ''),
                    'err': float(r['cell_worst_err']),
                })
    cells.sort(key=lambda c: c['x_lo'])
    return cells


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, axes = plt.subplots(2, 1, figsize=(12, 4), constrained_layout=True)
    strip_h = 0.8

    seen_types = set()

    for ax, (ld, ld_label) in zip(axes, [(False, 'LI'), (True, 'LD')]):
        cells = load_cells(PERCELL_PATH, KIND, Q, DEPTH, EXPONENT, ld)
        if not cells:
            ax.text(0.5, 0.5, 'no data', ha='center', va='center',
                    transform=ax.transAxes)
            continue

        # Find worst cell
        worst_idx = max(range(len(cells)), key=lambda i: cells[i]['err'])

        for i, c in enumerate(cells):
            ctype = c['type']
            color = TYPE_COLORS.get(ctype, TYPE_COLORS[''])
            seen_types.add(ctype)
            rect = Rectangle((c['x_lo'], 0), c['x_hi'] - c['x_lo'], strip_h,
                              facecolor=color, edgecolor='white',
                              linewidth=0.3)
            ax.add_patch(rect)

            # Mark worst cell
            if i == worst_idx:
                ax.plot(c['x_mid'], strip_h + 0.05, 'v', color='black',
                        markersize=6, zorder=5)

        ax.set_xlim(1.0, 2.0)
        ax.set_ylim(-0.05, strip_h + 0.15)
        ax.set_yticks([])
        ax.tick_params(axis='x', labelsize=8)
        ax.set_ylabel(ld_label, fontsize=10, fontweight='bold')

        # Type counts
        type_counts = {}
        for c in cells:
            t = c['type'] if c['type'] else 'unknown'
            type_counts[t] = type_counts.get(t, 0) + 1
        count_str = '  '.join('%s: %d' % (t, n) for t, n in sorted(type_counts.items()))
        ax.text(0.01, 0.95, count_str, transform=ax.transAxes,
                fontsize=7, va='top', color='#555555')

    axes[1].set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=9)

    # Legend
    legend_patches = [Patch(facecolor=TYPE_COLORS[t], label=TYPE_LABELS[t])
                      for t in ['endpoint', 'H', 'D'] if t in seen_types]
    fig.legend(handles=legend_patches, loc='lower center', ncol=3,
               fontsize=8, bbox_to_anchor=(0.5, -0.04))

    kind_short = SHORT.get(KIND, KIND)
    fig.suptitle(
        'Candidate phase barcode: %s, $q = %d$, depth $= %d$, exponent $= %s$'
        % (kind_short, Q, DEPTH, EXPONENT),
        fontsize=12, fontweight='bold',
    )

    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Candidate phase barcode: %s, q=%d, depth=%d" % (KIND, Q, DEPTH))
make_plot()
print("Done.")
