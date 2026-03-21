# DayLog

Day's 2023 FRSR analysis gives an exact finite candidate set for the
extrema of piecewise-linear coarse approximations to `x^(p/q)`. We study finite-state intercept policies for those approximations and find that the log-linear structure in binary floating point (known since Mitchell 1962) is not just useful but optimal: geometric partitions are the zero-cost baseline under scale symmetry; any departure has measurable structural cost.

We can make that cost concrete by isolating how much error comes from each sharing constraint in the finite-state machine — parameter budget, layer sharing, and automaton coupling. This potentially opens a path to quantitative exchange rates between structural investment and approximation quality.

Our overall and rather brash goal: transform the triangle inequality into a computable measure of the cost of departure from a log-linear surrogate, producing a "computational ruler" for approximation problems governed by scaling.

[`DISTANT-SHORES.md`](DISTANT-SHORES.md): overall science goal and the six-step roadmap, with steps #5 and #6 labeled with [MENEHUNE], indicating the presence of magical helpers are needed to carry the logic forward [ed.: We aren't done yet.].
- `experiments/keystone/KEYSTONE.md` represents the immediate jumping off point from Day (steps 1-4), with `experiments/stepstone/STEPSTONE.md` and `experiments/ripple/RIPPLE.md` aligned with that.
- `experiments/wall/WALL.md` & `experiments/wall/damage/DAMAGE.md` represent the first real foray into [MENEHUNE] #5.

## Terminology

See [`GLOSSARY.md`](GLOSSARY.md).

## Layout

```
experiments/          Runnable sweeps, visualizations, and analysis
  EXPERIMENTS.md        Experiment areas + hypothesis registry
  keystone/             Partition comparison (K1–K3) and thesis
  wall/                 Wall obstruction model and diagnostics
    damage/             Foreign-error analysis (chord sharing counterfactuals)
  alternation/          Sign-pattern analysis
  stepstone/            Chord error structure
  ripple/               Coastline area convergence
lib/                  Shared math modules (paths, day, partitions, ...)
helpers/              Import helper (pathing.py)
tests/                Test suite (run via ./sagew tests/run_tests.sage)
sources/              Reference material
DISTANT-SHORES.md     Six-step roadmap toward the computational ruler
PARTITIONS.md         Partition family classification
GLOSSARY.md           Project terminology
AGENTS.md             How to work here (imports, running, planning)
```
