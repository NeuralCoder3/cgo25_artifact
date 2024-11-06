#!/bin/bash

time z3 sort_smt.smt
time cvc5 --lang smt2 sort_smt.smt
