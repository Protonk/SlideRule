# Alternation

## The idea

When the shared-delta optimizer assigns intercepts to cells, each cell ends
up displaced from its per-cell optimum. The displacement has a sign: the
shared policy pushes the cell's intercept either above (+) or below (-) where
it would freely choose to be. The sequence of signs across cells — reading
left to right through the partition — is the **alternation pattern**.

The alternation pattern is the wall's spatial fingerprint. It tells you how
the sharing constraint organizes its compromises across the domain.

## Why signs, not magnitudes

The magnitude of displacement varies continuously and depends on solver
precision, target exponent, and other parameters. The sign is robust: it changes only
when the shared intercept crosses the free-per-cell intercept. This makes
the sign sequence a topological invariant of the displacement profile — it
survives perturbations of the optimizer output and captures the qualitative
structure of the compromise.

The sign sequence is also maximally discrete: one bit per cell. That
discretization is the source of power. A length-N bitstring can be stored,
compared, compressed, and visualized with tools that don't apply to
continuous profiles.

## What we observe

Empirically, the sign sequences across (kind, q, depth, layer_mode) share
several properties:

1. **High compressibility.** At N=128 cells, most sign sequences have only
   2-10 sign changes. The run-length encoding has 3-11 runs. The sequence
   is overwhelmingly block-structured, not noisy.

2. **Sandwich dominance.** The layer-dependent patterns almost always have
   the form `[-a +b -c]`: a negative block on the left, a large positive
   block in the middle, a negative block on the right. Two sign changes,
   three runs.

3. **LI vs LD contrast.** Layer-invariant patterns have more sign changes
   but are still sparse. The extra changes appear as small intrusions into
   the dominant positive block — the coarse regional compromise develops
   internal inconsistencies as depth grows.

4. **Depth stability.** The run structure is qualitatively stable across
   depths: a 3-run sandwich at d=4 is still a 3-run sandwich at d=7. The
   boundary positions shift, but the number of runs is nearly constant.

## What this means for the wall

The wall is the cost of forcing cells to share intercepts. The alternation
pattern shows *where* that cost concentrates. Cells in the negative-sign
regions at the endpoints are being pushed away from their optima in one
direction; cells in the positive-sign core are pushed the other way. The
sharing constraint is making a spatial bargain: sacrifice the endpoints to
serve the middle.

The compressibility of the pattern says the bargain is simple — the
optimizer is not making N independent compromises, it's making 2-5 regional
deals. That's consistent with the wall decomposition: the dominant source
is layer sharing (a coarse constraint), not automaton coupling (a fine
constraint).
