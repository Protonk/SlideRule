# SlideRule

Every floating-point number carries a coarse logarithm for free. The integer part of the IEEE 754 bit pattern counts powers of two; the fractional part interpolates linearly between them. Together they give the pseudo-log L(x), which agrees with log₂ at every power of two and is affine between. The gap ε(m) = log₂(1+m) − m is what this surrogate costs you: smooth, concave, zero at the binade boundaries, and the same function whether you read it as an approximation error, a grid displacement, or a departure from the reciprocal distribution.

We built finite-state machines that read binary digits and try to close this gap by sharing correction parameters across cells of the domain. The sharing is what makes them small; it is also what prevents them from being exact. The persistent residual — the wall — does not vanish as the machines grow, and its structure is organised by ε itself. The displacement field Δ^L = −ε acts as a forcing function: it determines, at first order, the shape of the optimal correction field across the partition zoo, including adversarial constructions designed to break the pattern. The shape of the disease governs the cost of the cure.

The forcing predicts a staircase in the exchange rate between structural cost and approximation quality: boundary cells are cheap, peak cells must be absorbed in clusters, and the binding cell advances in discrete jumps whose locations are set by ε. The Fourier decomposition of the density defect gives a spectral view of the same ordering. Whether this staircase is a property of the FSM or of any binary-representation corrector is the open question.

If it is intrinsic, there exists a computational ruler d_comp(τ) — the minimum structural cost to achieve tolerance τ — whose tick marks are set by the gap between additive and multiplicative coordinates and do not depend on the machine you use to close it. We are [building the instruments](reckoning/TRAVERSE.md) to find out.

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
