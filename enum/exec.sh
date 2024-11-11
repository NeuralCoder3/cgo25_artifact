#!/bin/bash

echo "Compare search with astar"
mkdir -p results

echo "Fast astar for n=3, first solution: (around 100ms)"
cargo run --bin astar --features n3 --features heuristic1 --features optimalinstructions --release | tee results/sol3_h1.txt
echo "Fast astar for n=4, first solution: (around 2.5s)"
cargo run --bin astar --features n4 --features heuristic1 --features optimalinstructions --release | tee results/sol4_h1.txt
echo "Fast astar for n=5, first solution: (around 11min)"
cargo run --bin astar --features n5 --features heuristic1 --features optimalinstructions --release | tee results/sol5_h1.txt

echo ""
echo "All solutions for n=3 (10min to find 5602, 30min to completion):"
SOLUTION_DIR=sol3 cargo run --bin astar --features allsolutions --features n3 --features heuristic2 --release | tee results/sol3_allsolutions_log.txt
echo "Solutions are stored in sol3"

# checking
python check.py sol3/3_11
if [ $? -eq 0 ]; then
    echo "Solution is correct"
else
    echo "Solution is incorrect"
fi

echo ""
echo "Generate heuristic solutions (4min and 25s):"
SOLUTION_DIR=sol3_h15 cargo run --bin astar --features allsolutions --features n3 --features heuristic15 --release | tee results/sol3_h15_allsolutions_log.txt
SOLUTION_DIR=sol3_h1 cargo run --bin astar --features allsolutions --features n3 --features heuristic1 --release | tee results/sol3_h1_allsolutions_log.txt

# tsne
echo ""
echo "Computing TSNE embedding for n=3"
python tsne_marked.py

# Parallel, GPU
echo ""
echo "Running Parallel Dijkstra (around 30s)"
cargo run --bin parallel --release | tee results/sol3_parallel.txt

# only execute if --gpu is set
if [ "$1" == "--gpu" ]; then
    # nix-shell -p opencl-headers opencl-info ocl-icd
    echo "Running GPU search (around 3min)"
    cargo run --bin gpu --release | tee results/sol3_gpu.txt
    echo "Running GPU2 search (around 1min)"
    cargo run --bin gpu_struct --release | tee results/sol3_gpu_struct.txt
fi


# minmax
echo ""
echo "Min/Max (around 3ms)"
cargo run --bin minmax --release | tee results/sol3_minmax.txt
echo "Min/Max all solutions (around 500ms)"
SOLUTION_DIR=sol3_minmax cargo run --bin minmax --features allsolutions --release | tee results/sol3_minmax_allsolutions.txt
echo "Min/Max for n=4 (around 50ms)"
cargo run --bin minmax --features n4 --release | tee results/sol4_minmax.txt
# only minimal length, longer solutions are still easy (and might still be helpful, e.g. length 27 can be found in 4s)
echo "Min/Max for n=5 (around 1min)"
cargo run --bin minmax --features n5 --release | tee results/sol5_minmax.txt
