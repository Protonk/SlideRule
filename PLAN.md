# PLAN

Activity: Layer dependence size and stability

Question: Are we seeing a real q=3 layer-dependent floor, and how robust is the
current L1c support away from the narrow alpha=1/2 grid?

Design:
- Keep this follow-up empirical and narrow. Do not refactor drivers unless the
  next runs force it.
- First target the q=3 depth story directly:
  - run layer-dependent follow-up points at q=3 for intermediate depths not yet
    tested, at minimum d=5 and d=7
  - keep both `uniform_x` and `geometric_x`
  - keep matching layer-invariant reference rows for interpretation
- Treat the q=3 question as answered only if the near-plateau survives those
  intermediate depths, not just the current sparse set {4, 6, 8}.
- Then add a small robustness check away from alpha=1/2:
  - minimum grid: reuse a shallow and a deeper point, e.g. (q=3, d=4) and
    (q=5, d=6)
  - minimum alpha add-on: alpha=1/3
- Record results in a separate lodestone run directory rather than appending
  into earlier artifacts.
- Update docs cautiously:
  - if the q=3 near-plateau persists, describe it as stronger evidence for a
    q=3 floor
  - if alpha=1/3 preserves L1c, upgrade robustness wording
  - otherwise narrow the claim instead of forcing a broad positive summary
