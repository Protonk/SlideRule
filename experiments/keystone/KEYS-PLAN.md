Purpose: transient execution tracker for establishing repo support for Keystone thesis sections 1-4 and for queuing the downstream wall follow-through those sections motivate
Canonical for: in-flight support criteria, weakening criteria, literature-binding tasks, and the near-term keys-to-wall execution order
Not for: durable thesis prose, final hypothesis claims, or run logs that should live in results/

# Keys Plan

Temporary planning file. Keep execution state here while the keys work is in
flight, then dissolve it once the durable `KEYSTONE.md` sections are backed by
artifacts and literature linkage. This file now absorbs the remaining active
content from the old cross-cutting `WALLS-AND-KEYS-PLAN.md`.

## Current status

Done without Sage:

- [x] Created this transient tracker.
- [x] Added `Repo Support`, `Status`, and `Literature Linkage` stubs under
  `KEYSTONE.md` sections 1-4.
- [x] Aligned numbering: KEYSTONE.md now uses §1 coordinate, §2 surrogate,
  §3 representation, §4 compatibility — matching the strategic plan.
- [x] Migrated the still-needed content out of `WALLS-AND-KEYS-PLAN.md`
  into this file.

Still pending on implementation and/or Sage follow-through:

- [ ] `coordinate_uniqueness.sage`
- [ ] `surrogacy_test.sage`
- [ ] `float_formats.sage`
- [ ] `compatibility_matrix.sage`
- [ ] run artifacts for each of the above
- [ ] literature search and binding pass for each section
- [ ] downstream wall scripts and wall-local runs

## Doc discipline

### Durable doc landing pattern

As each Keystone section gets real support, the durable shape in
`KEYSTONE.md` should remain:

- `Repo Support`
- `Status`
- `Literature Linkage`

Do not move this whole tracker into durable docs. Only the stable summary
belongs there.

### Literature-binding discipline

Keystone §§1-4 are not just internal claims to prove or exhibit. They also
have antecedents in the literature, and the repo should bind those antecedents
to the specific mechanism argued here.

Each section's `Literature Linkage` block should eventually answer:

- what outside proof, demonstration, or lineage exists
- how that overlaps exactly with the repo's claim
- what mechanism or explanatory step the repo adds
- where the literature stops short of the repo's framing

## Keys claim tracker

| § | Claim | Support type | Owning artifact | Status | Support criterion | Weakening criterion | Literature task | Doc destination |
|---|-------|-------------|-----------------|--------|-------------------|--------------------|-----------------|--------------------|
| 1 | Log is the unique coordinate linearizing scaling | Mixed | `coordinate_uniqueness.sage` | Scaffolded | Equal-log-width cells flatten difficulty; linear cells do not | Comparison does not materially separate difficulty profiles | Find prior functional-equation proofs; state overlap | KEYSTONE.md §1 |
| 2 | Pseudo-log surrogacy explained by scale equivariance | Experimental | `surrogacy_test.sage` | Scaffolded | Pseudo-log residual is the one geometric cells equalize, despite not being the best raw fit | Comparison reduces to plain best-fit ranking without isolating symmetry | Find prior pseudo-log / FISR treatments; distinguish from repo mechanism | KEYSTONE.md §2 |
| 3 | Binary scientific notation gives the pseudo-log structurally | Mixed | `float_formats.sage` | Scaffolded | Binary binades produce pseudo-log affine in log2; other bases do not | Script compares formats loosely without isolating binade/significand mechanism | Find prior significand-as-log treatments; note where repo generalizes | KEYSTONE.md §3 |
| 4 | Coordinate, surrogate, representation, discretization are jointly compatible | Experimental | `compatibility_matrix.sage` | Scaffolded | All-right combination is distinctly better; each broken layer has characteristic failure mode | Matrix shows rankings without clarifying which broken layer caused which failure | Find adjacent matched-layers literature; explain repo's formulation | KEYSTONE.md §4 |

## Keys follow-through

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

## Downstream wall queue

The wall work is downstream of the keys work: it localizes, attributes, and
scales the obstruction once the upstream keystone premises have repo support.

### Seed inventory to reuse

- `experiments/keystone/results/wall_surface_2026-03-18/`
- `experiments/keystone/results/partition_2026-03-18/`
- `experiments/keystone/results/h1a_gap_vs_q.csv`
- `experiments/keystone/results/h1b_depth_scaling.csv`
- `experiments/keystone/results/h1c_layer_dependent.csv`
- `experiments/alternation/`

### Wall-local code queue

- [ ] `experiments/wall/join_layer_modes.sage`
- [ ] `experiments/wall/collect_wall_sweep.sage`
- [ ] `experiments/wall/worst_cell_map.sage`
- [ ] `experiments/wall/wall_excess_ribbons.sage`
- [ ] `experiments/wall/gap_collapse.sage`
- [ ] `experiments/wall/candidate_phase_barcode.sage`

### Wall experiments to preserve

- [ ] E1. Worst-cell migration
- [ ] E2. Per-cell wall budget
- [ ] E3. Residual layer-dependent wall vs `q` and exponent
- [ ] E4. Parameter-to-cell ratio collapse
- [ ] E5. Alternation-to-wall correlation

### Recommended order after the keys artifacts begin to land

1. `coordinate_uniqueness.sage`
2. `surrogacy_test.sage`
3. `float_formats.sage`
4. `compatibility_matrix.sage`
5. Update `KEYSTONE.md` after each artifact with the output path and finding.
6. `experiments/wall/join_layer_modes.sage`
7. `experiments/wall/worst_cell_map.sage`
8. `experiments/wall/wall_excess_ribbons.sage`
9. non-`1/2` exponent wall sweep for E3
10. `experiments/wall/gap_collapse.sage`
11. E5 alternation-to-wall correlation

## Exit condition

This file can be dissolved when:

- each Keystone section has a concrete repo artifact
- each Keystone section has stable support language in `KEYSTONE.md`
- each Keystone section has at least a first-pass literature linkage
- the downstream wall queue has either been completed or migrated into a
  wall-local transient plan
