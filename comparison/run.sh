#!/bin/bash

# build the application
cmake --preset=clang.release.make
cmake --build build/clang.release.make

# run the application
mkdir -p times refined
exes=( "bench" "bench4" "bench5" "bench_embed" "bench_embed4" )
for exe in "${exes[@]}"; do
    ./build/clang.release.make/bin/$exe | tee times/$exe.txt
    python scripts/sort_times.py times/$exe.txt refined/sorted_$exe.txt
done



# LLVM MCA
cmake --build build/clang.release.make --target bench_s
llvm-mca -mcpu=skylake -march= build/clang.release.make/bench_s.s > times/bench_llvm_mca_skylake.txt
python scripts/llvm_mca_extract.py times/bench_llvm_mca_skylake.txt refined/bench_llvm_mca_skylake.txt

# UICA
# needs python with plotly
SCRIPT_DIR="$(realpath $(dirname $0))"
cd $SCRIPT_DIR/scripts/uica
./setup.sh

cd $SCRIPT_DIR
python scripts/run_uica.py build/clang.release.make/bench_s.s
python scripts/extract_uica.py '' times/bench_uica_throughput.txt refined/bench_uica_throughput.txt

