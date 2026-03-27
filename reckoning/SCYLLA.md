# SCYLLA

Lucky Dragon 7's corona-aliasing argument applies to machines with
finite total configuration space: at a given depth, a machine
with only finitely many configurations cannot distinguish all
local types once the corona count outruns that bound. An
unbounded real-valued accumulator evades that objection. It can
read the bit string with positional weights and compute the
affine pseudo-logarithm exactly.

This document follows that objection to its conclusion and then
closes the other jaw. The unbounded accumulator faces a
polynomial correction wall (§§1–4). The finite-width machine
faces a treewidth wall forced by the combinatorial structure of
the binary tiling (§§5–7). No single architecture evades both
(§8).

---

## §1. The objection

Fix a positive integer d. Read a binary string
(b₁, b₂, …, b_d) ∈ {0,1}^d with one control state and one
real-valued register, initialized to zero. At step j, add
δ_j · b_j to the register, where δ_j depends only on j. After
d steps the register holds

    S(b₁, …, b_d) = Σ_{j=1}^{d} δ_j · b_j .

For generic choices of (δ₁, …, δ_d), this map is injective,
so the machine can produce 2^d distinct outputs despite having
only one state. The finite-configuration aliasing argument does
not apply.

Now specialize to the binary significand of a floating-point
number x in the binade [1, 2):

    x = 1 + Σ_{j=1}^{d} 2^{−j} · b_j .

With the natural positional weights δ_j = 2^{−j}, the register
value is

    S = Σ_{j=1}^{d} 2^{−j} · b_j = x − 1 = m_x ,

the mantissa of x. On [1, 2), the pseudo-logarithm is

    L(x) = ⌊log₂ x⌋ + m_x = m_x .

So on this binade the machine computes L(x) exactly. On a
general binade [2^E, 2^{E+1}), the exponent E is obtained
separately, and the same mantissa computation gives

    L(x) = E + m_x .

The objection succeeds on its own terms: the machine resolves
the binary address exactly and gets L for free.

## §2. The gap

The true logarithm on [1, 2) is

    log₂(x) = log₂(1 + m_x) .

Having computed m_x, the machine has instead computed the affine
surrogate L(x) = m_x. Define

    ε(m) = log₂(1 + m) − m,    m ∈ [0, 1) .

Then

    log₂(x) = L(x) + ε(m_x) .

So the residual after free pseudo-log extraction is ε(m_x).
This object is architecture-free: it is determined by the
relation between log₂ and the bit-level affine surrogate, not
by any particular correction scheme.

Its basic properties are immediate:

- ε(0) = 0.
- ε(m) → 0 as m → 1.
- ε(m) > 0 for m ∈ (0, 1).
- ε is concave on [0, 1).
- ε has a unique maximum at m* = 1/ln 2 − 1 ≈ 0.4427, where
  ε(m*) ≈ 0.0861.

The unbounded accumulator has removed the addressing problem. It
has not removed ε.

## §3. Day's correction pipeline

Suppose the task is to approximate x^{−a/b} for fixed positive
integers a and b, in the setting analyzed by Day [2023]. Once
L(x) is known, form

    X = L(x),
    Y = c/b − (a/b)X,
    y = L^{−1}(Y) .

This is the coarse stage. It uses one affine map in pseudo-log
space and one inverse pseudo-log evaluation. In the bit model,
these are exact operations on the representation.

Measure the coarse error by

    z(x) = x^a · y(x)^b .

Day shows that z is a bounded continuous periodic function of
L(x), with period b, and that its range is a closed interval
[z_min, z_max] determined by c and the pair (a, b). Write

    ρ = z_max / z_min .

The correction stage seeks to approximate the exact factor
z^{−1/b} on that interval. If one restricts to a polynomial
corrector p(z) of degree at most n, the relevant quantity is the
minimax relative error

    ε_n^*(ρ) =
      min_{deg p ≤ n} max_{z ∈ [z_min, z_max]}
      |z^{−1/b} − p(z)| / z^{−1/b} .

For every finite degree n and every nondegenerate interval
[z_min, z_max], this error is strictly positive. The function
z^{−1/b} is not a polynomial on any interval of positive
length, so no finite-degree polynomial reproduces it exactly.

Therefore, even after exact computation of L and exact
resolution of z, the polynomial correction wall remains:

    ε_n^*(ρ) > 0    for every finite n .

