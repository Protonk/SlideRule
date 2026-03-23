# Elementals

Purpose: canonical home for non-data-driven figures that illustrate
steps in the DISTANT-SHORES argument chain.

Reading inward: depends on [`DISTANT-SHORES.md`](../../reckoning/DISTANT-SHORES.md)
for the roadmap, [`TILING.md`](../tiling/TILING.md) for the hyperbolic
framing, and [`KEYSTONE.md`](../keystone/KEYSTONE.md) for the
scale-symmetry thesis.

---

## Role in the program

Every other experiment area is primarily data-first: run a sweep, plot
the output. Elementals is argument-first: identify a claim in the
roadmap, decide what a reader would need to *see* in order to follow
the reasoning, and draw that.

The figures use computed curves (ε, Δ^L, chord slopes) but the
computation is evaluating known closed-form functions or shared library
helpers, not calling the optimizer. This makes them stable across
experiment runs and reusable outside any single experiment area.

The first figures establish a repeatable house style and routing rule so
future non-data-driven visuals can be added by following existing
examples rather than renegotiating scope each time.

## What belongs here

- Optimizer-free mathematical figures whose claim is stable across runs
- Reusable explanatory figures for the DISTANT-SHORES argument chain
- Illustrations that make geometric or algebraic content visible where
  prose compresses it

## What does not belong here

- Sweep summaries and result plots (those belong in their experiment area)
- Figures that require CSVs, `compute_case()`, or run caches
- Purely aesthetic treatments with no mathematical claim

## On-disk conventions

- Subfolder paths are ASCII: `poincare/`, `subspace/`, `staircase/`
- Display names use proper typography in docs and figure text (Poincaré)
- Outputs live in `experiments/elementals/<subfolder>/results/`
- Figure IDs are stable and appear in filenames

## How to add a figure

1. Identify the claim and the exact source passage.
2. Decide whether the figure belongs in `elementals/` or in a data area.
   Route here when it is optimizer-free and reusable. Keep it in the
   source area when it depends on run outputs or is tightly bound to
   one experiment's results layout.
3. Add a registry row (status: planned) before implementation.
4. Implement the script following the figure contract below.
5. Run with `./sagew` and update registry status.
6. Classify any overlapping older didactic script as prototype, legacy,
   or superseded.

## Figure contract

Every elemental script satisfies:

- **Docstring:** states the claim, source passage, mathematical objects
  drawn, and output path.
- **Computation:** loads shared helpers via `helpers/pathing.py`, uses
  closed-form functions, does not reach into optimizer pipelines.
- **Output:** writes to `experiments/elementals/<subfolder>/results/`.
- **Annotation:** if a quantity is scaled, normalized, or used only up to
  shape equivalence, the caption or docstring says so explicitly.
- **Done when:** the script runs from repo root with `./sagew`, the
  output lands in the canonical path, the registry is updated, and any
  overlapping older script has been classified.

---

## Subfolders

### poincare/  (display: Poincaré)

Figures from or about the Poincaré half-plane model.
Source domain: hyperbolic geometry.
Serves: `TILING.md` background (L14-L25), `DISTANT-SHORES.md` Step 2,
and the forcing-function framing of Step 5.

### (future: subspace/)

Projection geometry in R^n.
Source domain: linear algebra / convex geometry.
Serves: `DISTANT-SHORES.md` Steps 3-4 (low-rank subspaces, wall as
projection distance, nested subspace inclusions).

### (future: staircase/)

Discrete absorption and binding-cell ordering.
Source domain: combinatorial optimization / minimax geometry.
Serves: `DISTANT-SHORES.md` Step 5 (staircase prediction, covering game).

---

## Figure registry

| ID | Status | Subfolder | Script | Output | Claim | Source passage | Legacy relation |
|----|--------|-----------|--------|--------|-------|----------------|-----------------|
| E1a | done | poincare | `E1a_halfplane_grid.sage` | `results/E1a_halfplane_grid.png` | Dyadic scaling preserves hyperbolic cell shape | `TILING.md L16-L20` | new canonical |
| E1b | done | poincare | `E1b_two_projections.sage` | `results/E1b_two_projections.png` | Uniform and geometric partitions are two slicings of one tiling | `TILING.md L22-L25` | prototype: `tiling/two_slicings.sage` |
| E2 | done | poincare | `E2_displacement_distance.sage` | `results/E2_displacement_distance.png` | Hyperbolic distance between corresponding heights has the ε shape | `TILING.md L60-L71` | related: `tiling/tiling_trick.sage` |

---

## Legacy / prototype notes

| Script | Classification | Notes |
|--------|---------------|-------|
| `tiling/two_slicings.sage` | prototype | First draft of E1a+E1b combined; too busy, mixes the grid and the projections. Superseded once E1a and E1b land. |
| `tiling/tiling_trick.sage` | legacy composite | Four-panel overview mixing didactic and data-adjacent content. Panels 1-2 overlap E1/E2; panels 3-4 are closer to data-driven. Keep in place for now. |

---
