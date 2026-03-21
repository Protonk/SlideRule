# Walls and Keys Plan

Two fronts of work. The **wall** front collects wall-specific diagnostics
from existing keystone data and runs targeted new sweeps. The **keys** front
stands up the foundational claims in the keystone thesis that currently have
no experimental support.

The wall work is downstream of keystone's solver infrastructure. The keys
work is upstream of everything — it argues for the premises that the wall
experiments and DISTANT-SHORES both depend on.

This document is the strategic overview. Moving execution state should live in
an ephemeral keystone-local `PLAN.md` or `KEYS-PLAN.md`, not in
`KEYSTONE.md` itself.

## Execution scaffolding for the keys front

Before implementing the keys scripts, stand up a keystone-local transient
tracker with one row per Keystone section (§1-§4).

Suggested columns:

- claim / section
- support type: proof / experiment / mixed
- owning script or note
- expected figure or artifact
- support criterion
- failure or weakening criterion
- literature-binding task
- eventual doc destination

Use that transient table to manage the transition from "idea in the thesis" to
"claim exhibited in the repo." Do not move the whole table into durable docs.
The docs should get only the distilled, stable version.

### Durable doc landing pattern

As each Keystone section is supported, build a short durable subsection into
`KEYSTONE.md` with the same shape each time:

- `Repo Support`
- `Status`
- `Literature Linkage`

The plan should treat those doc stubs as part of the deliverable, not as a
later cleanup step.

### Literature-binding discipline

Keystone §§1-4 are not just internal claims to prove or exhibit. They also
have antecedents in the literature, and the repo should eventually bind those
antecedents to the specific mechanism being argued here.

For each Keystone section, add an explicit TODO block in the docs once the repo
support exists. The TODO should not merely say "find citations." It should
instruct a later human or agent to connect the external result to this repo's
mechanism.

Suggested TODO shape:

- `External antecedents`
- `TODO: find prior proof or demonstration`
- `TODO: state exact overlap with the claim made here`
- `TODO: explain what this repo's mechanism adds`
- `TODO: note where the literature stops short of the repo's framing`

## Transition status (2026-03-20)

Done:

- [x] Created a transient keystone-local tracker:
  `experiments/keystone/KEYS-PLAN.md`
- [x] Added durable `Repo Support`, `Status`, and `Literature Linkage`
  subsections under `KEYSTONE.md` §§1-4
- [x] Added literature-binding TODO structure to those sections
- [x] Aligned numbering: `KEYSTONE.md` now uses §1 coordinate,
  §2 surrogate, §3 representation, §4 compatibility — matching this plan

Still pending:

- [ ] `coordinate_uniqueness.sage`
- [ ] `surrogacy_test.sage`
- [ ] `float_formats.sage`
- [ ] `compatibility_matrix.sage`
- [ ] wall-local scripts: `join_layer_modes.sage`, `worst_cell_map.sage`,
  `wall_excess_ribbons.sage`
- [ ] run artifacts and first-pass interpretation for all of the above
- [ ] literature search and binding pass for §§1-4

---

## Part I: Keys — foundational claims

The keystone thesis (KEYSTONE.md §§1-4) makes four claims. K1-K3 test the
*consequences* of these claims. But the claims themselves have no
experimental support in the repo. Each needs at least one script that
exhibits, not merely asserts, the claim.

### §1. Coordinates

**Claim:** The logarithm is the unique coordinate on R_{>0} that turns
scaling into translation. Up to affine equivalence, u(lambda * x) =
u(x) + c(lambda) forces u = A log x + B.

**What's missing:** No demonstration. The functional-equation argument is
stated but never shown. No visualization of scaling becoming translation
in log coordinates, no comparison of what the approximation problem looks
like in log vs linear vs other coordinates.

**Proposed experiment:** `experiments/keystone/coordinate_uniqueness.sage`

- Take a family of power-law targets x^(p/q) for several exponents.
- In linear coordinates, show the error landscape is position-dependent
  (cells near x=1 are harder than cells near x=2).
- In log coordinates, show the error landscape is translation-invariant
  (all cells at the same log-width have the same difficulty).
- Visualize: side-by-side per-cell peak error in linear vs log, showing
  the flat line that only appears in log.

This is DISTANT-SHORES Step 2's foundation: the geometric grid is the
zero-cost baseline *because* log is the coordinate where all cells are
equally hard.

Doc follow-through: done. `KEYSTONE.md` §1 has `Repo Support`, `Status`,
and `Literature Linkage` stubs with literature-binding TODOs.

### §2. Surrogacy

**Claim:** The approximation-theoretic utility of the affine pseudo-log is
explained by scale equivariance — not merely its computational convenience.

