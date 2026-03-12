Purpose: dated summaries of important experiment runs
Canonical for: what was run, what the numbers were, and which artifacts were produced
Not for: evergreen conceptual definitions, the repo-level thesis, or the causal model behind the wall

# Sweep Reports

Explanations belong in [`LODESTONE.md`](LODESTONE.md) and
[`WALL.md`](WALL.md). This file is for dated empirical box scores.

## Current coverage

- All recorded sweeps so far are on the dyadic/geometric partition.
- No direct `L1`-`L3` partition-comparison run has been recorded yet.

## 2026-03-09 — Baseline minimax sweep

Driver:

- [`experiments/optimize_delta.sage`](experiments/optimize_delta.sage)

Scope:

- `alpha = 1/2`
- layer-invariant shared-delta model
- 10 cases covering `q in {1, 2, 3, 5}` and depths `4, 6, 8` plus the extra
  `(q, d) = (5, 4)` and `(5, 6)` detail lines

Box-score findings:

- `improve = single_err - opt_err` was positive in all tested cases.
- The best finite-case improvement was at shallow depth and larger `q`.
- `pat#` stayed tiny under the minimax objective, which is why H2 was retired.
- The detailed optimizer dump exposed dyadic loss explicitly.

Artifacts:

- Script output was terminal-only for this baseline run.
- Follow-on H1 sweep artifacts below supersede it for most current questions.

## 2026-03-09 — H1 sweep

Driver:

- [`experiments/h1_sweep.sage`](experiments/h1_sweep.sage)

Artifacts:

- [`experiments/results/h1b_depth_scaling.csv`](experiments/results/h1b_depth_scaling.csv)
- [`experiments/results/h1a_gap_vs_q.csv`](experiments/results/h1a_gap_vs_q.csv)
- [`experiments/results/h1c_layer_dependent.csv`](experiments/results/h1c_layer_dependent.csv)

Role in current program:

- This is the dyadic baseline sweep. It supports `H1` directly and provides the
  prerequisite comparisons needed before `L2` and `L3` can be tested across
  partition types.

### Sweep 1 — H1b: depth scaling at fixed q

Question:

- Does `improve / single_err` stabilize away from zero, or decay?

Parameters:

- `alpha = 1/2`
- `q = 5`
- `depth = 4..10`

| d | #params | #cells | single_err | opt_err | free_err | imp/sgl | gap |
|---|---------|--------|------------|---------|----------|---------|-----|
| 4 | 11 | 16 | 0.048019 | 0.022005 | 0.010423 | 0.5418 | 0.011582 |
| 5 | 11 | 32 | 0.048019 | 0.024053 | 0.005420 | 0.4991 | 0.018633 |
| 6 | 11 | 64 | 0.048019 | 0.034749 | 0.002763 | 0.2763 | 0.031986 |
| 7 | 11 | 128 | 0.048019 | 0.041091 | 0.001395 | 0.1443 | 0.039696 |
| 8 | 11 | 256 | 0.048019 | 0.044799 | 0.000701 | 0.0670 | 0.044098 |
| 9 | 11 | 512 | 0.048019 | 0.046537 | 0.000352 | 0.0309 | 0.046186 |
| 10 | 11 | 1024 | 0.048019 | 0.047405 | 0.000176 | 0.0128 | 0.047229 |

Direct observation:

- `improve / single_err` decays strongly with depth in the layer-invariant
  model.

### Sweep 2 — H1a: q scaling at fixed depth

Question:

- Does the gap close as the parameter budget grows relative to the cell count?

Parameters:

- `alpha = 1/2`
- `depth = 4`
- `q = 1, 2, 3, 5, 7, 9, 11, 13, 15`

| q | #params | #cells | opt_err | free_err | gap | imp/avl |
|---|---------|--------|---------|----------|-----|---------|
| 1 | 3 | 16 | 0.041081 | 0.010423 | 0.030658 | 0.1845 |
| 2 | 5 | 16 | 0.027826 | 0.010423 | 0.017403 | 0.5371 |
| 3 | 7 | 16 | 0.031873 | 0.010423 | 0.021450 | 0.4294 |
| 5 | 11 | 16 | 0.022005 | 0.010423 | 0.011582 | 0.6919 |
| 7 | 15 | 16 | 0.017546 | 0.010423 | 0.007124 | 0.8105 |
| 9 | 19 | 16 | 0.010783 | 0.010423 | 0.000360 | 0.9904 |
| 11 | 23 | 16 | 0.010783 | 0.010423 | 0.000360 | 0.9904 |
| 13 | 27 | 16 | 0.010783 | 0.010423 | 0.000360 | 0.9904 |
| 15 | 31 | 16 | 0.010783 | 0.010423 | 0.000360 | 0.9904 |

Direct observations:

- The layer-invariant gap closes rapidly as `q` increases at fixed shallow
  depth.
- The sweep saturates by `q = 9` in this particular `depth = 4` run.
- The small `q = 3` non-monotonicity is present in this shallow regime.

### Sweep 3 — H1c: layer-dependent vs layer-invariant

Question:

- How much does removing layer sharing reduce the wall?

Parameters:

- `alpha = 1/2`
- benchmark cases `(q, d) = (3, 6)` and `(5, 6)`
- both layer-invariant and layer-dependent runs

| q | d | mode | #params | #cells | opt_err | gap | imp/avl | gap reduction |
|---|---|------|---------|--------|---------|-----|---------|---------------|
| 3 | 6 | layer-inv | 7 | 64 | 0.038776 | 0.036013 | 0.2042 | — |
| 3 | 6 | layer-dep | 37 | 64 | 0.024520 | 0.021757 | 0.5193 | 39.6% |
| 5 | 6 | layer-inv | 11 | 64 | 0.034749 | 0.031986 | 0.2932 | — |
| 5 | 6 | layer-dep | 61 | 64 | 0.012127 | 0.009364 | 0.7931 | 70.7% |

Direct observations:

- Layer-dependent deltas outperform layer-invariant deltas in both benchmark
  cases.
- The larger parameter-to-cell ratio at `(q, d) = (5, 6)` coincides with a much
  smaller residual gap.

### H1d readout

Question:

- What shape does the optimized delta table take?

Direct observations:

- Layer-invariant solutions are moderately concentrated.
- Layer-dependent solutions are diffuse and use broad support.
- In the `q` sweep, support broadens as `q` grows.

## Where to look next

- For the guiding thesis and the still-missing direct tests, read
  [`LODESTONE.md`](LODESTONE.md).
- For the current status labels, read [`HYPOTHESES.md`](HYPOTHESES.md).
- For the current explanation of the wall, read [`WALL.md`](WALL.md).
