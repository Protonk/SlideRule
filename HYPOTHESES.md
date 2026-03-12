Purpose: active research claims and their current status
Canonical for: what the project currently believes is true, false, open, or deprioritized
Not for: script usage, run logs, or implementation details

# Hypotheses

## Current headline

The main live claim is the scale-equivariance thesis in
[`LODESTONE.md`](LODESTONE.md). The wall and H1 results remain important, but
mainly as dyadic-baseline evidence and diagnostics for testing that thesis.

## Primary lodestone hypotheses

### L1. Geometric partitions outperform uniform partitions for power-law targets

Status: untested

Claim:

- Running the existing FSM optimization on a uniform-in-`x` partition with the
  same number of cells as the dyadic/geometric partition should produce a
  qualitatively worse wall.
- Error should concentrate near the fine end, where additive cells are too wide
  relative to the local variation of `x^(p/q)`.

Why this matters:

- This is the direct negative-control experiment for the lodestone thesis. If
  the geometric partition is not measurably better, the thesis loses most of
  its empirical content.

Current prerequisite evidence:

- The existing dyadic sweeps already show that the solver, metrics, and wall
  decomposition are sensitive enough to distinguish parameter-budget and
  sharing effects on a partition aligned with scaling.

Next test:

- add a uniform partition generator with matched cell count
- rerun the layer-invariant minimax sweep on both partition types
- compare `gap`, cellwise error distribution, and where the worst cells live

### L2. Log-organized schemes behave more naturally across depth than x-organized schemes

Status: untested

Claim:

- Approximation quality for `x^(p/q)` should degrade less with depth on a
  geometric grid than on a uniform grid, because the geometric grid keeps the
  per-cell problem closer to self-similar across scales.

Why this matters:

- This asks whether the lodestone story is only a static partition preference
  or a real scaling law about how the difficulty of the problem replicates with
  depth.

Current prerequisite evidence:

- On the dyadic baseline, fixed-`q` gain decays with depth and shallow-depth
  recovery occurs as `q` grows. That makes partition dependence a concrete
  quantitative question rather than a slogan.

Next test:

- repeat the current depth and `q` sweeps on both partition types
- compare decay of `improve / single_err` and the scaling of `gap` relative to
  cell count

### L3. The wall decomposition is partition-dependent

Status: untested

Claim:

- On the geometric grid, the dominant wall source is currently layer sharing.
- On a uniform grid, the dominant wall source should shift toward
  cell-difficulty imbalance, because the smallest cells in the natural log
  geometry are no longer being represented fairly.

Why this matters:

- This determines whether the current wall decomposition is a structural fact
  about the FSM parameterization or partly an artifact of working on a
  partition already matched to scaling.

Current prerequisite evidence:

- On the dyadic baseline, layer-dependent deltas remove a large fraction of the
  wall in the tested benchmark cases.

Next test:

- run the layer-invariant vs layer-dependent comparison on a uniform partition
- compare gap reductions and cellwise error concentration against the dyadic
  baseline

## Supporting dyadic baseline hypotheses

### H1. Shared FSM structure gives real approximation power on the dyadic baseline

Status: supported, but qualified

Role in the current program:

- `H1` is no longer the repo's main thesis. It establishes that shared
  structure does nontrivial work on the matched dyadic/geometric partition, so
  the lodestone partition tests compare against a meaningful baseline rather
  than a degenerate model.

Current claim:

- Shared-delta FSM policies do beat the best single-intercept Day model in the
  tested finite cases.
- In the layer-invariant model, that gain is real but fragile: it decays with
  depth at fixed `q`.
- The wall is therefore not "FSMs do nothing", but "shared structure helps
  modestly on the matched grid unless the parameterization is loosened."

Key evidence:

- The baseline minimax sweep shows `improve = single_err - opt_err > 0` in all
  tested layer-invariant cases.
- The H1 sweep shows that fixed-depth performance improves strongly with larger
  `q`, and that layer-dependent deltas recover much more of the gap.

Immediate next tests:

- extend H1c only as needed to support `L3`
- run multi-`alpha` robustness checks
- turn the dyadic baseline observations into a scaling law in the
  parameter-to-cell ratio

## Working H1 sub-hypotheses

### H1a. At fixed depth, the gap closes with parameter budget

Status: supported

Claim:

- At fixed shallow depth, increasing `q` drives `opt_err` close to `free_err`.

Evidence:

- In the current depth-4 dyadic sweep, the layer-invariant model is already
  near the free-per-cell floor by `q = 9`.

Next test:

- repeat the `q` sweep at larger depths to see how the required parameter
  budget scales with `2^depth`

### H1b. At fixed q in the layer-invariant dyadic model, relative improvement decays with depth

Status: supported

Claim:

- For fixed `q`, the relative gain `improve / single_err` decays toward zero as
  depth grows.

Evidence:

- The `q = 5` dyadic depth sweep from `d = 4` to `d = 10` shows monotone decay
  from substantial finite-depth gain to near invisibility.

Next test:

- repeat the depth sweep for several fixed `q` values to estimate the decay law
- use the same parameter choices as the first uniform-grid comparison for `L2`

### H1c. Most of the dyadic wall in the tested cases is caused by layer sharing

Status: supported

Claim:

- Forcing one `delta[(state, bit)]` table to serve every layer is the dominant
  source of the observed wall in the tested dyadic benchmark cases.

Evidence:

- At `(q, d) = (3, 6)` and `(5, 6)`, layer-dependent deltas reduce the
  layer-invariant gap substantially, with the larger reduction at `q = 5`.

Next test:

- extend the layer-dependent comparison to a wider grid in `(q, depth)` and to
  more than one `alpha`
- reuse those same benchmark points when running the `L3` uniform-grid
  comparison

### H1d. Delta-shape depends strongly on parameterization

Status: observed, not yet elevated to a broad theorem

Claim:

- Layer-invariant optima are moderately concentrated.
- Layer-dependent optima are diffuse and genuinely use the enlarged parameter
  budget.

Evidence:

- The current sparsity/concentration readout shows small active support in the
  layer-invariant runs and broad support in the layer-dependent benchmark runs.

Next test:

- track the same statistics over a wider H1c sweep before treating this as a
  stable structural law
- check whether the same contrast survives once partition type is varied

## Retired or deprioritized hypotheses

### H2. The policy-induced active-extrema family actually grows

Status: falsified under the minimax objective

Current read:

- Under minimax optimization, the induced pattern family stays tiny in the
  tested cases. The objective equalizes cells rather than diversifying them.

### H3. The relevant Jukna object is the induced pattern family

Status: moot under the minimax objective

Current read:

- With induced families this small, there is no meaningful additive structure to
  discriminate between candidate objects.

### H4. There is a real tropical-vs-arithmetic compression story

Status: open, lower priority

Current read:

- There is still a compressed-optimization story, since the LP solves over
  shared parameters rather than per-leaf intercepts, but the original Jukna
  motivation is no longer the center of the project.

## Reading outward

- For the repo-level thesis and motivation, read [`LODESTONE.md`](LODESTONE.md).
- For the current dyadic obstruction model, read [`WALL.md`](WALL.md).
- For dated numeric evidence, read [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).
- For how to run the scripts behind those claims and the planned lodestone
  comparisons, read
  [`experiments/README.md`](experiments/README.md).
