# Distant Shores

Purpose: sketch a transformation from the triangle inequality to a computable
measure of computational cost of departure from a log-linear surrogate.
This is a roadmap, not a proof. Six steps, two gnomes.

Reading inward: depends on [`KEYSTONE.md`](KEYSTONE.md) for the
scale-symmetry thesis and [`WALL.md`](WALL.md) for the wall decomposition.

---

## Step 1. Computable reference triangle

Let L(x) be the affine pseudo-log, APPROX(x) any piecewise approximation to
log₂(x), and ε(m) = log₂(1+m) − m the departure of truth from surrogate on
the unit mantissa interval.

The triangle inequality gives

    |APPROX − log₂| ≤ |APPROX − L| + |L − log₂|

where:

- The first term is computable: both APPROX and L are available.
- The second term is known: it is ε(m), a fixed smooth function on [0,1),
  independent of the approximation.

This decomposes the inaccessible comparison (APPROX vs. truth) into a
computable comparison (APPROX vs. surrogate) plus a known budget (surrogate
vs. truth). Nothing here is new. What matters is that the decomposition is
*exact*, not itself an approximation — the two terms share no degrees of
freedom.

## Step 2. The geometric grid is the zero-cost baseline

L(x) is exact at every integer power of 2. These are the points where the
surrogate touches truth, and they are the boundaries of the dyadic partition.
Equivalently: a geometric grid in x-space (equal log-width cells) is the
unique partition whose boundaries lie on the exactness lattice of L.

Between grid points, ε(m) is the cost of using L instead of log₂. This cost
is paid by the representation itself — it requires no machinery, no
parameters, no state. It is what you get for free from scale symmetry and a
number format designed to be neutral under the reciprocal measure.

Any correction that reduces ε must be assembled from something that ε does not
provide. The question is what that something costs.

## Step 3. Corrections under shared structure live in a low-rank subspace

Partition [1,2) into 2^d cells. Each cell wants a correction δ_j that brings
the local chord closer to log₂ than L's chord provides. The vector of ideal
corrections δ* = (δ*_1, ..., δ*_{2^d}) is the free-per-cell optimum — one
free parameter per cell, no sharing.

An FSM with q states, processing d bits, generates a correction vector δ by
accumulating shared delta-table entries along each cell's bit path. The set of
achievable δ vectors is the image of a linear map from the parameter space
(dimension O(q) layer-invariant, O(qd) layer-dependent) into ℝ^{2^d}. Call
this image S — a low-dimensional subspace when the parameter count is much
less than the cell count.

The achievable corrections are exactly the points of S. The best shared
correction is the point in S closest to δ* under the minimax norm. This is
what the LP already computes.

## Step 4. The wall is a projection distance; the decomposition indexes nested subspaces

The wall = opt_err − free_err is the distance from δ* to the nearest point in
S, measured in the minimax norm on cell errors. It is a projection distance: a
geometric quantity determined by the angle between the target and the
achievable subspace.

The three wall sources correspond to three nested subspace inclusions:

    S_LI ⊂ S_LD ⊂ ℝ^{2^d}

where S_LI is the layer-invariant subspace (dim O(q)), S_LD is the
layer-dependent subspace (dim O(qd)), and ℝ^{2^d} is the free-per-cell space.

- Parameter budget: dim(S) ≪ 2^d. The subspace is thin.
- Layer sharing: S_LI ⊂ S_LD is a proper inclusion. The layer-invariant
  subspace is unnecessarily constrained.
- Automaton coupling: S_LD ⊂ ℝ^{2^d} is a proper inclusion. Even
  layer-dependent parameters are coupled by the state-transition graph.

Each inclusion adds distance from the target. The wall decomposition measures
how much distance each inclusion contributes. This is what the current
experiments quantify.

## Step 5. [GNOMES] The projection distance scales predictably with structural cost

Define a cost measure C on correction machinery: some function of parameter
count, sharing depth, and automaton topology. The wall decomposition gives
empirical data points (C, gap) for several configurations.

The claim needed here: these data points trace a curve with recognizable
scaling behavior. The gap-per-unit-cost — the exchange rate between structural
investment and approximation quality — has a well-defined functional form, at
least within the FSM family.

This is gnomes because:

- We do not yet have enough (C, gap) data to distinguish functional forms
  (power law? logarithmic? piecewise with a phase transition?).
- The wall evidence so far shows a plateau structure (cheap initial gains, then
  a sharing-induced cliff), which suggests the rate may not be smooth.
- Even within the FSM family, the rate might depend on the target function
  (alpha), the partition geometry, and the depth in ways that resist a single
  scaling law.

What would resolve this step: either a theorem relating subspace codimension
to minimax projection distance for the specific subspace structure the FSM
generates, or enough empirical data across (q, d, alpha, partition) to fit
a stable curve. The K1–K3 experiments are partial evidence but not yet
sufficient.

## Step 6. [GNOMES] The cost measure is a property of the problem, not the architecture

Given the rate from Step 5, define:

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

where the minimum is over correction machinery M (FSMs, lookup tables,
polynomial evaluators, or anything else) and C is the cost measure.

This is the computational ruler: the minimum structural cost to achieve
tolerance τ in departure from L, measured not in error magnitude but in the
machinery required to produce corrections beyond what L provides for free.

This is gnomes because:

- The rate from Step 5 is FSM-specific. A lookup table, a piecewise
  polynomial, or a different automaton topology would each have its own
  (C, gap) curve. For d_comp to be a property of the *approximation problem*
  rather than the *implementation*, the infimum over architectures must be
  well-defined and the FSM rate must be close to it (or at least informative
  about it).
- This is an architecture-invariance claim. It requires either showing that
  the FSM is near-optimal among low-cost correction strategies, or defining C
  abstractly enough (e.g., in bits of state, or circuit depth) that different
  architectures become commensurable.
- The De Caro MILP work (shared-coefficient piecewise-polynomial evaluation)
  is structurally analogous and might provide a second architecture to
  calibrate against, but this comparison has not been done.

What would resolve this step: a second architecture class (piecewise
polynomial with shared coefficients is the natural candidate) producing a
(C, gap) curve that, after appropriate normalization, aligns with the FSM
curve — or provably diverges, which would also be informative.

---

## Summary

| Step | Status | Content |
|------|--------|---------|
| 1 | Done | Triangle inequality; APPROX−L computable, ε known |
| 2 | Done | Geometric grid = zero-cost baseline from scale symmetry |
| 3 | Done | Shared-structure corrections live in a low-rank subspace |
| 4 | Done | Wall = projection distance; decomposition = nested subspaces |
| 5 | [GNOMES] | Projection distance scales predictably with cost measure |
| 6 | [GNOMES] | Cost measure is architecture-invariant → computational ruler |

The path from 1–4 is fair. Steps 5 and 6 each require new work: Step 5 is
empirical or semi-theoretical (scaling law for structured projection
distances), Step 6 is a universality claim (the rate is not an artifact of the
FSM). If Step 5 yields a phase transition rather than a smooth rate, the ruler
has irregular tick marks and the formulation in Step 6 needs revision — but
the irregular ruler is still informative.
