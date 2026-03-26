# Here Be Dragons

Purpose: record six speculative ideas arising from the pentagonal
variant of the binary tiling. None are connected to established
results. None have been tested. They are drawn on the map because
they were seen from the ship, not because anyone has landed.

Source observation: the Böröczky tiling has two combinatorially
equivalent realizations. The standard version connects vertices by
horocyclic arcs (geodesic curvature κ = 1); the pentagonal version
connects the same vertices by hyperbolic geodesics (κ = 0), producing
convex pentagons. In the half-plane model, the geodesic edges become
semicircles centered on the x-axis. The two tilings share all vertices
and combinatorics; they differ only in edge geometry.

Reference: David Eppstein, "A half-flipped binary tiling," blog post,
6 October 2024.
https://11011110.github.io/blog/2024/10/06/half-flipped-binary.html

Mathematical source: Dolbilin & Frettlöh, "Properties of Böröczky
tilings in high-dimensional hyperbolic spaces," *European Journal of
Combinatorics* 31(4), 2010.

Connection to project: POINCARE-CURRENTS.md identifies the binary (uniform)
partition as the horocyclic slicing and the geometric partition as the
geodesic slicing of the same hyperbolic structure. The pentagonal
variant makes this duality a fact of tiling theory rather than an
analogy.

---

## Dragon 1. ε as area between two types of straightness

The region between a horocyclic arc and the geodesic connecting the
same two endpoints has a definite hyperbolic area, computable from
the metric without writing down log₂ or the pseudo-log. For a tile
of height ln 2, this bulge area is determined by the width parameter
alone.

If the per-tile bulge area maps onto ε(m) evaluated at the
corresponding mantissa, you get a derivation of the pseudo-log error
bound that comes from intrinsic hyperbolic geometry — curvature of
horocycles — rather than from analyzing log₂(1+m) − m by Taylor
series. A derivation with different dependencies. It does not "square
the logarithm by squaring the logarithm" because it never mentions
the logarithm; it mentions curvature.

Whether this provides escape velocity from restating Mitchell 1962
is unknown.

## Dragon 2. Convexity shift as a partition-quality diagnostic

Standard binary tiles are non-convex (concave on top). Pentagonal
tiles are convex. In approximation terms: on a geometric partition,
the chord connecting log₂ values at cell boundaries lies entirely on
one side of the curve — the error is one-signed within the cell. On
a uniform partition, the chord can cross the curve, producing sign
changes within a cell. The non-convexity of the horocyclic tile
manifests as non-monotone error within a cell.

The number of sign changes of the error within a cell is controlled
by how far the partition boundary is from geodesic. This is already
implicit in the zero-crossing diagnostic (number of zero-crossings
of log-mismatch predicts extrema count in the error envelope). The
tiling language gives it a geometric name: counting how many times
the horocyclic boundary crosses the geodesic one within a tile.

## Dragon 3. Curvature profile for partition families

Every partition in the zoo defines, implicitly, a family of curves
connecting depth d to depth d+1. Uniform uses horocycles (κ = 1
everywhere). Geometric uses geodesics (κ = 0 everywhere). The
interesting partitions — dyadic_x, stern_brocot_x, adversarial
constructions — use boundaries that are neither uniform nor
geometric, corresponding to curves of varying curvature κ(m).

The curvature-mismatch scatter plot (cell width / locally optimal
geometric width per cell) is essentially measuring κ cell by cell.
The tiling framework suggests a cleaner object: the geodesic
curvature of the inter-level connection at each cell boundary,
living in [0, 1], equalling 0 at geometric boundaries. This might
be a more natural parameterization of the zoo than width-ratio.

## Dragon 4. Parallel transport and the delta table as a connection

The FSM reads bits and accumulates deltas — it moves through the
tiling along a path, cell by cell, at a fixed depth. In the standard
binary tiling, that path follows a horocycle. Parallel transport of a
vector along a horocycle rotates the frame by a definite amount per
unit of arc. Along a geodesic, no drift occurs.

