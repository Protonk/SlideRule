# Grid Presets

Nine preset grid layouts for comparing partition kinds. Each preset assigns
partition kinds to grid cells with a specific comparative narrative.

Machine-readable cell assignments: `distillations/partitions.json` (presets key).
Mathematical classification: `distillations/PARTITIONS.md`.

---

## Preset 1: `geo_vs_elementary` — 3x3, geometric at center

Thesis winner surrounded by naive spacing alternatives and optimization targets.

|   | Col 0 | Col 1 | Col 2 |
|---|-------|-------|-------|
| **R0** | uniform | harmonic | chebyshev |
| **R1** | reverse_geometric | **geometric** | mirror_harmonic |
| **R2** | powerlaw | arc_length | minimax_chord |

**Narrative.** Top row = first ideas a practitioner would try (equal width,
reciprocal spacing, Chebyshev nodes). Middle row = geometric flanked by two
distinct ways to reverse its bias toward `x_start`: reverse_geometric as the
log-space reversal, mirror_harmonic as the reciprocal mirror. Bottom row =
what happens when you optimize harder (power-law cranks density, arc_length
asks the curve, minimax_chord is the theoretical optimum).

---

## Preset 2: `geo_vs_number_theory` — 3x3, geometric at center

Thesis winner surrounded by number-theoretic and hierarchical constructions.

|   | Col 0 | Col 1 | Col 2 |
|---|-------|-------|-------|
| **R0** | stern_brocot | farey_rank | radical_inverse |
| **R1** | golden | **geometric** | sturmian |
| **R2** | minkowski | dyadic | ruler |

**Narrative.** Top row = rational-tree and low-discrepancy schemes (mediants,
Farey ranks, van der Corput). Middle row = irrational-rotation (golden),
log-uniform thesis winner, Sturmian words — a gradient through quasi-random
structures. Bottom row = hierarchical/fractal structure: minkowski (identical
to stern_brocot), dyadic (geometric under quantization), ruler (2-adic
valuation). Contrasts geometric's clean log-uniformity against deep arithmetic
structures.

---

## Preset 3: `geo_vs_chaos` — 3x3, geometric at center

Thesis winner surrounded by fractal, stochastic, and parametric perturbations.

|   | Col 0 | Col 1 | Col 2 |
|---|-------|-------|-------|
| **R0** | thuemorse | cantor | bitrev_geometric |
| **R1** | sinusoidal | **geometric** | beta |
| **R2** | random | dyadic | ruler |

**Narrative.** Top row = internal complexity (Thue-Morse anti-fractal, Cantor
gaps, bit-reversal chaos). Middle row = parametric modulation around geometric
(sinusoidal ripple, the zero-ripple thesis winner, beta shape control). Bottom
row = baselines (stochastic null, quantized geometric, structured 2-adic noise).

---

## Preset 4: `density_gradient` — 4x4, gestalt narrative

Reading order traces density centroid from extreme left-packing to right-packing.

|   | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **R0** | harmonic | powerlaw | minimax_chord | arc_length |
| **R1** | stern_brocot | golden | geometric | chebyshev |
| **R2** | uniform | radical_inverse | sturmian | sinusoidal |
| **R3** | beta | reverse_geometric | mirror_harmonic | random |

**Narrative.** R0 = strongest left-packing (reciprocal, power-law, minimax,
arc-length). R1 = moderate structure trending toward balance. R2 = near-uniform
(flat, low-discrepancy, quasi-uniform, periodic ripple). R3 = right-heavy and
controls. The diagonal traces density centroid migration from upper-left to
lower-right.

---

## Preset 5: `mathematical_sophistication` — 4x4, gestalt narrative

Rows represent increasing mathematical machinery.

|   | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **R0** | uniform | geometric | harmonic | mirror_harmonic |
| **R1** | chebyshev | sinusoidal | powerlaw | beta |
| **R2** | ruler | thuemorse | golden | sturmian |
| **R3** | stern_brocot | minkowski | arc_length | minimax_chord |

