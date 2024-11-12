# CGO'25 Artifact Evaluation

## Structure

For each kind of benchmarks, we provide a `run.sh` file to execute 
the corresponding test cases. 
If additional packages are used, we provide a local `Dockerfile` 
to ease the execution.

### Synthesis

For synthesis, we provide
- `cp` Constraint Programming, Section 4.2
- `enum` Enumerative Synthesis, Section 3
- `planning` Planning Formalisms, Section 5.2
- `smt` Satisfiability Modulo Theory (CEGIS and direct formulations), Section 4.1
- `stoke` Stoachistic Superoptimization, Section 5.2

### Sorting Kernel Comparison

The `comparison` folder contains the evaluation of the generated sorting kernels
against the reference implementations.

## Claims

Most methods are unable to generate sorting kernels for n=3 in reasonable time.
No method other than our enumerative synthesis can generate sorting kernels for n=4.

Our sorting kernels are faster than the reference implementations.

## Availability of the artifact

The CGO artifact is available at Zenodo ([10.5281/zenodo.14092980](https://zenodo.org/records/14092980)). 
Additionally, the files are available online in [this Github repository](https://github.com/NeuralCoder3/cgo25_artifact).

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14092980.svg)](https://doi.org/10.5281/zenodo.14092980)
