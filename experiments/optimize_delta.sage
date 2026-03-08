"""
Optimize shared delta and compare against baselines.

Uses bisection+LP minimax solver (exact) by default.

For each (q, depth), reports:
  single_err — best single shared intercept (delta = 0)
  opt_err    — optimized shared delta (bisection+LP minimax)
  free_err   — per-cell independent optimum (lower bound)
  improve    — single_err - opt_err  (how much the FSM helps)
  gap        — opt_err - free_err  (cost of the sharing constraint)

Run from project root:  ./sagew experiments/optimize_delta.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))

import time


def subset_size_str(greedy_size, exact_size):
    """Render greedy/exact subset sizes compactly."""
    exact_str = "-" if exact_size is None else str(exact_size)
    return f"{greedy_size}/{exact_str}"


def main():
    print("=" * 100)
    print("Shared-delta optimization: Day x Jukna (bisection+LP minimax)")
    print("=" * 100)

    p_num, q_den = 1, 2
    cases = [
        (1, 4), (1, 6), (1, 8),
        (2, 4), (2, 6), (2, 8),
        (3, 4), (3, 6),
        (5, 4), (5, 6),
    ]

    results = {}  # keyed by (q, depth)

    # ── Compute everything ──────────────────────────────────────────────

    print(f"\nalpha = {p_num}/{q_den}  (reciprocal square root)\n")

    header = (f"{'q':>3}  {'d':>2}  {'#p':>3}  {'paths':>5}  "
              f"{'single_err':>10}  {'opt_err':>10}  {'free_err':>10}  "
              f"{'single_u':>10}  {'opt_u':>10}  {'free_u':>10}  "
              f"{'improve':>9}  {'gap':>10}  "
              f"{'pat#':>4}  {'sum':>5}  {'s':>7}  {'cf':>7}  "
              f"{'steps':>6}  {'time':>5}")
    print(header)
    print("-" * len(header))

    for q, depth in cases:
        t0 = time.time()
        n_params = 1 + 2 * q

        # Paths
        edges, paths, edge_index = residue_paths(q, depth)

        # Best single-intercept baseline
        single_pol = best_single_intercept(paths, p_num, q_den)
        single_worst = single_pol["worst_abs"]
        single_union = single_pol["union_log2_ratio"]

        # Optimized shared delta
        opt_pol = optimize_shared_delta(q, depth, p_num, q_den)
        opt_worst = opt_pol["worst_err"]
        opt_union = opt_pol["union_log2_ratio"]
        n_evals = opt_pol["n_evals"]

        # Free per cell lower bound
        free_metrics = free_per_cell_metrics(depth, p_num, q_den)
        free_worst = free_metrics["worst_abs"]
        free_union = free_metrics["union_log2_ratio"]

        # Induced family diagnostics for the optimized policy
        active_family = build_active_pattern_family(
            paths, p_num, q_den, opt_pol["c0_rat"], opt_pol["delta_rat"], q
        )
        family_summary = summarize_vector_family(list(active_family["unique_vectors"]))

        improve = single_worst - opt_worst
        gap = opt_worst - free_worst

        elapsed = time.time() - t0

        sidon_str = subset_size_str(
            family_summary["greedy_sidon_subset_size"],
            family_summary["exact_sidon_subset_size"],
        )
        cf_str = subset_size_str(
            family_summary["greedy_cover_free_subset_size"],
            family_summary["exact_cover_free_subset_size"],
        )
        print(f"{q:>3}  {depth:>2}  {n_params:>3}  {2**depth:>5}  "
              f"{single_worst:>10.6f}  {opt_worst:>10.6f}  {free_worst:>10.6f}  "
              f"{single_union:>10.6f}  {opt_union:>10.6f}  {free_union:>10.6f}  "
              f"{improve:>9.6f}  {gap:>10.6f}  "
              f"{len(active_family['unique_vectors']):>4}  {family_summary['sumset_size']:>5}  "
              f"{sidon_str:>7}  {cf_str:>7}  "
              f"{n_evals:>6}  {elapsed:>5.1f}s")

        results[(q, depth)] = {
            "opt_pol": opt_pol,
            "single_pol": single_pol,
            "single_worst": single_worst,
            "single_union": single_union,
            "opt_worst": opt_worst,
            "opt_union": opt_union,
            "free_worst": free_worst,
            "free_union": free_union,
            "family_summary": family_summary,
            "active_family": active_family,
        }

    # ── Detailed delta view ─────────────────────────────────────────────

    for q, depth in [(3, 6), (5, 6)]:
        if (q, depth) not in results:
            continue
        r = results[(q, depth)]
        opt_pol = r["opt_pol"]

        print(f"\n--- Optimized delta: q={q}, depth={depth}, "
              f"alpha={p_num}/{q_den} ---\n")
        print(f"  c0         = {float(opt_pol['c0_rat']):>16.12f}")
        print(f"  worst_err  = {opt_pol['worst_err']:.8f}  "
              f"(single: {r['single_worst']:.8f}, free: {r['free_worst']:.8f})")
        print(f"  union_ratio= {opt_pol['union_log2_ratio']:.8f}  "
              f"(single: {r['single_union']:.8f}, free: {r['free_union']:.8f})")
        print(f"  converged  = {opt_pol['converged']}")
        print(f"  unique c's = {opt_pol['unique_intercepts']}")
        print()
        print(f"  {'(r, b)':>8}  {'delta':>16}")
        print(f"  {'─'*8}  {'─'*16}")
        for state in range(q):
            for b in (0, 1):
                d = float(opt_pol['delta_rat'][(state, b)])
                print(f"  ({state}, {b}):   {d:>16.12f}")
        print()

    # ── Summary ─────────────────────────────────────────────────────────

    print("=" * 100)
    print("'improve' = single_err - opt_err   (gain over best single shared intercept)")
    print("'gap'     = opt_err - free_err   (cost of sharing vs free per-cell)")
    print("'single_u'/'opt_u'/'free_u' are true union-level log2(zmax/zmin)")
    print("'pat#'    = number of distinct induced Day-pattern vectors")
    print("'s'/'cf'  = greedy/exact subset sizes on the induced family")
    print("=" * 100)


main()
