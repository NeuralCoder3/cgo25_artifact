int: s; % The number of timesteps.
int: perm_count;
int: n; % number of registers
int: swap;
array [1..perm_count, 1..n] of 0..n: init_perm;

include "globals.mzn";
% include "chuffed.mzn"; % makes it slower

enum Inst = { Mov, Min, Max};
int: normal_reg = n+swap;
% int: xmm_off = normal_reg;
% int: reg = n+swap+n+swap; % with xmm registers
int: reg = normal_reg;

array [1..s] of var Inst: cmd;
array [1..s] of var 1..reg: a;
array [1..s] of var 1..reg: b;

array [1..s,1..perm_count,1..reg] of var 0..n: state;

constraint %% state[0,..] = init_perm
    forall (k in 1..perm_count, r in 1..n) (
        state[1,k,r] = init_perm[k,r] 
        % state[1,k,r+xmm_off] = init_perm[k,r]
    );

constraint %% state[0,..,swap] = 0
    forall (k in 1..perm_count, r in 1..swap) (
        state[1,k,n+r] = 0
        % state[1,k,n+r+xmm_off] = 0
    );

constraint %% don't operate with yourself
    forall (t in 1..s) (
        a[t] != b[t]
    );

% min and max can use xmm registers
constraint %% min, max => xmm registers
    forall (t in 1..s) (
        cmd[t] = Min \/ cmd[t] = Max -> 
        a[t] <= n + swap /\ b[t] <= n + swap
    );


%% evolution of state (executing commands)


constraint %% change values (execute (c)mov)
    forall (t in 1..(s-1)) (
        % all non-a stay the same
        forall (k in 1..perm_count, r in 1..reg) (
            if r != a[t] then
                state[t+1,k,r] = state[t,k,r]
            endif
        ) /\
        (cmd[t] = Mov -> 
            forall (k in 1..perm_count) (
                state[t+1,k,a[t]] = state[t,k,b[t]]
            )) /\
        % min and max: s[a] = min/max(s[a], s[b])
        (cmd[t] = Min -> 
            forall (k in 1..perm_count) (
                state[t+1,k,a[t]] = min(state[t,k,a[t]], state[t,k,b[t]])
            )) /\
        (cmd[t] = Max ->
            forall (k in 1..perm_count) (
                state[t+1,k,a[t]] = max(state[t,k,a[t]], state[t,k,b[t]])
            ))
    );









constraint
        % sorted in normal register
        (
    (forall (k in 1..perm_count) (
            forall (r in 1..(n-1)) (
                state[s,k,r] <= state[s,k,r+1]
            ) /\
            sum([init_perm[k,r] = 0 | r in 1..n]) = sum([state[s,k,r] = 0 | r in 1..n])
            /\ sum([init_perm[k,r] = 1 | r in 1..n]) = sum([state[s,k,r] = 1 | r in 1..n])
            /\ sum([init_perm[k,r] = 2 | r in 1..n]) = sum([state[s,k,r] = 2 | r in 1..n])
            /\ sum([init_perm[k,r] = 3 | r in 1..n]) = sum([state[s,k,r] = 3 | r in 1..n]) 
        )) 
    );



output ["Step: \(t)\n" ++ 
    concat([
        concat(["\(state[t,k,r]) " | r in 1..reg]) ++ 
            % showFlag(flags[t,k,1]) ++ show(flags[t,k,2]) ++
            "\n"
         | k in 1..perm_count]) ++ 
    if t<s then "Run: \(cmd[t]) \(a[t]) \(b[t])\n" else "" endif ++
    "\n"
    | t in 1..s];


output ["\n"];


%% print all commands in the form "cmd a b"
output ["Program:\n"];
output ["\(cmd[t]) \(a[t]) \(b[t])\n" | t in 1..(s-1)];