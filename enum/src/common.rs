#[cfg(feature = "n3")] pub const NUMBERS: usize = 3;
#[cfg(feature = "n3")] pub const MAX_LEN: u8 = 11;
#[cfg(feature = "n3")] pub const MAX_LEN_MINMAX: u8 = 8;
#[cfg(feature = "n4")] pub const NUMBERS: usize = 4;
#[cfg(feature = "n4")] pub const MAX_LEN: u8 = 20; // impossible with 19 => test to prove minimality
#[cfg(feature = "n4")] pub const MAX_LEN_MINMAX: u8 = 15;
#[cfg(feature = "n5")] pub const NUMBERS: usize = 5;
#[cfg(feature = "n5")] pub const MAX_LEN: u8 = 33;
#[cfg(feature = "n5")] pub const MAX_LEN_MINMAX: u8 = 26; 
#[cfg(feature = "n6")] pub const NUMBERS: usize = 6;
#[cfg(feature = "n6")] pub const MAX_LEN_MINMAX: u8 = 40; // not proven to be minimal

#[cfg(not(any(feature = "n3", feature = "n4", feature = "n5", feature = "n6")))] pub const NUMBERS: usize = 3;
#[cfg(not(any(feature = "n3", feature = "n4", feature = "n5", feature = "n6")))] pub const MAX_LEN: u8 = 11;
#[cfg(not(any(feature = "n3", feature = "n4", feature = "n5", feature = "n6")))] pub const MAX_LEN_MINMAX: u8 = 8;

pub const SWAPS: usize = 1;

// const NUMBERS: usize = 6;
// const MAX_LEN: u8 = 45;
// const SWAPS: usize = 2; // increases perm states from 80640 to 1330560


// https://github.com/google-deepmind/alphadev/blob/main/sort_functions_test.cc
pub const REGS: usize = NUMBERS + SWAPS;
pub const CMP: usize = 0;
pub const MOV: usize = 1;
pub const CMOVG: usize = 2;
pub const CMOVL: usize = 3;
pub const NUMBERS_U8: u8 = NUMBERS as u8;

type Command = (usize, usize, usize);
#[derive(Clone, Eq, PartialEq, Hash, Ord, PartialOrd, Debug, Copy)]
pub struct Permutation(pub [u8; REGS + 2]);
pub type State = Vec<Permutation>;

use std::ops::{Index, IndexMut, Range};

impl Index<usize> for Permutation {
    type Output = u8;

    fn index(&self, index: usize) -> &Self::Output {
        &self.0[index]
    }
}

impl IndexMut<usize> for Permutation {
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        &mut self.0[index]
    }
}

impl Index<Range<usize>> for Permutation {
    type Output = [u8];

    fn index(&self, index: Range<usize>) -> &Self::Output {
        &self.0[index]
    }
}

impl IndexMut<Range<usize>> for Permutation {
    fn index_mut(&mut self, index: Range<usize>) -> &mut Self::Output {
        &mut self.0[index]
    }
}

pub fn possible_commands() -> Vec<Command> {
    let mut commands = vec![];
    for instr in &[MOV, CMOVG, CMOVL] {
        for to in 0..REGS {
            for from in 0..REGS {
                if to != from {
                    commands.push((*instr, to, from));
                }
            }
        }
    }
    for i in 0..REGS {
        for j in (i + 1)..REGS {
            commands.push((CMP, i, j));
        }
    }
    commands
}

// transform a permutation according to a command
pub fn apply(cmd: &Command, perm: &mut Permutation) {
    let (instr, to, from) = *cmd;
    match instr {
        CMP => {
            perm[REGS + 0] = (perm[to] < perm[from]) as u8;
            perm[REGS + 1] = (perm[to] > perm[from]) as u8;
        }
        MOV => perm[to] = perm[from],
        CMOVG => {
            if perm[REGS + 1] == 1 {
                perm[to] = perm[from];
            }
        }
        CMOVL => {
            if perm[REGS + 0] == 1 {
                perm[to] = perm[from];
            }
        }
        _ => panic!("Unknown instruction"),
    }
}

