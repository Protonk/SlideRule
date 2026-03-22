# Scramble Plan

Width-preserving position scrambles to test whether the intercept
field c* is organised by position in ε or by a width × position
coupling.

## Motivation

The basis identification (steps 1–3) established that ε(m_mid) is
the first-order organiser of R0(c*), and that cell-width distribution
alone (H_width) is eliminated. But width and position are correlated
in every partition tested so far: geometric has narrow cells at x=1
(low ε) and wide cells at x=2 (low ε), with cells around m*
substantially wider than the left-edge cells even though the very
widest cells sit near x=2. The Group H adversaries changed the width
histogram but did not decouple width from position.

The scramble test holds the width set constant and permutes which
width lands at which position. This is a permutation test on the
width-to-position assignment — a standard experimental design
applied to a novel setting.

The point of `peak_swap_x` and `peak_avoid_x` is not to add two more
named partitions to the beach. They are calibrated interventions.
Across the zoo, many geometric properties move at once: width
histogram, density centroid, local order, symmetry, arithmetic, and
curve-awareness. The two scrambles are useful precisely because they
hold the width spectrum fixed and move one interpretable coordinate:
how strongly large or small widths are coupled to the hard region near
`m*`.

So these two partitions should be read as axis calibrators, not as
standalone zoo curiosities. If they matter, they let us say something
stronger than "partition A differs from partition B": they let us say
that one specific width-to-position intervention is load-bearing.

## Construction

### Source partition

Use **geometric_x** at the target depth as the width source. Its
cells have a clear width gradient (narrow near x=1, wide near x=2
on [1, 2)), providing maximal leverage for the scramble.

At depth d, geometric_x has N = 2^d cells with widths

    w_j = x_{j+1} − x_j,   j = 0, ..., N−1

where x_j = 2^(j/N). These widths are monotonically increasing.

### Scramble construction

Given a permutation σ of {0, ..., N−1}, the scrambled partition has
boundaries:

    b_0 = 1
    b_k = 1 + Σ_{j=0}^{k−1} w_{σ(j)},   k = 1, ..., N

The total width is preserved (Σ w_j = 1), so b_N = 2. The cells
tile [1, 2) without gaps or overlaps. The width histogram is
identical to geometric's. Only the position assignment differs.

### Two specific scrambles

Let m* = 1/ln2 − 1 ≈ 0.4427. In mantissa coordinates, m* is the
position where ε peaks. On [1, 2), this corresponds to
x* = 1 + m* ≈ 1.4427.

Define the "distance to peak" for position p (mantissa of the cell
that will land there) as |p − m*|. The scrambles assign widths to
positions based on the relationship between width rank and position
rank:

To keep the target positions exogenous, define a fixed reference slot
system first:

    r_j = (j + 1/2) / N,   j = 0, ..., N−1

These are the midpoint mantissas of the uniform_x cells at the same
depth. They are external to the scramble and do not depend on the
assigned widths. Rank reference slots by |r_j − m*| and assign widths
to those slots. Only after the assignment is fixed do we lay the widths
down left-to-right and compute the actual final midpoints.

**`peak_swap_x`**: "narrow cells at the peak, wide cells at the
boundaries."

Sort the geometric widths ascending: w_{(0)} ≤ w_{(1)} ≤ ... ≤ w_{(N−1)}.
Sort the N reference slots by distance to m*, ascending (closest
first). Assign the narrowest width to the slot closest to m*, the
next narrowest to the next closest, etc.

Construction procedure:
1. Compute geometric widths w_0, ..., w_{N−1} and sort ascending.
2. Define the fixed reference slot midpoints r_0, ..., r_{N−1}.
3. Rank reference slots by |r_j − m*|, ascending. Break ties by
   lower index (leftward preference).
4. Assign the k-th narrowest width to the k-th closest slot.
5. Lay down the assigned widths left-to-right to produce boundaries.
6. Compute actual final midpoints from the laid-out boundaries.
7. Report the mismatch between intended reference-slot rank and actual
   final peak-distance rank.