**Narrative.** R0 = "Calculus I" — partitions anyone could define in 5 minutes
(equal, equal-log, equal-reciprocal, mirror). R1 = "Approximation theory" —
Chebyshev nodes, Fourier modulation, power-law density, parametric statistics.
R2 = "Combinatorics & Dynamics" — 2-adic valuation, formal languages, number
theory, symbolic dynamics. R3 = "Deep structure & optimization" — Stern-Brocot
tree, Minkowski question-mark, curve-intrinsic arc length, minimax
equi-oscillation.

---

## Preset 6: `relational_triangle` — 4x4 lower triangle + diagonal (10 items)

Diagonal = 4 anchor philosophies. Below-diagonal entries show connecting
relationships.

|   | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **R0** | **uniform** | · | · | · |
| **R1** | harmonic | **geometric** | · | · |
| **R2** | reverse_geometric | stern_brocot | **chebyshev** | · |
| **R3** | random | ruler | minimax_chord | **arc_length** |

**Diagonal anchors**: uniform (agnostic simplicity), geometric (scale
equivariance), chebyshev (classical approximation), arc_length
(curve-intrinsic).

**Below-diagonal relationships:**
- (1,0) harmonic — bridges uniform's additive regularity to geometric's
  multiplicative
- (2,0) reverse_geometric — uniform-like simplicity with geometric's
  multiplicative widths reversed
- (2,1) stern_brocot — connects geometric (log-uniform) and Chebyshev
  (endpoint-dense) via rational tree
- (3,0) random — the null model for uniform: no structure at all
- (3,1) ruler — connects geometric (multiplicative) to arc_length (refined)
  via fractal hierarchy
- (3,2) minimax_chord — connects Chebyshev (approximation-theoretic) to
  arc_length (curve geometry) as the actual optimum

---

## Preset 7: `symmetry_spine` — 3x3 lower triangle + diagonal (6 items)

Diagonal = symmetric partitions. Below-diagonal = symmetry-breaking departures.

|   | Col 0 | Col 1 | Col 2 |
|---|-------|-------|-------|
| **R0** | **uniform** | · | · |
| **R1** | harmonic | **geometric** | · |
| **R2** | powerlaw | mirror_harmonic | **chebyshev** |

**Diagonal**: uniform (flat symmetric), geometric (log-symmetric), chebyshev
(endpoint-symmetric). **Below-diagonal**: harmonic (left-heavy break from
uniform), powerlaw (extreme left-heavy), mirror_harmonic (right-heavy break
from geometric's balance, beside chebyshev's both-endpoint density).

---

## Preset 8: `complete_atlas` — 5x5, geometric at center

All 23 partitions in concentric rings around geometric. 2 blanks at
bottom-right.

|   | Col 0 | Col 1 | Col 2 | Col 3 | Col 4 |
|---|-------|-------|-------|-------|-------|
| **R0** | cantor | thuemorse | stern_brocot | farey_rank | · |
| **R1** | ruler | harmonic | uniform | radical_inverse | dyadic |
| **R2** | bitrev_geometric | reverse_geometric | **geometric** | mirror_harmonic | sinusoidal |
| **R3** | sturmian | golden | chebyshev | minkowski | beta |
| **R4** | · | minimax_chord | powerlaw | arc_length | random |

**Inner ring** (8 cells around center): uniform (above), chebyshev (below),
reverse_geometric (left), mirror_harmonic (right), harmonic (upper-left),
radical_inverse (upper-right), golden (lower-left), minkowski (lower-right).

**Outer ring** (14 of 16 slots filled): Top edge = fractal and number-theoretic.
Left edge = fractal/symbolic hierarchy. Right edge = parametric/quantized.
Bottom edge = optimization and controls. Blanks at opposite corners [0,4] and
[4,0], framing the atlas along the anti-diagonal through geometric's center.

---

## Preset 9: `four_pillars` — 4x4 diagonal only (4 items)

Four fundamental partition design philosophies.

|   | Col 0 | Col 1 | Col 2 | Col 3 |
|---|-------|-------|-------|-------|
| **R0** | **uniform** | · | · | · |
| **R1** | · | **geometric** | · | · |
| **R2** | · | · | **chebyshev** | · |
| **R3** | · | · | · | **minimax_chord** |

