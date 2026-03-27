# Narrow Passage

Working two dragons (6, then 4) to get purchase on a third (1).

The passage is from TRAVERSE Step 6 — the coordinate change from
geometric to computational language — toward a statement about
finite machines that does not name the FSM.

---

## Bearing under Radin §3

Radin's discussion of the Böröczky paradox shows that the binary
tiling does not support per-tile bookkeeping that is invariant under
hyperbolic isometries. That constraint matters here because this note
uses the binary tiling as geometric scaffolding.

The discipline is simple. Binade-local and per-tile objects are safe:
finite fields such as `Δ^L`, per-tile bulge areas `A(k, d)`, and
function analysis of `ε` on `[0,1]`. The danger begins only when
those local objects are promoted to global claims about the tiling.
In particular, sums, averages, densities, "total curvature", and
aggregate bulge areas must not be treated as invariant geometric
quantities of the binary tiling. If Dragon 1 succeeds, the conclusion
is only that `ε` has a per-tile geometric derivation.

---

## Part I. Three partitions and a divergence schedule (Dragon 6)

### 1. The three partitions

On [1, 2) at depth d, three partition families place their interior
grid points by different rules:

**Binary (uniform).** b_k = 1 + k/2^d. Additive subdivision.
Each split bisects the current interval. One bit determines which
half. This is the partition imposed by reading significand bits.

**Geometric.** g_k = 2^{k/2^d}. Multiplicative subdivision.
Each split is at the geometric mean of the interval's endpoints.
This is the partition at which ε vanishes — the zero-cost baseline
for chord approximation of log₂.

**Farey (Stern-Brocot mediant).** Recursively: the split point
of [p/q, r/s] is the mediant (p+r)/(q+s). Each split produces
the simplest new fraction. This is the partition optimal for
rational approximation of position within the binade.

Three optimality criteria — digit-processing, error-equalization,
rational-approximation — produce three different grids.

### 2. The divergence schedule

At depth 0 all three agree: boundaries at 1, 2.

At depth 1:

| Family    | Interior point | Decimal     |
|-----------|----------------|-------------|
| Binary    | 3/2            | 1.5000      |
| Farey     | 3/2            | 1.5000      |
| Geometric | √2             | 1.4142…     |

Binary and Farey agree. Geometric is alone. (Dragon 6 states that
all three agree at depth 1. This is wrong. The geometric split
is at √2, not 3/2.)

At depth 2, three interior points each:

| Family    | Points              | Decimal approx          |
|-----------|---------------------|-------------------------|
| Binary    | 5/4, 3/2, 7/4       | 1.250, 1.500, 1.750     |
| Farey     | 4/3, 3/2, 5/3       | 1.333, 1.500, 1.667     |
| Geometric | 2^¼, √2, 2^¾        | 1.189, 1.414, 1.682     |

Now all three disagree at the first and third interior points.
Binary and Farey still share the midpoint 3/2; geometric has √2
there, as at depth 1.

The pattern: binary and Farey share the leading split (the mediant
of the binade endpoints is 3/2, which is also the arithmetic
midpoint). They first diverge at depth 2, where binary bisects
additively (5/4) and Farey bisects by mediant (4/3). Geometric
diverges from both at depth 1 and the gap widens thereafter.

### 3. The divergence IS the displacement field

The displacement between binary and geometric grids in pseudo-log
space at grid point k is

    Δ^L_k = L(b_k) − log₂(g_k) = (k/2^d) − (k/2^d) = 0?

No. L(b_k) = k/2^d (the pseudo-log of the binary grid point,
since b_k ∈ [1,2) has mantissa k/2^d). But log₂(b_k) ≠ k/2^d.
The geometric grid point g_k has log₂(g_k) = k/2^d by
construction. So the displacement between the binary grid point
and the geometric grid point, measured in log₂ coordinates, is

    log₂(b_k) − log₂(g_k) = log₂(1 + k/2^d) − k/2^d = ε(k/2^d).

And the displacement measured in pseudo-log coordinates is

    L(b_k) − L(g_k) = (k/2^d) − L(2^{k/2^d}).

Since L(2^{k/2^d}) = (k/2^d) only when k/2^d is an integer (the
pseudo-log is exact at powers of 2), the two displacements are
related by the pseudo-log residual evaluated at the geometric
point. But the simpler and more useful statement is the one
already in BINADE-WHITECAPS §9: the displacement field at the binary
grid points is Δ^L_k = −ε(k/2^d), which is the pseudo-log
residual evaluated at the binary mantissa.

The divergence schedule between binary and geometric tilings is
ε, sampled at the binary grid points. This is forced by the
coordinate theory and requires no reference to any correction
architecture.

### 4. What the three-partition framework buys

A finite machine reading binary significand bits is committed to
the binary partition's addressing scheme. It receives a d-bit
string and must produce a correction. The correction task is:
given a binary address, output a value close to the displacement
between binary and geometric grids at that address.

