use itertools::Itertools;
use priority_queue::PriorityQueue;
use std::cmp::Reverse;
use std::rc::Rc;
use std::io::Write;

pub mod common;
use common::*;

// Nearly the same code as astar but specifics cut out (e.g. no cut heuristic, no preprocessing, ...)

fn main() {
    let possible_cmds = minmax_possible_commands();
    let permutations: Vec<Vec<u8>> = (1..=NUMBERS_U8).permutations(NUMBERS).collect(); 

    let mut queue = PriorityQueue::new();

    let tmp_dir = std::env::var("_CONDOR_SCRATCH_DIR").unwrap_or("/tmp".to_string());
    let mut i = 0;
    let mut path = format!("{}/sled-map{}", tmp_dir, i);
    while std::path::Path::new(&path).exists() {
        i += 1;
        path = format!("{}/sled-map{}", tmp_dir, i);
    }
    println!("Using sled map: {}", path);

    // if in git repository, print hash
    let git_hash = std::process::Command::new("git")
        .args(&["rev-parse", "--short", "HEAD"])
        .output()
        .expect("failed to execute git")
        .stdout;
    let git_hash = String::from_utf8(git_hash).unwrap();
    println!("Git hash: {}", git_hash);
    println!("n = {}", NUMBERS);
    println!("max_len = {}", MAX_LEN);
    println!("swaps = {}", SWAPS);


    let length_map = sled::open(path).unwrap();

    // extend numerical permutations with register for swap and flags
    // we use RC to avoid cloning the state
    let initial_state: Rc<State> = Rc::new(permutations
        .iter()
        .map(|p| {
            // +2 not needed but otherwise we have code duplication
            let mut perm = Permutation([0; REGS+2]);
            for (i, &x) in p.iter().enumerate() {
                perm[i] = x;
            }
            perm
        })
        .collect());

    length_map.insert(state_positions(&initial_state), vec![0 as u8]).unwrap();

    let node0 = Node{cmd: (0,0,0), prev: None};
    queue.push((node0,Rc::clone(&initial_state),0 as u8), Reverse(0));

    let mut visited : u64 = 0;
    let mut duplicate : u64 = 0;
    let mut cut : u64 = 0;

    let mut solution_count = 0;
    let solution_dir = std::env::var("SOLUTION_DIR").ok();
    let subdir = solution_dir.clone().map(|dir| format!("{}/{}_{}", dir, NUMBERS, MAX_LEN));
    if let Some(subdir) = &subdir {
        std::fs::create_dir_all(&subdir).unwrap();
        println!("Storing solutions in: {}", subdir);
    }else {
        println!("Not storing solutions");
    }

    let start = std::time::Instant::now();
    while let Some(((prg,state,length), _)) = queue.pop() {
        visited += 1;
        if visited % 100000 == 0 {
            print!("Open: {}, ", queue.len());
            print!("Visited: {}, ", visited);
            print!("Duplicate: {}, ", duplicate);
            print!("Cut: {}, ", cut);
            print!("Current length: {}, ", length);
            if subdir.is_some() {
                print!("Solutions: {}, ", solution_count);
            }
            print!("Time: {:?}", start.elapsed());
            println!("");
        }
        let state_repr = state_positions(&state);
        if let Some(state_len_vec) = length_map.get(&state_repr).unwrap() {
            if state_len_vec[0] < length {
                duplicate += 1;
                continue;
            }
        }


        if state.iter().all(|p| p[0..NUMBERS] == (1..=NUMBERS_U8).collect::<Vec<_>>()) {
            if solution_count == 0 {
                println!("Found first solution: {:?} of length: {}", state, length);
                print!("Time: {:?}", start.elapsed());
                println!("");
            }

            let cmds = extract_program(&prg);

            solution_count += 1;
            if let Some(subdir) = &subdir {
                let file = format!("{}/solution_{}.txt", subdir, solution_count-1);
                let mut file = std::fs::File::create(file).unwrap();
                for cmd in &cmds {
                    writeln!(file, "{}", minmax_show_command(cmd)).unwrap();
                }
            }else {
                println!("Program:");
                for cmd in cmds {
                    println!("{}", minmax_show_command(&cmd));
                }
                break;
            }
            continue;
        }

        // superseeded by check below => already do not insert into queue
        if length >= MAX_LEN {
            continue;
        }

        let prev_box = Some(Box::new(prg));

        let commands = &possible_cmds;
        // filter out min/max where from is 0 in any permutation
        let commands = commands.iter().filter(|cmd| {
            if cmd.0 == M_MIN || cmd.0 == M_MAX {
                let (_, _to, from) = **cmd;
                state.iter().all(|p| p[from] != 0)
            }else {
                true
            }
        }).collect::<Vec<_>>();

        for cmd in commands {
            let new_state = Rc::new(minmax_apply_all(&cmd, &state));
            let new_length = length + 1;

            if !viable(&new_state) {
                cut += 1;
                continue;
            }

            if new_length > MAX_LEN {
                cut += 1;
                continue;
            }

            let new_perm_count = new_state.iter().map(|p| &p[0..NUMBERS]).unique().count();

            // if already found with smaller length, skip
            let state_repr = state_positions(&new_state);
            if let Some(old_length_vec) = length_map.get(&state_repr).unwrap() {
                let old_length = old_length_vec[0];
                #[cfg(feature = "allsolutions")]
                {
                    if old_length < new_length { // solutions_all
                        duplicate += 1;
                        continue;
                    }else {
                        // println!("Found shorter path: {} -> {}", old_length, new_length);
                    }
                }
                #[cfg(not(feature = "allsolutions"))]
                {
                    if old_length <= new_length { // solutions_min
                        duplicate += 1;
                        continue;
                    }else {
                    }
                }
            }
            length_map.insert(state_repr, vec![new_length]).unwrap();

            let heuristic = new_perm_count as u8;
            let new_score = new_length + heuristic;
            // we can use A* (f+h) or Dijkstra (f) or greedy (h)
            let prg = Node{cmd: *cmd, prev: prev_box.clone()};
            queue.push((prg,Rc::clone(&new_state),new_length), Reverse(new_score));
        }
    }
    println!("Found {} solutions", solution_count);

    println!("Visited: {}, Duplicate: {}", visited, duplicate);
    println!("Elapsed: {:?}", start.elapsed());
}
