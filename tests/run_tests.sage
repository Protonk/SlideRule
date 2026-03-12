"""
Project test runner.

Run from project root:  ./sagew tests/run_tests.sage
"""

import os
_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
load(os.path.join(_root, 'lib', 'paths.sage'))
load(os.path.join(_root, 'lib', 'day.sage'))
load(os.path.join(_root, 'lib', 'partitions.sage'))
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
    assert_true(opt["m_opt"] >= 0, "minimax should expose nonnegative m_opt")
    assert_true(opt["max_delta_abs"] >= 0, "minimax should expose snapped max |delta|")
    assert_true("matches_continuous_tau" in opt, "minimax result should expose continuous-tau match status")
    assert_true("within_target" in opt, "minimax result should expose within_target")
    assert_true("fallback_used" in opt, "minimax result should expose fallback_used")
    assert_true("repair_used" in opt, "minimax result should expose repair_used")
    assert_true("tau_continuous" in opt, "minimax result should expose tau_continuous")
    assert_true("tau_snapped" in opt, "minimax result should expose tau_snapped")
    assert_true(opt["within_target"], "minimax smoke case should satisfy its final target")


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


def test_layer_dependent_smoke():
    q, depth = 2, 3
    opt = optimize_shared_delta(q, depth, 1, 2, layer_dependent=True)

    assert_true(opt["unique_intercepts"] >= 1,
                "layer-dependent minimax should expose at least one intercept")
    assert_true(opt["converged"],
                "layer-dependent minimax should converge")
    assert_true(opt["worst_err"] > 0,
                "layer-dependent worst_err should be positive")
    assert_true(opt.get("layer_dependent") == True,
                "result should report layer_dependent=True")


def test_layer_dependent_beats_invariant():
    q, depth = 2, 3
    ld = optimize_shared_delta(q, depth, 1, 2, layer_dependent=True)
    li = optimize_shared_delta(q, depth, 1, 2, layer_dependent=False)
    assert_true(
        ld["worst_err"] <= li["worst_err"] + 1e-8,
        f"layer-dependent ({ld['worst_err']:.8f}) should not be worse than "
        f"layer-invariant ({li['worst_err']:.8f})",
    )


def test_layer_dependent_above_free_bound():
    q, depth = 2, 3
    opt = optimize_shared_delta(q, depth, 1, 2, layer_dependent=True)
    free_worst, _ = free_per_cell_optimum(depth, 1, 2)
    assert_true(
        opt["worst_err"] >= free_worst - 1e-8,
        f"layer-dependent ({opt['worst_err']:.8f}) should be >= "
        f"free-per-cell bound ({free_worst:.8f})",
    )


def test_bits_index_roundtrip():
    for depth in (1, 2, 3, 5):
        N = 2^depth
        for j in range(N):
            bits = index_to_bits(j, depth)
            assert_true(len(bits) == depth, f"bits length mismatch for j={j}, depth={depth}")
            assert_true(bits_to_index(bits) == j, f"roundtrip failed for j={j}, depth={depth}")


def test_uniform_x_partition():
    depth = 4
    part = build_partition(depth, kind='uniform_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    # Contiguity: x_hi of cell j == x_lo of cell j+1
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"uniform_x contiguity gap at j={j}",
        )

    # Covers [1, 2)
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "uniform_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "uniform_x should end at 2")

    # Equal additive widths
    expected_width = HiR(1) / HiR(N)
    for row in part:
        assert_true(
            abs(row['width_x'] - expected_width) < tol,
            f"uniform_x cell {row['index']} has wrong additive width",
        )

    # bits match index
    for row in part:
        assert_true(
            bits_to_index(row['bits']) == row['index'],
            f"uniform_x cell {row['index']} bits mismatch",
        )


def test_geometric_x_partition():
    depth = 4
    part = build_partition(depth, kind='geometric_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    # Contiguity
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"geometric_x contiguity gap at j={j}",
        )

    # Covers [1, 2)
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "geometric_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "geometric_x should end at 2")

    # Equal log widths
    expected_log_width = HiR(1) / HiR(N)
    for row in part:
        assert_true(
            abs(row['width_log'] - expected_log_width) < tol,
            f"geometric_x cell {row['index']} has wrong log width: "
            f"{float(row['width_log'])} vs {float(expected_log_width)}",
        )

    # bits match index
    for row in part:
        assert_true(
            bits_to_index(row['bits']) == row['index'],
            f"geometric_x cell {row['index']} bits mismatch",
        )


def test_partition_row_map():
    depth = 3
    part = build_partition(depth, kind='uniform_x')
    rmap = partition_row_map(part)
    assert_true(len(rmap) == 2^depth, "row map should have 2^depth entries")
    for row in part:
        assert_true(row['bits'] in rmap, f"row map missing bits {row['bits']}")
        assert_true(rmap[row['bits']]['index'] == row['index'], "row map index mismatch")


def test_uniform_x_matches_dyadic():
    """Verify that uniform_x partition agrees with the legacy dyadic_cell_* helpers."""
    depth = 4
    part = build_partition(depth, kind='uniform_x')
    tol = HiR(10)^(-50)

    for row in part:
        dy_lo, dy_hi = dyadic_cell_bounds(row['bits'])
        assert_true(
            abs(row['x_lo'] - dy_lo) < tol,
            f"uniform_x x_lo disagrees with dyadic at cell {row['index']}",
        )
        assert_true(
            abs(row['x_hi'] - dy_hi) < tol,
            f"uniform_x x_hi disagrees with dyadic at cell {row['index']}",
        )

        dy_plo, dy_phi = dyadic_cell_plog(row['bits'])
        assert_true(
            abs(row['plog_lo'] - HiR(dy_plo)) < tol,
            f"uniform_x plog_lo disagrees with dyadic at cell {row['index']}",
        )
        assert_true(
            abs(row['plog_hi'] - HiR(dy_phi)) < tol,
            f"uniform_x plog_hi disagrees with dyadic at cell {row['index']}",
        )


def main():
    tests = [
        ("bits_index_roundtrip", test_bits_index_roundtrip),
        ("uniform_x_partition", test_uniform_x_partition),
        ("geometric_x_partition", test_geometric_x_partition),
        ("partition_row_map", test_partition_row_map),
        ("uniform_x_matches_dyadic", test_uniform_x_matches_dyadic),
        ("residue_paths", test_residue_paths),
        ("global_metrics_and_best_single", test_global_metrics_and_best_single),
        ("active_pattern_family", test_active_pattern_family),
        ("exact_combinatorics", test_exact_combinatorics),
        ("optimizer_smoke", test_optimizer_smoke),
        ("minimax_smoke", test_minimax_smoke),
        ("minimax_beats_nelder_mead", test_minimax_beats_nelder_mead),
        ("minimax_above_free_bound", test_minimax_above_free_bound),
        ("layer_dependent_smoke", test_layer_dependent_smoke),
        ("layer_dependent_beats_invariant", test_layer_dependent_beats_invariant),
        ("layer_dependent_above_free_bound", test_layer_dependent_above_free_bound),
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
