# Experiments subdirectory protocol

## When to create a new subdirectory

Create a new subdirectory when a new line of investigation meets all of:

1. Has 3+ scripts or will clearly grow to that.
2. Is topically distinct from existing subdirectories.
3. Produces its own artifacts (CSVs, PNGs, or both).

Otherwise, add scripts to an existing subdirectory.

## Naming conventions

- Directory names are short, singular nouns (e.g. `keystone`, `stepstone`).
- Script names use `snake_case` with a descriptive suffix
  (`_sweep`, `_diagnostic`, `_heatmap`).
- Results go in `<topic>/results/`, never at the `experiments/` root.
- An umbrella topic (like `stepstone/`) may contain subtopics, each with its
  own `results/` directory. The umbrella may also have a top-level `results/`
  for scripts that live at the umbrella root.

## Results layout

Generated artifacts (PNGs, CSVs) never live beside their driver scripts.
Each topic or subtopic that produces output keeps a flat `results/` directory.
File extensions and dated directory names distinguish result types; do not
subdivide `results/` further unless volume genuinely demands it.

## Minimum structure

A new subdirectory should contain at least:

- One runnable `.sage` script.
- A clear `Run:` docstring in each script showing the `./sagew` invocation.

## Sweep reports and run provenance

Dated box-score tables and observations live inside `results/` alongside the
artifacts they describe — not in a central file. To find sweep evidence for a
hypothesis:

1. Look for a `README.md` inside dated run directories
   (e.g. `keystone/results/keystone_2026-03-11/README.md`).
2. Look for topic-level report files in `results/`
   (e.g. `keystone/results/h1_report.md`).
3. For runs whose artifacts exist only in git history, check
   `results/historical.md`.

New sweep runs should follow the same pattern: write a `README.md` in the
run's output directory recording the driver, scope, and direct observations.

## Shared utilities

Before duplicating boilerplate, check whether `zoo_figure.sage`,
`sweep_driver.sage`, or `coastline_series.sage` already provides what you
need. Extend them if a pattern appears in 3+ scripts.
