# Interrupted Log

A Step-5 adversarial test on the partition zoo. The question is
simple: does `ε` survive partition surgery inside the zoo?

The name is literal. The zoo families are different ways of cutting
the log-shaped target so that their projections lay flatter or more
compactly. An interrupted log is what you get when those cuts are
spliced together.

This is not a proof program for architecture-invariance. It is a
stress test. If `ε` survives adversarial recombination of the tested
partition families, Step 5 gains real weight. If it does not, Step 5
should not bear load.

---

## 1. The question

The displacement field `Δ^L = -ε` organises the free intercept field
`c*` across the tested partition families. The zoo-surgery question
is:

> Can a composite partition, formed by gluing cells from different
> zoo families, achieve locally competitive performance everywhere
> without paying more than the `ε`-organised baseline?

The point is not to find a prettier partition. It is to ask whether
the local advantages of different families can be pasted together
cheaply enough to beat the common `ε` profile they all appear to see.

## 2. What a positive answer would give

The strongest useful outcome is narrow:

- `ε` would survive adversarial recombination inside the zoo.
- The zoo families would look less like unrelated heuristics and more
  like different projections of one shared obstruction.
- Step 5 in [TRAVERSE](TRAVERSE.md) would become a real filter:
  later arguments would only need to explain a surgery-stable
  `ε`-organised baseline, not every family idiosyncrasy separately.

This would still be a zoo result, not a theorem about all correction
architectures.

## 3. What it would not give

Even a perfect outcome here would not establish:

- a coordinate-change theorem between geometry and computation;
- a branching-program or communication lower bound;
- architecture-invariance beyond the tested zoo;
- the far-horizon claims in [ETAK](ETAK.md).

Those belong to [COMPLEXITY-REEF](COMPLEXITY-REEF.md).

## 4. What must be defined before testing

This note only becomes meaningful if four quantities are fixed in
advance:

1. what counts as a hybrid partition;
2. what "locally competitive" means numerically;
3. what the surgery cost currency is;
4. what baseline the hybrid is trying to beat.

The third item is the dangerous one. If surgery cost and
within-family fitting cost live in different units, the game proves
nothing. A win obtained with free surgery is not evidence that `ε`
fails; it is evidence that the bookkeeping was rigged.

## 5. Risks

### The zoo may be too small

A hybrid can fail to beat the baseline for reasons that belong to the
tested families rather than to `ε`. The conclusion must therefore be
phrased as "inside the zoo" unless the class of admissible surgeries
is widened in a principled way.

### Surgery may be the wrong currency test

If the chosen cost currency prices reassignment, splitting, and slope
choice inconsistently, the experiment answers a bookkeeping question
instead of a mathematical one.

### A clean loss would be informative

If a hybrid beats the `ε`-organised baseline cleanly, then Step 5 in
its current form is false. That is a useful result: it would show
that the apparent common forcing across the zoo is not stable under
recombination.

## 6. Operational rules

1. Formulate before attempting. Definitions come first: hybrid class,
   cost currency, competitiveness threshold, and baseline.
2. Attack with the best adversary available. The point is to break the
   claim, not to illustrate it.
3. Report the limit of the conclusion honestly. A win here is "inside
   the zoo," not "for all architectures."

---

## Reading outward

- [TRAVERSE](TRAVERSE.md) Step 5: where this stress test enters.
- [COMPLEXITY-REEF](COMPLEXITY-REEF.md): the separate complexity
  question that this note does not solve.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): the displacement field
  the zoo appears to follow.
- [ABYSSAL-DOUBT](ABYSSAL-DOUBT.md) §5: the non-factoring doubt this
  test does not resolve.
