Purpose: dated summaries of important experiment runs
Canonical for: what was run, what the numbers were, and which artifacts were produced
Not for: evergreen conceptual definitions, the repo-level thesis, or the causal model behind the wall

# Sweep Reports

Explanations belong in [`LODESTONE.md`](LODESTONE.md) and
[`WALL.md`](WALL.md). This file is for dated empirical box scores.

## Current coverage

- Legacy `uniform_x` baseline sweeps (2026-03-09).
- First direct `L1`–`L3` partition-comparison sweep (2026-03-11).
- L1c grid sweep: layer-dependent comparison across (q, depth) (2026-03-12).
- L1c stability sweep: q=3 depth fill and initial alpha=1/3 robustness
  (2026-03-12).
- Harmonic diagnostic sweep: reciprocal and mirrored-reciprocal controls
  (2026-03-12).

## 2026-03-09 — Baseline minimax sweep

Driver:

- [`experiments/lodestone/optimize_delta.sage`](experiments/lodestone/optimize_delta.sage)

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

- [`experiments/lodestone/h1_sweep.sage`](experiments/lodestone/h1_sweep.sage)

Artifacts:

- [`experiments/lodestone/results/h1b_depth_scaling.csv`](experiments/lodestone/results/h1b_depth_scaling.csv)
- [`experiments/lodestone/results/h1a_gap_vs_q.csv`](experiments/lodestone/results/h1a_gap_vs_q.csv)
- [`experiments/lodestone/results/h1c_layer_dependent.csv`](experiments/lodestone/results/h1c_layer_dependent.csv)

Role in current program:

- This is the legacy `uniform_x` baseline sweep. It supports `H1` directly and
  provides the historical context against which the lodestone comparison runs
  should be read.

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

## 2026-03-11 — Lodestone partition-comparison sweep

Driver:

- [`experiments/lodestone/lodestone_sweep.sage`](experiments/lodestone/lodestone_sweep.sage)

Artifacts:

- [`experiments/lodestone/results/lodestone_summary.csv`](experiments/lodestone/results/lodestone_summary.csv)
- [`experiments/lodestone/results/lodestone_percell.csv`](experiments/lodestone/results/lodestone_percell.csv)

Role in current program:

- This is the first direct test of `L1`–`L3`. It compares `uniform_x` and
  `geometric_x` partitions under the same optimizer, FSM parameterization, and
  objective.

### Sweep 1 — Depth scaling at fixed q=5, alpha=1/2

| kind | d | opt_err | free_err | gap | improve |
|------|---|---------|----------|-----|---------|
| uniform_x | 3 | 0.019391 | 0.019267 | 0.000124 | 0.028628 |
| geometric_x | 3 | 0.014812 | 0.014571 | 0.000240 | 0.033207 |
| uniform_x | 4 | 0.022005 | 0.010423 | 0.011582 | 0.026014 |
| geometric_x | 4 | 0.023075 | 0.007554 | 0.015521 | 0.024943 |
| uniform_x | 5 | 0.024053 | 0.005420 | 0.018633 | 0.023966 |
| geometric_x | 5 | 0.029850 | 0.003842 | 0.026007 | 0.018169 |
| uniform_x | 6 | 0.034749 | 0.002763 | 0.031986 | 0.013270 |
| geometric_x | 6 | 0.037989 | 0.001937 | 0.036051 | 0.010030 |

Direct observations:

- Geometric `free_err` is strictly lower at every depth (L1a).
- Geometric `opt_err` exceeds uniform at d>=4 (L1b against).
- The gap grows faster on geometric, indicating a larger sharing penalty.

### Sweep 2 — q scaling at fixed depth=4, alpha=1/2

| kind | q | opt_err | free_err | gap |
|------|---|---------|----------|-----|
| uniform_x | 1 | 0.041081 | 0.010423 | 0.030658 |
| geometric_x | 1 | 0.039032 | 0.007554 | 0.031478 |
| uniform_x | 2 | 0.027826 | 0.010423 | 0.017403 |
| geometric_x | 2 | 0.031006 | 0.007554 | 0.023452 |
| uniform_x | 3 | 0.031873 | 0.010423 | 0.021450 |
| geometric_x | 3 | 0.033031 | 0.007554 | 0.025477 |
| uniform_x | 5 | 0.022005 | 0.010423 | 0.011582 |
| geometric_x | 5 | 0.023075 | 0.007554 | 0.015521 |
| uniform_x | 7 | 0.017546 | 0.010423 | 0.007124 |
| geometric_x | 7 | 0.013679 | 0.007554 | 0.006125 |

Direct observations:

- At q=7, geometric wins on both `opt_err` and `gap`.
- At q=2, 3, 5, uniform has lower `opt_err` despite higher `free_err`.
- The crossover suggests that sufficient parameter budget can overcome the
  sharing penalty on geometric cells.

