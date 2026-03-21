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

Artifact: `coordinate_uniqueness.sage` -> `results/coordinate_uniqueness.png`

Computes the peak chord error of log2(x) on each cell for 6 partition kinds
at depth 6 (N=64). Geometric produces a perfectly flat line (max/min ratio =
1.0000000000). Uniform peaks near x=1 at ~5x the geometric level. Harmonic
inverts the curve. Chebyshev and ruler oscillate wildly. The flat line is
the exhibit: it is a direct consequence of log being the coordinate where
the approximation problem is translation-invariant under scaling.

#### Status

Exhibited. The flat geometric line and the position-dependent profiles of
all other partition kinds directly demonstrate the claim.

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

Artifact: `surrogacy_test.sage` -> `results/surrogacy_test.png`

Compares four surrogates for log2 on [1, 2): pseudo-log (x-1), Chebyshev
minimax linear fit, Taylor expansion at 1.5, and reciprocal (2-2/x).

Key result: the Chebyshev fit has the lowest peak residual (0.043 vs
pseudo-log's 0.086), but its residual is offset by -0.043 at both binade
boundaries. The pseudo-log is the only surrogate (besides the trivially
related reciprocal) whose residual vanishes at x=1 and x=2 — the coarsest
geometric cell boundaries. This means the correction task within each binade
is self-contained: no correction budget is wasted removing a constant offset.

The surrogacy claim is: the pseudo-log is preferred not because it minimizes
error, but because its error is boundary-aligned with the geometric grid,
making it correctable by binade-local machinery.

#### Status

Exhibited. The boundary-alignment property and the raw-error comparison
directly demonstrate the claim.

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

Artifact: `float_formats.sage` -> `results/float_formats.png`

Defines three toy float formats (binary b=2, hex b=16, base-3 b=3) and
plots four panels:

1. Significand sawtooth across binades — binary resets at every power of 2,
   hex has one wide tooth per power of 16, base-3 resets at powers of 3.
2. Residual on [1, 2) — binary's residual is the eps(m) shape from §2
   (zero at binade boundaries). Hex and base-3 have large residuals because
   [1, 2) is a partial binade for them.
3. The §2 connection — pseudo-log = significand field, with annotated
   boundary zeros.
4. Binade boundaries vs binary geometric grid — binary boundaries nest
   perfectly; base-3 boundaries fall between grid lines.

The exhibit shows that binary scientific notation gives you the pseudo-log
structurally: the significand field IS the pseudo-log, its teeth ARE the
geometric grid cells, and its residual vanishes at binade boundaries.

#### Status

Exhibited. The structural fact is visible in the sawtooth alignment and
the boundary-zero property.

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

Artifact: `compatibility_matrix.sage` -> `results/compatibility_matrix.png`

Compares geometric vs uniform grids at three levels: free per-cell error,
shared-delta per-cell error (LI), and wall excess (shared minus free). Four
panels at q=3, depth=6, exponent=1/2.

Key results:
- Free per-cell: geometric is flat (max/min ~ 1), uniform curves by ~2x.
  Geometric worst = 0.0019, uniform worst = 0.0028.
- Wall excess concentration: geometric max/min = 37.6 (distributed),
  uniform max/min = 179.7 (concentrated on already-hard cells near x=1).
- Under LI sharing, geometric has a larger total wall (0.040 vs 0.035) but
  a more evenly distributed wall excess.

The compatibility exhibit: geometric equalizes the free error (discretization
cooperates with the coordinate) and distributes the wall more evenly.
Uniform has unequal free error AND concentrated wall — the sharing penalty
piles on the cells that were already disadvantaged.

The surrogate layer was tested via c0 offset but the optimizer absorbs
the shift (c0 is a free parameter). The surrogate comparison is therefore
structural (§2-§3 exhibits) rather than optimizer-based.

#### Status

Exhibited (staged: discretization layer tested; surrogate layer exhibited
structurally in §2-§3; representation layer exhibited in §3).

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
