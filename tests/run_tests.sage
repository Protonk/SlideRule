"""
Project test runner.

Run from project root:  ./sagew tests/run_tests.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'policies.sage'))
load(os.path.join(_root, 'lib', 'jukna.sage'))
load(os.path.join(_root, 'lib', 'optimize.sage'))


def assert_true(condition, message):
    if not condition:
        raise AssertionError(message)


def assert_close(lhs, rhs, tol, message):
    if abs(lhs - rhs) > tol:
        raise AssertionError(f"{message}: lhs={lhs}, rhs={rhs}, tol={tol}")


def test_residue_paths():
    edges, paths, edge_index = residue_paths(2, 3)
    assert_true(len(edges) == 12, "unexpected edge count")
    assert_true(len(paths) == 8, "unexpected path count")
    assert_true(len(edge_index) == len(edges), "edge index mismatch")
    for row in paths:
        assert_true(sum(row["vec"]) == 3, "path incidence vector should have depth weight")
        assert_true(len(row["states"]) == 4, "state trace should include source plus depth states")


def test_global_metrics_and_best_single():
    _, paths, _ = residue_paths(1, 3)
    alpha_q = QQ(1) / QQ(2)
    zero = zero_policy(1, 3, alpha_q)
    metrics = global_exact_metrics(paths, 1, 2, zero["c0_rat"], zero["delta_rat"], 1)
    best = best_single_intercept(paths, 1, 2)

    assert_true(
        metrics["union_log2_ratio"] >= metrics["max_cell_log2_ratio"],
        "union ratio should dominate max cell ratio",
    )
    assert_true(
        best["worst_abs"] <= metrics["worst_abs"] + 1e-12,
        "best single intercept should not be worse than centered baseline",
    )


def test_active_pattern_family():
    _, paths, _ = residue_paths(1, 3)
    alpha_q = QQ(1) / QQ(2)
    zero = zero_policy(1, 3, alpha_q)
    family = build_active_pattern_family(paths, 1, 2, zero["c0_rat"], zero["delta_rat"], 1)

    assert_true(len(family["coordinate_keys"]) > 0, "pattern family should expose coordinates")
    assert_true(0 < len(family["unique_vectors"]) <= len(paths), "unexpected unique vector count")
    for vec in family["unique_vectors"]:
        assert_true(all(entry in (0, 1) for entry in vec), "pattern vectors must be 0-1")


def test_exact_combinatorics():
    vectors = [
        vector(ZZ, [1, 0, 0]),
        vector(ZZ, [0, 1, 0]),
        vector(ZZ, [0, 0, 1]),
        vector(ZZ, [1, 1, 0]),
    ]
    summary = summarize_vector_family(vectors)

    assert_true(summary["exact_sidon_subset"] is not None, "exact Sidon search should run")
    assert_true(summary["exact_cover_free_subset"] is not None, "exact cover-free search should run")
    assert_true(
        summary["exact_sidon_subset_size"] >= summary["greedy_sidon_subset_size"],
        "exact Sidon optimum should dominate greedy result",
    )
    assert_true(
        summary["exact_cover_free_subset_size"] >= summary["greedy_cover_free_subset_size"],
        "exact cover-free optimum should dominate greedy result",
    )
    assert_true(
        is_sidon(vectors, subset=summary["exact_sidon_subset"]),
        "exact Sidon subset must satisfy Sidon property",
    )
    assert_true(
        is_cover_free(vectors, subset=summary["exact_cover_free_subset"])[0],
        "exact cover-free subset must satisfy cover-free property",
    )


def test_optimizer_smoke():
    _, paths, _ = residue_paths(1, 2)
    best = best_single_intercept(paths, 1, 2)
    opt = optimize_shared_delta(1, 2, 1, 2, maxiter=40, n_restarts=1, dyadic_bits=8,
                                method='nelder-mead')

    assert_true(opt["unique_intercepts"] >= 1, "optimized policy should expose at least one intercept")
    assert_true(
        opt["worst_err"] <= best["worst_abs"] + 1e-8,
        "shared-delta optimizer should not regress against best single intercept on the smoke case",
    )


def test_minimax_smoke():
    opt = optimize_shared_delta(1, 2, 1, 2)  # defaults to method='minimax'

    assert_true(opt["unique_intercepts"] >= 1, "minimax should expose at least one intercept")
    assert_true(opt["converged"], "minimax should report converged")
    assert_true(opt["worst_err"] > 0, "minimax worst_err should be positive")


def test_minimax_beats_nelder_mead():
    q, depth = 2, 4
    mm = optimize_shared_delta(q, depth, 1, 2, method='minimax')
    nm = optimize_shared_delta(q, depth, 1, 2, method='nelder-mead',
                               maxiter=2000, n_restarts=2, dyadic_bits=12)
    assert_true(
        mm["worst_err"] <= nm["worst_err"] + 1e-8,
        f"minimax ({mm['worst_err']:.8f}) should be no worse than "
        f"nelder-mead ({nm['worst_err']:.8f})",
    )


def test_minimax_above_free_bound():
    q, depth = 2, 4
    mm = optimize_shared_delta(q, depth, 1, 2, method='minimax')
    free_worst, _ = free_per_cell_optimum(depth, 1, 2)
    assert_true(
        mm["worst_err"] >= free_worst - 1e-8,
        f"minimax ({mm['worst_err']:.8f}) should be >= "
        f"free-per-cell bound ({free_worst:.8f})",
    )


def main():
    tests = [
        ("residue_paths", test_residue_paths),
        ("global_metrics_and_best_single", test_global_metrics_and_best_single),
        ("active_pattern_family", test_active_pattern_family),
        ("exact_combinatorics", test_exact_combinatorics),
        ("optimizer_smoke", test_optimizer_smoke),
        ("minimax_smoke", test_minimax_smoke),
        ("minimax_beats_nelder_mead", test_minimax_beats_nelder_mead),
        ("minimax_above_free_bound", test_minimax_above_free_bound),
    ]

    print("=" * 80)
    print("smale test suite")
    print("=" * 80)

    for name, fn in tests:
        fn()
        print(f"[ok] {name}")

    print("=" * 80)
    print(f"passed {len(tests)} tests")
    print("=" * 80)


main()
