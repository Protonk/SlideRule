# Displacement Field and Staircase

This note records four project facts on the displacement between
binary and geometric grids:

1. the displacement field Δ^L and its identity with −ε;
2. the hyperbolic distance between the two grids;
3. the staircase prediction for the (C, gap) curve;
4. combinatorial ordering invariance as the weak form of Step 6.

The hyperbolic tiling background is included as geometric context.
The project-specific content is in the displacement field and the
staircase argument.

---

## 1. Binary tiling of the hyperbolic plane

In the Poincaré half-plane model, scaling (x, y) → (λx, λy) is an
isometry of the hyperbolic metric ds² = (dx² + dy²)/y². A binary
tiling is a family of rectangles related by dyadic scaling: moving up
one level doubles Euclidean width and height while preserving
hyperbolic shape and area.

The binary partition of [1, 2) and the geometric partition of [1, 2)
are two coordinate views of the same structure:

- Uniform-width cells (additive subdivision): horocyclic slicing.
- Equal-log-width cells (geometric subdivision): geodesic slicing.

---

## 2. The displacement field

At depth d, define the binary (uniform) grid point

    b_k = 1 + k/2^d,     k = 0, 1, …, 2^d

and the geometric grid point

    g_k = 2^{k/2^d},     k = 0, 1, …, 2^d.

Both grids agree at the endpoints: b_0 = g_0 = 1, b_{2^d} = g_{2^d} = 2.
At every interior point they disagree. In pseudo-log space (where the
uniform grid is equally spaced by construction), the displacement is

    Δ^L_k = (k/2^d) − log₂(1 + k/2^d) = −ε(k/2^d).

This is exactly the negated pseudo-log residual evaluated at the
uniform grid point's mantissa.

Δ^L depends only on (d, k), not on the FSM, the delta table, or the
number of states. It is a property of the representation. Any
architecture that processes binary significand bits must absorb this
field.

---

## 3. Hyperbolic distance between the grids

In the half-plane model with the y-axis as logarithmic coordinate,
place the geometric grid at heights y_k = 2^{k/2^d} and the binary
grid at heights y_k = 1 + k/2^d. The hyperbolic distance between
corresponding points is

    d_hyp(k) = |log(b_k / g_k)| = |log((1 + k/2^d) / 2^{k/2^d})|.

This measures the separation between additive and multiplicative
coordinates at cell k. The maximum occurs near k/2^d ≈ 1/ln 2 − 1
≈ 0.4427, the same mantissa value m* where ε(m) peaks.

The displacement field inherits the shape of the pseudo-log error:
zero at the endpoints, concave, maximal near m*.

---

## 4. The staircase prediction

The minimax objective makes the optimised error equal to the worst
cell's error. As parameters are added, the identity of the binding
cell changes discretely.

ε is zero at the domain boundaries (m = 0 and m = 1), maximal
near m* ≈ 0.44, and concave. A low-capacity corrector absorbs
cells where ε is small (near boundaries) before where it is large
(near the peak). As capacity increases, the absorbed region expands
toward the peak.

The binding cell — the worst unabsorbed cell — advances in discrete
jumps. This predicts a staircase in the (C, gap) curve:

- **Stair locations** are set by ε: which cells have similar
  displacement and must be absorbed simultaneously.
- **Stair heights** are set by the architecture's absorptive
  efficiency per parameter.

Near the ε peak, many cells cluster at similar displacement (ε is
concave and flat-topped near m*). An architecture must absorb them
roughly simultaneously. This predicts a wide plateau followed by a
cliff when enough parameters cover the cluster.

The plateau/cliff pattern in the existing wall data is consistent
with this picture: cheap initial gains correspond to absorbing
steep-gradient boundary cells; the cliff corresponds to hitting the
flat-topped cluster near m*.

---

## 5. Combinatorial ordering invariance

A smooth exchange rate would require discovering its functional form
empirically and then arguing that the form is architecture-invariant.
A staircase is easier to use.

The stair heights may differ between architectures, but the stair
locations are set by Δ^L: architectures processing the same binary
representation confront the same displacement profile and therefore
the same binding-cell ordering, at least after normalisation by
absorptive capacity.

This weakens the claim from "the rate has a recognisable functional
form" to "the combinatorial structure of the rate is
representation-intrinsic." Architecture-invariance then requires
only that different architectures respect the same binding-cell
ordering, not that they achieve the same numerical efficiency.

---

## 6. Connection to the density defect

The displacement field Δ^L = −ε is the same function whose
accumulated form E(t) = ∫₀ᵗ (2^w ln 2 − 1) dw is the
representation-native density defect (see
[BINADE-WHITECAPS](BINADE-WHITECAPS.md) §7). The Fourier
coefficients satisfy Ê(n) = δ̂(n)/(j2πn), decomposing the forcing
into frequency components on the binade circle.

If a correction architecture absorbs low-frequency displacement
before high-frequency, the stair locations in §4 correspond to
frequency thresholds: the spectral and spatial views of the
staircase are dual descriptions of the same absorption ordering.

---

## Experimental validation

The displacement field prediction is tested in
[`experiments/tiling/TILING.md`](../experiments/tiling/TILING.md):

- R0(c*) correlates with R0(Δ^L) at r = 0.80–0.89 across the
  partition zoo (T3).
- Three adversary partitions failed to break the correlation.
- Basis identification confirms ε(m_mid) as the first-order
  predictor (holdout corr 0.86).
- Width-preserving position scrambles do not degrade the ε predictor.
