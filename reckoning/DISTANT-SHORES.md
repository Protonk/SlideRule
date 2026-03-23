# Distant Shores

The destination: a computable measure of the structural cost of departing
from a log-linear surrogate.

---

## The computational ruler

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

where the minimum is over correction machinery M (FSMs, lookup tables,
polynomial evaluators, or anything else) and C is the cost measure.

This is the minimum structural cost to achieve tolerance τ in departure
from L, measured not in error magnitude but in the machinery required to
produce corrections beyond what L provides for free.

The forcing function Δ^L is architecture-free — a property of c*, not of
any particular corrector. If d_comp is a property of the approximation
problem rather than the implementation, the ruler's tick marks are
intrinsic to the gap between additive and multiplicative coordinates.

The passage to this shore is mapped in [DANGEROUS-SHOALS](DANGEROUS-SHOALS.md).
The full argument is in [TRAVERSE](TRAVERSE.md).

---

## Summary

| Step | Status | Content |
|------|--------|---------|
| 1 | Done | Triangle inequality; APPROX−L computable, ε known |
| 2 | Done | Geometric grid = zero-cost baseline; ε triple identity |
| 3 | [MENEHUNE] | FSM corrections ∈ low-rank subspace S (architecture-specific) |
| 4 | [MENEHUNE] | Wall = dist(δ*, S); decomposition describes FSM sharing |
| 5 | Forcing known; rate [MENEHUNE] | (C, gap) curve governed by Δ^L = −ε |
| 6 | [MENEHUNE] | d_comp(τ) architecture-invariant → computational ruler |

See [TRAVERSE](TRAVERSE.md) for the spine,
[DANGEROUS-SHOALS](DANGEROUS-SHOALS.md) for the open frontier.
