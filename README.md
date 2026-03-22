# DayLog

Binary floating point approximates the logarithm via a piecewise-linear surrogate whose error `ε(m) = log₂(1+m) − m` is known and fixed. Any correction architecture processing binary significand bits must absorb this error. We study the structural cost of that absorption and find that ε itself — recast as a representation displacement field — organises the cost at first order, across partition geometries, adversarial constructions, and width-position scrambles.

Day's 2023 FRSR analysis provides the analytical foundation: an exact finite candidate set for the extrema of piecewise-linear coarse approximations to `x^(p/q)`, which gives us exact minimax solutions rather than numerical approximations.

We can make the cost concrete by isolating how much error comes from each sharing constraint in the finite-state machine — parameter budget, layer sharing, and automaton coupling. The displacement field Δ^L = −ε is the forcing function that every binary-representation corrector must respond to. Its shape predicts the exchange rate between structural investment and approximation quality.

Our overall and rather brash goal: transform the triangle inequality into a computable measure of the cost of departure from a log-linear surrogate, producing a "computational ruler" for approximation problems governed by scaling.

- [`DISTANT-SHORES.md`](DISTANT-SHORES.md): six-step roadmap toward the computational ruler.
- `experiments/keystone/KEYSTONE.md`: scale-symmetry thesis and partition comparisons (steps 1–4).
- `experiments/wall/WALL.md`: wall obstruction model, fan-out mechanism, displacement analysis.
- `experiments/tiling/TILING.md`: hyperbolic tiling framework and the displacement field.

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
  tiling/               Displacement field and hyperbolic tiling framework
DISTANT-SHORES.md     Six-step roadmap toward the computational ruler
ABYSSAL-DOUBT.md      Serious doubts about the path
PARTITIONS.md         Partition family classification (26 kinds)
GLOSSARY.md           Project terminology
REFERENCES.md         Literature (Day 2023, Mitchell 1962, and lineage)
AGENTS.md             How to work here (imports, running, planning)
```
