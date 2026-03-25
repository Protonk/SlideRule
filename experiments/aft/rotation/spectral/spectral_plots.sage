"""
spectral_plots.sage — Plots for the Walsh spectral experiment.

Plot A: q-scan stacked bars (FSM P^k profile across q values)
Plot B: geometry vs placement (geometric, reverse, bitrev at q=3)
Plot C: inherited vs induced (P(ε), P(δ*), P(r_FSM), ensemble median)
Plot D: shape-statistic null (JSD histogram with FSM score)

Run:  ./sagew experiments/aft/rotation/spectral/spectral_plots.sage
"""

import csv
import os

from helpers import pathing

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

RESULTS_DIR = pathing('experiments', 'aft', 'rotation', 'spectral', 'results')
PHASE_A_CSV = os.path.join(RESULTS_DIR, 'spectral_phase_a.csv')
PHASE_C_CSV = os.path.join(RESULTS_DIR, 'spectral_phase_c.csv')

# Load Phase A data
with open(PHASE_A_CSV) as f:
    phase_a = list(csv.DictReader(f))

# Load Phase C data
with open(PHASE_C_CSV) as f:
    phase_c = list(csv.DictReader(f))

def _lookup(rows, depth, q, kind, mode='LI'):
    for r in rows:
        if (int(r['depth']) == depth and int(r['q']) == q
                and r['kind'] == kind and r['layer_mode'] == mode):
            return r
    return None

def _load_sidecar(depth, q, kind, mode='LI'):
    fname = f'spectral_{depth}_{q}_{kind}_{mode}.npz'
    path = os.path.join(RESULTS_DIR, fname)
    return np.load(path)


# ── Plot A: q-scan stacked bars ──────────────────────────────────────

def plot_a():
    fig, axes = plt.subplots(2, 3, figsize=(14, 7), sharey=True)
    kinds = ['geometric_x', 'uniform_x', 'harmonic_x',
             'reverse_geometric_x', 'bitrev_geometric_x', 'stern_brocot_x']
    kind_labels = ['geometric', 'uniform', 'harmonic',
                   'rev-geometric', 'bitrev-geometric', 'stern-brocot']
    qs = [2, 3, 4, 5, 6]
    depth = 9
    d = depth

    colors = plt.cm.viridis(np.linspace(0.1, 0.9, d + 1))

    for ax, kind, klabel in zip(axes.flat, kinds, kind_labels):
        bottoms = np.zeros(len(qs))
        for k in range(d + 1):
            vals = []
            for q in qs:
                sc = _load_sidecar(depth, q, kind)
                vals.append(float(sc['P_fsm'][k]))
                sc.close()
            vals = np.array(vals)
            ax.bar(range(len(qs)), vals, bottom=bottoms, color=colors[k],
                   label=f'k={k}' if kind == kinds[0] else None, width=0.7)
            bottoms += vals

        ax.set_xticks(range(len(qs)))
        ax.set_xticklabels([str(q) for q in qs])
        ax.set_title(klabel, fontsize=11, fontweight='bold')
        ax.set_xlabel('q')
        if ax in [axes[0, 0], axes[1, 0]]:
            ax.set_ylabel('P^k (normalised)')

    axes[0, 0].legend(fontsize=7, ncol=2, loc='upper right',
                       title='Walsh level', title_fontsize=8)
    fig.suptitle('FSM Walsh profile by q  (d=9, LI)',
                 fontsize=14, fontweight='bold', y=1.01)
    fig.tight_layout()
    out = os.path.join(RESULTS_DIR, 'plot_a_qscan.png')
    fig.savefig(out, dpi=180, bbox_inches='tight')
    plt.close(fig)
    print(f'  Saved {out}')


# ── Plot B: geometry vs placement ────────────────────────────────────

