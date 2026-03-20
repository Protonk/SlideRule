# Keystone partition-comparison sweep

Date: 2026-03-11
Driver: `partition_sweep.sage`
Scope: first direct K1–K3 test comparing `uniform_x` and `geometric_x`
under the same optimizer, FSM parameterization, and objective.
Exponent: `1/2`

## Sweep 1 — Depth scaling at fixed q=5

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

- Geometric `free_err` is strictly lower at every depth (K1a).
- Geometric `opt_err` exceeds uniform at d>=4 (K1b against).
- The gap grows faster on geometric, indicating a larger sharing penalty.

## Sweep 2 — q scaling at fixed depth=4

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

## Sweep 3 — Layer-dependent vs layer-invariant at (q=3, d=6)

| kind | mode | opt_err | free_err | gap | gap reduction |
|------|------|---------|----------|-----|---------------|
| uniform_x | layer-inv | 0.038776 | 0.002763 | 0.036013 | — |
| geometric_x | layer-inv | 0.041699 | 0.001937 | 0.039761 | — |
| uniform_x | layer-dep | 0.024520 | 0.002763 | 0.021757 | 39.6% |
| geometric_x | layer-dep | 0.021915 | 0.001937 | 0.019978 | 49.7% |

Direct observations:

- Layer-dependent deltas reduce the gap substantially for both partition kinds.
- Under layer dependence, geometric beats uniform (K1c supported at this point).
- Geometric gets a larger gap reduction (~50% vs ~40%), suggesting the sharing
  penalty is more concentrated in the layer-sharing source for geometric cells.

## Sweep 4 — Alpha=1/3 checkpoint (q=3, d=4)

| kind | opt_err | free_err | gap |
|------|---------|----------|-----|
| uniform_x | 0.021534 | 0.006987 | 0.014547 |
| geometric_x | 0.021647 | 0.005056 | 0.016592 |

Direct observations:

- Results are qualitatively similar to exponent_t=1/2 at this point: geometric has
  lower `free_err` but higher `gap`.
