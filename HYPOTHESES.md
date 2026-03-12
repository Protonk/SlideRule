Purpose: active research claims and their current status
Canonical for: what the project currently believes is true, false, open, or deprioritized
Not for: script usage, run logs, or implementation details

# Hypotheses

## Current headline

The main live claim is the scale-equivariance thesis in
[`LODESTONE.md`](LODESTONE.md). The first lodestone partition-comparison run
exists (2026-03-11). L1 has been subdivided: the cell-level advantage of
geometric partitions is clear, but the shared-delta advantage depends on the
parameterization regime. The wall and H1 results remain important as
legacy baseline evidence.

## Primary lodestone hypotheses

### L1. Geometric partitions outperform uniform partitions for power-law targets

Status: subdivided (2026-03-11) — see L1a, L1b, L1c below

The first lodestone partition-comparison sweep (2026-03-11) shows that the
original L1 claim is true at the cell level but not under the shared-delta
constraint in general. The distinction motivates three sub-hypotheses.

### L1a. Geometric cells have lower optimal per-cell error

Status: supported

Claim:

- The free-per-cell worst-case error (`free_err`) is lower on the geometric
  partition than on the uniform partition at every tested depth.

Evidence (lodestone sweep, alpha=1/2):

- In the depth sweep (q=5, d=3..6), geometric `free_err` is strictly lower at
  every depth. At d=6: geometric 0.00194 vs uniform 0.00276.
- The mechanism is clear: equal-log-width cells match the curvature of
  `log2(z)` for power-law targets, distributing error more evenly across cells.

### L1b. Geometric partitions yield lower minimax error under layer-invariant FSM sharing

Status: not generally supported

Claim:

- Under the layer-invariant shared-delta constraint, geometric partitions
  should yield lower `opt_err` than uniform partitions.

Evidence against (lodestone sweep, alpha=1/2):

- In the depth sweep at q=5, geometric `opt_err` exceeds uniform `opt_err` at
  d>=4. At d=6: geometric 0.03799 vs uniform 0.03475.
- In the q sweep at depth=4, uniform wins at q=2, 3, 5 while geometric wins at
  q=1 and q=7.
- The gap (`opt_err - free_err`) is consistently larger on the geometric
  partition, indicating a larger sharing penalty.

Key insight: the FSM sharing constraint is bitwise/additive in structure, which
may align better with uniform-x cell boundaries. Geometric cells win at the
cell level but the sharing penalty can erase that advantage.

### L1c. Under layer-dependent parameterization, the geometric advantage propagates

Status: supported at (q=3, d=6)

Claim:

- When the parameterization is loosened to layer-dependent deltas, the
  geometric free-per-cell advantage from L1a propagates through to lower
  `opt_err`.

Evidence (lodestone sweep, alpha=1/2):

- At (q=3, d=6) with layer-dependent deltas: geometric `opt_err` = 0.02191 vs
  uniform `opt_err` = 0.02452.
- Layer-dependent parameterization reduces the gap on both partition kinds
  (~40–50%), but the geometric partition ends up with a lower residual.

Next test:

- run layer-dependent comparison at more (q, depth) points to test whether L1c
  holds broadly or only at this one benchmark

### L2. Log-organized schemes behave more naturally across depth than x-organized schemes

Status: mixed, requires subdivision similar to L1 (2026-03-11)

Claim (unchanged):

- Approximation quality for `x^(p/q)` should degrade less with depth on a
  geometric grid than on a uniform grid, because the geometric grid keeps the
  per-cell problem closer to self-similar across scales.

Why this matters:

- This asks whether the lodestone story is only a static partition preference
  or a real scaling law about how the difficulty of the problem replicates with
  depth.

First evidence (lodestone sweep, alpha=1/2):

- `free_err` decays faster on geometric (lower at every tested depth),
  confirming the cell-level advantage from L1a.
- However, `opt_err` grows faster on geometric at higher depths under
  layer-invariant sharing, mirroring L1b.
