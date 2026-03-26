# NTBT Plan

Negation audit across `reckoning/`. Find every rhetorical opposition,
force each to earn its keep, and embed the discipline in
[AGENTS.md](AGENTS.md) when done.

---

## Opening lesson

The main danger is not decorative negation. It is a negation that
keeps a defeated candidate alive by making it sound like part of the
answer.

**Then**

> The DEPENDENCE experiment established that the wall depends on
> automaton topology, not just parameter count: inside the mod-`q`
> family, more states can buy a worse wall because the achievable
> subspace changes orientation with `q`. Step 4 therefore measures an
> FSM-specific exchange rate, not a universal one.

**Now**

> The DEPENDENCE experiment showed that parameter count does not
> reliably predict wall magnitude: inside the mod-`q` family, more
> states can buy a worse wall because the achievable subspace changes
> orientation with `q`. What governs the wall is subspace orientation,
> which parameter count does not capture. Step 4 therefore measures an
> FSM-specific exchange rate, not a universal one.

The old sentence could not simply be deleted. Parameter count had to be
named because the experiment ruled it out. But "not just" invited the
reader to keep parameter count inside the final explanation. The repair
was to remove it from the answer-space cleanly. That is the model case
for **re-frame**.

---

## 1. The discipline

A rhetorical opposition is any sentence that defines what something
is by first saying what it is not. Common forms:

- "X, not Y" / "not Y, but X"
- "not just Y" / "not only Y"
- "the question is not whether... it is..."
- "this is not a theorem / not a proof / not a substitute for..."
- "X does not Y" when a positive constraint would serve

Each instance ultimately gets one of four verdicts, but not all of them
should be assigned mechanically. After the first screens, surviving
cases go upstairs with a brief.

### Keeps

The opposition does real work. It draws a genuine contrast that
the reader needs, or it guards against a specific misreading that
would arise from the positive statement alone. The negation adds
information that the surrounding text does not already carry.

### Delete

The positive clause already carries the information. The negation
is throat-clearing ("not every X" before listing the X's),
restating what a neighbor says ("a portrait, not a verdict" before
a sentence that says what the portrait delivers), or an abstract
preamble to a concrete clause that does the work ("the converse is
not a gate: quiet sign refinements would not prove...").

### Rephrase

The constraint is real but can be stated positively. "Does not
conflate dimension with orientation" becomes "separates dimension
from orientation." The positive version is shorter and carries the
same information without the negation's implication that someone
was about to conflate them.

### Re-frame

The opposition is needed — the reader must understand that a
candidate has been eliminated or a framing has changed — but the
current wording misrepresents the finding. The paradigm case is the
opening lesson above: "not just" preserves a candidate the experiment
actually removed. Re-frame fixes the sentence so the eliminated
candidate leaves the arena cleanly.

Re-frame is the rarest verdict and the only one that requires
careful rewriting. The others are mechanical.

---

## 2. The test

For each instance, ask:

1. **Does the negation add information that the surrounding text
   does not already carry?** If no → delete.
2. **Does the negation misrepresent the finding it reports?** Does
   "not just" preserve something the evidence actually eliminated?
   Does "not X, it is Y" imply X was a plausible reading when it
   was not? If yes → re-frame.
3. **If it survives those two screens, brief it to a human.** The
   brief may recommend:
   - **rephrase**: the constraint is real and a positive statement
     would carry it cleanly;
   - **keeps**: the contrast is genuine and the reader needs it;
   - **uncertain**: not delete, and not safe to re-frame without
     human judgment.

Apply in this order. Delete remains the first mechanical screen.
Re-frame comes next because misleading negations are the main danger.
Everything that survives those screens goes to human review with a
brief rather than being auto-sorted.

---

## 3. File sequence

Work through `reckoning/` one file at a time. For each file:

1. Read the file.
2. List every rhetorical opposition with line number, the pattern,
   and a brief: delete, re-frame, recommend rephrase, recommend
   keeps, or uncertain.
3. Present the list to the human for review.
4. Make the approved edits.
5. Move to the next file.

Do not batch files. A conversation turn may cover at most one file.
Any file may take as many turns as needed; one file per turn is a
maximum, not a target.

### Ordering

Start with the most load-bearing documents (the ones most likely
to propagate misleading framing into other files), then work
outward.

1. **TRAVERSE.md** — the roadmap. Every other document reads
   outward from here. Misleading oppositions here set the tone
   for the project.
2. **ABYSSAL-DOUBT.md** — the doubt register. Heavy use of "the
   wall is not X, it is Y" framing by construction.
3. **POINCARE-CURRENTS.md** — the forcing/displacement theory.
   Likely has "the forcing does not X" claims that need checking.
4. **BINADE-WHITECAPS.md** — coordinate theory. Foundational; may
   be cleaner.
5. **DEPARTURE-POINT.md** — Day's framework. Oldest document;
   may have legacy framing.
6. **CHARYBDIS.md** — the rotation check. Recent; likely cleaner
   but has "the test does not X" precision guards.
7. **AUTOMATON-SARGASSUM.md** — the rejection loop. Recent; has
   "this is not a tournament / not a substitute" framing.
8. **INTERRUPTED-LOG.md** — the adversarial test.
9. **COMPLEXITY-REEF.md** — the complexity question.
10. **ETAK.md** — the horizon. Speculative; may have aspirational
    negations.
11. **NARROW-PASSAGE.md** — the passage toward Step 6.
12. **ROARING-40s.md** — the measure-support-to-contradiction
    chain. Argumentative; likely has oppositions.
13. **HERE-BE-DRAGONS.md** — speculative extensions.
14. **GLOSSARY.md** — definitions. Unlikely to have rhetorical
    oppositions but worth a check.
15. **PARTITIONS.md** — partition classification. Unlikely.
16. **REFERENCES.md** — bibliography. Skip.

---

## 4. Embed the discipline

Do not promote this discipline into [AGENTS.md](AGENTS.md)
automatically. Near the end of the sweep, stop and assess whether the
work just done warrants a permanent rule.

The threshold is experiential, not formal. The question is whether the
sweep produced a felt mathematical relaxation in the prose without
blunting epistemic caution. That assessment has to be made by discussion
with recent experience of the edits, not by abstract rule-design alone.

Add the discipline to [AGENTS.md](AGENTS.md) only if all of the
following are true:

1. It will not obtrude into the mathematics.
2. The stance being proposed would, in the main, describe the work
   output just produced by the sweep.
3. Applying the guidance back to the current document set would not, in
   the main, call for another round of changes.

If those conditions are met, add a short section to
[AGENTS.md](AGENTS.md) that encodes the discipline as a permanent
editing stance. The section should contain:

- The four verdicts (keeps, delete, rephrase, re-frame) with
  one-line definitions.
- The test (the four questions in order).
- The instruction: apply the test to any rhetorical opposition
  written or encountered during editing. New negations must earn
  their keep before they enter the text.

Any such guidance remains subordinate to epistemic marking. Negations
that distinguish theorem from conjecture, proof from heuristic, or
established result from working interpretation are presumptively
load-bearing.

The AGENTS.md entry should be short — a working reference, not a
tutorial. The tutorial is this plan; the reference is what
survives into daily practice.
