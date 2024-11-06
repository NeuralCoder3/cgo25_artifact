from z3 import *
import itertools

steps = 11+1
swap = 1
n = 3
init_perm = list(itertools.permutations(range(1, n+1)))
perm_count = len(init_perm)

Inst, (Cmp,Mov,CMovG,CMovL) = EnumSort('Inst', ["cmp","mov", "cmovg", "cmovl"])

reg = n+swap

s = Solver()

cmd = []
a = []
b = []
for i in range(steps):
    cmd.append(Const('cmd'+str(i), Inst))
    a.append(Int('a'+str(i)))
    b.append(Int('b'+str(i)))
    s.add(And(a[i] >= 0, a[i] < reg))
    s.add(And(b[i] >= 0, b[i] < reg))
    
state = {}
flags = {}
for i in range(steps):
    state[i] = {}
    flags[i] = {}
    for k in range(perm_count):
        # state[i][k] = {}
        # for r in range(reg):
        #     state[i][k][r] = Int('state'+str(i)+'_'+str(k)+'_'+str(r))
        #     s.add(And(state[i][k][r] >= 0, state[i][k][r] <= n))
        state[i][k] = Array('state'+str(i)+'_'+str(k), IntSort(), IntSort())
        # this constraint reduces 30min to 15min
        for r in range(reg):
            s.add(And(state[i][k][r] >= 0, state[i][k][r] <= n))
        flags[i][k] = {}
        for f in range(2):
            flags[i][k][f] = Bool('flags'+str(i)+'_'+str(k)+'_'+str(f))
            

# initial state
for k in range(perm_count):
    for r in range(n):
        s.add(state[0][k][r] == init_perm[k][r])
    for r in range(n, reg):
        s.add(state[0][k][r] == 0)
    for f in range(2):
        s.add(flags[0][k][f] == False)
        
for t in range(steps):
    s.add(a[t] != b[t])
    
    
# evolution of state
def flatten(l):
    return [item for sublist in l for item in sublist]

# change in flags (execute compare)
for t in range(steps-1):
    s.add(Implies(
        cmd[t] == Cmp, 
        And(flatten([
            [
                flags[t+1][k][0] == (state[t][k][a[t]] < state[t][k][b[t]]),
                flags[t+1][k][1] == (state[t][k][a[t]] > state[t][k][b[t]])
            ]
            for k in range(perm_count)]))
    ))
    s.add(Implies(
        cmd[t] != Cmp, 
        And(flatten([
            [
                flags[t+1][k][0] == flags[t][k][0],
                flags[t+1][k][1] == flags[t][k][1]
            ]
            for k in range(perm_count)]))
    ))
    
# change in state (execute (c)mov)
for t in range(steps-1):
    # all other (not a) stay the same
    for k in range(perm_count):
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
            for k in range(perm_count)
        ]))
    ))
    # execute cmovl
    s.add(Implies(
        cmd[t] == CMovL,
        And(([
            state[t+1][k][a[t]] == If(flags[t][k][0], state[t][k][b[t]], state[t][k][a[t]])
            for k in range(perm_count)
        ]))
    ))
    # execute cmovg
    s.add(Implies(
        cmd[t] == CMovG,
        And(([
            state[t+1][k][a[t]] == If(flags[t][k][1], state[t][k][b[t]], state[t][k][a[t]])
            for k in range(perm_count)
        ]))
    ))
    # nothing for cmp
    s.add(Implies(
        cmd[t] == Cmp,
        And(([
            state[t+1][k][a[t]] == state[t][k][a[t]]
            for k in range(perm_count)
        ]))
    ))
    
# goal
for k in range(perm_count):
    for r in range(n):
        s.add(state[steps-1][k][r] == r+1)
    
    
# heuristics
for t in range(steps):
    # only compare with larger register
    s.add(Implies(cmd[t] == Cmp, a[t] < b[t]))
    # no two consecutive compares
    if t < steps-1:
        s.add(Or(cmd[t] != Cmp, cmd[t+1] != Cmp))
    
    
# tests
    
# s.add(cmd[0] == Cmp)
# s.add(a[0] == 0)
# s.add(b[0] == 1)

# s.add(cmd[1] == CMovL)
# s.add(a[1] == 0)
# s.add(b[1] == 1)

# s.add(cmd[2] == Mov)
# s.add(a[2] == 3)
# s.add(b[2] == 1)

# write smt2 file
with open("sort_3_generated.smt2", "w") as f:
    f.write(s.to_smt2())

res = s.check()
if res == sat:
    m = s.model()
    commands = []
    for i in range(steps):
        commands.append((m[cmd[i]], m[a[i]], m[b[i]]))
    for i in range(steps):
        for k in range(perm_count):
            # print([m[state[i][k][r]] for r in range(reg)])
            values = [m.evaluate(state[i][k][r]) for r in range(reg)]
            flag_values = [m.evaluate(flags[i][k][f]) for f in range(2)]
            # print([m[flags[i][k][f]] for f in range(2)])
            print(" ".join([str(v) for v in values]), 
                  ("<" if flag_values[0] else " ") +
                  (">" if flag_values[1] else " "))
        if i != steps-1:
            print(" ".join(str(s) for s in commands[i]))
        print()
    print()
    print("Whole program:")
    for i in range(steps):
        print(" ".join(str(s) for s in commands[i]))
else:
    print(res)