**What's missing:** The FISR connection is acknowledged as "well-known and
does not require this thesis." The stronger claim — that the pseudo-log's
value as an *approximation tool* (not just a fast bit trick) comes from
scale equivariance — is the distinctive contribution of the keystone thesis,
and it has no experiment behind it.

**Proposed experiment:** `experiments/keystone/surrogacy_test.sage`

- Construct several candidate surrogates for log2 on [1, 2):
  - L(x) = x - 1 (the affine pseudo-log)
  - A Taylor surrogate: first-order expansion of log2 around x = 1.5
  - A Chebyshev minimax linear fit to log2 on [1, 2)
  - A "wrong symmetry" surrogate: e.g., linear in 1/x
- For each surrogate, compute the per-cell chord error when used as the
  coarse stage of a Day-style approximation.
- Show that L(x) = x - 1 is not the best pointwise approximation to log2
  (Chebyshev wins on raw error) but it is the one whose error structure
  is *scale-equivariant*: the residual eps(m) has the property that
  geometric cells equalize it.
- The surrogacy claim is: the pseudo-log is preferred not because it
  minimizes error, but because its error is organized by scale symmetry,
  making it correctable by scale-symmetric machinery (the FSM).

Doc follow-through: done. `KEYSTONE.md` §2 has `Repo Support`, `Status`,
and `Literature Linkage` stubs with literature-binding TODOs.

### §3. The representation

**Claim:** Any number format that expresses values in binary scientific
notation — sign, exponent, significand — gets the affine pseudo-log for
free on log2(x). This is not specific to IEEE 754.

**What's missing:** The repo talks about IEEE 754 significands specifically.
The claim is broader: the structure that makes the pseudo-log natural is
"fixed-point significand in a power-of-2 binade," which is shared by IEEE
754, Knuth's MIX floats, historic IBM hex floats (with caveats), posits
(with caveats), and any format where the significand is a linear encoding
within a power-of-2 interval.

The core fact: within any binade [2^k, 2^{k+1}), a number x has a
significand m = x / 2^k in [1, 2). The significand field stores m as a
fixed-point value. Reading that field as a number gives you m, and
m = x / 2^k, so m - 1 = x/2^k - 1, which is the affine pseudo-log of
log2(x) restricted to that binade. This is a structural fact about binary
scientific notation, not a specification detail of any particular standard.

**Proposed experiment:** `experiments/keystone/float_formats.sage`

- Define 3-4 toy float formats with different binade structures:
  - Binary (IEEE-like): binades [2^k, 2^{k+1}), significand linear
  - Hex (IBM-like): binades [16^k, 16^{k+1}), significand linear in
    wider binades
  - A deliberately broken format: binades at powers of 3
- For each format, define its "natural pseudo-log" (the piecewise-linear
  function that the significand field provides for free).
- Show that the binary format's pseudo-log is affine in log2(x) within
  each binade — and that this is what makes it a good surrogate. The hex
  format gets a coarser version (affine in log16, which is proportional
  to log2 but with 4x wider binades). The base-3 format gets a pseudo-log
  affine in log3(x), misaligned with the binary depth structure of the FSM.
- The point: "express a number in binary scientific notation, get the
  pseudo-log of log2(x) for free" is a structural fact about binary
  representation, not an IEEE 754 specification detail.

Doc follow-through: done. `KEYSTONE.md` §3 has `Repo Support`, `Status`,
and `Literature Linkage` stubs with literature-binding TODOs.

### §4. Joint compatibility

**Claim:** The coordinate (§1), the surrogate (§2), and the discretization
(geometric grid) are mutually adapted. Breaking any one layer degrades the
error structure in a predictable way.

**What's missing:** The wall experiments test one piece (geometric vs
uniform discretization). But the three-layer compatibility is never tested
as a unit. You could break the surrogate while keeping the right coordinate
and discretization, or break the coordinate while keeping the surrogate.

**Proposed experiment:** `experiments/keystone/compatibility_matrix.sage`

- Three layers, each with a "right" and "wrong" choice:
  - Coordinate: log (right) vs linear (wrong)
  - Surrogate: x-1 pseudo-log (right) vs Chebyshev fit (wrong)
  - Discretization: geometric (right) vs uniform (wrong)
- That's 2^3 = 8 combinations. For each, compute the per-cell error
  structure and the wall under shared-delta optimization.
- Show that all three "right" choices together produce equalized error and
  a small wall. Flipping any single layer to "wrong" breaks the
  equalization in a characteristic way:
  - Wrong coordinate: error is no longer scale-invariant
  - Wrong surrogate: error is scale-invariant but the residual is not
    correctable by scale-symmetric machinery
  - Wrong discretization: error is correctable in principle but the grid
    fights the correction structure
- This is the joint compatibility test. The prediction: the three layers
  are not independently good — they are good *together* because they share
  the same symmetry. Breaking any one breaks the cooperation.

