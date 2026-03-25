# How to work on SlideRule

>When only the last step seems to remain, the temptation is to treat any gap as a formality. That is the moment of greatest danger. We are in the moment of greatest danger.

## Local imports

> Shared module listings in `lib/README.md`

Reach for these tools to solve mathematical problems over inventing local solutions. Import them with our path-joiner, `helpers/pathing.py`. Example:

```
  from helpers import pathing
  load(pathing('lib', 'partitions.sage'))
```

### PLANning

Plan meaningful changes in temporary `PLAN.md` files, local to the activity being planned. Generate, use, and eventually dissolve these `PLAN`s as you work.

### Running

>All commands from project root. 

```sh
./sagew experiments/aft/keystone/partition_sweep.sage   # run a sweep
./sagew tests/run_tests.sage                        # run tests
./sagew                                             # bare Sage REPL
```

The `sagew` wrapper handles Sage setup. Do not use the system `python3` for project scripts.
