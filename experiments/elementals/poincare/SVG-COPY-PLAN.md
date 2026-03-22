# SVG Copy Plan: Binary Tiling Dual

Purpose: produce a SageMath/matplotlib rendering of the Eppstein binary
tiling dual SVG (`exterior/eppstein/binary/Binary-tiling-dual.svg.png`)
that is visually indistinguishable from the original.

Reference image: `exterior/eppstein/binary/Binary-tiling-dual.svg.png`
Reference description: "A binary tiling (red outline) and its dual
tiling (yellow curved triangles and blue and green curved
quadrilaterals)."

---

## 1. Coordinate system (decoded from the SVG)

The SVG maps the Poincaré half-plane to pixel coordinates via:

```
y_SVG = A - B / y_hyp
x_SVG = x_hyp * B + x_offset
```

where:
- `A = 1070.6` (the asymptotic boundary in SVG y-space)
- `B = 647.2` (scale factor)
- `y_hyp` is the half-plane height (y_hyp → ∞ maps to y_SVG → A from below)
- SVG y increases downward; the ideal boundary is at the bottom

The level boundaries in hyperbolic coordinates are:

| Level boundary | y_hyp | y_SVG  |
|---------------|-------|--------|
| top of level 0 | 0.5  | -224.6 |
| 0/1 boundary  | 1.0  | 423.4  |
| 1/2 boundary  | 2.0  | 747.0  |
| 2/3 boundary  | 4.0  | 909.0  |
| 3/4 boundary  | 8.0  | 989.9  |
| 4/5 boundary  | 16.0 | 1030.4 |
| 5/6 boundary  | 32.0 | 1050.6 |

Level d has boundaries at `y_hyp = 2^d` and `y_hyp = 2^(d+1)`.
Height per level halves in SVG space: 648, 324, 162, 81, 40.5, 20.2.

Full visible x-range: `[-272.3, 1777.6]` (2049.9 SVG units = 2 coarse
cells of width 1024.95 each).

**Important:** Cell centers use the **arithmetic** mean of their
`y_hyp` boundaries, not the geometric (hyperbolic midpoint) mean.
Verified: level-1 cell center at `y_hyp = (1+2)/2 = 1.5` gives
`y_SVG = 1070.6 - 647.2/1.5 = 639.1`, matching the SVG exactly.

---

## 2. Tiling structure

The binary tiling in the visible window:

| Level | Cells | Cell width (SVG) | Cell height (SVG) | y_hyp range |
|-------|-------|------------------|-------------------|-------------|
| 0     | 2     | 1025.0           | 648               | [1, 2]      |
| 1     | 4     | 512.5            | 324               | [2, 4]      |
| 2     | 8     | 256.25           | 162               | [4, 8]      |
| 3     | 16    | 128.1            | 81                | [8, 16]     |
| 4     | 32    | 64.0             | 40.5              | [16, 32]    |
| 5     | 64    | 32.0             | 20.2              | [32, 64]    |

There is also a partial level -1 (1 cell, `y_hyp ∈ [0.5, 1]`, above
the viewport) whose center is needed for the topmost dual faces.

Cell center at level d, position k:
- `x_center = x_left_edge + cell_width / 2`
- `y_center_hyp = (y_hyp_lo + y_hyp_hi) / 2` (arithmetic mean)

---

## 3. Dual face construction

The dual has one face per interior tiling vertex. Each tiling vertex is
at the intersection of a horocyclic boundary and a geodesic (vertical)
boundary.

### Vertex types

**Split vertex (valence 3, "T-junction"):** at a point where a
level-d cell splits into two level-(d+1) children. Three cells meet:
the parent above and two children below. The dual face is a **curved
triangle** connecting the three cell centers with geodesic arcs.

**Continuing vertex (valence 4):** at a geodesic boundary that persists
from level d to level d+1. Four cells meet: two above, two below. The
dual face is a **curved quadrilateral** connecting the four cell centers.

### Geodesic arcs

The dual face boundaries are hyperbolic geodesics between cell centers.
In the half-plane model, the geodesic between `(x1, y1)` and `(x2, y2)`:

- If `x1 = x2`: vertical segment.
- Otherwise: arc of the circle centered at `(cx, 0)` where
  `cx = ((x1² + y1²) - (x2² + y2²)) / (2(x1 - x2))`, radius
  `r = sqrt((x1-cx)² + y1²)`.

For rendering, these arcs must be mapped through the SVG coordinate
transform `(x_hyp, y_hyp) → (x_SVG, y_SVG)` after computation.

**Rendering approach:** compute the geodesic in hyperbolic coordinates,
sample ~30-50 points along the arc, then map each point to the output
coordinate system. Use `matplotlib.patches.Polygon` with the sampled
points to fill each dual face.

### Vertex ordering

For each vertex, the adjacent cell centers must be ordered
(counter-clockwise or clockwise) before connecting them with arcs.
Sort by angle from the vertex using `atan2(y_c - y_v, x_c - x_v)`.

---

## 4. Coloring

The SVG uses three colors:

| Color   | Hex       | Count | Applied to |
|---------|-----------|-------|------------|
| Yellow  | `#ffe07f` | ~128 subpaths | Curved triangles (valence-3 split vertices) |
| Green   | `#7fc8a2` | ~41 subpaths  | Curved quadrilaterals at some depths |
| Blue    | `#7fc0e6` | ~82 subpaths  | Curved quadrilaterals at other depths |

