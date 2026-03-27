# LORENTZ-ROUTE

Each level of integration machinery is a faster reference frame.
As the frame accelerates — from calculus to Riemann to Stieltjes
to Lebesgue to Padé to the civilizational enumeration of the TMD
— the residual transforms but does not vanish. The singularity
between additive and multiplicative structure is a geometric
invariant, visible from every frame, removable from none.

The sequence §§1–7 is a freefall through successive floors, each
built from heavier infrastructure than the last. §7 removes the
resource constraint entirely. The loop 7 → 4 is a fixed point.

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

The Poincaré half-plane, the hyperbolic metric, the Gauss
measure — these are all on the Lebesgue side. μ_? is on the
other side. No smooth boost crosses that gap.

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

## §6. One For All

§5 shows that a finite recurrence cannot close the gap between
binary and Farey subdivision. The generating function of the
corrections would need to be rational; the grids would need to
be commensurable; ln 2 would need to be rational. It isn't. So
no finite machine that captures a repeating pattern in the
corrections can succeed.

But §5 doesn't say anything about a finite machine that refuses
to look for a pattern. A machine that simply enumerates.

This machine exists. Lefèvre and Muller built it [LM00]. Over
four years, using approximately a hundred workstations, they
checked every double-precision floating-point input to log, exp,
log₂, 2^x, and the trigonometric functions. For each input, they
determined how close the function value comes to a rounding
breakpoint — a floating-point number or the midpoint of two
consecutive floating-point numbers. They published the worst
cases: the inputs where the function value is closest to a
breakpoint.

The core of their algorithm is a multi-scale filter. On each
small subdomain, the function is approximated by a linear
function, and the problem reduces to finding integer lattice
points near a line. This is solved by a variant of the Euclidean
algorithm — that is, by continued fractions [L99]. The
candidates surviving the filter are verified with
arbitrary-precision arithmetic. The method is exhaustive: every
input is checked, either by the filter or directly.

For log₂(x) on the full double-precision range, the result is
Property 4 of [LM00]: 55 extra bits beyond the 53-bit
significand suffice to resolve correct rounding, in all four
IEEE-754 rounding modes. The worst case for log₂ in the binade
[1/2, 1) has the form

    log₂(1.0110000101...) = −10000000000.1000100001...10100101...
                             followed by 55 zeros,

and the corresponding worst case in [1, 2) has those 55 zeros
replaced by 55 ones, by bit complementation — a symmetry of
ε(m) under m ↦ 1−m. [LM00, Table 5; M16, Tables 12.7–12.8.]

Muller consolidates the theory in [M16, Ch. 12]. The
probabilistic model treats the post-significand bits of f(x) as
independent fair coin flips. Under this model, the longest chain
of identical bits after the significand, among N inputs, is
approximately p + log₂(N), where p is the significand width.
For double precision with log₂ this gives roughly 53 + 55 = 108,
matching the exhaustive result. Muller's Table 12.1 shows
agreement between predicted and observed chain-length counts for
sin(x) at p = 24, down to the last row.

Gustafson's "minefield method" [G20] inverts the problem. Instead
of minimizing approximation error uniformly and hoping this
resolves all rounding decisions, he treats the hard-to-round
points as obstacles — "mines" — and builds a polynomial that
threads between them. His rule of thumb: the polynomial needs
roughly as many free coefficients as there are mines in its
domain. The construction is manual, not theoretical. He adjusts
roots interactively until the approximation clears every mine.
Perfect rounding is the direct goal, not the consequence of high
accuracy.

What does this accomplish, read as an integration tactic?

At precision p = 53, the question "how does log₂(1+m) interact
with the binary grid?" is completely answered. The table of worst
cases is an exhaustive census of the near-commensurabilities
between the function ε(m) and the breakpoint structure at this
resolution. The corrections from ε to the grid are known
individually, for every input. The Padé ghost (§5) said a
*pattern* in the corrections cannot be captured finitely. The
TMD project says: we don't need a pattern. We have the list.

The list is exact. It is a theorem, not an estimate. Every
double-precision input to log₂ is correctly accounted for. In
the language of §§1–4, this is successful Riemann-Stieltjes
integration of ε against the breakpoint measure at resolution
p = 53.

But the list does not refine.

Riemann integration refines: the sum at mesh h/2 includes and
improves the sum at mesh h. Partial sums accumulate. You can
stop at any resolution and you have captured everything coarser.

The TMD table at precision p gives almost nothing about precision
p+1. The breakpoints move when the grid changes. The
near-coincidences are controlled by different convergents of
continued fractions at different precisions. The table for
binary64 does not extend, inform, or constrain a table for
binary128. Muller states this directly:

  "For larger precisions (e.g., binary128), an exhaustive search
  is far beyond the abilities of the most powerful current
  computers." [M16, §12.7]

