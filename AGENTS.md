# How to work here

> Logistical guidance lives here, see `DISTANT-SHORES.md` for mathematical direction

## Experiments

For experiments, claims, and output interpretation -> `experiments/EXPERIMENTS.md`, with sweep findings and dated empirical summaries in `experiments/<topic>/results/`. Reading `EXPERIMENTS` and the agent guidance will tell you how to operate there.

## Library re-use

> Shared module listings -> `lib/README.md`

Reach for these tools to solve mathematical problems over inventing local solutions. 

## Local imports

Import with our path-joiner, `helpers/pathing.py`. Example:

```
  from helpers import pathing
  load(pathing('lib', 'partitions.sage'))
```

### PLANning

Processes which change the repo state should be recorded in temporary `PLAN.md`
files, local to the activity being planned. Prefer these files (or an
equivalent `SUBJECT-PLAN.md`) over embedding stateful planning information in
documentation. Generate, use, and eventually dissolve these `PLAN`s as you
work.

### Python environment

>Do not use the system `python3` for project scripts.

The project runs Python through Sage's bundled environment, with its own venv with known-good versions of SymPy, NumPy, matplotlib, and SciPy. The `sagew` wrapper provides `--python3` and `--pip`subcommands that exec Sage's bundled Python directly, invoke it like so: `./sagew --python3 sympy/example.py`.
