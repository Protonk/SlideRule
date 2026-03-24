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
