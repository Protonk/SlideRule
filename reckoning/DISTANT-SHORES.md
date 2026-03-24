# Distant Shores

The destination: a computational ruler of the exponential that rules out algebraicity. 

---

## The computational ruler

    d_comp(τ) = min { C(M) : M produces |APPROX_M − log₂| ≤ τ }

where the minimum is over correction machinery M and C is the cost
measure. If d_comp is a property of the approximation problem rather
than the implementation, the ruler's tick marks are intrinsic to the
gap between additive and multiplicative coordinates.

The full argument is in [TRAVERSE](TRAVERSE.md). The complexity
question is in [COMPLEXITY-REEF](COMPLEXITY-REEF.md).

## What the ruler enables

Let L(x) be the affine pseudo-log, APPROX(x) any piecewise approximation to
log₂(x), and ε(m) = log₂(1+m) − m the departure of truth from surrogate on
the unit mantissa interval. If d_comp exists, the triangle inequality gives

    |APPROX − log₂| ≤ |APPROX − L| + ε

This decomposes the inaccessible comparison (APPROX vs. truth) into a comparison (APPROX vs. surrogate) with a computable error bound whose second term has a known structural cost via d_comp.

The decomposition is exact: the two terms share no degrees of freedom. The first is computable (both APPROX and L are available); the second is ε, known in closed form. The ruler tells you
what it costs to close any fraction of ε.

## Why

[Schanuel's conjecture](https://en.wikipedia.org/wiki/Schanuel%27s_conjecture) is open. Schanuel says the exponential is as algebraically independent from the rationals as it could possibly be. Full stop, maximally independent.

ε(m) = log₂(1+m) − m is the displacement between the additive and multiplicative structures of ℝ_{>0}, sampled on the dyadic grid. If the rate-distortion curve for binary approximation of x^{p/q} shows that the cost of closing the gap never terminates — that every finite resource budget leaves a residual controlled by ε, and ε cannot be annihilated by any finite algebraic process on the bits — that is a statement about the algebraic independence of the exponential, arrived at through computation rather than through algebraic number theory.

A machine that could close the gap with finite resources could provide a counterexample. The geometry obtains the structure of the tiling. The measure theory defines ε as a canonical object. Computational complexity proves the impossibility.

---

See [TRAVERSE](TRAVERSE.md) for the spine.
