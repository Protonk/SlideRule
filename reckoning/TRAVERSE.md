# Traverse

The project studies the cost of closing the gap between the affine
pseudo-log and the true logarithm on one binade, using correction
architectures that read binary digits and share parameters across
cells. The structure of the gap ε governs the cost of closing it, in
a way that appears to be independent of the correction method.

This document is the six-step technical spine. Doubts are in
[ABYSSAL-DOUBT](ABYSSAL-DOUBT.md); the open frontier is in
[DANGEROUS-SHOALS](DANGEROUS-SHOALS.md).

---

## Definitions

**Domain.** One binade [1, 2), parameterised by mantissa m = x − 1 ∈ [0, 1).

**Pseudo-log.** L(x) = x − 1 = m. The affine surrogate for log₂(x)
on [1, 2), extracted for free from any binary scientific notation format
by reading the significand field. See [KEYSTONE](KEYSTONE.md) §3.

**Residual.** ε(m) = log₂(1+m) − m. The departure of truth from
surrogate. Smooth, concave on (0, 1), vanishes at m = 0 and m = 1,
peak ε(m*) ≈ 0.0861 at m* = 1/ln 2 − 1 ≈ 0.4427.

**Geometric grid at depth d.** The partition with boundaries
g_k = 2^{k/2^d}, k = 0, …, 2^d. Equal-log-width cells.

**Binary (uniform) grid at depth d.** The partition with boundaries
b_k = 1 + k/2^d. Equal-width cells in m.

**Displacement field.** Δ^L_k = (k/2^d) − log₂(1 + k/2^d) = −ε(k/2^d).
The signed displacement between uniform and geometric grid points in
pseudo-log space. See [TILING](TILING.md) §1.

**FSM correction.** A finite-state machine reads the d-bit address of
a cell and accumulates shared delta-table entries. The set of
achievable correction vectors is the image of a linear map from the
parameter space into ℝ^{2^d}. Call this image S.

**Free-per-cell optimum.** δ* = (δ*_1, …, δ*_{2^d}), the minimax-optimal
correction with one free parameter per cell. No sharing.

**Wall.** opt_err − free_err: the gap between the best shared correction
and the free-per-cell optimum. A projection distance from δ* to S in
the minimax norm.

---

## Step 1. Computable reference triangle — Done

The triangle inequality gives

    |APPROX − log₂| ≤ |APPROX − L| + |L − log₂|.

The first term is computable (both APPROX and L are available). The
second term is ε, known in closed form. The decomposition is exact: the
two terms share no degrees of freedom.