### Sweep 3 — Layer-dependent vs layer-invariant at (q=3, d=6)

| kind | mode | opt_err | free_err | gap | gap reduction |
|------|------|---------|----------|-----|---------------|
| uniform_x | layer-inv | 0.038776 | 0.002763 | 0.036013 | — |
| geometric_x | layer-inv | 0.041699 | 0.001937 | 0.039761 | — |
| uniform_x | layer-dep | 0.024520 | 0.002763 | 0.021757 | 39.6% |
| geometric_x | layer-dep | 0.021915 | 0.001937 | 0.019978 | 49.7% |

Direct observations:

- Layer-dependent deltas reduce the gap substantially for both partition kinds.
- Under layer dependence, geometric beats uniform (L1c supported at this point).
- Geometric gets a larger gap reduction (~50% vs ~40%), suggesting the sharing
  penalty is more concentrated in the layer-sharing source for geometric cells.

### Sweep 4 — Alpha=1/3 checkpoint (q=3, d=4)

| kind | opt_err | free_err | gap |
|------|---------|----------|-----|
| uniform_x | 0.021534 | 0.006987 | 0.014547 |
| geometric_x | 0.021647 | 0.005056 | 0.016592 |

Direct observations:

- Results are qualitatively similar to alpha=1/2 at this point: geometric has
  lower `free_err` but higher `gap`.

## 2026-03-12 — L1c grid sweep

Driver:

- [`experiments/lodestone/l1c_grid_sweep.sage`](experiments/lodestone/l1c_grid_sweep.sage)

Artifacts:

- [`experiments/lodestone/results/l1c_grid_2026-03-12/summary.csv`](experiments/lodestone/results/l1c_grid_2026-03-12/summary.csv)
- [`experiments/lodestone/results/l1c_grid_2026-03-12/percell.csv`](experiments/lodestone/results/l1c_grid_2026-03-12/percell.csv)
- [`experiments/lodestone/results/l1c_grid_2026-03-12/README.md`](experiments/lodestone/results/l1c_grid_2026-03-12/README.md)

Role in current program:

- This is the follow-up test of L1c, checking whether the geometric advantage
  under layer-dependent sharing holds beyond the single (q=3, d=6) benchmark.

### Stage 1 — (q=3, d=4), (q=5, d=4), (q=5, d=6), alpha=1/2

| kind | q | d | mode | opt_err | free_err | gap | gap reduction |
|------|---|---|------|---------|----------|-----|---------------|
| uniform_x | 3 | 4 | layer-inv | 0.031873 | 0.010423 | 0.021450 | — |
| geometric_x | 3 | 4 | layer-inv | 0.033031 | 0.007554 | 0.025477 | — |
| uniform_x | 3 | 4 | layer-dep | 0.024510 | 0.010423 | 0.014088 | 34.3% |
| geometric_x | 3 | 4 | layer-dep | 0.021838 | 0.007554 | 0.014284 | 43.9% |
| uniform_x | 5 | 4 | layer-inv | 0.022005 | 0.010423 | 0.011582 | — |
| geometric_x | 5 | 4 | layer-inv | 0.023075 | 0.007554 | 0.015521 | — |
| uniform_x | 5 | 4 | layer-dep | 0.012065 | 0.010423 | 0.001642 | 85.8% |
| geometric_x | 5 | 4 | layer-dep | 0.010251 | 0.007554 | 0.002697 | 82.6% |
| uniform_x | 5 | 6 | layer-inv | 0.034749 | 0.002763 | 0.031986 | — |
| geometric_x | 5 | 6 | layer-inv | 0.037989 | 0.001937 | 0.036051 | — |
| uniform_x | 5 | 6 | layer-dep | 0.012127 | 0.002763 | 0.009364 | 70.7% |
| geometric_x | 5 | 6 | layer-dep | 0.010127 | 0.001937 | 0.008190 | 77.3% |

Direct observations:

- Geometric layer-dependent `opt_err` < uniform layer-dependent `opt_err` at
  all three Stage 1 points.
- Gap reduction from layer dependence is larger on geometric at two of the
  three Stage 1 points, but not at (q=5, d=4).
- At (q=5, d=4), the layer-dependent gap nearly closes on both partition kinds.

### Stage 2 — (q=3, d=8), alpha=1/2

| kind | q | d | mode | opt_err | free_err | gap | gap reduction |
|------|---|---|------|---------|----------|-----|---------------|
| uniform_x | 3 | 8 | layer-inv | 0.044895 | 0.000701 | 0.044194 | — |
| geometric_x | 3 | 8 | layer-inv | 0.046349 | 0.000487 | 0.045862 | — |
| uniform_x | 3 | 8 | layer-dep | 0.024538 | 0.000701 | 0.023837 | 46.1% |
| geometric_x | 3 | 8 | layer-dep | 0.021838 | 0.000487 | 0.021351 | 53.5% |