Optional self-consistency refinement:

- Re-rank using actual final |midpoint − m*|, re-assign widths, and
  re-lay.
- Iterate until the assignment stabilises or until a fixed max
  iteration count is reached.
- Report iteration count, whether convergence occurred, and the final
  rank mismatch.

The fixed-slot construction is the primary object for interpretation,
because its target positions are external to the scramble. The
self-consistent refinement is a diagnostic, not the default claim
surface.

This inverts the natural relationship: geometric places its narrowest
cells far from m* (at x=1, where m=0 and ε=0) and its widest cells
near x=2 (where m=1 and ε=0). Peak_swap puts the narrowest cells
near m* (where ε is largest and the free intercept varies most
rapidly).

**`peak_avoid_x`**: "wide cells at the peak, narrow cells at the
boundaries."

The reverse assignment: the k-th *widest* width goes to the k-th
closest reference slot to m*. This packs wide cells near m* and
narrow cells at the boundaries.

This maximises the width-ε coupling: the widest cells (least
resolution) land where ε is largest (most curvature to resolve).

Taken together, the pair gives opposite ends of the same controlled
move:

- `peak_swap_x` suppresses width near the boundaries and pushes the
  finest resolution toward the hard region near `m*`
- `peak_avoid_x` does the reverse and withholds resolution from the
  hard region

This is why they are worth building even before the whole-zoo sweep is
finished. They test a controlled mechanism that the zoo mostly
entangles.

### Implementation

Add as a single parameterised partition kind `scramble_x` with a
`scramble_mode` parameter:

```
scramble_mode='peak_swap'   → peak_swap_x behavior
scramble_mode='peak_avoid'  → peak_avoid_x behavior
```

The boundary builder:
1. Build geometric_x at the same depth to get the source widths.
2. Sort widths ascending.
3. Define the fixed reference slot midpoints r_j = (j + 1/2) / N.
4. Rank reference slots by |r_j − m*| (ties: lower index first).
5. For peak_swap: assign k-th narrowest to k-th closest slot.
   For peak_avoid: assign k-th widest to k-th closest slot.
6. Lay down left-to-right and compute boundaries.
7. Compute actual final midpoints and report rank mismatch metrics.
8. Optional diagnostic refinement: iterate re-ranking until stable or
   max_iters, then report convergence status and final mismatch.

### Sanity control: uniform source

Run one scramble pair sourced from uniform_x. Uniform has equal
widths, so any permutation is a no-op — the scrambled partition
should produce exactly uniform_x. Stage A correlation should match
uniform's known value (0.87). This is a zero-cost check that the
boundary builder is correct.

### Coupling diagnostics

For geometric_x, peak_swap_x, and peak_avoid_x, report at least:

- `rho_peak`: correlation between width rank and `-|m_mid - m*|`
  Positive means wider cells land closer to the peak.
- `mean_width_eps`: the ε-weighted mean width

      mean_width_eps = (Σ_j width_j · ε(m_mid_j)) / (Σ_j ε(m_mid_j))

- `rank_mismatch_max`: maximum absolute displacement between reference
  peak-distance rank and actual final peak-distance rank
- `rank_mismatch_mean`: mean absolute rank displacement

These scalars make the coupling shift measurable rather than merely
descriptive.

They also make the scrambles commensurable with the rest of the zoo:
once these metrics exist for every partition kind, the scrambles can be
located as deliberate moves along one axis rather than treated as two
isolated special cases.

### Properties

Both scrambles:
- Same width histogram as geometric_x
- Same total width (tiles [1, 2) exactly)
- Not monotone in cell width (by design)
- Peak-aware through `m*`, but not optimizer-aware; they do not use
  `c*` or Day candidate structure directly
- Arithmetic: HiR

## Test design

### Basis fit on scrambles

Add both scrambles to the basis-identification holdout set. Refit
all basis families (trained on baselines d=5,6,7) and score on
scrambles.