The coloring rule (to be verified during implementation):
- **Yellow:** all split (valence-3) dual faces.
- **Green:** continuing (valence-4) dual faces where the boundary
  depth d is even.
- **Blue:** continuing (valence-4) dual faces where the boundary
  depth d is odd.

If the green/blue assignment doesn't match the reference after a first
pass, try: coloring by `(depth + horizontal_position) % 2`, or by the
parity of the cell index. The exact rule can be extracted by comparing
specific face positions in the SVG with the generated output.

### Tiling grid

The red grid (`#bc1e46`, stroke width 2) is drawn over the dual faces.
It consists of the rectangular cell boundaries: horizontal horocyclic
lines and vertical geodesic lines at each level.

---

## 5. Implementation steps

### Step 1: Coordinate system

Set up the half-plane coordinate system and the mapping to output
coordinates. The matplotlib figure should have:
- `figsize` chosen so the aspect ratio matches the SVG (1505.3 × 1053.9,
  roughly 1.43:1).
- `ax.set_xlim` and `ax.set_ylim` matching the SVG viewport:
  x ∈ [0, 1505.3], y ∈ [0, 1053.9], or equivalently work in
  hyperbolic coordinates and transform at render time.

**Test:** render just the level boundaries as horizontal lines and
verify their y-positions match the SVG values (423.4, 747.0, 909.0, ...).

### Step 2: Tiling grid

Draw the rectangular grid in red. At each level d, draw horizontal
lines at the top and bottom boundaries, and vertical lines at each
cell edge.

**Test:** overlay the red grid on the reference PNG and check alignment.

### Step 3: Cell centers

Compute all cell centers using arithmetic y-mean. Include one parent
level above the viewport for the topmost dual faces.

**Test:** plot cell centers as dots and verify they sit at the visual
center of each rectangular cell.

### Step 4: Vertex enumeration

Find all interior vertices and classify as split (valence 3) or
continuing (valence 4). For each, record the adjacent cell IDs.

**Test:** count vertices per level boundary and verify:
- boundary 0/1: 1 continuing + 2 split = 3
- boundary 1/2: 3 continuing + 4 split = 7
- boundary 2/3: 7 continuing + 8 split = 15
- boundary 3/4: 15 continuing + 16 split = 31
- boundary 4/5: 31 continuing + 32 split = 63

### Step 5: Geodesic arcs

Implement the geodesic arc computation. Test by drawing one arc
between two known cell centers and verifying it matches the
corresponding curve in the SVG.

**Test:** extract the first yellow petal's bezier control points from
the SVG and compare with the geodesic-arc polygon at the same vertex.
The petal at `x_hyp ≈ -16.1/B + offset`, `y_hyp = 2.0` has vertices at
cell centers `(-16, 639.1)`, `(-144.1, 855.0)`, and `(112.1, 855.0)`
in SVG coordinates.

### Step 6: Dual faces

Build and fill all dual face polygons. Apply the 3-color scheme.

**Test:** visual comparison with the reference PNG at each color
separately. Count faces per color and compare with SVG subpath counts.

### Step 7: Compositing

Layer the elements: dual faces (bottom), then red grid (top).
Remove axes and borders. Set background to white.

**Test:** overlay at 50% opacity on the reference PNG. All major
features (petal tips, grid intersections, color boundaries) should
align within ~2px.

### Step 8: Edge cases

Handle:
- Faces at the viewport boundary (clip rather than omit).
- The topmost face (extends above viewport — use the parent cell center).
- The bottommost faces (may be too small to render — stop at level 5).
- Left/right edges (faces at x = 0 and x = 2×cell_width are partial).

---

## 6. Verification checklist

After implementation, check each of these against the reference:

- [ ] Aspect ratio matches (≈ 1.43:1)
- [ ] Red grid lines align at all 6 level boundaries
- [ ] Red grid vertical lines align at each cell edge
- [ ] Yellow petals have the correct pointed-tip-up orientation
- [ ] Yellow petals touch adjacent petals without gaps or overlaps
- [ ] Green and blue quads fill the remaining space between yellow petals
- [ ] No white gaps between adjacent dual faces (complete tiling)
- [ ] The topmost face (large green quad) fills the top of the frame
- [ ] Color assignment matches: yellow = triangles, green/blue = quads
- [ ] Grid line color is `#bc1e46` (dark rose)
- [ ] Dual face edge strokes are black and thin (~0.5pt)
- [ ] The image reads as a seamless hyperbolic tiling, not a collection
  of isolated shapes

---

## 7. Files

| File | Role |
|------|------|
| `exterior/eppstein/binary/Binary-tiling-dual.svg` | Source SVG |
| `exterior/eppstein/binary/Binary-tiling-dual.svg.png` | Reference PNG |
| `experiments/elementals/poincare/E3_binary_tiling_dual.sage` | Existing prototype (current version) |
| `experiments/elementals/poincare/results/E3_binary_tiling_dual.png` | Output |
| This file | Plan |

The existing `E3_binary_tiling_dual.sage` should be revised in place.
The current prototype has the correct tiling structure but uses the
wrong y-centering (geometric mean instead of arithmetic), doesn't match
the SVG viewport framing, and has gaps between dual faces.
