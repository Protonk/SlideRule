# Start-to-Depletion Plan

From fan-out scaling to spectral depletion: what must be true
before the depletion order becomes a well-posed question.

Each section is a question whose answer gates what comes after it.

---

## A. What growth regime is the fan-out in?

The layer-0 delta pair serves all 2^d cells. This creates a
systematic positional displacement that later layers can only
partially repair. The wall is dominated by this early-layer
fan-out (WALL decomposition, 2a–2b).

The question is not only whether the displacement range stabilizes.
It is: which growth regime are we in?

- **Bounded.** The range approaches a finite limit. The
  architecture faces a bounded allocation problem, and adding
  states buys progress against a fixed displacement budget.

- **Slow growth.** The range keeps growing, but sublinearly in
  the number of cells. The wall is structural, but not in the
  strongest possible way; depth and budget remain commensurable.

- **Cell-scale growth.** The range grows on the same scale as the
  cell count. The FSM family has a hard structural ceiling: no
  amount of states can keep up with fan-out.

These are qualitatively different regimes. Everything downstream
depends on which one we are in, not only on the two endpoint cases.

**What to measure.** The displacement range (max − min of
c\_shared − c\_free across cells) as a function of depth at
fixed q, and as a function of q at fixed depth. Both LI and
LD. The fan\_out\_scaling sweep from EXCHANGE-RATE-PLAN §6
targets this directly.

**What to look for.** A curve that flattens, one that grows slowly
with depth, or one that tracks the cell-count scale. The depth
range 4–10 may distinguish these coarsely if the effect is clean,
but ambiguous intermediate growth should be treated as a real
result, not as failed measurement.

**What this does not answer.** Whether the stable limit (if it
exists) is the same for different automaton topologies. That
is the subject of B and C.

**Scout preview.** The alternation experiment
([ALTERNATION](../aft/alternation/ALTERNATION.md)) tracks the
*sign* of the displacement (c\_shared − c\_free) across cells
and its refinement across depths. The split sequence encodes how
many parent cells see their children disagree in sign at each
depth transition. This is a low-fidelity proxy for the
displacement *range* question asked here: if the sign pattern
keeps producing new structure at deep depths, the range is
unlikely to have settled either. But the converse is not a gate:
quiet sign refinements would not prove range stabilization. The
extended uniform split
sequence (1.0244003115, computed to d = 13) shows bursts of new
sign changes at d = 5–7, quiet at d = 8–9, then new activity at
d = 10+. That non-monotone pattern is an early warning that
stabilization at accessible depths may not be clean. Running the
split sequence to higher depth in parallel with the fan-out
scaling sweep is cheap and would show whether the two diagnostics
agree.

---

## B. What is the right cost axis?

DEPENDENCE showed that parameter count is not a valid cost
currency: mod-7 at d = 8 beats mod-9 and mod-11 despite fewer
parameters, because the subspace S\_q changes orientation with q.

Before any one-dimensional "matched cost" comparison (especially
Sargassum battery item 1), we need a denominator that does not
conflate dimension with orientation.

**Candidates:**

1. **Effective dimension of S.** The rank of the parameter-to-
   correction map (already computed in Charybdis via SVD). This
   controls for subspace thinness but not orientation. It may
   or may not resolve the DEPENDENCE non-monotonicity.

2. **Projection efficiency.** ‖proj\_S(δ\*)‖ / ‖δ\*‖ in some
   norm — how much of the target the subspace captures. This
   is an output, not an input, so using it as a cost axis risks
   circularity. But if it correlates with a structural feature
   of the automaton (such as graph diameter or mixing time), the
   structural feature could serve as the axis instead.

3. **A spectral measure.** Number of Walsh levels that S can
   address, or the total Walsh weight of S's basis vectors at
   levels ≤ k. This would be natural for the depletion
   question but requires the Walsh theory that is currently
   open (CHARYBDIS §2, MENEHUNE).

**Cross-architecture check.** The leading downstream candidate
for a second architecture is a De Caro-style piecewise-polynomial
corrector (see note at end of this section). All three candidates
above are well-defined for it: De Caro's achievable corrections
form a linear subspace of R^{2^d} of dimension (degree + 1) × T,
where T is the segment count. Effective dimension, Walsh spectral
weight of the basis vectors, and projection efficiency all
transfer without modification. Any cost axis chosen here should
remain valid for that comparison; axes that depend on the mod-q
transition structure (path algebra, graph diameter of the
state-transition graph) would not transfer and should be avoided
unless they correlate with a subspace-level quantity that does.

