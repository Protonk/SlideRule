# Damage

## The idea

When cells share a chord approximation to log2, each cell may be forced to
use a chord computed from a different cell. The **foreign-error matrix**
`E[j][k]` measures the peak error on cell k when using cell j's chord instead
of its own. The diagonal `E[k][k]` is the native chord error.

The **amplification factor** `R[j][k] = E[j][k] / E[k][k]` says how much
worse cell k gets when using a foreign chord. If `R` is near 1 everywhere,
the partition is robust to chord sharing. If `R` flares on certain cells,
those cells are fragile — they are disproportionately harmed by the sharing
constraint.

The **balance ratio** asks: for each cell, is it a net exporter (its chord
damages others more than foreign chords damage it) or a net importer? The
spatial pattern of exporters and importers reveals the geometry of the
sharing compromise.

---

## Scripts

### Shared helper

`_foreign_error.sage` — builds the error matrix `E[j][k]` and provides
`build_error_matrix(cells)`, `cell_chord(a, b)`, and the amplification
factor infrastructure. Loaded by the visualization scripts.

### Visualizations

| Script | Output | Description |
|--------|--------|-------------|
| `counter_factual.sage` | `results/counter_factual.png` | Damage ribbons: per-cell incoming vs exported error for 16 partition kinds |
| `amplification.sage` | `results/amplification.png` | Amplification ribbons: median excess `R - 1` for incoming and exported, across the zoo |
| `amplification_polar.sage` | `results/amplification_polar.png` | Same data in polar coordinates (m mapped to theta), 4x5 grid |
| `balance_linear.sage` | `results/balance_ratio_linear.png` | Balance ratio `exp / (exp + inc)` per cell, linear layout, 4x5 grid |
| `balance_polar.sage` | `results/balance_ratio.png`, `results/log_ratio.png` | Balance ratio and log-ratio in polar coordinates |
| `balance_summary.sage` | `results/balance_summary.csv` | Five-scalar summary per partition: crossings, area above/below, share above/below |
| `balance_scatter.sage` | `results/balance_scatter.png` | Territory vs intensity scatter from balance_summary.csv |
| `balance_bars.sage` | `results/balance_bars.png` | Diagonal residual bar chart ranked by balance projection |
| `balance_bars_anti.sage` | `results/balance_bars_anti.png` | Anti-diagonal residual bar chart: loud vs quiet damage economies |

Run any of them with `./sagew experiments/damage/<script>`.

### Dependency order

`balance_summary.sage` must be run first to produce `balance_summary.csv`,
which is consumed by `balance_scatter.sage`, `balance_bars.sage`, and
`balance_bars_anti.sage`. The other scripts are independent.

---

## Data flow

```
lib/partitions.sage (cell boundaries)
  +-- _foreign_error.sage (error matrix E[j][k])
       |-- counter_factual.sage   --> results/counter_factual.png
       |-- amplification.sage     --> results/amplification.png
       |-- amplification_polar.sage -> results/amplification_polar.png
       |-- balance_linear.sage    --> results/balance_ratio_linear.png
       |-- balance_polar.sage     --> results/balance_ratio.png
       |                              results/log_ratio.png
       +-- balance_summary.sage   --> results/balance_summary.csv
            |-- balance_scatter.sage  --> results/balance_scatter.png
            |-- balance_bars.sage     --> results/balance_bars.png
            +-- balance_bars_anti.sage--> results/balance_bars_anti.png
```

---

## Key findings

### Geometric is robust to chord sharing

On geometric partitions, the amplification ribbon is roughly flat — all cells
are equally vulnerable to foreign chords. On uniform partitions, the ribbon
flares near x=1, where cells have tiny native errors and are proportionally
most sensitive to chord displacement.

### Balance reveals spatial structure

The balance ratio is not spatially uniform for any partition. Net exporters
tend to cluster in regions where the chord slope deviates most from the
continuous slope. The scatter plot of territory (fraction of domain that is
net-exporting) vs intensity (excess error concentration) separates partitions
into distinct structural classes.

### Farey-rank and stern-brocot are structurally complex

These partitions have the highest crossing counts (sign changes in the
balance ratio), reflecting their fine internal structure under the sharing
constraint — consistent with their high run counts in the alternation
analysis.
