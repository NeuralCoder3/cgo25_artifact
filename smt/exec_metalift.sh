#!/bin/bash

mkdir -p ./results

cd metalift
./run.sh | tee ../results/metalift.txt

cd /app/smt
./exec.sh