**The test.** Compute the candidate cost measure for the mod-q
family across the DEPENDENCE grid (q ∈ {5, 7, 9, 11}, d = 6–8).
Does the DEPENDENCE non-monotonicity disappear when wall is
plotted against the new cost axis instead of parameter count?

If no candidate resolves the non-monotonicity, that does not stop
the whole battery. It means the cost-currency problem is genuinely
hard and Step C.1 cannot honestly be summarized by a single scalar
axis. That would itself be informative: it would mean the wall
depends on structural features of the automaton that are not
captured by any single number. In that regime, C.2–C.4 still go
through, and C.1 becomes a multi-axis portrait or a rejection
signal.

---

## C. The mod-q spending portrait

With the cost characterization from B, map how the incumbent mod-q
family spends structure across (q, d, layer mode).

This is the Sargassum battery (§5, items 1–4) applied to the
baseline family. The questions, in order of load-bearing weight:

1. **Gap frontier at matched cost.** If B yields a usable scalar
   axis, plot wall against it for the full (q, d) grid. Is the
   frontier a curve (a coherent exchange rate) or a cloud
   (architecture noise)? If B does not yield a scalar, treat this
   as a multi-axis frontier question instead.

2. **Fan-out fraction.** What share of the wall is layer-0
   fan-out, and how does that share change along the cost
   axis? If constant, fan-out is the whole story. If it
   drops, higher-layer corrections buy real improvement.

3. **Binding-cell migration.** Which cells bind the minimax,
   and do they migrate toward the ε peak as cost increases?
   The absorption staircase gives point measurements; the
   portrait systematizes them.

4. **Ordering stability.** Is the binding-cell order (which
   cells are absorbed first as q grows) the same at d = 6 as
   at d = 8? DEPENDENCE shows wall magnitude is not monotone
   in q at high depth; the question is whether the
   qualitative ordering survives.

The output is a portrait, not a verdict. The portrait tells us
what the mod-q FSM's managed exchange rate looks like: which
features are stable across the grid and which are idiosyncratic.

If the portrait is incoherent — no stable frontier, no stable
ordering, fan-out fraction jumping erratically — then the mod-q
family does not tell a stable Step-4 story and the Sargassum
should reject it. That would be a real finding, not a failure of
the plan.

**Scout preview.** The alternation experiment's zoo-wide split
sequence table ([ALTERNATION](../aft/alternation/ALTERNATION.md),
"Key findings") is a nearly adjacent view of ordering stability.
It records the displacement sign pattern across all 22 partition
kinds. The dominant pattern under LD is sandwich-shaped
\[−a +b −c\]: a negative block at each boundary, a positive block
in the middle near the ε peak. This sandwich appears across most
partition kinds, suggesting the FSM's spatial compromise pattern
is not a partition accident. The outlier (farey-rank, 29 runs at
d = 7) identifies which partition geometries are hostile to the
sharing pattern. This is not the same as the binding-cell
ordering asked about here, but it is related spatial data that
already exists and can inform expectations about C.4.

---

## C+. Which observables are family-local, and which admit a calibrator?

Not every quantity in A–D asks the same kind of question. Some are
about the incumbent mod-q family's internal mechanism; others can
already be checked against a genuinely different family to see
whether they are specific to mod-q or reflect a broader signal.

**Family-local diagnostics.** These are tied closely to the current
stateful path algebra and should be read first as internal mechanism
probes:

- A's layer-0 fan-out growth regime.
- C.2's fan-out fraction.
- Any LI/LD decomposition stated in layer-sharing language.

**Calibrator-compatible diagnostics.** These are the places where a
second family can already add signal:

- B's cost-axis candidates, provided the quantity is defined for both
  families.
- C.1's frontier coherence.
- C.3's binding-cell migration.
- C.4's ordering stability.
- D's Walsh-side depletion order and its comparison with ε's
  Fourier-side structure.

The point is not to force every diagnostic into the same template.
It is to avoid waiting for a complete theory of the incumbent family
before admitting any external signal.

---

## D. The depletion question becomes well-posed

Given A–C, the spectral depletion question becomes two linked
questions:

> As cost increases along the valid cost axis, which Walsh
> components of the residual does the FSM shed first, and does
> that machine-side depletion track the Fourier structure of ε?

This requires combining:

- The Walsh spectrum of the residual `r = δ\* − proj\_S(δ\*)`,
  already computed in the Charybdis spectral experiment at d = 9.
- The same Walsh computation across the (q, d) grid from C,
  tracking how level-k weights `W^k[r]` change as q grows at
  fixed d.
- The separate circle-Fourier structure of ε on the binade side,
  used only as a comparison target for whatever Walsh-side
  depletion order is observed.

The **depletion order** is the sequence of Walsh levels k in
which W^k\[r\] decreases fastest as cost grows. If that sequence
is stable across depth and layer mode, it is a candidate
family-stable feature of the mod-q family.

### What would make the depletion order interesting

- Stable across (q, d, layer mode) within mod-q. Then it is a
  property of the family, not an accident of individual automata.
- Correlates with the Fourier structure of ε on the binade circle.
  Then the machine-side (Walsh/Boolean) depletion reflects the
  function-side (Fourier/multiplicative) structure — the binary
  reader is absorbing ε in an order dictated by ε itself.
- Survives structured perturbations from CHARYBDIS §6. Then it
  has earned promotion from a family feature to a stronger source of
  cross-family signal.

### What would make it uninteresting

- Depends on q within the family. Then it is a mod-q
  idiosyncrasy, not a feature of sequential correction.
- No correlation with ε's Fourier content. Then the machine
  absorbs in an order that has nothing to do with the function's
  geometry.
- Collapses under structured perturbation. Then the order is
  fragile and unlikely to be representation-intrinsic.

At this point, "spectral depletion" is either a concrete object
with stability properties worth testing further, or it has failed
the coherence check and the Sargassum needs different entrants or
a different diagnostic.

**Scout preview.** The alternation experiment's sandwich
dominance pattern ([ALTERNATION](../aft/alternation/ALTERNATION.md))
is a spatial-domain view of what spectral depletion looks like
from the absorption side. The displacement (what the FSM absorbs)
and the residual (what it misses) are complementary projections
of δ\*. A 3-run sandwich \[−a +b −c\] has very low Walsh
complexity — essentially a step function with two transitions,
concentrated at low interaction orders. The Charybdis spectral
experiment confirmed the complementary picture: the residual
spectrum P(r\_FSM) is spread across high interaction orders while
the target δ\* concentrates at level 0. Together these suggest
the FSM absorbs low-order Walsh content first and leaves
high-order content behind. The split sequence — which tracks the
rate at which new sign boundaries appear at each depth transition —
may encode the rate at which new interaction orders enter the
displacement. If the depletion order from the residual side (D's
primary measurement) matches the absorption order visible in the
split sequence, that is a cross-check worth having rather than a
gate the theory must pass. The alternation data and
infrastructure already exist; computing the Walsh spectrum of the
displacement sign sequence is a small addition.

---

## Early calibrator family: De Caro

De Caro need not wait until every mod-q question is settled. A
memoryless piecewise-polynomial family can provide early signal on
the observables that are already comparable across families, even
while the stateful-only diagnostics remain local to the FSM.

This is not a promise that De Caro and mod-q already belong to one
clean formal class. There may be an intermediate class containing
both, or the right umbrella may be broader than both. The plan does
not need that settled up front. What matters is that De Caro can
already tell us whether some of the patterns seen in mod-q survive
contact with a genuinely different sharing geometry.

### De Caro piecewise-polynomial correctors

The leading candidate is De Caro et al.'s piecewise-polynomial
interpolator (De Caro et al., IEEE TCAS-I 2017; source in
`sources/Minimizing_Coefficients_[...].pdf`). The architecture:

- Divide [0, 1) into T = 2^s equal-length segments.
- The leading s bits of the input address a LUT returning
  per-segment coefficients: (n\_j, m\_j) for piecewise-linear,
  add p\_j for piecewise-quadratic.
- The remaining n − s bits give the within-segment offset for
  polynomial evaluation via multiply-add (MADD).
- Each segment has its own independent coefficients. Sharing is
  contiguous-block: all 2^{d−s} cells within one segment share
  the same polynomial.

