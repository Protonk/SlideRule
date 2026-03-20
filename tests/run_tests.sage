"""
Project test runner.

Run from project root:  ./sagew tests/run_tests.sage
"""

from helpers import pathing
load(pathing('lib', 'paths.sage'))
load(pathing('lib', 'day.sage'))
load(pathing('lib', 'partitions.sage'))
load(pathing('lib', 'policies.sage'))
load(pathing('lib', 'jukna.sage'))
load(pathing('lib', 'optimize.sage'))


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
    exponent_q = QQ(1) / QQ(2)
    zero = zero_policy(1, 3, exponent_q)
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
    exponent_q = QQ(1) / QQ(2)
    zero = zero_policy(1, 3, exponent_q)
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


def test_arb_evaluator_oracle_d3():
    """Arbitrary-cell evaluator matches exact evaluator on uniform_x depth=3."""
    c_rat = QQ(1) / QQ(4)  # exponent=1/2 => c = (1-1/2)/2 = 1/4
    max_disc, n_cells, _ = validate_arb_against_exact(3, 1, 2, c_rat, tol=1e-12, hard_tol=1e-8)
    assert_true(n_cells == 8, f"expected 8 cells, got {n_cells}")
    assert_true(
        max_disc <= 1e-12,
        f"arb evaluator oracle discrepancy {max_disc:.2e} exceeds 1e-12 at depth=3",
    )


def test_arb_evaluator_oracle_d5():
    """Arbitrary-cell evaluator matches exact evaluator on uniform_x depth=5."""
    c_rat = QQ(1) / QQ(4)
    max_disc, n_cells, _ = validate_arb_against_exact(5, 1, 2, c_rat, tol=1e-12, hard_tol=1e-8)
    assert_true(n_cells == 32, f"expected 32 cells, got {n_cells}")
    assert_true(
        max_disc <= 1e-12,
        f"arb evaluator oracle discrepancy {max_disc:.2e} exceeds 1e-12 at depth=5",
    )


def test_arb_evaluator_oracle_varied_c():
    """Oracle validation with an optimized intercept, not just the centered default."""
    _, paths, _ = residue_paths(1, 3)
    best = best_single_intercept(paths, 1, 2)
    c_rat = best["c0_rat"]
    max_disc, n_cells, _ = validate_arb_against_exact(3, 1, 2, c_rat, tol=1e-12, hard_tol=1e-8)
    assert_true(
        max_disc <= 1e-12,
        f"arb evaluator oracle discrepancy {max_disc:.2e} with optimized c at depth=3",
    )


def test_d_candidate_validity():
    """D-candidates that pass containment also pass floor(u)=k."""
    exponent_q = QQ(1) / QQ(2)
    c = QQ(1) / QQ(4)
    depth = 4
    partition = build_partition(depth, kind='uniform_x')

    for row in partition:
        breakpoints = cell_breakpoints_arb(row['plog_lo'], row['plog_hi'], 1, 2, c)
        for i in range(len(breakpoints) - 1):
            seg_lo = breakpoints[i]
            seg_hi = breakpoints[i + 1]
            seg_mid_hi = (HiR(seg_lo) + HiR(seg_hi)) / 2
            u_mid = HiR(c) - HiR(exponent_q) * seg_mid_hi
            k = Integer(floor(u_mid))
            xp_D = (c - QQ(k)) / (1 + exponent_q)
            if HiR(seg_lo) < HiR(xp_D) < HiR(seg_hi):
                assert_true(
                    _d_candidate_valid(xp_D, k, 1, 2, c),
                    f"D-candidate at plog={float(xp_D)} failed floor(u)=k "
                    f"on cell {row['index']} segment {i}",
                )


def test_arb_evaluator_geometric_smoke():
    """Arbitrary-cell evaluator runs on geometric_x cells without error."""
    c_rat = QQ(1) / QQ(4)
    depth = 4
    partition = build_partition(depth, kind='geometric_x')

    for row in partition:
        zmin, zmax, worst, ratio, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], 1, 2, c_rat
        )
        assert_true(worst >= 0, f"negative worst on geometric_x cell {row['index']}")
        assert_true(ratio >= 0, f"negative ratio on geometric_x cell {row['index']}")
        assert_true(meta['n_candidates'] >= 2, f"too few candidates on cell {row['index']}")


def test_arb_concavity_boundary_min():
    """On representative segments, worst negative excursion is at boundary, not D."""
    c_rat = QQ(1) / QQ(4)
    depth = 4
    partition = build_partition(depth, kind='uniform_x')

    for row in partition:
        _, _, _, _, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], 1, 2, c_rat
        )
        d_vals = [v for _, v, t in meta['candidates'] if t == 'D']
        non_d_vals = [v for _, v, t in meta['candidates'] if t != 'D']

        if not d_vals:
            continue

        min_d = min(d_vals)
        min_non_d = min(non_d_vals)
        assert_true(
            min_d > min_non_d + 1e-12,
            f"D-candidate realizes the worst negative excursion on cell {row['index']}: "
            f"min_d={min_d:.15e}, min_non_d={min_non_d:.15e}",
        )


def test_arb_meta_reports_x_and_plog():
    """Arbitrary-cell metadata should report worst candidate in both x and plog."""
    c_rat = QQ(1) / QQ(4)
    row = build_partition(4, kind='geometric_x')[5]
    _, _, _, _, meta = cell_logerr_arb(row['plog_lo'], row['plog_hi'], 1, 2, c_rat)

    assert_true('worst_x' in meta, "meta should expose worst_x")
    assert_true('worst_plog' in meta, "meta should expose worst_plog")
    assert_true(
        abs(meta['worst_x'] - (1.0 + meta['worst_plog'])) < 1e-12,
        "worst_x and worst_plog should satisfy x = 1 + plog on [1,2)",
    )
    assert_true(
        float(row['x_lo']) - 1e-12 <= meta['worst_x'] <= float(row['x_hi']) + 1e-12,
        "worst_x should lie inside the cell bounds",
    )


def test_minimax_uniform_x_partition():
    """Minimax with explicit uniform_x partition converges and has partition metadata."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='uniform_x')

    assert_true(opt["converged"], "uniform_x partition minimax should converge")
    assert_true(opt["worst_err"] > 0, "worst_err should be positive")
    assert_true(opt.get("partition_kind") == 'uniform_x', "result should report partition_kind")
    assert_true("worst_cell_bits" in opt, "result should have worst_cell_bits")


def test_minimax_geometric_x_smoke():
    """Minimax with geometric_x partition converges."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='geometric_x')

    assert_true(opt["converged"], "geometric_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "geometric_x worst_err should be positive")
    assert_true(opt.get("partition_kind") == 'geometric_x', "result should report geometric_x")
    assert_true("worst_cell_bits" in opt, "result should have worst_cell metadata")
    assert_true("worst_cell_index" in opt, "result should have worst_cell_index")
    assert_true("worst_cell_x_lo" in opt, "result should have worst_cell_x_lo")


def test_geometric_x_above_free_bound():
    """Geometric_x minimax stays above the free-per-cell bound."""
    q, depth = 1, 3
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='geometric_x')
    free_worst, _ = free_per_cell_optimum(depth, 1, 2, partition_kind='geometric_x')
    assert_true(
        opt["worst_err"] >= free_worst - 1e-8,
        f"geometric_x minimax ({opt['worst_err']:.8f}) should be >= "
        f"free-per-cell bound ({free_worst:.8f})",
    )


def test_harmonic_x_partition():
    depth = 4
    part = build_partition(depth, kind='harmonic_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    # Contiguity
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"harmonic_x contiguity gap at j={j}",
        )

    # Covers [1, 2)
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "harmonic_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "harmonic_x should end at 2")

    # Reciprocal spacing is finer near x=1 and wider near x=2.
    assert_true(
        part[-1]['width_x'] > part[0]['width_x'],
        "harmonic_x cells should be wider near x=2 than near x=1",
    )

    # Descriptive alias should resolve to the same geometry.
    alias_part = build_partition(depth, kind='reciprocal_x')
    for j in range(N):
        assert_true(
            abs(part[j]['x_lo'] - alias_part[j]['x_lo']) < tol
            and abs(part[j]['x_hi'] - alias_part[j]['x_hi']) < tol,
            f"reciprocal_x alias mismatch at j={j}",
        )

    # bits match index
    for row in part:
        assert_true(
            bits_to_index(row['bits']) == row['index'],
            f"harmonic_x cell {row['index']} bits mismatch",
        )


def test_mirror_harmonic_x_partition():
    depth = 4
    part = build_partition(depth, kind='mirror_harmonic_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)

    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"mirror_harmonic_x contiguity gap at j={j}",
        )

    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "mirror_harmonic_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "mirror_harmonic_x should end at 2")

    # Mirrored reciprocal spacing is wider near x=1 and finer near x=2.
    assert_true(
        part[0]['width_x'] > part[-1]['width_x'],
        "mirror_harmonic_x cells should be wider near x=1 than near x=2",
    )

    alias_part = build_partition(depth, kind='mirror_reciprocal_x')
    for j in range(N):
        assert_true(
            abs(part[j]['x_lo'] - alias_part[j]['x_lo']) < tol
            and abs(part[j]['x_hi'] - alias_part[j]['x_hi']) < tol,
            f"mirror_reciprocal_x alias mismatch at j={j}",
        )