The correction function is

    f: {0,1}^d → ℝ,    f(bits) = δ*_{cell(bits)},

where δ* is the free-per-cell optimal correction vector, organized
by ε. The Farey partition enters as a control: it provides a
second divergence schedule from the geometric baseline. The
displacement between Farey and geometric is a different function
on a different domain, but it is governed by the same target
(the geometric grid) and therefore by the same ε.

This means: the difficulty of the correction task — however
measured — is a property of the target function ε and the input
representation, not of the corrector. Different correctors face
different versions of the task (FSM reads bits sequentially; a
lookup table reads them all at once; a shared-coefficient
polynomial evaluates them differently). But all of them are
computing approximations to the same f.

The three-partition framework makes this visible. The geometric
partition is the destination. The binary partition is the
departure point. The Farey partition is a third port that is
equidistant from the destination in a different direction: the
binary-to-geometric displacement is organized by ε(k/2^d),
while the Farey-to-geometric displacement is organized by the
same ε evaluated at the Farey grid points' mantissas. The
correction cost from either departure point is governed by
the structure of ε composed with the respective grid, not by
the correction device.

---

## Part II. The correction task as connection-flattening (Dragon 4)

### 5. What the FSM is doing, reframed

The FSM reads bits one at a time, updating a state and
accumulating a correction. At each step, the accumulated
correction changes by δ[(state, bit)]. After d steps, the
total correction is the sum of d increments along the path
determined by the input bits.

In the tiling language: the FSM is walking along a row of tiles
at depth d, one tile per bit, accumulating a displacement. Each
step adds a local increment that depends on the current state and
the current bit. The total accumulated displacement after the walk
is the correction applied to that cell.

The target is the displacement field Δ^L. The FSM's job is to
produce a walk whose accumulated displacement matches −Δ^L at
every cell. The delta table determines the increments; the state
transition function determines which increments are available at
each step.

### 6. The connection analogy

In differential geometry, a connection on a fiber bundle tells
you how to transport a quantity along a path. Parallel transport
along a curved path accumulates a discrepancy (holonomy) that
measures the curvature of the connection. A flat connection has
zero holonomy.

The delta table is an assignment of increments to (state, bit)
pairs — an instruction for how to update the accumulated
correction at each step. This is structurally a discrete
connection: it tells you how to transport the correction along
the path through the binary tree. The trivial connection (all
deltas zero) accumulates zero correction everywhere. The
displacement field Δ^L is then the "curvature" that the
connection must flatten: the discrepancy between the trivial
connection and the target.

The wall is the L∞ residual of the best q-coefficient
connection applied to a fixed curvature field.

### 7. What this language does not yet buy

The analogy in §6 is suggestive but not yet load-bearing. Three
things are missing.

**The base space is not a manifold.** The binary tree is a
discrete graph. Connections on graphs are well-defined (as
assignments of group elements to edges), but the relationship
between connection coefficients and curvature is combinatorial,
not differential. The smooth intuition — that curvature is local
and connections are global — may or may not survive
discretization.

**The sharing constraint is not a gauge condition.** In gauge
theory, different connections related by gauge transformations
produce the same curvature. Here, the sharing constraint (q states,
layer-invariant or layer-dependent) restricts the space of
connections to a subspace S. The restriction is architectural, not
gauge-theoretic. Nothing in the formalism says that two connections
in S are "equivalent" — they are merely both achievable. The
subspace S plays the role of a "connection budget," not a gauge
orbit.

**The curvature field may not determine the residual.** The wall
is dist(Δ^L, S). Even if Δ^L is fixed by the representation,
S is not. Different architectures produce different S, hence
different walls, hence different residuals — all for the same
curvature field. The connection language reformulates the wall
cleanly but does not by itself show that the residual is
controlled by the curvature alone.

**The analogy stops before global aggregation.** `Δ^L` is a
well-defined finite field at fixed depth `d`. Calling it
"curvature" is useful only at that level. Nothing here licenses
summing, averaging, or integrating that field across rows of
tiles and treating the result as an isometry-invariant quantity
of the binary tiling.

### 8. What the connection language might buy

If the following could be established — and this is speculative,
not claimed — the connection language would become structural
rather than decorative:

**A spectral characterization of the residual.** The curvature
field Δ^L has a Fourier decomposition on the binade circle
(BINADE-WHITECAPS §8). A width-q machine can absorb at most
O(q) Fourier modes. The residual is then controlled by the tail
of the Fourier series of Δ^L — a statement about the smoothness
of ε, not about the machine. This would make the residual a
function of (Δ^L, q), not of (Δ^L, S), collapsing the
architecture-dependence to a single parameter.

If this route is real, it must be proved as compact-domain
Fourier analysis of `ε` and as a rank or approximation statement
about `S`. The hyperbolic picture is scaffolding for the route,
not part of its proof.

