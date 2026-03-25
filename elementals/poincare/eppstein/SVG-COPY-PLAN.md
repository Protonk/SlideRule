# SVG Copy Plan: Binary Tiling Dual

## 0. Frame

This effort is not primarily about manufacturing a reusable renderer,
and it is not a proof that some universal test suite works for all
hyperbolic diagrams. The main deliverable is an audited reconstruction
of one specific image:
`exterior/eppstein/binary/Binary-tiling-dual.svg.png`.

We want two outputs:

1. A SageMath/matplotlib rendering that can be judged against the
   reference image.
2. A readable case record of how the reconstruction converged:
   which out-of-band expectations we imposed, which tests were active
   or withheld at each stage, which attempts failed, and which checks
   actually ruled out wrong constructions.

The target knowledge is case-specific:

> For this geometry, on this diagram, these were the checks and
> instructions that bit.

If there is a tradeoff between generality and auditability, prefer
auditability.

---

## 1. Deliverables

### Primary deliverable

An audited reconstruction record consisting of:

- an assumption ledger
- preserved failed attempts
- a short postmortem for each attempt
- a record of which tests were withheld and why
- a record of which checks actually discriminated between plausible
  and implausible constructions

### Secondary deliverable

A revised
`elementals/poincare/E3_binary_tiling_dual.sage`
that renders an image matching the reference closely enough to support
the reconstruction claims.

### Non-goals

- building a generic "diagram factory"
- proving that this workflow transfers cleanly to other tilings
- compressing the work into a single final clean argument and discarding
  the dead ends

---

## 2. Audit Discipline

Every meaningful iteration should leave behind an argument record, not
just an image.

### 2.1 Assumption ledger

Maintain a ledger of out-of-band expectations, instructions, and
constraints. Each entry should include:

- `ID`
- `Type`: fact, derived claim, heuristic instruction, or deliberate
  workflow constraint
- `Statement`
- `Source`: SVG extraction, geometric derivation, visual judgment, or
  operator choice
- `Confidence`
- `Status`: active, revised, rejected, or confirmed
- `Why it matters`

Examples of entries:

- "Cell centers use arithmetic mean in `y_hyp`, not geometric mean."
- "Do not use full-image overlay until topology checks pass."
- "Treat green/blue coloring rule as unsettled until explicitly pinned."

### 2.2 Attempt records

Do not overwrite failed reasoning. Preserve attempts in a dedicated
results area, for example:

- `elementals/poincare/results/E3_binary_tiling_dual_attempts/`

Suggested naming:

- `A01_grid_only`
- `A02_wrong_center_rule`
- `A03_bad_quad_ordering`
- `A04_color_parity_candidate`

Each attempt should preserve, as applicable:

- rendered output
- overlay or crop comparisons
- short notes
- the active assumption set
- the active and withheld tests

### 2.3 Postmortem rule

Every failed attempt gets a short postmortem answering:

- What did this attempt believe?
- Why was that belief plausible?
- What specific check killed it?
- Which later attempts should inherit or avoid its choices?

### 2.4 "Test bite" rule

After each attempt, explicitly record which check actually bit.

Examples:

- "Vertex counts killed the construction before any overlay was needed."
- "Overlay exposed a curvature error that topology checks could not see."
- "Holding back color validation prevented premature tuning."

The point is not just to say whether a test passed. The point is to say
whether the test carried information that changed the search.

---

## 3. Working Geometric Record

These are the current working claims needed to execute the
reconstruction. They belong in the audit trail because they are not all
of the same epistemic kind.

### 3.1 Coordinate transform

Current decoded map from Poincare half-plane coordinates to SVG pixels:

```text
y_SVG = A - B / y_hyp
x_SVG = x_hyp * B + x_offset
```

with:

- `A = 1070.6`
- `B = 647.2`
- SVG `y` increasing downward
- the ideal boundary asymptotic to `y_SVG = 1070.6`

Working level boundaries:

| Boundary | `y_hyp` | `y_SVG` |
|----------|---------|---------|
| top of level -1 | 0.5 | -224.6 |
| 0/1 | 1.0 | 423.4 |
| 1/2 | 2.0 | 747.0 |
| 2/3 | 4.0 | 909.0 |
| 3/4 | 8.0 | 989.9 |
| 4/5 | 16.0 | 1030.4 |
| 5/6 | 32.0 | 1050.6 |

