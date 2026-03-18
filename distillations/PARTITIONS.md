# Partition Classification

The partition zoo contains **23 kinds** defined in `lib/partitions.sage`.
Each kind produces a partition of a domain `[x_start, x_start + x_width)`
into `2^depth` cells with distinct geometric character.

The thesis argues that **geometric** (equal log-width) achieves near-optimal
chord error for `1/(x ln 2)` while remaining curve-agnostic — a claim tested
by comparing against all 22 alternatives.

---

## Group A — Elementary Geometric

Simple spacing rules any practitioner would try first.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `uniform_x` | flat | symmetric | HiR | Equal additive width |
| `geometric_x` | log-uniform | log-symmetric | HiR | Equal log-width (scale equivariant) |
| `reverse_geometric_x` | right-dense | asymmetric | HiR | Geometric widths reversed (dense near x_end) |
| `harmonic_x` | left-dense | asymmetric | HiR | Equal spacing in 1/x (dense near x_start) |
| `mirror_harmonic_x` | right-dense | asymmetric | HiR | Mirrored reciprocal (dense near x_end) |

**uniform** divides equally in x-space. **geometric** divides equally in
log-space — the thesis winner. **harmonic** and **mirror_harmonic** are
reciprocal-space counterparts packing cells at opposite endpoints.
**reverse_geometric** reverses geometric's cell ordering.

---

## Group B — Number Theory / Rational Trees

Partitions arising from rational approximation and p-adic structure.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `stern_brocot_x` | rational-dense | asymmetric | QQ | Iterated mediant insertion |
| `minkowski_x` | rational-dense | asymmetric | QQ | Dyadic-to-Stern-Brocot conjugacy (? function) |
| `farey_rank_x` | rational-dense | asymmetric | QQ | Farey sequence rank-subsampled |
| `radical_inverse_x` | quasi-uniform | asymmetric | HiR | Van der Corput low-discrepancy (default base 2) |

**stern_brocot** inserts mediants between adjacent boundaries at each depth.
**minkowski** applies the inverse Minkowski question-mark function to map
dyadic rationals to Stern-Brocot mediants — producing identical boundaries
after affine scaling to the target domain (see Equivalences). **farey_rank** subsamples the Farey sequence F_Q at
equally-spaced ranks. **radical_inverse** generates the van der Corput
sequence, giving low-discrepancy quasi-uniform spacing.

Parameters:
- `radical_inverse_x`: `vdc_base` (default 2)
- `farey_rank_x`: `farey_order` (default: minimal Q with |F_Q| >= N+1)

---

## Group C — Fractal & Self-Similar

Partitions with internal self-similar or combinatorial structure.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `ruler_x` | fractal/scattered | asymmetric | QQ | Widths from 2-adic valuation |
| `thuemorse_x` | fractal/scattered | asymmetric | QQ | Thue-Morse binary sequence widths |
| `bitrev_geometric_x` | fractal/scattered | asymmetric | HiR | Geometric widths under bit-reversal permutation |
| `cantor_x` | fractal/scattered | asymmetric | HiR | Cells in surviving Cantor-dust intervals |

**ruler** assigns cell j width proportional to `2^{-v_2(j+1)}` where v_2 is
the 2-adic valuation — a fractal hierarchy. **thuemorse** alternates widths
by the parity of the popcount of j, producing the "anti-ruler." **bitrev_geometric**
takes geometric widths and permutes them by bit-reversal. **cantor** distributes
cells only within the surviving intervals of iterated middle-third removal.

Parameters:
- `thuemorse_x`: `tm_ratio` (default 2) — width ratio between 0-bit and 1-bit cells
- `cantor_x`: `cantor_levels` (default 3) — recursion depth for middle-third removal

---

## Group D — Symbolic Dynamics

Partitions from irrational rotation sequences and formal languages.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `golden_x` | quasi-uniform | asymmetric | HiR | Golden-ratio Kronecker sequence |
| `sturmian_x` | quasi-uniform | asymmetric | QQ | Sturmian word (irrational rotation) widths |

**golden** sorts the fractional parts `{j * phi}` for j = 1..N-1 to get
quasi-uniform breakpoints with the three-distance property. **sturmian**
generalizes this: cell widths are determined by the Sturmian sequence
`s_j = floor((j+1)*alpha + phase) - floor(j*alpha + phase)`, with `alpha`
reduced modulo 1 into the standard binary Sturmian regime and a configurable
width ratio.

Parameters:
- `sturmian_x`: `st_alpha` (default `1/phi`), `st_phase` (default 0),
  `st_ratio` (default 2)

---

## Group E — Approximation / Parametric

Partitions from approximation theory and parametric density families.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `chebyshev_x` | both endpoints | symmetric | HiR | Clenshaw-Curtis nodes |
| `sinusoidal_x` | fractal/scattered | asymmetric | HiR | Density oscillates in log-space |
| `powerlaw_x` | left-dense | asymmetric | HiR | Density ~ m^{-p} |
| `beta_x` | right-dense | asymmetric | HiR | Beta distribution CDF-inverted |

**chebyshev** places boundaries at Clenshaw-Curtis extrema, dense at both
endpoints — the classical choice for polynomial approximation. **sinusoidal**
modulates log-uniform density with a periodic ripple. **powerlaw** packs cells
aggressively near x_start via CDF inversion of a power law. **beta** uses the
Beta(alpha, beta) CDF for flexible asymmetric density shaping; the default
`Beta(5, 2)` setting is the intended right-dense control.

Parameters:
- `sinusoidal_x`: `sin_k` (default 3), `sin_alpha` (default 0.6)
- `powerlaw_x`: `pl_exponent` (default 3)
- `beta_x`: `beta_alpha` (default 5), `beta_beta` (default 2)

