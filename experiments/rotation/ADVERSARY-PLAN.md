# Adversary Plan

Follow-on partition experiments for the Test of Charybdis.

This note now has one job only:

- test whether nastier partition geometries can close the FSM's wall
  advantage or move the `ξ_n` story in a systematic way.

The standalone Walsh program now lives in
[`spectral/SPECTRAL.md`](./spectral/SPECTRAL.md) and
[`spectral/SPECTRAL-PLAN.md`](./spectral/SPECTRAL-PLAN.md).

---

## Job 1: Adversary partitions

The sweep showed wall quantile = 0.000 on all 72 configurations using
geometric, uniform, and harmonic partitions. The FSM always wins. The
question is whether that's a property of the FSM or a property of these
well-behaved partitions.

### Partition selection

These six partitions are not meant to be "the six hardest." They are
chosen to stress different possible failure modes: sharing fragility,
address scrambling, ε-coupling inversion, loss of geometric structure,
and non-dyadic self-similarity.

**1. `farey_rank_x`** — Number-theoretic adversary.

`DAMAGE.md` identifies Farey-rank as one of the partitions with the
highest balance-ratio crossing counts. That is exactly the kind of fine
internal structure that should make sharing expensive. If the FSM's
wall advantage is only robust on smoother sharing economies, Farey-rank
is a natural place for it to fail.

**2. `bitrev_geometric_x`** — Structural scrambler.

Geometric widths scattered by bit-reversal. This directly attacks the
FSM's reliance on binary addressing: the widths are the same as
geometric, but their assignment to cells is scrambled in exactly the
way that should confuse a machine that reads MSB first. If the wall
advantage comes from the FSM's tree structure matching the partition's
spatial structure, bit-reversal should damage that match.

**3. `stern_brocot_x`** — High-complexity number-theoretic.

`DAMAGE.md` also places Stern-Brocot among the highest-crossing
families. It is a second sharing-fragile number-theoretic adversary,
but from a different construction. If Farey-rank and Stern-Brocot move
together while the others do not, the vulnerability is more plausibly
about arithmetic/sharing complexity than about one special family.

**4. `scramble_x` (peak_swap mode)** — ε-coupling inversion.