**The diagonal progression**: (0) Agnostic simplicity — divide equally, ignore
the curve. (1) Scale equivariance — the thesis winner; equal log-width respects
multiplicative structure. (2) Classical approximation theory — Clenshaw-Curtis
nodes, what theory prescribes without problem-specific knowledge. (3) Curve-specific
optimization — the actual minimax optimum for `1/(x ln 2)`. The thesis claim:
geometric [1,1] achieves nearly the performance of minimax_chord [3,3] while
remaining curve-agnostic.

---

## Coverage Matrix

Every partition appears in at least 2 presets. `complete_atlas` contains all 23.

| Kind | Presets |
|------|---------|
| `uniform_x` | 1, 4, 5, 6, 7, 8, 9 |
| `geometric_x` | 1, 2, 3, 4, 5, 8, 9 |
| `harmonic_x` | 1, 4, 5, 6, 7, 8 |
| `mirror_harmonic_x` | 1, 4, 5, 7, 8 |
| `ruler_x` | 2, 3, 5, 6, 8 |
| `sinusoidal_x` | 3, 4, 5, 8 |
| `chebyshev_x` | 1, 4, 5, 6, 7, 8, 9 |
| `thuemorse_x` | 3, 5, 8 |
| `bitrev_geometric_x` | 3, 8 |
| `stern_brocot_x` | 2, 4, 5, 6, 8 |
| `reverse_geometric_x` | 1, 4, 6, 8 |
| `random_x` | 3, 4, 6, 8 |
| `dyadic_x` | 2, 3, 8 |
| `powerlaw_x` | 1, 4, 5, 7, 8 |
| `golden_x` | 2, 4, 5, 8 |
| `cantor_x` | 3, 8 |
| `minkowski_x` | 2, 5, 8 |
| `farey_rank_x` | 2, 5, 8 |
| `radical_inverse_x` | 2, 4, 5, 8 |
| `sturmian_x` | 2, 4, 5, 8 |
| `beta_x` | 3, 4, 5, 8 |
| `arc_length_x` | 1, 4, 5, 6, 8 |
| `minimax_chord_x` | 1, 4, 5, 6, 8, 9 |

---

# Proposed Tests for `lib/partitions.sage`

The existing suite (`tests/run_tests.sage`) has dedicated tests for 16 of 23
partition kinds. The 7 newest kinds — `minkowski_x`, `farey_rank_x`,
`radical_inverse_x`, `sturmian_x`, `beta_x`, `arc_length_x`,
`minimax_chord_x` — only receive generic contiguity/coverage checks from
`test_nondefault_domain_partition` and `test_float_cells`. Beyond the missing
kinds, several mathematical invariants and edge cases are untested even for
the 16 that do have dedicated tests.

Tests are organized into tiers by importance.

---

## Tier 1 — Dedicated tests for 7 untested kinds

Each needs at minimum: contiguity, coverage, bits-match-index, and one
kind-specific mathematical property assertion. Plus a minimax smoke test.

### `test_minkowski_x_partition`

- Contiguity, covers [1,2), bits match index.
- **Equivalence**: boundaries must be identical to `stern_brocot_x` at the
  same depth. This is the single most important partition test in the file —
  the equivalence is claimed in `PARTITIONS.md` but never verified.
  ```
  sb = build_partition(depth, kind='stern_brocot_x')
  mk = build_partition(depth, kind='minkowski_x')
  for j in range(N):
      assert abs(sb[j]['x_lo'] - mk[j]['x_lo']) < tol
  ```
- All boundaries should be in QQ (exact rational arithmetic).
- Known depth-2 boundaries should match stern_brocot depth-2:
  `[1, 4/3, 3/2, 5/3, 2]`.

### `test_farey_rank_x_partition`

- Contiguity, covers [1,2), bits match index.
- **Boundary rationality**: all boundaries should be in QQ.
- **Monotone**: boundaries strictly increasing.
- **Auto-Q convergence**: with default `farey_order=None`, should produce a
  valid partition without hanging. Test at depths 2, 3, 4.
