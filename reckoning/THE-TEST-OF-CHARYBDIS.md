# The Test of Charybdis

Is the FSM's wall special, or would any subspace of the same
dimension produce a wall with similar ε-structure? This note
describes a rotation check that can answer that narrower question
with existing infrastructure.

The test responds to [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §4b.

---

## 1. The question

The forcing Δ^L = −ε organises δ\*. The wall is dist(δ\*, S) in
the minimax norm. The wall correlates with ε across the partition
zoo. This note does not test that cross-zoo statistic directly: it
fixes (d, partition kind, q) and asks whether the FSM is unusual
relative to same-dimension null subspaces.

The rotation check tests whether the FSM subspace is special
relative to generic same-dimension subspaces. It does not by
itself distinguish "target-driven" from "architecture-driven" in
the sense of Doubt 4a, because a random subspace is not a
different architecture — it is a subspace with no structure at
all. The null is dimension-matched but not cost-matched or
access-matched: it controls for the thinness of S but not for
the binary-digit-reading structure that generated it.

The test is therefore a one-sided falsifier. If the FSM is
atypical, that is informative: orientation matters, and the
next question is what determines it (§6). If the FSM is
typical, the result is weak — high-dimensional random
projections concentrate, so typicality may be generic rather
than meaningful.

---

## 2. The rotation check

### Setup

Fix depth d, partition kind, and FSM parameters (q, layer mode).

**Canonical cell ordering.** All vectors (δ\*, B columns, ε values,
Walsh input) are indexed by cell j = 0, …, 2^d − 1 in lexicographic
bits order: cell j corresponds to `index_to_bits(j, depth)`, MSB
first. The Walsh-Hadamard transform uses this same ordering as the
Boolean cube coordinate.

Compute:

1. δ\* ∈ ℝ^{2^d}: the free intercept field c\* from the per-cell
   LP (`free_per_cell_metrics`).
2. S ⊂ ℝ^{2^d}: the FSM's achievable subspace (image of the
   parameter-to-correction linear map).
3. dim(S) = p = rank of the parameter-to-correction map, detected
   by SVD with relative cutoff 1e-10 against σ\_max.

### Rotation

Generate random subspaces S\_rand of the same dimension p:

    S_rand = Q · ℝ^p

where Q is a random orthonormal basis for a p-dimensional
subspace of ℝ^{2^d}, drawn uniformly from the Grassmannian
(e.g., via QR decomposition of a random matrix).

For each S\_rand, compute the L∞ best approximation:

    wall_rand = min_{s ∈ S_rand} ‖δ* − s‖_∞

via the LP: min t subject to −t ≤ δ\* − Bα ≤ t, where B is the
basis matrix of S\_rand. The LP returns a vertex solution.

If the L∞ minimizer is non-unique, the ideal tie-breaker is the one
minimizing ‖δ\* − Bα‖₂ (the residual L2 norm, not ‖α‖₂). In
practice, the LP minimizer is generically unique for random subspaces,
so the tie-break is moot. The current implementation uses the LP
solution directly; a separate `used_fallback` flag records this.

### Primary statistics

Three statistics, all compared against the same Grassmannian
ensemble:

1. **Wall magnitude.** Where does wall\_FSM sit in the distribution
   of wall\_rand? Report as a quantile or z-score.

2. **ξ\_n(ε, |r|).** Compute Chatterjee's correlation coefficient
   ξ\_n(ε(m\_mid), |r|) for the FSM and for each random subspace,
   where r is the cellwise residual δ\* − s\_∞.

   Where does ξ\_FSM sit in the distribution of ξ\_rand?

