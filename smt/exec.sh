#!/bin/bash

mkdir -p ./results

SCRIPT_DIR=$(dirname "$0")
cd $SCRIPT_DIR/smt2
./run.sh
cd $SCRIPT_DIR


echo "CVC5 Sygus synthesis:"
time cvc5 --lang=sygus2 sort_tuple_command.sy | tee ./results/sort_tuple_command.txt