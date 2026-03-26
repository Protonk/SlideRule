# Start-to-Depletion Plan

From fan-out scaling to spectral depletion: what must be true
before the depletion order becomes a well-posed question.

Rationale lives in [FOULING](FOULING.md). This file keeps the
execution order and the short TODO residue.

---

## A. Fan-Out Growth Regime

See [FOULING](FOULING.md) for the bounded / slow-growth /
cell-scale split.

- Measure displacement range `max(c_shared − c_free) - min(...)`
  as a function of depth at fixed `q`, and as a function of `q`
  at fixed depth.
- Run both LI and LD.
- Use the planned `fan_out_scaling` sweep as the main instrument.
- Run alternation split-sequence extensions in parallel only as a
  scout cross-check.

---

## B. Cost-Axis Candidates

See [FOULING](FOULING.md) for the cost-axis problem and the current
candidate list.

- Compute candidate measures on the DEPENDENCE grid
  `q ∈ {5, 7, 9, 11}`, `d = 6–8`.
- Check whether non-monotonicity disappears under any candidate axis.
- If no scalar works, record that explicitly and continue with C.2–C.4.

---

## C. Mod-q Spending Portrait

See [FOULING](FOULING.md) for what the portrait is meant to tell us.

- C.1 Gap frontier at matched cost.
- C.2 Fan-out fraction.
- C.3 Binding-cell migration.
- C.4 Ordering stability.
- If no scalar cost axis survives B, treat C.1 as a multi-axis
  frontier question.
- Use alternation only as a scout on C.4 expectations.

---

## C+. Family-Local vs Calibrator-Compatible

See [FOULING](FOULING.md) for the distinction.

- Treat A, C.2, and LI/LD decomposition claims as family-local.
- Treat B, C.1, C.3, C.4, and the Walsh/Fourier comparison in D as
  calibrator-compatible.

---

## D. Spectral Depletion

See [FOULING](FOULING.md) for the measured Walsh object and the
separate Fourier comparison object.

- Extend the Walsh residual computation across the `(q, d)` grid.
- Track how level-k weights `W^k[r]` change as cost grows.
- Compare the observed Walsh-side depletion order with ε's
  circle-Fourier structure.
- Use alternation only as a scout cross-check on absorption-side
  structure.

---

## E. Early Calibrator: De Caro

See [FOULING](FOULING.md) for why De Caro can provide early
cross-family signal without settling the exact umbrella class.

- Decide whether the Sargassum charter is meant narrowly
  (stateful sequential correctors) or broadly (all one-pass
  binary-digit-reading correctors). Expand only if the narrow
  reading is chosen.
- Implement the abstract De Caro subspace: real-valued piecewise
  polynomials of degree `p` on `T` equal segments of `[0, 1)`,
  evaluated at `2^d` cell centers.
- Run the calibrator-compatible slice on De Caro:
  B, C.1, C.3, C.4, and then D if the Walsh-side object is
  coherent enough to compare.
- If useful, define a De-Caro-native coarse-sharing diagnostic
  analogous to A/C.2 rather than forcing stateful fan-out
  language onto a memoryless family.
- Compare patterns and feed the result back into the sargassum.

---

## Reading outward

- [FOULING](FOULING.md): the stable problem container.
- [EXCHANGE-RATE-PLAN](../wall/EXCHANGE-RATE-PLAN.md) §6: fan-out
  scaling pivot.
- [DEPENDENCE](../wall/DEPENDENCE.md): the non-monotonicity that
  motivates the cost-axis problem.
- [AUTOMATON-SARGASSUM](../../reckoning/AUTOMATON-SARGASSUM.md):
  the rejection loop this plan feeds.
- [CHARYBDIS](../../reckoning/CHARYBDIS.md) §§5–6: Walsh spectral
  results and structured perturbations.
- [ALTERNATION](../aft/alternation/ALTERNATION.md): scout previews
  on displacement-side structure.