This is the most promising route because it converts the question
"which directions does S span?" into "how many modes can q states
absorb?" — a quantity that depends on the machine only through its
width. Whether it is true depends on whether the FSM's sharing
constraints are approximately aligned with the Fourier basis of
Δ^L, which is an empirical question that the existing
infrastructure could test.

**A lower bound from the curvature field.** If the Fourier tail
of Δ^L at mode q gives a lower bound on the residual achievable
by any width-q sequential reader of binary digits, the bound is
architecture-free. It says: no matter how you wire the states,
you cannot flatten more than O(q) modes of curvature per layer,
because each bit carries at most one bit of mode-selection
information and you have q slots to store it.

This is the connection to branching program lower bounds in
[COMPLEXITY-REEF](COMPLEXITY-REEF.md) §5. The Fourier characterization would be the
specific form such a bound takes for the correction function.

---

## Part III. Purchase on the bulge area (Dragon 1)

### 9. What Parts I and II set up

Part I establishes: the correction task is determined by ε,
the displacement between two grids (binary and geometric) on
the same domain.

Part II suggests (without proving): the cost of the correction
task is controlled by the information content of ε — its Fourier
complexity — not by the architecture of the corrector.

If both hold, the cost of correcting the pseudo-log is a
functional of ε alone. The question becomes: what IS ε, at the
most fundamental level? Is it an analytic accident (the Taylor
series of log₂(1+m) minus m), or does it have a geometric
identity?

### 10. The specific calculation

In the Poincaré half-plane model, place the binary grid point
b_k and the geometric grid point g_k at the same binade level.
They are connected by two paths:

- The horocyclic arc (horizontal line segment at constant y),
  which is the binary tiling's inter-cell boundary.
- The geodesic (semicircular arc), which is the pentagonal
  variant's inter-cell boundary.

These two paths bound a region — the "bulge" — with a definite
hyperbolic area. Dragon 1 asks: does this area equal ε(k/2^d)?

If it does, then ε admits a per-tile geometric derivation. The
area between two notions of straightness in a space of constant
negative curvature reproduces the same local quantity that appears
analytically as `log₂(1+m) - m`. That would identify a geometric
source for ε at the tile level. It would not, by itself, make ε a
global invariant of the binary tiling.

### 11. What the calculation requires

The binary and geometric grid points are at different horizontal
positions along the same horocycle (the binade level), not at
different heights. The horocyclic arc connects adjacent tile
vertices; the geodesic connects the same vertices. The bulge
region is bounded by two curves connecting the SAME pair of
endpoints (the vertices shared by both tilings). Its area
depends on the tile width, which varies across the row.

The computation is: for a horocyclic segment of Euclidean
length w at height h, what is the hyperbolic area between the
segment and the geodesic (semicircle) connecting its endpoints?

For a horocyclic segment from (x₀, h) to (x₀ + w, h), the
geodesic connecting the same endpoints is a semicircle of
radius w/2 centered at (x₀ + w/2, 0). The bulge area is

    A = ∫∫_R dA_hyp = ∫∫_R dx dy / y²

over the region R between the horizontal segment and the
semicircle.

This integral has a closed form. Whether that closed form,
evaluated at the tile widths and heights determined by the
binary tiling at depth d, yields ε(k/2^d) — that is the
question Dragon 1 poses.

### 12. What to do

Compute the bulge area integral for a single tile. The
parameters are: tile width w_k (Euclidean), tile height h_k,
both determined by the binade structure. Express the result
in terms of k and d. Compare with ε(k/2^d).

If they match: ε has a per-tile geometric derivation independent
of its analytic presentation. The correction cost in Part II may
then be read as the cost of reducing a finite residual field whose
entries come from hyperbolic tile geometry. The logarithm remains
the coordinate in which that local field takes the form `ε`; this
does not make the binary tiling itself carry a well-defined global
curvature or invariant aggregate bulge area.

If they do not match: determine whether the discrepancy is a
monotone reparametrization (in which case the qualitative picture
survives but the quantitative identity fails) or a structural
mismatch (in which case Dragon 1 is a cloud, not a coastline,
and Parts I–II still stand on their own).

---

## Scope

This document is preparation for the coordinate change
(TRAVERSE Step 6). Part I is ready to use. Part II identifies
what would need to be true for the connection language to bear
weight. Part III identifies a specific calculation whose outcome
determines whether the weight traces to geometry or stops at
analysis.

## Reading outward

- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): Dragons 1, 4, 6 as
  originally sighted.
- [TRAVERSE](TRAVERSE.md) Step 6: the crossing this passage
  prepares.
- [COMPLEXITY-REEF](COMPLEXITY-REEF.md) §5: branching program and
  communication complexity routes.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§7–9: the displacement
  field and Fourier structure of the density defect.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §§1, 4: the fan-out problem
  and the subspace objection.