Direct observations:

- L1c continues to hold at d=8.
- The geometric layer-dependent `opt_err` at (q=3, d=8) matches (q=3, d=4) to
  full precision and is close to, but not identical with, the earlier
  (q=3, d=6) result. This suggests a q=3 floor but does not establish one.
- Uniform layer-dependent `opt_err` is also nearly stable across d=4, 6, 8 at
  q=3 (~0.0245).

## 2026-03-12 — L1c stability sweep

Driver:

- [`experiments/lodestone/l1c_stability_sweep.sage`](experiments/lodestone/l1c_stability_sweep.sage)

Artifacts:

- [`experiments/lodestone/results/l1c_stability_2026-03-12/summary.csv`](experiments/lodestone/results/l1c_stability_2026-03-12/summary.csv)
- [`experiments/lodestone/results/l1c_stability_2026-03-12/percell.csv`](experiments/lodestone/results/l1c_stability_2026-03-12/percell.csv)
- [`experiments/lodestone/results/l1c_stability_2026-03-12/README.md`](experiments/lodestone/results/l1c_stability_2026-03-12/README.md)

Role in current program:

- This is the follow-up to the L1c grid sweep. It fills in the missing q=3
  intermediate depths and adds the first small alpha=1/3 robustness checks.

### Stage 1 — q=3 depth fill at alpha=1/2

| d | uniform_x LD opt_err | geometric_x LD opt_err |
|---|----------------------|------------------------|
| 4 | 0.024510 | 0.021838 |
| 5 | 0.024520 | 0.021864 |
| 6 | 0.024520 | 0.021915 |
| 7 | 0.024630 | 0.021844 |
| 8 | 0.024538 | 0.021838 |

Direct observations:

- Geometric remains better than uniform at every tested q=3 depth.
- The q=3 layer-dependent bands are narrow across d=4..8 on both partition
  kinds.
- Geometric varies by about 7.7e-5 across the full band; uniform varies by
  about 1.2e-4.
- This is stronger evidence for a q=3 layer-dependent floor, though still only
  empirical evidence.

### Stage 2 — alpha=1/3 robustness

| q | d | uniform_x LD opt_err | geometric_x LD opt_err |
|---|---|----------------------|------------------------|
| 3 | 4 | 0.014569 | 0.012381 |
| 5 | 6 | 0.007441 | 0.005819 |

Direct observations:

- L1c survives both tested alpha=1/3 points.
- At both points, geometric also gets the larger gap reduction from introducing
  layer dependence.

## 2026-03-12 — Harmonic diagnostic sweep

Driver:

- [`experiments/lodestone/harmonic_diagnostic_sweep.sage`](experiments/lodestone/harmonic_diagnostic_sweep.sage)

Artifacts:

- [`experiments/lodestone/results/harmonic_diagnostic_2026-03-12/summary.csv`](experiments/lodestone/results/harmonic_diagnostic_2026-03-12/summary.csv)
- [`experiments/lodestone/results/harmonic_diagnostic_2026-03-12/percell.csv`](experiments/lodestone/results/harmonic_diagnostic_2026-03-12/percell.csv)
- [`experiments/lodestone/results/harmonic_diagnostic_2026-03-12/README.md`](experiments/lodestone/results/harmonic_diagnostic_2026-03-12/README.md)

Role in current program:

- This is the corrected redistribution-control test. The initial harmonic
  interpretation was backwards: `harmonic_x` is reciprocal spacing and is
  still finer near `x=1`. The actual opposite-end control is
  `mirror_harmonic_x`, which is finer near `x=2`.
- The point of this sweep is to separate three possibilities:
  - the log-like geometry is unique
  - any x=1-heavy redistribution helps under layer dependence
  - any redistribution at all helps under layer dependence

### Layer-invariant results, alpha=1/2