When the SLZ algorithm [SLZ05] partially addresses wider
precisions, it starts fresh: new polynomial approximations on
new subintervals, new Coppersmith lattice reductions, new
feasibility instances. Nothing transfers from the binary64
computation.

This is §5's consequence, visible as engineering. The Padé ghost
says the corrections cannot be eventually periodic. Therefore
the table at precision p cannot predict precision p+1. Each
precision is a separate, complete, non-transferable act of
computation. The work grows (exponentially for exhaustive search,
subexponentially for SLZ) and the results are
precision-specific.

The thermocline here is sharper than §5's. §5 says: a finite
recurrence fails because the generating function is irrational.
§6 says: enumerate without a recurrence, and you succeed — but
the success is trapped at its resolution. The computational cost
of resolving the ε-grid interaction at precision p is paid in
full, buys nothing toward precision p+1, and must be repaid from
scratch at the new precision. Each level of the Stern-Brocot
correction sequence (§4) costs a fresh civilizational effort.

Gustafson's mines are the near-commensurabilities. His
polynomial threads between the ghosts of grid alignment.
Lefèvre and Muller's filter finds the ghosts by invoking
continued fractions — the same machinery that governs rational
approximation to ln 2. The four years and hundred machines are a
measurement of the computational cost of one level of the
fractal floor (§4), at one specific resolution.

The floor supports this weight. At p = 53, the floor is solid.
Step to p = 113 and you are standing on air.

## §7. The Culture

Suppose the machine has no resource bound. Not a larger
computer. A machine that has already completed every finite
computation. It has the TMD table for every precision p: for
p = 53, for p = 113, for every natural number. It has every
convergent of the continued fraction of ln 2.

§6 showed that each table is exact and non-transferable. The
machine overcomes non-transfer by holding all tables
simultaneously. For each mantissa value m = j/2^p at every
precision p, it knows the complete interaction between
log₂(1+m) and the breakpoint grid. By density and continuity,
this determines ε(m) everywhere on [0,1]. The machine knows ε.

The fractal floor of §4, which converged to μ_? through a
sequence of finite piecewise-smooth approximations, is now a
completed object. The machine holds the limit. It has μ_?.

With μ_? in hand, integration works. For any continuous f, the
machine evaluates ∫f dμ_? by Riemann-Stieltjes sums at every
mesh width and takes the limit. It has the entire integral
operator f ↦ ∫f dμ_?.

It cannot write dμ_? = g(x)dx. Not because something remains
to be calculated. Because g does not exist. The machine has
complete knowledge of both measures. Their mutual singularity
is a property of the relationship between two completed
infinite objects held simultaneously. No further computation is
available. The obstruction is not a deficit of information. It
is a theorem about structure.

The floor supports only itself. This is §4.  ∎

---

## Status

§§1–4: classical, no novel claims.

§5: the Padé condition (rationality of corrections) is
equivalent to commensurability of the grids. Classical.

§6: the non-transferability of the TMD tables across precisions
is an empirical fact of the Lefèvre-Muller and SLZ programs,
grounded in §5's cause. The interpretation of Gustafson's mines
as near-commensurabilities is ours.

§7: the transfinite completion is a thought experiment. Its
logical content is that removing the resource constraint does
not remove the singularity. The loop 7 → 4 is forced: the
completed object is μ_? itself, and μ_? is mutually singular
with Lebesgue. This is classical once you hold the completed
object.

The loop 1 → 2 → 3 → 4 → 5 → 6 → 7 → 4 is a fixed point.
Every path through the levels returns to §4. The singularity
between additive and multiplicative structure is not a
computational problem. It is the geometry.

---

## Reading outward

- [ROARING-40s](ROARING-40s.md): the earlier version of this
  argument, with §§8–9 pursuing the forced-contradiction route
  (the Brouwer route) rather than the invariance route.
- [SCYLLA](SCYLLA.md): the pincer argument. The finite-width
  machine and the unbounded accumulator are two reference frames
  viewing the same invariant ε. §8 of SCYLLA is the
  frame-independence claim.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§9–10: the
  displacement field Δ^L = −ε as hyperbolic distance between
  the binary and geometric grids.
- [DEPARTURE-POINT](DEPARTURE-POINT.md) §5: Day's decoupling
  theorem. The coarse-stage solution is inherited by every
  correction architecture. Frame-independence of the coarse
  structure.
- [ETAK](ETAK.md): Links 1–4 from the wall to algebraic
  independence. The Brouwer route and the Lorentz route enter
  Link 1 through different doors.
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
