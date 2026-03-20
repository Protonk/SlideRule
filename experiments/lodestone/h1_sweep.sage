"""
H1 hypothesis sweep: depth scaling (H1b), q scaling (H1a), and
layer-dependent vs layer-invariant comparison (H1c).

Sweep 1 (H1b): fixed q=5, exponent_t=1/2, depth in {4..10}.
Sweep 2 (H1a): fixed depth=4, exponent_t=1/2, q in {1,2,3,5,7,9,11,13,15}.
Sweep 3 (H1c): (q=3,d=6) and (q=5,d=6), layer-invariant vs layer-dependent.

All sweeps report delta-shape statistics for H1d (sparsity signal).

Run from project root:  ./sagew experiments/lodestone/h1_sweep.sage
"""

import os
import math

from helpers import pathing
load(pathing('experiments', 'lodestone', 'lodestone_runner.sage'))


# ── Delta-shape statistics (H1d) ────────────────────────────────────────

def delta_shape_stats(delta_rat, q, m_opt):
    """Compute sparsity/concentration statistics from the optimized delta table."""
    vals = [float(v) for v in delta_rat.values()]
    abs_vals = [abs(v) for v in vals]

    l1_delta = sum(abs_vals)
    l2_delta = math.sqrt(sum(v * v for v in vals))

    threshold_mopt10 = float(m_opt) / 10.0 if m_opt > 0 else 0.0
    nnz_mopt10 = sum(1 for a in abs_vals if a >= threshold_mopt10)
    nnz_1e3 = sum(1 for a in abs_vals if a >= 1e-3)
    n_zero = sum(1 for a in abs_vals if a == 0.0)

    sorted_abs = sorted(abs_vals, reverse=True)
    top2_sum = sum(sorted_abs[:2])
    top2_mass = top2_sum / l1_delta if l1_delta > 0 else 0.0

    return {
        "l1_delta": l1_delta,
        "l2_delta": l2_delta,
        "nnz_mopt10": nnz_mopt10,
        "nnz_1e3": nnz_1e3,
        "n_zero": n_zero,
        "top2_mass": top2_mass,
    }


# ── Per-case computation ────────────────────────────────────────────────

def run_h1_case(q, depth, p_num, q_den, layer_dependent=False):
    """Run one case via compute_case and add H1-specific delta-shape stats."""
    case = compute_case(q, depth, p_num, q_den, layer_dependent=layer_dependent)

    opt_pol = case["opt_pol"]
    ds = delta_shape_stats(opt_pol["delta_rat"], q, opt_pol["m_opt"])

    available = case["single_err"] - case["free_err"]
    improve_over_single = case["improve"] / case["single_err"] if case["single_err"] > 0 else 0.0
    improve_over_available = case["improve"] / available if available > 0 else 0.0

    return {
        "exponent": f"{p_num}/{q_den}",
        "q": q,
        "depth": depth,
        "n_params": case["n_params"],
        "layer_dependent": layer_dependent,
        "paths": case["n_paths"],
        "single_err": case["single_err"],
        "opt_err": case["opt_err"],
        "free_err": case["free_err"],
        "single_u": case["single_u"],
        "opt_u": case["opt_u"],
        "free_u": case["free_u"],
        "improve": case["improve"],
        "gap": case["gap"],
        "improve_over_single": improve_over_single,
        "improve_over_available": improve_over_available,
        "Mopt": opt_pol["m_opt"],
        "max_delta_abs": opt_pol["max_delta_abs"],
        "tau_continuous": opt_pol["tau_continuous"],
        "tau_snapped": opt_pol["tau_snapped"],
        "dyadic_loss": opt_pol["dyadic_loss"],
        "l1_delta": ds["l1_delta"],
        "l2_delta": ds["l2_delta"],
        "nnz_mopt10": ds["nnz_mopt10"],
        "nnz_1e3": ds["nnz_1e3"],
        "n_zero": ds["n_zero"],
        "top2_mass": ds["top2_mass"],
        "time": case["elapsed"],
    }


# ── Table printing ──────────────────────────────────────────────────────

TABLE_HEADER = (
    f"{'q':>3}  {'d':>2}  {'#p':>3}  {'paths':>5}  "
    f"{'single_err':>10}  {'opt_err':>10}  {'free_err':>10}  "
    f"{'improve':>9}  {'gap':>10}  {'imp/sgl':>7}  {'imp/avl':>7}  "
    f"{'Mopt':>8}  {'l1_d':>8}  {'nnz':>3}  {'top2':>5}  {'time':>6}"
)