Width-preserving scramble that inverts the width-ε correlation
(ρ_peak ≈ −0.99 vs geometric's −0.17). Already tested in the
tiling basis identification, where H_value still held at corr 0.85.
The question here is different: does inverting the ε coupling change
the FSM's wall advantage over random subspaces?

**5. `random_x` (seed 42)** — Null partition.

If the FSM's wall advantage persists on a structureless partition,
the advantage is intrinsic to the FSM's subspace orientation, not to
any alignment between partition geometry and binary structure. If the
advantage vanishes, the alignment matters. This is a fixed null
instance, not a random-partition ensemble.

**6. `cantor_x`** — Fractal adversary.

Self-similar gaps at multiple scales. The fractal structure is
incommensurate with the FSM's dyadic refinement. If the FSM's
advantage comes from scale-by-scale matching, the Cantor partition's
triadic gaps should disrupt it.

### Experimental design

- Depths: 7, 8 only. Depth 5–6 are too small for ξ_n.
- q: 3 only. The sweep showed q=3 is where ξ_n and Walsh are most
  structured. Holding q fixed makes the partition comparison clean.
- Layer modes: LI only. LI has the most variation in ξ_n sign and
  more complex alternation patterns. LD is the easier case for the
  FSM (more parameters, less sharing pain).
- n_draws: 300 (same as sweep).

That's 12 configurations (6 partitions × 2 depths).

### What to record

For each configuration, save:

- the usual summary row: `wall_fsm`, `wall_quantile`, `wall_zscore`,
  `xi_fsm`, `xi_quantile`, `xi_zscore`, fallback counts;
- a saturation-resistant wall metric such as
  `wall_fsm / median(wall_rand)` or `wall_fsm - min(wall_rand)`.

### What to look for

- **Wall quantile > 0.** Any configuration where the FSM's wall sits
  within the ensemble distribution, not below it. This would mean
  random subspaces can match the FSM on that partition.
- **Wall z-score magnitude.** Even if quantile stays at 0.000, a
  smaller |z| on adversary partitions (compared to the same-depth
  baseline z from the sweep) would show the partition is eroding the
  FSM's advantage.
- **Wall gap beyond quantile.** Because quantile saturated at 0.000 in
  the baseline sweep, also track a magnitude-style comparison such as
  `wall_fsm / median(wall_rand)` or the gap to the ensemble minimum.
- **ξ_n sign.** At d=8 q=3 LI, the baseline partitions already differ
  sharply. The adversaries should be read against those exact baseline
  rows, not against a single expected sign pattern. If Farey-rank and
  Stern-Brocot move together while bit-reversal and random do not, that
  points to arithmetic/sharing complexity rather than to one geometric
  family.

### Baseline comparison

From the main Charybdis sweep (d=7,8 q=3 LI):

| Kind | d | wall\_z | xi\_z |
|------|---|--------|-------|
| geometric\_x | 7 | −595 | +16 |
| uniform\_x | 7 | −695 | +52 |
| harmonic\_x | 7 | −379 | −33 |
| geometric\_x | 8 | −2149 | −113 |
| uniform\_x | 8 | −2755 | −59 |
| harmonic\_x | 8 | −1433 | −165 |

---

## Results (2026-03-24)

Output: `results/adversary_sweep.csv`.
Script: `adversary_sweep.sage`. 12 configs × 300 draws, 39 seconds.

| Kind | d | wall\_z | xi\_z | wall\_ratio |
|------|---|--------|-------|------------|
| farey\_rank\_x | 7 | −905 | +30 | 0.368 |
| bitrev\_geometric\_x | 7 | −692 | +41 | 0.427 |
| stern\_brocot\_x | 7 | −3527 | +17 | 0.286 |
| scramble\_x | 7 | −779 | +37 | 0.421 |
| random\_x | 7 | −942 | +1 | 0.451 |
| cantor\_x | 7 | −244 | −12 | 0.454 |
| farey\_rank\_x | 8 | −2819 | −44 | 0.404 |
| bitrev\_geometric\_x | 8 | −2739 | −54 | 0.451 |
| stern\_brocot\_x | 8 | −15062 | −87 | 0.319 |
| scramble\_x | 8 | −3210 | −57 | 0.455 |
| random\_x | 8 | −2793 | −59 | 0.446 |
| cantor\_x | 8 | −825 | −47 | 0.475 |

`wall_ratio` = wall\_fsm / median(wall\_rand).

### Reading the results

**Wall: no adversary came close.** All 12 configurations have
wall quantile = 0.000. The FSM wins everywhere, including on the
null partition (`random_x`). The wall advantage is intrinsic to the
FSM's subspace orientation, not to partition-FSM alignment.

Stern-Brocot is the strongest result, not the weakest: wall\_z =
−15062 at d=8, the most extreme z-score in the entire project.
Its wall\_ratio (0.319) means the FSM achieves only 32% of the
median random wall. The partition with the most intricate sharing
structure gives the FSM its largest relative advantage.

Cantor is the weakest adversary (smallest |wall\_z|), but still
massively atypical (z = −825 at d=8).

**ξ\_n: sign flip between d=7 and d=8.** At d=7, most adversaries
have positive ξ\_n z-scores (FSM residual more ε-structured than
random). At d=8, all adversaries flip to strongly negative z-scores
(FSM residual less ε-structured). This matches the baseline pattern:
the d=7→d=8 sign flip is not partition-specific.

The one exception at d=7 is cantor\_x (z = −12), which is already
negative at d=7. Cantor's fractal structure may interact differently
with the FSM's binary refinement.

random\_x at d=7 is nearly typical (z = +0.77), the only
configuration in the entire project where ξ\_n is not clearly
atypical. At d=8 it becomes strongly atypical (z = −59).

**Walsh at d=8, stern\_brocot\_x:** The Walsh profile is
unusual — energy at levels 5 and 7 (P5 = 0.249, P7 = 0.306),
unlike any baseline or other adversary. This may reflect the
Stern-Brocot tree's interaction with the mod-3 automaton.

---

## Summary

| Experiment | Configs | Draws | Purpose |
|---|---|---|---|
| Adversary sweep | 12 | 300 | Wall + ξ\_n on nasty partitions |

Total computation: `12` configurations × `300` draws, `39` seconds.
