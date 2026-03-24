# Shakedown

Adversarial review of
[`reckoning/DEPARTURE-POINT.md`](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md)
against
[`reckoning/AGENTS.md`](/Users/achyland/Desktop/Math/smale/reckoning/AGENTS.md),
[`exterior/day/day_sketch.m`](/Users/achyland/Desktop/Math/smale/exterior/day/day_sketch.m),
and pages 1–10 of
[`sources/day_generalize_frsr.pdf`](/Users/achyland/Desktop/Math/smale/sources/day_generalize_frsr.pdf).

Status update, 2026-03-23: the findings below were against the reviewed
version. They have been addressed in the current working copy of
[`reckoning/DEPARTURE-POINT.md`](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md).

## Findings

- [FIXED] High: [reckoning/DEPARTURE-POINT.md:85](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L85) gives the degree-0 minimax relative error as `(ρ^{1/2}−1)/(ρ^{1/2}+1)` while §§1–5 are stated for general `a/b`. Day’s general correction target is `z^{-1/b}` in [sources/day_generalize_frsr.pdf](/Users/achyland/Desktop/Math/smale/sources/day_generalize_frsr.pdf) (pp. 3–8); the `1/2` exponent is only the FRSR case `b=2`, exactly as used in [exterior/day/day_sketch.m:86](/Users/achyland/Desktop/Math/smale/exterior/day/day_sketch.m#L86). As written, §3 silently specializes to reciprocal square root and is incorrect for general `b`.
- [FIXED] High: [reckoning/DEPARTURE-POINT.md:205](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L205) presents a four-layer compatibility theorem that the repo does not actually prove. [experiments/keystone/KEYSTONE.md:29](/Users/achyland/Desktop/Math/smale/experiments/keystone/KEYSTONE.md#L29) explicitly says some of these are explanatory “consistency checks, not tests”, and [experiments/keystone/compatibility_matrix.sage:4](/Users/achyland/Desktop/Math/smale/experiments/keystone/compatibility_matrix.sage#L4) only varies discretization. “Breaking any one layer degrades the cooperation” should be weakened or marked `[MENEHUNE]` under [reckoning/AGENTS.md:7](/Users/achyland/Desktop/Math/smale/reckoning/AGENTS.md#L7).
- [FIXED] High: [reckoning/DEPARTURE-POINT.md:185](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L185) overgeneralizes from normal radix-2 formats to IBM hex and posits. The exact binary claim is fine for normal scientific notation, but Day already notes the bit-pattern story breaks for subnormals in [sources/day_generalize_frsr.pdf](/Users/achyland/Desktop/Math/smale/sources/day_generalize_frsr.pdf) (pp. 2–3). IBM hex gives an analogous base-16 sawtooth, not binary `L`, and [experiments/keystone/float_formats.sage:10](/Users/achyland/Desktop/Math/smale/experiments/keystone/float_formats.sage#L10) uses toy base-2/16/3 examples, not actual IBM or posit encodings.
- [FIXED] Medium: [reckoning/DEPARTURE-POINT.md:170](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L170) is true only if “linear surrogate” means affine in the within-binade coordinate `m` (equivalently affine in `x` on `[1,2]`). Under that class, uniqueness is literal, not “up to affine relatives”: endpoint exactness forces `S(0)=0` and `S(1)=1`, hence `S(m)=m`. If the class is broader, uniqueness fails; the repo’s own [experiments/keystone/surrogacy_test.sage:65](/Users/achyland/Desktop/Math/smale/experiments/keystone/surrogacy_test.sage#L65) includes `2-2/x`, which also vanishes at both boundaries. The follow-on claims about “correction budget” and “binade-local machinery” in [reckoning/DEPARTURE-POINT.md:175](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L175) are not tested by the exhibit and should be `[MENEHUNE]`.
- [FIXED] Medium: [reckoning/DEPARTURE-POINT.md:148](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L148) invokes the multiplicative Cauchy equation without the needed regularity hypotheses. Without continuity, measurability, local boundedness, or monotonicity, non-log pathological solutions exist. The exhibit [experiments/keystone/coordinate_uniqueness.sage:4](/Users/achyland/Desktop/Math/smale/experiments/keystone/coordinate_uniqueness.sage#L4) illustrates one error metric; it does not prove the uniqueness theorem stated in §6. The “equal difficulty / same task” language in [reckoning/DEPARTURE-POINT.md:156](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L156) should be sourced or marked `[MENEHUNE]`.
- [FIXED] Low: [reckoning/DEPARTURE-POINT.md:94](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L94) calls the `X-Y∈ℤ` family “kinks”. In Day’s proof in [sources/day_generalize_frsr.pdf](/Users/achyland/Desktop/Math/smale/sources/day_generalize_frsr.pdf) (pp. 4–6), those are stationary diagonal crossings; H/V are boundary crossings. [reckoning/DEPARTURE-POINT.md:61](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L61) also says the coarse formula “is the FRGR algorithm”, but Day’s Algorithm 2 includes refinement too.

## Section Verdicts

These verdicts apply to the reviewed version above, not to the current
working copy after the fixes.

- `§1` — `(a)` proved by the sources.
- `§2` — `(a)` proved by the sources, but it should say “coarse stage of FRGR”, not the whole algorithm.
- `§3` — `(b)` supported but not proved as written. Day proves `z`, boundedness, and periodicity; the stated degree-0 formula is wrong unless `b=2`.
- `§4` — `(a)` proved by the sources, with the wording fix that D are stationary diagonal crossings, not kinks.
- `§5` — `(a)` proved by the sources.
- `§6` — `(c)` asserted without support from the cited sources. If kept as theorem: require a nonconstant solution plus regularity such as continuity, measurability, or monotonicity. Mark [reckoning/DEPARTURE-POINT.md:156](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L156) `[MENEHUNE]`.
- `§7` — `(b)` supported but not proved. The Chebyshev comparison holds numerically; running [experiments/keystone/surrogacy_test.sage](/Users/achyland/Desktop/Math/smale/experiments/keystone/surrogacy_test.sage) gave `0.086071` for pseudo-log, `0.043036` for Chebyshev, and `-0.043036` at both endpoints. Uniqueness is valid only in the affine-in-`m` class. Mark [reckoning/DEPARTURE-POINT.md:175](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L175) `[MENEHUNE]`.
- `§8` — `(b)` supported but not proved. For normal radix-2 scientific notation, yes; for IBM hex the claim changes base, for subnormals it fails, and the posit/hex examples are not established by the cited sources.
- `§9` — `(c)` asserted without support. Direct experimental support exists only for the discretization layer; coordinate and representation are structural arguments, and the surrogate bullet is presently rhetorical. Mark [reckoning/DEPARTURE-POINT.md:205](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L205) through [reckoning/DEPARTURE-POINT.md:228](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md#L228) `[MENEHUNE]`.

For the four degradation bullets in `§9`: direct experimental support is only for “wrong discretisation”; “wrong coordinate” is a structural argument with an illustrative exhibit; “wrong representation” is structural or illustrative only; “wrong surrogate” is asserted without a matching correction experiment.

---

## POINCARE-CURRENTS Review

Adversarial review of
[`reckoning/POINCARE-CURRENTS.md`](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md)
against
[`reckoning/AGENTS.md`](/Users/achyland/Desktop/Math/smale/reckoning/AGENTS.md),
[`reckoning/BINADE-WHITECAPS.md`](/Users/achyland/Desktop/Math/smale/reckoning/BINADE-WHITECAPS.md),
[`reckoning/DEPARTURE-POINT.md`](/Users/achyland/Desktop/Math/smale/reckoning/DEPARTURE-POINT.md),
[`reckoning/TRAVERSE.md`](/Users/achyland/Desktop/Math/smale/reckoning/TRAVERSE.md),
and
[`reckoning/COMPLEXITY-REEF.md`](/Users/achyland/Desktop/Math/smale/reckoning/COMPLEXITY-REEF.md).

Scope: theoretical content only, `§§1–6`. The experimental section is
not reviewed here.

### Findings

- High: [reckoning/POINCARE-CURRENTS.md:47](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L47), [reckoning/POINCARE-CURRENTS.md:72](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L72), [reckoning/POINCARE-CURRENTS.md:83](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L83), and [reckoning/POINCARE-CURRENTS.md:115](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L115) use incompatible sign conventions. The note defines `Δ^L_k = k/2^d - log₂(1 + k/2^d) = -ε(k/2^d)`, but later describes `Δ^L` as zero at the endpoints, concave, and maximal near `m*`. Those shape claims are true for `ε = |Δ^L|`, not for signed `Δ^L`. As written, the file silently switches from the signed field to its magnitude.
- High: [reckoning/POINCARE-CURRENTS.md:79](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L79), [reckoning/POINCARE-CURRENTS.md:89](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L89), and [reckoning/POINCARE-CURRENTS.md:115](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L115) present the staircase and binding-cell-order claims as theory, but they are not proved here and are not treated elsewhere in the reckoning as settled. [reckoning/TRAVERSE.md:91](/Users/achyland/Desktop/Math/smale/reckoning/TRAVERSE.md#L91) already marks the corresponding step `[MENEHUNE]`. Under [reckoning/AGENTS.md:7](/Users/achyland/Desktop/Math/smale/reckoning/AGENTS.md#L7), `§§4–6` should either be marked `[MENEHUNE]` or rewritten into explicit conditional statements.
- Medium: [reckoning/POINCARE-CURRENTS.md:138](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L138) overstates the spectral claim. [reckoning/BINADE-WHITECAPS.md:177](/Users/achyland/Desktop/Math/smale/reckoning/BINADE-WHITECAPS.md#L177) through [reckoning/BINADE-WHITECAPS.md:221](/Users/achyland/Desktop/Math/smale/reckoning/BINADE-WHITECAPS.md#L221) give the exact Fourier bridge, but “if absorption proceeds by frequency band” is a conditional heuristic, not a theorem, and “the spectral and spatial views ... are dual descriptions of the same absorption ordering” states the hoped-for conclusion too strongly. [reckoning/COMPLEXITY-REEF.md:135](/Users/achyland/Desktop/Math/smale/reckoning/COMPLEXITY-REEF.md#L135) already records this as a prediction rather than an established result.
- Medium: [reckoning/POINCARE-CURRENTS.md:25](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L25) says the binary and geometric partitions “are two coordinate views of the same structure”. That may be good geometric intuition, but in this note it is not stated as a precise theorem with a construction or citation. Under the reckoning rules, either make the structure precise or mark the statement `[MENEHUNE]`.
- Medium: [reckoning/POINCARE-CURRENTS.md:52](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L52) overreaches from an exact representation identity to a computational conclusion. What `§2` proves is that `Δ^L` is representation-determined. “Any architecture that processes binary significand bits must absorb this field” is stronger: it is a claim about admissible correctors, not a theorem established here.
- Low: [reckoning/POINCARE-CURRENTS.md:131](/Users/achyland/Desktop/Math/smale/reckoning/POINCARE-CURRENTS.md#L131) compresses away the coordinate change that matters. The exact relation from [reckoning/BINADE-WHITECAPS.md:190](/Users/achyland/Desktop/Math/smale/reckoning/BINADE-WHITECAPS.md#L190) is `E(t) = -ε(φ(t))`, equivalently `E(ψ(m)) = -ε(m)`, not that `E` is simply the accumulated form of “the same function” on the same variable.

### Section Verdicts

- `§1` — `(b)` supported as geometric context, but not proved as a project theorem in its current form.
- `§2` — `(a)` proved by the existing reckoning. The identity `Δ^L_k = -ε(k/2^d)` is exact.
- `§3` — `(b)` supported but internally inconsistent as written because the distance formula is exact while the shape description uses the wrong sign convention.
- `§4` — `(c)` asserted without support. This is currently a conjectural architecture story, not a theorem.
- `§5` — `(c)` asserted without support. “Ordering invariance” is exactly the kind of computational-language claim that should be marked `[MENEHUNE]` unless proved.
- `§6` — `(b)` supported in part. The exact bridge to the density defect is established in [reckoning/BINADE-WHITECAPS.md](/Users/achyland/Desktop/Math/smale/reckoning/BINADE-WHITECAPS.md), but the absorption-ordering interpretation is conjectural.

### Recommendations

- Fix the sign discipline once and keep it fixed. Either:
  use signed `Δ^L = -ε`, in which case it is negative on `(0,1)`, zero at the endpoints, and has a minimum near `m*`; or
  redefine the staircase driver as `D = |Δ^L| = ε`, and say explicitly that the architecture discussion uses the unsigned magnitude.
- Mark `§§4–6` `[MENEHUNE]` unless the note is cut back to conditional language. A safe narrow replacement is: “If a machine class pays cost in proportion to unresolved displacement magnitude, then `ε` predicts where regime changes are likely to occur.”
- Demote `§1` to clearly labeled geometric context unless a precise theorem is added. The horocyclic/geodesic language is useful, but it is not yet an established project theorem in the present text.
- Replace “must absorb this field” in `§2` with a narrower exact statement, such as: “Any architecture using the same binary representation confronts correction targets indexed by this displacement profile.”
- Rewrite the first sentence of `§6` to preserve the coordinate maps explicitly:
  `E(t) = φ(t) - t = -ε(φ(t))`, hence `E(ψ(m)) = -ε(m)`.
- Keep the spectral paragraph conditional and local. It can say the Fourier bridge provides a possible spectral organization of the same defect, but it should not claim an absorption ordering theorem without a complexity argument.
