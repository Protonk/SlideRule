## Thesis

The logarithm is the canonical coordinate for approximation on R_{>0} when the
governing symmetry is scaling; the affine pseudo-log is a coarse affine
surrogate for that coordinate, and a uniform grid in log space — equivalently,
a geometric grid in x — is the natural discretization compatible with that
symmetry.

## Breakdown

### 1. The coordinate

On R_{>0}, scaling x -> lambda * x is the native symmetry. Up to affine change
of variable, the logarithm is the unique coordinate that turns this symmetry
into translation: u(lambda * x) = u(x) + c(lambda). Under mild regularity,
u = A log x + B.

This is not deep. It is the functional-equation characterization of the
logarithm fixing the rest of the structure: any approximation scheme
that wants to treat all scales uniformly must, at bottom, be organized in this
coordinate.

### 2. The surrogate

The affine pseudo-log is a coarse affine surrogate for log x, induced by the
number representation. For an example, within each binade the integer 
reinterpretation of an IEEE 754 significand is already an 
approximately linear function of log_2(x).
The piecewise-affine coarse stage of the Day model exploits exactly this: one
affine piece per dyadic cell, each a local linearization of the log coordinate.

This is what makes the affine pseudo-log useful. It is not a Taylor
approximation to log in the usual sense. It is a representation-level encoding
that happens to be affine in the coordinate that linearizes scaling, because
the floating-point format was designed to be neutral with respect to the
reciprocal (1/x) measure — the measure under which all binades carry equal
weight.

### 3. The discretization

A uniform grid in log space assigns each cell a constant multiplicative width.
Equivalently, a geometric grid in x. This is the natural discretization
compatible with scaling: it is the unique partition (up to offset and step
size) that is invariant under multiplication by the grid ratio.

The dyadic partition used in the Day model is exactly this grid with ratio 2.
Each bit of the binary expansion selects a halving of the current cell, and
the depth-d partition has 2^d cells of equal multiplicative width.

### 4. Compatibility

These three layers — coordinate, surrogate, discretization — are mutually
adapted:

- The coordinate linearizes the function class (power laws become linear in
  log).
- The surrogate approximates that coordinate cheaply within the number format.
- The discretization respects the symmetry of the coordinate, so the minimax
  objective does not fight the geometry.

The result is that equal-width bins in log are equally hard, the worst-case
error does not concentrate at any particular scale, and the approximation
scheme cooperates with the structure of the problem rather than working
against it.

## Hypotheses

### L1. Geometric partitions outperform uniform partitions for power-law targets

Status: subdivided (2026-03-11) — see L1a, L1b, L1c

The first partition-comparison sweep shows that the original L1 claim is true
at the cell level but not under the shared-delta constraint in general.

**L1a** (free-per-cell): geometric cells have lower optimal per-cell error at
every tested depth. *Supported* — equal-log-width cells match the curvature of
`log2(z)` for power-law targets.

**L1b** (shared-delta, layer-invariant): geometric partitions do not generally
yield lower `opt_err`. *Not generally supported* — at intermediate depths,
the sharing penalty on geometric cells erases the cell-level advantage.

**L1c** (layer-dependent): under layer-dependent parameterization, the
geometric advantage from L1a propagates to lower `opt_err`. *Supported* across
the tested exponent_t=1/2 grid (2026-03-12), with initial positive checks at
exponent_t=1/3, but now refined by reciprocal controls: geometric is not unique
inside the tested x=1-heavy family, while the actual opposite-end control
`mirror_harmonic_x` loses to `uniform_x` at every tested LD point. At q=3, the
layer-dependent `opt_err` now appears nearly depth-flat across d=4..8.

Key insight: the FSM sharing constraint is bitwise/additive in structure, which
may align better with uniform-x cell boundaries. The "sharing penalty"
(`opt_err - free_err`) is larger on geometric cells under layer-invariant
parameterization but smaller under layer-dependent parameterization.

