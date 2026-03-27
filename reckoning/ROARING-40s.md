# ROARING-40s

The chain from measure support to forced contradiction. This
document records a single argument thread: that the wall, the
singularity of ?(x), and the spectral tail of ε are three
projections of one obstruction, and that obstruction can be
cornered into a contradiction by forcing all three to meet.

---

## §1. The floor

Integration requires measure. The curve gives heights; the
measure gives widths. Without a measure, "area under the curve"
is undefined. The measure is the floor that supports the weight
of the integral.

Statistics also requires measure. The quincunx produces a
finite discrete distribution at every stage; the limit that
gives the continuous distribution requires topology (to say
what convergence means) and measure (to say what density means).

In both cases, geometry does all the visible work. Measure is
the invisible infrastructure that lets the limiting process
land somewhere.

## §2. Progressive failure of integration against ?(x)

?(x): [0,1] → [0,1], continuous, strictly increasing, maps
Farey subdivision to binary subdivision. Its distributional
measure μ_? is singular with respect to Lebesgue measure.

The failure of tools, in order of naïveté:

1. **Fundamental Theorem of Calculus.** Requires ?'(x). The
   derivative is zero a.e. FTC gives ∫?'(x)dx = 0 while ?(x)
   rises from 0 to 1. Tool fails.

2. **Riemann integration.** Works for ∫?(x)dx (?(x) as
   integrand, Lebesgue as floor). Cannot express ∫f d? — cannot
   use ?(x) as the floor.

3. **Riemann-Stieltjes.** Can compute ∫f d? for continuous f.
   Gives numbers, not analytical mobility. Cannot convert
   between ∫f d? and ∫f·g dx because no density g exists.

4. **Lebesgue / Radon-Nikodým.** Seeks g such that dμ_? = g dx.
   Requires absolute continuity of μ_? w.r.t. Lebesgue. They
   are mutually singular. No density exists. Tool fails.

5. **Change of reference measure.** Seek ν such that μ_? ≪ ν.
   To construct ν, must already know the singular structure of
   μ_?. Circular.

6. **Coordinate change.** y = ?(x) is a homeomorphism. In
   y-coordinates, μ_? becomes Lebesgue. But Lebesgue in
   x-coordinates becomes singular in y-coordinates. The
   singularity is in the relationship between the two measures,
   not in either one. No homeomorphism of [0,1] dissolves
   mutual singularity.

## §3. Geometric deformation fails

The one-parameter metric family ds = dx/x^α on [1,2)
interpolates between Euclidean (α = 0) and hyperbolic (α = 1).
Each member induces a measure ν_α = dx/x^α with positive
continuous density w.r.t. Lebesgue. Therefore ν_α is absolutely
continuous w.r.t. Lebesgue for every α ∈ [0,1].

Absolute continuity is transitive. μ_? is singular w.r.t.
Lebesgue, hence singular w.r.t. every ν_α. The entire
interpolation family lives on the continent of
Lebesgue-absolute-continuity. No smooth metric deformation
reaches μ_?.

Letting α vary with position (ds = dx/x^{α(x)}) changes
nothing as long as α(x) is finite a.e. The Gauss measure
dx/((1+x)ln 2), the natural invariant of the continued-fraction
dynamical system, also has a continuous density. Every
classically natural candidate floor is absolutely continuous
w.r.t. Lebesgue and therefore singular w.r.t. μ_?.

## §4. The fractal floor

Construct the floor fractally. At level n of the Stern-Brocot
tree, deform the metric on each Farey interval to match the
corresponding dyadic interval. This is a piecewise-smooth
metric. μ_? at resolution n is absolutely continuous w.r.t.
this level-n metric.

Take n → ∞. The limit is a metric whose induced measure is μ_?
itself. The floor supports only itself. Circular.

Stay at finite n. The level-n floor is a legitimate measure.
Integration against it works. The error between this floor and
μ_? is the next level of the fractal — the part of the
singularity not yet resolved.

This does not converge to a solution. It converges to a
sequence of increasingly precise descriptions of how the
singularity is structured, level by level.

## §5. The Padé ghost

For the level-by-level corrections to close — for a finite
amount of data to determine the rest — the generating function
of the corrections would need to be rational. That is: the
correction from level n to level (n+1) would need to satisfy a
finite linear recurrence. Padé approximation recovers rational
functions exactly from finitely many terms.

This requires that binary subdivision and Farey subdivision be
commensurable: that they share a common refinement reachable in
finitely many steps. In that world, the corrections eventually
repeat because the two grids eventually re-align.

The grids do not re-align. The near-alignments are controlled by
the rational approximations to ln 2. Each good approximant p/q
is a moment where the two grids almost lock into phase. The
irrationality of ln 2 ensures they never do. The irrationality
measure of ln 2 controls how close the near-misses get.

## §6. Any finite machine is a finite recurrence

