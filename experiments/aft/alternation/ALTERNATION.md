# Alternation

## The idea

When the shared-delta optimizer assigns intercepts to cells, each cell ends
up displaced from its per-cell optimum. The displacement has a sign: the
shared policy pushes the cell's intercept either above (+) or below (-) where
it would freely choose to be. The sequence of signs across cells — reading
left to right through the partition — is the **alternation pattern**.

The alternation pattern is the wall's spatial fingerprint. It tells you how
the sharing constraint organizes its compromises across the domain.

### Why signs, not magnitudes

The magnitude of displacement varies continuously and depends on solver
precision, target exponent, and other parameters. The sign is robust: it
changes only when the shared intercept crosses the free-per-cell intercept.
This makes the sign sequence a topological invariant of the displacement
profile — it survives perturbations of the optimizer output and captures the
qualitative structure of the compromise.

The sign sequence is also maximally discrete: one bit per cell. A length-N
bitstring can be stored, compared, compressed, and visualized with tools that
don't apply to continuous profiles.

### What we observe

Empirically, the sign sequences across (kind, q, depth, layer_mode) share
several properties:

1. **High compressibility.** At N=128 cells, most sign sequences have only
   2-10 sign changes. The RLE has 3-11 runs. The sequence is overwhelmingly
   block-structured, not noisy.

2. **Sandwich dominance.** The layer-dependent patterns almost always have
   the form `[-a +b -c]`: a negative block on the left, a large positive
   block in the middle, a negative block on the right.

3. **LI vs LD contrast.** Layer-invariant patterns have more sign changes
   but are still sparse. The extra changes appear as small intrusions into
   the dominant positive block as depth grows.

4. **Depth stability.** The run structure is qualitatively stable across
   depths: a 3-run sandwich at d=4 is still a 3-run sandwich at d=7.

---

## Scripts

### Top-level visualizations

All visualization scripts read from the keystone percell CSV
(`../keystone/results/wall_surface_2026-03-18/percell.csv`) and
load `sign_sequences.sage` as a shared helper.

| Script | Output | Description |
|--------|--------|-------------|
| `barcode_stack.sage` | `results/barcode_stack.png` | Depth-stacked barcode strips for 4 partition kinds, LI vs LD columns |
| `rle_ribbons.sage` | `results/rle_ribbons.png` | Run-length ribbons with spatial widths and cell-count annotations |
| `zoo_barcode.sage` | `results/zoo_barcode.png` | All 22 partition kinds at one depth, single column; computes on the fly via `compute_case` |

Run any of them with `./sagew experiments/aft/alternation/<script>`.

### Shared helper

`sign_sequences.sage` — loaded by the visualization scripts. Provides:

- `extract_signs(rows, kind, q, depth, exponent, ld)` — sign extraction from percell CSV rows
- `signs_only(sign_entries)` — extract just the sign values
- `sign_rle(signs)` — run-length encoding
- `transition_positions(sign_entries)` — x values where sign changes
- `refinement_splits(signs_d, signs_d1)` — parent indices where children disagree

### Refinement subdirectory

`refinement/` contains the split-sequence computation pipeline: dedicated
sign computation with caching, the split-sequence calculator, and a parallel
zoo-wide sweep.

| Script | Description |
|--------|-------------|
| `compute_signs.sage` | Shared helper. Calls `optimize_minimax` directly, reuses its cell-free-intercept map, caches results to JSONL |
| `split_sequence.sage` | Computes the split digit sequence for one partition kind across a depth range |
| `split_map.sage` | Visualization: where do new sign boundaries appear at each depth transition |
| `zoo_split_sequences.sage` | Parallel launcher: computes split sequences for all 22 partition kinds |
| `zoo_worker.sage` | Subprocess worker invoked by `zoo_split_sequences.sage` |

Run the zoo sweep: `./sagew experiments/aft/alternation/refinement/zoo_split_sequences.sage`

Configuration (edit at the top of each script): `Q`, `MAX_DEPTH`,
`LAYER_DEPENDENT`, `MAX_WORKERS`.

---

## Data flow

```
keystone percell CSV
  └─ sign_sequences.sage (extract from CSV)
       ├─ barcode_stack.sage ──► results/barcode_stack.png
       ├─ rle_ribbons.sage   ──► results/rle_ribbons.png
       └─ split_map.sage     ──► refinement/results/split_map.png

optimize_minimax (called directly)
  └─ compute_signs.sage (compute + cache)
       ├─ split_sequence.sage      ──► stdout + JSONL cache
       └─ zoo_split_sequences.sage ──► refinement/results/zoo_split_sequences.csv
            └─ zoo_worker.sage (subprocess per kind)

zoo_barcode.sage (standalone, calls compute_case)
  └─ results/zoo_barcode.png
```

---

## Cache layout

`refinement/results/<kind>/q<q>_<ld>_tol<tol>_db<db>.jsonl`

Each line in the JSONL file is one depth's sign data. To extend to a deeper
depth, the script appends a line. Existing depths are never recomputed.

Cache key components: kind, q, layer_dependent, tol, dyadic_bits,
solver_version. Different solver settings produce separate files.

Example: `refinement/results/uniform_x/q3_LI_tol1e-10_db20.jsonl` contains
one line per depth (currently depths 3-13).

---

## Key findings

### Split sequence: refinement digit table

The split sequence `1.AAAA...` encodes how many parent cells see their
children disagree in sign at each depth transition d→d+1. Computed at
q=3, LI, exponent=1/2, tol=1e-10, dyadic_bits=20.

| Kind | Sequence (4 digits) | Runs at d=7 |
|------|--------------------:|------------:|
| uniform | 1.0244 | 9 |
| geometric | 1.1120 | 2 |
| harmonic | 1.2110 | 2 |
| mirror-harmonic | 1.2215 | 11 |
| ruler | 1.0254 | 7 |
| sinusoidal | 1.1321 | 3 |
| chebyshev | 1.1000 | 2 |
| thue-morse | 1.0223 | 7 |
| bitrev-geometric | 1.1213 | 7 |
| stern-brocot | 1.1348 | 25 |
| reverse-geometric | 1.0142 | 9 |
| random | 1.1021 | 2 |
| dyadic | 1.1120 | 2 |
| power-law | 1.2100 | 2 |
| golden | 1.1631 | 3 |
| cantor | 1.2111 | 2 |
| farey-rank | 1.18313 | 29 |
| radical-inverse | 1.0244 | 9 |
| sturmian | 1.0112 | 5 |
| beta | 1.1237 | 17 |
| arc-length | 1.1200 | 2 |
| minimax-chord | 1.1010 | 2 |

### Identical pairs

Two pairs produce the same sign sequence (and therefore the same split
digits) at every depth tested:

- **uniform = radical-inverse** (1.0244) — radical-inverse in base 2
  produces uniform boundaries after sorting; this is a known equivalence.
- **geometric = dyadic** (1.1120) — dyadic snaps geometric targets to
  dyadic rationals, but the sign structure is unchanged.

### Extended sequence for uniform

Computed to depth 13 (10 digits): **1.0244003115**

Split counts: [0, 2, 4, 4, 0, 0, 3, 1, 1, 5]. The splits are not monotone —
there is a burst at d=5-7, then quiet at d=8-9, then new activity at d=10+.

### Outlier: farey-rank

Farey-rank is the only partition with a split count exceeding 9 (13 splits at
d=6→7), giving 5 characters in one digit position (1.1**8**3**13**). It also
has the highest run count at d=7 (29 runs). This partition has unusually fine
internal structure under the sharing constraint.
