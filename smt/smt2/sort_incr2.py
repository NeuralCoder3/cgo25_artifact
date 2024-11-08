from z3 import *
import itertools

steps = 11+1
swap = 1
n = 3
# steps = 20+1
# swap = 1
# n = 4

s = Solver()

# no test case could repeat (or even be the same kind/path)
# that is because the forward query finds a program that works on all tests (sat query, guaranteed)
# the backward query finds a test that is failed for this program (sat query, counterexample)

# we synthesize a full path-complete coverage (enumerate the logarithmic type for a dependent computation type)

Inst, (Cmp,Mov,CMovG,CMovL) = EnumSort('Inst', ["cmp","mov", "cmovg", "cmovl"])

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
for t in range(steps):
    # only compare with larger register
    s.add(Implies(cmd[t] == Cmp, a[t] < b[t]))
    # no two consecutive compares
    if t < steps-1:
        s.add(Or(cmd[t] != Cmp, cmd[t+1] != Cmp))

def flatten(l):
    return [item for sublist in l for item in sublist]

init_perm = []
last_perm = 0
state = {}
flags = {}
s.push()
while True:
    s.pop()
    # s.push()
    
    perm_count = len(init_perm)
    
    print("Run with test suite:")
    for i in range(perm_count):
        print(" ".join(str(s) for s in init_perm[i]))
        
    for i in range(steps):
        if i not in state:
            state[i] = {}
            flags[i] = {}
        for k in range(last_perm, perm_count):
            # array to handle access by register
            state[i][k] = Array('state'+str(i)+'_'+str(k), IntSort(), IntSort())
            flags[i][k] = {}
            for f in range(2):
                flags[i][k][f] = Bool('flags'+str(i)+'_'+str(k)+'_'+str(f))
                

    # initial state
    for k in range(last_perm,perm_count):
        for r in range(n):
            s.add(state[0][k][r] == init_perm[k][r])
        for r in range(n, reg):
            s.add(state[0][k][r] == 0)
        for f in range(2):
            s.add(flags[0][k][f] == False)
        
        
    # evolution of state

    # change in flags (execute compare)
    for t in range(steps-1):
        s.add(Implies(
            cmd[t] == Cmp, 
            And(flatten([
                [
                    flags[t+1][k][0] == (state[t][k][a[t]] < state[t][k][b[t]]),
                    flags[t+1][k][1] == (state[t][k][a[t]] > state[t][k][b[t]])
                ]
                for k in range(last_perm,perm_count)]))
        ))
        s.add(Implies(
            cmd[t] != Cmp, 
            And(flatten([
                [
                    flags[t+1][k][0] == flags[t][k][0],
                    flags[t+1][k][1] == flags[t][k][1]
                ]
                for k in range(last_perm,perm_count)]))
        ))
        
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
            cmd[t] == CMovL,
            And(([
                state[t+1][k][a[t]] == If(flags[t][k][0], state[t][k][b[t]], state[t][k][a[t]])
                for k in range(last_perm,perm_count)
            ]))
        ))
        # execute cmovg
        s.add(Implies(
            cmd[t] == CMovG,
            And(([
                state[t+1][k][a[t]] == If(flags[t][k][1], state[t][k][b[t]], state[t][k][a[t]])
                for k in range(last_perm,perm_count)
            ]))
        ))
        # nothing for cmp
        s.add(Implies(
            cmd[t] == Cmp,
            And(([
                state[t+1][k][a[t]] == state[t][k][a[t]]
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
        iflag = {}
        for t in range(steps):
            istate[t] = Array('istate'+str(t), IntSort(), IntSort())
            # init swap
            iflag[t] = {}
            for f in range(2):
                iflag[t][f] = Bool('iflag'+str(t)+'_'+str(f))

        # initial state
        for r in range(n, reg):
            isol.add(istate[0][r] == 0)
        for f in range(2):
            isol.add(iflag[0][f] == False)
            
        # we could add that isol[0][0..n] == init_perm
        
        # evolution of state
        for t in range(steps-1):
            # some duplication with above
            c, ia, ib = commands[t]
            if c == Cmp:
                isol.add(iflag[t+1][0] == (istate[t][ia] < istate[t][ib]))
                isol.add(iflag[t+1][1] == (istate[t][ia] > istate[t][ib]))
                for r in range(reg):
                    isol.add(istate[t+1][r] == istate[t][r])
            elif c == Mov:
                for f in range(2):
                    isol.add(iflag[t+1][f] == iflag[t][f])
                for r in range(reg):
                    if r == ia:
                        isol.add(istate[t+1][r] == istate[t][ib])
                    else:
                        isol.add(istate[t+1][r] == istate[t][r])
            elif c == CMovL:
                for f in range(2):
                    isol.add(iflag[t+1][f] == iflag[t][f])
                for r in range(reg):
                    if r == ia:
                        isol.add(istate[t+1][r] == If(iflag[t][0], istate[t][ib], istate[t][ia]))
                    else:
                        isol.add(istate[t+1][r] == istate[t][r])
            elif c == CMovG:
                for f in range(2):
                    isol.add(iflag[t+1][f] == iflag[t][f])
                for r in range(reg):
                    if r == ia:
                        isol.add(istate[t+1][r] == If(iflag[t][1], istate[t][ib], istate[t][ia]))
                    else:
                        isol.add(istate[t+1][r] == istate[t][r])
            else:
                raise Exception("Unknown command")
            
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
            
    else:
        print("The specification is unsatisfiable.")
        break