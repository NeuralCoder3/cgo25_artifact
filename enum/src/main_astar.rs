use itertools::Itertools;
use std::collections::VecDeque;
use std::collections::HashMap;
// has largest value at the top
use priority_queue::PriorityQueue;
use std::cmp::Reverse;
use std::rc::Rc;
use std::io::Write;

pub mod common;
use common::*;

fn main() {
    #[cfg(feature = "allsolutions")]
    {
        println!("Generating all solutions");
    }
    #[cfg(not(feature = "allsolutions"))]
    {
        println!("Generating minimal solutions");
    }

    // abort compilation if two heuristics are active
    #[cfg(any(
        all(feature = "heuristic1", feature = "heuristic2"),
        all(feature = "heuristic1", feature = "heuristic15"),
        all(feature = "heuristic2", feature = "heuristic15"),
    ))]
    {
        compile_error!("Two heuristics active");
    }

    #[cfg(any(
        all(feature = "n3", feature = "n5"),
        all(feature = "n3", feature = "n4"),
        all(feature = "n5", feature = "n4"),
    ))]
    {
        compile_error!("Two sizes selected");
    }


    let possible_cmds = possible_commands();
    let permutations: Vec<Vec<u8>> = (1..=NUMBERS_U8).permutations(NUMBERS).collect(); 
    let init_perm_count = permutations.len();

    let mut instructions_needed = HashMap::new();
    let mut swaps_needed = HashMap::new();
    // [u8] -> swap count
    {
        // via BFS from 1,...,NUMBERS -> until all permutations found
        let mut frontier = vec![];
        let mut init_perm = [0; NUMBERS];
        for (i, x) in init_perm.iter_mut().enumerate() {
            *x = (i+1) as u8;
        }
        frontier.push(init_perm);
        swaps_needed.insert(init_perm, 0);
        while let Some(perm) = frontier.pop() {
            let swaps = swaps_needed[&perm];
            for i in 0..NUMBERS {
                for j in (i + 1)..NUMBERS {
                    let mut new_perm = perm.clone();
                    new_perm.swap(i, j);
                    if !swaps_needed.contains_key(&new_perm) {
                        swaps_needed.insert(new_perm, swaps + 1);
                        frontier.push(new_perm);
                    }
                }
            }
        }
        println!("Computed swaps for {} permutations", swaps_needed.len());
        if swaps_needed.len() != init_perm_count {
            panic!("Not all permutations found");
        }
    }


    // now try any instructions -> relax heuristic (ignore all other dependencies)
    // could be used to only investigate programs that lead to a relaxed solution
    // there might be an instruction that is suboptimal across all individual but optimal global 
    // let's ignore that
    let mut useful_instructions = HashMap::new();
    {
        let mut frontier = VecDeque::new();
        let mut init_perm = Permutation([0; REGS + 2]);
        for (i, x) in init_perm[0..NUMBERS].iter_mut().enumerate() {
            *x = (i+1) as u8;
        }
        let init_perms : Vec<Permutation> = 
            // any swap and any flags
            // possible flags
            [(0,0), (0,1), (1,0), (1,1)].iter().map(|(lt,gt)| {
                // possible swap values
                // for general swap count, we need {0,...,N}^swap
                let numbers = (0..=NUMBERS_U8).collect::<Vec<u8>>();
                itertools::repeat_n(numbers, SWAPS).multi_cartesian_product().map(|swap| {
                    let mut new_perm = init_perm.clone();
                    for (i, &x) in swap.iter().enumerate() {
                        new_perm[NUMBERS+i] = x;
                    }
                    new_perm[REGS + 0] = *lt;
                    new_perm[REGS + 1] = *gt;
                    new_perm
                }).collect::<Vec<_>>()
            }).flatten().collect();
        for perm in init_perms {
            instructions_needed.insert(perm, 0);
            frontier.push_back(perm);
        }

        let commands = possible_commands();

        while let Some(perm) = frontier.pop_front() {
            let instructions = instructions_needed[&perm];
            for cmd in &commands {
                for new_perm in apply_invers(cmd, &perm) {
                    if !instructions_needed.contains_key(&new_perm) {
                        instructions_needed.insert(new_perm, instructions + 1);
                        frontier.push_back(new_perm);
                        // add cmd to vec of new_perm
                        useful_instructions.entry(new_perm).or_insert(vec![]).push(*cmd);
                    }
                }
            }
        }
        println!("Computed instructions for {} permutation states", instructions_needed.len());
    }

    // proxy queue via sled hashmap for all solution cases (large memory consumption 25GB (65 million states peak for n=4 with all solutions and cut))
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
            let mut perm = Permutation([0; REGS + 2]);
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

    let write_all = std::env::var("WRITE_ALL").is_ok();
    let mut solution_count = 0;
    let solution_dir = std::env::var("SOLUTION_DIR").ok();
    let subdir = solution_dir.clone().map(|dir| format!("{}/{}_{}", dir, NUMBERS, MAX_LEN));
    let all_dir = 
        if write_all {
            solution_dir.map(|dir| format!("{}/{}_{}_all", dir, NUMBERS, MAX_LEN))
        }else {
            None
        }
    ;
    if let Some(subdir) = &subdir {
        std::fs::create_dir_all(&subdir).unwrap();
        if let Some(all_dir) = &all_dir {
            std::fs::create_dir_all(&all_dir).unwrap();
        }
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
            print!("Current length: {}, ", length);
            if subdir.is_some() {
                print!("Solutions: {}, ", solution_count);
            }
            print!("Time: {:?}", start.elapsed());
            println!("");
        }
        if let Some(all_dir) = &all_dir {
            let file = format!("{}/state_{}_{}.txt", all_dir, length, visited);
            let mut file = std::fs::File::create(file).unwrap();
            let cmds = extract_program(&prg);
            for cmd in &cmds {
                writeln!(file, "{}", show_command(cmd)).unwrap();
            }
        }

        // test twice => in between another state might have reopened it better
        // => ignore in this case
        // we do not directly catch propagation
        // but all effects will eventually be overwritten
        // only happens with heuristic
        // but heuristic is useful overall
        // for only one solution we could cut for <= if the = case is another predecessor
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
                    writeln!(file, "{}", show_command(cmd)).unwrap();
                }
            }else {
                // if we do not store solutions, we are just interested in one
                println!("Program:");
                for cmd in cmds {
                    println!("{}", show_command(&cmd));
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

        #[cfg(feature = "optimalinstructions")]
        let commands = 
            state.iter().flat_map(|p| useful_instructions.get(p).unwrap_or(&possible_cmds).iter())
            .unique()
            .collect::<Vec<_>>();
        #[cfg(not(feature = "optimalinstructions"))]
        let commands = &possible_cmds;

        for cmd in commands {
            let new_state = Rc::new(apply_all(&cmd, &state));
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

            let new_length_u = new_length as usize;

            // greedy check if there is a significant cut possible
            // would be min_perm_count[new_length_u]

            // non-greedy (preservative) check if there is a significant cut possible
            #[cfg(feature = "heuristic2")]
            {
                if min_perm_count[length as usize]*2 < new_perm_count {
                    cut += 1;
                    continue;
                }
            }

            #[cfg(feature = "heuristic15")]
            {
                if min_perm_count[length as usize]*3/2 < new_perm_count {
                    cut += 1;
                    continue;
                }
            }

            #[cfg(feature = "heuristic1")]
            {
                if min_perm_count[length as usize] < new_perm_count {
                    cut += 1;
                    continue;
                }
            }

            if min_perm_count[new_length_u] > new_perm_count {
                min_perm_count[new_length_u] = new_perm_count;
            }


            // if already found with smaller length, skip
            let state_repr = state_positions(&new_state);
            if let Some(old_length_vec) = length_map.get(&state_repr).unwrap() {
                let old_length = old_length_vec[0];
                // <= is much faster and valid to find one solution (but not to find all solutions)
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

            /*
                For the heuristic, we could:
                - use the number of unique permutations remaining
                - use the number of unique register states remaining (permutations with flags and swaps)
                - the number of required swaps (roughly log of permutation count as each swap roughly halves the permutation count)
                - weight the swap count with 4 for rough instruction count
                - use the precomputed swap count (cayley distance)
                - use the number of instructions needed per permutation (precomputed -- relaxed plan ignoring dependencies)

                However, these are slower (or not much faster) than the permutation count heuristic
             */


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
