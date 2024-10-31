import os
import tqdm
import sys
import itertools

folder = "sol3_h1/3_11" 
if len(sys.argv) > 1:
    folder = sys.argv[1]
    
# recursively list all txt files
files = []
for root, dirs, fs in os.walk(folder):
    for f in fs:
        if f.endswith(".txt"):
            files.append(os.path.relpath(os.path.join(root, f), folder))
            
n = 3
permutations = list(itertools.permutations(range(1, n+1)))

def apply_instruction(perm, instr):
    perm = perm.copy()
    cmd, arg1, arg2 = instr
    arg1 -= 1
    arg2 -= 1
    # to, from
    if cmd == "CMP":
        perm[-2] = perm[arg1] < perm[arg2]
        perm[-1] = perm[arg1] > perm[arg2]
    elif cmd == "MOV":
        perm[arg1] = perm[arg2]
    elif cmd == "CMOVL":
        if perm[-2]:
            perm[arg1] = perm[arg2]
    elif cmd == "CMOVG":
        if perm[-1]:
            perm[arg1] = perm[arg2]
    return perm
        
def apply_program(perms, program):
    for instr in program:
        perms = [apply_instruction(perm, instr) for perm in perms]
    return perms

# add swap and flags
permutations = [(list(perm) + [0, False, False]) for perm in permutations]

for file in tqdm.tqdm(files):
    with open(os.path.join(folder, file), "r") as f:
        content = f.readlines()
        
    program = []
    for line in content:
        cmd, arg1, arg2 = line.split()
        cmd = cmd.strip().upper()
        arg1 = int(arg1)
        arg2 = int(arg2)
        program.append((cmd, arg1, arg2))
        
    perms = permutations.copy()
    perms = apply_program(perms, program)
    
    final_state = [perm[:3] for perm in perms]
    correct = all([state == list(range(1, n+1)) for state in final_state])
    if not correct:
        print(f"Found incorrect solution in {file}")
        print(program)
        print(perms)
        print(final_state)
        sys.exit(1)