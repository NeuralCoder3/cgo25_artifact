from z3 import *
import itertools

# steps = 8+1
# swap = 1
# n = 3
steps = 15+1
swap = 1
n = 4

s = Solver()

def sym_min(a, b):
    return If(a < b, a, b)
def sym_max(a, b):
    return If(a > b, a, b)

# TODO: execute symbolic test case on all previous programs

# TODO: in theory no test case could repeat (or even be the same kind/path)
# that is because the forward query finds a program that works on all tests (sat query, guaranteed)
# the backward query finds a test that is failed for this program (sat query, counterexample)

# we synthesize a full path-complete coverage (enumerate the logarithmic type for a dependent computation type)

# TODO: think about how/why no path is repeated

Inst, (Mov,Min,Max) = EnumSort('Inst', ["mov", "min", "max"])

reg = n+swap

cmd = []
a = []
b = []
for i in range(steps):
    cmd.append(Const('cmd'+str(i), Inst))
    a.append(Int('a'+str(i)))
    b.append(Int('b'+str(i)))
    s.add(And(a[i] >= 0, a[i] < reg))
    s.add(And(b[i] >= 0, b[i] < reg))

for t in range(steps):
    s.add(a[t] != b[t])
    
# heuristics

def flatten(l):
    return [item for sublist in l for item in sublist]

