Purpose: active research claims and their current status
Canonical for: what the project currently believes is true, false, open, or deprioritized
Not for: script usage, run logs, or implementation details

# Hypotheses

## Current headline

The original Day x Jukna program has narrowed. Under the current minimax
objective, the main live question is not induced combinatorics, but the
approximation wall between shared-delta policies and the free-per-cell lower
bound.

## H1. Shared FSM structure gives real approximation power

Status: supported, but qualified

Current claim:

- Shared-delta FSM policies do beat the best single-intercept Day model in the
  tested finite cases.
- In the layer-invariant model, that gain is real but fragile: it decays with
  depth at fixed `q`.
- The wall is therefore not "FSMs do nothing", but "shared structure helps only
  modestly unless the parameterization is loosened."

Key evidence:

- The baseline minimax sweep shows `improve = single_err - opt_err > 0` in all
  tested layer-invariant cases.
- The H1 sweep shows that fixed-depth performance improves strongly with larger
  `q`, and that layer-dependent deltas recover much more of the gap.

Immediate next tests:

- Broaden the H1c comparison beyond the current benchmark cases.
- Run multi-`alpha` sweeps.
- Turn the current observations into a scaling law in the parameter-to-cell
  ratio.

## Resolved H1 sub-hypotheses

### H1a. At fixed depth, the gap closes with parameter budget

Status: supported

Claim:

- At fixed shallow depth, increasing `q` drives `opt_err` close to `free_err`.

Evidence:

- In the current depth-4 sweep, the layer-invariant model is already near the
  free-per-cell floor by `q = 9`.

Next test:

- Repeat the `q` sweep at larger depths to see how the required parameter budget
  scales with `2^depth`.

### H1b. At fixed q in the layer-invariant model, relative improvement decays with depth

Status: supported

Claim:

- For fixed `q`, the relative gain `improve / single_err` decays toward zero as
  depth grows.

Evidence:

- The `q = 5` depth sweep from `d = 4` to `d = 10` shows monotone decay from
  substantial finite-depth gain to near invisibility.

Next test:

- Repeat the depth sweep for several fixed `q` values to estimate the decay law.

### H1c. Most of the wall in the tested cases is caused by layer sharing

Status: supported

Claim:

- Forcing one `delta[(state, bit)]` table to serve every layer is the dominant
  source of the observed wall in the tested benchmark cases.

Evidence:

- At `(q, d) = (3, 6)` and `(5, 6)`, layer-dependent deltas reduce the
  layer-invariant gap substantially, with the larger reduction at `q = 5`.

Next test:

- Extend the layer-dependent comparison to a wider grid in `(q, depth)` and to
  more than one `alpha`.

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

- Track the same statistics over a wider H1c sweep before treating this as a
  stable structural law.

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

- For the current obstruction model, read [`WALL.md`](WALL.md).
- For dated numeric evidence, read [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).
- For how to run the scripts behind those claims, read
  [`experiments/README.md`](experiments/README.md).
