# How to work on SlideRule

> Logistical guidance lives here, see `reckoning/DISTANT-SHORES.md` for mathematical direction

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

Plan meaningful changes in temporary `PLAN.md` files, local to the activity being planned. Generate, use, and eventually dissolve these `PLAN`s as you work.

### Running

The `sagew` wrapper handles Sage setup. Do not use the system `python3` for project scripts.

>All commands from project root. 

```sh
./sagew experiments/keystone/partition_sweep.sage   # run a sweep
./sagew tests/run_tests.sage                        # run tests
./sagew                                             # bare Sage REPL
```
