# Tiling

Purpose: argue that hyperbolic binary tiling provides a framework for
approaching DISTANT-SHORES steps 5 and 6 via a representation-intrinsic
displacement field, and sketch what's testable now.

---

## Background: binary tiling of the hyperbolic plane

In the Poincaré half-plane model, a binary tiling consists of
axis-aligned rectangles whose Euclidean width doubles at each level
upward. The hyperbolic metric is ds² = (dx² + dy²)/y², so the Euclidean
doubling exactly compensates the 1/y scaling: every tile has the same
hyperbolic area. Binary subdivision produces hyperbolically congruent
tiles.

The connection to the Smith chart (Mizuhashi 1937, Smith 1939) is not
metaphorical. The Smith chart is a conformal mapping of the impedance
plane to the reflection coefficient plane. Its grid structure — circles
of constant resistance, arcs of constant reactance — is a binary tiling
of hyperbolic space. The two representations (impedance and reflection
coefficient) are related by a Möbius transformation, and the gridlines
are horocycles and geodesics of the hyperbolic plane.

The relevance to this project: the binary partition of [1, 2) and the
geometric partition of [1, 2) are two coordinate views of the same
hyperbolic structure. Uniform-width cells (additive subdivision) and
equal-log-width cells (geometric subdivision) are the horocyclic and
geodesic slicings of the same tiling.

---

## 1. A representation displacement field

### Definition

At depth d, define the binary (uniform) partition point

    b_k = 1 + k / 2^d,     k = 0, 1, ..., 2^d

and the geometric partition point

    g_k = 2^(k / 2^d),     k = 0, 1, ..., 2^d.

Both grids agree at the endpoints: b_0 = g_0 = 1, b_{2^d} = g_{2^d} = 2.
At every interior point they disagree. The pointwise displacement is

    Δ_k = b_k − g_k = (1 + k/2^d) − 2^(k/2^d).

Equivalently, in pseudo-log space (where the uniform grid is equally
spaced by construction), the displacement is

    Δ^L_k = (k / 2^d) − log₂(1 + k/2^d),

which is exactly −ε(k/2^d), the negated pseudo-log error evaluated at
the uniform grid point's mantissa. This is not a coincidence: the
displacement between the two grids is the same function that KEYSTONE §2
identifies as the free cost of using L instead of log₂.

### Architecture-independence

The displacement field Δ^L depends only on (d, k). It does not reference
the FSM, the delta table, the number of states, or any correction
strategy. It is a property of the representation: the cost of the fact
that binary scientific notation partitions [1, 2) uniformly rather than
geometrically.

Any correction architecture that processes the bits of a binary
significand — FSM, lookup table, shared-coefficient polynomial,
neural network with binary input encoding — receives its input cells
at the binary partition points and must produce corrections appropriate
for a target organized at the geometric partition points. The
displacement field Δ^L is the forcing function that every such
architecture must absorb.

### Hyperbolic interpretation

In the half-plane model with y-axis as the logarithmic coordinate,
place horocycles at heights y_k = 2^(k/2^d). The binary grid points
b_k lie on a different family of horocycles, at heights 1 + k/2^d.
The hyperbolic distance between corresponding points is

    d_hyp(k) = |log(b_k / g_k)| = |log((1 + k/2^d) / 2^(k/2^d))|.

Since all tiles in a binary tiling are hyperbolically congruent, this
distance is measuring how far the "wrong" horocycle family (additive) is
from the "right" one (geometric) at each cell. The maximum of d_hyp over
k occurs near k/2^d ≈ 1/ln 2 − 1 ≈ 0.4427, which is the mantissa
value m* where ε(m) peaks. The displacement field inherits the structure
of ε, which is to say the structure of the curvature mismatch between
additive and multiplicative coordinates.

---

## 2. A testable prediction about layer 0

### Setup

The displacement analysis of 2026-03-21 showed that layer 0's single
delta pair must serve all 2^d cells, imposing a systematic positional
displacement that cascades through subsequent layers. ABYSSAL-DOUBT
identifies this as the dominant wall source and asks whether it is
FSM-specific or representation-intrinsic.

The tiling framework answers: the layer-0 displacement should track
the representation displacement field Δ^L.

### The prediction