For detailed evidence, see [`HYPOTHESES.md`](HYPOTHESES.md) and
[`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).

### L2. Log-organized schemes behave more naturally for power laws than x-organized schemes

Status: mixed, requires subdivision similar to L1

Claim (unchanged):

- Approximation quality for x^(p/q) should degrade less with depth on a
  geometric grid than on a uniform grid.

First evidence (2026-03-11):

- `free_err` decays faster on geometric (lower at every depth), confirming L1a.
- `opt_err` grows faster on geometric at higher depths under layer-invariant
  sharing, mirroring L1b.
- Whether geometric behaves "more naturally" depends on which metric is used
  and which parameterization regime applies.

### L3. The wall decomposition is partition-dependent

Status: first evidence (2026-03-11)

Claim (unchanged):

- On a geometric grid, the dominant wall source is layer sharing.
- On a uniform grid, the dominant wall source should shift toward cell-level
  difficulty imbalance.

First evidence:

- The gap differs between partition kinds at every tested point.
- At (q=3, d=6), layer-dependent deltas reduce the gap by ~40% (uniform) and
  ~50% (geometric), confirming that layer sharing is the dominant source for
  both geometries at this depth.
- The larger gap reduction on geometric suggests the sharing penalty is more
  concentrated in the layer-sharing source for geometric cells.

## Connections

### Hamming / Knuth / Coonen lineage

Hamming (1970) showed that significands under repeated multiplicative
arithmetic converge to the reciprocal distribution. Knuth (TAOCP Vol 2, §4.2)
presents this in the floating-point context and notes that log_2(f) is uniform.
Coonen (1984) cites Knuth in the IEEE 754 design rationale.

This lineage establishes that the 1/x measure is not an assumption but an
attractor of multiplicative computation. The affine pseudo-log is useful in
part because the number format was engineered to be neutral with respect to
this measure.

For the current project, this is a consistency check: the coordinate that is
mathematically canonical for scale-equivariant approximation is also the one
that real arithmetic naturally occupies. The two facts reinforce each other
but are logically independent.

### Benford's law

The reciprocal distribution is the continuous analogue of Benford's law.
Friar, Goldman, and Pérez-Mercader (2016) discuss the emergence of the
reciprocal distribution in physical data. Berger and Hill (2011) survey the
mathematical status of Benford's law.

The connection to this project is ecological rather than structural: Benford's
law says that the 1/x measure shows up empirically in naturally occurring
data, which means the coordinate we are using for approximation is also the
one matched to typical inputs. This is pleasant but not load-bearing. The
theorems in this project depend on the scale-equivariance characterization,
not on empirical digit distributions.

## Caveats on explanatory predictions

Two natural predictions of this thesis are of the form "X is explained by Y":

- The success of FISR-style methods is interpretable as exploitation of a
  representation that already approximates the correct coordinate.

- Failures of naive argument reduction may be explainable as misalignment with
  the coordinate in which the problem is simplest.

Both are plausible readings, but they carry a risk that the other predictions
do not. The L1–L3 hypotheses are falsifiable within the current codebase: you
run the experiment, measure the wall, and the numbers either support the claim
or they don't. The explanatory predictions are retrospective. They reinterpret
known facts under the thesis but do not expose the thesis to new risk.

This is not fatal — good frameworks do explain known facts — but it means
these predictions should not be treated as evidence for the thesis on the same
footing as L1–L3. They are consistency checks, not tests. If L1–L3 fail, no
amount of satisfying FISR narrative will save the formulation. If L1–L3
succeed, the FISR and argument-reduction stories become more credible as
corollaries, but they were never going to be the load-bearing evidence.

There is also a specificity problem. "FISR works because the bit layout
approximates log" is well-known and does not require this thesis. The thesis
adds the claim that the *approximation-theoretic* utility of the pseudo-log —
not just its computational convenience — is explained by scale equivariance.
That is a stronger and more specific claim, and it is the one that L1–L3
actually test. The FISR connection is a familiar entry point, not a novel
prediction.

Similarly, "argument reduction fails when the coordinate is wrong" is true but
broad. To make it genuinely testable, one would need to pick a specific case
of argument-reduction failure, identify the coordinate mismatch quantitatively,
and show that switching to a log-aligned reduction fixes it. Without that, it
remains an appealing narrative rather than a concrete claim.

## Reading outward

- For the wall decomposition that motivates the L1–L3 tests, read
  [`WALL.md`](WALL.md).
- For the current hypothesis status labels, read
  [`HYPOTHESES.md`](HYPOTHESES.md).
- For the sweep data behind the current wall model, read
  [`SWEEP-REPORTS.md`](SWEEP-REPORTS.md).
