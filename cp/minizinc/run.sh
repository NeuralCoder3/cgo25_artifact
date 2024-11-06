#!/bin/bash

mkdir -p results

echo "Running Minizinc with Chuffed:"
time minizinc --solver Chuffed sort_syn_v2_org_change.mzn sort_data3.dzn | tee results/minizinc_chuffed_3.txt
echo "Running Minizinc with Chuffed minmax:"
time minizinc --solver Chuffed sort_syn_minmax.mzn sort_data3_minmax.dzn | tee results/minizinc_chuffed_3_minmax.txt

echo "Generating all solutions:"
time minizinc --solver Chuffed -a sort_syn_v2_org_change.mzn sort_data3.dzn | tee results/minizinc_chuffed_3_all.txt