Let δ*_j be the free-per-cell optimal intercept for cell j under the
geometric partition, and let δ^{L0}_j be the intercept produced by
layer 0 alone (the base intercept c₀ plus the single layer-0 delta
correction for cell j's leading bit). The layer-0 displacement is

    D^{L0}_j = δ^{L0}_j − δ*_j.

**Prediction:** D^{L0}_j correlates with the representation displacement
Δ^L evaluated at the midpoint (or boundary) of cell j. Specifically,
the shape of D^{L0} across j = 0, ..., 2^d − 1 should resemble the
shape of −ε(m) sampled at the binary grid, modulo a scale factor and
an additive constant absorbed by c₀.

The scale factor and constant are free because layer 0 has two
parameters (one delta for bit 0, one for bit 1) plus the base
intercept, which together can absorb a global offset and a
left-half/right-half split. What they cannot absorb is the curvature
of ε within each half: the residual after removing a piecewise-constant
fit from Δ^L. That residual shape is the testable content.

### What the test discriminates

If the prediction holds, the layer-0 wall is representation-intrinsic:
the FSM is faithfully measuring the binary-to-geometric displacement,
and a different architecture processing the same bits would see the
same forcing. The wall is measuring the cost of binary representation,
not the cost of being an FSM.

If the prediction fails — if D^{L0} has structure uncorrelated with
Δ^L — then the layer-0 wall contains a substantial FSM-specific
component, and the tiling framework does not buy us what we need for
Step 6.

### Data requirements

This test requires only quantities already computed or cheaply
computable from existing infrastructure:

- Free-per-cell optimal intercepts δ*_j (from the LP at the geometric
  partition).
- Layer-0-only intercepts δ^{L0}_j (from the delta table with only
  the first layer applied).
- The representation displacement Δ^L_k = k/2^d − log₂(1 + k/2^d),
  which is a closed-form expression.

The comparison is a scatter plot or correlation coefficient: D^{L0}_j
vs. Δ^L at the corresponding cell location, across several depths.

---

## 3. Why the exchange rate might not be smooth

### The binding-cell argument

The minimax objective means the optimized error equals the worst cell's
error. As parameters are added to a correction architecture, the
identity of the worst cell changes. The exchange rate — gap reduction
per unit of structural cost — is smooth only if the worst cell migrates
smoothly as parameters increase. It won't.

The representation displacement Δ^L is not uniform across cells. It is
zero at the boundaries (k = 0 and k = 2^d), maximal near k/2^d ≈ 0.44,
and has a specific concave shape inherited from ε. A correction
architecture with few parameters can absorb the displacement in regions
where Δ^L is small (near the boundaries) but not where it is large (near
the peak). As parameters increase, the absorbed region expands outward
from the boundaries toward the peak.

The minimax error is controlled by the worst unabsorbed cell. This cell
sits at the frontier of the absorbed region, and the frontier advances
in discrete jumps as each new parameter brings a new cell below the
current worst. The (C, gap) curve is therefore a staircase: flat
stretches where new parameters reduce already-non-binding cells,
punctuated by drops when the binding cell finally flips.

### The shape of Δ^L predicts the staircase

The staircase structure is not random. The order in which cells become
absorbable is determined by the shape of Δ^L. Cells with small Δ^L
(near the domain boundaries) are cheap to absorb; cells near the peak
are expensive. The density of cells at each displacement level
determines the width of each stair.

Near the peak of ε, the displacement varies slowly (ε is concave and
flat-topped near m*), so many cells cluster at similar displacement
values. An architecture must absorb all of them roughly simultaneously
to reduce the minimax error. This predicts a wide plateau in the
(C, gap) curve near the displacement peak, followed by a cliff when
enough parameters finally cover the cluster.

Near the boundaries of [1, 2), the displacement varies steeply
(ε' is large near m = 0 and m = 1), so cells at different displacement
levels are well separated. Each new parameter picks off one cell at a
time, producing narrow stairs — which may look smooth at coarse
resolution.

### Relation to observed wall structure

The plateau/cliff pattern in the existing wall data — cheap initial
gains followed by a sharing-induced cliff — is consistent with this
picture. The cheap initial gains correspond to absorbing the
steep-gradient boundary cells; the cliff corresponds to hitting the
flat-topped cluster near m*. If the cliff location (in parameter count)
correlates with the number of cells within a fixed displacement
tolerance of the ε peak, the staircase model makes a quantitative
prediction rather than just a qualitative one.

### Why this helps with Steps 5–6

A smooth exchange rate would require discovering its functional form
empirically and then arguing that the form is architecture-invariant.
A staircase exchange rate is actually easier to work with, because:

The stair locations are set by Δ^L, which is architecture-free. Two
architectures processing the same binary representation encounter the
same displacement profile and therefore the same cell-absorption
ordering. Their staircases may have different step heights (one
architecture may absorb cells more efficiently than another), but the
step locations — the parameter counts at which the binding cell
changes — should coincide after normalization by absorptive capacity.

This replaces the strong Step 5 claim ("the rate has a recognizable
functional form") with a weaker but more defensible claim: the
*combinatorial structure* of the exchange rate — which cells bind when
— is representation-intrinsic, even if the quantitative rate is not.
Step 6 then needs only that different architectures respect the same
combinatorial ordering, not that they achieve the same numerical
efficiency.

---

## What this does and does not buy

**Buys:**

- A closed-form, architecture-free forcing function (Δ^L) that every
  binary-representation corrector must respond to.
- A testable prediction (§2) that can be checked against existing data
  without new implementation.
- A structural explanation for non-smooth exchange rates that is
  consistent with observed wall behavior.
- A weaker but potentially sufficient version of Steps 5 and 6:
  combinatorial ordering invariance rather than quantitative rate
  invariance.

**Does not buy:**

- A closed-form scaling law for the (C, gap) curve.
- A proof that the displacement field is the dominant wall source
  (this is the content of the §2 test).
- Elimination of the need for a second architecture (De Caro or
  equivalent) to validate Step 6.
- Tightness of the representation displacement as a lower bound on
  the wall.

The tiling framework reframes the [MENEHUNE] in Steps 5 and 6 from
"discover a universal scaling law" to "verify that a known forcing
function dominates the wall and that the combinatorial absorption
ordering it induces is architecture-invariant." The second formulation
is more modest and more testable.
