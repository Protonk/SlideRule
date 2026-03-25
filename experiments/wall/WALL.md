Purpose: define and explain the approximation wall seen in shared-delta optimization on the legacy `uniform_x` baseline and its partition-dependent extensions
Canonical for: the current obstruction model and its decomposition
Not for: the repo-level thesis, run logs, or full sweep tables

# Wall

## Role in the current program

Most baseline evidence in this file comes from the legacy exact `uniform_x`
path. The wall is not the repo's main claim. It is the diagnostic model for
understanding how the baseline fails, and it becomes directly load-bearing when
`K3` asks whether the same decomposition survives across partition geometries.

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

- It is not a solver bug. The LP-based solver outperforms the earlier
  heuristic search and the dyadic loss is tracked explicitly. The solver
  is finding the best solution within the FSM family.
- It is not the same thing as the single-intercept baseline. `single_err`
  tells us whether an FSM helps at all; the wall asks why the shared FSM
  still stops above the free-per-cell floor.
- It is not necessarily intrinsic to the approximation problem. The
  displacement analysis (2026-03-21) shows early-layer fan-out is the
  dominant source of the wall — layer 0's binary split does not
  decompose along log-equivariant lines. The residual LD wall shows
  that the full path algebra and automaton coupling remain part of
  the story after the top-level fan-out mode is partially corrected.
  But the wall as a whole is a cost of the FSM's binary decomposition,
  not a proven lower bound on shared-structure approximation in
  general.

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

Current evidence says this is the dominant source of the wall across all tested
partition kinds and exponents (1/3, 1/2, 2/3).

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

### Partition-dependent evidence (2026-03-11)

At (q=3, d=6, exp=1/2): LI gap is uniform 0.036, geometric 0.040; LD gap
is uniform 0.022, geometric 0.020. Gap reduction from layer dependence:
~40% (uniform), ~50% (geometric). Geometric has a larger LI gap but a
smaller LD residual, suggesting the sharing penalty interacts differently
with the two cell geometries. See [`EXPERIMENTS.md`](../EXPERIMENTS.md)
for the K1a/K1b/K1c subdivision.

### Exponent robustness (2026-03-20)

160-case sweep across exponents 1/3 and 2/3 (4 kinds x 5 depths x 2 q x
2 layer modes). The wall decomposition survives at both exponents:

- Layer sharing remains the dominant wall source for uniform, geometric,
  and harmonic. Median wall fraction (LI→LD reduction): ~67–75% at
  exponent 1/3, ~43–60% at exponent 2/3. The decomposition is
  exponent-dependent in magnitude but not in direction.
- Mirror_harmonic is a systematic outlier: wall fraction ~40% at both
  exponents, roughly half the benefit that other kinds receive from LD.
- Under LD, x=1-heavy partitions (geometric, harmonic) beat uniform at
  both exponents, confirming K1c. Mirror_harmonic loses to uniform under
  LD except at exponent 2/3, q=3, d=4–6, where it unexpectedly wins
  (crossover at d=7).
- LD gap saturates with depth: by d=7–8, successive depth increments add
  only ~5% more gap. The residual appears to approach a constant
  determined by cell geometry.

See `results/exponent_robustness_2026-03-20/summary.csv`.

### The wall is not pairwise chord displacement (2026-03-21)

The damage-vs-wall experiment (`damage_vs_wall.sage`) built a
foreign-intercept excess matrix F[j][k] measuring how much worse
cell k gets when forced to use cell j's free intercept. The best
non-self donor excess for each cell is small — neighboring cells'
free intercepts are nearly interchangeable. But the FSM's shared
intercept causes wall excess 10–17x larger than the best-donor
excess.

This means adjacent cells are not in conflict: their free optima
are similar. The wall is caused by the FSM path algebra imposing a
global distortion pattern that pushes every cell's intercept far from
its optimum simultaneously. No single-donor model captures this.

Key numbers at (geometric, q=3, d=6, exp=1/2):
- LI: mitigation fraction 3%, normalized total value-add −16.6
- LD: mitigation fraction 5%, normalized total value-add −10.7

See `results/exchange_rate/`.

### Displacement is a fan-out problem at early layers (2026-03-21)

The displacement pattern `c_shared - c_free` across cells has strong
spatial structure. Under LI, displacement correlates with cell position
(r=0.57 geometric, r=0.39 uniform) — the optimizer creates a
systematic sweep, pushing low cells negative and high cells positive.
Under LD, this correlation vanishes (r≈0), because later layers can
partially correct the early-layer distortion.

The mechanism: layer 0's delta serves all 2^d cells. No single value
works well for all of them, so it imposes a systematic positional
displacement. Later layers have finer sharing granularity but cannot
fully undo the distortion because they too are constrained by the
state-transition graph. LD helps by letting layers 2–4 pull back
(negative mean contributions), cutting the displacement range roughly
in half — matching the ~50% wall fraction reduction.

Final residue state does NOT explain displacement: all states have
nearly identical displacement statistics. The wall is a fan-out
problem, not a state-assignment problem.

See `results/exchange_rate/displacement_structure.png`.

## Working interpretation

The wall is currently best understood as:

1. a parameter-budget issue at shallow depth
2. mostly a layer-sharing issue at the tested deeper benchmark points
3. secondarily an automaton-coupling issue once layer sharing is removed
4. NOT a pairwise chord-displacement cost — the FSM path algebra
   imposes a structured distortion pattern
5. mechanistically, a fan-out problem at the early layers: layer 0
   must serve all cells, creating systematic positional displacement
   that later layers can only partially correct

This is a case-based decomposition, not yet a theorem.

## Open edges

- How does the layer-0 fan-out scale with depth and q? Does the
  displacement range grow, shrink, or stabilize?
- Does the residual automaton-coupling wall shrink predictably with
  larger `q` in the layer-dependent model?
- Is there a clean scaling law in the parameter-to-cell ratio?
- Does sign-sequence structure predict wall properties? (Future E5.)

## Reading outward

- For the repo-level thesis and why partition choice matters, read
  [`KEYSTONE.md`](../aft/keystone/KEYSTONE.md).
- For status labels and next tests, read [`EXPERIMENTS.md`](../EXPERIMENTS.md).
- For the sweep tables and dated observations behind this decomposition, see
  the run-level reports inside [`keystone/results/`](../aft/keystone/results/).
