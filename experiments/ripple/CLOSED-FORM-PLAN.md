# Closed-form coastline area

## Why

`coastline_area(depth, kind)` currently calls `scipy.integrate.quad` once
per cell.  At depth `d` that is `2^d` calls; across 23 partitions and
depths 1–10 it totals ~47K adaptive quadrature invocations.  This is
tolerable (~1–2 min) but blocks going deeper.  At depth 14 (N = 16384)
the count is ~375K and the runtime becomes impractical.

A closed-form antiderivative eliminates the quadrature entirely: each cell
becomes a direct evaluation, and the whole 23 x 10 sweep drops to
microseconds.

## The integrand

On cell `[a, b]` with chord slope `sigma_j`:

```
sigma_j = (log2(b) - log2(a)) / (b - a)
```

the integrand is

```
f(m) = |c(m) - (sigma_j - 1)|     where  c(m) = 1/(m ln 2) - 1
```

Since `sigma_j - 1` is a constant on the cell, this is

```
f(m) = |1/(m ln 2) - sigma_j|
```

## Shape analysis

`c(m) = 1/(m ln 2) - 1` is strictly decreasing on `[1, 2]`.  It crosses
zero at `m* = 1/ln 2 ≈ 1.4427`.  On any cell `[a, b]`:

- `c(m)` is monotone (decreasing).
- `sigma_j` is a constant horizontal line.

So the difference `c(m) - sigma_j` is monotone on `[a, b]` and changes
sign **at most once**.  The crossing point, if it exists, is where
`c(m) = sigma_j`, i.e.

```
m_cross = 1 / (sigma_j * ln 2)       (if  a <= m_cross <= b)
```

This means the absolute value splits into at most **two monotone pieces**
with a known split point.

## Antiderivative

The signed integral (without absolute value) of `c(m) - sigma_j` is:

```
F(m) = integral of [1/(m ln 2) - sigma_j] dm
     = ln(m) / ln(2) - sigma_j * m  + const
     = log2(m) - sigma_j * m  + const
```

So on any interval `[u, v]` where the sign does not change:

```
integral_u^v |c(m) - sigma_j| dm  =  ± [F(v) - F(u)]
```

with the sign chosen to make the result positive.

## Algorithm per cell

Given cell `[a, b]` with chord slope `sigma_j`:

1. Compute `m_cross = 1 / (sigma_j * ln 2)`.
2. If `m_cross <= a` or `m_cross >= b`: the integrand does not change sign.
   Return `|F(b) - F(a)|`.
3. Otherwise: split at `m_cross`.
   Return `|F(m_cross) - F(a)| + |F(b) - F(m_cross)|`.

where `F(m) = log2(m) - sigma_j * m`.

Total cost: one `log2` call and 2–3 subtractions per cell.  No quadrature.

## Why all 23 partitions share one formula

The integrand depends only on `sigma_j` (the cell's chord slope) and the
universal curve `1/(m ln 2)`.  Every partition kind produces the same
structure: a list of cells, each with its own `sigma_j`.  The closed-form
formula above applies identically regardless of how the partition generated
its cell boundaries.

No per-partition-kind specialization is needed.  One function handles all 23.

## Scope

This is a drop-in replacement for `coastline_area()` in `coastline.sage`.
The signature stays the same; the implementation changes from `integrate.quad`
to the closed-form evaluation above.  Everything downstream (measures,
sparklines, stability heatmap) benefits automatically.

Not urgent: the current quad-based implementation works fine at depth 10.
Implement this when deeper depth ranges are needed.
