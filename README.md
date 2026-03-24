# SlideRule

In normal radix-2 scientific notation, each value carries a coarse logarithmic coordinate for free: the exponent gives the binade, and the significand interpolates linearly within it. This gives the pseudo-log `L(x)`, which agrees with `log₂` at powers of two and is affine on each binade. The residual `ε(m) = log₂(1+m) − m` is the exact gap between the logarithmic and affine intra-binade coordinates; the same function reappears as approximation error, grid displacement, and density defect.

We study finite-state correctors that read binary digits and share parameters across cells in order to reduce that gap. In the FSM families we have built, finite sharing leaves a residual wall, and much of its observed structure tracks `ε`. Whether that structure is specific to these machines or intrinsic to a broader class of binary-representation correctors is still open.

The project asks whether there is a genuine computational ruler `d_comp(τ)`: a machine-independent exchange rate between structural cost and approximation quality set by the mismatch between additive/binary and multiplicative/logarithmic coordinates. We are [building the instruments](reckoning/TRAVERSE.md) to find out.

## Terminology

See [`GLOSSARY.md`](reckoning/GLOSSARY.md).

## Layout

```
reckoning/            The intellectual reckoning
  TRAVERSE.md           Seven-step spine: lattice to ruler
  DEPARTURE-POINT.md    Day's framework and the scale-symmetry thesis
  DISTANT-SHORES.md     The destination: d_comp(τ)
  COVERING-GAME.md      Proof program for architecture-invariance
  COMPLEXITY-REEF.md    The complexity question: cost models and lower bounds
  THE-TEST-OF-CHARYBDIS.md  Rotation check: is the wall target-driven or subspace-driven?
  ABYSSAL-DOUBT.md      Four doubts that shadow the program
  HERE-BE-DRAGONS.md    Speculative extensions (pentagonal tiling, duality)
  BINADE-WHITECAPS.md   Coordinate scaffold: ε triple identity
  POINCARE-CURRENTS.md  Displacement field and staircase prediction
  PARTITIONS.md         Partition family classification
  GLOSSARY.md           Project terminology
  REFERENCES.md         Literature
  AGENTS.md             Epistemological guidance for the reckoning
experiments/          Runnable sweeps, visualizations, and analysis
  EXPERIMENTS.md        Experiment areas + hypothesis registry
  keystone/             Partition comparison (K1–K3) and thesis
  wall/                 Wall obstruction model and diagnostics
    damage/             Foreign-error analysis
  tiling/               Displacement field tests and basis identification
  alternation/          Sign-pattern analysis
  stepstone/            Chord error structure
  ripple/               Coastline area convergence
  elementals/           Explanatory figures
lib/                  Shared math modules (paths, day, partitions, ...)
helpers/              Import helper (pathing.py)
tests/                Test suite (run via ./sagew tests/run_tests.sage)
exterior/             Reference implementations (Day sketch, etc.)
sources/              Reference material
AGENTS.md             How to work here (imports, running, planning)
```