# init_perm = [[1,2,3,0]]
# init_perm = [[2,1,3]]
init_perm = [[2,1,3,4]]
last_perm = 0
state = {}
s.push()
while True:
    s.pop()
    # s.push()
    
    # init_perm = list(itertools.permutations(range(1, n+1)))
    perm_count = len(init_perm)
    
    print("Run with test suite:")
    for i in range(perm_count):
        print(" ".join(str(s) for s in init_perm[i]))
        
    for i in range(steps):
        if i not in state:
            state[i] = {}
        for k in range(last_perm, perm_count):
            # array to handle access by register
            state[i][k] = Array('state'+str(i)+'_'+str(k), IntSort(), IntSort())
            # artificial for sort
            # for r in range(reg):
            #     s.add(And(state[i][k][r] >= 0, state[i][k][r] <= n))
                

    # initial state
    for k in range(last_perm,perm_count):
        for r in range(n):
            s.add(state[0][k][r] == init_perm[k][r])
        for r in range(n, reg):
            s.add(state[0][k][r] == 0)
        
        
    # evolution of state

        
    # change in state (execute (c)mov)
    for t in range(steps-1):
        # all other (not a) stay the same
        for k in range(last_perm,perm_count):
            for r in range(reg):
                s.add(Implies(
                    r != a[t],
                    state[t+1][k][r] == state[t][k][r]
                ))
        # execute Mov
        s.add(Implies(
            cmd[t] == Mov,
            And(([
                state[t+1][k][a[t]] == state[t][k][b[t]]
                for k in range(last_perm,perm_count)
            ]))
        ))
        # execute cmovl
        s.add(Implies(
            cmd[t] == Min,
            And(([
                # state[t+1][k][a[t]] == If(flags[t][k][0], state[t][k][b[t]], state[t][k][a[t]])
                state[t+1][k][a[t]] == sym_min(state[t][k][a[t]], state[t][k][b[t]])
                for k in range(last_perm,perm_count)
            ]))
        ))
        # execute cmovg
        s.add(Implies(
            cmd[t] == Max,
            And(([
                # state[t+1][k][a[t]] == If(flags[t][k][1], state[t][k][b[t]], state[t][k][a[t]])
                state[t+1][k][a[t]] == sym_max(state[t][k][a[t]], state[t][k][b[t]])
                for k in range(last_perm,perm_count)
            ]))
        ))
        
    goal = []
    # goal
    for k in range(last_perm,perm_count):
        sorted_perm = sorted(init_perm[k])
        for r in range(n):
            goal.append(state[steps-1][k][r] == sorted_perm[r])
            
    goal = And(goal)
    s.add(goal)
    
    s.push()
        
    res = s.check()
    if res == sat:
        m = s.model()
        commands = []
        for i in range(steps):
            commands.append((m[cmd[i]], m[a[i]], m[b[i]]))
        # for i in range(steps):
        #     for k in range(perm_count):
        #         values = [m.evaluate(state[i][k][r]) for r in range(reg)]
        #         # flag_values = [m.evaluate(flags[i][k][f]) for f in range(2)]
        #         print(" ".join([str(v) for v in values]))
        #             # ("<" if flag_values[0] else " ") +
        #             # (">" if flag_values[1] else " "))
        #     if i != steps-1:
        #         print(" ".join(str(s) for s in commands[i]))
        #     print()
        # print()
        
        print("Intermediate program:")
        for i in range(steps-1):
            print(" ".join(str(s) for s in commands[i]))
            
        # we have a program
        # but our test suite might not be complete
        # find a case that fails
        
        # we could do this in this program by adding a symbolic test case
        # or in a new solver
        
        isol = Solver()
        istate = {}
        for t in range(steps):
            istate[t] = Array('istate'+str(t), IntSort(), IntSort())
            # init swap
                
        # artificial for sort
        # for r in range(n):
        #     isol.add(And(istate[0][r] >= 1, istate[0][r] <= n))
        #     for r2 in range(n):
        #         if r != r2:
        #             isol.add(istate[0][r] != istate[0][r2])
            

        # initial state
        for r in range(n, reg):
            isol.add(istate[0][r] == 0)
            
        # we could add that isol[0][0..n] == init_perm
        
        # evolution of state
        for t in range(steps-1):
            # some duplication with above
            c, ia, ib = commands[t]
            # if c == Cmp:
            #     isol.add(iflag[t+1][0] == (istate[t][ia] < istate[t][ib]))
            #     isol.add(iflag[t+1][1] == (istate[t][ia] > istate[t][ib]))
            #     for r in range(reg):
            #         isol.add(istate[t+1][r] == istate[t][r])
            if c == Mov:
                for r in range(reg):
                    if r == ia:
                        isol.add(istate[t+1][r] == istate[t][ib])
                    else:
                        isol.add(istate[t+1][r] == istate[t][r])
            elif c == Min:
                for r in range(reg):
                    if r == ia:
                        # isol.add(istate[t+1][r] == If(iflag[t][0], istate[t][ia], istate[t][ib]))
                        # isol.add(istate[t+1][r] == If(istate[t][ia] < istate[t][ib], istate[t][ia], istate[t][ib]))
                        isol.add(istate[t+1][r] == sym_min(istate[t][ia], istate[t][ib]))
                    else:
                        isol.add(istate[t+1][r] == istate[t][r])
            elif c == Max:
                # for f in range(2):
                #     isol.add(iflag[t+1][f] == iflag[t][f])
                for r in range(reg):
                    if r == ia:
                        # isol.add(istate[t+1][r] == If(iflag[t][1], istate[t][ib], istate[t][ia]))
                        # isol.add(istate[t+1][r] == If(istate[t][ia] > istate[t][ib], istate[t][ia], istate[t][ib]))
                        isol.add(istate[t+1][r] == sym_max(istate[t][ia], istate[t][ib]))
                    else:
                        isol.add(istate[t+1][r] == istate[t][r])
            else:
                raise Exception("Unknown command: "+str(c))
            
        # goal
        goal = []
        # istate[steps-1][0..n] == sorted(istate[0][0..n])
        # "some" sorted numbers
        for r in range(n-1):
            goal.append(istate[steps-1][r] <= istate[steps-1][r+1])
        # permutation of istate[0][0..n]
        for r in range(n):
            # each number is in istate[0][0..n]
            goal.append(Or([istate[steps-1][r] == istate[0][ri] for ri in range(n)]))
            # each number is in istate[steps-1][0..n]
            goal.append(Or([istate[0][r] == istate[steps-1][ri] for ri in range(n)]))
        
        goal = And(goal)
        isol.add(Not(goal))
        
        res = isol.check()
        if res == sat:
            m = isol.model()
            print("Test case:")
            print(" ".join(str(m.evaluate(istate[0][r])) for r in range(n)))
            print()
            last_perm = len(init_perm)
            init_perm.append([m.evaluate(istate[0][r]).as_long() for r in range(n)])
        else:
            print("No test case found.")
            print("The program is correct.")
            break
            
        # inputs = []
        # for i in range(n):
        #     inputs.append(Int('input'+str(i)))
        #     isol.add(And(inputs[i] >= 0, inputs[i] <= n))
        
        # assume that we use this program
        # for i in range(steps):
        #     s.add(And(cmd[i] == commands[i][0], a[i] == commands[i][1], b[i] == commands[i][2]))
        
        # is there a test case that fails?
        
    else:
        print("The specification is unsatisfiable.")
        break
    
    
# Run with test suite:
# 2 1 3 4
# 31121 31120 31119 31118
# 31201 31202 31204 31203
# 29281 29284 29283 29282
# -1 29534 -2 0
# 14097 14094 14095 14096
# -3580 -3578 -3579 -3578
# 18624 18622 18625 18623
# ^CThe specification is unsatisfiable.

# real    811m51,619s
# user    811m5,417s
# sys     0m20,810s