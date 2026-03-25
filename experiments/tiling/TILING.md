# Tiling

Purpose: argue that hyperbolic binary tiling provides a framework for
approaching TRAVERSE Steps 5 and 6 via a representation-intrinsic
displacement field, and sketch what's testable now.

Reading inward: depends on [`ABYSSAL-DOUBT.md`](../../reckoning/ABYSSAL-DOUBT.md)
for the doubt this framework responds to, and
[`WALL.md`](../wall/WALL.md) for the fan-out displacement analysis that
motivates it.

---

## Background: binary tiling of the hyperbolic plane

In the Poincare half-plane model, scaling `(x, y) -> (lambda * x, lambda * y)`
is an isometry of the hyperbolic metric `ds^2 = (dx^2 + dy^2) / y^2`. A
binary tiling can therefore be viewed as a family of rectangles related by
dyadic scaling: moving up one level doubles Euclidean width and height while
preserving hyperbolic shape and area.

The binary partition of [1, 2) and the geometric partition of [1, 2) are two
coordinate views of the same structure. Uniform-width cells (additive
subdivision) and equal-log-width cells (geometric subdivision) are the
horocyclic and geodesic slicings of the same tiling.

---

## 1. A representation displacement field

### Definition

At depth d, define the binary (uniform) partition point

    b_k = 1 + k / 2^d,     k = 0, 1, ..., 2^d

and the geometric partition point

    g_k = 2^(k / 2^d),     k = 0, 1, ..., 2^d.

Both grids agree at the endpoints: b_0 = g_0 = 1, b_{2^d} = g_{2^d} = 2. At
every interior point they disagree. The pointwise displacement is

    Δ_k = b_k − g_k = (1 + k/2^d) − 2^(k/2^d).

Equivalently, in pseudo-log space (where the uniform grid is equally spaced by
construction), the displacement is

    Δ^L_k = (k / 2^d) − log₂(1 + k/2^d),

which is exactly `−ε(k/2^d)`, the negated pseudo-log error evaluated at the
uniform grid point's mantissa. This is the same function that KEYSTONE §2
identifies as the free cost of using `L` instead of `log₂`.

Because `Δ^L` depends only on `(d, k)`, not on the FSM, the delta table, or
the number of states, it is a property of the representation rather than a
particular corrector. Any architecture that processes binary significand bits
must absorb this same forcing field.

### Hyperbolic interpretation

In the half-plane model with the y-axis as logarithmic coordinate, place the
geometric grid at heights `y_k = 2^(k/2^d)` and the binary grid at heights
`y_k = 1 + k/2^d`. The hyperbolic distance between corresponding points is

    d_hyp(k) = |log(b_k / g_k)| = |log((1 + k/2^d) / 2^(k/2^d))|.

This measures the separation between additive and multiplicative coordinates at
cell `k`. The maximum occurs near `k/2^d ≈ 1/ln 2 − 1 ≈ 0.4427`, the same
mantissa value `m*` where `ε(m)` peaks. The displacement field therefore
inherits the shape of the pseudo-log error.

---

## 2. A testable prediction about layer 0

### Setup

The displacement analysis of 2026-03-21 showed that layer 0's single delta pair
must serve all `2^d` cells, imposing a systematic positional displacement that
cascades through subsequent layers. ABYSSAL-DOUBT identifies this as the
dominant wall source and asks whether it is FSM-specific or
representation-intrinsic.

The tiling framework predicts that the layer-0 displacement should track the
representation displacement field `Δ^L`.

### The prediction

