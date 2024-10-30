import os
import re
import shutil
import sys


postfix=""

if len(sys.argv) > 1:
    postfix = sys.argv[1]

uica_output = f"times/uica_output{postfix}"
output_file = f"times/uica_throughput{postfix}.txt"
output_file_sorted = f"refined/uica_throughput_sorted{postfix}.txt"

if len(sys.argv) > 2:
    output_file = sys.argv[2]
if len(sys.argv) > 3:
    output_file_sorted = sys.argv[3]

times = []

throughput_pattern = re.compile(r"Throughput \(in cycles per iteration\): (\d+\.\d+)")

files = os.listdir(uica_output)
# remove file extension
files = [".".join(f.split(".")[:-1]) for f in files]
    
for name in files:
    out_path = os.path.join(uica_output, name+".txt")

    # extract throughput
    # Throughput (in cycles per iteration): 12.61
    
    with open(out_path, "r") as f:
        content = f.read()
        m = throughput_pattern.search(content)
        if m:
            throughput = m.group(1)
            times.append((name, throughput))
        else:
            print(f"No throughput found for {name}")
            times.append((name, "N/A"))
            
# for name, throughput in times:
#     print(name, throughput)
with open(output_file, "w") as f:
    for name, throughput in times:
        f.write(f"{name}\t{throughput}\n")
            
times.sort(key=lambda x: 10000 if x[1] == "N/A" else float(x[1]))

with open(output_file_sorted, "w") as f:
    for name, throughput in times:
        f.write(f"{name}\t{throughput}\n")