Key comparison:
- Does H_value (ε at midpoint) still predict g on scrambles?
- Does H_balance's margin over H_value change?
- Does H_width remain eliminated?

This is the primary readout. The scramble plan is meant to test
generalisation of the basis claim, not just preserve a high Stage A
correlation.

### Stage A on scrambles

Run the same Stage A test (R0(c*) vs R0(Δ^L)) on both scrambles at
depths 5, 6, 7, 8. Compare correlations to baseline geometric_x.

This is a secondary diagnostic, not the headline quantity.

Predictions:
- If held-out basis prediction holds and Stage A correlation is stable:
  position dominates width assignment.
- If held-out basis prediction weakens while Stage A stays high:
  Stage A is too coarse to see the coupling.
- If both weaken:
  width × position coupling is probably first-order.

### What the scramble actually tests

The plan frames this as "holding width constant and permuting
position." More precisely: what is permuted is the width-to-position
assignment, where position means "where in [1, 2) the cell sits."
The cell's position determines both what ε looks like locally and
what the mantissa coordinates are — these cannot be separated, they
are the same thing. So the scramble tests: "does the specific width
that lands at position m matter, or only the position itself?"

### Interpretation matrix

| H_value on scrambles | H_balance margin | Reading |
|---|---|---|
| Holds | Stable | Strong support for T3 under this scramble family. |
| Holds | Changes | ε value drives the template; balance features are width-mediated. |
| Breaks | Holds | The 0.026 margin is load-bearing, not a correction. ε(m_mid) was proxying for balance geometry. Surprising. |
| Breaks | Breaks | Width × position coupling is first-order. T3 needs qualification. |

### Most informative outcomes

**peak_swap + H_value holds** is the clean finish for T3. Peak_swap
puts narrow cells where ε is large and wide cells where ε is small —
the opposite of geometric's natural coupling. If ε(m_mid) still
predicts g despite this inversion, width is genuinely irrelevant to
the template shape.

**H_value breaks on peak_avoid but holds on peak_swap** is the most
informative mixed outcome. It would mean: putting high resolution
where ε is large (peak_swap) lets the optimizer find intercepts that
follow ε; putting low resolution where ε is large (peak_avoid)
forces the optimizer into compromises that distort the template. The
forcing is positional, but the partition's ability to *express* the
forcing depends on having adequate resolution where it matters. That
is a second-order coupling, not a refutation of the positional story.

## Results (2026-03-21)

### Stage A correlations

| Partition | d=5 | d=6 | d=7 | d=8 |
|---|---|---|---|---|
| geometric (baseline) | 0.851 | 0.850 | 0.850 | 0.849 |
| peak_swap | 0.850 | 0.849 | 0.849 | 0.848 |
| peak_avoid | 0.886 | 0.887 | 0.887 | 0.888 |

Stage A correlations are stable under scrambling. Peak_swap matches
geometric almost exactly. Peak_avoid is slightly higher.

### Basis fit (trained on baselines d=5,6,7, scored on scrambles)

| Partition | H_value corr | H_value NRMSE | H_balance corr | H_balance NRMSE | H_width corr | H_width NRMSE |
|---|---|---|---|---|---|---|
| peak_swap d=6 | 0.851 | 0.457 | 0.860 | 0.444 | 0.543 | 0.726 |
| peak_avoid d=6 | 0.885 | 0.451 | 0.923 | 0.382 | 0.839 | 0.691 |

### Interpretation

**H_value holds on both scrambles.** Correlations 0.85–0.89, NRMSE
0.45 — essentially unchanged from the original adversary holdout
(0.86, 0.45). Width inversion does not break the ε-value predictor.
This is the "clean finish" outcome from the interpretation matrix:
**position dominates**.

**H_balance's margin changes.** On peak_swap, the margin over H_value
is ~0.013 NRMSE (down from 0.026 on the original holdout). On
peak_avoid, the margin widens to ~0.069 NRMSE — H_balance reaches
corr 0.923. This matches the second row of the interpretation matrix:
"ε value drives the template; balance features are width-mediated."
The endpoint-balance correction is real but is modulated by where
widths land relative to m*.

