# Glossary

Canonical reference for project-specific terms, notation, and objects.
Each entry is self-contained for retrieval. Mathematical definitions use
inline code or indented blocks.

---

## target exponent (exponent_t)

The rational number `p_num / q_den` such that the approximation target is
`x^(-exponent_t)`. For the default FRSR benchmark, `exponent_t = 1/2`.
Appears in sweep configs, CSV columns, and hypothesis statements throughout
the project.

Historical note: older code and CSV columns use the name `alpha` for this
quantity.

## alpha_Day (α_Day)

In the Day FRGR framework, `α_Day = min(a, b)` where the target function
is `x^(-a/b)` with `gcd(a,b) = 1`. The value α_Day determines which
candidate set (H or V) contributes `z_min`. For the FRSR case
(`x^(-1/2)`), `a = 1, b = 2`, so `α_Day = 1`. This is always a positive
integer, unlike the project's alpha which is a rational in (0, 1).

## alternation pattern

The sequence of signs `{+, −}^N` across the N = 2^depth cells, derived from
the displacement: `sign_j = sgn(displacement_j)`. This is the spatial
fingerprint of the wall. See
[`experiments/alternation/ALTERNATION.md`](experiments/alternation/ALTERNATION.md).

## automaton coupling

The third and finest source of the wall. Even in the layer-dependent
model, multiple leaves share parameters through the `(layer, state, bit)`
triple; the layer-dependent model has `1 + 2q × depth` parameters for
`2^depth` leaves, so parameters are still reused. The residual gap
`opt_err(layer-dependent) − free_err` is attributed to this coupling.

## beta (β)

Day notation: `β = max(a, b)`. For FRSR, `β = 2`.

## bits / binary_prefix

The depth-bit tuple of `0/1` values attached to a cell. This is the cell's
binary address in the refinement tree, not the geometry itself. In current
repo terminology, `bits` tells you which row you are talking about, while
the partition `kind` tells you how that row's `x`-space boundaries are
placed.

## c (magic constant parameter)

The free parameter in the coarse approximation line `aX + bY = c` in
pseudolog space. The integer part `s = floor(c)` controls only scaling;
the fractional part `t = frac(c)` controls approximation quality through
`ρ(t) = z_max(t) / z_min(t)`. The optimal `t*` minimises ρ. For the
FRSR case, `t* = 0.5`, so `c* = s + 0.5` for any integer s. The classic
Quake magic constant `0x5F3759DF` encodes a particular choice of c via
the IEEE 754 bit layout.

## candidate set

The finite set of points at which `z(x)` can attain its global extrema.
These are the points where the line `aX + bY = c` crosses an integer
grid line in pseudolog–pseudolog space. Day classifies them into three
families: H-points (integer X), V-points (integer Y), and D-points
(integer X − Y). In the `ζ` notation:

    H = { ζ(r, b, c) : 0 ≤ r < b }
    V = { ζ(r, a, c) : 0 ≤ r < a }
    D = { ζ(r, γ, c) : 0 ≤ r < γ }

The minimum z comes from the set indexed by α_Day and the maximum from the
set indexed by γ. The active candidate within each set depends on
whether `t = frac(c)` is above or below the switchover values `t0(α_Day)`
and `t1(γ)`.

## cell

One interval in a depth-`d` partition of the domain; there are `2^d`
cells at depth `d`. Each cell gets one affine piece of the
piecewise-linear approximation. In the free-per-cell model, each cell has
an independently optimised intercept. In shared-delta models, the
intercept is determined by the FSM state trajectory through that cell's
binary address.

## coarse approximation (coarse stage)

The first stage of the FRGR algorithm. Given `x`, compute `X = L(x)`,
then `Y = (c − aX) / b`, then `y = L⁻¹(Y)`. The output y is a
piecewise-linear approximation to `x^(−a/b)`, accurate to within a
factor controlled by ρ. No polynomial evaluation is needed; the
computation is integer arithmetic on the bit pattern. The coarse stage is
the object the smale project studies — the refinement polynomial is not
part of the current investigation.

## Day (2023)

