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
    # ("nocut","vis/solutions_all_nocut/3_11"),
    # ("cut_2","vis/solutions_all_cut_times2/3_11"),
    # ("cut_1","vis/solutions_all_cut_times1/3_11"),
    # ("min","vis/solutions_min_nocut/3_11"),
    # ("min"  ,"vis/all_commands_no_early/cut_1.5_all"),
    
    # ("min visit","vis/solutions_min_nocut/3_11_all"),
    # ("min sol","vis/solutions_min_nocut/3_11"),
    
    # ("cut_2 visit","vis/solutions_all_cut_times2/3_11_all"),
    # ("cut_2 sol","vis/solutions_all_cut_times2/3_11"),
    
    # ("cut_1 visit","vis/solutions_all_cut_times1/3_11_all", False),
    # ("cut_1 sol","vis/solutions_all_cut_times1/3_11", True),
    
    # ("cut_2 visit","vis/solutions_all_cut_times2/3_11_all", False),
    # ("cut_2 sol","vis/solutions_all_cut_times2/3_11", True),
    
    ("n=3 h=2","sol3/3_11", False),
    ("n=3 h=1.5","sol3_h15/3_11", False),
    ("n=3 h=1","sol3_h1/3_11", False),
]
# prefix="vis/solutions"
# prefix="vis/cut2"
# prefix="vis/cut1"
# prefix="vis/cut1_filtered"
# prefix="vis/cut1_marked"
prefix=""
# prefix="vis/min"
perplexity = 50
alpha = 70
length = 11

iter = 300
perturb = 0.1

# iter = 3000
# perturb = 0.5

# path = "vis/solutions_all_nocut/3_11"

# cut2 marked 3k
# t-SNE] KL divergence after 3000 iterations: 2.707211
# t-SNE done! Time elapsed: 43954.83477306366 seconds

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
        # program.append([cmd, arg1, arg2])
        program.append((cmd, arg1, arg2))
    # complete with 0,0,0 until length
    # while len(program) < length:
    #     program.append([0,0,0])
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
    # programs.append((
    #     name,
    #     [
    #         load_data(os.path.join(path, file))
    #         # for file in os.listdir(path)
    #         for file in tqdm(os.listdir(path), leave=False)
    #     ]
    # ))
    
# filter out programs < length
# programs = [
#     (name, [p for p in ps if len(p) == length])
#     for name, ps in programs
# ]
# extend programs to length
# programs = [
#     (name, [p + [[0,0,0]]*(length-len(p)) for p in ps])
#     for name, ps in programs
# ]
        
# convert (name, programs) to [(program, name)]
flat_programs = [
    (program, name)
    for name, programs in programs
    for program in programs
]
# flatten [[(program, name)]] -> [(program, name)]
# flat_programs = flatten(flat_programs)

# replaced_paths = 0
# replace subsumed programs with subsuming name
for i, (program, name) in enumerate(flat_programs):
    if tuple(program) in subsumed:
        # if name != subsumed[tuple(program)]:
        #     replaced_paths += 1
        flat_programs[i] = (program, subsumed[tuple(program)])

# print(f"Replaced {replaced_paths} paths")

# extend programs to length
flat_programs = [
    (p + [(0,0,0)]*(length-len(p)), name)
    for p, name in flat_programs
]

labels = np.array([name for _, name in flat_programs])
# flatten each program [(cmd, arg1, arg2)] -> [num]
data = np.array([flatten(p) for p, _ in flat_programs])
# add label (everywhere 1 for now)
# data = np.concatenate([data, np.ones((data.shape[0],1))], axis=1)
# labels = np.ones((data.shape[0],1))

time_start = time.time()
# tsne = TSNE(n_components=2, verbose=1, perplexity=40, n_iter=300)
# tsne = TSNE(n_components=2, verbose=1, perplexity=50, n_iter=3000)
tsne = TSNE(n_components=2, verbose=1, perplexity=perplexity, n_iter=iter)
# tsne_results = tsne.fit_transform(data)
tsne_results = tsne.fit_transform(data)

print('t-SNE done! Time elapsed: {} seconds'.format(time.time()-time_start))

# df_subset['tsne-2d-one'] = tsne_results[:,0]
# df_subset['tsne-2d-two'] = tsne_results[:,1]



plt.figure(figsize=(16,10))
# sns.scatterplot(
#     x = tsne_results[:,0], y=tsne_results[:,1],
#     palette=sns.color_palette("hls", 10),
#     # hue = [1]*len(tsne_results),
#     data = tsne_results,
#     legend="full",
#     alpha=0.3
# )

# scatter with labels
# palette = sns.color_palette("hls", len(solution_folders))
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
    # alpha=0.3
    alpha=alpha/100
)


plt.savefig(f"{prefix}_{'scattered_' if perturb > 0 else ''}a{alpha}_p{perplexity}_i{iter}.png")
# plt.show()

# solutions_scattered_a70_p50_i3000