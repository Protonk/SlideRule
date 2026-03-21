# Keystone

Compares partition kinds under shared-delta optimization. The core question
is whether geometric partitions achieve lower worst-case error than
alternatives under the FSM sharing constraint.

## Thesis

The logarithm is the canonical coordinate for approximation on R_{>0} when the
governing symmetry is scaling; the affine pseudo-log is a coarse affine
surrogate whose approximation-theoretic utility is explained by scale
equivariance; any binary scientific notation format gives you this surrogate
for free on log2(x); and the coordinate, surrogate, and discretization are
jointly adapted so that breaking any one layer degrades the error structure.

### 1. The coordinate

On R_{>0}, scaling x -> lambda * x is the native symmetry. Up to affine change
of variable, the logarithm is the unique coordinate that turns this symmetry
into translation: u(lambda * x) = u(x) + c(lambda). Under mild regularity,
u = A log x + B.

This is the reason equal-log-width cells have equal difficulty: the
approximation problem at one position is a translated copy of the problem at
any other position, so all cells of the same log-width face the same task.

#### Repo Support

Planned artifact: `coordinate_uniqueness.sage`

Target exhibit:

- compare per-cell difficulty in linear coordinates against log coordinates
- show that equal-log-width cells flatten the difficulty profile in a way
  linear cells do not

Transient execution tracking lives in [`KEYS-PLAN.md`](KEYS-PLAN.md).

#### Status

Scaffolded only. This claim is stated in the thesis, but the repo does not
yet contain a dedicated figure or result artifact exhibiting it.

#### Literature Linkage

- TODO: find prior proof or demonstration of the scaling-to-translation
  functional equation
- TODO: state exact overlap with the claim made here
- TODO: explain what this repo's mechanism adds
- TODO: note where the literature stops short of the repo's framing

### 2. The surrogate

The affine pseudo-log L(x) = x - 1 is a coarse surrogate for log2(x) on
[1, 2). Its approximation-theoretic utility is explained by scale equivariance:
L is not the best pointwise fit to log2 (a Chebyshev minimax linear fit wins
on raw error), but it is the surrogate whose residual eps(m) = log2(m) - (m-1)
has scale-equivariant structure. Geometric cells equalize this residual. A
Chebyshev surrogate has lower peak error but its residual is not organized by
scale symmetry, making it less correctable by scale-symmetric machinery.

This is the distinctive claim of the keystone thesis. The FISR connection
("the bit layout approximates log") is well-known and does not require this
framing. The thesis adds: the pseudo-log is preferred not because it minimizes
error, but because its error is correctable by the same symmetry that
organizes the coordinate.

#### Repo Support

Planned artifact: `surrogacy_test.sage`

Target exhibit:

- compare several surrogates for log2 on [1, 2): the pseudo-log, a Taylor
  expansion, a Chebyshev fit, a wrong-symmetry surrogate
- separate raw fit quality from symmetry compatibility
- show that the pseudo-log's residual is the one geometric cells equalize

Transient execution tracking lives in [`KEYS-PLAN.md`](KEYS-PLAN.md).

#### Status

Scaffolded only. No dedicated comparison artifact yet isolates the
approximation-theoretic claim from the more familiar FISR-style reading.

#### Literature Linkage

- TODO: find prior treatments of pseudo-log surrogacy, FISR interpretations,
  or coarse-log approximations
- TODO: state exact overlap with the claim made here
- TODO: explain what this repo's mechanism adds (scale-equivariant
  correctability, not just computational convenience)
- TODO: note where the literature stops short of the repo's framing

### 3. The representation

Any number format that expresses values in binary scientific notation --
sign, exponent, significand -- gets the affine pseudo-log for free on
log2(x). This is not specific to IEEE 754.

Within any binade [2^k, 2^{k+1}), a number x has a significand m = x / 2^k
in [1, 2). The significand field stores m as a fixed-point value. Reading
that field as a number gives you m, and m - 1 is the affine pseudo-log of
log2(x) restricted to that binade.