The parameter ρ is the place where ε re-enters. In Day's
analysis, the extrema of z are set by where the pseudo-log line
crosses integer grid boundaries, and those crossings are
controlled by the deviation of L from log₂, namely ε. So the
location of the polynomial wall is controlled by ε, though the
wall itself is still the polynomial approximation problem
against z^{−1/b}.

## §4. What the objection bought

The unbounded accumulator buys something real and important.

- Zero error in computing L(x).
- Zero error in forming the coarse-stage variable z(x).
- Exact resolution of the binary address and of all realized
  z-values.

What it does not buy is exact bounded correction. With a fixed
degree-n polynomial corrector, the remaining worst-case error is
still ε_n^*(ρ), and reducing that error requires either higher
degree or a different correction architecture with additional
fixed resources.

So the objection defeats the claim that the wall sits in address
resolution. It does not defeat the claim that a wall remains. It
moves the wall downstream, from front-end access to bounded
correction.

---

## §5. The tiling

The binary subdivision of [0,1] to depth d embeds in the Poincaré
half-plane as a tiling. Depth d lives at height y = 2^{−d}. Each
of the 2^d cells has Euclidean width 1/2^d and horocyclic arc
length 1, independent of d. Consecutive depths are separated by
hyperbolic distance ln 2. Every tile is congruent: horocyclic
width 1, height ln 2.

Each tile's bottom edge has horocyclic arc length 2, split into
two halves by the vertical geodesic separating the two child cells
at depth d+1. This gives five edges: one short horocyclic edge
(a), two half-length horocyclic edges (b₁, b₂), and two geodesic
edges (c). The edge-matching rules of the Böröczky prototile are
satisfied: c meets c between same-depth neighbors; each of b₁, b₂
meets the a-edge of the corresponding child; the a-edge meets the
b₁ or b₂ of the parent. The binary address of a cell — its d-bit
string — is the tail sequence in the sense of Dolbilin & Frettlöh
Definition 3.4: bit j records whether the cell descended into the
b₁ or b₂ half at depth j. All 2^d binary strings are realized at
depth d.

By Proposition 4.3 of Dolbilin & Frettlöh, the number of distinct
k-coronae is 2^{k−1}. By Theorem 4.4, the tiling is
non-crystallographic: no finite local template captures its global
structure.

The mantissa subdivision occupies a horoball sector (the region
above y = 0 between x = 0 and x = 1), not all of H².
Kisfaludi-Bak et al. work explicitly with finite patches of the
binary tiling in Section 7 of their separator paper. They take a
subgraph B₁ of the full binary tiling graph B₀ induced by vertices
in [0,1] × [2^{−⌈9n/δ⌉}, 1], show it is a geodesic subgraph of
B₀, and conclude it retains constant hyperbolicity. The
corona-counting argument is local: it requires only that the tile
and its depth-k neighborhood exist, which they do for any tile
sufficiently far from the boundary of the patch.

### Open question

The identification above requires that the binary significand
grid, realized as a tiling of H² with horocyclic strips at ln 2
spacing, is within the Böröczky class — sharing the edge-matching
combinatorics, not just the metric parameters. The ln 2 spacing,
the doubling, the horocyclic/geodesic duality, and the inter-strip
stacking rule (hyperbolic translation by ln 2 along the
perpendicular geodesic = the shift λ in Dolbilin & Frettlöh §2)
all match. Is the cell adjacency within each strip sufficient to
place the mantissa subdivision within the Böröczky class, or is it
a different tiling built from the same ingredients — and if the
latter, does the non-crystallographic conclusion (unbounded
k-coronae, treewidth Θ(d)) still hold for it?

This question gates §§6-7. If the mantissa grid is Böröczky, the
results below apply directly. If it is a different tiling with the
same metric parameters, the treewidth bound must be established
independently for that tiling.

## §6. The treewidth bound

Kisfaludi-Bak et al. (2023), Proposition 1.3: the treewidth of
any n-vertex planar δ-hyperbolic graph is O(δ log n).

For the binary tiling at constant δ, a patch of n = 2^d cells at
depth d has treewidth Θ(d).

A finite-state machine with q states reading d bits is a width-q
read-once branching program. Width-q branching programs cannot
represent arbitrary functions on a graph of treewidth t when
q < 2^{Ω(t)}. Since t = Θ(d) and q is fixed, the machine cannot
distinguish all local types once d is large enough.

