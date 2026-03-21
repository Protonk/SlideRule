"""
displacement_structure.sage — Analyze the intercept displacement pattern.

Examines c_shared - c_free across cells and its relationship to the
automaton's state-transition structure. The goal is to understand
WHY the FSM path algebra pushes intercepts away from per-cell optima.

Run:  ./sagew experiments/wall/displacement_structure.sage
"""

import csv
import os
from collections import defaultdict

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

CASES = [
    # (kind, q, depth, p_num, q_den, layer_dependent)
    ('geometric_x',  3, 6, 1, 2, False),
    ('geometric_x',  3, 6, 1, 2, True),
    ('uniform_x',    3, 6, 1, 2, False),
    ('uniform_x',    3, 6, 1, 2, True),
]

OUT_DIR = pathing('experiments', 'wall', 'results', 'exchange_rate')


# ── Automaton structure helpers ──────────────────────────────────────

def residue_state_path(bits, q):
    """Return the sequence of residue states visited by this bit path."""
    states = [0]
    r = 0
    for b in bits:
        r = (2 * r + b) % q
        states.append(r)
    return tuple(states)


def delta_contributions(bits, c0_rat, delta_rat, q):
    """Return per-layer delta contributions along the path."""
    r = 0
    contribs = []
    for t, b in enumerate(bits):
        key = (r, b)
        # Try layer-dependent key first
        ld_key = (t, r, b)
        if ld_key in delta_rat:
            contribs.append(float(delta_rat[ld_key]))
        elif key in delta_rat:
            contribs.append(float(delta_rat[key]))
        else:
            contribs.append(0.0)
        r = (2 * r + b) % q
    return contribs


def shared_state_count(bits_list, q):
    """For each (layer, state, bit) triple, count how many paths use it."""
    usage = defaultdict(list)
    for idx, bits in enumerate(bits_list):
        r = 0
        for t, b in enumerate(bits):
            usage[(t, r, b)].append(idx)
            r = (2 * r + b) % q
    return usage


# ── Analysis ─────────────────────────────────────────────────────────

def analyze_displacement(kind, q, depth, p_num, q_den, ld):
    """Compute displacement structure for one case."""
    case = compute_case(q, depth, p_num, q_den,
                        partition_kind=kind, layer_dependent=ld)

    partition = case['partition']
    opt_pol = case['opt_pol']
    free_metrics = case['free_metrics']

    c0_rat = opt_pol['c0_rat']
    delta_rat = opt_pol['delta_rat']

    # Free intercepts by bits
    free_by_bits = {}
    for fr in free_metrics['rows']:
        free_by_bits[fr['bits']] = QQ(fr['c_opt'])

    results = []
    all_bits = []
    for row in partition:
        bits = row['bits']
        all_bits.append(bits)
        c_shared = path_intercept(bits, c0_rat, delta_rat, q)
        c_free = free_by_bits[bits]

        state_path = residue_state_path(bits, q)
        contribs = delta_contributions(bits, c0_rat, delta_rat, q)

        results.append({
            'index': row['index'],
            'bits': bits,
            'x_mid': float((row['x_lo'] + row['x_hi']) / 2),
            'c_shared': float(c_shared),
            'c_free': float(c_free),
            'displacement': float(c_shared - c_free),
            'state_path': state_path,
            'final_state': state_path[-1],
            'contribs': contribs,
            'c0': float(c0_rat),
        })

    # Count state-transition sharing
    usage = shared_state_count(all_bits, q)

    return results, usage, case


def print_displacement_report(label, results, usage, q, depth):
    """Print a text report of displacement structure."""
    print()
    print("=" * 72)
    print(label)
    print("=" * 72)

    disps = [r['displacement'] for r in results]
    print()
    print("Displacement statistics:")
    print("  mean:   %+.6f" % np.mean(disps))
    print("  median: %+.6f" % np.median(disps))
    print("  std:    %.6f" % np.std(disps))
    print("  min:    %+.6f" % min(disps))
    print("  max:    %+.6f" % max(disps))
    print("  range:  %.6f" % (max(disps) - min(disps)))

    # Group by final residue state
    print()
    print("Displacement by final residue state:")
    by_state = defaultdict(list)
    for r in results:
        by_state[r['final_state']].append(r['displacement'])

    for state in sorted(by_state.keys()):
        ds = by_state[state]
        print("  state %d: n=%2d  mean=%+.6f  std=%.6f  range=[%+.6f, %+.6f]"
              % (state, len(ds), np.mean(ds), np.std(ds), min(ds), max(ds)))

    # Per-layer delta contribution analysis
    print()
    print("Per-layer delta contribution statistics:")
    for layer in range(depth):
        layer_contribs = [r['contribs'][layer] for r in results]
        print("  layer %d: mean=%+.6f  std=%.6f  range=[%+.6f, %+.6f]"
              % (layer, np.mean(layer_contribs), np.std(layer_contribs),
                 min(layer_contribs), max(layer_contribs)))

    # State-transition sharing: which (layer, state, bit) triples
    # are shared by many paths?
    print()
    print("Most-shared (layer, state, bit) triples:")
    sharing = [(k, len(v)) for k, v in usage.items()]
    sharing.sort(key=lambda x: -x[1])
    for (layer, state, bit), count in sharing[:10]:
        print("  (layer=%d, state=%d, bit=%d): %d paths" %
              (layer, state, bit, count))

    # Correlation: displacement vs cell position
    xs = [r['x_mid'] for r in results]
    corr = np.corrcoef(xs, disps)[0, 1]
    print()
    print("Displacement-position correlation: %.4f" % corr)