A finite machine reading binary digits and producing corrections
has bounded resources. Whatever it computes is eventually periodic
in structure: a width-q branching program cycles in a state space
of size at most q, and an unbounded accumulator with a fixed
weight alphabet produces outputs in a finitely generated group.

SCYLLA ([SCYLLA](SCYLLA.md)) shows that neither class escapes ε.
The finite-width machine faces a treewidth wall: the binary
tiling's combinatorial complexity forces aliasing across coronas
whose displacement field values differ (SCYLLA §§5–7). The
unbounded accumulator faces a polynomial wall: exact knowledge of
L and z does not make z^{−1/b} a polynomial (SCYLLA §§3–4). Both
walls are controlled by ε.

If the corrections could be made eventually periodic in the
Stern-Brocot basis, a finite machine capturing one period could
close the gap exactly. The Padé failure (§5) says the corrections
cannot repeat. The wall says the gap cannot close. The
irrationality of ln 2 says the grids cannot re-align.

These are three descriptions of the same property:

- The wall measures how far the correction sequence is from
  eventually periodic.
- The Padé failure measures how far the generating function is
  from rational.
- The irrationality of ln 2 measures how far the two grids are
  from commensurable.

## §7. Three residuals, one object

Three processes attempt to bridge additive and multiplicative
structure with finite resources:

1. **Finite correction of L.** A machine reads binary digits and
   corrects the pseudo-log toward log. It does partition surgery
   with finite state. The residual it cannot absorb has a
   spectral shape.

2. **Schatte's additive convergence.** Mantissa distributions
   under addition converge toward the logarithmic distribution.
   The residual at each stage has a spectral shape, with the
   rate controlled by H∞ summability.

3. **Padé approximation of ?(x) from the Stern-Brocot tree.**
   Finite levels of the tree give finite piecewise-smooth
   floors. The residual between the level-n floor and μ_? has a
   spectral shape.

The conjecture: these three residuals are the same spectral
object. Not analogous. Not similar. The same. Each process is
purchasing correction against the singular mismatch between
additive and multiplicative structure. The currency is the same:
one more near-commensurability of ln 2 absorbed, one more
spectral mode of ε captured, one more level of the Stern-Brocot
tree resolved. The exchange rate between these currencies is
what d_comp(τ) would measure.

## §8. The geometric approach

The pseudo-log L(x) = E_x + m_x is free. It is the part of
log₂ that binary representation gives you without computation.
Everything after L is purchased correction.

The geometric content of the problem — the displacement ε(m),
the metric interpolation, the cooperative geometry on one
binade — is almost sufficient. Integration almost works
geometrically (Riemann sums with constructible pieces). The
quincunx almost does statistics geometrically. In both cases,
geometry does the visible work and a limit closes the gap.

The limit requires measure. The measure requires a floor.

On one binade, a cooperative geometry exists: the binary grid
and logarithmic density align well enough that ε is visible as
a shape. Outside that binade, the same coordinates produce
singularities.

Arriving at the problem almost geometrically is the point. The
residual — the part geometry cannot reach — is where the
spectral structure lives.

## §9. The contradiction

All three residual descriptions converge on one point.

A finite machine gaining over the whole domain, over the
surrogate, without paying the cost that the surrogate's
geometry demands, would produce residuals with a specific
spectral structure. That structure is the same structure that
Padé would produce trying to approximate ?(x) from finite
Stern-Brocot data. That structure is the same structure that
Schatte's additive process produces trying to converge mantissa
distributions to the logarithmic distribution.

If those identifications hold, then a machine that closes the
gap finitely would simultaneously:

- force the correction generating function to be rational
  (Padé succeeds);
- force binary and Farey subdivision to be commensurable
  (the grids re-align);
- force μ_? to be absolutely continuous w.r.t. Lebesgue
  (the singularity dissolves);
- force ln 2 to be rational (the near-commensurabilities
  terminate).

ln 2 is irrational. Contradiction.

The chain: finite machine closes gap → corrections eventually
periodic → generating function rational → grids commensurable →
?(x) non-singular → ln 2 rational → contradiction.

---

## Status

Every link in this chain requires proof. The identifications in
§7 are conjectural. The passage from "same spectral object" to
the specific contradiction in §9 requires showing that the
three processes are not merely analogous but literally
computing the same sequence. The Schatte connection is
speculative. The load-bearing joint is the identification of
the FSM residual with the Stern-Brocot correction sequence.

What is established:

- §§1–4: classical, no novel claims.
- §5: the Padé condition (rationality of corrections) is
  equivalent to commensurability of the grids. Classical.
- §6: Conjectured in [SCYLLA](SCYLLA.md), with one question open. 
- §§7–9: conjectural.

---

## Reading outward

- [ETAK](ETAK.md): Links 1–4 from the wall to algebraic
  independence. This document's §§5–6 are a different route
  to the same Link 1 door. §9 is a sketch of the full chain
  through Links 1–3.
- [TRAVERSE](TRAVERSE.md): the route.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): structural doubts.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§9–10: some of the
  geometric infrastructure.
