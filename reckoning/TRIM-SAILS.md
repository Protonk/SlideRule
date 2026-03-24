# Trim Sails

Preparation for entering [NARROW-PASSAGE](NARROW-PASSAGE.md)
under the Böröczky constraint. Prompted by Radin, "Orbits of
Orbs" §3.

---

## Constraint

Radin (2004, p. 145) gives a disk packing in the binary tiling of
H² with one disk per tile. After the hyperbolic isometry `z ↦ 6z/5`,
the same packing has two disks per tile. The per-tile count doubles,
but the geometry has not changed. Conclusion: the binary tiling does
not support a `PSL(2,R)`-invariant probability measure on the space
of packings. In this tiling, per-tile bookkeeping is not
isometry-invariant.

Operational rule: in any argument built on the binary tiling, do not
sum, average, or compare quantities across tiles and then treat the
result as invariant under hyperbolic isometries or continuous
rescaling.

---

## Standing Warning

[NARROW-PASSAGE](NARROW-PASSAGE.md) now contains the local caveats it
needs. Keep only this discipline in view when reading or revising it:

- Binade-local and per-tile objects are safe. This includes finite
  fields such as `Δ^L`, per-tile bulge areas `A(k, d)`, and function
  analysis of `ε` on `[0, 1]`.
- The danger begins when those local objects are promoted to global
  claims about the binary tiling.
- In particular, do not treat sums, averages, densities, "total
  curvature", or aggregate bulge area as invariant geometric
  quantities of the tiling.
- If Dragon 1 succeeds, the conclusion is only that `ε` has a
  per-tile geometric derivation. It is not that the binary tiling
  carries a well-defined global curvature.

Generally, when a claim in [NARROW-PASSAGE](NARROW-PASSAGE.md) moves 
from a finite field on one binade or one tile to a global statement 
about the binary tiling, stop and check it against Radin §3.

---

## References

- Radin, C. "[Orbits of Orbs: Sphere Packing Meets Penrose
  Tilings](sources/radin-sphere-packing.pdf)." Amer. Math. Monthly 111 (2004), 137–149.
  Especially §3 (pp. 144–146): the Böröczky paradox and the
  non-existence of invariant measures on binary tiling packings.

- Böröczky, K. "Gömbkitöltések állandó görbületű terekben I."
  Mat. Lapok 25 (1974), 265–306. The disk-doubling construction.

## Reading outward

- [NARROW-PASSAGE](NARROW-PASSAGE.md): the passage this document
  prepares for.
- [HERE-BE-DRAGONS](HERE-BE-DRAGONS.md): Dragons 1, 4 where
  the hazard applies.
- [POINCARE-CURRENTS](POINCARE-CURRENTS.md): the displacement
  field (safe as binade-local).
