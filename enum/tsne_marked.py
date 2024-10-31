import time
import numpy as np
from sklearn.manifold import TSNE
import os
import matplotlib.pyplot as plt
import seaborn as sns
from tqdm import tqdm


def flatten(xss):
    return [x for xs in xss for x in xs]

commands = ["cmp", "mov", "cmovl", "cmovg"]

solution_folders = [
    
    ("n=3 h=2","sol3/3_11", False),
    ("n=3 h=1.5","sol3_h15/3_11", False),
    ("n=3 h=1","sol3_h1/3_11", False),
]
prefix="tsne"
perplexity = 50
alpha = 70
length = 11

iter = 300
perturb = 0.1

# iter = 3000
# perturb = 0.5

subsumed = dict()

def load_data(path):
    with open(path, 'r') as f:
        data = f.readlines()
    program = []
    for line in data:
        cmd, arg1, arg2 = line.split()
        cmd = cmd.strip().lower()
        cmd = commands.index(cmd)
        arg1 = int(arg1)
        arg2 = int(arg2)
        program.append((cmd, arg1, arg2))
    return program

programs = []
for name, path, subsume in tqdm(solution_folders):
    ps = []
    for file in tqdm(os.listdir(path), leave=False):
        program = load_data(os.path.join(path, file))
        if subsume:
            # add all prefixes of program to subsumed
            for i in range(1, len(program)+1):
                subsumed[tuple(program[:i])] = name
        ps.append(program)
    programs.append((name, ps))
    
        
# convert (name, programs) to [(program, name)]
flat_programs = [
    (program, name)
    for name, programs in programs
    for program in programs
]

# replace subsumed programs with subsuming name
for i, (program, name) in enumerate(flat_programs):
    if tuple(program) in subsumed:
        flat_programs[i] = (program, subsumed[tuple(program)])

# extend programs to length
flat_programs = [
    (p + [(0,0,0)]*(length-len(p)), name)
    for p, name in flat_programs
]

labels = np.array([name for _, name in flat_programs])
# flatten each program [(cmd, arg1, arg2)] -> [num]
data = np.array([flatten(p) for p, _ in flat_programs])

time_start = time.time()
tsne = TSNE(n_components=2, verbose=1, perplexity=perplexity, n_iter=iter)
tsne_results = tsne.fit_transform(data)

print('t-SNE done! Time elapsed: {} seconds'.format(time.time()-time_start))

plt.figure(figsize=(16,10))

# for more distinct colors
palette = sns.color_palette("bright", len(solution_folders))

# offset coordinates very slightly to avoid overlap
offset = perturb
xcoord = tsne_results[:,0] 
ycoord = tsne_results[:,1]
if perturb > 0:
    xcoord = xcoord + np.random.uniform(-offset, offset, xcoord.shape)
    ycoord = ycoord + np.random.uniform(-offset, offset, ycoord.shape)

sns.scatterplot(
    x=xcoord, y=ycoord,
    hue=labels,
    palette=palette,
    alpha=alpha/100
)


plt.savefig(f"{prefix}_{'scattered_' if perturb > 0 else ''}a{alpha}_p{perplexity}_i{iter}.png")