| kind | q | d | opt_err | free_err | gap |
|------|---|---|---------|----------|-----|
| uniform_x | 3 | 4 | 0.031873 | 0.010423 | 0.021450 |
| geometric_x | 3 | 4 | 0.033031 | 0.007554 | 0.025477 |
| harmonic_x | 3 | 4 | 0.033496 | 0.007685 | 0.025811 |
| mirror_harmonic_x | 3 | 4 | 0.033495 | 0.018303 | 0.015192 |
| uniform_x | 5 | 4 | 0.022005 | 0.010423 | 0.011582 |
| geometric_x | 5 | 4 | 0.023075 | 0.007554 | 0.015521 |
| harmonic_x | 5 | 4 | 0.022495 | 0.007685 | 0.014810 |
| mirror_harmonic_x | 5 | 4 | 0.022183 | 0.018303 | 0.003881 |
| uniform_x | 5 | 6 | 0.034749 | 0.002763 | 0.031986 |
| geometric_x | 5 | 6 | 0.037989 | 0.001937 | 0.036051 |
| harmonic_x | 5 | 6 | 0.038901 | 0.002225 | 0.036676 |
| mirror_harmonic_x | 5 | 6 | 0.027559 | 0.005339 | 0.022219 |
| uniform_x | 3 | 8 | 0.044895 | 0.000701 | 0.044194 |
| geometric_x | 3 | 8 | 0.046349 | 0.000487 | 0.045862 |
| harmonic_x | 3 | 8 | 0.047126 | 0.000577 | 0.046550 |
| mirror_harmonic_x | 3 | 8 | 0.043617 | 0.001390 | 0.042227 |

Direct observations:

- The original three-way statement “uniform wins everywhere under LI” was only
  true before the actual opposite-end control was added.
- `mirror_harmonic_x` is already competitive at `(q=5, d=4)` and is best at
  the tested deeper points `(q=5, d=6)` and `(q=3, d=8)`.
- Under LI sharing, the control picture is therefore the opposite of the old
  “any redistribution helps” story: the x=2-heavy partition can outperform
  both x=1-heavy partitions and uniform at deeper points.

### Layer-dependent results, alpha=1/2

| kind | q | d | opt_err | free_err | gap |
|------|---|---|---------|----------|-----|
| uniform_x | 3 | 4 | 0.024510 | 0.010423 | 0.014088 |
| geometric_x | 3 | 4 | 0.021838 | 0.007554 | 0.014284 |
| harmonic_x | 3 | 4 | 0.019220 | 0.007685 | 0.011535 |
| mirror_harmonic_x | 3 | 4 | 0.028325 | 0.018303 | 0.010022 |
| uniform_x | 5 | 4 | 0.012065 | 0.010423 | 0.001642 |
| geometric_x | 5 | 4 | 0.010251 | 0.007554 | 0.002697 |
| harmonic_x | 5 | 4 | 0.010910 | 0.007685 | 0.003225 |
| mirror_harmonic_x | 5 | 4 | 0.018968 | 0.018303 | 0.000665 |
| uniform_x | 5 | 6 | 0.012127 | 0.002763 | 0.009364 |
| geometric_x | 5 | 6 | 0.010127 | 0.001937 | 0.008190 |
| harmonic_x | 5 | 6 | 0.011029 | 0.002225 | 0.008803 |
| mirror_harmonic_x | 5 | 6 | 0.019016 | 0.005339 | 0.013676 |
| uniform_x | 3 | 8 | 0.024538 | 0.000701 | 0.023837 |
| geometric_x | 3 | 8 | 0.021838 | 0.000487 | 0.021351 |
| harmonic_x | 3 | 8 | 0.019220 | 0.000577 | 0.018643 |
| mirror_harmonic_x | 3 | 8 | 0.028325 | 0.001390 | 0.026935 |

### Rankings under layer dependence

| q | d | 1st (best) | 2nd | 3rd | 4th (worst) |
|---|---|------------|-----|-----|-------------|
| 3 | 4 | harmonic_x (0.01922) | geometric_x (0.02184) | uniform_x (0.02451) | mirror_harmonic_x (0.02833) |
| 5 | 4 | geometric_x (0.01025) | harmonic_x (0.01091) | uniform_x (0.01207) | mirror_harmonic_x (0.01897) |
| 5 | 6 | geometric_x (0.01013) | harmonic_x (0.01103) | uniform_x (0.01213) | mirror_harmonic_x (0.01902) |
| 3 | 8 | harmonic_x (0.01922) | geometric_x (0.02184) | uniform_x (0.02454) | mirror_harmonic_x (0.02833) |

Direct observations:

- `harmonic_x` and `geometric_x` both beat `uniform_x` at all tested
  layer-dependent points.
- The actual opposite-end control `mirror_harmonic_x` loses to `uniform_x` at
  all tested layer-dependent points.
- So the broad claim “any redistribution helps under LD sharing” is false.
  Direction matters.
- Within the x=1-heavy family, the ranking is q-dependent: harmonic wins at
  q=3, geometric wins at q=5.
- Note: harmonic `opt_err` at q=3 is identical at d=4 and d=8 (0.019220),
  mirroring the q=3 floor pattern seen in the stability sweep for geometric.

## Where to look next

- For the guiding thesis and the still-missing direct tests, read
  [`LODESTONE.md`](LODESTONE.md).
- For the current status labels, read [`HYPOTHESES.md`](HYPOTHESES.md).
- For the current explanation of the wall, read [`WALL.md`](WALL.md).