Doc follow-through: done. `KEYSTONE.md` §4 has `Repo Support`, `Status`,
and `Literature Linkage` stubs with literature-binding TODOs.

---

## Part II: Wall — diagnostics and scaling

The wall front collects wall-specific localization, attribution, and scaling
diagnostics from existing keystone outputs and targeted new sweeps.

### Seed inventory

Existing assets to reuse before launching new sweeps:

- `keystone/results/wall_surface_2026-03-18/` — 200-case seed grid
  (4 kinds x 5 q-values x 5 depths x 2 layer modes, exponent 1/2)
- `keystone/results/partition_2026-03-18/` — broader zoo seed
- H1 scaling anchors: `h1a_gap_vs_q.csv`, `h1b_depth_scaling.csv`,
  `h1c_layer_dependent.csv`
- Alternation sign/run-length tooling in `alternation/`

Current visual coverage (already in keystone):
- Total wall size across (q, depth): `gap_surface.sage`
- Floor / captured / wall decomposition: `wall_decomposition.sage`
- Per-cell optimized error profile: `error_profile.sage`
- Intercept displacement: `intercept_displacement.sage`

### Wall-local code layer

Scripts in `experiments/wall/` that reuse `keystone_runner.sage`:

- `join_layer_modes.sage` — pair LI and LD rows for the same (kind, q,
  depth, exponent); output: `gap_li`, `gap_ld`, `gap_reduction`,
  worst-cell location for both modes.
- `collect_wall_sweep.sage` — wall-local driver adding derived columns:
  `param_to_cell_ratio`, `gap_over_free`, `wall_excess` per cell.

### Proposed wall experiments

**E1. Worst-cell migration.** Does the wall stay pinned or migrate with
(q, depth, layer_mode)? Use existing `worst_cell_index` from percell CSV.
A stable hotspot supports cell-difficulty; a moving hotspot supports
sharing-geometry.

**E2. Per-cell wall budget.** Is the wall broad or concentrated?
`wall_excess_i = cell_worst_err_i - free_cell_worst_i` distinguishes
"every cell hurt a little" from "a few cells dominate."

**E3. Residual LD wall vs q and exponent.** After removing layer sharing,
does the residual wall shrink predictably with larger q? Test at exponents
1/3, 1/2, 2/3. This is an open edge in WALL.md.

**E4. Parameter-to-cell ratio collapse.** Can the wall be organized by
rho = n_params / 2^depth instead of raw (q, depth)? This gives one common
language for LI and LD models and tests the scaling-law idea in WALL.md.

**E5. Alternation-to-wall correlation.** Does the spatial sign structure
(run count, sandwich pattern, transition locations) predict wall size or
concentration?

### Proposed wall visualizations

- `worst_cell_map.sage` — panel grid colored by worst-cell position
- `wall_excess_ribbons.sage` — per-cell free vs optimized error, showing
  the local wall itself
- `gap_collapse.sage` — scatter of gap vs param-to-cell ratio, colored
  by partition kind
- `candidate_phase_barcode.sage` — per-cell strip colored by
  worst-candidate type

---

## Recommended order

**Keys first, then wall.** The keys experiments are cheaper (mostly no
optimizer, just error evaluation) and they establish the premises that the
wall analysis depends on.

1. ~~Create `KEYS-PLAN.md` tracker~~ — done
2. ~~Add `Repo Support` / `Status` / `Literature Linkage` to KEYSTONE.md~~ — done
3. ~~Align numbering: §1 coordinate, §2 surrogate, §3 representation, §4 compatibility~~ — done
4. `coordinate_uniqueness.sage` — exhibit §1
5. `surrogacy_test.sage` — exhibit §2
6. `float_formats.sage` — exhibit §3
7. `compatibility_matrix.sage` — exhibit §4 (this one uses the optimizer)
8. After each keys artifact lands, update `KEYSTONE.md` with artifact path
   and finding.
9. `join_layer_modes.sage` — wall infrastructure
10. `worst_cell_map.sage` — first wall diagnostic
11. `wall_excess_ribbons.sage` — second wall diagnostic
12. E3 sweep (non-1/2 exponents) — first new data
13. `gap_collapse.sage` — test scaling law
14. E5 correlation — tie wall to alternation

## Success condition

The plan has paid off when:

- KEYSTONE.md §§1-4 each have at least one figure showing (not asserting)
  the claim
- each section's `Repo Support` block points to a concrete artifact
- each section's `Literature Linkage` block has at least a first-pass binding
- `experiments/wall/` has its own result stack answering where the wall
  lives, how LI and LD differ locally, whether the residual LD wall scales
  with q, and whether the dominant wall source changes with partition
  geometry or exponent
- DISTANT-SHORES Steps 1-2 can point to exhibited foundations rather than
  stated premises