def test_minimax_harmonic_x_smoke():
    """Minimax with harmonic_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='harmonic_x')

    assert_true(opt["converged"], "harmonic_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "harmonic_x worst_err should be positive")
    assert_true(opt.get("partition_kind") == 'harmonic_x', "result should report harmonic_x")
    assert_true("worst_cell_bits" in opt, "result should have worst_cell metadata")
    assert_true("worst_cell_index" in opt, "result should have worst_cell_index")


def test_minimax_mirror_harmonic_x_smoke():
    """Minimax with mirror_harmonic_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='mirror_harmonic_x')

    assert_true(opt["converged"], "mirror_harmonic_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "mirror_harmonic_x worst_err should be positive")
    assert_true(
        opt.get("partition_kind") == 'mirror_harmonic_x',
        "result should report mirror_harmonic_x",
    )
    assert_true("worst_cell_bits" in opt, "result should have worst_cell metadata")
    assert_true("worst_cell_index" in opt, "result should have worst_cell_index")


def test_ruler_x_partition():
    """Ruler partition: contiguity, covers [1,2), widths follow 2-adic valuation."""
    depth = 4
    part = build_partition(depth, kind='ruler_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"ruler_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "ruler_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "ruler_x should end at 2")

    # Cell 0 (j+1=1, v2=0) should be widest; cell N-1 (j+1=N, v2=depth) narrowest.
    widths = [float(r['width_x']) for r in part]
    assert_true(widths[0] == max(widths), "ruler_x cell 0 should be widest")
    assert_true(widths[-1] == min(widths), "ruler_x cell N-1 should be narrowest")

    # Width ratios should be powers of 2.
    w0 = widths[0]
    for j in range(N):
        ratio = w0 / widths[j]
        log_ratio = round(float(log(ratio, 2)))
        assert_true(
            abs(ratio - 2**log_ratio) < 1e-10,
            f"ruler_x width ratio at j={j} is not a power of 2: {ratio}",
        )


def test_sinusoidal_x_partition():
    """Sinusoidal partition: contiguity, covers [1,2), widths oscillate."""
    depth = 4
    part = build_partition(depth, kind='sinusoidal_x', sin_k=3, sin_alpha=0.6)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)   # bisection gives ~18 digits, not exact arithmetic
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"sinusoidal_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "sinusoidal_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "sinusoidal_x should end at 2")

    # Widths should NOT be monotone (oscillating density).
    widths = [float(r['width_x']) for r in part]
    diffs = [widths[j+1] - widths[j] for j in range(len(widths) - 1)]
    has_increase = any(d > 0 for d in diffs)
    has_decrease = any(d < 0 for d in diffs)
    assert_true(has_increase and has_decrease,
                "sinusoidal_x widths should oscillate (not monotone)")

    # alpha=0 should recover geometric (uniform in log-space).
    part0 = build_partition(depth, kind='sinusoidal_x', sin_k=3, sin_alpha=0.0)
    geo = build_partition(depth, kind='geometric_x')
    for j in range(N):
        assert_true(
            abs(float(part0[j]['width_x']) - float(geo[j]['width_x'])) < 1e-10,
            f"sinusoidal_x with alpha=0 should match geometric at j={j}",
        )


