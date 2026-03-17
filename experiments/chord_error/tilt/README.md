# Tilt decomposition

## The identity

Every per-cell chord error is the global chord error minus an affine
correction:

    E_{[a,b]}(m) = eps(m) - delta(m)

where eps(m) = log_2(m) - (m - 1) is the global error and
delta(m) = chord_{[a,b]}(m) - (m - 1) is the tilt.  The tilt is affine
in m with slope (sigma - 1), where sigma is the per-cell chord slope.

The second derivative is preserved: E'' = eps'' = -1/(m^2 ln 2).  Only
the first derivative changes.  This is Stage 3 of the chord error argument
(`plog_chord_argument.sage`).

## The tilt as piecewise-linear interpolant

When we tile [1, 2] with N cells and draw delta(m) on each cell, the result
is continuous across cell boundaries — both sides equal eps at each boundary
point.  The collection of tilt segments is the piecewise-linear interpolant
of eps at the partition points.  The gap between eps and this interpolant is
E, the per-cell error.

## What the visualization shows

Top panel: E(m) as a 100-tooth sawtooth for a uniform partition.  Each tooth
is a per-cell error arch vanishing at cell boundaries.  The red peak envelope
connects the tooth tips and decays from left to right — front-loaded curvature
makes left cells harder.  Peak ratio approaches 4:1 as N grows.

Bottom panel: the tilt slope (sigma - 1) as a step function across [1, 2].
Positive on the left (cell chord is steeper than the global chord), zero near
m = 1/ln 2 ~ 1.44, negative on the right.  This is the derivative of the
piecewise-linear interpolant minus 1.

## The zero crossing at m*

The tilt slope crosses zero where the per-cell chord slope equals the global
chord slope (sigma = 1).  This happens near m* = 1/ln 2, the peak of the
global error — the same distinguished point from Stage 1.

## Convergence

The peak ratio for uniform partitions does not vanish with N.  In the
small-cell limit:

    E_peak(a) ~ 1 / (8 N^2 a^2 ln 2)        (uniform, cell at position a)
    E_peak    ~ ln(2) / (8 N^2)               (geometric, all cells)

The ratio E_uniform(a) / E_geometric = 1/(a^2 ln^2 2), independent of N.
At a=1 the uniform peak is ~2.08x the geometric peak; at a=2 it is ~0.52x.
They cross at a = 1/ln 2 — the same m* again.

## Scripts

`chord_slope_crossing.sage` — cell chord slope step function showing the
zero crossing at m* = 1/ln 2.  Run with
`./sagew experiments/error/tilt/chord_slope_crossing.sage`.
Writes `chord_slope_crossing.png`.

`uniform_vs_geometric_peaks.sage` — three-panel comparison of uniform vs
geometric per-cell error and peak envelopes.  Run with
`./sagew experiments/error/tilt/uniform_vs_geometric_peaks.sage`.
Writes `uniform_vs_geometric_peaks.png`.
