# Error trident

## The three errors

On a partition of [1, 2] into N cells, three error measures tell different
stories about the chord approximation to log_2.

**Global error** (gray).  The single chord m - 1 spans the full octave.  Its
peak error within each cell is fixed regardless of N — it is a property of the
chord and the curvature of log_2.  The peak sits near m* = 1/ln 2 ~ 1.443 and
decays toward both endpoints.

**Exported damage** (red).  Each cell's locally optimal chord — the secant of
log_2 at the cell endpoints — is perfect for that cell but wrong everywhere
else.  The exported damage is the median peak error that this chord produces on
all other cells.  It measures how much a cell's local solution hurts the rest
of the domain.

**Incoming damage** (blue).  The transpose: for a given cell, the median peak
error produced on it by all other cells' chords.  It measures how vulnerable a
cell is to foreign solutions.

The exported and incoming bars aggregate the same matrix along different axes.
The matrix entry e_{j->k} is the peak of |log_2(m) - chord_j(m)| on cell k.
Red takes row medians; blue takes column medians.

## What the visualization shows

A vertical stack of panels, one per cell count (N = 4, 8, 16, 32, 64), with
uniform and geometric partitions side by side.  At each cell's midpoint, the
three bars stand as a cluster.

As N grows:

- Gray stays fixed.  The global chord error is insensitive to partitioning.
- Red grows, especially at the left (m ~ 1) under uniform partitions.  Cells
  in the high-curvature region have steep optimal chords that are increasingly
  wrong in the flat region near m = 2.  The damage spike at m ~ 1 stays pinned
  near 0.14 and barely moves with N.
- Blue grows at the right under uniform partitions.  The flat cells near m = 2
  are the ones most damaged by foreign chords from the left.

The crossover count — cells where exported damage exceeds global error — grows
with N for both partition kinds.

## The geometric symmetry

Under geometric partitioning, max(red) = max(blue) at every N.  The damage
matrix is symmetric under index reversal: every cell exports exactly as much
as it imports.  This is a direct consequence of log-space self-similarity —
geometric cells are translates of each other in the coordinate where log_2 is
linear.

Under uniform partitioning, the red/blue split is asymmetric.  Left cells are
net exporters (tall red, shorter blue); right cells are net importers (tall
blue, shorter red).

## Computing e_{j->k}

The function f(m) = log_2(m) - chord_j(m) is concave (second derivative
-1/(m^2 ln 2)).  Its unconstrained stationary point is m*_j = 1/(sigma_j ln 2).
On a foreign cell [a_k, b_k], f may be positive, negative, or sign-changing,
so the sup-norm is needed.  Three candidates suffice:

    e_{j->k} = max(|f(a_k)|, |f(b_k)|, |f(m*_j)| if m*_j in (a_k, b_k))

## Aggregation: why median

- Max is dominated by the single worst foreign cell.
- Mean washes out structure.
- Median gives the typical exported/incoming damage — robust to the one or two
  cells where the foreign chord happens to be accidentally good or maximally
  bad.  Uses lower-median (floor index of sorted values, excluding self).

## Script

`error_trident_vis.sage` — run with `./sagew experiments/error/error_trident_vis.sage`.
Writes `error_trident.png`.
