# Displacement Field Test: Current Read

This note is the short operational summary of the tiling experiment as it
currently stands. It is based on:

- `experiments/tiling/results/displacement_field/stage_a.csv`
- `experiments/tiling/results/displacement_field/stage_bc.csv`
- the companion plots in `experiments/tiling/results/displacement_field/`

Assumed context: the reader already knows the framing in `ABYSSAL-DOUBT.md`
and `DISTANT-SHORES.md`.

## Bottom line

The experiment supports a restrained version of the tiling claim:

- The displacement field `Δ^L(m) = m - log2(1 + m) = -ε(m)` is a good
  first-order description of the coarse forcing seen by the current FSM
  family.
- The strongest evidence is geometry-only: the free-per-cell intercept field
  already carries the same leading-bit residual shape as `Δ^L`.
- The actual FSM layer-0 allocation is close to, but not identical with, the
  best leading-bit fit to that free field. That mismatch is the current
  evidence for an FSM-specific component.
- Extra capacity (`LD` instead of `LI`, or larger `q`) improves final error
  much more reliably than it changes the layer-0 picture. That is consistent
  with a "coarse forcing + later repair" story.
- The forcing looks bounded on the tested depth range `d = 4..8`; it does not
  show signs of blowing up with depth.

What this does **not** establish: architecture-invariance. No second binary
architecture has been tested yet, and only the `x^(-1/2)` target is covered.

## Why the naive test is degenerate

The FSM's layer 0 has three free parameters (base intercept plus one delta
per leading bit). Its output is a step function: one constant per half.
Subtracting the free intercept field and demeaning within each half cancels
the layer-0 constants entirely, leaving only the free field's curvature.
A raw correlation between "layer-0 displacement" and `Δ^L` therefore tests
the free geometry, not the optimizer's allocation. It will come out positive
for trivial reasons.

The meaningful question is:

> After removing the best leading-bit step function, does the remaining shape
> in the free geometry and in the solved FSM data still look like `Δ^L`?

The experiment is built around that question, using these objects:

- `c*`: free-per-cell optimal intercept field
- `c^(<=t)`: cumulative shared intercept using layers `0..t`
- `Π0(f)`: best leading-bit piecewise-constant fit to a field `f`
- `R0(f) = f - Π0(f)`: the residual a pure leading-bit split cannot absorb

## What was tested

### Stage A: geometry only

Across 20 cases
`(4 partition kinds) x (depths 4, 5, 6, 7, 8)`, compare `R0(c*)` with
`R0(Δ^L)`. No shared solve is involved here.

### Stage B: actual layer-0 allocation

Across 48 solved cases
`(4 partition kinds) x (q = 3, 5) x (depths 4, 6, 8) x (LI/LD)`, compare
the actual `c^(<=0)` with the best leading-bit fit `Π0(c*)`.

### Stage C: cumulative absorption

On the same 48 solved cases, compare how fast `c^(<=t)` approaches `c*` under
`LI` vs `LD`, and under `q = 3` vs `q = 5`.

### Stage D: depth scaling

Track whether the leading-bit residual norm `||R0(c*)||∞` stabilizes or keeps
growing over `d = 4..8`.

## What the data supports

### Stage A: geometry-only residual match (strongest result)

The geometry-only residual match is consistently strong across all 20 cases.

| Partition kind | `corr(R0(c*), R0(Δ^L))` |
|---|---|
| uniform | `0.869 .. 0.875` |
| geometric | `0.849 .. 0.858` |
| harmonic | `0.804 .. 0.827` |
| mirror-harmonic | `0.839 .. 0.892` |

The important point is not that the match is perfect; it is not. The
best-scale normalized error still sits around `0.40 .. 0.59` depending on
partition and norm. But the same residual shape survives across all tested
depths and all four partition families.

Working read: before the FSM is involved, the free target already carries the
same leading-bit forcing shape as `Δ^L`. This is the cleanest evidence that
the tiling field is not empty symbolism.

### Stage B: layer-0 allocation (qualifies the claim)

The `L∞` layer-0 fit gap

`||c^(<=0) - Π0(c*)||∞`

ranges from `0.0077` to `0.0478`, with median `0.0191` across the 48 solved
cases.

So the actual layer-0 field is usually in the right neighborhood of the best
two-bin absorber, but it is not the same object. The largest outlier is:

- `harmonic_x`, `q = 3`, `depth = 6`, `LD`: fit gap `0.0478`

Two cautions matter here:

- `LD` is usually closer than `LI` at layer 0, but not always:
  `17 / 24` matched `LD` vs `LI` comparisons favor `LD`.
- This stage does **not** show that the FSM is merely reading off the tiling
  field. It shows that the FSM is approximating a target whose coarse shape is
  tiling-like, with a persistent optimizer-specific offset.

Working read: `Δ^L` explains the geometry of the target better than it explains
the exact optimizer allocation. The remaining gap is where automaton coupling
is currently living.

### Stage C: cumulative absorption (supports repair story)

For matched `LI` vs `LD` comparisons:

- `LD` has lower final error in `24 / 24` cases.
- The median final-error gain is about `0.0237` in `L∞`.
- The median layer-0 error change is only about `0.0084`.

For matched `q = 3` vs `q = 5` comparisons:

- `q = 5` has lower final error in `24 / 24` cases.
- The median final-error gain is about `0.0114`.
- The median layer-0 error change is only about `0.0035`.

This is the cleanest solver-dependent pattern in the experiment. More freedom
helps, but it helps much more at the end of the cumulative solve than at layer
0 itself.

Working read: `LI` vs `LD`, and `q = 3` vs `q = 5`, are mostly changing repair
capacity, not replacing the coarse forcing with a different one.

### Stage D: depth scaling (bounded forcing)

The geometry-only residual norm `||R0(c*)||∞` over depth is:

| Partition kind | `d = 4` | `d = 6` | `d = 8` |
|---|---:|---:|---:|
| uniform | `0.050` | `0.056` | `0.058` |
| geometric | `0.049` | `0.054` | `0.055` |
| harmonic | `0.045` | `0.049` | `0.050` |
| mirror-harmonic | `0.047` | `0.056` | `0.058` |

Across the four partition families, the depth-6 value is already about
`95% .. 98%` of the depth-8 value. Depth 7 is already about `98% .. 99%` of
depth 8.

Working read: on the tested range, the leading-bit forcing is converging toward
a partition-dependent limit. This looks like a bounded allocation problem, not
an obviously divergent one.

## Carrying this forward

If you need one sentence:

> For the present FSM experiments, `Δ^L` is the right zeroth-order forcing
> field, but it does not by itself determine the optimizer's exact layer-0
> allocation.

That is enough to weaken the "this is just an FSM artifact" reading of the
abyssal doubt. It is **not** enough to claim that Step 6 is settled.

When reasoning about wall data:

- Treat `Δ^L` as the baseline object. The free geometry already carries
  its residual shape.
- Treat the layer-0 fit gap as the present measure of FSM-specific
  distortion relative to that baseline.
- Treat `LD` and larger `q` primarily as ways of improving later-layer
  repair, not as ways of changing the coarse forcing.
- Do **not** claim architecture-invariance. The next decisive move is a
  second binary architecture or a genuine lower bound.

What the experiment does not yet prove:

- No second binary architecture has been checked.
- Only the `x^(-1/2)` target is tested. `Δ^L` is exponent-independent,
  but `c*` is not.
- Depth stabilization is empirical on `d = 4..8`, not a theorem.
