# Traverse

The project studies the cost of closing the gap between the affine
pseudo-log and the true logarithm on one binade. The structure of the
gap ε governs the cost of closing it, in a way that appears to be
independent of the correction method.

Seven steps from the lattice to the ruler. Terminology: see
[GLOSSARY](GLOSSARY.md). Doubts: see [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md).

---

## Step 1. The lattice — Done

Day's pseudo-log L(x) = floor(log₂ x) + x·2^{−floor(log₂ x)} − 1
gives a coarse approximation to log₂ for free from any binary
scientific notation format. The quality metric z(x) = x·y² measures
deviation from y = x^{−1/2}; z is periodic in pseudo-log space, its
extrema occur at a finite candidate set, and the optimal intercept c*
follows analytically. See [KEYSTONE](KEYSTONE.md) §§1–3.

The geometric grid at depth d places its boundaries at g_k = 2^{k/2^d}
— refinements of the binade lattice, the points where the residual
ε(m) = log₂(1+m) − m vanishes. Between them, ε is the cost of using L
instead of log₂. This cost is paid by the representation. It requires
no machinery.

ε has three identities under the log₂/mod-1 coordinate system:

1. The approximation error of L as a surrogate for log₂.
2. The displacement −Δ^L between the binary and geometric grids.
3. The accumulated departure from the reciprocal density in
   log-binade coordinates.

These are forced by the coordinate theory, not by any property of the
correction architecture. See [BINADE-WHITECAPS](BINADE-WHITECAPS.md)
§§6–7.

## Step 2. The wall [MENEHUNE]

Replace Day's single intercept with shared corrections. The FSM with
q states processing d bits generates correction vectors in a subspace
S ⊂ ℝ^{2^d} (dim O(q) layer-invariant, dim O(qd) layer-dependent).
The wall is dist(δ*, S) in the minimax norm.

S is architecture-specific. A different correction architecture
produces a different S. A full lookup table gives S = ℝ^{2^d} and
there is no wall. The dimension tells you S is thin; it does not tell
you which directions it spans.

The wall decomposition S_LI ⊂ S_LD ⊂ ℝ^{2^d} describes the FSM's
sharing layers. The dominant source is the leading-bit mismatch:
the first bit splits the domain at its midpoint (additive), while the
logarithm's natural split is the geometric mean (multiplicative).
This mismatch is representation-intrinsic. Whether the *cost* of the
mismatch is also representation-intrinsic is what Steps 5–6 must
establish. See [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §4.

## Step 3. The forcing — Done

Δ^L(m) = m − log₂(1+m) = −ε(m) organises the free-per-cell intercept
field c* across the partition zoo. The forcing is architecture-free —
it depends on the representation, not the corrector. Properties:

- **Closed form.** No dependence on FSM, delta table, or correction
  strategy.
- **Bounded.** Leading-bit residual stabilises by depth 6–7.
- **Partition-independent at first order.** ε(m_mid) predicts the
  template shape at correlation 0.85–0.89 regardless of partition
  geometry.

The shape of the gap governs the cost of closing it. See
[POINCARE-CURRENTS](POINCARE-CURRENTS.md).

## Step 4. The exchange rate [MENEHUNE]

The forcing's shape predicts a staircase in the (C, gap) curve.
Δ^L is zero at domain boundaries, maximal near m* ≈ 0.44, and
concave. A correction architecture absorbs displacement where Δ^L is
small (near boundaries) before where it is large (near the peak).
The binding cell advances in discrete jumps.

Near the ε peak, many cells cluster at similar displacement. These
must be absorbed roughly simultaneously, predicting a wide plateau
followed by a cliff. Stair locations are set by Δ^L; stair heights
by the architecture's absorptive efficiency per parameter.

The Fourier decomposition of the density defect (Ê(n) = δ̂(n)/(j2πn))
gives a spectral interpretation: if absorption proceeds by frequency
band, the stair locations correspond to frequency thresholds rather
than spatial cell clusters. See [BINADE-WHITECAPS](BINADE-WHITECAPS.md)
§§7–8.

## Step 5. The covering game [MENEHUNE]

Can any adversarial combination of partition strategies beat the
ε-organised baseline? If a composite partition — cells drawn from
different families, chosen adversarially — cannot achieve locally
competitive performance without paying more than the ε-organised
cost, then geometric structure controls computational cost.

If the stair locations are set by the forcing regardless of which
partitions contribute cells, they are problem-intrinsic, not
architecture-specific. See [COVERING-GAME](COVERING-GAME.md).

## Step 6. The coordinate change [MENEHUNE]

The formal bridge from geometric to computational language. The FSM
is a branching program of width q and depth d. The correction task —
mapping a d-bit prefix to a near-optimal δ — is a function whose
complexity is controlled by the information content of δ*, which is
controlled by the shape of ε.

A lower bound on branching program size or communication complexity
for this function would make the staircase a forced consequence of
the function's structure under any width-bounded sequential reader
of binary digits. The bound would not care what sits between input
and output.

See [COVERING-GAME](COVERING-GAME.md) for the proof avenues.

## Step 7. The ruler [MENEHUNE]

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

If the crossing succeeds, d_comp is the minimum structural cost to
achieve tolerance τ in departure from L — intrinsic to the gap
between additive and multiplicative coordinates. A computational
ruler of the exponential.

See [DISTANT-SHORES](DISTANT-SHORES.md).

---

## Summary

| Step | Status | Content |
|------|--------|---------|
| 1 | Done | Day's framework; geometric grid; ε triple identity |
| 2 | [MENEHUNE] | Wall = dist(δ*, S); FSM-specific |
| 3 | Done | Forcing Δ^L = −ε organises c*; architecture-free |
| 4 | [MENEHUNE] | (C, gap) staircase; spectral structure |
| 5 | [MENEHUNE] | Covering game: does structure control cost? |
| 6 | [MENEHUNE] | Coordinate change: geometric ↔ computational |
| 7 | [MENEHUNE] | d_comp(τ): the computational ruler |

---

## Reading outward

- [KEYSTONE](KEYSTONE.md): scale-symmetry thesis.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): displacement field,
  staircase prediction, spectral structure.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md): coordinate theory,
  spectral structure.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): doubts about the wall,
  the forcing-residual gap, the subspace.
- [DANGEROUS-SHOALS](DANGEROUS-SHOALS.md): open work for
  Steps 4–7.
- [COVERING-GAME](COVERING-GAME.md): proof program for Steps 5–6.
- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): speculative extensions.
- [DISTANT-SHORES](DISTANT-SHORES.md): the destination.