Let `δ*_j` be the free-per-cell optimal intercept for cell `j` under the
geometric partition, and let `δ^{L0}_j` be the intercept produced by layer 0
alone (the base intercept `c₀` plus the single layer-0 delta correction for
cell `j`'s leading bit). The layer-0 displacement is

    D^{L0}_j = δ^{L0}_j − δ*_j.

Layer 0 has three free parameters (`c₀`, `δ(0,0)`, `δ(0,1)`), so it can absorb
a global offset and a left-half/right-half split. What it cannot absorb is the
within-half curvature of `ε`. That residual curvature is the actual testable
content.

Write `R0(v)` for "remove the best leading-bit piecewise-constant fit from
`v`." The prediction is that the residual curvature of `D^{L0}` should match
the residual curvature of `Δ^L`. In practice the experiment measures this by
comparing `R0(c*)` with `R0(Δ^L)`, where `c*` is the free-per-cell intercept
field.

On the geometric partition alone this test is weak, because `δ*_j` is nearly
flat. It becomes discriminating across partitions and depths:

- **Across partitions:** On `uniform_x`, `δ*` varies substantially with
  position, producing a large residual whose shape should track `ε`
  curvature. The residual magnitude should rank-order with partition departure
  from geometric.
- **Across depths:** Layer 0 always has 2 values but serves `2^d` cells. The
  piecewise-constant fit gets coarser relative to the smooth `ε` hump as depth
  grows, so the residual curvature should grow with depth, tracking
  `ε'' = −1/((1+m)^2 ln 2)`.

If the residual match holds, the evidence supports a representation-intrinsic
forcing at layer 0: the FSM is responding to the binary-to-geometric mismatch
rather than inventing an arbitrary distortion. If it fails, then a substantial
part of the layer-0 wall is still FSM-specific.

### Test results (2026-03-21)

The four-stage test (`displacement_field_test.sage`) found that `R0(c*)`
correlates with `R0(Δ^L)` at `r = 0.80–0.89` across 20 baseline cases
(`4` partition kinds × `5` depths). The match is robust:

- Stage A (geometry-only): PASS. Correlations stable across depths.
- Stage B (layer-0 allocation): MIXED. The optimizer's layer 0 is close to the
  best leading-bit projection but systematically offset by path-algebra
  constraints.
- Stage C (cumulative absorption): PASS. LD beats LI by repairing at layers 1+,
  not by changing the layer-0 picture.
- Stage D (depth scaling): forcing stabilises by `d = 6–7`.

Three adversary partitions designed to break Stage A all failed to find its
boundary:

| Adversary | Design intent | Actual corr |
|---|---|---|
| `half_geometric_x` | Kill `R0(c*)` by making halves geometric | 0.876 |
| `eps_density_x` | Pre-absorb forcing via `ε`-proportional density | 0.80–0.83 |
| `midpoint_dense_x` | Put `R0(c*)` and `R0(Δ^L)` out of phase | 0.88 |

These results support, rather than prove, that `Δ^L` is the right zeroth-order
forcing field for this FSM family.

---

## 3. Why the exchange rate might not be smooth

### Why a staircase is plausible

The minimax objective makes the optimized error equal to the worst cell's
error. As parameters are added, the identity of the binding cell changes
discretely. Because `ε` is zero at the boundaries, maximal near
`m ≈ 0.44`, and flat-topped near its peak, a low-capacity corrector
absorbs easy boundary cells first and harder peak cells in clusters.

That predicts a staircase in the `(C, gap)` curve: narrow early stairs near the
steep boundary regions, then a wide plateau and cliff near the peak where many
cells have similar displacement. The plateau/cliff pattern in the existing wall
data is consistent with this picture. Cheap initial gains correspond to
absorbing steep-gradient boundary cells; the later cliff corresponds to hitting
the flat-topped cluster near `m*`. If the cliff location correlates with the
number of cells within a fixed displacement tolerance of the `ε` peak, the
staircase model becomes quantitative rather than merely descriptive.

### Why this helps with Steps 5–6

A smooth exchange rate would require discovering its functional form
empirically and then arguing that the form is architecture-invariant. A
staircase is easier to use. The step heights may differ between architectures,
but the step locations are set by `Δ^L`: architectures processing the same
binary representation confront the same displacement profile and therefore the
same binding-cell ordering, at least after normalization by absorptive
capacity.

This weakens the Step 5 claim from "the rate has a recognizable functional
form" to "the combinatorial structure of the rate is representation-intrinsic."
Step 6 then needs only that different architectures respect the same
binding-cell ordering, not that they achieve the same numerical efficiency.

---

## What this does and does not buy

**Buys:**

- A closed-form, architecture-free forcing function (`Δ^L`) that every
  binary-representation corrector must respond to.
- A testable prediction (§2) that can be checked against existing data without
  new implementation.
- A structural explanation for non-smooth exchange rates that is consistent
  with observed wall behavior.
- A weaker but potentially sufficient version of Steps 5 and 6:
  combinatorial ordering invariance rather than quantitative rate invariance.

**Does not buy:**

- A closed-form scaling law for the `(C, gap)` curve.
- A proof that the displacement field is the dominant wall source
  (this is the content of the §2 test).
- Elimination of the need for a second architecture (De Caro or equivalent) to
  validate Step 6.
- Tightness of the representation displacement as a lower bound on the wall.

---

## Connection to the displacement analysis

The fan-out analysis (2026-03-21, `wall/displacement_structure.sage`) found
that the wall is dominated by early-layer fan-out, not by pairwise chord
displacement or residue-state assignment. The tiling framework gives that
result a geometric reading: layer 0 splits the domain at the binary midpoint
`m = 0.5`, while the forcing field peaks at `m* ≈ 0.44`. The mismatch between
those two reference points propagates through later layers.

This does not make the wall identical to `ε`. Rather, the pseudo-log error
`ε`, the binary/geometric grid displacement `Δ^L`, and the early-layer wall
all involve the same underlying forcing. The first two are literally the same
function; the third is the corrector's response to it. The tiling framework
supplies the geometric setting in which that relationship looks natural rather
than accidental.

## Basis identification and scramble test (2026-03-21)

The displacement-field test established that `R0(c*)` tracks `R0(Δ^L)`, where
`c*` is the free-per-cell intercept field. Basis identification then asked
which simple basis best predicts that residual in native cell coordinates,
trained on baseline partitions and scored on held-out adversaries.

Among the tested families, width alone (`H_width`) fails badly (holdout NRMSE
`1.57`). A single scalar `ε(m_mid)` (`H_value`) captures most of the signal
(holdout corr `0.86`), and endpoint-balance geometry (`H_balance`) performs
best by a narrow margin of `0.026` NRMSE. On affine-detrended geometric
partitions, all `ε`-based families score `corr > 0.999`.

Width-preserving position scrambles (`peak_swap` and `peak_avoid`) tested
whether inverting the width-`ε` coupling breaks the `ε` predictor. It does not.
`H_value` holds at `corr 0.85–0.89` on both scrambles, while `H_balance`'s
margin shrinks on `peak_swap` and widens on `peak_avoid`, confirming that it
captures a width × `ε` interaction rather than a purely positional signal.

Scramble results at depth 6 (trained on baselines `d = 5, 6, 7`):

| Partition | H_value corr | H_value NRMSE | H_balance corr | H_balance NRMSE | H_width corr |
|---|---|---|---|---|---|
| peak_swap | 0.851 | 0.457 | 0.860 | 0.444 | 0.543 |
| peak_avoid | 0.885 | 0.451 | 0.923 | 0.382 | 0.839 |

Coupling diagnostics confirm the intervention achieved near-perfect inversion:
geometric `rho_peak = −0.17`, `peak_swap = −0.99`, `peak_avoid = +0.99`.

The affine-detrended geometric case remains the cleanest result: with the
affine ramp removed, `c*`'s nonlinear residual is almost perfectly `ε`. The
summary figure (`results/t3_summary.png`) shows 9 partitions' transported
`R0(c*)` collapsing onto the scaled `ε` template at depths 6 and 8 across
baselines, adversaries, and scrambles.

Taken together, these tests support `Δ^L = −ε` as the first-order organiser of
`c*` across the tested partition families. The open question is now on the
corrector side: how different architectures absorb that forcing.

See `results/basis_identification/basis_holdout_summary.md` for detailed
analysis.

## Reading outward

- [`ABYSSAL-DOUBT.md`](../../reckoning/ABYSSAL-DOUBT.md): the doubt this responds to.
- [`TRAVERSE.md`](../../reckoning/TRAVERSE.md): the roadmap whose Steps 5–6
  this framework addresses.
- [`WALL.md`](../wall/WALL.md): the wall decomposition and displacement
  analysis.
- [`KEYSTONE.md`](../keystone/KEYSTONE.md) §2: the surrogate error `ε(m)` that
  `Δ^L` turns out to equal.
