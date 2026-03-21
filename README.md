# DayLog

TODO:IGNORE FOR NOW 

>FSM-parameterised coarse-stage approximations meet scale-equivariant geometry.

>

Mike Day's 2023 FRSR analysis gives an exact finite candidate set for the extrema of piecewise-linear coarse approximations to `x^(p/q)`. 

Studying finite-state intercept policies for those coarse approximations shows us something rather interesting: 
> 

proof that the log-linear relationship in binary scientific notation style floating point representations known since at least Mitchell 1962 is not just useful but optimal in a very specific way: 


This repo studies finite-state intercept policies for those coarse approximations. 

The overall and rather brash goal: transform the triangle inequality into a computable measure of the cost of departure from a log-linear surrogate, producing a "computational ruler" for approximation problems governed by scaling.



## Documentation

- [`DISTANT-SHORES.md`](DISTANT-SHORES.md): overall science goal and the
  six-step roadmap toward a computational ruler.
- [`experiments/EXPERIMENTS.md`](experiments/EXPERIMENTS.md): experiment drivers, output
  columns, and which scripts support the keystone program.
- [`PARTITIONS.md`](PARTITIONS.md): analytical classification of the partition
  family and the current selection rationale.

## Terminology

TODO:REPLACE WITH POINTER TO GLOSSARY

## Running

TODO:MIGRATE (A MINIMAL VERSION) TO AGENTS.MD

All commands below are run from project root.

```sh
./sagew experiments/keystone/partition_sweep.sage
./sagew experiments/keystone/h1_sweep.sage
./sagew experiments/keystone/inspect_case.sage
python3 lib/trajectory.py
./sagew tests/run_tests.sage
./sagew
```