The total frame-drift across a full row of 2^d tiles is the
integrated displacement Σ Δ_k, which sums to 0 by endpoint agreement
(b_0 = g_0, b_{2^d} = g_{2^d}) but has a signed profile peaking
near m*. The delta table compensates for this drift. In
differential-geometric language: the delta table is a discrete
connection on the tiling, the displacement field Δ^L is the curvature
of the trivial (zero-delta) connection, and the wall measures how
well a finite set of connection coefficients can flatten this
curvature.

This buys a language: the wall is a curvature residual, the delta
table is a connection. The question "is the wall
architecture-intrinsic?" becomes "does the curvature depend on the
connection or only on the base space?" In Riemannian geometry the
answer is clear (curvature of the base is intrinsic; the connection
is not). In this discrete setting it is less clear, but the question
is well-posed.

## Dragon 5. The harmonic sequence under inversion

Eppstein shows that inverting a binary tiling through a geodesic
perpendicular to the symmetry axis maps equally-spaced tile
boundaries to a harmonic sequence: radii proportional to
1, 1/2, 1/3, 1/4, ... This is the discrete shadow of the fact that
exp maps additive structure to multiplicative structure — the same
fact that makes the pseudo-log work. The inversion is a Möbius
transformation, hence a hyperbolic isometry: it preserves all metric
relationships while changing the model representation.

This gives a third reference frame: the "inverted" frame where binary
spacings become harmonic spacings. In this frame the ε function looks
different — the peak near m* maps somewhere else, the endpoints still
agree. Whether any wall structure simplifies there is unknown. It is
a navigational move: same ocean, different star chart.

## Dragon 6. Farey tiling as a genuinely different tiling

The pentagonal variant is the same tiling with different edges. The
Farey tessellation is a different tiling entirely — ideal triangles
with vertices at rationals on the boundary circle. The zoo already
has stern_brocot_x and farey_rank_x.

In the tiling language: binary splits are digit-processing-optimal
(one bit per split), Farey-mediant splits are
rational-approximation-optimal (simplest fraction per split), and
geometric splits are error-equalization-optimal (equal cell
difficulty). These three optimality criteria produce three different
tilings. Their agreements (depth 1: all three split at 3/2) and
divergences (depth 2: binary at 5/4, Farey at 4/3) characterize the
costs of choosing one representation over another.

For TRAVERSE Step 6: the tiling framework suggests a specific
form of the architecture-invariance question. Is the exchange rate
determined by the base tiling (vertices and combinatorics, shared
between horocyclic and geodesic variants) or by edge geometry (which
differs)? If the combinatorial structure determines the binding-cell
ordering regardless of how edges are drawn, the pentagonal variant
provides the geometric reason architecture-invariance might hold.

---

Let me read the existing document and the uploaded NARROW-PASSAGE to make sure Dragon 7 doesn't repeat something already crystallized there.Good. NARROW-PASSAGE §4 already says the correction task difficulty is a property of ε and the input representation, not the corrector. But it argues this from the coordinate theory — from the fact that all correctors approximate the same function. Dragon 7 would argue it from the tiling's combinatorial structure, which is a different and potentially stronger route.

Here's a draft.

---

## Dragon 7. The wall as a non-crystallographic theorem

The binary subdivision of [0,1] to depth d embeds in the Poincaré
half-plane as a tiling. Depth d lives at height y = 2^{−d}. Each of
the 2^d cells has Euclidean width 1/2^d and horocyclic arc length 1,
independent of d. Consecutive depths are separated by hyperbolic
distance ln 2. Every tile is congruent: horocyclic width 1, height
ln 2.

