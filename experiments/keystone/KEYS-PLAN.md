Purpose: transient execution tracker for establishing repo support for Keystone thesis sections 1-4
Canonical for: in-flight support criteria, weakening criteria, and literature-binding tasks for the keys front
Not for: durable thesis prose, final hypothesis claims, or run logs that should live in results/

# Keys Plan

Temporary planning file. Keep execution state here while the keys work is in
flight, then dissolve it once the durable `KEYSTONE.md` sections are backed by
artifacts and literature linkage.

## Current status

Done without Sage:

- [x] Created this transient tracker.
- [x] Added `Repo Support`, `Status`, and `Literature Linkage` stubs under
  `KEYSTONE.md` sections 1-4.
- [x] Aligned numbering: KEYSTONE.md now uses §1 coordinate, §2 surrogate,
  §3 representation, §4 compatibility — matching the strategic plan.

Still pending on implementation and/or Sage follow-through:

- [ ] `coordinate_uniqueness.sage`
- [ ] `surrogacy_test.sage`
- [ ] `float_formats.sage`
- [ ] `compatibility_matrix.sage`
- [ ] run artifacts for each of the above
- [ ] literature search and binding pass for each section

## Claim tracker

| § | Claim | Support type | Owning artifact | Status | Support criterion | Weakening criterion | Literature task | Doc destination |
|---|-------|-------------|-----------------|--------|-------------------|--------------------|-----------------|--------------------|
| 1 | Log is the unique coordinate linearizing scaling | Mixed | `coordinate_uniqueness.sage` | Scaffolded | Equal-log-width cells flatten difficulty; linear cells do not | Comparison does not materially separate difficulty profiles | Find prior functional-equation proofs; state overlap | KEYSTONE.md §1 |
| 2 | Pseudo-log surrogacy explained by scale equivariance | Experimental | `surrogacy_test.sage` | Scaffolded | Pseudo-log residual is the one geometric cells equalize, despite not being the best raw fit | Comparison reduces to plain best-fit ranking without isolating symmetry | Find prior pseudo-log / FISR treatments; distinguish from repo mechanism | KEYSTONE.md §2 |
| 3 | Binary scientific notation gives the pseudo-log structurally | Mixed | `float_formats.sage` | Scaffolded | Binary binades produce pseudo-log affine in log2; other bases do not | Script compares formats loosely without isolating binade/significand mechanism | Find prior significand-as-log treatments; note where repo generalizes | KEYSTONE.md §3 |
| 4 | Coordinate, surrogate, representation, discretization are jointly compatible | Experimental | `compatibility_matrix.sage` | Scaffolded | All-right combination is distinctly better; each broken layer has characteristic failure mode | Matrix shows rankings without clarifying which broken layer caused which failure | Find adjacent matched-layers literature; explain repo's formulation | KEYSTONE.md §4 |

## Per-section follow-through

### §1. The coordinate

- [ ] implement `coordinate_uniqueness.sage`
- [ ] decide whether a short proof note is needed alongside the visualization
- [ ] run it via `./sagew`
- [ ] write the produced artifact path into `KEYSTONE.md` §1
- [ ] perform the literature-binding pass for §1

### §2. The surrogate

- [ ] implement `surrogacy_test.sage`
- [ ] run it via `./sagew`
- [ ] write the produced artifact path into `KEYSTONE.md` §2
- [ ] perform the literature-binding pass for §2

### §3. The representation

- [ ] implement `float_formats.sage`
- [ ] add a brief explanatory note if the script alone is too implicit
- [ ] run it via `./sagew`
- [ ] write the produced artifact path into `KEYSTONE.md` §3
- [ ] perform the literature-binding pass for §3

### §4. Compatibility

- [ ] implement `compatibility_matrix.sage`
- [ ] run it via `./sagew`
- [ ] write the produced artifact path into `KEYSTONE.md` §4
- [ ] perform the literature-binding pass for §4

## Exit condition

This file can be dissolved when:

- each Keystone section has a concrete repo artifact
- each Keystone section has stable support language in `KEYSTONE.md`
- each Keystone section has at least a first-pass literature linkage
- the remaining work is only iterative refinement, not execution tracking
