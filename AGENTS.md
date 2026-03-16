# How to work here

> Logistical guidance lives here, see `LODESTONE.md` for mathematical direction

## Task -> Document

- Repo orientation -> `README.md`
- Guiding thesis / scientific north star -> `LODESTONE.md`
- Active research claims/status -> `HYPOTHESES.md`
- Current obstruction / wall diagnostics -> `WALL.md`
- Sweep findings and dated empirical summaries -> `SWEEP-REPORTS.md`
- Experiment usage and output interpretation -> `experiments/README.md`
- Library/module structure and numerical caveats -> `lib/README.md`
- Immediate next work -> `PLAN.md` or `SUBJECT-PLAN.md`
- Latest work-cycle handoff -> `REPORT.md`

### PLANning

Processes which change the repo state should be recorded in temporary `PLAN.md`
files, local to the activity being planned. Prefer these files (or an
equivalent `SUBJECT-PLAN.md`) over embedding stateful planning information in
documentation. Generate, use, and eventually dissolve these `PLAN`s as you
work.

### Python environment

The project runs Python through Sage's bundled environment, not the system
Python. Sage ships its own venv with known-good versions of SymPy, NumPy,
matplotlib, and SciPy. The `sagew` wrapper provides `--python3` and `--pip`
subcommands that exec Sage's bundled Python directly.

```
./sagew --python3 sympy/plog_error_chain.py
```

Do not use the system `python3` for project scripts.

### Handoff REPORTing

Use the `REPORT.md` document to keep a best-effort running log of the following:
* Useful procedural context about your current workset.
* Recent, active "gotchas" or wrinkles in practice
The reporting handoff should NOT recapitulate or route to existing docs. The repo is small and `REPORT.md` space is precious.
