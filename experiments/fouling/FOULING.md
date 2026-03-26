# Fouling

>Architecture-managed exchange rate: from fan-out scaling through spectral depletion.

We study what a candidate sequential corrector family looks
like after it has been fouled by the Step-5 questions to understand 
which parts of the incumbent mod-`q` story are stable, which 
are family-local, and where a genuinely different family can 
start providing signal.

The [DEPENDENCE](../wall/DEPENDENCE.md) experiment showed that
parameter count does not reliably predict wall magnitude: inside
the mod-`q` family, more states can buy a worse wall because the
achievable subspace changes orientation with `q`. What governs the
wall is subspace orientation, which parameter count does not capture.
Step 4 therefore measures an FSM-specific exchange rate, not a
universal one. Fouling
asks what survives that finding.

The argument has a vertical chain and a horizontal split. The vertical
chain: identify the fan-out growth regime (§1), find a valid cost axis
now that parameter count has failed (§2), map the mod-`q` spending
portrait against that axis (§3), and arrive at spectral depletion —
whether the FSM sheds Walsh components of the residual in a stable
order that tracks ε's Fourier structure (§5). Each step gates the
next, but failure at any step does not kill the program — it narrows
what can be concluded and may itself be the finding.

The horizontal split: some diagnostics are family-local
(fan-out regime, fan-out fraction, LI/LD decomposition). Others are
calibrator-compatible — they are well-defined for any architecture
that produces a linear subspace of `R^{2^d}` from binary-digit
input, and can already receive signal from a genuinely different
family (§4). De Caro's memoryless piecewise-polynomial architecture
is the leading calibrator candidate, covering the compatible slice
without waiting for the full mod-`q` characterization (§6).

The destination is a depletion order stable enough to test against a
second architecture. If it exists, the project has a candidate
invariant to carry into the
[Interrupted Log](../../reckoning/INTERRUPTED-LOG.md). If it does not,
the [sargassum](../../reckoning/AUTOMATON-SARGASSUM.md) needs different
entrants.

---

## 1. Fan-Out Growth Regimes

The layer-0 delta pair serves all `2^d` cells. This creates a
systematic positional displacement that later layers can only
partially repair. The wall is dominated by this early-layer
fan-out.

The question is which growth regime the displacement range is in:

- **Bounded.** The range approaches a finite limit. The
  architecture faces a bounded allocation problem, and adding
  states buys progress against a fixed displacement budget.
- **Slow growth.** The range keeps growing, but sublinearly in
  the number of cells; depth and budget remain commensurable.
- **Cell-scale growth.** The range grows on the same scale as the
  cell count. The FSM family has a hard structural ceiling: no
  amount of states can keep up with fan-out.

**Scout preview.** The alternation experiment
([ALTERNATION](../aft/alternation/ALTERNATION.md)) tracks the
sign of the displacement `c_shared − c_free` across cells and its
refinement across depths. The split sequence is a low-fidelity proxy
for the displacement-range question: if the sign pattern keeps
producing new structure at deep depths, the range is unlikely to have
settled either. Quiet sign refinements alone would not prove range
stabilization.

## 2. The Cost-Axis Problem

[DEPENDENCE](../wall/DEPENDENCE.md) showed that parameter count is not
a valid cost currency: mod-7 at `d = 8` beats mod-9 and mod-11 despite
fewer parameters, because the subspace `S_q` changes orientation with
`q`.

Before any one-dimensional "matched cost" comparison, we need a
denominator that separates dimension from orientation.

Current candidates:

1. **Effective dimension of `S`.** The rank of the
   parameter-to-correction map.
2. **Projection efficiency.** `||proj_S(δ*)|| / ||δ*||` in some
   norm.
3. **A spectral measure.** Number of Walsh levels that `S` can
   address, or the total Walsh weight of `S`'s basis vectors at
   levels `≤ k`.

## 3. The Mod-q Spending Portrait

The spending portrait maps how the incumbent mod-`q` family spends
structure across `(q, d, layer mode)`.

The portrait has four parts:

1. **Gap frontier at matched cost.** Wall plotted against the cost
   axis for the full `(q, d)` grid. A curve is a coherent exchange
   rate; a cloud is architecture noise.
2. **Fan-out fraction.** What share of the wall is layer-0 fan-out,
   and how does that share change with cost.
3. **Binding-cell migration.** Which cells bind the minimax, and do
   they migrate toward the ε peak as cost increases.
