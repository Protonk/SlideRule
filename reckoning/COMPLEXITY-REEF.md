# Complexity Reef

The computational complexity question for the ruler. What the
computational object is, what cost models are admissible, which
lower-bound tools might apply, and what success would mean.

---

## 1. The computational target

The correction problem produces a family of functions
`f_d : {0,1}^d → ℝ` at each depth d. Candidate targets:

- `δ*_d`: the free-per-cell optimal correction vector.
- `c*_d`: the free intercept field.
- `Δ^L_d`: the sampled displacement field (= −ε at grid points).

These are related by affine transforms. The canonical target for
lower-bound purposes should be chosen so that the norm / loss
function aligns with the minimax objective used by the LP.

## 2. Machine classes

The ruler compares correction architectures under a common cost
measure. Admissible classes:

- **FSMs / ordered branching programs.** Width q, depth d. The
  current experimental platform. One-pass sequential reader of
  binary digits.
- **Shared-coefficient piecewise polynomials.** The De Caro MILP
  architecture. The natural second data point for
  architecture-invariance.
- **Lookup tables.** S = ℝ^{2^d}, no wall. The zero-sharing
  reference.

Each class "reads binary digits" in a different sense. The FSM
reads them sequentially with bounded state. The polynomial
evaluator reads a prefix and applies a shared formula. The lookup
table reads the full address. The ruler must be defined so that
these are commensurable.

A second binary-representation architecture — De Caro is the
natural candidate — producing a (C, gap) curve comparable to the
FSM curve would test architecture-invariance empirically. Alignment
after normalisation supports it. Divergence bounds how much of the
exchange rate is architecture-specific.

## 3. Cost currencies

| Currency | What it measures | What it hides | Cross-architecture? |
|----------|-----------------|---------------|---------------------|
| Width / state count q | FSM capacity | Transition structure | FSM-only |
| Coefficient count | Polynomial capacity | Degree, sharing | Polynomial-only |
| Parameter count | Total free parameters | How they're used | Comparable |
| Circuit depth | Sequential cost | Parallelism | Comparable |
| Description length | Kolmogorov-style | Constants | Comparable |
| Communication bits | Information crossing a cut | Cut placement | Comparable |

The primary currency for d_comp should be comparable across
unlike architectures. Parameter count is the simplest candidate.
Communication bits is the most architecture-free but hardest to
measure.

For d_comp to be a property of the problem rather than the
implementation:

- The infimum over architectures must be well-defined and the FSM
  rate must be informative about it.
- Different architectures must be commensurable under C. Either the
  FSM is near-optimal among low-cost strategies, or C is defined
  abstractly enough to allow comparison.

A weaker but potentially sufficient version: stair *locations*
(which cells bind when) are set by Δ^L and should be
architecture-invariant, even if stair *heights* differ.

## 4. Candidate invariants of the target

Which properties of `f_d` are architecture-free and visible to
lower-bound tools?

- **Binary-tree / prefix structure.** The d-bit address is a path
  in a complete binary tree.
- **Haar-wavelet / tree-spectral mass.** The target's energy
  distribution across scales.
- **Fourier content on the binade circle.** The spectral
  decomposition via the density defect (BINADE-WHITECAPS §§7–8).
- **Alternation / sign structure.** The sign pattern of the
  displacement across cells.
- **Peak clustering near m\*.** Many cells have similar displacement
  near ε's maximum.
- **Description complexity.** The information content of δ\* as a
  function of d.

## 5. Tool routes

### Branching programs

The FSM is an ordered branching program of width q and depth d.
Lower bounds on branching program size for computing certain
functions would, if the correction function falls in the right
class, give a lower bound on the wall that references Δ^L but not
the FSM. The staircase becomes a forced consequence of the
function's structure under any width-bounded sequential reader.

**Main obstruction:** these are hard theorems for specific
functions. The correction function may fall in an intermediate
regime where existing tools give only trivial bounds.

### Communication complexity

The binary representation encodes position in one coordinate
system. The optimal correction lives in another. Any architecture
that reads binary digits and outputs corrections is performing a
coordinate translation. The minimum cost of that translation is
bounded below by something intrinsic to the two coordinate
systems — which is Δ^L again.

**Main obstruction:** the one-way communication model requires a
natural partition of the input bits. The prefix/suffix split is
natural for the FSM but may not be for other architectures.

### Metric entropy / covering numbers

The free correction field δ\* lives in ℝ^{2^d}. The achievable
subspace S has dimension ≪ 2^d. The gap is a covering number
question: how many balls of radius τ are needed to cover δ\*'s
projection onto S?

**Main obstruction:** the covering number depends on the geometry
of S, which is architecture-specific.

### Spectral / mode-count lower bounds

If absorption proceeds by frequency band (POINCARE-CURRENTS §6),
the number of resolved modes is an architecture-free count. A
lower bound on modes needed to achieve tolerance τ would give a
spectral version of d_comp.

**Main obstruction:** the frequency-band absorption ordering is a
prediction, not a theorem.

### Approximation-theoretic widths

Kolmogorov n-widths or nonlinear widths of the target field in
the minimax norm. These measure the best n-dimensional
approximation to δ\* regardless of the subspace chosen.

**Main obstruction:** n-widths are architecture-free but may not
match the structured subspaces that real architectures produce.

## 6. Minimal theorems worth having

The weakest nontrivial results that would advance the project:

- Width-q machines cannot resolve more than k(q) ordered binding
  transitions.
- Any architecture in a specified class must pay at least one unit
  of cost per absorbed frequency band.
- Stair locations are determined by a target invariant even when
  stair heights are not.
- The n-width of δ\* in the minimax norm scales as a known function
  of n, giving a universal lower envelope for d_comp.

## 7. Falsifiers and failure modes

- The lower-bound tools only see smoothness and give trivial bounds.
- The target field is too structured for generic hardness methods.
- The chosen cost currency is incomparable across architectures.
- A counterexample architecture breaks any proposed invariant.
- The covering number / n-width depends on the norm in a way that
  makes the bound vacuous for the minimax objective.

---

## Reading outward

- [TRAVERSE](TRAVERSE.md): where the complexity question enters
  (Steps 5–6).
- [COVERING-GAME](COVERING-GAME.md): the combinatorial test of
  architecture-invariance.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): the displacement field
  and spectral structure.
- [BINADE-WHITECAPS](BINADE-WHITECAPS.md): the Fourier
  decomposition of the density defect.
- [DISTANT-SHORES](DISTANT-SHORES.md): the destination (d_comp).
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md): doubts about the wall and
  the subspace.