This is a structural fact about binary scientific notation: IEEE 754,
Knuth's MIX floats, historic IBM hex floats (with wider binades), posits
(with variable-width binades), and any format where the significand is a
linear encoding within a power-of-2 interval. The binary format's pseudo-log
is affine in log2(x) within each binade. A hex format gets a coarser version
(affine in log16, proportional to log2 but with 4x wider binades). A
hypothetical base-3 format would get a pseudo-log affine in log3(x),
misaligned with binary depth structure.

#### Repo Support

Planned artifact: `float_formats.sage`

Target exhibit:

- define 3-4 toy float formats with different binade structures
- for each, construct its natural pseudo-log
- show that binary binades produce a pseudo-log affine in log2, and that this
  is what makes it a good surrogate; contrast with other bases

Transient execution tracking lives in [`KEYS-PLAN.md`](KEYS-PLAN.md).

#### Status

Scaffolded only. The repo currently discusses IEEE 754 specifically; the
broader structural claim about binary scientific notation is not yet
exhibited.

#### Literature Linkage

- TODO: find prior treatments of significands as coarse logs, FISR-style
  interpretations, and non-IEEE float analogues
- TODO: state exact overlap with the claim made here
- TODO: explain what this repo's mechanism adds (generalization beyond
  IEEE 754 to any binary scientific notation)
- TODO: note where the literature stops short of the repo's framing

### 4. Compatibility

These four layers -- coordinate, surrogate, representation, discretization --
are mutually adapted:

- The coordinate linearizes the function class (power laws become linear in
  log).
- The surrogate approximates that coordinate with scale-equivariant error.
- The representation provides that surrogate for free from binary scientific
  notation.
- The discretization (geometric grid = uniform in log space) respects the
  symmetry of the coordinate, so the minimax objective does not fight the
  geometry.

The result is that equal-width bins in log are equally hard, the worst-case
error does not concentrate at any particular scale, and the approximation
scheme cooperates with the structure of the problem rather than working
against it.

Breaking any one layer degrades the cooperation in a characteristic way:
wrong coordinate makes error position-dependent; wrong surrogate makes the
residual uncorrectable by scale-symmetric machinery; wrong representation
misaligns the free surrogate with the binary depth structure; wrong
discretization makes the grid fight the correction geometry.

#### Repo Support

Planned artifact: `compatibility_matrix.sage`

Target exhibit:

- four switchable layers (coordinate, surrogate, representation,
  discretization), each with a right and wrong choice: 2^4 = 16 combinations
- canonical target: the all-right combination produces equalized error and a
  small wall; flipping any single layer breaks the equalization
  characteristically
- acceptable staged implementation: first hold representation fixed and test
  the 2^3 coordinate / surrogate / discretization slice, then add the
  representation switch explicitly in a second pass

Transient execution tracking lives in [`KEYS-PLAN.md`](KEYS-PLAN.md).

#### Status

Scaffolded only. The partition sweeps test a downstream piece (geometric vs
uniform discretization), but the multi-layer compatibility claim has not been
exhibited as a single matrix.

#### Literature Linkage

- TODO: find prior arguments about matched coordinates, matched
  discretizations, or surrogate-geometry compatibility
- TODO: state exact overlap with the claim made here
- TODO: explain what this repo's mechanism adds (the three-layer joint
  formulation)
- TODO: note where the literature stops short of the repo's framing

## Hypotheses

The testable predictions of this thesis are tracked in
[`HYPOTHESES.md`](../HYPOTHESES.md). The primary tests are K1 (partition
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

- For the wall decomposition that motivates the K1--K3 tests, read
  [`WALL.md`](../wall/WALL.md).
- For the current hypothesis status labels, read
  [`HYPOTHESES.md`](../HYPOTHESES.md).
- For the overall science goal, read
  [`DISTANT-SHORES.md`](../../DISTANT-SHORES.md).

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

Run any of them with `./sagew experiments/keystone/<script>`.

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
