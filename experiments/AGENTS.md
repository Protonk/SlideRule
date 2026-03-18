# Experiments subdirectory protocol

## When to create a new subdirectory

Create a new subdirectory when a new line of investigation meets all of:

1. Has 3+ scripts or will clearly grow to that.
2. Is topically distinct from existing subdirectories.
3. Produces its own artifacts (CSVs, PNGs, or both).

Otherwise, add scripts to an existing subdirectory.

## Naming conventions

- Directory names are short, singular nouns (e.g. `lodestone`, `stepstone`).
- Script names use `snake_case` with a descriptive suffix
  (`_sweep`, `_diagnostic`, `_heatmap`).
- Results go in `<topic>/results/`, never at the `experiments/` root.

## Minimum structure

A new subdirectory should contain at least:

- One runnable `.sage` script.
- A clear `Run:` docstring in each script showing the `./sagew` invocation.

## Shared utilities

Before duplicating boilerplate, check whether `zoo_figure.sage` or
`sweep_driver.sage` already provides what you need. Extend them if a
pattern appears in 3+ scripts.
