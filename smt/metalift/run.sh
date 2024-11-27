#!/bin/bash

time python sort3.py
echo "With all commands (timeout 5min):"
time timeout 300 python sort3_mov.py