- **Explicit Q**: with `farey_order=10`, verify boundaries are drawn from
  F_10 (all boundary fractions should have denominator <= 10 after
  subtracting x_start and dividing by x_width).

### `test_radical_inverse_x_partition`

- Contiguity, covers [1,2), bits match index.
- **Equivalence**: `radical_inverse_x(vdc_base=2)` should produce identical
  boundaries to `uniform_x`. This is the second claimed equivalence.
  ```
  ri = build_partition(depth, kind='radical_inverse_x', vdc_base=2)
  un = build_partition(depth, kind='uniform_x')
  for j in range(N):
      assert abs(ri[j]['x_lo'] - un[j]['x_lo']) < tol
  ```
- **Base 3**: with `vdc_base=3`, boundaries should differ from uniform.
  Widths should be quasi-uniform (no width more than ~3x any other).

### `test_sturmian_x_partition`

- Contiguity, covers [1,2), bits match index.
- All boundaries should be in QQ (exact rational arithmetic).
- **Exactly two distinct widths** (like Thue-Morse): Sturmian words over
  {0,1} assign one of two widths per cell, ratio = `st_ratio`.
  ```
  widths = sorted(set(float(r['width_x']) for r in part))
  assert len(widths) == 2
  assert abs(widths[1] / widths[0] - st_ratio) < 1e-10
  ```
- **Balance**: the count of wide vs narrow cells should match the expected
  Sturmian density. For the default `st_alpha = 1/phi`, approximately 61.8% of
  cells should get the `s_j = 1` width.

### `test_beta_x_partition`

- Contiguity, covers [1,2), bits match index.
- **Right-dense** (default alpha=5, beta=2): first cell should be wider than
  last cell.
- **Uniform limit**: `beta_x(beta_alpha=1, beta_beta=1)` is the uniform
  distribution — should approximate `uniform_x` within bisection tolerance.
  ```
  beta_part = build_partition(depth, kind='beta_x', beta_alpha=1, beta_beta=1)
  unif_part = build_partition(depth, kind='uniform_x')
  for j in range(N):
      assert abs(float(beta_part[j]['x_lo']) - float(unif_part[j]['x_lo'])) < 1e-8
  ```
- **Symmetric limit**: `beta_x(beta_alpha=5, beta_beta=5)` should produce
  a symmetric partition (w_j ≈ w_{N-1-j}).

### `test_arc_length_x_partition`

- Contiguity, covers [1,2), bits match index.
- **Equal arc length**: for each cell, numerically integrate
  `sqrt(1 + 1/(x^4 ln(2)^2))` from x_lo to x_hi. All cells should have
  equal arc length within bisection tolerance.
  ```
  arcs = [numerical_integral(ds, float(r['x_lo']), float(r['x_hi']))[0]
          for r in part]
  for a in arcs:
      assert abs(a - arcs[0]) / arcs[0] < 1e-8
  ```
- **Left-dense**: first cell narrower than last cell (curvature is higher
  near x=1).

### `test_minimax_chord_x_partition`

- Contiguity, covers [1,2), bits match index.
- **Equal peak error**: the maximum chord-to-curve gap within each cell
  should be approximately equal across all cells (equi-oscillation). Verify
  that max cell error / min cell error < 1 + epsilon for some reasonable
  epsilon (say 0.1 for depth=4).
  ```
  errors = [cell_error(float(r['x_lo']), float(r['x_hi'])) for r in part]
  assert max(errors) / min(errors) < 1.1
  ```
- **Beats geometric**: the worst cell error of minimax_chord should be <=
  the worst cell error of geometric at the same depth. (This is the thesis
  claim in the other direction — minimax_chord is the theoretical optimum.)
- **Left-dense**: first cell narrower than last.
- **No degenerate cells**: all cells should have positive width (guards
  against the pad/trim code masking convergence failure where the march
  produces too few cells and the tail collapses to zero-width stubs at
  x_end).
  ```
  for r in part:
      assert float(r['width_x']) > 1e-15
  ```

### Minimax smoke tests (7 new)

One `test_minimax_<kind>_smoke` per kind, same pattern as the existing 16:
converges, positive worst_err, reports partition_kind.

---

## Tier 2 — Mathematical invariants across all kinds

