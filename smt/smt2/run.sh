#!/bin/bash

mkdir -p ../results

echo "CEGIS encoding of SMT:"
time python -u sort_incr2.py | tee ../results/sort_incr2.txt
echo "CEGIS minmax:"
time python -u sort_incr_minmax.py | tee ../results/sort_incr_minmax.txt
echo "Component based CEGIS:"
time python -u sort3.py -d 1 -m 12 | tee ../results/sort_component.txt
echo "Direct SMT encoding:"
time z3 sort_smt.smt | tee ../results/sort_smt_z3.txt
echo "Direct SMT encoding using cvc5:"
time cvc5 --lang smt2 sort_smt.smt | tee ../results/sort_smt_cvc5.txt