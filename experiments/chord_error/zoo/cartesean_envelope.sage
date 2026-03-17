"""
cartesean_envelope.sage — Peak envelopes for all sixteen partition kinds.

Sixteen panels (4x4 grid) with independent y-scales showing per-cell chord
error sawtooths with peak envelopes.

Run:  ./sagew experiments/chord_error/zoo/cartesean_envelope.sage
"""

from helpers import pathing
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, log2 as math_log2


# ── Configuration ────────────────────────────────────────────────────

DEPTH = 6   # N = 64
M_PER_CELL = 40


# ── Math ─────────────────────────────────────────────────────────────

def cell_chord_slope(a, b):
    return (math_log2(b) - math_log2(a)) / (b - a)


def log_mean(a, b):
    return (b - a) / (log(b) - log(a))


def build_profiles(cells):
    m_segments = []
    E_segments = []
    peak_ms = []
    peak_Es = []

    for a, b in cells:
        sigma = cell_chord_slope(a, b)
        ms = np.linspace(a, b, M_PER_CELL)
        chord_vals = math_log2(a) + sigma * (ms - a)
        E_vals = np.log2(ms) - chord_vals

        m_segments.append(ms)
        E_segments.append(E_vals)

        m_pk = log_mean(a, b)
        E_pk = math_log2(m_pk) - (math_log2(a) + sigma * (m_pk - a))
        peak_ms.append(m_pk)
        peak_Es.append(E_pk)

    m_all = np.concatenate(m_segments)
    E_all = np.concatenate(E_segments)
    return m_all, E_all, np.array(peak_ms), np.array(peak_Es)


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    N = 2**DEPTH
    fig, axes = plt.subplots(4, 4, figsize=(18, 14),
                             sharey=False,
                             constrained_layout=True)

    for ax, (name, color, kind) in zip(axes.flat, PARTITION_ZOO):
        cells = float_cells(DEPTH, kind)
        m_all, E_all, pk_m, pk_E = build_profiles(cells)

        ax.fill_between(m_all, 0, E_all, color=color, alpha=0.35)
        ax.plot(m_all, E_all, '-', color=color, linewidth=0.2)
        ax.plot(pk_m, pk_E, '-', color='#333333', linewidth=1.2)

        ax.set_xlim(1.0, 2.0)
        ax.ticklabel_format(axis='y', style='scientific', scilimits=(0, 0),
                            useMathText=True)
        ax.yaxis.get_offset_text().set_visible(False)
        ax.tick_params(labelsize=6)

        ratio = pk_E.max() / pk_E.min() if pk_E.min() > 0 else float('inf')
        ax.set_title('%s: %.4f peak ratio' % (name, ratio),
                     fontsize=9, fontweight='bold')

    for ax in axes[:, 0]:
        ax.set_ylabel('per-cell error', fontsize=8)
    for ax in axes[3, :]:
        ax.set_xlabel('$m$', fontsize=8)

    fig.suptitle(
        'Peak envelope shapes across sixteen partition geometries\n'
        '$N = %d$ cells on $[1,\\, 2)$' % N,
        fontsize=13, fontweight='bold',
    )

    out_path = 'experiments/chord_error/zoo/cartesean_envelope.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print("Saved: %s" % out_path)


# ── Diagnostics ──────────────────────────────────────────────────────

def print_diagnostics():
    N = 2**DEPTH
    print()
    print("Partition zoo diagnostics")
    print("=" * 60)
    print("  N = %d" % N)
    for name, _, kind in PARTITION_ZOO:
        cells = float_cells(DEPTH, kind)
        _, _, _, pk_E = build_profiles(cells)
        ratio = pk_E.max() / pk_E.min() if pk_E.min() > 0 else float('inf')
        print("  %-18s  peak range: %.4e .. %.4e  ratio=%.2f:1" %
              (name, pk_E.min(), pk_E.max(), ratio))
    print()


# ── Main ─────────────────────────────────────────────────────────────

print_diagnostics()
make_plot()
print("Done.")