3. **Walsh spectral profile.** Compute the Walsh-Hadamard transform
   of the cellwise residual r\_j for the FSM and for each random
   subspace. Report the level-k weight

       W^k[r] = Σ_{|S|=k} r̂(S)²,    k = 0, …, d

   where x is the binary address of a cell,
   r̂(S) = 2^{−d} Σ\_x r(x) χ\_S(x), and
   χ\_S(x) = (−1)^{Σ\_{i∈S} x\_i} on {0,1}^d
   (O'Donnell, Definition 1.19). Compare the FSM's spectral profile
   (W^0, …, W^d) against the ensemble distribution at each level.

   The normalized profile P^k = W^k / Σ\_j W^j is the primary shape
   diagnostic; raw W^k is confounded with wall magnitude and is
   secondary.

   Does the FSM's residual concentrate its energy at different
   interaction orders than a random subspace's residual?

The ensemble provides a baseline that reflects the target's
ε-organisation without requiring an explicit gate or nuisance
conditioning. Every random subspace faces the same δ\*, so whatever
functional dependence the target generically induces between ε
and |r| is already in the ensemble distribution. Each statistic
is informative only as excess over that baseline.

### Why ξ\_n

Chatterjee's ξ\_n(X, Y) is designed for i.i.d. samples and, in that
setting, converges to 1 iff Y is a measurable function of X. Here we
use ξ\_n more modestly: as a threshold-free descriptive statistic for
how strongly the residual magnitude appears to depend on ε across
cells.

The role of ξ\_n in this note is therefore operational, not
asymptotic. Define the score

    T_ξ(S) := ξ_n(ε(m_mid), |r_S|)

for the minimax residual r\_S associated to a subspace S. The test
does not need ξ\_n to estimate a population quantity in the
Chatterjee sense. It only needs T_ξ to be a sensible directional
score for ε-structured residual dependence, so that comparing
T_ξ(S_FSM) to the Grassmannian ensemble measures whether the FSM is
special with respect to that score.

The asymmetry matters. ξ(ε, |r|) asks "does knowing ε determine
the residual magnitude?" in the directional sense relevant to Doubt
4b. ξ(|r|, ε) asks the reverse, which is not the question.

ξ\_n is threshold-free: no near-active set, no τ, no arbitrary
boundary. The entire residual profile is used.

Available as `scipy.stats.chatterjeexi` in the project's sagew
environment. Since ε(m\_mid) can produce tied values,
add seeded uniform jitter of magnitude ~1e-12 × max(ε) to ε before
computing ξ\_n. Generate the jittered ε vector once per configuration
and reuse it for the FSM and every random draw; resampling jitter per
draw would inflate ensemble variance artificially. Record the jitter
seed in every output row.

### Why Walsh-Hadamard [MENEHUNE]

The Walsh basis χ\_S(x) = (−1)^{Σ\_{i∈S} x\_i} on {0,1}^d is the
character basis for the additive group (ℤ/2)^d (O'Donnell, §1.3,
Theorem 1.5). It is the native harmonic analysis for functions
on the Boolean cube, and therefore a natural way to probe the
bit-product structure induced by binary cell addresses.

A correction depending only on bits 0, …, k−1 lives in
span{χ\_S : S ⊆ {0, …, k−1}}. That makes Walsh analysis a natural
language for asking which interaction orders are present among the
address bits. For the full FSM with sharing and bounded width q,
however, the exact relationship between the achievable subspace S
and Walsh modes has not been derived. In particular, the wall is
not yet identified with an L∞ projection onto "excluded Walsh
modes."

This is distinct from the Fourier analysis on the binade circle
([BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§7–8), which
diagonalises the multiplicative/logarithmic geometry of the
mantissa interval. Walsh instead diagonalises the Boolean product
structure on the address cube. These are not the same contrast as
"function side" versus "machine side": the FSM itself is more
faithfully described by a sequential prefix filtration on the
binary refinement tree. In that sense, a Haar/dyadic martingale
decomposition is closer to the FSM's step-by-step revelation of
bits, while Walsh is closer to interaction order on the full cube.
The Fourier, Walsh, and prefix-tree views address different
questions about the same residual. The relationship between them is
open.

The Walsh spectrum of δ\* has not been computed. The level-k
weight W^k[δ\*] = Σ\_{|S|=k} δ̂\*(S)² is a concrete computation
to perform. The decay of |δ̂\*(S)| with |S| (interaction order)
is a natural quantity to compare against what a shallow bounded-
width reader can capture.

Convention: {0,1}^d addressing to match the codebase. The
Walsh-Hadamard transform is computed via the fast Hadamard
transform in O(n log n).

The Walsh spectral profile is richer than ξ\_n in a different
direction: it says not just whether the residual is unusual
relative to the null, but how its energy is distributed across
bit-interaction orders.

---

## 3. Candidate theory of the ensemble [MENEHUNE]

Candidate routes for analyzing the Grassmannian ensemble for

    wall_rand = min_α ‖δ* − Qα‖_∞.

None of these are specialized into a theorem about the wall
functional. They are heuristic guidance, not a proved account
of when the test has power.

### Candidate route: concentration of wall\_rand

One possible route is to show that the wall

    Q ↦ min_α ‖δ* − Qα‖_∞

is a Lipschitz function of the random orthonormal basis Q. For two
bases Q₁, Q₂ with optimal coefficients α₁\*, α₂\*:

    |wall(Q₁) − wall(Q₂)| ≤ ‖Q₁ − Q₂‖_op · max(‖α₁*‖₂, ‖α₂*‖₂).

This requires a justified estimate on ‖α\*‖₂ and the correct
concentration theorem for the Grassmannian model. If achieved,
one expects subgaussian tails around the median:

    P{|wall_rand − M_wall| ≥ t} ≤ 2 exp(−cn t²/L²).

That would give a quantitative notion of how far the FSM must
sit from the center to register as atypical.

### Candidate route: general-norm deviation

The matrix deviation inequality for general norms (Vershynin,
Theorem 9.6.3) extends to any positive-homogeneous subadditive
function f, including the L∞ norm. For a Gaussian matrix A and
any T ⊂ ℝ^n:

    E sup_{x∈T} |f(Ax) − E f(Ax)| ≤ Cb · γ(T)

where γ(T) is the Gaussian complexity and f(x) ≤ b‖x‖₂.

Since the wall is an L∞ quantity, this is the right class of
tool. The exact set T and reduction that would place wall\_rand
inside this theorem's hypotheses remain to be identified.

### Candidate route: Gordon comparison

The wall is a min-max quantity, so Gordon's inequality is a natural
comparison tool to investigate:

    E inf_u sup_t X_{ut} ≤ E inf_u sup_t Y_{ut}

The relevant Gaussian processes and increment bounds remain to
be set up explicitly.

### Candidate route: width-based heuristics

The M\* bound (Vershynin, Theorem 9.3.1) gives

    E diam(T ∩ E) ≤ CK² w(T) / √m

where T is a bounded set, E = ker A is a random subspace of
codimension m, and w(T) is the Gaussian width. This suggests that
width-like quantities may matter for how random subspaces intersect a
constraint set related to the wall problem.

The escape theorem (Vershynin, Theorem 9.3.4) gives the
threshold: if m ≥ CK⁴ w(T)², the random subspace misses T
entirely with high probability. This does not imply that a random
subspace of dimension p contains a fixed nonzero vector δ\*; for
p < n, that event has probability zero. So these theorems should be
read only as heuristic motivation for trying width-based descriptions
of the wall problem.

### Candidate route: effective dimension

For random projections of a set diameter, the effective dimension
d(T) ≍ w(T)²/diam(T)² (Vershynin, Definition 7.5.12) marks a phase
transition. It is tempting to ask whether an analogous threshold
governs the wall statistic here, but that has not been derived.

The effective dimension of the relevant constrained set should
therefore be treated, at most, as a possible guide to simulation
design. The note should not currently claim that p below some width-
based threshold makes the magnitude test provably powerless, nor that
ξ\_n is then the only remaining discriminator.

### Source references

- Vershynin §9.3: `sources/vershynin/snip1_M_star_bound.pdf`
- Vershynin §7.2: `sources/vershynin/snip2_gordon_inequality.pdf`
- Vershynin §9.6: `sources/vershynin/snip3_matrix_deviation_general_norms.pdf`
- Background: `sources/vershynin/snip4_gaussian_width.pdf`,
  `snip5_concentration_sphere.pdf`, `snip6_random_projections.pdf`

---

## 4. What the outcomes mean [MENEHUNE]

The experiment reports quantiles and z-scores, not automatic
"typical/atypical" labels. The outcome cells below are interpretive
guidance for a human reader.

With three statistics, the outcome space is richer than a 2×2.
The most informative cases:

### All typical

Wall magnitude, ξ\_n, and Walsh profile are all within the bulk
of the Grassmannian ensemble. Against this null, the FSM is not
obviously special. Weak evidence. §3 sketches possible reasons
why typicality may be generic but does not establish a theorem
quantifying how weak this case is.

### Wall or ξ atypical, Walsh typical

The FSM differs from the null in aggregate (wall size or
ε-structured residual dependence) but not in the coarse
distribution of Walsh energy across interaction orders. Under
this null, the specialness appears in magnitude or aggregate
ε-structure more than in the level-by-level Walsh profile.

### Walsh atypical, wall and ξ typical

The FSM's residual occupies different Walsh levels than a random
subspace's residual, even though the aggregate statistics look
the same. Against this null, that is evidence of subspace-
specific spectral structure in the residual. This outcome is
invisible to wall magnitude and ξ\_n alone, and it suggests that
the FSM's binary-tree structure may matter for the wall.

### Multiple atypical

The FSM is atypical on two or three statistics. The next
question is what determines that specialness (§6). The Walsh
profile may indicate which interaction orders to investigate.

---

## 5. Implementation notes

The L∞ best-approximation problem for an arbitrary basis matrix B
is a standard LP with p + 1 variables (p coefficients α plus the
slack t) and 2^{d+1} constraints. The existing LP infrastructure
handles this if the constraint matrix is replaced with B.

Note: the current code may assume the FSM's sparse/tree-structured
matrix. If so, it needs generalisation to accept an arbitrary
dense basis.

For each subspace (FSM and each random draw): solve the LP, compute
the cellwise residual r, compute ξ\_n(ε(m\_mid), |r|) via
`scipy.stats.chatterjeexi`, and compute the Walsh-Hadamard transform
of r via the fast Hadamard transform (O(n log n)). If the L∞
minimizer is non-unique, use the L2 tie-breaker from §2 before
computing ξ\_n and the Walsh transform.

Normalization matters. With the convention from §2,

    r̂(S) = 2^{−d} Σ_x r(x) χ_S(x),

Parseval gives

    Σ_S r̂(S)^2 = 2^{−d} Σ_x r(x)^2.

So the level weights W^k sum to the mean squared residual, not the
total squared residual. An implementation using an unnormalized
Hadamard transform must divide by 2^d before forming W^k.

The ensemble should be large enough to estimate quantiles of both
wall\_rand and ξ\_rand, as well as reference bands for the Walsh
level weights W^k. A few hundred draws should suffice at d = 5–7.

The check should be run across multiple partition kinds. If the
FSM is special for geometric but not for uniform, the answer
depends on partition geometry, which would itself be informative.

---

## 5b. Current results (2026-03-24)

The rotation check has been run. Results are in
[`experiments/rotation/ROTATION.md`](../experiments/rotation/ROTATION.md)
(main sweep + adversary sweep) and
[`experiments/rotation/spectral/`](../experiments/rotation/spectral/)
(Walsh spectral experiment).

**Wall magnitude.** The FSM is atypical (quantile 0.000) in all 84
tested configurations: 72 baseline (depths 5–8 × q 2,3,4 × 3
partition kinds × LI/LD) plus 12 adversary (6 partitions × depths 7,8
× q=3 × LI). No adversary partition eroded the advantage. Stern-Brocot
— the partition with the most intricate sharing structure — gave the
FSM its *largest* relative advantage (wall\_z = −15,062 at d=8).

**ξ\_n.** The FSM is atypical in most configurations at depth ≥ 7,
but the sign depends on partition geometry, q, and depth in a
structured way. The sign is not a single-direction story.

**Walsh shape.** The FSM's normalised Walsh profile is qualitatively
different from random subspaces (JSD quantile = 1.000 in all 57
spectral configurations at d=9). The spectral experiment established
that this shape is *induced* by the shared minimax projection: the
upstream spectra P(ε) and P(δ\*) are concentrated at level 0, while
the residual spectrum P(r\_FSM) is spread across multiple interaction
orders. The shared approximation creates bit-interaction structure
that was not present in the target.

The outcome is "multiple atypical" (§4): wall, ξ\_n, and Walsh
profile are all atypical, in different ways. The next question —
what determines the FSM's spectral fingerprint — is addressed by
the structured null families (§6) and the spectral experiment's
geometry-vs-placement analysis.

---

## 6. Structured null families

The Grassmannian ensemble tests the FSM against subspaces with
no structure. To address Doubt 4a — whether the wall's structure
is shared by other binary-digit-reading architectures — the null
must preserve binary-address features while varying others.

Candidate structured families:

- **Preserving binary-tree nesting.** Subspaces that respect the
  leading-bit split (allocating basis vectors between the left and
  right halves as evenly as possible) but randomise within each
  half. Tests whether the tree structure is what makes S special.
- **Preserving layer structure.** Subspaces with the same
  block-diagonal structure as the FSM's layer-dependent
  parameterisation but with random block entries. Tests whether
  the layer sharing pattern is what matters.
- **Permuting cells within dyadic blocks.** Apply row permutations
  within each fixed dyadic block (for example, within each leading-
  bit half or each depth-k block), scrambling which nearby cells
  share parameters while preserving coarse binary geometry. Tests
  whether the FSM's exact cell-to-parameter assignment is special
  once the coarse binary structure is held fixed.

A Walsh-based design would become possible once the relationship
between the FSM subspace and Walsh modes is worked out: one could
then compare against subspaces matched on coarse Walsh levels but
randomized within those levels. [MENEHUNE] That would test whether
mode selection matters more than orientation within a level.

If the FSM is atypical against the Grassmannian but typical
within a structured family, the structure shared by that family
may be what matters for the wall. [MENEHUNE] That would begin to
address the architecture question without building a second
architecture.

---

## 7. Extensions

### Principal angle decomposition

Compute the principal angle between S and span(δ\*). A small angle
means S is well aligned with the target direction in Euclidean
geometry; a large angle means δ\* lies far from S in that sense.
This is a secondary Euclidean diagnostic, not a characterisation
of the L∞ wall.

### Circle-Fourier decomposition of the residual

The Walsh-Hadamard analysis (§2) diagonalises the additive/Boolean
structure induced by binary addressing. The Fourier analysis on the
binade circle ([BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§7–8)
diagonalises the multiplicative/logarithmic structure native to the
underlying function. The point of comparing them is not just
"machine side" versus "function side": it is to ask how
multiplicative regularity or singularity is transported, under
binary addressing, into additive bit interactions.

A residual that is spectrally simple in the circle-Fourier basis but
diffuse or high-order in Walsh would indicate representation-induced
complexity: a function that is simple in its natural geometry but
complicated in the binary product structure. Conversely, concentration
in low Walsh levels despite nontrivial Fourier content would suggest
that the binary architecture captures a compressed additive shadow of
the multiplicative structure. The relationship between the two
spectral theories remains open.

---

## Reading outward

- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §4: the doubt this test
  addresses.
- [TRAVERSE](TRAVERSE.md) Step 2: the wall's [MENEHUNE] status.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): the forcing on the
  target side.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§7–8: Fourier analysis
  on the binade circle (multiplicative/logarithmic side). Distinct
  from the Walsh analysis here (additive/binary side).
- [COMPLEXITY-REEF](COMPLEXITY-REEF.md): the complexity question
  this test is upstream of.
- O'Donnell, *Analysis of Boolean Functions* (Cambridge, 2014),
  Chapter 1: `sources/Odonnell-CH1.pdf`.