# ── Plot ─────────────────────────────────────────────────────────────

def make_displacement_plot(all_results):
    """Multi-panel displacement structure visualization."""
    n = len(all_results)
    fig, axes = plt.subplots(n, 3, figsize=(15, 3.2 * n),
                             constrained_layout=True)
    if n == 1:
        axes = axes.reshape(1, -1)

    for i, (label, results, _, q, _) in enumerate(all_results):
        xs = [r['x_mid'] for r in results]
        disps = [r['displacement'] for r in results]
        states = [r['final_state'] for r in results]

        # Panel 1: displacement vs position
        ax = axes[i, 0]
        ax.bar(xs, disps, width=(xs[1] - xs[0]) * 0.8,
               color=['#3498db' if d > 0 else '#e74c3c' for d in disps],
               alpha=0.7)
        ax.axhline(0, color='#999', linewidth=0.5)
        ax.set_ylabel('Displacement (c_shared - c_free)', fontsize=8)
        ax.set_title(label, fontsize=9, fontweight='bold')
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)

        # Panel 2: color by final residue state
        ax = axes[i, 1]
        cmap = plt.cm.Set1
        state_colors = [cmap(s / max(q, 1)) for s in states]
        ax.bar(xs, disps, width=(xs[1] - xs[0]) * 0.8,
               color=state_colors, alpha=0.7)
        ax.axhline(0, color='#999', linewidth=0.5)
        ax.set_ylabel('Displacement', fontsize=8)
        ax.set_title('Colored by final state (mod %d)' % q, fontsize=9)
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.set_xlim(1.0, 2.0)

        # Legend for states
        unique_states = sorted(set(states))
        handles = [plt.Rectangle((0, 0), 1, 1, color=cmap(s / max(q, 1)),
                                 alpha=0.7) for s in unique_states]
        ax.legend(handles, ['state %d' % s for s in unique_states],
                  fontsize=6, loc='upper right')

        # Panel 3: per-layer delta contributions stacked
        ax = axes[i, 2]
        depth = len(results[0]['contribs'])
        cumulative = np.zeros(len(results))
        c0 = results[0]['c0']
        layer_colors = plt.cm.viridis(np.linspace(0.2, 0.9, depth))

        # Start from c0 offset (c0 is the base, contribs add to it)
        for layer in range(depth):
            layer_vals = np.array([r['contribs'][layer] for r in results])
            ax.bar(xs, layer_vals, bottom=cumulative,
                   width=(xs[1] - xs[0]) * 0.8,
                   color=layer_colors[layer], alpha=0.7,
                   label='layer %d' % layer)
            cumulative += layer_vals

        # Overlay total displacement as line
        ax.plot(xs, disps, color='black', linewidth=1.0, linestyle='--',
                label='total disp', zorder=5)
        ax.axhline(0, color='#999', linewidth=0.5)
        ax.set_ylabel('Delta contributions', fontsize=8)
        ax.set_title('Per-layer decomposition', fontsize=9)
        ax.grid(True, alpha=0.3, linewidth=0.5)
        ax.tick_params(labelsize=7)
        ax.legend(fontsize=6, loc='upper right')
        ax.set_xlim(1.0, 2.0)

    for ax in axes[-1, :]:
        ax.set_xlabel('Cell midpoint $m$ in $[1,\\, 2)$', fontsize=9)

    fig.suptitle('Intercept displacement structure: c_shared - c_free',
                 fontsize=12, fontweight='bold')

    out_path = os.path.join(OUT_DIR, 'displacement_structure.png')
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print()
    print("Saved: %s" % out_path)


# ── Main ─────────────────────────────────────────────────────────────

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

all_results = []

for kind, q, depth, p_num, q_den, ld in CASES:
    ld_tag = "LD" if ld else "LI"
    label = "%s %s q=%d d=%d" % (kind, ld_tag, q, depth)

    results, usage, case = analyze_displacement(
        kind, q, depth, p_num, q_den, ld)

    print_displacement_report(label, results, usage, q, depth)

    all_results.append((label, results, usage, q, case))

    del case
    import gc; gc.collect()

print()
print("Making displacement structure plot...")
make_displacement_plot(all_results)
print()
print("Done.")
