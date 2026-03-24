# Traverse

The project studies the cost of closing the gap between the affine
pseudo-log and the true logarithm on one binade. The structure of the
gap ε governs the cost of closing it, in a way that appears to be
independent of the correction method.

Seven steps from the lattice to the ruler. Terminology: see
[GLOSSARY](GLOSSARY.md). Doubts: see [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md).

---

## Step 1. The lattice — Done

Day defines the pseudo-log

    L(x) = floor(log₂ x) + x·2^{−floor(log₂ x)} − 1

and shows that, for the power-law target `x^{−a/b}`, the coarse stage

    y = L⁻¹((c − aL(x)) / b)

has quality metric `z(x) = x^a y(x)^b`. In the reciprocal-square-root
case `a = 1`, `b = 2`, this is `z = x·y²`. `z` is periodic in
pseudo-log space, its extrema lie in a finite candidate set, and the
optimal intercept `c*` follows analytically. See
[DEPARTURE-POINT](DEPARTURE-POINT.md) §§1–5.

Separately, Matula's base-2 significance space gives the intra-binade
coordinate

    m = x·2^{−j} − 1,    x ∈ [2^j, 2^{j+1}).

On one binade the true logarithmic coordinate is `t = log₂(1+m)`,
while the affine pseudo-log uses `m` itself. The residual

    ε(m) = log₂(1+m) − m

is therefore the exact discrepancy between the logarithmic and linear
intra-binade coordinates. The binade lattice `2^j` are its zeros; the
depth-`d` geometric grid `g_k = 2^{k/2^d}` refines that lattice, and
its interior points generally sample nonzero `ε`. See
[DEPARTURE-POINT](DEPARTURE-POINT.md) §§6–8 and
[BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§4–6.

At this level `ε` has three exact identities:

1. surrogate residual: `ε(m) = ψ(m) − m`;
2. sampled grid displacement: `Δ^L_k = L(g_k) − k/2^d = −ε(k/2^d)`;
3. accumulated representation-native defect: `E(t) = −ε(φ(t))`.

These are coordinate facts, prior to any correction architecture. See
[BINADE-WHITECAPS](BINADE-WHITECAPS.md) §§4–7.

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
ε is zero at domain boundaries, maximal near m* ≈ 0.44, and
concave. A correction architecture absorbs cells where ε is
small (near boundaries) before where it is large (near the peak).
The binding cell advances in discrete jumps.

Near the ε peak, many cells cluster at similar displacement. These
must be absorbed roughly simultaneously, predicting a wide plateau
followed by a cliff. Stair locations are set by ε; stair heights
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

## Reading outward

- [DEPARTURE-POINT](DEPARTURE-POINT.md): Day's framework,
  scale-symmetry thesis, four-layer compatibility.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): displacement field,
  staircase prediction, spectral structure.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md): coordinate theory,
  spectral structure.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): doubts about the wall,
  the forcing-residual gap, the subspace.
- [COVERING-GAME](COVERING-GAME.md): proof program for Step 5.
- [COMPLEXITY-REEF](COMPLEXITY-REEF.md): the complexity question
  for Steps 6–7.
- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): speculative extensions.
- [DISTANT-SHORES](DISTANT-SHORES.md): the destination.