Each tile's bottom edge has horocyclic arc length 2, split into two
halves by the vertical geodesic separating the two child cells at
depth d+1. This gives five edges: one short horocyclic edge (a),
two half-length horocyclic edges (b₁, b₂), and two geodesic edges
(c). The edge-matching rules of the Böröczky prototile are
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
above y = 0 between x = 0 and x = 1), not all of H². Kisfaludi-Bak
et al. work explicitly with finite patches of the binary tiling in
Section 7 of their separator paper. They take a subgraph B₁ of the
full binary tiling graph B₀ induced by vertices in
[0,1] × [2^{−⌈9n/δ⌉}, 1], show it is a geodesic subgraph of B₀,
and conclude it retains constant hyperbolicity. The corona-counting
argument is local: it requires only that the tile and its depth-k
neighborhood exist, which they do for any tile sufficiently far from
the boundary of the patch.

The same paper establishes (Proposition 1.3) that any n-vertex
planar δ-hyperbolic graph has treewidth O(δ log n). For the binary
tiling at constant δ, a patch of n = 2^d cells at depth d has
treewidth Θ(d). A finite-state machine with q states reading d bits
is a width-q read-once branching program. Width-q branching programs
cannot represent arbitrary functions on a graph of treewidth t when
q < 2^{Ω(t)}. Since t = Θ(d) and q is fixed, the machine must
assign identical corrections to cells whose neighborhoods — and
therefore whose displacement field values — differ. The residual is
the projection of Δ^L onto the part of the displacement field that
the machine's finite width cannot separate.

This makes the wall a property of the tiling's combinatorial
complexity rather than of any specific correction architecture.
The tiling has treewidth growing as Θ(d). Any finite machine has
fixed width. The gap between them is nonzero for every finite
machine at every sufficient depth. Different machines close
different parts of the gap, but the gap's existence is forced by
the tiling, not by the machine's design.

The stair-location invariance claimed in POINCARE-CURRENTS §5
becomes a corollary: stair locations are set by the corona structure
of the tiling, stair heights vary by architecture, and the ordering
does not change because it is set by the tail sequence, which is a
property of the prototile. The covering game in Step 6 does not
need to argue about specific architectures if the obstruction is a
property of the tile complex itself.

The connection to the Fourier picture in NARROW-PASSAGE §8 is
suggestive but unproved. If the treewidth bound controls the number
of absorbable Fourier modes of Δ^L, the spectral characterization
of the residual (modes beyond the machine's width) would follow
from the tiling's treewidth growth. This would unify the
combinatorial (corona-counting) and analytical (Fourier tail)
descriptions of the wall. Whether this unification is real depends
on whether the FSM's sharing constraints are approximately aligned
with the Walsh-Hadamard basis of Δ^L — a question the existing
experimental infrastructure could test.

**Open question.** The identification above requires that the binary
significand grid, realized as a tiling of H² with horocyclic strips
at ln 2 spacing, is within the Böröczky class — sharing not just the
metric parameters but the edge-matching combinatorics. The ln 2
spacing, the doubling, the horocyclic/geodesic duality, and the
inter-strip stacking rule (hyperbolic translation by ln 2 along the
perpendicular geodesic = the shift λ in Dolbilin & Frettlöh §2) all
match. Is the cell adjacency within each strip sufficient to place
the mantissa subdivision within the Böröczky class, or is it a
different tiling built from the same ingredients — and if the
latter, does the non-crystallographic conclusion (unbounded
k-coronae, treewidth Θ(d)) still hold for it?


---

## What this document is not

This is not a research plan. There are no experiments proposed, no
hypotheses stated, no predictions made. Each dragon may turn out to
be a cloud, a coastline, or a sea monster. The purpose is to have
them written down so they can be examined one at a time under
controlled skepticism, rather than drifting as ambient enthusiasm.

## Reading outward

- [`POINCARE-CURRENTS.md`](POINCARE-CURRENTS.md): the displacement
  field framework these dragons extend.
- [`ABYSSAL-DOUBT.md`](ABYSSAL-DOUBT.md): the doubt about whether
  the wall measures the problem or the architecture.
- [`TRAVERSE.md`](TRAVERSE.md): Steps 5–6 that Dragons
  4 and 6 gesture toward.
- [`AGENTS.md`](AGENTS.md): epistemological rules for the reckoning.
