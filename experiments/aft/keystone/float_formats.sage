"""
float_formats.sage — Exhibit Keystone §3: the representation claim.

Normal radix-2 scientific notation gives the binary affine pseudo-log for
free. More generally, a radix-b significand yields a radix-b analogue:
the normalized significand m = x / b^k within each binade [b^k, b^{k+1})
is piecewise-linear in log_b(x). For binary (b=2), the teeth of this
sawtooth are exactly the geometric grid cells, and the residual vanishes
at each tooth boundary (the §2 result).

This script defines three toy float formats (binary, hex, base-3), plots
the significand-as-pseudo-log sawtooth for each across several binades,
and shows the alignment (or misalignment) with binary depth structure.

Run:  ./sagew experiments/aft/keystone/float_formats.sage
"""

import os
from math import log, log2, floor

from helpers import pathing
load(pathing('lib', 'day.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ── Configuration ────────────────────────────────────────────────────

OUT_PATH = pathing('experiments', 'aft', 'keystone', 'results', 'float_formats.png')

FORMATS = [
    {'name': 'binary (b=2)',  'base': 2,  'color': '#9467bd', 'lw': 2.0},
    {'name': 'hex (b=16)',    'base': 16, 'color': '#e74c3c', 'lw': 1.5},
    {'name': 'base-3 (b=3)',  'base': 3,  'color': '#2ca02c', 'lw': 1.5},
]

# Plot range: x in [1, 16] covers multiple binades for all formats
X_LO = 1.0
X_HI = 16.0


# ── Pseudo-log from significand ──────────────────────────────────────

def binade_exponent(x, base):
    """Return k such that x in [base^k, base^{k+1})."""
    return int(floor(log(x) / log(base)))


def significand(x, base):
    """Return m = x / base^k, the significand in [1, base)."""
    k = binade_exponent(x, base)
    return x / (base ** k)


def format_pseudolog(x, base):
    """The pseudo-log that the significand field gives for free.

    Within binade [base^k, base^{k+1}), the significand m = x/base^k
    is in [1, base). Normalized to [0, 1): (m - 1) / (base - 1).
    This is piecewise-linear in log_base(x), resetting at each binade.
    """
    m = significand(x, base)
    return (m - 1.0) / (base - 1.0)


def format_residual(x, base):
    """Residual: log_base(x) mod 1 minus the normalized pseudo-log.

    log_base(x) mod 1 is the fractional part of the "true" position
    within the binade. The pseudo-log approximates it linearly.
    The residual is the departure from truth within one binade.
    """
    frac_log = (log(x) / log(base)) % 1.0
    return frac_log - format_pseudolog(x, base)


# ── Plot ─────────────────────────────────────────────────────────────

def make_plot():
    fig, axes = plt.subplots(2, 2, figsize=(13, 9), constrained_layout=True)

    xs = np.linspace(X_LO + 1e-10, X_HI - 1e-10, 4000)

    # Panel 1: pseudo-log sawtooth across binades
    ax = axes[0, 0]
    for fmt in FORMATS:
        ys = [format_pseudolog(float(x), fmt['base']) for x in xs]
        ax.plot(xs, ys, color=fmt['color'], linewidth=fmt['lw'],
                label=fmt['name'], alpha=0.9)

    # Mark binary binade boundaries
    for k in range(5):
        bx = 2 ** k
        if X_LO <= bx <= X_HI:
            ax.axvline(bx, color='#cccccc', linewidth=0.6, linestyle='--')

    ax.set_xlabel('$x$', fontsize=9)
    ax.set_ylabel('Normalized pseudo-log', fontsize=9)
    ax.set_title('Significand sawtooth across binades', fontsize=10,
                  fontweight='bold')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.2, linewidth=0.4)
    ax.tick_params(labelsize=8)
    ax.set_xlim(X_LO, X_HI)

    # Panel 2: residual within one binade [1, 2) — zoomed
    ax = axes[0, 1]
    xs_binade = np.linspace(1.0 + 1e-10, 2.0 - 1e-10, 1000)
    for fmt in FORMATS:
        if fmt['base'] == 2:
            # For binary, [1, 2) is one full binade
            ys = [format_residual(float(x), fmt['base']) for x in xs_binade]
            ax.plot(xs_binade, ys, color=fmt['color'], linewidth=fmt['lw'],
                    label=fmt['name'])
        else:
            # For other bases, [1, 2) is a partial binade — show the
            # residual of the pseudo-log vs true log_base position
            ys = [format_residual(float(x), fmt['base']) for x in xs_binade]
            ax.plot(xs_binade, ys, color=fmt['color'], linewidth=fmt['lw'],
                    label=fmt['name'], alpha=0.9)

    ax.axhline(0, color='#999999', linewidth=0.5)
    ax.set_xlabel('$x$ in $[1, 2)$', fontsize=9)
    ax.set_ylabel('Residual: frac($\\log_b x$) $-$ pseudo-log', fontsize=9)
    ax.set_title('Residual on $[1, 2)$', fontsize=10, fontweight='bold')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.2, linewidth=0.4)
    ax.tick_params(labelsize=8)

    # Panel 3: binary pseudo-log vs log2 on [1, 2) — the §2 connection
    ax = axes[1, 0]
    xs_b = np.linspace(1.0 + 1e-10, 2.0 - 1e-10, 1000)
    plog_vals = [float(x) - 1.0 for x in xs_b]
    log2_vals = [log2(float(x)) for x in xs_b]
    residual_vals = [l - p for l, p in zip(log2_vals, plog_vals)]

    ax.plot(xs_b, log2_vals, color='#333333', linewidth=1.5, label='$\\log_2(x)$')
    ax.plot(xs_b, plog_vals, color='#9467bd', linewidth=2.0, linestyle='--',
            label='pseudo-log $x - 1$')
    ax.fill_between(xs_b, plog_vals, log2_vals, color='#9467bd', alpha=0.15)

    # Mark boundary zeros
    ax.plot([1.0, 2.0], [0.0, 1.0], 'o', color='#9467bd', markersize=6,
            zorder=5)
    ax.annotate('residual = 0', xy=(1.0, 0.0), xytext=(1.15, -0.05),
                fontsize=7, color='#9467bd',
                arrowprops=dict(arrowstyle='->', color='#9467bd', lw=0.8))
    ax.annotate('residual = 0', xy=(2.0, 1.0), xytext=(1.75, 1.05),
                fontsize=7, color='#9467bd',
                arrowprops=dict(arrowstyle='->', color='#9467bd', lw=0.8))

    ax.set_xlabel('$x$ in $[1, 2)$', fontsize=9)
    ax.set_ylabel('value', fontsize=9)
    ax.set_title('Binary: pseudo-log = significand field',
                  fontsize=10, fontweight='bold')
    ax.legend(fontsize=7, loc='upper left')
    ax.grid(True, alpha=0.2, linewidth=0.4)
    ax.tick_params(labelsize=8)

    # Panel 4: alignment with binary depth structure
    ax = axes[1, 1]

    # Show binary binade boundaries and depth-2 geometric cell boundaries
    # on [1, 16). For binary, they nest perfectly. For base-3, they don't.
    y_positions = {'binary (b=2)': 2.0, 'hex (b=16)': 1.0, 'base-3 (b=3)': 0.0}

    for fmt in FORMATS:
        y = y_positions[fmt['name']]
        base = fmt['base']

        # Draw binade boundaries as tall ticks
        k = 0
        while base ** k <= X_HI:
            bx = base ** k
            if X_LO <= bx <= X_HI:
                ax.plot([bx, bx], [y - 0.3, y + 0.3],
                        color=fmt['color'], linewidth=2.0)
            k += 1

        # Label
        ax.text(0.8, y, fmt['name'], fontsize=8, fontweight='bold',
                color=fmt['color'], ha='right', va='center')

    # Draw binary geometric cell boundaries at depth 2 (4 cells per binade)
    for k in range(4):
        for j in range(5):
            bx = (2 ** k) * 2 ** (j / 4.0)
            if X_LO <= bx <= X_HI:
                ax.plot([bx, bx], [1.5, 2.5], color='#cccccc',
                        linewidth=0.5, linestyle='-')

    ax.set_xlim(0.5, X_HI + 0.5)
    ax.set_ylim(-0.6, 2.8)
    ax.set_xlabel('$x$', fontsize=9)
    ax.set_yticks([])
    ax.set_title('Binade boundaries vs binary geometric grid',
                  fontsize=10, fontweight='bold')
    ax.set_xscale('log', base=2)
    ax.grid(True, alpha=0.15, linewidth=0.4, axis='x')
    ax.tick_params(labelsize=8)

    fig.suptitle(
        'Representation: binary scientific notation gives the pseudo-log '
        'structurally',
        fontsize=12, fontweight='bold',
    )

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=180, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Float formats: 3 toy formats, x in [%.0f, %.0f]" % (X_LO, X_HI))

make_plot()

# Boundary residual check
print()
print("  Boundary residuals at binade edges:")
for fmt in FORMATS:
    base = fmt['base']
    for k in range(3):
        bx = float(base ** k)
        r = format_residual(bx + 1e-15, base)
        print("    %-16s  x=%-6g  residual = %+.2e" % (fmt['name'], bx, r))

print()
print("Done.")
