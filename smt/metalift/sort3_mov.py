import sys
sys.path.append('/app/metalift')

from metalift.ir import *
from metalift.analysis_new import VariableTracker, analyze

# x y z, swap register, le flag, ge flag
StateType = lambda: TupleT(TupleT(Int(), Int(), Int()), Int(), Bool(), Bool())

def targetLang():
  state = Var("state", StateType())
  xyz = TupleGet(state, IntLit(0))
  x = TupleGet(xyz, IntLit(0))
  y = TupleGet(xyz, IntLit(1))
  z = TupleGet(xyz, IntLit(2))
  swap = TupleGet(state, IntLit(1))
  le = TupleGet(state, IntLit(2))
  ge = TupleGet(state, IntLit(3))
  
  instructions = []
  for a in range(4):
    for b in range(a+1,4):
      ra = [x,y,z,swap][a]
      rb = [x,y,z,swap][b]
      cmp = FnDecl(f"cmp_r{a}_r{b}",
                StateType(),
               Tuple(Tuple(x, y, z), swap, Lt(ra, rb), Gt(ra, rb)),
               state)
      instructions.append(cmp)
      s = [x,y,z,swap]
      s[a], s[b] = s[b], s[a]
      sx,sy,sz,sswap = s
      mov = FnDecl(f"mov_r{a}_r{b}",
                StateType(),
                Tuple(Tuple(sx, sy, sz), sswap, le, ge),
               state)
      instructions.append(mov)
      cmov_gt = FnDecl(f"cmov_gt_r{a}_r{b}",
                StateType(),
                Ite(ge, Tuple(Tuple(sx, sy, sz), sswap, le, ge), state),
               state)
      instructions.append(cmov_gt)
      cmov_lt = FnDecl(f"cmov_lt_r{a}_r{b}",
                StateType(),
                Ite(le, Tuple(Tuple(sx, sy, sz), sswap, le, ge), state),
               state)
      instructions.append(cmov_lt)
      
  return instructions

x = Var("x", Int())
y = Var("y", Int())
z = Var("z", Int())

xyz = Tuple(x, y, z)
init = Tuple(xyz, IntLit(0), BoolLit(False), BoolLit(False))

# res = Call("f", StateType(), init)
res = Call("f", StateType(), x, y, z)
res_xyz = TupleGet(res, IntLit(0))
rx = TupleGet(res_xyz, IntLit(0))
ry = TupleGet(res_xyz, IntLit(1))
rz = TupleGet(res_xyz, IntLit(2))

correct = And(
  Le(rx, ry),
  Le(ry, rz)
)
  

print(correct.toSMT())

lang = targetLang()
for f in lang:
  print(f.name())

grammar = init

for i in range(12):
  calls = [
    Call(f.name(), StateType(), grammar) for f in lang
  ]
  grammar = Choose(
    *calls,
    grammar # no-op
  )


synthF = Synth(
  "f", # function name
  grammar, # body
  # init, # arguments
  x,y,z
)


from metalift.synthesize_auto import synthesize
result = synthesize(
  "example", # name of the synthesis problem
  lang, # list of utility functions
  [x,y,z], # list of variables to verify over
  [synthF], # list of functions to synthesize
  [], # list of predicates
  correct, # verification condition
  [synthF], # type metadata for functions to synthesize, just pass the Synth node otherwise
  unboundedInts=True, # verify against the full range of integers (by default integers are restricted to a fixed number of bits)
)

print(result)
