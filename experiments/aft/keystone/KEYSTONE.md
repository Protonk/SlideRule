# Keystone

Compares partition kinds under shared-delta optimization. The core question
is whether geometric partitions achieve lower worst-case error than
alternatives under the FSM sharing constraint.

## Thesis

The scale-symmetry thesis and Day's FRGR framework are stated in
[`DEPARTURE-POINT.md`](../../../reckoning/DEPARTURE-POINT.md). This
experiment tests the thesis via partition comparison.

### Exhibits

| Claim | Script | Artifact |
|-------|--------|----------|
| §6 Coordinate uniqueness | `coordinate_uniqueness.sage` | `results/coordinate_uniqueness.png` |
| §7 Surrogate boundary-alignment | `surrogacy_test.sage` | `results/surrogacy_test.png` |
| §8 Representation structure | `float_formats.sage` | `results/float_formats.png` |
| §9 Four-layer compatibility | `compatibility_matrix.sage` | `results/compatibility_matrix.png` |

## Hypotheses

The testable predictions of this thesis are tracked in
[`EXPERIMENTS.md`](../../EXPERIMENTS.md). The primary tests are K1 (partition
performance under sharing), K2 (depth scaling), and K3 (wall decomposition
dependence on partition geometry).

## Caveats on explanatory predictions

Two natural predictions of this thesis are of the form "X is explained by Y":

- The success of FISR-style methods is interpretable as exploitation of a
  representation that already approximates the correct coordinate.

- Failures of naive argument reduction may be explainable as misalignment with
  the coordinate in which the problem is simplest.

Both are plausible readings, but they carry a risk that the other predictions
do not. The K1--K3 hypotheses are falsifiable within the current codebase: you
run the experiment, measure the wall, and the numbers either support the claim
or they don't. The explanatory predictions are retrospective. They reinterpret
known facts under the thesis but do not expose the thesis to new risk.

This is not fatal -- good frameworks do explain known facts -- but it means
these predictions should not be treated as evidence for the thesis on the same
footing as K1--K3. They are consistency checks, not tests.

## Reading outward

- For the thesis (Day's framework + scale-symmetry), read
  [`DEPARTURE-POINT.md`](../../../reckoning/DEPARTURE-POINT.md).
- For the wall decomposition that motivates the K1--K3 tests, read
  [`WALL.md`](../../wall/WALL.md).
- For the current hypothesis status labels, read
  [`EXPERIMENTS.md`](../../EXPERIMENTS.md).
- For the overall science goal, read
  [`TRAVERSE.md`](../../../reckoning/TRAVERSE.md).

---

## Scripts

### Sweeps

| Script | Output | Description |
|--------|--------|-------------|
| `partition_sweep.sage` | `results/<RUN_TAG>/summary.csv`, `percell.csv` | Cartesian product of KINDS x GRID x EXPONENTS x LAYER_MODES through `compute_case` |
| `h1_sweep.sage` | `results/h1_*.csv` | Uniform-only H1 hypothesis baseline: depth scaling, q scaling, layer-dependent comparison, delta-shape statistics |

### Diagnostics

| Script | Description |
|--------|-------------|
| `inspect_case.sage` | Single-case workbench: three-metric computation, delta table, induced pattern family, combinatorial summary, exact-vs-sampled validation |

### Visualizations

| Script | Output | Description |
|--------|--------|-------------|
| `error_profile.sage` | `results/error_profile.png` | Per-cell worst error vs position for one case |
| `wall_decomposition.sage` | `results/wall_decomposition.png` | Stacked bars (floor / captured / wall) across depths and partition kinds |
| `gap_surface.sage` | `results/gap_surface.png` | Heatmap of gap across (q, depth) for multiple kinds and layer modes |
| `intercept_displacement.sage` | `results/intercept_displacement.png` | How far sharing pushes each cell from its per-cell optimum; LI vs LD |

Run any of them with `./sagew experiments/aft/keystone/<script>`.

### Shared helper

`keystone_runner.sage` provides:

- `compute_case(q, depth, p_num, q_den, partition_kind, layer_dependent)` --
  runs one case through the three-metric pipeline (single, opt, free)
- `build_summary_row(case, source_run)`, `build_percell_rows(case, source_run)`
  -- canonical CSV row builders
- `SUMMARY_COLUMNS`, `PERCELL_COLUMNS` -- column definitions

`h1_sweep.sage` reuses `compute_case()` but defines its own 27-column CSV
schema.

---

## Data flow

```
lib/ (paths, day, partitions, policies, optimize)
  +-- keystone_runner.sage (compute_case + CSV builders)
       |-- partition_sweep.sage    --> results/<RUN_TAG>/summary.csv
       |                               results/<RUN_TAG>/percell.csv
       +-- h1_sweep.sage           --> results/h1_*.csv
       +-- inspect_case.sage       --> stdout

results/<RUN_TAG>/percell.csv
  |-- error_profile.sage           --> results/error_profile.png
  |-- intercept_displacement.sage  --> results/intercept_displacement.png
  +-- gap_surface.sage             --> results/gap_surface.png

results/<RUN_TAG>/summary.csv
  +-- wall_decomposition.sage      --> results/wall_decomposition.png
```

## Results layout

Each `partition_sweep` run creates a dated `results/<RUN_TAG>/` directory
with `summary.csv` and `percell.csv`. H1 outputs are flat CSVs in `results/`.

Key run tags:
- `wall_surface_2026-03-18` -- 200-case sweep (4 kinds x 5 q-values x
  5 depths x 2 layer modes), used by alternation and gap_surface
- `partition_2026-03-18` -- broader partition comparison sweep

---

## Key findings

### Geometric wins under sharing

Across all tested (q, depth, exponent) configurations, geometric partitions
achieve the lowest or near-lowest optimized error under the shared-delta
constraint. The wall (gap between optimized and free-per-cell error) is
consistently smaller for geometric than for uniform.

### Wall decomposition

The error budget decomposes into three parts: floor (free-per-cell minimum),
captured (improvement from optimization), and wall (residual cost of sharing).
The wall grows with depth but its fraction of total error stabilizes. The
wall_decomposition visualization shows this across depths 3-8 for three
partition kinds.

### Layer-dependent vs layer-invariant

Layer-dependent parameterization (per-layer deltas) consistently beats
layer-invariant (shared deltas) but the gap is modest. The intercept
displacement plot shows the structural difference: LI has broad spatial
swings, LD has tight oscillation (sandwich structure).