Visible x-range:

- `[-272.3, 1777.6]` in SVG coordinates
- total width `2049.9`, corresponding to two coarse cells

### 3.2 Cell structure

Working visible tiling data:

| Level | Cells | Width (SVG) | Height (SVG) | `y_hyp` range |
|-------|-------|-------------|--------------|---------------|
| 0 | 2 | 1025.0 | 648 | `[1, 2]` |
| 1 | 4 | 512.5 | 324 | `[2, 4]` |
| 2 | 8 | 256.25 | 162 | `[4, 8]` |
| 3 | 16 | 128.1 | 81 | `[8, 16]` |
| 4 | 32 | 64.0 | 40.5 | `[16, 32]` |
| 5 | 64 | 32.0 | 20.2 | `[32, 64]` |

One partial level `-1` cell above the viewport is needed for topmost
dual faces.

### 3.3 Cell-center rule

Current working claim:

- Cell centers use the arithmetic mean of the `y_hyp` boundaries:
  `y_center_hyp = (y_lo + y_hi) / 2`

This is a high-value claim because it changes the geometry materially
and should be treated as an auditable assumption, not a casual detail.

### 3.4 Dual-face types

Working classification:

- Split vertices (valence 3) produce curved triangles.
- Continuing vertices (valence 4) produce curved quadrilaterals.

### 3.5 Geodesic boundaries

Between cell centers `(x1, y1)` and `(x2, y2)` in the half-plane:

- if `x1 = x2`, use a vertical segment
- otherwise use the circle centered at `(cx, 0)` with

```text
cx = ((x1^2 + y1^2) - (x2^2 + y2^2)) / (2(x1 - x2))
r  = sqrt((x1 - cx)^2 + y1^2)
```

Render after computing in hyperbolic coordinates, then map sampled
points to SVG/output coordinates.

### 3.6 Coloring

Current candidate rule:

- yellow for split-vertex triangles
- green/blue for continuing quadrilaterals by depth parity

Status:

- unsettled until checked directly against the reference

Do not quietly "tune until it looks right" without recording what was
tried and what evidence ruled a candidate in or out.

---

## 4. Discriminative Test Ladder

Tests should not be treated as a flat checklist. They should be ordered
by how much structure they constrain and by when they become useful.

### Tier 1: cheap structural checks

Use early. These should kill bad constructions before visual matching.

- level-boundary positions match decoded values
- cell-center placement agrees with chosen center rule
- vertex counts per boundary:
  - boundary 0/1: `1 continuing + 2 split = 3`
  - boundary 1/2: `3 continuing + 4 split = 7`
  - boundary 2/3: `7 continuing + 8 split = 15`
  - boundary 3/4: `15 continuing + 16 split = 31`
  - boundary 4/5: `31 continuing + 32 split = 63`
- adjacency/cardinality of cells around each vertex

### Tier 2: local geometric checks

Use after topology is credible.

- representative geodesic arcs pass through expected endpoints
- local face orientation matches the reference
- sampled polygons close without gaps at shared boundaries
- a known petal or quad crop matches the reference qualitatively

### Tier 3: color and compositing checks

Use after geometry is credible.

- yellow faces correspond to split vertices
- green/blue rule matches selected reference locations
- grid overlay order is correct
- stroke color and thickness read correctly

### Tier 4: global visual checks

Use late. These are valuable, but they are also easy to misuse if they
become the first tool.

- 50% opacity overlay against the reference
- crop-by-crop comparison at high-curvature regions
- edge-of-viewport clipping behavior
- overall seamlessness of the tiling

### Withheld-test rule

Each attempt should state which tests are being withheld on purpose.

Examples:

- hold back full-image overlay until vertex counts and representative
  arcs pass
- hold back color checks while geometry is still moving
- hold back pixel-diff style judgments while sampling density is under
  active revision

This matters because later we want to know not just which tests exist,
but whether delaying a test improved convergence.

---

## 5. Attempt Workflow

Each meaningful attempt should be small enough to reason about and rich
enough to falsify.

### Step 1: State the attempt

Before running anything, record:

- attempt ID and short name
- exact hypothesis
- active assumptions
- deliberate workflow constraints
- active tests
- withheld tests
- expected failure mode, if any

### Step 2: Produce an artifact

Generate one focused output:

- grid only
- centers only
- one representative face family
- one color rule candidate
- full composite

Avoid mixing too many moving parts in a single attempt unless the point
of the attempt is the interaction itself.

### Step 3: Compare at the right resolution

Use only the tests chosen for the attempt. If an early structural check
already kills the construction, stop there and record that fact rather
than layering on lower-value comparisons.

### Step 4: Write the verdict

For each attempt, record:

- pass, fail, or inconclusive
- what bit
- what survived
- what changed in the next attempt

---

## 6. Recommended Attempt Sequence

This sequence is deliberately shaped to produce informative failures.

### A. Coordinate and grid baseline

Goal:

- verify the viewport, level boundaries, and rectangular tiling grid

Active tests:

- boundary y-positions
- cell widths
- vertical line alignment

Withhold:

- full overlay
- color checks

Reason:

- if the rectangular scaffold is wrong, later curved geometry is not
  worth interpreting

### B. Center-rule confirmation

Goal:

- test arithmetic-mean centers against plausible alternatives

Active tests:

- center dots at representative cells
- local comparison against visibly centered placements

Withhold:

- full dual-face rendering

Reason:

- this is a high-leverage assumption and should earn its place

### C. Vertex topology

Goal:

- enumerate interior vertices and classify them correctly

Active tests:

- per-boundary vertex counts
- correct valence labels
- neighbor-cell identity checks

Withhold:

- overlay
- color checks

Reason:

- topology should kill bad enumerations quickly

### D. Representative geodesics

Goal:

- validate the curve construction on a few known faces before building
  all faces

Active tests:

- endpoint correctness
- curve shape at selected petals/quads
- shared-boundary consistency

Withhold:

- full-scene aesthetic judgment

### E. Face assembly

Goal:

- assemble all dual faces without gaps or overlaps

Active tests:

- local seam checks
- crop comparisons
- topmost and edge-face handling

Withhold:

- exact color verdict if geometry is still unstable

### F. Color rule

Goal:

- determine the actual green/blue assignment rule from evidence

Active tests:

- sampled location truth table against the reference
- consistency by depth and/or horizontal parity

Do not accept:

- a rule justified only by "it looks close overall"

### G. Final compositing

Goal:

- confirm that the fully assembled image reads like the reference

Active tests:

- overlay
- edge clipping
- stroke order
- overall no-gap visual read

---

## 7. Attempt Record Template

Each attempt note should be short and standardized.

```text
Attempt ID:
Name:

Hypothesis:

Active assumptions:
- ...

Deliberate workflow constraints:
- ...

Active tests:
- ...

Withheld tests:
- ...

Artifacts:
- output image(s)
- comparison crop(s)

Verdict:

What bit:

What survived:

Next change:
```

---

## 8. Success Criteria

Success is not only "the final PNG looks right." Success means the
resulting record lets a later reader answer:

- Which assumptions were injected from outside the image?
- Which of those assumptions survived contact with the diagram?
- Which failed attempts were plausible, and why did they fail?
- Which tests actually constrained the search?
- Which tests were more useful when delayed?
- What should a later reconstruction effort try sooner, later, or not
  at all for this kind of geometry?

The rendering endpoint still matters. The final image should support the
claim that the reconstruction is faithful. But the more durable output
is the scrutinized argument trail that explains how the reconstruction
became credible.

---

## 9. Files

| File | Role |
|------|------|
| `exterior/eppstein/binary/Binary-tiling-dual.svg` | Source SVG |
| `exterior/eppstein/binary/Binary-tiling-dual.svg.png` | Reference PNG |
| `elementals/poincare/E3_binary_tiling_dual.sage` | Renderer under revision |
| `elementals/poincare/results/E3_binary_tiling_dual.png` | Current/final output |
| `elementals/poincare/results/E3_binary_tiling_dual_attempts/` | Preserved attempt artifacts and notes |
| This file | Reconstruction and audit plan |

The existing `E3_binary_tiling_dual.sage` should be revised in place,
but the reasoning history should not be collapsed into a single clean
story. Preserve the path, especially where a withheld test or a failed
assumption turned out to matter.
