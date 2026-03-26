# Automaton Sargassum

A Step-5 rejection loop for candidate sequential corrector families.
The question is not "which machine wins?" but "which one-pass
binary-digit-reading correctors survive enough abuse to deserve the
Interrupted Log?"

The name is literal. This is the weed-belt where candidate
architectures pick up computational cruft. Most should stay here.
Only a family that still tells a coherent Step-4 story after fouling,
perturbation, and comparison should be allowed through.

This is not a theorem note. It is a charter for disciplined
architecture triage.

---

## 1. The role

Step 4 now studies an FSM exchange rate, not a universal one. That
means Step 5 cannot begin by assuming the current mod-`q` family is
the right carrier of the project. Before adversarial partition surgery
can bear load, the candidate sequential corrector family itself must
survive a separate rejection loop.

The sargassum answers the upstream question:

> Which one-pass binary-digit-reading sequential corrector families are
> stable, comparable, and interpretable enough to be worth carrying
> into the Interrupted Log?

The output is not a champion. The output is a short list of families
that have earned the right to be tested against adversarial
partitioning.

## 2. What enters the weed-belt

The unit of competition is a **family**, not a single automaton.
An entrant must specify:

1. a one-pass binary-digit-reading mechanism;
2. a depth/width or depth/cost scaling rule;
3. a comparable cost currency;
4. a clear sharing discipline;
5. a family description rich enough to define nearby perturbations.

Single-point gadgets do not qualify. A one-off machine can always look
good by accident.

The umbrella class here is **sequential corrector families**. FSMs are
the current leading subclass, not the whole class.

## 3. Admission rules

An entrant is admissible only if it satisfies all of the following:

- **Binary input is real.** It must read the given binary digits, not
  a pre-geometrized representation.
- **Sequentiality is honest.** No hidden lookahead, table lookup, or
  offline per-cell advice masquerading as state.
- **Cost is legible.** Parameter count, width, depth, or another
  stated currency must be comparable across nearby variants.
- **Family structure is explicit.** We need to know how the
  architecture changes as cost changes.
- **Perturbations make sense.** It must be possible to vary topology
  without changing the problem being solved.

The purpose of these rules is to stop solver exploits and bookkeeping
tricks from entering the program under the name of "new architecture."

## 4. Canonical entrants

The initial field should be small and interpretable:

- **The current mod-`q` residue family.** The baseline FSM subclass
  and control.
- **Structured perturbations of the FSM.** The families sketched in
  [CHARYBDIS](CHARYBDIS.md) §6: binary-tree-preserving randomizations,
  layer-structure-preserving variants, and dyadic-block permutations.
- **Small arithmetic variants.** For example, alternative residue
  updates or state-coupling rules, provided they remain honest
  one-pass families with comparable cost.
- **Exotic entrants.** A backward-spigot-inspired family or other
  arithmetic mechanism is welcome only if it yields a real bounded
  family, not a one-off curiosity.

The right attitude is conservative: start with a small field and make
entrants justify themselves.

## 5. The battery

Every entrant is sent back through Step 4. The question is whether the
family produces a stable architecture-managed story, not merely
whether it posts a low gap somewhere.

The minimum battery is:

1. **Gap frontier at matched cost.** Does the family improve the
   best-achieved wall at comparable budget, or only at isolated
   points?
2. **Fan-out scaling.** Does the layer-0 displacement range stabilize,
   shrink, or grow with depth?
3. **Topology sensitivity.** How much wall spread appears under
   nearby family variants at matched cost?
4. **Ordering stability.** Are the binding-cell and staircase claims
   coherent across depth and nearby variants?
5. **Spectral depletion profile.** If the family appears to absorb
   low-frequency forcing before high-frequency, is that pattern stable
   or accidental?
6. **Perturbation robustness.** Does a small structural change leave
   the Step-4 story intact, or does the mechanism collapse?

If a family cannot tell a coherent story under this battery, it has no
business advancing.

## 6. Rejection rules

A family is rejected if any of the following dominate its behaviour:

- **One-point success.** It wins only at isolated `(q, d)` values.
- **Bookkeeping arbitrage.** It buys improvement by changing the cost
  accounting rather than the architecture.
- **Narrative instability.** Small perturbations radically change the
  claimed mechanism.
- **Opaque gains.** It improves numbers without yielding an
  interpretable Step-4 picture.
- **Solver parasitism.** Its apparent gains depend on loopholes in the
  optimization setup rather than on a credible sharing discipline.

Rejection is the default. Advancement must be earned.

## 7. Promotion

A family passes the sargassum only if it yields a stable Step-4 story:

- coherent at matched cost;
- robust under nearby perturbations;
- interpretable in terms of fan-out, topology, and ordering;
- worth exposing to an adversarial partition attack.

What gets promoted is not "the best machine." It is "a sequential
corrector family whose behaviour is coherent enough that failure in
the Interrupted Log would be informative."

## 8. What this is not

This is not:

- a winner-take-all tournament;
- an unconstrained automaton synthesizer;
- a beauty contest for exotic constructions;
- a substitute for the Interrupted Log.

A tournament produces a champion. The project needs a filter.

## 9. Operational rule

Keep the field small. Reject aggressively. Record why families fail.
The sargassum is useful only if most things drown there.

When a family survives, rerun Step 4 on that family explicitly before
claiming that anything has been learned. Only then does it earn the
second test in [INTERRUPTED-LOG](INTERRUPTED-LOG.md).

---

## Reading outward

- [TRAVERSE](TRAVERSE.md) Step 5: where this rejection loop enters.
- [INTERRUPTED-LOG](INTERRUPTED-LOG.md): the second Step-5 test after
  a family survives the sargassum.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §1: why the FSM must now be
  managed as an architecture.
- [CHARYBDIS](CHARYBDIS.md) §6: structured null families that should
  be among the first entrants.
