# References

## Departure Point

Matula, D. W. (1970). A formalization of floating-point numeric base
conversion. *IEEE Transactions on Computers*, C-19(8), 681–692.

Day, M. (2023). Generalising the fast reciprocal square root algorithm.
arXiv:2307.15600. https://arxiv.org/abs/2307.15600

## Lineage

Mitchell, J. N., Jr. (1962). Computer multiplication and division using
binary logarithms. *IRE Transactions on Electronic Computers*,
EC-11(4), 512–517.

Gustafsson, O., & Hellman, N. (2021). Approximate floating-point
operations with integer units by processing in the logarithmic domain.
In *Proc. IEEE 28th Symposium on Computer Arithmetic (ARITH)*,
96–103. https://doi.org/10.1109/ARITH51176.2021.00019

## Piecewise-linear correction lineage

Combet, M., Van Zonneveld, H., & Verbeek, L. (1965). Computation of
the base two logarithm of binary numbers. *IEEE Transactions on
Electronic Computers*, EC-14(6), 863–867.

Marino, D. (1972). New algorithms for the approximate evaluation in
hardware of binary logarithms and elementary functions. *IEEE
Transactions on Computers*, C-21(12), 1416–1421.

Degryse, D., & Guerin, B. (1972). A logarithmic transcoder. *IEEE
Transactions on Computers*, C-21(11), 1165–1168.

## Alternatives

De Caro, D., Napoli, E., Esposito, D., Castellano, G., Petra, N., &
Strollo, A. G. M. (2017). Minimizing coefficients wordlength for
piecewise-polynomial hardware function evaluation with exact or
faithful rounding. *IEEE Transactions on Circuits and Systems I:
Regular Papers*, 64(5), 1187–1200.
https://doi.org/10.1109/TCSI.2016.2629850

## Test of Charybdis

O'Donnell, R. (2014). *Analysis of Boolean Functions*. Cambridge
University Press.

Vershynin, R. (2026). *High-Dimensional Probability: An Introduction
with Applications in Data Science*. 2nd ed. Cambridge University Press.

## Binade Whitecaps

Sripad, A. B., & Snyder, D. L. (1978). Quantization errors in floating-point arithmetic. *IEEE Trans. Acoustics, Speech, and Signal Processing*, ASSP-26(5), 456–463.

> Core result: Proposition 2 (§II). The mantissa has the reciprocal density 1/(m ln 2) iff φ(2πn) = 0 for all nonzero integers n, where φ is the characteristic function of log₂|X|. Remark 2 gives the sufficient form: band-limited with |φ(u)| = 0 for |u| ≥ 2π. The Gaussian case (§III, eqs. 24–27) evaluates φ(2πn) through the Gamma function on Re(s) = ½, yielding max relative departure 0.23% independent of σ (eq. 30). Proposition 1 gives the general Fourier series for the mantissa density when the condition fails.

Lacroix, A., & Hartwig, F. (1992). Distribution densities of the mantissa and exponent of floating point numbers. In *Proc. IEEE International Symposium on Circuits and Systems*, 1792–1795.

> Key result: §IV ("Independency and Continuity"). Derives a continuity condition at dyad boundaries: the conditional mantissa CDF must satisfy a boundary-matching relation involving p_β(j)/p_β(j+1). For the reciprocal density this holds exactly (statistical independence of mantissa and exponent); for any other density it fails, producing a discontinuity that couples mantissa to exponent. §III shows a single sum of uniform operands gives a triangular mantissa density misaligned with dyad boundaries; two multiplications suffice for near-reciprocal convergence.

Miller, S. J., & Nigrini, M. J. (2007). The modulo 1 central limit theorem and Benford's law for products. arXiv:math/0607686v2.

> Core result: Theorem 1.1 (§2). The sum of M independent continuous RVs mod 1 converges to uniform in L¹ iff for each n ≠ 0, the product ĝ₁(n)···ĝ_M(n) → 0 as M → ∞. Theorem 1.2 translates to Benford's law for products. Convergence rate is controlled by max_m |ĝ_m(n)|: strictly < 1 for each n gives geometric decay in M. Example 2.4 constructs a sequence where individual convergence holds but the non-identical product does not.

## Binary tiling

Radin, C. "[Orbits of Orbs: Sphere Packing Meets Penrose Tilings](sources/radin-sphere-packing.pdf)." Amer. Math. Monthly 111 (2004), 137–149. Especially §3 (pp. 144–146): the Böröczky paradox and the non-existence of invariant measures on binary tiling packings.

Böröczky, K. "Gömbkitöltések állandó görbületű terekben I." Mat. Lapok 25 (1974), 265–306. The disk-doubling construction.
