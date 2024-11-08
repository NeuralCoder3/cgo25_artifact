#!/bin/bash

mkdir -p results

echo "Running minizinc tests:"

SCRIPT_DIR="$(realpath $(dirname $0))"
cd $SCRIPT_DIR/minizinc
./run.sh
cd $SCRIPT_DIR

echo "Running python mip sort synthesis:"
python -u mip/sort_mip.py | tee results/mip.txt