// "undo" a command on a permutation to traverse the program backwards
// multiple "origins" that lead to the given permutations are possible
// returns an empty vector if the command can not result in the given permutation
// could alternatively be computed via brute force
pub fn apply_invers(cmd: &Command, perm: &Permutation) -> Vec<Permutation> {
    let (instr, to, from) = *cmd;
    match instr {
        CMP => {
            let lt_flag = perm[REGS + 0];
            let gt_flag = perm[REGS + 1];
            // check that flags are set correctly
            if ((lt_flag == 0 && !(perm[to] < perm[from])) || (lt_flag == 1 && perm[to] < perm[from])) &&
                ((gt_flag == 0 && !(perm[to] > perm[from])) || (gt_flag == 1 && perm[to] > perm[from])) {
                // valid flags
                // => return state with flags as anything (would be overwritten)
                return 
                // 0,0; 0,1; 1,0; 1,1 as possibilities for the flags
                [(0,0), (0,1), (1,0), (1,1)].iter().map(|(lt,gt)| {
                    let mut new_perm = perm.clone();
                    new_perm[REGS + 0] = *lt;
                    new_perm[REGS + 1] = *gt;
                    new_perm
                }).collect::<Vec<_>>();
            }else {
                return vec![];
            }
        }
        MOV => {
            if perm[to] != perm[from] {
                return vec![];
            }
            // dest could be anything before
            return [0;NUMBERS+1].iter().enumerate().map(|(x, _)| {
                let mut new_perm = perm.clone();
                new_perm[to] = x as u8;
                new_perm
            }).collect::<Vec<_>>();
        }
        CMOVG => {
            let gt_flag = perm[REGS + 1];
            if gt_flag == 0 {
                // flag not set => noop
                return vec![perm.clone()];
            }
            // flag set => was overwrite (same as with MOV)
            return apply_invers(&(MOV, to, from), perm);
        }
        CMOVL => {
            let lt_flag = perm[REGS + 0];
            if lt_flag == 0 {
                // flag not set => noop
                return vec![perm.clone()];
            }
            // flag set => was overwrite (same as with MOV)
            return apply_invers(&(MOV, to, from), perm);
        }
        _ => panic!("Unknown instruction"),
    }
}

// map a command over all permutations in a state
pub fn apply_all(cmd: &Command, state: &State) -> State {
    let mut new_state = Vec::new();
    for perm in state {
        let mut new_perm = perm.clone();
        apply(cmd, &mut new_perm);
        new_state.push(new_perm);
    }
    new_state.sort();
    new_state.dedup();
    new_state
}

pub fn apply_all_no_dedup(cmd: &Command, state: &State) -> State {
    let mut new_state = Vec::new();
    for perm in state {
        let mut new_perm = perm.clone();
        apply(cmd, &mut new_perm);
        new_state.push(new_perm);
    }
    new_state
}

// check if the state can never reach a solution
// corresponds to delete-relaxed planning check
pub fn viable(state: &State) -> bool {
    for perm in state {
        for n in 1..=NUMBERS_U8 {
            if !perm[0..REGS].contains(&n) {
                return false;
            }
        }
    }
    true
}

pub fn show_command(cmd: &Command) -> String {
    let (instr, to, from) = *cmd;
    // 1-indexed to stay consistent with minizinc
    let to = to+1;
    let from = from+1;
    match instr {
        CMP => format!("CMP {} {}", to, from),
        MOV => format!("MOV {} {}", to, from),
        CMOVG => format!("CMOVG {} {}", to, from),
        CMOVL => format!("CMOVL {} {}", to, from),
        _ => panic!("Unknown instruction"),
    }
}

// linked list to store the commands and pointer to last element
// https://rust-unofficial.github.io/too-many-lists/
// https://rust-unofficial.github.io/too-many-lists/second-option.html
#[derive(Clone, Eq, PartialEq, Hash)]
pub struct Node {
    pub cmd: Command,
    pub prev: Option<Box<Node>>,
}

// for each permutation, take out register values, concat => serializable byte array
// we could use perm_positions for more informed hashing/equality check
pub fn state_positions(state: &State) -> Vec<u8> {
    state.iter().flat_map(|p| p.0).collect()
}

pub fn extract_program(node: &Node) -> Vec<Command> {
    let mut cmds = vec![];
    let mut node = node;
    while let Some(prev) = &node.prev {
        cmds.push(node.cmd);
        node = prev;
    }
    cmds.reverse();
    cmds
}

pub const M_MOV: usize = 0; // movdqa
pub const M_MIN: usize = 1; // pminud => compare first and second, move smaller to first
pub const M_MAX: usize = 2;

pub fn minmax_possible_commands() -> Vec<Command> {
    let mut commands = vec![];
    for instr in &[M_MOV, M_MIN, M_MAX] {
        for to in 0..REGS {
            for from in 0..REGS {
                if to != from {
                    commands.push((*instr, to, from));
                }
            }
        }
    }
    commands
}


pub fn minmax_apply(cmd: &Command, perm: &mut Permutation) {
    let (instr, to, from) = *cmd;
    match instr {
        M_MOV => perm[to] = perm[from],
        M_MIN => {
            perm[to] = perm[to].min(perm[from]);
        }
        M_MAX => {
            perm[to] = perm[to].max(perm[from]);
        }
        _ => panic!("Unknown instruction"),
    }
}

pub fn minmax_apply_all(cmd: &Command, state: &State) -> State {
    let mut new_state = Vec::new();
    for perm in state {
        let mut new_perm = perm.clone();
        minmax_apply(cmd, &mut new_perm);
        new_state.push(new_perm);
    }
    new_state.sort();
    new_state.dedup();
    new_state
}

pub fn minmax_show_command(cmd: &Command) -> String {
    let (instr, to, from) = *cmd;
    // 1-indexed to stay consistent with minizinc
    // let to = to+1;
    // let from = from+1;
    let to = format!("%%xmm{}", to);
    let from = format!("%%xmm{}", from);
    match instr {
        M_MOV => format!("movdqa {}, {}", from, to),
        M_MIN => format!("pminud {}, {}", from, to),
        M_MAX => format!("pmaxud {}, {}", from, to),
        _ => panic!("Unknown instruction"),
    }
}