**H_width is further weakened on peak_swap** (corr 0.54, NRMSE 0.73)
but partially recovers on peak_avoid (corr 0.84, NRMSE 0.69). This
makes sense: peak_avoid places wide cells near m* where ε is large,
creating an artificial width-ε correlation that H_width can partially
exploit. But H_value still beats H_width on both scrambles.

**Coupling diagnostics confirm the intervention worked:**
- geometric: rho_peak = −0.17 (weak natural coupling)
- peak_swap: rho_peak = −0.99 (strong inverted coupling)
- peak_avoid: rho_peak = +0.99 (strong aligned coupling)

The scrambles achieved near-perfect inversion and alignment of the
width-to-peak-distance coupling while preserving the width histogram.

### Bottom line

T3 survives the scramble test. The ε-value predictor (H_value) is
robust to width-position inversion. The balance features (H_balance)
are width-modulated but subdominant. Width alone (H_width) remains
eliminated as a first-order explanation on peak_swap, where the
natural coupling is inverted.

## Wiring the zoo (current scope)

The scramble work should not live in a side pocket. The immediate
mechanical task is to wire the whole partition zoo into the same
observable pipeline so the scrambles and the existing 25 kinds can be
compared on equal footing.

This is intentionally boring work. It is preparation, not theory.

### Goal

For each of the 25 existing kinds plus `peak_swap_x` and
`peak_avoid_x`, produce the same basic diagnostic bundle:

- partition rows at the target depths
- free intercept field `c*`
- transported residual field `g = R0(c*)`
- basis-family features already defined in
  `INTERCEPT-ORGANIZE-PLAN.md`
- scramble-style coupling diagnostics where applicable
- basic metadata copied from `PARTITIONS.md` / `partitions.json`

The point is not to explain the whole zoo immediately. The point is to
make the zoo queryable by the same observables before making more
interpretive claims.

### Mechanical outputs

- `zoo_observables.csv`
  One row per cell per partition/depth with `m_mid`, widths, `c*`,
  `g = R0(c*)`, and ε-derived features.
- `zoo_partition_metrics.csv`
  One row per partition/depth with summary diagnostics such as Stage A
  correlation, basis-fit summaries, and coupling statistics.
- `zoo_metadata.csv`
  Stable partition descriptors drawn from the existing partition
  classification: group, density, symmetry, arithmetic, curve-aware,
  and any scramble-specific tags.

### Present use of the zoo wiring

Current purpose:

1. make sure the scrambles run through the same pipeline as the rest of
   the zoo
2. make it cheap to check whether an observed scramble effect is
   genuinely unusual or already present in some existing kind
3. get the data into a form that supports a later latent survey without
   deciding that survey prematurely

Explicit non-goal for now:

- do **not** rush into an all-zoo theory of correlates
- do **not** fit a grand explanatory model over 27 partition names just
  because the table exists

The right stopping point is: the scrambles are working, the zoo is
wired, the diagnostics are comparable, and we pause to reflect before
escalating.

## Future work

Once the scrambles are working and the zoo is wired, a natural next
question is whether the 27 partitions are really 27 unrelated cases or
whether they factor through a much smaller fingerprint space.

That future program would ask for each partition:

- a small number of computed fingerprint coordinates
- whether the intercept-template observables live on a low-rank surface
  in that coordinate space
- whether the scrambles behave like controlled moves along one of those
  coordinates

Promising fingerprint coordinates include:

- width inequality / width entropy
- ε-weighted mean width
- width-rank vs peak-distance coupling
- permutation disorder relative to monotone width order
- within-half geometricity

If that works, the partition zoo stops being a Borges library of named
constructions and becomes a survey over a few mechanistic axes. But
that is deliberately future work. The present plan stops earlier:
build the two interventions, wire the zoo, then pause.
