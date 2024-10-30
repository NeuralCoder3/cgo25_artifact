import re
import os
import sys

file = "3_llvm_mca.txt"
output = "3_llvm_mca_plain.txt"

if len(sys.argv) > 1:
    file = sys.argv[1]
if len(sys.argv) > 2:
    output = sys.argv[2]
    
    
# [i] Code Region - {name}
# ...
# Block Throughput: {throughput}

# example
# [0] Code Region - sort3_alphadev

# Iterations:        100
# Instructions:      2100
# Total Cycles:      1059
# Total uOps:        2100

# Dispatch Width:    2
# uOps Per Cycle:    1.98
# IPC:               1.98
# Block RThroughput: 10.5

# list of regions with their throughputs
throughputs = []

pattern = re.compile(r"Code Region - (\w+).*?Block RThroughput: (\d+\.\d+)", re.DOTALL)
# pattern = re.compile(r"Code Region - (\w+)\n\nIterations:\s+(\d+)", re.DOTALL)
# pattern = re.compile(r"Code Region - (\w+)\n\nIteratio.*?Block RThroughput: (\d+\.\d+)", re.DOTALL)

with open(file, "r") as f:
    content = f.read()
    
count = 0
for m in pattern.finditer(content):
    region = m.group(1)
    throughput = m.group(2)
    throughput = float(throughput)
    throughputs.append((region, throughput))
    # print(region, throughput)
    count += 1
    # if count >= 100:
    #     break
    
# for region, throughput in throughputs[:100]:
#     print(region, throughput)
    
throughputs.sort(key=lambda x: x[1])
with open(output, "w") as f:
    for region, throughput in throughputs:
        f.write(f"{region}\t{throughput}\n")