def print_row(r):
    print(
        f"{r['q']:>3}  {r['depth']:>2}  {r['n_params']:>3}  {r['paths']:>5}  "
        f"{r['single_err']:>10.6f}  {r['opt_err']:>10.6f}  {r['free_err']:>10.6f}  "
        f"{r['improve']:>9.6f}  {r['gap']:>10.6f}  {r['improve_over_single']:>7.4f}  "
        f"{r['improve_over_available']:>7.4f}  "
        f"{r['Mopt']:>8.6f}  {r['l1_delta']:>8.5f}  {r['nnz_mopt10']:>3}  "
        f"{r['top2_mass']:>5.3f}  {r['time']:>5.1f}s"
    )


# ── CSV output ──────────────────────────────────────────────────────────

CSV_COLUMNS = [
    "exponent", "q", "depth", "n_params", "layer_dependent",
    "single_err", "opt_err", "free_err",
    "single_u", "opt_u", "free_u",
    "improve", "gap", "improve_over_single", "improve_over_available",
    "Mopt", "max_delta_abs",
    "tau_continuous", "tau_snapped", "dyadic_loss",
    "l1_delta", "l2_delta", "nnz_mopt10", "nnz_1e3", "n_zero", "top2_mass",
    "time",
]


def write_h1_csv(rows, filepath):
    write_csv(rows, filepath, CSV_COLUMNS)


# ── Main ────────────────────────────────────────────────────────────────

def main():
    p_num, q_den = 1, 2
    results_dir = pathing('experiments', 'lodestone', 'results')

    # ── Sweep 1: H1b — depth scaling at fixed q ─────────────────────────

    print("=" * 100)
    print("Sweep 1 (H1b): depth scaling at fixed q=5, exponent=1/2")
    print("=" * 100)
    print()

    h1b_q = 5
    h1b_depths = [4, 5, 6, 7, 8, 9, 10]

    print(TABLE_HEADER)
    print("-" * len(TABLE_HEADER))

    h1b_rows = []
    for depth in h1b_depths:
        r = run_h1_case(h1b_q, depth, p_num, q_den)
        print_row(r)
        h1b_rows.append(r)

    write_h1_csv(h1b_rows, os.path.join(results_dir, 'h1b_depth_scaling.csv'))

    # ── Sweep 2: H1a — q scaling at fixed depth ─────────────────────────

    print()
    print("=" * 100)
    print("Sweep 2 (H1a): q scaling at fixed depth=4, exponent=1/2")
    print("=" * 100)
    print()

    h1a_depth = 4
    h1a_qs = [1, 2, 3, 5, 7, 9, 11, 13, 15]

    print(TABLE_HEADER)
    print("-" * len(TABLE_HEADER))

    h1a_rows = []
    for q in h1a_qs:
        r = run_h1_case(q, h1a_depth, p_num, q_den)
        print_row(r)
        h1a_rows.append(r)

    write_h1_csv(h1a_rows, os.path.join(results_dir, 'h1a_gap_vs_q.csv'))

    # ── Sweep 3: H1c — layer-dependent vs layer-invariant ──────────────

    print()
    print("=" * 100)
    print("Sweep 3 (H1c): layer-dependent vs layer-invariant at (q=3,d=6) and (q=5,d=6)")
    print("=" * 100)
    print()

    h1c_cases = [(3, 6), (5, 6)]

    print(TABLE_HEADER)
    print("-" * len(TABLE_HEADER))

    h1c_rows = []
    for q_val, d_val in h1c_cases:
        r_li = run_h1_case(q_val, d_val, p_num, q_den, layer_dependent=False)
        print_row(r_li)
        h1c_rows.append(r_li)

        r_ld = run_h1_case(q_val, d_val, p_num, q_den, layer_dependent=True)
        print_row(r_ld)
        h1c_rows.append(r_ld)

        gap_li = r_li["gap"]
        gap_ld = r_ld["gap"]
        if gap_li > 0:
            print(f"  -> layer-dep gain: opt_err {r_li['opt_err']:.6f} -> {r_ld['opt_err']:.6f}, "
                  f"gap {gap_li:.6f} -> {gap_ld:.6f} "
                  f"({(1 - gap_ld/gap_li)*100:.1f}% reduction)")
        print()

    write_h1_csv(h1c_rows, os.path.join(results_dir, 'h1c_layer_dependent.csv'))

    print()
    print("=" * 100)
    print("Column key:")
    print("  imp/sgl  = improve / single_err         (relative gain)")
    print("  imp/avl  = improve / (single - free)     (fraction of available room)")
    print("  Mopt     = min max|delta| at continuous tau")
    print("  l1_d     = sum |delta_i|")
    print("  nnz      = count of |delta_i| >= Mopt/10")
    print("  top2     = mass fraction in 2 largest |delta_i|")
    print("=" * 100)


main()
