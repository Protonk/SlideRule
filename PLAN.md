# Ripple Plan

## Goal

Create a new home at `experiments/ripple/` for work on normalized asymptotic
behavior: measures, diagnostics, and visualizations that study how partition
families approach their limiting coastline-area behavior as depth increases.

This should keep `experiments/stepstone/` from accumulating another cluster of
one-off analysis scripts while giving us a place to iterate on both the math
and the presentation.

## Why A New Folder

- `stepstone/` already carries the direct geometric/error experiments.
- This new work is about convergence behavior, normalization choices, and
  derived stability measures across depth.
- The likely workflow is iterative: try a measure, inspect the resulting
  picture, adjust the measure, repeat.
- That argues for a dedicated subarea with clean separation between:
  computation,
  reusable measures,
  visualization entry points,
  and generated outputs.

## Proposed Layout

```
experiments/ripple/
├── README.md
├── coastline.sage              shared computation + measures
├── ripple_sparklines.sage      23-panel sparkline grid
├── stability_heatmap.sage      MOVED from stepstone/hazards/
└── results/                    output images + cached series
```

No nested `lib/` — helpers sit alongside the scripts they serve.

## What moves in

### `stability_heatmap.sage` — from `stepstone/hazards/`

The existing stability heatmap computes coastline areas for all partitions
at depths 1-10, normalizes by geometric, and renders a binary
stable/unstable grid. It is a coarse-binary view of the same convergence
question ripple addresses with continuous measures. Housing them together
means they share the same `coastline_area()` implementation and stay
consistent when the math changes.

After the move, `stepstone/hazards/` retains `_slope_deviation.sage`,
`curated.sage`, and their PNGs. The deleted `crossings.sage` and
`crossings.png` are already handled by the FRACTAL-PLAN.

### `coastline.sage` — rewritten, not extracted

Two files currently implement `coastline_area()`:

- `stepstone/hazards/stability_heatmap.sage` (accepts any `kind`)
- `stepstone/integrate_coastline.sage` (hardcodes `uniform_x`)

Both use identical math: `integrate.quad(|1/(m ln 2) - sigma_j|, a, b)`
summed over cells. The function is ~10 lines and not worth ceremonial
extraction. We rewrite it once in `coastline.sage` alongside the measure
definitions, and both `stability_heatmap.sage` and `ripple_sparklines.sage`
load from there.

`coastline.sage` provides:

```sage
def coastline_area(depth, kind):
    """Sum of |continuous_slope - cell_chord_slope| integrated per cell."""

def coastline_series(kinds, depths):
    """Return dict keyed by kind -> list of raw areas across depths."""

def scaled_series(raw, depths):
    """Multiply each area by 2^depth."""

# ── Measure registry ──────────────────────────────────────────────
MEASURES = {
    'log_ratio':     lambda B, d: log(B[d] / B[d-1]),
    'difference':    lambda B, d: B[d] - B[d-1],
    'rel_change':    lambda B, d: abs(B[d] - B[d-1]) / abs(B[d-1]),
    'geo_ratio':     ...,   # needs geo series passed in
    'geo_change':    ...,   # needs geo series passed in
}
```

No cached series exist today. Whether to add CSV caching to `results/`
is a decision for the first iteration — we may find the compute is fast
enough at moderate depths that caching adds complexity for no benefit.

## Core Question

We suspect each partition may approach an asymptotic coastline-volume/area
constant, but possibly with different convergence velocity and different
amounts of oscillation. The first visualization should therefore emphasize:

- whether the normalized quantity appears to settle,
- how quickly it settles,
- whether it approaches monotonically or with sign changes,
- whether some families are notably ragged or wobbly across depth.

## First Math Pass

Start by computing, for every partition and every depth in a chosen range:

- raw coastline area `A_d(kind)`
- scaled area `B_d(kind) = 2^d * A_d(kind)`

Then define the first candidate ripple signal from the scaled quantity:

- `R_d(kind) = log(B_d(kind) / B_{d-1}(kind))`

This preserves sign and compresses scale, so wobble should remain visible even
when absolute magnitudes vary widely.

## Measures To Iterate On

We should expect to iterate on the measure, not just the plot. Candidate
families worth supporting from the start:

- signed log-ratio: `log(B_d / B_{d-1})`
- signed difference: `B_d - B_{d-1}`
- relative change magnitude: `|B_d - B_{d-1}| / |B_{d-1}|`
- geometric-referenced ratio:
  `B_d(kind) / B_d(geometric_x)`
- geometric-referenced change:
  `log((B_d(kind) / B_d(geo)) / (B_{d-1}(kind) / B_{d-1}(geo)))`

We do not yet know which framing is the most revealing. The design should make
it cheap to swap these in and compare outputs.

## Depth Range

Stay at depth 10 (N = 1024) for now. At 23 partitions x depths 1–10 this
is ~47K `integrate.quad` calls — noticeable but tolerable (under 2 minutes).
No caching layer; just recompute each run.

If deeper depths are needed later, a closed-form antiderivative of the
integrand can replace quad entirely. See `CLOSED-FORM-PLAN.md` for the
sketch. That's a math task, not a plumbing task, and doesn't block anything.

## Visualization Direction

First deliverable:

- a linear sparkline strip, one row per partition, consistent horizontal
  depth axis, clearly indicated zero line when the measure is signed.
  Partition selection and ordering are configurable at the top of the
  script — may be the full 23 or a curated subset. Layout loaded from
  `lib/partitions.sage` (PARTITION_ZOO) or `lib/partitions.json`
  directly, not via `zoo_figure.sage`.

Likely follow-ups:

- sorted sparkline strip by wobble/raggedness score
- heatmap version for fast comparison (stability_heatmap is the prototype)
- single-partition deep dives with annotations
- summary ranking plots for "most stable", "most oscillatory", etc.

## Ergonomics

Make this easy to iterate on:

- Centralize all candidate measures in `coastline.sage` rather than burying
  math inside plotting scripts.
- Have one precompute path that emits reusable per-depth series for all
  partitions so later plots do not recompute expensive integrals unnecessarily.
- Keep plotting entry points thin: load precomputed series, choose a measure,
  render.
- Put all tweakable settings near the top of each script:
  depth range, chosen measure, baseline mode, output path.
- The measure registry in `coastline.sage` makes switching between measures
  one-line configuration rather than code surgery.

## Implementation Sequence

1. Create `experiments/ripple/` with `README.md` and `results/`.
2. Write `experiments/ripple/coastline.sage` with `coastline_area()`,
   `coastline_series()`, `scaled_series()`, and the measure registry.
3. `git mv experiments/stepstone/hazards/stability_heatmap.sage
   experiments/ripple/stability_heatmap.sage` — update its load paths and
   output path, replace its local `coastline_area()` with a load of
   `coastline.sage`.
4. Update `stepstone/integrate_coastline.sage` to load `coastline.sage`
   instead of defining its own copy.
5. Build `experiments/ripple/ripple_sparklines.sage` for the sparkline
   strip.
6. Generate an initial output and inspect whether the chosen measure actually
   exposes wobble versus mere scale differences.
7. Iterate on measure choice, baseline choice, and ordering if the first pass
   is visually flat or misleading.

## Open Decisions

- Is `2^d * A_d(kind)` the right primary normalization, or is a
  geometric-referenced quantity more revealing?
- Should the default sparkline show signed change or magnitude-only change?
- What depth range gives enough asymptotic signal without making the render too
  slow?
- Should the 23 panels be kept in canonical zoo order, or reordered by
  stability/wobble once the metric exists?
