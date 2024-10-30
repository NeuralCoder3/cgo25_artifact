import os
import tqdm
import re

def replace_all(repls, str):
    # return re.sub('|'.join(repls.keys()), lambda k: repls[k.group(0)], str)                                     
    return re.sub('|'.join(re.escape(key) for key in repls.keys()),
                  lambda k: repls[k.group(0)], str)   

# folder = "solutions_all_cut_2/4_20" # 56 => 28359/279180 (10%)
# folder = "solutions_min_cut/4_20" # only commands => 51 -> 9
# folder = "solutions_all_cut/3_11" # only commands => 1186 -> 18
# folder = "solutions_min_cut/3_11" # only commands => 18 -> 9

# folder = "vis/sol_only/solutions_all_nocut/3_11" # 1642 solutions -> 21 unique
# folder = "vis/sol_only/solutions_all_cut_times1/3_11" # 234 solutions -> 11 unique
# folder = "vis/sol_only/solutions_all_cut_times2/3_11" # 1642 solutions -> 21 unique (384 unsorted)
 
# check that no two files have the same content
# files = os.listdir(folder)
# files = [f for f in files if f.endswith(".txt")]


# folder = "/home/marcel/Documents/Projekte/ml/minizinc/output/" # 5602 solutions -> 23 unique
# folder = "/home/marcel/Documents/Projekte/ml/minizinc/enumeration-synth/conduit/alg_2" # 63 unique
folder = "vis/all_commands_no_early/cut_2_all/3_11" # 
# recursively list all txt files
files = []
for root, dirs, fs in os.walk(folder):
    for f in fs:
        if f.endswith(".txt"):
            files.append(os.path.relpath(os.path.join(root, f), folder))


found = dict()
# unique up to reordering
unique = dict()
c=0

for file in tqdm.tqdm(files):
    c += 1
    with open(os.path.join(folder, file), "r") as f:
        content = f.read()

    if content in found:
        # print(f"Found duplicate: {file} and {found[content]}")
        pass
    else:
        found[content] = file
        
    # if content.replace("\n", " ").startswith("cmp 1 2 mov 4 1 cmovl 4 2 cmovg 1 2 cmp 3 1 mov 2 3 cmovl 2 1 cmovl 1 3 cmp 2 4 cmovl 3 4 cmovg 2 4"):
    # if content.replace("\n", " ").startswith("cmp 1 2 mov 4 1 cmovl 4 2 cmovg 1 2 cmp 1 3 mov 2 3 cmovg 2 1 cmovg 1 3 cmp 2 4 cmovl 3 4 cmovg 2 4"):
    #     print(f"Found alphadev in {file}")

    sorted_content = content
    # # handle renaming
    # # => count amounto f 1 2 3 4s
    # # sort by amount [(3, 23), (2, 34), ...]
    # # name by sorted [3->1, 2->2, ...]
    # registers = ["1", "2", "3", "4"]
    # counts = [(r,sorted_content.count(r)) for r in registers]
    # counts = sorted(counts, key=lambda x: x[1])
    # mapping = dict()
    # for i, (r, _) in enumerate(counts):
    #     mapping[r] = str(i+1)
    # # replace all at once to avoid conflicts
    # # print(counts)
    # # print(mapping)
    # sorted_content = sorted_content.translate(str.maketrans(mapping))
    # # sorted_content = replace_all(mapping, sorted_content)

    lines = sorted_content.split("\n")
    lines = [line.split()[0] for line in lines if line.strip() != ""]
    sorted_content = "\n".join(lines)


    lines = sorted_content.split("\n")
    lines = sorted(lines)
    sorted_content = "\n".join(lines)

    if sorted_content not in unique:
        unique[sorted_content] = content
    # if len(unique) == 56:
    #     print(c)
    #     break
        
print(f"Unique: {len(unique)}")
print(f"Solutions: {len(found)}")
print(f"Total: {len(files)}")