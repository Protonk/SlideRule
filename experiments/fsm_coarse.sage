"""
FSM coarse-stage experiment: Day x Jukna.

Builds a residue-automaton path family, attaches Day-style coarse
approximations with FSM-dependent intercepts, and measures both
the exact H/V/D error and the Jukna-type combinatorial structure
(Sidon / cover-free subsets) of the path incidence vectors.

Run from project root:  ./sagew experiments/fsm_coarse.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))

from collections import defaultdict


# ── Measurement ─────────────────────────────────────────────────────────

def run_experiment(q, depth, p, qpow, policy_name='zero', policy_kwargs=None):
    """
    For a given (q, depth, p/qpow), build paths, measure combinatorics
    and exact coarse-stage error.
    """
    if policy_kwargs is None:
        policy_kwargs = {}

    edges, paths, edge_index = residue_paths(q, depth)
    vecs = [P["vec"] for P in paths]
    n_paths = len(paths)
    n_edges = len(edges)
    alpha_q = QQ(p) / QQ(qpow)

    policy = build_intercept_policy(policy_name, q, depth, alpha_q, **policy_kwargs)
    c0_rat = policy["c0_rat"]
    delta_rat = policy["delta_rat"]

    intercepts = [path_intercept(P["bits"], c0_rat, delta_rat, q) for P in paths]
    intercept_min = min(intercepts)
    intercept_max = max(intercepts)
    intercept_span = intercept_max - intercept_min

    # Jukna diagnostics
    full_sidon = is_sidon(vecs)
    sidon_sub = greedy_sidon_subset(vecs)
    sidon_size = len(sidon_sub)

    cf_size = None
    if n_paths <= 256:
        cf_sub = greedy_cover_free_subset(vecs)
        cf_size = len(cf_sub)

    exact_worst, exact_ratio, cell_data = global_exact_error(
        paths, p, qpow, c0_rat, delta_rat, q
    )

    # Terminal-state distribution
    terminal_counts = defaultdict(int)
    for P in paths:
        terminal_counts[P["terminal"]] += 1

    return {
        "q": q,
        "depth": depth,
        "p": p,
        "qpow": qpow,
        "alpha": float(alpha_q),
        "policy": policy["name"],
        "policy_description": policy["description"],
        "n_paths": n_paths,
        "n_edges": n_edges,
        "full_sidon": full_sidon,
        "sidon_subset_size": sidon_size,
        "cover_free_subset_size": cf_size,
        "c0": float(c0_rat),
        "intercept_min": float(intercept_min),
        "intercept_max": float(intercept_max),
        "intercept_span": float(intercept_span),
        "unique_intercepts": len(set(intercepts)),
        "exact_worst_log2err": exact_worst,
        "exact_log2_ratio": exact_ratio,
        "cell_data": cell_data,
        "terminal_distribution": dict(terminal_counts),
    }


def print_row(result):
    cf_str = str(result["cover_free_subset_size"]) if result["cover_free_subset_size"] is not None else "-"
    print(f"  pol={result['policy']:<13}  q={result['q']:>2}  d={result['depth']:>2}  "
          f"paths={result['n_paths']:>5}  edges={result['n_edges']:>4}  "
          f"c#={result['unique_intercepts']:>4}  "
          f"cspan={result['intercept_span']:.6f}  "
          f"sidon={'Y' if result['full_sidon'] else 'N'}  "
          f"s_sub={result['sidon_subset_size']:>4}  "
          f"cf={cf_str:>4}  "
          f"err={result['exact_worst_log2err']:.6f}  "
          f"ratio={result['exact_log2_ratio']:.6f}")


# ── Validation ──────────────────────────────────────────────────────────

def validate(q, depth, p, qpow, policy_name='zero', policy_kwargs=None, nsamp=2048):
    """Compare exact H/V/D evaluator against dense sampling."""
    if policy_kwargs is None:
        policy_kwargs = {}

    edges, paths, edge_index = residue_paths(q, depth)
    alpha_q = QQ(p) / QQ(qpow)
    alpha_hi = HiR(alpha_q)
    policy = build_intercept_policy(policy_name, q, depth, alpha_q, **policy_kwargs)
    c0_rat = policy["c0_rat"]
    delta_rat = policy["delta_rat"]

    max_disc = 0.0
    checked = 0
    for P in paths[:16]:
        c_rat = path_intercept(P["bits"], c0_rat, delta_rat, q)
        _, _, exact_worst, _ = cell_exact_logerr(P["bits"], p, qpow, c_rat)
        sampled_worst = float(cell_logerr_sampled(
            P["bits"], alpha_hi, HiR(c_rat), nsamp=nsamp
        ))
        disc = abs(exact_worst - sampled_worst)
        if disc > max_disc:
            max_disc = disc
        checked += 1

    return max_disc, checked


# ── Cell report ─────────────────────────────────────────────────────────

def cell_report(bits, p_num, q_den, c_rat):
    """Print detailed H/V/D analysis for a single cell."""
    alpha_q = QQ(p_num) / QQ(q_den)
    c = QQ(c_rat)
    plog_lo, plog_hi = dyadic_cell_plog(bits)

    bps = cell_breakpoints(bits, p_num, q_den, c_rat)

    print(f"  cell bits={bits}  plog=[{float(plog_lo):.6f}, {float(plog_hi):.6f})")
    print(f"  c={float(c):.6f}  alpha={float(alpha_q):.6f}")
    print(f"  breakpoints ({len(bps)}): {[float(x) for x in bps]}")

    for i in range(len(bps) - 1):
        seg_lo = bps[i]
        seg_hi = bps[i + 1]
        seg_mid = (seg_lo + seg_hi) / 2
        u_mid = c - alpha_q * seg_mid
        k = floor(u_mid)
        xp_D = (c - QQ(k)) / (1 + alpha_q)
        has_D = seg_lo < xp_D < seg_hi

        val_lo = float(log2_z_at(seg_lo, p_num, q_den, c_rat))
        val_hi = float(log2_z_at(seg_hi, p_num, q_den, c_rat))

        D_str = ""
        if has_D:
            val_D = float(log2_z_at(xp_D, p_num, q_den, c_rat))
            D_str = f"  D@{float(xp_D):.6f}={val_D:.8f}"

        print(f"    seg[{i}] floor(u)={k}  "
              f"log2z=[{val_lo:.8f}, {val_hi:.8f}]{D_str}")

    zmin, zmax, worst, ratio = cell_exact_logerr(bits, p_num, q_den, c_rat)
    print(f"  => zmin={zmin:.8f}  zmax={zmax:.8f}  worst={worst:.8f}  ratio={ratio:.8f}")
    print()


# ── Main ────────────────────────────────────────────────────────────────

def main():
    print("=" * 80)
    print("FSM coarse-stage experiment: Day x Jukna  (exact H/V/D evaluator)")
    print("=" * 80)

    # Validation
    print("\n--- Validation: exact vs sampled (2048 samples) ---\n")
    validation_cases = [
        ('zero', {}, 1, 4, 1, 2),
        ('state_bit', {}, 3, 5, 1, 2),
        ('terminal_bias', {}, 5, 4, 2, 3),
        ('zero', {}, 2, 6, 1, 3),
    ]
    for policy_name, policy_kwargs, q_v, d_v, p_v, qp_v in validation_cases:
        disc, checked = validate(
            q_v, d_v, p_v, qp_v,
            policy_name=policy_name,
            policy_kwargs=policy_kwargs,
        )
        print(f"  pol={policy_name:<13} q={q_v} depth={d_v} alpha={p_v}/{qp_v}  "
              f"max discrepancy={disc:.2e}  (checked {checked} cells)")
    print()

    # Policy comparison
    print("--- Intercept policy comparison: q=3, depth=6, alpha=1/2 ---\n")
    for policy_name in ('zero', 'state_bit', 'terminal_bias', 'hand_tuned'):
        result = run_experiment(q=3, depth=6, p=1, qpow=2, policy_name=policy_name)
        print_row(result)
    print()

    # Detailed cell report
    print("--- Detailed cell report: q=3, depth=4, alpha=1/2 ---\n")
    c0 = QQ(1) / QQ(4)
    for bits in [(0,0,0,0), (0,1,0,1), (1,0,1,0), (1,1,1,1)]:
        cell_report(bits, 1, 2, c0)

    # Vary depth
    print("--- Varying depth, fixed q (alpha = 1/2) ---\n")
    for q in (1, 2, 3, 5):
        for depth in (3, 4, 5, 6, 7, 8):
            if 2**depth > 512 and q > 3:
                continue
            result = run_experiment(q, depth, p=1, qpow=2, policy_name='zero')
            print_row(result)
        print()

    # Vary q
    print("--- Varying q, fixed depth=6 (alpha = 1/2) ---\n")
    for q in range(1, 10):
        result = run_experiment(q, depth=6, p=1, qpow=2, policy_name='zero')
        print_row(result)
    print()

    # Different alpha
    print("--- Different alpha = p/qpow, q=3, depth=6 ---\n")
    alphas = [(1, 2), (1, 3), (2, 3), (1, 5), (3, 5), (2, 7)]
    for p, qpow in alphas:
        result = run_experiment(q=3, depth=6, p=p, qpow=qpow, policy_name='zero')
        print_row(result)
    print()

    print("=" * 80)
    print("Exact evaluator: breakpoints are u-integer crossings (Day H-grid),")
    print("stationary points are Day D-candidates.  V-grid absent inside [1,2).")
    print()
    print("Current policy layer exposes path-dependent intercept families.")
    print("Next question: which rational policy/search class actually improves")
    print("Day error while preserving interesting Jukna structure?")
    print("=" * 80)


main()
