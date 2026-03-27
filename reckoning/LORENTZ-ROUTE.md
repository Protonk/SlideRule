# LORENTZ-ROUTE

> "On two occasions I have been asked, – 'Pray, Mr. Babbage, if
> you put into the machine wrong figures, will the right answers
> come out?' ... I am not able rightly to apprehend the kind of
> confusion of ideas that could provoke such a question."
> — Charles Babbage

> "You best start believing in ghost stories, Miss Turner...
> you're in one."
> — Hector Barbossa

Each level of integration machinery adds more infrastructure to
the same obstruction. From calculus to Riemann to Stieltjes to
Lebesgue to Padé to exhaustive TMD enumeration, the residual
changes form but does not vanish. The singularity between
additive and multiplicative structure persists throughout.

Sections §§1–7 move through successive attempts to integrate
against μ_?: calculus, Riemann, Stieltjes, Lebesgue, fractal
approximation, exhaustive enumeration, and finally removal of
the resource bound. Section 7 returns to §4: even with all
finite computations completed, the limit object is still μ_?.

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
Lebesgue, hence singular w.r.t. every ν_α. No smooth metric
deformation reaches μ_?.

Letting α vary with position (ds = dx/x^{α(x)}) changes
nothing as long as α(x) is finite a.e. The Gauss measure
dx/((1+x)ln 2), the natural invariant of the continued-fraction
dynamical system, also has a continuous density. Every
classically natural candidate floor is absolutely continuous
w.r.t. Lebesgue and therefore singular w.r.t. μ_?.

The Poincaré half-plane, the hyperbolic metric, and the Gauss
measure all stay in the absolutely continuous class. Classically,
that class is meager in the weak-* topology on Borel probability
measures on [0,1] [O80, Ch. 18]. Section 3 fails because every
smooth candidate stays inside that meager class. Section 4 must
therefore proceed by finite approximants that remain absolutely
continuous at each level, with the singular target appearing
only in the limit.

## §4. The fractal floor

Construct the floor fractally. At level n of the Stern-Brocot
tree, deform the metric on each Farey interval to match the
corresponding dyadic interval. This is a piecewise-smooth
metric, so its induced measure remains absolutely continuous
with respect to Lebesgue. μ_? at resolution n is absolutely
continuous w.r.t. this level-n metric.

Take n → ∞. The limit is a metric whose induced measure is μ_?
itself.

Stay at finite n. The level-n floor is a legitimate measure.
Integration against it works. But it computes against the
level-n approximation, not against μ_? itself. What remains is
the gap between that finite approximation and the limit.

The construction yields increasingly precise descriptions of
the singular structure, level by level; the full object appears
only in the limit.

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

## §6. One For All

§5 shows that a finite recurrence cannot close the gap between
binary and Farey subdivision. The generating function of the
corrections would need to be rational; the grids would need to
be commensurable; ln 2 would need to be rational. It isn't. So
no finite machine that captures a repeating pattern in the
corrections can succeed.

So try a stronger but narrower tool. Fix a source format, an
output format, a rounding mode, and the function log₂. The
output line is partitioned into rounding cells, with walls at
the rounding breakpoints: representable numbers in directed
modes, midpoints between consecutive representable numbers in
round-to-nearest. Pull that partition back through log₂. On the
input side, this gives intervals on which the rounding decision
is constant.

Now restrict to the binary64 source lattice. For each input x,
ask how far log₂(x) lies from the nearest rounding wall in the
chosen output partition. The hard-to-round inputs are those for
which this boundary clearance is smallest. The TMD tables are
catalogs of those minima: the sampled inputs where log₂ comes
closest to the pulled-back rounding walls.

Lefèvre and Muller built this machinery [LM00]. Over four
years, using approximately a hundred workstations, they checked
every double-precision floating-point input to log, exp, log₂,
2^x, and the trigonometric functions. The core of their
algorithm is a multi-scale filter. On each small subdomain, the
function is approximated by a linear function, and the problem
reduces to finding integer lattice points near a line. This is
solved by a variant of the Euclidean algorithm — that is, by
continued fractions [L99]. The candidates surviving the filter
are verified with arbitrary-precision arithmetic. The method is
exhaustive: every input is checked, either by the filter or
directly.