def plot_b():
    fig, axes = plt.subplots(1, 5, figsize=(16, 3.5), sharey=True)
    kinds = ['geometric_x', 'reverse_geometric_x', 'bitrev_geometric_x']
    kind_labels = ['geometric', 'rev-geometric', 'bitrev-geometric']
    colors = ['#2166ac', '#b2182b', '#4dac26']
    depth = 9
    d = depth

    for ax, q in zip(axes, [2, 3, 4, 5, 6]):
        x = np.arange(d + 1)
        width = 0.25
        for i, (kind, klabel, color) in enumerate(zip(kinds, kind_labels, colors)):
            sc = _load_sidecar(depth, q, kind)
            P = sc['P_fsm']
            sc.close()
            ax.bar(x + (i - 1) * width, P, width=width, color=color,
                   label=klabel if q == 2 else None, alpha=0.85)

        ax.set_xticks(x)
        ax.set_xlabel('Walsh level k')
        ax.set_title(f'q = {q}', fontsize=11, fontweight='bold')

    axes[0].set_ylabel('P^k')
    axes[0].legend(fontsize=8, loc='upper right')
    fig.suptitle('Geometry vs placement  (d=9, LI)',
                 fontsize=14, fontweight='bold', y=1.04)
    fig.tight_layout()
    out = os.path.join(RESULTS_DIR, 'plot_b_placement.png')
    fig.savefig(out, dpi=180, bbox_inches='tight')
    plt.close(fig)
    print(f'  Saved {out}')


# ── Plot C: inherited vs induced ─────────────────────────────────────

def plot_c():
    configs = [
        (3, 'geometric_x', 'geometric q=3'),
        (3, 'stern_brocot_x', 'stern-brocot q=3'),
        (5, 'uniform_x', 'uniform q=5'),
    ]
    depth = 9
    d = depth

    fig, axes = plt.subplots(1, 3, figsize=(15, 4), sharey=True)

    for ax, (q, kind, title) in zip(axes, configs):
        sc = _load_sidecar(depth, q, kind)
        x = np.arange(d + 1)

        # Ensemble median
        ens_median = np.median(sc['ensemble_P_norm'], axis=0)

        ax.bar(x - 0.3, sc['P_eps'], width=0.2, color='#cccccc',
               label='P(ε)', alpha=0.9)
        ax.bar(x - 0.1, sc['P_delta_star'], width=0.2, color='#888888',
               label='P(δ*)', alpha=0.9)
        ax.bar(x + 0.1, sc['P_fsm'], width=0.2, color='#b2182b',
               label='P(r_FSM)', alpha=0.9)
        ax.bar(x + 0.3, ens_median, width=0.2, color='#2166ac',
               label='P(r_rand) med', alpha=0.9)

        ax.set_xticks(x)
        ax.set_xlabel('Walsh level k')
        ax.set_title(title, fontsize=11, fontweight='bold')
        sc.close()

    axes[0].set_ylabel('P^k')
    axes[0].legend(fontsize=8, loc='upper right')
    fig.suptitle('Inherited vs induced spectrum  (d=9, LI)',
                 fontsize=14, fontweight='bold', y=1.04)
    fig.tight_layout()
    out = os.path.join(RESULTS_DIR, 'plot_c_inherited.png')
    fig.savefig(out, dpi=180, bbox_inches='tight')
    plt.close(fig)
    print(f'  Saved {out}')


# ── Plot D: shape-statistic null ─────────────────────────────────────

def plot_d():
    configs = [
        (3, 'geometric_x', 'geometric q=3'),
        (3, 'stern_brocot_x', 'stern-brocot q=3'),
        (5, 'bitrev_geometric_x', 'bitrev q=5'),
    ]
    depth = 9

    fig, axes = plt.subplots(1, 3, figsize=(14, 3.5))

    for ax, (q, kind, title) in zip(axes, configs):
        sc = _load_sidecar(depth, q, kind)
        null = sc['shape_null']
        sc_data = np.load(os.path.join(RESULTS_DIR,
                          f'spectral_{depth}_{q}_{kind}_LI.npz'))

        # Get FSM JSD from CSV
        r = _lookup(phase_a, depth, q, kind)
        jsd_fsm = float(r['jsd_fsm'])

        ax.hist(null, bins=50, color='#2166ac', alpha=0.7,
                edgecolor='white', linewidth=0.5, density=True)
        ax.axvline(jsd_fsm, color='#b2182b', linewidth=2,
                   label=f'FSM = {jsd_fsm:.4f}')
        ax.set_xlabel('JSD to reference')
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.legend(fontsize=9)
        sc_data.close()

    axes[0].set_ylabel('density')
    fig.suptitle('Shape-statistic null distribution  (d=9, LI)',
                 fontsize=14, fontweight='bold', y=1.04)
    fig.tight_layout()
    out = os.path.join(RESULTS_DIR, 'plot_d_shape_null.png')
    fig.savefig(out, dpi=180, bbox_inches='tight')
    plt.close(fig)
    print(f'  Saved {out}')


# ── Run ──────────────────────────────────────────────────────────────

print('Spectral plots')
print()
plot_a()
plot_b()
plot_c()
plot_d()
print()
print('Done.')
