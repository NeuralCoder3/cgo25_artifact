import os
import re
import shutil
import sys

# distrobox enter archbox
# source ../uiCA/venv/bin/activate

postfix=""
assemblyFile = "build/clang.release.make/bench_s.s"

if len(sys.argv) > 1:
    assemblyFile = sys.argv[1]
    
if len(sys.argv) > 2:
    postfix = sys.argv[2]
    
asm_folder = f"times/uica_asm{postfix}"
uicaPath = "./scripts/uiCA/uiCA.py"
tmp_folder = "times/tmp"
uica_output = f"times/uica_output{postfix}"
    
# if not os.path.exists(outputFolder):
#     os.makedirs(outputFolder)
    
if os.path.exists(asm_folder):
    shutil.rmtree(asm_folder, ignore_errors=True)
os.makedirs(asm_folder)
    
# extract between "# LLVM-MCA-BEGIN {name}" and "# LLVM-MCA-END"
# into {name}.s

pattern = re.compile(r"# LLVM-MCA-BEGIN (\w+)(.*?)# LLVM-MCA-END", re.DOTALL)

with open(assemblyFile, "r") as f:
    content = f.read()

files = []
for m in pattern.finditer(content):
    name = m.group(1)
    asm = m.group(2)
    asm = asm.strip()
    # asm = asm.replace("\n", "\n\t")
    asm = asm.strip()
    files.append((name, asm))
    
# files = files[:10]
    
for name, asm in files:
    with open(os.path.join(asm_folder, name+".s"), "w") as f:
        f.write(asm+"\n")
    
print(f"Extracted {len(files)} regions")

# sys.exit(0)

# distrobox enter archbox
# source ../uiCA/venv/bin/activate
if not os.path.exists(uicaPath):
    print("uiCA not found")
    sys.exit(1)
if os.path.exists(tmp_folder):
    shutil.rmtree(tmp_folder)
os.makedirs(tmp_folder)
if os.path.exists(uica_output):
    shutil.rmtree(uica_output)
os.makedirs(uica_output)

for name, asm in files:
    # as test.s -o test.o
    # uiCA.py -arch SKL test.o
    asm_path = os.path.join(asm_folder, name+".s")
    obj_path = os.path.join(tmp_folder, name+".o")
    cmd = f"as {asm_path} -o {obj_path}"
    print(cmd)
    os.system(cmd)
    out_path = os.path.join(uica_output, name+".txt")
    cmd = f"python {uicaPath} -arch SKL {obj_path} > {out_path}"
    print(cmd)
    os.system(cmd)