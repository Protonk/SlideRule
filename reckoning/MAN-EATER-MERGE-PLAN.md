# Man-Eater Merge Plan

Turn `SCYLLA.md` and `scylla-man-eater.md` into one document.

---

## What each document is doing

**SCYLLA** is formal. It constructs the unbounded-accumulator
objection to Dragon 7, traces it through Day's polynomial
correction framework, and shows a wall persists: the minimax
polynomial error ε_n*(ρ) is nonzero for every finite degree n,
and ρ is controlled by ε. The argument is clean but narrow — it
proves a wall for polynomial correctors against z^{-1/b}, which
is a different object from the project's sharing wall dist(δ*, S).

**Man-eater** is interpretive. It argues SCYLLA improves the
project by stripping away a false bottleneck (address resolution)
and exposing the real cost (bounded correction of ε). It
reframes the wall, reconnects to ETAK and ROARING-40s, and
proposes an immediate program. The rhetorical energy is high but
the precision is low — it treats SCYLLA as if it already proved
something about the project's sharing wall when it only proved
something about polynomial degree.

## The gap between them

SCYLLA proves: for any fixed polynomial degree n, the minimax
error ε_n*(ρ(c*)) > 0 on [z_min, z_max]. This is a wall
against polynomial correctors in Day's framework.

The project's wall is: dist(δ*, S) in the L∞ norm, where S is
the achievable subspace of a sharing architecture. This is a wall
against shared-parameter correctors in the minimax-intercept
framework.

These are related — both are forced by ε — but they are not the
same object. SCYLLA's wall is about polynomial degree. The
project's wall is about sharing topology. A merged document must
be honest about this: SCYLLA establishes that a wall exists in
Day's correction pipeline even for an unbounded accumulator, and
that the wall's location is controlled by ε. It does not
establish that the project's sharing wall is controlled by ε in
the same way.

Man-eater elides this gap repeatedly. Every "the wall is..."
statement in man-eater conflates the two walls.

## What to keep

### From SCYLLA

- **§§1-5**: the machine, natural weights, L(x) computation, the
  gap ε, properties of ε. Clean and needed. The merged document
  must establish that L is free.
- **§§6-9**: Day's framework through the minimax polynomial error.
  Keep the structure but thin the exposition — the merged reader
  doesn't need every intermediate formula.
- **§10**: what the unbounded accumulator bought (and didn't buy).
  This is the punchline of the mathematical argument.
- **§12** (partially): "where the wall is" — the observation that
  ρ is controlled by ε is sound. The conflation with the
  project's sharing wall is not.
- **§13** (partially): L as the free part, ε as what remains.

### From man-eater

- **§1**: "what survives the objection" — the core reframing.
  The post-SCYLLA question is about bounded correction of ε,
  not address resolution. Keep this idea; rewrite to be precise
  about which wall is being discussed.
- **§2**: "corrected meaning of the wall" — the insight that the
  wall should be reframed as residual after free L extraction.
  Worth one paragraph, not a section.
- **§3** (partially): the connection to ETAK — that with L free,
  the spectral question about ε becomes the primary question.
  Keep the connection; cut the rhetoric.
- **§5** (partially): "the claim worth defending" has a usable
  core: the project's invariant is the cost of corrective
  structure applied to ε, not the number of states.
- **§7**: the immediate program duplicates FOULING. Cut.

### From man-eater: cut entirely

- **§4** (ROARING-40s connection): too speculative. ROARING-40s'
  three-residual identification is conjectural, and man-eater's
  claim that SCYLLA "makes the first member precise enough to
  compare" overstates what's been established.
- **§6** (the hard consequence): aspirational.
- **§8** (final sentence): rhetorical flourish.
- All "that is a substantial upgrade in sharpness" style
  assertions. The merged document should show, not declare.

## Structure of the merged document

### Title: SCYLLA

Keep the name. One document, one argument.

### Opening

One paragraph: Dragon 7's corona-aliasing argument applies to
finite-configuration machines. An unbounded accumulator evades
it by computing L(x) exactly. This document follows that
objection and shows what wall remains.

### §1. The objection

The positional-weight machine (SCYLLA §§1-3). Establish that
L(x) is free.

### §2. The gap

ε(m) = log₂(1+m) − m. Properties. This is what remains after
L. Architecture-free. (SCYLLA §§4-5, thinned.)

### §3. Day's correction pipeline

The coarse stage through z, ρ, and the minimax polynomial error.
(SCYLLA §§6-9, compressed.) Establish: even with exact L, the
polynomial correction wall ε_n*(ρ) is nonzero for every finite n,
and ρ is controlled by ε.

### §4. What the objection bought

(SCYLLA §10, clean.) Zero error in L, zero error in z, nonzero
error in polynomial correction. The accumulator resolved the
address perfectly. It did not resolve the correction.

### §5. What this means for the project

This is the section that replaces man-eater. One careful
treatment:

- The polynomial correction wall (ε_n*) and the project's
  sharing wall (dist(δ*, S)) are distinct objects. Both are
  forced by ε but through different mechanisms.
- SCYLLA establishes that address resolution is not the
  bottleneck. The bottleneck is bounded correction.
- The project's sharing wall is one instance of bounded
  correction. SCYLLA's polynomial wall is another. They meet
  at ε: both measure the cost of correcting the
  additive-to-multiplicative displacement with finite resources.
- The post-SCYLLA base point for the project: L is free, ε is
  explicit, the question is what bounded corrective structure
  costs against ε.

### §6. Connection to the horizon

Brief. ETAK Link 2 (spectral decay) now sits against the
corrected base point: with L free, the spectral question is
about ε's Fourier content, not about address resolution.
One paragraph, not a section-length argument.

### Status

What is established (§§1-4: clean). What is interpretive (§5:
the connection between the two walls is stated, not proved).
What is aspirational (§6: horizon connection).

### Reading outward

Dragon 7, TRAVERSE, ABYSSAL-DOUBT, ETAK, COMPLEXITY-REEF.

## Execution

1. Write the merged document.
2. Delete `scylla-man-eater.md`.
3. Verify all cross-references in reckoning/ that point to
   SCYLLA still resolve.

## What the merged document must not do

- Claim SCYLLA's polynomial wall IS the project's sharing wall.
- Claim the immediate program is novel (it's in FOULING).
- Use "the wall is not X, it is Y" without earning it per the
  discipline applied in this sweep.
- Assert consequences for ROARING-40s that depend on unproved
  identifications.
