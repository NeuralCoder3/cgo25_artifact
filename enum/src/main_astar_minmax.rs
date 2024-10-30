use itertools::Itertools;
// has largest value at the top
use priority_queue::PriorityQueue;
use std::cmp::Reverse;
use std::rc::Rc;
use std::io::Write;


pub mod common;
use common::*;

fn main() {
    let possible_cmds = minmax_possible_commands();
    let permutations: Vec<Vec<u8>> = (1..=NUMBERS_U8).permutations(NUMBERS).collect(); 
    let init_perm_count = permutations.len();


    // TODO: proxy queue via sled hashmap for all solution cases (large memory concumption 25GB (65 million states peak for n=4 with all solutions and cut))
    let mut queue = PriorityQueue::new();

    // find unused sled-mapX file in a temporary directory (_CONDOR_SCRATCH_DIR or /tmp/ else)
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
    // let mut candidates = 0;
    let mut cut : u64 = 0;

    // let mut file;
    // // #[cfg(feature = "store-canidates")]
    // {
    //     // environment variable if available
    //     // let tmp_file = std::env::var("TMP_FILE").unwrap_or("/home/s8maullr/results/tmp_len_15_all_perm.log".to_string());
    //     let tmp_file = std::env::var("TMP_FILE").unwrap_or("candidates.log".to_string());
    //     println!("Storing candidates in: {}", tmp_file);
    //     file = std::fs::File::create(tmp_file).unwrap();
    // }

    // list of previous states to reconstruct program
    // (we want all (shortest) predecessors hence a single one together with the state in the queue is (probably) not enough)
    // TODO: check if we get lists of length > 1
    // let mut prev_states : HashMap<Vec<u8>, Vec<Node>> = HashMap::new();

    // TODO: should be arguments not env
    // let all_solutions = std::env::var("ALL_SOLUTIONS").is_ok();

    // let mut solutions = vec![];
    let mut solution_count = 0;
    let solution_dir = std::env::var("SOLUTION_DIR").ok();
    let subdir = solution_dir.clone().map(|dir| format!("{}/{}_{}", dir, NUMBERS, MAX_LEN));
    if let Some(subdir) = &subdir {
        std::fs::create_dir_all(&subdir).unwrap();
        println!("Storing solutions in: {}", subdir);
    }else {
        println!("Not storing solutions");
    }



    let mut min_perm_count = [init_perm_count; (MAX_LEN as usize)+1];

    let start = std::time::Instant::now();
    while let Some(((prg,state,length), _)) = queue.pop() {
        visited += 1;
        if visited % 100000 == 0 {
            print!("Open: {}, ", queue.len());
            print!("Visited: {}, ", visited);
            print!("Duplicate: {}, ", duplicate);
            print!("Cut: {}, ", cut);
            // print!("Candidates: {}, ", candidates);
            print!("Current length: {}, ", length);
            if subdir.is_some() {
                print!("Solutions: {}, ", solution_count);
            }
            print!("Time: {:?}", start.elapsed());
            println!("");
            // #[cfg(feature = "store-canidates")]
            // file.sync_all().unwrap();
        }
        // if let Some(all_dir) = &all_dir {
        //     let file = format!("{}/state_{}_{}.txt", all_dir, length, visited);
        //     let mut file = std::fs::File::create(file).unwrap();
        //     let cmds = extract_program(&prg);
        //     for cmd in &cmds {
        //         writeln!(file, "{}", show_command(cmd)).unwrap();
        //     }
        // }

        // test twice => in between another state might have reopened it better
        // => ignore in this case
        // we do not directly catch propagation
        // but all effects will eventually be overwritten
        // only happens with heuristic
        // but heuristic is useful overall
        // for only one solution we could cut for <= if the = case is another predecessor
        // TODO: possible solution: keep track of queue, store length separately
        let state_repr = state_positions(&state);
        if let Some(state_len_vec) = length_map.get(&state_repr).unwrap() {
            if state_len_vec[0] < length {
                duplicate += 1;
                continue;
            }
        }


        // if state.iter().all(|p| p[0..NUMBERS] == state[0][0..NUMBERS]) {
        if state.iter().all(|p| p[0..NUMBERS] == (1..=NUMBERS_U8).collect::<Vec<_>>()) {
            // println!("Found solution: {:?} of length: {}", state, length);
            if solution_count == 0 {
                println!("Found first solution: {:?} of length: {}", state, length);
                print!("Time: {:?}", start.elapsed());
                println!("");
            }

            // reconstruct program
            // let mut prg = prg;
            // let mut cmds = vec![];
            // while let Some(node) = prg.prev {
            //     cmds.push(prg.cmd);
            //     prg = *node;
            // }
            // cmds.reverse();
            let cmds = extract_program(&prg);

            // solutions.push(cmds);
            solution_count += 1;
            if let Some(subdir) = &subdir {
                let file = format!("{}/solution_{}.txt", subdir, solution_count-1);
                let mut file = std::fs::File::create(file).unwrap();
                for cmd in &cmds {
                    writeln!(file, "{}", minmax_show_command(cmd)).unwrap();
                }
            }else {
                // if we do not store solutions, we are just interested in one
                println!("Program:");
                for cmd in cmds {
                    println!("{}", minmax_show_command(&cmd));
                }
                break;
            }
            continue;


            // break;
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
        // let commands = commands(&state);
        // let commands = 
        //     state.iter().flat_map(|p| useful_instructions.get(p).unwrap_or(&possible_cmds).iter())
        //     .unique()
        //     // .cloned()
        //     .collect::<Vec<_>>();

        // for cmd in &possible_cmds {
        for cmd in commands {
            let new_state = Rc::new(minmax_apply_all(&cmd, &state));
            let new_length = length + 1;

            if !viable(&new_state) {
                cut += 1;
                continue;
            }

            // TODO: move solution check here?

            // cut before insertion to save memory (and have value ready for heuristics)
            // let needed_instructions = new_state.iter().map(|p| instructions_needed.get(p).unwrap()).max().unwrap();
            // if needed_instructions + new_length > MAX_LEN {
            //     cut += 1;
            //     continue;
            // }
            if new_length > MAX_LEN {
                cut += 1;
                continue;
            }

            let new_perm_count = new_state.iter().map(|p| &p[0..NUMBERS]).unique().count();

            // TODO: why is this not subsumed by a*
            // why is it so good
            // why is it valid

            let new_length_u = new_length as usize;


                // try out cuts
        // 16s with state length (swaps)
        // 52s with perm count (without heuristic: 492s)

        // the cuts do not change the (naiv) solution count for n=3 
        // we still find 18 solutions

        // if min_perm_count[min(new_length_u,new_length_u-1)]+2 < new_state.len() {
        //     // works with 4
        //     cut += 1;
        //     continue;
        // } 
        // if min_perm_count[min(new_length_u,new_length_u-1)]+2 < new_perm_count {
        //     // works with 4
        //     cut += 1;
        //     continue;
        // } 

        // greedy check if there is a significant cut possible
        // works :O in 288s (keeps queue small (at least in the beginning))
        // if min_perm_count[new_length_u] * 2 < new_perm_count {
        //     cut += 1;
        //     continue;
        // }

        // non-greedy (preservative) check if there is a significant cut possible
        // together with above in 257s
        // if min_perm_count[min(new_length_u,new_length_u-1)] * 2 < new_perm_count {
        // if min_perm_count[length as usize] * 2 < new_perm_count {
        //     cut += 1;
        //     continue;
        // }

        // n = 4
        // +2    
        // *2    > 100s
        // *3/2  78s
        // *5/4  4.88s
        // *1    2.22s  (689s for n=5)
        // *4    > 140s
        // if min_perm_count[length as usize] < new_perm_count {
        //     cut += 1;
        //     continue;
        // }




        // if min_perm_count[new_length_u] < new_perm_count {
        //     cut += 1;
        //     continue;
        // }


        // safe cut (keeps 1642 for n=3)
        // if 2*min_perm_count[length as usize] < new_perm_count {
        //     cut += 1;
        //     continue;
        // }



        // for length (including swap states)
        // if min_perm_count[new_length_u] > new_state.len() {
        //     min_perm_count[new_length_u] = new_state.len();
        // }
        // only perm
        if min_perm_count[new_length_u] > new_perm_count {
            min_perm_count[new_length_u] = new_perm_count;
        }


            // if already found with smaller length, skip
            let state_repr = state_positions(&new_state);
            if let Some(old_length_vec) = length_map.get(&state_repr).unwrap() {
                let old_length = old_length_vec[0];
                // <= is much faster and valid to find one solution
                // with <= we find 18 solutions for n=3 (in 4s)
                // <, we find 1642 solutions for n=3 (in 38s)
                // if old_length <= new_length { //      solutions_min
                if old_length < new_length { // solutions_all
                    duplicate += 1;
                    continue;
                }else {
                    // TODO: do something
                    // println!("Found shorter path: {} -> {}", old_length, new_length);
                }
            }
            length_map.insert(state_repr, vec![new_length]).unwrap();

            /*
                For the heuristic, we could:
                - use the number of unique permutations remaining
                - use the number of unique register states remaining (permutations with flags and swaps)
                - the number of required swaps (roughly log of permutation count as each swap roughly halves the permutation count)
                - weight the swap count with 4 for rough instruction count
                - use the precomputed swap count (cayley distance)
                - use the number of instructions needed per permutation (precomputed -- relaxed plan ignoring dependencies)

                However, these seem to be slower (or not much faster) than the permutation count heuristic
             */


            let heuristic = new_perm_count as u8;
            // let heuristic = (new_state.len()) as u8;
            // try with instruction heuristic instead
            // let heuristic = new_state.iter().map(|p| instructions_needed[p]).max().unwrap();
            // let heuristic = 0;

            let new_score = new_length + heuristic;
            // we can use A* (f+h) or Dijkstra (f) or greedy (h)
            let prg = Node{cmd: *cmd, prev: prev_box.clone()};
            queue.push((prg,Rc::clone(&new_state),new_length), Reverse(new_score));
        }
    }

    // #[cfg(feature = "store-canidates")]
    // {
    // // close file
    // file.sync_all().unwrap();
    // drop(file);
    // }

    println!("Found {} solutions", solution_count);

    println!("Visited: {}, Duplicate: {}", visited, duplicate);
    println!("Elapsed: {:?}", start.elapsed());
}

// SOLUTION_DIR=vis_minmax/solutions_all_minmax _CONDOR_SCRATCH_DIR=./tmp2/ cargo run --release --bin minmax | tee -a vis_minmax/all_minmax_log.txt
// SOLUTION_DIR=vis_minmax/solutions_all_minmax_5_26 _CONDOR_SCRATCH_DIR=./tmp2/ cargo run --release --bin minmax | tee -a vis_minmax/all_minmax_5_26_log.txt