def test_minimax_ruler_x_smoke():
    """Minimax with ruler_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='ruler_x')
    assert_true(opt["converged"], "ruler_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "ruler_x worst_err should be positive")


def test_minimax_sinusoidal_x_smoke():
    """Minimax with sinusoidal_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='sinusoidal_x')
    assert_true(opt["converged"], "sinusoidal_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "sinusoidal_x worst_err should be positive")


def test_chebyshev_x_partition():
    """Chebyshev partition: contiguity, covers [1,2), dense at both endpoints."""
    depth = 4
    part = build_partition(depth, kind='chebyshev_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"chebyshev_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "chebyshev_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "chebyshev_x should end at 2")

    # Cells at endpoints should be narrower than cells in the middle.
    mid = N // 2
    assert_true(
        part[0]['width_x'] < part[mid]['width_x'],
        "chebyshev_x: first cell should be narrower than middle cell",
    )
    assert_true(
        part[-1]['width_x'] < part[mid]['width_x'],
        "chebyshev_x: last cell should be narrower than middle cell",
    )


def test_minimax_chebyshev_x_smoke():
    """Minimax with chebyshev_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='chebyshev_x')
    assert_true(opt["converged"], "chebyshev_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "chebyshev_x worst_err should be positive")


def test_thuemorse_x_partition():
    """Thue-Morse partition: contiguity, covers [1,2), exactly two distinct widths."""
    depth = 4
    part = build_partition(depth, kind='thuemorse_x', tm_ratio=2)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"thuemorse_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "thuemorse_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "thuemorse_x should end at 2")

    # Exactly two distinct widths with ratio tm_ratio.
    widths = sorted(set(float(r['width_x']) for r in part))
    assert_true(len(widths) == 2, f"thuemorse_x should have 2 distinct widths, got {len(widths)}")
    ratio = widths[1] / widths[0]
    assert_true(
        abs(ratio - 2.0) < 1e-10,
        f"thuemorse_x width ratio should be 2:1, got {ratio}",
    )


def test_minimax_thuemorse_x_smoke():
    """Minimax with thuemorse_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='thuemorse_x')
    assert_true(opt["converged"], "thuemorse_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "thuemorse_x worst_err should be positive")


def test_bitrev_geometric_x_partition():
    """Bitrev-geometric partition: contiguity, covers [1,2), same width multiset as geometric."""
    depth = 4
    part = build_partition(depth, kind='bitrev_geometric_x')
    geo = build_partition(depth, kind='geometric_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"bitrev_geometric_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "bitrev_geometric_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "bitrev_geometric_x should end at 2")

    # Same multiset of widths as geometric (sorted widths should match).
    br_widths = sorted(float(r['width_x']) for r in part)
    geo_widths = sorted(float(r['width_x']) for r in geo)
    for j in range(N):
        assert_true(
            abs(br_widths[j] - geo_widths[j]) < 1e-12,
            f"bitrev_geometric_x sorted width mismatch at j={j}",
        )

    # But the order should differ (not identical to geometric).
    order_differs = any(
        abs(float(part[j]['width_x']) - float(geo[j]['width_x'])) > 1e-12
        for j in range(N)
    )
    assert_true(order_differs, "bitrev_geometric_x should differ in cell order from geometric")


def test_minimax_bitrev_geometric_x_smoke():
    """Minimax with bitrev_geometric_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='bitrev_geometric_x')
    assert_true(opt["converged"], "bitrev_geometric_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "bitrev_geometric_x worst_err should be positive")


def test_stern_brocot_x_partition():
    """Stern-Brocot partition: contiguity, covers [1,2), known depth-2 boundaries."""
    depth = 4
    part = build_partition(depth, kind='stern_brocot_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"stern_brocot_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "stern_brocot_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "stern_brocot_x should end at 2")

    # All boundaries should be rationals.
    for row in part:
        # HiR values from QQ should be exact rationals.
        x_lo_f = float(row['x_lo'])
        assert_true(x_lo_f > 0, f"stern_brocot_x cell {row['index']} has non-positive x_lo")

    # Known depth-2 boundaries: [1, 4/3, 3/2, 5/3, 2].
    part2 = build_partition(2, kind='stern_brocot_x')
    expected = [QQ(1), QQ(4)/QQ(3), QQ(3)/QQ(2), QQ(5)/QQ(3), QQ(2)]
    boundaries = [part2[0]['x_lo']] + [r['x_hi'] for r in part2]
    for j in range(5):
        assert_true(
            abs(boundaries[j] - HiR(expected[j])) < tol,
            f"stern_brocot_x depth-2 boundary {j}: expected {expected[j]}, "
            f"got {float(boundaries[j])}",
        )


def test_minimax_stern_brocot_x_smoke():
    """Minimax with stern_brocot_x partition converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='stern_brocot_x')
    assert_true(opt["converged"], "stern_brocot_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "stern_brocot_x worst_err should be positive")


def test_reverse_geometric_x_partition():
    """Reverse geometric: contiguity, covers [1,2), widths increase left to right."""
    depth = 4
    part = build_partition(depth, kind='reverse_geometric_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-50)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"reverse_geometric_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "reverse_geometric_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "reverse_geometric_x should end at 2")

    # Widths should decrease (opposite of geometric, which increases).
    widths = [float(r['width_x']) for r in part]
    for j in range(N - 1):
        assert_true(widths[j] > widths[j + 1],
                    f"reverse_geometric_x widths should decrease at j={j}")


def test_minimax_reverse_geometric_x_smoke():
    """Minimax with reverse_geometric_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='reverse_geometric_x')
    assert_true(opt["converged"], "reverse_geometric_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "reverse_geometric_x worst_err should be positive")


def test_random_x_partition():
    """Random partition: contiguity, covers [1,2), deterministic with fixed seed."""
    depth = 4
    part = build_partition(depth, kind='random_x', random_seed=42)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"random_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "random_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "random_x should end at 2")

    # Deterministic: same seed gives same partition.
    part2 = build_partition(depth, kind='random_x', random_seed=42)
    for j in range(N):
        assert_true(
            abs(float(part[j]['width_x']) - float(part2[j]['width_x'])) < 1e-14,
            f"random_x should be deterministic at j={j}",
        )


def test_minimax_random_x_smoke():
    """Minimax with random_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='random_x')
    assert_true(opt["converged"], "random_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "random_x worst_err should be positive")


def test_dyadic_x_partition():
    """Dyadic partition: contiguity, covers [1,2), all boundaries are dyadic rationals."""
    depth = 4
    part = build_partition(depth, kind='dyadic_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"dyadic_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "dyadic_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "dyadic_x should end at 2")

    # All interior boundaries should be dyadic rationals (denominator is power of 2).
    R = depth + 4
    scale = 2**R
    for j in range(1, N):
        val = float(part[j]['x_lo'])
        snapped = round(val * scale) / scale
        assert_true(
            abs(val - snapped) < 1e-12,
            f"dyadic_x boundary at j={j} is not dyadic: {val}",
        )


def test_minimax_dyadic_x_smoke():
    """Minimax with dyadic_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='dyadic_x')
    assert_true(opt["converged"], "dyadic_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "dyadic_x worst_err should be positive")


def test_powerlaw_x_partition():
    """Power-law partition: contiguity, covers [1,2), first cell narrower than last."""
    depth = 4
    part = build_partition(depth, kind='powerlaw_x', pl_exponent=3)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"powerlaw_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "powerlaw_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "powerlaw_x should end at 2")

    # Aggressive left-packing: first cell much narrower than last.
    assert_true(
        float(part[0]['width_x']) < float(part[-1]['width_x']),
        "powerlaw_x: first cell should be narrower than last cell",
    )
    # Check ratio is substantial (p=3 should give big difference).
    ratio = float(part[-1]['width_x']) / float(part[0]['width_x'])
    assert_true(ratio > 5, f"powerlaw_x width ratio should be large, got {ratio:.1f}")


def test_minimax_powerlaw_x_smoke():
    """Minimax with powerlaw_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='powerlaw_x')
    assert_true(opt["converged"], "powerlaw_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "powerlaw_x worst_err should be positive")


def test_golden_x_partition():
    """Golden-ratio partition: contiguity, covers [1,2), N-1 distinct interior points."""
    depth = 4
    part = build_partition(depth, kind='golden_x')
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"golden_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "golden_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "golden_x should end at 2")

    # Widths should be non-uniform (multiple distinct values).
    widths = [round(float(r['width_x']), 12) for r in part]
    assert_true(
        len(set(widths)) > 1,
        "golden_x should have non-uniform widths",
    )

    # Widths should be non-monotone (quasi-random scattering).
    raw_widths = [float(r['width_x']) for r in part]
    diffs = [raw_widths[j+1] - raw_widths[j] for j in range(len(raw_widths) - 1)]
    has_inc = any(d > 1e-15 for d in diffs)
    has_dec = any(d < -1e-15 for d in diffs)
    assert_true(has_inc and has_dec,
                "golden_x widths should be non-monotone")


def test_minimax_golden_x_smoke():
    """Minimax with golden_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='golden_x')
    assert_true(opt["converged"], "golden_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "golden_x worst_err should be positive")


def test_cantor_x_partition():
    """Cantor dust partition: contiguity, covers [1,2), non-monotone widths."""
    depth = 4
    part = build_partition(depth, kind='cantor_x', cantor_levels=3)
    N = 2^depth
    assert_true(len(part) == N, f"expected {N} cells, got {len(part)}")

    tol = HiR(10)^(-10)
    for j in range(N - 1):
        assert_true(
            abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
            f"cantor_x contiguity gap at j={j}",
        )
    assert_true(abs(part[0]['x_lo'] - HiR(1)) < tol, "cantor_x should start at 1")
    assert_true(abs(part[-1]['x_hi'] - HiR(2)) < tol, "cantor_x should end at 2")

    # Widths should be non-monotone (clustered structure with gaps).
    widths = [float(r['width_x']) for r in part]
    diffs = [widths[j+1] - widths[j] for j in range(len(widths) - 1)]
    has_increase = any(d > 1e-15 for d in diffs)
    has_decrease = any(d < -1e-15 for d in diffs)
    assert_true(has_increase and has_decrease,
                "cantor_x widths should be non-monotone")


def test_minimax_cantor_x_smoke():
    """Minimax with cantor_x converges and returns positive worst_err."""
    q, depth = 1, 2
    opt = optimize_shared_delta(q, depth, 1, 2, partition_kind='cantor_x')
    assert_true(opt["converged"], "cantor_x minimax should converge")
    assert_true(opt["worst_err"] > 0, "cantor_x worst_err should be positive")


def test_partition_aware_best_single():
    """best_single_intercept works with partition_kind."""
    _, paths, _ = residue_paths(1, 3)
    best_legacy = best_single_intercept(paths, 1, 2)
    best_uniform = best_single_intercept(paths, 1, 2, partition_kind='uniform_x')
    best_geometric = best_single_intercept(paths, 1, 2, partition_kind='geometric_x')

    # uniform_x should agree closely with legacy
    assert_true(
        abs(best_legacy["worst_abs"] - best_uniform["worst_abs"]) < 1e-10,
        "partition-aware uniform_x best_single should match legacy",
    )
    # geometric should produce a finite positive result
    assert_true(
        best_geometric["worst_abs"] > 0,
        "geometric_x best_single should have positive error",
    )
    assert_true(
        best_geometric.get("partition_kind") == 'geometric_x',
        "result should report partition_kind",
    )


def test_nondefault_domain_partition():
    """Partition on [2, 4) — all sixteen kinds cover the domain contiguously."""
    depth = 3
    N = 2^depth
    tol = HiR(10)^(-10)  # relaxed for float-based partitions
    xs, xw = 2, 2  # domain [2, 4)

    for kind in PARTITION_KINDS:
        part = build_partition(depth, kind=kind, x_start=xs, x_width=xw)
        assert_true(len(part) == N, f"{kind} [2,4): expected {N} cells")
        assert_true(
            abs(part[0]['x_lo'] - HiR(xs)) < tol,
            f"{kind} [2,4): should start at {xs}",
        )
        assert_true(
            abs(part[-1]['x_hi'] - HiR(xs + xw)) < tol,
            f"{kind} [2,4): should end at {xs + xw}",
        )
        for j in range(N - 1):
            assert_true(
                abs(part[j]['x_hi'] - part[j + 1]['x_lo']) < tol,
                f"{kind} [2,4): contiguity gap at j={j}",
            )
        # x_start and x_width stored in rows
        assert_true(
            abs(part[0]['x_start'] - HiR(xs)) < tol,
            f"{kind}: x_start not stored",
        )
        assert_true(
            abs(part[0]['x_width'] - HiR(xw)) < tol,
            f"{kind}: x_width not stored",
        )


def test_nondefault_domain_evaluator():
    """D-candidate and evaluator work on [2, 4) with uniform_x."""
    depth = 3
    xs, xw = 2, 2
    p_num, q_den = 1, 2
    exponent_q = QQ(p_num) / QQ(q_den)
    c0 = default_c0(exponent_q, xw)

    part = build_partition(depth, kind='uniform_x', x_start=xs, x_width=xw)
    for row in part:
        zmin, zmax, worst, ratio, meta = cell_logerr_arb(
            row['plog_lo'], row['plog_hi'], p_num, q_den, c0,
            x_start=xs)
        assert_true(worst >= 0, f"cell {row['index']}: negative worst error")
        assert_true(
            meta['worst_x'] >= xs and meta['worst_x'] <= xs + xw,
            f"cell {row['index']}: worst_x outside domain",
        )


def test_nondefault_domain_minimax():
    """Minimax optimizer converges on [2, 4) with geometric_x."""
    q, depth = 3, 3
    p_num, q_den = 1, 2
    xs, xw = 2, 2

    result = optimize_minimax(
        q, depth, p_num, q_den,
        partition_kind='geometric_x',
        x_start=xs, x_width=xw,
    )
    assert_true(result['converged'], "minimax on [2,4) should converge")
    assert_true(result['worst_err'] > 0, "minimax on [2,4) should have positive error")

    # Free-per-cell bound should also work
    free_worst, _ = free_per_cell_optimum(
        depth, p_num, q_den,
        partition_kind='geometric_x',
        x_start=xs, x_width=xw,
    )
    assert_true(free_worst > 0, "free-per-cell on [2,4) should have positive error")
    assert_true(
        result['worst_err'] >= free_worst - 1e-8,
        "minimax should be >= free-per-cell bound on [2,4)",
    )


def test_float_cells():
    """float_cells returns correct float tuples matching build_partition."""
    depth = 4
    N = 2^depth
    for kind in PARTITION_KINDS:
        cells = float_cells(depth, kind)
        rows = build_partition(depth, kind)
        assert_true(len(cells) == N, "%s: expected %d cells" % (kind, N))
        for j in range(N):
            a, b = cells[j]
            assert_true(isinstance(a, float), "%s cell %d: x_lo not float" % (kind, j))
            assert_true(isinstance(b, float), "%s cell %d: x_hi not float" % (kind, j))
            assert_close(a, float(rows[j]['x_lo']), 1e-12,
                         "%s cell %d: x_lo mismatch" % (kind, j))
            assert_close(b, float(rows[j]['x_hi']), 1e-12,
                         "%s cell %d: x_hi mismatch" % (kind, j))


def test_depth_for_N():
    """depth_for_N inverts 2^depth correctly and rejects non-powers."""
    assert_true(depth_for_N(1) == 0, "depth_for_N(1) should be 0")
    assert_true(depth_for_N(2) == 1, "depth_for_N(2) should be 1")
    assert_true(depth_for_N(64) == 6, "depth_for_N(64) should be 6")
    assert_true(depth_for_N(512) == 9, "depth_for_N(512) should be 9")
    try:
        depth_for_N(100)
        assert_true(False, "depth_for_N(100) should raise ValueError")
    except ValueError:
        pass


def test_partition_zoo():
    """PARTITION_ZOO has 23 entries, all valid kinds, all unique colors."""
    assert_true(len(PARTITION_ZOO) == 23, "PARTITION_ZOO should have 23 entries")
    kinds = [kind for _, _, kind in PARTITION_ZOO]
    colors = [color for _, color, _ in PARTITION_ZOO]
    for kind in kinds:
        assert_true(kind in PARTITION_KINDS,
                    "PARTITION_ZOO kind %s not in PARTITION_KINDS" % kind)
    assert_true(len(set(kinds)) == 23, "PARTITION_ZOO has duplicate kinds")
    assert_true(len(set(colors)) == 23, "PARTITION_ZOO has duplicate colors")


# ── Layer 1: Universal contract harness ──────────────────────────────

EXACT_KINDS = frozenset({
    'ruler_x', 'thuemorse_x', 'stern_brocot_x',
    'minkowski_x', 'farey_rank_x', 'sturmian_x',
})

CURVE_AWARE_KINDS = frozenset({'arc_length_x', 'minimax_chord_x'})

AFFINE_EQUIVARIANT_KINDS = frozenset({
    'uniform_x', 'ruler_x', 'chebyshev_x', 'thuemorse_x', 'stern_brocot_x',
    'random_x', 'golden_x', 'cantor_x', 'farey_rank_x', 'radical_inverse_x',
    'sturmian_x', 'beta_x', 'minkowski_x',
})


def layer1_tolerance(kind):
    """Return the Layer 1 comparison tolerance for a partition kind."""
    return HiR(10)**(-50) if kind in EXACT_KINDS else HiR(10)**(-10)


def check_layer1_contract(depth, kind, tol=None, **kwargs):
    """Run all Layer 1 contract checks on a single partition build.

    Checks: cell count, endpoints, strict monotonicity, contiguity,
    width sum, index/bits agreement, no NaN/inf/zero-width, determinism,
    and row-local field consistency (width_x, plog_lo, plog_hi, width_log).
    """
    import math as _m

    x_start = kwargs.pop('x_start', 1)
    x_width = kwargs.pop('x_width', 1)
    tol = layer1_tolerance(kind) if tol is None else tol

    part = build_partition(depth, kind=kind, x_start=x_start,
                           x_width=x_width, **kwargs)
    N = 2^depth
    a = HiR(x_start)
    w = HiR(x_width)
    tag = f"{kind} depth={depth} [{x_start},{x_start+x_width})"

    # Cell count.
    assert_true(len(part) == N, f"{tag}: expected {N} cells, got {len(part)}")

    # Endpoints.
    assert_true(
        abs(part[0]['x_lo'] - a) < tol,
        f"{tag}: x_lo[0]={float(part[0]['x_lo'])} != x_start={x_start}",
    )
    assert_true(
        abs(part[-1]['x_hi'] - (a + w)) < tol,
        f"{tag}: x_hi[-1]={float(part[-1]['x_hi'])} != x_end={x_start+x_width}",
    )

    width_sum = HiR(0)
    for j, row in enumerate(part):
        # No NaN / inf.
        for field in ('x_lo', 'x_hi', 'width_x', 'width_log', 'plog_lo', 'plog_hi'):
            fv = float(row[field])
            assert_true(_m.isfinite(fv), f"{tag} cell {j}: {field} is {fv}")

        # Strict monotonicity.
        assert_true(
            row['x_lo'] < row['x_hi'],
            f"{tag} cell {j}: x_lo={float(row['x_lo'])} >= x_hi={float(row['x_hi'])}",
        )

        # No zero-width.
        assert_true(
            float(row['width_x']) > 0,
            f"{tag} cell {j}: zero width",
        )

        # Index / bits agreement.
        assert_true(row['index'] == j, f"{tag}: index={row['index']} != j={j}")
        assert_true(
            bits_to_index(row['bits']) == j,
            f"{tag} cell {j}: bits {row['bits']} -> {bits_to_index(row['bits'])}",
        )
        assert_true(len(row['bits']) == depth,
                     f"{tag} cell {j}: bits length {len(row['bits'])} != depth {depth}")

        # Row-local field consistency.
        assert_true(
            abs(row['width_x'] - (row['x_hi'] - row['x_lo'])) < tol,
            f"{tag} cell {j}: width_x inconsistent",
        )
        assert_true(
            abs(row['plog_lo'] - (row['x_lo'] - a)) < tol,
            f"{tag} cell {j}: plog_lo inconsistent",
        )
        assert_true(
            abs(row['plog_hi'] - (row['x_hi'] - a)) < tol,
            f"{tag} cell {j}: plog_hi inconsistent",
        )
        expected_log = row['x_hi'].log() / LN2 - row['x_lo'].log() / LN2
        assert_true(
            abs(row['width_log'] - expected_log) < tol,
            f"{tag} cell {j}: width_log inconsistent",
        )

        # Contiguity (checked against next cell).
        if j < N - 1:
            assert_true(
                abs(row['x_hi'] - part[j + 1]['x_lo']) < tol,
                f"{tag}: contiguity gap at j={j}",
            )

        width_sum += row['width_x']

    # Width sum.
    assert_true(
        abs(width_sum - w) < tol * N,
        f"{tag}: width sum {float(width_sum)} != x_width {float(w)}",
    )

    # Determinism: rebuild and compare.
    part2 = build_partition(depth, kind=kind, x_start=x_start,
                            x_width=x_width, **kwargs)
    det_tol = HiR(0) if kind in EXACT_KINDS else tol
    for j in range(N):
        assert_true(
            abs(part[j]['x_lo'] - part2[j]['x_lo']) <= det_tol
            and abs(part[j]['x_hi'] - part2[j]['x_hi']) <= det_tol,
            f"{tag} cell {j}: non-deterministic",
        )


def test_layer1_all_kinds_default_domain():
    """Layer 1 contract on all 23 kinds, depths 0-6, default domain [1,2)."""
    for kind in PARTITION_KINDS:
        for depth in range(7):
            check_layer1_contract(depth, kind)


def test_layer1_all_kinds_nondefault_domain():
    """Layer 1 contract on all 23 kinds, depths 0-6, domains [2,5) and [0.5,3.5)."""
    for kind in PARTITION_KINDS:
        for depth in range(7):
            check_layer1_contract(depth, kind, x_start=2, x_width=3)
            check_layer1_contract(depth, kind, x_start=QQ(1)/QQ(2), x_width=3)


def test_layer1_affine_equivariance():
    """Affine-equivariant normalized kinds match across domains after rescaling.

    Only tests kinds where boundaries are defined in [0,1] then scaled to
    [a, a+w) — i.e. the normalized breakpoints don't depend on x_start or
    x_width.  Multiplicative kinds (geometric, harmonic, sinusoidal, etc.)
    and curve-aware kinds are excluded.
    """
    depth = 4
    N = 2^depth
    tol = HiR(10)^(-8)

    for kind in AFFINE_EQUIVARIANT_KINDS:
        ref = build_partition(depth, kind=kind, x_start=1, x_width=1)
        alt = build_partition(depth, kind=kind, x_start=3, x_width=7)
        for j in range(N):
            # Normalize both to [0,1).
            ref_lo = (ref[j]['x_lo'] - HiR(1)) / HiR(1)
            ref_hi = (ref[j]['x_hi'] - HiR(1)) / HiR(1)
            alt_lo = (alt[j]['x_lo'] - HiR(3)) / HiR(7)
            alt_hi = (alt[j]['x_hi'] - HiR(3)) / HiR(7)
            assert_true(
                abs(float(alt_lo) - float(ref_lo)) < float(tol),
                f"{kind} cell {j}: affine equivariance failed for x_lo",
            )
            assert_true(
                abs(float(alt_hi) - float(ref_hi)) < float(tol),
                f"{kind} cell {j}: affine equivariance failed for x_hi",
            )


def test_layer4_invalid_inputs():
    """Bad parameters should raise ValueError, not produce NaN or silently corrupt."""
    cases = [
        # (kind, kwargs, expected_exception, label)
        ('uniform_x', dict(depth=-1), ValueError, "negative depth"),
        ('uniform_x', dict(depth=float('nan')), ValueError, "NaN depth"),
        ('uniform_x', dict(depth=float('inf')), ValueError, "inf depth"),
        ('uniform_x', dict(x_width=0), ValueError, "zero x_width"),
        ('uniform_x', dict(x_width=-1), ValueError, "negative x_width"),
        ('uniform_x', dict(x_start=float('nan')), ValueError, "NaN x_start"),
        ('uniform_x', dict(x_start=float('inf')), ValueError, "inf x_start"),
        ('uniform_x', dict(x_width=float('nan')), ValueError, "NaN x_width"),
        ('uniform_x', dict(x_width=float('inf')), ValueError, "inf x_width"),
        ('sinusoidal_x', dict(sin_k=float('inf')), ValueError, "inf sin_k"),
        ('sinusoidal_x', dict(sin_alpha=1.0), ValueError, "sin_alpha = 1.0"),
        ('sinusoidal_x', dict(sin_alpha=1.5), ValueError, "sin_alpha > 1.0"),
        ('sinusoidal_x', dict(sin_alpha=float('inf')), ValueError, "inf sin_alpha"),
        ('thuemorse_x', dict(tm_ratio=float('nan')), ValueError, "NaN tm_ratio"),
        ('random_x', dict(random_seed=float('inf')), ValueError, "inf random_seed"),
        ('dyadic_x', dict(dyadic_res=float('nan')), ValueError, "NaN dyadic_res"),
        ('powerlaw_x', dict(pl_exponent=1.0), ValueError, "pl_exponent = 1.0"),
        ('powerlaw_x', dict(pl_exponent=float('nan')), ValueError, "NaN pl_exponent"),
        ('cantor_x', dict(cantor_levels=float('inf')), ValueError, "inf cantor_levels"),
        ('farey_rank_x', dict(farey_order=0), ValueError, "farey_order = 0"),
        ('farey_rank_x', dict(farey_order=1), ValueError, "farey_order too small"),
        ('farey_rank_x', dict(farey_order=float('inf')), ValueError, "inf farey_order"),
        ('radical_inverse_x', dict(vdc_base=1), ValueError, "vdc_base < 2"),
        ('radical_inverse_x', dict(vdc_base=0), ValueError, "vdc_base = 0"),
        ('radical_inverse_x', dict(vdc_base=float('nan')), ValueError, "NaN vdc_base"),
        ('radical_inverse_x', dict(vdc_base=float('inf')), ValueError, "inf vdc_base"),
        ('sturmian_x', dict(st_alpha=float('nan')), ValueError, "NaN st_alpha"),
        ('sturmian_x', dict(st_phase=float('inf')), ValueError, "inf st_phase"),
        ('sturmian_x', dict(st_ratio=0), ValueError, "st_ratio = 0"),
        ('sturmian_x', dict(st_ratio=-1), ValueError, "st_ratio < 0"),
        ('beta_x', dict(beta_alpha=0), ValueError, "beta_alpha = 0"),
        ('beta_x', dict(beta_beta=-1), ValueError, "beta_beta < 0"),
        ('beta_x', dict(beta_alpha=float('nan')), ValueError, "NaN beta_alpha"),
        ('beta_x', dict(beta_beta=float('inf')), ValueError, "inf beta_beta"),
        ('minimax_chord_x', dict(minimax_tol=0), ValueError, "minimax_tol = 0"),
        ('minimax_chord_x', dict(minimax_tol=-1e-6), ValueError, "minimax_tol < 0"),
        ('minimax_chord_x', dict(minimax_tol=float('inf')), ValueError, "inf minimax_tol"),
    ]

    for kind, kw, expected_exception, label in cases:
        depth = kw.pop('depth', 2)
        x_start = kw.pop('x_start', 1)
        x_width = kw.pop('x_width', 1)
        try:
            build_partition(depth, kind=kind, x_start=x_start, x_width=x_width, **kw)
            assert_true(False, f"layer4 {label}: should have raised {expected_exception.__name__}")
        except expected_exception:
            pass


# ── Phase 2: Layer 3 collapses, equivalences, parameter relations ────


def test_minkowski_equals_stern_brocot():
    """Minkowski and Stern-Brocot produce identical QQ boundaries (depths 1-5)."""
    for depth in range(1, 6):
        mk = build_partition(depth, kind='minkowski_x')
        sb = build_partition(depth, kind='stern_brocot_x')
        N = 2**depth
        for j in range(N):
            assert_true(
                mk[j]['x_lo'] == sb[j]['x_lo'],
                f"depth={depth} cell {j}: minkowski x_lo != stern_brocot x_lo "
                f"({float(mk[j]['x_lo'])} vs {float(sb[j]['x_lo'])})",
            )
            assert_true(
                mk[j]['x_hi'] == sb[j]['x_hi'],
                f"depth={depth} cell {j}: minkowski x_hi != stern_brocot x_hi "
                f"({float(mk[j]['x_hi'])} vs {float(sb[j]['x_hi'])})",
            )
    # Also verify on a non-default domain.
    for depth in range(1, 4):
        mk = build_partition(depth, kind='minkowski_x', x_start=2, x_width=5)
        sb = build_partition(depth, kind='stern_brocot_x', x_start=2, x_width=5)
        N = 2**depth
        for j in range(N):
            assert_true(
                mk[j]['x_lo'] == sb[j]['x_lo'],
                f"depth={depth} [2,7) cell {j}: minkowski x_lo != stern_brocot x_lo",
            )


def test_radical_inverse_base2_equals_uniform():
    """radical_inverse_x(vdc_base=2) should match uniform_x (depths 1-5)."""
    tol = HiR(10)**(-10)
    for depth in range(1, 6):
        ri = build_partition(depth, kind='radical_inverse_x', vdc_base=2)
        uf = build_partition(depth, kind='uniform_x')
        N = 2**depth
        for j in range(N):
            assert_close(
                ri[j]['x_lo'], uf[j]['x_lo'], tol,
                f"depth={depth} cell {j}: radical_inverse(base=2) x_lo != uniform x_lo",
            )
            assert_close(
                ri[j]['x_hi'], uf[j]['x_hi'], tol,
                f"depth={depth} cell {j}: radical_inverse(base=2) x_hi != uniform x_hi",
            )


def test_sturmian_ratio1_equals_uniform():
    """sturmian_x(st_ratio=1) collapses to uniform_x regardless of alpha/phase."""
    import math
    tol = HiR(10)**(-10)
    combos = [
        dict(st_alpha=(math.sqrt(5) - 1) / 2, st_phase=0.0),
        dict(st_alpha=math.sqrt(2) - 1, st_phase=0.0),
        dict(st_alpha=(math.sqrt(5) - 1) / 2, st_phase=0.3),
        dict(st_alpha=math.pi - 3, st_phase=0.7),
    ]
    for depth in range(1, 5):
        uf = build_partition(depth, kind='uniform_x')
        N = 2**depth
        for kw in combos:
            st = build_partition(depth, kind='sturmian_x', st_ratio=1, **kw)
            for j in range(N):
                assert_close(
                    st[j]['x_lo'], uf[j]['x_lo'], tol,
                    f"depth={depth} st_ratio=1 alpha={kw['st_alpha']:.4f}: "
                    f"cell {j} x_lo mismatch",
                )


def test_beta_uniform_collapse():
    """Beta(1, 1) approx uniform_x (CDF is identity; bisection tolerance only)."""
    tol = HiR(10)**(-8)
    for depth in range(1, 5):
        bt = build_partition(depth, kind='beta_x', beta_alpha=1.0, beta_beta=1.0)
        uf = build_partition(depth, kind='uniform_x')
        N = 2**depth
        for j in range(N):
            assert_close(
                bt[j]['x_lo'], uf[j]['x_lo'], tol,
                f"depth={depth} cell {j}: Beta(1,1) x_lo != uniform x_lo",
            )


def test_beta_swap_symmetry():
    """Beta(a,b) and Beta(b,a) boundaries satisfy b_j + b'_{N-j} = 2*x_start + x_width."""
    tol = HiR(10)**(-8)
    test_params = [(2.0, 5.0), (0.5, 3.0)]
    for depth in range(1, 5):
        N = 2**depth
        for ba, bb in test_params:
            fwd = build_partition(depth, kind='beta_x', beta_alpha=ba, beta_beta=bb)
            rev = build_partition(depth, kind='beta_x', beta_alpha=bb, beta_beta=ba)
            a = fwd[0]['x_start']
            w = fwd[0]['x_width']
            target = HiR(2) * a + w
            # Extract boundary arrays: b_0 .. b_N.
            fwd_b = [fwd[j]['x_lo'] for j in range(N)] + [fwd[N - 1]['x_hi']]
            rev_b = [rev[j]['x_lo'] for j in range(N)] + [rev[N - 1]['x_hi']]
            for j in range(N + 1):
                assert_close(
                    fwd_b[j] + rev_b[N - j], target, tol,
                    f"depth={depth} Beta({ba},{bb}) j={j}: swap symmetry violated",
                )


def test_minimax_chord_refinement():
    """Equalized error at depth d+1 <= error at depth d, strict for d <= 4."""
    import math
    ln2 = math.log(2.0)

    def cell_max_chord_error(x_lo_f, x_hi_f):
        """Independently compute max |chord - curve| for c(x) = 1/(x ln 2) - 1."""
        c_lo = 1.0 / (x_lo_f * ln2) - 1.0
        c_hi = 1.0 / (x_hi_f * ln2) - 1.0
        slope = (c_hi - c_lo) / (x_hi_f - x_lo_f)
        if slope >= 0:
            return 0.0
        x_crit = math.sqrt(-1.0 / (slope * ln2))
        if x_crit <= x_lo_f or x_crit >= x_hi_f:
            return 0.0
        chord_val = c_lo + slope * (x_crit - x_lo_f)
        curve_val = 1.0 / (x_crit * ln2) - 1.0
        return abs(chord_val - curve_val)

    prev_max_err = None
    for depth in range(1, 7):
        part = build_partition(depth, kind='minimax_chord_x')
        N = 2**depth
        errors = [cell_max_chord_error(float(part[j]['x_lo']),
                                        float(part[j]['x_hi']))
                  for j in range(N)]
        max_err = max(errors)
        if prev_max_err is not None:
            assert_true(
                max_err <= prev_max_err * (1 + 1e-10),
                f"depth={depth}: minimax error {max_err:.6e} > previous {prev_max_err:.6e}",
            )
            if depth <= 4:
                assert_true(
                    max_err < prev_max_err * 0.99,
                    f"depth={depth}: minimax error did not strictly decrease "
                    f"({max_err:.6e} vs {prev_max_err:.6e})",
                )
        prev_max_err = max_err


def test_dyadic_snapping_low_res():
    """At dyadic_res=2, low depths are valid but depth=3 produces snapping collisions."""
    # Safe: depth=1 and depth=2 pass Layer 1 contract.
    check_layer1_contract(1, 'dyadic_x', dyadic_res=2)
    check_layer1_contract(2, 'dyadic_x', dyadic_res=2)
    # Unsafe: depth=3 at dyadic_res=2 — geometric targets snap to same dyadic
    # rational, producing zero-width cells.
    part = build_partition(3, kind='dyadic_x', dyadic_res=2)
    has_collision = any(float(part[j]['width_x']) <= 0 for j in range(len(part)))
    assert_true(has_collision,
                "depth=3 dyadic_res=2: expected snapping collision (zero-width cell)")


def test_sinusoidal_amplitude_sweep():
    """Forward law F(t_j) = j/N holds at alpha approaching the monotonicity threshold."""
    import math
    alphas = [0.8, 0.9, 0.95, 0.99]
    depth = 3
    N = 2**depth
    sin_k = 3

    for alpha in alphas:
        # Verify Layer 1 contract still holds.
        check_layer1_contract(depth, 'sinusoidal_x', sin_alpha=alpha, sin_k=sin_k)

        # Verify forward law: F(t_j) approx j/N where t = log(x/a)/log(r).
        part = build_partition(depth, kind='sinusoidal_x',
                               sin_alpha=alpha, sin_k=sin_k)
        a_f = float(part[0]['x_start'])
        x_end_f = a_f + float(part[0]['x_width'])
        r = x_end_f / a_f
        twopik = 2.0 * math.pi * sin_k
        coeff = alpha / twopik

        def F(t):
            return t - coeff * math.sin(twopik * t)

        # Tolerance degrades as alpha -> 1.
        tol = 1e-8 if alpha < 0.95 else 1e-6

        for j in range(N + 1):
            if j == 0:
                b = float(part[0]['x_lo'])
            elif j == N:
                b = float(part[N - 1]['x_hi'])
            else:
                b = float(part[j]['x_lo'])
            t = math.log(b / a_f) / math.log(r)
            target = j / N
            assert_true(
                abs(F(t) - target) < tol,
                f"sinusoidal alpha={alpha} j={j}: F(t)={F(t):.10f} != {target}, "
                f"gap={abs(F(t) - target):.2e}, tol={tol}",
            )

def test_sturmian_phase_variation():
    """Varying phase preserves two-width alphabet; long-cell count changes by at most 1."""
    import math
    st_alpha = (math.sqrt(5) - 1) / 2
    phases = [0.0, 0.1, 0.25, 0.5, 0.7, 0.99]
    for depth in range(2, 6):
        N = 2**depth
        long_counts = []
        for phase in phases:
            part = build_partition(depth, kind='sturmian_x',
                                   st_alpha=st_alpha, st_phase=phase)
            widths = [float(part[j]['width_x']) for j in range(N)]
            unique_widths = sorted(set(round(w, 10) for w in widths))
            assert_true(
                len(unique_widths) == 2,
                f"depth={depth} phase={phase}: expected 2 width classes, "
                f"got {len(unique_widths)}: {unique_widths}",
            )
            thresh = (unique_widths[0] + unique_widths[1]) / 2.0
            long_count = sum(1 for w in widths if w > thresh)
            long_counts.append(long_count)
        # Long-cell count should vary by at most 1 across all phases.
        assert_true(
            max(long_counts) - min(long_counts) <= 1,
            f"depth={depth}: long-cell count varies by more than 1 "
            f"across phases: {long_counts}",
        )


# ── Phase 3: Layer 2 independent forward evaluators ──────────────────


def _forward_beta_cdf(x, alpha, beta):
    """Return Beta(alpha, beta) CDF at x.

    Use mpmath.betainc or scipy.stats.beta.cdf — NOT the same bisection
    inversion used by _beta_boundaries.

    Input:  x in [0, 1], alpha > 0, beta > 0.
    Output: float in [0, 1].
    """
    if x <= 0:
        return 0.0
    if x >= 1:
        return 1.0
    try:
        from scipy.stats import beta as scipy_beta

        return float(scipy_beta.cdf(float(x), float(alpha), float(beta)))
    except ImportError:
        from mpmath import betainc, mp

        with mp.workdps(80):
            x_mp = mp.mpf(repr(x))
            alpha_mp = mp.mpf(repr(alpha))
            beta_mp = mp.mpf(repr(beta))
            return float(betainc(alpha_mp, beta_mp, 0, x_mp, regularized=True))


def _slow_beta_quantile(p, alpha, beta):
    """Slow inverse Beta CDF via quadrature plus bisection.

    This preserves the original production algorithm as an adversarial
    reference path for Beta regression checks.
    """
    from sage.all import numerical_integral

    if p <= 0:
        return 0.0
    if p >= 1:
        return 1.0
    ba = float(alpha)
    bb = float(beta)

    def integrand(u):
        return u**(ba - 1.0) * (1.0 - u)**(bb - 1.0)

    total, _ = numerical_integral(integrand, 0.0, 1.0)
    target = float(p) * total
    lo, hi = 0.0, 1.0
    for _ in range(60):
        mid = (lo + hi) / 2.0
        val, _ = numerical_integral(integrand, 0.0, mid)
        if val < target:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2.0


def _forward_arc_length(x_lo, x_hi):
    """Return arc length of f(x) = 1/(x ln 2) from x_lo to x_hi.

    Integrand: sqrt(1 + 1/(x^4 (ln 2)^2)).
    Use mpmath.quad or sage numerical_integral — NOT the same call site
    as _arc_length_boundaries.

    Input:  0 < x_lo < x_hi.
    Output: positive float.
    """
    from mpmath import mp, quad, sqrt

    with mp.workdps(80):
        x_lo_mp = mp.mpf(repr(x_lo))
        x_hi_mp = mp.mpf(repr(x_hi))
        ln2 = mp.log(2)

        def ds(x):
            return sqrt(1 + 1 / (x**4 * ln2**2))

        return float(quad(ds, [x_lo_mp, x_hi_mp]))


def _forward_chord_error(x_lo, x_hi):
    """Return max |chord(x) - curve(x)| for curve c(x) = 1/(x ln 2) - 1
    on [x_lo, x_hi].

    Chord is linear interpolation of c at endpoints.
    c is convex, so the chord lies above the curve.
    Critical point where tangent parallels chord:
        c'(x_crit) = slope  =>  x_crit = sqrt(-1 / (slope * ln 2)).
    Max error = chord(x_crit) - c(x_crit).

    Input:  0 < x_lo < x_hi.
    Output: non-negative float.
    """
    import math

    ln2 = math.log(2.0)

    def curve(x):
        return 1.0 / (x * ln2) - 1.0

    c_lo = curve(x_lo)
    c_hi = curve(x_hi)
    slope = (c_hi - c_lo) / (x_hi - x_lo)
    x_crit = math.sqrt(-1.0 / (slope * ln2))
    x_crit = min(max(x_crit, x_lo), x_hi)
    chord_at_crit = c_lo + slope * (x_crit - x_lo)
    return max(0.0, chord_at_crit - curve(x_crit))


def _forward_van_der_corput(k, base):
    """Return the radical inverse of integer k in the given base.

    Uses exact rational (QQ) arithmetic to accumulate the digit-reversed
    fraction, avoiding any floating-point ordering or rounding issues.
    The production code (_radical_inverse_boundaries) uses float accumulation;
    this QQ path catches any float-precision divergence.

    Example: k=5, base=3: 5 in base 3 is '12', reversed '21',
    so result = 2/3 + 1/9 = 7/9.

    Input:  k >= 1, base >= 2.
    Output: float in (0, 1).
    """
    b = int(base)
    n = int(k)
    result = QQ(0)
    place = QQ(1)
    while n > 0:
        n, digit = divmod(n, b)
        place /= b
        result += digit * place
    return float(result)


def _forward_farey(Q):
    """Return sorted Farey sequence F_Q in [0, 1] as list of QQ.

    Uses the classical next-term recurrence (mediant-based):
    given consecutive Farey neighbours a/b, c/d, the next term after
    c/d is  (k*c - a) / (k*d - b)  where k = floor((b + Q) / d).

    This is algorithmically independent from the brute-force enumeration
    used by _farey_rank_boundaries (which iterates all p/q pairs and
    deduplicates via a set of QQ).

    Input:  Q >= 1.
    Output: sorted list of QQ values in [0, 1].
    """
    Q_int = int(Q)
    # Seed: F_Q always starts with 0/1 and 1/Q.
    result = [QQ(0)]
    a, b = 0, 1
    c, d = 1, Q_int
    while c <= Q_int:
        result.append(QQ(c) / QQ(d))
        k = (Q_int + b) // d
        a, b, c, d = c, d, k * c - a, k * d - b
    return result


def _forward_sturmian_word(N, alpha, phase):
    """Return length-N binary word from irrational rotation.

    Uses the interval-membership characterization: s_j = 1 iff the
    orbit point {j*alpha + phase} falls in [1 - alpha, 1), where {x}
    is the fractional part.  This is mathematically equivalent to the
    floor-difference formula used by _sturmian_binary_boundaries but
    computationally independent — an off-by-one in floor subtraction
    would not affect the interval test, and vice versa.

    Uses mpmath at 80-digit precision to avoid float64 rounding near
    rational alpha values.

    Input:  N >= 1, alpha irrational (float), phase real (float).
    Output: list of N ints, each 0 or 1.
    """
    from mpmath import mp, frac

    with mp.workdps(80):
        # Convert to Python float first to avoid Sage RealNumber repr issues.
        alpha_mp = mp.mpf(float(alpha))
        if alpha_mp < 0:
            alpha_mp += 1
        phase_mp = mp.mpf(float(phase))
        threshold = 1 - alpha_mp
        word = []
        for j in range(int(N)):
            orbit = frac(j * alpha_mp + phase_mp)
            word.append(1 if orbit >= threshold else 0)
        return word


# ── Phase 3: Layer 2 test functions ──────────────────────────────────


def test_forward_beta_cdf():
    """Build beta_x, apply independent CDF to normalized boundaries, assert = j/N."""
    tol_cdf = 1e-6
    for depth in range(1, 5):
        for ba, bb in [(5.0, 2.0), (2.0, 5.0), (0.5, 0.5)]:
            part = build_partition(depth, kind='beta_x',
                                   beta_alpha=ba, beta_beta=bb)
            N = 2**depth
            a_f = float(part[0]['x_start'])
            w_f = float(part[0]['x_width'])
            for j in range(N + 1):
                if j < N:
                    b = float(part[j]['x_lo'])
                else:
                    b = float(part[N - 1]['x_hi'])
                t = (b - a_f) / w_f
                cdf_val = _forward_beta_cdf(t, ba, bb)
                target = j / N
                assert_true(
                    abs(cdf_val - target) < tol_cdf,
                    f"beta_cdf depth={depth} Beta({ba},{bb}) j={j}: "
                    f"CDF({t:.6f})={cdf_val:.8f} != {target}",
                )


def test_beta_library_matches_slow_reference():
    """Compare SciPy beta_x boundaries against the old slow inverse-CDF path."""
    tol = 1e-7
    cases = [
        (3, 5.0, 2.0, (1, 4, 7)),
        (3, 0.5, 0.5, (1, 4, 7)),
        (3, 100.0, 1.0, (1, 4, 7)),
    ]
    for depth, ba, bb, js in cases:
        part = build_partition(depth, kind='beta_x',
                               beta_alpha=ba, beta_beta=bb)
        N = 2**depth
        a_f = float(part[0]['x_start'])
        w_f = float(part[0]['x_width'])
        for j in js:
            got = float(part[j]['x_lo'])
            expected = a_f + w_f * _slow_beta_quantile(j / N, ba, bb)
            assert_true(
                abs(got - expected) < tol,
                f"beta slow ref depth={depth} Beta({ba},{bb}) j={j}: "
                f"got {got:.10f} != expected {expected:.10f}",
            )


def test_forward_arc_length():
    """Build arc_length_x, compute independent arc-length increments, assert equal."""
    for depth in range(1, 5):
        part = build_partition(depth, kind='arc_length_x')
        N = 2**depth
        increments = []
        for j in range(N):
            inc = _forward_arc_length(float(part[j]['x_lo']),
                                       float(part[j]['x_hi']))
            increments.append(inc)
        mean_inc = sum(increments) / len(increments)
        tol = mean_inc * 1e-6
        for j, inc in enumerate(increments):
            assert_true(
                abs(inc - mean_inc) < tol,
                f"arc_length depth={depth} cell {j}: "
                f"increment {inc:.10f} != mean {mean_inc:.10f}",
            )


def test_forward_minimax_equalization():
    """Build minimax_chord_x, compute per-cell peak chord error, assert equalized."""
    for depth in range(1, 5):
        part = build_partition(depth, kind='minimax_chord_x')
        N = 2**depth
        errors = []
        for j in range(N):
            err = _forward_chord_error(float(part[j]['x_lo']),
                                        float(part[j]['x_hi']))
            errors.append(err)
        mean_err = sum(errors) / len(errors)
        tol = mean_err * 1e-6
        for j, err in enumerate(errors):
            assert_true(
                abs(err - mean_err) < tol,
                f"minimax equalization depth={depth} cell {j}: "
                f"error {err:.8e} != mean {mean_err:.8e}",
            )


def test_forward_minimax_local_optimality():
    """Perturb each interior breakpoint by +/-eps, verify worst-case error does not improve."""
    for depth in range(1, 4):
        part = build_partition(depth, kind='minimax_chord_x')
        N = 2**depth
        # Extract float boundary array b_0 .. b_N.
        bdry = [float(part[j]['x_lo']) for j in range(N)] + \
               [float(part[N - 1]['x_hi'])]
        # Baseline worst-case error.
        baseline = max(_forward_chord_error(bdry[j], bdry[j + 1])
                       for j in range(N))
        # Perturb each interior boundary.
        eps = 1e-8
        for i in range(1, N):
            for sign in [-1, +1]:
                perturbed = list(bdry)
                perturbed[i] += sign * eps
                if perturbed[i] <= perturbed[i - 1] or \
                   perturbed[i] >= perturbed[i + 1]:
                    continue
                worst = max(_forward_chord_error(perturbed[j], perturbed[j + 1])
                            for j in range(N))
                assert_true(
                    worst >= baseline * (1 - 1e-4),
                    f"minimax local opt depth={depth} bdry {i} sign={sign}: "
                    f"perturbed worst {worst:.8e} < baseline {baseline:.8e}",
                )


def test_forward_farey_rank():
    """Build farey_rank_x, verify boundaries against independent Farey sequence."""
    for depth in range(1, 5):
        N = 2**depth
        part = build_partition(depth, kind='farey_rank_x')
        a = part[0]['x_start']
        w = part[0]['x_width']
        # Find minimal Q such that |F_Q| >= N+1.
        Q = 1
        while True:
            fseq = _forward_farey(Q)
            if len(fseq) >= N + 1:
                break
            Q += 1
        # Verify Q minimality: F_{Q-1} should have too few members.
        if Q > 1:
            fseq_prev = _forward_farey(Q - 1)
            assert_true(
                len(fseq_prev) < N + 1,
                f"depth={depth}: F_{Q-1} has {len(fseq_prev)} >= {N+1}, "
                f"Q={Q} not minimal",
            )
        # Subsample fseq at equally-spaced ranks.
        M = len(fseq) - 1
        expected_norm = [fseq[int(j * M) // int(N)] for j in range(N + 1)]
        # Compare boundaries.
        tol = HiR(10)**(-10)
        for j in range(N + 1):
            if j < N:
                b = part[j]['x_lo']
            else:
                b = part[N - 1]['x_hi']
            expected_val = a + w * HiR(expected_norm[j])
            assert_close(
                b, expected_val, tol,
                f"farey_rank depth={depth} j={j}: boundary mismatch",
            )


def test_forward_sturmian_word():
    """Build sturmian_x, reconstruct binary word, check alphabet/count/balancedness."""
    import math
    st_alpha = (math.sqrt(5) - 1) / 2  # golden ratio conjugate
    for depth in range(1, 6):
        N = 2**depth
        for st_phase in [0.0, 0.3]:
            part = build_partition(depth, kind='sturmian_x',
                                   st_alpha=st_alpha, st_phase=st_phase)
            # Get independent word from stub.
            # Use Python float() and int mod to avoid Sage RealNumber %
            # coercion (Sage's 1.0 is a RealNumber; float % RealNumber
            # can produce negative results).
            alpha_f = float(st_alpha)
            alpha_mod = alpha_f - int(alpha_f)  # fractional part, always >= 0
            word = _forward_sturmian_word(N, alpha_mod, float(st_phase))
            assert_true(len(word) == N,
                        f"sturmian word length {len(word)} != {N}")
            # Check two-class alphabet from widths.
            widths = [float(part[j]['width_x']) for j in range(N)]
            w_min, w_max = min(widths), max(widths)
            assert_true(
                w_max - w_min > 1e-14 or N == 1,
                f"depth={depth}: single width class (widths indistinguishable)",
            )
            # Reconstruct binary word: 1 = long (above threshold).
            thresh = (w_min + w_max) / 2.0
            reconstructed = [1 if w > thresh else 0 for w in widths]
            # 1-count should match forward word.
            assert_true(
                sum(reconstructed) == sum(word),
                f"depth={depth} phase={st_phase}: 1-count {sum(reconstructed)} "
                f"!= forward {sum(word)}",
            )
            # Balancedness: any two substrings of same length differ
            # in 1-count by at most 1.  Restrict to depth <= 5.
            if depth <= 5:
                for L in range(1, N + 1):
                    counts = [sum(word[i:i + L])
                              for i in range(N - L + 1)]
                    assert_true(
                        max(counts) - min(counts) <= 1,
                        f"depth={depth} phase={st_phase}: "
                        f"balancedness violated at substring length {L}",
                    )


def test_forward_radical_inverse():
    """Build radical_inverse_x(base=3), verify against independent VdC computation."""
    tol = HiR(10)**(-10)
    for depth in range(1, 5):
        N = 2**depth
        part = build_partition(depth, kind='radical_inverse_x', vdc_base=3)
        a = part[0]['x_start']
        w = part[0]['x_width']
        a_f = float(a)
        w_f = float(w)
        # Independently compute sorted VdC sequence in base 3.
        vdc_points = sorted([_forward_van_der_corput(k, 3)
                             for k in range(1, N)])
        # Compare interior boundaries (j=1..N-1) plus endpoints.
        for j in range(N + 1):
            if j < N:
                b = part[j]['x_lo']
            else:
                b = part[N - 1]['x_hi']
            if j == 0:
                expected = a
            elif j == N:
                expected = a + w
            else:
                expected = HiR(a_f + w_f * vdc_points[j - 1])
            assert_close(
                b, expected, tol,
                f"radical_inverse(base=3) depth={depth} j={j}: boundary mismatch",
            )


# ── Phase 3: Layer 2 stress tests ───────────────────────────────────


def test_stress_sinusoidal_alpha_099():
    """sinusoidal_x at alpha=0.99 depth=5: barely monotone F(t)."""
    import math
    depth = 5
    N = 2**depth
    alpha = 0.99
    sin_k = 3
    check_layer1_contract(depth, 'sinusoidal_x', sin_alpha=alpha, sin_k=sin_k)
    # Inline forward-law check (no stub needed — F is a closed-form formula).
    part = build_partition(depth, kind='sinusoidal_x',
                           sin_alpha=alpha, sin_k=sin_k)
    a_f = float(part[0]['x_start'])
    x_end_f = a_f + float(part[0]['x_width'])
    r = x_end_f / a_f
    twopik = 2.0 * math.pi * sin_k
    coeff = alpha / twopik

    def F(t):
        return t - coeff * math.sin(twopik * t)

    tol = 1e-4  # Relaxed: near-threshold alpha at high depth.
    for j in range(N + 1):
        if j == 0:
            b = float(part[0]['x_lo'])
        elif j == N:
            b = float(part[N - 1]['x_hi'])
        else:
            b = float(part[j]['x_lo'])
        t = math.log(b / a_f) / math.log(r)
        target = float(j) / float(N)
        assert_true(
            abs(F(t) - target) < tol,
            f"stress sinusoidal alpha=0.99 depth=5 j={j}: "
            f"F(t)={F(t):.8f} != {target:.8f}",
        )


def test_stress_powerlaw_near_one():
    """powerlaw_x at pl_exponent=1.001: ill-conditioned CDF inversion."""
    depth = 4
    check_layer1_contract(depth, 'powerlaw_x', pl_exponent=1.001)
    part = build_partition(depth, kind='powerlaw_x', pl_exponent=1.001)
    N = 2**depth
    # Density should still pack left: first cell narrower than last.
    assert_true(
        float(part[0]['width_x']) < float(part[N - 1]['width_x']),
        "powerlaw pl_exponent=1.001: first cell should be narrower than last",
    )


def test_stress_beta_extreme():
    """beta_x with extreme shapes: Beta(0.5,0.5) U-shaped and Beta(100,1) rightward."""
    tol_cdf = 1e-4
    # U-shaped density: cells pack at both endpoints.
    check_layer1_contract(3, 'beta_x', beta_alpha=0.5, beta_beta=0.5)
    part_u = build_partition(3, kind='beta_x', beta_alpha=0.5, beta_beta=0.5)
    N = 2**3
    a_f = float(part_u[0]['x_start'])
    w_f = float(part_u[0]['x_width'])
    for j in range(N + 1):
        if j < N:
            b = float(part_u[j]['x_lo'])
        else:
            b = float(part_u[N - 1]['x_hi'])
        t = (b - a_f) / w_f
        cdf_val = _forward_beta_cdf(t, 0.5, 0.5)
        assert_true(
            abs(cdf_val - j / N) < tol_cdf,
            f"Beta(0.5,0.5) j={j}: CDF({t:.6f})={cdf_val:.6f} != {j/N}",
        )
    # Extreme rightward skew.
    check_layer1_contract(3, 'beta_x', beta_alpha=100, beta_beta=1)
    part_r = build_partition(3, kind='beta_x', beta_alpha=100, beta_beta=1)
    a_f2 = float(part_r[0]['x_start'])
    w_f2 = float(part_r[0]['x_width'])
    for j in range(N + 1):
        if j < N:
            b = float(part_r[j]['x_lo'])
        else:
            b = float(part_r[N - 1]['x_hi'])
        t = (b - a_f2) / w_f2
        cdf_val = _forward_beta_cdf(t, 100, 1)
        assert_true(
            abs(cdf_val - j / N) < tol_cdf,
            f"Beta(100,1) j={j}: CDF({t:.6f})={cdf_val:.6f} != {j/N}",
        )


def test_stress_cantor_low_n():
    """cantor_x depth=2 cantor_levels=3: valid partition with Cantor-endpoint boundaries."""
    depth = 2
    cantor_levels = 3
    check_layer1_contract(depth, 'cantor_x', cantor_levels=cantor_levels)
    part = build_partition(depth, kind='cantor_x', cantor_levels=cantor_levels)
    N = 2**depth
    a_f = float(part[0]['x_start'])
    w_f = float(part[0]['x_width'])
    # Build Cantor dust interval endpoints independently.
    intervals = [(0.0, 1.0)]
    for _ in range(cantor_levels):
        new = []
        for lo, hi in intervals:
            third = (hi - lo) / 3.0
            new.append((lo, lo + third))
            new.append((hi - third, hi))
        intervals = new
    # Collect all Cantor-interval endpoints as valid boundary positions.
    endpoints = set()
    for lo, hi in intervals:
        endpoints.add(round(lo, 12))
        endpoints.add(round(hi, 12))
    endpoints.add(0.0)
    endpoints.add(1.0)
    # Each interior boundary should land on a Cantor-interval endpoint.
    # (When N < 2^cantor_levels, cells span gaps between intervals,
    # but boundaries still align with interval edges.)
    for j in range(1, N):
        b_norm = round((float(part[j]['x_lo']) - a_f) / w_f, 12)
        assert_true(
            b_norm in endpoints,
            f"cantor cell {j}: boundary {b_norm:.8f} not a "
            f"Cantor-interval endpoint",
        )


def test_stress_sturmian_near_rational():
    """sturmian_x with alpha near rational: partition valid, two width classes."""
    depth = 4
    N = 2**depth
    alpha = 1.5 + 1e-15  # Near 3/2; after mod 1 -> near 1/2.
    check_layer1_contract(depth, 'sturmian_x', st_alpha=alpha)
    part = build_partition(depth, kind='sturmian_x', st_alpha=alpha)
    widths = [float(part[j]['width_x']) for j in range(N)]
    unique_widths = sorted(set(round(w, 8) for w in widths))
    assert_true(
        len(unique_widths) <= 2,
        f"sturmian near-rational: expected <= 2 width classes, "
        f"got {len(unique_widths)}: {unique_widths}",
    )


def test_stress_arc_length_depth1():
    """arc_length_x depth=1: single interior boundary left of center."""
    check_layer1_contract(1, 'arc_length_x')
    part = build_partition(1, kind='arc_length_x')
    bdry_mid = float(part[0]['x_hi'])
    a_f = float(part[0]['x_start'])
    xe_f = a_f + float(part[0]['x_width'])
    domain_mid = (a_f + xe_f) / 2.0
    # Curvature higher near x_start => equal arc length places split
    # left of domain center.
    assert_true(
        bdry_mid < domain_mid,
        f"arc_length depth=1: boundary {bdry_mid:.6f} should be "
        f"< midpoint {domain_mid:.6f}",
    )
    # Boundary strictly in interior.
    assert_true(
        bdry_mid > a_f + 1e-10 and bdry_mid < xe_f - 1e-10,
        f"arc_length depth=1: boundary {bdry_mid:.6f} too close to endpoint",
    )
    # Forward law: both cells should have equal arc length.
    inc1 = _forward_arc_length(a_f, bdry_mid)
    inc2 = _forward_arc_length(bdry_mid, xe_f)
    tol = max(inc1, inc2) * 1e-4
    assert_close(
        HiR(inc1), HiR(inc2), HiR(tol),
        f"arc_length depth=1: unequal increments {inc1:.8f} vs {inc2:.8f}",
    )


def main():
    tests = [
        ("bits_index_roundtrip", test_bits_index_roundtrip),
        ("uniform_x_partition", test_uniform_x_partition),
        ("geometric_x_partition", test_geometric_x_partition),
        ("partition_row_map", test_partition_row_map),
        ("uniform_x_matches_dyadic", test_uniform_x_matches_dyadic),
        ("arb_evaluator_oracle_d3", test_arb_evaluator_oracle_d3),
        ("arb_evaluator_oracle_d5", test_arb_evaluator_oracle_d5),
        ("arb_evaluator_oracle_varied_c", test_arb_evaluator_oracle_varied_c),
        ("d_candidate_validity", test_d_candidate_validity),
        ("arb_evaluator_geometric_smoke", test_arb_evaluator_geometric_smoke),
        ("arb_concavity_boundary_min", test_arb_concavity_boundary_min),
        ("arb_meta_reports_x_and_plog", test_arb_meta_reports_x_and_plog),
        ("minimax_uniform_x_partition", test_minimax_uniform_x_partition),
        ("minimax_geometric_x_smoke", test_minimax_geometric_x_smoke),
        ("harmonic_x_partition", test_harmonic_x_partition),
        ("mirror_harmonic_x_partition", test_mirror_harmonic_x_partition),
        ("minimax_harmonic_x_smoke", test_minimax_harmonic_x_smoke),
        ("minimax_mirror_harmonic_x_smoke", test_minimax_mirror_harmonic_x_smoke),
        ("ruler_x_partition", test_ruler_x_partition),
        ("sinusoidal_x_partition", test_sinusoidal_x_partition),
        ("minimax_ruler_x_smoke", test_minimax_ruler_x_smoke),
        ("minimax_sinusoidal_x_smoke", test_minimax_sinusoidal_x_smoke),
        ("chebyshev_x_partition", test_chebyshev_x_partition),
        ("minimax_chebyshev_x_smoke", test_minimax_chebyshev_x_smoke),
        ("thuemorse_x_partition", test_thuemorse_x_partition),
        ("minimax_thuemorse_x_smoke", test_minimax_thuemorse_x_smoke),
        ("bitrev_geometric_x_partition", test_bitrev_geometric_x_partition),
        ("minimax_bitrev_geometric_x_smoke", test_minimax_bitrev_geometric_x_smoke),
        ("stern_brocot_x_partition", test_stern_brocot_x_partition),
        ("minimax_stern_brocot_x_smoke", test_minimax_stern_brocot_x_smoke),
        ("reverse_geometric_x_partition", test_reverse_geometric_x_partition),
        ("minimax_reverse_geometric_x_smoke", test_minimax_reverse_geometric_x_smoke),
        ("random_x_partition", test_random_x_partition),
        ("minimax_random_x_smoke", test_minimax_random_x_smoke),
        ("dyadic_x_partition", test_dyadic_x_partition),
        ("minimax_dyadic_x_smoke", test_minimax_dyadic_x_smoke),
        ("powerlaw_x_partition", test_powerlaw_x_partition),
        ("minimax_powerlaw_x_smoke", test_minimax_powerlaw_x_smoke),
        ("golden_x_partition", test_golden_x_partition),
        ("minimax_golden_x_smoke", test_minimax_golden_x_smoke),
        ("cantor_x_partition", test_cantor_x_partition),
        ("minimax_cantor_x_smoke", test_minimax_cantor_x_smoke),
        ("geometric_x_above_free_bound", test_geometric_x_above_free_bound),
        ("partition_aware_best_single", test_partition_aware_best_single),
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
        ("nondefault_domain_partition", test_nondefault_domain_partition),
        ("nondefault_domain_evaluator", test_nondefault_domain_evaluator),
        ("nondefault_domain_minimax", test_nondefault_domain_minimax),
        ("float_cells", test_float_cells),
        ("depth_for_N", test_depth_for_N),
        ("partition_zoo", test_partition_zoo),
        ("layer1_all_kinds_default_domain", test_layer1_all_kinds_default_domain),
        ("layer1_all_kinds_nondefault_domain", test_layer1_all_kinds_nondefault_domain),
        ("layer1_affine_equivariance", test_layer1_affine_equivariance),
        ("layer4_invalid_inputs", test_layer4_invalid_inputs),
        ("layer3_minkowski_equals_stern_brocot", test_minkowski_equals_stern_brocot),
        ("layer3_radical_inverse_base2_equals_uniform", test_radical_inverse_base2_equals_uniform),
        ("layer3_sturmian_ratio1_equals_uniform", test_sturmian_ratio1_equals_uniform),
        ("layer3_beta_uniform_collapse", test_beta_uniform_collapse),
        ("layer3_beta_swap_symmetry", test_beta_swap_symmetry),
        ("layer3_minimax_chord_refinement", test_minimax_chord_refinement),
        ("layer3_dyadic_snapping_low_res", test_dyadic_snapping_low_res),
        ("layer3_sinusoidal_amplitude_sweep", test_sinusoidal_amplitude_sweep),
        ("layer3_sturmian_phase_variation", test_sturmian_phase_variation),
    ]

    layer2_tests = [
        ("layer2_forward_beta_cdf", test_forward_beta_cdf),
        ("layer2_beta_library_matches_slow_reference", test_beta_library_matches_slow_reference),
        ("layer2_forward_arc_length", test_forward_arc_length),
        ("layer2_forward_minimax_equalization", test_forward_minimax_equalization),
        ("layer2_forward_minimax_local_optimality", test_forward_minimax_local_optimality),
        ("layer2_forward_farey_rank", test_forward_farey_rank),
        ("layer2_forward_sturmian_word", test_forward_sturmian_word),
        ("layer2_forward_radical_inverse", test_forward_radical_inverse),
        ("layer2_stress_sinusoidal_alpha_099", test_stress_sinusoidal_alpha_099),
        ("layer2_stress_powerlaw_near_one", test_stress_powerlaw_near_one),
        ("layer2_stress_beta_extreme", test_stress_beta_extreme),
        ("layer2_stress_cantor_low_n", test_stress_cantor_low_n),
        ("layer2_stress_sturmian_near_rational", test_stress_sturmian_near_rational),
        ("layer2_stress_arc_length_depth1", test_stress_arc_length_depth1),
    ]

    print("=" * 80)
    print("smale test suite")
    print("=" * 80)

    passed = 0
    for name, fn in tests + layer2_tests:
        try:
            fn()
            print(f"[ok] {name}")
            passed += 1
        except NotImplementedError as exc:
            raise AssertionError(f"{name} unexpectedly raised NotImplementedError") from exc

    print("=" * 80)
    print(f"passed {passed} tests")
    print("=" * 80)


main()
