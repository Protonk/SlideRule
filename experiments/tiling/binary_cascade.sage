"""
binary_cascade.sage — Binary cascade exploration view.

Workbench for iterating on the tiling theory. Shows the LD optimizer's
layer-by-layer allocation alongside the Haar wavelet decomposition of
the forcing function, so you can see where they agree, where they don't,
and use the disagreements to learn what isn't yet understood.

Layout: d+2 rows sharing a mantissa x-axis.
  Row 0:     target (c* - c0) vs scaled Delta^L
  Rows 1-d:  actual layer-t contribution vs Haar prediction at scale t
  Row d+1:   remainder after all layers

Right margin: split bars (explained / unexplained) per layer.

Run:  ./sagew experiments/tiling/binary_cascade.sage
"""

import os
from math import log, log2

from helpers import pathing
load(pathing('experiments', 'keystone', 'keystone_runner.sage'))
load(pathing('experiments', 'tiling', 'leading_bit_projection.sage'))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np


# -- Configuration --------------------------------------------------------

Q = 5
DEPTH = 6
P_NUM = 1
Q_DEN = 2
KIND = 'geometric_x'

OUT_PATH = pathing('experiments', 'tiling', 'results', 'binary_cascade.png')

LN2 = float(log(2.0))
M_STAR = 1.0 / LN2 - 1.0


# -- Computation -----------------------------------------------------------

def compute_layer_contributions(case):
    """Per-cell per-layer delta contributions, cell midpoints, free intercepts."""
    delta = case['opt_pol']['delta_rat']
    q = case['q']
    depth = case['depth']
    N = 2 ** depth

    contributions = np.zeros((depth, N))
    cell_mids = np.zeros(N)
    free_intercepts = np.zeros(N)

    for fr in case['free_metrics']['rows']:
        idx = fr['index'] if 'index' in fr else bits_to_index(fr['bits'])
        free_intercepts[idx] = float(fr['c_opt'])

    for p in case['paths']:
        bits = p['bits']
        idx = bits_to_index(bits)
        prow = case['row_map'][bits]
        cell_mids[idx] = float((prow['x_lo'] + prow['x_hi']) / 2) - 1.0

        r = 0
        for t in range(depth):
            b = bits[t]
            ld_key = (t, r, b)
            li_key = (r, b)
            if ld_key in delta:
                contributions[t, idx] = float(delta[ld_key])
            elif li_key in delta:
                contributions[t, idx] = float(delta[li_key])
            r = (2 * r + b) % q

    return contributions, cell_mids, free_intercepts