- The relative improvement `improve / single_err` is not straightforwardly
  better on geometric across depth.

Next test:

- repeat the depth sweep with layer-dependent parameterization to see if L1c
  extends to depth scaling
- subdivide L2 along the same L1a/L1b/L1c lines if the pattern persists

### L3. The wall decomposition is partition-dependent

Status: first evidence (2026-03-11)

Claim:

- On the geometric grid, the dominant wall source is currently layer sharing.
- On a uniform grid, the dominant wall source should shift toward
  cell-difficulty imbalance, because the smallest cells in the natural log
  geometry are no longer being represented fairly.

Why this matters:

- This determines whether the current wall decomposition is a structural fact
  about the FSM parameterization or partly an artifact of working on a
  partition already matched to scaling.

First evidence (lodestone sweep, alpha=1/2, q=3, d=6):

- Layer-dependent deltas reduce the gap by ~40% (uniform) and ~50% (geometric),
  confirming that layer sharing is the dominant wall source for both partition
  kinds at this depth.
- The gap differs between partition kinds at every tested (q, depth) point.
- The residual gap after removing layer sharing differs between partition kinds,
  consistent with the prediction that cell-difficulty imbalance contributes
  differently.

Next test:

- extend the layer-dependent comparison to more (q, depth) points
- examine which cells are worst-case on each partition kind to distinguish
  layer-sharing from cell-difficulty sources directly

## Supporting legacy baseline hypotheses

### H1. Shared FSM structure gives real approximation power on the legacy `uniform_x` baseline

Status: supported, but qualified

Role in the current program:

- `H1` is no longer the repo's main thesis. It establishes that shared
  structure does nontrivial work on the legacy `uniform_x` baseline, so the
  lodestone partition tests compare against a meaningful baseline rather than a
  degenerate model.

Current claim:

- Shared-delta FSM policies do beat the best single-intercept Day model in the
  tested finite cases.
- In the layer-invariant model, that gain is real but fragile: it decays with
  depth at fixed `q`.
- The wall is therefore not "FSMs do nothing", but "shared structure helps
  modestly on the baseline grid unless the parameterization is loosened."

Key evidence:

- The baseline minimax sweep shows `improve = single_err - opt_err > 0` in all
  tested layer-invariant cases.
- The H1 sweep shows that fixed-depth performance improves strongly with larger
  `q`, and that layer-dependent deltas recover much more of the gap.

Immediate next tests:

- extend H1c only as needed to support `L3`
- run multi-`alpha` robustness checks
- turn the baseline observations into a scaling law in the
  parameter-to-cell ratio

## Working H1 sub-hypotheses

### H1a. At fixed depth, the gap closes with parameter budget

Status: supported

Claim:

- At fixed shallow depth, increasing `q` drives `opt_err` close to `free_err`.

Evidence:

- In the current depth-4 baseline sweep, the layer-invariant model is already
  near the free-per-cell floor by `q = 9`.

Next test:

- repeat the `q` sweep at larger depths to see how the required parameter
  budget scales with `2^depth`

### H1b. At fixed q in the layer-invariant baseline model, relative improvement decays with depth

Status: supported

Claim:

- For fixed `q`, the relative gain `improve / single_err` decays toward zero as
  depth grows.

Evidence:

- The `q = 5` baseline depth sweep from `d = 4` to `d = 10` shows monotone decay
  from substantial finite-depth gain to near invisibility.

Next test:

- repeat the depth sweep for several fixed `q` values to estimate the decay law
- use the same parameter choices as the first uniform-grid comparison for `L2`

### H1c. Most of the baseline wall in the tested cases is caused by layer sharing

Status: supported

Claim:

- Forcing one `delta[(state, bit)]` table to serve every layer is the dominant
  source of the observed wall in the tested benchmark cases.

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
- For the current obstruction model, read [`WALL.md`](WALL.md).
- For dated numeric evidence, read [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).
- For how to run the scripts behind those claims and the planned lodestone
  comparisons, read
  [`experiments/README.md`](experiments/README.md).
