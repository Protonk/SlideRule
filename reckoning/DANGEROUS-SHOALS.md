# Dangerous Shoals

The passage to the destination
(the computational ruler) crosses water where the depth is uncertain
and the rocks are real. This document maps the open work and the
hazards, so that when we are close enough to touch the far shore we
do not mistake proximity for arrival.

---

## The problem

Step 5 establishes a forcing function and measures how one architecture
absorbs it. Step 6 asks whether the absorption ordering is
architecture-invariant. The current resolution path is empirical:
implement a second binary-representation architecture, compare curves.
That gives two data points in architecture space. Arguing universality
from n=2 is exactly the epistemic position we cannot afford.

The alternative is to prove that the geometric structure of the
displacement field *controls* the computational cost of correction,
so that no architecture — not just the two we tested — can escape the
ordering. This is the covering game, and it requires crossing from
geometric to computational language in a way that is not metaphorical.
See [COVERING-GAME](COVERING-GAME.md).

If we can do it, the staircase locations become theorems. If we
cannot, the whole edifice rests on empirical coincidence between
two architectures that happen to share a binary-representation
starting point. The difference between these outcomes is the
difference between a result and a narrative.

---

## Step 5: open work

The forcing function Δ^L = −ε and its properties (closed form, bounded,
partition-independent at first order, structured) are established. The
staircase prediction and spectral structure are derived. See
[TRAVERSE](TRAVERSE.md) Step 5 for the science. What remains:

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

## Step 6: what the crossing requires

For d_comp(τ) to be a property of the approximation problem rather
than the implementation, two things are needed:

- The infimum over architectures must be well-defined and the FSM rate
  must be informative about it.
- Different architectures must be commensurable under the cost measure C.
  Either the FSM is near-optimal among low-cost strategies, or C is
  defined abstractly enough (bits of state, circuit depth) to allow
  comparison.

A weaker but potentially sufficient version: stair *locations* (which
cells bind when) are set by Δ^L and should be architecture-invariant,
even if stair *heights* differ. Step 6 then requires only that
different architectures respect the same binding-cell ordering.

A second binary-representation architecture — shared-coefficient
piecewise polynomials (De Caro MILP) is the natural candidate —
producing a (C, gap) curve comparable to the FSM curve. Alignment
after normalisation supports architecture-invariance. Divergence
bounds how much of the exchange rate is architecture-specific.

The mathematical program for making this rigorous is the covering
game. See [COVERING-GAME](COVERING-GAME.md).

---

## Reading outward

- [AGENTS](AGENTS.md): epistemological rules for working on the
  reckoning (MENEHUNE discipline, proof standards, outcome levels).

- [TRAVERSE](TRAVERSE.md): the six-step spine.
- [DISTANT-SHORES](DISTANT-SHORES.md): the destination (d_comp).
- [COVERING-GAME](COVERING-GAME.md): the mathematical program for
  architecture-invariance.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): the doubt about whether the wall
  measures the problem or the architecture.
- [TILING](../experiments/tiling/TILING.md): the displacement field.
- [KEYSTONE](../experiments/keystone/KEYSTONE.md) §4: the compatibility
  argument the crossing would complete.
