# DOC Refactor Plan

## Goal

Make the repo legible by separating:

- **named docs** for research concepts and conclusions
- **generic docs** for repo operation, current work, and handoff state

The intended effect is that a tired reader, or a new human, can answer two
different questions without scanning everything:

- "What does this project currently claim or believe?"
- "How do I work in this repo right now?"

## Principle

Use **named nouns** for intellectual containment and **generic roles** for
implementation-facing engagement.

- Named docs should be the canonical place for ideas, hypotheses, obstructions,
  and empirical conclusions.
- Generic docs should be the canonical place for navigation, script usage,
  current plans, and recent work state.

## Proposed Document Roles

### Generic docs

- `README.md`
  - one-screen repo map
  - current headline in a few bullets
  - reading order
  - no long hypothesis argument
  - no sweep tables

- `AGENTS.md`
  - short router: given a task type, which docs to read and update
  - e.g., "when a sweep produces decisive results: update hypothesis status
    in HYPOTHESES.md, add dated entry to SWEEP-REPORTS.md, revise WALL.md
    if the decomposition changes, update REPORT.md with what just happened"
  - written after the named docs exist, since the router depends on them

- `PLAN.md`
  - immediate next work only
  - replace freely
  - not canonical for research claims

- `REPORT.md`
  - last-cycle handoff or latest work summary
  - what changed, what ran, what remains
  - not canonical for scientific status

- `lib/README.md`
  - implementation/module guide

- `experiments/README.md`
  - experiment operator guide
  - scripts, inputs, outputs, runtime, result artifact locations

### Named docs

- `HYPOTHESES.md`
  - active hypotheses and status
  - decisive next test for each

- `WALL.md`
  - what "the wall" means
  - current decomposition of the obstruction
  - what appears structural vs objective-specific

- `SWEEP-REPORTS.md`
  - dated summaries of important sweeps
  - short result narratives plus links to result files

Possible later additions only if they genuinely become distinct:

- `OBJECTIVES.md`
- `PARAMETERIZATIONS.md`

## Containment Rule

Each substantive doc should answer one primary question.

- `README.md`: how do I orient myself here?
- `HYPOTHESES.md`: what are we trying to establish?
- `WALL.md`: what obstruction are we seeing?
- `SWEEP-REPORTS.md`: what have we observed?
- `experiments/README.md`: how do I run and read the experiments?
- `lib/README.md`: how does the implementation fit together?
- `PLAN.md`: what are we doing next?
- `REPORT.md`: what just happened?

If a section does not match the file's question, move it.

## Top-Of-File Convention

Add a compact 3-line contract to each major named doc:

- `Purpose:`
- `Canonical for:`
- `Not for:`

This should be used first on:

- `HYPOTHESES.md`
- `WALL.md`
- `SWEEP-REPORTS.md`

It can later be added to generic docs if useful.

## First-Pass Migration

### Step 0: disperse REPORT.md before it gets overwritten

The current `REPORT.md` contains durable scientific content (the
three-constraint wall decomposition, quantitative attribution tables, H1d
sparsity findings, implications) that will lose its home once REPORT.md is
rewritten as a current-cycle handoff. This content must be placed in its
target named docs *before* any trimming or rewriting happens.

Disperse to `WALL.md`:

- definition of the wall (the "Setup" and "Why the wall exists" sections)
- three-constraint decomposition (layer sharing, automaton coupling, cell
  growth) with quantitative attribution table
- the residual-gap analysis

Disperse to `HYPOTHESES.md`:

- H1a, H1b, H1c, H1d findings and their confirmed/supported status
- the interpretive framework ("big improvement from layer dependence means
  the wall is largely caused by layer sharing")

Disperse to `SWEEP-REPORTS.md`:

- H1b depth-scaling table and box-score finding
- H1a q-scaling table and box-score finding
- H1c comparison table and box-score finding
- H1d sparsity observations
- links to CSV files

After Step 0, the content in REPORT.md should exist in at least one named
doc. REPORT.md itself is then free to be rewritten as a handoff.

### Step 1: create canonical named docs

Create (seeded with content dispersed in Step 0):

- `HYPOTHESES.md`
- `WALL.md`
- `SWEEP-REPORTS.md`

### Step 2: move research-state content out of other generic docs

Move from `README.md`:

- detailed hypothesis statuses
- long empirical interpretation
- contingency-table style research conclusions
- refined H1 sub-hypotheses in full detail

Keep in `README.md`:

- short current-state bullets
- short reading order
- links to canonical named docs

Move from `experiments/README.md`:

- long hypothesis status narrative
- research interpretation of sweeps

Keep in `experiments/README.md`:

- what each script does
- columns
- runtime expectations
- which named doc each script informs

## Proposed Content Destinations

### `HYPOTHESES.md`

Should contain:

- H1 and refined H1a-H1d
- status labels such as `supported`, `falsified`, `open`, `moot`
- decisive next experiment for each

Should not contain:

- script usage
- implementation detail from `lib/`
- long tables

### `WALL.md`

Should contain:

- definition of the wall
- current decomposition into parameter budget, layer sharing, and automaton
  coupling
- what has and has not been isolated empirically

Should not contain:

- run logs
- command snippets

### `SWEEP-REPORTS.md`

**Open design question:** The boundary between SWEEP-REPORTS.md and WALL.md
is blurry for analytical content. The working rule is:

- SWEEP-REPORTS.md owns **description**: what ran, what the numbers were,
  what moved (box-score style).
- WALL.md owns **explanation**: why things moved, the causal model, the
  constraint decomposition.

This distinction (description vs explanation) is tenuous in practice — "the
gap dropped 71%" is description, but "the wall is largely caused by layer
sharing" is explanation, and they come from the same table. This needs
continued attention as the docs mature.

Should contain:

- dated sweep entries
- data tables and direct observations (X went up, Y went down, Z% change)
- links to CSV artifacts and relevant scripts

Should not contain:

- causal models or constraint decompositions (those belong in WALL.md)
- evergreen conceptual definitions
- implementation planning

## Reading Order

Target human reading order after refactor:

1. `README.md`
2. `HYPOTHESES.md`
3. `WALL.md`
4. `SWEEP-REPORTS.md`
5. `experiments/README.md`
6. `lib/README.md`
7. `PLAN.md`
8. `REPORT.md`

## Implementation Order

1. Disperse `REPORT.md` content into target named docs (Step 0).
2. Create `HYPOTHESES.md`, `WALL.md`, and `SWEEP-REPORTS.md` (seeded from
   Step 0 dispersal plus content moved from README and experiments/README).
3. Trim `README.md` to orientation and current-state summary.
4. Trim `experiments/README.md` to operator guidance and references.
5. Rewrite `REPORT.md` as a current-cycle handoff.
6. Write `AGENTS.md` as a short router: given a task type, which docs to
   read and which to update. This step comes after the move because the
   router's value depends on the named docs existing in their final roles.
7. Optionally retire or fold `LAUNCHPAD-PLAN.md` if it no longer serves a live
   purpose.

Note: `PLAN.md` is now treated as a disposable template. It does not contain
research content requiring migration — its current H1a–H1d sequence served as
a work plan and is superseded by the results now recorded in named docs.

## Success Criteria

- A reader can find the current claims without opening `README.md` plus three
  other files to triangulate them.
- A reader can find run instructions without reading research narrative.
- `PLAN.md` and `REPORT.md` can churn freely without destabilizing the repo's
  intellectual map.