Note: the experimental program (Steps 3–6) measures walls by LP
optimisation that never references this decomposition. Step 1 provides
an accounting frame; the LP provides the measurements. See
[ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §3 on the load-bearing status of
the triangle.

## Step 2. The geometric grid is the zero-cost baseline — Done

L(x) is exact at every integer power of 2. These are the binade
boundaries — the points where the log₂/mod-1 coordinate circle has
its seam. The geometric grid at depth d places all its boundaries at
points where ε vanishes: these are refinements of the binade lattice.
Between grid points, ε is the cost of using L instead of log₂. This
cost is paid by the representation. It requires no machinery.

ε has three identities under the log₂/mod-1 coordinate system:

1. The approximation error of L as a surrogate for log₂.
2. The displacement −Δ^L between the binary and geometric grids.
3. The accumulated departure from the reciprocal density in
   log-binade coordinates: E(t) = ∫₀ᵗ (2^w ln 2 − 1) dw = −ε(φ(t)),
   where φ(t) = 2^t − 1.

These are proved in [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §6–§7.
The coincidence is forced by the coordinate theory, not by any property
of the correction architecture.

See [KEYSTONE](KEYSTONE.md) §1–§2 for the scale-symmetry argument.

## Step 3. The FSM's achievable corrections form a low-rank subspace [MENEHUNE]

Partition [1, 2) into 2^d cells. The FSM with q states processing d
bits generates correction vectors in the image S of a linear map from
the parameter space (dim O(q) layer-invariant, dim O(qd)
layer-dependent) into ℝ^{2^d}. When the parameter count is much less
than the cell count, S is a low-dimensional subspace.

S is the FSM's subspace. A different correction architecture — a
lookup table, a polynomial evaluator, anything with a different sharing
topology — produces a different S. A full lookup table gives
S = ℝ^{2^d} and there is no wall. The dimension tells you S is thin;
it does not tell you which directions it spans or how it is oriented
relative to δ*.

The best shared correction is the point in S closest to δ* under the
minimax norm. This is what the LP computes.

## Step 4. The wall is a projection distance from δ* to S [MENEHUNE]

The wall is dist(δ*, S) in the minimax norm. Three nested subspace
inclusions give the wall decomposition:

    S_LI ⊂ S_LD ⊂ ℝ^{2^d}

where S_LI is the layer-invariant subspace, S_LD is the
layer-dependent subspace, and ℝ^{2^d} is the free-per-cell space.

- **Parameter budget.** dim(S) ≪ 2^d. The subspace is thin.
- **Layer sharing.** S_LI ⊂ S_LD is proper. Layer-invariant parameters
  are overconstrained.
- **Automaton coupling.** S_LD ⊂ ℝ^{2^d} is proper. Even
  layer-dependent parameters are coupled by the state-transition graph.

The nesting describes the FSM's layer architecture. The wall
decomposition measures how much distance each sharing layer
contributes — but this is a decomposition of an FSM-specific
quantity. Which components of δ* are captured and which are lost
is read from LP solutions, not derived from the nesting description.

The dominant source of the wall is the earliest sharing constraint:
the leading bit splits the domain at its midpoint (additive), while
the logarithm's natural split is the geometric mean (multiplicative).
This mismatch is representation-intrinsic — every architecture that
reads binary digits faces it. Whether the *cost* of the mismatch is
also representation-intrinsic is exactly what Steps 5–6 need to
establish. See [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §4.

See [TILING](TILING.md) for the displacement analysis.

## Step 5. [MENEHUNE] The projection distance scales predictably with structural cost

Define a cost measure C on correction machinery (function of parameter
count, sharing depth, automaton topology). The wall decomposition gives
empirical data points (C, gap) for several configurations. The claim:
these data points trace a curve whose shape is governed by the forcing
function Δ^L = −ε.

### The forcing function

Δ^L(m) = m − log₂(1+m) = −ε(m) is the first-order organiser of the
free-per-cell intercept field c*. Validated across 25 partition families
including adversaries and width-scrambles. Properties:

- **Closed form.** Depends only on the binary representation. No
  dependence on FSM, delta table, or correction strategy.
- **Bounded.** Leading-bit residual ‖R₀(c*)‖_∞ stabilises by depth
  6–7 at a partition-dependent limit (~0.050–0.058). The wall is a
  finite allocation problem.
- **Partition-independent at first order.** ε(m_mid) predicts the
  template shape at correlation 0.85–0.89 regardless of partition
  geometry. Partition-dependent modulation (33% of PC variance) is
  subdominant.
- **Structured.** Leading term c₀(m) tracks ε(m); correction terms
  track endpoint-balance geometry from the Day candidate structure.
  Empirical term structure: c*(m, w) ≈ c₀(m) + c₁(m)·w + …

See [TILING](TILING.md).

### Staircase prediction

Δ^L is zero at domain boundaries, maximal near m* ≈ 0.44, and
concave. A correction architecture with few parameters absorbs
displacement where Δ^L is small (near boundaries) but not where it is
large (near the peak). As parameters increase, the absorbed region
expands toward the peak.

The minimax error is controlled by the worst unabsorbed cell. This
cell advances in discrete jumps. Stair locations are set by Δ^L
(which cells have similar displacement and must be absorbed
simultaneously). Stair heights are set by the architecture's
absorptive efficiency per parameter.

Near the ε peak, many cells cluster at similar displacement (ε is
concave and flat-topped near m*). These must be absorbed roughly
simultaneously, predicting a wide plateau followed by a cliff.

### Spectral structure

The accumulated density defect E(t) = ∫₀ᵗ (2^w ln 2 − 1) dw satisfies
E(t) = −ε(φ(t)), and its Fourier coefficients satisfy
Ê(n) = δ̂(n)/(j2πn). If a correction architecture absorbs
low-frequency displacement before high-frequency, the stair locations
correspond to frequency thresholds rather than spatial cell clusters.
See [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §7–§8.

### [MENEHUNE] Open work for Step 5

1. **Measure the (C, gap) curve.** Vary q at fixed depth and partition.
   Check whether the binding cell migrates in the order predicted by
   Δ^L (boundary cells first, peak cells last). Tractable with existing
   infrastructure.

2. **Quantify stair heights.** Gap reduction per new parameter: roughly
   constant (step function with predictable steps) or position-dependent?

3. **Separate partition dependence.** First-order forcing is
   partition-independent; correction terms are partition-dependent
   (width-modulated balance geometry). The (C, gap) curve may have
   partition-independent stair locations but partition-dependent stair
   heights.

4. **Derive the local asymptotic model.** c*(m, w) ≈ c₀(m) + c₁(m)·w
   via the Day candidate structure. If c₀(m) is a functional of ε, the
   forcing is proved, not just correlated. This requires new mathematics.

## Step 6. [MENEHUNE] The cost measure is architecture-invariant

Given the rate from Step 5, define:

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

where the minimum is over correction machinery M and C is the cost
measure.

Any binary-representation architecture targets the same c* field,
organised by the same ε. The forcing function Δ^L is
architecture-free. But the absorption rate in Step 5 is measured on
FSMs. For d_comp to be a property of the problem rather than the
implementation:

- The infimum over architectures must be well-defined and the FSM rate
  must be informative about it.
- Different architectures must be commensurable under C. Either the FSM
  is near-optimal among low-cost strategies, or C is defined abstractly
  enough (bits of state, circuit depth) to allow comparison.

A weaker but potentially sufficient version: stair *locations* (which
cells bind when) are set by Δ^L and should be architecture-invariant,
even if stair *heights* differ. Step 6 then requires only that
different architectures respect the same binding-cell ordering.

### [MENEHUNE] Open work for Step 6

A second binary-representation architecture — shared-coefficient
piecewise polynomials (De Caro MILP) is the natural candidate —
producing a (C, gap) curve comparable to the FSM curve. Alignment
after normalisation supports architecture-invariance. Divergence
bounds how much of the exchange rate is architecture-specific.

See [DANGEROUS-SHOALS](DANGEROUS-SHOALS.md) for the hazards of
arguing universality from two data points.

---

## Summary

| Step | Status | Content |
|------|--------|---------|
| 1 | Done | Triangle inequality; APPROX−L computable, ε known |
| 2 | Done | Geometric grid = zero-cost baseline; ε triple identity |
| 3 | [MENEHUNE] | FSM corrections ∈ low-rank subspace S (architecture-specific) |
| 4 | [MENEHUNE] | Wall = dist(δ*, S); decomposition describes FSM sharing |
| 5 | Forcing known; rate [MENEHUNE] | (C, gap) curve governed by Δ^L = −ε |
| 6 | [MENEHUNE] | d_comp(τ) architecture-invariant → computational ruler |

---

## Reading outward

- [KEYSTONE](KEYSTONE.md): scale-symmetry thesis (coordinate,
  surrogate, representation, compatibility).
- [TILING](TILING.md): displacement field, forcing function
  validation, staircase argument.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md): log₂/mod-1 coordinate
  theory, ε triple identity, spectral structure.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): three doubts (fan-out mismatch,
  forcing-residual gap, exactness trap).
- [DANGEROUS-SHOALS](DANGEROUS-SHOALS.md): navigational rules for
  Steps 5–6.
- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): speculative extensions
  (hyperbolic geometry, tiling duality).
- [DISTANT-SHORES](DISTANT-SHORES.md): the destination.
