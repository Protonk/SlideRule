Purpose: define and explain the approximation wall seen in shared-delta optimization on the legacy `uniform_x` baseline and its partition-dependent extensions
Canonical for: the current obstruction model and its decomposition
Not for: the repo-level thesis, run logs, or full sweep tables

# Wall

## Role in the current program

Most baseline evidence in this file comes from the legacy exact `uniform_x`
path. The wall is not the repo's main claim. It is the diagnostic model for
understanding how the baseline fails, and it becomes directly load-bearing when
`L3` asks whether the same decomposition survives across partition geometries.

## Definition

The wall is the persistent gap

`gap = opt_err - free_err`

between:

- `opt_err`: the best worst-case error achieved by a shared-delta FSM policy
- `free_err`: the free-per-cell lower bound obtained by optimizing intercepts
  independently on each leaf

The wall is the amount of error forced by shared structure after optimizer
quality has already been accounted for.

## What the wall is not

- It is not primarily a solver bug. The LP-based solver outperforms the earlier
  heuristic search and the dyadic loss is tracked explicitly.
- It is not the same thing as the single-intercept baseline. `single_err` tells
  us whether an FSM helps at all; the wall asks why the shared FSM still stops
  above the free-per-cell floor.

## Current decomposition

The current baseline model has three nested constraints.

### 1. Exponential cell growth

- The number of leaves is `2^depth`.
- The layer-invariant shared policy has only `1 + 2q` parameters.
- The layer-dependent shared policy has `1 + 2q * depth` parameters.

At shallow depth, adding states can make the parameter budget comparable to the
cell count. At larger depth, cell growth outruns both parameterizations.

### 2. Layer sharing

- In the layer-invariant model, the same `delta[(state, bit)]` table is reused
  at every depth.
- That forces one correction law to serve both coarse and fine positional
  effects.

Current evidence says this is the dominant source of the wall in the benchmark
cases that have been compared directly.

### 3. Automaton coupling

- Even the layer-dependent model does not assign one free intercept per leaf.
- It assigns corrections to `(layer, state, bit)` triples, and many leaves reuse
  those same triples.

So some coupling remains even after layer sharing is removed.

## Current evidence

Unless marked otherwise, the evidence below is on the legacy `uniform_x`
baseline.

### Parameter budget can nearly remove the wall at shallow depth

At depth 4, increasing `q` in the layer-invariant model drives `opt_err` very
close to `free_err`. This says the baseline wall is not absolute at small
depth; it is strongly tied to parameter budget.

### Layer sharing is a large part of the wall at the tested benchmark points

At `(q, d) = (5, 6)`:

- layer-invariant gap: `0.031986`
- layer-dependent gap: `0.009364`

This is a large reduction, so the current best explanation is that reusing one
delta table across all layers is the main obstruction in the layer-invariant
baseline model.

### Residual coupling remains after layer dependence is introduced

The layer-dependent model still does not reach `free_err` in the tested cases.
That residual is the current evidence for a second wall coming from the
residue-state basis itself.

### First partition-dependent evidence (2026-03-11)

The first lodestone partition-comparison sweep tests the wall on both
`uniform_x` and `geometric_x`. Key observations at (q=3, d=6), target exponent 1/2:

- Layer-invariant gap: uniform 0.03601, geometric 0.03976.
- Layer-dependent gap: uniform 0.02176, geometric 0.01998.
- Gap reduction from layer dependence: ~40% (uniform), ~50% (geometric).

Layer sharing is the dominant wall source for both partition kinds at this
depth. The geometric partition has a larger layer-invariant gap but a smaller
layer-dependent residual, suggesting that the sharing penalty interacts
differently with the two cell geometries.

The gap is also consistently larger on geometric across the full depth sweep
(q=5, d=3..6) in the layer-invariant model, which is why L1b is not generally
supported. See [`HYPOTHESES.md`](HYPOTHESES.md) for the L1a/L1b/L1c
subdivision and [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md) for the dated sweep
summary.

## Working interpretation

The wall is currently best understood as:

1. a parameter-budget issue at shallow depth
2. mostly a layer-sharing issue at the tested deeper benchmark points
3. secondarily an automaton-coupling issue once layer sharing is removed

This is a case-based decomposition, not yet a theorem.

## Open edges

- Does the residual automaton-coupling wall shrink predictably with larger `q`
  in the layer-dependent model?
- Do the same decompositions hold away from `exponent = 1/2`?
- Do the same decompositions survive on `uniform_x`, or does
  cell-difficulty imbalance become dominant there?
- Is there a clean scaling law in the parameter-to-cell ratio that captures both
  the layer-invariant and layer-dependent models?

## Reading outward

- For the repo-level thesis and why partition choice matters, read
  [`LODESTONE.md`](LODESTONE.md).
- For status labels and next tests, read [`HYPOTHESES.md`](HYPOTHESES.md).
- For the sweep tables and dated observations behind this decomposition, read
  [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).