def haar_component(f, t):
    """Haar wavelet detail at scale t.

    Refinement from t-bit prefix grouping to (t+1)-bit prefix grouping.
    W_t[j] = mean(f in (t+1)-bit group of j) - mean(f in t-bit group of j)

    Scale 0: global -> 2 halves (leading bit)
    Scale 1: 2 halves -> 4 quarters
    ...
    Scale d-1: N/2 pairs -> N singletons (= f - coarsest-that-includes-j)
    """
    N = len(f)
    coarse = N >> t          # cells per t-bit group
    fine = N >> (t + 1)      # cells per (t+1)-bit group

    if fine < 1:
        return np.zeros(N)

    result = np.zeros(N)
    for j in range(N):
        c_start = (j // coarse) * coarse
        f_start = (j // fine) * fine
        result[j] = np.mean(f[f_start:f_start + fine]) - np.mean(f[c_start:c_start + coarse])
    return result


# -- Plot ------------------------------------------------------------------

CLR_ACTUAL   = '#1f77b4'
CLR_PREDICT  = '#d62728'
CLR_GAP      = '#e67e22'
CLR_TARGET   = '#2ca02c'
CLR_FORCING  = '#9467bd'
CLR_ENTERING = '#bbbbbb'


def make_cascade():
    print("  Computing LD case: %s q=%d d=%d..." % (KIND, Q, DEPTH))
    case = compute_case(Q, DEPTH, P_NUM, Q_DEN, partition_kind=KIND,
                        layer_dependent=True)
    print("    opt_err=%.6f  gap=%.6f  (%.1fs)"
          % (case['opt_err'], case['gap'], case['elapsed']))

    contribs, cell_mids, free_c = compute_layer_contributions(case)
    c0 = float(case['opt_pol']['c0_rat'])
    N = 2 ** DEPTH

    # For geometric_x, index order = mantissa order, so no resorting needed.
    # But be explicit: sort by mantissa and carry indices.
    sort_idx = np.argsort(cell_mids)
    ms = cell_mids[sort_idx]
    free_s = free_c[sort_idx]
    contribs_s = contribs[:, sort_idx]

    # Target: what the deltas need to produce
    target = free_s - c0

    # Forcing field
    dL = np.array([delta_L(m) for m in ms])
    alpha_dL = scale_fit(target, dL)

    # Haar decomposition of target (in index order, then sort)
    # For geometric_x sort_idx is identity, but do it properly:
    target_idx = free_c - c0
    haar_idx = np.zeros((DEPTH, N))
    for t in range(DEPTH):
        haar_idx[t] = haar_component(target_idx, t)

    # Verify: global_mean + sum(haar) should reconstruct target
    haar_global = np.mean(target_idx)
    recon = haar_global + haar_idx.sum(axis=0)
    recon_err = np.max(np.abs(recon - target_idx))
    print("  Haar reconstruction error: %.2e" % recon_err)

    # Sort for display
    haar_s = haar_idx[:, sort_idx]

    # Entering residuals: what's left for layer t onward
    # entering[0] = target (everything)
    # entering[t] = target - sum of actual layers 0..t-1
    entering = np.zeros((DEPTH + 1, N))
    entering[0] = target.copy()
    for t in range(DEPTH):
        entering[t + 1] = entering[t] - contribs_s[t]
    # entering[DEPTH] = final remainder

    # Per-layer diagnostics
    corrs = np.zeros(DEPTH)
    actual_norms = np.zeros(DEPTH)
    predict_norms = np.zeros(DEPTH)
    for t in range(DEPTH):
        a = contribs_s[t]
        p = haar_s[t]
        actual_norms[t] = np.max(np.abs(a))
        predict_norms[t] = np.max(np.abs(p))
        if np.std(a) > 1e-15 and np.std(p) > 1e-15:
            corrs[t] = np.corrcoef(a, p)[0, 1]
        else:
            corrs[t] = 0.0

    # ---- Figure ----
    # Show layers 0..DEPTH-2; fold the last layer into the remainder
    # (it's nearly inert and adds noise at this scale).
    SHOW = DEPTH - 1   # layers 0..4
    n_rows = SHOW + 2  # target + SHOW layers + remainder
    fig = plt.figure(figsize=(14, 2.4 * n_rows))
    gs = gridspec.GridSpec(n_rows, 2, width_ratios=[7, 1],
                           hspace=0.35, wspace=0.08,
                           left=0.07, right=0.95, top=0.94, bottom=0.04)

    main_axes = []
    margin_axes = []
    for row in range(n_rows):
        ax = fig.add_subplot(gs[row, 0])
        ax_m = fig.add_subplot(gs[row, 1])
        main_axes.append(ax)
        margin_axes.append(ax_m)

    # Share x across all main axes
    for ax in main_axes[1:]:
        ax.sharex(main_axes[0])

    # ---- Row 0: Target ----
    ax = main_axes[0]
    ax.plot(ms, target, '-', color=CLR_TARGET, linewidth=1.5,
            label='$c^* - c_0$  (target)')
    ax.plot(ms, dL * alpha_dL, '--', color=CLR_FORCING, linewidth=1.0,
            alpha=0.7, label='$%.2f\\,\\Delta^L$' % alpha_dL)
    ax.axhline(0, color='#cccccc', linewidth=0.3)
    ax.axvline(M_STAR, color='#888888', linewidth=0.5, linestyle=':')
    ax.set_ylabel('target', fontsize=8)
    ax.legend(fontsize=6, loc='lower left')
    ax.tick_params(labelsize=7)
    ax.grid(True, alpha=0.2, linewidth=0.3)
    ax.set_title(
        'Binary cascade:  %s LD,  q=%d,  d=%d,  exponent=%d/%d'
        % (KIND.replace('_x', ''), Q, DEPTH, P_NUM, Q_DEN),
        fontsize=11, fontweight='bold', loc='left')

    # Upper-right: legend for the visual vocabulary — large enough for IDE viewing
    ax_m = margin_axes[0]
    ax_m.set_xlim(0, 1)
    ax_m.set_ylim(0, 1)
    ax_m.axis('off')
    legend_items = [
        (CLR_ACTUAL,  '-',  'actual $\\delta_t$'),
        (CLR_PREDICT, '--', 'Haar $W_t$'),
        (CLR_GAP,     None, 'gap'),
        (CLR_ENTERING, '-', 'entering'),
    ]
    for i, (color, ls, label) in enumerate(legend_items):
        y = 0.85 - i * 0.23
        if ls is not None:
            ax_m.plot([0.04, 0.28], [y, y], ls, color=color, linewidth=2.5,
                      clip_on=False, transform=ax_m.transAxes)
        else:
            ax_m.fill_between([0.04, 0.28], y - 0.07, y + 0.07,
                              color=color, alpha=0.25, clip_on=False,
                              transform=ax_m.transAxes)
        ax_m.text(0.35, y, label, fontsize=10, va='center',
                  transform=ax_m.transAxes)
    target_norm = np.max(np.abs(target))

    # ---- Rows 1..SHOW: Layer cascade ----
    bar_max = max(actual_norms[:SHOW].max(), predict_norms[:SHOW].max()) * 1.3

    for t in range(SHOW):
        ax = main_axes[t + 1]
        actual = contribs_s[t]
        predicted = haar_s[t]
        enter = entering[t]

        # Entering residual as thin gray line
        ax.plot(ms, enter, '-', color=CLR_ENTERING, linewidth=0.6, alpha=0.5)

        # Gap fill between actual and predicted (the interesting part)
        ax.fill_between(ms, actual, predicted, alpha=0.12, color=CLR_GAP,
                        step='mid')

        # Actual layer contribution (solid step)
        ax.step(ms, actual, '-', color=CLR_ACTUAL, linewidth=1.3, where='mid',
                label='actual $\\delta_%d$' % t if t == 0 else None)

        # Haar prediction (dashed step)
        ax.step(ms, predicted, '--', color=CLR_PREDICT, linewidth=1.0,
                alpha=0.8, where='mid',
                label='Haar $W_%d$' % t if t == 0 else None)

        ax.axhline(0, color='#cccccc', linewidth=0.3)
        ax.axvline(M_STAR, color='#888888', linewidth=0.5, linestyle=':')
        ax.set_ylabel('layer %d' % t, fontsize=8)
        ax.tick_params(labelsize=7)
        ax.grid(True, alpha=0.2, linewidth=0.3)

        # Correlation annotation
        r = corrs[t]
        ax.text(0.98, 0.88, '$r = %.3f$' % r, transform=ax.transAxes,
                fontsize=7, ha='right', va='top',
                color=CLR_ACTUAL if abs(r) > 0.5 else '#888888',
                fontweight='bold' if abs(r) > 0.8 else 'normal')

        # ---- Margin: split bar ----
        ax_m = margin_axes[t + 1]
        r2 = corrs[t] ** 2
        explained = actual_norms[t] * r2
        unexplained = actual_norms[t] * (1 - r2)

        ax_m.barh([0], [explained], color=CLR_ACTUAL, alpha=0.7, height=0.5)
        ax_m.barh([0], [unexplained], left=[explained], color=CLR_ACTUAL,
                  alpha=0.2, height=0.5, hatch='///')
        # Haar prediction norm as a reference tick
        ax_m.axvline(predict_norms[t], color=CLR_PREDICT, linewidth=0.8,
                     linestyle='--', alpha=0.6)

        ax_m.set_xlim(0, bar_max)
        ax_m.set_yticks([])
        ax_m.tick_params(labelsize=5)
        if t == 0:
            # R² label for margin column header
            ax_m.set_title('$R^2$', fontsize=6, pad=2)

    # ---- Remainder: target minus layers 0..SHOW-1 ----
    # (includes contribution of any omitted layers, so it's what's left
    # for the last layer + optimizer slack + snapping noise)
    ax = main_axes[-1]
    remainder = entering[SHOW]
    ax.fill_between(ms, remainder, alpha=0.2, color=CLR_PREDICT, step='mid')
    ax.step(ms, remainder, '-', color=CLR_PREDICT, linewidth=1.3, where='mid')
    ax.axhline(0, color='#cccccc', linewidth=0.3)
    ax.axvline(M_STAR, color='#888888', linewidth=0.5, linestyle=':')
    ax.set_ylabel('remainder', fontsize=8)
    ax.set_xlabel('Mantissa $m$ in $[0,\\, 1)$', fontsize=9)
    ax.tick_params(labelsize=7)
    ax.grid(True, alpha=0.2, linewidth=0.3)

    rem_norm = np.max(np.abs(remainder))
    ax.text(0.98, 0.88, '$\\|r\\|_\\infty = %.5f$' % rem_norm,
            transform=ax.transAxes, fontsize=7, ha='right', va='top',
            color=CLR_PREDICT, fontweight='bold')

    # Lower-right: 2x2 colored-cell budget table (image-style)
    ax_m = margin_axes[-1]
    ax_m.set_xlim(0, 1)
    ax_m.set_ylim(0, 1)
    ax_m.axis('off')
    absorbed_pct = (1.0 - rem_norm / target_norm) * 100
    remainder_pct = rem_norm / target_norm * 100

    # 2x2 grid: [target_norm, absorbed%] / [remainder_norm, empty-label]
    cells = [
        # (x0, y0, w, h, color, text, sublabel)
        (0.0,  0.5, 0.5, 0.5, CLR_TARGET,  '%.3f' % target_norm, 'target'),
        (0.5,  0.5, 0.5, 0.5, CLR_ACTUAL,  '%.1f%%' % absorbed_pct, 'absorbed'),
        (0.0,  0.0, 0.5, 0.5, CLR_PREDICT, '%.3f' % rem_norm, 'remainder'),
        (0.5,  0.0, 0.5, 0.5, '#f0f0f0',   '%d' % SHOW, 'layers'),
    ]
    for x0, y0, w, h, color, text, sub in cells:
        rect = plt.Rectangle((x0, y0), w, h, transform=ax_m.transAxes,
                              facecolor=color, alpha=0.35, edgecolor='white',
                              linewidth=1.5, clip_on=False)
        ax_m.add_patch(rect)
        ax_m.text(x0 + w / 2, y0 + h * 0.58, text,
                  transform=ax_m.transAxes, ha='center', va='center',
                  fontsize=11, fontweight='bold', color='#222222')
        ax_m.text(x0 + w / 2, y0 + h * 0.22, sub,
                  transform=ax_m.transAxes, ha='center', va='center',
                  fontsize=7, color='#555555')

    # Suppress x tick labels on all but bottom
    for ax in main_axes[:-1]:
        plt.setp(ax.get_xticklabels(), visible=False)
    for ax_m in margin_axes:
        ax_m.set_xticklabels([])

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    fig.savefig(OUT_PATH, dpi=200, bbox_inches='tight')
    print("Saved: %s" % OUT_PATH)

    # ---- Console diagnostics ----
    print()
    print("  Layer diagnostics:")
    print("  %5s  %10s  %10s  %8s  %6s" %
          ('layer', '||actual||', '||Haar||', 'corr', 'R^2'))
    for t in range(DEPTH):
        print("  %5d  %10.6f  %10.6f  %8.4f  %5.1f%%"
              % (t, actual_norms[t], predict_norms[t], corrs[t],
                 corrs[t]**2 * 100))

    print()
    print("  Remainder ||r||_inf = %.6f" % rem_norm)
    print("  Target    ||t||_inf = %.6f" % target_norm)
    print("  Remainder / target  = %.1f%%" % (rem_norm / target_norm * 100))

    # Haar budget check
    haar_total = haar_s.sum(axis=0) + haar_global
    haar_recon_s = haar_total[sort_idx] if not np.array_equal(sort_idx, np.arange(N)) else haar_total
    print("  Haar sum check: max|target - (mean + sum W_t)| = %.2e"
          % np.max(np.abs(target - (haar_global + haar_s.sum(axis=0)))))


# -- Main ------------------------------------------------------------------

print()
print("Binary cascade: %s LD q=%d d=%d" % (KIND, Q, DEPTH))
make_cascade()
print("Done.")