These are structural tests that should hold universally but are currently
unchecked.

### `test_width_sum_invariant`

For every kind and depth, the sum of cell widths should equal x_width.
Currently no test checks this; contiguity + coverage implies it only if
floating-point rounding is well-behaved.
```
for kind in PARTITION_KINDS:
    part = build_partition(depth, kind=kind)
    total = sum(r['width_x'] for r in part)
    assert abs(total - HiR(1)) < tol
```

### `test_positive_widths`

Every cell should have strictly positive width_x and width_log. The
minimax_chord pad/trim, cantor's remainder distribution, and dyadic's
snapping can each produce zero-width cells under adversarial parameters.

### `test_strict_boundary_ordering`

For every kind, x_lo < x_hi within each cell, and boundaries are strictly
monotone across cells. Subtly different from contiguity — contiguity checks
that consecutive cells abut but not that they don't invert.

### `test_plog_consistency`

Every row stores `plog_lo = x_lo - x_start` and `plog_hi = x_hi - x_start`.
Verify this identity for all 23 kinds.

### `test_width_log_consistency`

Every row stores `width_log = log2(x_hi) - log2(x_lo)`. Verify this agrees
with the stored value for all 23 kinds. (Catches cases where x_lo or x_hi is
negative or zero, which would blow up log.)

---

## Tier 3 — Kind-specific mathematical properties (existing 16 kinds)

These deepen coverage for kinds that already have basic tests.

### `test_chebyshev_x_symmetry`

Chebyshev widths should be symmetric: `w_j ≈ w_{N-1-j}`. The existing test
only checks endpoint-narrower-than-middle.

### `test_uniform_x_symmetry`

Uniform widths should be exactly equal (already tested), and the partition
should be symmetric about its midpoint: `x_lo[j] + x_hi[N-1-j] = 2*a + w`.

### `test_geometric_x_monotone_widths`

Geometric widths should strictly increase (narrow cells at x=1, wider at x=2
on [1,2)). The existing test checks equal log-widths but not the additive
width ordering.

### `test_reverse_geometric_is_reverse_of_geometric`

Width sequence of reverse_geometric should be the exact reversal of
geometric's width sequence. Currently only checks monotone decreasing.

### `test_bitrev_is_involution`

`_bitrev(_bitrev(j, depth), depth) == j` for all j in [0, 2^depth).
A helper function bug here would silently corrupt bitrev_geometric.

### `test_ruler_width_spectrum`

Ruler should have exactly `depth + 1` distinct widths (one per 2-adic
valuation level 0..depth). Currently only checks widest/narrowest and
power-of-2 ratios.

### `test_thuemorse_balance`

Thue-Morse should have exactly N/2 wide cells and N/2 narrow cells (the
sequence is balanced). Currently only checks 2 distinct widths and ratio.

### `test_golden_three_distance`

The three-distance theorem guarantees that the golden-ratio Kronecker
sequence has at most 3 distinct gap sizes. Verify:
```
widths = sorted(set(round(float(r['width_x']), 12) for r in part))
assert len(widths) <= 3
```

### `test_cantor_gap_structure`

Cells should be clustered within the surviving Cantor-dust intervals. For
`cantor_levels=L`, there should be `2^L` clusters of cells separated by
gaps at the removed middle thirds.

### `test_stern_brocot_refinement`

At depth d+1, every boundary from depth d should appear among the depth d+1
boundaries (mediant insertion only adds, never removes). This is the key
structural property of the Stern-Brocot tree.

### `test_harmonic_equal_reciprocal_spacing`

The defining property: `1/x_lo[j]` values should be equally spaced. Currently
only checks "wider near x=2 than x=1."

---

## Tier 4 — Edge cases and parameter boundaries

These target specific implementation risks — the "deliberately troublesome
functions."

### `test_sinusoidal_alpha_near_one`

`sin_alpha = 0.99` should still produce a valid partition (F(t) is barely
monotone). `sin_alpha = 1.0` makes F'(t) = 0 at some points — bisection may
fail or produce duplicate boundaries. The implementation has no guard;
document whether this is intended or should raise.

