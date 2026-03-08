"""
Optimize shared delta and compare against baselines.

For each (q, depth), reports:
  zero_err   — uniform intercept (no FSM)
  opt_err    — optimized shared delta
  free_err   — per-cell independent optimum (lower bound)
  improve    — zero_err - opt_err  (how much the FSM helps)
  gap        — opt_err - free_err  (cost of the sharing constraint)

Run from project root:  sage experiments/optimize_delta.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))

from collections import defaultdict
import time


def main():
    print("=" * 100)
    print("Shared-delta optimization: Day x Jukna")
    print("=" * 100)

    p_num, q_den = 1, 2
    alpha_q = QQ(p_num) / QQ(q_den)

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
              f"{'zero_err':>10}  {'opt_err':>10}  {'free_err':>10}  "
              f"{'improve':>9}  {'gap':>10}  "
              f"{'c#':>4}  {'s_sub':>5}  {'cf':>4}  "
              f"{'evals':>6}  {'time':>5}")
    print(header)
    print("-" * len(header))

    for q, depth in cases:
        t0 = time.time()
        n_params = 1 + 2 * q

        # Paths and Jukna diagnostics
        edges, paths, edge_index = residue_paths(q, depth)
        vecs = [P["vec"] for P in paths]
        sidon_size = len(greedy_sidon_subset(vecs))
        cf_size = len(greedy_cover_free_subset(vecs)) if len(paths) <= 256 else None

        # Zero baseline
        zero_pol = zero_policy(q, depth, alpha_q)
        zero_worst, _, _ = global_exact_error(
            paths, p_num, q_den, zero_pol["c0_rat"], zero_pol["delta_rat"], q
        )

        # Optimized shared delta
        opt_pol = optimize_shared_delta(q, depth, p_num, q_den)
        opt_worst = opt_pol["worst_err"]
        n_unique = opt_pol["unique_intercepts"]
        n_evals = opt_pol["n_evals"]

        # Free per cell lower bound
        free_worst, _ = free_per_cell_optimum(depth, p_num, q_den)

        improve = zero_worst - opt_worst
        gap = opt_worst - free_worst

        elapsed = time.time() - t0

        cf_str = str(cf_size) if cf_size is not None else "-"
        print(f"{q:>3}  {depth:>2}  {n_params:>3}  {2**depth:>5}  "
              f"{zero_worst:>10.6f}  {opt_worst:>10.6f}  {free_worst:>10.6f}  "
              f"{improve:>9.6f}  {gap:>10.6f}  "
              f"{n_unique:>4}  {sidon_size:>5}  {cf_str:>4}  "
              f"{n_evals:>6}  {elapsed:>5.1f}s")

        results[(q, depth)] = {
            "opt_pol": opt_pol,
            "zero_worst": zero_worst,
            "opt_worst": opt_worst,
            "free_worst": free_worst,
            "sidon_size": sidon_size,
            "cf_size": cf_size,
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
              f"(zero: {r['zero_worst']:.8f}, free: {r['free_worst']:.8f})")
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
    print("'improve' = zero_err - opt_err   (how much shared FSM corrections help)")
    print("'gap'     = opt_err - free_err   (cost of sharing vs free per-cell)")
    print("'c#'      = number of distinct intercepts under the optimized policy")
    print("'s_sub'   = greedy Sidon subset size")
    print("'cf'      = greedy cover-free subset size")
    print("=" * 100)


main()
