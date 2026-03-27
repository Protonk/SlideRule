# Dragon 7. The wall as a non-crystallographic theorem

The binary significand grid embeds in the Poincaré half-plane as
a tiling. The tiling's combinatorial complexity — unbounded corona
count, growing treewidth — forces any finite-width machine to
alias cells whose displacement field values differ.

This document separates the argument into four parts with
different epistemic status. §1 describes the tiling and states
the open question that gates everything after it. §2 applies the
treewidth bound. §3 draws the aliasing consequence. §4 records
downstream connections that depend on §§1-3.

---

## §1. The tiling

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

This question gates §§2-4. If the mantissa grid is Böröczky, the
results below apply directly. If it is a different tiling with the
same metric parameters, the treewidth bound must be established
independently for that tiling.

---

## §2. The treewidth bound

Kisfaludi-Bak et al. (2023), Proposition 1.3: the treewidth of
any n-vertex planar δ-hyperbolic graph is O(δ log n).

For the binary tiling at constant δ, a patch of n = 2^d cells at
depth d has treewidth Θ(d).

A finite-state machine with q states reading d bits is a width-q
read-once branching program. Width-q branching programs cannot
represent arbitrary functions on a graph of treewidth t when
q < 2^{Ω(t)}. Since t = Θ(d) and q is fixed, the machine cannot
distinguish all local types once d is large enough.

This section depends on §1: the tiling must be planar and
constant-hyperbolic for Proposition 1.3 to apply. Both properties
hold for the Böröczky tiling. If the mantissa grid is confirmed
within that class (§1, open question), the bound follows.

---

## §3. The aliasing consequence

The treewidth bound (§2) forces the machine to assign identical
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

## §4. Downstream connections

These depend on §§1-3 and have additional conjectural content.

### Staircase corollary

The stair-location invariance claimed in
[BINADE-WHITECAPS](BINADE-WHITECAPS.md) §12 becomes a corollary
of the tiling structure: stair locations are set by the corona
structure, stair heights vary by architecture, and the ordering
does not change because it is set by the tail sequence, which is a
property of the prototile. The covering game in Step 6 does not
need to argue about specific architectures if the obstruction is a
property of the tile complex itself.

### Fourier unification conjecture

The connection to the Fourier picture in
[NARROW-PASSAGE](NARROW-PASSAGE.md) §8 is suggestive but
unproved. If the treewidth bound controls the number of absorbable
Fourier modes of Δ^L, the spectral characterization of the
residual (modes beyond the machine's width) would follow from the
tiling's treewidth growth. This would unify the combinatorial
(corona-counting) and analytical (Fourier tail) descriptions of
the wall. Whether this unification is real depends on whether the
FSM's sharing constraints are approximately aligned with the
Walsh-Hadamard basis of Δ^L — a question the existing
experimental infrastructure could test.

---

## Status

§1: the tiling embedding and its properties are stated. The open
question (Böröczky class membership) is unresolved and gates
everything below.

§2: the treewidth bound is a proved theorem (Kisfaludi-Bak et al.,
Proposition 1.3). Its application here is conditional on §1.

§3: the aliasing consequence follows from §2 by standard
branching-program arguments. Conditional on §§1-2.

§4: the staircase corollary is conditional on §§1-3. The Fourier
unification is a separate conjecture.

---

## Reading outward

- [SCYLLA](SCYLLA.md) §4a: where the treewidth wall enters the
  pincer argument.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§9–13: the
  displacement field framework.
- [NARROW-PASSAGE](NARROW-PASSAGE.md) §8: the Fourier
  characterization route.
- [TRAVERSE](TRAVERSE.md) Step 6: the crossing this dragon
  supports.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §1: the fan-out problem.
- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): the other six dragons.

## Sources

- Dolbilin & Frettlöh, "Properties of Böröczky tilings in
  high-dimensional hyperbolic spaces," *European Journal of
  Combinatorics* 31(4), 2010.
- Kisfaludi-Bak et al., "Separator Theorem and Algorithms for
  Planar Hyperbolic Graphs," arXiv:2310.11283, 2023.