### `test_powerlaw_exponent_one`

`pl_exponent = 1.0` causes `exp = 1 - p = 0`, which is a division by zero
in the CDF inversion formula `(...)^{1/exp}`. Should either degenerate
gracefully to log-uniform (geometric) or raise a clear error. Currently
it will produce `inf` or `nan`.

### `test_powerlaw_exponent_near_one`

`pl_exponent = 1.001` should produce a valid partition but with extreme
width ratios. Verify contiguity and positive widths survive.

### `test_beta_extreme_params`

- `beta_alpha=0.5, beta_beta=0.5` (U-shaped density, arcsin distribution)
  — bisection should still converge but cells pack heavily at both endpoints.
- `beta_alpha=100, beta_beta=1` — nearly all cells crammed at x_end.
  Verify no zero-width cells.

### `test_cantor_low_N`

When `2^depth < 2^cantor_levels` (more Cantor intervals than cells), the
remainder distribution assigns 0 cells to some intervals. Verify the
partition is still valid (no empty intervals producing duplicate boundaries
or zero-width cells). For example, `depth=2` (N=4) with `cantor_levels=3`
(8 intervals) — only 4 of 8 intervals get a cell.

### `test_minimax_chord_low_depth`

At depth=1 (N=2 cells), the march algorithm has very little room. Verify
it produces a valid 2-cell partition with positive widths, not two copies
of x_end from the pad/trim fallback.

### `test_minimax_chord_no_degenerate_tail`

At depth=5 or 6, verify that the last cell has width > 0 and is not just
an artifact of `while len(pts) < N+1: pts.append(xe_f)`. This guards
against the march terminating too early and the tail being filled with
zero-width stubs.

### `test_farey_auto_Q_terminates`

The auto-Q loop in `_farey_rank_boundaries` increments Q until `|F_Q| >= N+1`.
At depth=6 (N=64), verify this terminates in reasonable time and produces a
valid Q. (Farey sequence size grows as ~3Q^2/pi^2, so Q ~ 8 suffices for
N=64, but verify.)

### `test_sturmian_floor_precision`

Sturmian uses `math.floor((j+1)*alpha + phase)` with float arithmetic.
For `st_alpha` near a rational number (e.g., `st_alpha = 1.5 + 1e-15`),
floor can misfire. Construct a case where `(j+1)*alpha + phase` is within
1e-14 of an integer and verify the partition is still valid.

### `test_dyadic_snapping_preserves_order`

Dyadic snapping can produce non-monotone boundaries if two adjacent geometric
targets snap to the same dyadic rational. At very low `dyadic_res` (e.g., 2),
verify boundaries are still monotone or that the implementation handles
collisions.

### `test_random_different_seeds`

Two different seeds should produce different partitions. (Validates that the
seed is actually being used, not accidentally hardcoded.)

---

## Tier 5 — Cross-kind comparative tests

### `test_minimax_chord_beats_all`

At a fixed depth, minimax_chord should have the lowest worst-cell chord error
among all 23 kinds (it is the theoretical optimum). If any other kind beats
it, the minimax_chord implementation has a bug.

### `test_geometric_near_minimax`

The thesis claim: geometric's worst-cell error should be within a small
factor (say 2x) of minimax_chord's at depth >= 4. This isn't a correctness
test but a sanity check that the thesis narrative holds.

### `test_domain_scaling_invariance`

For kinds defined by normalized coordinates on `[0,1]` and then scaled
(`uniform_x`, `chebyshev_x`, `ruler_x`, `thuemorse_x`, `stern_brocot_x`,
`random_x` with fixed seed, `golden_x`, `cantor_x`, `minkowski_x`,
`farey_rank_x`, `radical_inverse_x`, `sturmian_x`, `beta_x`), the partition
on `[a, a+w)` should be an affine rescaling of the partition on `[1, 2)`.
For multiplicative / reciprocal families (`geometric_x`, `harmonic_x`,
`mirror_harmonic_x`, `bitrev_geometric_x`, `reverse_geometric_x`,
`sinusoidal_x`, `powerlaw_x`, `dyadic_x`) and for curve-aware kinds, it
generally should not be.