Mike Day, "Generalising the Fast Reciprocal Square Root Algorithm,"
arXiv:2307.15600. The foundational reference for this project. Key
contributions: (1) generalises FRSR to arbitrary `x^(−a/b)`; (2) shows
z(x) has a finite candidate set for its extrema; (3) proves ρ = z_max /
z_min is the correct optimisation target; (4) gives Algorithm 3 for
computing optimal c; (5) provides closed-form linear minimax refinement
coefficients. The smale project uses Day's coarse-stage framework as its
starting point and studies what happens when the intercept c is replaced
by a state-dependent correction policy.

## delta (δ), delta table

The correction applied to the base intercept by the FSM. The shared-delta
policy stores a table `δ[(state, bit)]` giving the additive correction
for each (state, bit) pair. In the **layer-invariant** model, one table
is reused at every depth level, giving `1 + 2q` total parameters (1 base
intercept + 2q delta entries for q states × 2 bit values). In the
**layer-dependent** model, each depth level has its own table, giving
`1 + 2q × depth` parameters.

## depth (d)

The number of levels in the binary refinement tree. Any depth-`d`
partition in this repo has `2^d` leaf cells. Depth also equals the
number of bits consumed by the FSM in determining the intercept for a
given input.

## displacement

The signed difference `path_intercept_j − free_cell_intercept_j` for a
given cell under a shared-delta policy. Positive displacement means the
sharing constraint pushes the cell's intercept above its per-cell optimum;
negative means below. The sign of the displacement gives the alternation
pattern; the magnitude gives the local cost of sharing. The displacement
profile across all cells is the continuous precursor to the binary
alternation sequence.

## dyadic

An overloaded historical term. In this repo it can refer to three
different things:

1. binary addressing by bit-prefix cells;
2. the legacy exact oracle path with equal-additive cells
   `[1 + j/2^d, 1 + (j+1)/2^d)`, which corresponds to current `uniform_x`;
3. dyadic-rational snapping, as in the `dyadic_x` control partition or the
   optimizer's dyadic rounding of returned parameters.

Because the term is overloaded, current repo docs prefer explicit names
such as `uniform_x`, `geometric_x`, `dyadic_x`, and `bits`.

## dyadic_x

A specific partition kind in the zoo: geometric target boundaries snapped
to nearby dyadic rationals `k/2^R`. It is a finite-precision control, not
the same thing as the legacy exact `uniform_x` oracle path and not a
synonym for binary addressing.

## epsilon function, ε(m)

The global pseudo-log error: `ε(m) = log₂(m) − (m − 1)` for
`m ∈ [1, 2)`. This is the gap between the true logarithm and the affine
pseudo-log on one binade. It is concave, zero at both endpoints
(`ε(1) = 0`, `ε(2) = log₂(2) − 1 = 0`), with maximum at
`m* = 1 / ln 2`. Its second
derivative is `ε''(m) = −1/(m² ln 2)`. The tilt decomposition writes
each per-cell chord error as `ε(m) − δ(m)` where δ is the affine tilt.

## evaluation regime

The repo has two evaluation regimes for per-cell and global error
computation.

The **reference exact `uniform_x` oracle** computes exact extrema on the
equal-additive `uniform_x` cells. It is the authoritative regression and
validation target.

The **arbitrary-cell regime** computes the same style of error metrics from
general cell bounds, typically supplied as `plog_lo` / `plog_hi` from a
partition row. This is the regime used for current cross-partition
keystone comparisons.

The relationship between them is important: on `uniform_x`, the
arbitrary-cell regime is checked against the reference exact `uniform_x`
oracle, and the exact oracle remains the validation anchor for the more
general path.

## foreign-chord error matrix, E[j, k]

A matrix whose (j, k) entry records the error when the chord optimised
for cell j is applied to cell k instead. This is a tool for reasoning
about how FSM policies, which force cells to share correction parameters,
incur error by using "foreign" chords.

## free-per-cell lower bound (free_err)

The best worst-case error achievable when each leaf cell independently
optimises its own intercept with no sharing constraint. This is the
unconstrained floor — no FSM or shared policy can beat it. The wall is
defined as `opt_err − free_err`.

## FRGR (Fast Reciprocal General Root)

Day's generalisation of FRSR to `x^(−a/b)` for arbitrary coprime
positive integers a, b. Algorithm 2 in Day (2023). The coarse stage
uses the pseudolog line `aX + bY = c`; the refinement stage multiplies
by a degree-n minimax polynomial in z.