4. **Ordering stability.** Whether the binding-cell order is the
   same at `d = 6` as at `d = 8`.

The portrait tells us what
the mod-`q` FSM's managed exchange rate looks like: which features are
stable across the grid and which are idiosyncratic.

**Scout preview.** The alternation experiment's zoo-wide split
sequence table is a nearly adjacent view of ordering stability —
related spatial data that can inform expectations about binding-cell
ordering.

## 4. Family-Local vs Calibrator-Compatible Observables

**Family-local diagnostics**

- layer-0 fan-out growth regime;
- fan-out fraction;
- LI/LD decomposition phrased in stateful layer-sharing language.

**Calibrator-compatible diagnostics**

- cost-axis candidates;
- frontier coherence;
- binding-cell migration;
- ordering stability;
- Walsh-side depletion order and its comparison with ε's
  Fourier-side structure.

## 5. Spectral Depletion

The spectral depletion question has two linked parts:

> As cost increases, which Walsh components of the residual does the
> FSM shed first, and does that machine-side depletion track the
> Fourier structure of ε?

The measured object is the Walsh spectrum of the residual
`r = δ* − proj_S(δ*)`. The comparison object is the separate
circle-Fourier structure of ε on the binade side.

The **depletion order** is the sequence of Walsh levels `k` in which
`W^k[r]` decreases fastest as cost grows. If that sequence is stable
across depth and layer mode, it is a candidate family-stable feature
of the mod-`q` family.

What would make the depletion order interesting:

- stable across `(q, d, layer mode)` within mod-`q`;
- correlated with the Fourier structure of ε on the binade circle;
- surviving structured perturbations from
  [CHARYBDIS](../../reckoning/CHARYBDIS.md) §6.

What would make it uninteresting:

- depending strongly on `q` within the family;
- showing no correlation with ε's Fourier content;
- collapsing under structured perturbation.

**Scout preview.** Alternation's sandwich-dominance picture is a
spatial-domain complement to the residual-side spectral view. If the
depletion order from the residual side matches the absorption order
visible in the split sequence, that is useful cross-checking signal.

## 6. Early Calibrator Family: De Caro

De Caro et al.'s piecewise-polynomial interpolator (IEEE TCAS-I 2017;
`sources/Minimizing_Coefficients_[...].pdf`) divides `[0, 1)` into
`T = 2^s` equal-length segments. The leading `s` bits of the input
address a LUT returning per-segment coefficients: `(n_j, m_j)` for
piecewise-linear, add `p_j` for piecewise-quadratic. The remaining
bits give the within-segment offset for polynomial evaluation. Each
segment has its own independent coefficients. Sharing is
contiguous-block: all `2^{d−s}` cells within one segment share the
same polynomial. The achievable corrections form a linear subspace of
`R^{2^d}` with dimension `(degree + 1) × T`.

De Caro is a *memoryless* binary reader: the leading bits select
parameters once via LUT lookup, and there is no state carried across
bits. The FSM is *stateful*: its path algebra couples corrections
across cells through state transitions. These are genuinely different
sharing geometries producing subspaces of the same `R^{2^d}` with the
same Walsh decomposition available. De Caro faces the same
binary-to-logarithmic mismatch as the FSM: equal-length segments are
a linear partition, allocating the same polynomial degree to the ε
peak as to the boundary where ε ≈ 0.

Whether De Caro sits inside the current sargassum charter depends on
how "sequential corrector" is meant. Under a narrow, stateful
reading, it is outside the charter but still useful as an early
calibrator. Under a broad one-pass reading, it is already admissible
as a formal entrant. The other admission rules (binary input is real,
cost is legible, family structure is explicit, perturbations make
sense) are satisfied either way.

De Caro does not directly address the family-local diagnostics:
fan-out growth regime, fan-out fraction, and LI/LD decomposition are
all phrased in the FSM's stateful layer-sharing language. A
De-Caro-native coarse-sharing diagnostic may be worth defining if the
calibrator comparison proves informative.

## Reading outward

- [AUTOMATON-SARGASSUM](../../reckoning/AUTOMATON-SARGASSUM.md): the
  rejection loop this experiment feeds.
- [DEPENDENCE](../wall/DEPENDENCE.md): the architecture-dependence
  finding that motivates this work.
- [ABYSSAL-DOUBT](../../reckoning/ABYSSAL-DOUBT.md) §1: the fan-out
  problem.
- [TRAVERSE](../../reckoning/TRAVERSE.md) Steps 4–5: where this sits
  in the roadmap.