---

## Group F — Curve-Aware

Partitions that use knowledge of the target curve `c(x) = 1/(x ln 2)`.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `arc_length_x` | left-dense | asymmetric | HiR | Equal arc-length cells |
| `minimax_chord_x` | left-dense | asymmetric | HiR | Minimax chord error equi-oscillation |

**arc_length** divides the curve into cells of equal arc length — a natural
geometric criterion. **minimax_chord** solves for the partition that equalizes
the maximum chord-to-curve error across all cells — for `1/(x ln 2)` this is a
closed-form partition with equal spacing in `x^(-1/2)`.

These are the only two curve-aware partitions; all others are curve-agnostic.

Parameters:
- `minimax_chord_x`: `minimax_tol` (default 1e-12)

---

## Group G — Null Model

Baselines and controls.

| Kind | Density | Symmetry | Arithmetic | Description |
|------|---------|----------|------------|-------------|
| `random_x` | quasi-uniform | asymmetric | HiR | Sorted uniform random breakpoints |
| `dyadic_x` | quantized log-uniform | asymmetric | HiR | Geometric targets snapped to dyadic rationals |

**random** is the stochastic null model — no structure, just sorted uniform
draws. **dyadic** quantizes geometric boundaries to the nearest `k/2^R`,
showing what happens when finite-precision hardware constrains log-uniform
spacing.

Parameters:
- `random_x`: `random_seed` (default 42)
- `dyadic_x`: `dyadic_res` (default depth+4)

---

## Equivalences

Two known boundary-array identities:

1. **`minkowski_x` = `stern_brocot_x`** (unconditional) — The inverse
   Minkowski question-mark function maps dyadic rationals to Stern-Brocot
   mediants, producing identical boundary arrays at every depth.

2. **`radical_inverse_x(base=2)` = `uniform_x`** — The van der Corput
   sequence in base 2, when sorted, produces equally-spaced points.

---

## Quick Reference

All 23 partitions in zoo order:

| # | Kind | Display | Color | Group | Density | Arith | Curve-aware |
|---|------|---------|-------|-------|---------|-------|-------------|
| 0 | `uniform_x` | uniform | `#1f77b4` | A | flat | HiR | no |
| 1 | `geometric_x` | geometric | `#9467bd` | A | log-uniform | HiR | no |
| 2 | `harmonic_x` | harmonic | `#2ca02c` | A | left-dense | HiR | no |
| 3 | `mirror_harmonic_x` | mirror-harmonic | `#d62728` | A | right-dense | HiR | no |
| 4 | `ruler_x` | ruler | `#e67e22` | C | fractal | QQ | no |
| 5 | `sinusoidal_x` | sinusoidal | `#17becf` | E | fractal | HiR | no |
| 6 | `chebyshev_x` | chebyshev | `#8c564b` | E | both-endpoints | HiR | no |
| 7 | `thuemorse_x` | thue-morse | `#e377c2` | C | fractal | QQ | no |
| 8 | `bitrev_geometric_x` | bitrev-geometric | `#7f7f7f` | C | fractal | HiR | no |
| 9 | `stern_brocot_x` | stern-brocot | `#bcbd22` | B | rational-dense | QQ | no |
| 10 | `reverse_geometric_x` | reverse-geometric | `#ff7f0e` | A | right-dense | HiR | no |
| 11 | `random_x` | random | `#aec7e8` | G | quasi-uniform | HiR | no |
| 12 | `dyadic_x` | dyadic | `#98df8a` | G | quant-log-uniform | HiR | no |
| 13 | `powerlaw_x` | power-law | `#ff9896` | E | left-dense | HiR | no |
| 14 | `golden_x` | golden | `#c5b0d5` | D | quasi-uniform | HiR | no |
| 15 | `cantor_x` | cantor | `#c49c94` | C | fractal | HiR | no |
| 16 | `minkowski_x` | minkowski | `#e41a1c` | B | rational-dense | QQ | no |
| 17 | `farey_rank_x` | farey-rank | `#377eb8` | B | rational-dense | QQ | no |
| 18 | `radical_inverse_x` | radical-inverse | `#4daf4a` | B | quasi-uniform | HiR | no |
| 19 | `sturmian_x` | sturmian | `#984ea3` | D | quasi-uniform | QQ | no |
| 20 | `beta_x` | beta | `#ff7f00` | E | right-dense | HiR | no |
| 21 | `arc_length_x` | arc-length | `#a65628` | F | left-dense | HiR | yes |
| 22 | `minimax_chord_x` | minimax-chord | `#f781bf` | F | left-dense | HiR | yes |

---

## Grid Presets (summary)

Nine preset grid layouts for comparative visualization. Full specifications
with cell assignments and narratives are in `PLAN.md`.

| Preset | Dims | Fill | Center | Theme |
|--------|------|------|--------|-------|
| `geo_vs_elementary` | 3x3 | full | geometric | Thesis winner vs naive alternatives |
| `geo_vs_number_theory` | 3x3 | full | geometric | Thesis winner vs number-theoretic constructions |
| `geo_vs_chaos` | 3x3 | full | geometric | Thesis winner vs fractal/stochastic perturbations |
| `density_gradient` | 4x4 | full | — | Density centroid migration left-to-right |
| `mathematical_sophistication` | 4x4 | full | — | Rows = increasing mathematical machinery |
| `relational_triangle` | 4x4 | lower triangle | — | 4 anchor philosophies with bridging relationships |
| `symmetry_spine` | 3x3 | lower triangle | — | Symmetric diagonal with symmetry-breaking departures |
| `complete_atlas` | 5x5 | partial | geometric | All 23 partitions in concentric rings |
| `four_pillars` | 4x4 | diagonal | — | 4 fundamental design philosophies |