## FRSR (Fast Reciprocal Square Root)

The special case `a = 1, b = 2` of FRGR, corresponding to `x^(−1/2)`.
The original Quake III algorithm. In Day's notation: `α_Day = 1, β = 2,
γ = 3`. The optimal `t* = 0.5`, giving `c* = s + 0.5` for any integer s.
The candidate set has |H| = 2, |V| = 1, |D| = 3 candidates per period.

## FSM (finite-state machine)

The device that reads the bits of the input's binary representation and
transitions through states, accumulating an intercept correction. The
FSM has q states and processes one bit per depth level. At each step,
it emits a delta correction `δ[(current_state, bit)]` and transitions
to a new state. After processing all d bits, the accumulated correction
determines the intercept for that leaf cell. Two cells with different
bit addresses may still share the same state trajectory if they agree
on all FSM-relevant bits.

## gamma (γ)

Day notation: `γ = a + b`. For FRSR, `γ = 3`. The D-point candidates
(diagonal crossings) are indexed by residues mod γ, and `z_max` comes
from this family.

## gap

Synonym for the wall when expressed as a number: `gap = opt_err − free_err`.

## geometric partition (geometric_x)

The partition with equal log-width cells: cell j spans
`[x_start · r^j, x_start · r^(j+1))` where `r = (x_width / x_start + 1)^(1/N)`.
It is the unique partition invariant under multiplication by the grid
ratio. In the keystone program it is the preferred scale-equivariant
curve-agnostic geometry. In current repo terminology it is a geometry
name, distinct from the cell's binary address. See
[`KEYSTONE.md`](KEYSTONE.md) and [`HYPOTHESES.md`](HYPOTHESES.md) for
the status of the partition-comparison claims.

## candidate families (H, V, D)

The three families of candidate extrema for z(x) in Day's framework.
**H-points** occur where the pseudolog X is an integer (horizontal grid
lines); values are `ζ(r, b, c)` for `0 ≤ r < b`. **V-points** occur
where Y is an integer (vertical grid lines); values are `ζ(r, a, c)`
for `0 ≤ r < a`. **D-points** occur where `X − Y` is an integer
(diagonal grid lines); values are `ζ(r, γ, c)` for `0 ≤ r < γ`.
The minimum z comes from whichever of H or V has the smaller index
(`α_Day = min(a,b)`); the maximum z always comes from D. All three families
are expressed through the zeta function `ζ(r, k, c)`.

## hypotheses H1–H4, K1–K3

The project maintains two hypothesis families. **H1–H4** concern the
shared-delta / FSM story. **K1–K3** concern the keystone
scale-symmetry thesis and partition comparisons. See
[`HYPOTHESES.md`](HYPOTHESES.md) and [`KEYSTONE.md`](KEYSTONE.md).

## index

The integer cell id `0 .. 2^depth - 1` in row order. `index` and `bits`
encode the same position in the binary refinement tree:
`bits_to_index(bits)` converts one way and `index_to_bits(index, depth)`
converts the other. Like `bits`, `index` names a row position, not a
geometry.

## intercept

The additive constant `c` used by the coarse approximation on a given
cell. In the single-intercept baseline there is one global intercept for
the whole partition. In shared-delta models, each cell's effective
intercept is the base value plus the FSM corrections accumulated along the
cell's path. In the free-per-cell lower bound, each cell chooses its own
intercept independently.

## improve, imp/avl

Two summary statistics. `improve = single_err − opt_err`: how much the
shared-delta FSM beats the single-intercept Day baseline.
`imp/avl = improve / (single_err − free_err)`: the fraction of
*available* improvement (gap between baseline and floor) that the FSM
captures. An `imp/avl` near 1 means the FSM nearly closes the gap to
the free-per-cell floor.

## layer-dependent model

The parameterisation where each depth level has its own delta table:
`δ[(layer, state, bit)]`. Total parameters: `1 + 2q × depth`. This
removes the layer-sharing constraint but retains automaton coupling.

## layer-invariant model

The parameterisation where one delta table `δ[(state, bit)]` is reused at
every depth level. Total parameters: `1 + 2q`. This is the FSM's most
constrained shared mode.

## layer sharing

The second of three wall sources. The layer-invariant model forces one
correction law to serve all depth levels, conflating coarse and fine
positional effects.

## KEYSTONE

The project document (`KEYSTONE.md`) that states the overarching
scale-symmetry thesis: the logarithm is the canonical coordinate for
approximation on R_{>0} under scaling, the affine pseudo-log is its
coarse surrogate, and geometric grids are the natural compatible
discretization. Contains the K1–K3 hypothesis statements and the
Hamming/Knuth/Coonen lineage.

## minimax objective

The project optimises worst-case (L∞) relative error across all cells.
The FSM policy is chosen to minimise the maximum per-cell chord error.
This equioscillation-seeking objective tends to equalise cells rather
than diversify them.

## opt_err

The best worst-case error achieved by the shared-delta FSM policy under
the given parameterisation (layer-invariant or layer-dependent). This is
the number compared against `free_err` to compute the wall and against
`single_err` to compute the improvement.

## parameter budget

The first of three wall sources. The layer-invariant model has `1 + 2q`
parameters for `2^d` cells; the layer-dependent model has `1 + 2q × d`.
At larger depth, cell count growth (`2^d`) outruns both parameterisations.

## partition zoo

The collection of partition kinds implemented in `lib/partitions.sage`,
organised into labelled subgroups by construction method (elementary
geometric, number-theoretic, fractal, etc.). The zoo is open-ended — the
current count is 23 but may grow. Subgroup definitions and per-kind
metadata are in [`PARTITIONS.md`](PARTITIONS.md) and serialised in
[`lib/partitions.json`](lib/partitions.json).

## partition kind

The canonical string naming a partition geometry, passed to
`build_partition(...)` and stored as `row['kind']`. Examples include
`uniform_x`, `geometric_x`, `harmonic_x`, and `dyadic_x`.

## partition row

One row dict in a built partition. A partition row identifies one cell and
its geometry metadata, including `index`, `bits`, `x_lo`, `x_hi`,
`plog_lo`, `plog_hi`, `width_x`, `width_log`, and `kind`.

## partition_row_map (row map)

A dictionary from `bits` to the corresponding partition row. This is the
standard way to marry the FSM/path side of the code to arbitrary partition
geometry: the path supplies `bits`, and the row map supplies the matching
`x`-space and pseudo-log bounds for that cell under the chosen partition
kind.

## phi (φ)

Day notation: `φ(k) = 2^(1/(k−1)) / (2^(1/k) − 1) − k + 1`, extended
by limits at k = 0 and k = 1. The function whose integer and fractional
parts give `r̄(k)` and `t1(k)`, respectively. Controls which D-candidate
gives `z_max`.

## pseudo-log, pseudolog, L(x)

The piecewise-linear function that agrees with `log₂(x)` at powers of 2
and is linear between them. For `x > 0`, with `E_x = floor(log₂ x)` and
`m_x = x · 2^(−E_x) − 1`:

    L(x) = E_x + m_x

Its inverse is `L⁻¹(X) = 2^(floor(X)) · (1 + X − floor(X))`. The
pseudo-log is the mathematical abstraction of the IEEE 754 bit-pattern
reinterpretation. Within each binade, it is affine in x with slope
`2^(−E_x)`. The gap `log₂(m) − (m − 1)` is the error function ε(m).
The KEYSTONE thesis identifies the pseudo-log as a coarse affine
surrogate for the logarithmic coordinate that linearises scaling on R_{>0}.

## plog_lo, plog_hi

The pseudo-log lower and upper bounds attached to a partition row. They are
the `L(x)`-space images of `x_lo` and `x_hi`, and they are the inputs used
by the arbitrary-cell evaluator on non-legacy partition geometries.

## q (number of FSM states)

The state count of the finite-state machine. The FSM has q states
labelled `0, 1, ..., q−1`. Each state–bit pair `(s, b)` maps to a delta
correction and a next state. Increasing q enlarges the parameter budget:
`2q` delta entries per layer in the delta table.

## rho (ρ)

The ratio `ρ = z_max / z_min`. This is the optimisation target for the
coarse stage: minimising ρ minimises the worst-case relative error of the
coarse approximation. Day proves that the optimal polynomial refinement
error depends only on ρ and the polynomial degree, not on `z_min` and
`z_max` separately. The degree-0 (constant correction) minimax relative
error is `(√ρ − 1) / (√ρ + 1)`.

## SageMath / Sage

The computational environment used for all `.sage` files in the project.
Sage extends Python with exact arithmetic (QQ, RR, SR), combinatorics,
and algebra. The project runs Sage scripts via the `./sagew` wrapper.
Key libraries used alongside Sage: `numpy` and `scipy.optimize.linprog`
(for the LP-based minimax optimiser), `matplotlib` (for plotting).
SymPy is used in some analytical work (e.g., the pseudo-log chord
argument). The Sage files use `.sage` extension and are preprocessed by
Sage's preparsing step before execution as Python.

## scale symmetry / scale equivariance

The governing symmetry of the problem: `x → λx` for λ > 0. The
logarithm is (up to affine transformation) the unique coordinate that
turns this multiplicative symmetry into additive translation. The
KEYSTONE thesis argues that approximation schemes for power-law targets
should be organised in this coordinate, and that the pseudo-log and
geometric grids are the coarse implementations of that principle.

## sharing penalty

The excess error incurred by a shared-delta policy relative to the
free-per-cell floor on a given partition. Numerically, it equals the
wall: `opt_err − free_err`. The sharing penalty can differ across
partition kinds and parameterisation modes.

## single_err (single-intercept baseline)

The worst-case error of the best no-FSM baseline with one global
intercept `c` applied across the chosen partition geometry. This is the
baseline the shared-delta model must beat to demonstrate any value.

## t0, t1 (switchover values)

In Day's framework, `t0(α_Day)` is the value of `t = frac(c)` where the
identity of the `z_min` candidate switches (between residues 0 and
`α_Day − 1`). `t1(γ)` is where the `z_max` candidate switches (between
residues r̄ and r̄ − 1). For `α_Day = 1`: `t0 = 1/ln(2) − 1 ≈ 0.4427`.
The function `φ(γ) = r̄ + t1` determines both.

## tilt, tilt decomposition

Every per-cell chord error equals the global pseudo-log error minus an
affine correction: `E_{[a,b]}(m) = ε(m) − δ(m)`, where `δ(m)` is the
tilt — an affine function of m with slope `(σ − 1)`, σ being the
per-cell chord slope. The second derivative is preserved:
`E'' = ε'' = −1/(m² ln 2)`. The tilt segments across all cells form the
piecewise-linear interpolant of ε at the partition points. See
[`experiments/stepstone/TILT.md`](experiments/stepstone/TILT.md).

## uniform partition (uniform_x)

The partition with equal additive-width cells on the `x` axis. On `[1,2)`
at depth `d`, cell `j` is `[1 + j/2^d, 1 + (j+1)/2^d)`. This is the
legacy exact baseline geometry and the meaning intended when older project
notes say "dyadic partition" in the cell-geometry sense.

## wall

The central object of study: the persistent gap `wall = opt_err − free_err`
between the best shared-delta FSM policy and the unconstrained per-cell
lower bound. The wall is decomposed into three nested sources: (1)
parameter budget, (2) layer sharing, (3) automaton coupling. It is a
case-based decomposition supported by sweep data, not yet a theorem.
The alternation pattern is the wall's spatial fingerprint — it shows where
the sharing penalty concentrates across cells. See [`WALL.md`](WALL.md).

## z(x) (quality metric)

The function `z(x) = x^a · y(x)^b`, where y is the coarse approximation
to `x^(−a/b)`. When `y = x^(−a/b)` exactly, `z = 1`. The deviation of
z from 1 measures coarse-stage error. Day shows z is periodic in
pseudolog space with period b along the X-axis, and that its extrema
occur only at the candidate set H ∪ V ∪ D. The ratio `ρ = z_max / z_min`
is the optimisation target.

## zeta function, ζ(r, k, c)

Day's parametric family for candidate z-values:

    ζ(r, k, c) = 2^(s − r) · (1 + (r + t) / k)^k

where `s = floor(c)`, `t = frac(c)`, `k ∈ Z+`, `r ∈ {0, ..., k−1}`.
The sets H, V, D are expressed as `{ζ(r, b, c)}`, `{ζ(r, a, c)}`,
`{ζ(r, γ, c)}` respectively. The function `ζ̂(r, k, t) = 2^(−r/k) · (1 + (r+t)/k)`
is the normalised version whose k-th power (times 2^s) recovers ζ.
