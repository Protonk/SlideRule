"""
octave_error_scaling.sage — Error across octaves.

Two panels compare how the optimized worst-case error varies:
  Left:  full octaves [2^e, 2^{e+1}) — constant multiplicative span (2x).
  Right: unit-width windows [s, s+1) — shrinking multiplicative span.

Theory predicts full octaves give constant error (curvature x width cancels),
while unit-width shows decaying error (curvature decreases at higher x_start,
but width stays the same, so cells become easier).

Run:  ./sagew experiments/stitching/octave_error_scaling.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'partitions.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import time


# ── Configuration ────────────────────────────────────────────────────

Q = 3
DEPTH = 3
P_NUM = 1
Q_DEN = 2

OCTAVE_EXPONENTS = [0, 1, 2, 3, 4]         # [2^e, 2^{e+1})
UNIT_STARTS = [1, 2, 4, 8, 16]             # [s, s+1)
KINDS = ['uniform_x', 'geometric_x']


# ── Compute ──────────────────────────────────────────────────────────

def run_case(kind, x_start, x_width):
    """Return (free_err, opt_err, seconds)."""
    t0 = time.time()

    free = free_per_cell_metrics(
        DEPTH, P_NUM, Q_DEN,
        partition_kind=kind, x_start=x_start, x_width=x_width)

    opt = optimize_minimax(
        Q, DEPTH, P_NUM, Q_DEN,
        partition_kind=kind, x_start=x_start, x_width=x_width)

    return free['worst_abs'], opt['worst_err'], time.time() - t0


def compute_all():
    results = {}

    print("  Full octaves [2^e, 2^{e+1}):")
    for e in OCTAVE_EXPONENTS:
        xs = Integer(2)^e
        xw = Integer(2)^e
        for kind in KINDS:
            free_err, opt_err, dt = run_case(kind, xs, xw)
            results[('octave', e, kind)] = (free_err, opt_err)
            print(f"    e={e}  [{xs},{xs+xw})  {kind:15s}"
                  f"  free={free_err:.6e}  opt={opt_err:.6e}  ({dt:.1f}s)")

    print("\n  Unit-width [s, s+1):")
    for s in UNIT_STARTS:
        for kind in KINDS:
            free_err, opt_err, dt = run_case(kind, s, 1)
            results[('unit', s, kind)] = (free_err, opt_err)
            print(f"    s={s:2d}   [{s},{s+1})  {kind:15s}"
                  f"  free={free_err:.6e}  opt={opt_err:.6e}  ({dt:.1f}s)")

    return results


# ── Plot ─────────────────────────────────────────────────────────────

STYLES = {
    'uniform_x':   {'color': '#1f77b4', 'marker': 'o', 'label': 'uniform'},
    'geometric_x': {'color': '#d62728', 'marker': 's', 'label': 'geometric'},
}


def make_plot(results):
    fig, (ax_oct, ax_unit) = plt.subplots(1, 2, figsize=(12, 5))

    # ── Left: full octaves ───────────────────────────────────────────
    for kind in KINDS:
        s = STYLES[kind]
        free_vals = [results[('octave', e, kind)][0] for e in OCTAVE_EXPONENTS]
        opt_vals  = [results[('octave', e, kind)][1] for e in OCTAVE_EXPONENTS]

        ax_oct.plot(OCTAVE_EXPONENTS, opt_vals,
                    '-', marker=s['marker'], color=s['color'],
                    linewidth=1.8, markersize=5, label=f"{s['label']} opt")
        ax_oct.plot(OCTAVE_EXPONENTS, free_vals,
                    '--', marker=s['marker'], color=s['color'],
                    linewidth=1.2, markersize=4, alpha=0.5,
                    label=f"{s['label']} free")

    ax_oct.set_xlabel('octave exponent $e$', fontsize=10)
    ax_oct.set_ylabel('worst-case error', fontsize=10)
    ax_oct.set_title('Full octaves $[2^e,\\, 2^{e+1})$', fontsize=11,
                     fontweight='bold')
    ax_oct.set_xticks(OCTAVE_EXPONENTS)
    ax_oct.legend(fontsize=8)
    ax_oct.tick_params(labelsize=8)

    # ── Right: unit-width ────────────────────────────────────────────
    xs_idx = list(range(len(UNIT_STARTS)))
    for kind in KINDS:
        s = STYLES[kind]
        free_vals = [results[('unit', s_val, kind)][0] for s_val in UNIT_STARTS]
        opt_vals  = [results[('unit', s_val, kind)][1] for s_val in UNIT_STARTS]

        ax_unit.plot(xs_idx, opt_vals,
                     '-', marker=s['marker'], color=s['color'],
                     linewidth=1.8, markersize=5, label=f"{s['label']} opt")
        ax_unit.plot(xs_idx, free_vals,
                     '--', marker=s['marker'], color=s['color'],
                     linewidth=1.2, markersize=4, alpha=0.5,
                     label=f"{s['label']} free")

    ax_unit.set_xlabel('$x_{\\mathrm{start}}$', fontsize=10)
    ax_unit.set_ylabel('worst-case error', fontsize=10)
    ax_unit.set_title('Fixed-width $[s,\\, s{+}1)$', fontsize=11,
                      fontweight='bold')
    ax_unit.set_xticks(xs_idx)
    ax_unit.set_xticklabels([str(s) for s in UNIT_STARTS])
    ax_unit.set_yscale('log')
    ax_unit.legend(fontsize=8)
    ax_unit.tick_params(labelsize=8)

    fig.suptitle(
        f'Error across octaves — q={Q}, d={DEPTH}, '
        f'$\\alpha$={P_NUM}/{Q_DEN}',
        fontsize=13, fontweight='bold',
    )
    fig.tight_layout(rect=[0, 0, 1, 0.94])

    out_path = 'experiments/stitching/octave_error_scaling.png'
    fig.savefig(out_path, dpi=180, bbox_inches='tight')
    print(f"\nSaved: {out_path}")


# ── Diagnostics ──────────────────────────────────────────────────────

def print_analysis(results):
    print("\nAnalysis:")

    for kind in KINDS:
        ovals = [results[('octave', e, kind)][1] for e in OCTAVE_EXPONENTS]
        ratio = max(ovals) / min(ovals) if min(ovals) > 0 else float('inf')
        print(f"  {kind:15s} octave opt: "
              f"{min(ovals):.6e} .. {max(ovals):.6e}  (max/min = {ratio:.4f})")

    for kind in KINDS:
        uvals = [results[('unit', s, kind)][1] for s in UNIT_STARTS]
        decay = uvals[0] / uvals[-1] if uvals[-1] > 0 else float('inf')
        print(f"  {kind:15s} unit opt:   "
              f"{uvals[0]:.6e} -> {uvals[-1]:.6e}  (decay x{decay:.1f})")

    # Geometric advantage ratio
    print("\n  Geometric advantage (uniform_opt / geometric_opt):")
    for e in OCTAVE_EXPONENTS:
        u = results[('octave', e, 'uniform_x')][1]
        g = results[('octave', e, 'geometric_x')][1]
        print(f"    octave e={e}: {u/g:.4f}")
    for s in UNIT_STARTS:
        u = results[('unit', s, 'uniform_x')][1]
        g = results[('unit', s, 'geometric_x')][1]
        print(f"    unit  s={s:2d}: {u/g:.4f}")


# ── Main ─────────────────────────────────────────────────────────────

print()
print("Octave error scaling")
print("=" * 72)
print(f"  q={Q}, depth={DEPTH}, alpha={P_NUM}/{Q_DEN}")
print()

results = compute_all()
print_analysis(results)
make_plot(results)
print("Done.")
