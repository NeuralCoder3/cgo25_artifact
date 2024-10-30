import re
import sys
import os


file = "embed_all_quick.txt"
output = sys.stdout
if len(sys.argv) > 1:
    file = sys.argv[1]
if len(sys.argv) > 2:
    output = open(sys.argv[2], "w")

# Benchmark                              Time             CPU   Iterations
# cassioneri_15                    7761102 ns      7760723 ns           89
pattern = re.compile(r"(\w+)\s+(\d+)\s+ns\s+(\d+)\s+ns\s+(\d+)")
times = []
with open(file, "r") as f:
    for line in f:
        m = pattern.match(line)
        if m:
            # print(m.group(1), m.group(2), m.group(3), m.group(4))
            benchmark = m.group(1)
            time = int(m.group(2))
            cpu = int(m.group(3))
            iterations = int(m.group(4))
            times.append((benchmark, time, cpu, iterations))
        else:
            continue
        
times.sort(key=lambda x: x[1])
width = [
    max(len(str(t[i])) for t in times)
    for i in range(4)
]
print(f"{'Benchmark':<{width[0]}} {'Time':>{width[1]}} {'CPU':>{width[2]}} {'Iterations':>{width[3]}}", file=output)
print("-" * (sum(width) + 3 * 3), file=output)
for t in times:
    # print(t[0], t[1], t[2], t[3])
    print(f"{t[0]:<{width[0]}} {t[1]:>{width[1]}} {t[2]:>{width[2]}} {t[3]:>{width[3]}}" , file=output)
    