For log₂(x) on the full double-precision range, the result is
Property 4 of [LM00]: 55 extra bits beyond the 53-bit
significand suffice to resolve correct rounding, in all four
IEEE-754 rounding modes. The table therefore identifies the
narrowest sampled passages in this pulled-back partition for
binary64 log₂. The worst case for log₂ in the binade [1/2, 1)
has the form

    log₂(1.0110000101...) = −10000000000.1000100001...10100101...
                             followed by 55 zeros,

and the corresponding worst case in [1, 2) has those 55 zeros
replaced by 55 ones, by bit complementation — a symmetry of
ε(m) under m ↦ 1−m. [LM00, Table 5; M16, Tables 12.7–12.8.]

Muller consolidates the theory in [M16, Ch. 12]. The
probabilistic model treats the post-significand bits of f(x) as
independent fair coin flips. In this language, a hard-to-round
point is one where many bits are needed before the value is
known to lie on one side of the rounding wall rather than the
other. Under the model, the longest chain of identical bits
after the significand, among N inputs, is approximately
p + log₂(N), where p is the significand width. For double
precision with log₂ this gives roughly 53 + 55 = 108, matching
the exhaustive result. Muller's Table 12.1 shows agreement
between predicted and observed chain-length counts for sin(x)
at p = 24, down to the last row.

Gustafson's "minefield method" [G20] attacks the same geometry
from the other side. Instead of certifying the narrow passages,
he treats them as obstacles — "mines" — and builds a polynomial
that threads between them. His rule of thumb: the polynomial
needs roughly as many free coefficients as there are mines in
its domain. The construction is manual, not theoretical. He
adjusts roots interactively until the approximation clears
every mine. Perfect rounding is the direct goal, not the
consequence of high accuracy.

At precision p = 53, this stronger tool succeeds at a fixed
resolution. It identifies where the binary64 source lattice
comes closest to the rounding walls pulled back through log₂,
and it certifies the minimum clearance there. But it still does
not produce a reusable floor, density, or recurrence. It
traverses one sampled partition completely.

And it does not refine across precisions. When the precision
changes, both the source lattice and the breakpoint set change,
so the pulled-back partition changes with them. The table for
binary64 gives almost nothing about binary128. Muller states
this directly:

  "For larger precisions (e.g., binary128), an exhaustive search
  is far beyond the abilities of the most powerful current
  computers." [M16, §12.7]

When the SLZ algorithm [SLZ05] partially addresses wider
precisions, it starts fresh: new polynomial approximations on
new subintervals, new Coppersmith lattice reductions, new
feasibility instances. Nothing transfers from the binary64
computation.

## §7. The Culture

The force of §§1–6 cuts both ways. Each failure is evidence
that the obstruction is structural. But each failure is also
first-order: one floor, one deformation, one recurrence, one
sampled rounding partition at a time. The missing object, if
there is one, may live one level up.

So strengthen the tool in the only way §6 has not already
tested. Do not ask for more tables. Ask for a theory of the
family of tables.

For each precision p, §6 gives a sampled boundary-clearance
field: the distance from log₂(x) to the nearest pulled-back
rounding wall, evaluated on the source lattice of that
precision. The TMD table records the minima of that field. A
Culture-scale computation would not stop at certifying those
minima one precision at a time. It would study the whole family
{κ_p} at once, looking for transport laws from p to p+1,
renormalization rules, stable invariants of the minima,
compressed descriptions of their migration, or coordinates in
which the family aligns.

That is qualitatively different from §6. Section 6 traverses
one sampled partition completely. This move asks whether the
sequence of sampled partitions is itself a structured object.
Perhaps the tables do not refine pointwise but do cohere
second-order: perhaps the narrow passages migrate by a law, the
extremal set has a stable statistic, or the family admits a
compressed generator that no single table reveals.

