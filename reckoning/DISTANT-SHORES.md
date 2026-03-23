# Distant Shores

The destination: a computational ruler of the exponential.

---

## The computational ruler

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

where the minimum is over correction machinery M and C is the cost
measure. If d_comp is a property of the approximation problem rather
than the implementation, the ruler's tick marks are intrinsic to the
gap between additive and multiplicative coordinates.

The passage to this shore is mapped in [DANGEROUS-SHOALS](DANGEROUS-SHOALS.md).
The full argument is in [TRAVERSE](TRAVERSE.md).

## What the ruler enables

If d_comp exists, the triangle inequality

    |APPROX − log₂| ≤ |APPROX − L| + ε

gives a computable error bound whose second term has a known structural
cost via d_comp. The decomposition is exact: the two terms share no
degrees of freedom. The first is computable (both APPROX and L are
available); the second is ε, known in closed form. The ruler tells you
what it costs to close any fraction of ε.

---

## Summary

| Step | Status | Content |
|------|--------|---------|
| 1 | Done | Day's framework; geometric grid; ε triple identity |
| 2 | [MENEHUNE] | Wall = dist(δ*, S); FSM-specific |
| 3 | Done | Forcing Δ^L = −ε organises c*; architecture-free |
| 4 | [MENEHUNE] | (C, gap) staircase; spectral structure |
| 5 | [MENEHUNE] | Covering game: does structure control cost? |
| 6 | [MENEHUNE] | Coordinate change: geometric ↔ computational |
| 7 | [MENEHUNE] | d_comp(τ): the computational ruler |

See [TRAVERSE](TRAVERSE.md) for the spine,
[DANGEROUS-SHOALS](DANGEROUS-SHOALS.md) for the open frontier.