This section depends on §5: the tiling must be planar and
constant-hyperbolic for Proposition 1.3 to apply. Both properties
hold for the Böröczky tiling. If the mantissa grid is confirmed
within that class (§5, open question), the bound follows.

## §7. The aliasing consequence

The treewidth bound (§6) forces the machine to assign identical
corrections to cells whose neighborhoods differ. The displacement
field Δ^L = −ε varies across those neighborhoods: it is zero at
the binade boundaries, maximal near m* ≈ 0.4427, and concave
between. Cells with different coronas sit at different positions
in this field.

The residual is the projection of Δ^L onto the part of the
displacement field that the machine's finite width cannot
separate. The wall is nonzero because the field varies across the
aliased coronas.

This makes the wall a property of the tiling's combinatorial
complexity. The tiling has treewidth growing as Θ(d). Any finite
machine has fixed width. The gap between them is nonzero for every
finite machine at every sufficient depth. Different machines close
different parts of the gap, but the gap's existence is forced by
the tiling.

---

## §8. The pincer

Any machine that reads binary digits and produces corrections
faces at least one of these walls.

If it has finite width, the treewidth of the binary tiling
forces aliasing (§§5–7). The machine cannot distinguish all local
types, so it must assign identical corrections to cells whose
displacement field values differ. The residual is nonzero
because Δ^L varies across the aliased coronas.

If it has unbounded width and therefore resolves addressing
perfectly, the polynomial approximation problem against
z^{−1/b} forces a nonzero residual (§§3–4). Exact knowledge of
L and z does not make z^{−1/b} a polynomial.

The common element is ε. The treewidth wall exists because the
displacement field Δ^L = −ε varies across coronas that the
machine cannot distinguish. The polynomial wall exists because
ρ = z_max/z_min is controlled by ε through the grid crossings
where L deviates from log₂. Both walls measure the cost of
correcting the additive-to-multiplicative displacement with
finite resources. They do so through different mechanisms,
against different machine classes, at opposite ends of the
space/time tradeoff.

The project's sharing wall — dist(δ*, S) in the L∞ norm — is a
third object, distinct from both. It concerns shared-parameter
correctors in the minimax-intercept framework. SCYLLA does not
prove the sharing wall equals either the polynomial wall or the
treewidth wall. What it establishes is that ε is the common
obstruction: any bounded correction architecture, whether
maximally serial or supernaturally parallel, faces a wall that
is controlled by ε.

The stair-location invariance claimed in
[BINADE-WHITECAPS](BINADE-WHITECAPS.md) §12 becomes a corollary
of the treewidth structure if §§5-7 hold: stair locations are set
by the corona structure of the tiling, and the ordering does not
change because it is set by the tail sequence, which is a property
of the prototile.

---

## Status

§§1–4: established. The unbounded accumulator defeats the
address-resolution objection, computes L exactly, and still
faces a nonzero polynomial correction wall in Day's framework.

§§5–7: established conditionally. The treewidth bound
(Proposition 1.3 of Kisfaludi-Bak et al.) is a proved theorem.
The tiling embedding and corona counting (Dolbilin & Frettlöh)
are proved for the Böröczky tiling. Application to the project
depends on confirming that the binary significand grid is within
the Böröczky class (open question, flagged in §5).

§8: interpretive. The pincer framing — that the two walls
bracket the problem from opposite poles and both are controlled
by ε — is stated, not proved. The connection to the project's
sharing wall is motivated and disciplined here, not established.

## Reading outward

- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): the other six dragons.
  Dragon 7 originated there and is now developed here.
- [TRAVERSE](TRAVERSE.md): the broader traversal of the wall and
  its reformulations.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§9–13: the
  displacement field framework.
- [NARROW-PASSAGE](NARROW-PASSAGE.md) §8: the Fourier
  characterization route (suggestive connection to §§5-7).
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): the project-wide pressure
  on what has and has not been established.
- [COMPLEXITY-REEF](COMPLEXITY-REEF.md): the complexity framing
  for bounded corrective structure.

## Sources

- Day [2023], arXiv:2307.15600: the correction pipeline used
  in §§1–4.
- Kisfaludi-Bak et al. [2023], arXiv:2310.11283: separator
  theorem and treewidth bound for planar δ-hyperbolic graphs.
  Used in §§5–6.
- Dolbilin & Frettlöh [2010], *European Journal of
  Combinatorics* 31(4): corona counting and non-crystallographic
  property of the Böröczky tiling. Used in §5.
