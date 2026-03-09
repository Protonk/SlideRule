Purpose: define and explain the approximation wall seen in shared-delta optimization
Canonical for: the current obstruction model and its decomposition
Not for: run logs, command usage, or full sweep tables

# Wall

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

The current model has three nested constraints.

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

### Parameter budget can nearly remove the wall at shallow depth

At depth 4, increasing `q` in the layer-invariant model drives `opt_err` very
close to `free_err`. This says the wall is not absolute at small depth; it is
strongly tied to parameter budget.

### Layer sharing is a large part of the wall at the tested benchmark points

At `(q, d) = (5, 6)`:

- layer-invariant gap: `0.031986`
- layer-dependent gap: `0.009364`

This is a large reduction, so the current best explanation is that reusing one
delta table across all layers is the main obstruction in the layer-invariant
model.

### Residual coupling remains after layer dependence is introduced

The layer-dependent model still does not reach `free_err` in the tested cases.
That residual is the current evidence for a second wall coming from the
residue-state basis itself.

## Working interpretation

The wall is currently best understood as:

1. a parameter-budget issue at shallow depth
2. mostly a layer-sharing issue at the tested deeper benchmark points
3. secondarily an automaton-coupling issue once layer sharing is removed

This is a case-based decomposition, not yet a theorem.

## Open edges

- Does the residual automaton-coupling wall shrink predictably with larger `q`
  in the layer-dependent model?
- Do the same decompositions hold away from `alpha = 1/2`?
- Is there a clean scaling law in the parameter-to-cell ratio that captures both
  the layer-invariant and layer-dependent models?

## Reading outward

- For status labels and next tests, read [`HYPOTHESES.md`](HYPOTHESES.md).
- For the sweep tables and dated observations behind this decomposition, read
  [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).
