# Superimposed per-cell arches

## The idea

Rescale each cell's per-cell chord error E_j(m) to a common coordinate
t = (m - a) / (b - a) in [0, 1] and overlay all N arches on the same axes.
This reveals the full distribution of arch shapes across the partition.

## What the visualization shows

Two panels (uniform | geometric), shared y-axis, all N=32 arches overlaid.
Cell position is encoded by color (viridis: dark = m~1, bright = m~2).

- **Uniform**: a fan.  Dark arches (left cells, high curvature) are tall with
  peaks pulled left.  Bright arches (right cells, low curvature) are short
  with peaks pulled right.  Peak ratio 3.82:1 at N=32.
- **Geometric**: complete overlap.  All 32 arches collapse onto one curve.
  Peak ratio 1.00:1 exactly.

The shared y-axis makes the comparison honest: the geometric arch sits at
about half the height of the uniform fan's tallest arch.

## Why geometric collapses

Geometric cells have constant ratio b/a = 2^(1/N).  The chord error on
[a, ra] depends only on the ratio r, not on a: after rescaling to [0, 1],
the arch is the same function for every cell.  This is log-space
self-similarity — geometric cells are translates of each other in the
coordinate where log_2 is linear.

## The fan never closes

The uniform peak ratio approaches 4:1 as N grows (it is 3.82 at N=32,
3.94 at N=100).  In the limit:

    E_peak_j ~ 1 / (8 N^2 a_j^2 ln 2)

so the ratio between the leftmost (a=1) and rightmost (a=2) peaks is
(2/1)^2 = 4.  The fan is a permanent structural feature of uniform
partitioning, not a transient artifact.

The uniform and geometric peaks cross at a = 1/ln 2 ~ 1.4427 — the
global error peak m* from Stage 1.

## Computing the arches

For each cell [a_j, b_j]:

    sigma_j  = (log2(b_j) - log2(a_j)) / (b_j - a_j)
    m(t)     = a_j + t * (b_j - a_j)
    E_j(t)   = log2(m(t)) - [log2(a_j) + sigma_j * (m(t) - a_j)]

Peak location in rescaled coordinates:

    m_peak_j = (b_j - a_j) / (ln(b_j) - ln(a_j))     (logarithmic mean)
    t_peak_j = (m_peak_j - a_j) / (b_j - a_j)

## Script

`superimposed_arches_vis.sage` — run with
`./sagew experiments/error/superimposed_arches_vis.sage`.
Writes `superimposed_arches.png`.