**Why it is structurally informative.** De Caro is a *memoryless*
binary reader. The leading bits select parameters once via LUT
lookup; there is no state carried across bits. The FSM is
*stateful*: its path algebra couples corrections across cells
through state transitions. These are genuinely different sharing
geometries producing subspaces of the same R^{2^d} with the same
Walsh decomposition available.

De Caro faces the same binary-to-logarithmic mismatch as the
FSM: equal-length segments are a linear partition, allocating the
same polynomial degree to the ε peak as to the boundary where
ε ≈ 0. A geometric segmentation would fix this, but that is the
circularity from ABYSSAL-DOUBT §1.

**Calibrator note.** De Caro is one-pass and binary-digit-reading, but
memoryless rather than stateful. Whether it already sits inside the
current Sargassum charter depends on how "sequential corrector" is
meant. Under a narrow, stateful reading, it is outside the charter
but still useful as an early calibrator. Under a broad one-pass
reading, it is already admissible as a formal entrant. The other
admission rules (binary input is real, cost is legible, family
structure is explicit, perturbations make sense) are all satisfied
either way. The precise charter boundary can stay open while De Caro
provides signal on the cross-family observables.

**What De Caro can calibrate now.**

- B's cost-axis candidates.
- C.1's frontier coherence.
- C.3's binding-cell migration.
- C.4's ordering stability.
- D's Walsh-side depletion order and its relation to ε's Fourier
  structure.

**What De Caro does not calibrate directly.**

- A's current layer-0 fan-out question.
- C.2's fan-out fraction as stated.
- LI/LD decomposition claims phrased in stateful layer-sharing
  language.

**Suggested order.** First get enough of A–C on mod-q to know what is
family-local and what is calibrator-compatible. Then bring in De Caro
on the compatible slice. D still matters, but De Caro does not need to
wait for a fully resolved depletion theory before it starts providing
signal.

**TODO**

- [ ] Decide whether the Sargassum charter is meant narrowly
      (stateful sequential correctors) or broadly (all one-pass
      binary-digit-reading correctors). Expand the charter only
      if the narrow reading is chosen.
- [ ] Implement the abstract De Caro subspace: real-valued
      piecewise polynomials of degree p on T equal segments of
      [0, 1), evaluated at 2^d cell centers. The hardware
      details (coefficient quantization, PPM truncation, MADD
      architecture) are irrelevant; only the subspace geometry
      matters.
- [ ] Run the calibrator-compatible slice on the De Caro family:
      B, C.1, C.3, C.4, and then D if the Walsh-side object is
      coherent enough to compare.
- [ ] If useful, define a De-Caro-native coarse-sharing diagnostic
      analogous to A/C.2 rather than forcing stateful fan-out
      language onto a memoryless family.
- [ ] Compare patterns. Agreement provides stronger signal that the
      observed structure is not specific to the mod-q path algebra.
      Disagreement sends both families back through the Sargassum for
      further triage.

---

## Reading outward

- [FOULING](FOULING.md): the experiment stub.
- [EXCHANGE-RATE-PLAN](../wall/EXCHANGE-RATE-PLAN.md) §6: fan-out
  scaling pivot (Step A infrastructure).
- [DEPENDENCE](../wall/DEPENDENCE.md): the non-monotonicity that
  motivates Step B.
- [AUTOMATON-SARGASSUM](../../reckoning/AUTOMATON-SARGASSUM.md):
  the battery that Step C instantiates.
- [CHARYBDIS](../../reckoning/CHARYBDIS.md) §§5–6: Walsh spectral
  results and structured nulls (Step D inputs).
- [ABYSSAL-DOUBT](../../reckoning/ABYSSAL-DOUBT.md) §1: the deeper
  doubt about representation-intrinsic vs architecture-intrinsic.
- [ALTERNATION](../aft/alternation/ALTERNATION.md): displacement
  sign patterns and split sequences. Low-fidelity preview of A
  (sign stabilization as proxy for range stabilization), nearly
  adjacent view of C.4 (spatial ordering across the partition
  zoo), and spatial-domain complement of D (absorption-side
  Walsh structure).
- De Caro et al., "Minimizing Coefficients Wordlength for
  Piecewise-Polynomial Hardware Function Evaluation," IEEE
  TCAS-I, vol. 64, no. 5, May 2017:
  `sources/Minimizing_Coefficients_[...].pdf`. Early calibrator
  family candidate.