If such a theory exists, it changes the question. The task is
no longer to integrate against one finite survey. It is to
extract a limit law from the procession of finite surveys. The
object of integration is not one TMD table but the family of
TMD tables.

What would success look like? Not another certified table. A
successful Culture move would produce a reusable description of
the whole family: enough structure to predict new precisions
without recomputing them from scratch, or enough compression to
replace exhaustive traversal by a law.

But that success, if it comes, still has to land somewhere.
Either the family-level theory remains descriptive —
statistics, migration rules, compressed summaries — in which
case it has not yet produced a floor for integration. Or it is
strong enough to determine the limiting object itself. Then the
gain is real, but the object reached is the same one already
waiting at the end of §4: the singular measure μ_?, not an
absolutely continuous density.

So the Culture objection is not "what if we had more search?"
Section 6 already answered that form. The serious objection is:
what if the family of failed finite surveys has a second-order
structure of its own? This is the strongest version of the
computational hope. It does not repeat §6 with larger numbers.
It asks whether the sequence of first-order failures can itself
be integrated.

---

## Status

§§1–4: classical, no novel claims.

§5: the Padé condition (rationality of corrections) is
equivalent to commensurability of the grids. Classical.

§6: the non-transferability of the TMD tables across precisions
is an empirical fact of the Lefèvre-Muller and SLZ programs,
grounded in §5's cause. The interpretation of Gustafson's mines
as near-commensurabilities is ours.

§7: the Culture objection is a thought experiment about
second-order structure. The family {κ_p} of per-precision
boundary-clearance fields may, in principle, admit transport
laws, renormalization, or compression that no single table
reveals. None of that is established here. The section's
logical content is narrower: it isolates the strongest
computational hope that is not merely "more search."

The route 1 → 2 → 3 → 4 → 5 → 6 records repeated first-order
failures against the singularity. Section 7 asks whether those
failures themselves form a higher-order object. If they do,
that object still has to land either in a descriptive theory of
the table family or in the same singular limit already present
in §4.

---

## Reading outward

- [ROARING-40s](ROARING-40s.md): the earlier version of this
  argument, with §§8–9 pursuing the forced-contradiction route
  rather than the invariance route.
- [SCYLLA](SCYLLA.md): the pincer argument. The finite-width
  machine and the unbounded accumulator face different walls
  controlled by the same ε. §8 of SCYLLA states that pincer.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§9–10: the
  displacement field Δ^L = −ε as hyperbolic distance between
  the binary and geometric grids.
- [DEPARTURE-POINT](DEPARTURE-POINT.md) §5: Day's decoupling
  theorem. The coarse-stage solution is inherited by every
  correction architecture.
- [ETAK](ETAK.md): Links 1–4 from the wall to algebraic
  independence. The forced-contradiction route and the
  invariance route enter Link 1 through different doors.
- [TRAVERSE](TRAVERSE.md): the route.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): structural doubts.

## References

- [LM00] Lefèvre, V. and Muller, J.-M. "Worst Cases for Correct
  Rounding of the Elementary Functions in Double Precision."
  INRIA Research Report RR-4044, 2000.

- [L99] Lefèvre, V. "An Algorithm That Computes a Lower Bound on
  the Distance Between a Segment and Z²." In *Developments in
  Reliable Computing*, Kluwer, 1999, pp. 203–212.

- [M16] Muller, J.-M. *Elementary Functions: Algorithms and
  Implementation*, 3rd ed. Birkhäuser, 2016. Chapter 12.

- [SLZ05] Stehlé, D., Lefèvre, V., and Zimmermann, P.
  "Searching Worst Cases of a One-Variable Function Using
  Lattice Reduction." IEEE Trans. Computers, 2005.

- [G20] Gustafson, J. L. "The Minefield Method: A Uniformly Fast
  Solution to the Table-Maker's Dilemma." Proc. IEEE, ~2020.

- [O80] Oxtoby, J. C. *Measure and Category*, 2nd ed.
  Springer-Verlag, 1980. Chapter 18.
