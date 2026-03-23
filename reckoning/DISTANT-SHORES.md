# Distant Shores

The destination: a computable measure of the structural cost of departing
from a log-linear surrogate. 

---

## Step 5. [MENEHUNE] The projection distance scales predictably with structural cost

Define a cost measure C on correction machinery: some function of parameter
count, sharing depth, and automaton topology. The wall decomposition gives
empirical data points (C, gap) for several configurations.

The claim needed here: these data points trace a curve with recognizable
scaling behavior. The gap-per-unit-cost — the exchange rate between structural
investment and approximation quality — has a well-defined functional form, at
least within the FSM family.

### The forcing function

The representation displacement field Δ^L(m) = m − log₂(1+m) = −ε(m) is the
first-order organiser of the free-per-cell intercept field c*. It is validated
across 9 partition families including adversaries and width-scrambles that
invert the width-position coupling. The forcing is:

- **Known in closed form.** Δ^L depends only on the binary representation,
  not on the FSM, the delta table, or any correction strategy.
- **Bounded.** The leading-bit residual ||R0(c*)||∞ stabilises by depth 6-7
  at a partition-dependent limit (~0.050-0.058). The wall is a finite
  allocation problem, not a structurally growing one.
- **Partition-independent at first order.** ε(m_mid) predicts the template
  shape at corr 0.85-0.89 regardless of partition geometry.
  Partition-dependent modulation (33% of PC variance) is subdominant.
- **Structured.** The leading term c₀(m) tracks ε(m); correction terms
  track endpoint-balance geometry from the Day candidate structure. This
  gives the term structure of the local asymptotic expansion
  c*(m, w) ≈ c₀(m) + c₁(m)·w + ... empirically, before derivation.

See `experiments/tiling/TILING.md`.

The question for Step 5 is therefore: how does the FSM absorb this known
forcing as structural cost C increases?

### What the exchange rate should look like

The forcing's shape predicts that the (C, gap) curve is a staircase, not a
smooth function. The argument (from `TILING.md` §3):

Δ^L is zero at the domain boundaries (m = 0 and m = 1), maximal near
m* ≈ 0.44, and concave. A correction architecture with few parameters can
absorb the displacement where Δ^L is small (near boundaries) but not where
it is large (near the peak). As parameters increase, the absorbed region
expands toward the peak.

The minimax error is controlled by the worst unabsorbed cell. This cell sits
at the frontier of the absorbed region and advances in discrete jumps. The
stair locations are set by Δ^L — which cells have similar displacement values
and must be absorbed simultaneously — and the stair heights are set by the
architecture's absorptive efficiency per parameter.

Near the ε peak, many cells cluster at similar displacement values (ε is
concave and flat-topped near m*). An architecture must absorb them roughly
simultaneously. This predicts a wide plateau followed by a cliff when enough
parameters cover the cluster.

### [MENEHUNE] Absorption rate and term structure

- **Measuring the (C, gap) curve against the known forcing.** Vary q at fixed
  depth and partition, record the wall, and check whether the binding cell
  migrates in the order predicted by Δ^L (boundary cells absorbed first, peak
  cells last). This tests the staircase prediction and is tractable with
  existing infrastructure.

- **Quantifying the stair heights.** How much gap reduction does each new
  parameter buy? If the height per parameter is roughly constant, the exchange
  rate is a step function with predictable steps. If it varies, the rate
  depends on where in the staircase you are.

- **Partition dependence of the rate.** The first-order forcing is
  partition-independent, but the correction terms are partition-dependent
  (the balance-geometry margin is width-modulated). The (C, gap) curve may
  have partition-independent stair locations but partition-dependent stair
  heights. Separating these gives a precise statement of what is universal
  and what is not.

- **Local asymptotic model.** Deriving c*(m, w) ≈ c₀(m) + c₁(m)·w through
  the Day candidate structure would give an analytic foundation for the
  empirical term structure. If c₀(m) = (functional of ε), the forcing is
  proven, not just correlated. This is the cleanest resolution of Step 5
  but requires new mathematics.

### Spectral structure of the forcing

The forcing function has a Fourier decomposition. The accumulated
representation-native density defect E(t) = ∫₀ᵗ (2ʷ ln 2 − 1) dw satisfies
E(t) = −ε(φ(t)), and its Fourier coefficients relate to the density defect
by Ê(n) = δ̂(n)/(j2πn). This decomposes the forcing into frequency
components on the binade circle.

The spectral view may inform the staircase prediction: if a correction
architecture absorbs low-frequency displacement components before
high-frequency ones, the stair locations correspond to frequency thresholds
rather than spatial cell clusters. The binding-cell ordering (which cells
are absorbed when) might have a cleaner characterisation in frequency space
than in cell space.

See [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §7–§8.

## Step 6. [MENEHUNE] The cost measure is a property of the problem, not the architecture

Given the rate from Step 5, define:

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

where the minimum is over correction machinery M (FSMs, lookup tables,
polynomial evaluators, or anything else) and C is the cost measure.

This is the computational ruler: the minimum structural cost to achieve
tolerance τ in departure from L, measured not in error magnitude but in the
machinery required to produce corrections beyond what L provides for free.

The forcing function Δ^L is architecture-free — it is a property of c*, not
of any particular corrector. Any binary-representation architecture targets
the same c* field, organised by the same ε. But the absorption rate from
Step 5 is measured on FSMs. For d_comp to be a property of the
*approximation problem* rather than the *implementation*, two things are
needed:

- The infimum over architectures must be well-defined and the FSM rate must
  be close to it (or at least informative about it).
- Different architectures must be commensurable under C. This requires either
  showing that the FSM is near-optimal among low-cost correction strategies,
  or defining C abstractly enough (e.g., in bits of state, or circuit depth)
  that different architectures can be compared.

The staircase prediction from Step 5 offers a weaker but potentially
sufficient version: the stair *locations* (which cells bind when) are set by
Δ^L and should be architecture-invariant, even if the stair *heights* (gap
reduction per parameter) differ between architectures. Step 6 would then
require only that different architectures respect the same combinatorial
binding-cell ordering, not that they achieve the same numerical efficiency.

### [MENEHUNE] What remains

A second binary-representation architecture — shared-coefficient piecewise
polynomials (De Caro MILP) is the natural candidate — producing a (C, gap)
curve that can be compared to the FSM curve. Alignment after normalisation
would support architecture-invariance. Divergence would also be informative:
it would bound how much of the exchange rate is architecture-specific.

---

## Summary

| Step | Status | Content |
|------|--------|---------|
| 1 | Done | Triangle inequality; APPROX−L computable, ε known |
| 2 | Done | Geometric grid = zero-cost baseline from scale symmetry |
| 3 | Done | Shared-structure corrections live in a low-rank subspace |
| 4 | Done | Wall = projection distance; decomposition = nested subspaces |
| 5 | Forcing known; rate [MENEHUNE] | Projection distance scales predictably with cost measure |
| 6 | [MENEHUNE] | Cost measure is architecture-invariant → computational ruler |

Steps 1–4 are established. Step 5 has a known forcing function (Δ^L = −ε),
a predicted exchange-rate shape (staircase), and a known term structure
(c₀ tracks ε, corrections track balance geometry). What remains in Step 5
is measuring the absorption rate and proving the term structure. Step 6
requires a second binary-representation architecture to test whether the
binding-cell ordering is architecture-invariant.
